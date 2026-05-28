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
    # Missing manifest is a usage error (the script cannot run at all), not a
    # validation failure — so exit 2, not 1, per the three-state contract.
    _out, err, code = run_validator("validate-manifest.sh", "/nonexistent/harness.manifest.yaml")
    assert_equal 2, code, "missing manifest must exit 2 (usage error), not 1"
    assert_match(/not found|No such file/i, err)
    refute_match(/NoMethodError|Psych::SyntaxError/, err,
                 "raw Ruby exception names must not leak to stderr")
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
# validate-doc-references.sh
#
# Asserts every `platform/...` reference inside Markdown files under
# <project-root>/platform/ resolves on disk. Fenced code blocks are skipped;
# `.doc-reference-ignore` patterns are honored.
# ---------------------------------------------------------------------------
class TestValidateDocReferences < Minitest::Test
  def test_valid_fixture_passes
    out, err, code = run_validator(
      "validate-doc-references.sh",
      fixture_project("valid-doc-references")
    )
    assert_equal 0, code, "Expected exit 0. stderr: #{err}\nstdout: #{out}"
    assert_match(/✓/, out)
  end

  def test_broken_fixture_fails_and_reports_path
    _out, err, code = run_validator(
      "validate-doc-references.sh",
      fixture_project("broken-doc-references")
    )
    assert_equal 1, code, "Expected exit 1 for broken reference"
    assert_match(/does-not-exist\.md/, err, "broken path must appear in stderr")
    assert_match(/index\.md/, err, "source file must appear in stderr")
  end

  def test_broken_reference_inside_fence_passes
    out, err, code = run_validator(
      "validate-doc-references.sh",
      fixture_project("doc-references-in-fence")
    )
    assert_equal 0, code,
                 "Broken reference inside fenced block should be skipped. stderr: #{err}\nstdout: #{out}"
    assert_match(/✓/, out)
  end

  def test_ignore_file_exempts_known_misses
    out, err, code = run_validator(
      "validate-doc-references.sh",
      fixture_project("doc-references-ignored")
    )
    assert_equal 0, code,
                 "Ignore file must exempt known misses. stderr: #{err}\nstdout: #{out}"
    assert_match(/✓/, out)
  end

  def test_missing_project_root_aborts
    # A genuinely missing <project-root> is the only remaining usage error
    # (exit 2). PRD-0012 (OPP-0023) removed the platform/-must-exist guard: a
    # submodule consumer has no top-level platform/, and that is a valid layout,
    # not misuse.
    nonexistent = File.join(Dir.tmpdir, "validate-doc-refs-nope-#{Process.pid}")
    _out, err, code = run_validator("validate-doc-references.sh", nonexistent)
    assert_equal 2, code, "missing project root must exit 2 (usage error)"
    assert_match(/does not exist/i, err)
  end

  def test_empty_dir_has_nothing_to_scan_and_passes
    # No platform/ and no markdown at all → nothing to scan → clean exit 0
    # (NOT exit 2). "Nothing to validate" is success, not a usage error.
    Dir.mktmpdir do |tmpdir|
      out, err, code = run_validator("validate-doc-references.sh", tmpdir)
      assert_equal 0, code, "empty dir (nothing to scan) must exit 0. stderr: #{err}"
      assert_match(/✓/, out)
    end
  end

  def test_consumer_without_platform_dir_valid_passes
    # OPP-0023 / PRD-0012: a submodule consumer (no top-level platform/) whose
    # own docs all resolve must validate green — Pass 2 scans the consumer's
    # *.md regardless of whether a platform/ tree exists.
    out, err, code = run_validator(
      "validate-doc-references.sh",
      fixture_project("consumer-no-platform-valid")
    )
    assert_equal 0, code,
                 "Consumer with no platform/ and valid links must exit 0. stderr: #{err}\nstdout: #{out}"
    assert_match(/✓/, out)
  end

  def test_consumer_without_platform_dir_broken_is_flagged
    # The consumer scan must actually catch a broken link in consumer docs —
    # exit 1 (not exit 2), proving Pass 2 ran against the consumer's own tree.
    _out, err, code = run_validator(
      "validate-doc-references.sh",
      fixture_project("consumer-no-platform-broken")
    )
    assert_equal 1, code, "broken link in a no-platform consumer must exit 1, not 2"
    assert_match(/does-not-exist\.md/, err, "broken consumer path must appear in stderr")
  end

  def test_runs_clean_against_harness_repo
    # The harness's own repo MUST validate green — this is the dogfood guarantee.
    harness_root = File.expand_path("..", PLATFORM_DIR)
    out, err, code = run_validator("validate-doc-references.sh", harness_root)
    assert_equal 0, code,
                 "Harness's own platform/ docs must have no broken references. stderr: #{err}"
    assert_match(/✓/, out)
  end

  # ---------------------------------------------------------------------------
  # v2 — renderer-aware scope expansion
  # ---------------------------------------------------------------------------

  def test_v2_broken_relative_link_is_flagged
    # `[X](../bar/does-not-exist.md)` — no `platform/` prefix, so v1 missed
    # it entirely. v2 must catch it via the relative-link resolver.
    _out, err, code = run_validator(
      "validate-doc-references.sh",
      fixture_project("v2-broken-relative-link")
    )
    assert_equal 1, code, "v2 must catch the broken relative-path link"
    assert_match(/does-not-exist\.md/, err, "broken target must appear in stderr")
    assert_match(/broken/i, err, "reason should classify as broken")
  end

  def test_v2_inline_code_link_is_skipped
    # `[broken](does-not-exist.md)` inside backtick code-span is pedagogical,
    # not a real link. v2 strips inline code spans before extracting links.
    out, err, code = run_validator(
      "validate-doc-references.sh",
      fixture_project("v2-inline-code-link")
    )
    assert_equal 0, code,
                 "Inline-code link syntax must NOT be flagged. stderr: #{err}\nstdout: #{out}"
    assert_match(/✓/, out)
  end

  def test_v2_bare_extensionless_target_is_flagged
    # `[license](../../LICENSE-MIT)` — file exists on disk but GitBook 404s
    # because it treats extensionless basenames as directories.
    _out, err, code = run_validator(
      "validate-doc-references.sh",
      fixture_project("v2-bare-extensionless")
    )
    assert_equal 1, code, "renderer-fragile bare-extensionless link must fail"
    assert_match(/LICENSE-MIT/, err)
    assert_match(/extensionless|GitBook/i, err)
  end

  def test_v2_trailing_slash_directory_target_is_flagged
    # `[inner directory](inner/)` — trailing slash trips GitBook's `<target>/README.md` lookup.
    _out, err, code = run_validator(
      "validate-doc-references.sh",
      fixture_project("v2-trailing-slash")
    )
    assert_equal 1, code, "trailing-slash directory link must fail"
    assert_match(%r{inner/}, err)
    assert_match(/directory target|GitBook/i, err)
  end

  def test_v2_external_targets_are_skipped
    # https://, http://, mailto:, tel:, #anchor, <autolink>, {{template}} are
    # all external/non-disk and must never be flagged.
    out, err, code = run_validator(
      "validate-doc-references.sh",
      fixture_project("v2-external-skipped")
    )
    assert_equal 0, code,
                 "External / anchor / template targets must be skipped. stderr: #{err}\nstdout: #{out}"
    assert_match(/✓/, out)
  end

  def test_v2_ignore_file_exempts_relative_link
    # `.doc-reference-ignore` matches against the resolved project-rooted path,
    # not the raw target — this lets a single rule exempt the same broken
    # target from multiple source files.
    out, err, code = run_validator(
      "validate-doc-references.sh",
      fixture_project("v2-ignored-by-file")
    )
    assert_equal 0, code,
                 "Ignored relative link must not be flagged. stderr: #{err}\nstdout: #{out}"
    assert_match(/✓/, out)
  end
end

# ---------------------------------------------------------------------------
# validate-companions.sh — forbiddenPatterns semantics
#
# Each test sets up a throwaway git repo with a single ephemeral module
# definition that declares a forbidden pattern. The base branch and HEAD
# differ by exactly the file under test, so changed_files() returns it.
#
# These tests skip when `git` is not available in PATH.
# ---------------------------------------------------------------------------
GIT_AVAILABLE = system("bash -c 'command -v git >/dev/null 2>&1'")

class TestValidateCompanionsForbidden < Minitest::Test
  def setup
    skip "git not available — skipping forbidden-pattern integration tests" unless GIT_AVAILABLE
  end

  # Build a temporary harness-mount layout:
  #   <tmp>/.harness/platform/...   (symlink into the real platform/)
  #   <tmp>/harness.manifest.yaml   (declares core + one ad-hoc agent module)
  #   <tmp>/platform/agents/test-forbidden/module.yaml  (forbidden rule)
  #
  # Then init git, commit the baseline, branch, make a change, and run the
  # validator through the .harness mount.
  def with_forbidden_fixture(forbidden_pattern:, change_paths:, baseline_paths: [])
    Dir.mktmpdir do |tmp|
      # Mount the real platform tree so the validator can find core modules.
      FileUtils.mkdir_p(File.join(tmp, ".harness"))
      File.symlink(File.expand_path("..", PLATFORM_DIR), File.join(tmp, ".harness/auto-harness"))
      # Build a side platform/ dir under the fixture that holds the ad-hoc
      # module. Mount the real platform tree under .harness for validator
      # script resolution, then point the manifest at a custom module path
      # via composition through a per-fixture module file.
      ad_hoc_dir = File.join(tmp, "fixture-platform/agents/test-forbidden")
      FileUtils.mkdir_p(ad_hoc_dir)
      File.write(File.join(ad_hoc_dir, "module.yaml"), <<~YAML)
        id: test-forbidden
        type: agent
        version: 0.0.1
        summary: Test-only module exercising forbiddenPatterns.
        dependsOn: []
        conflictsWith: []
        requiredArtifacts: []
        optionalArtifacts: []
        sensitivePaths: []
        companionRules:
          - description: Test forbidden rule
            triggerPaths:
              - "^src/"
            requiredAny:
              - "^AGENTS\\\\.md$"
            forbiddenPatterns:
              - "#{forbidden_pattern}"
        validators:
          - validate-companions
      YAML

      # We avoid wiring this into the real manifest by invoking the validator
      # against a tiny manifest that points at a tiny module set in this tmp.
      # The Ruby loader needs the module YAML resolvable via the standard
      # category dir layout, so symlink into a synthetic platform.
      syn_root = File.join(tmp, "syn")
      syn_platform = File.join(syn_root, "platform")
      FileUtils.mkdir_p(File.join(syn_platform, "agents/test-forbidden"))
      FileUtils.mkdir_p(File.join(syn_platform, "core/kernel/base"))
      FileUtils.mkdir_p(File.join(syn_platform, "validators"))
      File.write(File.join(syn_platform, "agents/test-forbidden/module.yaml"),
                 File.read(File.join(ad_hoc_dir, "module.yaml")))
      # Reuse the real kernel/base module.yaml so dependency resolution works.
      real_kernel = File.join(PLATFORM_DIR, "core/kernel/base/module.yaml")
      File.write(File.join(syn_platform, "core/kernel/base/module.yaml"),
                 File.read(real_kernel))
      # Symlink the validator scripts and lib into the synthetic platform so
      # SCRIPT_DIR/../.. resolves a HARNESS_ROOT that contains the syn manifest.
      %w[validate-companions.sh].each do |s|
        File.symlink(File.join(PLATFORM_DIR, "validators", s),
                     File.join(syn_platform, "validators", s))
      end
      File.symlink(File.join(PLATFORM_DIR, "validators/lib"),
                   File.join(syn_platform, "validators/lib"))

      manifest_path = File.join(syn_root, "harness.manifest.yaml")
      File.write(manifest_path, <<~YAML)
        schemaVersion: 1
        project:
          id: test-forbidden
          name: Test Forbidden
          maturity: prototype
          criticality: low
        modules:
          core:
            - kernel/base
          agents:
            - test-forbidden
        overrides:
          requiredArtifacts: []
          disabledValidations: []
      YAML

      # Build the git working copy at syn_root.
      Dir.chdir(syn_root) do
        system("git init -q -b main")
        system("git config user.email test@example.com")
        system("git config user.name Test")

        # Baseline: write the manifest and any baseline files, then commit on main.
        baseline_paths.each do |p|
          full = File.join(syn_root, p)
          FileUtils.mkdir_p(File.dirname(full))
          File.write(full, "baseline\n")
        end
        system("git add -A")
        system("git commit -q -m baseline")

        # Branch off and make the change(s).
        system("git checkout -q -b feature")
        change_paths.each do |p|
          full = File.join(syn_root, p)
          FileUtils.mkdir_p(File.dirname(full))
          File.write(full, "change\n")
        end
        system("git add -A")
        system("git commit -q -m change")

        # Run the validator script through the synthetic platform.
        script = File.join(syn_platform, "validators/validate-companions.sh")
        cmd = ["bash", script, manifest_path, syn_root, "main"]
        stdout, stderr, status = Open3.capture3(*cmd)
        yield stdout.strip, stderr.strip, status.exitstatus
      end
    end
  end

  # A single innocuous change that triggers nothing in the kernel/base rule.
  # Lets the forbiddenPatterns scenarios be tested without noise from the
  # governance-entrypoint companion rule on AGENTS.md / HARNESS.md edits.
  def test_no_offending_file_passes
    # README.md doesn't match the test rule's triggerPaths (`^src/`), the
    # forbidden pattern, OR any kernel/base trigger — so the run is clean.
    with_forbidden_fixture(
      forbidden_pattern: "(^|/)AGENTS\\\\.override\\\\.md$",
      change_paths: ["README.md"]
    ) do |out, err, code|
      assert_equal 0, code, "no forbidden hit and no other rule triggered. stderr: #{err}\nstdout: #{out}"
      assert_match(/✓/, out)
    end
  end

  def test_offending_file_fails_with_hard_message
    with_forbidden_fixture(
      forbidden_pattern: "(^|/)AGENTS\\\\.override\\\\.md$",
      change_paths: ["src/AGENTS.override.md"]
    ) do |out, err, code|
      assert_equal 1, code, "forbidden hit must fail. stdout: #{out}"
      assert_match(/forbidden path/i, err)
      assert_match(/AGENTS\.override\.md/, err)
    end
  end

  def test_offending_file_with_satisfied_required_any_still_fails
    # The whole point of forbidden-first: even though AGENTS.md would satisfy
    # the requiredAny rule for the trigger paths, the forbidden hit must win.
    # We include docs/operating-principles.md so the kernel/base rule on
    # AGENTS.md doesn't muddy the result.
    with_forbidden_fixture(
      forbidden_pattern: "(^|/)AGENTS\\\\.override\\\\.md$",
      change_paths: ["src/AGENTS.override.md", "AGENTS.md", "docs/operating-principles.md"]
    ) do |out, err, code|
      assert_equal 1, code, "forbidden must win over requiredAny. stdout: #{out}"
      assert_match(/forbidden path/i, err)
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

# ---------------------------------------------------------------------------
# Uniform --help / -h flag on every validator
#
# Each validator must short-circuit on --help or -h as the first argument:
#   - exit 0 (success — user got what they asked for)
#   - stdout starts with a "Usage:" block
#   - no Ruby invocation (so the help text appears even on a project that has
#     no manifest, no platform/ dir, no ripgrep, etc.)
# This guarantee is what makes `validate-X.sh --help` safe as the first thing
# a new user runs.
# ---------------------------------------------------------------------------
VALIDATOR_SCRIPTS = %w[
  validate-manifest.sh
  validate-module-graph.sh
  validate-required-artifacts.sh
  validate-placeholders.sh
  validate-agent-pack.sh
  validate-companions.sh
  validate-doc-references.sh
  validate-catalog-counts.sh
  validate-list-completeness.sh
  validate-trust-tier.sh
  validate-sensitive-paths.sh
].freeze

class TestValidatorHelpFlag < Minitest::Test
  VALIDATOR_SCRIPTS.each do |script|
    define_method("test_#{script.tr('-.', '__')}_long_help_exits_zero") do
      out, err, code = run_validator(script, "--help")
      assert_equal 0, code, "#{script} --help must exit 0. stderr: #{err}"
      assert_match(/Usage:/, out, "#{script} --help must print a Usage: block")
      assert_match(/Exit codes:/, out, "#{script} --help must document exit codes")
    end

    define_method("test_#{script.tr('-.', '__')}_short_help_exits_zero") do
      out, err, code = run_validator(script, "-h")
      assert_equal 0, code, "#{script} -h must exit 0. stderr: #{err}"
      assert_match(/Usage:/, out, "#{script} -h must print a Usage: block")
    end

    define_method("test_#{script.tr('-.', '__')}_help_does_not_invoke_ruby") do
      # If --help short-circuits before the heredoc, it works even when the
      # default manifest path doesn't exist (validator is run from /tmp).
      Dir.mktmpdir do |tmp|
        cmd = ["bash", File.join(SCRIPT_DIR, script), "--help"]
        stdout, _stderr, status = Open3.capture3(*cmd, chdir: tmp)
        assert_equal 0, status.exitstatus,
                     "#{script} --help must work even with no manifest in cwd"
        assert_match(/Usage:/, stdout)
      end
    end
  end
end

# ---------------------------------------------------------------------------
# Typed-error / usage-error exit-code contract (exit 2, not 1)
#
# These tests assert the audit-finding fixes:
#   1. Malformed-shape inputs produce a typed "✗ <message>" line on stderr
#      and exit 2 — never a raw Ruby NoMethodError or Psych::SyntaxError.
#   2. Missing-manifest and missing-dependency conditions also exit 2.
# ---------------------------------------------------------------------------
class TestValidatorUsageErrorExitCodes < Minitest::Test
  def test_empty_manifest_yields_typed_error_and_exit_2
    # Regression for the audit finding:
    #   $ echo '' | xargs bash validate-manifest.sh
    #   -:8:in '<main>': undefined method '[]' for nil (NoMethodError)
    # After fix: clean "✗ ... mapping at the top level ..." + exit 2.
    Dir.mktmpdir do |tmp|
      path = File.join(tmp, "empty.yaml")
      File.write(path, "")
      _out, err, code = run_validator("validate-manifest.sh", path)
      assert_equal 2, code, "empty manifest must exit 2 (usage error)"
      assert_match(/mapping at the top level/i, err)
      refute_match(/NoMethodError/, err,
                   "raw NoMethodError must not leak from validate-manifest.sh")
    end
  end

  def test_malformed_yaml_manifest_yields_typed_error_and_exit_2
    Dir.mktmpdir do |tmp|
      path = File.join(tmp, "broken.yaml")
      File.write(path, "schemaVersion: 1\nproject: { id: x\n")
      _out, err, code = run_validator("validate-manifest.sh", path)
      assert_equal 2, code, "malformed-YAML manifest must exit 2 (usage error)"
      assert_match(/not valid YAML/i, err)
      refute_match(/Psych::SyntaxError/, err,
                   "raw Psych::SyntaxError must not leak to stderr")
    end
  end

  def test_module_graph_empty_manifest_yields_typed_error_and_exit_2
    # validate-module-graph.sh uses HarnessRegistry.load_manifest too — same
    # typed-error contract must apply.
    Dir.mktmpdir do |tmp|
      path = File.join(tmp, "empty.yaml")
      File.write(path, "")
      _out, err, code = run_validator("validate-module-graph.sh", path)
      assert_equal 2, code, "empty manifest must exit 2 from module-graph too"
      assert_match(/mapping at the top level/i, err)
      refute_match(/NoMethodError/, err)
    end
  end

  def test_required_artifacts_missing_manifest_exits_2
    _out, err, code = run_validator(
      "validate-required-artifacts.sh",
      "/nonexistent/manifest.yaml",
      "/tmp"
    )
    assert_equal 2, code, "missing manifest must exit 2"
    assert_match(/not found|No such file/i, err)
  end

  def test_agent_pack_malformed_manifest_exits_2
    Dir.mktmpdir do |tmp|
      path = File.join(tmp, "string.yaml")
      File.write(path, "not-a-mapping\n")
      _out, err, code = run_validator("validate-agent-pack.sh", path, tmp)
      assert_equal 2, code, "non-mapping manifest must exit 2 from agent-pack"
      assert_match(/mapping at the top level/i, err)
    end
  end
end

# ---------------------------------------------------------------------------
# validate-list-completeness.sh
#
# Wave 1 of the 2026-05-27 audit roadmap (refresh-2.md finding M-j). Asserts
# that every governance/catalog entity on disk is referenced in its canonical
# index file. Tests use inline mktmpdir fixtures so each scenario is colocated
# with its assertion — no static disk fixture per case.
# ---------------------------------------------------------------------------
class TestValidateListCompleteness < Minitest::Test
  # Build a minimal "complete-aligned" project tree at `root`: one entity per
  # check (ADR, PRD, OPP, composition, template subdirectory, profile module)
  # with all index rows present.
  def write_complete_fixture(root)
    # ADR + PRD + OPP files
    FileUtils.mkdir_p(File.join(root, "docs/adr"))
    File.write(File.join(root, "docs/adr/ADR-0001-test.md"), "# ADR-0001\n")
    FileUtils.mkdir_p(File.join(root, "docs/requirements"))
    File.write(File.join(root, "docs/requirements/PRD-0001-test.md"), "# PRD-0001\n")
    FileUtils.mkdir_p(File.join(root, "docs/opportunities"))
    File.write(File.join(root, "docs/opportunities/OPP-0001-test.md"), "# OPP-0001\n")
    # candidates.md — either a row or a "retired" footnote satisfies; an
    # OPP-NNNN token in either form contains the assertion anchor.
    File.write(File.join(root, "docs/opportunities/candidates.md"),
               "# Candidates\n\n- OPP-0001 test cluster row\n")

    # docs/README.md — single index for ADR/PRD/OPP tables
    File.write(File.join(root, "docs/README.md"), <<~MD)
      # Records
      | [0001](adr/ADR-0001-test.md) | Test ADR |
      | [0001](requirements/PRD-0001-test.md) | Test PRD |
      | [0001](opportunities/OPP-0001-test.md) | Test OPP |
    MD

    # Composition + dual indexes (compositions/README.md + root README.md)
    FileUtils.mkdir_p(File.join(root, "platform/compositions"))
    File.write(File.join(root, "platform/compositions/test-comp.yaml"),
               "schemaVersion: 1\n")
    File.write(File.join(root, "platform/compositions/README.md"),
               "| [test-comp.yaml](test-comp.yaml) | test |\n")
    File.write(File.join(root, "README.md"),
               "Compositions: [test-comp.yaml](platform/compositions/test-comp.yaml)\n")

    # Template subdirectory + directory-map row
    FileUtils.mkdir_p(File.join(root, "platform/templates/widget"))
    File.write(File.join(root, "platform/templates/widget/template.md"),
               "# widget\n")
    File.write(File.join(root, "platform/templates/README.md"),
               "| Widget | mod | `templates/widget/template.md` |\n")

    # Profile module + SUMMARY.md entry
    FileUtils.mkdir_p(File.join(root, "platform/profiles/management/test-mod"))
    File.write(File.join(root, "platform/profiles/management/test-mod/module.yaml"),
               "id: test-mod\n")
    File.write(File.join(root, "SUMMARY.md"),
               "* [Test](platform/profiles/management/test-mod/README.md)\n")
  end

  def test_complete_fixture_passes
    Dir.mktmpdir do |tmp|
      write_complete_fixture(tmp)
      out, err, code = run_validator("validate-list-completeness.sh", tmp)
      assert_equal 0, code, "complete fixture must pass. stderr: #{err}\nstdout: #{out}"
      assert_match(/✓/, out)
    end
  end

  def test_adr_missing_from_docs_readme_fails
    Dir.mktmpdir do |tmp|
      write_complete_fixture(tmp)
      # Strip the ADR row from docs/README.md
      File.write(File.join(tmp, "docs/README.md"), <<~MD)
        # Records
        | [0001](requirements/PRD-0001-test.md) | Test PRD |
        | [0001](opportunities/OPP-0001-test.md) | Test OPP |
      MD
      _out, err, code = run_validator("validate-list-completeness.sh", tmp)
      assert_equal 1, code, "missing ADR row must exit 1"
      assert_match(/missing ADR row for ADR-0001/, err)
    end
  end

  def test_prd_missing_from_docs_readme_fails
    Dir.mktmpdir do |tmp|
      write_complete_fixture(tmp)
      File.write(File.join(tmp, "docs/README.md"), <<~MD)
        # Records
        | [0001](adr/ADR-0001-test.md) | Test ADR |
        | [0001](opportunities/OPP-0001-test.md) | Test OPP |
      MD
      _out, err, code = run_validator("validate-list-completeness.sh", tmp)
      assert_equal 1, code, "missing PRD row must exit 1"
      assert_match(/missing PRD row for PRD-0001/, err)
    end
  end

  def test_opp_missing_from_candidates_fails
    Dir.mktmpdir do |tmp|
      write_complete_fixture(tmp)
      # OPP is in docs/README.md but absent from candidates.md.
      File.write(File.join(tmp, "docs/opportunities/candidates.md"),
                 "# Candidates\n\n(empty index)\n")
      _out, err, code = run_validator("validate-list-completeness.sh", tmp)
      assert_equal 1, code, "missing OPP candidates row must exit 1"
      assert_match(/missing OPP candidates row for OPP-0001/, err)
    end
  end

  def test_composition_missing_from_compositions_readme_fails
    Dir.mktmpdir do |tmp|
      write_complete_fixture(tmp)
      File.write(File.join(tmp, "platform/compositions/README.md"),
                 "no rows here\n")
      _out, err, code = run_validator("validate-list-completeness.sh", tmp)
      assert_equal 1, code, "missing composition row must exit 1"
      assert_match(/missing composition.*for test-comp\.yaml/, err)
    end
  end

  def test_template_subdirectory_missing_from_templates_readme_fails
    Dir.mktmpdir do |tmp|
      write_complete_fixture(tmp)
      # Wipe the templates README row for the widget subdir
      File.write(File.join(tmp, "platform/templates/README.md"),
                 "no directory-map rows\n")
      _out, err, code = run_validator("validate-list-completeness.sh", tmp)
      assert_equal 1, code, "missing template subdirectory row must exit 1"
      assert_match(/missing template subdirectory row for widget/, err)
    end
  end

  def test_profile_module_missing_from_summary_fails
    Dir.mktmpdir do |tmp|
      write_complete_fixture(tmp)
      File.write(File.join(tmp, "SUMMARY.md"), "* [Other](other.md)\n")
      _out, err, code = run_validator("validate-list-completeness.sh", tmp)
      assert_equal 1, code, "missing module row in SUMMARY.md must exit 1"
      assert_match(/missing profile module row for profiles\/management\/test-mod/, err)
    end
  end

  def test_consumer_without_entity_directories_passes_vacuously
    # Consumer-safety contract: if a downstream project omits a category
    # directory entirely (no docs/adr/, no compositions, etc.), the check is
    # a no-op for that category. Empty tree → zero entities → exit 0.
    Dir.mktmpdir do |tmp|
      out, err, code = run_validator("validate-list-completeness.sh", tmp)
      assert_equal 0, code,
                   "empty directory must pass (no entities to assert). stderr: #{err}"
      assert_match(/✓/, out)
    end
  end

  def test_missing_project_root_aborts_with_exit_2
    nonexistent = File.join(Dir.tmpdir, "validate-list-completeness-nope-#{Process.pid}")
    _out, err, code = run_validator("validate-list-completeness.sh", nonexistent)
    assert_equal 2, code, "missing project root must exit 2 (usage error)"
    assert_match(/not a directory/i, err)
  end

  def test_runs_clean_against_harness_repo
    # Dogfood: the harness's own repo must validate green. This is the
    # acceptance test for Wave 1's "land an immediate fixing commit" —
    # ADR-0015 row, missing composition rows, missing template subdir
    # entries all repaired in the same PR that introduces the validator.
    harness_root = File.expand_path("..", PLATFORM_DIR)
    out, err, code = run_validator("validate-list-completeness.sh", harness_root)
    assert_equal 0, code,
                 "Harness's own indexes must be complete. stderr: #{err}\nstdout: #{out}"
    assert_match(/✓/, out)
  end
end

# ---------------------------------------------------------------------------
# validate-trust-tier.sh
#
# Wave 5.1 of the 2026-05-27 audit roadmap (PRD-0006 / ADR-0017). Asserts
# each active module's declared trust-tier is coherent with the inferred
# tier (computed from sensitivePaths regex against representative sample
# paths), and that agent-pack maxTier ceilings respect the active
# manifest's highest non-agent tier.
#
# Per PRD-0006 FR-003 Implementation Notes: "the validator runs against the
# harness's own active modules as its integration test; no separate fixture
# project needed at v1." The dogfood run is the primary integration test;
# unit-level rule coverage (declared < inferred, missing rationale, agent
# maxTier breach, criticality cross-check) is exercised inline in the
# Ruby helper logic and validated by the dogfood run's outcome shape.
# Fixture-style isolation tests would require a platform-root-override
# argument on the script that's out of v1 scope.
# ---------------------------------------------------------------------------
class TestValidateTrustTier < Minitest::Test
  HARNESS_ROOT = File.expand_path("..", PLATFORM_DIR)

  def test_runs_clean_against_harness_repo
    # Dogfood: the harness's own manifest must validate green. This is the
    # primary integration test per PRD-0006 FR-003 Implementation Notes.
    manifest = File.join(HARNESS_ROOT, "harness.manifest.yaml")
    out, err, code = run_validator("validate-trust-tier.sh", manifest, HARNESS_ROOT)
    assert_equal 0, code,
                 "Harness's own tier declarations must be coherent. stderr: #{err}\nstdout: #{out}"
    assert_match(/✓/, out)
  end

  def test_missing_manifest_aborts_with_exit_2
    nonexistent = File.join(Dir.tmpdir, "validate-trust-tier-nope-#{Process.pid}.yaml")
    _out, err, code = run_validator("validate-trust-tier.sh", nonexistent)
    assert_equal 2, code, "missing manifest must exit 2 (usage error)"
    assert_match(/not found|No such file/i, err)
  end
end

# ---------------------------------------------------------------------------
# validate-sensitive-paths.sh
#
# Wave 5.3 of the 2026-05-27 audit roadmap (OPP-0034 / ADR-0017). Asserts
# every declared sensitivePaths regex pattern is overlapped by at least
# one companionRules.triggerPaths regex on some active module (cross-
# module coverage allowed). Closes safety-security-sweep §2 claim 12
# (Asserted-only → Enforced).
#
# Per OPP-0034 Risk 3 ("The kernel's existing declarations all pass"),
# the dogfood run is the primary integration test. Same platform-root-
# resolution constraint as validate-trust-tier.sh: fixture-style
# isolation tests would require a platform-root-override that's out of
# v1 scope.
# ---------------------------------------------------------------------------
class TestValidateSensitivePaths < Minitest::Test
  HARNESS_ROOT = File.expand_path("..", PLATFORM_DIR)

  def test_runs_clean_against_harness_repo
    # Dogfood: the harness's own manifest must validate green. OPP-0034
    # explicitly predicted this would pass without a fixing commit; this
    # test enforces that prediction (and will catch any future drift
    # where a new sensitivePaths declaration lands without companion-rule
    # coverage).
    manifest = File.join(HARNESS_ROOT, "harness.manifest.yaml")
    out, err, code = run_validator("validate-sensitive-paths.sh", manifest, HARNESS_ROOT)
    assert_equal 0, code,
                 "Harness's sensitive paths must all be companion-rule covered. stderr: #{err}\nstdout: #{out}"
    assert_match(/✓/, out)
    # Sanity: ensure the validator actually checked something, not just
    # vacuously passed because no sensitivePaths exist.
    assert_match(/sensitive-path patterns are companion-rule covered/, out)
  end

  def test_missing_manifest_aborts_with_exit_2
    nonexistent = File.join(Dir.tmpdir, "validate-sensitive-paths-nope-#{Process.pid}.yaml")
    _out, err, code = run_validator("validate-sensitive-paths.sh", nonexistent)
    assert_equal 2, code, "missing manifest must exit 2 (usage error)"
    assert_match(/not found|No such file/i, err)
  end
end
