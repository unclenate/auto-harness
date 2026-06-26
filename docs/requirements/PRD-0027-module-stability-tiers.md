<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0027: Module Stability Tiers — `validate-module-stability.sh`

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-26 | **Review Cycle:** On-change

**Status:** Accepted *(design-only per § 9; the implementing PR ships the validator + backfill)*
**Date:** 2026-06-26 (filed + accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Promoting OPP: [OPP-0050](../opportunities/OPP-0050-module-stability-tiers-parity.md) — `proposed`; this PRD ratifies the v1 wedge and flips OPP-0050 → `accepted` in the same commit.
- Sibling validator precedent: [`validate-list-completeness.sh`](../../platform/validators/validate-list-completeness.sh) and [`validate-catalog-counts.sh`](../../platform/validators/validate-catalog-counts.sh) — the **always-on, structural, catalog-wide** validator shape this follows (not a predict-clean module-gated overlay validator). It enumerates every module on disk and asserts a property, like list-completeness does.
- Related operating principles:
  - [§ 10 Classify Claims Before Enforcing Them](../operating-principles.md#10-classify-claims-before-enforcing-them) — stability extends § 10's honesty discipline from *per-claim* enforcement classification to *per-module* readiness classification. Same spirit: declare the truth, don't overclaim.
  - [§ 5 Self-Governance](../operating-principles.md#5-self-governance) — the platform's blanket "alpha" (`harness.manifest.yaml: maturity: platform`) becomes a granular, queryable per-module claim.
  - [§ 9 Split Design from Implementation](../operating-principles.md#9-split-design-from-implementation) — this PRD is the design; the implementing PR ships the validator + the 57-module backfill.
- Distinct from: trust tier (`validate-trust-tier.sh`, *risk/autonomy*) and the manifest-level `maturity: platform` + digital-twin consumer twin-maturity (*project*-maturity). Stability is a third, independent axis: *module battle-testedness*.

## Overview

The catalog carries uniform structural metadata (six fields in 57/57 module.yaml)
and real anti-sprawl discipline (the § 12 inclusion test; candidate-stub promotion),
but **no signal of how proven a given module is**. `stability` is present in **0/57**
modules. A consumer composing a manifest cannot tell `management/privacy-by-design`
(dedicated validator, shipped, dogfooded) from a one-off scaffold.

This PRD specifies a v1 **`stability` field** on every module plus an **always-on
structural validator** that asserts the field is present and from a fixed enum:

```yaml
stability: stable        # one of: experimental | beta | stable
```

The validator (`validate-module-stability.sh`) enumerates every `module.yaml` under
`platform/` and fails if any omits `stability` or declares a value outside the enum.
It is **not predict-clean** — like `validate-list-completeness`, it is a catalog
structural check that runs against the harness's own modules, so the v1 implementation
**backfills all 57 modules** against the rubric below. The validator checks
*presence + enum membership only*, never the *correctness* of the human judgment
(honesty is an authoring act, as § 10 classification is).

## The stability rubric

The implementing PR assigns each module a tier against this rubric (the validator
does not enforce the rubric — it is authoring guidance, documented in
`extending-the-harness.md` and the validator `--help`):

| Tier | Meaning | Test |
|------|---------|------|
| **`stable`** | Proven; safe to build on | Shipped **and** has machine enforcement (a dedicated validator or a companion rule) **and** is foundational (kernel) **or** has ≥ 1 real dogfood / consumer instance |
| **`beta`** | Shipped and usable, not yet battle-tested | Shipped and structurally complete, but enforcement is companion-only/thin **or** it has no real consumer instance yet |
| **`experimental`** | Scaffold / speculative / niche | Single speculative consumer, a thin or illustrative overlay, or a niche stack with no production use |

The rubric is deliberately coarse (three tiers). Per-module rationale is not
required in the field, but the backfill PR's description records any non-obvious
calls.

## Goals & Non-Goals

**Goals:**

- Ship `platform/validators/validate-module-stability.sh` — Bash 3.2 compatible,
  shellcheck-clean at warning severity, 3-state exit. Enumerates `module.yaml`
  files under `platform/`; asserts each declares `stability` ∈
  `{experimental, beta, stable}`; lists every offender on failure. A
  `--scan-file <module.yaml>` seam validates one file without enumerating, for
  fixture tests.
- Backfill `stability:` into all **57** module.yaml files against the rubric.
- Document the rubric in `platform/workflow/extending-the-harness.md` (module-author
  guide) and the validator `--help`.
- Surface stability in the `harness-onboarding` skill catalog (a column / note) and
  add **one honest stack-parity note** (`stacks/` is 3/4 JS-family:
  `coffeescript`, `node-javascript`, `node-typescript` + `python`).
- Wire the validator into the chain: `kernel/base` validators list,
  `.github/workflows/harness.yml`, `AGENTS.md` run-order, `harness-governance`
  SKILL.md chain + signature note, `validators/README.md`, root `README.md` table.
  Validator count **19 → 20** reconciled at every documented site.
- Integration test: `TestValidateModuleStability` + the `VALIDATOR_SCRIPTS` help row.
- One paired distillation observation.

**Non-Goals (deferred):**

- **Behavior-gating on stability.** v1 does not warn or block when a consumer
  activates an `experimental` module. The field is informational + asserted-present;
  acting on it is a follow-up.
- **A module deprecation / lifecycle policy.** A `deprecated` enum value is **not**
  added in v1 — that seeds a separate process concern (a follow-up OPP), and adding
  it now would imply a lifecycle the harness hasn't designed. v1 enum is exactly
  three values.
- **Stack-parity build-out.** Building PHP/Go/etc. stacks is OPP-0011/0012 territory;
  v1 ships only the honest *note* about the current skew.
- **Auto-inferred stability.** No derivation from validator-presence/age — declared
  only, to avoid laundering unearned confidence.
- **A new operating-principle section.** Stability is an application of § 10, not a
  new principle; no § 13 here.

## §10 Claim Classification

| Claim ID | Claim | Current | After v1 |
|----------|-------|---------|----------|
| C-STAB-1 | Every catalog module declares its readiness tier | Asserted-only (implicit, 0/57) | **Enforced** — `validate-module-stability.sh` blocks a missing/invalid `stability` |
| C-STAB-2 | A module's readiness is distinct from its risk tier and its per-claim enforcement | Asserted-only | **Asserted (documented)** — the rubric + cross-refs make the three-axis distinction explicit; not machine-enforced (it is a conceptual boundary) |

**Not converted:** whether a given module's *assigned tier is correct* remains a
human judgment (Asserted-only) — the validator checks presence + enum, never
correctness, exactly as § 10 classification is authored, not computed.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001 | `validate-module-stability.sh` ships | Bash 3.2, shellcheck-clean, 3-state exit. Default mode enumerates `module.yaml` under `platform/` and exits 1 listing every module whose `stability` is missing or not in `{experimental,beta,stable}`; exits 0 when all valid; exit 2 on usage error. |
| FR-002 | `--scan-file <module.yaml>` seam | Validates a single module file without enumeration (no git/manifest needed), for fixtures. |
| FR-003 | All 57 modules backfilled | Every `platform/**/module.yaml` declares `stability` from the enum, assigned against the rubric. |
| FR-004 | Rubric documented | The three-tier rubric appears in `platform/workflow/extending-the-harness.md` and the validator `--help`. |
| FR-005 | Always-on wiring + count bump | Added to `kernel/base` validators, `harness.yml`, `AGENTS.md`, `harness-governance` chain + signature note, `validators/README.md`, root `README.md` table. `validate-catalog-counts.sh` validator count 19 → 20 at every documented site. |
| FR-006 | Onboarding + parity surfacing | `harness-onboarding` SKILL.md surfaces stability; one stack-parity note records the JS-family skew. |
| FR-007 | Integration tests | `TestValidateModuleStability` (clean pass; missing-field fail; out-of-enum fail; `--scan-file`) + the help-coverage `VALIDATOR_SCRIPTS` row. |

### Out of Scope

| Feature | Reason | Revisit |
|---------|--------|---------|
| Behavior-gating on `experimental` | v1 is declare + assert-present | Follow-up OPP once the field exists |
| `deprecated` enum value + lifecycle policy | Separate process change-class (§ 7) | A module-lifecycle OPP |
| Stack build-out (PHP/Go/…) | OPP-0011/0012 | Those OPPs |

## Technical Constraints

- **Always-on**, not module-gated — every harnessed project (and the harness itself)
  runs it; the `disabledValidations` escape hatch is the opt-out.
- Bash 3.2 compatible (no `mapfile`), shellcheck-clean at warning severity,
  3-state exit; Ruby `YAML.safe_load` for the field parse (same pattern as the other
  validators).
- Enum is a frozen 3-value set in v1; extending it is a PR that also updates the
  rubric doc.

## CI/CD Gates

- Full validator chain (20 validators) green on the implementing PR — which means
  the backfill must be complete, since the new validator runs against the harness's
  own 57 modules.
- `validate-catalog-counts.sh` green after the 19 → 20 bump.
- Integration tests added; markdownlint + shellcheck clean.

## Acceptance Criteria for OPP-0050 → `accepted`

This PRD flips OPP-0050 `proposed → accepted` on acceptance. Implementation
completes when FR-001…FR-007 merge and the harness's own CI passes with all 57
modules declaring a valid `stability`.

## Versioning Implications

Additive: a new optional-at-the-schema-level but enforced-in-practice field, a new
always-on validator (count 19 → 20), no breaking change. Lands in the next minor.
