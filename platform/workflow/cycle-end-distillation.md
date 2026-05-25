<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Cycle-End Distillation

## Closing the Loop on Institutional Learning

Distillation is the act of taking what was *learned* during a unit of work
and recording it where the project will encounter it again. Auto-harness
provides the destinations for distilled knowledge; this workflow defines
*when* to distill, *where each kind of learning belongs*, and *how the
trigger mechanisms compose*.

> **Visual:** [Distillation Trigger Composition diagram](../../docs/architecture/diagrams.md#5-distillation-trigger-composition) —
> shows how the active hook + passive companion rule + trigger signals +
> knowledge destinations all compose.

This document is the canonical home for the "heartbeat with Knowledge
Contribution step" pattern that earlier module READMEs reference as
aspirational prose. The pattern is now grounded in actionable machinery:
a companion rule on `management/knowledge-capture` fires at PR boundary,
an optional Claude Code session-end hook prompts during work, and this
workflow doc is the human-facing reference both lean on.

> **Spec source:** PRD-0004
> ([`docs/requirements/PRD-0004-distillation-triggers.md`](../../docs/requirements/PRD-0004-distillation-triggers.md))

---

## When to Distill — Cycle-End Signals

A *cycle end* is any moment when a substantive unit of work concludes. The
v1 trigger set names four file-diff signals:

| Signal | Pattern in PR diff | Why it's a trigger |
|--------|---------------------|---------------------|
| New or modified ADR | `^docs/adr/ADR-` | Architectural decisions encode learning that future readers must understand to interpret the codebase |
| New or modified OPP | `^docs/opportunities/OPP-` | Opportunity records (especially status flips from `proposed`) carry investigation-phase learning that the spawned PRD won't fully capture |
| New or modified module manifest | `^platform/.+/module\.yaml$` | A new or changed module is a reusable pattern; the learning that motivated it is what makes it adoptable elsewhere. Pattern covers modules anywhere under `platform/` — `profiles/`, `agents/`, and `core/kernel/`. |
| Active-module catalog change | `^harness\.manifest\.yaml$` | Adopting / removing a module is a project-shape decision; the rationale lives in the manifest only by reference |

Other plausible signals — issue closure, audit findings, version bumps —
are deliberately out of scope at v1. See PRD-0004 § Out of Scope for the
rationale.

---

## Which Destination — The Satisfier Decision Tree

The companion rule accepts either of two destinations. Choose by the
*shape* of the learning:

```text
┌─ What is the shape of the learning? ─────────────────────────────────┐
│                                                                       │
│  Single-data-point insight from this specific work, severity-tagged?  │
│    └─→ docs/knowledge/shared-observations.md                          │
│        (one entry appended; cite the trigger artifact as Context)     │
│                                                                       │
│  Durable how-this-project-works truth applicable to all future work?  │
│    └─→ docs/operating-principles.md                                   │
│        (new bullet under existing section, OR new section if novel —  │
│         this is the curated longitudinal destination for the project) │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
```

**Default: shared-observations.** Most cycle-end distillations are
single-data-point insights — that's why the file is append-only and
severity-tagged. If you're unsure, write an observation; promotion to
operating-principles happens later when the pattern crystallizes.

**Operating-principles only when durable.** A pattern reaches operating-
principles when you can answer "yes" to: *"Is this true regardless of who
is doing the work, what they are working on, and when?"* If the answer is
"in this case" or "for this kind of work," it's an observation, not a
principle. Operating-principles is the project's *curated longitudinal*
destination — promotion is the act of curation.

> **Historical note (ADR-0014, 2026-05-25):** This decision tree used to
> name a third destination, `docs/knowledge/distilled-learnings.md`,
> intended for *"synthesis of multiple prior observations into curated
> knowledge."* The file went 40 days with zero inbound flow while
> operating-principles.md absorbed the curated-synthesis charter in
> practice (§§ 7-8). Per operating-principle § 7 (*Align File Boundaries
> with Change-Class Boundaries*), two destinations whose change-classes
> collapsed into one are now one destination. The historical pointer at
> `docs/knowledge/distilled-learnings.md` remains for external-link
> safety; the satisfier set is the two destinations above.

---

## Composition with Existing Rules

The cycle-end distillation rule (`knowledge-capture` companion rule #4)
fires on distillation-worthy *work*. Other companion rules fire on
destination *touches*. Both can fire on the same PR; satisfying one does
not satisfy the other.

| Rule fires when… | Required satisfier | Both can fire together? |
|--------------------|--------------------|--------------------------|
| New ADR landed (distillation trigger) | Any knowledge destination edited | Yes |
| shared-observations.md edited (audit trail) | memory/YYYY-MM-DD.md OR change-log.md | Yes |
| **Worked example:** PR introduces ADR-NNNN + observation + change-log entry | Both rules fire; both are satisfied | This is the normal pattern |

If a PR satisfies the distillation trigger by editing `shared-observations.md`,
that edit also triggers the audit-trail rule on observation edits — so
the PR must also include a `memory/YYYY-MM-DD.md` or `change-log.md`
entry. Two rules, two satisfiers, one coherent PR.

---

## Anti-Patterns

**Cargo-cult observations.** An observation entry appended to a PR
exclusively to satisfy the rule, with no substantive connection to the
trigger work, is worse than a missing observation — it degrades the
signal of every entry around it. The `humanReview` text on the rule
calls this out explicitly; reviewers push back.

**Distillation-fatigue avoidance.** The trigger set is deliberately
heavy (ADR / OPP / module / catalog). Routine work (Dependabot bumps,
typo fixes, version-only edits) does not fire the rule. If you find
yourself adding observations to PRs the rule didn't trigger on, you're
over-distilling — that's not a failure mode the rule causes, but watch
for it as the surrounding discipline tightens.

**Pre-emptive bypass via `overrides.disabledValidations`.** The
manifest's override mechanism exists for migration situations and
genuine emergencies (e.g., the PR landing this very rule, which had to
turn the rule off for one merge to introduce it). Routine use of the
override defeats the rule. If a class of PR routinely needs the
override, either the trigger set is wrong (revisit in an ADR) or the
team is selecting against the rule (revisit in review).

**Auto-generated distillation entries.** A pattern of "I'll just have
the agent draft something" produces text that satisfies the regex but
doesn't carry insight. Distillation is a human act of synthesis;
agent-drafted material is fine as input, but human review of *what to
keep* is the curation discipline that makes the destinations valuable.

---

## How Agents Should Use This

Agents working in projects with `management/knowledge-capture` active:

1. **Before opening a PR**, check whether the diff contains any trigger
   signals from the table above. If yes, plan the satisfier in the same
   PR — the rule will fire in CI otherwise.
2. **At session end** (if running Claude Code with the
   `.claude/hooks/distillation-prompt.sh` Stop-hook adapter installed),
   respond to the hook prompt by surfacing any insights worth capturing.
   The prompt names the branch's commit shortlog and the specific
   trigger signals detected; use that as the input for "what learning
   emerged?" The hook is the in-session reminder; the companion rule is
   the PR-boundary floor.
3. **When writing the observation/principle**, cite the trigger artifact
   explicitly in the Context field. The connection between work and
   distillation must be legible months later.
4. **Default to shared-observations.md** unless the insight is clearly
   universal — in which case operating-principles.md is the right
   destination. Prefer drafting the observation first; promote to
   operating-principles when the pattern crystallizes.

---

## How Humans Should Use This

Maintainers reviewing PRs:

1. **Look for the trigger signals first.** If any of the four are in the
   diff, scan for the satisfier — it must be in the same PR.
2. **Read the satisfier for substance.** Does the observation/principle
   *come from* the trigger work, or is it tangential text appended to
   pass CI? Reject cargo-cult entries.
3. **For ADRs specifically**, the rejected-alternatives discussion is
   often the highest-value distillation. An observation that captures
   "we tried X but it failed because Y" carries weight; an observation
   that just restates the ADR's decision doesn't.
4. **For OPPs**, the Disposition field's rationale on status flips is
   the distillable substance. An observation that codifies "the
   `proposed → exploring` flip happened same-day because Z" carries the
   discovery-pattern learning.

---

## References

- Spec: [`docs/requirements/PRD-0004-distillation-triggers.md`](../../docs/requirements/PRD-0004-distillation-triggers.md)
- Originating OPP: [`docs/opportunities/OPP-0004-distillation-triggers.md`](../../docs/opportunities/OPP-0004-distillation-triggers.md)
- Companion rule (rule #4): [`platform/profiles/management/knowledge-capture/module.yaml`](../profiles/management/knowledge-capture/module.yaml)
- Optional in-session hook (Claude Code): reference implementation at [`platform/examples/sample-projects/node-web-saas-postgres/.claude/hooks/distillation-prompt.sh`](../examples/sample-projects/node-web-saas-postgres/.claude/hooks/distillation-prompt.sh); install snippet in [`platform/agents/claude-code/README.md`](../agents/claude-code/README.md)
- Related operating principles: [`docs/operating-principles.md`](../../docs/operating-principles.md) § 3 (Documentation as Part of the Change) and § 7 (Align File Boundaries with Change-Class Boundaries)
- Cheap-satisfier discipline: [`docs/adr/ADR-0010-cheap-satisfiers-for-routine-governance.md`](../../docs/adr/ADR-0010-cheap-satisfiers-for-routine-governance.md) — same gradient applies; the trigger set is heavy precisely so the rule does not fire on routine work
