# Migration Readiness Checklist

<!-- Complete this checklist for every database migration before it runs in production. -->
<!-- Companion rule: changes to this file or to migrations/ require a human reviewer. -->

**Migration ID / name:** [[MIGRATION_ID]]
**Author:** [[MIGRATION_AUTHOR]]
**Reviewer:** [[MIGRATION_REVIEWER]]
**Target environment:** staging → production
**Estimated runtime:** [[ESTIMATED_RUNTIME]]

---

## Review

- [ ] Migration script reviewed by a second developer (not the author)
- [ ] Migration is idempotent or has a clear non-idempotency justification documented below
- [ ] Migration does not drop columns or tables that are still referenced in application code
- [ ] All new columns have appropriate defaults or are nullable — no hard `NOT NULL` without default on existing tables
- [ ] Indexes are created `CONCURRENTLY` where applicable to avoid table locks
- [ ] Foreign key constraints are added in a separate migration from the column addition

## Compatibility

- [ ] Migration has been tested against a recent production data snapshot in staging
- [ ] Application code is compatible with both the pre- and post-migration schema (zero-downtime deploy pattern)
- [ ] No application code relies on a column or table being dropped in this migration

## Rollback

- [ ] Rollback script exists and has been tested
- [ ] Rollback runtime is acceptable (can be completed within the maintenance window if needed)
- [ ] Rollback does not cause data loss beyond what is acceptable given this migration's purpose

## Verification

- [ ] Migration ran successfully in staging within the past 48 hours with no errors
- [ ] Post-migration: key queries confirmed performant (no full table scans introduced)
- [ ] Post-migration: application smoke tests pass against the migrated schema

---

## Notes

_Document any non-idempotency justification, unusual locking behavior, or migration-specific
risks here. This section is required if any checklist item above is marked N/A._
