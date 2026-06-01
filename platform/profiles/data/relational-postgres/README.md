<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Data Overlay: Relational Postgres

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay governs migration discipline, compatibility planning, and post-apply verification
for relational schema changes. It does not assume a specific migration tool — Flyway, Liquibase,
Alembic, Drizzle, and raw SQL migration files are all supported.

---

## What This Overlay Governs

**Required artifact:** `docs/database/migration-readiness.md`
Before any migration runs in production, this document must describe: what the migration does,
what the rollback procedure is, how compatibility with the running application is maintained
during the migration window, and what verification steps confirm success.

**Optional artifact:** `docs/database/migration-records/`
A directory of per-migration records for production applies. Recommended once the project
reaches production. Each record captures: migration applied, timestamp, who applied it, and
whether rollback was tested.

**Sensitive paths:** `migrations/`, `supabase/migrations/`, `alembic/`, `db/migrations/`
Changes to migration files trigger a companion rule requiring an update to the migration
readiness document or a migration record.

---

## Core Rule: Migration Apply Is a Human Action

> Schema migration generation may be automated. Schema migration application to production
> is always a human-directed Tier 4 action. Agents may propose migrations and validate their
> SQL, but the apply command runs under human authorization.

Review gate: *"Migration apply remains human-directed even if generation is automated."*

---

## Migration Discipline

Every migration that ships to production should be able to answer:

- **Compatibility:** Does the app run correctly against the old schema, the new schema, and
  during the transition window where both versions may be deployed?
- **Rollback:** If the migration must be reversed, what is the exact rollback procedure?
  Has it been tested?
- **Verification:** After applying, how do you confirm the migration succeeded? What does
  a partial or failed apply look like?
- **Destructive risk:** Does the migration delete columns, drop tables, or remove indexes?
  If yes, that warrants heightened review.

---

## How This Overlay Composes

| Pair with | When |
|-----------|------|
| `architectures/web-app` or `api-service` | Most web and API applications with relational data |
| `domains/supabase` | Supabase manages the Postgres instance |
| `delivery/production-saas` | Production data — migration records become essential |

---

## Agent Behavior

Agents may generate migration files and review migration SQL. Agents must not apply migrations
to any non-local database without explicit human authorization. Changes to migration files must
be accompanied by a migration readiness update or migration record in the same PR.

---

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- Related module: [`domains/supabase`](../../domains/supabase/README.md)
- Templates: `platform/templates/database/`
