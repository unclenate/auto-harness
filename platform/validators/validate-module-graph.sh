#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
set -euo pipefail

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-module-graph.sh — Validate active-module dependencies, conflicts, and type assignments.

Usage:
  validate-module-graph.sh [<manifest-path>]

Arguments:
  manifest-path  Path to harness.manifest.yaml (optional; default: <repo-root>/harness.manifest.yaml)

Example:
  bash platform/validators/validate-module-graph.sh harness.manifest.yaml

Exit codes:
  0  validation passed
  1  validation failed (missing dependency, active conflict, or category/type mismatch)
  2  usage error (missing/unreadable/malformed manifest, missing module definition on disk)
USAGE
    exit 0
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PLATFORM_ROOT="${HARNESS_ROOT}/platform"
MANIFEST_PATH="${1:-${HARNESS_ROOT}/harness.manifest.yaml}"

ruby -I"${SCRIPT_DIR}/lib" - "${PLATFORM_ROOT}" "${MANIFEST_PATH}" <<'RUBY'
require "harness_registry"

platform_root = ARGV[0]
manifest_path = ARGV[1]

begin
  manifest = HarnessRegistry.load_manifest(manifest_path)
  modules = HarnessRegistry.active_modules(platform_root, manifest)
rescue HarnessRegistry::ManifestShapeError => e
  warn "✗ #{e.message}"
  exit 2
rescue RuntimeError => e
  # active_modules raises a bare RuntimeError when a referenced module.yaml
  # is missing on disk — that's a usage / environment problem, not a
  # governance violation, so route it through exit 2.
  warn "✗ #{e.message}"
  exit 2
end

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
