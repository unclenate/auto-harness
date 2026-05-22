<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Management Overlay: Opportunity Capture

This overlay adds a durable, reviewable, project-level surface for forward-looking
candidate records to any project that adopts it. Pre-PRD candidates — product
opportunities, strategic theses, "things we might pursue" — accumulate as
one-file-per-candidate records with explicit status, evidence-linkage to the
observation surface, and a binding promotion contract: accepting a candidate
requires spawning a real PRD in the same commit.

---

## What This Overlay Requires

One required file plus one optional file in `docs/opportunities/`:

**Required — `docs/opportunities/README.md`** — The project's opportunity-capture
policies. Declares the foundational Record Structure choice (locked by ADR),
the adjustable Write Policy, the status definitions and what each transition
requires, and a reference to the companion rules that enforce the audit-trail
floor and the PRD-spawning contract.

**Optional — `docs/opportunities/candidates.md`** — Organizational index of
candidates, with cluster headings and a grouped list of `OPP-NNNN` line items.
Lives outside `README.md` by design so the index can evolve freely without
invoking the ADR-required policy-change rule. Add this file when the candidate
set grows past a flat list. See `platform/templates/opportunity/candidates.md`
for the template.

Per-candidate records (`OPP-NNNN-slug.md`) accumulate in the same directory as
contributors capture and explore opportunities.

---

## How This Overlay Fits With Other Modules

| Module | Relationship |
|--------|--------------|
| `core/kernel/base` | Required dependency — trust tier model applies to opportunity edits |
| `management/project-standard` | Required dependency — revision tracker is the audit trail when used |
| `management/knowledge-capture` | Soft dependency — the Origin / Evidence field links forward-looking candidates to backward-looking observations when grounded; both modules can be adopted independently |
| `management/product-lite` (PRDs) | Soft dependency — accepted candidates spawn PRDs; the PRD module governs the downstream artifact |
| All agent packs | Agents read the opportunity README on heartbeats to know how to contribute candidates and apply the Write Policy |

---

## Companion Rules

Two companion rules enforce the governance floor; `humanReview` text covers four
substantive checks the regex layer cannot enforce:

1. **Any edit to an OPP record** requires an audit-trail entry in the day's
   daily memory log or the project change-log. This is the floor.
   `humanReview` covers: (a) Disposition rationale when status changed from
   `proposed`, (b) PRD spawned in the same commit when status flipped to
   `accepted`, (c) substantive rationale (not a one-line status edit) for
   `declined` or `superseded` transitions.

2. **Changes to `docs/opportunities/README.md`** (the project's policy file)
   require an ADR. This is the foundational governance floor — changing the
   record structure silently would invalidate every past candidate's
   interpretation. The optional sibling `candidates.md` (organizational
   index of candidates) is deliberately *not* covered by this rule: cluster
   headings and `OPP-NNNN` line-item edits are free-evolution. See ADR-0012
   for the rationale behind the split.

---

## Review Gates

Human review ensures the overlay's intent is preserved:

- The Record Structure choice is effectively one-way. Reviewers treat any ADR
  proposing a structural change with extra scrutiny — including verification
  that past candidates can be interpreted under the new structure or that a
  migration plan exists.
- Accepted candidates must spawn a PRD in the same commit. An `accepted`
  status without a PRD is a contract violation — block or fix in review.
- The Origin / Evidence field is the gap-closer. A `thesis-only` marker
  without a stated reason undermines the module's purpose; reviewers push back.

---

## Agent Behavior

Agents in opportunity-capture-enabled projects:

1. Read `docs/opportunities/README.md` on each heartbeat to pick up current
   policies (Write Policy, status definitions, escalation patterns).
2. Contribute candidates per the Write Policy. Under `heartbeat-only` (the
   recommended default), candidates are filed only during the Knowledge
   Contribution step of the agent's heartbeat, after dreaming has distilled
   their daily logs. This keeps signal high.
3. When filing a candidate, link the Origin / Evidence field to specific
   observations in `docs/knowledge/shared-observations.md` when grounded, or
   mark `thesis-only` with a stated reason when un-grounded.
4. Do not autonomously flip status to `accepted` — this is a human decision
   that binds a PRD commitment. Agents may draft Disposition rationale and
   stage a PRD for human review, but the status transition is human.
5. **When filing a new OPP or flipping an OPP's status from `proposed`**,
   the cycle-end distillation rule on `management/knowledge-capture` fires
   at PR boundary. Pair the OPP change with an observation, operating-
   principle edit, or distilled-learning entry per
   [`platform/workflow/cycle-end-distillation.md`](../../../workflow/cycle-end-distillation.md).
   This requires `management/knowledge-capture` to be active in the
   project; projects running opportunity-capture without knowledge-capture
   miss this trigger but should consider adopting both modules together.

The `harness-onboarding` skill identifies whether a project should adopt
opportunity-capture during onboarding. It's an optional module — projects
add it when forward-looking idea durability is a real concern (e.g.,
projects with multiple contributors filing candidates over weeks/months,
or projects where ideas regularly get lost between sessions).

---

## When to Adopt This Module

Good fit for projects that:

- Capture product opportunities or strategic directions mid-session that
  warrant durable per-record memory beyond conversation history
- Have a real promotion path from idea → PRD → delivery and want the
  intermediate state to be a first-class artifact, not a backlog item
- Benefit from explicit evidence linkage between forward-looking ideas and
  the observations that grounded them

Less necessary for:

- Single-session throwaway work
- Projects with no PRD discipline (the promotion contract has no anchor)
- Contexts where idea durability is already handled by an external tool
  (Linear, Notion, etc.) and dual-capture would be noise

---

## References

- Module definition: `platform/profiles/management/opportunity-capture/module.yaml`
- Templates: `platform/templates/opportunity/`
- Locking ADR (auto-harness adoption): `docs/adr/ADR-0004-opportunity-capture-record-structure.md`
- Index-split ADR: `docs/adr/ADR-0012-opportunity-capture-index-split.md`
- Spec: `docs/requirements/PRD-0003-opportunity-capture-module.md`
- Related modules: `management/knowledge-capture/README.md` (the observation surface),
  `management/product-lite/README.md` (the PRD surface that accepted candidates spawn)
