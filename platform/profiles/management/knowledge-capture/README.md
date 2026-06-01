<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Management Overlay: Knowledge Capture

**Depends on:** `kernel/base`, `management/project-standard`.
**Conflicts with:** None.

This overlay adds a durable, shared, reviewable surface for institutional
knowledge to any project that adopts it. Agent observations, human insights,
and distilled learnings accumulate here — governed by the project's own
rules and enforced by the harness.

---

## What This Overlay Requires

Two files in `docs/knowledge/`:

**`docs/knowledge/README.md`** — The project's knowledge-capture policies.
Declares the foundational Observation Structure choice (locked by ADR),
the adjustable Write Policy, and the Escalation Table that governs what
companion rules apply at each severity level.

**`docs/knowledge/shared-observations.md`** — Append-only structured
observations from project participants. Agents write here during their
Knowledge Contribution heartbeat step (or however the Write Policy
permits). Humans append here after reviews or insights worth preserving.

The project's **curated longitudinal destination** — durable
how-this-project-works truths synthesized from accumulating observations —
is [`docs/operating-principles.md`](../../../../docs/operating-principles.md).
Promotion from observations to principles happens when patterns
crystallize, driven by evidence accumulating in shared-observations
rather than a synthetic cadence.

> **Historical note (ADR-0014, 2026-05-25).** This module previously
> declared a third required artifact, `docs/knowledge/distilled-learnings.md`,
> as a separate curated-synthesis destination. It was sunset after 40 days
> of zero inbound flow; operating-principles absorbed the curated charter
> in practice. See
> [ADR-0014](../../../../docs/adr/ADR-0014-sunset-distilled-learnings.md)
> and [PRD-0011](../../../../docs/requirements/PRD-0011-distilled-learnings-disposition.md).
> The file remains as a dormancy pointer for external-link safety.

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
   log (or the project change log). This is the audit trail. Higher-severity
   observations trigger additional companion rules from OTHER modules —
   the agent's workflow applies the escalation table in the knowledge
   README, which drives those additional edits.

2. **Changes to the Observation Structure** require an ADR. This is a
   foundational governance choice; changing it silently would invalidate
   every past observation's interpretation.

3. **Cycle-end distillation** (PRD-0004): when a PR contains
   distillation-worthy work (new/modified ADR, OPP, module manifest, or
   the active-module catalog), the same PR must touch one of the two
   knowledge destinations —
   [`docs/knowledge/shared-observations.md`](../../../../docs/knowledge/shared-observations.md)
   or [`docs/operating-principles.md`](../../../../docs/operating-principles.md).
   See [`platform/workflow/cycle-end-distillation.md`](../../../workflow/cycle-end-distillation.md)
   for the satisfier decision tree.

---

## Review Gates

Human review ensures the overlay's intent is preserved:

- The Observation Structure choice is effectively one-way. Reviewers treat
  any ADR proposing a structural change with extra scrutiny — including
  verification that past observations can be interpreted under the new
  structure or that a migration plan exists.
- Operating-principles promotions cite their source observations. Unsourced
  principles aren't institutional knowledge; they're opinions.
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
4. Promote patterns to `docs/operating-principles.md` when they
   crystallize — when the same pattern appears across multiple
   observations or when a single observation has clearly universal scope.
   Operating-principles is the curated longitudinal destination; promotion
   is the act of curation, driven by accumulated evidence rather than a
   synthetic cadence.
5. **At cycle end** (PR boundary, ADR landed, OPP status flip, new module
   published, manifest catalog change), perform the cycle-end distillation
   pass per [`platform/workflow/cycle-end-distillation.md`](../../../workflow/cycle-end-distillation.md).
   The companion-rule layer enforces this at PR boundary; the workflow doc
   defines the satisfier decision tree.

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

## See Also

- Templates: `platform/templates/knowledge/`
- Related: `management/project-standard/README.md` (revision tracker),
  `delivery/production-saas/README.md` (risk register)
