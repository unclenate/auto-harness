<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0004 — Distillation Triggers (Closing the Cycle-End Gap)

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-05-21
**Last Updated:** 2026-05-22
**Confidence:** high

---

## Thesis

Auto-harness provides the *destinations* for distilled knowledge
(`docs/knowledge/shared-observations.md`, `docs/knowledge/distilled-learnings.md`,
`docs/operating-principles.md`, ADRs) but provides no *triggers* that
reliably cause distillation to happen during or after a work cycle. The
result: insights that should land in durable institutional memory get
either cached as private agent memory (and lost to the project) or
remembered only when a human happens to prompt for them. Define and ship
the trigger layer — a combination of validators (passive), workflow
rituals (declarative), and tool-specific hooks (active) — so that
distillation becomes a property of the harness rather than a discipline
the maintainer has to remember.

This is the "if the harness's job is durable knowledge, the harness should
make sure it happens" thesis, made concrete.

## Origin / Evidence

- **Observation:** `docs/knowledge/shared-observations.md` — *"Consumer-driven
  feedback has displaced the scheduled-review cadence as the active quality
  mechanism"* (process severity, 2026-05-20). Names the immediate symptom:
  the declared scheduled-review cadence (`distilled-learnings.md` target
  2026-04-30) never fired; consumer issues #24 and #28 did the actual
  learning. But that observation only addresses *what's replacing* the
  cadence, not *why the cadence didn't fire* — which is the deeper gap
  this opportunity captures.

- **Lived evidence — this very session.** Two memory-worthy insights
  emerged during PR #29's work (file-boundaries-as-precision; module-text-
  reads-in-stripped-contexts). Both would have been privately cached as
  Claude Code agent memory and never reached the harness if the user had
  not explicitly said "let's run a documentation pass." The harness
  provided the surfaces; the *prompt to use them at the right moment* came
  from the user, not the harness. This is a reproducible pattern: every
  recent session has produced learnings whose capture depended on the
  maintainer remembering to ask.

- **Aspirational prose with no machinery.** Several module READMEs
  reference a "heartbeat with Knowledge Contribution step" pattern (e.g.,
  `platform/profiles/management/knowledge-capture/README.md`,
  `platform/profiles/management/opportunity-capture/README.md` § Agent
  Behavior). Today this is documentation about a pattern that doesn't
  exist as actionable infrastructure — no skill, no validator, no hook
  enforces the heartbeat or its Knowledge Contribution step. The text
  describes a contract that is not currently enforced.

- **External signal — maintainer expectation.** The maintainer assumed
  this was already happening in harness-governed projects and was
  surprised to learn it was not. The "I thought that was a core function"
  reaction is itself evidence: distillation triggers feel like they
  *should* be a load-bearing part of the harness's value proposition, and
  their absence is invisible until pointed at.

- **Internal precedent.** auto-harness already has the surface
  primitives — modules, validators, companion rules, skills, workflows,
  templates, hooks (via the `agents/claude-code` module). What's missing
  is composition: a coherent set of trigger artifacts that fire on
  concrete cycle-end signals (PR merged, ADR landed, issue closed, audit
  finding resolved) and demand distillation before the cycle is allowed
  to close.

## Why Now

- **Active gap is producing latent loss.** Every session that runs
  without a distillation trigger leaks some quantum of institutional
  knowledge into private agent caches that future agents (and the
  maintainer's future self) cannot reach. The longer this continues, the
  larger the gap between what the project knows and what it remembers.

- **Recent surface maturity.** With ADR-0012 (file-boundaries-as-
  precision), the path-disambiguation principle, and the freshly-merged
  observation about consumer feedback, the *content* the harness should
  be distilling is becoming more legible. The gap between
  "distillation-worthy moments" and "distillations actually filed" is
  growing visible just as the surface mechanics stabilize.

- **Maintainer-stated priority.** The maintainer explicitly flagged this
  as a core-function gap requiring near-term resolution, not background
  cleanup. Filing now (rather than batching with longer-term R&D)
  preserves that priority signal.

- **Composability moment.** auto-harness is approaching public-launch
  readiness (OSS cut already shipped per ADR-0005; quality audit closure
  in progress). Defining distillation triggers before broader consumer
  adoption means consumers inherit the pattern by default rather than
  inheriting the current gap.

## Risks / Open Questions

### Design-shape choice: passive, active, or both?

Two viable shapes, with a hybrid option:

1. **Passive** — new validator(s) flag missing distillation when
   concrete signals are present in a PR diff. Examples:
   - "Branch landed an ADR but no `shared-observations.md` entry"
   - "Branch closes an issue but no audit trail of learning"
   - "Branch publishes a new module but `operating-principles.md`
     untouched"
   This is harness-native (regex over diffs, same machinery as existing
   companion rules), CI-enforced, and tool-agnostic. Weakness: only
   fires at PR boundary, can't catch insights that happened mid-session.

2. **Active** — Claude Code (and other agent-tool) hooks that fire at
   `SessionEnd` / `Stop` / `SubagentStop` and prompt the agent (or the
   user) to surface anything worth distilling. This catches mid-session
   insights and is more reliable at real-time capture. Weakness: tool-
   specific (Claude Code hooks ≠ Cursor hooks ≠ Copilot ≠ Codex), and a
   hook ignored is still a hook ignored.

3. **Hybrid (recommended at thesis stage; PRD should validate).** The
   active hooks prompt agents during session; the passive validators
   enforce the floor at PR boundary. Each catches what the other misses.

### Heartbeat formalization

The "heartbeat with Knowledge Contribution step" prose currently scattered
across module READMEs needs to become either (a) a single canonical
workflow document with concrete steps and exit criteria, or (b) explicitly
retired as aspirational and replaced with whatever the new trigger
machinery is. Leaving the prose in place alongside new machinery would
create two patterns competing for the same role.

### Risk: distillation-fatigue / Cargo-cult observations

A trigger that fires too eagerly will produce low-signal observations
(every PR generates an entry, most of which are noise). The companion
rule pattern has the answer baked in: distinguish substantive from
routine via lighter-weight satisfiers (change-log entry vs. observation
vs. ADR). The trigger layer should respect the same gradient.

### Risk: tool coupling

Claude Code hooks specifically would couple part of this machinery to one
agent tool. Mitigation: keep the *contract* tool-agnostic (define what a
distillation trigger looks like in module/skill/workflow terms), provide
a Claude Code adapter as the first implementation, document the contract
clearly so adapters for Cursor / Copilot / Codex can follow.

### Risk: scope sprawl

This OPP touches knowledge-capture, opportunity-capture, kernel/base,
agents/claude-code, validators, skills, workflows. PRD scoping needs to
decide: v1 = passive validators only? v1 = active hook only? v1 = both
for one module then propagate? The smallest-useful-change discipline
applies.

### Open questions for the PRD pass

- What concrete signals count as "cycle end"? (PR merge? Issue close?
  ADR landed? Audit finding resolved? End of Claude Code session?)
- What's the minimum-viable trigger: validator-only? hook-only? both?
- Does the heartbeat pattern get retired, formalized, or absorbed?
- How does this compose with existing companion rules without creating
  duplicate enforcement?
- Does this surface as a new module (`management/distillation-cadence`?)
  or as additions to `knowledge-capture` and `agents/claude-code`?
- What does the consumer experience look like? Do they opt in, or is it
  inherited from `kernel/base`?

## Disposition

**2026-05-21 (proposed → exploring):** Maintainer-stated priority drove
the immediate flip same day as filing. Hybrid trigger layer scoped as
additions to existing modules (`management/knowledge-capture`,
`agents/claude-code`) rather than a new top-level
`management/distillation-cadence` module. Heartbeat prose to be
formalized into actionable workflow, not retired — the pattern was
right, the machinery was the gap.

**2026-05-22 (exploring → accepted):** PRD-0004 finalized and accepted;
the v1 companion rule landed in `platform/profiles/management/knowledge-capture/module.yaml`
(v1.0.0 → v1.1.0); the canonical workflow document at
`platform/workflow/cycle-end-distillation.md` shipped; heartbeat prose
in `knowledge-capture` and `opportunity-capture` module READMEs
cross-links to the new workflow; `harness-governance` skill and
`docs/operating-principles.md` updated to reference the new rule and
workflow. The implementation PR satisfied its own new rule by
construction (no `overrides.disabledValidations` bootstrap needed) —
this dynamic itself produced a fresh observation captured in
`docs/knowledge/shared-observations.md` (2026-05-22 implementation
pass). Acceptance criteria 1-4 from PRD-0004 § "Acceptance Criteria for
OPP-0004 Promotion to accepted" all met.

**Deferred to follow-up (not blocking acceptance):** Claude Code
`Stop`/`SessionEnd` hook adapter (PRD-0004 FR-006/007 — should-have,
PRD-marked as may-follow-in-second-PR). Active hook is the in-session
ergonomic; the PR-boundary companion rule is the floor and is now live.

## Promotion

PRD-0004 (`docs/requirements/PRD-0004-distillation-triggers.md`) —
finalized and Accepted 2026-05-22. The v1 trigger machinery
(passive companion rule + canonical workflow doc) shipped in the same
PR that promoted this candidate. The active-hook adapter remains as
should-have follow-up work tracked under the same PRD.
