<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0004: Distillation Triggers — Cycle-End Trigger Machinery for Institutional Knowledge

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-05-21 | **Review Cycle:** On-change

**Status:** Proposed
**Date:** 2026-05-21
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Related OPP: [OPP-0004](../opportunities/OPP-0004-distillation-triggers.md) — `exploring`; this PRD is its promotion candidate
- Related ADRs:
  - [ADR-0010](../adr/ADR-0010-cheap-satisfiers-for-routine-governance.md) — companion-rule satisfiers scale with change weight; distillation triggers inherit the same gradient
  - [ADR-0012](../adr/ADR-0012-opportunity-capture-index-split.md) — file-boundaries-as-precision; informs how trigger artifacts are shaped
  - ADR-0001 (modular governance), ADR-0002 (knowledge-capture observation structure)
- Related observations:
  - `docs/knowledge/shared-observations.md` — *"Consumer-driven feedback has displaced the scheduled-review cadence as the active quality mechanism"* (2026-05-20) is the proximate motivator
  - `docs/operating-principles.md` § 7 — file boundaries express change-class boundaries; trigger artifacts respect the same discipline
- Other: `platform/profiles/management/knowledge-capture/` (gains the trigger companion rule); `platform/profiles/agents/claude-code/` (gains the active-hook adapter); `platform/workflow/` (gains the cycle-end ritual doc)

## Overview

Auto-harness today provides the *destinations* for distilled institutional
knowledge (`docs/knowledge/shared-observations.md`,
`docs/knowledge/distilled-learnings.md`, `docs/operating-principles.md`,
ADRs) and enforces *audit trails on edits* to those destinations through
companion rules. What it does not provide is the inverse — *triggers* that
fire when distillation-worthy work happens and demand a distillation trail
in return.

The result: distillation-worthy moments (ADRs landing, OPPs filed, modules
published, audit findings resolved) routinely pass through the validator
chain with no observation, no operating-principle edit, no learning
captured. The insights either end up cached as private agent memory and
lost to the project, or surface only when a human happens to prompt for
them. The harness's value proposition rests on durable institutional
knowledge; relying on maintainer-memory to trigger the durability layer is
a failure mode the harness should close.

This PRD specifies the v1 trigger machinery as three coordinated additions:

1. **A new companion rule on `management/knowledge-capture`** — when
   distillation-worthy signals appear in a PR diff (new ADR, new OPP,
   OPP status flip from `proposed`, new module), at least one knowledge
   destination must be touched in the same diff. Uses the existing
   `validate-companions.sh` machinery — no new validator code.
2. **A Claude Code session-end hook in `agents/claude-code`** — fires at
   `Stop` / `SessionEnd`, surfaces a structured "what's worth capturing?"
   prompt referencing the session's commit pattern. Does not auto-write;
   produces material for the human or agent to act on.
3. **A new workflow document** — `platform/workflow/cycle-end-distillation.md`
   defines what counts as a cycle end, what to check at each, and how the
   companion rule and hook compose. The aspirational "heartbeat with
   Knowledge Contribution step" prose scattered across module READMEs is
   replaced by cross-links to this workflow.

The three pieces ride mostly existing machinery and dogfood themselves on
the auto-harness repo immediately. Consumer projects with
`management/knowledge-capture` active inherit the companion rule by
default; projects also running `agents/claude-code` inherit the hook
adapter; the workflow doc applies universally.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- Add one companion rule to `management/knowledge-capture`'s `module.yaml`
  that requires a distillation trail when distillation-worthy signals
  appear in a PR diff.
- Define the trigger signal set (regex over diff paths only at v1 — no
  commit-message scanning) and the satisfier set (any of the knowledge
  destinations).
- Add a Claude Code `Stop` / `SessionEnd` hook configuration under
  `platform/agents/claude-code/` that emits a structured distillation
  prompt summarizing the session's commits.
- Ship the new workflow doc and cross-link to it from every module README
  that currently references the aspirational heartbeat pattern.
- Auto-harness dogfoods all three pieces on its own repo in the same PR
  that delivers them.

**Non-Goals** — outcomes explicitly out of scope:

- **Cursor / Copilot / Codex hook adapters** — *(the contract is
  agent-tool-agnostic but only the Claude Code adapter ships at v1;
  adding other tools without a real consumer driving the need would
  be speculative).*
- **Auto-writing of observations or operating-principle edits** — *(state
  changes to durable institutional knowledge are human decisions; a
  trigger prompts the human/agent to act, it does not act on their
  behalf).*
- **Commit-message-pattern detection (e.g., `closes #N`)** — *(file-diff
  patterns are sufficient signal for v1; adding commit-message parsing
  expands validator scope and creates a class of false-positives that
  doesn't justify itself yet).*
- **Auto-generated distilled-learnings entries** — *(distillation is
  curation; a trigger that auto-generates entries undermines the
  curation discipline the module exists to preserve).*
- **A new top-level `management/distillation-cadence` module** —
  *(distillation belongs to `knowledge-capture`; promoting to a new
  module before v1 success warrants would be premature abstraction).*
- **Retiring the scheduled-review cadence in `distilled-learnings.md`** —
  *(the cadence-vs-event-driven open question from OPP-0004 is
  deliberately left open at v1; running both in parallel for one
  cycle will produce data to settle the question with).*

> Distinction from `Functional Requirements > Out of Scope`: Non-Goals
> are *outcomes* ("we are not solving X for Y"); FR-Out-of-Scope is
> *features* ("we are not building feature Z").

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Solo maintainer | Owns a harness-governed project; produces distillation-worthy work in most sessions | A reliable trigger that fires at cycle boundaries so distillation doesn't depend on remembering to prompt for it |
| AI agent (Claude Code, etc.) | Operates in a harness-governed session; surfaces insights mid-work | A clear signal at session end naming what's worth capturing, and a structured prompt for filing it |
| Consumer-project contributor | Lands a PR that introduces an ADR or module in a project that has `knowledge-capture` active | CI feedback that names the missing distillation trail before merge, with clear guidance on satisfiers |
| Reviewer (human) | Reads a PR with a heavy artifact (ADR, OPP, module) | Confidence that the PR's learning has been captured somewhere durable, not just in the merged commit |

## User Stories

- As a solo maintainer, when I land an ADR, I want the harness to require
  a paired observation, operating-principle edit, or learning entry, so
  the architectural decision's *learning* doesn't get lost while its
  *artifact* lives forever.
- As an AI agent operating Claude Code, when my session ends, I want a
  structured prompt naming what's worth distilling from the session's
  commit pattern, so the maintainer-or-future-me has material to act on
  rather than a blank "anything worth capturing?" question.
- As a consumer-project contributor, when I file a PR that creates a new
  module, I want CI to flag the missing distillation trail at the same
  level of severity as a missing ADR, so the contract is unambiguous and
  the satisfier choice is mine.
- As a reviewer, when I open a PR introducing an OPP that flips to
  `accepted`, I want to see in the same diff what the project *learned*
  from accepting it (not just *what* it accepted), so the PRD-spawning
  contract carries learning forward, not just commitment.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | New companion rule on `management/knowledge-capture` | A new entry appended to `companionRules` in `platform/profiles/management/knowledge-capture/module.yaml` with `triggerPaths` covering the four signal classes (see FR-002) and `requiredAny` covering the three satisfier paths (see FR-003) | Uses existing `validate-companions.sh` machinery; no new validator code |
| FR-002 | Trigger signal set (regex over diff file paths) | The rule's `triggerPaths` matches **any** of: `^docs/adr/ADR-` (new or modified ADR), `^docs/opportunities/OPP-` (new or modified OPP), `^platform/profiles/.+/module\.yaml$` (new or modified module manifest), `^harness\.manifest\.yaml$` (active-module catalog change) | OR semantics inherent to `triggerPaths` |
| FR-003 | Satisfier set (knowledge destinations) | The rule's `requiredAny` matches **any** of: `^docs/knowledge/shared-observations\.md$`, `^docs/operating-principles\.md$`, `^docs/knowledge/distilled-learnings\.md$` | Note: `distilled-learnings.md` carries its own additional companion rule requiring a review-log satisfier; this PRD does not change that |
| FR-004 | `humanReview` text for the new rule | The rule's `humanReview` field documents the substantive check: the distillation trail entry must be *about the same work* the trigger artifact represents — not a tangential observation appended to satisfy the rule. Example phrasing: "Reviewers verify the distillation entry captures the learning *from* the trigger work (the ADR's rejected alternatives, the OPP's evidence pattern, the module's reusable insight) rather than an unrelated observation appended to pass the rule." | This is the equivalent of ADR-0012's `humanReview` discipline — text catches what the regex cannot |
| FR-005 | Companion-rule description names the intent | The rule's `description` explains in one paragraph what classes of work trigger distillation, what counts as a trail, and why this rule exists. Reads cleanly when stripped from surrounding YAML context (per operating-principles § 3 sub-bullet). | |
| FR-006 | Claude Code session-end hook configuration | A new hook entry under `platform/agents/claude-code/` (file path TBD by the claude-code module's hook conventions; reviewed against the existing `agents/claude-code` module structure) registered on `Stop` and/or `SessionEnd` events. The hook produces a structured prompt — see FR-007 — to stdout for the agent or user to consume. | Claude Code's hook surface; tool-specific |
| FR-007 | Hook prompt structure | The hook emits: (1) the session's commit shortlog scoped to the current branch, (2) any new ADR/OPP/module file paths created, (3) a question block asking what learning emerged worth capturing, (4) a link to `platform/workflow/cycle-end-distillation.md` for the decision criteria | Structured enough to act on without re-reading the workflow each time |
| FR-008 | Cycle-end distillation workflow doc | New file `platform/workflow/cycle-end-distillation.md` defines: (a) what counts as a cycle end (PR merge, ADR landed, OPP status flip from `proposed`, new module published, audit finding resolved), (b) decision tree for choosing which satisfier (observation vs operating-principle vs distilled-learning), (c) how the FR-001 companion rule and FR-006 hook compose, (d) anti-patterns (cargo-cult observations, distillation-fatigue) | Cross-references operating-principles § 7 |
| FR-009 | Heartbeat prose grounding | Every module README currently referencing the "heartbeat with Knowledge Contribution step" pattern (audit: `knowledge-capture/README.md` § Agent Behavior; `opportunity-capture/README.md` § Agent Behavior; possibly others) is updated to cross-link `platform/workflow/cycle-end-distillation.md`. The workflow doc carries the canonical pattern; module READMEs reference it. | Eliminates the documentation-as-aspiration problem |
| FR-010 | Auto-harness dogfoods all three pieces | The PR delivering this PRD includes: the companion rule landing in `knowledge-capture`, the hook configured in `agents/claude-code`, the workflow doc, and at least one *real* distillation-trail entry in `shared-observations.md` triggered by the new rule firing on this very PR (since this PR introduces a new module-config change). | The PR validates itself |
| FR-011 | Companion-rule humanReview uses full paths | Per operating-principles § 3, all path references in the new rule's `description` and `humanReview` are fully qualified (`docs/knowledge/shared-observations.md`, not `shared-observations.md`) | Lesson from PR #29 Copilot review |
| FR-012 | Change-log entry naming PRD-0004 | `docs/project/change-log.md` entry on the implementation PR satisfies the kernel/base + knowledge-capture audit-trail rules and links PRD-0004 + OPP-0004 | Self-governance dogfooding |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-013 | `harness-governance` skill cross-link | `platform/skills/harness-governance/SKILL.md` gains a section pointing at the cycle-end-distillation workflow so agents loading that skill discover the trigger contract | |
| FR-014 | Operating-principles cross-link | `docs/operating-principles.md` § 3 (Documentation as Part of the Change) gains a bullet referencing the cycle-end distillation contract as the trigger-side counterpart to the destination-side discipline already documented there | Co-locates the two halves of the contract |
| FR-015 | Audit-finding satisfier optional path | Workflow doc explicitly accommodates the lighter satisfier pattern from ADR-0010 (change-log entry) when the trigger is itself routine (e.g., minor Dependabot module bump). Rule does not relax; humanReview text covers the gradient. | Mirrors the cheap-satisfiers discipline |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| Cursor / Copilot / Codex hook adapters | Each tool has its own hook conventions; building four adapters at v1 multiplies surface area without a real consumer driving the need | After v1 Claude Code adapter validates the hook prompt structure and a non-Claude-Code consumer asks for parity |
| Commit-message pattern triggers (`closes #N`, etc.) | File-diff signals are sufficient; commit-message parsing expands validator scope and creates false-positive classes (PR description includes "closes" but PR doesn't actually close) | When the v1 file-diff trigger set demonstrably misses a meaningful class of distillation-worthy work |
| Auto-generated distillation entries | Generation contradicts the curation discipline; trigger should prompt human/agent action, not bypass it | Likely never; if revisited, only as a tightly-scoped suggested-draft helper, not autonomous writes |
| Threshold-batched distillation (e.g., "every N closures") | Event-driven at v1 is simpler; thresholds add state the validator chain doesn't currently have | When event-driven v1 produces observable distillation-fatigue from too-frequent firing |
| Migration of existing untriggered distillation-worthy artifacts | Backward enforcement would create an enormous false-positive surface on first run; v1 enforces from the rule's land-date forward | Probably never; archaeological distillation isn't the value proposition |

## Technical Constraints

- **Companion-rule machinery is regex-over-paths only.** The trigger
  signal set must be expressible as path regex. This is a feature, not a
  limitation — it forces signal definition to live in artifact shape
  rather than in commit-message conventions or build-time metadata.
- **`validate-companions.sh` runs against the PR diff vs base branch.**
  The trigger fires at PR boundary, not on every commit. Mid-PR distillation
  contributions get folded in by the final diff; multi-commit PRs still
  satisfy if any commit in the diff touched a satisfier path.
- **Claude Code hook semantics are tool-specific.** The hook
  implementation must respect Claude Code's existing hook configuration
  format under `platform/agents/claude-code/` and not introduce new
  invocation conventions. Stop / SessionEnd events fire on session
  termination; this PRD does not change that.
- **Backward compatibility with consumer projects.** Consumer projects
  that have `knowledge-capture` active inherit the new rule on next
  validator run. The first PR in any active consumer project that
  triggers it will fire — by design — surfacing whatever distillation
  trail is missing. This is acceptable: the rule is the contract; first
  firing is the diagnostic.
- **No validator-engine changes.** All v1 enforcement rides
  `validate-companions.sh` as-is. If a future requirement needs trigger
  semantics that exceed companion-rule expressiveness, a separate ADR
  decides whether to extend the validator or reshape the signal set.

## Tech Stack

*(Governance PRD — no application stack to specify. The tools involved are
the existing validator chain (Ruby + Bash) and the Claude Code hook
runtime.)*

| Layer | Choice | Why |
|-------|--------|-----|
| Validator runtime | Ruby (via `validate-companions.sh`) | Existing machinery; no addition |
| Hook runtime | Claude Code's native hook runtime | Tool-native; no shim |
| Documentation format | Markdown + cross-references | Existing convention |

## API & Data Contracts

*(N/A — governance PRD; no API surface introduced.)*

## UI/UX Notes

*(N/A — governance PRD; no user-facing surface beyond CI output and the
hook prompt structure, both already specified in FR-006 and FR-007.)*

## CI/CD Gates

- The new companion rule lands in `knowledge-capture/module.yaml`. The
  existing `validate-companions.sh` CI job exercises it automatically on
  every PR. No new CI job is added.
- The Claude Code hook is configured once under `agents/claude-code/`;
  consumers who activate the module inherit it. No CI gate enforces hook
  presence (the hook is an agent-side ergonomic, not a governance floor).
- The PR delivering this PRD must itself pass the new rule — i.e., must
  include a `shared-observations.md` entry capturing what was learned
  from designing the trigger layer (a meta-observation about the harness
  discovering it should harness itself). This is the dogfooding
  self-validation.

## Open Questions (carried forward from OPP-0004, with PRD positions)

| Question | PRD position | What v1 will validate |
|----------|--------------|-----------------------|
| What concrete signals count as cycle end? | v1: new ADR, new OPP, OPP status flip from proposed, new module manifest, harness.manifest.yaml change. Other signals (issue closure, audit findings, version bump) deferred. | After v1, observe missed triggers and add signals as needed |
| Passive vs active vs hybrid? | v1: both (companion rule + hook). Companion rule is the floor; hook is the in-session reminder. | Whether the hook actually changes behavior or just adds noise |
| Heartbeat: retire, formalize, or absorb? | v1: absorbed. The cycle-end-distillation workflow doc becomes canonical; module-README prose cross-links to it. | Whether agents working in the harness reliably load the workflow when relevant |
| Composition with existing companion rules? | v1: new rule lives on `knowledge-capture`; it does not duplicate the audit-trail rule (which fires on destinations being *edited*). Trigger rule fires on distillation-worthy *work*; audit-trail rule fires on destination *touches*. Both can fire on the same PR; satisfying one satisfies its own concern. | Whether the combined rule pressure feels coherent or contradictory in practice |
| New module vs additions? | v1: additions to existing modules (`knowledge-capture` + `agents/claude-code`). New module deferred. | Whether the addition pattern stays clean or surface-bleed argues for promotion to its own module |
| Consumer experience: opt-in or inherited from kernel/base? | v1: inherited via `knowledge-capture`. Projects not running `knowledge-capture` have no destinations, so the trigger has nothing to satisfy against. The rule's existence is conditional on the module's activation, which is the correct gating. | Whether consumers want a kernel-level floor (probably no — but watch) |

## Acceptance Criteria for OPP-0004 Promotion to `accepted`

Per the opportunity-capture module's promotion contract, OPP-0004
promotes to `accepted` when this PRD is **finalized and reviewed** AND
**at least one trigger mechanism ships** as proof of contract. Concretely:

1. This PRD lands as `Accepted` (status field flips after review)
2. The companion rule from FR-001..FR-005 lands in
   `knowledge-capture/module.yaml`
3. Auto-harness dogfoods the rule with one real distillation-trail entry
   (FR-010)
4. OPP-0004's `Status` flips to `accepted`, `Promotion` field links this
   PRD, `Disposition` notes the acceptance rationale

The hook (FR-006/007) and workflow doc (FR-008) may land in a follow-up
PR if the implementation PR grows too large, but the companion rule and
its dogfooded firing are the minimum bar.

## Rollout

- **Implementation PR scope:** Companion rule + workflow doc + at least
  one real distillation-trail entry (the FR-010 dogfood). Hook adapter
  may follow in a second PR if scope warrants.
- **Consumer notification:** Brief note in the auto-harness CHANGELOG.md
  pointing at this PRD when the implementation lands. Consumers running
  `knowledge-capture` will see the new rule fire on their next
  distillation-worthy PR; the rule's `humanReview` text is their
  inline guidance.
- **Watch metric:** After 30 days of the rule being live, count the
  ratio of (distillation-worthy PRs filed) to (distillation-trail
  satisfiers landed). The rule succeeds if the ratio approaches 1:1; it
  fails if PRs routinely bypass the rule via disabled-validation
  overrides or by satisfying with low-signal observations.

## Risks

- **Distillation-fatigue.** Rule fires too often, observations degrade
  in quality, signal/noise inverts. *Mitigation:* trigger signal set is
  deliberately heavy (ADR / OPP / module / catalog only); audit at 30
  days and tighten if needed.
- **Cargo-cult satisfiers.** Contributors append a one-line observation
  to pass the rule without real distillation. *Mitigation:* `humanReview`
  text and the workflow doc address this directly; reviewer discipline
  is the backstop, same pattern as every other companion rule.
- **Hook coupling.** Claude Code hook adapter becomes the de-facto
  pattern; other tools' adapters never get built. *Mitigation:*
  workflow doc carries the canonical pattern in tool-agnostic terms;
  hook is the *adapter*, not the *contract*.
- **Self-referential satisfaction.** The PR landing this PRD must
  satisfy its own new rule. If the rule's exact text is wrong, the PR
  can't merge to fix the rule. *Mitigation:* the implementation PR can
  use the `overrides.disabledValidations` escape hatch for one merge,
  documented as such; subsequent runs enforce normally.

## Open Implementation Questions (PRD acceptance does not require resolving)

- Exact file path for the Claude Code hook configuration under
  `platform/agents/claude-code/` — determined by reviewing the
  agents/claude-code module's existing hook conventions during
  implementation
- Exact wording of the hook prompt template — iterated against real
  session output before landing
- Whether `harness-governance` skill should embed the workflow text or
  link to it — implementation-time call
