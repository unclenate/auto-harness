<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0041: Out-of-Band Memory Consolidation ("Dreaming") — `management/memory-consolidation`

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-08-31 | **Review Cycle:** on-change

**Status:** Accepted
**Date:** 2026-08-31
**Author:** @unclenate

## Cross-references

- **Promotes:** OPP-0058 (out-of-band memory consolidation — filed proposed, `c3e0618`). Design notes: `docs/superpowers/plans/2026-08-11-dreaming-module.md`.
- **Complements (does not replace):** PRD-0004 in-band distillation — dreaming is the *out-of-band* second layer (between sessions, dedicated budget, cross-session corpus), not a rival.
- **Depends on:** OPP-0057 / **PRD-0040** (the tamper-evident audit record) — dreaming's evidence citations become hash-verifiable (`prev_hash`) once the audit log carries it; until then, citations are `sessionId`+`timestamp`+excerpt.
- **Genre precedent:** `agents/acp` / `management/agent-coordination` — declarative contract + reference orchestrator, **Half-enforced**.

## Problem

The harness has guardrailed destinations for institutional memory and exactly one fully-wired trigger — the PR-boundary in-band distillation (PRD-0004). Several declared synthesis needs never fire: promotion of crystallized observations to operating-principles (gap #1, ~40-day dormancy observed), accumulation-vs-promotion back-pressure (gap #3), and periodic §10 doctrine re-audit (gap #4). In-band capture *structurally cannot* see patterns recurring **across** sessions, and forcing cross-session synthesis into a task session buys it at the cost of that task's attention budget. The missing layer is out-of-band: a governed, dedicated-budget batch that mines the cross-session transcript corpus and **proposes** knowledge-tree changes for a human to promote.

## Resolved framing (Q3/Q9, at OPP-0058 filing)

- **Q9 = unified:** one `management/memory-consolidation` overlay covers the session-shape gaps (not three OPPs).
- **Q3 = staging-only:** dreaming writes proposals to a reviewable staging surface a human promotes from; it **never** writes directly to `operating-principles.md`. Both re-openable here if the shape proves wrong.

## Goals

1. Ship the opt-in `management/memory-consolidation` overlay with its declarative contracts + a reference orchestrator, **v1 = promotion-candidate scan (gap #1)** on Claude Code transcripts, operator-invoked.
2. Make write-authority **propose-only** structurally (Tier 2 branch; a human merges; never Tier 3) — the load-bearing safety (the Letta divergence: machines do not merge their own memory).
3. Make evidence **honest and (eventually) verifiable**: prevalence across genuinely independent sessions; blind sub-agent assessment; hash-verifiable citations once PRD-0040's `prev_hash` lands.

## Functional Requirements

| FR | Requirement | §10 classification |
|---|---|---|
| FR-001 | **Transcript-provider contract.** A declared per-agent-pack interface: what a session transcript is, where it lands, required fields (`sessionId`, `timestamp`, tool-call records), and declared degraded modes. v1 provider: Claude Code. | Asserted (declarative contract); a `--scan-file`-seamed linter is deferred. |
| FR-002 | **Steering file.** Declarative per-org policy: signal thresholds (min prevalence / independent-session count), noise filters, dedicated token budget, target surfaces, evidence bar. | Asserted; shape-lint deferred to `validate-dreaming-*`. |
| FR-003 | **Dreaming job (reference orchestrator).** Operator-invoked batch: select corpus (respecting `permissionScope`) → partition transcripts → fan **independent** sub-agents (blind, disjoint partitions; consolidate only after all return) → consolidate against the *current* store → emit a **proposed diff** on a branch. Python/stdlib; `tick()`/`next_wake_s`, no busy-spin. Reference material, not enforced runtime. | Half-enforced (reference). |
| FR-004 | **Proposed-diff output contract.** Branch-PR anatomy: each `PROPOSE <add\|promote\|retire\|reclassify\|re-verify>` block carries an evidence block (`>= N` citations = `sessionId`+`timestamp`+excerpt **[+ event-hash once PRD-0040's `prev_hash` lands]**), prevalence (`X independent / Y total / Z agents`), mode-basis, and provenance (run-id, steering version, corpus scope) in a per-run manifest (`docs/knowledge/dreaming-runs/<run-id>.md`). **Rejected proposals are preserved** in the run manifest with rationale so a later run suppresses re-proposal (the dissent record for machine-generated knowledge). | Enforced by a companion rule (manifest mandatory) + `validate-dreaming-output` (deferred). |
| FR-005 | **Promotion-candidate scan (gap #1, the v1 duty).** Surface crystallized observations and propose promotion to a **staging surface** (never direct-to-operating-principles). The human merge is the gate; a confidence/evidence threshold gates whether a change is *proposed*, **never** whether it is merged. | Half-enforced. |
| FR-006 | **Propose-only enforced structurally.** The job runs Tier 2 (writes a branch), never Tier 3 (never merges). `tier.declared` set accordingly; review gates require human merge of any proposal. | Enforced (trust-tier + reviewGates). |

## Out of scope / deferred to their own records

- **Back-pressure audit (gap #3)** and **periodic §10 doctrine audit (gap #4)** and **staleness re-verification** — Phase 2/3.
- **`validate-dreaming-*` linter(s)** — the shape-lint for the steering file + proposed-diff evidence blocks; deferred (own record), with a pre-authored `--scan-file`-seamed design in the plan notes.
- **Non-Claude transcript providers** (Codex/Grok/…) — v1 is Claude Code; others follow the transcript-provider contract as they gain audit surfaces (Grok/Codex depend on their own audit maturity, cf. PRD-0040).
- **Direct machine write to the knowledge tree** — **rejected** (propose-only is load-bearing).

## §10 posture

**Half-enforced**, consistent with the reference-tool genre. Propose-only (FR-006) and the manifest companion rule (FR-004) are **Enforced**; the dreaming orchestrator, steering file, and transcript-provider contract are the declarative surface honored by a consumer running the job (**Asserted** until the deferred `validate-dreaming-*` linters land). The overlay is opt-in (`management/memory-consolidation`), default-off.

## Open questions (for PRD review)

1. Staging surface concretely: a dedicated `docs/knowledge/promotion-candidates.md` a human curates, vs. a labeled PR to `operating-principles.md` a human merges? (Both keep the human gate; the former adds a durable review queue.)
2. Provider trigger: purely operator-invoked (v1) vs. a `ScheduleWakeup`-paced cadence in a later phase — the pacing discipline mirrors the coordination loop's no-busy-spin heartbeat.
3. The distillation companion for the machine surface keys on `dreaming-runs/` (a machine-only-authored path), never on the shared `shared-observations.md`/`promotion-candidates.md` — confirm the trigger-path design (the mechanism-by-check-class rule from OPP-0058's own distillation observation).
