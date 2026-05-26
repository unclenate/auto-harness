<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0032 — Session-Cycle Orchestration and Review-Trigger Taxonomy

**Status:** exploring
**Owner:** @unclenate
**Created:** 2026-05-25
**Last Updated:** 2026-05-25 *(promoted from candidate-stub in `candidates.md` after a second concrete instance accumulated. Same-day flip `proposed` → `exploring` per the established maintainer-priority cadence; [PRD-0013](../requirements/PRD-0013-session-cycle-orchestration.md) drafted committing to the workflow-doc-only v1 scope.)*
**Confidence:** medium-high *(diagnosis); high (on the workflow-doc-only v1 scope; per-rule companion-rule decisions deferred to follow-up OPPs/PRDs)*

---

## Thesis

Auto-harness has accumulated powerful enforcement machinery — companion
rules at PR boundary, validators (8 of them), Stop-event hook adapters,
audit-trail rules, cycle-end distillation triggers — but **no defined
"optimal session shape" with review checkpoints that systematically
fire them.** A session might add ten shared-observations, ship a PRD,
and merge — but never run the promotion-candidate scan that
operating-principles benefits from, never check whether the second-pass
onboarding framing would surface new gaps, never audit the back-pressure
between observation accumulation and synthesis.

The automations exist. The *cadence that consumes their output* is
underspecified.

Two concrete instances surfaced this gap in one session (2026-05-25):

1. **Distilled-learnings dormancy** (resolved by ADR-0014 / PRD-0011):
   the file went 40 days with zero inbound flow because the
   "dedicated review sessions" it depended on were never scheduled.
   The forcing trigger that should have driven curation didn't exist.
2. **Tula two-pass discovery** (paired observation, 2026-05-25):
   the first brownfield onboarding pass against Tula caught the
   product-shape gaps but missed the platform-layer gaps entirely.
   The "orthogonal-framing second pass" that surfaced the missing
   cluster was not scheduled — it happened only because the maintainer
   noticed the gap on re-read of the README. No automation prompted
   for it.

Both are instances of the same class: **declared review processes that
no automation fires.** The harness has the trigger primitives
(companion rules, hooks, audit-trail rules); what it lacks is a
**taxonomy of session-boundary review checkpoints** and a workflow
that names which automation fires at each.

Add **OPP-0032 — Session-Cycle Orchestration and Review-Trigger
Taxonomy** to surface this as a substantive design space. The v1
shape — pending PRD-pass — is a new workflow doc plus a structured
review-trigger taxonomy that names:

- **What checkpoints exist** in an ideal session cycle (session
  start, work, PR open, PR merge, post-merge, periodic-review,
  external-event-driven)
- **Which automations fire at each checkpoint** (Stop-event hooks,
  companion rules, validators, manual reviews)
- **Which reviews are declared but unfired** (the gap class — the
  "second-pass onboarding," the "operating-principles
  promotion-candidate scan," the "knowledge-tree back-pressure
  audit")
- **What forcing mechanism each unfired review needs** (companion
  rule, scheduled CI workflow, agent-skill prompt, audit cadence)

Output candidates for v1: a new `platform/workflow/session-shape.md`
covering the full session arc; a taxonomy section in
`platform/workflow/cycle-end-distillation.md` (existing) covering only
the PR-boundary slice; possibly extensions to `harness-onboarding`
SKILL.md prompting for framing questions explicitly; possibly new
companion rules for currently-unfired reviews.

## Origin / Evidence

- **Maintainer framing during the OPP-0024/0026 investigation (2026-05-25):**
  *"It may warrant further investigation because it seems that there's
  an as yet undefined optimal set of process steps for a session, and
  we are missing reviews that could be triggering these powerful
  automations we've designed."* Recorded verbatim in `candidates.md`
  under the candidate-stub paragraph that this OPP promotes.
- **First instance — distilled-learnings dormancy** (see
  [OPP-0026](OPP-0026-distilled-learnings-disposition.md),
  [ADR-0014](../adr/ADR-0014-sunset-distilled-learnings.md),
  [PRD-0011](../requirements/PRD-0011-distilled-learnings-disposition.md),
  and the paired observation *"Declared knowledge surfaces without an
  inbound-flow trigger silently die; operating-principles ate
  distilled-learnings' lunch"* in `shared-observations.md`, 2026-05-25):
  a declared review process ("dedicated review sessions") that no
  automation fired. The disposition was to sunset the surface, but
  the underlying review process — *promotion of accumulated
  observations into operating-principles* — still happens; it just
  happens *ad-hoc, when the maintainer notices*. That ad-hoc-ness is
  exactly the gap.
- **Second instance — Tula two-pass discovery** (see
  [OPP-0027](OPP-0027-frontier-agent-posture.md) and the paired
  observation *"Brownfield catalog gaps surface in layers — the
  first profile pass catches product-shape gaps; a second pass
  catches platform-layer gaps"* in `shared-observations.md`,
  2026-05-25): a declared review process ("orthogonal-framing
  second pass for non-trivial consumers") that no automation
  scheduled. The second pass happened only because the maintainer
  re-read the Tula README and noticed the gap. The
  `harness-onboarding` SKILL doesn't prompt for it; no companion
  rule fires on the first-pass OPP filing demanding a second-pass
  review.
- **The pattern is structural, not idiosyncratic.** Both instances
  share the *same shape*: a review process declared in prose, with
  a clear forcing-mechanism need, but no automation actually fires
  it. The cycle-end-distillation rule (PRD-0004) is the *positive*
  case of this pattern — declared review with a fired trigger. The
  promotion-candidate scan and the second-pass onboarding are the
  *negative* cases.
- **Adjacent positive evidence.** The cycle-end-distillation rule
  worked end-to-end on PRs #60, #61, #62 — fired the trigger,
  forced the distillation, caught CI when the trigger was
  initially mis-judged. The pattern *works when it exists*. The
  question is which other declared reviews would benefit from
  similar machinery.
- **The harness's own enforcement machinery is uniquely
  well-positioned for this work.** Auto-harness already has the
  primitives: companion rules can target trigger paths; hooks can
  fire on session events; validators can scheduled-run in CI;
  agent skills can prompt at session boundaries. The gap is
  *deciding which review wants which primitive*, not *building new
  primitives*.

## Why Now

- **Two clean instances in one session.** Both instances surfaced
  *within hours of each other*; the convergence is itself evidence
  the pattern is real and recurring.
- **The candidate-stub in `candidates.md` was held pending a second
  instance.** That gate just cleared. Per the stub's own
  promotion-criterion text: *"Promoted from candidate-stub to OPP
  when a second concrete instance of 'declared review without a
  trigger' surfaces independently."*
- **The cycle-end distillation rule (PRD-0004) just demonstrated
  the positive pattern at production scale this session.** Three
  PR-boundary firings, three substantive distillations forced into
  being. The harness has a successful template to follow for the
  other unfired reviews.
- **The next round of OPP→PRD work (PRD-0007 canonical-position,
  PRD-0006 trust-tier-enforcement, the OPP-0027..0031 cluster) will
  exercise session-boundary review pressure heavily.** Naming the
  taxonomy now gives those future PRDs a coherent vocabulary to
  cite rather than each reinventing the framing.

## Risks / Open Questions

1. **Scope: workflow-doc-only, or workflow + new companion rules?**
   Initial bias: workflow-doc-only at v1 (taxonomy + named
   checkpoints + declared unfired reviews), with explicit per-rule
   PRD passes for any new companion rules the taxonomy
   recommends. Avoids the "ship a taxonomy and four new rules in
   one PR" failure mode; preserves the OPP→PRD→implementation
   cadence per rule.
2. **Where does the taxonomy live?** Options: (a) extend
   `cycle-end-distillation.md` to cover the full session arc (not
   just cycle-end); (b) new `platform/workflow/session-shape.md`
   as a peer doc; (c) section in `harness-governance/SKILL.md`.
   Bias: (b) — a peer workflow doc; the cycle-end doc stays
   focused on its specific trigger pattern, and the session-shape
   doc covers the umbrella.
3. **Which unfired reviews land in v1's taxonomy vs. defer to v2?**
   Bias: name *all currently-declared-but-unfired* reviews in v1
   (audit them out of `cycle-end-distillation.md`,
   `harness-onboarding/SKILL.md`, the knowledge-capture README,
   and the operating-principles file); decide per-review whether to
   propose machinery at v1 or defer.
4. **Should second-pass onboarding be required, recommended, or
   optional?** Bias: *recommended for non-trivial consumers; the
   `harness-onboarding` SKILL prompts for the framing question and
   recommends a second pass; the consumer decides*. Required would
   over-trigger; optional with no prompt would under-fire.
5. **What about reviews that are *fired but ineffective*?** E.g.,
   the cycle-end distillation rule fires, but if the satisfier is
   cargo-cult (an unrelated observation appended), the review
   technically fires while serving no function. This is a different
   gap (review quality, not review firing); defer to a separate OPP
   if evidence accumulates.
6. **Does this overlap with OPP-0006 trust-tier-enforcement?**
   Tangentially: trust-tier and session-cycle-orchestration both
   involve "what enforcement fires when." They are orthogonal —
   trust-tier is about *which capabilities are permitted at which
   tier*, session-cycle is about *which reviews fire at which
   checkpoint*. PRD-pass should explicitly note the separation.
7. **What about reviews that are *fired automatically but not
   substantive enough*?** E.g., a hypothetical "weekly skill-pack
   audit" cron that runs but produces no actionable output. This
   is the same review-quality gap as Q5; defer.
8. **Does this become an *operating-principle* eventually?** Possibly
   yes, if the taxonomy lands and proves load-bearing — a candidate
   for operating-principles § 9 in the spirit of "every declared
   review needs a forcing mechanism, or it silently dies." Defer
   the principle promotion until at least one v1 review the
   taxonomy names has been implemented and shown to work.

## Disposition

**2026-05-25 — `proposed` → `exploring`.** Same-day promotion per the
established maintainer-priority cadence (OPP-0004/0005/0006/0007/0026
pattern). Direction committed: **workflow-doc-only v1 scope.** The
taxonomy itself is the v1 deliverable; per-rule companion-rule
decisions are explicitly deferred to follow-up OPPs/PRDs. Rejection
rationale captured in PRD-0013's Out of Scope section: shipping
taxonomy + multiple new companion rules in one PR conflates *design
work* (deciding which review wants which primitive) with
*implementation work* (writing the regex, the satisfier set, the
human-review text). The OPP→PRD→implementation cadence the project
relies on works *per discrete change-class*; bundling rule
implementations with the taxonomy that motivates them blurs the
boundary.

[PRD-0013 — Session-Cycle Orchestration and Review-Trigger Taxonomy](../requirements/PRD-0013-session-cycle-orchestration.md)
drafted as the paired design, covering 9 must-have FRs: new workflow
doc, taxonomy section, audit of currently-declared-but-unfired
reviews, per-review trigger-class classification, positive-template
cross-reference, evidence cross-references, explicit deferrals of
per-rule machinery, recommended sequencing of follow-up OPPs.

Acceptance criteria for OPP-0032 → `accepted`: PRD-0013 Accepted +
FR-001..FR-009 merged + at least one of the named follow-up reviews
graduates to a filed OPP/PRD pair within the next 30 days (validates
that the taxonomy is *load-bearing* and not just descriptive prose).

## Promotion

See [`docs/requirements/PRD-0013-session-cycle-orchestration.md`](../requirements/PRD-0013-session-cycle-orchestration.md).

## Related

- Originating candidate-stub: `docs/opportunities/candidates.md` §
  *"Session-cycle orchestration & review-trigger taxonomy"* (now
  removed; replaced with the standard OPP-row pointer)
- First instance: [OPP-0026](OPP-0026-distilled-learnings-disposition.md) +
  [ADR-0014](../adr/ADR-0014-sunset-distilled-learnings.md) +
  [PRD-0011](../requirements/PRD-0011-distilled-learnings-disposition.md)
- Second instance: [OPP-0027](OPP-0027-frontier-agent-posture.md) cluster
  plus the *"Brownfield catalog gaps surface in layers"* observation
- Positive-template reference: [PRD-0004 — Distillation Triggers](../requirements/PRD-0004-distillation-triggers.md)
  (the cycle-end-distillation rule is the worked example of a successful
  declared-review-with-fired-trigger pattern)
- Workflow surface most likely to host the taxonomy:
  [platform/workflow/cycle-end-distillation.md](../../platform/workflow/cycle-end-distillation.md),
  with a possible new peer `platform/workflow/session-shape.md`
- Related operating-principles: § 3 (Documentation as Part of the
  Change), § 7 (Align File Boundaries with Change-Class Boundaries)
