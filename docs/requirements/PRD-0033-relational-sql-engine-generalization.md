<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0033: Generalize the Relational Data Module — `data/relational-postgres` → `data/relational-sql` (engine-in-artifact)

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-07-02 | **Review Cycle:** On-change

**Status:** Accepted *(design-only per § 9; a separate implementing PR performs the rename, adds the engine field, and migrates every in-repo consumer atomically)*
**Date:** 2026-07-02 (filed + accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Promoting OPP: [OPP-0012](../opportunities/OPP-0012-data-module-relational-sql-engine-generalization.md) — `proposed` at filing; this PRD ratifies its design and resolves its five open questions. **OPP-0012 flips `proposed → accepted` at the implementing PR's merge** (which edits `module.yaml`, tripping the PRD-0004 distillation rule there — where the reusable observation is captured — rather than in this design-only PR).
- Adjacent OPP, same `data/` family: [OPP-0009](../opportunities/OPP-0009-data-module-embedded-key-value.md) — adds `data/embedded-key-value`. Sequencing (per OPP-0012 open question 4): **`relational-sql` first** (renames an existing module), then `embedded-key-value` (adds a new one).
- Field-location precedent: [PRD-0028](PRD-0028-ai-foundry-target.md) — the AI-foundry `foundries` enum lives **in the artifact**, not `module.yaml`, because `module.schema.json` sets `additionalProperties: false`. The `engine` field here follows the same precedent for the same reason.
- Related operating-principles: § 9 (Split Design from Implementation — this PRD is the design; a separate PR implements), § 10 (the engine declaration is new **Asserted-only** content — no validator in v1; the rename does not change any existing enforcement posture).

## Overview

The relational-data module is named `data/relational-postgres` — the SQL engine is baked
into the module *identity*. A consumer on MySQL, MariaDB, or SQLite must either activate the
wrong-named module (inheriting an implied Postgres assumption) or activate no relational
module at all and lose data-layer governance. OpenEMR's brownfield onboarding took the
latter for exactly this reason (MySQL-only, no module fits).

The module's substantive content — migration readiness, schema governance, rollback
discipline, migration records, the migration-touch companion rule — is ~95%
engine-independent; the differences (dialect syntax, migration-tool choice, full-text-search
availability, SQLite's embedded operational posture) are footnotes inside the required
artifact `docs/database/migration-readiness.md`, not module-level distinctions.

This PRD ratifies generalizing the module to `data/relational-sql` with the engine declared
as an enum **in the artifact**, and specifies a **hard, atomic, single-commit rename** —
justified by the disk-verified finding that the rename's entire blast radius is in-repo.

## Design Decisions (resolving OPP-0012's open questions)

Disk verification (2026-07-02) established the facts these decisions rest on:

- **Blast radius is 100% in-repo:** `relational-postgres` is referenced as a hard dependency
  by **4 compositions** (`node-web-saas-postgres`, `python-api-service-postgres`,
  `brownfield-lite`, `web3-risk-analytics`), **1 module** (`domains/supabase` via
  `dependsOn`), and **2 sample-project manifests** (`node-web-saas-postgres`,
  `submodule-consumer`), plus ~30 prose references. **OpenEMR — the motivating consumer —
  declares no data module, so there is no external manifest depending on the current name.**
- **`engine:` on `module.yaml` fails schema validation:** `module.schema.json` sets
  `additionalProperties: false` and does not list `engine`; adding it as a module field would
  require extending the closed core schema that governs all profile modules.
- **No alias/deprecation facility exists:** module-id aliasing is not implemented in
  `harness_registry.rb`, and the `stability` enum has no `deprecated` value.

| # | OPP-0012 open question | Decision | Rationale |
|---|------------------------|----------|-----------|
| 1 | Migration approach for the breaking rename | **Hard, atomic, single-commit rename.** No alias facility built. | Every consumer is in-repo and migratable in one commit; CI (composition resolution + validator chain) proves the cutover is clean. An alias/deprecation mechanism would be net-new machinery serving *no* external consumer. OPP-0012's own "migration cost compounds with delay" argues acting while adoption is entirely internal. |
| 2 | Where does `engine` live | **In the artifact** — a `engine:` field in `docs/database/migration-readiness.md`, enum `{postgres, mysql, mariadb, sqlite}`. | `module.schema.json`'s `additionalProperties: false` forbids it on `module.yaml`; matches the PRD-0028 foundries-enum precedent. Zero core-schema change. |
| 3 | Is `engine` single-value or a list | **Single-value** — the primary production engine. | Test-environment SQLite (Postgres-in-prod / SQLite-in-tests) is an implementation detail below module-level governance. Keeps the artifact unambiguous. |
| 4 | Does SQLite want its own module | **No — keep SQLite in the shared `relational-sql` enum for v1**, with an engine-conditional operational-posture note in the template (SQLite = embedded: single-file, no replication/backup-service). Factor out a `data/relational-embedded` module **only if** the SQLite footnotes prove to overwhelm the engine-shared content (OPP-0012's own validation gate). | Avoids premature module sprawl; the shared artifact already carries the 95% overlap. |
| 5 | Order vs OPP-0009 (`embedded-key-value`) | **`relational-sql` first, then `embedded-key-value`.** | This one renames an existing module; OPP-0009 adds a new one to the same family. Renaming first avoids re-touching a just-added module. |

## Goals & Non-Goals

**Goals (for the implementing PR):**

- Rename `platform/profiles/data/relational-postgres/` → `data/relational-sql/`;
  `module.yaml` `id: relational-postgres` → `relational-sql`; keep all other module content
  (dependsOn, requiredArtifacts, sensitivePaths, companionRules, validators, reviewGates)
  identical. Major-version bump `1.0.0 → 2.0.0` (breaking identity change).
- Add an `engine:` field (enum `{postgres, mysql, mariadb, sqlite}`, single-value) to the
  `docs/database/migration-readiness.md` **template**, with engine-conditional sections
  (dialect/migration-tool footnotes; a SQLite embedded-posture note). Prose sections retained.
- Atomically migrate every in-repo consumer in the same commit: the 4 compositions, the
  `domains/supabase` `dependsOn`, and the 2 sample-project manifests.
- Sweep the ~30 prose references (README, SUMMARY, workflow docs, templates, skills,
  `module-types.md`) for the old id → new id (the non-validator cross-doc-consistency class).
- Profile-module count is **unchanged at 52** (a rename, not an addition) — no
  `validate-catalog-counts` bump.
- Flip OPP-0012 `proposed → accepted` and add one paired distillation observation (the
  in-repo-blast-radius / rename-economics insight), satisfying the PRD-0004 rule fired by the
  `module.yaml` + OPP edits.

**Non-Goals (deferred):**

- **An `engine`-enum content validator** (`validate-relational-engine.sh`-style). The engine
  field is **Asserted-only** in v1 (declared in the artifact, human-reviewed). A future OPP
  can add enum enforcement if a consumer surfaces the need — this keeps the rename focused.
- **A module-id alias/deprecation facility.** Explicitly not built (see Decision 1).
- **Extending `module.schema.json`** with a first-class `engine` property (see Decision 2).
- **A separate `data/relational-embedded` module for SQLite** (see Decision 4 — conditional,
  deferred).
- **`data/embedded-key-value` (OPP-0009).** Separate OPP, lands after this (see Decision 5).

## § 10 Claim Classification

| Claim ID | Claim | Current | After v1 |
|----------|-------|---------|----------|
| C-REL-1 | The relational-data module fits any SQL engine, not only Postgres | Implicit-false (the module is Postgres-named; non-Postgres consumers get no fit) | **True** — the module is engine-neutral (`data/relational-sql`); the consumer declares its engine in the artifact |
| C-REL-2 | The declared `engine` is a valid enum member (`postgres`/`mysql`/`mariadb`/`sqlite`) | n/a (no such field) | **Asserted-only** — declared in `migration-readiness.md`, human-reviewed; no validator in v1 |
| C-REL-3 | Migration changes carry a readiness/records artifact | Enforced (`validate-companions` on the migration-touch companion rule) | **Unchanged** — the companion rule is preserved verbatim through the rename |

The rename changes no existing enforcement posture (C-REL-3 is carried through intact); it
adds engine-neutrality (C-REL-1) and one new Asserted-only field (C-REL-2).

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001 | Module renamed | `platform/profiles/data/relational-sql/module.yaml` exists with `id: relational-sql`, `version: 2.0.0`; the old directory is gone. All other module.yaml fields byte-identical to the former `relational-postgres` except `id`, `version`, `summary` (engine-neutral wording), and `compiledFragments` path. `validate-module-schema` / `validate-module-stability` pass. |
| FR-002 | Engine field in the artifact | `platform/templates/database/migration-readiness.md` declares `engine:` (enum `{postgres, mysql, mariadb, sqlite}`, single-value) with engine-conditional sections and a SQLite embedded-posture note. No bracketed-placeholder or literal date-stub tokens (`validate-placeholders` clean). |
| FR-003 | Atomic in-repo consumer migration | The 4 compositions (`node-web-saas-postgres`, `python-api-service-postgres`, `brownfield-lite`, `web3-risk-analytics`), `domains/supabase`'s `dependsOn`, and the 2 sample-project manifests all reference `relational-sql`. Composition resolution + `validate-manifest` pass for every sample project. |
| FR-004 | Prose reference sweep | Every prose reference to `relational-postgres` (README, SUMMARY, `platform/workflow/**`, templates, skills, `platform/core/registry/module-types.md`, docs) updated to `relational-sql`; `validate-doc-references` / `validate-list-completeness` pass. Historical records (change-log, prior OPP/PRD bodies, dated plans/specs) are left as written (they describe the past). |
| FR-005 | Counts unchanged | Profile-module count stays **52**; `validate-catalog-counts` passes with no count edits. |
| FR-006 | OPP flip + distillation | OPP-0012 flipped `proposed → accepted`; one paired `shared-observations` entry added; change-log entry added. The full companion/distillation set (`validate-companions`, distillation rule) passes in PR-diff mode. |
| FR-007 | Chain stays green | The full validator chain passes; `git grep relational-postgres` returns only intentional historical records. |

### Should Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-S01 | Engine footnote quality | The engine-conditional sections are substantive (dialect, migration tool, full-text-search) rather than a bare enum echo, so a MySQL/MariaDB/SQLite consumer gets real guidance, not a Postgres doc with the name swapped. |

### Out of Scope

| Feature | Reason | Revisit |
|---------|--------|---------|
| `engine`-enum content validator | v1 keeps the field Asserted-only; the rename stays focused | future OPP if a consumer needs enforcement |
| Module-id alias / deprecation facility | blast radius is 100% in-repo; serves no external consumer | only if an external consumer adopts the old name before cutover |
| `module.schema.json` `engine` property | avoids changing the closed core schema | tied to the validator above |
| `data/relational-embedded` (SQLite) | premature module sprawl; conditional on footnote noise | if SQLite footnotes overwhelm shared content |
| `data/embedded-key-value` (OPP-0009) | separate OPP | after this rename |

## Technical Constraints

- **Rename, not copy** — preserve git history via `git mv` on the module directory.
- **Byte-identical carry-through** — the migration-touch companion rule, sensitivePaths, and
  reviewGates transfer verbatim; the rename must not silently alter enforcement.
- **Single atomic commit** for the id change + all consumer migrations, so no intermediate
  state has a dangling `dependsOn` / composition reference (composition resolution would fail
  a half-migrated tree).
- **No new runtime dependencies** — this is a rename + a template edit; no validator, no
  schema change.
- **Historical-record discipline** — dated change-log entries, prior OPP/PRD bodies, and
  `docs/superpowers/plans|specs/**` describe past decisions and are **not** rewritten; only
  live catalog surfaces are swept (the same discipline used in prior count/rename sweeps).

## CI/CD Gates

- Full validator chain green (24 validators — **no count change**), including
  `validate-catalog-counts`, `validate-doc-references`, `validate-list-completeness`,
  `validate-manifest` (all sample projects), `validate-companions`, and the PRD-0004
  distillation check in PR-diff mode.
- `git grep -n relational-postgres` returns only intentional historical records.
- markdownlint + shellcheck clean.

## Acceptance Criteria for OPP-0012 → `accepted`

OPP-0012 flips `proposed → accepted` when FR-001…FR-007 merge and the harness's own CI
passes — the module is engine-neutral, every in-repo consumer resolves against the new id,
and the engine field is live in the artifact template.

## Versioning Implications

Breaking at the **module** identity level (`relational-postgres` no longer resolves), but
**non-breaking for the catalog as a whole** because every consumer is migrated in the same
commit and there is no external manifest on the old id. Module version `1.0.0 → 2.0.0`. The
engine field is additive content on the `migration-readiness.md` artifact (a consumer
regenerates or adds it when adopting v2). Lands in the next minor release; profile-module
count unchanged at 52.
