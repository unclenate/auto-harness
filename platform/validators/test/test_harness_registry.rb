# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "harness_registry"

# ---------------------------------------------------------------------------
# patterns_match?
# ---------------------------------------------------------------------------
class TestPatternsMatch < Minitest::Test
  def test_single_pattern_matches
    assert HarnessRegistry.patterns_match?(["^docs/product/requirements\\.md$"], "docs/product/requirements.md")
  end

  def test_single_pattern_no_match
    refute HarnessRegistry.patterns_match?(["^docs/product/requirements\\.md$"], "docs/product/release-intent.md")
  end

  def test_multiple_patterns_first_matches
    patterns = ["^docs/product/requirements\\.md$", "^docs/discovery/mvp-scope\\.md$"]
    assert HarnessRegistry.patterns_match?(patterns, "docs/product/requirements.md")
  end

  def test_multiple_patterns_second_matches
    patterns = ["^docs/product/requirements\\.md$", "^docs/discovery/mvp-scope\\.md$"]
    assert HarnessRegistry.patterns_match?(patterns, "docs/discovery/mvp-scope.md")
  end

  def test_multiple_patterns_none_match
    patterns = ["^docs/product/requirements\\.md$", "^docs/discovery/mvp-scope\\.md$"]
    refute HarnessRegistry.patterns_match?(patterns, "src/app.ts")
  end

  def test_prefix_pattern_without_closing_anchor
    # ^docs/adr/ADR- should match any ADR regardless of suffix
    pattern = ["^docs/adr/ADR-"]
    assert HarnessRegistry.patterns_match?(pattern, "docs/adr/ADR-0001-stack-choice.md")
    assert HarnessRegistry.patterns_match?(pattern, "docs/adr/ADR-0002-database.md")
    refute HarnessRegistry.patterns_match?(pattern, "docs/adr/overview.md")
  end

  def test_empty_patterns_array
    refute HarnessRegistry.patterns_match?([], "docs/product/requirements.md")
  end

  def test_nil_patterns_treated_as_empty
    refute HarnessRegistry.patterns_match?(nil, "docs/product/requirements.md")
  end

  def test_path_with_hyphen_and_dot
    # Dots in the pattern are escaped (\.) — bare dot in path should not match wrong files
    assert HarnessRegistry.patterns_match?(["^docs/project/change-log\\.md$"], "docs/project/change-log.md")
    refute HarnessRegistry.patterns_match?(["^docs/project/change-log\\.md$"], "docs/project/change-logXmd")
  end
end

# ---------------------------------------------------------------------------
# disabled_validation?
# ---------------------------------------------------------------------------
class TestDisabledValidation < Minitest::Test
  def manifest_with(disabled)
    { "overrides" => { "disabledValidations" => disabled } }
  end

  def test_validation_listed_is_disabled
    assert HarnessRegistry.disabled_validation?(manifest_with(["required-artifacts"]), "required-artifacts")
  end

  def test_validation_not_listed_is_not_disabled
    refute HarnessRegistry.disabled_validation?(manifest_with(["companions"]), "required-artifacts")
  end

  def test_empty_list_nothing_disabled
    refute HarnessRegistry.disabled_validation?(manifest_with([]), "required-artifacts")
  end

  def test_missing_key_nothing_disabled
    refute HarnessRegistry.disabled_validation?({}, "required-artifacts")
  end

  def test_multiple_entries_correct_one_found
    manifest = manifest_with(["companions", "required-artifacts", "placeholders"])
    assert HarnessRegistry.disabled_validation?(manifest, "required-artifacts")
    assert HarnessRegistry.disabled_validation?(manifest, "companions")
    refute HarnessRegistry.disabled_validation?(manifest, "module-graph")
  end
end

# ---------------------------------------------------------------------------
# required_artifacts aggregation
# ---------------------------------------------------------------------------
class TestRequiredArtifacts < Minitest::Test
  def module_stub(artifacts)
    { "requiredArtifacts" => artifacts }
  end

  def manifest_with_overrides(overrides = [])
    { "overrides" => { "requiredArtifacts" => overrides } }
  end

  def test_single_module_artifacts
    mods = [module_stub(["docs/product/problem-statement.md", "docs/product/requirements.md"])]
    result = HarnessRegistry.required_artifacts(mods, manifest_with_overrides)
    assert_equal ["docs/product/problem-statement.md", "docs/product/requirements.md"], result
  end

  def test_multiple_modules_aggregated
    mods = [
      module_stub(["docs/product/problem-statement.md"]),
      module_stub(["docs/discovery/intake-questionnaire.md", "docs/discovery/mvp-scope.md"])
    ]
    result = HarnessRegistry.required_artifacts(mods, manifest_with_overrides)
    assert_includes result, "docs/product/problem-statement.md"
    assert_includes result, "docs/discovery/intake-questionnaire.md"
    assert_includes result, "docs/discovery/mvp-scope.md"
    assert_equal 3, result.length
  end

  def test_deduplication_across_modules
    mods = [
      module_stub(["HARNESS.md", "AGENTS.md"]),
      module_stub(["HARNESS.md", "docs/operating-principles.md"])
    ]
    result = HarnessRegistry.required_artifacts(mods, manifest_with_overrides)
    assert_equal 1, result.count("HARNESS.md"), "HARNESS.md should appear only once"
    assert_equal 3, result.length
  end

  def test_manifest_overrides_appended
    mods = [module_stub(["docs/product/requirements.md"])]
    manifest = manifest_with_overrides(["docs/extra/custom-artifact.md"])
    result = HarnessRegistry.required_artifacts(mods, manifest)
    assert_includes result, "docs/product/requirements.md"
    assert_includes result, "docs/extra/custom-artifact.md"
  end

  def test_nil_required_artifacts_handled
    mods = [{ "requiredArtifacts" => nil }]
    result = HarnessRegistry.required_artifacts(mods, manifest_with_overrides)
    assert_equal [], result
  end

  def test_mixed_literal_and_oneOf_entries_aggregated
    one_of = { "oneOf" => ["docs/PRD.md", "docs/PRD-*.md"] }
    mods = [module_stub(["docs/operating-principles.md", one_of])]
    result = HarnessRegistry.required_artifacts(mods, manifest_with_overrides)
    assert_equal 2, result.length
    assert_includes result, "docs/operating-principles.md"
    assert_includes result, one_of
  end

  def test_duplicate_oneOf_deduplicated
    a = { "oneOf" => ["docs/PRD.md", "docs/PRD-*.md"] }
    b = { "oneOf" => ["docs/PRD.md", "docs/PRD-*.md"] }
    mods = [module_stub([a]), module_stub([b])]
    result = HarnessRegistry.required_artifacts(mods, manifest_with_overrides)
    assert_equal 1, result.length, "structurally identical oneOf entries must dedupe"
  end
end

# ---------------------------------------------------------------------------
# artifact_satisfied? — supports literal paths, oneOf alternatives, and globs
#
# Spec (see ADR-0006):
#   - Literal path string: satisfied iff the file exists relative to project root
#   - oneOf hash: satisfied iff at least one alternative is satisfied
#   - Glob characters (`*`, `?`) in any path expand via Dir.glob
# ---------------------------------------------------------------------------
class TestArtifactSatisfied < Minitest::Test
  def with_files(files)
    Dir.mktmpdir do |tmpdir|
      Array(files).each do |rel|
        full = File.join(tmpdir, rel)
        FileUtils.mkdir_p(File.dirname(full))
        File.write(full, "")
      end
      yield tmpdir
    end
  end

  def test_literal_path_present
    with_files("docs/operating-principles.md") do |root|
      assert HarnessRegistry.artifact_satisfied?("docs/operating-principles.md", root)
    end
  end

  def test_literal_path_missing
    with_files([]) do |root|
      refute HarnessRegistry.artifact_satisfied?("docs/operating-principles.md", root)
    end
  end

  def test_oneOf_all_missing_fails
    with_files([]) do |root|
      entry = { "oneOf" => ["docs/PRD.md", "docs/full-plan.md"] }
      refute HarnessRegistry.artifact_satisfied?(entry, root)
    end
  end

  def test_oneOf_first_alternative_present_passes
    with_files("docs/PRD.md") do |root|
      entry = { "oneOf" => ["docs/PRD.md", "docs/product/requirements.md"] }
      assert HarnessRegistry.artifact_satisfied?(entry, root)
    end
  end

  def test_oneOf_second_alternative_present_passes
    with_files("docs/product/requirements.md") do |root|
      entry = { "oneOf" => ["docs/PRD.md", "docs/product/requirements.md"] }
      assert HarnessRegistry.artifact_satisfied?(entry, root)
    end
  end

  def test_glob_in_literal_match
    with_files("docs/PRD-v2.md") do |root|
      assert HarnessRegistry.artifact_satisfied?("docs/PRD-*.md", root)
    end
  end

  def test_glob_in_literal_no_match
    with_files("docs/other.md") do |root|
      refute HarnessRegistry.artifact_satisfied?("docs/PRD-*.md", root)
    end
  end

  def test_glob_in_oneOf_alternative_matches
    with_files("docs/PRD-v2-revised.md") do |root|
      entry = { "oneOf" => ["docs/PRD.md", "docs/PRD-*.md"] }
      assert HarnessRegistry.artifact_satisfied?(entry, root)
    end
  end

  def test_glob_no_match_in_any_oneOf_alternative_fails
    with_files("docs/unrelated.md") do |root|
      entry = { "oneOf" => ["docs/PRD.md", "docs/PRD-*.md"] }
      refute HarnessRegistry.artifact_satisfied?(entry, root)
    end
  end

  def test_question_mark_glob_matches_single_char
    with_files("docs/v1.md") do |root|
      assert HarnessRegistry.artifact_satisfied?("docs/v?.md", root)
    end
  end

  def test_backwards_compat_existing_literal_required_artifact
    # Existing modules use only literal strings — must continue to work unchanged.
    with_files("docs/product/requirements.md") do |root|
      assert HarnessRegistry.artifact_satisfied?("docs/product/requirements.md", root)
    end
  end

  def test_empty_string_entry_is_not_satisfied
    with_files([]) do |root|
      refute HarnessRegistry.artifact_satisfied?("", root)
    end
  end

  def test_oneOf_with_empty_list_is_not_satisfied
    with_files("docs/PRD.md") do |root|
      refute HarnessRegistry.artifact_satisfied?({ "oneOf" => [] }, root)
    end
  end
end

# ---------------------------------------------------------------------------
# artifact_label — human-readable description for error reporting
# ---------------------------------------------------------------------------
class TestArtifactLabel < Minitest::Test
  def test_literal_label_returns_path
    assert_equal "docs/PRD.md", HarnessRegistry.artifact_label("docs/PRD.md")
  end

  def test_oneOf_label_lists_alternatives
    entry = { "oneOf" => ["docs/PRD.md", "docs/PRD-*.md"] }
    label = HarnessRegistry.artifact_label(entry)
    assert_match(/one of/i, label)
    assert_match(/PRD\.md/, label)
    assert_match(/PRD-\*\.md/, label)
  end
end

# ---------------------------------------------------------------------------
# Companion rule logic (inline simulation — no shell, no git)
#
# Reproduces the inner loop from validate-companions.sh so the rule logic
# can be tested with controlled changed_files arrays.
# ---------------------------------------------------------------------------
class TestCompanionRuleLogic < Minitest::Test
  # The rule from discovery-intake / product-lite:
  # trigger: requirements.md or mvp-scope.md changed
  # required: change-log.md OR any ADR file
  RULE = {
    "triggerPaths" => ["^docs/product/requirements\\.md$", "^docs/discovery/mvp-scope\\.md$"],
    "requiredAny"  => ["^docs/project/change-log\\.md$", "^docs/adr/ADR-", "^docs/requirements/PRD-"]
  }.freeze

  # Returns true if the rule passes (not triggered, or triggered and satisfied)
  def rule_passes?(changed_files)
    triggered = changed_files.any? { |p| HarnessRegistry.patterns_match?(RULE["triggerPaths"], p) }
    return true unless triggered

    changed_files.any? { |p| HarnessRegistry.patterns_match?(RULE["requiredAny"], p) }
  end

  def test_requirements_changed_alone_fails
    refute rule_passes?(["docs/product/requirements.md"])
  end

  def test_requirements_with_change_log_passes
    assert rule_passes?(["docs/product/requirements.md", "docs/project/change-log.md"])
  end

  def test_requirements_with_adr_passes
    assert rule_passes?(["docs/product/requirements.md", "docs/adr/ADR-0002-new-decision.md"])
  end

  def test_mvp_scope_changed_alone_fails
    refute rule_passes?(["docs/discovery/mvp-scope.md"])
  end

  def test_mvp_scope_with_change_log_passes
    assert rule_passes?(["docs/discovery/mvp-scope.md", "docs/project/change-log.md"])
  end

  def test_mvp_scope_with_adr_passes
    assert rule_passes?(["docs/discovery/mvp-scope.md", "docs/adr/ADR-0003-scope-change.md"])
  end

  def test_requirements_with_prd_passes
    assert rule_passes?(["docs/product/requirements.md", "docs/requirements/PRD-0001-new-feature.md"])
  end

  def test_mvp_scope_with_prd_passes
    assert rule_passes?(["docs/discovery/mvp-scope.md", "docs/requirements/PRD-0002-scope-pivot.md"])
  end

  def test_unrelated_file_not_triggered
    assert rule_passes?(["src/app.ts", "src/components/Button.tsx"])
  end

  def test_both_trigger_paths_changed_with_companion_passes
    files = ["docs/product/requirements.md", "docs/discovery/mvp-scope.md", "docs/project/change-log.md"]
    assert rule_passes?(files)
  end

  def test_both_trigger_paths_changed_without_companion_fails
    files = ["docs/product/requirements.md", "docs/discovery/mvp-scope.md"]
    refute rule_passes?(files)
  end

  def test_empty_changed_files_not_triggered
    assert rule_passes?([])
  end
end

# ---------------------------------------------------------------------------
# first_forbidden_match — used by validate-companions.sh forbiddenPatterns
# ---------------------------------------------------------------------------
class TestFirstForbiddenMatch < Minitest::Test
  def test_returns_nil_when_no_pattern_matches
    assert_nil HarnessRegistry.first_forbidden_match(["^src/secrets/"], "src/app.ts")
  end

  def test_returns_nil_for_empty_pattern_list
    assert_nil HarnessRegistry.first_forbidden_match([], "src/AGENTS.override.md")
  end

  def test_returns_nil_for_nil_pattern_list
    assert_nil HarnessRegistry.first_forbidden_match(nil, "src/AGENTS.override.md")
  end

  def test_returns_pattern_and_path_when_matched
    pattern, matched = HarnessRegistry.first_forbidden_match(
      ["(^|/)AGENTS\\.override\\.md$"],
      "src/AGENTS.override.md"
    )
    assert_equal "(^|/)AGENTS\\.override\\.md$", pattern
    assert_equal "src/AGENTS.override.md", matched
  end

  def test_first_match_wins_when_multiple_patterns_could_match
    patterns = ["^src/", "^src/AGENTS\\.override\\.md$"]
    pattern, _ = HarnessRegistry.first_forbidden_match(patterns, "src/AGENTS.override.md")
    assert_equal "^src/", pattern, "first pattern in list should be returned"
  end

  def test_matches_root_level_file_via_anchor_alternation
    _, path = HarnessRegistry.first_forbidden_match(
      ["(^|/)AGENTS\\.override\\.md$"],
      "AGENTS.override.md"
    )
    assert_equal "AGENTS.override.md", path
  end

  def test_matches_nested_file_via_slash_alternation
    _, path = HarnessRegistry.first_forbidden_match(
      ["(^|/)AGENTS\\.override\\.md$"],
      "deep/nested/AGENTS.override.md"
    )
    assert_equal "deep/nested/AGENTS.override.md", path
  end
end

# ---------------------------------------------------------------------------
# extract_doc_references — used by validate-doc-references.sh
# ---------------------------------------------------------------------------
class TestExtractDocReferences < Minitest::Test
  def test_returns_empty_for_blank_input
    assert_equal [], HarnessRegistry.extract_doc_references("")
  end

  def test_returns_empty_for_nil_input
    assert_equal [], HarnessRegistry.extract_doc_references(nil)
  end

  def test_returns_empty_when_no_platform_paths
    md = "# Title\n\nNo references here at all.\n"
    assert_equal [], HarnessRegistry.extract_doc_references(md)
  end

  def test_extracts_markdown_link_reference
    md = "See [config](platform/foo/bar.yaml) for details.\n"
    refs = HarnessRegistry.extract_doc_references(md)
    assert_equal 1, refs.length
    assert_equal "platform/foo/bar.yaml", refs.first[:path]
    assert_equal 1, refs.first[:line]
  end

  def test_extracts_bare_path_reference
    md = "Line one.\nSee platform/workflow/foo.md\n"
    refs = HarnessRegistry.extract_doc_references(md)
    assert_equal 1, refs.length
    assert_equal "platform/workflow/foo.md", refs.first[:path]
    assert_equal 2, refs.first[:line]
  end

  def test_extracts_inline_code_reference
    md = "Module at `platform/profiles/foo/module.yaml`.\n"
    refs = HarnessRegistry.extract_doc_references(md)
    assert_equal 1, refs.length
    assert_equal "platform/profiles/foo/module.yaml", refs.first[:path]
  end

  def test_skips_references_inside_fenced_code_blocks
    md = <<~MD
      # Title

      Real: platform/real.md

      ```bash
      cat platform/illustrative/example.md
      ```

      After fence: platform/after.md
    MD
    refs = HarnessRegistry.extract_doc_references(md)
    paths = refs.map { |r| r[:path] }
    assert_includes paths, "platform/real.md"
    assert_includes paths, "platform/after.md"
    refute_includes paths, "platform/illustrative/example.md"
  end

  def test_multiple_extensions_recognized
    md = <<~MD
      - platform/a.md
      - platform/b.yaml
      - platform/c.yml
      - platform/d.sh
      - platform/e.rb
      - platform/f.json
      - platform/g.txt
    MD
    paths = HarnessRegistry.extract_doc_references(md).map { |r| r[:path] }
    %w[platform/a.md platform/b.yaml platform/c.yml platform/d.sh
       platform/e.rb platform/f.json platform/g.txt].each do |p|
      assert_includes paths, p
    end
  end

  def test_unsupported_extension_not_matched
    md = "See platform/foo/image.png for the diagram.\n"
    assert_equal [], HarnessRegistry.extract_doc_references(md)
  end

  def test_multiple_references_on_same_line
    md = "[a](platform/a.md) and [b](platform/b.md)\n"
    refs = HarnessRegistry.extract_doc_references(md)
    assert_equal 2, refs.length
    assert_equal [1, 1], refs.map { |r| r[:line] }
  end

  def test_fence_toggling_handles_multiple_blocks
    md = <<~MD
      Pre: platform/pre.md
      ```
      In1: platform/in1.md
      ```
      Mid: platform/mid.md
      ```
      In2: platform/in2.md
      ```
      Post: platform/post.md
    MD
    paths = HarnessRegistry.extract_doc_references(md).map { |r| r[:path] }
    assert_includes paths, "platform/pre.md"
    assert_includes paths, "platform/mid.md"
    assert_includes paths, "platform/post.md"
    refute_includes paths, "platform/in1.md"
    refute_includes paths, "platform/in2.md"
  end
end

# ---------------------------------------------------------------------------
# doc_reference_ignored? and doc_reference_resolves?
# ---------------------------------------------------------------------------
class TestDocReferenceHelpers < Minitest::Test
  def test_ignored_when_pattern_matches
    assert HarnessRegistry.doc_reference_ignored?(
      "platform/workflow/missing.md",
      ["^platform/workflow/missing\\.md$"]
    )
  end

  def test_not_ignored_when_no_pattern_matches
    refute HarnessRegistry.doc_reference_ignored?(
      "platform/workflow/present.md",
      ["^platform/workflow/missing\\.md$"]
    )
  end

  def test_not_ignored_with_empty_patterns
    refute HarnessRegistry.doc_reference_ignored?("platform/anything.md", [])
  end

  def test_not_ignored_with_nil_patterns
    refute HarnessRegistry.doc_reference_ignored?("platform/anything.md", nil)
  end

  def test_resolves_when_file_exists
    Dir.mktmpdir do |tmp|
      FileUtils.mkdir_p(File.join(tmp, "platform/foo"))
      File.write(File.join(tmp, "platform/foo/bar.md"), "x")
      assert HarnessRegistry.doc_reference_resolves?("platform/foo/bar.md", tmp)
    end
  end

  def test_does_not_resolve_when_file_absent
    Dir.mktmpdir do |tmp|
      refute HarnessRegistry.doc_reference_resolves?("platform/foo/missing.md", tmp)
    end
  end

  def test_does_not_resolve_for_blank_or_nil
    Dir.mktmpdir do |tmp|
      refute HarnessRegistry.doc_reference_resolves?("", tmp)
      refute HarnessRegistry.doc_reference_resolves?(nil, tmp)
    end
  end
end

# ---------------------------------------------------------------------------
# load_doc_reference_ignore — file format and edge cases
# ---------------------------------------------------------------------------
class TestLoadDocReferenceIgnore < Minitest::Test
  def test_returns_empty_when_file_missing
    Dir.mktmpdir do |tmp|
      assert_equal [], HarnessRegistry.load_doc_reference_ignore(File.join(tmp, "nope"))
    end
  end

  def test_reads_one_pattern_per_line
    Dir.mktmpdir do |tmp|
      path = File.join(tmp, ".doc-reference-ignore")
      File.write(path, "^a$\n^b$\n")
      assert_equal ["^a$", "^b$"], HarnessRegistry.load_doc_reference_ignore(path)
    end
  end

  def test_skips_comments_and_blank_lines
    Dir.mktmpdir do |tmp|
      path = File.join(tmp, ".doc-reference-ignore")
      File.write(path, "# header\n\n^a$\n# tail\n^b$\n")
      assert_equal ["^a$", "^b$"], HarnessRegistry.load_doc_reference_ignore(path)
    end
  end

  def test_trims_trailing_whitespace
    Dir.mktmpdir do |tmp|
      path = File.join(tmp, ".doc-reference-ignore")
      File.write(path, "^a$   \n")
      assert_equal ["^a$"], HarnessRegistry.load_doc_reference_ignore(path)
    end
  end
end
