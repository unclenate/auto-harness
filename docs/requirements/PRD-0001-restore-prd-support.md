# PRD-0001: Restore PRD Support as First-Class Governance Record

**Status:** Accepted
**Date:** 2026-04-07
**Author:** @unclenate
**Reviewers:** @unclenate

## Overview

The legacy harness had numbered PRDs (Product Requirements Documents) as first-class
records created alongside ADRs to capture product decisions during development. The
modular redesign collapsed this into "update requirements.md and log in change-log.md,"
losing the longitudinal institutional memory for product choices. This PRD restores
the PRD process as a first-class governance record type.

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Developer | Solo or small-team developer using AI assistants | A structured way to record product decisions that survives context switches |
| Team lead | Person responsible for product direction | Traceable record of what was decided, why, and what was rejected |

## User Stories

- As a developer, I want to create numbered PRDs for significant product decisions, so that the rationale is preserved for future contributors and AI agents.
- As a team lead, I want PRDs enforced by companion rules in CI, so that product changes don't bypass the decision record.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | PRD template | Template exists at `platform/templates/product/prd.md` with standard sections | Done |
| FR-002 | Companion rule integration | PRD pattern `^docs/requirements/PRD-` accepted by requiredAny in product-facing modules | Done — 13 modules, 15 rules |
| FR-003 | Canonical record status | PRDs listed as canonical records in kernel documentation | Done |
| FR-004 | Workflow integration | Bootstrap, discovery, and troubleshooting docs reference PRDs | Done |
| FR-005 | Test coverage | Unit tests confirm PRD satisfies companion rules | Done — 2 new tests |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| PRD-specific validator | Presence is checked by validate-required-artifacts; content quality is a review gate | If adoption reveals that templates are filled with placeholder content |
| PRD numbering automation | Manual numbering (PRD-NNNN) is sufficient at current scale | If projects accumulate 50+ PRDs |

## Technical Constraints

- Must use existing companion rule infrastructure (no new validator needed)
- Must follow the same `requiredAny` pattern as ADRs
- Web3 module excluded — its companion rules guard architecture/security boundaries

## Success Metrics

| KPI | Target | How measured |
|-----|--------|-------------|
| Companion rule coverage | PRD accepted by all non-web3 modules with ADR rules | Grep for `^docs/requirements/PRD-` across module.yaml files |
| Test coverage | 2+ tests confirming PRD satisfies companion rules | Test suite output |
| Template completeness | Template has all sections from legacy PRD format | Manual review |

## Dependencies

- Existing companion rule infrastructure (validate-companions.sh)
- Existing test suite (test_harness_registry.rb)

## Open Questions

- (none remaining)

## Related Documents

- ADR-0001: Modular governance architecture (`docs/adr/ADR-0001-modular-governance.md`)
- Legacy PRD format: `legacy/project-specific/CentralCityApp.Development.Harness.txt`
- Product-lite README: `platform/profiles/management/product-lite/README.md` § Connecting to PRDs
