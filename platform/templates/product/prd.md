<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# PRD-NNNN: [[PRD_TITLE]]

**Version:** 1.0 | **Owner:** [[OWNER]] | **Last Updated:** YYYY-MM-DD | **Review Cycle:** [[REVIEW_CYCLE]]

**Status:** Proposed | Accepted | Superseded by PRD-NNNN | Deprecated
**Date:** YYYY-MM-DD
**Author:** [[OWNER]]
**Reviewers:** [[OWNER]]

## Cross-references

- Related ADRs: [[RELATED_ADR]]
- KPI definitions: `docs/standards/kpi-dictionary.md`
- Architecture context: `docs/architecture/overview.md`
- Other: [[RELATED_DOCUMENT]]

## Overview

[[PRD_OVERVIEW]]

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- [[GOAL_1]]
- [[GOAL_2]]

**Non-Goals** — outcomes explicitly out of scope. Be specific; vague non-goals
allow scope to creep back in:

- [[NON_GOAL_1]] — *(why excluded)*
- [[NON_GOAL_2]] — *(why excluded)*

> Distinction from `Functional Requirements > Out of Scope`: Non-Goals are
> *outcomes* ("we are not solving X for Y"); FR-Out-of-Scope is *features*
> ("we are not building feature Z").

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| [[PERSONA_NAME]] | | |

## User Stories

- As a [[PERSONA_NAME]], I want to [[USER_ACTION]], so that [[USER_VALUE]].

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | [[REQUIREMENT]] | [[ACCEPTANCE_CRITERIA]] | |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| | | After [[MILESTONE_1]] |

## Technical Constraints

- [[TECHNICAL_CONSTRAINT]]

## Tech Stack

*(When applicable — fill if this PRD drives AI-agent build work. Leave the
table empty for governance-only PRDs.)*

The stack below is decided. Do not re-architect during build. Architectural
changes require an ADR, not a rewrite during execution.

| Layer | Choice | Why |
|-------|--------|-----|
| Language / runtime | [[STACK_LANGUAGE]] | |
| Framework | [[STACK_FRAMEWORK]] | |
| Data store | [[STACK_DATA_STORE]] | |
| Hosting / deploy target | [[STACK_HOSTING]] | |
| Auth | [[STACK_AUTH]] | |
| Other (queue, cache, observability, etc.) | [[STACK_OTHER]] | |

## API & Data Contracts

*(When applicable — fill if this PRD introduces or changes API surface or data shapes.)*

**Endpoints:**

| Method | Path | Auth | Request body | Response shape |
|--------|------|------|--------------|----------------|
| [[API_METHOD]] | [[API_PATH]] | [[API_AUTH]] | [[API_REQUEST]] | [[API_RESPONSE]] |

**Data shapes:**

*(Schema for primary entities. Prefer linking to an authoritative source —
OpenAPI spec, Prisma schema, SQL migration, Pydantic model — over restating
inline. Inline only when no source-of-truth exists yet.)*

- [[DATA_ENTITY]] — see `[[DATA_SCHEMA_LINK]]`

## UI/UX Notes

*(When applicable — fill if this PRD has a user-facing surface.)*

**Layout:**

*(One paragraph per major view. Reference Figma / wireframes if available.)*

- [[VIEW_NAME]] — [[VIEW_LAYOUT_DESCRIPTION]]

**States to handle explicitly** *(this is where AI-agent builds drift most)*:

- Empty state: [[UI_EMPTY_STATE]]
- Loading state: [[UI_LOADING_STATE]]
- Error state: [[UI_ERROR_STATE]]
- Success / completion state: [[UI_SUCCESS_STATE]]

**Accessibility & responsive expectations:**

- WCAG target: [[UI_WCAG_TARGET]]
- Breakpoints / device support: [[UI_BREAKPOINTS]]

## CI/CD Gates

*(When applicable — required for production-saas growth stage; optional for
prototype / MVP. Co-locates the quality bar with the requirements that must
satisfy it.)*

| Gate | Required? | Notes |
|------|-----------|-------|
| Lint passes | [[GATE_LINT]] | |
| Type-check passes | [[GATE_TYPECHECK]] | e.g., `tsc --strict` |
| Test coverage threshold | [[GATE_COVERAGE]] | e.g., ≥80% line coverage |
| Required tests added | [[GATE_TESTS]] | List FR-IDs that must have tests |
| Validator chain passes | [[GATE_VALIDATORS]] | `bash platform/validators/validate-required-artifacts.sh` |
| Companion-rule check passes | [[GATE_COMPANIONS]] | `bash platform/validators/validate-companions.sh` |
| Change-log updated | [[GATE_CHANGELOG]] | `docs/project/change-log.md` |

For full release-stage checks, see `docs/ops/release-checklist.md`.

## Success Metrics

| KPI | Target | How measured |
|-----|--------|-------------|
| [[METRIC]] | [[TARGET]] | [[METHOD]] |

Reference specific KPIs from `docs/standards/kpi-dictionary.md` rather than
defining new ones inline.

## Dependencies

- [[DEPENDENCY_1]]

## Open Questions

- [ ] [[OPEN_QUESTION]]
