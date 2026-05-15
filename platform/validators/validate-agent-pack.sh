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

if HarnessRegistry.disabled_validation?(manifest, "agent-pack")
  puts "✓ Agent-pack validation disabled by manifest override"
  exit 0
end

modules = HarnessRegistry.active_modules(platform_root, manifest).select { |mod| mod["type"] == "agent" }
errors = []

modules.each do |mod|
  errors << "#{mod['id']} must declare at least one agent adapter" if Array(mod["agentAdapters"]).empty?
  errors << "#{mod['id']} must declare at least one compiled fragment" if Array(mod["compiledFragments"]).empty?
  Array(mod["requiredArtifacts"]).each do |artifact|
    path = File.join(project_root, artifact)
    errors << "#{mod['id']} requires missing artifact #{artifact}" unless File.exist?(path)
  end
  Array(mod["compiledFragments"]).each do |fragment|
    fragment_path = File.join(platform_root, fragment.sub(%r{\Aplatform/}, ""))
    errors << "#{mod['id']} references missing compiled fragment #{fragment}" unless File.exist?(fragment_path)
  end
end

if errors.empty?
  puts "✓ Agent-pack validation passed for #{project_root}"
else
  warn "✗ Agent-pack validation failed:"
  errors.each { |error| warn "  - #{error}" }
  exit 1
end
RUBY
