<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0026 — `distilled-learnings.md` Disposition (Sunset, Revive, or Clarify)

**Status:** exploring
**Owner:** @unclenate
**Created:** 2026-05-25
**Last Updated:** 2026-05-25 *(filed as OPP-0024 in working tree; renumbered to OPP-0026 after PR #59 took the OPP-0023 slot — same session, same renumbering cascade. Promoted `proposed` → `exploring` same-day per the maintainer-priority cadence; [PRD-0011](../requirements/PRD-0011-distilled-learnings-disposition.md) drafted committing to Option A — Sunset.)*
**Confidence:** high (on the diagnosis); high (on Option A as the disposition, committed in PRD-0011)

---

## Thesis

`docs/knowledge/distilled-learnings.md` has been a 64-line shell since the
day the `management/knowledge-capture` module was first added on 2026-04-16.
**Zero content entries in 40 days.** The file is declared as a
`requiredArtifact` of the knowledge-capture module and is one of three
acceptable destinations for the cycle-end distillation trigger rule
(PRD-0004), but it has no *forcing* trigger of its own — only an
audit-trail rule that fires *if* it is edited, and the workflow doc
explicitly tells authors *not* to write to it opportunistically:

> "Don't write directly to `distilled-learnings.md` to satisfy the trigger
> rule. That file has its own audit-trail rule requiring a review-log
> satisfier. **Promote observations to learnings during dedicated review,
> not opportunistically.**"
> — `platform/workflow/cycle-end-distillation.md:86-89`

Nothing schedules the dedicated review sessions. In practice,
`docs/operating-principles.md` has **absorbed the charter** — §§ 7 and 8
were added this session (2026-05-23 and 2026-05-24) as exactly the kind
of cross-observation synthesis distilled-learnings was supposed to host.
The 2026-05-24 documentation audit flagged the staleness as finding M8
("review cadence ~7 months stale") but treated it as a status-drift
cosmetic. The investigation that produced this OPP (mid-bundle,
2026-05-25) revealed it is structural, not cosmetic.

**Three viable dispositions:**

- **Option A — Sunset.** Drop `distilled-learnings.md` from the
  knowledge-capture module's `requiredArtifacts`, drop it from the
  cycle-end-distillation rule's `requiredAny` satisfier list, remove the
  audit-trail rule that gates its edits, and update
  `cycle-end-distillation.md` + `docs/knowledge/README.md` to name
  `operating-principles.md` as the canonical curated-knowledge surface.
  The actual file would either be deleted or retained as a stub pointing
  at operating-principles.

- **Option B — Revive.** Add a *forcing* trigger that schedules curation
  sessions. Candidates: (i) time-based — a companion rule that fires
  every quarter (e.g., "the `Last Updated` date in distilled-learnings.md
  must be within 90 days of HEAD's commit date when `ADR-*` or `OPP-*`
  files are modified"); (ii) count-based — fires when
  shared-observations.md grows by N entries since the last
  distilled-learnings update; (iii) audit-based — every quality audit
  (`QUALITY-AUDIT-*.md`) must include a one-paragraph distillation
  ratification or note that no entries crystallized. Each adds machinery;
  PRD-pass would pick one.

- **Option C — Clarify.** Update `docs/knowledge/README.md` +
  `cycle-end-distillation.md` to say *"distilled-learnings.md is dormant
  pending an established curation cycle; operating-principles is the
  primary curated surface today"*. Cheapest move; preserves optionality
  for a future revive; honest about current practice. Does not fix the
  underlying gap, just labels it.

Initial bias: **Option A**. The evidence is strong that
operating-principles has eaten the charter. Two surfaces serving the
same function is harder to govern than one, and the project's own
operating-principle § 7 ("Align File Boundaries with Change-Class
Boundaries") argues against keeping two destinations whose change-classes
have collapsed into one. But this is a governance-policy decision the
maintainer should rule on — the OPP exists to surface the question, not
to predetermine the answer.

## Origin / Evidence

- **Maintainer question, 2026-05-25 (mid-bundle):** *"when does the
  process trigger to generate distilled learnings happen?
  distilled-learnings.md seems way behind and it doesn't seem to be
  triggered by anything? Does it get read by anything?"* The investigation
  that answered the question surfaced the gap and motivated this OPP.
- **Documentation audit M8 (2026-05-24):** *"`distilled-learnings.md`
  shows a review cadence ~7 months stale."* Audit-confirmed staleness.
  Treated as cosmetic in the audit; this OPP reframes it as structural.
- **File-level evidence:** `git log` on `docs/knowledge/distilled-learnings.md`
  shows one commit — the module's initial creation. `wc -l` is 64 lines,
  the size of the empty template. Same `wc -l` for
  `docs/knowledge/shared-observations.md` is 1,218+ lines and rising.
- **Charter-collision evidence:** operating-principles.md gained §§ 7 and
  8 in the last 72 hours (2026-05-23 and 2026-05-24), each generalizing
  ~3 prior observations into durable principles. That is exactly the
  curation distilled-learnings.md was supposed to host. The de-facto
  workflow is *observation → operating-principles* with
  distilled-learnings absent from the loop.
- **Audit-trail rule firing pattern:** the knowledge-capture module's
  rule #3 (distilled-learnings edits require review-log satisfier) has
  not fired in 40 days because no commit has touched the file.
  rule #1 (shared-observations edits require change-log or daily memory)
  fires constantly — dozens of times per session. Asymmetry in firing
  rates is the structural signal.
- **Paired observation:** *"Declared knowledge surfaces without an
  inbound-flow trigger silently die; operating-principles ate
  distilled-learnings' lunch"* in
  `docs/knowledge/shared-observations.md` (appended this session).
  Frames the gap as the *intra-repo* sibling of the
  cross-repo-silent-declaration pattern that motivates OPP-0025 — same
  architectural root cause, two different surface manifestations.

## Why Now

Three converging signals:

1. **The audit caught it as M8** but mislabeled the severity.
2. **The maintainer noticed independently** when investigating the
   distillation flow mid-bundle — second instance of the concern reaching
   conscious attention.
3. **operating-principles.md just acquired two more sections** (§§ 7
   and 8 this session), making the charter-collision evidence concrete.
   Each new operating-principles section is one more piece of evidence
   that distilled-learnings is not where the work is happening.

Continuing to declare a surface that is not being used misleads future
contributors about what the project actually practices. The
discipline-cost of resolving this is low (a small module.yaml edit + a
workflow-doc update); the cost of letting it sit is governance-debt that
compounds.

## Risks / Open Questions

1. **Is operating-principles.md the right umbrella, or are
   distilled-learnings and operating-principles legitimately distinct
   change-classes?** The cycle-end-distillation workflow doc draws a
   distinction: operating-principles is for *"durable how-this-project-works
   truth applicable to all future work"*; distilled-learnings is for
   *"synthesis of multiple prior observations into curated knowledge."*
   In theory those differ. In practice §§ 7 and 8 do both. PRD-pass
   should decide whether the theoretical distinction is worth preserving.
2. **If sunset, what happens to the existing 64-line shell file?**
   Options: (a) delete it; (b) retain as a 1-line redirect stub
   ("Curation now happens in operating-principles.md; see git history
   pre-2026-05 for the original charter"). Bias toward (b) — historical
   pointers are cheap and prevent broken links from external references.
3. **If revive, which forcing trigger?** Time-based has the cleanest
   semantics but the highest false-positive rate. Count-based ties to
   actual back-pressure but is harder to specify. Audit-based piggybacks
   on existing review cadence but only fires when audits happen. PRD-pass
   should weigh.
4. **Does the cycle-end-distillation rule's three-destination satisfier
   list change if Option A wins?** Yes — drop the third entry, leaving
   shared-observations and operating-principles. The rule fires the same;
   the satisfier set is smaller.
5. **Is there any downstream consumer of distilled-learnings.md content
   that would break if Option A wins?** Investigation found: no skill
   loads it at session start; no validator depends on its content; the
   harness-onboarding skill references it as one of three knowledge
   destinations but does not require content. The downstream surface
   is documentation-only; sunset is non-breaking.
6. **Should Option B's revive trigger be a `knowledge-capture`
   companion rule, or a standalone validator?** Companion rule keeps
   the trigger close to the rest of the knowledge-capture governance;
   validator gives more flexibility for cross-file conditions. Bias
   toward companion rule.
7. **What about the deeper "session-cycle orchestration gap" the
   investigation surfaced?** That is genuinely bigger than this OPP and
   is captured separately as a candidate stub in
   `docs/opportunities/candidates.md` (cluster: *"Session-cycle
   orchestration / review-trigger taxonomy"*). This OPP's disposition
   should not block on the broader question — distilled-learnings.md's
   fate can be decided narrowly, and the broader work either composes
   on top (if revive wins) or becomes simpler (if sunset wins).

## Disposition

**2026-05-25 — `proposed` → `exploring`.** Promoted same-day per the
established maintainer-priority cadence (the OPP-0004/0005/0006/0007
pattern). Direction committed: **Option A — Sunset.** Evidence
strongly favors: 40 days of zero inbound flow,
`operating-principles.md` has *de facto* absorbed the
curated-knowledge charter (§§ 7 and 8 added this session are exactly
the cross-observation synthesis distilled-learnings was supposed to
host), and operating-principle § 7 itself explicitly argues against
keeping two destinations whose change-classes have collapsed into
one. Option B (revive with a forcing trigger) and Option C (label
dormant pending established cadence) were both weighed and rejected
for v1; PRD-0011 records the rejection rationale and the triggers
that would justify revisiting either.

[PRD-0011 — Sunset distilled-learnings.md](../requirements/PRD-0011-distilled-learnings-disposition.md)
drafted as the paired design, covering 13 must-have FRs (module.yaml
edits, workflow-doc updates, dormancy stub for the file itself, ADR-0014
as the decision record, knowledge README + HARNESS.md + cycle-end
workflow updates) plus 3 should-have FRs (template-side mirror,
templates README update, optional review-log entry).

Acceptance criteria for OPP-0026 → `accepted` mirrors PRD-0007's
pattern: PRD-0011 Accepted, FR-001..FR-013 merged, ADR-0014 Accepted,
validators green, and a paired observation in `shared-observations.md`
confirming the sunset.

## Promotion

See [`docs/requirements/PRD-0011-distilled-learnings-disposition.md`](../requirements/PRD-0011-distilled-learnings-disposition.md).
