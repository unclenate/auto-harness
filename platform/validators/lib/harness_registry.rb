# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
require "yaml"

# Defend against catastrophic-backtracking regex from user-controlled
# module.yaml patterns (companionRules.triggerPaths / requiredAny /
# forbiddenPatterns + .doc-reference-ignore). A pathological pattern like
# /(a+)+$/ against a long matching input could otherwise wedge a validator.
# Ruby 3.2+ supports Regexp.timeout; older Ruby (3.0, 3.1) ignores it
# silently so this is safe to set unconditionally.
Regexp.timeout = 1.0 if Regexp.respond_to?(:timeout=)

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

  # ---------------------------------------------------------------------------
  # v2: renderer-aware markdown link extraction
  #
  # The v1 extractor (above) only catches `platform/...`-shaped strings — it
  # misses the bug class that costs reviewers the most:
  #   1. Relative-path link targets (`../foo.md`, `../adr/ADR-0001.md`) — the
  #      idiomatic way to cross-link sibling-dir docs.
  #   2. Bare extensionless targets (`LICENSE-MIT`, `NOTICE`) — render on
  #      GitHub.com but GitBook treats them as directories and 404s on
  #      `<target>/README.md`.
  #   3. Directory-shaped targets (`path/to/dir/`) — same renderer issue.
  #   4. False-positives when `[text](path)` syntax appears inside inline
  #      backtick code spans (which v1 already skips for fenced blocks but not
  #      for inline `...`).
  #
  # The helpers below give validate-doc-references.sh v2 a renderer-aware
  # surface: every `[text](target)` link (skipping fenced + inline code) is
  # resolved relative to the markdown file's directory, checked for on-disk
  # existence, and classified as renderer-safe or renderer-fragile.
  # ---------------------------------------------------------------------------

  # Markdown link `[text](target)`. Captures `target` only — `text` is ignored.
  # The body forbids whitespace and `)` so we don't greedily eat across the
  # closing paren of a sibling link on the same line.
  MARKDOWN_LINK_REGEX = /\[(?:[^\]\n]*)\]\(([^)\s]+)(?:\s+"[^"]*")?\)/.freeze

  # Schemes that should never be checked on disk.
  EXTERNAL_LINK_PREFIXES = %w[http:// https:// mailto: tel: ftp:// ftps:// ssh:// data: javascript:].freeze

  # Inline backtick code-span: `...` (no nesting, single-line). Stripping these
  # before scanning for link syntax prevents false positives when a doc shows
  # an example link as inline code, e.g.: `[X](broken.md)`.
  INLINE_CODE_REGEX = /`[^`\n]*`/.freeze

  # Markdown files we never scan even when nominally under project root.
  # - legacy/ — archived material; broken-link discipline doesn't apply
  # - .git/, .claude/, node_modules/ — tooling/dependency artifacts
  # - .worktrees/ — agent worktrees; transient
  # - platform/validators/test/fixtures/ — intentionally-broken fixtures
  # - platform/templates/docs/ — template SUMMARY.md etc. ship to consumers;
  #                              its `[]()` links are consumer-side, not ours
  DEFAULT_SCAN_EXCLUDE_PREFIXES = [
    "legacy/",
    ".git/",
    ".claude/",
    "node_modules/",
    ".worktrees/",
    "platform/validators/test/fixtures/",
    "platform/templates/docs/"
  ].freeze

  # Remove inline backtick code-spans from a single line. Returns a string
  # of the same length-or-shorter with all `...` runs replaced by spaces so
  # any column offsets a caller might compute remain monotonic.
  def self.strip_inline_code_spans(line)
    return "" unless line.is_a?(String)

    line.gsub(INLINE_CODE_REGEX) { |m| " " * m.length }
  end

  # True if the target is an external scheme, a pure anchor, an HTML tag
  # autolink (`<https://...>`), an empty string, or a template placeholder.
  # These targets are NEVER checked on disk.
  def self.link_target_external?(target)
    return true unless target.is_a?(String)
    return true if target.empty?
    return true if target.start_with?("#")
    return true if target.start_with?("<")
    return true if target.start_with?("{{")  # mustache / liquid templates
    return true if EXTERNAL_LINK_PREFIXES.any? { |p| target.start_with?(p) }

    false
  end

  # Strip `#anchor` (and any `?query`) from a link target. The path portion is
  # what gets checked on disk; anchors and queries are renderer concerns.
  def self.strip_link_anchor(target)
    return target unless target.is_a?(String)

    target.sub(/[#?].*\z/, "")
  end

  # Resolve a relative-link target against the markdown file's directory.
  # Returns the project-root-relative path string with the anchor stripped, or
  # nil if the target escapes the project root (which we treat as not on disk).
  #
  # Examples (project_root = /repo):
  #   resolve_relative_link("foo.md", "/repo/docs/adr", "/repo")
  #     => "docs/adr/foo.md"
  #   resolve_relative_link("../shared.md", "/repo/docs/adr", "/repo")
  #     => "docs/shared.md"
  #   resolve_relative_link("../../platform/x.md", "/repo/docs/adr", "/repo")
  #     => "platform/x.md"
  #   resolve_relative_link("README.md#section", "/repo", "/repo")
  #     => "README.md"
  def self.resolve_relative_link(target, md_file_dir, project_root)
    return nil if link_target_external?(target)

    cleaned = strip_link_anchor(target)
    return nil if cleaned.nil? || cleaned.empty?

    project_root_abs = File.expand_path(project_root)
    md_dir_abs       = File.expand_path(md_file_dir)
    joined           = File.expand_path(cleaned, md_dir_abs)

    # Must remain under project root.
    return nil unless joined == project_root_abs || joined.start_with?(project_root_abs + "/")

    rel = joined.sub(/\A#{Regexp.escape(project_root_abs)}\/?/, "")
    rel = "." if rel.empty?
    rel
  end

  # Renderer-safety classification. Returns one of:
  #   :ok                 — target resolves to a file with a known extension
  #   :missing            — target does not resolve on disk (broken link)
  #   :directory_target   — target ends with `/` (or resolves to a directory) —
  #                         GitBook 404s on `<target>/README.md`
  #   :extensionless      — target has no extension AND resolves to a file
  #                         (e.g. `LICENSE-MIT` — renders on GitHub.com, breaks
  #                         on GitBook which treats it as a directory)
  #
  # `target`  is the raw link target (used to detect trailing slash).
  # `resolved_rel_path` is the project-root-relative resolved path (anchor
  # stripped). nil means resolve_relative_link returned nil (escapes project
  # root → treat as missing).
  def self.link_target_classify(target, resolved_rel_path, project_root)
    return :missing if resolved_rel_path.nil?

    cleaned = strip_link_anchor(target.to_s)
    full    = File.join(project_root, resolved_rel_path)

    return :directory_target if cleaned.end_with?("/")
    return :missing unless File.exist?(full)
    return :directory_target if File.directory?(full)

    basename = File.basename(resolved_rel_path)
    return :extensionless unless basename.include?(".")

    :ok
  end

  # True if the markdown link is safe to leave as-is for both GitHub.com and
  # GitBook-style renderers. Convenience wrapper around link_target_classify.
  def self.link_target_renderer_safe?(target, resolved_rel_path, project_root)
    link_target_classify(target, resolved_rel_path, project_root) == :ok
  end

  # Extract every `[text](target)` link from a markdown document, skipping
  # targets that appear inside fenced code blocks or inline backtick code
  # spans, and skipping external/anchor/template targets. Returns an array of
  # hashes: [{target: String, line: Integer}, ...].
  def self.extract_markdown_links(markdown)
    return [] unless markdown.is_a?(String)

    in_fence = false
    links    = []

    markdown.each_line.with_index(1) do |line, lineno|
      if line.match?(FENCE_REGEX)
        in_fence = !in_fence
        next
      end
      next if in_fence

      stripped = strip_inline_code_spans(line)
      stripped.scan(MARKDOWN_LINK_REGEX) do |match|
        target = match[0]
        next if link_target_external?(target)

        links << { target: target, line: lineno }
      end
    end

    links
  end

  # Enumerate every markdown file under project_root we should scan, applying
  # DEFAULT_SCAN_EXCLUDE_PREFIXES against the project-root-relative path.
  # Extra prefixes (project-specific) may be passed in `extra_exclude_prefixes`.
  # Returns sorted array of absolute paths.
  def self.markdown_files_to_scan(project_root, extra_exclude_prefixes = [])
    project_root_abs = File.expand_path(project_root)
    exclude          = DEFAULT_SCAN_EXCLUDE_PREFIXES + Array(extra_exclude_prefixes)

    # No FNM_DOTMATCH — Dir.glob does not descend into dot-prefixed directories
    # by default, which is the desired behavior for .git/, .claude/, etc.
    Dir.glob(File.join(project_root_abs, "**", "*.md")).reject do |path|
      rel = path.sub(/\A#{Regexp.escape(project_root_abs)}\/?/, "")
      exclude.any? { |prefix| rel.start_with?(prefix) }
    end.sort
  end
end
