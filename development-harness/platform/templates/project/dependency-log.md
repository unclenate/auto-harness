# Dependency Log

<!-- Source: platform/profiles/management/project-standard -->
<!-- Update when external dependencies are added, change status, or resolve. -->

This log tracks external dependencies that affect delivery: third-party APIs, vendor
integrations, platform services, shared infrastructure, and cross-team handoffs.
Internal library or package dependencies belong in `pyproject.toml` / `package.json`,
not here.

A dependency is worth logging when its status, availability, or readiness can block
a milestone or delivery phase.

---

## Active Dependencies

| Dependency | Type | Owner | Status | Impact if Delayed | Target Date | Notes |
| ---------- | ---- | ----- | ------ | ----------------- | ----------- | ----- |
| [[DEPENDENCY_1]] | Team / Vendor / Infra / API | [[OWNER]] | Open / In progress / Resolved / Blocked | [[IMPACT]] | YYYY-MM-DD | [[NOTE]] |

**Type definitions:**

- **Team** — another internal team's deliverable that this project depends on
- **Vendor** — external SaaS, tool, or service that must be provisioned or configured
- **Infra** — infrastructure provisioning (cloud resources, environments, DNS, certs)
- **API** — third-party API that must be available, stable, or quota-approved

---

## Resolved Dependencies

Move entries here when the dependency is fully resolved and no longer a delivery risk.

| Dependency | Type | Resolved Date | Resolution Notes |
| ---------- | ---- | ------------- | ---------------- |
| [[DEPENDENCY]] | [[TYPE]] | YYYY-MM-DD | [[HOW_IT_RESOLVED]] |

---

## Dependency Health Signals

- **Open > 2 weeks with no progress** — escalate to stakeholder report
- **Blocked** — add to stakeholder report decisions section immediately
- **Target date passed without resolution** — flag as milestone risk

---

## Reference

| Resource | Path |
| -------- | ---- |
| Milestones | `docs/project/milestones.md` |
| Change log | `docs/project/change-log.md` |
| Risk register | `docs/security/risk-register.md` |
| Stakeholder report | `docs/program/stakeholder-report.md` |
