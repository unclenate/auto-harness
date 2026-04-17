# Management Overlay: Knowledge Capture

This overlay adds a durable, shared, reviewable surface for institutional
knowledge to any project that adopts it. Agent observations, human insights,
and distilled learnings accumulate here — governed by the project's own
rules and enforced by the harness.

---

## What This Overlay Requires

Three files in `docs/knowledge/`:

**`docs/knowledge/README.md`** — The project's knowledge-capture policies.
Declares the foundational Observation Structure choice (locked by ADR),
the adjustable Write Policy, the Distillation and Review cadences, and
the Escalation Table that governs what companion rules apply at each
severity level.

**`docs/knowledge/shared-observations.md`** — Append-only structured
observations from project participants. Agents write here during their
Knowledge Contribution heartbeat step (or however the Write Policy
permits). Humans append here after reviews or insights worth preserving.

**`docs/knowledge/distilled-learnings.md`** — Curated longitudinal
synthesis. Agents autonomously draft distillations from observations on
a scheduled cadence. Humans and agents review together on a separate
cadence, promoting accepted distillations into this file. Supersession
is preserved; nothing is silently overwritten.

---

## How This Overlay Fits With Other Modules

| Module | Relationship |
|--------|--------------|
| `core/kernel/base` | Required dependency — trust tier model applies to knowledge edits |
| `management/project-standard` | Required dependency — escalation to revision tracker depends on it |
| `delivery/production-saas` | Soft dependency — risk-bearing observations escalate to the risk register this module provides |
| All agent packs | Agents read the knowledge README on heartbeats to know how to contribute |

---

## Companion Rules

Three companion rules enforce the governance floor:

1. **Observation additions** require a pointer in the day's daily memory
   log. This is the audit trail. Higher-severity observations trigger
   additional companion rules from OTHER modules — the agent's workflow
   applies the escalation table in the knowledge README, which drives
   those additional edits.

2. **Changes to the Observation Structure** require an ADR. This is a
   foundational governance choice; changing it silently would invalidate
   every past observation's interpretation.

3. **Distillation edits** require either a daily memory entry or a review
   log entry. Curation of durable learnings is a team activity, not a
   unilateral agent edit.

---

## Review Gates

Human review ensures the overlay's intent is preserved:

- The Observation Structure choice is effectively one-way. Reviewers treat
  any ADR proposing a structural change with extra scrutiny — including
  verification that past observations can be interpreted under the new
  structure or that a migration plan exists.
- Distilled learnings cite their sources. Unsourced assertions aren't
  institutional knowledge; they're opinions.
- Write Policy changes come with rationale. If a project toggles from
  heartbeat-only to autonomous mode, the rationale should name the
  specific signal/noise condition that motivated the change.

---

## Agent Behavior

Agents in knowledge-capture-enabled projects:

1. Read `docs/knowledge/README.md` on each heartbeat to pick up current
   policies (Write Policy, cadences, escalation table).
2. Contribute observations per the Write Policy. Under `heartbeat-only`
   (the recommended default), observations are appended only during the
   Knowledge Contribution step after dreaming has distilled daily logs.
3. Apply the escalation table when severity warrants it — staging changes
   to the revision tracker, ADRs, or risk register alongside the
   observation, but not committing them.
4. Autonomously draft proposed distilled learnings on the Draft Cadence.
   Drafts are staged; humans and agents curate them together on the
   Review Cadence.

The `harness-onboarding` skill identifies whether a project should adopt
knowledge-capture during onboarding. It's an optional module — projects
add it when institutional knowledge durability is a real concern.

---

## When to Adopt This Module

Good fit for projects that:

- Have multiple participants (agents and humans) contributing over time
- Need knowledge continuity across sessions or personnel changes
- Benefit from explicit capture of "why we decided this" beyond what
  ADRs alone cover
- Run research or experimentation where observations compound into
  durable learnings

Less necessary for:

- Single-session throwaway work
- Projects whose governance fits entirely in ADRs and the revision tracker
- Contexts where the signal-to-noise ratio of captured observations
  would be dominated by noise

---

## References

- Templates: `platform/templates/knowledge/`
- Workflow pattern: `platform/workflow/knowledge-capture-pattern.md`
- Related: `management/project-standard/README.md` (revision tracker),
  `delivery/production-saas/README.md` (risk register)
