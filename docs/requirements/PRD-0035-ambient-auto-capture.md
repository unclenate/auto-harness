<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0035: Ambient Auto-Capture — schema-shaped stub upgrade to the distillation Stop hook

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-07-13 | **Review Cycle:** On-change

**Status:** Accepted *(design-only per § 9; the implementing PR upgrades the `distillation-prompt.sh` reference hook and its docs)*
**Date:** 2026-07-13 (filed + accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Promoting OPP: [OPP-0053](../opportunities/OPP-0053-observation-ledger-hygiene.md) — `accepted`; this PRD ratifies its **Layer 2** (the ambient auto-capture Stop-hook), the half deferred by [PRD-0034](PRD-0034-validate-observation-hygiene.md). On this PRD's implementation-merge, OPP-0053 is delivered end-to-end (both layers).
- Layer 1 (the enforcement half): [PRD-0034](PRD-0034-validate-observation-hygiene.md) / `validate-observation-hygiene.sh` — the CI gate that BLOCKS a non-conformant observation. This PRD is the **ergonomics half**: it pre-pours the ADR-0002 shape at session-end so conforming is the path of least resistance. Enforcement + ergonomics on the same schema.
- Upgraded artifact: [`distillation-prompt.sh`](../../platform/examples/sample-projects/node-web-saas-postgres/.claude/hooks/distillation-prompt.sh) — the existing PRD-0004 FR-006/FR-007 Stop-hook reference implementation. It already detects the exact condition (a distillation-trigger path changed on the branch, no satisfier touched yet); today it **reminds**, and this PRD upgrades it to also **scaffold**.
- Governed schema: [ADR-0002](../adr/ADR-0002-knowledge-capture-structured-observations.md) — the six-field Observation Structure the stub mirrors. The stub's field set + enums are the same single source of truth `validate-observation-hygiene.sh` enforces; the two must stay in sync (a "keep in sync" note, exactly like the hook's existing trigger-set sync note against `knowledge-capture/module.yaml`).
- Lineage: [PRD-0004](PRD-0004-distillation-triggers.md) (the distillation-trigger contract the hook implements); `platform/workflow/cycle-end-distillation.md` (the satisfier decision tree the stub points at); `docs/architecture/stigmergy.md` § 4 "Forced Traces" (the hook is point 2 — "In-Session Hooks / Active Prompting" — which this PRD advances from *remind* to *scaffold*).
- Related operating-principles: § 9 (this PRD is the design; a separate PR implements).

## Overview

`validate-observation-hygiene.sh` (Layer 1) made ADR-0002 conformance a hard CI gate for
newly-added observations. Enforcement alone raises the cost of the *first* attempt: an agent
that hand-writes an observation from memory can still land off-enum on the first try and only
learn at PR-time. The `distillation-prompt.sh` Stop-hook already fires at exactly the right
moment — end-of-session on a feature branch that changed a distillation-trigger path without
touching a knowledge destination — but it only emits a prose reminder to "run the distillation
pass." It stops one step short of the shape.

This PRD upgrades that hook from **remind** to **scaffold**: when it fires, it also emits an
**ADR-0002-shaped inert stub** — the six field labels pre-poured, `Context` and `Contributed by`
pre-filled from the detected git context (the trigger files, the branch, today's ISO date), and
the judgement fields (`Observation`, `Implication`, `Confidence`, `Severity`) left as explicit
fill-me placeholders. The agent fills four fields into a correct skeleton instead of recalling
the schema. This is the active-trace half `stigmergy.md` § 4 gestures at: the passive companion
rule forces a trace to exist, the reminder hook nudges, and now the scaffold makes the *correctly
shaped* trace the default output.

### The stub is inert by construction

The load-bearing safety property (OPP-0053's risk note): the stub must never be a
schema-conformant entry that could satisfy the very check it stands in for. This is guaranteed
mechanically, not by convention:

- **Primary guarantee — `validate-observation-hygiene.sh` (Layer 1).** The `Confidence` and
  `Severity` fields carry placeholder values (illustrated below as `[[low|medium|high]]` /
  `[[informational|governance-relevant|architectural|risk-bearing]]`) that are **not** valid enum
  values. *Any* non-enum placeholder fails the enum check, so if an unfilled stub is ever
  committed on a branch with `knowledge-capture` active, Layer 1 rejects it in CI. This holds
  regardless of how the placeholder is spelled — it is the robust guarantee.
- **Secondary guard — `validate-placeholders.sh`.** That validator matches only
  strict-uppercase tokens (`[[A-Z0-9_]+]]`). The implementation should therefore spell each
  fill-field as a strict-uppercase token (e.g. a `CONFIDENCE` token in doubled square brackets)
  so `validate-placeholders` *also* flags an unfilled stub — belt-and-suspenders. The
  allowed-value hints (`low|medium|high`, etc.) then live in an adjacent HTML comment rather
  than inside the token, so the token stays strict-uppercase. (Spelling the token is an
  implementation detail; the acceptance criterion is that an unfilled stub fails **at least**
  Layer 1, and preferably both.)

So an unfilled stub cannot merge, cannot masquerade as a real observation, and cannot silently
satisfy the distillation companion. Replacing the placeholders with real values is the only way
to make it pass — which is exactly the desired behavior.

### Key design decision — stub destination

The one reviewable fork. Where does the scaffold go?

- **Option A (stdout only):** emit the stub in the hook's existing markdown prompt; the agent
  copies it into `shared-observations.md` and fills it. Zero disk writes beyond the current
  behavior. The conservative floor.
- **Option B (draft file + stdout pointer) — RECOMMENDED:** additionally write the stub to a
  **gitignored** `.claude/drafts/distillation-<ISO-timestamp>.md`, and point the prompt at it.
  The scaffold persists on disk to fill and move into the ledger — genuine "auto-capture" without
  mutating the governed file. Consistent with the hook's existing side effect (it already
  `mkdir -p .claude/logs` and appends an audit line), and safe because the draft dir is gitignored
  (so it can never be the accidental commit the `[[...]]` placeholders also guard against).
- **Option C (append to `shared-observations.md`) — REJECTED:** a Stop-hook auto-mutating a
  governed, CI-gated file is a surprising Tier-2 side effect; an unfilled stub committed there
  would block CI; and it muddies the ledger's diff. The `[[...]]` inertness makes it *safe* but
  not *tasteful*.

Recommendation: **Option B**, with A as the fallback if the maintainer prefers zero new disk
writes. The implementing PR should also add `.claude/drafts/` to the sample project's
`.gitignore` (and document the one-line addition for consumers).

## Goals & Non-Goals

**Goals:**

- Upgrade `distillation-prompt.sh` (reference implementation) so that, in the existing
  trigger-present + satisfier-absent branch, it emits an ADR-0002-shaped inert stub in addition
  to the current prompt. Bash 3.2, shellcheck-clean at `-S warning`, still **exit 0 always**
  (informational; never blocks the agent), still silent in all the current silent-exit cases.
- The stub shape (single source of truth with `validate-observation-hygiene.sh`) — fields and
  fill-points shown illustratively below; the *actual* fill tokens are strict-uppercase per
  FR-002 (allowed-value hints in an adjacent HTML comment), so the literal forms here are shape,
  not spelling:
  - a heading line with a one-line-observation fill-point
  - `- **Context:**` — pre-filled: the detected trigger files + branch (the hook already computes
    `$TRIGGERS` and `$CURRENT_BRANCH`).
  - `- **Observation:**` / `- **Implication:**` — fill-point placeholders.
  - `- **Confidence:**` — fill-point (allowed: `low` / `medium` / `high`).
  - `- **Severity:**` — fill-point (allowed: `informational` / `governance-relevant` /
    `architectural` / `risk-bearing`).
  - `- **Contributed by:**` — the ISO date pre-filled (the hook already computes an ISO
    timestamp), the name/handle a fill-point.
- Implement **Option B** (recommended): write the stub to a gitignored
  `.claude/drafts/distillation-<timestamp>.md` and reference it in the prompt; add `.claude/drafts/`
  to the sample project's `.gitignore`. (If the maintainer selects Option A at review, drop the
  draft-file write and the `.gitignore` line; everything else is unchanged.)
- Keep the enum lists and field set **in sync** with `validate-observation-hygiene.sh` — add a
  sync note to the hook header (mirroring its existing "keep these in sync" note against the
  companion rule's trigger set).
- A hermetic test (git-fixture) that invokes the hook and asserts: stub emitted when a trigger
  path changed and no satisfier touched; silent when a satisfier is present; silent when no
  trigger; the emitted stub fails `validate-observation-hygiene.sh --scan-file` and
  `validate-placeholders.sh` (proving inertness).
- Doc updates: `stigmergy.md` § 4 point 2 (remind → scaffold), `cycle-end-distillation.md` (the
  stub is now offered), `platform/agents/claude-code/README.md` (hook description).

**Non-Goals (deferred):**

- **Auto-*filling* the judgement fields** (`Observation` / `Implication` / `Confidence` /
  `Severity`). The scaffold pre-pours *shape and context*, never the *judgement* — picking the
  severity and calibrating confidence is an authoring act (the `validate-module-stability` /
  Layer 1 semantic-quality boundary). A hook that guessed them would manufacture exactly the
  cargo-cult entries the distillation rule warns against.
- **Auto-committing or auto-moving** the stub into `shared-observations.md`. The agent fills and
  places it; the hook only scaffolds.
- **A new validator or a validator-count change.** This is a hook upgrade; the count stays 25.
- **Promoting the hook out of the sample project** into an always-installed harness component.
  It remains a reference implementation consumers opt into via `.claude/settings.json`, exactly
  as today.
- **Changing the trigger/satisfier detection.** The existing detection is correct and reused
  verbatim; only the emission changes.

## § 10 Claim Classification

Layer 2 is **ergonomics, not enforcement** — it changes no claim's Enforced/Asserted status.
Layer 1 (PRD-0034) already moved C-OBS-1..3 to Enforced; this PRD lowers the *friction* of
conforming without touching what is enforced.

| Claim ID | Claim | Current | After v1 |
|----------|-------|---------|----------|
| C-CAP-1 | At session-end on a trigger branch with no satisfier, the agent is offered a correctly-shaped ADR-0002 skeleton to fill | Asserted-only (the hook reminds in prose; the agent recalls the schema from memory) | **Asserted (assisted)** — the hook scaffolds the shape; still no enforcement that the agent uses it (enforcement is Layer 1's job at PR-time) |
| C-CAP-2 | The scaffold cannot itself satisfy the shape gate or the distillation companion | n/a (no scaffold today) | **Enforced (by construction)** — the non-enum placeholder values fail `validate-observation-hygiene` (robust), and strict-uppercase tokens additionally fail `validate-placeholders`, so an unfilled stub cannot merge |

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001 | Stub emission on the existing fire condition | In the trigger-present + satisfier-absent branch, the hook emits the ADR-0002-shaped stub (heading + six fields, `Context`/`Contributed by`-date pre-filled, judgement fields as `[[…]]` placeholders) in addition to the current prompt. All current silent-exit paths unchanged. Still `exit 0` always. |
| FR-002 | Inert by construction | An unfilled stub fails `validate-observation-hygiene.sh --scan-file` (the `Confidence`/`Severity` placeholders are non-enum values — the robust guarantee, independent of spelling). Preferably it *also* fails `validate-placeholders.sh` — achieved by spelling each fill-field as a strict-uppercase `[[A-Z0-9_]+]]` token with the allowed-value hint in an adjacent HTML comment. Acceptance: an unfilled stub fails **at least** Layer 1. |
| FR-003 | Shape is single-source-of-truth with Layer 1 | Field set + enum lists match `validate-observation-hygiene.sh` exactly; a header sync note documents the coupling (mirroring the hook's existing trigger-set sync note). |
| FR-004 | Option B destination | Stub written to gitignored `.claude/drafts/distillation-<timestamp>.md`; the prompt references it; `.claude/drafts/` added to the sample project `.gitignore`. (Swap to Option A — stdout only — if selected at review.) |
| FR-005 | Bash 3.2 + exit-0-always + graceful degradation | Shellcheck-clean at `-S warning`; every current silent-exit case (non-git, detached HEAD, on base branch, no base ref, no changed files, no trigger, satisfier present) still exits silent; the draft-file write degrades silently if `.claude/` is unwritable. |
| FR-006 | Hermetic hook test | A git-fixture test invokes the hook in a temp repo and asserts: stub emitted on trigger-without-satisfier; silent on satisfier-present and on no-trigger; and the emitted stub fails both `validate-observation-hygiene.sh --scan-file` and `validate-placeholders.sh` (inertness proof). |
| FR-007 | Doc propagation | `stigmergy.md` § 4 point 2 updated (remind → scaffold); `cycle-end-distillation.md` documents the stub; `platform/agents/claude-code/README.md` hook description updated. No validator-count change. |

### Should Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-S01 | Multiple-trigger heading hint | When several trigger files changed, the stub's `Context` lists them so the agent can scope the observation to the most substantive one. |

### Out of Scope

| Feature | Reason | Revisit |
|---------|--------|---------|
| Auto-filling judgement fields | picking severity / calibrating confidence is an authoring act | not planned (the semantic-quality boundary) |
| Auto-committing / auto-moving the stub | the agent fills and places it | not planned |
| New validator / count change | this is a hook upgrade | n/a |
| Always-installed (non-sample) hook | stays an opt-in reference implementation | a future OPP if consumers ask |

## Technical Constraints

- **Bash 3.2 compatible**, **shellcheck clean at `-S warning`**, **exit 0 always** (the hook is
  informational and must never block a Stop event).
- **No new runtime dependencies** — Bash + `git` + coreutils `date`, exactly as today.
- **Enum lists duplicated, intentionally** — the hook is a self-contained reference file that
  cannot `source` the validator; the sync note makes the coupling explicit and greppable.
- **Draft-file write must be best-effort** — wrapped so an unwritable `.claude/` degrades to
  stdout-only rather than erroring (preserving exit-0-always).
- The stub's own prose must not trip `validate-skill-content.sh` if the hook file is ever scanned
  (it is a sample-project file, currently outside the active-module scan, but keep it clean).

## CI/CD Gates

- Full validator chain green (validator count unchanged at **25**); markdownlint + shellcheck
  clean on the upgraded hook.
- The new hermetic hook test passes, including the inertness proof (stub fails both validators).

## Acceptance Criteria for OPP-0053 → fully delivered

OPP-0053 is delivered end-to-end when FR-001…FR-007 merge: Layer 1 (enforcement, PRD-0034) and
Layer 2 (ergonomics, this PRD) both live. The structured-agent-ledger gate on the knowledge
ledger then has both halves the OPP scoped — the CI gate that blocks drift and the session-end
scaffold that makes conforming the default.

## Versioning Implications

Additive and sample-project-scoped: an upgrade to a reference-implementation hook plus doc
updates. No module version bump (the hook is not a module), no validator-count change, no schema
change (the stub mirrors ADR-0002, it does not alter it). Consumers who have copied
`distillation-prompt.sh` re-copy the upgraded version (or cherry-pick the stub block) when they
want the scaffold; existing installs keep working unchanged (the upgrade only adds emission).
Lands in the next minor.
