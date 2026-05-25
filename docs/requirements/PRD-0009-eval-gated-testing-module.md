<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0009: Eval-Gated Testing Module

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-05-25 | **Review Cycle:** On-change

**Status:** Accepted *(v1 module scaffolded; release marker v0.5.2)*
**Date:** 2026-05-25 (filed) | 2026-05-25 (accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Promotes: [OPP-0019](../opportunities/OPP-0019-eval-gated-testing-posture.md) — `proposed` → `accepted`
- Pairs with: [PRD-0008](PRD-0008-agent-skill-pack-architecture.md) (the skill pack the gate protects)
- Related (deferred, harness-side): [OPP-0020](../opportunities/OPP-0020-evaluation-tooling-in-harness-toolchain.md) — invoking Waza / GAIA / Inspect from the harness toolchain
- Sibling module: `platform/profiles/management/testing-standard/` (percentage-coverage shaped)
- Evidence: `tula:docs/knowledge/harness-coverage-gap-analysis.md` §TG2

## Overview

`management/testing-standard` is percentage-coverage shaped and cannot
express the quality model of AI-native projects that gate on **binary-graded
evaluation of model/agent outputs**. OPP-0019 surfaced this from Tula's Waza
suite (per-skill `eval.yaml`, graders, `task_completion ≥ 0.8`, a
`basic/edge/should-not-trigger/triage-override` task taxonomy, synthetic
fixtures via `redact_phi_for_eval.mjs`).

This PRD specifies a v1 **sibling** module `management/eval-gated-testing`
with one required artifact (an eval strategy), an optional threshold split-out,
sensitive-path coverage of eval suites, and a grader-threshold companion rule.

## Goals & Non-Goals

**Goals**

- Ship `platform/profiles/management/eval-gated-testing/{module.yaml,README.md}`.
- Require `docs/testing/eval-strategy.md`; provide
  `platform/templates/testing/eval-strategy.md`.
- Bind eval-strategy / grader-threshold changes to change-log / ADR / PRD via
  a companion rule.
- Review gates for synthetic fixtures, meaningful graders, and a stated flake
  policy.
- Coexist with `testing-standard` (`conflictsWith: []`).

**Non-Goals**

- **A `mode: eval-gate` field on `testing-standard`.** OPP-0019 biased toward
  this to avoid catalog sprawl, but mode-conditional required artifacts would
  require new conditional logic in `validate-required-artifacts.sh`. A
  self-contained sibling module needs **zero validator changes** and does not
  risk existing `testing-standard` consumers. The mode-field convergence is
  recorded as future work, contingent on the validator gaining
  conditional-artifact support.
- **Running the evals.** Invoking Waza / GAIA / Inspect from the harness
  toolchain is OPP-0020 (deferred). This module is the consumer *posture*.
- **Mandating a framework.** The strategy names the runner; the module is
  tool-neutral.

## Functional Requirements

### FR-001 — Module definition

`management/eval-gated-testing` `module.yaml`: `type: management`,
`dependsOn: [kernel/base]`, `conflictsWith: []`, `requiredArtifacts:
[docs/testing/eval-strategy.md]`, optional `docs/testing/grader-thresholds.md`.

### FR-002 — Sensitive paths

`^evals/`, the strategy/threshold docs, `eval\.yaml$`, `\.waza\.`.

### FR-003 — Threshold companion rule

Changes to `docs/testing/eval-strategy.md` or `grader-thresholds.md` require
change-log, ADR, or PRD. `humanReview` rejects trivially-passable graders and
silent threshold reductions; agents may not lower a threshold without human
approval.

### FR-004 — Eval-strategy template

`platform/templates/testing/eval-strategy.md` (tokenized header; sections for
scope, runner/CI, graders, thresholds, the task taxonomy, synthetic-fixture
policy, flake policy).

### FR-005 — Review gates

Named grader set + thresholds + taxonomy; synthetic-only fixtures; meaningful
graders; stated flake policy; coverage discipline still applies where
deterministic code exists.

### FR-006 — Catalog propagation

SUMMARY Module Library (Management); `harness-onboarding` SKILL.md management
catalog; `discovery-to-composition` Step 6 rubric row. Counts: shared module
+1; `templates` +1.

## Acceptance Criteria for OPP-0019 → `accepted`

1. This PRD `Accepted`.
2. FR-001…FR-006 merged.
3. Full validator chain green on the PR.
4. Module reachable from the `harness-onboarding` skill catalog and named as a
   sibling to `testing-standard` in the rubric.

## Out of Scope

- The `mode:`-field convergence on `testing-standard` (future work; needs
  conditional-artifact validator support).
- Harness-side eval execution (OPP-0020).

## Risks

- **Catalog sprawl.** A sibling module is one more management overlay. Accepted
  tradeoff: it is self-contained and zero-validator-risk, and the README names
  the convergence path so the sprawl is intentional, not accidental.
- **Grader gaming.** Mitigated by the meaningful-grader review gate.

## Open Questions Resolved

- **Variant vs sibling?** → **sibling**, for zero validator-logic risk in v1
  (diverges from the OPP's mode-field bias, with rationale).
- **One artifact or two?** → one required (`eval-strategy.md`), thresholds
  optionally split out when the doc grows. Mirrors how a small project keeps
  strategy + thresholds together.

## Versioning Implications

Module ships at `1.0.0`. Counts bump within the v0.5.2 batch. Release marker:
**v0.5.2**.
