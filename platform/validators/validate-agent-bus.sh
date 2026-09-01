#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
#
# validate-agent-bus.sh — contract-conformance linter for the agent-coordination
# bus (OPP-0061, promotes OPP-0059 / PRD-0039). Checks a bus-transcript JSONL
# against docs/coordination/control-loop-contract.md: envelope shape, per-type
# payload keys, the correlation-id rule, lifecycle validity per id, tier_ceiling
# sanity, and sync shape + size/rate caps.
#
# Bus messages are runtime/gitignored (.coordination/bus/), so there is no
# committed artifact for a per-PR gate. This linter is therefore a REFERENCE
# TOOL: an operator runs it against a live session (or a captured transcript),
# and CI runs it against committed fixtures to prove it is correct. It moves the
# schema/lifecycle/tier_ceiling checks from §10 Asserted-only to Half-enforced.
#
# Usage:
#   validate-agent-bus.sh --scan-file <bus-transcript.jsonl>
#     Validate every message (one JSON object per line). To check a live
#     session, concatenate an agent's inbox+outbox JSON into one JSONL first.
#
# Exit codes (harness 3-state):
#   0  clean, or WARN-only (sync caps / a Tier>=4 dispatch are advisory in v1)
#   1  at least one ERROR (a structural contract violation)
#   2  usage error (bad arguments / file not found)
#
# Configurable caps (env, WARN-level in v1 — the contract deferred these here):
#   AGENT_BUS_MAX_SYNC_STATE_BYTES   (default 8192)
#   AGENT_BUS_MAX_SYNC_PER_SENDER    (default 1 — coalesce; >N same-sender sync = WARN)
set -euo pipefail

if [[ "${1:-}" != "--scan-file" ]]; then
  echo "Usage: validate-agent-bus.sh --scan-file <bus-transcript.jsonl>" >&2
  exit 2
fi
shift
TARGET_FILE="${1:-}"
if [[ -z "$TARGET_FILE" ]]; then
  echo "✗ --scan-file requires a file path argument" >&2
  exit 2
fi
if [[ ! -f "$TARGET_FILE" ]]; then
  echo "✗ File not found: $TARGET_FILE" >&2
  exit 2
fi

MAX_SYNC_STATE_BYTES="${AGENT_BUS_MAX_SYNC_STATE_BYTES:-8192}" \
MAX_SYNC_PER_SENDER="${AGENT_BUS_MAX_SYNC_PER_SENDER:-1}" \
ruby - "$TARGET_FILE" <<'RUBY' || exit $?
require "json"
require "time"

TYPES = %w[dispatch ack progress done block sync verdict].freeze
# per-type required payload keys (control-loop-contract.md "Message types")
REQUIRED_PAYLOAD = {
  "dispatch" => %w[task], "ack" => [], "progress" => %w[note],
  "done" => %w[result], "block" => %w[reason], "sync" => %w[state],
  "verdict" => %w[decision rationale],
}.freeze
VERDICT_DECISIONS = %w[approve reject revise].freeze
ENVELOPE = %w[type id from to tier_ceiling ts payload].freeze
TERMINALS = %w[done block verdict].freeze

max_sync_bytes = Integer(ENV["MAX_SYNC_STATE_BYTES"])
max_sync_sender = Integer(ENV["MAX_SYNC_PER_SENDER"])

errors = []   # structural contract violations -> exit 1
warns  = []   # advisory (caps, high tier)     -> exit 0 with notice

path = ARGV[0]
lines = File.readlines(path)

# per-correlation-id ordered event list, for the lifecycle pass
chains = Hash.new { |h, k| h[k] = [] }
sync_by_sender = Hash.new(0)

lines.each_with_index do |raw, i|
  ln = i + 1
  next if raw.strip.empty?
  begin
    msg = JSON.parse(raw)
  rescue JSON::ParserError => e
    errors << "line #{ln}: malformed JSON (#{e.message.split("\n").first})"
    next
  end
  unless msg.is_a?(Hash)
    errors << "line #{ln}: message must be a JSON object"
    next
  end

  # envelope: required fields
  missing = ENVELOPE.reject { |f| msg.key?(f) }
  errors << "line #{ln}: missing envelope field(s): #{missing.join(', ')}" unless missing.empty?

  type = msg["type"]
  unless TYPES.include?(type)
    errors << "line #{ln}: unknown message type: #{type.inspect}"
    next
  end

  # tier_ceiling: an int (never bool — bool is an Integer subclass concern in some langs; be explicit)
  tc = msg["tier_ceiling"]
  if tc == true || tc == false || !tc.is_a?(Integer)
    errors << "line #{ln}: tier_ceiling must be an integer, got #{tc.inspect}"
  elsif tc < 0 || tc > 5
    errors << "line #{ln}: tier_ceiling #{tc} out of range 0..5"
  elsif type == "dispatch" && tc >= 4
    warns << "line #{ln}: dispatch tier_ceiling #{tc} is human-gated (Tier 4/5)"
  end

  # ts: parseable ISO-8601
  if msg.key?("ts")
    begin
      Time.iso8601(msg["ts"].to_s)
    rescue ArgumentError, TypeError
      errors << "line #{ln}: ts is not a parseable ISO-8601 timestamp: #{msg['ts'].inspect}"
    end
  end

  # to/from/id non-empty (to may be "*" only for sync)
  %w[from].each do |f|
    errors << "line #{ln}: #{f} must be a non-empty string" if msg[f].to_s.empty?
  end
  if msg["to"].to_s.empty?
    errors << "line #{ln}: to must be a non-empty string"
  elsif msg["to"] == "*" && type != "sync"
    errors << "line #{ln}: to \"*\" is only valid for a sync broadcast, not #{type}"
  end

  # per-type payload keys
  payload = msg["payload"]
  if payload.is_a?(Hash)
    (REQUIRED_PAYLOAD[type] || []).each do |k|
      errors << "line #{ln}: #{type} payload missing #{k.inspect}" unless payload.key?(k)
    end
    if type == "verdict" && payload.key?("decision") &&
       !VERDICT_DECISIONS.include?(payload["decision"])
      errors << "line #{ln}: verdict decision #{payload['decision'].inspect} not in " \
                "#{VERDICT_DECISIONS.inspect}"
    end
    if type == "sync" && payload.key?("state")
      bytes = JSON.generate(payload["state"]).bytesize
      if bytes > max_sync_bytes
        warns << "line #{ln}: sync state #{bytes}B exceeds cap #{max_sync_bytes}B"
      end
    end
  else
    errors << "line #{ln}: payload must be a JSON object"
  end

  # correlation: every non-dispatch/non-sync message carries an id
  if !%w[dispatch sync].include?(type) && msg["id"].to_s.empty?
    errors << "line #{ln}: #{type} must carry a correlation id"
  end

  # collect for lifecycle + rate passes
  if type == "sync"
    sync_by_sender[msg["from"]] += 1
  elsif !msg["id"].to_s.empty?
    chains[msg["id"]] << { ln: ln, type: type }
  end
end

# lifecycle validity per correlation id
chains.each do |id, events|
  types = events.map { |e| e[:type] }
  first_ln = events.first[:ln]
  unless types.first == "dispatch"
    errors << "id #{id.inspect} (line #{first_ln}): chain does not begin with a dispatch " \
              "(saw #{types.first})"
  end
  # a response before its ack (ack must precede any progress/terminal)
  ack_idx = types.index("ack")
  resp_idx = types.index { |t| %w[progress done block verdict].include?(t) }
  if resp_idx && (ack_idx.nil? || resp_idx < ack_idx)
    errors << "id #{id.inspect} (line #{first_ln}): a response precedes its ack"
  end
  # at most one terminal UNLESS a post-block retry dispatch reopens the chain
  term_positions = types.each_index.select { |k| TERMINALS.include?(types[k]) }
  term_positions.each do |tp|
    next if types[tp] != "done" && types[tp] != "verdict" # block may be followed by a retry
    later_dispatch = types[(tp + 1)..].to_a.include?("dispatch")
    trailing = types[(tp + 1)..].to_a.reject { |t| t == "dispatch" }
    unless trailing.empty? || later_dispatch
      errors << "id #{id.inspect}: activity after a #{types[tp]} terminal without a retry dispatch"
    end
  end
  if term_positions.count { |tp| %w[done verdict].include?(types[tp]) } > 1
    errors << "id #{id.inspect}: more than one success/verdict terminal"
  end
end

# sync rate (per-sender coalesce signal)
sync_by_sender.each do |sender, n|
  if n > max_sync_sender
    warns << "sender #{sender.inspect}: #{n} sync broadcasts exceed the coalesce cap " \
             "#{max_sync_sender} (WARN)"
  end
end

if !errors.empty?
  puts "✗ agent-bus conformance failed (#{errors.size} error(s)):"
  errors.each { |e| puts "  - #{e}" }
  warns.each  { |w| puts "  ~ WARN: #{w}" }
  exit 1
elsif !warns.empty?
  puts "✓ agent-bus conformance passed with #{warns.size} advisory warning(s):"
  warns.each { |w| puts "  ~ WARN: #{w}" }
  exit 0
else
  puts "✓ agent-bus transcript conforms to the control-loop contract " \
       "(#{lines.reject { |l| l.strip.empty? }.size} message(s))."
  exit 0
end
RUBY
