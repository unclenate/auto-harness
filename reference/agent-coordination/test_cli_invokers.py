# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
"""TDD tests for build_argv. Pure construction; NO CLI is spawned. The argv is built for
subprocess with shell=False, so the task is always a single, un-interpreted element."""
import unittest
from cli_invokers import build_argv, SUPPORTED_CLIS

DANGER = ["danger-full-access", "--dangerously-bypass-approvals-and-sandbox", "--allow-all-paths"]


class TestBuildArgv(unittest.TestCase):
    def test_codex_read_only_at_low_tier(self):
        argv = build_argv("codex", "list files", effective_tier=1)
        self.assertEqual(argv[:2], ["codex", "exec"])
        self.assertIn("read-only", argv)
        self.assertEqual(argv[-1], "list files")

    def test_codex_workspace_write_at_mid_tier(self):
        argv = build_argv("codex", "edit a file", effective_tier=3)
        self.assertIn("workspace-write", argv)
        self.assertNotIn("read-only", argv)

    def test_codex_skips_git_repo_check(self):
        argv = build_argv("codex", "list files", effective_tier=1)
        self.assertIn("--skip-git-repo-check", argv)

    def test_grok_headless_single_turn(self):
        argv = build_argv("grok", "summarize", effective_tier=1)
        self.assertEqual(argv[0], "grok")
        self.assertIn("-p", argv)
        self.assertNotIn("--always-approve", argv)

    def test_grok_auto_approves_at_mid_tier(self):
        argv = build_argv("grok", "refactor", effective_tier=3)
        self.assertIn("--always-approve", argv)

    def test_copilot_non_interactive_prompt(self):
        argv = build_argv("copilot", "explain this", effective_tier=2)
        self.assertEqual(argv[0], "copilot")
        self.assertIn("-p", argv)
        self.assertIn("--allow-all-tools", argv)

    def test_codex_model_override_when_given(self):
        argv = build_argv("codex", "x", effective_tier=1, model="gpt-5-codex")
        self.assertIn("-c", argv)
        self.assertIn("model=gpt-5-codex", argv)

    def test_no_model_override_by_default(self):
        argv = build_argv("codex", "x", effective_tier=1)
        self.assertNotIn("-c", argv)

    def test_tier_4_or_higher_is_refused(self):
        for cli in SUPPORTED_CLIS:
            with self.assertRaises(ValueError):
                build_argv(cli, "deploy", effective_tier=4)

    def test_never_emits_sandbox_bypass_or_full_access(self):
        for cli in SUPPORTED_CLIS:
            for tier in (0, 1, 2, 3):
                argv = build_argv(cli, "x", effective_tier=tier)
                for danger in DANGER:
                    self.assertNotIn(danger, argv, "%s tier %d leaked %s" % (cli, tier, danger))

    def test_task_is_a_single_uninterpreted_argument(self):
        hostile = "a.txt; rm -rf / && echo `whoami`"
        for cli in SUPPORTED_CLIS:
            argv = build_argv(cli, hostile, effective_tier=1)
            self.assertEqual(sum(1 for a in argv if a == hostile), 1)

    def test_unknown_cli_rejected(self):
        with self.assertRaises(ValueError):
            build_argv("antigravity", "x", effective_tier=1)


if __name__ == "__main__":
    unittest.main()
