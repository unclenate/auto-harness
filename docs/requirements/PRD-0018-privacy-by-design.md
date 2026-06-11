<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0018: Privacy-by-Design Module

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-03 | **Review Cycle:** On-change

**Status:** Accepted
**Date:** 2026-06-03
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- **Origin ADR:** [ADR-0018](../adr/ADR-0018-privacy-by-default-posture.md) —
  Privacy-by-Default Posture. This PRD is the build specification called out in
  that ADR.
- **Design context:** `docs/superpowers/specs/2026-06-03-privacy-by-design-design.md` —
  full design spec: module structure, artifact schema, validator contract, bootstrap
  wiring, and forcing-artifact list grounding all architectural decisions in this PRD.
- **Related operating principles:**
  - [§ 9 Split Design from Implementation](../operating-principles.md#9-split-design-from-implementation) —
    this PRD ships the design contract; the implementing PR ships the module
    scaffolding, templates, validator, and propagation.
  - [§ 10 Classify Claims Before Enforcing Them](../operating-principles.md#10-classify-claims-before-enforcing-them) —
    see §10 Claim Classification block below.
  - [§ 11 Privacy by Design, by Default](../operating-principles.md#11-privacy-by-design-by-default) —
    the governing doctrine this PRD makes operational.
- **Related PRDs:**
  - [PRD-0017](PRD-0017-healthcare-fhir-smart-wedge.md) — immediate predecessor;
    introduces the jurisdiction-neutral-core / forcing-artifact / bias-guardrail
    triad that this PRD applies cross-vertically.
  - [PRD-0016](PRD-0016-security-static-analysis-module.md) — sibling management
    overlay; the WARN-posture / ship-as-catalog / gated-inactive dogfood pattern
    this PRD follows.

## Overview

Privacy is a cross-cutting concern that touches every consumer project handling
personal or sensitive data. The harness is chartered to help consumers implement
Privacy by Design (PbD) by default — not merely permit it. The obligation is
proactive, not reactive (Cavoukian Principle 1).

No `management/privacy-by-design` module currently exists. Projects that want
structured privacy governance have no harness-native scaffold; there is no
forcing artifact requiring a declared legal regime, no companion rule pairing
data-handling changes with a privacy document, and no default-on mechanism
nudging new projects toward coverage.

This PRD specifies a new `management/privacy-by-design` module — the first
cross-vertical application of the jurisdiction-neutral-core / forcing-artifact /
bias-guardrail triad introduced in PRD-0017 — plus the validator, templates,
bootstrap wiring, and catalog propagation needed to make privacy coverage the
default for every bootstrapped consumer.

The content spine is Cavoukian's seven Foundational Principles of Privacy by
Design, which are jurisdiction-neutral by design. The applicable legal regime
(GDPR, CCPA/CPRA, LGPD, PIPEDA, PIPL, or none) is declared by the consumer
in the forcing artifact at initialization time; the harness never hard-codes
a regime.

v1 is **design-only** per § 9; the implementing PR builds the scaffolding,
validator, templates, and propagation.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- Ship `platform/profiles/management/privacy-by-design/module.yaml` +
  `README.md` declaring `type: management`, `dependsOn: [kernel/base]`,
  required artifact (`docs/privacy/privacy-profile.md`), optional artifacts,
  sensitive paths, companion rules, and review gates.
- Ship `validate-privacy-by-design.sh` — module-gated (exits 0 when inactive),
  VALIDATE layer (profile presence + consistency), WARN layer (privacy-risk
  patterns, exits 0), and `--scan-file` test seam.
- Ship `platform/templates/privacy/` with three templates including the
  bias-guardrail `privacy-profile.md` (seven-principle explainer + regime
  choice + `none` exemption path).
- Wire the module as default-active: `install.sh`-generated manifests include
  the overlay; discovery Step 6 lists it default-on; Bootstrap-Complete adds
  `privacy-profile.md` to its checklist; onboarding skill and
  intake-questionnaire educate at init flow.
- Wire CI (3 workflows) and propagate catalog counts: validators 14→15,
  modules 38→39, templates 66→69.
- Pass the full 15-validator suite with the module in a sample/test context;
  the validator is gated-inactive for auto-harness's own CI (exit 0).

**Non-Goals** — outcomes explicitly out of scope. Be specific; vague
non-goals allow scope to creep back in:

- **NOT a legal-compliance engine.** v1 forces the consumer to name their
  regime and complete the seven-principle profile; it does not verify the
  named regime's legal requirements are met. Legal sufficiency is the
  consumer's responsibility and a matter for specialist review.
- **NOT kernel-mandatory.** The module is default-on but opt-out is permitted
  for genuinely data-free projects. A `none` exemption in
  `docs/privacy/privacy-profile.md` is the documented, auditable exit.
- **NOT a runtime data scanner.** The validator inspects governance artifacts
  (profile presence, companion-rule pairing, regime consistency) — it does not
  scan runtime data, payloads, or log streams for PII.
- **The optional `harness-privacy` skill.** Deferrable to a should-have or
  Phase 2 delivery; this PRD does not block on it.

> Distinction from `Functional Requirements > Out of Scope`: Non-Goals are
> *outcomes* ("we are not solving legal compliance"); FR Out-of-Scope is
> *features* ("we are not building a DPIA tool").

## §10 Claim Classification

Per the [§10 operating principle](../operating-principles.md#10-classify-claims-before-enforcing-them),
this PRD names each load-bearing claim and its enforcement mechanism:

| Claim | Class | Mechanism |
|-------|-------|-----------|
| `docs/privacy/privacy-profile.md` exists when module is active | Enforced | `validate-privacy-by-design.sh` + `validate-required-artifacts.sh` |
| Data-handling change pairs with a privacy document | Enforced | `validate-companions.sh` (companion rule on data-handling paths) |
| Privacy-risk patterns are surfaced | Half-enforced | `validate-privacy-by-design.sh` WARN layer (best-effort scan, exits 0) |
| Privacy outcomes are correct and legally sufficient | Asserted-only | Review gate (`humanReview`) + bias-guardrail text in `privacy-profile.md` |

**Claims explicitly NOT converted by v1** (remain Asserted-only):

- **Profile is legally sufficient for the declared regime.** v1 forces the
  consumer to name their jurisdiction and complete the seven-principle
  profile; it does not verify the named regime's requirements are met. That
  is a specialist-review concern.
- **Data inventory is complete.** v1 validates that `data-inventory.md`
  exists when present; it does not verify completeness or accuracy of the
  declared data categories.
- **Privacy Impact Assessment covers all risks.** v1 validates that
  `privacy-impact-assessment.md` exists when present; risk-coverage
  assessment is a review-gate behavior.

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Harness maintainer | Repository's primary owner | The first cross-vertical application of the jurisdiction-neutral-core triad ships, validating the default-on bootstrap mechanism and the WARN-posture / ship-as-catalog pattern alongside PRD-0016. |
| Consumer maintainer handling PII | A team adopting auto-harness for a product that processes personal data | A scaffold with required artifacts that force regime declaration; companion rules that catch data-handling changes; templates with the seven-principle explainer and a `none` exemption for genuinely data-free scopes. |
| Data-free project maintainer | A team building a library or CLI tool with no PII | A clean, documented `none` exemption path in `docs/privacy/privacy-profile.md` that satisfies the validator without spurious ceremony. |
| Harness contributor | Outside contributor adding a new module or template | The `management/privacy-by-design` module provides a concrete structural precedent for cross-cutting management overlays with WARN-posture validators and default-on bootstrap wiring. |

## User Stories

- As a **consumer maintainer handling PII**, I want to bootstrap a new project
  and find `docs/privacy/privacy-profile.md` already present in my
  Bootstrap-Complete checklist, so that I cannot silently omit regime
  declaration or skip the seven-principle profile.
- As a **consumer maintainer handling PII**, I want companion rules to require
  a privacy document update whenever I change a data-handling path, so that
  privacy coverage stays synchronized with the codebase.
- As a **data-free project maintainer**, I want to write a `none` exemption in
  `docs/privacy/privacy-profile.md` and have the validator accept it cleanly,
  so that my CI does not produce spurious privacy warnings for a CLI tool that
  handles no personal data.
- As a **harness maintainer**, I want `validate-privacy-by-design.sh` to exit 0
  on auto-harness's own CI while the module ships as catalog (gated-inactive),
  so that self-dogfood CI remains green throughout the delivery.
- As a **harness contributor** reviewing a PR that edits a data-handling path,
  I want the companion rule to require a privacy document pairing, so that
  privacy artifact changes are tracked in the audit trail alongside the code
  changes that trigger them.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| M1 | `management/privacy-by-design` module scaffolding | `module.yaml` and `README.md` present at `platform/profiles/management/privacy-by-design/`. `module.yaml` declares `type: management`, `dependsOn: [kernel/base]`, `requiredArtifacts: [docs/privacy/privacy-profile.md]`, optional artifacts (`data-inventory.md`, `privacy-impact-assessment.md`), sensitive paths, two companion rules (data-handling change pairs a privacy doc; profile regime change pairs change-log/ADR), and review gates. | Mirrors the `management/eval-gated-testing` companion-rule and review-gate shape. |
| M2 | `validate-privacy-by-design.sh` | Script at `platform/validators/validate-privacy-by-design.sh`. Module-gated (exit 0 when inactive). VALIDATE layer: profile presence + consistency (data-inventory lists PII categories while profile regime is `none` → fail). WARN layer: privacy-risk patterns, exit 0. `--scan-file <path>` test seam per validator test-seam pattern. | WARN posture: validator is advisory, not blocking, on detected risk patterns. Gated-inactive for auto-harness own CI. |
| M3 | `platform/templates/privacy/` with three templates | `privacy-profile.md` (bias-guardrail: seven-principle explainer + regime choice + `none` exemption), `data-inventory.md`, `privacy-impact-assessment.md`. All carry SPDX headers (`UncleNate@gmail.com`, dual-license). | Bias-guardrail text in `privacy-profile.md` must state: "This module makes no legal regime the default. Declare yours below. Do not assume GDPR (or any single regime) norms, definitions, or compliance obligations." |
| M4 | Default-active mechanism + init-flow education | `install.sh`-generated manifest includes `management/privacy-by-design`; discovery Step 6 lists it default-on; Bootstrap-Complete checklist adds `docs/privacy/privacy-profile.md`; onboarding skill and intake-questionnaire include privacy-profile initialization guidance. | Cavoukian Principle 1 ("privacy as the default setting") met at the harness layer, not left to consumer initiative. |
| M5 | CI wiring + catalog-count propagation | Three CI workflow files updated to invoke `validate-privacy-by-design.sh`. Catalog counts propagated: validators 14→15, modules 38→39, templates 66→69. | Count sites: `validate-catalog-counts.sh` ASSERTIONS, `HARNESS.md`, `README.md` Module System table, any other documented count locations. |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-S01 | Optional `harness-privacy` skill | `platform/skills/harness-privacy/SKILL.md` providing privacy-by-design guidance, regime-specific pointers, and `privacy-profile.md` authoring examples. | Deferrable to Phase 2 or a follow-on PR. This PRD does not block on it. |
| FR-S02 | One paired distillation observation in `docs/knowledge/shared-observations.md` | Captures the design pressure of the first cross-vertical application of the jurisdiction-neutral-core / forcing-artifact / bias-guardrail triad. | Mirrors the knowledge-capture convention from PRD-0016 and PRD-0017. |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| Legal-compliance verification | Runtime legal sufficiency is a specialist-review concern; v1 validates governance declarations, not legal adequacy | If a consumer mounts a legal-tech linter in their CI and wants harness governance of its configuration |
| DPIA (Data Protection Impact Assessment) tooling | A structured DPIA tool is a separate domain concern; v1 only validates that a `privacy-impact-assessment.md` artifact exists when present | When a grounded consumer requests DPIA toolchain integration |
| PII detection in source files or payloads | Runtime scanning is out of scope for the WARN-posture validator; governance of artifacts, not data | If a future consumer requests automated PII scanning and a harness governance hook is appropriate |
| Kernel-mandatory enforcement | Rejected in ADR-0018; data-free projects would suffer spurious ceremony | ADR-0018 is settled; revisit only if the consumer-autonomy principle is revised |
| `harness-privacy` skill | Deferrable should-have; Phase 1 is design-only (§ 11 + ADR-0018 + this PRD); the module, validator, and templates are Phase 2 deliverables | Phase 2 or a follow-on PR per open question below |

## Implementation Deferral

Per operating principle § 9, this PRD ships the design contract; the
implementing PR adds the module scaffolding, validator, templates, bootstrap
wiring, CI updates, and catalog propagation.

| Deferred implementation | Deferred to | Why deferred |
|-------------------------|-------------|--------------|
| Module YAML + README scaffolding | Implementing PR (Phase 2) | Design-first discipline per § 9 |
| `validate-privacy-by-design.sh` | Implementing PR (Phase 2) | Same |
| Three privacy templates under `platform/templates/privacy/` | Implementing PR (Phase 2) | Same |
| Bootstrap wiring + init-flow education | Implementing PR (Phase 2) | Same |
| CI workflow updates + catalog-count propagation | Implementing PR (Phase 2) | Same |
| Distillation observation (FR-S02) | Implementing PR (Phase 2) | Captured during implementation, not design |
| Optional `harness-privacy` skill | Phase 2 or follow-on PR | Deferrable should-have |

What v1 (this PRD) commits to (the design contract that must hold before the
implementing PR is built):

- The `module.yaml` declaration shape as specified in M1.
- The validator contract (module-gated, VALIDATE + WARN layers, `--scan-file`
  seam) as specified in M2.
- The three-template set with bias-guardrail text as specified in M3.
- The default-active mechanism and init-flow education surfaces as specified in M4.
- The CI wiring and catalog-count targets as specified in M5.
- The 15-validator green requirement for the implementing PR.

## Technical Constraints

- **Module type: `management`.** Mirrors `management/security-static-analysis`
  and `management/eval-gated-testing` for companion-rule and review-gate shape.
- **Bash 3.2 + system Ruby** — existing CI environment; no new dependencies.
- **WARN posture for the validator.** The VALIDATE layer (profile presence +
  consistency) blocks on failure; the WARN layer (risk patterns) is advisory
  only (exits 0). This is a design constraint, not an implementation detail.
- **Module-gated activation.** `validate-privacy-by-design.sh` must exit 0
  cleanly when `management/privacy-by-design` is not active in the manifest.
  Auto-harness's own CI must remain green throughout delivery (ship-as-catalog
  dogfood-deferred pattern, per PRD-0016 precedent).
- **`--scan-file` test seam.** Required per the validator test-seam pattern
  (platform-root-fixed constraint affects every active-module enumerator);
  fixture-firing tests must not require a full harness manifest.
- **SPDX dual-license headers** on all new files: `SPDX-License-Identifier:
  MIT OR Apache-2.0`, copyright `2026 Nate DiNiro <UncleNate@gmail.com>`.
- **Jurisdiction-neutral core.** The module does not declare a default legal
  regime. The `privacy-profile.md` forcing artifact requires the consumer to
  name their regime. The bias-guardrail text in the template is mandatory.

## CI/CD Gates

| Gate | Required? | Notes |
|------|-----------|-------|
| Lint passes (markdownlint, shellcheck) | Yes | All new `.md` files pass markdownlint; new shell script passes shellcheck |
| Full 15-validator suite exits 0 | Yes | Both on the harness's own CI (gated-inactive path, exit 0) and against a sample/test context activating the module |
| Companion-rule check passes | Yes | `validate-companions.sh` passes; sensitive paths on the module overlap active trigger paths |
| List-completeness check passes | Yes | `validate-list-completeness.sh` resolves this PRD row in `docs/README.md` |
| Change-log updated | Yes | One entry in `docs/project/change-log.md` for the implementing PR |
| Catalog-count ASSERTIONS correct | Yes | `validate-catalog-counts.sh` ASSERTIONS bumped: validators 14→15, modules 38→39, templates 66→69; all documented count sites updated |

## Success Metrics

| KPI | Target | How measured |
|-----|--------|-------------|
| Dogfood pass rate at implementing PR | 100% — harness's own 15-validator suite passes (module present but not active in harness manifest; validator gated-inactive exits 0) | Implementing PR's CI run |
| Bootstrap coverage | Every `harness bootstrap`-generated manifest includes `management/privacy-by-design` | Bootstrap smoke test at implementing PR |
| Default exemption path | A project with `none` regime in `docs/privacy/privacy-profile.md` passes the validator cleanly | Fixture test with `--scan-file` seam |
| Consistency detection | A project with `data-inventory.md` listing PII categories while `privacy-profile.md` regime is `none` fails the VALIDATE layer | Fixture test with `--scan-file` seam |
| Bias-guardrail propagation | `privacy-profile.md` template carries the guardrail text verbatim as specified in M3 | Template file review at implementing PR |

## Dependencies

- `platform/validators/lib/harness_registry.rb` — module enumeration (existing;
  new module registered via the standard profiles path).
- `platform/profiles/management/` — sibling directory for `security-static-analysis`
  and `eval-gated-testing`; `privacy-by-design` follows the same shape.
- `platform/core/kernel/bootstrap/` — init-flow education wiring (Bootstrap-Complete
  checklist update).
- `install.sh` — default-manifest generation (adds `management/privacy-by-design`
  to generated manifests).
- Bash 3.2 + system Ruby (already in CI environment; no new gems or package
  manifests).

## Verification

The module is verified, not asserted:

- All 15 validators pass with the module active in a sample/test context
  (manifest, module-graph, required-artifacts, companions, catalog-counts,
  list-completeness, doc-references, and the new `validate-privacy-by-design.sh`).
- `validate-privacy-by-design.sh` exits 0 on auto-harness's own CI (gated-inactive;
  module not in harness manifest during ship-as-catalog period).
- markdownlint passes on all new and changed markdown.

## Open Questions

- [ ] **Dogfood / manifest default** — default ship-as-catalog, dogfood-deferred;
  the harness's own `harness.manifest.yaml` does not activate
  `management/privacy-by-design` until a maintainer-authorized change.
  **Bias: follow the PRD-0016 precedent exactly; ship-as-catalog with a gated
  validator; a separate PR activates the module in the harness's own manifest
  after the implementing PR is merged and CI is green.**
- [ ] **Exact sensitivePaths and WARN regex patterns** — validated against sample
  consumer trees at implementation time. Design spec names candidates (paths
  containing `privacy`, `pii`, `personal`, `gdpr`, `data`, `consent`, `dsar`,
  `retention`); the implementing PR finalizes and tests the set. **Bias: use the
  design spec candidates as the v1 starting point; refine if they cause false
  positives on real consumer trees.**
- [ ] **`harness-privacy` skill — ship in Phase 2 or defer to a later PR?**
  Phase 1 is design-only (§ 11 + ADR-0018 + this PRD); the module, validator,
  and templates are Phase 2 deliverables. The optional skill (FR-S01) is a
  should-have that can accompany Phase 2 or move to a follow-on PR.
  **Bias: include in Phase 2; the skill adds discoverability value and does
  not block any enforced claim, but co-shipping with the module is lower
  overhead than a dedicated follow-on PR.**
