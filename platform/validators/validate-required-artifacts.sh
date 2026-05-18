#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
set -euo pipefail

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-required-artifacts.sh — Assert every requiredArtifact declared by active modules exists on disk.

Usage:
  validate-required-artifacts.sh [<manifest-path>] [<project-root>]

Arguments:
  manifest-path  Path to harness.manifest.yaml (optional; default: <repo-root>/harness.manifest.yaml)
  project-root   Path to the consumer project root (optional; default: current working directory)

Example:
  bash platform/validators/validate-required-artifacts.sh harness.manifest.yaml .

Exit codes:
  0  validation passed (or disabled via overrides.disabledValidations)
  1  validation failed (one or more required artifacts missing on disk)
  2  usage error (missing/unreadable/malformed manifest, missing module definition)
USAGE
    exit 0
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PLATFORM_ROOT="${HARNESS_ROOT}/platform"
MANIFEST_PATH="${1:-${HARNESS_ROOT}/harness.manifest.yaml}"
PROJECT_ROOT="${2:-$(pwd)}"

ruby -I"${SCRIPT_DIR}/lib" - "${PLATFORM_ROOT}" "${MANIFEST_PATH}" "${PROJECT_ROOT}" <<'RUBY'
require "harness_registry"

platform_root = ARGV[0]
manifest_path = ARGV[1]
project_root = ARGV[2]

begin
  manifest = HarnessRegistry.load_manifest(manifest_path)
rescue HarnessRegistry::ManifestShapeError => e
  warn "✗ #{e.message}"
  exit 2
end

if HarnessRegistry.disabled_validation?(manifest, "required-artifacts")
  puts "✓ Required artifact validation disabled by manifest override"
  exit 0
end

begin
  modules = HarnessRegistry.active_modules(platform_root, manifest)
rescue RuntimeError => e
  warn "✗ #{e.message}"
  exit 2
end

missing = HarnessRegistry.required_artifacts(modules, manifest).reject do |entry|
  HarnessRegistry.artifact_satisfied?(entry, project_root)
end

if missing.empty?
  puts "✓ Required artifacts are present in #{project_root}"
else
  warn "✗ Required artifact validation failed:"
  missing.each { |entry| warn "  - missing #{HarnessRegistry.artifact_label(entry)}" }
  exit 1
end
RUBY
