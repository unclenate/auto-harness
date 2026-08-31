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

# only these declared modes earn full confidence; a missing/unknown mode is down-weighted,
# never trusted at 1.0 (contract: "degraded modes are declared, not silent" — the conservative
# branch is the silent one, so an undeclared mode must NOT fail open to full weight).
_FULL_CONFIDENCE_MODES = {"full", "session-only"}

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
            # full/session-only → full weight; prose-lossy AND any missing/unknown mode → down-weighted
            total += 1.0 if s.get("mode") in _FULL_CONFIDENCE_MODES else self.prose_lossy_weight
        return total

    def passes(self, candidate):
        # count DISTINCT citations: a single transcript cited N times is ONE source, not N. Parallels
        # the prevalence dedup (contract requires ">= N transcripts", a citation being sessionId +
        # timestamp + excerpt); here a citation is an opaque identity token, deduped by value.
        if len(set(candidate.get("citations", []))) < self.min_citations:
            return False
        return self._weighted_prevalence(candidate.get("sessions", [])) >= self.min_prevalence
