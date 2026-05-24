<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0007 — Canonical-Position Artifact as Harness Primitive

**Status:** exploring
**Owner:** @unclenate
**Created:** 2026-05-22
**Last Updated:** 2026-05-24 *(promoted to exploring; PRD-0007 drafted)*
**Confidence:** high

---

## Thesis

Auto-harness's management profiles produce a rich artifact set — problem-statement,
personas, requirements, release-intent, mvp-scope, OPPs, ADRs, a change-log, knowledge
observations. **None of them is the single ratified north-star that every other artifact
must cite and that cannot drift.** Decisions, framings, and assumptions accumulate
across artifacts as independent snapshots of evolving thinking, with no fixed reference
they all align to. The result, observed end-to-end in a real consumer project: artifacts
drift apart, the project loses its own ground truth, and recovery requires a hand-rolled
"canonical position" doc + a multi-day reconciliation cycle.

Introduce a **canonical-position artifact** as a first-class harness primitive — a
required artifact of a management profile (likely a refined `project-standard` or a new
overlay), with a companion-rule contract that every strategy / product / GTM / partnership
artifact declares alignment to it, and that it can be revised only via a ratified
update (not by drift). The artifact closes the gap between "we have an opinion" and "we
have a position." It composes with the other learnings filed alongside it (see Related):
the intake declares which canonical position it was filled against, the opportunity
backlog re-audits when the canonical position changes, the review/reconciliation artifact
type proposes canonical-position revisions, and validator opt-outs name the canonical
position they were granted under.

This is the **highest-leverage single addition** the harness can make against the failure
class observed in `bdits/municipal-brain` — and likely the failure class that drives most
long-running planning projects into the kind of incoherence-recovery cycle that
reconciliation reviews are designed to catch only *after* the damage is done.

## Origin / Evidence

- **Lived evidence — `bdits/municipal-brain` reconciliation, 2026-05-22.** Over roughly
  six weeks the project accumulated a dozen planning documents that asserted three
  different wedges, three platform prices, two funding postures, three competitive maps,
  and three mutually exclusive answers to "which product is the platform." MB-REV-003
  (project alignment audit, four-lens, four parallel agents) named the root cause
  explicitly: *"there has never been a single canonical 'BDITS position' document. Each
  new artifact is written against Nate's latest thinking rather than against a fixed
  reference, and the superseded artifacts are never retired."* The fix was *"to ratify
  one canonical position and make every other document cite it"* — which the project did
  by hand-rolling `docs/BDITS-000-canonical-position.md` (190 lines, the parent of the
  entire reconciled corpus). See `bdits/municipal-brain` at commit `ff953c1`:
  `docs/reviews/2026-05-22-project-alignment-audit.md` §§ 2, 9; `docs/BDITS-000-canonical-position.md`.

- **The harness should have caught this.** Every artifact municipal-brain authored was
  governed by auto-harness companion rules and validators. None of those rules check for
  *alignment to a canonical reference* because no such reference is a first-class
  artifact in the harness's vocabulary. The validators did their job perfectly under the
  contract they were given; the contract didn't include the load-bearing concept.

- **The hand-rolled fix is reproducible — and is structural evidence that the gap is
  real.** BDITS-000 took roughly four hours of MB-REV-001/002/003 four-agent audit work +
  several hours of authorship to ratify. Every consumer project that runs long enough
  will hit the same drift; every one will either invent a hand-rolled equivalent or
  accept the incoherence. Making the artifact a harness primitive moves the work from
  "hand-roll under duress at month six" to "scaffold at module-adopt time, maintain
  continuously."

- **Aspirational prose already exists.** `platform/profiles/management/product-lite/`
  and `platform/profiles/management/discovery-intake/` both reference concepts the
  canonical-position artifact would formalize ("the project's stated direction," "the
  strategic intent the artifacts serve"). Today these references are loose; the
  artifact would be the explicit citable home for them.

- **Aligns with the harness's structural genre.** Auto-harness is the
  governance-harness (per shared-observations entry 2026-05-12) — it gates work against
  rules. A canonical-position artifact is exactly the kind of *reference document* a
  governance-harness should provide rules *against*. The gap is internally consistent
  with the project's positioning, which is itself signal that this is the right primitive.

## Why Now

- **The failure class is producing real cost in real consumer projects today.** The
  `bdits/municipal-brain` reconciliation is one data point but is unlikely to be the
  last. Every long-running multi-document planning project the harness governs faces
  the same drift mechanic; the cost is hidden until reconciliation surfaces it. Filing
  the OPP now anchors the gap so it doesn't keep recurring undocumented.

- **Composability moment with related gaps.** Four sibling observations filed in the
  same session (validator opt-out staleness; opportunity-capture backlog reconciliation;
  formal review artifact type; intake-vs-canonical-direction staleness) all *depend* on
  the existence of a canonical-position artifact to do their proposed job. Filing the
  artifact OPP now establishes the anchor point that the four sibling resolutions will
  refer back to.

- **Auto-harness is at public-launch readiness.** Per OSS cut (ADR-0005, PR #5) the
  framework is moving from internal use to consumer-facing distribution. The earlier
  the canonical-position primitive lands, the more consumer projects inherit it by
  default rather than the current gap.

- **Maintainer recognition.** The municipal-brain reconciliation handoff explicitly
  flagged this as *"the harness's most important missing primitive"* and the *"highest-
  leverage single change."* That maintainer-stated-priority signal is the same kind of
  evidence OPP-0004 used (per its Why Now) — when the maintainer recognizes a structural
  gap, the cost of *not* filing it as an OPP is the cost of forgetting it before
  consumers hit it again.

## Risks / Open Questions

### Module placement

Two viable shapes:

1. **New module — `management/canonical-position`** (or similar). Clean separation; the
   artifact is the module's whole purpose; companion rules and validators are scoped to
   the artifact's lifecycle. Weakness: another module to compose into manifests; risk of
   under-adoption if consumers don't recognize they need it.

2. **Required artifact of an existing module** — likely `project-standard` or a new
   `management/strategic-direction` that extends it. The artifact lives in an already-
   adopted module so every project that uses project-standard inherits the canonical-
   position discipline. Weakness: stretches project-standard's purpose; may conflict
   with project-standard's existing artifacts (scope-plan, milestones, etc.).

Hybrid (recommended at thesis stage; PRD should validate): a new lightweight overlay
module that *depends on* project-standard and adds the single required artifact + the
companion rules around it. Composes by addition rather than retrofit.

### Artifact shape

The artifact needs to balance "ratified position" with "lives at the edge of evolving
thinking." Candidate sections:

- **Identity / entity** (who is this, what does it ship)
- **Wedge / job-to-be-done** (the single replicable thing it does)
- **Two-or-three-product structure** (what's in / out of the product surface)
- **Buyer / motion** (who pays, how)
- **Positioning** (the thing-it-is-not, the thing-it-replaces)
- **Update policy** (how this document gets revised; nothing supersedes it except a
  newer ratified version)

`bdits/municipal-brain`'s BDITS-000 is one shape (190 lines, 10 sections). The PRD pass
should generalize across project shapes — a single-product B2B SaaS, a research-pipeline
project, an internal platform — without forcing a canon-shape mismatch.

### Companion-rule contract

The artifact's value is its citation discipline. Candidate rules:

1. **Strategy / product / GTM / partnership artifacts MUST cite the canonical-position
   artifact** by file path and, ideally, by commit SHA at the time of authorship.
2. **Editing the canonical-position artifact requires a ratification trail** — a review
   artifact (see learning #4 / Observation C in this session) + a change-log entry +
   maintainer-explicit ratification.
3. **Manifest validator opt-outs must name the canonical-position section that grants
   them** — closes the "set-and-forget overrides" failure class (Observation A).

### Composition with other proposed work in this session

This OPP is intentionally the anchor for a set of five sibling observations (filed
concurrently in `docs/knowledge/shared-observations.md`). Each observation's proposed
resolution references this OPP as the central node it connects to:

- **Validator opt-out staleness** (Observation A) — overrides cite a canonical-position
  section that explains the override's basis; when that section changes, the override
  is flagged stale.
- **Opportunity-capture backlog re-audit** (Observation B) — when the canonical-position
  artifact is ratified or substantially revised, the OPP backlog is automatically
  flagged for re-audit; companion rule may demand a re-audit-trail entry.
- **Formal review / reconciliation artifact type** (Observation C) — the review artifact
  is the natural producer of canonical-position revisions; the two artifact types
  compose into a coherent lifecycle (review → propose canonical revision → ratify).
- **Discovery-intake one-shot vs. canonical-direction-changed** (Observation D) — the
  intake declares which canonical-position commit SHA it was filled against; when that
  SHA is superseded, the intake auto-flags stale.
- **Positive patterns** (Observation E) — the salvage-before-archive + ARCHIVE-INDEX
  pattern is the natural way to retire a canonical-position version when it's
  superseded.

The PRD should design the artifact in awareness of these compositions so the v1
implementation lands a coherent system, not a disconnected primitive.

### Risk: over-prescription

The harness's strength is governing structure without prescribing content. The canonical-
position artifact could overreach by demanding specific sections all projects must use.
Mitigation: define the artifact's *role* (single source of truth for strategic
direction) and *companion-rule contract* (must be cited, can only be revised via
ratification); leave the section structure to templates per project shape, similar to
how the harness already handles `requirements.md` and `problem-statement.md`.

### Risk: chicken-and-egg at module adoption

A new module adopting the canonical-position requirement on day one would block
greenfield projects from adopting any other artifact until they've authored a canonical
position. Mitigation: at module-adopt time, a placeholder canonical-position artifact
ships in the templates (similar to current product-lite skeleton artifacts) with
`<!-- TODO -->` markers; the artifact exists structurally before its content is
ratified. The companion rule fires on citation, not on completeness — citing a
placeholder is allowed during early-phase work.

### Risk: scope sprawl

This OPP touches discovery-intake, opportunity-capture, project-standard, possibly
delivery profiles (the canonical position likely informs the maturity / criticality
declarations the manifest already has). PRD scoping needs to decide: v1 = artifact +
citation rule only? v1 = artifact + citation rule + intake-tie-in? v1 = artifact +
all four compositions? The smallest-useful-change discipline applies — but the four
compositions are mutually reinforcing, so v1 may need to be broader than usual to
deliver coherent value.

### Open questions for the PRD pass

- New module vs. addition to project-standard vs. new overlay?
- Required citation form — file path only, or file path + commit SHA?
- How does the artifact compose with `docs/operating-principles.md` (which is *how the
  project works*, not *what the project ships*)? They're complementary but their
  boundary needs to be explicit.
- What does the ratification trail look like — review artifact + change-log + ADR? Or
  a single "ratification" record type?
- Does the artifact carry per-section versioning (allowing partial revisions) or full-
  document versioning (every revision supersedes the previous wholesale)?
- How does this work for project shapes that don't have a clear "strategic position"
  (e.g., an internal tooling library, a research pipeline)? Is the artifact optional
  for those, or does the canon shape gracefully degrade?
- Does adoption require a one-time migration for existing harness-governed projects, or
  is it greenfield-only?

## Disposition

**2026-05-24 (proposed → exploring):** Promoted same-cycle per
established maintainer-priority cadence (consistent with OPP-0004,
OPP-0005, OPP-0006). The "highest-leverage single change" framing
from the municipal-brain handoff + the depend-on-this-anchor
structure of the four sibling observations + the maintainer-stated-
priority signal together justify proceeding to PRD rather than
extending the open-design phase further.

**Direction set** on a **new lightweight overlay module** —
`management/canonical-position` — that depends on `project-standard`
and adds exactly one required artifact (`docs/canonical-position.md`)
plus the citation companion rule + the ratification flow. Hybrid path
from the OPP's module-placement discussion: new module (clean
separation; opt-in adoption) rather than extending project-standard
(stretches its purpose) or building a full-weight strategic-direction
module (premature ambition before adoption signal).

**V1 scope** scoped to deliver coherent value without sprawl:

1. The canonical-position artifact itself + template + module
2. The citation companion rule (strategy-shaped artifacts must cite
   the canonical-position file)
3. The ratification companion rule (editing the canonical-position
   artifact requires a paired review-artifact + change-log entry)
4. The review-artifact type (Observation C) — *bundled into v1 because
   the ratification flow depends on it*; no longer a separate
   follow-up
5. The three "positive patterns" from Observation E promoted to
   `operating-principles.md` as § 9 additions

**Deferred** to follow-up OPPs (each is substantial enough on its own):

- Observation A — validator opt-out staleness pressure (needs
  trust-tier machinery from OPP-0006/PRD-0006 to land first)
- Observation B — opportunity-capture backlog re-audit on canonical
  change (needs canonical-change-detection mechanism)
- Observation D — discovery-intake canonical-SHA pinning (needs the
  artifact + companion rule + intake schema update)

These three follow-up OPPs will reference OPP-0007 as their anchor
when filed. PRD-0007 drafted 2026-05-24 paired with this Disposition
update.

## Promotion

- See [PRD-0007](../requirements/PRD-0007-canonical-position-artifact.md) —
  drafted 2026-05-24; status `Proposed` (acceptance contingent on
  landing the v1 implementation: new `management/canonical-position`
  module + artifact template + citation companion rule + ratification
  flow + review-artifact type from Observation C + § 9 operating-
  principle additions from Observation E).

## Related

- **Sibling observations filed concurrently** in `docs/knowledge/shared-observations.md`:
  - *"Validator opt-out has no staleness pressure"* (Observation A)
  - *"Opportunity-capture has no backlog-reconciliation trigger when the canonical
    direction changes"* (Observation B)
  - *"No formal review/reconciliation artifact type — and the ad-hoc one proved
    high-value"* (Observation C)
  - *"Discovery-intake treats the intake as one-shot; canonical-direction-changed →
    intake-stale path is missing"* (Observation D)
  - *"Three positive patterns to promote to harness conventions"* (Observation E)

- **Evidence repo:** `bdits/municipal-brain` at commit `ff953c1`. Key artifacts:
  - `docs/BDITS-000-canonical-position.md` — the hand-rolled fix.
  - `docs/reviews/2026-05-22-project-alignment-audit.md` — the four-lens audit that surfaced the gap.
  - `docs/reviews/2026-05-22-materials-alignment-review.md` — the M-1..M-4 remediation worked from this gap inward.
  - `docs/project/change-log.md` — the 2026-05-22 cluster of entries documenting the reconciliation.

- **Related harness work:**
  - OPP-0004 (distillation triggers, accepted 2026-05-22) — the closest harness-side
    precedent for a "core function that was assumed to exist but wasn't machinery."
    Canonical-position is similar in shape but bigger in scope.
  - `management/knowledge-capture/README.md` — the canonical-position artifact extends
    the knowledge-capture pattern (durable institutional memory) into the strategic
    layer.
  - `docs/operating-principles.md` — the analogous artifact for *how the harness
    project itself works*; the canonical-position artifact would be the consumer-
    project counterpart.
