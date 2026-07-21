# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — reference implementation tests.
"""Unit tests for the ACP tier-policy engine (policy.py).

Run: python3 -m unittest discover -s platform/agents/acp/reference-proxy
"""

import unittest

import policy as pol

SENSITIVE = [r"^\.acp/", r"(^|/)acp-policy\.ya?ml$"]


class TestClassify(unittest.TestCase):
    def test_read_kinds_are_tier_0(self):
        for kind in ("read", "search", "think"):
            self.assertEqual(pol.classify(kind), 0)

    def test_edit_is_tier_2(self):
        self.assertEqual(pol.classify("edit", path="src/app.py"), 2)

    def test_edit_governance_entrypoint_is_tier_5(self):
        for path in ("HARNESS.md", "AGENTS.md", ".github/workflows/ci.yml", "secrets/key"):
            self.assertEqual(pol.classify("edit", path=path), 5, path)

    def test_execute_command_classification(self):
        self.assertEqual(pol.classify("execute", command="pytest -q"), 1)
        self.assertEqual(pol.classify("execute", command="npm run build"), 1)
        self.assertEqual(pol.classify("execute", command="pip install requests"), 4)
        self.assertEqual(pol.classify("execute", command="terraform apply"), 5)
        self.assertEqual(pol.classify("execute", command="kubectl rollout"), 5)
        self.assertEqual(pol.classify("execute", command="echo hi"), 3)  # conservative default

    def test_sensitive_path_bumps_tier(self):
        # edit (tier 2) to a sensitive path → tier 3
        self.assertEqual(pol.classify("edit", path=".acp/policy.yaml", sensitive_paths=SENSITIVE), 3)

    def test_fetch_publish_escalates(self):
        self.assertEqual(pol.classify("fetch", command="GET https://x"), 2)
        self.assertEqual(pol.classify("fetch", command="POST https://x"), 3)

    def test_unknown_kind_falls_back_to_other(self):
        self.assertEqual(pol.classify("wibble"), 3)


class TestOptionsFor(unittest.TestCase):
    def test_tier_0_offers_allow_always(self):
        spec = pol.options_for(0)
        self.assertIn("allow_always", spec["options"])
        self.assertEqual(spec["default"], "allow_always")

    def test_tier_3_has_no_allow_always(self):
        spec = pol.options_for(3)
        self.assertNotIn("allow_always", spec["options"])
        self.assertEqual(spec["default"], "reject_once")

    def test_tier_5_is_reject_only(self):
        spec = pol.options_for(5)
        self.assertEqual(spec["options"], ["reject_always"])
        self.assertTrue(spec.get("block_at_seam"))

    def test_delete_strips_allow_always_even_at_tier_2(self):
        spec = pol.options_for(2, kind="delete")
        self.assertNotIn("allow_always", spec["options"])

    def test_sensitive_strips_allow_always(self):
        spec = pol.options_for(2, sensitive=True)
        self.assertNotIn("allow_always", spec["options"])

    def test_stripping_allow_always_repairs_default(self):
        # If the tier's default was allow_always but it's banned, the default moves.
        spec = pol.options_for(0, kind="delete")   # tier 0 default is allow_always
        self.assertNotEqual(spec["default"], "allow_always")
        self.assertIn(spec["default"], spec["options"])


class TestRewritePermissionRequest(unittest.TestCase):
    def _req(self, kind, path=None, command=None):
        tool = {"kind": kind}
        if path:
            tool["locations"] = [{"path": path}]
        if command:
            tool["rawInput"] = {"command": command}
        return {"toolCall": tool, "options": [{"optionId": "allow_once"}]}

    def test_tier_5_auto_rejects_at_seam(self):
        params, decision = pol.rewrite_permission_request(self._req("edit", path="HARNESS.md"))
        self.assertEqual(decision, "reject_always")
        self.assertEqual([o["optionId"] for o in params["options"]], ["reject_always"])
        self.assertEqual(params["_governance"]["tier"], 5)

    def test_tier_2_presents_rewritten_options(self):
        params, decision = pol.rewrite_permission_request(self._req("edit", path="src/x.py"))
        self.assertIsNone(decision)   # user is asked
        ids = [o["optionId"] for o in params["options"]]
        self.assertIn("allow_once", ids)
        self.assertEqual(params["_governance"]["tier"], 2)

    def test_sensitive_path_withholds_allow_always_and_hints(self):
        params, decision = pol.rewrite_permission_request(
            self._req("edit", path=".acp/policy.yaml"), sensitive_paths=SENSITIVE)
        ids = [o["optionId"] for o in params["options"]]
        self.assertNotIn("allow_always", ids)
        self.assertTrue(params["_governance"]["sensitive"])
        self.assertEqual(params["_governance"]["tier"], 3)

    def test_options_are_well_formed_acp_shape(self):
        params, _ = pol.rewrite_permission_request(self._req("read"))
        for opt in params["options"]:
            self.assertIn("optionId", opt)
            self.assertIn("name", opt)
            self.assertIn("kind", opt)


if __name__ == "__main__":
    unittest.main()
