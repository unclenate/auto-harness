# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
"""TDD tests for build_argv. Pure construction; NO CLI is spawned. The argv is built for
subprocess with shell=False, so the task is always a single, un-interpreted element AND — the
security invariant these tests defend — can never separate into its own FLAG token (a leading-dash
task must not re-open a sandbox beneath the tier gate)."""
import unittest
from cli_invokers import build_argv, SUPPORTED_CLIS

# sandbox-bypass / full-access tokens that must NEVER appear in a built argv. Note: copilot's
# --allow-all-tools is NOT here — it is a legitimate, required flag at tier >= 2 (H1 is closed by
# refusing read-only copilot, not by banning the flag).
DANGER = ["danger-full-access", "--dangerously-bypass-approvals-and-sandbox", "--allow-all-paths"]


class TestBuildArgv(unittest.TestCase):
    def test_codex_read_only_at_low_tier(self):
        argv = build_argv("codex", "list files", effective_tier=1)
        self.assertEqual(argv[:2], ["codex", "exec"])
        self.assertIn("read-only", argv)
        self.assertEqual(argv[-2:], ["--", "list files"])

    def test_codex_workspace_write_at_mid_tier(self):
        argv = build_argv("codex", "edit a file", effective_tier=3)
        self.assertIn("workspace-write", argv)
        self.assertNotIn("read-only", argv)

    def test_codex_skips_git_repo_check(self):
        argv = build_argv("codex", "list files", effective_tier=1)
        self.assertIn("--skip-git-repo-check", argv)

    def test_codex_model_override_when_given(self):
        argv = build_argv("codex", "x", effective_tier=1, model="gpt-5-codex")
        self.assertIn("-c", argv)
        self.assertIn("model=gpt-5-codex", argv)

    def test_no_model_override_by_default(self):
        argv = build_argv("codex", "x", effective_tier=1)
        self.assertNotIn("-c", argv)

    def test_grok_headless_single_turn(self):
        argv = build_argv("grok", "summarize", effective_tier=1)
        self.assertEqual(argv[0], "grok")
        self.assertIn("--single=summarize", argv)
        self.assertNotIn("--always-approve", argv)

    def test_grok_auto_approves_at_mid_tier(self):
        argv = build_argv("grok", "refactor", effective_tier=3)
        self.assertIn("--always-approve", argv)

    def test_copilot_non_interactive_prompt(self):
        argv = build_argv("copilot", "explain this", effective_tier=2)
        self.assertEqual(argv[0], "copilot")
        self.assertIn("--prompt=explain this", argv)
        self.assertIn("--allow-all-tools", argv)

    # --- C1: a leading-dash task must never be parsed as a flag ---

    def test_codex_leading_dash_task_isolated_after_separator(self):
        evil = "--dangerously-bypass-approvals-and-sandbox"
        argv = build_argv("codex", evil, effective_tier=1)
        self.assertEqual(argv[-2:], ["--", evil])   # after "--", codex reads it as the prompt

    def test_codex_leading_dash_sandbox_override_neutralized(self):
        # the task tries to flip the sandbox; because it sits after "--", our -s read-only stands
        argv = build_argv("codex", "--sandbox=danger-full-access", effective_tier=1)
        self.assertEqual(argv[-2], "--")
        self.assertIn("read-only", argv)

    def test_grok_leading_dash_task_bound_to_option(self):
        argv = build_argv("grok", "--sandbox=danger", effective_tier=1)
        self.assertIn("--single=--sandbox=danger", argv)
        self.assertNotIn("--sandbox=danger", argv)   # never a bare, separately-parsed token

    def test_copilot_leading_dash_task_bound_to_option(self):
        argv = build_argv("copilot", "--allow-all-paths", effective_tier=2)
        self.assertIn("--prompt=--allow-all-paths", argv)
        self.assertNotIn("--allow-all-paths", argv)

    # --- H1: copilot cannot honor a read-only cap ---

    def test_copilot_refuses_read_only_tier(self):
        for tier in (0, 1):
            with self.assertRaises(ValueError):
                build_argv("copilot", "x", effective_tier=tier)

    def test_copilot_allowed_at_tier_2_plus(self):
        self.assertEqual(build_argv("copilot", "x", effective_tier=2)[0], "copilot")

    def test_codex_and_grok_still_allow_read_only(self):
        self.assertEqual(build_argv("codex", "x", effective_tier=1)[0], "codex")
        self.assertEqual(build_argv("grok", "x", effective_tier=1)[0], "grok")

    # --- tier ceiling + danger invariants ---

    def test_tier_4_or_higher_is_refused(self):
        for cli in SUPPORTED_CLIS:
            with self.assertRaises(ValueError):
                build_argv(cli, "deploy", effective_tier=4)

    def test_never_emits_sandbox_bypass_or_full_access(self):
        for cli in SUPPORTED_CLIS:
            for tier in (0, 1, 2, 3):
                try:
                    argv = build_argv(cli, "x", effective_tier=tier)
                except ValueError:
                    continue   # a refusal (copilot read-only) is a safe outcome — no argv emitted
                for danger in DANGER:
                    self.assertNotIn(danger, argv, "%s tier %d leaked %s" % (cli, tier, danger))

    def test_task_is_single_element_and_unparseable_as_flag(self):
        hostile = "a.txt; rm -rf / && echo `whoami`"
        self.assertEqual(build_argv("codex", hostile, effective_tier=1)[-2:], ["--", hostile])
        self.assertIn("--single=%s" % hostile, build_argv("grok", hostile, effective_tier=1))
        self.assertIn("--prompt=%s" % hostile, build_argv("copilot", hostile, effective_tier=2))

    def test_unknown_cli_rejected(self):
        with self.assertRaises(ValueError):
            build_argv("antigravity", "x", effective_tier=1)


if __name__ == "__main__":
    unittest.main()
