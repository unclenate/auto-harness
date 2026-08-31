# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
"""Steering-policy validation + the evidence bar for the dreaming reference orchestrator.
Reference material, not enforced runtime. Implements docs/knowledge/dreaming-contract.md.

Dict-in by design: the reference operates on a policy DICT (the shape of dreaming-policy.yaml).
Loading the consumer's YAML is the consumer's concern (stdlib has no YAML parser); tests build
policy dicts directly. `load_policy` is a thin JSON fallback for a machine-readable steering file."""
import json

# a coarse ordering of permission scopes, least → most privileged; a provider may never
# feed a proposal targeting a store more privileged than the provider's own scope.
_SCOPE_RANK = {"public": 0, "consumer-local": 1, "maintainer-local": 2, "kernel": 3}

_REQUIRED_TOP = ["budget", "evidenceBar", "targetSurfaces", "corpus"]

def load_policy(path):
    """Load a machine-readable steering file (JSON form). The canonical steering file is YAML
    (dreaming-policy.yaml); a consumer parses it with their own tooling and passes the dict in.
    This helper exists only so the reference is runnable end-to-end from a JSON fixture."""
    with open(path) as fh:
        return json.load(fh)

def _scope_rank(scope):
    if scope not in _SCOPE_RANK:
        raise ValueError("unknown permissionScope: %r" % scope)
    return _SCOPE_RANK[scope]

def validate_policy(policy):
    """Raise ValueError on a malformed steering policy or a permission-scope violation."""
    for k in _REQUIRED_TOP:
        if k not in policy:
            raise ValueError("steering policy missing required key: %s" % k)
    corpus_scope = policy["corpus"].get("permissionScope")
    if corpus_scope is None:
        raise ValueError("corpus.permissionScope is required")
    corpus_rank = _scope_rank(corpus_scope)
    # permissionScope mirroring: no provider may exceed the corpus scope
    for pack, prov in (policy.get("transcriptProviders") or {}).items():
        ps = prov.get("permissionScope")
        if ps is not None and _scope_rank(ps) > corpus_rank:
            raise ValueError(
                "transcript provider %r scope %r exceeds corpus scope %r" % (pack, ps, corpus_scope))

class EvidenceBar:
    """Decides whether a consolidated candidate clears the steering file's evidence bar.
    A candidate: {"pattern": str, "sessions": [{"sessionId","mode"}...], "citations": [...]}."""
    def __init__(self, policy):
        bar = policy["evidenceBar"]
        self.min_prevalence = bar["minPrevalenceSessions"]
        self.min_citations = bar["minCitationsPerChange"]
        self.prose_lossy_weight = bar.get("proseLossyWeight", 0.5)

    def _weighted_prevalence(self, sessions):
        # count DISTINCT independent sessions; a prose-lossy session is down-weighted
        seen, total = set(), 0.0
        for s in sessions:
            sid = s["sessionId"]
            if sid in seen:
                continue          # prevalence counts INDEPENDENT sessions, never one echoed N times
            seen.add(sid)
            total += self.prose_lossy_weight if s.get("mode") == "prose-lossy" else 1.0
        return total

    def passes(self, candidate):
        if len(candidate.get("citations", [])) < self.min_citations:
            return False
        return self._weighted_prevalence(candidate.get("sessions", [])) >= self.min_prevalence
