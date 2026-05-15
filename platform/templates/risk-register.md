<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Risk Register

<!-- Source: platform/profiles/delivery/production-saas or management/project-standard -->
<!-- Review cadence: monthly minimum; after every incident; before each major release. -->
<!-- Web3 projects: use templates/web3/risk-register-web3.md for chain-specific risks. -->

**Owner:** [[RISK_OWNER]]
**Last reviewed:** YYYY-MM-DD

This register tracks risks that could affect delivery, operations, security, or compliance.
It is a living document — add new risks as they are identified, update mitigations as they
are implemented, and move resolved risks to the Closed section.

A risk that becomes an active incident moves out of this register and into an incident
record (`docs/ops/incidents/`).

---

## Open Risks

| ID | Area | Risk | Likelihood | Impact | Mitigation | Owner | Status |
| -- | ---- | ---- | ---------- | ------ | ---------- | ----- | ------ |
| R-001 | [[AREA]] | [[DESCRIBE_THE_RISK]] | Low / Med / High | Low / Med / High | [[DESCRIBE_CONTROL_OR_PLAN]] | [[OWNER]] | Open / Monitoring / Mitigated |

**Area categories:** Security, Data, Infrastructure, Delivery, Compliance, Third-party, Team

**Likelihood definitions:**

- **High** — likely to occur within this release cycle
- **Med** — possible but not expected; worth monitoring
- **Low** — unlikely; document for awareness

**Impact definitions:**

- **High** — would block release, cause data loss, or create compliance exposure
- **Med** — would require significant rework or delay a milestone
- **Low** — manageable within normal operations

---

## Mitigation Guidance by Area

### Security

Common controls: dependency scanning in CI, secret scanning, SAST, pen test before launch,
security review for auth and data access paths.

### Data

Common controls: migration dry-run in staging, rollback plan documented, backup verified
before migration, data access audit log active.

### Infrastructure

Common controls: environment parity checks, load testing before production, runbook for
critical operations, on-call rotation defined.

### Compliance

Common controls: legal review for PII handling, GDPR/CCPA checklist, audit trail active
for regulated operations, retention policy documented.

### Third-party

Common controls: fallback for critical integrations, SLA reviewed, quota increase requested,
vendor incident contact documented.

### Delivery

Common controls: scope freeze date agreed, dependency log updated weekly, blockers escalated
within 24 hours, milestone exit criteria defined.

---

## Closed Risks

Move risks here when they are fully mitigated or no longer applicable. Preserve the record
— closed risks provide context for future decisions.

| ID | Area | Risk | Closed Date | Resolution |
| -- | ---- | ---- | ----------- | ---------- |
| R-00X | [[AREA]] | [[RISK]] | YYYY-MM-DD | [[HOW_RESOLVED]] |

---

## Reference

| Resource | Path |
| -------- | ---- |
| Web3 risk register | `platform/templates/web3/risk-register-web3.md` |
| Incident template | `platform/templates/incident.md` |
| Ownership map | `docs/security/ownership-map.md` |
| Trust model | `platform/core/kernel/base/trust-model.md` |
