#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-observation-hygiene.sh — Lint newly-added shared observations
# against the ADR-0002 Observation Structure. The knowledge-ledger
# instance of the structured-agent-ledger gate (see
# docs/architecture/stigmergy.md § 4); the verdict-ledger instance is
# validate-coordination-verdicts.sh (OPP-0052).
#
# Why this exists:
#   management/knowledge-capture already enforces that a shared
#   observation EXISTS and CONNECTS (an audit-trail pointer, and — for
#   ADR/OPP/module edits — a paired PRD-0004 distillation entry). It
#   never checks the observation's SHAPE. ADR-0002 ratified a six-field
#   structure with two locked enums, but nothing lints an entry against
#   it, and a ratified schema with no validator drifts: at OPP-0053's
#   filing, 59% of live observations carried an off-enum Severity, the
#   most-severe canonical level (risk-bearing) was used 0×, and ~20%
#   omitted Confidence or Contributed-by. Severity is load-bearing — it
#   drives the escalation table (governance-relevant → revision tracker,
#   architectural → ADR, risk-bearing → risk register) — so off-enum
#   Severity silently defeats severity-driven escalation.
#
#   This validator is OPP-0053 Layer 1: a diff-based shape linter. It
#   checks each observation ADDED versus the base branch against the
#   ADR-0002 shape (six fields, both enums, an ISO date). It grandfathers
#   history — only diff-added records are linted, so the existing corpus
#   is never re-litigated. It asserts PRESENCE + ENUM MEMBERSHIP ONLY,
#   never the semantic quality of the judgement (honesty of the call is
#   an authoring act — the validate-module-stability boundary).
#
#   Roadmap citation: OPP-0053 (origin/evidence); PRD-0034 (design
#   contract, incl. the § 10 enforce-as-locked Severity classification);
#   ADR-0002 (the governed schema). Enforce-as-locked: off-enum values
#   fail on new observations; the enum is the contract, the drift is the
#   defect. If a future ADR amends either enum, the CONFIDENCE_ENUM /
#   SEVERITY_ENUM lists below follow in the same PR.
#
# Usage:
#   validate-observation-hygiene.sh [<manifest>] [<project-root>] [<base-branch>]
#   validate-observation-hygiene.sh --scan-file <path-to-observations-file>
#
# Behavior:
#   Main mode:
#     1. Parse the manifest, enumerate active modules.
#     2. If management/knowledge-capture is NOT active: exit 0 with a
#        "module inactive — skipping" message (predict-clean for that
#        consumer). The harness itself DOES activate knowledge-capture,
#        so its own CI runs this live (dogfood).
#     3. If active: diff docs/knowledge/shared-observations.md against
#        the base branch, collect the observations whose `### ` heading
#        was ADDED, and validate each against the ADR-0002 shape.
#     4. Outside a git tree / base ref absent (shallow CI, non-PR
#        dogfood): exit 0 with an informational message.
#
#   --scan-file mode:
#     Bypass active-module gating and git. Read the given file, treat
#     EVERY `### ` record as in-scope, and validate the ADR-0002 shape.
#     Used for fixture-firing tests per the validator-test-seam pattern.
#
# ADR-0002 shape (per newly-added observation):
#   - **Context:**, **Observation:**, **Implication:**, **Confidence:**,
#     **Severity:**, **Contributed by:** — all six present.
#   - Confidence ∈ {low, medium, high}
#   - Severity   ∈ {informational, governance-relevant, architectural,
#                   risk-bearing}   (enforce-as-locked)
#   - Contributed by carries a name/handle + an ISO-8601 date.
#   Enum checks are case-insensitive on the leading value token and
#   tolerate trailing prose (e.g. "high. The blast radius…").
#
# Exit codes:
#   0  validation passed (or module inactive, or nothing to lint)
#   1  one or more newly-added observations violate the ADR-0002 shape
#   2  usage error (missing manifest, bad project-root, missing git, …)

set -euo pipefail

# ----------------------------------------------------------------------
# Help
# ----------------------------------------------------------------------

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-observation-hygiene.sh — Lint newly-added shared observations
against the ADR-0002 Observation Structure (six fields, two locked
enums, an ISO date). Diff-based: only observations added vs. the base
branch are linted; history is grandfathered. Presence + enum membership
only — never the semantic quality of the judgement.

Usage:
  validate-observation-hygiene.sh [<manifest>] [<project-root>] [<base-branch>]
  validate-observation-hygiene.sh --scan-file <path-to-observations-file>

Arguments:
  manifest      Path to harness.manifest.yaml (default: ./harness.manifest.yaml)
  project-root  Path to the project root (default: dirname of manifest)
  base-branch   Git ref to diff against (default: main)
  --scan-file   Direct-content-test mode: validate every `### ` record in
                an arbitrary observations-shaped file, bypassing active-
                module gating and git. Used for fixture-firing tests.

ADR-0002 shape (per newly-added observation):
  Six fields present: Context, Observation, Implication, Confidence,
    Severity, Contributed by.
  Confidence ∈ {low, medium, high}
  Severity   ∈ {informational, governance-relevant, architectural,
                risk-bearing}   (enforce-as-locked)
  Contributed by carries a name/handle + an ISO-8601 date (e.g. 2026-07-11).

Behavior (main mode): module-gated on management/knowledge-capture.
Inactive → exit 0 (skip). Active → diff shared-observations.md vs. base,
lint each observation whose `### ` heading was added. Outside a git tree
or base ref absent → exit 0 (informational).

Exit codes:
  0  passed (or module inactive, or nothing to lint)
  1  a newly-added observation violates the ADR-0002 shape
  2  usage error
USAGE
    exit 0
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
HARNESS_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PLATFORM_ROOT="${HARNESS_ROOT}/platform"

OBSERVATIONS_REL="docs/knowledge/shared-observations.md"

# ----------------------------------------------------------------------
# --scan-file mode — direct content test, no active-module enumeration,
# no git; every `### ` record is in scope.
# ----------------------------------------------------------------------

if [[ "${1:-}" == "--scan-file" ]]; then
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
  MODE=scan-file ruby - "$TARGET_FILE" <<'RUBY' || exit $?
require "set"

# --- shared validation logic -----------------------------------------
CONFIDENCE_ENUM = %w[low medium high].freeze
SEVERITY_ENUM   = %w[informational governance-relevant architectural risk-bearing].freeze
FIELDS = ["Context", "Observation", "Implication", "Confidence", "Severity", "Contributed by"].freeze

def field_value(body, field)
  # Normalize each line (drop the leading "- " bullet and all "*" bold
  # markers) so both "- **Field:** v" and "- **Field**: v" parse the
  # same. ADR-0002 / the live ledger use the colon-inside-bold form.
  re = /\A#{Regexp.escape(field)}\s*:\s*(.*)\z/i
  body.each_line do |l|
    norm = l.sub(/^\s*-\s*/, "").gsub("*", "").strip
    m = norm.match(re)
    return m[1].strip if m
  end
  nil
end

def leading_token(val)
  m = val.to_s.strip.match(/\A([A-Za-z][A-Za-z-]*)/)
  m ? m[1].downcase : nil
end

def validate_record(heading, body)
  errors = []
  FIELDS.each do |f|
    errors << "missing field '**#{f}:**'" if field_value(body, f).nil?
  end

  if (c = field_value(body, "Confidence"))
    tok = leading_token(c)
    unless CONFIDENCE_ENUM.include?(tok)
      errors << "Confidence '#{c[0, 30]}' → '#{tok}' not in {#{CONFIDENCE_ENUM.join(', ')}}"
    end
  end

  if (s = field_value(body, "Severity"))
    tok = leading_token(s)
    unless SEVERITY_ENUM.include?(tok)
      hint = ""
      hint = " (low/medium are Confidence values; Severity is a separate enum)" if %w[low medium].include?(tok)
      hint = " (canonical spelling is 'architectural')" if tok == "architecture"
      errors << "Severity '#{s[0, 40]}' → '#{tok}' not in {#{SEVERITY_ENUM.join(', ')}}#{hint}"
    end
  end

  if (cb = field_value(body, "Contributed by"))
    has_date = cb.match?(/\d{4}-\d{2}-\d{2}/)
    name_part = cb.sub(/,?\s*\d{4}-\d{2}-\d{2}.*\z/m, "").strip
    errors << "Contributed by missing an ISO-8601 date (YYYY-MM-DD form)" unless has_date
    errors << "Contributed by missing a name/handle before the date" if name_part.empty?
  end

  errors
end

# Split a markdown body into observation records keyed by `### ` heading.
def parse_records(text)
  records = []
  current = nil
  text.each_line do |line|
    if (m = line.match(/^###\s+(.*)$/))
      records << current if current
      current = { heading: m[1].strip, body: +"" }
    elsif current
      current[:body] << line
    end
  end
  records << current if current
  records
end
# ---------------------------------------------------------------------

target = ARGV[0]
text = File.read(target)
records = parse_records(text)

if records.empty?
  puts "✓ Observation-hygiene validation passed (#{target}: no `### ` observation records found)."
  exit 0
end

total_violations = 0
records.each do |rec|
  errs = validate_record(rec[:heading], rec[:body])
  next if errs.empty?
  total_violations += errs.length
  warn "✗ #{target}: observation \"#{rec[:heading][0, 70]}\""
  errs.each { |e| warn "    - #{e}" }
end

if total_violations > 0
  warn ""
  warn "✗ Observation-hygiene validation failed: #{total_violations} shape violation(s) across #{records.length} record(s) in #{target}."
  warn "  ADR-0002 requires six fields; Confidence ∈ {#{CONFIDENCE_ENUM.join(', ')}}; Severity ∈ {#{SEVERITY_ENUM.join(', ')}}; Contributed-by name + ISO date."
  exit 1
end

puts "✓ Observation-hygiene validation passed (#{target}: #{records.length} record(s) conform to ADR-0002)."
exit 0
RUBY
  exit 0
fi

# ----------------------------------------------------------------------
# Main mode — manifest-driven active-module gating + diff-based scan
# ----------------------------------------------------------------------

MANIFEST="${1:-harness.manifest.yaml}"
PROJECT_ROOT="${2:-}"
BASE_BRANCH="${3:-main}"

if [[ ! -f "$MANIFEST" ]]; then
  echo "✗ Manifest not found: $MANIFEST" >&2
  exit 2
fi

if [[ -z "$PROJECT_ROOT" ]]; then
  PROJECT_ROOT="$(cd "$(dirname "$MANIFEST")" && pwd)"
fi

if [[ ! -d "$PROJECT_ROOT" ]]; then
  echo "✗ Project root not a directory: $PROJECT_ROOT" >&2
  exit 2
fi

if ! command -v git >/dev/null 2>&1; then
  echo "✗ git not available in PATH (required for diff-based scan)" >&2
  exit 2
fi

ruby -I "$LIB_DIR" -r harness_registry - "$MANIFEST" "$PLATFORM_ROOT" "$PROJECT_ROOT" "$BASE_BRANCH" "$OBSERVATIONS_REL" <<'RUBY' || exit $?
require "set"

# --- shared validation logic (kept identical to --scan-file block) ----
CONFIDENCE_ENUM = %w[low medium high].freeze
SEVERITY_ENUM   = %w[informational governance-relevant architectural risk-bearing].freeze
FIELDS = ["Context", "Observation", "Implication", "Confidence", "Severity", "Contributed by"].freeze

def field_value(body, field)
  # Normalize each line (drop the leading "- " bullet and all "*" bold
  # markers) so both "- **Field:** v" and "- **Field**: v" parse the
  # same. ADR-0002 / the live ledger use the colon-inside-bold form.
  re = /\A#{Regexp.escape(field)}\s*:\s*(.*)\z/i
  body.each_line do |l|
    norm = l.sub(/^\s*-\s*/, "").gsub("*", "").strip
    m = norm.match(re)
    return m[1].strip if m
  end
  nil
end

def leading_token(val)
  m = val.to_s.strip.match(/\A([A-Za-z][A-Za-z-]*)/)
  m ? m[1].downcase : nil
end

def validate_record(heading, body)
  errors = []
  FIELDS.each do |f|
    errors << "missing field '**#{f}:**'" if field_value(body, f).nil?
  end

  if (c = field_value(body, "Confidence"))
    tok = leading_token(c)
    unless CONFIDENCE_ENUM.include?(tok)
      errors << "Confidence '#{c[0, 30]}' → '#{tok}' not in {#{CONFIDENCE_ENUM.join(', ')}}"
    end
  end

  if (s = field_value(body, "Severity"))
    tok = leading_token(s)
    unless SEVERITY_ENUM.include?(tok)
      hint = ""
      hint = " (low/medium are Confidence values; Severity is a separate enum)" if %w[low medium].include?(tok)
      hint = " (canonical spelling is 'architectural')" if tok == "architecture"
      errors << "Severity '#{s[0, 40]}' → '#{tok}' not in {#{SEVERITY_ENUM.join(', ')}}#{hint}"
    end
  end

  if (cb = field_value(body, "Contributed by"))
    has_date = cb.match?(/\d{4}-\d{2}-\d{2}/)
    name_part = cb.sub(/,?\s*\d{4}-\d{2}-\d{2}.*\z/m, "").strip
    errors << "Contributed by missing an ISO-8601 date (YYYY-MM-DD form)" unless has_date
    errors << "Contributed by missing a name/handle before the date" if name_part.empty?
  end

  errors
end

def parse_records(text)
  records = []
  current = nil
  text.each_line do |line|
    if (m = line.match(/^###\s+(.*)$/))
      records << current if current
      current = { heading: m[1].strip, body: +"" }
    elsif current
      current[:body] << line
    end
  end
  records << current if current
  records
end
# ---------------------------------------------------------------------

manifest_path = ARGV[0]
platform_root = ARGV[1]
project_root  = ARGV[2]
base_branch   = ARGV[3]
obs_rel       = ARGV[4]

MODULE_ID = "management/knowledge-capture".freeze

begin
  manifest = HarnessRegistry.load_manifest(manifest_path)
rescue HarnessRegistry::ManifestShapeError => e
  warn "✗ #{e.message}"
  exit 2
end

active_modules = HarnessRegistry.active_modules(platform_root, manifest)

# Active-module gating. knowledge-capture is opt-in for consumers; the
# harness itself DOES activate it, so the harness's own CI runs this live.
unless active_modules.any? { |m| m["id"] == "knowledge-capture" || m["__id_with_type"] == MODULE_ID }
  puts "✓ Observation-hygiene validation skipped (management/knowledge-capture not active)."
  exit 0
end

obs_path = File.join(project_root, obs_rel)
unless File.exist?(obs_path)
  puts "✓ Observation-hygiene validation passed (no #{obs_rel} present in this project)."
  exit 0
end

Dir.chdir(project_root)

unless system("git rev-parse --is-inside-work-tree > /dev/null 2>&1")
  puts "ℹ Not inside a git working tree; skipping diff-based observation scan."
  exit 0
end

unless system("git rev-parse --verify #{base_branch} > /dev/null 2>&1")
  puts "ℹ Base ref #{base_branch} not present locally; skipping diff-based observation scan."
  exit 0
end

# Collect the headings whose `### ` line was ADDED in the diff vs. base.
diff = `git diff --unified=0 #{base_branch}...HEAD -- #{obs_rel} 2>/dev/null`
added_headings = Set.new
diff.each_line do |l|
  # Added observation heading: `+### Heading text`. The `+++` file header
  # cannot match because it has no space after three chars.
  if (m = l.match(/^\+###\s+(.*)$/))
    added_headings << m[1].strip
  end
end

if added_headings.empty?
  puts "✓ Observation-hygiene validation passed (no newly-added observations vs. #{base_branch})."
  exit 0
end

# Read the CURRENT file and validate the full record for each new heading.
records = parse_records(File.read(obs_path))
in_scope = records.select { |r| added_headings.include?(r[:heading]) }

total_violations = 0
in_scope.each do |rec|
  errs = validate_record(rec[:heading], rec[:body])
  next if errs.empty?
  total_violations += errs.length
  warn "✗ #{obs_rel}: newly-added observation \"#{rec[:heading][0, 70]}\""
  errs.each { |e| warn "    - #{e}" }
end

if total_violations > 0
  warn ""
  warn "✗ Observation-hygiene validation failed: #{total_violations} ADR-0002 shape violation(s) across #{in_scope.length} newly-added observation(s)."
  warn "  Six fields required; Confidence ∈ {#{CONFIDENCE_ENUM.join(', ')}}; Severity ∈ {#{SEVERITY_ENUM.join(', ')}} (enforce-as-locked); Contributed-by name + ISO date."
  warn "  History is grandfathered — only observations added vs. #{base_branch} are linted."
  exit 1
end

puts "✓ Observation-hygiene validation passed (#{in_scope.length} newly-added observation(s) conform to ADR-0002)."
exit 0
RUBY
