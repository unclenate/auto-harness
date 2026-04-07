# Ownership Map

<!-- Source: platform/profiles/management/project-standard or production-saas -->
<!-- Update: when team changes, when new domains are added, or at each major milestone. -->
<!-- This map drives reviewer assignment for sensitive-path changes. -->

**Last updated:** YYYY-MM-DD

Ownership maps declare who is responsible for each domain of the system. The primary owner
makes final decisions in their domain and is the first reviewer for changes touching it.
The secondary owner is the backup for reviews and incidents.

Domains marked **Sensitive** trigger elevated review gates in the harness companion rules.
Human review is required for any PR that modifies files in a sensitive domain.

---

## Ownership Table

| Domain | Description | Files / Paths | Primary Owner | Secondary Owner | Sensitive |
| ------ | ----------- | ------------- | ------------- | --------------- | --------- |
| Governance | Harness manifest, AGENTS.md, CLAUDE.md, CI workflows | `harness.manifest.yaml`, `AGENTS.md`, `.claude/`, `.github/` | [[OWNER]] | [[BACKUP]] | Yes |
| Product | Requirements, personas, discovery artifacts | `docs/product/`, `docs/discovery/` | [[PRODUCT_OWNER]] | [[BACKUP]] | No |
| Architecture | ADRs, architecture overview, system design | `docs/adr/`, `docs/architecture/` | [[TECH_LEAD]] | [[BACKUP]] | No |
| Data / Schema | Database migrations, schema definitions | `migrations/`, `prisma/`, `schema/` | [[DATA_OWNER]] | [[BACKUP]] | Yes |
| Auth / Security | Authentication, authorization, secrets config | `src/auth/`, `src/security/`, `.env.*` | [[SECURITY_OWNER]] | [[BACKUP]] | Yes |
| API surface | Public API routes, contracts, OpenAPI specs | `src/api/`, `openapi/` | [[API_OWNER]] | [[BACKUP]] | No |
| Infrastructure | Cloud config, IaC, environment variables | `infra/`, `terraform/`, `.env.production` | [[INFRA_OWNER]] | [[BACKUP]] | Yes |
| Observability | Logging, metrics, alerts, runbooks | `src/observability/`, `docs/ops/` | [[OPS_OWNER]] | [[BACKUP]] | No |
| [[DOMAIN]] | [[DESCRIPTION]] | [[PATHS]] | [[OWNER]] | [[BACKUP]] | Yes / No |

Add or remove rows to match your project's domain structure.

---

## Sensitive Domain Policy

For domains marked **Sensitive**, the following apply:

1. **PRs must include a human reviewer** — automated approval is not sufficient.
2. **Companion rules are active** — changes to sensitive paths must also update relevant
   governance artifacts (ADRs, runbooks, or change log) in the same PR.
3. **Tier escalation** — changes in sensitive domains may require Tier 4 or 5 approval
   per the trust model (`platform/core/kernel/base/trust-model.md`).

---

## Review Assignment

When the harness or CI flags a change in a sensitive domain, assign the primary owner
as reviewer. If unavailable, assign the secondary owner. Never merge a sensitive-domain
PR without at least one domain owner review.

---

## Reference

| Resource | Path |
| -------- | ---- |
| Trust model | `platform/core/kernel/base/trust-model.md` |
| Companion rules guide | `platform/workflow/skills-and-agents.md` |
| Risk register | `docs/security/risk-register.md` |
| CODEOWNERS | `.github/CODEOWNERS` |
