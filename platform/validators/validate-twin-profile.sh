#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-twin-profile.sh — Enforce the twin-profile contract for projects
# activating the management/digital-twin overlay.
#
# Why this exists:
#   The management/digital-twin module implements a maturity-gated twin-profile
#   forcing artifact. Consumers declare a maturity level, standards conformance
#   (with status: published vs emerging), and the governing Gemini Principles.
#   This validator is the declaration-checking half of that contract: it confirms
#   docs/twin/twin-profile.md exists and is well-formed, and guards against the
#   most dangerous overclaim — citing a known-emerging standard as ratified.
#
#   Roadmap citation: PRD-0023 (design contract); Phase 2 Task 3.
#
# Usage:
#   validate-twin-profile.sh [--block] [<manifest>] [<project-root>]
#   validate-twin-profile.sh --scan-file <path-to-twin-profile>
#
# Behavior:
#   Main mode:
#     1. Parse the manifest, enumerate active modules.
#     2. If management/digital-twin is NOT active: exit 0 with a
#        "module inactive" message.
#     3. If active: read docs/twin/twin-profile.md, assert:
#          - File exists (exit 1 if missing).
#          - maturity: field is non-empty.
#          - conformance: field contains at least one entry.
#          - governingPrinciples: field is non-empty.
#          - No conformance entry marks a known-emerging standard as
#            status: published (overclaim guard).
#          Known-emerging: ISO 23247-5, ISO 23247-6, ISO/IEC 30188.
#     4. WARN posture (advisory, exit 0): with `--block`, escalate to exit 1.
#
#   --scan-file mode:
#     Bypass active-module gating. Treat the given file as a twin-profile.md.
#     Run ONLY the profile-parse checks (no tree WARN scan). Used for
#     fixture-firing tests. Exit 1 on parse/check failure, 0 on clean.
#
# Exit codes:
#   0  validation passed (or module inactive)
#   1  validation failed (missing artifact, malformed profile, missing required
#      field, emerging-as-published overclaim, or --block with WARN hits)
#   2  usage error

set -euo pipefail

# ----------------------------------------------------------------------
# Help
# ----------------------------------------------------------------------

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-twin-profile.sh — Enforce the twin-profile contract for projects
activating the management/digital-twin overlay.

Usage:
  validate-twin-profile.sh [--block] [<manifest>] [<project-root>]
  validate-twin-profile.sh --scan-file <path-to-twin-profile>

Arguments:
  manifest      Path to harness.manifest.yaml (default: ./harness.manifest.yaml)
  project-root  Path to the project root (default: dirname of manifest)
  --block       Escalate WARN-layer hits to a non-zero exit; default off.
  --scan-file   Direct-content-test mode: validate an arbitrary
                twin-profile-shaped file. Used for fixture-firing
                tests per PRD-0023.

Behavior (main mode):
  1. Parse the manifest, enumerate active modules.
  2. If management/digital-twin is NOT active in the active set:
     exit 0 with "module inactive — skipping" message.
  3. If active: read docs/twin/twin-profile.md, parse the YAML
     frontmatter between --- fences, assert:
       - maturity: is a non-empty string
       - conformance: is a non-empty list
       - governingPrinciples: is a non-empty string
       - No conformance entry marks a known-emerging standard
         (ISO 23247-5, ISO 23247-6, ISO/IEC 30188) as status: published
  4. Advisory WARN posture (exit 0). --block escalates to exit 1.

Behavior (--scan-file mode):
  Validates the profile-parse + overclaim-guard checks against an
  arbitrary file, bypassing active-module gating. Useful for fixture
  firing tests.

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
# Maturity validation
# ----------------------------------------------------------------
maturity = fm["maturity"]

if maturity.nil? || (maturity.is_a?(String) && maturity.strip.empty?)
  warn "✗ #{target}: missing required field 'maturity:' in frontmatter"
  warn "  → declare a maturity level: digital-model | digital-shadow | digital-twin-prototype | operational-twin | control-loop"
  exit 1
end

unless maturity.is_a?(String)
  warn "✗ #{target}: 'maturity:' must be a string (got #{maturity.class.name})"
  exit 1
end

maturity = maturity.strip

# ----------------------------------------------------------------
# Conformance validation
# ----------------------------------------------------------------
conformance = fm["conformance"]

if conformance.nil? || !conformance.is_a?(Array) || conformance.empty?
  warn "✗ #{target}: missing required field 'conformance:' (must be a non-empty list)"
  warn "  → declare at least one standards conformance entry with standard and status"
  exit 1
end

# ----------------------------------------------------------------
# Governing principles validation
# ----------------------------------------------------------------
principles = fm["governingPrinciples"]

if principles.nil? || (principles.is_a?(String) && principles.strip.empty?)
  warn "✗ #{target}: missing required field 'governingPrinciples:' in frontmatter"
  warn "  → declare which Gemini Principles govern this twin (Purpose / Trust / Function)"
  exit 1
end

# ----------------------------------------------------------------
# Overclaim guard — known-emerging standards must not be cited as published
# ----------------------------------------------------------------
KNOWN_EMERGING = ["ISO 23247-5", "ISO 23247-6", "ISO/IEC 30188"].freeze

overclaims = []
conformance.each do |entry|
  next unless entry.is_a?(Hash)
  standard = entry["standard"].to_s.strip
  status   = entry["status"].to_s.strip.downcase
  if KNOWN_EMERGING.include?(standard) && status == "published"
    overclaims << standard
  end
end

if overclaims.any?
  warn "✗ #{target}: overclaim detected — known-emerging standard(s) cited as 'published':"
  overclaims.each { |s| warn "  → #{s} is emerging (not yet ratified) — cite as status: emerging" }
  warn "  → citing an emerging standard as ratified misrepresents the twin's conformance claims"
  exit 1
end

puts "✓ Twin-profile validation passed (#{target}: maturity=#{maturity})"
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

HARNESS_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PLATFORM_ROOT="${HARNESS_ROOT}/platform"

ruby -I "$LIB_DIR" -r harness_registry - "$MANIFEST" "$PLATFORM_ROOT" "$PROJECT_ROOT" "$BLOCK" <<'RUBY' || exit $?
require "yaml"

manifest_path = ARGV[0]
platform_root = ARGV[1]
project_root  = ARGV[2]
block_mode    = ARGV[3] == "1"

MODULE_ID   = "digital-twin".freeze
PROFILE_REL = "docs/twin/twin-profile.md".freeze

KNOWN_EMERGING = ["ISO 23247-5", "ISO 23247-6", "ISO/IEC 30188"].freeze

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
unless active_modules.any? { |m| m["id"] == "digital-twin" }
  puts "✓ Twin-profile validation skipped (management/digital-twin not active)"
  exit 0
end

# -----------------------------------------------------------------
# VALIDATE — module is active; profile must exist and be well-formed
# -----------------------------------------------------------------

profile_path = File.join(project_root, PROFILE_REL)
unless File.exist?(profile_path)
  warn "✗ Required artifact missing: #{PROFILE_REL}"
  warn "  → the management/digital-twin module is active but its required artifact is not present"
  warn "  → see platform/templates/digital-twin/twin-profile.md for the template"
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

maturity = fm["maturity"]
if maturity.nil? || (maturity.is_a?(String) && maturity.strip.empty?)
  warn "✗ #{PROFILE_REL}: missing required field 'maturity:' in frontmatter"
  warn "  → declare a maturity level: digital-model | digital-shadow | digital-twin-prototype | operational-twin | control-loop"
  exit 1
end

conformance = fm["conformance"]
if conformance.nil? || !conformance.is_a?(Array) || conformance.empty?
  warn "✗ #{PROFILE_REL}: missing required field 'conformance:' (must be a non-empty list)"
  exit 1
end

principles = fm["governingPrinciples"]
if principles.nil? || (principles.is_a?(String) && principles.strip.empty?)
  warn "✗ #{PROFILE_REL}: missing required field 'governingPrinciples:' in frontmatter"
  exit 1
end

overclaims = []
conformance.each do |entry|
  next unless entry.is_a?(Hash)
  standard = entry["standard"].to_s.strip
  status   = entry["status"].to_s.strip.downcase
  if KNOWN_EMERGING.include?(standard) && status == "published"
    overclaims << standard
  end
end

if overclaims.any?
  warn "✗ #{PROFILE_REL}: overclaim detected — known-emerging standard(s) cited as 'published':"
  overclaims.each { |s| warn "  → #{s} is emerging — cite as status: emerging" }
  exit 1
end

puts "✓ Twin-profile validation passed (#{PROFILE_REL}: maturity=#{maturity.to_s.strip})"

# -----------------------------------------------------------------
# WARN layer — advisory (no tree scan in v1; the profile checks are primary)
# -----------------------------------------------------------------
if block_mode
  # No advisory hits generated in v1 — exit 0 under block mode too.
end

exit 0
RUBY
