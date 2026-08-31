# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
"""Manual TDD tests for the dreaming reference orchestrator. distill_fn is a FAKE — zero external
calls. Run: python3 reference/dreaming/test_dreaming.py"""
import copy, unittest
from policy import validate_policy, EvidenceBar
from consolidate import consolidate
from run import dreaming_run

TARGET = "docs/knowledge/promotion-candidates.md"

def _policy(**over):
    p = {
        "schemaVersion": 1,
        "budget": {"maxTokens": 200000, "maxSubAgents": 8,
                   "maxProposedChangesPerRun": 15, "maxCorpusSessions": 500},
        "evidenceBar": {"minPrevalenceSessions": 3, "minCitationsPerChange": 2,
                        "proseLossyWeight": 0.5},
        "targetSurfaces": [TARGET],
        "corpus": {"permissionScope": "maintainer-local"},
        "transcriptProviders": {"claude-code": {"permissionScope": "maintainer-local", "mode": "full"}},
    }
    p.update(over); return p

def _sess(sid, mode="full", agent="claude-code"):
    return {"sessionId": sid, "mode": mode, "agent": agent}

def _corpus(n, mode="full"):
    return [_sess("s%d" % i, mode=mode) for i in range(n)]

# a fake sub-agent: reports pattern "p" seen in exactly the sessions of its partition
def _fake_distill(partition):
    return [{"pattern": "p", "verb": "promote", "target": TARGET, "change": "promote observation X",
             "sessions": list(partition), "citations": ["c1", "c2"], "mode_basis": "full"}]

class TestPolicy(unittest.TestCase):
    def test_missing_budget_raises(self):
        p = _policy(); del p["budget"]
        with self.assertRaises(ValueError):
            validate_policy(p)
    def test_provider_scope_exceeding_corpus_raises(self):
        p = _policy(transcriptProviders={"claude-code": {"permissionScope": "kernel"}})
        with self.assertRaises(ValueError):
            validate_policy(p)
    def test_valid_policy_ok(self):
        validate_policy(_policy())  # no raise

class TestEvidenceBar(unittest.TestCase):
    def _cand(self, sessions, citations=("c1", "c2")):
        return {"pattern": "p", "sessions": sessions, "citations": list(citations)}
    def test_below_prevalence_fails(self):
        self.assertFalse(EvidenceBar(_policy()).passes(self._cand([_sess("s1"), _sess("s2")])))
    def test_meets_prevalence(self):
        self.assertTrue(EvidenceBar(_policy()).passes(
            self._cand([_sess("s1"), _sess("s2"), _sess("s3")])))
    def test_same_session_not_double_counted(self):
        self.assertFalse(EvidenceBar(_policy()).passes(
            self._cand([_sess("s1"), _sess("s1"), _sess("s1")])))
    def test_prose_lossy_downweighted(self):
        pl = [_sess("s%d" % i, mode="prose-lossy") for i in range(4)]   # 4 * 0.5 = 2.0 < 3
        self.assertFalse(EvidenceBar(_policy()).passes(self._cand(pl)))
        pl6 = [_sess("s%d" % i, mode="prose-lossy") for i in range(6)]  # 6 * 0.5 = 3.0 >= 3
        self.assertTrue(EvidenceBar(_policy()).passes(self._cand(pl6)))
    def test_below_citations_fails(self):
        self.assertFalse(EvidenceBar(_policy()).passes(
            self._cand([_sess("s1"), _sess("s2"), _sess("s3")], citations=("only-one",))))

class TestConsolidate(unittest.TestCase):
    def test_merges_across_partitions_to_prevalence(self):
        props = consolidate(_corpus(3), _policy(), _fake_distill)
        self.assertEqual(len(props), 1)
        self.assertEqual(props[0]["prevalence"]["independent"], 3)
        self.assertEqual(props[0]["target"], TARGET)
    def test_single_session_pattern_filtered(self):
        self.assertEqual(consolidate(_corpus(1), _policy(), _fake_distill), [])
    def test_suppresses_rejected_pattern(self):
        self.assertEqual(consolidate(_corpus(3), _policy(), _fake_distill, rejected={"p"}), [])

class TestDreamingRun(unittest.TestCase):
    def test_proposes_only_never_merges(self):
        out = dreaming_run(_corpus(3), _policy(), _fake_distill)
        self.assertEqual(out["wrote"], "branch")
        self.assertNotIn("merged", out.values())
        self.assertEqual(len(out["proposals"]), 1)
        self.assertEqual(out["manifest"]["run_id"], "run-1")
    def test_refuses_off_target_surface(self):
        def off_target(partition):
            return [{"pattern": "p", "verb": "promote", "target": "docs/operating-principles.md",
                     "change": "x", "sessions": list(partition), "citations": ["c1", "c2"],
                     "mode_basis": "full"}]
        with self.assertRaises(ValueError):
            dreaming_run(_corpus(3), _policy(), off_target)
    def test_manifest_preserves_rejected(self):
        prior = [{"rejected": [{"pattern": "old-pat", "rationale": "declined"}]}]
        out = dreaming_run(_corpus(3), _policy(), _fake_distill, prior_manifests=prior)
        pats = [r["pattern"] for r in out["manifest"]["rejected"]]
        self.assertIn("old-pat", pats)
    def test_corpus_over_budget_raises(self):
        p = _policy()
        p["budget"]["maxCorpusSessions"] = 2   # corpus of 3 exceeds it
        with self.assertRaises(ValueError):
            dreaming_run(_corpus(3), p, _fake_distill)
    def test_too_many_proposals_over_budget_raises(self):
        # a distill_fn reporting TWO distinct patterns, each seen in the partition's sessions
        def two_patterns(partition):
            return [{"pattern": pat, "verb": "promote", "target": TARGET, "change": "c",
                     "sessions": list(partition), "citations": ["c1", "c2"], "mode_basis": "full"}
                    for pat in ("p1", "p2")]
        p = _policy()
        p["budget"]["maxProposedChangesPerRun"] = 1   # 2 proposals exceed it
        with self.assertRaises(ValueError):
            dreaming_run(_corpus(3), p, two_patterns)

if __name__ == "__main__":
    unittest.main()
