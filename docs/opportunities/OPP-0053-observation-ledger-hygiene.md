<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0053 — Observation-Ledger Hygiene Gate (structured-agent-ledger validator + ambient auto-capture)

**Status:** accepted *(Layer 1 implemented 2026-07-12 per [PRD-0034](../requirements/PRD-0034-validate-observation-hygiene.md) — `validate-observation-hygiene.sh` shipped, registered under `management/knowledge-capture` v1.3.0, and the structured-agent-ledger gate species named in `stigmergy.md` §4. Layer 2, the ambient auto-capture Stop-hook, remains a deferred follow-on PRD.)*
**Owner:** @unclenate
**Created:** 2026-07-10
**Last Updated:** 2026-07-12
**Confidence:** high (field-proven this session — see Origin / Evidence)

---

## Thesis

`management/knowledge-capture` enforces that a shared observation **exists** and is
**connected** — any addition to `docs/knowledge/shared-observations.md` must carry an
audit-trail pointer (change-log entry) and, for ADR/OPP/module edits, a paired
distillation entry (PRD-0004). It never checks the observation's **shape**. The
structure is ratified — ADR-0002 locks six fields (`Context`, `Observation`,
`Implication`, `Confidence` with enum `low|medium|high`, `Severity` with enum
`informational|governance-relevant|architectural|risk-bearing`, `Contributed by`
with name/handle + ISO date) — but nothing lints an entry against it. A ratified
schema with no validator is a schema that drifts, and it has: of 105 live
observations, **62 (59%) carry an off-enum `Severity`**, the most-severe canonical
level `risk-bearing` is used **0×**, 24 (23%) omit `Confidence`, and 21 (20%) omit
`Contributed by`.

The proposal ships, in two layers:

1. **`validate-observation-hygiene.sh`** — a diff-based linter that checks each
   observation *added versus the base branch* against the ADR-0002 shape: six fields
   present, `Confidence` in its enum, `Severity` in its enum, an ISO date on
   `Contributed by`. BLOCK posture, module-gated (predict-clean when
   knowledge-capture is inactive), grandfathering the existing 105 (diff-scoped, so
   history is never re-litigated). It checks **presence and shape only — never the
   semantic quality of the judgement**, exactly as `validate-lane-integrity.sh`
   checks a lane declaration's shape and not the wisdom of the split.
2. **Ambient auto-capture Stop-hook** — when a session touched a distillation-trigger
   path (ADR/OPP/module.yaml) but never appended to the ledger, scaffold a
   schema-shaped **inert stub** so the six fields are pre-poured and the omission is
   visible rather than silent. This is the active-trace half that
   `docs/architecture/stigmergy.md` §4 ("Forced Traces") half-draws: today the
   `distillation-prompt.sh` hook *reminds*; this *scaffolds*.

### Reconciliation with OPP-0052

OPP-0052 (federated review-lane) and this OPP are the **same species** — a
*structured-agent-ledger gate*: a validator that lints each newly-added record in an
append-only, agent-emitted ledger against a declared schema, diff-based against the
base branch, BLOCK posture, module-gated. OPP-0052 governs the **verdict ledger**
(`docs/coordination/verdicts/`, JSON, cross-provider review); this governs the
**knowledge ledger** (`docs/knowledge/shared-observations.md`, Markdown, longitudinal
memory). They are retargeted instances of one contract, not one validator.

Reuse lands at the **convention layer, not shared code**: the species is *named* in
`stigmergy.md`, the two validators keep **separate module homes**
(`management/knowledge-capture` vs. `management/coordination`), and no shared library
is built — a Markdown field-parser and a JSON schema-validator barely overlap, so a
shared lib would be a thin abstraction over two dissimilar parsers. Concrete-first
over premature abstraction; the reconciliation is a cross-reference and a shared
vocabulary, which is what actually transfers.

### Sub-components (decomposed)

| Sub-component | What it governs | Disposition |
|---|---|---|
| **`validate-observation-hygiene.sh`** | Lints each observation added vs. base against ADR-0002: six fields present, `Confidence` enum, `Severity` enum, ISO date on `Contributed by`; presence + shape only, never semantic quality | **Wedge — Enforced** |
| **Ambient auto-capture Stop-hook** | Session touched a distillation-trigger path but not the ledger → scaffold a schema-shaped inert stub | **Wedge — active-trace** |
| Species naming in `stigmergy.md` | Names the *structured-agent-ledger gate* species so OPP-0052's and this validator read as instances of one contract | Asserted (doc) |
| `Severity` enforce-as-locked vs. amend-ADR-0002 | Whether to enforce the ADR-0002 enum as-is (`process`/`low`/`medium` become errors) or first amend the enum to admit field-observed values | Open — resolve at PRD time |
| `Confidence` / `Contributed-by` history backfill | Whether the 24/21 pre-existing omissions get backfilled or stay grandfathered | Asserted (deferred) |

## Origin / Evidence

Field-proven this session. Two consecutive parallel-session PRs shipped with exactly
the defects a shape-linter catches, each corrected by hand:

1. **PR #165** carried a phantom `shared-observations.md` claim and a mis-cited
   companion rule — a presence/linkage error that the audit-trail companion does not
   see because the pointer existed; only the *content* was wrong.
2. **PR #167** shipped missing its audit-trail satisfier **and** leaked a consumer
   name into a redaction-guarded file — caught only by the diff-mode redaction
   validator plus hand review, not by any shape check on the observation itself.

The standing drift on the live ledger (105 observations) is the accumulated evidence
that ratification ≠ enforcement:

- **62/105 (59%) off-enum `Severity`** — `process` 28, `low` 15, `medium` 6,
  `architecture` 8 (a spelling variant of canonical `architectural`),
  `programming-discipline` 4, `security` 1.
- **`risk-bearing` — the most-severe canonical level — used 0×.** The vocabulary
  that would flag the highest-stakes lessons is the one nobody reaches for.
- **21 entries (`low` / `medium`) are `Confidence`-vocabulary values misfiled into
  the `Severity` field** — the two locked enums bleed into each other precisely
  because nothing keeps them apart.
- **24/105 (23%) omit `Confidence`; 21/105 (20%) omit `Contributed by`.**

The ledger is the harness's own longitudinal memory; a linter on *its* schema is the
harness dogfooding the declare-then-enforce contract it sells to consumers.

## Why Now

- **The ledger is the harness's own longitudinal memory.** Every session reads it
  back; drift there compounds silently and degrades the exact substrate other
  governance leans on.
- **OPP-0052 just landed (#169) as the sibling half.** Filing this now, while the
  structured-agent-ledger species is fresh, lets the two validators ship as
  recognized instances of one contract rather than as two unrelated one-offs.
- **Auto-capture closes a loop `stigmergy.md` §4 already half-draws.** The passive
  companion rules and the `distillation-prompt.sh` reminder are the "forced traces"
  today; a scaffolding Stop-hook is the active half the section gestures at but the
  harness does not yet ship.

## Risks / Open Questions

- **`Severity` enforce-as-locked vs. amend-ADR-0002.** The single load-bearing PRD
  question. Enforce-as-locked treats the ADR-0002 enum as the contract and makes
  `process`/`low`/`medium` errors (leaning: the ratified schema is the norm; drift is
  the defect). Amend-first would widen the enum to admit `process` before enforcing.
  This is a schema change either way if amended — companion-rule-gated via
  knowledge-capture's `sensitivePath` on `docs/knowledge/README.md` — so it is
  maintainer-domain. Classify with a § 10 claim table at PRD time.
- **Diff-record extraction.** The linter must isolate *one added observation* from a
  unified diff (heading-to-heading) to lint it in isolation without re-scanning the
  grandfathered 105 — the same diff-record discipline as
  `validate-knowledge-redaction.sh`.
- **Module gating + self-coverage.** Gate on `management/knowledge-capture`,
  predict-clean when inactive; per the PR-#88 rule, the validator's own fixture must
  land inside knowledge-capture's `triggerPaths` so it is self-covered.
- **Hook false-positives.** A Stop-hook that scaffolds a stub on every
  distillation-path touch risks noise on sessions that legitimately add none; the
  stub must be **inert** (never itself a schema-conformant entry that would satisfy
  the very check it stands in for) and clearly marked as a prompt.
- **Backfill boundary.** Whether the 24 `Confidence`-omitting and 21
  `Contributed-by`-omitting historical entries get a one-time backfill or stay
  grandfathered — a scope decision that trades a clean ledger against churn on
  settled history.

## Disposition

**Proposed (2026-07-10).** Recommended promotion path: a PRD that ships **Layer 1
(`validate-observation-hygiene.sh`) + the `stigmergy.md` species-naming first**, with
a § 10 claim table that classifies the `Severity` enforce-as-locked decision
explicitly, then **Layer 2 (the auto-capture Stop-hook)** as the active-trace
follow-on. Shipping Layer 1 takes the validator count 24 → 25 (catalog-counts
propagation). The linter is the thin, field-harvested wedge; the hook is the deferred
depth — mirroring OPP-0052's schema-first, routing-later staging and OPP-0046's
lane-first, economics-later staging.

## Related

- **Sibling half (review-lane):** OPP-0052 (`management/coordination`,
  `validate-coordination-verdicts.sh`) — the same structured-agent-ledger species on
  the verdict ledger.
- **Grand-sibling (scope-lane):** OPP-0046 / PRD-0025 (`management/work-package`,
  `validate-lane-integrity.sh`).
- **Governed schema:** ADR-0002 (structured shared observations — the six-field
  contract this linter enforces).
- **Complements:** PRD-0004 (the distillation-trigger companion this shape-check
  completes — presence/linkage enforced there, shape enforced here).
- **Coordination model:** `docs/architecture/stigmergy.md` §3B (observation ledger as
  longitudinal memory) and §4 (Forced Traces — the active-trace half the hook fills).
- **Diff-based precedent:** `validate-knowledge-redaction.sh` (scans only new lines
  vs. base; the record-extraction pattern this linter reuses).
