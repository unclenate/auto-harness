#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-sensitive-paths.sh — Assert every declared sensitivePaths
# pattern is overlapped by at least one companion-rule triggerPath.
#
# Why this exists:
#   `sensitivePaths` is the framework's documentary metadata for "this
#   path-shape needs elevated review when changed." The safety sweep
#   (§2 claim 12) classified this as Asserted-only: zero validators
#   actually read the field. A path declared sensitive but not covered
#   by any companion rule's `triggerPaths` is sold-as-policy but
#   never-checked-in-code — exactly the doc-code-alignment gap §7
#   warned against.
#
#   This validator closes that gap by asserting the structural
#   invariant that gives `sensitivePaths` its semantic meaning: a path
#   declared sensitive MUST be under elevated review via at least one
#   companion rule, on some active module.
#
#   Roadmap citation: ADR-0017 (Safety Hardening Roadmap) Wave 5.3.
#   Closes safety-security-sweep §2 claim 12 (Asserted-only → Enforced)
#   per OPP-0034.
#
# Usage:
#   validate-sensitive-paths.sh [<manifest>] [<project-root>]
#
# Behavior:
#   1. Parse the manifest, enumerate active modules.
#   2. Collect every sensitivePaths regex pattern across all active
#      modules → "covered set" (initially empty).
#   3. Collect every companionRules.triggerPaths regex pattern across
#      all active modules → "trigger set".
#   4. For each sensitive pattern, check overlap against the trigger
#      set via a pragmatic three-tier match (literal equality,
#      substring containment either direction). Highest-confidence
#      match wins; first match short-circuits.
#   5. Sensitive patterns with no overlap are violations — the
#      validator emits a structured error naming the offending
#      pattern + the module that declared it + the closest near-miss
#      trigger (if any).
#
#   Cross-module overlap is allowed: a module's sensitivePaths need
#   not be covered by its OWN companion rule — coverage by any active
#   module's companion rule suffices. (Sweep §2 explicitly notes
#   this; matches the kernel's own setup where some sensitive paths
#   are covered by the same module's companion rule, but the
#   invariant doesn't require co-location.)
#
# Pragmatic overlap semantics (OPP-0034 Risk 1):
#   Strict regex-subset checking is undecidable in general. v1 uses
#   a 3-tier approximation:
#     (a) Literal equality: sensitive == trigger string.
#     (b) Trigger contains sensitive: any trigger pattern's string has
#         the sensitive pattern as a substring (e.g., trigger
#         `^docs/adr/ADR-` covers sensitive `^docs/adr/`).
#     (c) Sensitive contains trigger: any trigger pattern is a
#         substring of the sensitive (e.g., trigger `^foo/`
#         covers sensitive `^foo/bar/`).
#   This is the practical contract — Recommendation 1 of safety-
#   security-sweep §2 calls for "overlap" not exact match. Future v2
#   could add anchor/character-class subset analysis.
#
# Exit codes:
#   0  every active sensitivePaths pattern is overlapped by some
#      companion-rule triggerPaths pattern
#   1  one or more sensitive paths are uncovered
#   2  usage error (missing/malformed manifest, etc.)

set -euo pipefail

# ----------------------------------------------------------------------
# Help
# ----------------------------------------------------------------------

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-sensitive-paths.sh — Assert sensitivePaths are companion-rule covered.

Usage:
  validate-sensitive-paths.sh [<manifest>] [<project-root>]

Arguments:
  manifest      Path to harness.manifest.yaml (default: ./harness.manifest.yaml)
  project-root  Path to the project root (default: dirname of manifest)

Behavior:
  Across all active modules, collects every `sensitivePaths` regex
  pattern and every `companionRules.triggerPaths` regex pattern. Asserts
  each sensitive pattern is overlapped by at least one trigger pattern,
  using a pragmatic 3-tier overlap check (literal equality, trigger
  contains sensitive as substring, or sensitive contains trigger as
  substring). Cross-module overlap is allowed.

  A sensitive path with no overlapping trigger is documentary metadata
  that no companion rule enforces — exactly the doc-code-alignment gap
  safety-security-sweep §2 claim 12 flagged. v1 of this validator
  closes that gap structurally.

Exit codes:
  0  all sensitive paths are companion-rule covered
  1  one or more sensitive paths are uncovered
  2  usage error
USAGE
    exit 0
    ;;
esac

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

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
HARNESS_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PLATFORM_ROOT="${HARNESS_ROOT}/platform"

# ----------------------------------------------------------------------
# Delegate to Ruby for YAML parsing + per-module traversal.
# ----------------------------------------------------------------------

ruby -I "$LIB_DIR" -r harness_registry - "$MANIFEST" "$PLATFORM_ROOT" <<'RUBY' || exit $?
manifest_path = ARGV[0]
platform_root = ARGV[1]

begin
  manifest = HarnessRegistry.load_manifest(manifest_path)
rescue HarnessRegistry::ManifestShapeError => e
  warn "✗ #{e.message}"
  exit 2
end

active_modules = HarnessRegistry.active_modules(platform_root, manifest)

# Collect every (sensitive_pattern, module_id) tuple across active modules.
sensitive_entries = []
active_modules.each do |mod|
  mod_id = mod["id"] || "(unknown)"
  Array(mod["sensitivePaths"]).each do |group|
    patterns = group.is_a?(Hash) ? Array(group["patterns"]) : Array(group)
    patterns.each { |p| sensitive_entries << [p.to_s, mod_id] }
  end
end

# Collect every trigger pattern (flat array; module identity not needed
# because overlap can be cross-module).
trigger_patterns = []
active_modules.each do |mod|
  Array(mod["companionRules"]).each do |rule|
    next unless rule.is_a?(Hash)
    Array(rule["triggerPaths"]).each { |p| trigger_patterns << p.to_s }
  end
end

# Pragmatic 3-tier overlap check. Returns the matched trigger string
# or nil. See script header for the contract.
def find_overlap(sensitive, triggers)
  # Tier (a): literal equality.
  triggers.each { |t| return t if t == sensitive }
  # Tier (b): trigger contains sensitive as substring.
  triggers.each { |t| return t if t.include?(sensitive) && t != sensitive }
  # Tier (c): sensitive contains trigger as substring.
  triggers.each { |t| return t if sensitive.include?(t) && t != sensitive }
  nil
end

violations = 0
total_checks = sensitive_entries.size

sensitive_entries.each do |sensitive, mod_id|
  match = find_overlap(sensitive, trigger_patterns)
  next if match
  warn "✗ #{mod_id}: sensitive path #{sensitive.inspect} has no overlapping companion-rule triggerPath"
  violations += 1
end

if violations > 0
  warn ""
  warn "✗ Sensitive-paths validation failed: #{violations} of #{total_checks} sensitive pattern(s) uncovered."
  warn "  Each declared sensitivePath must be overlapped by at least one"
  warn "  companionRules.triggerPaths regex on some active module."
  exit 1
end

if total_checks == 0
  puts "✓ Sensitive-paths validation passed (no sensitive paths declared by any active module)."
else
  puts "✓ All #{total_checks} sensitive-path patterns are companion-rule covered."
end
exit 0
RUBY
