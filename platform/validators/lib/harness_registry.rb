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

  # Raised by load_manifest / load_yaml when the input file is missing,
  # unreadable, fails to parse as YAML, or parses to something other than a
  # top-level mapping (Hash). Validators rescue this to convert raw Ruby
  # stack traces into clean "✗ <message>" stderr + exit 2 (usage error).
  class ManifestShapeError < StandardError; end

  def self.load_yaml(path)
    YAML.safe_load(File.read(path), permitted_classes: [], aliases: false)
  end

  # Load and shape-check a manifest file. Returns the parsed Hash on success.
  # Raises ManifestShapeError with a human-readable message when the input is
  # missing, unreadable, malformed YAML, or not a top-level mapping. Callers
  # (validator Ruby heredocs) rescue this and exit 2 with the message — never
  # leak a raw NoMethodError / Psych::SyntaxError stack trace to end users.
  def self.load_manifest(path)
    unless path.is_a?(String) && !path.empty?
      raise ManifestShapeError, "Manifest path is required (got #{path.inspect})"
    end
    unless File.exist?(path)
      raise ManifestShapeError, "Manifest not found: #{path}"
    end
    unless File.readable?(path)
      raise ManifestShapeError, "Manifest is not readable: #{path}"
    end

    raw = File.read(path)
    begin
      data = YAML.safe_load(raw, permitted_classes: [], aliases: false)
    rescue Psych::SyntaxError => e
      raise ManifestShapeError, "Manifest is not valid YAML (#{path}): #{e.message}"
    end

    unless data.is_a?(Hash)
      actual = data.nil? ? "empty document" : data.class.to_s
      raise ManifestShapeError,
            "Manifest must be a YAML mapping at the top level (got #{actual}): #{path}"
    end

    data
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

  # Returns true when the artifact entry is satisfied relative to project_root.
  # entry may be a literal path string, a path with glob characters (* or ?),
  # or a hash of the form { "oneOf" => [<path-or-glob>, ...] } which is satisfied
  # when at least one alternative is satisfied.
  def self.artifact_satisfied?(entry, project_root)
    if entry.is_a?(Hash) && entry.key?("oneOf")
      Array(entry["oneOf"]).any? { |alt| path_or_glob_exists?(alt, project_root) }
    else
      path_or_glob_exists?(entry, project_root)
    end
  end

  # Human-readable label for an artifact entry — used in validator error output.
  def self.artifact_label(entry)
    if entry.is_a?(Hash) && entry.key?("oneOf")
      "one of: #{Array(entry['oneOf']).join(', ')}"
    else
      entry.to_s
    end
  end

  def self.path_or_glob_exists?(pattern, project_root)
    return false unless pattern.is_a?(String) && !pattern.empty?

    full = File.join(project_root, pattern)
    if pattern.include?("*") || pattern.include?("?") || pattern.include?("[")
      !Dir.glob(full).empty?
    else
      File.exist?(full)
    end
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

  # Returns the first [pattern, matched_path] tuple where `path` matches a
  # forbidden pattern, or nil when no match. Used by validate-companions.sh to
  # produce a clear "forbidden path X matched pattern Y" error message.
  def self.first_forbidden_match(patterns, path)
    Array(patterns).each do |pattern|
      return [pattern, path] if Regexp.new(pattern).match?(path)
    end
    nil
  end

  # ---------------------------------------------------------------------------
  # Doc-reference extraction (validate-doc-references.sh)
  #
  # Extracts every `platform/...` path string from a Markdown document so the
  # validator can assert each referenced path resolves on disk. The extractor
  # skips fenced code blocks (``` ... ```) so illustrative paths used in code
  # examples don't trigger false positives.
  #
  # The recognized regex matches paths shaped like:
  #   platform/<word-chars-with-./->/...<ext>
  # where <ext> ∈ { md, yaml, yml, sh, rb, json, txt }.
  #
  # Returns an array of hashes: [{path: String, line: Integer}, ...].
  # ---------------------------------------------------------------------------
  DOC_REFERENCE_REGEX = %r{platform/[A-Za-z0-9_./\-]+\.(?:md|yaml|yml|sh|rb|json|txt)}.freeze
  FENCE_REGEX = /\A\s*```/.freeze

  def self.extract_doc_references(markdown)
    return [] unless markdown.is_a?(String)

    in_fence = false
    references = []

    markdown.each_line.with_index(1) do |line, lineno|
      if line.match?(FENCE_REGEX)
        in_fence = !in_fence
        next
      end
      next if in_fence

      line.scan(DOC_REFERENCE_REGEX) do |_|
        match_data = Regexp.last_match
        references << { path: match_data[0], line: lineno }
      end
    end

    references
  end

  def self.load_doc_reference_ignore(path)
    return [] unless File.exist?(path)

    File.readlines(path).map(&:strip).reject do |line|
      line.empty? || line.start_with?("#")
    end
  end

  def self.doc_reference_ignored?(path, patterns)
    Array(patterns).any? { |pattern| Regexp.new(pattern).match?(path) }
  end

  # Resolve a `platform/...`-style reference against the project root. Returns
  # true if the file (or, for trailing-slash refs, directory) exists on disk.
  def self.doc_reference_resolves?(path, project_root)
    return false unless path.is_a?(String) && !path.empty?

    File.exist?(File.join(project_root, path))
  end
end
