# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
"""Consolidation: partition the transcript corpus into disjoint slices, fan an INJECTED
distill_fn (a sub-agent) over each independently, consolidate only after all return, apply the
evidence bar, and emit PROPOSE records. Reference material, not enforced runtime.

distill_fn is injected (a sub-agent in production, a fake in tests — zero external calls), the
same seam pattern as the native_adapter's send_fn. Sub-agents assess BLIND over disjoint
partitions; the orchestrator consolidates only after all have returned, so a pattern's prevalence
reflects genuinely independent observations, never one finding echoed N times."""
from policy import EvidenceBar

def _partition(sessions, max_slices):
    """Disjoint round-robin partition of the corpus into at most max_slices non-overlapping slices."""
    n = max(1, min(max_slices, len(sessions))) if sessions else 1
    slices = [[] for _ in range(n)]
    for i, s in enumerate(sessions):
        slices[i % n].append(s)
    return [sl for sl in slices if sl]

def consolidate(corpus, policy, distill_fn, rejected=None):
    """corpus: list of session dicts. distill_fn(partition) -> [candidate]; each candidate is
    {"pattern","verb","target","change","sessions":[{sessionId,mode}],"citations":[...],"mode_basis"}.
    Returns a list of PROPOSE records that clear the evidence bar and are not already rejected."""
    rejected = set(rejected or ())
    max_slices = policy["budget"]["maxSubAgents"]
    partitions = _partition(corpus, max_slices)

    # fan out over disjoint partitions; collect ALL returns before consolidating (blind independence)
    returned = [distill_fn(part) for part in partitions]

    # consolidate: merge candidates sharing a pattern key across partitions (union sessions/citations)
    merged = {}
    for candidates in returned:
        for c in candidates:
            key = c["pattern"]
            if key not in merged:
                merged[key] = {
                    "pattern": key, "verb": c["verb"], "target": c["target"],
                    "change": c["change"], "sessions": [], "citations": [], "mode_basis": c.get("mode_basis"),
                }
            merged[key]["sessions"].extend(c.get("sessions", []))
            merged[key]["citations"].extend(c.get("citations", []))

    bar = EvidenceBar(policy)
    proposals = []
    for key, cand in merged.items():
        if key in rejected:
            continue                      # suppress a pattern a human already declined
        if not bar.passes(cand):
            continue
        # distinct-independent prevalence for the provenance stat
        sids = {s["sessionId"] for s in cand["sessions"]}
        agents = {s.get("agent") for s in cand["sessions"] if s.get("agent")}
        proposals.append({
            "verb": cand["verb"], "target": cand["target"], "change": cand["change"],
            "citations": cand["citations"], "mode_basis": cand["mode_basis"],
            "prevalence": {"independent": len(sids), "total": len(cand["sessions"]),
                           "agents": len(agents)},
            "pattern": key,
        })
    return proposals
