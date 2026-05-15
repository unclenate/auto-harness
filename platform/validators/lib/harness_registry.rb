# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
require "yaml"

module HarnessRegistry
  CATEGORY_DIRS = {
    "core" => "core",
    "stacks" => "profiles/stacks",
    "architectures" => "profiles/architectures",
    "data" => "profiles/data",
    "delivery" => "profiles/delivery",
    "management" => "profiles/management",
    "domains" => "profiles/domains",
    "agents" => "agents"
  }.freeze

  def self.load_yaml(path)
    YAML.safe_load(File.read(path), permitted_classes: [], aliases: false)
  end

  def self.load_manifest(path)
    load_yaml(path)
  end

  def self.disabled_validation?(manifest, name)
    Array(manifest.dig("overrides", "disabledValidations")).include?(name)
  end

  def self.required_artifact_overrides(manifest)
    Array(manifest.dig("overrides", "requiredArtifacts"))
  end

  def self.resolve_module_path(platform_root, category, ref)
    base_dir = CATEGORY_DIRS.fetch(category)
    relative = if category == "core"
      File.join(base_dir, ref, "module.yaml")
    else
      File.join(base_dir, ref, "module.yaml")
    end
    File.join(platform_root, relative)
  end

  def self.active_refs(manifest)
    modules = manifest.fetch("modules", {})
    CATEGORY_DIRS.keys.flat_map do |category|
      Array(modules[category]).map { |ref| [category, ref] }
    end
  end

  def self.active_modules(platform_root, manifest)
    active_refs(manifest).map do |category, ref|
      path = resolve_module_path(platform_root, category, ref)
      raise "Missing module definition for #{category}:#{ref} at #{path}" unless File.exist?(path)

      data = load_yaml(path)
      data["__path"] = path
      data["__category"] = category
      data
    end
  end

  def self.module_id_set(modules)
    modules.each_with_object({}) { |mod, acc| acc[mod.fetch("id")] = mod }
  end

  def self.required_artifacts(modules, manifest)
    artifacts = modules.flat_map { |mod| Array(mod["requiredArtifacts"]) }
    artifacts.concat(required_artifact_overrides(manifest))
    artifacts.uniq
  end

  def self.changed_files(project_root, base_branch)
    Dir.chdir(project_root) do
      prefix = `git rev-parse --show-prefix 2>/dev/null`.strip
      output = `git diff --name-only origin/#{base_branch}...HEAD 2>/dev/null`
      output = `git diff --name-only #{base_branch}...HEAD 2>/dev/null` if output.strip.empty?
      output
        .lines
        .map(&:strip)
        .reject(&:empty?)
        .map do |path|
          if prefix.empty?
            path
          elsif path.start_with?(prefix)
            path.delete_prefix(prefix)
          end
        end
        .compact
    end
  end

  def self.patterns_match?(patterns, path)
    Array(patterns).any? { |pattern| Regexp.new(pattern).match?(path) }
  end
end
