#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-trace-contract.sh — Enforce the trace-contract content
# contract for projects activating a module that requires the
# OpenTelemetry multi-agent trace contract.
#
# Why this exists:
#   The frontier-agent cluster's agent-observability overlay (PRD-0014)
#   and ai-foundry-target overlay (PRD-0028, which reuses the same
#   artifact via the deferred-dependency model) ship declarative-v1:
#   they require docs/observability/trace-contract.md to EXIST, but
#   nothing checks the artifact is internally well-formed. OPP-0051
#   opened the v2-enforcement thread and split "enforcement" into a
#   buildable artifact-content half and a still-deferred
#   code-cross-reference half. This validator is the artifact-content
#   half's anchor — the cross-foundry conformance check.
#
#   It is opt-in: when no active module requires the trace contract,
#   the validator exits 0 with a "skipping" message (the harness itself
#   does not activate either module, so the harness's own CI run is a
#   no-op pass — predict-clean). When an active module requires it, the
#   validator reads docs/observability/trace-contract.md and asserts the
#   YAML frontmatter pins a semconv version, declares at least one span
#   in a conventional GenAI operation shape, and states a content-capture
#   posture. Presence + shape only — never that the declared spans match
#   the emitted telemetry (that is the deferred code-cross-reference half).
#
#   Roadmap citation: OPP-0051 (origin / evidence); PRD-0031 (design
#   contract); anchor OPP-0027 (frontier-agent posture). Converts the
#   artifact-shape sub-axis of PRD-0014's central claim (C-TRACE-1)
#   from Asserted toward Enforced; the runtime-conformance sub-axis
#   (C-TRACE-2) stays deferred.
#
# Usage:
#   validate-trace-contract.sh [<manifest>] [<project-root>]
#   validate-trace-contract.sh --scan-file <path-to-trace-contract-file>
#
# Behavior:
#   Main mode:
#     1. Parse the manifest, enumerate active modules.
#     2. If NO active module declares docs/observability/trace-contract.md
#        in its requiredArtifacts: exit 0 with a "skipping" message.
#     3. If one does: read the artifact, parse YAML frontmatter, validate
#        semconv_version / spans / content_capture.
#
#   --scan-file mode:
#     Bypass active-module gating. Read the given path as a
#     trace-contract.md artifact. Validate the same shape. Used for
#     fixture tests per PRD-0031 FR-005 (the test-seam pattern per
#     feedback-validator-test-seam-pattern).
#
# Recommended GenAI operation set (per PRD-0031 Technical Constraints;
# the trace-contract template documents the conventional span shapes):
#   - chat
#   - invoke_agent
#   - execute_tool
#   - create_agent
#   - embeddings
#   - invoke_workflow
#
# Exit codes:
#   0  validation passed (or no active module requires the artifact)
#   1  validation failed (missing artifact, malformed frontmatter,
#      missing/empty version pin, no conventional span, bad content_capture)
#   2  usage error

set -euo pipefail

# ----------------------------------------------------------------------
# Help
# ----------------------------------------------------------------------

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-trace-contract.sh — Enforce the trace-contract content contract
for projects activating a module that requires the OpenTelemetry
multi-agent trace contract (architectures/agent-observability or
architectures/ai-foundry-target).

Usage:
  validate-trace-contract.sh [<manifest>] [<project-root>]
  validate-trace-contract.sh --scan-file <path-to-trace-contract-file>

Arguments:
  manifest      Path to harness.manifest.yaml (default: ./harness.manifest.yaml)
  project-root  Path to the project root (default: dirname of manifest)
  --scan-file   Direct-content-test mode: validate an arbitrary
                trace-contract-shaped file. Used for fixture-firing
                tests per PRD-0031 FR-005.

Behavior (main mode):
  1. Parse the manifest, enumerate active modules.
  2. If NO active module declares docs/observability/trace-contract.md
     in its requiredArtifacts: exit 0 with a "skipping" message.
  3. If one does: read docs/observability/trace-contract.md, parse the
     YAML frontmatter between --- fences, assert:
       - semconv_version: a non-empty string (the OpenTelemetry GenAI
         semantic-conventions version pin)
       - spans: a non-empty list with at least one conventional GenAI
         operation (chat, invoke_agent, execute_tool, create_agent,
         embeddings, invoke_workflow)
       - content_capture: one of {opt-in, none} (the privacy-sensitive
         content-attribute posture)

Behavior (--scan-file mode):
  Validates the same shape against an arbitrary file, bypassing
  active-module gating. Useful for fixture-firing tests and for ad-hoc
  validation of a candidate trace-contract.md before committing it.

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

RECOMMENDED_OPERATIONS = %w[
  chat
  invoke_agent
  execute_tool
  create_agent
  embeddings
  invoke_workflow
].freeze

CONTENT_CAPTURE_ENUM = %w[opt-in none].freeze

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

version = fm["semconv_version"]
if version.nil? || (version.is_a?(String) && version.strip.empty?)
  warn "✗ #{target}: missing required field 'semconv_version:' (the OpenTelemetry GenAI semantic-conventions version pin)"
  violations += 1
elsif !version.is_a?(String)
  warn "✗ #{target}: 'semconv_version:' must be a string (got #{version.class.name})"
  violations += 1
end

spans = fm["spans"]
if spans.nil?
  warn "✗ #{target}: missing required field 'spans:'"
  violations += 1
elsif !spans.is_a?(Array)
  warn "✗ #{target}: 'spans:' must be a list (got #{spans.class.name})"
  violations += 1
elsif spans.empty?
  warn "✗ #{target}: 'spans:' must have at least one entry"
  violations += 1
elsif spans.none? { |s| s.is_a?(String) && RECOMMENDED_OPERATIONS.include?(s) }
  warn "✗ #{target}: 'spans:' declares no conventional GenAI operation"
  warn "  → name at least one of: #{RECOMMENDED_OPERATIONS.join(', ')}"
  violations += 1
end

content_capture = fm["content_capture"]
if content_capture.nil? || (content_capture.is_a?(String) && content_capture.strip.empty?)
  warn "✗ #{target}: missing required field 'content_capture:' (declare the content-attribute posture)"
  violations += 1
elsif !CONTENT_CAPTURE_ENUM.include?(content_capture)
  warn "✗ #{target}: 'content_capture: #{content_capture}' is not one of {#{CONTENT_CAPTURE_ENUM.join(', ')}}"
  warn "  → content attributes carry user data and are opt-in/off-by-default in the conventions; declare 'opt-in' or 'none'"
  violations += 1
end

if violations > 0
  warn ""
  warn "✗ Trace-contract validation failed: #{violations} field error(s) in #{target}"
  exit 1
end

puts "✓ Trace-contract validation passed (#{target}: semconv pinned, #{spans.length} span(s), content_capture=#{content_capture})"
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

ARTIFACT_REL = "docs/observability/trace-contract.md".freeze
RECOMMENDED_OPERATIONS = %w[
  chat
  invoke_agent
  execute_tool
  create_agent
  embeddings
  invoke_workflow
].freeze
CONTENT_CAPTURE_ENUM = %w[opt-in none].freeze

begin
  manifest = HarnessRegistry.load_manifest(manifest_path)
rescue HarnessRegistry::ManifestShapeError => e
  warn "✗ #{e.message}"
  exit 2
end

active_modules = HarnessRegistry.active_modules(platform_root, manifest)

# Active-module gating — the artifact is opt-in. The validator activates
# when ANY active module declares docs/observability/trace-contract.md in
# its requiredArtifacts (today: architectures/agent-observability, which
# owns it, or architectures/ai-foundry-target, which reuses it via the
# deferred-dependency model). The harness itself activates neither, so the
# harness's own CI run is a no-op pass (predict-clean).
requiring = active_modules.select { |m| Array(m["requiredArtifacts"]).include?(ARTIFACT_REL) }
if requiring.empty?
  puts "✓ Trace-contract validation skipped (no active module requires #{ARTIFACT_REL})"
  exit 0
end

artifact_path = File.join(project_root, ARTIFACT_REL)
unless File.exist?(artifact_path)
  warn "✗ Required artifact missing: #{ARTIFACT_REL}"
  warn "  → an active module (#{requiring.map { |m| m['id'] }.join(', ')}) requires the trace contract, but it is not present"
  warn "  → see platform/templates/observability/trace-contract.md for the template"
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

version = fm["semconv_version"]
if version.nil? || (version.is_a?(String) && version.strip.empty?)
  warn "✗ #{ARTIFACT_REL}: missing required field 'semconv_version:' (the OpenTelemetry GenAI semantic-conventions version pin)"
  violations += 1
elsif !version.is_a?(String)
  warn "✗ #{ARTIFACT_REL}: 'semconv_version:' must be a string (got #{version.class.name})"
  violations += 1
end

spans = fm["spans"]
if spans.nil?
  warn "✗ #{ARTIFACT_REL}: missing required field 'spans:'"
  violations += 1
elsif !spans.is_a?(Array)
  warn "✗ #{ARTIFACT_REL}: 'spans:' must be a list (got #{spans.class.name})"
  violations += 1
elsif spans.empty?
  warn "✗ #{ARTIFACT_REL}: 'spans:' must have at least one entry"
  violations += 1
elsif spans.none? { |s| s.is_a?(String) && RECOMMENDED_OPERATIONS.include?(s) }
  warn "✗ #{ARTIFACT_REL}: 'spans:' declares no conventional GenAI operation"
  warn "  → name at least one of: #{RECOMMENDED_OPERATIONS.join(', ')}"
  violations += 1
end

content_capture = fm["content_capture"]
if content_capture.nil? || (content_capture.is_a?(String) && content_capture.strip.empty?)
  warn "✗ #{ARTIFACT_REL}: missing required field 'content_capture:' (declare the content-attribute posture)"
  violations += 1
elsif !CONTENT_CAPTURE_ENUM.include?(content_capture)
  warn "✗ #{ARTIFACT_REL}: 'content_capture: #{content_capture}' is not one of {#{CONTENT_CAPTURE_ENUM.join(', ')}}"
  warn "  → content attributes carry user data and are opt-in/off-by-default in the conventions; declare 'opt-in' or 'none'"
  violations += 1
end

if violations > 0
  warn ""
  warn "✗ Trace-contract validation failed: #{violations} field error(s) in #{ARTIFACT_REL}"
  exit 1
end

puts "✓ Trace-contract validation passed (#{ARTIFACT_REL}: semconv pinned, #{spans.length} span(s), content_capture=#{content_capture})"
exit 0
RUBY
