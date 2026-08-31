<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Reference: dreaming orchestrator

A runnable, dependency-free (Python 3 stdlib) reference for the `management/memory-consolidation`
overlay (PRD-0041). It demonstrates the **out-of-band** consolidation shape — mine a cross-session
transcript corpus and emit an evidence-backed **proposed diff** a human promotes.

> **Reference material, not enforced runtime.** This is example/adoption code — the harness's genre is
> the *declarative* governance contract ([`../../docs/knowledge/dreaming-contract.md`](../../docs/knowledge/dreaming-contract.md)).
> No harness validator gates this orchestrator; it exists so adopters have a working starting point, like
> a template. Treat it as a reference, not a hardened production consolidator.

## Layout

| File | Responsibility |
|---|---|
| `policy.py` | Load + validate the steering file (dict-in; stdlib has no YAML — a consumer parses `dreaming-policy.yaml` with their own tooling and passes the dict in) and the `EvidenceBar` (prevalence across independent sessions, citation floor, prose-lossy down-weighting). |
| `consolidate.py` | Partition the corpus into **disjoint** slices, fan an **injected** `distill_fn` (a sub-agent; a fake in tests) over each **independently**, consolidate only after all return, and emit `PROPOSE` records that clear the evidence bar. |
| `run.py` | The operator-invoked run: emit a proposed diff + a run manifest to a **branch**. **Propose-only** — it never merges, never targets a surface outside the steering file's `targetSurfaces`, and preserves rejected proposals. |
| `test_dreaming.py` | Manual TDD tests (fake `distill_fn`, zero external calls). |

## Run the manual tests

```bash
cd reference/dreaming
python3 test_dreaming.py
```

## Safety

- **Propose-only.** The run writes a *proposed* diff + manifest to a branch; a **human merges** (Tier 2,
  never Tier 3 — the Letta divergence rejected). No confidence/evidence threshold may auto-merge: the bar
  gates whether a change is *proposed*, never whether it is *merged*.
- **Blind, independent evidence.** Sub-agents assess over disjoint corpus partitions and the orchestrator
  consolidates only after all return, so a pattern's prevalence reflects genuinely independent sessions,
  never one finding echoed N times. Same-session sightings are de-duplicated.
- **Permission-scope mirroring.** A provider may not feed a proposal targeting a store more privileged than
  its own scope; proposals may only target declared `targetSurfaces` (v1: the `promotion-candidates.md`
  staging surface).

The contract at [`../../docs/knowledge/dreaming-contract.md`](../../docs/knowledge/dreaming-contract.md)
is the source of truth; this code follows it, it does not define it.
