<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0012 — Generalize `data/relational-postgres` → `data/relational-sql` (engine sub-field)

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-24
**Last Updated:** 2026-05-24
**Confidence:** high

---

## Thesis

The harness's relational-data module is named `data/relational-postgres` —
the engine is baked into the module identity. A consumer project on
MySQL, MariaDB, or SQLite must either (a) activate the wrong-named module
and inherit the implied Postgres assumption, or (b) activate no relational
module and lose data-layer governance entirely. OpenEMR's brownfield
onboarding took option (b) for exactly this reason — MySQL-only project,
no module fits.

The substantive content of the module — migration readiness, schema
governance, ORM policy, connection pooling, transaction discipline — is
~95% engine-independent. The differences (specific syntax, migration tool
choice, full-text-search availability) are footnotes inside the required
artifact `docs/database/migration-readiness.md`, not module-level
distinctions.

Generalize the module name and contract:

- Rename `data/relational-postgres` → `data/relational-sql`
- Add a required `engine` field on the module declaration:
  `engine: postgres | mysql | mariadb | sqlite`
- Update the `migration-readiness.md` template with engine-aware sections
  (collapsible by engine; default to the consumer's declared engine)
- Provide a v1→v2 migration path: existing manifests declaring
  `data/relational-postgres` continue to validate, with a deprecation
  warning and a recommended `engine: postgres` declaration

This closes the data-module gap for OpenEMR (MySQL) without proliferating
near-identical modules per engine.

## Origin / Evidence

- **Consumer project: OpenEMR (`https://github.com/openemr/openemr`).**
  Brownfield onboarding session 2026-05-24 produced a gap analysis at
  `docs/knowledge/harness-coverage-gap-analysis.md` § G2 in the consumer
  project tree. Gap analysis evaluates two options (new
  `data/relational-mysql` module vs generalization to `data/relational-sql`
  with engine sub-field) and recommends generalization. This OPP adopts
  that recommendation.

- **Code-level evidence in OpenEMR:** `composer.json` extensions
  (`ext-mysqli`, `ext-pdo_mysql`), `sql/` directory with 50+ versioned
  MySQL upgrade scripts spanning two decades (`2_6_0-to-2_6_1_upgrade.sql`
  through `4_2_0-to-4_2_1_upgrade.sql` and beyond), `sql/Migrations/`
  (Doctrine Migrations 3.9), `adodb/adodb-php ^5.22` (legacy
  compatibility layer), `doctrine/dbal ^4.4`, `doctrine/orm ^3.6`.

- **OpenEMR's onboarding session explicitly omitted relational data.**
  From the bootstrap commit (`eced4ce`): *"Stacks and data modules omitted
  pending upstream catalog gaps (no stacks/php, no data/relational-mysql)."*
  The harness has Doctrine-Migrations-aware governance ready to apply, but
  no module to apply it through for a MySQL consumer.

- **MySQL ≠ rare niche.** It powers WordPress (≈40% of the web), Drupal,
  the majority of LAMP-stack legacy applications, and many healthcare /
  CMS / e-commerce systems. SQLite is the default for development
  databases, mobile apps, and embedded tooling. MariaDB is a drop-in
  MySQL replacement increasingly preferred for new deployments. The
  current module name implicitly excludes all of them.

- **The 95% overlap is real.** OpenEMR's gap analysis: *"The required
  artifacts are 95% identical between Postgres and MySQL; the differences
  are footnotes (engine-specific syntax, migration tool choice). The
  sub-field approach scales to SQLite (common in tests) and MariaDB
  (drop-in MySQL replacement) without further sprawl."*

- **Internal precedent.** Many existing modules already use sub-field
  patterns for closely-related variants — `delivery/` distinguishes
  `prototype` / `mvp` / `production-saas` / `internal-platform`, all of
  which share most artifacts. The engine sub-field on `relational-sql`
  is the same shape.

## Why Now

- **Unblocks the OpenEMR data layer.** OpenEMR's manifest currently
  declares no data module. Once `data/relational-sql` with
  `engine: mysql` exists, OpenEMR's manifest can activate it
  immediately, getting governance over its migration vault (50+
  versioned upgrade scripts plus Doctrine Migrations) and dual
  ADODB / Doctrine data abstraction layer. Deferring leaves OpenEMR's
  data layer ungoverned.

- **The migration cost compounds with delay.** Existing consumer
  projects on `data/relational-postgres` will need a coordinated
  migration. The longer the rename waits, the more consumers there
  are to coordinate. Filing now anchors the migration window before
  adoption broadens.

- **Aligns with other catalog-breadth OPPs filed in the same session.**
  OPP-0011 (PHP stack) and OPP-0013 (healthcare domain family) both
  unblock substantive OpenEMR canonization work. Generalizing the
  data module is the third leg of that "make catalog wide enough
  for OpenEMR to land cleanly" set.

## Risks / Open Questions

- **The rename is a breaking change for existing consumers.** Any project
  declaring `data/relational-postgres` in its manifest needs to update
  to `data/relational-sql` with `engine: postgres`. Mitigation: keep
  the old name as a deprecated alias for one minor version (e.g., v1.5
  emits a deprecation warning; v2.0 removes the alias).

- **`engine: sqlite` may want a different module entirely.** SQLite is
  often embedded rather than served — its operational posture (no
  backup service, no replication, single-file storage) diverges from
  Postgres / MySQL / MariaDB in ways that may make a shared module
  noisy. Validation: prototype the `migration-readiness.md` template
  with SQLite footnotes and see whether the footnotes overwhelm the
  engine-shared content. If yes, factor SQLite into a separate
  `data/relational-embedded` module.

- **`engine` as a single-value sub-field vs. multi-value.** Some
  consumers run Postgres in production and SQLite in tests. Does the
  module's `engine` field accept a list? Initial bias: single-value
  (the "primary production engine") to keep validator logic simple;
  test-environment SQLite is an implementation detail that doesn't
  need module-level governance.

- **OPP-0009 (data-module-embedded-key-value, YouBase) is adjacent.**
  Both OPPs touch the `data/` family. OPP-0009 proposes
  `data/embedded-key-value` for LevelDB-style storage. OPP-0012 (this
  one) reshapes the existing relational module. They don't conflict
  but they should land in a sensible order — relational-sql first
  (renames an existing module), then embedded-key-value (adds a new
  module to the same family).

## Disposition

<!-- Empty: status is proposed -->

## Promotion

<!-- Empty: not yet accepted -->

## Related

- Gap analysis source: consumer project (`openemr`) at
  `docs/knowledge/harness-coverage-gap-analysis.md` § G2b
- Module to be renamed: `platform/profiles/data/relational-postgres/`
- Adjacent OPP on the same family: [OPP-0009](OPP-0009-data-module-embedded-key-value.md)
  — adds `data/embedded-key-value` (YouBase project)
- Companion OPPs filed in the same session (OpenEMR canonization):
  [OPP-0011](OPP-0011-stack-module-php.md),
  [OPP-0013](OPP-0013-domain-family-healthcare-decomposed.md),
  [OPP-0014](OPP-0014-polyglot-companion-services.md),
  [OPP-0015](OPP-0015-regulated-compliance-test-kits.md),
  [OPP-0016](OPP-0016-specialist-healthcare-review-skills.md),
  [OPP-0017](OPP-0017-legacy-coexistence-template-family.md)
