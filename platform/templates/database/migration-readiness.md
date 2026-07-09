---
# Primary production SQL engine (single-value): one of postgres | mysql | mariadb | sqlite.
# Machine-checkable mirror of the "Database Engine" section below. Asserted-only in v1
# (human-reviewed; no validator yet) — keep it in sync with the prose.
engine: postgres
---

<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Migration Readiness — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

This document records the team's migration discipline: how migrations are authored,
reviewed, tested, and rolled back. It is a required artifact for any project using
the `relational-sql` data module.

---

## Database Engine

Declare the **primary production SQL engine** — single-value, one of `postgres`,
`mysql`, `mariadb`, or `sqlite`. It is mirrored in the YAML frontmatter above and
governs the dialect, migration tooling, and operational-posture notes that follow. (A
test-only SQLite alongside a Postgres production engine is an implementation detail,
not the declared engine.)

| Engine | Dialect / migration notes | Full-text search |
|--------|---------------------------|------------------|
| `postgres` | Transactional DDL — most migration tools apply DDL atomically, so a failed migration rolls back cleanly. Flyway / Liquibase / Alembic / Drizzle all first-class. | Native `tsvector` / GIN |
| `mysql` | Non-transactional DDL (implicit commits) — a failed migration can leave a partial schema; prefer small, individually reversible steps. | `FULLTEXT` indexes (InnoDB) |
| `mariadb` | MySQL-compatible; watch for divergence in JSON functions and sequence support across versions. | `FULLTEXT` indexes |
| `sqlite` | Limited `ALTER TABLE` (pre-3.35 has no drop/alter column — rebuild-and-copy); single writer at a time. | `FTS5` extension |

### SQLite operational posture (embedded)

When `engine: sqlite`, the operational model is **embedded**, not client/server: the
database is a single file in the application's storage, there is no replication or
managed backup service, and a "production apply" means shipping a file-level migration
with the release. The migration-records discipline still applies, but the "who applied
it to the server" column becomes "which release shipped it," and backups are file (or
WAL) snapshots rather than a DBA-run service.

---

## Migration Tooling

| Property | Value |
|----------|-------|
| Migration framework | [[MIGRATION_FRAMEWORK]] |
| Migration directory | [[MIGRATION_DIRECTORY]] |
| Run command (up) | [[MIGRATION_UP_COMMAND]] |
| Run command (down) | [[MIGRATION_DOWN_COMMAND]] |
| Status command | [[MIGRATION_STATUS_COMMAND]] |

---

## Migration Discipline

### Authoring Rules

- Every migration has a corresponding down/rollback migration
- Migrations are backward-compatible unless explicitly flagged and reviewed
- Data migrations (backfills, transforms) are separate from schema migrations
- No destructive operations (`DROP TABLE`, `DROP COLUMN`) without an ADR

### Review Requirements

- All migrations require code review before merge
- Destructive or data-altering migrations require [[MIGRATION_REVIEWER]] sign-off
- Migrations that affect indexes on large tables require performance review

### Testing

- Migrations are tested against a copy of production schema (not just empty database)
- Up and down migrations are both tested
- Migration test command: [[MIGRATION_TEST_COMMAND]]

---

## Rollback Policy

| Scenario | Action |
|----------|--------|
| Schema migration failed mid-apply | Run down migration, investigate, fix, re-apply |
| Schema migration succeeded but app broken | Run down migration, deploy previous app version |
| Data migration produced incorrect results | Execute corrective migration, document in incident record |
| Irreversible migration (acknowledged) | Must be flagged in PR, approved by [[MIGRATION_REVIEWER]], and have a forward-fix plan |

---

## Environment-Specific Notes

| Environment | Migration policy |
|-------------|-----------------|
| Local | Run freely; seed data may need refresh after down migrations |
| Staging | Applied automatically on deploy; must match production migration set |
| Production | Applied as part of release checklist; requires [[PRODUCTION_MIGRATION_APPROVER]] authorization |

---

## Companion Rule

Changes to the migration directory (`[[MIGRATION_DIRECTORY]]`) trigger a companion rule
requiring this file to also be updated in the same PR. This ensures migration documentation
stays current with the actual migration set.
