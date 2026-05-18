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
# Companion rule logic WITH forbiddenPatterns — inline simulation
#
# Mirrors the forbidden-first check from validate-companions.sh so the
# precedence (forbidden wins over requiredAny satisfaction) can be tested
# without shell or git.
# ---------------------------------------------------------------------------
class TestCompanionRuleForbiddenLogic < Minitest::Test
  RULE = {
    "triggerPaths"      => ["^\\.codex/", "(^|/)AGENTS\\.override\\.md$"],
    "requiredAny"       => ["^AGENTS\\.md$", "^docs/adr/ADR-"],
    "forbiddenPatterns" => ["(^|/)AGENTS\\.override\\.md$"]
  }.freeze

  # Returns :pass, :forbidden, or :missing_companion — mirroring the validator's
  # exit-code-determining states.
  def evaluate(changed_files, rule = RULE)
    Array(rule["forbiddenPatterns"]).each do |fp|
      changed_files.each do |path|
        return :forbidden if HarnessRegistry.first_forbidden_match([fp], path)
      end
    end

    triggered = changed_files.any? { |p| HarnessRegistry.patterns_match?(rule["triggerPaths"], p) }
    return :pass unless triggered

    satisfied = changed_files.any? { |p| HarnessRegistry.patterns_match?(rule["requiredAny"], p) }
    satisfied ? :pass : :missing_companion
  end

  def test_no_changes_passes
    assert_equal :pass, evaluate([])
  end

  def test_unrelated_change_passes
    assert_equal :pass, evaluate(["src/app.ts"])
  end

  def test_forbidden_path_alone_fails
    assert_equal :forbidden, evaluate(["src/AGENTS.override.md"])
  end

  def test_forbidden_path_with_satisfying_required_any_still_fails
    # The whole point — a forbidden path adjacent to an AGENTS.md edit must
    # NOT pass. Forbidden wins over satisfaction.
    files = ["src/AGENTS.override.md", "AGENTS.md"]
    assert_equal :forbidden, evaluate(files)
  end

  def test_forbidden_root_level_path_fails
    assert_equal :forbidden, evaluate(["AGENTS.override.md"])
  end

  def test_forbidden_deeply_nested_path_fails
    assert_equal :forbidden, evaluate(["a/b/c/d/AGENTS.override.md"])
  end

  def test_trigger_with_companion_passes_when_no_forbidden_match
    assert_equal :pass, evaluate([".codex/config.toml", "AGENTS.md"])
  end

  def test_trigger_without_companion_fails_when_no_forbidden_match
    assert_equal :missing_companion, evaluate([".codex/config.toml"])
  end

  def test_rule_without_forbidden_patterns_behaves_as_before
    rule = {
      "triggerPaths" => ["^docs/product/requirements\\.md$"],
      "requiredAny"  => ["^docs/project/change-log\\.md$"]
    }
    assert_equal :missing_companion, evaluate(["docs/product/requirements.md"], rule)
    assert_equal :pass, evaluate(
      ["docs/product/requirements.md", "docs/project/change-log.md"],
      rule
    )
  end

  def test_empty_forbidden_patterns_array_behaves_as_no_field
    rule = RULE.merge("forbiddenPatterns" => [])
    assert_equal :missing_companion, evaluate(["src/AGENTS.override.md"], rule)
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

# ---------------------------------------------------------------------------
# strip_inline_code_spans — v2 renderer-aware helper
#
# `[text](target)` inside an inline backtick code span is markdown code, not a
# real link. Stripping the span before scanning prevents validate-doc-references
# from false-positive flagging pedagogical / example link syntax.
# ---------------------------------------------------------------------------
class TestStripInlineCodeSpans < Minitest::Test
  def test_blank_input_returns_empty_string
    assert_equal "", HarnessRegistry.strip_inline_code_spans("")
  end

  def test_nil_input_returns_empty_string
    assert_equal "", HarnessRegistry.strip_inline_code_spans(nil)
  end

  def test_line_without_backticks_unchanged
    line = "See [config](foo.md) for details.\n"
    assert_equal line, HarnessRegistry.strip_inline_code_spans(line)
  end

  def test_inline_code_span_is_replaced_with_spaces
    line = "Example link: `[X](broken.md)` here.\n"
    out  = HarnessRegistry.strip_inline_code_spans(line)
    refute_includes out, "[X](broken.md)"
    assert_equal line.length, out.length, "length must be preserved for column-offset stability"
  end

  def test_multiple_code_spans_on_one_line_all_stripped
    line = "First `[A](a.md)` then `[B](b.md)`.\n"
    out  = HarnessRegistry.strip_inline_code_spans(line)
    refute_includes out, "[A](a.md)"
    refute_includes out, "[B](b.md)"
  end

  def test_real_link_outside_code_span_preserved
    line = "Real [keep](keep.md) and code `[drop](drop.md)`.\n"
    out  = HarnessRegistry.strip_inline_code_spans(line)
    assert_includes out, "[keep](keep.md)"
    refute_includes out, "[drop](drop.md)"
  end
end

# ---------------------------------------------------------------------------
# link_target_external? — v2 renderer-aware helper
# ---------------------------------------------------------------------------
class TestLinkTargetExternal < Minitest::Test
  def test_https_url_is_external
    assert HarnessRegistry.link_target_external?("https://github.com/x/y")
  end

  def test_http_url_is_external
    assert HarnessRegistry.link_target_external?("http://example.com")
  end

  def test_mailto_is_external
    assert HarnessRegistry.link_target_external?("mailto:user@example.com")
  end

  def test_tel_is_external
    assert HarnessRegistry.link_target_external?("tel:+15555550100")
  end

  def test_anchor_only_is_external
    assert HarnessRegistry.link_target_external?("#section-name")
  end

  def test_autolink_tag_form_is_external
    assert HarnessRegistry.link_target_external?("<https://example.com>")
  end

  def test_template_placeholder_is_external
    assert HarnessRegistry.link_target_external?("{{baseUrl}}/x.md")
  end

  def test_empty_target_is_external
    assert HarnessRegistry.link_target_external?("")
  end

  def test_nil_target_is_external
    assert HarnessRegistry.link_target_external?(nil)
  end

  def test_relative_path_is_not_external
    refute HarnessRegistry.link_target_external?("../foo.md")
    refute HarnessRegistry.link_target_external?("foo.md")
    refute HarnessRegistry.link_target_external?("docs/adr/ADR-0001.md")
  end
end

# ---------------------------------------------------------------------------
# strip_link_anchor — v2 renderer-aware helper
# ---------------------------------------------------------------------------
class TestStripLinkAnchor < Minitest::Test
  def test_no_anchor_unchanged
    assert_equal "foo.md", HarnessRegistry.strip_link_anchor("foo.md")
  end

  def test_anchor_stripped
    assert_equal "foo.md", HarnessRegistry.strip_link_anchor("foo.md#section")
  end

  def test_query_stripped
    assert_equal "foo.md", HarnessRegistry.strip_link_anchor("foo.md?ref=x")
  end

  def test_anchor_at_start_strips_to_empty
    assert_equal "", HarnessRegistry.strip_link_anchor("#section")
  end
end

# ---------------------------------------------------------------------------
# resolve_relative_link — v2 renderer-aware helper
# ---------------------------------------------------------------------------
class TestResolveRelativeLink < Minitest::Test
  def with_project
    Dir.mktmpdir { |tmp| yield File.realpath(tmp) }
  end

  def test_same_dir_link
    with_project do |root|
      result = HarnessRegistry.resolve_relative_link("foo.md", File.join(root, "docs"), root)
      assert_equal "docs/foo.md", result
    end
  end

  def test_parent_dir_link
    with_project do |root|
      result = HarnessRegistry.resolve_relative_link("../shared.md", File.join(root, "docs/adr"), root)
      assert_equal "docs/shared.md", result
    end
  end

  def test_root_relative_via_double_parent
    with_project do |root|
      result = HarnessRegistry.resolve_relative_link("../../platform/x.md", File.join(root, "docs/adr"), root)
      assert_equal "platform/x.md", result
    end
  end

  def test_anchor_stripped_from_resolved_path
    with_project do |root|
      result = HarnessRegistry.resolve_relative_link("README.md#section", root, root)
      assert_equal "README.md", result
    end
  end

  def test_target_at_project_root
    with_project do |root|
      result = HarnessRegistry.resolve_relative_link("README.md", root, root)
      assert_equal "README.md", result
    end
  end

  def test_external_target_returns_nil
    with_project do |root|
      assert_nil HarnessRegistry.resolve_relative_link("https://example.com", root, root)
      assert_nil HarnessRegistry.resolve_relative_link("mailto:x@y", root, root)
      assert_nil HarnessRegistry.resolve_relative_link("#section", root, root)
    end
  end

  def test_target_escaping_project_root_returns_nil
    with_project do |root|
      # ../../../etc/passwd would escape the project root entirely.
      result = HarnessRegistry.resolve_relative_link("../../../../etc/passwd", File.join(root, "docs"), root)
      assert_nil result
    end
  end
end

# ---------------------------------------------------------------------------
# link_target_classify / link_target_renderer_safe? — v2 renderer-aware helper
# ---------------------------------------------------------------------------
class TestLinkTargetClassify < Minitest::Test
  def with_files(files)
    Dir.mktmpdir do |tmp|
      root = File.realpath(tmp)
      Array(files).each do |rel|
        full = File.join(root, rel)
        FileUtils.mkdir_p(File.dirname(full))
        File.write(full, "")
      end
      yield root
    end
  end

  def test_resolves_to_existing_file_with_extension_is_ok
    with_files("docs/foo.md") do |root|
      assert_equal :ok, HarnessRegistry.link_target_classify("docs/foo.md", "docs/foo.md", root)
      assert HarnessRegistry.link_target_renderer_safe?("docs/foo.md", "docs/foo.md", root)
    end
  end

  def test_missing_target_is_missing
    with_files([]) do |root|
      assert_equal :missing, HarnessRegistry.link_target_classify("docs/foo.md", "docs/foo.md", root)
      refute HarnessRegistry.link_target_renderer_safe?("docs/foo.md", "docs/foo.md", root)
    end
  end

  def test_trailing_slash_is_directory_target
    with_files("docs/foo/README.md") do |root|
      assert_equal :directory_target,
                   HarnessRegistry.link_target_classify("docs/foo/", "docs/foo", root)
      refute HarnessRegistry.link_target_renderer_safe?("docs/foo/", "docs/foo", root)
    end
  end

  def test_target_resolving_to_directory_is_directory_target
    # No trailing slash but the resolved path is a directory — still fragile
    # because renderers like GitBook will still try `<target>/README.md`.
    with_files("docs/foo/README.md") do |root|
      assert_equal :directory_target,
                   HarnessRegistry.link_target_classify("docs/foo", "docs/foo", root)
    end
  end

  def test_bare_extensionless_existing_file_is_extensionless
    with_files("LICENSE-MIT") do |root|
      assert_equal :extensionless,
                   HarnessRegistry.link_target_classify("LICENSE-MIT", "LICENSE-MIT", root)
      refute HarnessRegistry.link_target_renderer_safe?("LICENSE-MIT", "LICENSE-MIT", root)
    end
  end

  def test_nil_resolved_path_is_missing
    with_files([]) do |root|
      assert_equal :missing, HarnessRegistry.link_target_classify("foo.md", nil, root)
    end
  end

  def test_anchor_in_target_ignored_for_classification
    with_files("docs/foo.md") do |root|
      assert_equal :ok,
                   HarnessRegistry.link_target_classify("docs/foo.md#section", "docs/foo.md", root)
    end
  end
end

# ---------------------------------------------------------------------------
# extract_markdown_links — v2 renderer-aware helper
# ---------------------------------------------------------------------------
class TestExtractMarkdownLinks < Minitest::Test
  def test_blank_input_returns_empty
    assert_equal [], HarnessRegistry.extract_markdown_links("")
  end

  def test_nil_input_returns_empty
    assert_equal [], HarnessRegistry.extract_markdown_links(nil)
  end

  def test_extracts_single_link
    md   = "See [config](foo/bar.yaml) for details.\n"
    refs = HarnessRegistry.extract_markdown_links(md)
    assert_equal 1, refs.length
    assert_equal "foo/bar.yaml", refs.first[:target]
    assert_equal 1, refs.first[:line]
  end

  def test_extracts_relative_parent_link
    md   = "See [adr](../adr/ADR-0001.md).\n"
    refs = HarnessRegistry.extract_markdown_links(md)
    assert_equal "../adr/ADR-0001.md", refs.first[:target]
  end

  def test_skips_external_links
    md = <<~MD
      [a](https://example.com) [b](http://example.com) [c](mailto:x@y) [d](#anchor)
    MD
    assert_equal [], HarnessRegistry.extract_markdown_links(md)
  end

  def test_skips_links_inside_fenced_block
    md = <<~MD
      Real: [keep](keep.md)

      ```
      Bogus: [drop](drop.md)
      ```

      After: [keep2](keep2.md)
    MD
    targets = HarnessRegistry.extract_markdown_links(md).map { |r| r[:target] }
    assert_includes targets, "keep.md"
    assert_includes targets, "keep2.md"
    refute_includes targets, "drop.md"
  end

  def test_skips_links_inside_inline_code_span
    md   = "Real [keep](keep.md) and pedagogical `[drop](drop.md)`.\n"
    refs = HarnessRegistry.extract_markdown_links(md)
    targets = refs.map { |r| r[:target] }
    assert_includes targets, "keep.md"
    refute_includes targets, "drop.md"
  end

  def test_extracts_link_with_title
    # [text](path "title") form
    md = "See [x](foo.md \"my title\").\n"
    refs = HarnessRegistry.extract_markdown_links(md)
    assert_equal "foo.md", refs.first[:target]
  end

  def test_extracts_bare_extensionless_target
    md = "See [license](LICENSE-MIT) for terms.\n"
    refs = HarnessRegistry.extract_markdown_links(md)
    assert_equal "LICENSE-MIT", refs.first[:target]
  end

  def test_extracts_trailing_slash_target
    md = "See [dir](path/to/dir/) for the bundle.\n"
    refs = HarnessRegistry.extract_markdown_links(md)
    assert_equal "path/to/dir/", refs.first[:target]
  end

  def test_extracts_multiple_links_on_same_line
    md   = "[a](a.md) and [b](b.md) and [c](c.md)\n"
    refs = HarnessRegistry.extract_markdown_links(md)
    assert_equal 3, refs.length
    assert_equal %w[a.md b.md c.md], refs.map { |r| r[:target] }
  end

  def test_extracts_link_with_anchor_preserved_in_target
    # The target still contains the anchor — the caller (validator) strips it
    # via strip_link_anchor / resolve_relative_link.
    md   = "See [x](foo.md#section).\n"
    refs = HarnessRegistry.extract_markdown_links(md)
    assert_equal "foo.md#section", refs.first[:target]
  end

  def test_line_numbers_correct_across_blank_lines
    md = "First line.\n\n[link](foo.md)\n"
    refs = HarnessRegistry.extract_markdown_links(md)
    assert_equal 3, refs.first[:line]
  end
end

# ---------------------------------------------------------------------------
# markdown_files_to_scan — v2 enumeration helper
# ---------------------------------------------------------------------------
class TestMarkdownFilesToScan < Minitest::Test
  def test_finds_top_level_markdown
    Dir.mktmpdir do |tmp|
      root = File.realpath(tmp)
      File.write(File.join(root, "README.md"), "")
      files = HarnessRegistry.markdown_files_to_scan(root)
      assert_includes files, File.join(root, "README.md")
    end
  end

  def test_finds_nested_markdown
    Dir.mktmpdir do |tmp|
      root = File.realpath(tmp)
      FileUtils.mkdir_p(File.join(root, "docs/adr"))
      File.write(File.join(root, "docs/adr/ADR-0001.md"), "")
      files = HarnessRegistry.markdown_files_to_scan(root)
      assert_includes files, File.join(root, "docs/adr/ADR-0001.md")
    end
  end

  def test_excludes_legacy
    Dir.mktmpdir do |tmp|
      root = File.realpath(tmp)
      FileUtils.mkdir_p(File.join(root, "legacy/old"))
      File.write(File.join(root, "legacy/old/x.md"), "")
      File.write(File.join(root, "good.md"), "")
      files = HarnessRegistry.markdown_files_to_scan(root)
      refute_includes files, File.join(root, "legacy/old/x.md")
      assert_includes files, File.join(root, "good.md")
    end
  end

  def test_excludes_node_modules_and_git
    Dir.mktmpdir do |tmp|
      root = File.realpath(tmp)
      FileUtils.mkdir_p(File.join(root, "node_modules/pkg"))
      FileUtils.mkdir_p(File.join(root, ".git"))
      File.write(File.join(root, "node_modules/pkg/readme.md"), "")
      File.write(File.join(root, ".git/HEAD.md"), "")
      files = HarnessRegistry.markdown_files_to_scan(root)
      refute(files.any? { |f| f.include?("/node_modules/") })
      refute(files.any? { |f| f.include?("/.git/") })
    end
  end

  def test_excludes_template_docs_and_fixtures
    Dir.mktmpdir do |tmp|
      root = File.realpath(tmp)
      FileUtils.mkdir_p(File.join(root, "platform/templates/docs"))
      FileUtils.mkdir_p(File.join(root, "platform/validators/test/fixtures/projects/x"))
      File.write(File.join(root, "platform/templates/docs/SUMMARY.md"), "")
      File.write(File.join(root, "platform/validators/test/fixtures/projects/x/foo.md"), "")
      files = HarnessRegistry.markdown_files_to_scan(root)
      refute_includes files, File.join(root, "platform/templates/docs/SUMMARY.md")
      refute_includes files, File.join(root, "platform/validators/test/fixtures/projects/x/foo.md")
    end
  end

  def test_extra_exclude_prefix_honored
    Dir.mktmpdir do |tmp|
      root = File.realpath(tmp)
      FileUtils.mkdir_p(File.join(root, "build"))
      File.write(File.join(root, "build/out.md"), "")
      files = HarnessRegistry.markdown_files_to_scan(root, ["build/"])
      refute_includes files, File.join(root, "build/out.md")
    end
  end
end

# ---------------------------------------------------------------------------
# load_manifest — typed-error shape checking
#
# load_manifest must convert every form of bad input into a typed
# HarnessRegistry::ManifestShapeError so validator heredocs can catch one
# exception type and exit 2 with a clean stderr message. None of these
# scenarios may leak a raw NoMethodError or Psych::SyntaxError to callers.
# ---------------------------------------------------------------------------
class TestLoadManifestShape < Minitest::Test
  def test_valid_manifest_returns_hash
    Dir.mktmpdir do |tmp|
      path = File.join(tmp, "harness.manifest.yaml")
      File.write(path, "schemaVersion: 1\nproject:\n  id: x\n")
      data = HarnessRegistry.load_manifest(path)
      assert_kind_of Hash, data
      assert_equal 1, data["schemaVersion"]
    end
  end

  def test_missing_path_raises_typed_error
    err = assert_raises(HarnessRegistry::ManifestShapeError) do
      HarnessRegistry.load_manifest("/no/such/manifest.yaml")
    end
    assert_match(/not found/i, err.message)
    assert_match(%r{/no/such/manifest\.yaml}, err.message)
  end

  def test_empty_path_raises_typed_error
    err = assert_raises(HarnessRegistry::ManifestShapeError) do
      HarnessRegistry.load_manifest("")
    end
    assert_match(/required/i, err.message)
  end

  def test_nil_path_raises_typed_error
    err = assert_raises(HarnessRegistry::ManifestShapeError) do
      HarnessRegistry.load_manifest(nil)
    end
    assert_match(/required/i, err.message)
  end

  def test_empty_yaml_document_raises_typed_error
    # An empty file parses to nil, which is not a Hash — this is the regression
    # case from the audit: `echo '' | xargs bash validate-manifest.sh` used to
    # produce a raw NoMethodError stack trace.
    Dir.mktmpdir do |tmp|
      path = File.join(tmp, "empty.yaml")
      File.write(path, "")
      err = assert_raises(HarnessRegistry::ManifestShapeError) do
        HarnessRegistry.load_manifest(path)
      end
      assert_match(/mapping at the top level/i, err.message)
      assert_match(/empty document/i, err.message)
    end
  end

  def test_yaml_string_at_top_level_raises_typed_error
    Dir.mktmpdir do |tmp|
      path = File.join(tmp, "string.yaml")
      File.write(path, "just-a-string\n")
      err = assert_raises(HarnessRegistry::ManifestShapeError) do
        HarnessRegistry.load_manifest(path)
      end
      assert_match(/mapping at the top level/i, err.message)
      assert_match(/String/, err.message)
    end
  end

  def test_yaml_array_at_top_level_raises_typed_error
    Dir.mktmpdir do |tmp|
      path = File.join(tmp, "array.yaml")
      File.write(path, "- one\n- two\n")
      err = assert_raises(HarnessRegistry::ManifestShapeError) do
        HarnessRegistry.load_manifest(path)
      end
      assert_match(/mapping at the top level/i, err.message)
      assert_match(/Array/, err.message)
    end
  end

  def test_malformed_yaml_raises_typed_error
    Dir.mktmpdir do |tmp|
      path = File.join(tmp, "broken.yaml")
      # Tab indentation inside a mapping value is a Psych::SyntaxError, as is
      # an unterminated flow mapping. Use the flow form for portability.
      File.write(path, "schemaVersion: 1\nproject: { id: x\n")
      err = assert_raises(HarnessRegistry::ManifestShapeError) do
        HarnessRegistry.load_manifest(path)
      end
      assert_match(/not valid YAML/i, err.message)
    end
  end

  def test_typed_error_is_a_standard_error
    # Validators rescue under StandardError (specifically the typed subclass)
    # without needing a `rescue Exception` — confirm inheritance.
    assert_operator HarnessRegistry::ManifestShapeError, :<, StandardError
  end
end
