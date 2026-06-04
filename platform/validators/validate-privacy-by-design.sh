#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-privacy-by-design.sh — Enforce the privacy-by-design contract for
# projects activating the management/privacy-by-design overlay.
#
# Why this exists:
#   The management/privacy-by-design module implements Cavoukian's seven
#   Privacy by Design principles as a jurisdiction-neutral spine. Consumers
#   declare a legal regime (GDPR, CCPA, HIPAA, etc.) or an explicit "none"
#   exemption with a documented rationale. This validator is the declaration-
#   checking half of that contract: it confirms the privacy-profile.md exists
#   and is well-formed, checks consistency against any data-inventory.md, and
#   surfaces advisory WARN hits for privacy-risk indicators (analytics,
#   telemetry, third-party egress, PII-shaped logging).
#
#   Roadmap citation: PRD-0018 (design contract); ADR-0018 (Privacy by Design
#   posture); Phase 2 Task 5.
#
# Usage:
#   validate-privacy-by-design.sh [--block] [<manifest>] [<project-root>]
#   validate-privacy-by-design.sh --scan-file <path-to-privacy-profile>
#
# Behavior:
#   Main mode:
#     1. Parse the manifest, enumerate active modules.
#     2. If management/privacy-by-design is NOT active: exit 0 with a
#        "module inactive" message.
#     3. If active: read docs/privacy/privacy-profile.md, assert:
#          - File exists (exit 1 if missing).
#          - Declares a regime: either a non-empty `regime:` field (e.g.,
#            `regime: GDPR`) OR `regime: none` with a non-empty `exemption:`
#            field. If neither holds, exit 1.
#          - Consistency: if docs/privacy/data-inventory.md exists AND contains
#            personal-data entries (non-empty data rows) while the profile
#            declares `regime: none` — that is a contradiction — exit 1.
#     4. WARN layer (advisory, exit 0): scan the project tree for privacy-risk
#        indicators (analytics/telemetry keywords, third-party egress patterns,
#        PII-shaped logging, data-collection without nearby consent). Surface
#        hits on stderr. With `--block`: escalate WARN hits to exit 1.
#        Optional: if `regime: none` but sensitive-data-looking paths exist in
#        the tree and no data-inventory.md exists, emit a WARN and exit 0.
#
#   --scan-file mode:
#     Bypass active-module gating. Treat the given file as a privacy-profile.md.
#     Run ONLY the profile-parse + consistency checks (no tree WARN scan). Used
#     for fixture-firing tests. Exit 1 on parse/consistency failure, 0 on clean.
#
# Behavior detail — privacy-profile.md shape:
#   The validator reads a YAML frontmatter block between --- fences, looking for:
#     - `regime:` field — any non-empty string other than "none" is a declared
#       regime. "none" requires a non-empty `exemption:` field.
#   A profile file that has no frontmatter, an empty regime, or `regime: none`
#   without a non-empty exemption is considered unfilled and fails.
#
#   Consistency check (--scan-file mode):
#     If the profile contains `regime: none` AND the profile body (below the
#     closing --- fence) contains personal-data indicator rows (lines matching
#     `personal_data|personal-data|data_subject|PII` case-insensitively), the
#     validator treats that as a regime:none contradiction and exits 1.
#     (In gated mode the same contradiction is checked against data-inventory.md.)
#
# Exit codes:
#   0  validation passed (or module inactive)
#   1  validation failed (missing artifact, malformed profile, missing required
#      field, regime:none contradiction, or --block with WARN hits)
#   2  usage error

set -euo pipefail

# ----------------------------------------------------------------------
# Help
# ----------------------------------------------------------------------

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-privacy-by-design.sh — Enforce the privacy-by-design contract for
projects activating the management/privacy-by-design overlay.

Usage:
  validate-privacy-by-design.sh [--block] [<manifest>] [<project-root>]
  validate-privacy-by-design.sh --scan-file <path-to-privacy-profile>

Arguments:
  manifest      Path to harness.manifest.yaml (default: ./harness.manifest.yaml)
  project-root  Path to the project root (default: dirname of manifest)
  --block       Escalate WARN-layer privacy-risk hits to a non-zero exit;
                default off.
  --scan-file   Direct-content-test mode: validate an arbitrary
                privacy-profile-shaped file. Used for fixture-firing
                tests per PRD-0018.

Behavior (main mode):
  1. Parse the manifest, enumerate active modules.
  2. If management/privacy-by-design is NOT active in the active set:
     exit 0 with "module inactive — skipping" message.
  3. If active: read docs/privacy/privacy-profile.md, parse the YAML
     frontmatter between --- fences, assert:
       - regime: is a non-empty string (e.g. GDPR, CCPA, HIPAA, PIPEDA)
         OR regime: none with a non-empty exemption: field.
       - If docs/privacy/data-inventory.md exists and contains personal-data
         entries while the profile declares regime: none — contradiction — exit 1.
  4. Advisory WARN scan (exit 0): scan the project for privacy-risk
     indicators and surface hits on stderr. --block escalates to exit 1.

Behavior (--scan-file mode):
  Validates the profile-parse + consistency shape against an arbitrary file,
  bypassing active-module gating. The consistency check inspects the profile
  body itself for personal-data indicator lines (since no data-inventory.md
  is available in isolation). Useful for adversarial-fixture firing tests.

Exit codes:
  0  validation passed (or module inactive)
  1  validation failed
  2  usage error
USAGE
    exit 0
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
HARNESS_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PLATFORM_ROOT="${HARNESS_ROOT}/platform"

# ----------------------------------------------------------------------
# --scan-file mode — direct content test, no active-module enumeration
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
  ruby - "$TARGET_FILE" <<'RUBY_SCAN' || exit $?
require "yaml"

target = ARGV[0]
raw    = File.read(target)

# ----------------------------------------------------------------
# Frontmatter extraction
# ----------------------------------------------------------------
unless raw.start_with?("---\n") || raw.start_with?("---\r\n")
  warn "✗ #{target}: missing YAML frontmatter (expected '---' fence at line 1)"
  exit 1
end

parts = raw.split(/^---\s*$/, 3)
if parts.length < 3
  warn "✗ #{target}: malformed YAML frontmatter (could not locate closing '---' fence)"
  exit 1
end
fm_text = parts[1]
body    = parts[2]

begin
  fm = YAML.safe_load(fm_text)
rescue Psych::SyntaxError => e
  warn "✗ #{target}: YAML frontmatter parse error: #{e.message}"
  exit 1
end

unless fm.is_a?(Hash)
  warn "✗ #{target}: YAML frontmatter must be a mapping (got #{fm.class.name})"
  exit 1
end

# ----------------------------------------------------------------
# Regime validation
# ----------------------------------------------------------------
regime = fm["regime"]

if regime.nil? || (regime.is_a?(String) && regime.strip.empty?)
  warn "✗ #{target}: missing required field 'regime:' in frontmatter"
  warn "  → declare a legal regime (e.g. GDPR, CCPA, HIPAA) or regime: none"
  warn "  → if regime: none, also provide a non-empty 'exemption:' field"
  exit 1
end

unless regime.is_a?(String)
  warn "✗ #{target}: 'regime:' must be a string (got #{regime.class.name})"
  exit 1
end

regime = regime.strip

if regime == "none"
  exemption = fm["exemption"]
  if exemption.nil? || !exemption.is_a?(String) || exemption.strip.empty?
    warn "✗ #{target}: regime: none requires a non-empty 'exemption:' field"
    warn "  → document why this project is exempt from privacy-regime selection"
    exit 1
  end

  # ----------------------------------------------------------------
  # Consistency check — regime: none but personal-data indicator rows
  # in the profile body itself (used as the test-seam stand-in for
  # data-inventory.md in --scan-file mode).
  #
  # A contradiction requires at least one table data row (not a
  # separator row and not the first/header row) that matches
  # PERSONAL_DATA_PATTERN. A table with only a header row (no data
  # rows) is NOT a contradiction — that is an empty inventory.
  # ----------------------------------------------------------------
  PERSONAL_DATA_PATTERN = /personal[_-]data|data[_-]subject|PII/i.freeze
  DATA_ROW_PATTERN      = /^\|\s*\S/i.freeze

  # Collect table-looking rows from the body.
  body_table_rows = body.lines.select { |l| l.match?(DATA_ROW_PATTERN) }
  # Drop separator rows (only |---|:---:| etc. content).
  non_separator = body_table_rows.reject { |l| l.gsub(/[\|\-:\s]/, "").empty? }
  # Drop the first non-separator row (the column header row).
  data_rows = non_separator.drop(1)
  # Flag a contradiction only when a data row matches personal-data indicators.
  pd_hits = data_rows.select { |l| l.match?(PERSONAL_DATA_PATTERN) }

  if pd_hits.any?
    warn "✗ #{target}: regime: none but the profile body contains personal-data indicator rows"
    pd_hits.first(3).each { |l| warn "  → #{l.strip}" }
    warn "  → either declare an appropriate regime or remove the personal-data entries"
    exit 1
  end

  puts "✓ Privacy-profile validation passed (#{target}: regime=none, exemption declared)"
  exit 0
end

# Non-none regime — just needs to be a non-empty string (already checked above).
puts "✓ Privacy-profile validation passed (#{target}: regime=#{regime})"
exit 0
RUBY_SCAN
  exit 0
fi

# ----------------------------------------------------------------------
# Main mode — manifest-driven active-module gating
# ----------------------------------------------------------------------

BLOCK=0
if [[ "${1:-}" == "--block" ]]; then
  BLOCK=1
  shift
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

ruby -I "$LIB_DIR" -r harness_registry - "$MANIFEST" "$PLATFORM_ROOT" "$PROJECT_ROOT" "$BLOCK" <<'RUBY' || exit $?
require "yaml"

manifest_path = ARGV[0]
platform_root = ARGV[1]
project_root  = ARGV[2]
block_mode    = ARGV[3] == "1"

MODULE_ID    = "management/privacy-by-design".freeze
PROFILE_REL  = "docs/privacy/privacy-profile.md".freeze
INVENTORY_REL = "docs/privacy/data-inventory.md".freeze

# Privacy-risk WARN patterns (keyword-based, bounded grep).
WARN_PATTERNS = [
  { id: "analytics",    regex: /\b(analytics|telemetry|tracking|pageview)\b/i,
    label: "analytics/telemetry indicator" },
  { id: "pii-log",      regex: /\b(log|logger|logging|console)\b.*\b(email|password|phone|ssn|dob|birthdate|address|creditcard)\b/i,
    label: "PII-shaped logging" },
  { id: "egress",       regex: /\b(send|post|upload|transmit)\b.*\b(user|customer|personal|private)\b/i,
    label: "third-party data egress candidate" },
  { id: "collect-noconsent", regex: /\b(collect|gather|harvest)\b.*\b(data|information)\b/i,
    label: "data-collection without nearby consent indicator" },
].freeze

begin
  manifest = HarnessRegistry.load_manifest(manifest_path)
rescue HarnessRegistry::ManifestShapeError => e
  warn "✗ #{e.message}"
  exit 2
end

begin
  active_modules = HarnessRegistry.active_modules(platform_root, manifest)
rescue RuntimeError => e
  warn "usage error: #{e.message}"
  exit 2
end

# Active-module gating — the module is opt-in.
unless active_modules.any? { |m| m["id"] == "privacy-by-design" }
  puts "✓ Privacy-by-design validation skipped (management/privacy-by-design not active)"
  exit 0
end

# -----------------------------------------------------------------
# VALIDATE — module is active; profile must exist and be well-formed
# -----------------------------------------------------------------

profile_path = File.join(project_root, PROFILE_REL)
unless File.exist?(profile_path)
  warn "✗ Required artifact missing: #{PROFILE_REL}"
  warn "  → the management/privacy-by-design module is active but its required artifact is not present"
  warn "  → see platform/templates/privacy/privacy-profile.md for the template"
  exit 1
end

raw = File.read(profile_path)
unless raw.start_with?("---\n") || raw.start_with?("---\r\n")
  warn "✗ #{PROFILE_REL}: missing YAML frontmatter (expected '---' fence at line 1)"
  exit 1
end

parts = raw.split(/^---\s*$/, 3)
if parts.length < 3
  warn "✗ #{PROFILE_REL}: malformed YAML frontmatter (could not locate closing '---' fence)"
  exit 1
end
fm_text = parts[1]

begin
  fm = YAML.safe_load(fm_text)
rescue Psych::SyntaxError => e
  warn "✗ #{PROFILE_REL}: YAML frontmatter parse error: #{e.message}"
  exit 1
end

unless fm.is_a?(Hash)
  warn "✗ #{PROFILE_REL}: YAML frontmatter must be a mapping (got #{fm.class.name})"
  exit 1
end

regime = fm["regime"]

if regime.nil? || (regime.is_a?(String) && regime.strip.empty?)
  warn "✗ #{PROFILE_REL}: missing required field 'regime:' in frontmatter"
  warn "  → declare a legal regime (GDPR, CCPA, HIPAA, PIPEDA, etc.) or regime: none"
  exit 1
end

unless regime.is_a?(String)
  warn "✗ #{PROFILE_REL}: 'regime:' must be a string (got #{regime.class.name})"
  exit 1
end

regime = regime.strip

if regime == "none"
  exemption = fm["exemption"]
  if exemption.nil? || !exemption.is_a?(String) || exemption.strip.empty?
    warn "✗ #{PROFILE_REL}: regime: none requires a non-empty 'exemption:' field"
    warn "  → document why this project is exempt from privacy-regime selection"
    exit 1
  end

  # Consistency: regime: none + personal-data rows in data-inventory → contradiction.
  #
  # A contradiction requires at least one table data row (not a separator row
  # and not the first/header row) that matches PERSONAL_DATA_PATTERN. A table
  # with only a header row (no data rows) is NOT a contradiction — that is an
  # empty inventory.
  inventory_path = File.join(project_root, INVENTORY_REL)
  if File.exist?(inventory_path)
    PERSONAL_DATA_PATTERN = /personal[_-]data|data[_-]subject|PII/i.freeze
    DATA_ROW_PATTERN      = /^\|\s*\S/i.freeze
    inv_content = File.read(inventory_path)
    inv_table_rows = inv_content.lines.select { |l| l.match?(DATA_ROW_PATTERN) }
    # Drop separator rows (only |---|:---:| etc. content).
    non_separator_rows = inv_table_rows.reject { |l| l.gsub(/[\|\-:\s]/, "").empty? }
    # Drop the first non-separator row (the column header row).
    data_rows = non_separator_rows.drop(1)
    # Flag a contradiction only when a data row matches personal-data indicators.
    pd_hits = data_rows.select { |l| l.match?(PERSONAL_DATA_PATTERN) }
    if pd_hits.any?
      warn "✗ Contradiction: #{PROFILE_REL} declares regime: none but #{INVENTORY_REL}"
      warn "  contains #{pd_hits.length} personal-data indicator row(s)."
      warn "  → either remove the personal-data entries or declare an appropriate regime"
      exit 1
    end

    # An inventory with only a header row (empty table) is OK.
  end
end

puts "✓ Privacy-profile validation passed (#{PROFILE_REL}: regime=#{regime})"

# -----------------------------------------------------------------
# WARN layer — advisory privacy-risk indicator scan
# -----------------------------------------------------------------

warn_hits = 0

# Scan non-vendor source files for privacy-risk indicators.
scan_extensions = %w[.rb .py .js .ts .go .java .php .ex .exs .cs .swift .kt .rs .lua]
scan_dirs       = %w[src lib app cmd pkg].map { |d| File.join(project_root, d) }
                                         .select { |d| File.directory?(d) }

# Broad scan: if none of the standard dirs exist, skip the WARN scan silently.
unless scan_dirs.empty?
  Dir.glob(scan_dirs.map { |d| File.join(d, "**", "*") }.flatten).each do |path|
    next unless File.file?(path)
    next unless scan_extensions.include?(File.extname(path).downcase)

    begin
      content = File.read(path, encoding: "utf-8")
    rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError
      next
    end

    content.each_line.with_index(1) do |line, lineno|
      WARN_PATTERNS.each do |pat|
        if line.match?(pat[:regex])
          warn "⚠ #{path.sub(project_root + '/', '')}:#{lineno}: #{pat[:label]}: #{line.strip.slice(0, 120)}"
          warn_hits += 1
          break
        end
      end
    end
  end
end

# Advisory: regime: none but sensitive-data-looking paths in tree, no data-inventory.
if regime == "none"
  inventory_path = File.join(project_root, INVENTORY_REL)
  unless File.exist?(inventory_path)
    sensitive_globs = %w[pii personal consent user_data user-data privacy]
    SKIP_DIRS = %w[.git node_modules vendor dist].freeze
    found_sensitive = sensitive_globs.any? do |keyword|
      Dir.glob(File.join(project_root, "**", "*#{keyword}*"), File::FNM_CASEFOLD).any? do |p|
        rel = p.sub(project_root + "/", "")
        SKIP_DIRS.none? { |d| rel.start_with?("#{d}/") }
      end
    end
    if found_sensitive
      warn "⚠ regime: none but data-handling-looking paths detected in the project tree."
      warn "  → Consider re-evaluating the exemption or adding a data-inventory.md."
      warn_hits += 1
    end
  end
end

if warn_hits > 0
  warn ""
  if block_mode
    warn "✗ Privacy-by-design WARN scan: #{warn_hits} advisory hit(s) found (--block enabled)."
    exit 1
  else
    warn "ℹ Privacy-by-design WARN scan: #{warn_hits} advisory hit(s) surfaced (WARN posture; not failing CI)."
    warn "  Pass --block to escalate to hard fail."
    exit 0
  end
end

exit 0
RUBY
