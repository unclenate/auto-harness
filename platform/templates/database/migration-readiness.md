<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Migration Readiness — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

This document records the team's migration discipline: how migrations are authored,
reviewed, tested, and rolled back. It is a required artifact for any project using
the `relational-postgres` data module.

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
