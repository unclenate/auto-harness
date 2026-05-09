# PRD-0002: Extend PRD Template with Optional Execution-Spec Sections

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-05-09 | **Review Cycle:** On-change

**Status:** Accepted
**Date:** 2026-05-09
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Related ADRs: ADR-0001 (Modular governance architecture)
- KPI definitions: `docs/standards/kpi-dictionary.md` *(no inline KPIs in this PRD)*
- Architecture context: `docs/architecture/overview.md`
- Other: PRD-0001 (Restored PRD support), `platform/templates/product/prd.md`, `platform/profiles/management/product-lite/README.md` § Connecting to PRDs

## Overview

The PRD template absorbed governance metadata (Version line, Cross-references, KPI
dictionary linkage) from the adsclaw absorption (`2cfc3ae`). It did not absorb the
*execution-spec* qualities of hackathon-style PRD frameworks — the parts of a PRD that
constrain an AI agent's build choices: explicit Goals & Non-Goals, a decided Tech Stack,
API & Data contracts, UI/UX state expectations, and a CI/CD quality bar. This PRD
extends the template additively with those five sections so a single template serves
both **governance PRDs** (durable decision records) and **execution-spec PRDs**
(single-agent build briefs), without splitting into two templates.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- Add five sections to the PRD template — `Goals & Non-Goals` (always required),
  `Tech Stack`, `API & Data Contracts`, `UI/UX Notes`, `CI/CD Gates` (each marked
  "when applicable") — without removing or renaming existing sections.
- Keep a single PRD template; differentiate flavors by which optional sections a given
  PRD fills versus marks `N/A — governance PRD`.
- Update placeholder reference and product-lite documentation so users know how to fill
  or omit the optional sections.
- Maintain backward compatibility: existing PRD-0001 backfills cleanly to the new
  template using the `N/A — governance PRD` convention; no in-flight PRD breaks.

**Non-Goals** — outcomes explicitly out of scope:

- Splitting into two templates (governance vs. execution-spec) — *(template proliferation
  is worse than optional sections; revisit only if adoption shows the optional cue is
  routinely confusing).*
- Adding a content-quality validator that checks, e.g., "Tech Stack lists ≥3 layers" —
  *(presence-only via existing validators; content quality stays a human review gate,
  consistent with PRD-0001's reasoning).*
- Touching the ADR template to add execution-spec sections — *(ADRs and PRDs serve
  different purposes; this absorption is PRD-only).*
- Removing the existing `Technical Constraints` section — *(it captures defensive
  constraints distinct from the prescriptive `Tech Stack`; both have value).*

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Solo developer with AI assistant | Builds a discrete feature with one agent end-to-end | A PRD that constrains the agent's stack, API, UI, and CI choices so it doesn't drift |
| Team lead / product owner | Records durable product direction | A PRD that captures lifecycle, cross-references, and rationale — unchanged from before |
| Reviewer / future contributor | Reads the PRD months later | Clear cue ("when applicable") so they know whether unfilled execution sections were skipped intentionally or forgotten |

## User Stories

- As a solo developer, I want my PRD to declare the stack, API surface, UI states, and CI gates, so that my AI agent stops re-architecting or inventing endpoints during build.
- As a team lead, I want governance PRDs to remain compact (no forced execution detail), so that scope/strategy decisions don't drown in implementation specifics.
- As a reviewer, I want optional sections labeled `N/A` rather than empty, so that I can distinguish "intentionally skipped" from "forgotten."

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | `Goals & Non-Goals` section added to template | Section appears between `Overview` and `Target Audience` in `platform/templates/product/prd.md`; two goal slots and two non-goal slots wired as placeholder tokens | Always required (not "when applicable") |
| FR-002 | `Tech Stack` section added to template | Section appears after `Technical Constraints`; clearly labeled "when applicable"; table with Language/runtime, Framework, Data store, Hosting, Auth, Other layers | Optional |
| FR-003 | `API & Data Contracts` section added to template | Section appears after `Tech Stack`; labeled "when applicable"; endpoints table + data shapes block with link convention | Optional |
| FR-004 | `UI/UX Notes` section added to template | Section appears after `API & Data Contracts`; labeled "when applicable"; layout paragraph + explicit empty/loading/error/success state slots + a11y/responsive expectations | Optional |
| FR-005 | `CI/CD Gates` section added to template | Section appears after `UI/UX Notes`; labeled "when applicable, required for production-saas growth stage"; table covering lint, type-check, coverage, validators, companions, change-log | Optional |
| FR-006 | Placeholder reference updated | Every new placeholder token introduced in the template appears in `platform/templates/README.md` with usage column | Catches placeholder validator regressions |
| FR-007 | `product-lite` README documents the two flavors | § "Connecting to PRDs" describes governance vs. execution-spec PRDs and the `N/A — governance PRD` convention | Tells users how to use the new sections |
| FR-008 | PRD-0001 backfilled to current template | PRD-0001 has Version line, Cross-references, Goals & Non-Goals, and the four optional sections marked `N/A — governance PRD` | Backwards-compat demonstration |
| FR-009 | Change-log entry created | `docs/project/change-log.md` has a 2026-05-09 row referencing PRD-0002 | Self-governance dogfooding |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-010 | Validator chain still passes | `validate-manifest.sh`, `validate-module-graph.sh`, `validate-required-artifacts.sh`, `validate-companions.sh`, `validate-placeholders.sh` all exit 0 against the resulting tree | Must hold before commit |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| Two-template split (governance vs. execution-spec) | Single-template-with-optional-sections avoids template proliferation and keeps the ADR/PRD parallel intact | If review feedback shows the optional cue is routinely missed |
| Content-quality validator for Tech Stack / API / UI sections | Presence-only checks remain sufficient; quality stays a human review gate | If filled sections are routinely vacuous and content drift becomes a real problem |
| Updating the ADR template to mirror the new sections | ADRs record architectural decisions; product execution detail belongs in PRDs | If a future ADR needs API surface detail, revisit |

## Technical Constraints

- Must remain markdown-only — no schema, frontmatter, or programmatic parsing required.
- Must not break the placeholder validator: every new `[[...]]` token in the template must be documented in `platform/templates/README.md`.
- Must preserve existing companion-rule pattern: `^docs/requirements/PRD-` continues to satisfy `requiredAny` rules across the 13 product-facing modules.

## Tech Stack

*N/A — governance PRD, not a build spec. The change is a markdown template edit; no code stack is involved.*

## API & Data Contracts

*N/A — governance PRD, no API surface or data shape changes.*

## UI/UX Notes

*N/A — governance PRD, no user-facing surface.*

## CI/CD Gates

*N/A — additions are markdown edits and a new artifact (PRD-0002 itself); existing validator chain (`validate-manifest`, `validate-module-graph`, `validate-required-artifacts`, `validate-companions`, `validate-placeholders`) is sufficient and is run as part of acceptance.*

## Success Metrics

| KPI | Target | How measured |
|-----|--------|-------------|
| Validator chain pass | All 5 validators exit 0 after the change | Run the chain locally and observe in CI |
| Template self-consistency | Every placeholder token in `platform/templates/product/prd.md` is listed in `platform/templates/README.md` | `rg -o '\[\[[A-Z0-9_]+\]\]' platform/templates/product/prd.md \| sort -u` matches the README mapping |
| Backwards compatibility | PRD-0001 satisfies companion rules with the new template structure | Existing tests in `platform/validators/test/test_harness_registry.rb` continue to pass |

## Dependencies

- `2cfc3ae` (`feat(templates): absorb ADR and PRD improvements from adsclaw`) — provides the post-absorption baseline this PRD extends.
- PRD-0001 — provides the prior precedent for treating PRD-template changes as governance decisions in their own right.

## Open Questions

- (none remaining)
