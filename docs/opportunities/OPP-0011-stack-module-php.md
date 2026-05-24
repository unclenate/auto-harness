<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0011 — Stack Module for PHP (with skill + two validators)

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-24
**Last Updated:** 2026-05-24
**Confidence:** high

---

## Thesis

The auto-harness stack catalog has `stacks/node-typescript` and `stacks/python`
but no module for PHP. PHP is one of the most common server-side languages —
particularly dominant in healthcare (OpenEMR, OpenMRS), CMS (WordPress, Drupal,
Joomla), e-commerce (Magento, PrestaShop), government, and academic research.
A PHP-primary consumer onboarding today selects no stack module (the conservative
choice — what OpenEMR's manifest did) and loses stack-aware governance, or
risks mis-selecting `node-typescript` because `package.json` exists for a
UI build pipeline.

This is the same structural gap OPP-0008 documents from a Node-JS-without-TS
angle — *two independent brownfield onboardings inside 24 hours both hit
"no stack module fits"*. The catalog needs breadth.

Close the PHP-shaped gap as a coherent four-part contribution:

1. **`stacks/php` module** — Composer dependency policy, PHPStan baseline
   posture, PHPCS / PER-CS coding-style adoption, Rector modernization,
   pre-commit hook routing.
2. **`harness-php` skill** — PHP-specific code-review skill that knows the
   PSR adoption table, the Composer / PHPStan / PHPCS / Rector toolchain,
   and the container-routed dev-workflow patterns that mature PHP projects
   use.
3. **`validate-php-strict-types.sh` validator** — confirms every `.php`
   file under `src/` declares `strict_types=1`. Counterpart to
   language-specific validators the harness already provides for other
   languages.
4. **`validate-conventional-commits.sh` validator** — general-purpose
   absorption from OpenEMR's CI; the harness has no validator for this
   even though Conventional Commits is one of the most common patterns
   adopted by harness consumers. PHP-adjacent but generalizable.

Bundling these under one OPP rather than four independent OPPs reflects
that they ship as a coherent "PHP-aware harness" — a single PRD scope
rather than four parallel ones.

## Origin / Evidence

- **Consumer project: OpenEMR (`https://github.com/openemr/openemr`).**
  Brownfield onboarding session 2026-05-24 produced a gap analysis at
  `docs/knowledge/harness-coverage-gap-analysis.md` in the consumer
  project tree, sized for direct upstream extraction. The analysis
  identifies gaps §G1 (`stacks/php`), §G13 (`harness-php` skill), §G17
  (`validate-php-strict-types.sh`), and §G18
  (`validate-conventional-commits.sh`). All four close together with
  one cohesive contribution.

- **Code-level evidence in OpenEMR:** `composer.json` (PHP ≥ 8.2.0, ~120
  dependencies including Laminas MVC, Symfony components, Doctrine,
  Monolog, Guzzle), `phpstan.neon.dist` (level 10 / max + custom rules
  at `tests/PHPStan/Rules/`), `phpcs.xml.dist` (PER-CS 3.0),
  `tests/Rector/` (modernization rules), `.pre-commit-config.yaml`
  (multi-tool hook suite routed through Docker via `prek-install`),
  `.github/workflows/conventional-commits.yml` (CI gate).

- **OpenEMR's onboarding session explicitly omitted stacks** rather than
  mis-classify. From the bootstrap commit (eced4ce on the consumer
  repo): *"Stacks and data modules omitted pending upstream catalog
  gaps (no stacks/php, no data/relational-mysql)."* Conservative module
  selection working as intended, but the cost is that PHP-aware governance
  the project would want (PSR adoption, PHPStan baseline policy, static-
  analysis discipline) has no home.

- **The trap is real, not theoretical.** OpenEMR's `package.json` is for
  a Gulp/SASS UI build (Angular 1.8 + jQuery + Bootstrap 4) and has no
  TypeScript. A less-careful onboarding would activate
  `stacks/node-typescript` because `package.json` exists, inheriting
  Node-TS required artifacts that don't apply. The brownfield
  assessment explicitly omitted stacks to avoid this trap; the harness
  should not require careful manual avoidance.

- **PSR adoption table is harness-relevant.** OpenEMR's `CLAUDE.md`
  declares PSR-1 / PSR-4 / PSR-3 / PSR-11 / PER-CS 3.0 adoption plus
  optional PSR-7 / 15 / 17 / 18 / 20. The harness's standards-pattern
  workflow (`platform/workflow/standards-pattern.md`) was built to
  govern exactly this kind of stack-level standards table —
  `stacks/php` would be its natural required-artifact home.

- **Convergence with OPP-0008.** YouBase's brownfield onboarding hit the
  same "no stack module fits" outcome from a Node-JS-without-TypeScript
  angle. Two consumer projects converging on the same gap within 24 hours
  is evidence that catalog breadth — not the harness's two-stack
  default — is the load-bearing issue.

- **Internal precedent.** `stacks/node-typescript` and `stacks/python`
  already establish the module shape. `stacks/php` mirrors their
  structure (low novelty risk), with the addition that PHP's static-
  analysis culture (PHPStan + Rector + PHPCS) is richer than most JS /
  Python setups and warrants explicit policy declaration.

## Why Now

- **Anchoring imminent OpenEMR canonization OPPs.** OpenEMR is the
  harness's first major brownfield canonization project; its per-
  subsystem OPPs (FHIR R4 server, HL7 v2, OAuth2/SMART, etc.) land
  imminently. Filing `stacks/php` before those land means the
  canonization OPPs reference a real module instead of a placeholder.
  Deferring means refactoring the canonization OPPs once the stack
  module ships.

- **Convergence with OPP-0008 raises the priority.** A single isolated
  catalog gap might be deferrable; two consumer projects hitting
  related gaps in the same session means the stack catalog needs
  broadening, not patching. The two OPPs together justify a "fix the
  stack catalog breadth" PRD that handles both shapes coherently.

- **The validators are independently valuable.** Even if `stacks/php`
  takes time to design, `validate-conventional-commits.sh` is small
  and ships standalone — many consumer projects already enforce the
  convention informally. The harness layer absorbs an existing CI
  pattern at no marginal cost.

## Risks / Open Questions

- **`stacks/php` granularity.** PHP has at least three large idiomatic
  sub-shapes: Symfony (DI-heavy, modern), Laravel (convention-heavy,
  also modern), and Laminas (where OpenEMR sits). Does the module
  govern the language layer or the framework layer? Initial bias:
  language layer (Composer / PHPStan / PHPCS / Rector are
  framework-independent); framework-specific overlays
  (`stacks/php-symfony`, `stacks/php-laravel`) would be separate OPPs
  if demand surfaces.

- **`validate-php-strict-types.sh` requires PHP installed in CI.** The
  harness's existing validators are Ruby + bash; this one introduces a
  PHP dependency on the runner. Options: (a) require PHP in the
  validator's CI matrix; (b) write a grep-only heuristic that catches
  the declaration without parsing; (c) defer to PHPStan's built-in
  `strictRules` config and only validate that the config is set
  correctly. Option (c) is most consistent with the harness's stance —
  delegate to the project's native tools where possible.

- **`validate-conventional-commits.sh` overlap.** Existing tools
  (commitlint, conventional-commits CLI, GitHub's commit-validation
  action) already do this. The harness validator should be thin: parse
  commit messages on the branch and check format. Should not reinvent
  the spec.

- **`harness-php` skill adoption.** Skills load on demand. If consumer
  projects mostly use generic language-agnostic skills, the PHP-specific
  skill may be ignored. Validation: monitor whether the skill is
  invoked during the OpenEMR canonization sessions; if not, it likely
  doesn't carry weight in other PHP consumers either.

## Disposition

<!-- Empty: status is proposed -->

## Promotion

<!-- Empty: not yet accepted -->

## Related

- Gap analysis source: consumer project (`openemr`) at
  `docs/knowledge/harness-coverage-gap-analysis.md` §§ G1, G13, G17, G18
- Convergent OPP: [OPP-0008](OPP-0008-stack-module-node-javascript-and-coffeescript.md)
  — same structural insight from a Node-JS-without-TS angle (YouBase project)
- Existing parallel modules: `platform/profiles/stacks/node-typescript/`,
  `platform/profiles/stacks/python/`
- Existing parallel validators: `platform/validators/validate-*.sh`
- Existing parallel skills: `platform/skills/harness-*`
- Companion OPPs filed in the same session (OpenEMR canonization):
  [OPP-0012](OPP-0012-data-module-relational-sql-engine-generalization.md),
  [OPP-0013](OPP-0013-domain-family-healthcare-decomposed.md),
  [OPP-0014](OPP-0014-polyglot-companion-services.md),
  [OPP-0015](OPP-0015-regulated-compliance-test-kits.md),
  [OPP-0016](OPP-0016-specialist-healthcare-review-skills.md),
  [OPP-0017](OPP-0017-legacy-coexistence-template-family.md)
