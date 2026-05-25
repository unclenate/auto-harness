<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0014: Sunset `distilled-learnings.md` — Consolidate Curated Longitudinal Knowledge in `operating-principles.md`

**Status:** Accepted
**Date:** 2026-05-25
**Author:** @unclenate
**Reviewers:** @unclenate
**Context sources:**

- [OPP-0026](../opportunities/OPP-0026-distilled-learnings-disposition.md) — Disposition: Sunset / Revive / Clarify
- [PRD-0011](../requirements/PRD-0011-distilled-learnings-disposition.md) — Sunset `distilled-learnings.md` (the design)
- [QUALITY-AUDIT-2026-05-25-documentation-refresh.md](../QUALITY-AUDIT-2026-05-25-documentation-refresh.md) finding M8 — "review cadence ~7 months stale"
- Paired observations in `docs/knowledge/shared-observations.md`:
  - *"Declared knowledge surfaces without an inbound-flow trigger silently die; operating-principles ate distilled-learnings' lunch"* (2026-05-25)
  - *"Sunsetting a declared-but-unused mechanism must rule out replicating the failure mode at the surviving destination"* (2026-05-25)

## Context

`docs/knowledge/distilled-learnings.md` was added on 2026-04-16 as one
of three knowledge destinations declared by `management/knowledge-capture`
v1.0.0 (alongside `shared-observations.md` and the project's own
knowledge README). It was conceived as the curated longitudinal
synthesis destination — observations that crystallized into durable
institutional knowledge would be promoted here during dedicated review
sessions.

Forty days later, the file has **zero content entries.** The 64-line
template scaffold has not changed. During that same window:

- `shared-observations.md` grew from empty to 1,377 lines (~70 entries)
- `operating-principles.md` acquired §§ 7 and 8 — exactly the
  cross-observation synthesis distilled-learnings was supposed to host

The audit (2026-05-25) flagged the staleness as cosmetic finding M8.
The investigation triggered by the maintainer's mid-bundle question
*"when does the process trigger to generate distilled learnings happen?
distilled-learnings.md seems way behind and it doesn't seem to be
triggered by anything? Does it get read by anything?"* revealed the
gap is structural, not cosmetic:

1. **No forcing trigger exists.** PRD-0004's cycle-end distillation
   rule lists distilled-learnings.md as one of three acceptable
   satisfiers, but `cycle-end-distillation.md` explicitly tells authors
   *not* to write to it opportunistically — it is reserved for
   "dedicated review sessions" that nothing schedules.

2. **The audit-trail rule never fires.** The companion rule that gates
   edits to `distilled-learnings.md` (`knowledge-capture` rule #3,
   requiring a review-log satisfier) has not fired in 40 days because
   no commit has touched the file.

3. **`operating-principles.md` is the de facto curated destination.**
   Cross-observation synthesis — exactly distilled-learnings'
   declared charter — is happening in operating-principles instead.
   §§ 7 and 8 are concrete examples; the cadence is "promote when the
   pattern crystallizes," driven by evidence accumulating in
   shared-observations.

4. **Operating-principle § 7** (*Align File Boundaries with Change-Class
   Boundaries*) — adopted by this project for exactly this kind of
   gap — explicitly argues that two destinations whose change-classes
   have collapsed into one should not remain two destinations.

This is the *intra-repo* sibling of the cross-repo silent-declaration
pattern recorded the same session (paired with OPP-0025): a *declared
surface* with no inbound-flow trigger silently fails as a destination,
and the failure is invisible because no validator catches it. The
declared `requiredArtifact` is itself the gap.

## Decision

**Sunset `docs/knowledge/distilled-learnings.md`.** Consolidate the
curated-longitudinal-knowledge function in `docs/operating-principles.md`.

Concretely:

1. Remove `docs/knowledge/distilled-learnings.md` from the
   `management/knowledge-capture` module's `requiredArtifacts`.
2. Remove `^docs/knowledge/distilled-learnings\.md$` from the
   cycle-end-distillation rule's `requiredAny` satisfier list (rule #4)
   — leaving two destinations (`shared-observations.md`,
   `operating-principles.md`).
3. Remove the audit-trail rule (rule #3) that gates edits to
   `distilled-learnings.md`.
4. Remove the `sensitivePaths` block for `distilled-learnings.md`.
5. Rewrite `docs/knowledge/distilled-learnings.md` as a **one-paragraph
   dormancy pointer** to `docs/operating-principles.md`. Preserves
   external referenceability; signals dormancy honestly. Mirror this
   on the template side (`platform/templates/knowledge/distilled-learnings.md`).
6. Update `platform/workflow/cycle-end-distillation.md`'s satisfier
   decision tree from three destinations to two.
7. Update the `knowledge-capture` README, `docs/knowledge/README.md`,
   `HARNESS.md` knowledge surfaces table, Diagram 5 (Distillation
   Trigger Composition), and the harness skill references to match.
8. Add a one-paragraph note to `docs/operating-principles.md` claiming
   the curated-longitudinal-knowledge role explicitly.

`shared-observations.md` continues to function unchanged as the
default cycle-end-distillation destination.

## Alternatives Considered

**Option B — Revive with a forcing trigger.** Add a time-based,
count-based, or audit-based companion rule that schedules curation
sessions and forces distilled-learnings.md to be updated.

*Rejected* because the failure mode that killed distilled-learnings is
specifically *declared triggers nobody adopts*. Adding upstream
pressure to operating-principles.md ("quarterly review", "every N
observations triggers a check") would be just as synthetic as the
trigger that failed at distilled-learnings. operating-principles'
current "promote when the pattern crystallizes" cadence is healthy
because the promotion *is driven by real evidence accumulating in
shared-observations.md*, not by clock or count. Recreating the
synthetic-trigger failure mode against a different destination is
exactly what the paired observation warns against.

**Revisit if:** operating-principles itself shows staleness symptoms
after 6+ months (no new sections added despite continued observation
accumulation that should crystallize). Until then, the evidence-driven
cadence works.

**Option C — Clarify dormant pending established cadence.** Keep the
file and the companion rules as-is, but update `docs/knowledge/README.md`
and `cycle-end-distillation.md` to say *"distilled-learnings.md is
dormant pending an established curation cycle; operating-principles is
the primary curated surface today."*

*Rejected* because leaving a declared `requiredArtifact` that the
project agrees not to use is worse than removing it. It signals to
consumer projects that they should have one too, when the right signal
is "operating-principles is the surface; the dormant historical file is
preserved for reference." Declared-but-not-used is the silent-failure
mode this ADR removes, not labels around.

**Revisit if:** evidence emerges that the dormant-pointer approach
causes confusion (consumer reports of breakage, audit findings of
ambiguity) such that explicit labeling would be clearer than removal.

## Consequences

### Positive

- The declared surface of `management/knowledge-capture` matches its
  actual practice. The audit's M8 finding moves from "open" to
  "resolved by removal."
- `cycle-end-distillation.md` decision tree shows one curated
  destination, not two — newcomers and agents stop having to disambiguate.
- Operating-principle § 7's discipline is exercised on the project's
  own machinery, not just imposed on consumers.
- The dormancy stub preserves external-link safety with negligible
  maintenance cost.
- The companion-rule count drops by one (rule #3); the cycle-end
  satisfier set shrinks by one. Both reduce surface area.

### Negative

- Loss of the *theoretical* distinction between
  "curated longitudinal synthesis" (distilled-learnings) and "durable
  how-this-project-works truth" (operating-principles). In practice
  the distinction never materialized, but the theoretical clarity is
  gone.
- Future projects with a genuine need for a *separate* curated-synthesis
  destination (distinct from durable principles) will need to file a
  new OPP to reintroduce one — they cannot fall back on this module's
  declared surface.
- Consumer projects with `knowledge-capture` active that *were*
  populating distilled-learnings (if any exist outside auto-harness
  itself) will see the file drop from `requiredArtifacts` and may
  experience their own staleness pressure differently.

### Neutral

- `shared-observations.md` is unchanged. Its inflow is healthy.
- The cycle-end distillation rule (PRD-0004 v1) is unchanged in
  *shape* — only the satisfier set changes. The rule continues to fire
  on the same trigger paths.

## Implementation Notes

This ADR is paired with [PRD-0011](../requirements/PRD-0011-distilled-learnings-disposition.md),
which enumerates 13 must-have FRs that operationalize the decision.
ADR-0014 records *what* and *why*; PRD-0011 records *the spec*; the
implementing PR ships *the how*.

The implementation is intentionally non-breaking: removal from
`requiredArtifacts` is a softening of the module contract, not a
tightening. Consumer projects upgrading to the new module version
will see one fewer required file, never an additional one.

The PRD's Option B / Option C rejections include explicit revisit
triggers; this ADR preserves them as supersession criteria. If those
triggers fire, a new ADR superseding this one is the correct path
forward — not a silent reversal.

## Related

- [PRD-0011](../requirements/PRD-0011-distilled-learnings-disposition.md) — the spec this ADR formalizes
- [OPP-0026](../opportunities/OPP-0026-distilled-learnings-disposition.md) — the originating opportunity record
- [PRD-0004](../requirements/PRD-0004-distillation-triggers.md) — the cycle-end-distillation rule this ADR shrinks the satisfier list of
- [ADR-0002](ADR-0002-knowledge-capture-structured-observations.md) — the foundational Observation Structure choice (unchanged by this ADR; observations remain the default destination)
- Operating principles: § 7 (Align File Boundaries with Change-Class Boundaries) — the load-bearing argument for this ADR
- Audit finding M8 — `docs/QUALITY-AUDIT-2026-05-25-documentation-refresh.md`
