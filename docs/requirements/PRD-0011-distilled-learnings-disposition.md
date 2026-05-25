<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0011: Sunset `distilled-learnings.md` — Consolidate Curated Knowledge in `operating-principles.md`

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-05-25 | **Review Cycle:** On-change

**Status:** Proposed
**Date:** 2026-05-25 (filed)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Related OPP: [OPP-0026](../opportunities/OPP-0026-distilled-learnings-disposition.md) — `exploring`; this PRD is its promotion candidate
- Related ADRs (anticipated, may spawn during implementation):
  - ADR-0014 (proposed) — Sunset distilled-learnings.md; consolidate curated longitudinal knowledge in operating-principles.md (decision record formalizing the destination collapse)
- Related observations:
  - *"Declared knowledge surfaces without an inbound-flow trigger silently die; operating-principles ate distilled-learnings' lunch"* (2026-05-25, `docs/knowledge/shared-observations.md`) — the originating observation, captured during the bundle this OPP/PRD pair spawned out of
  - *"Cross-repo declarations have the same silent-drift failure mode as intra-repo doctrine-without-enforcement"* (2026-05-25) — sibling observation; same architectural root cause
  - *"Doctrine in prose without enforcement in code is a recurring harness gap"* (2026-05-23) — the umbrella pattern these two observations sit under
- Related audit finding: [QUALITY-AUDIT-2026-05-25-documentation-refresh.md](../QUALITY-AUDIT-2026-05-25-documentation-refresh.md) finding M8 — *"`distilled-learnings.md` shows a review cadence ~7 months stale"* — flagged as cosmetic; this PRD reframes it as structural
- Related candidate (not yet an OPP): *Session-cycle orchestration / review-trigger taxonomy* in `docs/opportunities/candidates.md` — the broader concern the OPP-0026 investigation surfaced, of which this PRD is one narrow instance
- Related operating-principles: § 3 (Documentation as Part of the Change), § 7 (Align File Boundaries with Change-Class Boundaries) — the **principle § 7 is the load-bearing argument for this PRD**: two destinations whose change-classes have collapsed into one should not remain two destinations
- Related modules: `platform/profiles/management/knowledge-capture/module.yaml` v1.1.0 — the module that currently declares `distilled-learnings.md` as a required artifact + cycle-end-distillation satisfier

## Overview

`docs/knowledge/distilled-learnings.md` has been a 64-line shell since
the `management/knowledge-capture` module was first added on 2026-04-16.
**Zero content entries in 40 days.** The file is declared as a
`requiredArtifact` of the knowledge-capture module and is one of three
acceptable destinations for the cycle-end distillation trigger rule
(PRD-0004), but it has no *forcing* trigger of its own and the workflow
doc explicitly tells authors *not* to write to it opportunistically:

> "Don't write directly to `distilled-learnings.md` to satisfy the trigger
> rule. **Promote observations to learnings during dedicated review, not
> opportunistically.**"
> — `platform/workflow/cycle-end-distillation.md:86-89`

Nothing schedules the dedicated review sessions.
`docs/operating-principles.md` has *de facto* absorbed the charter —
§§ 7 and 8 added this session are exactly the cross-observation
synthesis distilled-learnings was supposed to host.

This PRD specifies the v1 disposition as **Option A — Sunset.**
Remove `distilled-learnings.md` from the knowledge-capture module's
required-artifact set, remove it from the cycle-end-distillation rule's
satisfier list, remove the audit-trail rule that gates its edits,
update the workflow doc and the knowledge-capture README to name
`operating-principles.md` as the canonical curated-knowledge
destination, retain the file itself as a one-paragraph dormancy
pointer (preserves historical links from external references), and
record the decision as ADR-0014. This collapses two declared
destinations whose change-classes have collapsed into one in practice
to one declared destination — bringing the module's declared surface
back into agreement with the project's actual practice.

Three viable dispositions were weighed in OPP-0026:

- **Option A — Sunset** (chosen). Evidence strongly favors: 40 days of
  zero inbound flow, operating-principles has absorbed the charter,
  operating-principle § 7 explicitly argues against two destinations
  whose change-classes have collapsed.
- **Option B — Revive** (rejected for v1; revisit if Option A
  evidence weakens). Add a forcing trigger (time/count/audit-based)
  to schedule curation sessions. Rejected because: (a) operating-
  principles is already absorbing the work; (b) a forcing trigger
  added now would either fire on the same change-class
  operating-principles serves (creating a routing problem) or fire on
  a synthetic schedule that the team would then resent or game.
- **Option C — Clarify** (rejected for v1). Label the file dormant
  pending an established curation cycle. Rejected because: leaving a
  declared `requiredArtifact` that the project agrees not to use is
  worse than removing it — it signals to consumers that they should
  have one too, when the right signal is "operating-principles is the
  surface; the dormant historical file is preserved for reference."

The PRD treats Option A as the v1 deliverable and explicitly defers
Option B/C arguments to follow-up OPPs **if** evidence emerges that
operating-principles is overloaded or that a curation cadence
distinct from durable-truths is needed.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- Bring the knowledge-capture module's declared surface back into
  agreement with the project's actual practice — one curated
  destination, not two.
- Preserve external referenceability — readers landing on
  `distilled-learnings.md` from old links get a clear pointer to
  `operating-principles.md` rather than a 404 or a stale file.
- Make `operating-principles.md` the unambiguous, machine-checkable
  curated-knowledge destination for cycle-end distillation by editing
  the rule and the workflow doc together — no behavioral drift between
  module config and workflow prose.
- Capture the disposition decision as ADR-0014 so future readers can
  reconstruct the reasoning without re-running OPP-0026's
  investigation.
- Update `docs/knowledge/README.md` to name operating-principles as
  the curated-knowledge destination — closing the documentation gap
  flagged by audit finding M8.

**Non-Goals** — outcomes explicitly out of scope:

- **Solving the broader "session-cycle orchestration gap"** — *(why
  excluded: this PRD addresses one symptom — a single declared
  destination without inbound flow — not the whole pattern. The
  candidate stub in `candidates.md` for the broader review-trigger
  taxonomy is the right surface for that work, after a second
  concrete instance accumulates. Treating one instance as the whole
  pattern is the OPP-overreach failure mode operating-principles § 2
  explicitly cautions against.)*
- **Revising the cycle-end distillation rule itself** — *(why
  excluded: PRD-0004's three-destination satisfier model is sound for
  observations + principles; only the third destination is being
  removed. The rule logic is unchanged.)*
- **Forcing a curation cadence on `operating-principles.md`** — *(why
  excluded: operating-principles works today on a "promote when the
  pattern crystallizes" cadence — that is healthy, not broken. Adding
  a time-based trigger would create the exact failure mode this PRD
  removes from distilled-learnings.)*
- **Migrating existing content from distilled-learnings.md into
  operating-principles.md** — *(why excluded: the file is empty
  except for the template scaffolding; there is no content to
  migrate. If non-trivial content existed, this would be a different
  PRD.)*
- **Producing a forwarding script that auto-detects external links
  pointing at distilled-learnings.md** — *(why excluded: the file is
  retained as a redirect-stub, which is a cheap, durable solution.
  External-link auditing is a different problem.)*

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Harness maintainer | Owns the knowledge-capture module + the cycle-end-distillation workflow | A clean, ratified disposition + a small migration path + a durable record (ADR-0014) |
| Consumer-project maintainer | Has `management/knowledge-capture` active in their manifest | Knowledge that the required-artifact set shrank by one; an updated module README explaining why; no manual migration needed (the file just stops being required) |
| Future contributor reading the change-log | Wants to understand *why* the destination collapsed | A clear paper trail from observation → OPP → PRD → ADR-0014 → the module/workflow edits |

## User Stories

- As the **harness maintainer**, I want to remove `distilled-learnings.md` from the required-artifact set so the module's declared surface matches the project's actual curation practice.
- As a **consumer-project maintainer with `knowledge-capture` active**, I want the `requiredArtifacts` list to stop demanding a file my team is not maintaining, so my `validate-required-artifacts` doesn't pressure me to fill a destination the upstream project itself doesn't fill.
- As a **future contributor**, I want the workflow doc to name *exactly one* curated-knowledge destination so I do not have to read between the lines to figure out where synthesis belongs.
- As a **reader following an old link** to `docs/knowledge/distilled-learnings.md`, I want a clear pointer to `operating-principles.md` rather than a stale empty file or a 404.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | Remove `docs/knowledge/distilled-learnings.md` from `requiredArtifacts` in `platform/profiles/management/knowledge-capture/module.yaml` | `git diff` shows the line removed; `validate-required-artifacts.sh` no longer flags absence of the file for projects with `knowledge-capture` active | One-line edit |
| FR-002 | Remove `^docs/knowledge/distilled-learnings\.md$` from the cycle-end-distillation rule's `requiredAny` satisfier list (rule #4 in the same module.yaml) | `git diff` shows the line removed; the rule still accepts `shared-observations.md` and `operating-principles.md` | One-line edit |
| FR-003 | Remove the audit-trail rule (rule #3) that gates edits to `distilled-learnings.md` (the entire rule block) | The `sensitivePaths` block for `distilled-learnings.md` may also be removed if it no longer serves; the file is being downgraded to dormant | Whole-rule-block edit; coordinate with FR-004 (sensitivePaths) |
| FR-004 | Remove the `sensitivePaths` block for `distilled-learnings.md` in the same module.yaml | `git diff` shows the four-line entry removed (description + patterns block) | Coordinated with FR-003; preserves the "no orphan declarations" invariant |
| FR-005 | Rewrite `docs/knowledge/distilled-learnings.md` as a **one-paragraph dormancy pointer** explaining the file is retained for historical reference but curation has consolidated into `docs/operating-principles.md`; preserves the SPDX header | File renders as a pointer page when accessed from external links; `validate-doc-references.sh` resolves any inbound links cleanly | Retains link-safety; cheaper than a delete-and-redirect |
| FR-006 | Update `platform/workflow/cycle-end-distillation.md`: remove `distilled-learnings.md` from the three-destination decision tree (lines ~57-77); update the "anti-patterns" section that referenced the file; update the references block | Decision tree shows two destinations (observations + principles); the "don't write to distilled-learnings opportunistically" guidance is removed; no broken cross-references | Includes the diagram-text-form decision tree |
| FR-007 | Update `platform/profiles/management/knowledge-capture/README.md`: remove the bullet describing distilled-learnings.md; explicitly state that operating-principles.md is the curated-knowledge destination; cite ADR-0014 | The compiled fragment readers load at session start no longer points at the dormant file | Knowledge-capture is part of the active-modules catalog; this README is the compiled fragment |
| FR-008 | Update `docs/knowledge/README.md` to name `operating-principles.md` as the curated longitudinal destination; remove the bullet that named distilled-learnings.md as that destination; closes audit M8 | Reader of the knowledge-tree index sees the correct destination | One-bullet edit + one-section rephrasing |
| FR-009 | Update `docs/operating-principles.md` (if needed) to add a one-paragraph note at the top of the file explaining its role as the curated longitudinal destination for the project's distilled learnings — citing ADR-0014 | Self-describing; reader can answer "what is this file for?" from the file itself | Possibly already adequate; check before editing |
| FR-010 | File ADR-0014 — Sunset distilled-learnings.md — recording: the evidence (40-day staleness, charter collapse), the three options weighed, the rationale for Option A, the rejected alternatives' triggers (the conditions under which Option B/C should be revisited), and the explicit non-goals from this PRD | ADR rendered, accepted on merge, cited by FR-007 and the rewritten dormancy stub in FR-005 | Canonical decision record |
| FR-011 | Update the harness's own `harness.manifest.yaml` if it declares `knowledge-capture` (it does) — no manifest change needed since the module.yaml change is downstream; verify validators stay green | `validate-required-artifacts.sh` exits 0; `validate-companions.sh` exits 0; `validate-catalog-counts.sh` exits 0 | Self-dogfood; no manifest schema change |
| FR-012 | Update the `docs/architecture/diagrams.md` Distillation Trigger Composition diagram (#5) to remove `distilled-learnings.md` from the destination set | Diagram label / node count matches the two-destination reality | If the diagram lists three destinations, the integer is one of `validate-catalog-counts.sh`'s assertion targets if it's exposed there — check |
| FR-013 | Update `docs/knowledge/distilled-learnings.md`'s entry in `HARNESS.md` (knowledge surfaces table line ~73) to mark it dormant | Readers loading HARNESS.md see the correct status; no broken navigation | One-row edit |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-014 | Update `platform/templates/knowledge/distilled-learnings.md` (the template) similarly — keep as a dormancy stub or remove from the templates tree | Consumer projects scaffolding new knowledge surfaces don't get the dormant file as a fresh `requiredArtifact` | Template-side consistency with the destination-side change |
| FR-015 | Update `platform/templates/README.md` directory map to reflect the template change | One-row edit (table is already known to drift; this is also a list-completeness instance) | Cosmetic |
| FR-016 | Cite this PRD's disposition in the next quarterly distilled-learnings review meeting *if it exists* — confirming the sunset is durable rather than reactive | Optional: a one-line entry in `docs/project/review-log.md` if one is established | Aspirational; depends on session-cycle work |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| Adding a forcing trigger to operating-principles.md (the Option B shape applied to a different destination) | Would replicate the failure this PRD removes from distilled-learnings.md | If operating-principles itself shows staleness symptoms after 6+ months |
| Auto-migrating existing distilled-learnings content into operating-principles | File is empty; nothing to migrate | If a future PRD revives distilled-learnings with content that then needs to fold back |
| Forwarding script for old external links | Manual redirect-stub (FR-005) is cheaper and durable | If link-traffic data ever shows volume on the old path |
| Generalizing this to "every declared knowledge destination needs an inbound trigger" | The Session-cycle orchestration candidate in `candidates.md` is the right surface for that pattern | After a second instance of the declared-without-flow gap accumulates |

## Technical Constraints

- The change must not break consumer projects with `knowledge-capture` active. **Removal from `requiredArtifacts` is a softening, not a tightening — it cannot break.**
- The dormancy stub for `distilled-learnings.md` must keep the SPDX header so `validate-placeholders.sh` and `validate-doc-references.sh` continue to pass.
- The validator count remains at 8; no new validator is being added. (Option B would have added one; Option A does not.)
- All edits are confined to `platform/profiles/management/knowledge-capture/`, `docs/knowledge/`, `docs/operating-principles.md`, `platform/workflow/cycle-end-distillation.md`, `HARNESS.md`, `docs/architecture/diagrams.md` (if Diagram 5 references the destination), and `docs/adr/ADR-0014-*.md`.

## CI/CD Gates

| Gate | Required? | Notes |
|------|-----------|-------|
| Lint passes | Yes | markdownlint clean |
| Validator chain passes | Yes | All 8 validators; the dormancy stub passes placeholders + doc-references |
| Companion-rule check passes | Yes | Changes touch a module.yaml + governance-entrypoint paths; the same PR must satisfy the kernel/base companion rules (it does, via the ADR + change-log entry) |
| Change-log updated | Yes | Bundle entry documenting the disposition decision + ADR-0014 link |
| ADR-0014 accepted | Yes | Decision record formalizing Option A |

## Success Metrics

| KPI | Target | How measured |
|-----|--------|-------------|
| `distilled-learnings.md` declared-but-unfilled gap | Closed | The file is no longer in `requiredArtifacts`; the audit's M8 finding moves from "open" to "resolved by removal" |
| Curated-knowledge destination ambiguity | Eliminated | `cycle-end-distillation.md` decision tree shows exactly one curated destination (operating-principles); workflow doc + module README + knowledge README all agree |
| External-link safety | Preserved | `validate-doc-references.sh` exit 0 after the rewrite; no orphan inbound links |
| Consumer breakage | None | Consumer projects with `knowledge-capture` active validate green after upgrading to the new module version |

## Dependencies

- ADR-0014 must be drafted in the same PR (or a precursor PR) — see FR-010.
- The OPP-0026 status flip to `accepted` happens on merge of this PRD per the standard OPP→PRD promotion contract.

## Open Questions

- [ ] **Should the dormancy stub for `distilled-learnings.md` link forward to a specific section of `operating-principles.md`, or just to the file?** Bias: link to the file with a one-sentence framing. Specific-section linking creates a maintenance surface as operating-principles evolves.
- [ ] **Should the equivalent template (`platform/templates/knowledge/distilled-learnings.md`) be deleted, or retained as a dormancy stub?** Bias: retained as a dormancy stub mirroring the destination file. Deletion is irreversible without git archaeology; retention is cheap and matches the destination-side treatment.
- [ ] **Does Diagram 5 (Distillation Trigger Composition) need a redraw, or only a label edit?** Verify by reading the diagram source in `docs/architecture/diagrams.md`. If the destinations are enumerated in a label, label edit; if they're separate nodes, redraw.
- [ ] **Does `harness-onboarding` SKILL need an edit?** The skill currently mentions `distilled-learnings.md` as one of three knowledge destinations; if so, it needs the same two-destination update as `cycle-end-distillation.md`.
- [ ] **Is operating-principles.md ready to take the load?** Today's content (§§ 1-8) is already serving the curated-knowledge function. The PRD assumes "yes"; if reviewers disagree, the right response is a follow-up enhancement to operating-principles' structure, not a reversal of this PRD.
- [ ] **Should this PRD include a one-paragraph dormancy note ADDED to `operating-principles.md` explicitly claiming the curated-longitudinal-knowledge role?** Bias: yes, but as a small addition not a restructure — FR-009 captures this conditionally.

## Acceptance Criteria for OPP-0026 → `accepted`

(Mirrors PRD-0007's pattern for OPP promotion-on-PRD-acceptance.)

OPP-0026 flips from `exploring` → `accepted` when:

- PRD-0011 Status flips to `Accepted` (this document)
- FR-001..FR-013 merged (Must Have)
- ADR-0014 Accepted
- All 8 validators green on the implementing PR
- The implementing PR includes a paired observation in `shared-observations.md` confirming the sunset *happened* (closes the audit-trail loop on the rule-#3 removal — the file going dormant)

FR-014..FR-016 (Should Have) can land in the implementing PR or a follow-up; they are not gates for the `accepted` flip.
