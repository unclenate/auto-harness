<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0025: Work-Package Lane Contract (`management/work-package`)

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-15 | **Review Cycle:** On-change

**Status:** Accepted
**Date:** 2026-06-15
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- **Origin OPP:** [OPP-0046](../opportunities/OPP-0046-parallel-multi-agent-work-package-lane-contract.md)
  — Parallel Multi-Agent Work-Package Lane Contract (triaged from issues #121 +
  #122). This PRD is a **partial promotion**: it promotes the **lane (scope)
  wedge**; OPP-0046's deferred sub-components (cross-agent memory-bus auto-load,
  interface-first contract-stub, project-specific rules) stay `proposed`.
- **Adopts as a deferred phase:** [OPP-0047](../opportunities/OPP-0047-delivery-cost-unit-economics-governance.md)
  — the **economic** contract (`tokenBudget` + delivery-cost record) is folded in
  as this module's **v2 phase**, not a separate module. Lane = scope contract,
  cost record = economic contract; one governance object, staged depth.
- **Structural precedent:** [PRD-0023](PRD-0023-digital-twin-scenario-runtime-overlay.md)
  (the module-gated, predict-clean validator shape) and the deep-domain wedge PRDs
  (PRD-0017/0019/0024) for the design-then-implement split.
- **Related operating principles:**
  - [§ 9 Split Design from Implementation](../operating-principles.md#9-split-design-from-implementation)
    — this PRD ships the design contract; the implementing PR ships the module,
    validator, templates, and propagation.
  - [§ 10 Classify Claims Before Enforcing Them](../operating-principles.md#10-classify-claims-before-enforcing-them)
    — see §10 Claim Classification below.

## Overview

auto-harness is now a live multi-agent workspace — Claude, Codex, and Gemini run
concurrent work-packages in isolated git worktrees — but it has **no
machine-checkable governance for parallel execution**. The work-package boundary
lives in prose, so agents reconcile the tension between a "hard file list,"
acceptance criteria, named symbol locations, worktree setup, and per-tool defaults
by hand and inconsistently (the field failures recorded in issues #121/#122).

This PRD specifies a thin **v1 wedge**: a new `management/work-package` module
providing a **machine-readable lane contract** on a work-package spec, a
**lane-vs-diff validator** that checks an agent's actual changes against its
declared lane, an **idempotent worktree runbook**, and a **conflict-protocol**
onboarding rule. This is the multi-agent analog of the module declare-then-enforce
contract (`sensitivePaths` + `companionRules` + `validate-companions`): declare a
boundary, then mechanically check work against it, leaving judgment to review.

v1 is **design-only** per § 9; the implementing PR builds the scaffolding. The
module is the single home for the work-package governance object; **v1 governs
scope** (the lane), and the **economic contract** (OPP-0047) is the module's
deferred v2 phase.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering (in the implementing PR):

- Ship `platform/profiles/management/work-package/` (`module.yaml` + `README.md`),
  `type: management`, default-off opt-in.
- Define a **lane schema** — a declarative block on a work-package spec with:
  `branch`, `base`, `prMode` (`draft`|`ready`), `allowedFiles` (globs),
  `readOnlyFiles`, `requiredChecks` (commands that must pass), `forbiddenCommands`.
- Ship **`validate-lane-integrity.sh`** — a module-gated validator that checks a
  branch's actual diff against its declared lane (changed files ⊆ `allowedFiles`;
  `readOnlyFiles` untouched; schema well-formed). Predict-clean on the harness's
  own CI (no lane declared → no-op), mirroring the digital-twin validators.
- Ship a **work-package lane template** under `platform/templates/work-package/`.
- Add the **conflict-protocol** rule to agent onboarding: *if an acceptance
  criterion or named symbol requires a file outside `allowedFiles`, stop and
  report — never silently honor the lane too narrowly or silently expand it.*
- Ship an **idempotent worktree runbook** (workflow doc): normalized
  `git worktree add -b <branch> <path> <base>`; never mutate the shared checkout's
  branch state; re-attach if the worktree exists; the sibling-worktree validator
  fallback (run validators from the main checkout's `platform/` when `.harness` is
  empty in a sibling worktree).
- Discoverability + a sample composition + one diagram + catalog-count propagation.
- Pass the full validator suite with the new module + validator on disk
  (predict-clean: the harness does not activate the module).
- Promote **OPP-0046 → accepted (partial promotion)** in this PRD's cycle.

**Non-Goals** — explicitly deferred:

- **The economic contract** — `tokenBudget` on the lane + a delivery-cost record
  (OPP-0047). This is the module's **v2 phase**, not a separate module.
- **Cross-agent memory-bus auto-load** (OPP-0046 deferred) — loading
  `shared-observations.md` into the dispatching agent's context.
- **Interface-first contract-stub phase** (OPP-0046 / issue #122).
- **Session-level / real-time enforcement.** v1 is **PR-boundary** only (an agent
  can still go out-of-lane mid-session; the validator catches it at PR time),
  mirroring trust-tier v1's PR-boundary scope.
- **Project-specific execution rules** (e.g. the symlink-`node_modules` constraint)
  — those belong in a consumer's `shared-observations.md`, not the platform.

## §10 Claim Classification

Per the [§10 operating principle](../operating-principles.md#10-classify-claims-before-enforcing-them):

| Claim | Class | Mechanism |
|-------|-------|-----------|
| A branch's changed files stay within its declared `allowedFiles` lane | Enforced | `validate-lane-integrity.sh` (diff vs lane) |
| `readOnlyFiles` are not modified | Enforced | `validate-lane-integrity.sh` |
| The lane schema is present and well-formed when the module is active | Enforced | `validate-lane-integrity.sh` (schema check) + `validate-required-artifacts.sh` |
| An out-of-lane symbol/criterion triggers **stop-and-report**, not silent expansion | Asserted-only | conflict-protocol onboarding rule + review gate |
| Worktrees are created idempotently without mutating shared checkout state | Asserted-only | the idempotent worktree runbook |
| `forbiddenCommands` are not run | Asserted-only | declared in the lane; not mechanically verifiable from a diff (review / optional CI-log scan) |
| `prMode` (`draft`/`ready`) is honored by the publishing agent | Asserted-only | declared in the lane; the agent reads it (normalizes the Codex-defaults-to-draft variance) |

**Claims explicitly NOT converted by v1** (remain Asserted-only or deferred):

- **Token spend stays within budget.** Deferred to the module's v2 economic phase
  (OPP-0047); v1 has no `tokenBudget`.
- **The work is semantically correct/complete.** A review-gate concern; the lane
  governs *where* an agent may write, not *whether* the change is right.
- **Cross-agent constraints propagate automatically.** The memory-bus auto-load is
  deferred; v1 relies on the dispatching agent reading `shared-observations.md`.

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Harness maintainer (multi-agent dispatcher) | Runs Claude + Codex + Gemini on concurrent work-packages | A machine-checkable lane so an executing agent's actual diff can be verified against the scope it was given. |
| Executing agent (any LLM) | Builds a single work-package in an isolated worktree | An unambiguous, lintable boundary + a stop-and-report rule for out-of-lane needs, instead of inferring scope from prose. |
| Consumer maintainer running multi-agent delivery | A team adopting auto-harness for parallel agentic builds | A reusable lane contract + worktree runbook + validator, opt-in via the module. |
| Future PRD author (v2) | Promoting the economic phase (OPP-0047) | The lane as a stable *unit of delivery* to attach `tokenBudget` + cost records to. |

## User Stories

- As a **dispatcher**, I want each work-package to declare a lane (`allowedFiles`,
  `requiredChecks`, `prMode`), so an executing agent's PR can be linted against the
  scope I assigned rather than trusted.
- As an **executing agent**, I want a rule that says *stop and report* when a
  required symbol lives outside `allowedFiles`, so I don't silently expand my lane
  or honor it too narrowly (the ACP `CAPABILITY_RULES` failure in #121).
- As an **executing agent**, I want a normalized worktree command
  (`git worktree add -b <branch> <path> <base>`), so cross-LLM worktree-init
  variance (#122) stops breaking setups.
- As a **harness maintainer**, I want `validate-lane-integrity.sh` to be
  module-gated and predict-clean, so adding it does not perturb the harness's own
  CI when no lane is declared.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | `management/work-package` module scaffolding | `module.yaml` + `README.md`; `type: management`; default-off opt-in; required artifact = the lane spec; sensitive paths + companion rule on the lane spec. | Single home for the WP governance object. |
| FR-002 | Lane schema definition | The lane block declares `branch`, `base`, `prMode` (`draft`\|`ready`), `allowedFiles`, `readOnlyFiles`, `requiredChecks`, `forbiddenCommands`. Documented in the README + template. | From issue #121's proposed schema. |
| FR-003 | `validate-lane-integrity.sh` | Module-gated validator: given a lane spec + a base ref, asserts changed files ⊆ `allowedFiles`, `readOnlyFiles` unchanged, and the lane schema is well-formed. Exit-code contract documented. Predict-clean (no-op when no lane present). | The Enforced claim. Mirrors the digital-twin module-gated shape. |
| FR-004 | Work-package lane template | `platform/templates/work-package/lane.md` (or `.yaml`) carrying the lane block + the conflict-protocol reminder; tokenized SPDX header. | — |
| FR-005 | Conflict-protocol onboarding rule | `platform/skills/harness-onboarding/SKILL.md` (and/or agent packs) state the stop-and-report rule for out-of-`allowedFiles` work. | Asserted-only. |
| FR-006 | Idempotent worktree runbook | A workflow doc with the normalized worktree commands, the no-shared-state-mutation rule, and the sibling-worktree validator fallback. | Mirrors `consumer-upgrade-runbook.md` as a workflow-doc deliverable. |
| FR-007 | Discoverability + composition + diagram + counts | Module in SUMMARY / README module table / onboarding skill / discovery-to-composition; a sample composition; one diagram; all catalog counts bumped. | Companion-rule propagation per `CLAUDE.md`. |
| FR-008 | Full validator suite passes | All validators (chain grows 17→18 with `validate-lane-integrity.sh`) exit 0 with the module on disk; harness does not activate it (predict-clean). | New validator is module-gated. |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-S01 | Distillation observation | Capture the wedge's reusable insight (the lane as the multi-agent re-targeting of the module contract; the combine-home-stage-depth promotion of two coupled OPPs). | Satisfies PRD-0004 distillation on the implementing PR's new module manifest. |
| FR-S02 | "When to activate" + dogfood note | README names when a consumer activates the module and notes the open dogfood question (should auto-harness declare lanes for its own `codex/*` multi-agent branches?). | — |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| `tokenBudget` + delivery-cost record | The module's v2 economic phase (OPP-0047) | After v1 lane wedge ships |
| Cross-agent memory-bus auto-load | OPP-0046 deferred sub-component | Separate promotion |
| Real-time / session-level enforcement | Requires AI-client hooks; v1 is PR-boundary | v2+ |
| `forbiddenCommands` hard enforcement | Not verifiable from a diff | If a CI command-log surface appears |

## Implementation Deferral

Per § 9, this PRD ships the design contract; the implementing PR adds the module,
validator, template, runbook, discoverability, diagram, composition, counts, and
the distillation observation.

| Deferred implementation | Deferred to | Why |
|-------------------------|-------------|-----|
| Module YAML + README, `validate-lane-integrity.sh`, lane template, worktree runbook | Implementing PR (Phase 2) | Design-first per § 9 |
| Discoverability + diagram + composition + counts | Implementing PR (Phase 2) | Same |
| Economic phase (`tokenBudget` + cost record) | A v2 PRD (OPP-0047) | Lane must exist as the cost unit first |

## Technical Constraints

- **Module type: `management`** — accepted by `validate-module-graph.sh`.
- **Module-gated, predict-clean validator** — `validate-lane-integrity.sh` no-ops
  when no lane spec is present, so the harness's own CI stays green without the
  module activated (the digital-twin validator pattern).
- **PR-boundary enforcement only** in v1 (no real-time hooks).
- **Per-module sensitive-path self-coverage** — the module's `sensitivePaths` must
  be self-covered by its own `companionRules.triggerPaths`.
- **Bash 3.2 + system Ruby**; **SPDX dual-license headers**; `UncleNate@gmail.com`.

## CI/CD Gates

| Gate | Required? | Notes |
|------|-----------|-------|
| markdownlint + shellcheck | Yes | New `.md` + the new `.sh` validator |
| Full validator suite (17→18) exits 0 | Yes | Predict-clean on the harness's own CI |
| `validate-catalog-counts.sh` after bumps | Yes | Modules + validators (17→18) + templates + diagrams + compositions |
| `validate-list-completeness.sh` | Yes | New module + validator + template-subdir indexed |
| `validate-companions.sh` (PR-diff mode) | Yes | The new module YAML triggers the distillation + governance satisfiers in the same PR |
| Change-log updated | Yes | One entry per PR |

## Success Metrics

| KPI | Target | How measured |
|-----|--------|-------------|
| Dogfood pass rate at implementing PR | 100% — full validator suite passes with the module present, not activated | Implementing PR CI |
| Lane-vs-diff detection | A deliberately out-of-lane change in a sample composition's lane is flagged by `validate-lane-integrity.sh` | Implementing PR test |
| Worktree-init variance closed | The runbook's command is the one referenced in dispatch prompts | Spot-check |
| Schema completeness | The lane template carries all seven fields | Template review |

## Dependencies

- `platform/validators/lib/harness_registry.rb` — module enumeration (existing).
- `platform/skills/harness-onboarding/SKILL.md` — the conflict-protocol rule host.
- The digital-twin module-gated validators — the predict-clean validator precedent.
- Bash 3.2 + system Ruby.

## Verification

The wedge is verified, not asserted:

- The full validator suite passes with the module + `validate-lane-integrity.sh`
  on disk; the harness does not activate the module (predict-clean).
- A sample composition with a deliberately out-of-lane change is flagged by the
  validator (the Enforced claim demonstrated).
- markdownlint + shellcheck pass on all new files.

## Open Questions

- [ ] **Lane-spec home** — frontmatter on a work-package spec, a sibling YAML, or
  a dedicated section? **Bias: a fenced YAML block on the WP spec** (issue #121's
  shape), so prose and lane live together.
- [ ] **How `validate-lane-integrity.sh` obtains the diff + lane** — base-ref arg
  like the diff-mode validators (`. <base>`) + a WP-spec path. **Bias: mirror the
  `validate-companions.sh` diff-mode interface.**
- [ ] **`forbiddenCommands` enforcement** — declare-only + review, or an optional
  CI-log scan. **Bias: declare-only in v1 (Asserted-only); revisit if a command-log
  surface exists.**
- [ ] **Dogfood** — should auto-harness declare lanes for its own `codex/*` /
  multi-agent branches? **Bias: yes, as a fast-follow once v1 ships — it would make
  the harness govern its own multi-agent development.**
- [ ] **Worktree-runbook home** — a new `platform/workflow/` doc vs. a section in
  an existing one. **Bias: a new dedicated workflow doc, mirroring
  `consumer-upgrade-runbook.md`.**
- [ ] **PRD / diagram / validator-count numbers** — re-derive next-free against
  `main` at implementation time (maintainer/Codex parallel work may have moved them).
