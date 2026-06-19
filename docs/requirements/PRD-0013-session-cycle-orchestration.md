<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0013: Session-Cycle Orchestration and Review-Trigger Taxonomy

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-19 *(`Proposed` → `Accepted`: FR-001..FR-009 (Must Have) + FR-010..FR-011 (Should Have) implemented as `platform/workflow/session-shape.md`; OPP-0032 flipped to `accepted`.)* | **Review Cycle:** On-change

**Status:** Accepted
**Date:** 2026-05-25 (filed)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Related OPP: [OPP-0032](../opportunities/OPP-0032-session-cycle-orchestration.md) — `exploring`; this PRD is its promotion candidate
- Originating evidence (paired observations):
  - *"Declared knowledge surfaces without an inbound-flow trigger silently die; operating-principles ate distilled-learnings' lunch"* (`shared-observations.md`, 2026-05-25) — first instance
  - *"Brownfield catalog gaps surface in layers — the first profile pass catches product-shape gaps; a second pass catches platform-layer gaps"* (`shared-observations.md`, 2026-05-25) — second instance
  - *"The candidate-stub-to-OPP promotion gate worked end-to-end on first firing"* (`shared-observations.md`, 2026-05-25) — meta-observation about the promotion-gate that produced OPP-0032
- Positive-template reference: [PRD-0004 — Distillation Triggers](PRD-0004-distillation-triggers.md) — the cycle-end-distillation rule (currently the only fired declared review at PR boundary; this PRD's taxonomy generalizes the pattern to other checkpoints)
- Related ADRs (anticipated): possibly ADR-0015 if the taxonomy becomes load-bearing enough to lock; deferred until after the workflow doc lands and at least one follow-up review graduates
- Related modules: `management/knowledge-capture` v1.2.0 (the home of the cycle-end-distillation rule); `management/opportunity-capture` (the home of the candidate-stub-with-promotion-criterion pattern); `harness-onboarding` SKILL (recommended for the framing-question prompt that the layered-brownfield observation surfaces)
- Related operating-principles: § 3 (Documentation as Part of the Change), § 7 (Align File Boundaries with Change-Class Boundaries)

## Overview

Auto-harness has accumulated a substantial set of enforcement
primitives — companion rules at PR boundary, validators (8 of them),
Claude Code Stop-event hook adapters, audit-trail rules, the
cycle-end distillation trigger — and one demonstrably-working
declared-review-with-fired-trigger pair (PRD-0004 → cycle-end rule).
But several other *declared review processes* exist in the codebase
with no automation firing them: the operating-principles
promotion-candidate scan, the second-pass brownfield onboarding
against a different framing question, the knowledge-tree
back-pressure audit, the candidate-stub-with-promotion-criterion
gate, and possibly more.

The gap is not "we need more enforcement primitives." The harness
*has* the primitives — companion rules can target trigger paths,
hooks can fire on session events, validators can run scheduled in
CI, agent skills can prompt at session boundaries. The gap is
**deciding which review wants which primitive, at which
session-boundary checkpoint, with what evidence-bar firing it**.

This PRD specifies v1 as **workflow-doc-only**: a new
`platform/workflow/session-shape.md` peer to
`cycle-end-distillation.md` that produces a **taxonomy of
session-boundary review checkpoints**, audits *currently-declared-but-
unfired reviews* across the codebase, classifies each by the
trigger-class that would fire it correctly, and explicitly defers
per-rule companion-rule machinery to follow-up OPPs/PRDs.

The deferral is load-bearing. Shipping the taxonomy and four new
companion rules in one PR would conflate two distinct change classes
that operating-principle § 7 explicitly argues against bundling: the
*design work* of deciding which review wants which primitive is one
class; the *implementation work* of writing each rule's regex,
satisfier set, and human-review text is a different class. Per-rule
PRD passes preserve the OPP→PRD→implementation cadence the project
has used successfully five times this session.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- Produce a single canonical workflow doc that names the
  session-boundary checkpoints, the trigger-class taxonomy, and the
  audit of currently-declared-but-unfired reviews.
- Make declared-but-unfired reviews *visible* — every such review
  currently buried in workflow docs, module READMEs, and skill files
  gets a line in the audit section.
- Classify each unfired review by the trigger-class that would fire
  it correctly (PR-boundary / session-boundary / time-boundary /
  count-boundary / audit-boundary / external-event-driven).
- Recommend a sequencing for the follow-up OPPs that would implement
  each — without committing to any of them in this PRD.
- Cite the cycle-end-distillation rule (PRD-0004) as the
  positive-template reference and explain *why* it works (declared
  review + fired trigger + evidence-bar in the trigger paths).

**Non-Goals** — outcomes explicitly out of scope:

- **Implementing any new companion rule.** *(Why excluded: the
  failure mode this PRD avoids — conflating design work with
  implementation work in one PR — is the exact pattern operating-
  principle § 7 names. Each new rule warrants its own OPP→PRD pass.)*
- **Modifying any existing companion rule.** *(Why excluded: the
  cycle-end-distillation rule, the audit-trail rules, the various
  module-specific rules are all stable. The taxonomy *catalogs* them;
  it does not refactor them.)*
- **Auditing review *quality* (cargo-cult satisfier risk).** *(Why
  excluded: a declared review that fires but produces shallow
  satisfaction is a different gap class. This PRD scopes to
  fired-vs-unfired; quality-of-firing is a separate follow-up
  candidate.)*
- **Forcing a single canonical session shape on consumers.** *(Why
  excluded: the workflow doc is *advisory* — it describes the
  checkpoint taxonomy and the harness's own currently-declared
  reviews. Consumer projects compose their own session shape from
  the same primitives; the harness doesn't dictate a session shape
  via module machinery.)*
- **Renaming or restructuring `cycle-end-distillation.md`.** *(Why
  excluded: that doc is well-named for its specific trigger pattern;
  the new `session-shape.md` is a peer covering the umbrella taxonomy.
  Both stay.)*
- **Promoting the candidate-stub-with-promotion-criterion technique
  to operating-principles § 9 in this PRD.** *(Why excluded: the
  technique has one observed firing as of OPP-0032 — the promotion-
  gate observation. A second observed firing in a future session is
  the bar for operating-principle promotion. v1 of this PRD names
  the technique in the taxonomy section but doesn't elevate it.)*

> Distinction from the `Functional Requirements > Out of Scope`
> table below: the bullets above are *outcomes* this PRD does not
> commit to delivering; the table below names *specific features*
> that are explicitly not in v1.

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Harness maintainer | Owns the workflow surface + decides which follow-up OPPs land first | A taxonomy that names the gaps + a sequencing recommendation that doesn't lock the order |
| Future-PRD author | Drafting a per-rule PRD that the taxonomy points at | A clear reference for which trigger-class their rule should adopt, + the positive-template pattern from PRD-0004 |
| Consumer-project author | Wants to understand auto-harness's session-cycle shape so they can mirror it | A descriptive (not prescriptive) account of the session-boundary checkpoints + the harness's own firing pattern at each |
| Agent (claude-code, openclaw, etc.) | Loading workflow docs at session start | A concise checkpoint reference + the trigger-class vocabulary for matching their session-events to harness primitives |

## User Stories

- As the **harness maintainer**, I want a single canonical doc listing every declared-but-unfired review so I can sequence follow-up OPPs deliberately rather than discovering each gap reactively.
- As a **future-PRD author**, I want a documented trigger-class taxonomy so my rule's design references one of five named classes rather than reinventing the framing.
- As a **consumer-project author**, I want to see *which checkpoints the harness fires automations at* so I can decide whether to mirror the same shape or diverge with rationale.
- As an **agent**, I want a one-paragraph workflow-doc summary at session start that names the session-boundary checkpoints so I can recognize which one I am about to cross.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | Create `platform/workflow/session-shape.md` as a new peer to `cycle-end-distillation.md` | File exists; has SPDX header; passes markdownlint; passes doc-references validator | The canonical home of the taxonomy |
| FR-002 | Document the session-boundary checkpoint taxonomy: **session start**, **work**, **PR open**, **PR merge**, **post-merge**, **periodic-review**, **external-event-driven** | Each checkpoint named with a one-paragraph description, the kinds of automations that fit there, and a concrete example from the harness's own currently-firing primitives | Anchor of the doc |
| FR-003 | Document the trigger-class taxonomy: **PR-boundary**, **session-boundary**, **time-boundary**, **count-boundary**, **audit-boundary**, **external-event-driven** | Each trigger-class named with the primitive(s) that implement it (companion rule, Stop-event hook, scheduled CI, agent-skill prompt, manual audit cadence), the failure mode it prevents, and at least one concrete example | The matchup between trigger-class and checkpoint is many-to-many; the doc explicitly notes this |
| FR-004 | Audit currently-declared-but-unfired reviews across the codebase | A section listing each declared-but-unfired review with: file location of the declaration, the review's intended purpose, the trigger-class it most likely wants, and a one-line recommended next step (OPP candidate / template enhancement / SKILL prompt / etc.) | This is the actionable output |
| FR-005 | Audit currently-declared-and-fired reviews — the positive baseline | A short section enumerating each declared review that *has* a fired trigger today, with explicit citation of the rule/hook/validator that fires it. Cycle-end-distillation rule is the canonical instance; the various audit-trail rules are the others | Establishes the "this works" reference set against which the unfired reviews are weighed |
| FR-006 | Per-unfired-review trigger-class classification | For each unfired review in FR-004, declare which of the six trigger-classes (FR-003) would fire it correctly, with a one-sentence rationale | The actionable v1 design output |
| FR-007 | Recommended sequencing of follow-up OPPs (advisory, not committed) | A "Next steps" section naming the recommended first OPP to file, the next, etc., with brief rationale per item. Explicitly framed as *advisory* — maintainer prioritizes per the existing OPP cadence | Avoids the "ship four rules in one PR" failure mode while still giving the maintainer a starting point |
| FR-008 | Cross-reference back to the cycle-end-distillation rule + PRD-0004 + the candidate-stub-with-promotion-criterion technique | The workflow doc explicitly cites PRD-0004 as the positive template and the OPP-0032 promotion-gate observation as a second positive example (the candidate-stub gate is itself a trigger-class instance) | Closes the loop on the workflow's evidence base |
| FR-009 | Update `SUMMARY.md` and `docs/README.md` to register the new workflow doc | New entry in SUMMARY.md workflow section; if `docs/README.md` lists workflow docs, add it there too | List-completeness drift class — fix in the same bundle |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-010 | Update `cycle-end-distillation.md` with a one-paragraph forward-pointer to `session-shape.md` | Reader of the cycle-end doc sees that it covers the *PR-boundary slice* of a larger taxonomy and can navigate to the umbrella | Closes the navigation gap between the two peer docs |
| FR-011 | Update `harness-governance` SKILL.md with a one-line reference to the taxonomy | Agents loading the governance skill see the trigger-class vocabulary | Aspirational — the SKILL is heavily used so even a one-liner has leverage |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| Implementing the `harness-onboarding` SKILL prompt for framing question (per the layered-brownfield observation's implication) | Distinct change class — touches a SKILL file's interactive behavior, not just descriptive prose | Follow-up OPP after PRD-0013 lands |
| Implementing the `validate-review-coverage.sh` validator (one that checks declared reviews against fired triggers programmatically) | v1 ships descriptive prose; v2 ships machinery; same pattern as PRD-0004 v1 (workflow + companion rule) vs v2 (validator) | After the taxonomy stabilizes and at least one follow-up review graduates |
| Codifying the candidate-stub-with-explicit-promotion-criterion technique in `platform/templates/opportunity/candidates.md` | Distinct template change; explicit Out of Scope per Non-Goals | Follow-up OPP after a second promotion-gate firing |
| Promoting the discipline to operating-principles § 9 | One observed firing of the promotion-gate; bar is two | After a second future-session firing |
| Adding companion rules for any of the currently-unfired reviews | Per-rule PRD passes; explicit Out of Scope per Non-Goals | Each gets its own OPP/PRD |
| Building a session-state dashboard / visualization | The workflow doc is the v1 surface; visualization is v2+ | If the taxonomy proves load-bearing and the maintainer wants a UI |

## Technical Constraints

- The new doc must not duplicate content from `cycle-end-distillation.md` — it sits *above* it as a taxonomy peer, with explicit cross-references.
- The audit of declared-but-unfired reviews must cite concrete file locations (e.g., `platform/profiles/management/knowledge-capture/README.md:90`) so future readers can verify the audit is current.
- Every recommendation in FR-007 (sequencing) must be advisory; PRD-0013 commits to nothing about which follow-up OPP lands first.
- All workflow-doc-only — no `module.yaml` edits, no validator changes, no schema changes, no companion-rule additions or modifications.

## CI/CD Gates

| Gate | Required? | Notes |
|------|-----------|-------|
| Lint passes | Yes | markdownlint clean |
| Validator chain passes | Yes | All 8 validators; new workflow doc passes placeholders, doc-references, catalog-counts |
| Companion-rule check passes | Yes | Touches OPP-0032 + new PRD file → cycle-end distillation rule fires; satisfier is the paired observation in `shared-observations.md` (this PRD's drafting itself is the first audit-section entry for "the candidate-stub-promotion review" — a meta-loop the taxonomy notes) |
| Change-log updated | Yes | Bundle entry citing PRD-0013, ADR-N/A (no ADR for v1), OPP-0032 |
| Workflow count bumped | Maybe | Adding `session-shape.md` increases the workflow count by 1; `validate-catalog-counts.sh` will catch the drift if any documented count references workflows; bump assertion sites accordingly |

## Success Metrics

| KPI | Target | How measured |
|-----|--------|-------------|
| Currently-declared-but-unfired reviews | Catalogued, not hidden | The audit section of `session-shape.md` lists each one with file location |
| Trigger-class vocabulary | Adopted by ≥1 follow-up PRD within 30 days | A follow-up PRD references one of the six trigger-classes by name in its rule design |
| Workflow-doc navigation | Cycle-end doc and session-shape doc cross-reference each other | Both docs include forward-pointers in their introductions |
| Taxonomy load-bearing | At least one declared-but-unfired review graduates to a filed OPP/PRD within 30 days | Validates that the audit produces actionable next steps rather than descriptive prose |

## Dependencies

- OPP-0032 must remain at `exploring` until this PRD lands; flips to `accepted` on merge.
- No new modules; no schema changes; no validator changes.
- Composes with the upcoming PRDs for OPP-0027..0031 (the Tula second-pass cluster) — those PRDs will reference the trigger-class vocabulary this PRD establishes.

## Open Questions

- [ ] **Should `session-shape.md` include a Mermaid diagram of the checkpoint flow?** Bias: yes, but small. The diagram should show the seven checkpoints with one example automation per checkpoint, not a full session-arc visualization. The harness's diagram corpus has set a precedent for visual-where-helpful (Diagram 5 distillation-trigger-composition is the closest existing peer).
- [ ] **Should FR-004's audit be exhaustive or representative?** Bias: exhaustive at v1 (every declared-but-unfired review I can find with grep). Lays the work bare. v2 can re-audit when the codebase changes.
- [ ] **Does the harness-onboarding SKILL itself need a separate OPP for the framing-question prompt?** PRD-0013 marks it Out of Scope; the follow-up OPP would draft the SKILL change. Bias: yes, file it as a small follow-up OPP after PRD-0013 lands. The discipline-of-deferral is more important than the per-task velocity.
- [ ] **Will the workflow doc need updates as the cluster from OPP-0027..0031 ships?** Almost certainly yes — each new module that introduces session-boundary primitives will add rows to the taxonomy. PRD-0013 v1 covers the *current* state; the doc evolves alongside the catalog. Plan a v2 revision marker rather than treating v1 as immutable.
- [ ] **Should the doc include a "what's already firing" success table separately from "what's declared but unfired" gap table?** Bias: yes, both tables (FR-005 + FR-004). The positive baseline is itself instructive; it shows the maintainer what the pattern looks like when it works.
- [ ] **Does the doc need a section on review-quality (cargo-cult risk) even though it's marked Out of Scope?** Bias: a one-paragraph forward-pointer noting that *quality* is a separate concern, with a candidate follow-up OPP cited if/when a second instance accumulates. This is the candidate-stub-with-promotion-criterion technique applied recursively to this PRD's own out-of-scope items.

## Acceptance Criteria for OPP-0032 → `accepted`

(Mirrors PRD-0007 and PRD-0011's pattern.)

OPP-0032 flips from `exploring` → `accepted` when:

- PRD-0013 Status flips to `Accepted` (this document)
- FR-001..FR-009 merged (Must Have)
- All 8 validators green on the implementing PR
- The implementing PR includes a paired observation in `shared-observations.md` confirming the workflow doc *exists and is referenced* (closes the audit-trail loop on the workflow-doc-as-design-artifact)
- At least one declared-but-unfired review identified in FR-004 graduates to a filed OPP/PRD pair within 30 days of merge (validates the taxonomy is load-bearing — if no follow-up OPP is filed in 30 days, the taxonomy may be descriptive prose without operational effect, and a revision pass is warranted)

FR-010..FR-011 (Should Have) can land in the implementing PR or a follow-up; they are not gates for the `accepted` flip.
