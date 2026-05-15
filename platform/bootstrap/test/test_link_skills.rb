# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
require "minitest/autorun"
require "open3"
require "tmpdir"
require "fileutils"

# ---------------------------------------------------------------------------
# Integration tests for platform/bootstrap/link-skills.sh
#
# These tests build scratch "consumer repo" directories under tmpdir, simulate
# a submodule mount by symlinking .harness → the real auto-harness repo root,
# then invoke link-skills.sh and assert on stdout + exit code + symlink state.
#
# Requirements: Ruby 3.0+, bash
# Run: ruby platform/bootstrap/test/test_link_skills.rb
# ---------------------------------------------------------------------------

SCRIPT_PATH = File.expand_path("../link-skills.sh", __dir__)
HARNESS_ROOT = File.expand_path("../../..", __dir__)

def run_link_skills(project_root, *args)
  cmd = ["bash", SCRIPT_PATH, "--project-root", project_root, *args]
  stdout, stderr, status = Open3.capture3(*cmd)
  [stdout.strip, stderr.strip, status.exitstatus]
end

# Build a consumer-repo scaffold at `dir` with .harness → HARNESS_ROOT.
def setup_consumer_repo(dir)
  FileUtils.mkdir_p(dir)
  File.symlink(HARNESS_ROOT, File.join(dir, ".harness"))
end

class TestLinkSkillsFreshInstall < Minitest::Test
  def test_creates_relative_symlinks_in_both_targets
    Dir.mktmpdir do |dir|
      setup_consumer_repo(dir)
      out, _err, code = run_link_skills(dir, "harness-governance")

      assert_equal 0, code, "expected success. out: #{out}"
      assert_match(%r{\[CREATED\] \.agents/skills/harness-governance}, out)
      assert_match(%r{\[CREATED\] \.claude/skills/harness-governance}, out)
      assert_match(/Summary: 0 OK, 2 CREATED/, out)

      agents_link = File.readlink(File.join(dir, ".agents/skills/harness-governance"))
      claude_link = File.readlink(File.join(dir, ".claude/skills/harness-governance"))
      assert_equal "../../.harness/platform/skills/harness-governance", agents_link
      assert_equal "../../.harness/platform/skills/harness-governance", claude_link
    end
  end

  def test_custom_mount_path
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "vendor"))
      File.symlink(HARNESS_ROOT, File.join(dir, "vendor/auto-harness"))
      out, _err, code = run_link_skills(dir, "--mount-path", "vendor/auto-harness", "harness-governance")

      assert_equal 0, code, "expected success. out: #{out}"
      link = File.readlink(File.join(dir, ".claude/skills/harness-governance"))
      assert_equal "../../vendor/auto-harness/platform/skills/harness-governance", link
    end
  end

  def test_single_target_via_flag
    Dir.mktmpdir do |dir|
      setup_consumer_repo(dir)
      out, _err, code = run_link_skills(dir, "--targets", ".claude/skills", "harness-governance")

      assert_equal 0, code
      assert File.symlink?(File.join(dir, ".claude/skills/harness-governance"))
      refute File.exist?(File.join(dir, ".agents/skills/harness-governance")),
             ".agents/skills/ should not be populated when --targets excludes it"
    end
  end
end

class TestLinkSkillsIdempotency < Minitest::Test
  def test_rerun_reports_ok_for_existing_correct_symlinks
    Dir.mktmpdir do |dir|
      setup_consumer_repo(dir)
      run_link_skills(dir, "harness-governance")  # first run

      out, _err, code = run_link_skills(dir, "harness-governance")  # second run
      assert_equal 0, code
      assert_match(%r{\[OK\] \.agents/skills/harness-governance}, out)
      assert_match(%r{\[OK\] \.claude/skills/harness-governance}, out)
      assert_match(/Summary: 2 OK, 0 CREATED/, out)
    end
  end
end

class TestLinkSkillsConflicts < Minitest::Test
  def test_misdirected_symlink_conflicts_without_force
    Dir.mktmpdir do |dir|
      setup_consumer_repo(dir)
      FileUtils.mkdir_p(File.join(dir, ".agents/skills"))
      File.symlink("/tmp/some/other/path", File.join(dir, ".agents/skills/harness-governance"))

      out, _err, code = run_link_skills(dir, "--targets", ".agents/skills", "harness-governance")
      assert_equal 1, code
      assert_match(/\[CONFLICT\].*points to.*\/tmp\/some\/other\/path.*use --force/, out)
    end
  end

  def test_misdirected_symlink_replaced_with_force
    Dir.mktmpdir do |dir|
      setup_consumer_repo(dir)
      FileUtils.mkdir_p(File.join(dir, ".agents/skills"))
      File.symlink("/tmp/some/other/path", File.join(dir, ".agents/skills/harness-governance"))

      out, _err, code = run_link_skills(dir, "--force", "--targets", ".agents/skills", "harness-governance")
      assert_equal 0, code
      assert_match(/\[REPLACED\]/, out)
      assert_equal "../../.harness/platform/skills/harness-governance",
                   File.readlink(File.join(dir, ".agents/skills/harness-governance"))
    end
  end

  def test_real_directory_never_replaced_even_with_force
    Dir.mktmpdir do |dir|
      setup_consumer_repo(dir)
      real_dir = File.join(dir, ".agents/skills/harness-governance")
      FileUtils.mkdir_p(real_dir)
      File.write(File.join(real_dir, "my-file.md"), "user content")

      out, _err, code = run_link_skills(dir, "--force", "--targets", ".agents/skills", "harness-governance")
      assert_equal 1, code, "real directory must conflict even with --force"
      assert_match(/\[CONFLICT\].*is a directory/, out)
      assert File.exist?(File.join(real_dir, "my-file.md")),
             "user file inside the directory must be preserved"
    end
  end
end

class TestLinkSkillsErrors < Minitest::Test
  def test_unknown_skill_errors_with_exit_2
    Dir.mktmpdir do |dir|
      setup_consumer_repo(dir)
      _out, err, code = run_link_skills(dir, "no-such-skill")
      assert_equal 2, code
      assert_match(/unknown skill 'no-such-skill'/, err)
    end
  end

  def test_missing_submodule_errors_with_exit_2
    Dir.mktmpdir do |dir|
      # no .harness created
      _out, err, code = run_link_skills(dir, "harness-governance")
      assert_equal 2, code
      assert_match(/harness skills dir not found/, err)
      assert_match(/submodule.*initialized/, err)
    end
  end

  def test_absolute_mount_path_rejected
    Dir.mktmpdir do |dir|
      setup_consumer_repo(dir)
      _out, err, code = run_link_skills(dir, "--mount-path", "/absolute/path", "harness-governance")
      assert_equal 2, code
      assert_match(/--mount-path must be relative/, err)
    end
  end

  def test_no_skills_provided_errors_with_exit_2
    Dir.mktmpdir do |dir|
      setup_consumer_repo(dir)
      _out, err, code = run_link_skills(dir)
      assert_equal 2, code
      assert_match(/no skill names provided/, err)
    end
  end

  def test_bad_flag_errors_with_exit_2
    Dir.mktmpdir do |dir|
      setup_consumer_repo(dir)
      _out, err, code = run_link_skills(dir, "--nonsense", "harness-governance")
      assert_equal 2, code
      assert_match(/unknown flag: --nonsense/, err)
    end
  end
end

class TestLinkSkillsHelp < Minitest::Test
  def test_help_flag_exits_zero_and_prints_usage
    out, _err, code = Open3.capture3("bash", SCRIPT_PATH, "--help").then { |o, e, s| [o, e, s.exitstatus] }
    assert_equal 0, code
    assert_match(/link-skills\.sh/, out)
    assert_match(/Usage:/, out)
    assert_match(/--mount-path/, out)
  end
end
