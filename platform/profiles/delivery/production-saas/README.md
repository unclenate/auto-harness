<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Delivery Overlay: Production SaaS

**Depends on:** `kernel/base`.
**Conflicts with:** `prototype`.

This overlay turns operational readiness into required artifacts instead of optional advice.
Activating it means real users, real data, and real consequences for downtime or data loss.
The four required ops artifacts enforce this reality before the first production deploy.

---

## Required Artifacts

**`docs/ops/environment-inventory.md`**
A record of every environment in the system (local, staging, production), what runs where,
how credentials are managed, and who has access to what. Without this, incident response
starts with archaeology.

**`docs/ops/release-checklist.md`**
The steps taken before and after every production release. Not a reminder list — a gate.
Each step has an owner and a pass/fail signal. Teams that skip this drift toward "it works
on my machine" deploys.

**`docs/ops/rollback-checklist.md`**
The steps to reverse a release if something goes wrong. Must be tested before it's needed.
A rollback checklist that has never been exercised is not a rollback plan.

**`docs/security/risk-register.md`**
A living record of known risks, their mitigations, and who owns each. Not a compliance
checkbox — an honest assessment of what could go wrong and what the team is doing about it.

---

## Optional: Fallback Matrix

**`docs/ops/fallback-matrix.md`** — Degraded-mode and manual fallback plan
for every critical automated function. Based on the principle that every
automated function must have a defined fallback, because automation that
fails silently is worse than no automation.

The fallback matrix complements but does not replace the rollback checklist.
Rollback reverses a release after failure; fallback keeps the system useful
*during* failure. They answer different questions:

| Artifact | Question it answers |
|----------|---------------------|
| `rollback-checklist.md` | How do we undo this release safely? |
| `incident.md` | How do we respond while the incident is active? |
| `fallback-matrix.md` | How do we stay useful while a dependency is failing? |
| `runbook-index.md` | Where are the step-by-step procedures? |

### When to adopt

This artifact is **optional on `production-saas`** but effectively required
before the project reaches the **Harness Ready** lifecycle stage (see
`platform/core/kernel/base/lifecycle-controls.md`). Expected progression:

| Lifecycle stage | Fallback matrix expected state |
|-----------------|-------------------------------|
| Bootstrap Complete | Empty template in place is fine; populating not required |
| Requirements captured | Component Failure Matrix populated — you know what your dependencies are |
| Pre-production launch | Per-Function Fallback Mode blocks defined for all critical functions; Degradation Priorities set |
| Harness Ready | First Fallback Exercise logged; matrix is current |
| Ongoing (post-launch) | Fallback Exercise Log updated quarterly; new functions add fallback definition before release |

### How to populate

Three paths depending on project stage:

1. **Greenfield projects** — Populate alongside architecture decisions. When
   an ADR names a new external dependency or automated function, the
   matrix gets a new row in the same change.
2. **Brownfield adoption** — Use the `harness-onboarding` skill's
   governance inventory phase to glean existing fallback patterns from the
   codebase, runbooks, or incident postmortems.
3. **Mid-project adoption** — Start with what breaks most: run a quick
   "what fails weekly" audit, document each component's current fallback
   behavior (even if it's "manual intervention by on-call"), then graduate
   from there.

Template: `platform/templates/ops/fallback-matrix.md`. Pattern absorbed
from adsclaw's fallback-first architecture principle.

---

## Companion Rule

Changes to delivery automation (`.github/workflows/`, `Dockerfile`, `terraform/`, `deploy/`,
`infra/`) trigger a companion rule requiring an update to at least one of the three ops
artifacts. Deployment topology changes must be reflected in operational documentation.

---

## Review Gates

*"Production posture requires named release ownership and rollback authority."*

Before any production release, a named human must own the release and be authorized to
execute the rollback checklist. Anonymous or automated deploys with no named owner are
a governance failure in production posture.

---

## Conflicts with `prototype`

These two postures are mutually exclusive. See `delivery/prototype/README.md` for graduation
criteria and the transition path.

---

## Agent Behavior

Agents may prepare release artifacts, update checklists, and propose infrastructure changes.
Agents must not apply infrastructure changes, trigger production deployments, or modify
environment credentials without explicit human authorization (Tier 4/5 actions).

---

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- Related module: [`delivery/internal-platform`](../internal-platform/README.md)
- Templates: `platform/templates/deployment/`
