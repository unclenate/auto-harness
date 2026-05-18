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
BASE_BRANCH="${3:-main}"

ruby -I"${SCRIPT_DIR}/lib" - "${PLATFORM_ROOT}" "${MANIFEST_PATH}" "${PROJECT_ROOT}" "${BASE_BRANCH}" <<'RUBY'
require "harness_registry"

platform_root = ARGV[0]
manifest_path = ARGV[1]
project_root = ARGV[2]
base_branch = ARGV[3]
manifest = HarnessRegistry.load_manifest(manifest_path)

if HarnessRegistry.disabled_validation?(manifest, "companions")
  puts "✓ Companion validation disabled by manifest override"
  exit 0
end

modules = HarnessRegistry.active_modules(platform_root, manifest)
changed_files = HarnessRegistry.changed_files(project_root, base_branch)

if changed_files.empty?
  puts "No changed files detected relative to #{base_branch}. Skipping companion validation."
  exit 0
end

failures = []
forbidden_hits = []

# Forbidden-paths check runs FIRST. A forbidden match is a hard fail regardless
# of any requiredAny satisfaction — a forbidden path satisfying its own
# requiredAny would produce confusing output if the forbidden check ran second.
modules.each do |mod|
  Array(mod["companionRules"]).each do |rule|
    forbidden = Array(rule["forbiddenPatterns"])
    next if forbidden.empty?

    changed_files.each do |path|
      match = HarnessRegistry.first_forbidden_match(forbidden, path)
      next unless match

      forbidden_hits << {
        "module" => mod["id"],
        "description" => rule["description"],
        "pattern" => match[0],
        "path" => match[1]
      }
    end
  end
end

modules.each do |mod|
  Array(mod["companionRules"]).each do |rule|
    triggered = changed_files.any? { |path| HarnessRegistry.patterns_match?(rule["triggerPaths"], path) }
    next unless triggered

    satisfied = changed_files.any? { |path| HarnessRegistry.patterns_match?(rule["requiredAny"], path) }
    next if satisfied

    failures << {
      "module" => mod["id"],
      "description" => rule["description"],
      "required" => Array(rule["requiredAny"]),
      "review" => rule["humanReview"]
    }
  end
end

if forbidden_hits.empty? && failures.empty?
  puts "✓ Companion validation passed."
  exit 0
end

if !forbidden_hits.empty?
  warn "✗ Companion validation failed (forbidden paths):"
  forbidden_hits.each do |hit|
    warn "  ERROR: forbidden path #{hit['path']} matched pattern #{hit['pattern']} (rule: #{hit['description']})"
  end
end

if !failures.empty?
  warn "✗ Companion validation failed:" if forbidden_hits.empty?
  warn "✗ Companion validation also failed (missing required companions):" unless forbidden_hits.empty?
  failures.each do |failure|
    warn "  - #{failure['module']}: #{failure['description']}"
    failure["required"].each { |pattern| warn "    required change matching #{pattern}" }
    unless failure["review"].to_s.empty?
      warn "    human review: #{failure['review']}"
    end
  end
end

exit 1
RUBY
