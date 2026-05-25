<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0019 — Binary-Eval Quality-Gate as a Testing Posture

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-24
**Last Updated:** 2026-05-24
**Confidence:** high

---

## Thesis

`management/testing-standard` is **percentage-coverage shaped**: its
required artifacts (`docs/testing/test-strategy.md`,
`docs/testing/coverage-thresholds.md`) express unit/integration coverage
percentages and a testing pyramid. A growing class of AI-native projects
gates quality on **binary-graded evaluation of model/agent outputs**
instead — and the existing module cannot express grader thresholds, an
eval task taxonomy, or the synthetic-fixture discipline that this style
requires.

Add an **eval-gated testing posture** — initial bias: a variant or sibling
overlay to `testing-standard` (`management/testing-standard` gaining an
`eval-gate` mode, or a sibling `management/eval-gated-testing`) — whose
artifacts express: grader-threshold definitions, the eval task taxonomy
(`basic` / `edge` / `should-not-trigger` / domain-override), synthetic
fixture rules, and the spec-gate-in-CI contract.

This is the **consumer-facing posture** (what a project declares about how
its quality is gated). The **harness-side capability** to actually run such
gates — wiring Waza / GAIA / Inspect into the toolchain — is OPP-0020.

## Origin / Evidence

- **Consumer project: Tula (`github.com/unclenate/tula` fork).** Brownfield
  onboarding 2026-05-24; gap analysis §TG2. Each skill ships
  `evals/<skill>/eval.yaml` (metric + threshold + graders), a `tasks/` set,
  and synthetic `fixtures/`. The task taxonomy encodes *intent* coverage,
  not line coverage: `basic-usage`, `edge-case`, `should-not-trigger`
  (anti-trigger), and domain cases like `triage-override`. Graders include
  `not_empty` and `under_word_budget`; thresholds like
  `task_completion ≥ 0.8` gate merge. `redact_phi_for_eval.mjs` enforces
  synthetic-fixtures-only.
- **External signal — eval-as-unit-test is an industry pattern.** Microsoft
  Foundry frames agent evaluators "as unit tests with binary Pass/Fail,"
  covering both *system* (final outcome) and *process* (step-by-step tool
  use) evaluation; [`microsoft/waza`](https://github.com/microsoft/waza)
  operationalizes this as a CI spec gate. Tula's suite is shaped to publish
  into that lifecycle.
- **Why `testing-standard` does not fit as-is.** `coverage-thresholds.md`
  has no slot for grader definitions, eval task classes, or the
  fixtures-must-be-synthetic rule. Forcing an eval-gated project to fill a
  percentage-coverage template produces a misleading artifact.
- **Why OPP-0015 (regulated test kits) is a different pattern.** Inferno-style
  external conformance kits are third-party suites invoked by exit code;
  binary-LLM-eval gates are authored *alongside the unit under test* and
  grade model output. Both are "non-percentage gates" but their ownership,
  authorship, and runtime differ.

## Why Now

- **Two halves of one production model.** Pairs with OPP-0018 — the
  skill-pack topology and its eval gate are designed together or a seam
  appears later.
- **AI-native projects increasingly gate on evals, not coverage.** The
  harness will meet more of them; a posture that only knows percentages
  mis-describes a rising share of consumers.
- **Low marginal cost.** Likely a mode-flag + one artifact template, not a
  new module family — cheap to add, immediately useful.

## Risks / Open Questions

- **Variant vs sibling module.** A `mode: coverage | eval-gate` field on
  `testing-standard` keeps the catalog compact (mirrors OPP-0012's
  `engine:` sub-field approach for relational-SQL); a sibling module is
  cleaner if the artifact sets diverge enough. PRD decides; bias toward the
  mode-field to avoid catalog sprawl.
- **Threshold gaming.** Binary graders can be satisfied by trivial outputs
  (`not_empty` passes on a stub). The posture's reviewGates must require
  that graders be *meaningful*, not just present — analogous to the
  trust-tier reviewGate that rejects "everything is Tier 2" placeholders.
- **Non-determinism.** LLM-output evals are flaky in a way coverage numbers
  are not. The artifact should require a stated policy on flake tolerance
  (pass-rate over N runs, temperature pinning) so a green gate means
  something.
- **Overlap with OPP-0020.** This OPP is the *consumer declaration*; OPP-0020
  is the *harness capability to execute it*. Keep the boundary explicit so
  the two don't merge into an over-scoped single change.

## Disposition

<!-- Empty: status is proposed -->

## Promotion

<!-- Empty: not yet accepted -->

## Related

- Gap analysis source: consumer project (`tula`) at
  `docs/knowledge/harness-coverage-gap-analysis.md` §TG2
- Pairs with: [OPP-0018](OPP-0018-architecture-eval-gated-skill-pack.md)
  (the skill pack the gate protects), [OPP-0020](OPP-0020-evaluation-tooling-in-harness-toolchain.md)
  (harness-side eval tooling)
- Adjacent (different gate pattern): [OPP-0015](OPP-0015-regulated-compliance-test-kits.md)
  (external regulator conformance kits)
- Existing module extended: `platform/profiles/management/testing-standard/module.yaml`
