# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
require "minitest/autorun"
require "open3"
require "tmpdir"
require "fileutils"

# ---------------------------------------------------------------------------
# Integration tests for platform/bootstrap/install.sh
#
# Builds a scratch "consumer repo" under tmpdir, simulates a submodule mount
# by symlinking .harness → HARNESS_ROOT, then invokes install.sh and asserts
# on stdout + exit code + resulting file state.
#
# Requirements: Ruby 3.0+, bash
# Run: ruby platform/bootstrap/test/test_install.rb
# ---------------------------------------------------------------------------

INSTALL_PATH = File.expand_path("../install.sh", __dir__)
HARNESS_ROOT = File.expand_path("../../..", __dir__)
COEXIST_FIXTURES_DIR = File.expand_path("fixtures/consumer-repos", __dir__)

def run_install(project_root, *args)
  cmd = ["bash", INSTALL_PATH, "--project-root", project_root, *args]
  stdout, stderr, status = Open3.capture3(*cmd)
  [stdout, stderr, status.exitstatus]
end

def setup_mount(dir, target = HARNESS_ROOT)
  FileUtils.mkdir_p(dir)
  File.symlink(target, File.join(dir, ".harness"))
end

def mtime(path)
  File.stat(path).mtime
end

class TestInstallGreenfield < Minitest::Test
  def test_empty_repo_gets_full_scaffold
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      out, _err, code = run_install(dir)
      assert_equal 0, code, "expected clean exit. out: #{out}"

      assert File.exist?(File.join(dir, "harness.manifest.yaml"))
      assert File.exist?(File.join(dir, "HARNESS.md"))
      assert File.exist?(File.join(dir, "CLAUDE.md"))
      assert File.exist?(File.join(dir, "AGENTS.md"))

      assert File.symlink?(File.join(dir, ".claude/skills/harness-governance"))
      assert File.symlink?(File.join(dir, ".agents/skills/harness-governance"))

      assert_match(/CREATED:/, out)
      assert_match(/Completed successfully\./, out)
      refute_match(/CONFLICTS:\n  - /, out)
    end
  end

  def test_agents_md_contains_marker_block
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      run_install(dir)
      content = File.read(File.join(dir, "AGENTS.md"))
      assert_includes content, "<!-- harness-managed-section -->"
      assert_includes content, "<!-- /harness-managed-section -->"
      assert_includes content, "Harness governance"
    end
  end

  def test_harness_manifest_is_from_composition
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      run_install(dir)
      content = File.read(File.join(dir, "harness.manifest.yaml"))
      assert_match(/^schemaVersion: 1$/, content)
      assert_match(/^  id: brownfield-project/, content)
      # management/privacy-by-design is default-active in the brownfield-lite
      # composition so every bootstrapped project gets it automatically.
      assert_match(/- privacy-by-design/, content,
                   "default composition must include management/privacy-by-design")
    end
  end
end

class TestInstallIdempotency < Minitest::Test
  def test_rerun_skips_harness_style_files
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      run_install(dir)  # first run
      out, _err, code = run_install(dir)  # second run
      assert_equal 0, code
      assert_match(/SKIPPED \(existing\):/, out)
      assert_match(/harness\.manifest\.yaml.*harness-style/, out)
      assert_match(/HARNESS\.md.*harness-style/, out)
    end
  end

  def test_force_overwrites_harness_style_files
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      run_install(dir)
      manifest_path = File.join(dir, "harness.manifest.yaml")
      File.write(manifest_path, "schemaVersion: 1\n# I modified this\n")
      out, _err, code = run_install(dir, "--force")
      assert_equal 0, code
      assert_match(/replaced/, out)
      refute_match(/I modified this/, File.read(manifest_path))
    end
  end
end

class TestInstallBrownfield < Minitest::Test
  def test_foreign_claude_md_is_preserved_and_exits_zero
    # CLAUDE.md being consumer-authored is an INFORMATIONAL conflict — the
    # harness intentionally leaves the file alone and emits a suggestion.
    # Exit 0 because there is nothing for the user to act on; the install
    # produced a coherent, working harness setup.
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      File.write(File.join(dir, "CLAUDE.md"),
                 "# my custom claude.md\n\nno harness references here.\n")
      out, _err, code = run_install(dir)
      assert_equal 0, code, "informational conflict (consumer CLAUDE.md) must exit 0. out: #{out}"
      assert_match(/CONFLICTS:/, out)
      assert_match(/CLAUDE\.md exists and appears consumer-authored/, out)
      # New informational-completion message
      assert_match(/item\(s\) in CONFLICTS are informational.*no action required/i, out)
      refute_match(/Resolve them and re-run/, out)
      assert_equal "# my custom claude.md\n\nno harness references here.\n",
                   File.read(File.join(dir, "CLAUDE.md"))
    end
  end

  def test_foreign_manifest_reported_as_blocking_conflict
    # Unparseable manifest is BLOCKING — the harness can't function without a
    # valid manifest, so the user must resolve before re-running.
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      # manifest without the schemaVersion: 1 signature
      File.write(File.join(dir, "harness.manifest.yaml"), "not: a harness manifest\n")
      out, _err, code = run_install(dir)
      assert_equal 1, code, "unparseable manifest must be blocking. out: #{out}"
      assert_match(/CONFLICTS:/, out)
      assert_match(/harness\.manifest\.yaml.*lacks harness signature/, out)
      assert_match(/blocking conflict.*Resolve them and re-run/, out)
      assert_equal "not: a harness manifest\n",
                   File.read(File.join(dir, "harness.manifest.yaml"))
    end
  end
end

class TestInstallExitCodes < Minitest::Test
  # Acceptance for Item 5b: three-state exit codes.

  def test_clean_install_exits_zero
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      out, _err, code = run_install(dir)
      assert_equal 0, code, "clean install must exit 0. out: #{out}"
      assert_match(/Completed successfully\./, out)
    end
  end

  def test_informational_only_conflict_exits_zero_with_new_message
    # Consumer CLAUDE.md is the canonical informational case.
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      File.write(File.join(dir, "CLAUDE.md"), "# consumer file\n")
      out, _err, code = run_install(dir)
      assert_equal 0, code, "informational-only conflicts must exit 0. out: #{out}"
      assert_match(/item\(s\) in CONFLICTS are informational.*no action required/i, out)
      # The legacy "Resolve them" wording must NOT appear in the informational path.
      refute_match(/Resolve them and re-run/, out)
    end
  end

  def test_blocking_conflict_exits_one_with_legacy_message
    # Unparseable manifest is blocking.
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      File.write(File.join(dir, "harness.manifest.yaml"), "garbage\n")
      out, _err, code = run_install(dir)
      assert_equal 1, code, "blocking conflict must exit 1. out: #{out}"
      assert_match(/blocking conflict\(s\)\. Resolve them and re-run\./, out)
    end
  end

  def test_blocking_plus_informational_exits_one
    # If at least one conflict is blocking, exit code is 1 regardless of
    # informational entries piled up beside it.
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      File.write(File.join(dir, "harness.manifest.yaml"), "garbage\n")
      File.write(File.join(dir, "CLAUDE.md"), "# consumer file\n")
      _out, _err, code = run_install(dir)
      assert_equal 1, code, "any blocking conflict must trump informational ones"
    end
  end
end

class TestInstallCoexistence < Minitest::Test
  def copy_fixture_to(src_name, dst_dir)
    FileUtils.cp_r("#{COEXIST_FIXTURES_DIR}/#{src_name}/.", dst_dir)
  end

  def snapshot_mtimes(paths)
    paths.each_with_object({}) { |p, h| h[p] = mtime(p) if File.exist?(p) }
  end

  def test_cursor_detected_and_file_untouched
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      copy_fixture_to("coexist-cursor", dir)
      before = mtime(File.join(dir, ".cursorrules"))

      out, _err, code = run_install(dir)
      assert_equal 0, code, "out: #{out}"
      assert_match(/PLATFORMS OBSERVED.*\n.*cursor.*\.cursorrules/m, out)
      assert_equal before, mtime(File.join(dir, ".cursorrules"))
    end
  end

  def test_multi_platform_all_untouched_and_reported
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      copy_fixture_to("coexist-multi", dir)
      platform_files = [
        File.join(dir, ".cursorrules"),
        File.join(dir, ".github/copilot-instructions.md"),
      ]
      before = snapshot_mtimes(platform_files)

      out, _err, code = run_install(dir)
      assert_equal 0, code, "out: #{out}"
      assert_match(/cursor.*\.cursorrules/, out)
      assert_match(/github-copilot.*\.github\/copilot-instructions\.md/, out)

      after = snapshot_mtimes(platform_files)
      before.each { |p, t| assert_equal t, after[p], "#{p} mtime changed" }
    end
  end

  def test_agents_md_custom_content_preserved_on_merge
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      copy_fixture_to("coexist-multi", dir)
      original = File.read(File.join(dir, "AGENTS.md"))

      out, _err, code = run_install(dir)
      assert_equal 0, code, "out: #{out}"

      merged = File.read(File.join(dir, "AGENTS.md"))
      # Custom content should appear verbatim in the merged file
      assert_includes merged, "data-pipeline monorepo"
      assert_includes merged, "Pipeline tests pass"
      assert_includes merged, "Downstream schema compatibility verified"
      # And the managed block should be present
      assert_includes merged, "<!-- harness-managed-section -->"
      assert_includes merged, "<!-- /harness-managed-section -->"
      # And the merged file is strictly longer than the original (custom + managed)
      assert merged.length > original.length, "merged file should contain both custom and managed content"
    end
  end

  def test_openclaw_files_detected_and_untouched
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      copy_fixture_to("coexist-openclaw", dir)
      files = %w[TOOLS.md SOUL.md IDENTITY.md BOOT.md HEARTBEAT.md].map { |f| File.join(dir, f) }
      before = snapshot_mtimes(files)

      out, _err, code = run_install(dir)
      assert_equal 0, code, "out: #{out}"
      assert_match(/openclaw.*TOOLS\.md/, out)

      after = snapshot_mtimes(files)
      before.each { |p, t| assert_equal t, after[p], "#{p} was modified" }
    end
  end
end

class TestInstallDryRun < Minitest::Test
  def test_dry_run_writes_nothing
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      out, _err, code = run_install(dir, "--dry-run")
      assert_equal 0, code
      assert_match(/DRY-RUN/, out)
      refute File.exist?(File.join(dir, "harness.manifest.yaml")),
             "dry-run should not create files"
      refute File.exist?(File.join(dir, ".claude/skills/harness-governance")),
             "dry-run should not create symlinks"
    end
  end
end

class TestInstallCliValidation < Minitest::Test
  def test_unknown_flag_exits_2
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      _out, err, code = run_install(dir, "--nonsense")
      assert_equal 2, code
      assert_match(/unknown argument/, err)
    end
  end

  def test_absolute_mount_path_rejected
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      _out, err, code = run_install(dir, "--mount-path", "/absolute")
      assert_equal 2, code
      assert_match(/--mount-path must be relative/, err)
    end
  end

  def test_missing_composition_errors
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      _out, err, code = run_install(dir, "--composition", "no-such-composition")
      assert_equal 2, code
      assert_match(/composition not found/, err)
    end
  end
end

class TestInstallForceIdentityPreservation < Minitest::Test
  # Acceptance for Item 5a: --force preserves project.id / project.name /
  # project.maturity / project.criticality from the existing manifest.

  def test_force_preserves_project_identity_across_composition_swap
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      manifest_path = File.join(dir, "harness.manifest.yaml")

      # Seed an existing harness-style manifest with a real consumer identity.
      File.write(manifest_path, <<~YAML)
        schemaVersion: 1
        project:
          id: my-test-project
          name: My Test Project
          maturity: mvp
          criticality: high
        modules:
          core:
            - kernel/base
          agents:
            - base
        overrides: {}
      YAML

      # --force with a composition whose example identity is different.
      out, _err, code = run_install(
        dir, "--force", "--composition", "interview-driven-discovery"
      )
      assert_equal 0, code, "expected clean exit. out: #{out}"

      regen = File.read(manifest_path)

      # Identity preserved
      assert_match(/^  id: my-test-project$/, regen, "id must be preserved")
      assert_match(/^  name: My Test Project$/, regen, "name must be preserved")
      assert_match(/^  maturity: mvp$/, regen, "maturity must be preserved")
      assert_match(/^  criticality: high$/, regen, "criticality must be preserved")

      # Composition's example identity must NOT have leaked in
      refute_match(/example-interview-driven/, regen,
                   "composition's example id must NOT clobber consumer identity")
      refute_match(/Example Interview-Driven Project/, regen,
                   "composition's example name must NOT clobber consumer identity")

      # Composition governance (modules) IS present
      assert_match(/^  management:/, regen,
                   "composition's modules block (with management) should be applied")
      assert_match(/^    - interview-driven$/, regen,
                   "composition's interview-driven module should be applied")
    end
  end

  def test_force_against_empty_repo_uses_composition_defaults
    # Acceptance: --force against a repo with no existing manifest behaves
    # identically to today (composition defaults written verbatim).
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      _out, _err, code = run_install(
        dir, "--force", "--composition", "interview-driven-discovery"
      )
      assert_equal 0, code

      content = File.read(File.join(dir, "harness.manifest.yaml"))
      # Composition identity unchanged — nothing to merge from.
      assert_match(/^  id: example-interview-driven$/, content)
      assert_match(/^  name: Example Interview-Driven Project$/, content)
    end
  end

  def test_force_with_corrupt_existing_manifest_falls_through
    # Acceptance: if the existing manifest has no `project:` block (corrupt /
    # stub), composition defaults are used — no half-merged Frankenstein.
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      manifest_path = File.join(dir, "harness.manifest.yaml")
      # Has the schemaVersion signature (so --force engages) but no project block.
      File.write(manifest_path, "schemaVersion: 1\nmodules:\n  core: [kernel/base]\n")

      _out, _err, code = run_install(
        dir, "--force", "--composition", "interview-driven-discovery"
      )
      assert_equal 0, code

      regen = File.read(manifest_path)
      # Fell through to composition defaults
      assert_match(/^  id: example-interview-driven$/, regen)
      assert_match(/^  name: Example Interview-Driven Project$/, regen)
    end
  end
end

class TestInstallCiSnippet < Minitest::Test
  def test_ci_snippet_references_submodule_root
    Dir.mktmpdir do |dir|
      setup_mount(dir)
      out, _err, code = run_install(dir)
      assert_equal 0, code
      assert_match(/HARNESS_SUBMODULE_ROOT/, out)
      assert_match(/ruby\/setup-ruby@v1/, out)
      assert_match(/submodules: recursive/, out)
    end
  end
end
