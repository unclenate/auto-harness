#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
set -euo pipefail

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
manifest = HarnessRegistry.load_manifest(manifest_path)

if HarnessRegistry.disabled_validation?(manifest, "required-artifacts")
  puts "✓ Required artifact validation disabled by manifest override"
  exit 0
end

modules = HarnessRegistry.active_modules(platform_root, manifest)
missing = HarnessRegistry.required_artifacts(modules, manifest).reject do |artifact|
  File.exist?(File.join(project_root, artifact))
end

if missing.empty?
  puts "✓ Required artifacts are present in #{project_root}"
else
  warn "✗ Required artifact validation failed:"
  missing.each { |artifact| warn "  - missing #{artifact}" }
  exit 1
end
RUBY
