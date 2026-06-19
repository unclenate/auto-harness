<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Management Overlay: Work-Package Lane Contract

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay governs **parallel multi-agent delivery** — a dispatcher running
several agents (Claude, Codex, Gemini, …) on concurrent work-packages in
isolated git worktrees. It gives each work-package a **machine-checkable lane**:
which files an agent may write, which it must not touch, which checks must pass,
and how the PR is opened. It is a default-off, opt-in cross-cutting concern.

The lane is the **multi-agent re-targeting of the module declare-then-enforce
contract** (`sensitivePaths` + `companionRules` + `validate-companions`): declare
a boundary, then mechanically check the agent's actual diff against it, leaving
judgment to review. Where a module declares the boundary of a *capability*, a
lane declares the boundary of a single *dispatched task*.

## What This Overlay Requires

- **Required:** `docs/work-package/lane.md` — the forcing artifact. Carries a
  fenced ```yaml lane block declaring the seven lane fields (below) plus the
  prose that describes the work-package. Template at
  `platform/templates/work-package/`.

## Lane schema (the seven fields)

| Field | Type | Meaning |
|---|---|---|
| `branch` | string | The feature branch the work-package lands on. |
| `base` | string | The ref the branch is cut from and diffed against. |
| `prMode` | `draft` \| `ready` | How the publishing agent opens the PR (normalizes the Codex-defaults-to-draft variance). |
| `allowedFiles` | list of globs | The lane: every changed file must match at least one. |
| `readOnlyFiles` | list of globs | Files the agent may read but must not modify. |
| `requiredChecks` | list | Commands that must pass before the PR is ready. |
| `forbiddenCommands` | list | Commands the agent must not run (declare-only in v1). |

## Conflict protocol (stop-and-report)

> If an acceptance criterion or a named symbol requires a file **outside**
> `allowedFiles`, **stop and report** — never silently widen the lane to reach
> it, and never silently honor the lane too narrowly by skipping the criterion.
> The dispatcher resolves the tension by amending the lane (a reviewed change),
> not the executing agent on its own initiative.

This is the multi-agent analog of the trust-tier rule against finding a
lower-tier-looking workaround for a higher-tier effect.

## Enforcement

- **`validate-lane-integrity.sh`** — module-gated, predict-clean. When the
  module is active it reads the lane spec, asserts the schema is well-formed,
  diffs the branch against `base`, and fails if any changed file is outside
  `allowedFiles` or touches `readOnlyFiles`. When the module is **not** active
  (the default, including the harness's own CI) it is a no-op. A `--scan-file`
  mode checks an arbitrary lane spec — and, given an explicit changed-file list,
  the lane-vs-diff check — without git, for fixture-firing tests.
- **`validate-companions`** — a change to the lane spec requires a change-log
  entry or an ADR, so re-scoping a dispatched lane is a reviewed act.

## §10 claim classification

`allowedFiles` containment and `readOnlyFiles` immutability are **Enforced**
(the validator checks the diff). The stop-and-report rule, the idempotent
worktree runbook, `forbiddenCommands`, and `prMode` honoring are **Asserted-only**
in v1 — declared in the lane, honored by the agent, confirmed at review. The
economic contract (`tokenBudget` + a delivery-cost record, OPP-0047) is this
module's deferred **v2 phase**, not a separate module.

## Worktree runbook

Idempotent worktree setup, the no-shared-state-mutation rule, and the
sibling-worktree validator fallback live in
[`platform/workflow/work-package-worktree-runbook.md`](../../../workflow/work-package-worktree-runbook.md).

## Composition

Composes with any stack/architecture/domain — the lane governs *where* an agent
writes, orthogonal to *what* is being built. See
`platform/compositions/work-package-lane.yaml` for a sample.

## When to activate

Activate when you dispatch **two or more agents in parallel** on isolated
work-packages and want each agent's diff verifiable against the scope it was
given. Not needed for single-agent, single-branch development — there is no lane
to cross.

> **Open dogfood question (FR-S02).** Should auto-harness declare lanes for its
> own `codex/*` multi-agent branches, making the harness govern its own parallel
> development? Bias: yes, as a fast-follow once v1 ships.
