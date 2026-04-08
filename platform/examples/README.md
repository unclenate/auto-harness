# Examples

Working examples that demonstrate how harnessed projects look in practice. These are
illustrative — they show real content, not placeholder tokens — but they are not
canonical governance. For authoritative definitions, see the kernel and module READMEs.

---

## Composed Entrypoints

Sample `HARNESS.md`, `AGENTS.md`, and `CLAUDE.md` files showing how a project's root
agent adapter files reference the harness governance contract.

- [HARNESS.md](composed-entrypoints/HARNESS.md)
- [AGENTS.md](composed-entrypoints/AGENTS.md)
- [CLAUDE.md](composed-entrypoints/CLAUDE.md)

## Node Web SaaS Postgres

A complete sample project with all governance artifacts filled in. Demonstrates a
Node/TypeScript web app with PostgreSQL, using the `node-web-saas-postgres` composition.

**Root files:**

- [HARNESS.md](sample-projects/node-web-saas-postgres/HARNESS.md)
- [AGENTS.md](sample-projects/node-web-saas-postgres/AGENTS.md)
- [CLAUDE.md](sample-projects/node-web-saas-postgres/CLAUDE.md)
- [harness.manifest.yaml](sample-projects/node-web-saas-postgres/harness.manifest.yaml)

**Governance artifacts:**

- Discovery: [Intake Questionnaire](sample-projects/node-web-saas-postgres/docs/discovery/intake-questionnaire.md), [MVP Scope](sample-projects/node-web-saas-postgres/docs/discovery/mvp-scope.md)
- Product: [Problem Statement](sample-projects/node-web-saas-postgres/docs/product/problem-statement.md), [Personas](sample-projects/node-web-saas-postgres/docs/product/personas.md), [Requirements](sample-projects/node-web-saas-postgres/docs/product/requirements.md), [Release Intent](sample-projects/node-web-saas-postgres/docs/product/release-intent.md)
- Architecture: [Overview](sample-projects/node-web-saas-postgres/docs/architecture/overview.md)
- Database: [Migration Readiness](sample-projects/node-web-saas-postgres/docs/database/migration-readiness.md)
- Security: [Risk Register](sample-projects/node-web-saas-postgres/docs/security/risk-register.md)
- Operations: [Environment Inventory](sample-projects/node-web-saas-postgres/docs/ops/environment-inventory.md), [Release Checklist](sample-projects/node-web-saas-postgres/docs/ops/release-checklist.md), [Rollback Checklist](sample-projects/node-web-saas-postgres/docs/ops/rollback-checklist.md)
- Project: [Scope Plan](sample-projects/node-web-saas-postgres/docs/project/scope-plan.md), [Milestones](sample-projects/node-web-saas-postgres/docs/project/milestones.md), [Change Log](sample-projects/node-web-saas-postgres/docs/project/change-log.md), [Dependency Log](sample-projects/node-web-saas-postgres/docs/project/dependency-log.md)
- Governance: [Operating Principles](sample-projects/node-web-saas-postgres/docs/operating-principles.md)
