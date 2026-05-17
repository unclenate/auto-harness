# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
require "minitest/autorun"
require "open3"
require "tmpdir"
require "fileutils"

# ---------------------------------------------------------------------------
# Integration tests for harness validator shell scripts.
#
# These tests shell out to the actual validate-*.sh scripts against known-good
# and known-bad fixture projects. They verify that:
#   - Each validator exits 0 on valid input
#   - Each validator exits 1 and emits a specific error on invalid input
#   - Disabled-validation overrides are respected
#
# Requirements: Ruby 3.0+, bash
# Run: ruby -I platform/validators/lib \
#           platform/validators/test/test_validators_integration.rb
#
# These tests do NOT call git or external services — companion validation is
# tested via the unit test inline loop in test_harness_registry.rb.
# ---------------------------------------------------------------------------

SCRIPT_DIR   = File.expand_path("../../", __FILE__)       # platform/validators/
PLATFORM_DIR = File.expand_path("../", SCRIPT_DIR)        # platform/
FIXTURES_DIR = File.expand_path("fixtures/projects", File.dirname(__FILE__))

# Helper: run a validator script and return [stdout, stderr, exit_status]
def run_validator(script_name, *args)
  cmd = ["bash", File.join(SCRIPT_DIR, script_name), *args]
  stdout, stderr, status = Open3.capture3(*cmd)
  [stdout.strip, stderr.strip, status.exitstatus]
end

# Helper: path to a fixture project manifest
def fixture_manifest(project_name)
  File.join(FIXTURES_DIR, project_name, "harness.manifest.yaml")
end

# Helper: path to a fixture project root
def fixture_project(project_name)
  File.join(FIXTURES_DIR, project_name)
end

# ---------------------------------------------------------------------------
# validate-manifest.sh
# ---------------------------------------------------------------------------
class TestValidateManifest < Minitest::Test
  def test_valid_prototype_passes
    out, err, code = run_validator("validate-manifest.sh", fixture_manifest("valid-prototype"))
    assert_equal 0, code, "Expected exit 0. stderr: #{err}"
    assert_match(/✓/, out)
  end

  def test_valid_testing_standard_passes
    out, err, code = run_validator("validate-manifest.sh", fixture_manifest("valid-testing-standard"))
    assert_equal 0, code, "Expected exit 0. stderr: #{err}"
    assert_match(/✓/, out)
  end

  def test_broken_bad_schema_fails
    out, err, code = run_validator("validate-manifest.sh", fixture_manifest("broken-bad-schema"))
    assert_equal 1, code, "Expected exit 1. stdout: #{out}"
    assert_match(/schemaVersion must be 1/, err)
    assert_match(/project\.maturity is required/, err)
    assert_match(/project\.criticality is required/, err)
    assert_match(/unknown module groups/, err)
  end

  def test_missing_manifest_aborts
    _out, err, code = run_validator("validate-manifest.sh", "/nonexistent/harness.manifest.yaml")
    assert_equal 1, code
    assert_match(/not found|No such file/i, err)
  end
end

# ---------------------------------------------------------------------------
# validate-module-graph.sh
# ---------------------------------------------------------------------------
class TestValidateModuleGraph < Minitest::Test
  def test_valid_prototype_passes
    out, err, code = run_validator("validate-module-graph.sh", fixture_manifest("valid-prototype"))
    assert_equal 0, code, "Expected exit 0. stderr: #{err}"
    assert_match(/✓/, out)
  end

  def test_valid_testing_standard_passes
    out, err, code = run_validator("validate-module-graph.sh", fixture_manifest("valid-testing-standard"))
    assert_equal 0, code, "Expected exit 0. stderr: #{err}"
    assert_match(/✓/, out)
  end

  def test_broken_bad_dependency_fails
    out, err, code = run_validator("validate-module-graph.sh", fixture_manifest("broken-bad-dependency"))
    assert_equal 1, code, "Expected exit 1. stdout: #{out}"
    assert_match(/depends on missing module project-standard/, err)
  end

  def test_broken_conflict_fails
    out, err, code = run_validator("validate-module-graph.sh", fixture_manifest("broken-conflict"))
    assert_equal 1, code, "Expected exit 1. stdout: #{out}"
    assert_match(/conflict/, err.downcase)
  end
end

# ---------------------------------------------------------------------------
# validate-required-artifacts.sh
# ---------------------------------------------------------------------------
class TestValidateRequiredArtifacts < Minitest::Test
  def test_valid_prototype_with_all_artifacts_passes
    out, err, code = run_validator(
      "validate-required-artifacts.sh",
      fixture_manifest("valid-prototype"),
      fixture_project("valid-prototype")
    )
    assert_equal 0, code, "Expected exit 0. stderr: #{err}"
    assert_match(/✓/, out)
  end

  def test_valid_testing_standard_with_testing_artifacts_passes
    out, err, code = run_validator(
      "validate-required-artifacts.sh",
      fixture_manifest("valid-testing-standard"),
      fixture_project("valid-testing-standard")
    )
    assert_equal 0, code, "Expected exit 0 — testing docs must be present. stderr: #{err}"
    assert_match(/✓/, out)
  end

  def test_broken_missing_artifact_fails
    out, err, code = run_validator(
      "validate-required-artifacts.sh",
      fixture_manifest("broken-missing-artifact"),
      fixture_project("broken-missing-artifact")
    )
    assert_equal 1, code, "Expected exit 1. stdout: #{out}"
    assert_match(/missing/, err)
    assert_match(/docs\/product/, err)
  end

  def test_disabled_validation_exits_zero
    # Create a temporary manifest with required-artifacts disabled
    Dir.mktmpdir do |tmpdir|
      manifest_path = File.join(tmpdir, "harness.manifest.yaml")
      File.write(manifest_path, <<~YAML)
        schemaVersion: 1
        project:
          id: test-disabled
          name: Test Disabled
          maturity: prototype
          criticality: low
        modules:
          core:
            - kernel/base
          management:
            - product-lite
        overrides:
          requiredArtifacts: []
          disabledValidations:
            - required-artifacts
      YAML

      out, err, code = run_validator("validate-required-artifacts.sh", manifest_path, tmpdir)
      assert_equal 0, code, "Disabled validation should exit 0. stderr: #{err}"
      assert_match(/disabled/i, out)
    end
  end

  def test_artifact_missing_from_project_root_fails
    # Valid manifest but empty project directory — no artifact files exist
    Dir.mktmpdir do |tmpdir|
      out, err, code = run_validator(
        "validate-required-artifacts.sh",
        fixture_manifest("broken-missing-artifact"),
        tmpdir
      )
      assert_equal 1, code, "Expected exit 1 for missing artifacts. stdout: #{out}"
      assert_match(/missing/, err)
    end
  end

  # ---------------------------------------------------------------------------
  # oneOf semantics + glob support (see ADR-0006)
  #
  # These tests drive validate-required-artifacts.sh against synthesized
  # manifests that exercise oneOf entries via overrides.requiredArtifacts.
  # Going through overrides avoids coupling the integration test to any
  # specific module's yaml — the heavy lifting is in HarnessRegistry, and the
  # shell validator is just a thin wrapper.
  # ---------------------------------------------------------------------------
  def write_kernel_artifacts(root)
    File.write(File.join(root, "HARNESS.md"), "# HARNESS.md\n")
    File.write(File.join(root, "AGENTS.md"), "# AGENTS.md\n")
    FileUtils.mkdir_p(File.join(root, "docs"))
    File.write(File.join(root, "docs/operating-principles.md"), "# OP\n")
  end

  # override_yaml is the body for overrides.requiredArtifacts, written one entry
  # per element. Each element is either a literal string (e.g. "docs/PRD.md")
  # or a Hash like { "oneOf" => ["docs/PRD.md", "docs/PRD-*.md"] }. Building the
  # YAML programmatically avoids fragile heredoc-in-heredoc indentation.
  def write_oneof_manifest(path, override_entries)
    lines = [
      "schemaVersion: 1",
      "project:",
      "  id: test-oneof",
      "  name: Test OneOf",
      "  maturity: prototype",
      "  criticality: low",
      "modules:",
      "  core:",
      "    - kernel/base",
      "overrides:",
      "  requiredArtifacts:"
    ]
    Array(override_entries).each do |entry|
      if entry.is_a?(Hash) && entry["oneOf"]
        lines << "    - oneOf:"
        entry["oneOf"].each { |alt| lines << "        - \"#{alt}\"" }
      else
        lines << "    - \"#{entry}\""
      end
    end
    lines << "  disabledValidations: []"
    File.write(path, lines.join("\n") + "\n")
  end

  def test_oneOf_alternative_present_passes
    Dir.mktmpdir do |tmpdir|
      write_kernel_artifacts(tmpdir)
      File.write(File.join(tmpdir, "docs/PRD-v2.md"), "# PRD\n")
      manifest = File.join(tmpdir, "harness.manifest.yaml")
      write_oneof_manifest(manifest, [
        { "oneOf" => ["docs/PRD.md", "docs/PRD-*.md", "docs/product/requirements.md"] }
      ])

      out, err, code = run_validator("validate-required-artifacts.sh", manifest, tmpdir)
      assert_equal 0, code, "oneOf with glob match must pass. stderr: #{err}\nstdout: #{out}"
      assert_match(/✓/, out)
    end
  end

  def test_oneOf_all_alternatives_missing_fails_with_one_of_label
    Dir.mktmpdir do |tmpdir|
      write_kernel_artifacts(tmpdir)
      manifest = File.join(tmpdir, "harness.manifest.yaml")
      write_oneof_manifest(manifest, [
        { "oneOf" => ["docs/PRD.md", "docs/PRD-*.md"] }
      ])

      _out, err, code = run_validator("validate-required-artifacts.sh", manifest, tmpdir)
      assert_equal 1, code, "all oneOf alternatives missing must fail"
      assert_match(/missing.*one of/i, err)
      assert_match(/PRD\.md/, err)
    end
  end

  def test_glob_in_literal_entry_matches
    Dir.mktmpdir do |tmpdir|
      write_kernel_artifacts(tmpdir)
      FileUtils.mkdir_p(File.join(tmpdir, "docs"))
      File.write(File.join(tmpdir, "docs/PRD-v3-final.md"), "# PRD\n")
      manifest = File.join(tmpdir, "harness.manifest.yaml")
      write_oneof_manifest(manifest, ["docs/PRD-*.md"])

      out, _err, code = run_validator("validate-required-artifacts.sh", manifest, tmpdir)
      assert_equal 0, code, "literal glob entry should match. stdout: #{out}"
      assert_match(/✓/, out)
    end
  end

  def test_mixed_literal_and_oneOf_entries_both_satisfied_passes
    Dir.mktmpdir do |tmpdir|
      write_kernel_artifacts(tmpdir)
      FileUtils.mkdir_p(File.join(tmpdir, "docs"))
      File.write(File.join(tmpdir, "docs/full-plan.md"), "# Plan\n")
      File.write(File.join(tmpdir, "docs/PRD-v1.md"), "# PRD\n")
      manifest = File.join(tmpdir, "harness.manifest.yaml")
      write_oneof_manifest(manifest, [
        "docs/full-plan.md",
        { "oneOf" => ["docs/PRD.md", "docs/PRD-*.md"] }
      ])

      out, err, code = run_validator("validate-required-artifacts.sh", manifest, tmpdir)
      assert_equal 0, code, "mixed entries all satisfied must pass. stderr: #{err}"
      assert_match(/✓/, out)
    end
  end

  def test_existing_modules_with_literal_artifacts_still_work
    # Backwards-compat smoke test — the existing valid-prototype fixture uses
    # only literal artifacts and must continue to validate green unchanged.
    out, err, code = run_validator(
      "validate-required-artifacts.sh",
      fixture_manifest("valid-prototype"),
      fixture_project("valid-prototype")
    )
    assert_equal 0, code, "literal-only modules must keep passing. stderr: #{err}"
    assert_match(/✓/, out)
  end
end

# ---------------------------------------------------------------------------
# validate-placeholders.sh
# Note: this validator takes only a project root (no manifest arg) — it scans
# all tracked files for [[PLACEHOLDER]] and YYYY-MM-DD tokens using ripgrep.
# These tests are skipped when ripgrep is not installed as a real binary.
# ---------------------------------------------------------------------------
RG_AVAILABLE = system("bash -c 'command -v rg >/dev/null 2>&1'")

class TestValidatePlaceholders < Minitest::Test
  def setup
    skip "ripgrep (rg) not installed as a real binary — skipping placeholder tests" unless RG_AVAILABLE
  end

  def test_no_placeholders_passes
    Dir.mktmpdir do |tmpdir|
      File.write(File.join(tmpdir, "README.md"), "No placeholders here.\n")

      out, err, code = run_validator("validate-placeholders.sh", tmpdir)
      assert_equal 0, code, "Expected exit 0. stderr: #{err}"
      assert_match(/✓/, out)
    end
  end

  def test_unfilled_bracket_placeholder_fails
    Dir.mktmpdir do |tmpdir|
      File.write(File.join(tmpdir, "docs.md"), "Owner: [[OWNER_NAME]]\n")

      out, _err, code = run_validator("validate-placeholders.sh", tmpdir)
      assert_equal 1, code, "Expected exit 1 for unfilled placeholder"
      assert_match(/OWNER_NAME/, out)
    end
  end

  def test_date_placeholder_fails
    Dir.mktmpdir do |tmpdir|
      File.write(File.join(tmpdir, "notes.md"), "Last reviewed: YYYY-MM-DD\n")

      out, _err, code = run_validator("validate-placeholders.sh", tmpdir)
      assert_equal 1, code, "Expected exit 1 for YYYY-MM-DD placeholder"
      assert_match(/YYYY-MM-DD/, out)
    end
  end

  def test_valid_prototype_fixture_passes
    # The valid-prototype fixture has only empty stub files — no placeholder tokens
    out, err, code = run_validator("validate-placeholders.sh", fixture_project("valid-prototype"))
    assert_equal 0, code, "Expected exit 0 for valid-prototype fixture. stderr: #{err}"
    assert_match(/✓/, out)
  end
end

# ---------------------------------------------------------------------------
# validate-agent-pack.sh
# ---------------------------------------------------------------------------
class TestValidateAgentPack < Minitest::Test
  def test_valid_prototype_with_agents_md_passes
    out, err, code = run_validator(
      "validate-agent-pack.sh",
      fixture_manifest("valid-prototype"),
      fixture_project("valid-prototype")
    )
    assert_equal 0, code, "Expected exit 0. stderr: #{err}"
    assert_match(/✓/, out)
  end

  def test_missing_agents_md_fails
    Dir.mktmpdir do |tmpdir|
      manifest_path = File.join(tmpdir, "harness.manifest.yaml")
      File.write(manifest_path, <<~YAML)
        schemaVersion: 1
        project:
          id: test-no-agents
          name: No Agents MD
          maturity: prototype
          criticality: low
        modules:
          core:
            - kernel/base
          agents:
            - base
        overrides:
          requiredArtifacts: []
          disabledValidations: []
      YAML
      # AGENTS.md intentionally not created

      out, err, code = run_validator("validate-agent-pack.sh", manifest_path, tmpdir)
      assert_equal 1, code, "Expected exit 1 for missing AGENTS.md. stdout: #{out}"
      assert_match(/AGENTS\.md/, err)
    end
  end

  def test_no_agent_modules_passes_vacuously
    Dir.mktmpdir do |tmpdir|
      manifest_path = File.join(tmpdir, "harness.manifest.yaml")
      File.write(manifest_path, <<~YAML)
        schemaVersion: 1
        project:
          id: test-no-agent-module
          name: No Agent Module
          maturity: prototype
          criticality: low
        modules:
          core:
            - kernel/base
        overrides:
          requiredArtifacts: []
          disabledValidations: []
      YAML

      out, err, code = run_validator("validate-agent-pack.sh", manifest_path, tmpdir)
      assert_equal 0, code, "Expected exit 0 when no agent modules declared. stderr: #{err}"
    end
  end
end

# ---------------------------------------------------------------------------
# Submodule-mount path resolution
#
# Proves that validators work correctly when invoked through a submodule-style
# mount path (e.g. `.harness/platform/validators/...`) rather than through the
# top-level `platform/validators/...`. The fixture at
# `fixtures/projects/valid-submodule-mount/` contains a `.harness` symlink
# that simulates what `git submodule add` would produce in a consumer repo.
#
# The claim under test: HARNESS_ROOT resolution via SCRIPT_DIR/../.. is
# mount-agnostic, so no validator changes are required to support submodule
# consumers. A green test here is the proof.
# ---------------------------------------------------------------------------
class TestSubmoduleMount < Minitest::Test
  SUBMODULE_FIXTURE = File.expand_path("fixtures/projects/valid-submodule-mount", File.dirname(__FILE__))

  # Run a validator through the fixture's own `.harness/platform/validators/...` path.
  def run_via_mount(script_name, *args)
    mount_script = File.join(SUBMODULE_FIXTURE, ".harness/platform/validators", script_name)
    cmd = ["bash", mount_script, *args]
    stdout, stderr, status = Open3.capture3(*cmd)
    [stdout.strip, stderr.strip, status.exitstatus]
  end

  def manifest_path
    File.join(SUBMODULE_FIXTURE, "harness.manifest.yaml")
  end

  def test_harness_symlink_resolves_to_repo_root
    mount = File.join(SUBMODULE_FIXTURE, ".harness")
    assert File.symlink?(mount), "expected .harness to be a symlink"
    resolved = File.realpath(mount)
    expected = File.expand_path("..", PLATFORM_DIR)  # platform/'s parent = repo root
    assert_equal expected, resolved,
                 "mount symlink should resolve to the auto-harness repo root"
  end

  def test_validate_manifest_through_mount_passes
    out, err, code = run_via_mount("validate-manifest.sh", manifest_path)
    assert_equal 0, code, "expected exit 0 through mount. stderr: #{err}"
    assert_match(/✓/, out)
  end

  def test_validate_module_graph_through_mount_passes
    out, err, code = run_via_mount("validate-module-graph.sh", manifest_path)
    assert_equal 0, code, "expected exit 0 through mount. stderr: #{err}"
    assert_match(/✓/, out)
  end

  def test_top_level_and_mount_paths_produce_equivalent_results
    # Same manifest, same validator, invoked two different ways — must agree.
    top_out, _top_err, top_code =
      run_validator("validate-manifest.sh", manifest_path)
    mount_out, _mount_err, mount_code =
      run_via_mount("validate-manifest.sh", manifest_path)

    assert_equal top_code, mount_code,
                 "exit codes must match between top-level and mount invocations"
    assert_equal top_out, mount_out,
                 "stdout must match between top-level and mount invocations"
  end
end
