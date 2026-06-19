<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0003: Opportunity Capture — Forward-Looking Candidate Module

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-19 *(status reconciled `Proposed` → `Accepted`: the `management/opportunity-capture` module shipped and is active in `harness.manifest.yaml`; ADR-0004 Accepted; all FRs delivered. The `docs/README.md` index already recorded this PRD as Accepted — this corrects the stale source-file status line.)* | **Review Cycle:** On-change

**Status:** Accepted
**Date:** 2026-05-12
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Related ADRs: ADR-0001 (Modular governance architecture), ADR-0002 (Knowledge Capture observation structure — analog precedent), ADR-0004 (Opportunity Capture record structure — companion to this PRD)
- KPI definitions: `docs/standards/kpi-dictionary.md` *(no inline KPIs in this PRD)*
- Architecture context: `docs/architecture/overview.md`
- Other: `platform/profiles/management/knowledge-capture/` (the structural analog), `platform/templates/product/prd.md` (the artifact a promoted candidate spawns)

## Overview

The harness currently has two surfaces for institutional knowledge: `docs/knowledge/shared-observations.md` (backward-looking, append-only, severity-tagged observations) and `docs/knowledge/distilled-learnings.md` (curated synthesis). Neither captures *forward-looking candidate directions* — product opportunities, strategic theses, "things we might pursue" — at the pre-PRD stage. The gap manifests when a session produces an analysis with product potential (e.g., "this competing project is in a different layer, and the adjacency suggests an exportable governance contract"): there is no harness-native surface for it, so it lives only in conversation history or memory until distillation eventually surfaces it, by which point momentum is lost.

This PRD specifies a new module — `management/opportunity-capture` — parallel in shape to `management/knowledge-capture`. It adds a per-project surface (`docs/opportunities/`) for one-file-per-candidate records with explicit status (proposed | exploring | accepted | declined | superseded), evidence-linkage to the observation surface, and a hard promotion contract: accepting a candidate requires spawning a real PRD in the same commit. The gap between forward-looking ideas and backward-looking observations closes at the explicit evidence link, not by merging the two surfaces.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- Define a new opt-in module `management/opportunity-capture` with `module.yaml`, `README.md`, and compiled fragments, parallel in structure to `management/knowledge-capture`.
- Provide templates under `platform/templates/opportunity/` for the project-level policy README and per-candidate record (`OPP-NNNN-slug.md`).
- Specify the foundational record-structure choice (locked by ADR-0004) and the adjustable Write Policy (autonomous | heartbeat-only | draft-to-promote).
- Specify four companion rules enforced by the existing `validate-companions` validator — no new validator code.
- Adopt the module in auto-harness's own `harness.manifest.yaml` (dogfooding) and populate `docs/opportunities/README.md` with the locked record-structure choice.
- Define an explicit promotion contract: `accepted` status requires a PRD to be created or referenced in the same commit, with the candidate's `Promotion` field linking the spawned PRD.

**Non-Goals** — outcomes explicitly out of scope:

- New validator code — *(the design rides entirely on existing `validate-required-artifacts` and `validate-companions`; introducing new validators would expand the validator surface area without corresponding benefit).*
- Automatic promotion or status-change automation — *(state transitions are intentionally human decisions; an "accepted" status is a real decision with a binding artifact, not a tooling outcome).*
- A registry / index file (e.g., auto-generated status table) — *(filesystem listing + `Status:` line in each file is sufficient at this scale; revisit only if candidate count makes scanning painful).*
- Mandatory evidence linkage — *(the Origin / Evidence field supports a `thesis-only` marker for un-grounded ideas; forcing fabricated evidence would degrade signal worse than allowing labeled ungrounded entries).*
- Symmetric back-linking from PRDs to OPPs as a required field — *(an optional PRD-template polish; out of scope here to avoid scope creep into the PRD template).*

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Solo developer / harness creator | Captures product-shaped insights mid-session and needs them durable beyond conversation history | A harness-native surface for forward-looking candidates with clear evidence-linkage to observations and a real promotion path |
| Project participant (agent or human) | Notices a strategic direction or product opportunity during normal work | A low-ceremony way to file the candidate without conflating it with the append-only observation record |
| Reviewer / future contributor | Reads `docs/opportunities/` months later to understand what was considered | A clear status, disposition rationale, and (where accepted) a pointer to the resulting PRD; a clear (where declined) reason it was not pursued |

## User Stories

- As a solo developer, I want to file a product opportunity that I noticed during a session, with a link to the observation that grounds it, so the idea is durable beyond conversation history and traceable to its evidence.
- As a project participant, I want to mark a candidate as `declined` with a rationale, so the same idea doesn't keep getting re-proposed without addressing why it was rejected.
- As a reviewer, I want every `accepted` candidate to have a PRD in the same commit, so "accepted" is not a status that drifts to mean "intended but never built."
- As an agent operating under the Write Policy, I want to know whether I may append candidates autonomously or only during a heartbeat, so my contributions match the project's signal/noise tolerance.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | New module directory created | `platform/profiles/management/opportunity-capture/` exists with `module.yaml` and `README.md`, parallel in shape to `knowledge-capture/` | |
| FR-002 | `module.yaml` declares required artifacts | `requiredArtifacts` lists `docs/opportunities/README.md` | Per-candidate files are not required artifacts — adoption requires the policy file, not specific candidates |
| FR-003 | `module.yaml` declares sensitive paths | `sensitivePaths` covers `^docs/opportunities/README\.md$` (the policy) | Parallels knowledge-capture's pattern for its own README |
| FR-004 | Two companion rules declared, covering four substantive checks | `companionRules` declares: (1) trigger `^docs/opportunities/OPP-` → `requiredAny` includes an audit-trail entry (the day's daily memory file or `docs/project/change-log.md`); `humanReview` text covers (a) appropriate Disposition rationale when status changed from `proposed`, (b) `accepted` status accompanied by a PRD created/referenced in the same commit, (c) `declined`/`superseded` accompanied by substantive rationale (not just a status-line edit). (2) trigger `^docs/opportunities/README\.md$` → `requiredAny` includes `^docs/adr/ADR-`; `humanReview` confirms the ADR explicitly addresses the structural change. | Pattern parallels `knowledge-capture`'s use of `humanReview` text for the substantive checks the regex layer cannot enforce |
| FR-005 | Validators wired | `validators` lists `validate-required-artifacts` and `validate-companions` | No new validator code |
| FR-006 | Module declares dependency | `dependsOn` includes `kernel/base`; does NOT depend on `knowledge-capture` (link is artifact-level, not module-level) | Allows projects to adopt opportunity-capture without knowledge-capture if desired |
| FR-007 | Per-candidate template created | `platform/templates/opportunity/opp-template.md` exists with required fields: Status, Owner, Created, Last Updated, Confidence, Thesis, Origin / Evidence, Why Now, Risks / Open Questions, Disposition, Promotion | Structure locked by ADR-0004 |
| FR-008 | Policy README template created | `platform/templates/opportunity/README.md` exists with: foundational record-structure choice (locked-via-ADR), adjustable Write Policy (autonomous / heartbeat-only / draft-to-promote), status definitions, companion-rule reference | Mirrors knowledge-capture's `README.md` template shape |
| FR-009 | Auto-harness adopts the module | `harness.manifest.yaml` adds `opportunity-capture` to `modules.management` | Dogfooding |
| FR-010 | Auto-harness's `docs/opportunities/README.md` created | Project-level policy file exists, references ADR-0004 as the locking record, declares Write Policy `heartbeat-only` with rationale | Parallels how `docs/knowledge/README.md` references ADR-0002 |
| FR-011 | ADR-0004 created and accepted | `docs/adr/ADR-0004-opportunity-capture-record-structure.md` documents the locked foundational choice (record structure), alternatives considered, consequences | Companion to this PRD |
| FR-012 | Change-log entry created | `docs/project/change-log.md` has a 2026-05-12 row referencing PRD-0003 + ADR-0004 | Self-governance dogfooding |
| FR-013 | Placeholder reference updated | Every new placeholder token introduced in `platform/templates/opportunity/` appears in `platform/templates/README.md` with usage column | Catches placeholder validator regressions |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-014 | Validator chain still passes | `validate-manifest.sh`, `validate-module-graph.sh`, `validate-required-artifacts.sh`, `validate-companions.sh`, `validate-placeholders.sh` all exit 0 against the resulting tree | Must hold before commit |
| FR-015 | First candidate file demonstrates the shape | `docs/opportunities/OPP-0001-exportable-governance-contract-for-runtime-harnesses.md` exists, citing the Hive analysis observation as Origin / Evidence | Drafted as part of this PRD's execution to validate the shape; can be filed independently if the user prefers to land just the module first |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| Auto-generated status registry / index file | Filesystem listing + per-file Status line is sufficient at low candidate count; tooling for scanning can come later | When candidate count exceeds ~30 or scanning by status becomes painful in practice |
| Symmetric PRD → OPP back-link as a required PRD field | Asymmetric forward-only linkage from OPP works; mandating reverse linkage in the PRD template is scope-creep | When the harness has enough OPP→PRD pairs that one-way traceability becomes a real review pain point |
| Automatic status transitions (e.g., bot moves stale `proposed` candidates to `archived`) | Status changes are decisions, not bookkeeping; automating them undermines the contract | When manual hygiene falls behind and review evidence shows real decay |
| Soft-promotion path (OPP morphs into a PRD via rename rather than spawn) | Two records preserves history of "this was once a candidate"; rename loses the candidate's exploration period in anything except git log | If duplication between OPP and its spawned PRD turns out to be high enough to be wasteful |

## Technical Constraints

- Must remain markdown + YAML only — no schema, frontmatter, or programmatic parsing required beyond what existing validators already perform.
- Must not break the placeholder validator: every new `[[...]]` token introduced in `platform/templates/opportunity/` must be documented in `platform/templates/README.md`.
- Must preserve the existing companion-rule trigger-path pattern (`^docs/opportunities/...` style); validator regex anchoring follows the same conventions used by `knowledge-capture`.
- Companion rule for `status flips to accepted → PRD spawned` is implemented as a path-pattern rule: edits to `^docs/opportunities/OPP-` paired with edits to `^docs/requirements/PRD-` in the same commit. The validator cannot enforce that the status line *specifically* changed to `accepted` — content semantics remain a human review gate, consistent with the framework's principle that validators check presence/structure and humans check intent.

## Tech Stack

*N/A — governance PRD shaping markdown templates and YAML manifests; no code stack involved.*

## API & Data Contracts

*N/A — governance PRD, no API surface or data shape changes beyond markdown record shape (covered in ADR-0004).*

## UI/UX Notes

*N/A — governance PRD, no user-facing surface beyond directory layout and markdown structure.*

## CI/CD Gates

| Gate | Required? | Notes |
|------|-----------|-------|
| Lint passes | N/A | No code |
| Type-check passes | N/A | No code |
| Test coverage threshold | N/A | No code |
| Required tests added | N/A | No code; validator chain stands in |
| Validator chain passes | Yes | `bash platform/validators/validate-manifest.sh harness.manifest.yaml` and the rest of the chain; all exit 0 |
| Companion-rule check passes | Yes | Specifically the four new rules introduced by `opportunity-capture` |
| Change-log updated | Yes | FR-012 |

For full release-stage checks, see `docs/ops/release-checklist.md`.

## Success Metrics

| KPI | Target | How measured |
|-----|--------|-------------|
| Validator chain pass | All 5 validators exit 0 after the change | Run the chain locally and observe in CI |
| Template self-consistency | Every placeholder token in `platform/templates/opportunity/` is listed in `platform/templates/README.md` | `rg -o '\[\[[A-Z0-9_]+\]\]' platform/templates/opportunity/ \| sort -u` matches the README mapping |
| Module shape parity | `platform/profiles/management/opportunity-capture/module.yaml` schema-validates identically to `knowledge-capture/module.yaml` against the manifest validator | `validate-manifest.sh` exit 0 with the new module declared |
| Dogfood adoption | `docs/opportunities/README.md` exists and references ADR-0004 | File presence and grep for `ADR-0004` reference |

## Dependencies

- ADR-0002 — the structural precedent (knowledge-capture's foundational-choice lock by ADR); ADR-0004 follows the same pattern.
- PRD-0002 — establishes the practice of treating PRDs as governance-spec records (template change → PRD).
- `platform/profiles/management/knowledge-capture/` — the parallel module whose shape this module mirrors.
- `platform/templates/product/prd.md` — the artifact a promoted candidate spawns.

## Open Questions

- [ ] Should the per-candidate template include an optional `Reviewers:` field for governance-relevant or architectural-flavored candidates? Currently a candidate has `Owner:` but no explicit reviewer list. Defer until adoption shows whether this matters in practice.
- [ ] When a candidate is `superseded`, should the superseding candidate be required to back-link (currently the superseded one points forward; the superseding one is not required to point back)? Mirrors the symmetric-back-link question for PRDs — same defer-until-needed answer.
