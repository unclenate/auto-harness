#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-scenario-manifest.sh — Enforce the scenario-manifest contract for
# projects activating the management/digital-twin overlay.
#
# Why this exists:
#   A scenario manifest makes a simulation run reproducible. The
#   management/digital-twin module requires that scenario manifests carry the
#   sections necessary for reproducibility, provenance, and safe publication.
#   This validator confirms each manifest YAML is well-formed: required top-
#   level sections present, datasets versioned, assumptions uncertainty-
#   annotated, provenance declared, and no output published without an
#   explicit approval record.
#
#   Roadmap citation: PRD-0023 (design contract); Phase 2 Task 4.
#
# Usage:
#   validate-scenario-manifest.sh [--block] [<manifest>] [<project-root>]
#   validate-scenario-manifest.sh --scan-file <path-to-scenario-manifest>
#
# Behavior:
#   Main mode:
#     1. Parse the manifest, enumerate active modules.
#     2. If management/digital-twin is NOT active: exit 0 with a
#        "module inactive" message.
#     3. If active: scan all *.yaml files under scenarios/ for the required
#        shape. WARN posture; --block escalates to exit 1.
#
#   --scan-file mode:
#     Bypass active-module gating. Treat the given file as a scenario manifest.
#     Run ONLY the manifest-parse checks. Used for fixture-firing tests.
#     Exit 1 on failure, 0 on clean.
#
# Required top-level sections (checked in both modes):
#   scenario, datasets, assumptions, outputs, uncertainty, provenance
#
# Per-dataset required fields:
#   source, version, asOf, confidence
#
# Per-assumption required fields:
#   confidence, sensitivity
#
# Publication guard:
#   An output with publicationAllowed: true requires a publication.approvalStatus
#   key to be present in the manifest.
#
# Exit codes:
#   0  validation passed (or module inactive)
#   1  validation failed (missing section, missing dataset field, missing
#      assumption field, provenance absent, or publication-without-approval)
#   2  usage error

set -euo pipefail

# ----------------------------------------------------------------------
# Help
# ----------------------------------------------------------------------

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-scenario-manifest.sh — Enforce the scenario-manifest contract for
projects activating the management/digital-twin overlay.

Usage:
  validate-scenario-manifest.sh [--block] [<manifest>] [<project-root>]
  validate-scenario-manifest.sh --scan-file <path-to-scenario-manifest>

Arguments:
  manifest      Path to harness.manifest.yaml (default: ./harness.manifest.yaml)
  project-root  Path to the project root (default: dirname of manifest)
  --block       Escalate WARN-layer hits to a non-zero exit; default off.
  --scan-file   Direct-content-test mode: validate an arbitrary scenario
                manifest YAML file. Used for fixture-firing tests per PRD-0023.

Behavior (main mode):
  1. Parse the manifest, enumerate active modules.
  2. If management/digital-twin is NOT active in the active set:
     exit 0 with "module inactive — skipping" message.
  3. If active: scan all scenario manifests, assert each carries:
       - Required top-level sections: scenario, datasets, assumptions,
         outputs, uncertainty, provenance
       - Each dataset has: source, version, asOf, confidence
       - Each assumption has: confidence, sensitivity
       - provenance is present (non-nil)
       - No output with publicationAllowed: true lacks a
         publication.approvalStatus key

Behavior (--scan-file mode):
  Validates the same shape against an arbitrary YAML file, bypassing
  active-module gating. Useful for fixture-firing tests.

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

begin
  raw = YAML.safe_load(File.read(target))
rescue Psych::SyntaxError => e
  warn "✗ #{target}: YAML parse error: #{e.message}"
  exit 1
end

unless raw.is_a?(Hash)
  warn "✗ #{target}: must be a YAML mapping at the top level"
  exit 1
end

errors = []

# ----------------------------------------------------------------
# Required top-level sections
# ----------------------------------------------------------------
REQUIRED_SECTIONS = %w[scenario datasets assumptions outputs uncertainty provenance].freeze

REQUIRED_SECTIONS.each do |section|
  unless raw.key?(section) && !raw[section].nil?
    errors << "missing required top-level section '#{section}:'"
  end
end

# ----------------------------------------------------------------
# Dataset field validation (only if datasets section present and is a list)
# ----------------------------------------------------------------
datasets = raw["datasets"]
if datasets.is_a?(Array)
  datasets.each_with_index do |ds, idx|
    next unless ds.is_a?(Hash)
    %w[source version asOf confidence].each do |field|
      unless ds.key?(field) && !ds[field].nil? && ds[field].to_s.strip != ""
        errors << "dataset[#{idx}] (id=#{ds['id'] || '?'}) missing required field '#{field}:'"
      end
    end
  end
end

# ----------------------------------------------------------------
# Assumption field validation (only if assumptions section present and is a list)
# ----------------------------------------------------------------
assumptions = raw["assumptions"]
if assumptions.is_a?(Array)
  assumptions.each_with_index do |assumption, idx|
    next unless assumption.is_a?(Hash)
    %w[confidence sensitivity].each do |field|
      unless assumption.key?(field) && !assumption[field].nil? && assumption[field].to_s.strip != ""
        errors << "assumption[#{idx}] (id=#{assumption['id'] || '?'}) missing required field '#{field}:'"
      end
    end
  end
end

# ----------------------------------------------------------------
# Publication guard — publicationAllowed: true requires an approvalStatus
# ----------------------------------------------------------------
outputs = raw["outputs"]
publication = raw["publication"]
approval_status = publication.is_a?(Hash) ? publication["approvalStatus"] : nil

if outputs.is_a?(Array)
  outputs.each_with_index do |output, idx|
    next unless output.is_a?(Hash)
    if output["publicationAllowed"] == true
      if approval_status.nil? || approval_status.to_s.strip.empty?
        errors << "output[#{idx}] (id=#{output['id'] || '?'}) has publicationAllowed: true but no publication.approvalStatus is declared"
      end
    end
  end
end

if errors.any?
  errors.each { |e| warn "✗ #{target}: #{e}" }
  exit 1
end

puts "✓ Scenario-manifest validation passed (#{target})"
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

REQUIRED_SECTIONS = %w[scenario datasets assumptions outputs uncertainty provenance].freeze

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
  puts "✓ Scenario-manifest validation skipped (management/digital-twin not active)"
  exit 0
end

# -----------------------------------------------------------------
# VALIDATE — scan scenario manifests under scenarios/
# -----------------------------------------------------------------

scenarios_dir = File.join(project_root, "scenarios")

unless File.directory?(scenarios_dir)
  # No scenarios/ directory — nothing to validate; advisory only.
  warn "⚠ management/digital-twin is active but no scenarios/ directory found at #{scenarios_dir}"
  warn "  → create a scenarios/ directory and add scenario manifests when running scenarios"
  if block_mode
    exit 1
  else
    exit 0
  end
end

manifest_files = Dir.glob(File.join(scenarios_dir, "**", "*.yaml"))

if manifest_files.empty?
  warn "⚠ management/digital-twin is active but no scenario manifest YAML files found under scenarios/"
  warn "  → add scenario manifests (see platform/templates/digital-twin/scenario-manifest-spec.md)"
  if block_mode
    exit 1
  else
    exit 0
  end
end

errors = []

manifest_files.each do |mf|
  rel = mf.sub(project_root + "/", "")
  begin
    raw = YAML.safe_load(File.read(mf))
  rescue Psych::SyntaxError => e
    errors << "#{rel}: YAML parse error: #{e.message}"
    next
  end

  unless raw.is_a?(Hash)
    errors << "#{rel}: must be a YAML mapping at the top level"
    next
  end

  REQUIRED_SECTIONS.each do |section|
    unless raw.key?(section) && !raw[section].nil?
      errors << "#{rel}: missing required top-level section '#{section}:'"
    end
  end

  datasets = raw["datasets"]
  if datasets.is_a?(Array)
    datasets.each_with_index do |ds, idx|
      next unless ds.is_a?(Hash)
      %w[source version asOf confidence].each do |field|
        unless ds.key?(field) && !ds[field].nil? && ds[field].to_s.strip != ""
          errors << "#{rel}: dataset[#{idx}] missing required field '#{field}:'"
        end
      end
    end
  end

  assumptions = raw["assumptions"]
  if assumptions.is_a?(Array)
    assumptions.each_with_index do |assumption, idx|
      next unless assumption.is_a?(Hash)
      %w[confidence sensitivity].each do |field|
        unless assumption.key?(field) && !assumption[field].nil? && assumption[field].to_s.strip != ""
          errors << "#{rel}: assumption[#{idx}] missing required field '#{field}:'"
        end
      end
    end
  end

  outputs = raw["outputs"]
  publication = raw["publication"]
  approval_status = publication.is_a?(Hash) ? publication["approvalStatus"] : nil

  if outputs.is_a?(Array)
    outputs.each_with_index do |output, idx|
      next unless output.is_a?(Hash)
      if output["publicationAllowed"] == true
        if approval_status.nil? || approval_status.to_s.strip.empty?
          errors << "#{rel}: output[#{idx}] has publicationAllowed: true but no publication.approvalStatus"
        end
      end
    end
  end
end

if errors.any?
  errors.each { |e| warn "✗ #{e}" }
  if block_mode
    exit 1
  else
    warn ""
    warn "ℹ Scenario-manifest WARN scan: #{errors.length} issue(s) found (WARN posture; not failing CI)."
    warn "  Pass --block to escalate to hard fail."
    exit 0
  end
end

puts "✓ Scenario-manifest validation passed (#{manifest_files.length} manifest(s) checked)"
exit 0
RUBY
