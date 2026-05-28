#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-skill-content.sh — Scan authored prose in active modules
# against a denylist of prompt-injection and tier-bypass patterns.
#
# Why this exists:
#   The framework's authored prose — module.yaml description-class
#   fields, SKILL.md bodies, compiledFragments markdown — is loaded
#   into downstream AI agent contexts at session start. This makes
#   the prose an attack surface. The current defense is human review
#   (CODEOWNERS plus maintainer scrutiny). That is necessary but not
#   structurally sufficient against a contributor or maintainer
#   mistake; a deny-list validator closes the gap at the structural
#   layer.
#
#   Roadmap citation: ADR-0017 (Safety Hardening Roadmap) Wave 5.2;
#   PRD-0015 (design contract); OPP-0033 (origin / evidence).
#   Closes safety-security-sweep §3 vectors V1, V2, V4 (partial), V6.
#
# Usage:
#   validate-skill-content.sh [--verbose] [<manifest>] [<project-root>]
#
# Behavior:
#   1. Parse the manifest, enumerate active modules.
#   2. For each active module collect the v1 scanned-fields set:
#      (a) module.yaml top-level: description, summary, reviewGates[]
#      (b) module.yaml companionRules[].humanReview
#      (c) every SKILL.md body referenced by the module's
#          recommendedSkills list (resolved to platform/skills/<name>/SKILL.md)
#      (d) every markdown file referenced by compiledFragments[]
#   3. For each gathered text, scan against the built-in denylist
#      of prompt-injection and tier-bypass patterns (per PRD-0015
#      Technical Constraints, sourced from safety-security-sweep §3
#      Recommendation 2).
#   4. Apply .skill-content-ignore exemption file at project root
#      (line-regex format mirroring .doc-reference-ignore /
#      .placeholder-ignore / .knowledge-redaction-ignore).
#   5. Surface hits to stderr with file/source + line + matched
#      pattern + a suggested-fix hint per PRD-0015 FR-S01.
#   6. Default posture: BLOCK (exit 1 on any unexempted hit). Per
#      PRD-0015 FR-003 — the absorption mechanism is predict-clean
#      (the harness's own authored prose is predicted to pass).
#
#   Pattern source — each is cited inline below:
#     P01: ignore previous instructions (sweep §3 Rec 2 — V1/V2)
#     P02: treat as Tier [0-5] (V4 partial)
#     P03: always operates? at Tier (V4 partial)
#     P04: skip (the )?validator (V2)
#     P05: supersedes? harness-governance (V4/V6)
#     P06: ^System: at line start (role-prompt header, V2)
#     P07: ^User: at line start (role-prompt header, V2)
#     P08: ^Assistant: at line start (role-prompt header, V2)
#     P09: zero-width characters U+200B/200C/200D/FEFF (V1/V2)
#     P10: Unicode bidi marks U+202A-202E, U+2066-2069 (V1/V2)
#
# Exit codes:
#   0  no unexempted hits (validation passed)
#   1  unexempted denylist match(es) found
#   2  usage error (missing manifest, bad project root, etc.)

set -euo pipefail

# ----------------------------------------------------------------------
# Help
# ----------------------------------------------------------------------

VERBOSE=0
case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-skill-content.sh — Scan authored prose for prompt-injection
and tier-bypass patterns in active modules.

Usage:
  validate-skill-content.sh [--verbose] [<manifest>] [<project-root>]

Arguments:
  --verbose     List exempted hits with the regex that matched.
  manifest      Path to harness.manifest.yaml (default: ./harness.manifest.yaml)
  project-root  Path to the project root (default: dirname of manifest)

Scanned fields per active module (PRD-0015 FR-001):
  - module.yaml: description, summary, reviewGates[], companionRules[].humanReview
  - SKILL.md bodies referenced via recommendedSkills[]
  - markdown files referenced via compiledFragments[]

Denylist (v1 seed — PRD-0015 Technical Constraints, sourced from
safety-security-sweep §3 Recommendation 2):
  P01 ignore previous instructions
  P02 treat as Tier [0-5]
  P03 always operates at Tier
  P04 skip (the) validator
  P05 supersedes harness-governance
  P06–P08 role-prompt headers (^System:, ^User:, ^Assistant:)
  P09 zero-width characters (U+200B, U+200C, U+200D, U+FEFF)
  P10 Unicode bidirectional override marks (U+202A–202E, U+2066–2069)

Exemptions:
  Add line-regex patterns to .skill-content-ignore in the project root.
  One regex per line; # comments allowed. A line matching any pattern
  is exempted from scanning. Format mirrors .doc-reference-ignore,
  .placeholder-ignore, and .knowledge-redaction-ignore.

Default posture is BLOCK (exit 1 on any unexempted hit). Unlike
validate-knowledge-redaction.sh's WARN posture, the framework's own
authored prose surface has zero known historical violations; v1
ships as hard-fail from PR 1 (predict-clean absorption mechanism per
feedback-validator-absorption-mechanisms).

Exit codes:
  0  no unexempted hits
  1  unexempted hits found
  2  usage error
USAGE
    exit 0
    ;;
esac

if [[ "${1:-}" == "--verbose" ]]; then
  VERBOSE=1
  shift
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
HARNESS_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PLATFORM_ROOT="${HARNESS_ROOT}/platform"

# --scan-file mode: scan a single arbitrary file's content against the
# denylist, without enumerating active modules. Useful for testing
# fixtures and for ad-hoc adversarial-corpus checks. Output format
# matches the main-mode scan — same per-line surfacing + same exit
# code semantics (0 clean, 1 hit, 2 usage).
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
  ruby -I "$LIB_DIR" - "$TARGET_FILE" "$VERBOSE" <<'RUBY_SCAN' || exit $?
target  = ARGV[0]
verbose = ARGV[1] == "1"

DENYLIST = [
  ["P01", /ignore\s+previous\s+instructions/i,                 "ignore-previous-instructions"],
  ["P02", /treat\s+as\s+Tier\s+[0-5]/i,                        "treat-as-Tier"],
  ["P03", /always\s+operates?\s+at\s+Tier/i,                   "always-operates-at-Tier"],
  ["P04", /skip\s+(?:the\s+)?validator/i,                      "skip-the-validator"],
  ["P05", /supersedes?\s+harness-governance/i,                 "supersedes-harness-governance"],
  ["P06", /^System:\s/,                                        "System-role-header"],
  ["P07", /^User:\s/,                                          "User-role-header"],
  ["P08", /^Assistant:\s/,                                     "Assistant-role-header"],
  ["P09", /[​‌‍﻿]/,                                            "zero-width-char"],
  ["P10", /[‪-‮⁦-⁩]/,                                          "bidi-override-char"]
].freeze

hits = 0
File.readlines(target).each_with_index do |raw, idx|
  line = raw.chomp
  DENYLIST.each do |pid, re, label|
    next unless re.match?(line)
    excerpt = line.length > 100 ? "#{line[0, 100]}…" : line
    warn "✗ #{target}:#{idx + 1}: #{pid} (#{label}) matched in: #{excerpt}"
    hits += 1
  end
end

if hits > 0
  warn "✗ Scan-file mode: #{hits} hit(s) in #{target}"
  exit 1
end
puts "✓ Scan-file mode: clean (no denylist matches in #{target})"
exit 0
RUBY_SCAN
  # --scan-file mode is exclusive — don't fall through to main scan.
  exit 0
fi

MANIFEST="${1:-harness.manifest.yaml}"
PROJECT_ROOT="${2:-}"

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

# ----------------------------------------------------------------------
# Delegate to Ruby for YAML parsing, file enumeration, content scanning.
# ----------------------------------------------------------------------

ruby -I "$LIB_DIR" -r harness_registry - "$MANIFEST" "$PLATFORM_ROOT" "$PROJECT_ROOT" "$VERBOSE" <<'RUBY' || exit $?
manifest_path = ARGV[0]
platform_root = ARGV[1]
project_root  = ARGV[2]
verbose       = ARGV[3] == "1"

begin
  manifest = HarnessRegistry.load_manifest(manifest_path)
rescue HarnessRegistry::ManifestShapeError => e
  warn "✗ #{e.message}"
  exit 2
end

active_modules = HarnessRegistry.active_modules(platform_root, manifest)

# v1 denylist — each entry is [id, regex, suggested_fix_hint]. Pattern
# sources are cited inline per FR-002 + PRD-0015 Technical Constraints
# (safety-security-sweep §3 Recommendation 2 is the canonical source).
DENYLIST = [
  ["P01", /ignore\s+previous\s+instructions/i,
   "rephrase to avoid the injection-canonical phrase 'ignore previous instructions'"],
  ["P02", /treat\s+as\s+Tier\s+[0-5]/i,
   "rephrase tier reference — direct tier-assignment phrasing is V4 attack-surface"],
  ["P03", /always\s+operates?\s+at\s+Tier/i,
   "rephrase tier reference — 'always operates at Tier N' is V4 attack-surface"],
  ["P04", /skip\s+(?:the\s+)?validator/i,
   "rephrase — 'skip the validator' phrasing is direct V2 bypass instruction"],
  ["P05", /supersedes?\s+harness-governance/i,
   "rephrase authority claim — 'supersedes harness-governance' is V4/V6 attack-surface"],
  ["P06", /^System:\s/,
   "rephrase or escape — '^System:' at line start is a role-prompt header (V2)"],
  ["P07", /^User:\s/,
   "rephrase or escape — '^User:' at line start is a role-prompt header (V2)"],
  ["P08", /^Assistant:\s/,
   "rephrase or escape — '^Assistant:' at line start is a role-prompt header (V2)"],
  ["P09", /[​‌‍﻿]/,
   "remove zero-width characters (U+200B/200C/200D/FEFF) — invisible injection vector"],
  ["P10", /[‪-‮⁦-⁩]/,
   "remove Unicode bidirectional override marks — invisible-reorder injection vector"]
].freeze

# Load exemption patterns from .skill-content-ignore (if present).
ignore_path = File.join(project_root, ".skill-content-ignore")
ignore_patterns = []
if File.exist?(ignore_path)
  File.readlines(ignore_path).each do |raw|
    line = raw.chomp
    next if line.strip.empty?
    next if line.strip.start_with?("#")
    begin
      ignore_patterns << Regexp.new(line)
    rescue RegexpError => e
      warn "✗ .skill-content-ignore: invalid regex on line #{raw.inspect}: #{e.message}"
      exit 2
    end
  end
end

def line_exempted?(content, ignore_patterns)
  ignore_patterns.any? { |re| re.match?(content) }
end

# Gather (source_label, content_lines) tuples per FR-001 scanned-fields set.
sources = []  # each: [label_for_error, [lines_with_index]]

def push_text(sources, label, text)
  return unless text.is_a?(String) && !text.empty?
  lines = text.split("\n").each_with_index.map { |l, i| [i + 1, l] }
  sources << [label, lines]
end

def push_strings(sources, label, arr)
  Array(arr).each_with_index do |item, idx|
    next unless item.is_a?(String)
    push_text(sources, "#{label}[#{idx}]", item)
  end
end

active_modules.each do |mod|
  mod_id = mod["id"] || "(unknown)"
  mod_path = mod["__path"] || "(unknown)"

  # (a) module.yaml top-level scanned fields
  push_text(sources, "#{mod_path}:description", mod["description"])
  push_text(sources, "#{mod_path}:summary", mod["summary"])
  push_strings(sources, "#{mod_path}:reviewGates", mod["reviewGates"])

  # (b) companionRules[].humanReview
  Array(mod["companionRules"]).each_with_index do |rule, idx|
    next unless rule.is_a?(Hash)
    push_text(sources, "#{mod_path}:companionRules[#{idx}].humanReview", rule["humanReview"])
  end

  # (c) SKILL.md bodies referenced by recommendedSkills[]
  Array(mod["recommendedSkills"]).each do |skill_name|
    next unless skill_name.is_a?(String)
    skill_md = File.join(platform_root, "skills", skill_name, "SKILL.md")
    next unless File.exist?(skill_md)
    push_text(sources, skill_md, File.read(skill_md))
  end

  # (d) compiledFragments[] markdown bodies
  Array(mod["compiledFragments"]).each do |frag_rel|
    next unless frag_rel.is_a?(String)
    # compiledFragments paths are repo-root-relative in current usage
    # (e.g. "platform/core/kernel/base/doctrine.md").
    candidates = [
      File.join(project_root, frag_rel),
      File.join(platform_root, "..", frag_rel)
    ]
    found = candidates.find { |c| File.exist?(c) }
    next unless found
    push_text(sources, found, File.read(found))
  end
end

# Scan.
violations = 0
exempted_count = 0

sources.each do |label, lines|
  lines.each do |lineno, content|
    DENYLIST.each do |pid, re, hint|
      next unless re.match?(content)
      if line_exempted?(content, ignore_patterns)
        exempted_count += 1
        if verbose
          excerpt = content.length > 100 ? "#{content[0, 100]}…" : content
          warn "ℹ exempted: #{label}:#{lineno}: #{pid} match in: #{excerpt}"
        end
      else
        excerpt = content.length > 100 ? "#{content[0, 100]}…" : content
        warn "✗ #{label}:#{lineno}: #{pid} matched in: #{excerpt}"
        warn "  → #{hint}"
        warn "  → if pedagogical / documentary, add to .skill-content-ignore with justification"
        violations += 1
      end
    end
  end
end

if violations > 0
  warn ""
  warn "✗ Skill-content validation failed: #{violations} unexempted denylist match(es) across #{sources.size} scanned source(s)."
  warn "  Default posture is BLOCK (predict-clean absorption mechanism)."
  exit 1
end

if sources.empty?
  puts "✓ Skill-content validation passed (no scanned sources — no active modules with description/summary/reviewGates/SKILL.md/compiledFragments)."
elsif exempted_count > 0
  puts "✓ Skill-content validation passed (#{sources.size} sources scanned; #{exempted_count} exempted via .skill-content-ignore)."
else
  puts "✓ Skill-content validation passed (#{sources.size} sources scanned; zero denylist matches)."
end
exit 0
RUBY
