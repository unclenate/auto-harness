#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PLATFORM_ROOT="${HARNESS_ROOT}/platform"
MANIFEST_PATH="${1:-${HARNESS_ROOT}/harness.manifest.yaml}"

ruby - "${MANIFEST_PATH}" "${PLATFORM_ROOT}" <<'RUBY'
require "yaml"
manifest_path = ARGV[0]
abort "Manifest not found: #{manifest_path}" unless File.exist?(manifest_path)

manifest = YAML.safe_load(File.read(manifest_path), permitted_classes: [], aliases: false)
errors = []

errors << "schemaVersion must be 1" unless manifest["schemaVersion"] == 1

project = manifest["project"] || {}
%w[id name maturity criticality].each do |key|
  errors << "project.#{key} is required" if project[key].to_s.strip.empty?
end

module_groups = manifest["modules"]
if !module_groups.is_a?(Hash)
  errors << "modules must be a map of module arrays"
else
  allowed = %w[core stacks architectures data delivery management domains agents]
  extra = module_groups.keys - allowed
  errors << "unknown module groups: #{extra.join(', ')}" unless extra.empty?
  allowed.each do |group|
    next if module_groups[group].nil?
    errors << "modules.#{group} must be an array" unless module_groups[group].is_a?(Array)
  end
end

overrides = manifest["overrides"]
if !overrides.is_a?(Hash)
  errors << "overrides must be present"
else
  %w[requiredArtifacts disabledValidations].each do |key|
    next if overrides[key].nil?
    errors << "overrides.#{key} must be an array" unless overrides[key].is_a?(Array)
  end
end

if errors.empty?
  puts "✓ Manifest structure is valid: #{manifest_path}"
else
  warn "✗ Manifest validation failed:"
  errors.each { |error| warn "  - #{error}" }
  exit 1
end
RUBY
