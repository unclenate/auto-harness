#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-model-routing.sh — Enforce the model-routing content contract
# for projects activating architectures/intelligent-model-routing.
#
# Why this exists:
#   The frontier-agent cluster's intelligent-model-routing overlay
#   (PRD-0029) ships declarative-v1: it requires
#   docs/architecture/model-routing.md to EXIST, but nothing checks the
#   artifact is internally well-formed. This is OPP-0051 phase 3 — the
#   artifact-content/shape half of v2 enforcement (mirrors
#   validate-trace-contract.sh, PRD-0031).
#
#   Opt-in / module-gated: when no active module requires the artifact,
#   exits 0 with a "skipping" message (predict-clean). When active, reads
#   model-routing.md and asserts the YAML frontmatter declares at least
#   one task→model route. Providers are FREE-FORM by design (PRD-0029
#   Open Question 2), so there is no provider-enum check — the validator
#   asserts route shape, not provider membership. Presence + shape only.
#
#   Roadmap citation: OPP-0051 (origin) / PRD-0032 (design, phase 3) /
#   PRD-0029 (the module) / OPP-0027 (cluster anchor).
#
# Usage:
#   validate-model-routing.sh [<manifest>] [<project-root>]
#   validate-model-routing.sh --scan-file <path-to-model-routing-file>
#
# Exit codes:
#   0  validation passed (or no active module requires the artifact)
#   1  validation failed
#   2  usage error

set -euo pipefail

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-model-routing.sh — Enforce the model-routing content contract
for projects activating architectures/intelligent-model-routing.

Usage:
  validate-model-routing.sh [<manifest>] [<project-root>]
  validate-model-routing.sh --scan-file <path-to-model-routing-file>

Arguments:
  manifest      Path to harness.manifest.yaml (default: ./harness.manifest.yaml)
  project-root  Path to the project root (default: dirname of manifest)
  --scan-file   Direct-content-test mode: validate an arbitrary
                model-routing-shaped file (fixture tests).

Behavior (main mode):
  1. Parse the manifest, enumerate active modules.
  2. If NO active module declares docs/architecture/model-routing.md in
     its requiredArtifacts: exit 0 with a "skipping" message.
  3. If one does: read the artifact, parse the YAML frontmatter, assert:
       - routes: a non-empty list; each entry a map with a non-empty
         task and a non-empty model. Providers are free-form (no enum).

Exit codes:
  0  validation passed (or no active module requires the artifact)
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

raw = File.read(target)
unless raw.start_with?("---\n") || raw.start_with?("---\r\n")
  warn "✗ #{target}: missing YAML frontmatter (expected '---' fence at line 1)"
  exit 1
end
parts = raw.split(/^---\s*$/, 3)
if parts.length < 3
  warn "✗ #{target}: malformed YAML frontmatter (could not locate closing '---' fence)"
  exit 1
end
begin
  fm = YAML.safe_load(parts[1])
rescue Psych::SyntaxError => e
  warn "✗ #{target}: YAML frontmatter parse error: #{e.message}"
  exit 1
end
unless fm.is_a?(Hash)
  warn "✗ #{target}: YAML frontmatter must be a mapping (got #{fm.class.name})"
  exit 1
end

violations = 0
routes = fm["routes"]
if routes.nil?
  warn "✗ #{target}: missing required field 'routes:'"
  violations += 1
elsif !routes.is_a?(Array)
  warn "✗ #{target}: 'routes:' must be a list (got #{routes.class.name})"
  violations += 1
elsif routes.empty?
  warn "✗ #{target}: 'routes:' must have at least one entry"
  violations += 1
else
  routes.each_with_index do |r, idx|
    unless r.is_a?(Hash)
      warn "✗ #{target}: 'routes[#{idx}]' must be a map with task + model (got #{r.class.name})"
      violations += 1
      next
    end
    task = r["task"]
    unless task.is_a?(String) && !task.strip.empty?
      warn "✗ #{target}: 'routes[#{idx}].task' must be a non-empty string"
      violations += 1
    end
    model = r["model"]
    unless model.is_a?(String) && !model.strip.empty?
      warn "✗ #{target}: 'routes[#{idx}].model' must be a non-empty string"
      violations += 1
    end
  end
end

if violations > 0
  warn ""
  warn "✗ Model-routing validation failed: #{violations} field error(s) in #{target}"
  exit 1
end
puts "✓ Model-routing validation passed (#{target}: #{routes.length} route(s) declared)"
exit 0
RUBY_SCAN
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

ruby -I "$LIB_DIR" -r harness_registry - "$MANIFEST" "$PLATFORM_ROOT" "$PROJECT_ROOT" <<'RUBY' || exit $?
require "yaml"
manifest_path = ARGV[0]
platform_root = ARGV[1]
project_root  = ARGV[2]

ARTIFACT_REL = "docs/architecture/model-routing.md".freeze

begin
  manifest = HarnessRegistry.load_manifest(manifest_path)
rescue HarnessRegistry::ManifestShapeError => e
  warn "✗ #{e.message}"
  exit 2
end

active_modules = HarnessRegistry.active_modules(platform_root, manifest)
requiring = active_modules.select { |m| Array(m["requiredArtifacts"]).include?(ARTIFACT_REL) }
if requiring.empty?
  puts "✓ Model-routing validation skipped (no active module requires #{ARTIFACT_REL})"
  exit 0
end

artifact_path = File.join(project_root, ARTIFACT_REL)
unless File.exist?(artifact_path)
  warn "✗ Required artifact missing: #{ARTIFACT_REL}"
  warn "  → an active module (#{requiring.map { |m| m['id'] }.join(', ')}) requires it, but it is not present"
  warn "  → see platform/templates/architecture/model-routing.md for the template"
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
begin
  fm = YAML.safe_load(parts[1])
rescue Psych::SyntaxError => e
  warn "✗ #{ARTIFACT_REL}: YAML frontmatter parse error: #{e.message}"
  exit 1
end
unless fm.is_a?(Hash)
  warn "✗ #{ARTIFACT_REL}: YAML frontmatter must be a mapping (got #{fm.class.name})"
  exit 1
end

violations = 0
routes = fm["routes"]
if routes.nil?
  warn "✗ #{ARTIFACT_REL}: missing required field 'routes:'"
  violations += 1
elsif !routes.is_a?(Array)
  warn "✗ #{ARTIFACT_REL}: 'routes:' must be a list (got #{routes.class.name})"
  violations += 1
elsif routes.empty?
  warn "✗ #{ARTIFACT_REL}: 'routes:' must have at least one entry"
  violations += 1
else
  routes.each_with_index do |r, idx|
    unless r.is_a?(Hash)
      warn "✗ #{ARTIFACT_REL}: 'routes[#{idx}]' must be a map with task + model (got #{r.class.name})"
      violations += 1
      next
    end
    task = r["task"]
    unless task.is_a?(String) && !task.strip.empty?
      warn "✗ #{ARTIFACT_REL}: 'routes[#{idx}].task' must be a non-empty string"
      violations += 1
    end
    model = r["model"]
    unless model.is_a?(String) && !model.strip.empty?
      warn "✗ #{ARTIFACT_REL}: 'routes[#{idx}].model' must be a non-empty string"
      violations += 1
    end
  end
end

if violations > 0
  warn ""
  warn "✗ Model-routing validation failed: #{violations} field error(s) in #{ARTIFACT_REL}"
  exit 1
end
puts "✓ Model-routing validation passed (#{ARTIFACT_REL}: #{routes.length} route(s) declared)"
exit 0
RUBY
