# Delivery Overlay: Production SaaS

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
