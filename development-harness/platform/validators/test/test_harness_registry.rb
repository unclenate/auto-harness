require "minitest/autorun"
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
    "requiredAny"  => ["^docs/project/change-log\\.md$", "^docs/adr/ADR-"]
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
