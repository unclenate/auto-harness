#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PLATFORM_ROOT="${HARNESS_ROOT}/platform"
MANIFEST_PATH="${1:-${HARNESS_ROOT}/harness.manifest.yaml}"

ruby -I"${SCRIPT_DIR}/lib" - "${PLATFORM_ROOT}" "${MANIFEST_PATH}" <<'RUBY'
require "harness_registry"

platform_root = ARGV[0]
manifest_path = ARGV[1]
manifest = HarnessRegistry.load_manifest(manifest_path)
modules = HarnessRegistry.active_modules(platform_root, manifest)
id_map = HarnessRegistry.module_id_set(modules)
errors = []

modules.each do |mod|
  Array(mod["dependsOn"]).each do |dependency|
    errors << "#{mod['id']} depends on missing module #{dependency}" unless id_map.key?(dependency)
  end

  Array(mod["conflictsWith"]).each do |conflict|
    errors << "#{mod['id']} conflicts with active module #{conflict}" if id_map.key?(conflict)
  end
end

expected_type = {
  "core" => "core",
  "stacks" => "stack",
  "architectures" => "architecture",
  "data" => "data",
  "delivery" => "delivery",
  "management" => "management",
  "domains" => "domain",
  "agents" => "agent"
}

modules.each do |mod|
  actual = mod["type"]
  expected = expected_type.fetch(mod["__category"])
  errors << "#{mod['id']} resolved from #{mod['__category']} but declares type #{actual}" unless actual == expected
end

if errors.empty?
  puts "✓ Module graph is valid for #{manifest_path}"
else
  warn "✗ Module graph validation failed:"
  errors.each { |error| warn "  - #{error}" }
  exit 1
end
RUBY
