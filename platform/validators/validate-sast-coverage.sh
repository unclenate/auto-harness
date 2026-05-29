#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-sast-coverage.sh — Enforce the SAST coverage contract for
# projects activating the management/security-static-analysis overlay.
#
# Why this exists:
#   The framework governs AI agents that generate code. Sweep section 11
#   names this as "the largest mission-relative gap in the entire safety
#   sweep": the harness has zero machinery to inspect agent-generated
#   code for security smells. The management/security-static-analysis
#   module addresses the gap with an opt-in posture: consumers declare
#   their SAST contract; the harness validates the declaration is
#   well-formed; the consumer CI runs the tool and gates on findings.
#
#   This validator is the declaration-checking half of that contract.
#   It is opt-in: when the module is not in the active set, the
#   validator exits 0 with a "module inactive" message. When the
#   module is active, the validator reads docs/security/sast-coverage.md
#   and asserts the YAML frontmatter declares a tool from the
#   recommended set, at least one scanPath, and a severityThreshold.
#
#   Roadmap citation: ADR-0017 (Safety Hardening Roadmap) Wave 5.4;
#   PRD-0016 (design contract); OPP-0035 (origin / evidence).
#   Half-enforces sweep section 11 (consumer CI honors the contract
#   for end-to-end enforcement; the harness validates the declaration).
#
# Usage:
#   validate-sast-coverage.sh [<manifest>] [<project-root>]
#   validate-sast-coverage.sh --scan-file <path-to-sast-coverage-file>
#
# Behavior:
#   Main mode:
#     1. Parse the manifest, enumerate active modules.
#     2. If management/security-static-analysis is NOT active: exit 0
#        with a "module inactive" message.
#     3. If active: read docs/security/sast-coverage.md, parse YAML
#        frontmatter, validate tool / scanPaths / severityThreshold.
#
#   --scan-file mode:
#     Bypass active-module gating. Read the given path as a
#     sast-coverage.md artifact. Validate the same shape. Used for
#     fixture tests per PRD-0016 FR-S03 (the test-seam pattern per
#     feedback-validator-test-seam-pattern).
#
# Recommended-set (per PRD-0016 FR-004; module README documents the
# pick-one guidance per stack):
#   - semgrep
#   - codeql
#   - bandit
#   - gosec
#   - eslint-plugin-security
#   - snyk-code
#
# Exit codes:
#   0  validation passed (or module inactive)
#   1  validation failed (missing artifact, malformed frontmatter,
#      missing required field, tool not in recommended set)
#   2  usage error

set -euo pipefail

# ----------------------------------------------------------------------
# Help
# ----------------------------------------------------------------------

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-sast-coverage.sh — Enforce the SAST coverage contract for
projects activating the management/security-static-analysis overlay.

Usage:
  validate-sast-coverage.sh [<manifest>] [<project-root>]
  validate-sast-coverage.sh --scan-file <path-to-sast-coverage-file>

Arguments:
  manifest      Path to harness.manifest.yaml (default: ./harness.manifest.yaml)
  project-root  Path to the project root (default: dirname of manifest)
  --scan-file   Direct-content-test mode: validate an arbitrary
                sast-coverage-shaped file. Used for fixture-firing
                tests per PRD-0016 FR-S03.

Behavior (main mode):
  1. Parse the manifest, enumerate active modules.
  2. If management/security-static-analysis is NOT active in the
     active set: exit 0 with "module inactive — skipping" message.
  3. If active: read docs/security/sast-coverage.md, parse the YAML
     frontmatter between --- fences, assert:
       - tool: is a string from the recommended set
         (semgrep, codeql, bandit, gosec, eslint-plugin-security,
         snyk-code)
       - scanPaths: is a non-empty list
       - severityThreshold: is a non-empty string

Behavior (--scan-file mode):
  Validates the same shape against an arbitrary file, bypassing
  active-module gating. Useful for adversarial-fixture firing tests
  and for ad-hoc validation of a candidate sast-coverage.md before
  committing it.

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

RECOMMENDED_TOOLS = %w[
  semgrep
  codeql
  bandit
  gosec
  eslint-plugin-security
  snyk-code
].freeze

raw = File.read(target)
unless raw.start_with?("---\n") || raw.start_with?("---\r\n")
  warn "✗ #{target}: missing YAML frontmatter (expected '---' fence at line 1)"
  exit 1
end

# Extract frontmatter between leading --- and the next --- on its own line.
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

violations = 0

tool = fm["tool"]
if tool.nil? || (tool.is_a?(String) && tool.strip.empty?)
  warn "✗ #{target}: missing required field 'tool:' in frontmatter"
  violations += 1
elsif !tool.is_a?(String)
  warn "✗ #{target}: 'tool:' must be a string (got #{tool.class.name})"
  violations += 1
elsif !RECOMMENDED_TOOLS.include?(tool)
  warn "✗ #{target}: 'tool: #{tool}' is not in the recommended set"
  warn "  → pick one of: #{RECOMMENDED_TOOLS.join(', ')}"
  warn "  → if your tool belongs on the list, file a PR adding it to RECOMMENDED_TOOLS in validate-sast-coverage.sh + the module README"
  violations += 1
end

scan_paths = fm["scanPaths"]
if scan_paths.nil?
  warn "✗ #{target}: missing required field 'scanPaths:' in frontmatter"
  violations += 1
elsif !scan_paths.is_a?(Array)
  warn "✗ #{target}: 'scanPaths:' must be a list (got #{scan_paths.class.name})"
  violations += 1
elsif scan_paths.empty?
  warn "✗ #{target}: 'scanPaths:' must have at least one entry"
  violations += 1
else
  scan_paths.each_with_index do |path, idx|
    unless path.is_a?(String) && !path.strip.empty?
      warn "✗ #{target}: 'scanPaths[#{idx}]' must be a non-empty string (got #{path.inspect})"
      violations += 1
    end
  end
end

threshold = fm["severityThreshold"]
if threshold.nil?
  warn "✗ #{target}: missing required field 'severityThreshold:' in frontmatter"
  violations += 1
elsif !threshold.is_a?(String)
  warn "✗ #{target}: 'severityThreshold:' must be a string (got #{threshold.class.name})"
  violations += 1
elsif threshold.strip.empty?
  warn "✗ #{target}: 'severityThreshold:' must be non-empty"
  violations += 1
end

if violations > 0
  warn ""
  warn "✗ SAST coverage validation failed: #{violations} field error(s) in #{target}"
  exit 1
end

puts "✓ SAST coverage validation passed (#{target}: tool=#{tool}, #{scan_paths.length} scanPath(s), severityThreshold=#{threshold})"
exit 0
RUBY_SCAN
  exit 0
fi

# ----------------------------------------------------------------------
# Main mode — manifest-driven active-module gating
# ----------------------------------------------------------------------

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

ruby -I "$LIB_DIR" -r harness_registry - "$MANIFEST" "$PLATFORM_ROOT" "$PROJECT_ROOT" <<'RUBY' || exit $?
require "yaml"

manifest_path = ARGV[0]
platform_root = ARGV[1]
project_root  = ARGV[2]

MODULE_ID = "management/security-static-analysis".freeze
ARTIFACT_REL = "docs/security/sast-coverage.md".freeze
RECOMMENDED_TOOLS = %w[
  semgrep
  codeql
  bandit
  gosec
  eslint-plugin-security
  snyk-code
].freeze

begin
  manifest = HarnessRegistry.load_manifest(manifest_path)
rescue HarnessRegistry::ManifestShapeError => e
  warn "✗ #{e.message}"
  exit 2
end

active_modules = HarnessRegistry.active_modules(platform_root, manifest)

# Active-module gating — the module is opt-in. When the consumer's
# manifest does not activate it, the validator exits 0 with a
# "module inactive — skipping" message. The harness itself does not
# activate the module, so the harness's own CI run is a no-op pass.
unless active_modules.any? { |m| m["id"] == "security-static-analysis" || m["__id_with_type"] == MODULE_ID }
  puts "✓ SAST coverage validation skipped (management/security-static-analysis not active)"
  exit 0
end

# Module is active — read the required artifact.
artifact_path = File.join(project_root, ARTIFACT_REL)
unless File.exist?(artifact_path)
  warn "✗ Required artifact missing: #{ARTIFACT_REL}"
  warn "  → the management/security-static-analysis module is active but its required artifact is not present"
  warn "  → see platform/templates/security/sast-coverage.md for the template"
  exit 1
end

raw = File.read(artifact_path)
unless raw.start_with?("---\n") || raw.start_with?("---\r\n")
  warn "✗ #{ARTIFACT_REL}: missing YAML frontmatter (expected '---' fence at line 1)"
  exit 1
end

parts = raw.split(/^---\s*$/, 3)
if parts.length < 3
  warn "✗ #{ARTIFACT_REL}: malformed YAML frontmatter (could not locate closing '---' fence)"
  exit 1
end
fm_text = parts[1]

begin
  fm = YAML.safe_load(fm_text)
rescue Psych::SyntaxError => e
  warn "✗ #{ARTIFACT_REL}: YAML frontmatter parse error: #{e.message}"
  exit 1
end

unless fm.is_a?(Hash)
  warn "✗ #{ARTIFACT_REL}: YAML frontmatter must be a mapping (got #{fm.class.name})"
  exit 1
end

violations = 0

tool = fm["tool"]
if tool.nil? || (tool.is_a?(String) && tool.strip.empty?)
  warn "✗ #{ARTIFACT_REL}: missing required field 'tool:' in frontmatter"
  violations += 1
elsif !tool.is_a?(String)
  warn "✗ #{ARTIFACT_REL}: 'tool:' must be a string (got #{tool.class.name})"
  violations += 1
elsif !RECOMMENDED_TOOLS.include?(tool)
  warn "✗ #{ARTIFACT_REL}: 'tool: #{tool}' is not in the recommended set"
  warn "  → pick one of: #{RECOMMENDED_TOOLS.join(', ')}"
  warn "  → if your tool belongs on the list, file a PR adding it to RECOMMENDED_TOOLS in validate-sast-coverage.sh + the module README"
  violations += 1
end

scan_paths = fm["scanPaths"]
if scan_paths.nil?
  warn "✗ #{ARTIFACT_REL}: missing required field 'scanPaths:' in frontmatter"
  violations += 1
elsif !scan_paths.is_a?(Array)
  warn "✗ #{ARTIFACT_REL}: 'scanPaths:' must be a list (got #{scan_paths.class.name})"
  violations += 1
elsif scan_paths.empty?
  warn "✗ #{ARTIFACT_REL}: 'scanPaths:' must have at least one entry"
  violations += 1
else
  scan_paths.each_with_index do |path, idx|
    unless path.is_a?(String) && !path.strip.empty?
      warn "✗ #{ARTIFACT_REL}: 'scanPaths[#{idx}]' must be a non-empty string (got #{path.inspect})"
      violations += 1
    end
  end
end

threshold = fm["severityThreshold"]
if threshold.nil?
  warn "✗ #{ARTIFACT_REL}: missing required field 'severityThreshold:' in frontmatter"
  violations += 1
elsif !threshold.is_a?(String)
  warn "✗ #{ARTIFACT_REL}: 'severityThreshold:' must be a string (got #{threshold.class.name})"
  violations += 1
elsif threshold.strip.empty?
  warn "✗ #{ARTIFACT_REL}: 'severityThreshold:' must be non-empty"
  violations += 1
end

if violations > 0
  warn ""
  warn "✗ SAST coverage validation failed: #{violations} field error(s) in #{ARTIFACT_REL}"
  exit 1
end

puts "✓ SAST coverage validation passed (#{ARTIFACT_REL}: tool=#{tool}, #{scan_paths.length} scanPath(s), severityThreshold=#{threshold})"
exit 0
RUBY
