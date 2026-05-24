<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0017 — Legacy-Coexistence Template Family (+ PHI tripwire validator)

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-24
**Last Updated:** 2026-05-24
**Confidence:** medium-high

---

## Thesis

Mature brownfield projects routinely accumulate **legacy-modern coexistence
layers** — patterns where two implementations of the same concern run
side-by-side, one being the original and one being its replacement-in-
progress. The harness has no templates that document these patterns,
even though every long-running brownfield onboarding is likely to
encounter one or more.

OpenEMR exhibits four such patterns simultaneously, all in production
service:

- **Versioned SQL upgrade vault** — 50+ versioned upgrade scripts in
  `sql/` (`2_6_0-to-2_6_1_upgrade.sql` through current) coexisting with
  modern `sql/Migrations/` Doctrine Migrations. The vault is a frozen
  changelog of two decades of schema evolution; new schema changes go
  through Doctrine; the vault is preserved.
- **Dual data abstraction layer** — `adodb/adodb-php ^5.22` legacy
  compatibility surface coexisting with `doctrine/dbal ^4.4` modern
  abstraction. New code uses Doctrine; legacy code uses ADODB; both
  serve the same MySQL database.
- **Multi-template-engine migration** — Twig 3.x (modern), Smarty 4.5
  (legacy), and raw PHP (oldest) all live simultaneously. The migration
  direction is documented (Twig is target). Test infrastructure
  exists for both compilation and render tests of Twig templates.
- **Auth-pattern proliferation** — OAuth2 + OIDC server (modern), SMART
  on FHIR launch context (modern), gacl ACL (legacy), session-based
  patient portal auth (sub-app pattern). Multiple auth concerns
  layered, each correct for its scope.

The harness's existing templates don't acknowledge coexistence patterns
as a first-class concern. A brownfield-lite onboarding inherits a
`migration-readiness.md` template that assumes one data layer; that
implicit assumption fails to model OpenEMR's reality.

Add a coherent template family — `templates/coexistence/` plus an auth
sub-family — that documents these patterns:

| Template | What it captures |
|---|---|
| `templates/coexistence/upgrade-vault-history.md` | Long-tail versioned SQL upgrade pattern. Vault structure, how versions chain, how to author a new upgrade, when the vault closes (with the modern migration system taking over) |
| `templates/coexistence/dual-data-layer-migration.md` | Legacy + modern data abstraction coexistence. Migration direction, scope rules ("new code uses X, legacy stays on Y"), deprecation timeline, validator rules to prevent regression |
| `templates/coexistence/template-engine-migration.md` | Multi-template-engine coexistence (Twig + Smarty + PHP). Per-page engine selection rules, migration cadence, snapshot-test discipline for the modern engine |
| `templates/auth/oauth2-with-smart-scopes.md` | OAuth2 / OIDC server with healthcare-flavored scopes (`patient/`, `user/`, `system/`, plus SMART launch context). Generalizes to non-healthcare regulated industries |
| `templates/auth/acl-rbac-design.md` | Full ACL/RBAC reference (modeled on gacl, generalizable). Default-deny, scope hierarchy, scope-to-action mapping |
| `templates/auth/sub-app-portal-auth.md` | Pattern for an app exposing a portal sub-app with a separate auth surface |

Plus a PHI tripwire validator as the lightweight completion of the
audit toolkit:

- **`validate-no-phi-in-logs.sh`** — heuristic scan for variables named
  `patient_*`, `phi_*`, `ssn`, `dob`, `mrn`, `npi`, etc. in log calls.
  High false-positive tolerance — useful as a tripwire, not a gate.
  Healthcare-adjacent but applies to any PII-handling project.

This is the "absorption" layer of the OpenEMR canonization work — the
patterns where OpenEMR's lived experience teaches something the harness
should record before downstream consumers re-discover it.

## Origin / Evidence

- **Consumer project: OpenEMR (`https://github.com/openemr/openemr`).**
  Brownfield onboarding session 2026-05-24 produced a gap analysis at
  `docs/knowledge/harness-coverage-gap-analysis.md` §§ G8, G9, G10, G11,
  G16.

- **Code-level evidence in OpenEMR for each template:**
  - **Upgrade-vault-history:** `sql/` contains 50+ versioned `*_upgrade.sql`
    files. The names encode the version chain
    (`2_6_0-to-2_6_1_upgrade.sql`, `2_6_1-to-2_6_5_upgrade.sql`, …,
    `4_2_0-to-4_2_1_upgrade.sql`). Modern schema work uses
    `sql/Migrations/` (Doctrine Migrations).
  - **Dual-data-layer:** `composer.json` declares both
    `adodb/adodb-php ^5.22.11` (legacy compatibility surface) and
    `doctrine/dbal ^4.4` (modern). `library/ADODB_mysqli_log.php`
    instantiates the ADODB layer; `src/Core/Migrations/` houses the
    Doctrine-side migrations.
  - **Template-engine-migration:** `composer.json` includes Twig 3.x
    (modern) and Smarty 4.5 (legacy). OpenEMR's `CLAUDE.md` documents
    the migration direction: *"Templates: Twig 3.x (modern), Smarty 4.5
    (legacy)."* `tests/Tests/Isolated/Common/Twig/fixtures/render/`
    holds Twig render-test fixtures.
  - **Auth oauth2-with-smart-scopes:** `oauth2/authorize.php`,
    `src/Tools/OAuth2/ClientCredentialsAssertionGenerator.php`,
    `src/FHIR/SMART/`, `Documentation/api/AUTHENTICATION.md`,
    `Documentation/api/AUTHORIZATION.md`,
    `Documentation/api/SMART_ON_FHIR.md`.
  - **Auth acl-rbac-design:** `gacl/` (the gacl-php library OpenEMR
    customized), `src/Gacl/GaclApi.php`, `src/Gacl/GaclAdminApi.php`,
    `src/Gacl/Gacl.php`.
  - **Auth sub-app-portal-auth:** `portal/` (full sub-app),
    `src/Controllers/Portal/PatientPortalLoginController.php`,
    `src/Controllers/Portal/PortalLoginCredentialsRepository.php`,
    `src/Controllers/Portal/SqlPortalLoginCredentialsRepository.php`,
    `src/Controllers/Portal/PortalAuditLogger.php`.
  - **PHI-in-logs validator scope:** `src/Common/Logging/Audit/`,
    `EventAuditLogger`, `BreakglassChecker`, `PortalAuditLogger` —
    audit-log discipline in place; the validator would tripwire
    accidental PHI in *non-audit* logs (system logger, error stacks,
    etc.).

- **The coexistence patterns are not unique to OpenEMR.** Every
  long-running brownfield application accumulates equivalent patterns:
  WordPress with both legacy and modern hooks; Drupal with multiple
  generations of module APIs; Rails with `app/`-vs-`engines/`; Django
  with old `forms.py`-style and modern `forms/`. The OpenEMR-derived
  templates would document a pattern broader than OpenEMR — they
  formalize a class of governance need that every long-running
  consumer faces.

- **The harness's existing templates assume single-implementation
  systems.** `database/migration-readiness.md` doesn't anticipate a
  vault of versioned upgrade scripts alongside a modern migration
  system. `architecture-overview.md` doesn't anticipate three template
  engines. The coexistence templates fill a real gap, not a
  speculative one.

## Why Now

- **Anchors the OpenEMR canonization OPPs for legacy-pattern
  subsystems.** Several candidate OPPs in OpenEMR's
  `docs/opportunities/candidates.md` (OPP-0026 upgrade-vault, OPP-0027
  dual-layer, OPP-0028 template-engine migration) reference these
  templates directly. Filing the upstream OPP now lets the
  downstream-consumer OPPs land against real templates rather than
  placeholders.

- **Two-decade-tracking patterns are atypically rich.** OpenEMR is 25
  years old; the patterns it has accumulated are uncommonly mature.
  The harness's window to absorb them is the canonization session
  that's literally producing the evidence. Defer and the patterns
  get reconstructed from secondary sources.

- **The validator is small and ships independently.** Even if the
  template family takes time to design,
  `validate-no-phi-in-logs.sh` is a thin heuristic that can ship
  alone. Useful as a tripwire on any healthcare or PII-handling
  consumer. Doesn't depend on the templates landing first.

## Risks / Open Questions

- **Confidence medium-high because the templates need design work,
  not just absorption.** Each template captures a pattern OpenEMR
  exhibits, but generalizing the pattern into a consumer-fill
  template requires extracting OpenEMR-specific specifics (class
  names, code paths) from the general pattern shape. PRD authoring
  should weigh whether each template lands as a generic skeleton or
  as an OpenEMR-flavored example with an explicit "your equivalent
  here" structure.

- **`templates/coexistence/` family naming.** Is "coexistence" the
  right framing, or is it "legacy migration"? The patterns are about
  legacy-modern coexistence *during* a multi-year migration — both
  framings are partial. Initial bias: "coexistence" because it
  acknowledges that the coexistence period can be permanent (some
  legacy will never fully migrate).

- **Auth templates may belong with security family.** The auth
  templates (oauth2-with-smart-scopes, acl-rbac-design,
  sub-app-portal-auth) are auth-flavored, not coexistence-flavored.
  They could equally live under `templates/auth/` rather than
  `templates/coexistence/auth/`. PRD authoring decides the
  taxonomy.

- **PHI-in-logs validator false-positive rate.** Heuristic-based
  validators that scan for variable names will catch legitimate
  uses (e.g., a `patient_count` integer that's not PHI). Mitigation:
  the validator should be opt-in via manifest, with an allowlist
  file for known-safe patterns. Mirror the
  `.placeholder-ignore` /  `.doc-reference-ignore` allowlist pattern
  OpenEMR's onboarding flagged as worth absorbing into the harness.

- **`validate-no-phi-in-logs.sh` overlaps with broader PII-handling
  validation.** A PII-handling project (e.g., a fintech with SSN /
  bank-account fields) wants the same tripwire. Should the
  validator be `validate-no-pii-in-logs.sh` with PHI-specific
  variable lists as a configurable preset? Initial bias: name it
  PHI-specific to match the OpenEMR-derived evidence, but expose
  the variable-list as configuration so non-healthcare consumers
  can adopt with their own list.

## Disposition

<!-- Empty: status is proposed -->

## Promotion

<!-- Empty: not yet accepted -->

## Related

- Gap analysis source: consumer project (`openemr`) at
  `docs/knowledge/harness-coverage-gap-analysis.md` §§ G8, G9, G10, G11, G16
- Existing parallel templates: `platform/templates/database/migration-readiness.md`
  (which `upgrade-vault-history.md` extends)
- Allowlist-pattern reference: the consumer-project absorption
  observation about `.placeholder-ignore` / `.doc-reference-ignore`
  (in the cycle-end-distillation entry filed alongside this OPP)
- Companion OPPs filed in the same session (OpenEMR canonization):
  [OPP-0011](OPP-0011-stack-module-php.md),
  [OPP-0012](OPP-0012-data-module-relational-sql-engine-generalization.md),
  [OPP-0013](OPP-0013-domain-family-healthcare-decomposed.md),
  [OPP-0014](OPP-0014-polyglot-companion-services.md),
  [OPP-0015](OPP-0015-regulated-compliance-test-kits.md),
  [OPP-0016](OPP-0016-specialist-healthcare-review-skills.md)
