<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# [[PROJECT_NAME]] — Fallback Matrix

**Version:** 1.0 | **Owner:** [[OWNER]] | **Last Updated:** YYYY-MM-DD | **Review Cycle:** [[REVIEW_CYCLE]]

**Purpose:** Define degraded-mode and manual fallback for every critical
automated function. Automation that fails silently is worse than no
automation. Every critical function must declare: normal mode, degraded
mode, manual fallback, and trigger conditions for switching modes.

---

## Fallback Principles

- **Every automated function has a defined fallback.** No exceptions for
  "it's always worked." The fallback is documented before the automation
  is marked production-ready.
- **Silent failures are forbidden.** A failed automation must raise a
  signal a human can act on — alert, ticket, dashboard, log.
- **Degraded > disabled > broken.** Prefer a reduced-capability mode over
  a hard failure. Prefer a manual fallback over losing the capability.
- **Fallbacks are tested.** A fallback that has never been exercised
  doesn't work.

---

## Component Failure Matrix

For each critical dependency, declare what breaks when it fails and what
the fallback is.

| Failed Component | Impact | Fallback | Trigger Condition |
|------------------|--------|----------|-------------------|
| [[COMPONENT_NAME]] | [[IMPACT]] | [[FALLBACK]] | [[TRIGGER]] |

<!-- Add one row per critical component. Typical categories:
     - External services (databases, APIs, auth providers)
     - Local services (model runtimes, container daemons)
     - Internal tooling (automation nodes, workers, schedulers)
     - Data pipelines (ingestion, transformation, delivery) -->

---

## Degradation Priorities

When capacity is constrained (resource exhaustion, partial outage,
planned maintenance), maintain these functions in priority order.
Higher-priority functions take precedence.

- **P0 — Revenue-critical / safety-critical:** [[P0_DESCRIPTION]]
- **P1 — Core business operation:** [[P1_DESCRIPTION]]
- **P2 — Delivery pipeline:** [[P2_DESCRIPTION]]
- **P3 — Convenience / non-blocking:** [[P3_DESCRIPTION]]

---

## Per-Function Fallback Mode

For each critical automated function, define all four modes.

### [[FUNCTION_NAME]]

- **Normal mode:** [[NORMAL_MODE]]
- **Degraded mode:** [[DEGRADED_MODE]]
- **Manual fallback:** [[MANUAL_FALLBACK]]
- **Switch trigger:** [[SWITCH_TRIGGER]]
- **Exit criteria (return to normal):** [[EXIT_CRITERIA]]

<!-- Duplicate the above block for each critical function. -->

---

## Fallback Exercise Log

Untested fallbacks are hypotheses. Exercise each fallback at least
quarterly and log the result.

| Function | Fallback Exercised | Date | Result | Issues Found |
|----------|-------------------|------|--------|--------------|
| [[FUNCTION_NAME]] | [[FALLBACK_TYPE]] | YYYY-MM-DD | Pass / Partial / Fail | [[NOTES]] |

---

## Cross-references

- Rollback procedures (restoration, not degradation): `docs/ops/rollback-checklist.md`
- Incident response (during active failures): `docs/ops/incident.md`
- Runbooks for manual fallback execution: `docs/ops/runbook-index.md`
- Related ADRs: [[RELATED_ADR]]

---

**Document Owner:** [[OWNER]]
