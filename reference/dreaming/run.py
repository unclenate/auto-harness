# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
"""The operator-invoked dreaming run: consolidate the corpus into proposals, assemble a run
manifest, and report a PROPOSED diff written to a BRANCH. Propose-only — it NEVER merges, never
writes above the corpus permissionScope, and no confidence threshold may auto-merge (the Letta
divergence rejected). Reference material, not enforced runtime; a scheduler owns cadence (v1 is
operator-invoked)."""
from policy import validate_policy
from consolidate import consolidate

def _rejected_from(prior_manifests):
    """Patterns a human already rejected in prior runs — suppressed so they are not re-proposed."""
    out = set()
    for m in prior_manifests or ():
        for r in m.get("rejected", []):
            out.add(r["pattern"])
    return out

def dreaming_run(corpus, policy, distill_fn, prior_manifests=None, run_id="run-1"):
    """Returns {"proposals": [...], "manifest": {...}, "wrote": "branch"}. Refuses any proposal
    whose target is not a declared targetSurface. NEVER merges."""
    validate_policy(policy)
    allowed = set(policy["targetSurfaces"])
    rejected = _rejected_from(prior_manifests)

    proposals = consolidate(corpus, policy, distill_fn, rejected=rejected)

    # target-surface containment: dreaming may only PROPOSE to declared staging surfaces.
    for p in proposals:
        if p["target"] not in allowed:
            raise ValueError(
                "proposal targets %r, not a declared targetSurface %s" % (p["target"], sorted(allowed)))

    manifest = {
        "run_id": run_id,
        "policy_version": policy.get("schemaVersion"),
        "corpus_scope": policy["corpus"].get("permissionScope"),
        "proposals": proposals,
        # preserve rejected proposals (dissent record) so the next run suppresses re-proposal
        "rejected": [{"pattern": pat, "rationale": "carried from a prior run"} for pat in sorted(rejected)],
    }
    # propose-only: the run writes a BRANCH of staged proposals; a human merges. It NEVER merges.
    return {"proposals": proposals, "manifest": manifest, "wrote": "branch"}
