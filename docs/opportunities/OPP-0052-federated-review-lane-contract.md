<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0052 — Federated Review-Lane Contract (verdict schema + coordination substrate)

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-07-09
**Last Updated:** 2026-07-09
**Confidence:** high (field-proven before authored — see Origin / Evidence)

---

## Thesis

OPP-0046 / PRD-0025 mechanized the **scope-lane** (who writes what: the
`work-package` lane contract, the idempotent worktree runbook, and
`validate-lane-integrity.sh`). The complementary **review-lane** — *who reviews
whom, in what artifact, and how verdicts are tallied* — has no machine-checkable
substrate. The proposal ships a `platform/templates/coordination/` scaffold plus a
`validate-coordination-verdicts.sh` validator so that Claude / Codex / Copilot /
Antigravity all emit the **same** verdict artifact and an adjudicating core can
tally them mechanically. This is the multi-agent analog of the pattern the harness
already runs for modules — *declare a contract, then mechanically check work
against it* — retargeted from scope (OPP-0046) to review.

The design is authority-of-record in a consumer supervisor repo's ADR (the
Inter-Agent Operating Contract, "Monolithic Core, Federated Adversaries":
federate skepticism across providers, centralize truth in one writer-of-record and
one adjudicated ledger per workstream). This OPP is the **harness enforcement half**
so every governed repo inherits the substrate rather than re-deriving it.

### Sub-components (decomposed)

| Sub-component | What it governs | Disposition |
|---|---|---|
| **`platform/templates/coordination/` scaffold** | Canonical `docs/coordination/` shape: `sync-log-<repo>.md`, `verdicts/verdict-<canonicalTaskId>-<provider>.json`, `review-request-<canonicalTaskId>.md` | **Wedge candidate** |
| **Provider-neutral verdict schema** | `{ taskId, reviewer("<provider>/<model>"), verdict(approved\|rejected\|approved-with-findings), severity, findings[], timestamp }` | **Wedge candidate** |
| **`validate-coordination-verdicts.sh`** | Lints verdict files against the schema; asserts `taskId` is a declared **canonical shared** id (not per-file / per-provider); flags a substantive workstream merged without ≥ 1 decorrelated-provider verdict | **Wedge candidate** |
| **Canonical-taskId onboarding rule** | Reviewer copies the canonical `taskId` from the review-request; never mints its own (the field-observed label-swap fix) | **Wedge candidate (onboarding)** |
| Decorrelated-provider routing | Assign the reviewer from a *different* provider than the author (reviewer value ∝ decorrelation of blind spots) | Asserted (onboarding skill) |
| Whole-branch coverage backstop | No substantive branch merges without ≥ 1 review-lane verdict | Asserted / half-enforced |

## Origin / Evidence

Field-proven before authored. A consumer harvest workstream (2026-07-06..08) ran a
federated review lane: an agent from one provider reviewed two adapters authored by
an agent from another, emitting schema-conformant verdicts under
`docs/coordination/verdicts/`. Two defects surfaced, and each becomes one enforced
rule above:

1. **Verdict label-swap** — reviewers minted per-file/per-provider ids, so verdicts
   for the same task could not be tallied → the **canonical shared `taskId`** rule.
2. **Core-only adjudication** — a run of tasks was adjudicated without any
   decorrelated-provider verdict → the **mandatory decorrelated coverage** flag.

The supervisor reconstructed full cross-repo state on return from these committed
artifacts alone, across a multi-day comms blackout — the strongest available case
for *coordinate-through-artifacts* (stigmergy) as an enforceable substrate rather
than a convention.

- **Internal precedent.** The verdict artifact is the review-lane analog of the
  module declare-then-enforce contract (`sensitivePaths` / `companionRules`,
  OPP-0034 / ADR-0017); the canonical-taskId binding is a *stop-and-copy* discipline
  like the scope-lane's stop-and-report; the coordination directory is the
  structured-observations ledger (ADR-0002) used as an inter-agent channel.
- **Coordination model.** Instantiates `docs/architecture/stigmergy.md`; harvested
  per `platform/workflow/upstream-harvesting.md` (Workflow #24).

## Why Now

- **The harness is already the multi-agent workspace this governs.** The scope-lane
  half (OPP-0046) shipped because parallel multi-agent execution recurred in the
  field; the review-lane is the same workspace's other unmechanized seam, and the
  two defects above are concrete, not hypothetical.
- **Federation makes the seam wider, not narrower.** As reviewers span providers
  (Claude / Codex / Copilot / Antigravity), a prose-only verdict convention diverges
  per tool exactly where cross-provider tally most needs a stable shape.
- **The authority-of-record already exists.** A consumer supervisor ratified the
  design; the harness enforcement half is the missing lower layer, and shipping it
  now closes the two-layer split rather than leaving enforcement asserted-only.

## Risks / Open Questions

- **Enforced vs. asserted boundary.** Verdict-JSON schema conformance,
  canonical-`taskId` binding, and verdict-file naming are mechanizable (Enforced);
  decorrelated-provider *routing* and the whole-branch coverage backstop are agent
  behavior routed through the onboarding skill (Asserted / half-enforced). Classify
  precisely at PRD time with a § 10 claim table.
- **Schema home + versioning.** Is the verdict schema a JSON Schema file under
  `platform/templates/coordination/`, a fenced block in a spec, or both? It needs a
  version pin so cross-provider emitters can target a stable contract.
- **Module gating.** Should the validator be always-on or gated behind a
  `management/coordination` (or `work-package` v2) module, predict-clean when
  inactive — matching the opt-in pattern of `validate-lane-integrity.sh`?
- **Canonical-id source of truth.** The review-request declares the canonical
  `taskId`; the validator must resolve "declared canonical" without a central
  registry (likely: the id is well-formed and matches a review-request in the same
  coordination directory).
- **Adjacency with the scope-lane.** Lane (scope) and verdict (review) are two
  halves of one multi-agent contract; decide whether this lands as a sibling module
  or a v2 phase of `management/work-package`.

## Disposition

**Proposed (2026-07-09).** Harvested from a consumer federated-review field cycle
into the harness enforcement half of a two-layer inter-agent contract. Recommended
promotion path: a PRD that ships the **verdict-schema + `validate-coordination-verdicts.sh`
wedge** (the two Enforced rules) with a § 10 claim classification, deferring
decorrelated-routing and the coverage backstop to the onboarding skill. The
scaffold and schema are the thin, field-harvested wedge; the routing/coverage
asserts are the deferred depth — mirroring OPP-0046's lane-first, economics-later
staging.

## Related

- Sibling half (scope-lane): OPP-0046 / PRD-0025 (`management/work-package`,
  `validate-lane-integrity.sh`).
- Declare-then-enforce precedent: OPP-0034 / ADR-0017 (`validate-sensitive-paths`),
  the module `companionRules` contract.
- Cross-agent memory channel: ADR-0002 (structured shared observations).
- Coordination model: `docs/architecture/stigmergy.md`;
  `platform/workflow/multi-agent-tool-coordination.md`;
  `platform/workflow/upstream-harvesting.md` (Workflow #24 — how this OPP was
  harvested).
- Authority-of-record: a consumer supervisor's Inter-Agent Operating Contract ADR
  (the design this enforcement half implements).
