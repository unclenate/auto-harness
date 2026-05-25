<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Management Overlay: Eval-Gated Testing

## What this module adds

This overlay governs projects whose **primary quality gate is binary-graded
evaluation of model or agent outputs** rather than line/branch coverage. It
is the sibling of `management/testing-standard` (which is percentage-coverage
shaped). A project may activate either, or both — coverage for deterministic
code, eval gates for model/agent behavior.

It turns the eval discipline into a reviewable contract:

- **An eval strategy** (`docs/testing/eval-strategy.md`) naming the runner,
  the grader set, the pass thresholds, the task taxonomy, and the flake
  policy.
- **A grader-threshold companion rule** — lowering a threshold or removing an
  anti-trigger case requires a change-log entry, ADR, or PRD.
- **Review gates** that reject trivially-passable graders and non-synthetic
  fixtures.

## When to activate

Activate `management/eval-gated-testing` when:

- Quality is gated on whether a model/agent output *does the right thing*
  (task adherence, format, safety) — graded Pass/Fail — rather than on code
  coverage.
- You run an eval suite in CI as a merge gate (Microsoft Waza, GAIA, UK-AISI
  Inspect, or a bespoke harness).
- Your test corpus is task fixtures with expected outcomes and graders, not
  unit assertions.

Pair it with `architectures/agent-skill-pack` when the thing being evaluated
is an authored skill pack: that module's companion rule asks each skill change
to be paired with a matching eval (or an authoring-conventions / ADR update);
this module governs what those evals must establish.

## What it requires

- **Required:** `docs/testing/eval-strategy.md` — the eval contract. Template
  at `platform/templates/testing/eval-strategy.md`.
- **Optional:** `docs/testing/grader-thresholds.md` — a split-out threshold
  table when the strategy doc grows large.
- **Companion rule:** changes to the eval strategy or grader thresholds
  require a change-log entry, an ADR, or a PRD.

## The task taxonomy this module expects

The strategy should classify eval tasks so reviewers can see what is and is
not covered:

| Class | Purpose |
|-------|---------|
| `basic-usage` | The skill/agent does the expected thing on the common input |
| `edge-case` | Boundary inputs, partial data, ambiguous requests |
| `should-not-trigger` | Anti-trigger: the skill/agent must *decline* or stay silent |
| domain-override | Domain-specific safety gates that must fire (e.g. a triage redirect that pre-empts normal output) |

The `should-not-trigger` and override classes are the ones that distinguish
an eval gate from a demo: they assert the system knows when *not* to act.

## What it does not do

- It does not replace `management/testing-standard`. Where deterministic code
  exists, coverage discipline still applies; this module governs the *eval*
  surface alongside it.
- It does not run the evals. The strategy names the runner; invoking that
  runner from the harness toolchain (Waza / GAIA / Inspect adapters) is a
  separate, harness-side concern, not part of this consumer-facing posture.
- It does not mandate a specific eval framework. The strategy declares which
  runner is in use; the module is tool-neutral.
