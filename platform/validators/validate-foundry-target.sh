#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-foundry-target.sh — Enforce the foundry-target content
# contract for projects activating architectures/ai-foundry-target.
#
# Why this exists:
#   The frontier-agent cluster's ai-foundry-target overlay (PRD-0028)
#   ships declarative-v1: it requires docs/architecture/foundry-targets.md
#   to EXIST, but nothing checks the artifact is internally well-formed.
#   This is OPP-0051 phase 2 — the artifact-content/shape half of v2
#   enforcement, the second validator in the cluster's content-validator
#   family (mirrors validate-trace-contract.sh, PRD-0031).
#
#   Opt-in / module-gated: when no active module requires the artifact,
#   exits 0 with a "skipping" message (predict-clean — the harness does
#   not activate the module). When active, reads foundry-targets.md and
#   asserts the YAML frontmatter declares at least one foundry from the
#   enum, each with a live/roadmap status. Presence + shape only — never
#   that the declared foundries are reachable (the deferred
#   code-cross-reference half).
#
#   Roadmap citation: OPP-0051 (origin) / PRD-0032 (design, phase 2) /
#   PRD-0028 (the module) / OPP-0027 (cluster anchor).
#
# Usage:
#   validate-foundry-target.sh [<manifest>] [<project-root>]
#   validate-foundry-target.sh --scan-file <path-to-foundry-targets-file>
#
# Foundries enum (per PRD-0028 / PRD-0032 FR-001):
#   azure-ai-foundry, nvidia-ai-foundry, palantir-aip,
#   aws-bedrock-agentcore, google-vertex-agent-engine, custom
#
# Exit codes:
#   0  validation passed (or no active module requires the artifact)
#   1  validation failed
#   2  usage error

set -euo pipefail

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-foundry-target.sh — Enforce the foundry-target content contract
for projects activating architectures/ai-foundry-target.

Usage:
  validate-foundry-target.sh [<manifest>] [<project-root>]
  validate-foundry-target.sh --scan-file <path-to-foundry-targets-file>

Arguments:
  manifest      Path to harness.manifest.yaml (default: ./harness.manifest.yaml)
  project-root  Path to the project root (default: dirname of manifest)
  --scan-file   Direct-content-test mode: validate an arbitrary
                foundry-targets-shaped file (fixture tests).

Behavior (main mode):
  1. Parse the manifest, enumerate active modules.
  2. If NO active module declares docs/architecture/foundry-targets.md in
     its requiredArtifacts: exit 0 with a "skipping" message.
  3. If one does: read the artifact, parse the YAML frontmatter, assert:
       - foundries: a non-empty list; each entry a map with
         id: one of {azure-ai-foundry, nvidia-ai-foundry, palantir-aip,
         aws-bedrock-agentcore, google-vertex-agent-engine, custom}
         and status: one of {live, roadmap}

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
FOUNDRY_ENUM = %w[azure-ai-foundry nvidia-ai-foundry palantir-aip aws-bedrock-agentcore google-vertex-agent-engine custom].freeze
STATUS_ENUM = %w[live roadmap].freeze

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
foundries = fm["foundries"]
if foundries.nil?
  warn "✗ #{target}: missing required field 'foundries:'"
  violations += 1
elsif !foundries.is_a?(Array)
  warn "✗ #{target}: 'foundries:' must be a list (got #{foundries.class.name})"
  violations += 1
elsif foundries.empty?
  warn "✗ #{target}: 'foundries:' must have at least one entry"
  violations += 1
else
  foundries.each_with_index do |f, idx|
    unless f.is_a?(Hash)
      warn "✗ #{target}: 'foundries[#{idx}]' must be a map with id + status (got #{f.class.name})"
      violations += 1
      next
    end
    id = f["id"]
    unless id.is_a?(String) && FOUNDRY_ENUM.include?(id)
      warn "✗ #{target}: 'foundries[#{idx}].id' (#{id.inspect}) is not one of {#{FOUNDRY_ENUM.join(', ')}}"
      violations += 1
    end
    status = f["status"]
    unless status.is_a?(String) && STATUS_ENUM.include?(status)
      warn "✗ #{target}: 'foundries[#{idx}].status' (#{status.inspect}) is not one of {#{STATUS_ENUM.join(', ')}}"
      violations += 1
    end
  end
end

if violations > 0
  warn ""
  warn "✗ Foundry-target validation failed: #{violations} field error(s) in #{target}"
  exit 1
end
puts "✓ Foundry-target validation passed (#{target}: #{foundries.length} foundry/ies declared)"
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

ARTIFACT_REL = "docs/architecture/foundry-targets.md".freeze
FOUNDRY_ENUM = %w[azure-ai-foundry nvidia-ai-foundry palantir-aip aws-bedrock-agentcore google-vertex-agent-engine custom].freeze
STATUS_ENUM = %w[live roadmap].freeze

begin
  manifest = HarnessRegistry.load_manifest(manifest_path)
rescue HarnessRegistry::ManifestShapeError => e
  warn "✗ #{e.message}"
  exit 2
end

active_modules = HarnessRegistry.active_modules(platform_root, manifest)
requiring = active_modules.select { |m| Array(m["requiredArtifacts"]).include?(ARTIFACT_REL) }
if requiring.empty?
  puts "✓ Foundry-target validation skipped (no active module requires #{ARTIFACT_REL})"
  exit 0
end

artifact_path = File.join(project_root, ARTIFACT_REL)
unless File.exist?(artifact_path)
  warn "✗ Required artifact missing: #{ARTIFACT_REL}"
  warn "  → an active module (#{requiring.map { |m| m['id'] }.join(', ')}) requires it, but it is not present"
  warn "  → see platform/templates/architecture/foundry-targets.md for the template"
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
foundries = fm["foundries"]
if foundries.nil?
  warn "✗ #{ARTIFACT_REL}: missing required field 'foundries:'"
  violations += 1
elsif !foundries.is_a?(Array)
  warn "✗ #{ARTIFACT_REL}: 'foundries:' must be a list (got #{foundries.class.name})"
  violations += 1
elsif foundries.empty?
  warn "✗ #{ARTIFACT_REL}: 'foundries:' must have at least one entry"
  violations += 1
else
  foundries.each_with_index do |f, idx|
    unless f.is_a?(Hash)
      warn "✗ #{ARTIFACT_REL}: 'foundries[#{idx}]' must be a map with id + status (got #{f.class.name})"
      violations += 1
      next
    end
    id = f["id"]
    unless id.is_a?(String) && FOUNDRY_ENUM.include?(id)
      warn "✗ #{ARTIFACT_REL}: 'foundries[#{idx}].id' (#{id.inspect}) is not one of {#{FOUNDRY_ENUM.join(', ')}}"
      violations += 1
    end
    status = f["status"]
    unless status.is_a?(String) && STATUS_ENUM.include?(status)
      warn "✗ #{ARTIFACT_REL}: 'foundries[#{idx}].status' (#{status.inspect}) is not one of {#{STATUS_ENUM.join(', ')}}"
      violations += 1
    end
  end
end

if violations > 0
  warn ""
  warn "✗ Foundry-target validation failed: #{violations} field error(s) in #{ARTIFACT_REL}"
  exit 1
end
puts "✓ Foundry-target validation passed (#{ARTIFACT_REL}: #{foundries.length} foundry/ies declared)"
exit 0
RUBY
