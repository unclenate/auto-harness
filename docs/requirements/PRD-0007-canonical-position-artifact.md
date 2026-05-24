<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0007: Canonical-Position Artifact as Harness Primitive

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-05-24 | **Review Cycle:** On-change

**Status:** Proposed
**Date:** 2026-05-24 (filed)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Related OPP: [OPP-0007](../opportunities/OPP-0007-canonical-position-artifact.md) — `exploring`; this PRD is its promotion candidate
- Related ADRs (anticipated, may spawn during implementation):
  - ADR-0013 — Canonical-position artifact as harness primitive (decision record formalizing the new module + companion-rule contract)
- Related observations (the five sibling observations in `docs/knowledge/shared-observations.md`, all dated 2026-05-22):
  - *"Validator opt-out has no staleness pressure"* (A) — **deferred to follow-up OPP**
  - *"Opportunity-capture has no backlog-reconciliation trigger when canonical direction changes"* (B) — **deferred to follow-up OPP**
  - *"No formal review/reconciliation artifact type — and the ad-hoc one proved high-value"* (C) — **bundled into v1**
  - *"Discovery-intake treats the intake as one-shot; canonical-direction-changed → intake-stale path is missing"* (D) — **deferred to follow-up OPP**
  - *"Three positive patterns from a heavy-load reconciliation worth promoting to harness conventions"* (E) — **bundled into v1 as operating-principles § 9 additions**
- Field-evidence repo: `bdits/municipal-brain` at commit `ff953c1` — see OPP-0007 § Related for the specific artifacts that motivated the OPP
- Related operating-principles: § 5 (Self-Governance), § 7 (Align File Boundaries with Change-Class Boundaries), § 8 (Prefer Text Representations)

## Overview

Auto-harness's management profiles produce a rich artifact set —
problem-statement, personas, requirements, release-intent, mvp-scope,
OPPs, ADRs, a change-log, knowledge observations. **None of them is
the single ratified north-star that every other artifact must cite
and that cannot drift.** Decisions, framings, and assumptions
accumulate across artifacts as independent snapshots of evolving
thinking, with no fixed reference they all align to. The result,
observed end-to-end in `bdits/municipal-brain`: artifacts drift apart,
the project loses its own ground truth, and recovery requires a
hand-rolled "canonical position" doc + a multi-day reconciliation.

This PRD specifies the v1 mechanism as **a new lightweight overlay
module** (`management/canonical-position`) that depends on
`project-standard` and adds five coordinated pieces:

1. **The canonical-position artifact itself** — `docs/canonical-position.md`,
   required by the new module, scaffolded from a new template, with
   a section structure that adapts to project shape (B2B SaaS vs.
   research pipeline vs. internal platform).

2. **Citation companion rule** — strategy-shaped artifacts
   (`requirements.md`, `release-intent.md`, `mvp-scope.md`, OPP files,
   GTM/partnership artifacts when present) must cite the
   canonical-position file. PRs that edit those artifacts without
   either citing or updating the canonical-position file fail
   `validate-companions.sh`.

3. **Ratification flow** — editing `docs/canonical-position.md`
   requires a paired review-artifact in `docs/reviews/` + a
   change-log entry. This codifies the "you cannot silently revise
   the north star" discipline.

4. **The review-artifact type** (Observation C) — bundled into v1
   because the ratification flow depends on it. New template at
   `platform/templates/management/review.md`; new optional artifact
   pattern in `docs/reviews/REVIEW-NNNN-slug.md`; companion-rule
   semantics defined.

5. **Three operating-principle additions** (Observation E patterns) —
   change-log as commit-grouping spec, companion-rules discipline
   under load, salvage-before-archive + ARCHIVE-INDEX — added to
   `docs/operating-principles.md` as § 9 *"Patterns from
   Reconciliation Loads"*.

The three remaining sibling observations (A, B, D) are deferred to
separate follow-up OPPs that will anchor on OPP-0007 as their
prerequisite.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- New module `platform/profiles/management/canonical-position/` with
  `module.yaml`, `README.md`, and compiled fragments.
- New artifact template `platform/templates/management/canonical-position.md`
  with placeholder tokens + adaptive section structure.
- New artifact template `platform/templates/management/review.md`
  defining the review-artifact format (with mandatory cite of the
  canonical-position file when the review's subject is canonical
  revision).
- Two new companion rules wired through `validate-companions.sh` (no
  validator code change):
  - **Citation rule** — when strategy-shaped artifacts change, the
    diff must include a citation to `docs/canonical-position.md`
    (either an existing citation appears in the same artifact or the
    canonical-position file itself is touched in the same PR).
  - **Ratification rule** — when `docs/canonical-position.md`
    changes, the same PR must include a `docs/reviews/REVIEW-*.md`
    file AND a `docs/project/change-log.md` entry.
- Update to `docs/operating-principles.md` adding § 9 with the three
  patterns from Observation E.
- Update to the `harness-governance` SKILL.md mentioning the new
  module + rules.
- Update to `SUMMARY.md` Module Library (new row under Management).
- `harness.manifest.yaml` does *not* adopt the new module by default;
  this is opt-in for projects that have strategic positioning
  concerns. The new module appears in catalogs but is not active in
  auto-harness itself unless we decide to dogfood it.
- Catalog-count assertions in `validate-catalog-counts.sh` bumped
  (modules_profiles 26→27, templates likely +2).
- One paired architectural observation capturing v1's design pressure
  per the OPP→PRD cascade pattern.

**Non-Goals** — explicitly deferred to follow-up:

- **Validator opt-out staleness machinery** (Observation A). Needs
  trust-tier-enforcement (PRD-0006) machinery to land first; the
  opt-out citation works most cleanly once tier declarations exist
  and the validator already inspects overrides.
- **Opportunity-capture backlog re-audit on canonical change**
  (Observation B). Needs canonical-change-detection mechanism
  (probably a content-hash compare); separate scope.
- **Discovery-intake canonical-SHA pinning** (Observation D). Needs
  the canonical-position artifact + companion rule + intake schema
  update; the schema work is its own design.
- **Dogfooding the new module in auto-harness itself.** v1 ships the
  module as opt-in; auto-harness can adopt later if/when the
  maintainer decides the framework's own positioning needs the
  artifact.
- **Required `canonical-position.md` for all `project-standard`
  consumers.** The new module is *opt-in via manifest activation*;
  not a forced upgrade for existing consumers.
- **Per-section ratification.** v1 treats the artifact as
  full-document — every revision supersedes the previous wholesale.
  Per-section versioning is a future enhancement if v1 reveals the
  full-document granularity is too coarse.
- **GTM/partnership artifact templates.** The canonical-position
  artifact accommodates GTM/partnership content, but separate
  scaffolded templates for those artifact types are out of scope.

## Functional Requirements

### FR-001 — New `management/canonical-position` module

Create `platform/profiles/management/canonical-position/` containing:

- `module.yaml` declaring:
  - `id: management/canonical-position`
  - `type: management`
  - `version: 1.0.0`
  - `dependsOn: [management/project-standard]`
  - `conflictsWith: []` (no current conflicts)
  - `requiredArtifacts: [docs/canonical-position.md]`
  - `optionalArtifacts: [docs/reviews/]` — the directory containing
    `REVIEW-NNNN-*.md` files (the ratification trail)
  - `companionRules` — two rules per FR-003 and FR-004 below
  - `validators: [validate-companions, validate-required-artifacts]`
  - `agentAdapters: [platform/agents/base]`
  - `compiledFragments: [platform/profiles/management/canonical-position/README.md]`
- `README.md` explaining: when to activate (projects with strategic
  positioning concerns); what the artifact is for; how ratification
  works; what does *not* belong in the artifact (operating-principles,
  scope plans, tactical milestones).

### FR-002 — Canonical-position artifact template

New template at `platform/templates/management/canonical-position.md`
with tokenized header (per the v1 header-token convention from
PRD-0005) and an adaptive section structure. Required sections (every
project shape):

- **Identity / entity** — who is this project, what does it ship at
  the highest level
- **Wedge / job-to-be-done** — the single replicable thing it does
- **Boundaries** — what's in scope; what's explicitly not in scope
- **Positioning** — what it is *not*, what it *replaces*, what
  alternatives consumers / users have
- **Update policy** — how revisions to this document are ratified
  (cross-reference to the ratification rule + the review-artifact
  template)

Recommended sections (optional, present when relevant):

- **Buyer / motion** (B2B SaaS / commercial projects)
- **Funding / sustainability** (commercial projects)
- **Research thesis** (research / pipeline projects)
- **Internal mandate** (internal tooling / platform projects)
- **Partnership posture** (projects with significant partnership
  dependencies)

The template ships with `<!-- TODO: ratify -->` markers so the
artifact exists structurally on day one; the citation rule fires on
*citation*, not on *content completeness*.

### FR-003 — Citation companion rule

Added to the new module's `companionRules`:

```yaml
- description: "Strategy-shaped artifacts must cite the canonical-position
    artifact. When these artifacts are edited, the diff must include
    either an existing citation to docs/canonical-position.md or the
    canonical-position file itself in the same PR (the latter being the
    case where the citation is being updated to a new revision)."
  triggerPaths:
    - "^docs/product/requirements\\.md$"
    - "^docs/product/release-intent\\.md$"
    - "^docs/product/mvp-scope\\.md$"
    - "^docs/product/problem-statement\\.md$"
    - "^docs/discovery/.*\\.md$"
    - "^docs/opportunities/OPP-"
    - "^docs/partnerships/.*\\.md$"
    - "^docs/gtm/.*\\.md$"
  requiredAny:
    - "^docs/canonical-position\\.md$"
  humanReview: "Reviewers verify the cited canonical-position section
    actually grounds the change. Citation must be substantive (the change
    references a specific canonical section), not ornamental."
```

The rule fires on edits to any strategy-shaped artifact. Satisfier is
**either**: the canonical-position file itself is touched in the same
PR (the citation is being updated as part of authoring a new
revision), OR — and this requires PRD-pass refinement — the strategy
artifact's content references the canonical-position file in its
text. The v1 implementation uses path-only satisfier (the simpler
rule); the content-citation check is deferred to v2.

### FR-004 — Ratification companion rule

```yaml
- description: "Editing the canonical-position artifact requires a
    paired ratification trail: a review-artifact (docs/reviews/REVIEW-*.md)
    documenting the review that produced the revision, AND a change-log
    entry (docs/project/change-log.md). This codifies the 'you cannot
    silently revise the north star' discipline."
  triggerPaths:
    - "^docs/canonical-position\\.md$"
  requiredAny:
    - "^docs/reviews/REVIEW-[0-9]+-.+\\.md$"
  forbiddenPatterns: []
  humanReview: "Reviewers verify the review artifact's recommendations
    actually correspond to the canonical-position changes proposed in
    the same PR. A review artifact that doesn't reference the canonical
    revisions is cargo-cult; reviewers push back."
```

Note: the rule's `requiredAny` lists only the review-artifact path
because the kernel-base companion rule already requires
`docs/project/change-log.md` (or equivalent) for any substantive
edit. The two rules compose — both fire on the same PR; satisfying
each independently.

### FR-005 — Review-artifact template + lightweight type

New template at `platform/templates/management/review.md`:

Required sections:

- **Review ID + date + reviewers**
- **Subject** — what artifact / decision is under review
- **Inputs** — what was read; what was consulted
- **Findings** — what's wrong / what's right / what's missing
- **Recommendations** — specific actions (each tied to a finding)
- **Disposition** — accepted / partially accepted / rejected, with
  rationale

The artifact pattern `docs/reviews/REVIEW-NNNN-slug.md` mirrors the
OPP and ADR patterns. The module's `optionalArtifacts` lists the
directory `docs/reviews/` so consumers can opt into the structure
without ratification firing on early-phase reviews.

The review-artifact type also satisfies Observation C's standalone
gap — "no formal review/reconciliation artifact type" — by giving
review work a first-class template + directory + numbering scheme.
Other modules can reference the type in their own companion rules
(e.g., a future periodic-audit module might require a review entry).

### FR-006 — Operating-principles § 9 (Observation E patterns)

Add a new section to `docs/operating-principles.md`:

```markdown
## 9. Patterns from Reconciliation Loads

When the harness experiences heavy concurrent work (large
reconciliation passes, audit-closure sprints, multi-PR refactors),
three patterns consistently produce coherent outcomes:

### Change-log as commit-grouping spec
Drafting the `docs/project/change-log.md` entry first, then making
the commits structured to match the entry's grouping, produces
PRs that are reviewable as one coherent change rather than a
chronological audit of edits.

### Companion-rules discipline under load
When PR scope grows (10+ files, multiple modules touched), companion
rules continue to fire correctly because they operate on path
patterns, not on diff size. The PR-load doesn't degrade the gate;
reviewers can lean on the rules to enforce that satisfiers are
present even when manually inspecting every file is impractical.

### Salvage-before-archive + ARCHIVE-INDEX
When retiring artifacts (superseded plans, obsolete OPPs,
deprecated modules), move them to `docs/archive/` with an
`ARCHIVE-INDEX.md` row documenting the salvage rationale rather
than deleting. The archive is a recoverable record; deletion is
not.
```

These additions are non-binding observations (operating-principles
isn't a contract surface), but they codify what worked during
`bdits/municipal-brain`'s reconciliation so future heavy-load passes
can be deliberate about adopting the same patterns.

### FR-007 — Catalog-count assertion bumps

Adding the new module bumps `modules_profiles` 26 → 27. Adding two
new templates (`management/canonical-position.md`,
`management/review.md`) bumps `templates` 56 → 58.

The catalog-counts validator catches drift at all four assertion
sites (`platform/reference/how-to-read.md` × 2,
`docs/architecture/diagrams.md` × 1, `docs/_assets/cover-back.svg`).
All bumped in the same PR.

### FR-008 — Documentation updates

- `platform/skills/harness-governance/SKILL.md` — companion-rules
  table gains rows for the citation rule and the ratification rule.
- `SUMMARY.md` Module Library Management section — new row for
  canonical-position.
- `platform/workflow/discovery-to-composition.md` — decision rubric
  gains "Does the project have strategic positioning concerns?" row
  pointing at the new module.
- `platform/templates/README.md` — gains rows for the two new
  templates in its inventory.

## Acceptance Criteria for OPP-0007 Promotion to `accepted`

OPP-0007 flips from `exploring` to `accepted` when **all** of the
following are met:

1. PRD-0007 status flips to `Accepted`
2. FR-001 through FR-008 implemented and merged to `main`
3. All 8 validators pass on the implementation PR (including
   `validate-catalog-counts.sh` after the FR-007 bumps land)
4. The new module is reachable from the `harness-onboarding` skill's
   catalog and from `discovery-to-composition.md`'s decision rubric
5. At least one downstream consumer (or a sample-project fixture)
   demonstrates the citation + ratification flow end-to-end

The five sibling observations remain *open* observations after
OPP-0007 → `accepted` — the deferred ones (A, B, D) become
follow-up OPPs that anchor on OPP-0007; the bundled ones (C, E) are
considered closed by the v1 work.

## Out of Scope

Reproduced from Non-Goals above:

- Validator opt-out staleness machinery (Observation A → follow-up OPP)
- Opportunity-capture backlog re-audit (Observation B → follow-up OPP)
- Discovery-intake canonical-SHA pinning (Observation D → follow-up OPP)
- Dogfooding the module in auto-harness itself
- Required canonical-position for all `project-standard` consumers
- Per-section ratification
- GTM / partnership artifact templates

## Risks

### Risk: Citation rule produces false positives on routine artifact edits

Strategy-shaped artifacts (`requirements.md`, etc.) get edited for
many reasons — typo fixes, formatting cleanup, link updates. If the
citation rule fires on *every* edit, consumers will route around it
with `overrides.disabledValidations` or by appending throwaway
citations.

**Mitigation:** The rule's satisfier is *either* an existing
citation in the strategy artifact OR a touch on
`canonical-position.md` itself. Routine edits to a strategy
artifact that already cites the canonical-position file (because
the consumer set up the citation once) pass without further action.
Only the *first* substantive edit and the *first* edit-after-
ratification need a paired update. The `humanReview` text codifies
the "substantive citation" expectation; reviewers push back on
ornamental citations.

### Risk: Ratification trail becomes ceremonial

Every canonical-position edit requires a review artifact. If small
edits (typo fixes, link updates) trigger the rule, the review
artifact becomes a no-op file consumers create to pass the
validator — exactly the kind of cargo-cult discipline that
Observation E warns against.

**Mitigation:** The rule's `humanReview` text demands the review
artifact's recommendations actually correspond to the
canonical-position changes. Trivial edits — typo fixes, formatting
— should be batched into a single review artifact per quarter or
explicit "no-substance" annotation. This is reviewer discipline,
not validator-enforceable. If v1 reveals routine cargo-culting,
v1.5 adds a `routine-edits-allowed` annotation pattern.

### Risk: Module-placement decision proves wrong at scale

The PRD picks a new dedicated module over extending
`project-standard`. If consumer projects routinely adopt
`project-standard` *and* `canonical-position` together, the
separation adds friction without value.

**Mitigation:** v1 ships the separate module; usage telemetry (in
practice: observing whether consumer manifests pair them) informs a
later consolidation decision. The module is named neutrally
(`canonical-position`) so a future merge into `project-standard` is
possible without renaming.

### Risk: The artifact's section structure prescribes content

OPP-0007 raised this risk explicitly: the harness's strength is
governing structure without prescribing content; an over-specified
canonical-position template could overreach.

**Mitigation:** Template ships with required sections (5 sections
that apply to every project shape) + recommended sections (4
sections that apply when relevant). Consumers can add custom
sections freely. The companion rule fires on *citation*, not on
*section presence* — so a consumer who removes a recommended
section doesn't fail validation.

### Risk: v1 scope is too broad — 8 FRs across module, two templates, two companion rules, operating-principles edit, catalog updates

The PRD bundles the review-artifact (Observation C) into v1, which
expands scope versus a minimal "just the artifact" v1.

**Mitigation:** The ratification flow depends on the review
artifact, so splitting them across two PRs would leave v1 with a
ratification rule that can't be satisfied. The bundling is
load-bearing. If implementation reveals the scope is too large,
the fallback is to ship FR-001 + FR-002 + FR-003 + FR-007 + FR-008
as v1, defer FR-004 + FR-005 + FR-006 to v1.5 — but the citation
rule alone delivers most of the value.

## Open Questions Resolved by This PRD

The OPP-0007 open questions are resolved as follows:

- **New module vs. addition to project-standard vs. new overlay?**
  → **New lightweight overlay module** (`management/canonical-position`)
  that depends on project-standard. Clean separation; opt-in
  adoption; doesn't stretch project-standard's purpose.

- **Citation form — file path only, or file path + commit SHA?**
  → **File path only at v1.** Commit SHA pinning is a stronger
  guarantee but requires consumer projects to manage SHA bumps when
  canonical-position revises. v1 keeps the rule satisfier simple;
  SHA pinning is a v1.5 enhancement if needed.

- **Composition with `docs/operating-principles.md`?**
  → **Complementary, distinct surfaces.** Operating-principles is
  *how the project works*; canonical-position is *what the project
  ships*. The boundary: operating-principles changes when *process*
  evolves; canonical-position changes when *product/strategy*
  evolves. PRD makes the boundary explicit in the new module's
  README.

- **Ratification trail shape — review artifact + change-log + ADR?
  Or a single ratification record type?**
  → **Review artifact + change-log entry.** ADRs are for decisions
  about *how the project is governed*; canonical-position revisions
  are about *what the project is doing*. The review artifact is the
  natural producer of canonical-position revisions; an ADR may
  follow if the revision motivated a structural change to *how*
  the project works.

- **Per-section vs. full-document versioning?**
  → **Full-document.** Every ratified revision supersedes the
  previous wholesale. Per-section versioning is a v1.5+ enhancement
  if v1's full-document granularity proves too coarse.

- **Project shapes without "strategic position"?**
  → **Optional adoption.** Projects without strategic positioning
  concerns (internal tooling libraries, research pipelines used as
  scratch-space) don't activate the module. The module's README
  explains when to skip.

- **One-time migration for existing harness-governed projects, or
  greenfield-only?**
  → **Greenfield + opt-in for existing projects.** No required
  migration. Existing consumers who want the discipline add the
  module to their manifest; non-adopters see no change.

## Future Work (Not v1)

- **Validator opt-out citation rule** (Observation A) — overrides
  in `harness.manifest.yaml` must cite a canonical-position section
  that grants them. Needs trust-tier enforcement (PRD-0006) machinery
  to land first because the override semantics will be tier-aware by
  then.

- **Opportunity-capture backlog re-audit** (Observation B) — when
  canonical-position is ratified (revised), the OPP backlog is
  automatically flagged for re-audit. Needs canonical-change-detection
  (probably content-hash compare; possibly the ratification trail's
  SHA).

- **Discovery-intake canonical-SHA pinning** (Observation D) — the
  intake declares which canonical-position commit SHA it was filled
  against; companion rule auto-flags stale when SHA superseded.
  Requires the artifact + the citation rule (this PRD) + schema
  update to discovery-intake.

- **GTM / partnership artifact templates** — adapt the
  canonical-position artifact's recommended sections into standalone
  templates that consumer projects can scaffold when they have GTM
  or partnership documentation needs.

- **Per-section ratification + diff** — allow revising one section
  of canonical-position without superseding the whole document; the
  ratification trail tracks per-section history.

- **Dogfooding canonical-position in auto-harness itself** — if the
  framework's own positioning needs structured ratification (e.g.,
  to coordinate consumer expectations through major version bumps),
  adopt the module in `harness.manifest.yaml`.

## Implementation Notes

- **Sequencing within the implementation PR:** FR-005 (review-artifact
  template) must land *with* FR-004 (ratification rule) because the
  rule's satisfier references the review artifact's path pattern. FR-007
  (catalog bumps) ride alongside FR-001 + FR-002 (module + template
  add).

- **Self-stabilization:** the citation rule's `triggerPaths` include
  `docs/product/requirements.md` — which is one of auto-harness's
  own active required artifacts. If we dogfood the new module
  (Non-Goal — currently *not* in v1), the implementation PR itself
  would trigger the citation rule on the requirements.md edit and
  need a paired canonical-position edit. v1 explicitly *does not*
  adopt the module in auto-harness, so the rule fires only against
  consumer manifests.

- **Distillation trigger:** since the implementation PR adds new
  modules (`platform/profiles/management/canonical-position/module.yaml`),
  the cycle-end distillation rule fires per the regex
  `^platform/.+/module\.yaml$`. A paired observation will be needed
  in the implementation PR — anticipated and budgeted.

- **Testing:** mirror the patterns from earlier modules. The
  validator chain runs against the harness's own manifest (which does
  not activate the new module); the sample-projects CI runs against
  sample manifests (none of which currently activate the new module).
  A new sample-project demonstrating canonical-position adoption end-
  to-end can be added in v1.5; v1 ships without a sample-project
  example to avoid scope creep.

## CI / CD Gates

- All 8 existing validators must pass on the implementation PR.
- `validate-catalog-counts.sh` must pass after FR-007's bumps to the
  documented counts.
- `sample-projects` CI job must continue to pass — the new module
  affects no sample.
- Shellcheck at `--severity=warning` (no new bash scripts in this
  PR; the validator changes are companion-rule additions to
  `module.yaml`).
- Markdownlint clean on new docs.

## Versioning Implications

- Canonical-position v1 is a **MINOR bump** to v0.7.0 (additive
  module; new templates; new companion rules; no breaking change).
- The v0.6.0 release-marker is trust-tier-enforcement implementation
  (PRD-0006); canonical-position is the v0.7.0 release-marker.
- CHANGELOG.md `## [v0.7.0]` will document:
  - **Added:** `management/canonical-position` module, two new
    templates, § 9 operating-principle additions
  - **Changed:** SUMMARY.md catalogs, `validate-catalog-counts.sh`
    assertion table
- Module-level versioning: the new module starts at `1.0.0` per
  established convention.
