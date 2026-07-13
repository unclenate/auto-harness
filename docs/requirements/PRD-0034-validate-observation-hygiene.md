<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0034: Observation-Hygiene Content Validator — `validate-observation-hygiene.sh`

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-07-11 | **Review Cycle:** On-change

**Status:** Accepted *(design-only per § 9; the implementing PR ships the validator + its knowledge-capture registration + the stigmergy species-naming + propagation)*
**Date:** 2026-07-11 (filed + accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Promoting OPP: [OPP-0053](../opportunities/OPP-0053-observation-ledger-hygiene.md) — `proposed` at filing; this PRD ratifies its **Layer 1** deliverable (the diff-based shape linter) plus the stigmergy species-naming, and flips it `proposed → exploring`. OPP-0053 flips `exploring → accepted` at this validator's implementation-merge; the **Layer 2 ambient auto-capture Stop-hook** is a follow-on phase with its own PRD.
- Sibling OPP (same species): [OPP-0052](../opportunities/OPP-0052-federated-review-lane-contract.md) — the *structured-agent-ledger gate* on the **verdict** ledger; this PRD's validator is the same species on the **knowledge** ledger. Reconciled at the convention layer (named in `stigmergy.md`, separate module homes), not shared code.
- Governed schema: [ADR-0002](../adr/ADR-0002-knowledge-capture-structured-observations.md) — the six-field Observation Structure (`Context`, `Observation`, `Implication`, `Confidence` enum `low|medium|high`, `Severity` enum `informational|governance-relevant|architectural|risk-bearing`, `Contributed by` name + ISO date). This validator enforces that shape; changing the schema itself remains ADR-domain (companion-gated via knowledge-capture's `sensitivePath` on `docs/knowledge/README.md`).
- Owning module: [`management/knowledge-capture`](../../platform/profiles/management/knowledge-capture/module.yaml) (v1.2.0) — already enforces that an observation **exists** and **connects** (audit-trail + PRD-0004 distillation companions) but never its **shape**. This validator closes that gap and registers under the module's `validators:` list.
- Diff-based precedent: [`validate-knowledge-redaction.sh`](../../platform/validators/validate-knowledge-redaction.sh) (OPP-0036 / PRD, Wave 5.5) — scans only new lines added to `docs/knowledge/shared-observations.md` vs. a base branch; the record-extraction + grandfather-history discipline this validator reuses. Module-gated + diff-based, like `validate-lane-integrity.sh` (PRD-0025).
- Shape-assertion precedent: [`validate-module-stability.sh`](../../platform/validators/validate-module-stability.sh) (PRD-0027) and [`validate-trace-contract.sh`](../../platform/validators/validate-trace-contract.sh) (PRD-0031) — presence + enum-membership only, never the correctness of the human judgment.
- Related operating-principles: § 9 (Split Design from Implementation — this PRD is the design; a separate PR implements), § 10 (this validator converts the ADR-0002 **shape** claim for new observations from Asserted-only to Enforced; it asserts presence + enum membership only, never the semantic quality of the judgement).

## Overview

`management/knowledge-capture` mechanizes two things about every addition to
`docs/knowledge/shared-observations.md`: an **audit-trail** pointer (change-log entry) and,
for ADR/OPP/module edits, a **paired distillation** entry (PRD-0004). It never checks that
the observation is **internally well-formed**. ADR-0002 ratified a six-field structure with
two locked enums, but nothing lints an entry against it — and a ratified schema with no
validator drifts. It has: of 105 live observations, **62 (59%) carry an off-enum
`Severity`**, the most-severe canonical level `risk-bearing` is used **0×**, 21 entries
misfile `Confidence`-vocabulary (`low`/`medium`) into `Severity`, 24 (23%) omit `Confidence`,
and 21 (20%) omit `Contributed by`.

This drift is not cosmetic. ADR-0002 makes `Severity` **load-bearing**: it drives the
escalation table (`governance-relevant → revision tracker`, `architectural → ADR`,
`risk-bearing → risk register`). An off-enum `Severity` matches no escalation rule, so a
`process`-tagged observation that should have escalated silently does not — the drift defeats
the very mechanism the field exists to power.

This PRD ratifies OPP-0053's **Layer 1**: **`validate-observation-hygiene.sh`**, a diff-based
content validator that lints each observation *added versus the base branch* against the
ADR-0002 shape — six fields present, `Confidence` in its enum, `Severity` in its enum, an ISO
date on `Contributed by`. It asserts **presence + shape only — never the semantic quality of
the judgement**, exactly as `validate-module-stability.sh` checks a declared stability value's
enum membership and not the honesty of the call.

Two design properties distinguish it from the requirement-set content validators
(`validate-trace-contract` and its siblings):

1. **Diff-based, grandfathering history.** It extracts only the observations *newly added* in
   the PR diff (heading-to-heading records) and lints those, so the existing 105 are never
   re-litigated — the same record-extraction discipline as `validate-knowledge-redaction.sh`.
2. **Active on the harness itself (dogfood, not predict-clean).** `knowledge-capture` is an
   **active** module on the harness, so this validator runs live on the harness's own CI —
   every *new* observation the harness commits must conform. This is the
   `validate-knowledge-redaction` / `validate-companions` absorption variant (dogfood on
   self), not the predict-clean no-op of the module-gated content validators. When
   `knowledge-capture` is **inactive** in a consumer manifest, the validator exits 0 with a
   "module inactive" skip (predict-clean for that consumer).

The **load-bearing design decision** is the `Severity` treatment, resolved here in § 10:
**enforce-as-locked**. The validator treats the ADR-0002 enum as the contract, so a new
observation carrying `process` / `low` / `medium` / `programming-discipline` / `security` /
`architecture` (the spelling variant of canonical `architectural`) **fails**. The rejected
alternative — amend ADR-0002 to admit `process` before enforcing — is a schema change, and
schema changes are ADR-domain (companion-gated on `docs/knowledge/README.md`); the drift is
the defect, not the schema, so enforcement is the correct lever. This § 10 classification is
the ratification checkpoint for that call.

## Goals & Non-Goals

**Goals:**

- Ship `platform/validators/validate-observation-hygiene.sh` — Bash 3.2, shellcheck-clean at
  `-S warning`, 3-state exit (0 pass / 1 violation / 2 usage). When `knowledge-capture` is
  **inactive**: exit 0 + skip message (predict-clean for that consumer). When active: diff
  `docs/knowledge/shared-observations.md` against the base branch, extract each newly-added
  observation record, and assert the ADR-0002 shape below.
- The ADR-0002 shape checks (presence + enum membership, never semantic quality), per
  newly-added observation:
  1. **All six fields present** — `Context`, `Observation`, `Implication`, `Confidence`,
     `Severity`, `Contributed by`.
  2. **`Confidence`** ∈ `{low, medium, high}`.
  3. **`Severity`** ∈ `{informational, governance-relevant, architectural, risk-bearing}`
     (enforce-as-locked — off-enum values fail).
  4. **`Contributed by`** carries a name/handle **and** an ISO-8601 calendar date
     (e.g. `2026-07-11`).
- **Grandfather history** — only observations added in the diff vs. base are linted; the
  existing 105 are exempt (diff-record extraction, per the redaction-validator precedent).
- Register the validator under `management/knowledge-capture`'s `validators:` list (its
  trigger surface — additions to `docs/knowledge/shared-observations.md` — is already the
  module's companion `triggerPath`, so self-coverage is inherent per the PR-#88 rule).
- Ship a `--scan-file <path>` test seam that lints an arbitrary shared-observations-shaped
  file without git or active-module gating (fixture-firing tests), per the
  validator-test-seam pattern; and a `--block`/default-posture decision fixed at **BLOCK**
  (the drift is already large; a WARN posture would not stop it).
- Name the **structured-agent-ledger gate** species in
  [`docs/architecture/stigmergy.md`](../../docs/architecture/stigmergy.md) § 4 (Forced Traces),
  so this validator and `validate-coordination-verdicts.sh` (OPP-0052) read as two instances
  of one contract — the convention-layer reconciliation, not shared code.
- Propagation: the validator joins the harness-governance run-order chain, AGENTS.md,
  `platform/validators/README.md`, the root README validator table + mermaid box, the
  `harness-governance` SKILL.md chain, and CI; the validator-count prose bumps **24 → 25** at
  every `validate-catalog-counts` ASSERTIONS site (the recipe auto-derives from the
  `validate-*.sh` file count; recompute at impl).
- Fixture tests in `platform/validators/test/` covering: inactive no-op pass, a well-formed
  new observation pass, and each failure mode (missing field, off-enum `Confidence`, off-enum
  `Severity`, `Contributed by` missing an ISO date), plus a grandfather case (an off-enum
  *pre-existing* observation not in the diff → still passes).
- One paired distillation observation on the implementing PR (its `knowledge-capture/module.yaml`
  edit fires the PRD-0004 trigger) — which the new validator then lints, closing the dogfood loop.

**Non-Goals (deferred):**

- **Layer 2 — the ambient auto-capture Stop-hook** (scaffold a schema-shaped inert stub when a
  session touched a distillation-trigger path but not the ledger). The active-trace half; its
  own follow-on PRD under OPP-0053, reusing this validator's shape definition as the stub's shape.
- **Semantic-quality checks** — whether the chosen `Severity` is *the right* severity, whether
  the `Observation` is insightful, whether the `Confidence` is calibrated. Presence + enum
  membership only; honesty of the call is an authoring act (the `validate-module-stability`
  boundary).
- **Backfilling the grandfathered 105** — the 24 `Confidence`-omitting and 21
  `Contributed-by`-omitting historical entries stay grandfathered. A one-time backfill is a
  separate, optional cleanup, not gated by this validator.
- **Amending the ADR-0002 `Severity` enum** to admit `process`. Explicitly rejected here (see
  § 10); a schema change is ADR-domain and would be its own ADR + companion-gated
  `docs/knowledge/README.md` edit.
- **A new operating-principle section.**

## § 10 Claim Classification

| Claim ID | Claim | Current | After v1 |
|----------|-------|---------|----------|
| C-OBS-1 | A newly-added shared observation carries all six ADR-0002 fields | Asserted-only (knowledge-capture enforces the trace exists + connects, not its shape) | **Enforced** when `knowledge-capture` is active — `validate-observation-hygiene.sh` asserts six-field presence on every diff-added record; predict-clean when the module is inactive |
| C-OBS-2 | `Confidence` and `Severity` are drawn from their locked ADR-0002 enums | Asserted-only (drift: 59% off-enum `Severity`, `risk-bearing` 0×) | **Enforced (enforce-as-locked)** — off-enum values fail on new observations; the enum is the contract, the drift is the defect |
| C-OBS-3 | `Contributed by` carries an attributable name + ISO date | Asserted-only (20% omit it) | **Enforced** on new observations |
| C-OBS-4 | The *chosen* `Severity`/`Confidence` is semantically correct for the observation | Asserted-only | **Unchanged** — semantic quality is an authoring act, not mechanizable (the `validate-module-stability` boundary) |

The enforce-as-locked classification of C-OBS-2 is this PRD's ratification checkpoint. The
rejected alternative (amend ADR-0002 to bless `process`) would move the contract to fit the
drift; enforcing the ratified enum instead treats the drift as the defect and is the reversible,
lower-commitment lever (a future ADR can still widen the enum, at which point the validator's
enum list follows).

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001 | `validate-observation-hygiene.sh` ships | Bash 3.2, shellcheck-clean (`-S warning`), 3-state exit. Inactive (`knowledge-capture` not active) → exit 0 + skip message. Active → diff `docs/knowledge/shared-observations.md` vs. base, extract diff-added records, run FR-002 checks. `--help` documents args + the ADR-0002 shape + the enforce-as-locked enum. |
| FR-002 | The ADR-0002 shape checks | Per diff-added observation: (1) all six fields present; (2) `Confidence` ∈ `{low,medium,high}`; (3) `Severity` ∈ `{informational,governance-relevant,architectural,risk-bearing}`; (4) `Contributed by` has name + ISO-8601 date (`2026-07-11` form). Per-field, per-record surfacing on failure (heading quoted). |
| FR-003 | Diff-record extraction grandfathers history | Only observations *added in the diff vs. base* are linted (heading-to-heading record boundaries); the existing 105 are never scanned. Outside a git tree / base absent (shallow CI, non-PR dogfood) → exit 0 with an informational message, per the redaction-validator precedent. |
| FR-004 | Module gating + inherent self-coverage | Gated on `management/knowledge-capture` active (via the `HarnessRegistry` active-module set). Registered in the module's `validators:` list; its trigger surface is already the module's companion `triggerPath` (PR-#88 self-coverage is inherent). |
| FR-005 | `--scan-file` test seam | `--scan-file <path>` lints an arbitrary shared-observations-shaped file (treating **all** records as in-scope, since there is no diff) without git or module gating, per the validator-test-seam pattern. |
| FR-006 | BLOCK posture | Default posture is **BLOCK** (exit 1 on any violation); the drift is already large enough that a WARN posture would not arrest it. Unlike `validate-knowledge-redaction` (WARN-by-default, `--block` to escalate), shape is unambiguous, so BLOCK is the default. |
| FR-007 | Stigmergy species-naming | `docs/architecture/stigmergy.md` § 4 names the **structured-agent-ledger gate** species and cross-references both instances (`validate-observation-hygiene.sh` on the knowledge ledger; `validate-coordination-verdicts.sh` on the verdict ledger). Doc-only; the convention-layer reconciliation with OPP-0052. |
| FR-008 | Propagation + validator-count bump | Validator wired into the harness-governance chain, AGENTS.md, `platform/validators/README.md`, root README table + mermaid box, the SKILL.md chain, CI. Validator count 24 → 25 at every `validate-catalog-counts` ASSERTIONS site (recipe auto-derives; recompute at impl). |
| FR-009 | Fixture tests | `platform/validators/test/` gains a `TestValidateObservationHygiene` case: inactive no-op, well-formed new-observation pass, the four failure modes (missing field, off-enum Confidence, off-enum Severity, no ISO date), and a grandfather case (off-enum *pre-existing* record not in the diff → pass). |
| FR-010 | Chain stays green; dogfood on the harness | The full validator chain passes on the harness's own CI. Because `knowledge-capture` is active, any new observation in the implementing PR (including its own PRD-0004 distillation entry) must be ADR-0002-conformant — the dogfood loop closes. |

### Should Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-S01 | Off-enum hint names the misfile | When a new observation's `Severity` is `low`/`medium` (a `Confidence` value), stderr hints "→ `low`/`medium` are `Confidence` values; `Severity` ∈ {informational, governance-relevant, architectural, risk-bearing}" — the single most common drift (21 entries). |
| FR-S02 | `architectural` spelling nudge | When `Severity` is `architecture`, stderr hints the canonical spelling is `architectural`. |

### Out of Scope

| Feature | Reason | Revisit |
|---------|--------|---------|
| Layer 2 ambient auto-capture Stop-hook | active-trace half; reuses this shape definition | own follow-on PRD under OPP-0053 |
| Semantic-quality checks (is the Severity *right*) | honesty of the call is an authoring act | not planned (the module-stability boundary) |
| Backfilling the grandfathered 105 | diff-based validator does not require it | optional one-time cleanup PR |
| Amending ADR-0002 to admit `process` | schema change is ADR-domain; drift is the defect | a future ADR if the severity axis is genuinely re-scoped |

## Technical Constraints

- **Bash 3.2 compatible** (macOS default); **shellcheck clean at `-S warning`**; **3-state
  exit** (0 / 1 / 2).
- **Ruby for content scanning** — inline `ruby`, same approach as
  `validate-knowledge-redaction.sh` / `harness_registry.rb`. No new runtime dependencies
  (Bash + system Ruby only). Field/heading parsing is line-oriented on the `- **Field:**`
  and `###`-heading conventions the ledger already uses.
- **Diff extraction** — `git diff <base>...HEAD -- docs/knowledge/shared-observations.md`
  restricted to added lines, grouped into records by `###` heading boundaries; a record is
  "new" if its heading line is added. Mirrors the redaction validator's added-line scan.
- **Canonical enums (codified here as the source, mirroring ADR-0002):** `Confidence` =
  `{low, medium, high}`; `Severity` = `{informational, governance-relevant, architectural,
  risk-bearing}`. If a future ADR amends either enum, the validator's list follows in the
  same PR (append-only discipline).
- **Active-module detection** — `HarnessRegistry` active-module set; checks whether
  `management/knowledge-capture` is active before doing content work (predict-clean skip for
  consumers that don't run it).
- **Performance** — < 2s on a normal PR diff.
- The validator's own authored prose (`--help`, inline comments) must not trip
  `validate-skill-content.sh` (meta-§10 — the new validator's surface is scanned by its siblings).

## CI/CD Gates

- Full validator chain (now **25** validators) green, including the new validator (dogfood on
  the harness) and `validate-catalog-counts` after the 24 → 25 bump.
- Fixture tests pass; markdownlint + shellcheck clean.
- Diff-mode self-check: the implementing PR's own new observation(s) pass
  `validate-observation-hygiene.sh` — the dogfood loop is itself a gate.

## Acceptance Criteria for OPP-0053 → `accepted`

OPP-0053 flips `exploring → accepted` when FR-001…FR-010 merge and the harness's own CI
passes — the observation-hygiene validator is OPP-0053's Layer 1 deliverable. Layer 2 (the
ambient auto-capture Stop-hook) proceeds as a follow-on phase (its own PRD) reusing the shape
definition this PR establishes.

## Versioning Implications

Additive: a new validator + a `validators:` registration on `knowledge-capture` (bump to
v1.3.0 — a new enforced check is a minor feature) + a doc paragraph in `stigmergy.md`. The
shape check is a **content tightening** for the shared-observations artifact, applied only to
*new* observations (diff-based), so existing history and existing consumers are unaffected
until they add a new observation under an active `knowledge-capture` — consistent with the
monotonic-tightening discipline. Lands in the next minor. Validator count 24 → 25.
