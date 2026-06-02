<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0017 — Healthcare FHIR + SMART-on-FHIR Wedge

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-01 | **Review Cycle:** On-change

**Status:** Proposed
**Date:** 2026-06-01
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- **Origin OPP:** [OPP-0013](../opportunities/OPP-0013-domain-family-healthcare-decomposed.md) —
  Healthcare domain family (decomposed). This PRD is a partial promotion:
  `healthcare-fhir` and `healthcare-smart-on-fhir` sub-modules only. The
  remaining ten OPP-0013 sub-modules stay `proposed`.
- **Design context:** `docs/superpowers/specs/2026-06-01-deep-industry-domains-healthcare-wedge-design.md` —
  brainstorming spec grounding all architectural decisions in this PRD.
- **Related OPPs (out of scope for this PRD):**
  - [OPP-0016](../opportunities/OPP-0016-specialist-healthcare-review-skills.md) —
    Specialist healthcare review skills; stays `proposed`.
  - [OPP-0022](../opportunities/OPP-0022-patient-facing-health-agent-safety.md) — Patient-facing agent-safety overlay; stays `proposed`.
- **Sibling module precedent:**
  - [`domains/supabase`](../../platform/profiles/domains/supabase/module.yaml) —
    the intra-family dependency shape (`smart-on-fhir` depends on `fhir`)
    mirrors the `supabase → relational-postgres` composition pattern.
  - [`management/eval-gated-testing`](../../platform/profiles/management/eval-gated-testing/module.yaml)
    ([PRD-0009](PRD-0009-eval-gated-testing-module.md)) — opt-in management
    overlay shape this PRD's companion-rule and review-gate conventions follow.
- **Related operating principles:**
  - [§ 9 Split Design from Implementation](../operating-principles.md#9-split-design-from-implementation) —
    this PRD ships the design contract; the implementing PR ships the module
    scaffolding, templates, and propagation.
  - [§ 10 Classify Claims Before Enforcing Them](../operating-principles.md#10-classify-claims-before-enforcing-them) —
    see §10 Claim Classification block below.
- **Related PRDs:**
  - [PRD-0016](PRD-0016-security-static-analysis-module.md) — immediate
    predecessor; shapes the format and §10 vocabulary used here.

## Overview

The harness has no `domains/healthcare-*` coverage. Two grounded consumers
exist: **OpenEMR** (provider/operator-side EHR, server/provider-launch SMART
role) and **Tula** (patient-authorized client, patient-access SMART role where
the patient is the resource owner). The slice exercised by both consumers is
**FHIR** (the data layer) and **SMART on FHIR** (the app-launch and
scope-delegation protocol), which is exactly where the trust-role and
global-jurisdiction questions concentrate.

This PRD specifies two new `domains/` catalog modules — `healthcare-fhir` and
`healthcare-smart-on-fhir` — plus the templates, discoverability updates, and
sample composition needed to validate both modules end-to-end. v1 is
**design-only** per § 9; the implementing PR builds the scaffolding.

The wedge is intentionally minimal. Its scope is bounded to the FHIR + SMART
intersection so that:

1. The implementing PR is a single half-day unit of work.
2. The three harvested framework primitives (jurisdiction-profile forcing
   artifact, bias guardrail, decomposition + trust-role pattern) emerge from a
   working example rather than speculation, which the design spec explicitly
   requires before a general "deep domain framework" operating-principle is
   authored.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- Ship `platform/profiles/domains/healthcare-fhir/module.yaml` +
  `README.md` declaring `type: domain`, `dependsOn: [kernel/base]`,
  required artifacts, sensitive paths, companion rules, and review gates.
- Ship `platform/profiles/domains/healthcare-smart-on-fhir/module.yaml` +
  `README.md` declaring `type: domain`, `dependsOn: [kernel/base,
  healthcare-fhir]`, required artifact, sensitive paths, companion rules, and
  review gates. The intra-family dependency teaches the composition pattern.
- Ship `platform/templates/healthcare/` with three tokenized templates:
  `fhir-resource-map.md`, `jurisdiction-profile.md` (carrying the bias
  guardrail), and `smart-scope-map.md`.
- Close the discoverability gap: both modules appear in `SUMMARY.md` (TOC),
  `HARNESS.md` Active Modules, the catalog `README.md` Module table,
  `platform/skills/harness-onboarding/SKILL.md`, and
  `platform/workflow/discovery-to-composition.md` Step 6 rubric.
- Add one healthcare domain family diagram to `docs/architecture/diagrams.md`
  (the FHIR ← SMART-on-FHIR dependency, the role axis, the jurisdiction
  overlay).
- Pass the full 14-validator suite with both modules on disk.
- Ship a sample composition (`platform/compositions/healthcare-fhir-app.yaml`
  or equivalent) that activates both modules and validates clean.

**Non-Goals** — outcomes explicitly out of scope. Be specific; vague
non-goals allow scope to creep back in:

- **The other ten OPP-0013 sub-modules** (hl7v2, ccda, ePrescribing, cdr,
  cqm, phi-encryption, audit-log, direct-messaging, ehi-export,
  patient-portal). Each is a separate future PRD. This PRD ships the wedge
  only.
- **[OPP-0022](../opportunities/OPP-0022-patient-facing-health-agent-safety.md) patient-facing agent-safety overlay.** Different governance
  surface (agent behavior under patient data access, not SMART mechanics).
  Stays a separate future module.
- **OPP-0016 specialist healthcare review skills.** Stays `proposed`.
  This PRD adds only the minimal onboarding pointer inside
  `harness-onboarding/SKILL.md`.
- **The abstract "deep domain framework" operating-principle / ADR.** Per
  the design spec's harvest plan: the three framework primitives are named
  here for deliberateness, but the operating-principle is authored in a later
  pass, stress-tested against finance and logistics before promotion.
- **A new validator specific to healthcare.** FHIR/SMART governance is
  expressible through the existing `validate-required-artifacts.sh` +
  `validate-companions.sh` machinery. No new validator is added by this PRD;
  the claim that required artifacts exist is enforced by the existing chain.

> Distinction from `Functional Requirements > Out of Scope`: Non-Goals are
> *outcomes* ("we are not solving runtime FHIR validation"); FR Out-of-Scope
> is *features* ("we are not building a resource-schema linter").

## §10 Claim Classification

Per the [§10 operating principle](../operating-principles.md#10-classify-claims-before-enforcing-them),
this PRD names each load-bearing claim and its enforcement mechanism:

| Claim | Class | Mechanism |
|-------|-------|-----------|
| Required artifacts exist when a healthcare module is active | Enforced | `validate-required-artifacts.sh` |
| Sensitive-path edits pair with a governance document | Enforced | `validate-companions.sh` |
| Jurisdiction is declared, never assumed | Asserted-only | review gate + bias-guardrail text in `jurisdiction-profile.md` template |
| Provider/patient scope boundary is respected | Asserted-only | review gate (`humanReview`) on any provider↔patient scope-boundary edit |
| Intra-family module dependency resolves cleanly | Enforced | `validate-module-graph.sh` |

**Claims explicitly NOT converted by v1** (remain Asserted-only):

- **FHIR resources are structurally valid against a profile.** v1 validates the
  governance *declaration* (`fhir-resource-map.md` exists and is well-formed);
  it does not invoke a FHIR profile validator. Runtime resource validation is
  out of scope.
- **Jurisdiction-profile is legally sufficient.** v1's bias guardrail forces
  the consumer to name their jurisdiction(s). It does not verify the named
  jurisdiction's legal requirements are met. Sufficiency is the consumer's
  responsibility and a matter for specialist review (OPP-0016).
- **SMART scopes satisfy the minimal-necessary principle.** v1 requires the
  `smart-scope-map.md` artifact exists with provider-launch and patient-access
  sections; it does not enumerate or assess the declared scopes against a
  minimal-necessary policy. That assessment is a review-gate behavior.

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Harness maintainer | Repository's primary owner | The first deep-domain wedge lands, validating the module composition pattern (`smart-on-fhir → fhir`) and grounding the three harvested framework primitives in a working example. |
| Healthcare consumer maintainer | A team adopting auto-harness for OpenEMR, Tula, or another FHIR/SMART project | Catalog modules with clear required artifacts; templates that force jurisdiction declaration and scope-map documentation; discoverability from `harness-onboarding/SKILL.md`. |
| Harness contributor | Outside contributor adding a healthcare module or template | The two modules provide a concrete structural precedent for deep-domain family modules; the intra-family dependency pattern is documented in `harness-onboarding/SKILL.md`. |
| Future vertical designer | Someone designing the next deep-domain wedge (finance, logistics, manufacturing) | The three harvested framework primitives (jurisdiction-forcing artifact, bias guardrail, decomposition + trust-role pattern) are named and documented in this PRD's design context so the generalization pass has a concrete reference. |

## User Stories

- As a **healthcare consumer maintainer**, I want to activate
  `domains/healthcare-fhir` in my manifest and have the harness require
  `docs/healthcare/fhir-resource-map.md` and
  `docs/healthcare/jurisdiction-profile.md`, so that new contributors cannot
  silently omit jurisdiction context or skip the resource inventory.
- As a **healthcare consumer maintainer**, I want to activate
  `domains/healthcare-smart-on-fhir` on top of `healthcare-fhir` and have the
  harness require `docs/healthcare/smart-scope-map.md` with explicit
  provider-launch and patient-access sections, so that the trust-role boundary
  is documented and reviewable before scope grants are shipped.
- As a **harness maintainer**, I want both modules to pass the full 14-validator
  suite clean (no new validators added, no existing assertion weakened), so that
  the wedge lands without harness-side fixing churn.
- As a **harness contributor** reviewing a PR that edits a FHIR-sensitive path,
  I want the companion rule to require an ADR or change-log entry, so that
  jurisdictional or PHI-boundary changes are tracked in the audit trail.
- As a **future vertical designer**, I want the jurisdiction-profile template to
  carry an explicit bias-guardrail block I can copy verbatim to finance or
  logistics, so the "no jurisdiction is the default" norm spreads across
  verticals without re-inventing it each time.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | `domains/healthcare-fhir` module scaffolding | `module.yaml` and `README.md` present at `platform/profiles/domains/healthcare-fhir/`. `module.yaml` declares `type: domain`, `dependsOn: [kernel/base]`, `conflictsWith: []`, `requiredArtifacts: [docs/healthcare/fhir-resource-map.md, docs/healthcare/jurisdiction-profile.md]`, sensitive paths, companion rules, review gate. | First `domains/` type modules in the catalog at time of this PRD; mirrors the opt-in management overlay shape for companion rules and review gates. |
| FR-002 | `domains/healthcare-smart-on-fhir` module scaffolding | `module.yaml` and `README.md` present at `platform/profiles/domains/healthcare-smart-on-fhir/`. `module.yaml` declares `type: domain`, `dependsOn: [kernel/base, healthcare-fhir]`, `conflictsWith: []`, `requiredArtifacts: [docs/healthcare/smart-scope-map.md]`, sensitive paths, companion rules, review gate. | Intra-family dependency on `healthcare-fhir` must resolve cleanly in `validate-module-graph.sh`. |
| FR-003 | `platform/templates/healthcare/` with three templates | `fhir-resource-map.md`, `jurisdiction-profile.md` (with bias-guardrail block), and `smart-scope-map.md` (with provider-launch and patient-access sections and trust-model note). All carry tokenized SPDX headers per attribution convention (`UncleNate@gmail.com`, dual-license). | Bias-guardrail text per design spec: "This module makes no jurisdiction the default. Declare yours below. Do not assume US (or any single region) norms, code sets, or legal regimes." |
| FR-004 | Discoverability propagation | Both modules and a "Healthcare domain family" orientation appear in: `SUMMARY.md` Module Library, `HARNESS.md` Active Modules, `platform/skills/harness-onboarding/SKILL.md` domain catalog, `platform/workflow/discovery-to-composition.md` Step 6 rubric. | Standard companion-rule propagation requirement per `CLAUDE.md`. |
| FR-005 | Healthcare domain family diagram in `docs/architecture/diagrams.md` | One diagram: `fhir ← smart-on-fhir` dependency, the provider/patient role axis, and the jurisdiction overlay. Authored as a template diagram for any future deep-domain family. | Doubles as the structural reference for the future generalization pass. |
| FR-006 | Sample composition activating both modules | A file at `platform/compositions/healthcare-fhir-app.yaml` (or an equivalent sample project) activates both `domains/healthcare-fhir` and `domains/healthcare-smart-on-fhir` and validates clean through the full validator suite. | Integration test for the intra-family dependency and required-artifact assertions. |
| FR-007 | Full 14-validator suite passes | `validate-manifest.sh`, `validate-module-graph.sh`, `validate-required-artifacts.sh`, `validate-placeholders.sh`, `validate-agent-pack.sh`, `validate-companions.sh`, `validate-doc-references.sh`, `validate-catalog-counts.sh`, `validate-list-completeness.sh`, `validate-trust-tier.sh`, `validate-sensitive-paths.sh`, `validate-knowledge-redaction.sh`, `validate-skill-content.sh`, `validate-sast-coverage.sh` all exit 0. No ASSERTIONS bumps needed for the two new modules (confirm during implementation). | Predict-clean absorption: the harness does not activate the new modules, so most validators are no-op pass or unchanged. Anticipated ASSERTIONS bump for module counts; the implementing PR must update all documented count sites per the Open Question on validate-catalog-counts.sh. |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-S01 | One paired distillation observation in `docs/knowledge/shared-observations.md` | Captures the design pressure of adding the first `domains/` type modules (as distinct from `management/` type). Anticipated observation: the intra-family dependency pattern and how it surfaces during `validate-module-graph.sh` testing. | Mirrors the knowledge-capture convention from PRD-0016. |
| FR-S02 | `platform/profiles/management/security-static-analysis/README.md`-style "when to use" guidance in both module READMEs | Each module README includes a short "when to activate this module" block naming the two grounded consumers (OpenEMR, Tula) and the role (provider vs patient). | Reduces activation friction for new healthcare consumers. |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| FHIR resource structure validation (schema / profile linting) | Runtime FHIR validation is a separate toolchain concern; v1 validates governance declarations, not resource payloads | If a consumer mounts a FHIR profile validator in their CI and wants harness governance of the validator configuration |
| [OPP-0022](../opportunities/OPP-0022-patient-facing-health-agent-safety.md) patient-facing agent-safety overlay | Different governance surface (agent behavior under patient data, not SMART mechanics); separate future module | When OPP-0022 reaches PRD pass |
| HL7v2, CCDA, ePrescribing, and the other ten OPP-0013 sub-modules | Out-of-wedge sub-domains; each gets its own PRD when a grounded consumer surfaces the need | Per OPP-0013 decomposition |
| Abstract "deep domain framework" operating-principle | Authored in a later pass after stress-testing against finance + logistics per the design spec's harvest plan | After the wedge ships and validates; see "Harvest plan" in design context |
| Specialist healthcare review skills (OPP-0016) | Separate OPP, different scope | When OPP-0016 reaches PRD pass |
| A new healthcare-specific validator | Existing validators (`validate-required-artifacts.sh`, `validate-companions.sh`) cover all enforced claims; no new validator needed | If a healthcare-specific structural assertion (e.g., scope-set minimality) proves mechanizable |

## Implementation Deferral

Per operating principle § 9, this PRD ships the design contract; the
implementing PR adds the module scaffolding, templates, discoverability
updates, and sample composition.

| Deferred implementation | Deferred to | Why deferred |
|-------------------------|-------------|--------------|
| Module YAML + README scaffolding for both modules | Implementing PR (Phase 2) | Design-first discipline per § 9 |
| Three healthcare templates under `platform/templates/healthcare/` | Implementing PR (Phase 2) | Same |
| Discoverability propagation (SUMMARY.md, HARNESS.md, onboarding skill, discovery-to-composition.md) | Implementing PR (Phase 2) | Same |
| Sample composition activating both modules | Implementing PR (Phase 2) | Same |
| Distillation observation (FR-S01) | Implementing PR (Phase 2) | Captured during implementation, not design |
| Abstract deep-domain framework operating-principle | Post-wedge harvest pass (separate spec → plan cycle) | Must be grounded in a working example; the wedge must ship first |
| Finance / logistics paper stress-test of the three primitives | Post-wedge harvest pass | Meaningless before the wedge validates the primitives |

What v1 (this PRD) commits to (the design contract that must hold before the
implementing PR is built):

- Both module `module.yaml` declarations as specified in FR-001 and FR-002,
  including the intra-family `dependsOn` relationship.
- The three templates with the bias-guardrail and trust-model note as specified
  in FR-003.
- The discoverability surfaces named in FR-004.
- The diagram spec in FR-005.
- The sample composition strategy named in FR-006.
- The 14-validator green requirement in FR-007.

## Technical Constraints

- **Module type: `domain`.** This PRD ships the first `domains/` type modules
  in the catalog. Confirm that the module-graph validator accepts `domain` type
  and resolves intra-family `dependsOn` during implementation. If not, a
  validator patch is in scope for the implementing PR.
- **Bash 3.2 + system Ruby** — existing CI environment; no new dependencies.
- **No new validator added by this PRD.** All enforced claims are expressed
  through the existing validator chain. If `validate-catalog-counts.sh`
  ASSERTIONS for module counts need bumping (active-modules-reachable or
  profiles module count), that is in scope for the implementing PR.
- **SPDX dual-license headers** on all new files:
  `SPDX-License-Identifier: MIT OR Apache-2.0`, copyright
  `2026 Nate DiNiro <UncleNate@gmail.com>`.
- **Jurisdiction-neutral core.** Neither module declares a default jurisdiction.
  The required artifacts force the consumer to declare theirs. This is a
  design constraint, not an implementation detail.
- **Intra-family dependency resolution.** `domains/healthcare-smart-on-fhir`
  declares `dependsOn: [kernel/base, healthcare-fhir]`. The
  `validate-module-graph.sh` validator must resolve this without a new
  module-graph validation path. If a patch is needed, it is in-scope for the
  implementing PR and must not break existing module-graph tests.

## CI/CD Gates

| Gate | Required? | Notes |
|------|-----------|-------|
| Lint passes (markdownlint, shellcheck) | Yes | All new `.md` files pass markdownlint; no new shell scripts added by this PRD |
| Full 14-validator suite exits 0 | Yes | Both on the harness's own CI (predict-clean path) and against the sample composition (activates the modules) |
| Companion-rule check passes | Yes | `validate-companions.sh` passes; sensitive paths on both modules overlap active trigger paths |
| List-completeness check passes | Yes | `validate-list-completeness.sh` resolves this PRD row in `docs/README.md` |
| Change-log updated | Yes | One entry in `docs/project/change-log.md` for the implementing PR |
| No ASSERTIONS regression in `validate-catalog-counts.sh` | Yes | If module-count ASSERTIONS are bumped, the bumps are correct and documented in the implementing PR |

## Success Metrics

| KPI | Target | How measured |
|-----|--------|-------------|
| Dogfood pass rate at implementing PR | 100% — harness's own 14-validator suite passes (modules are present but not activated in harness manifest) | Implementing PR's CI run |
| Sample composition validates clean | Both modules active in the sample composition; full suite exits 0 | `platform/compositions/healthcare-fhir-app.yaml` CI run |
| Discoverability coverage | Both modules reachable from `harness-onboarding/SKILL.md`, `SUMMARY.md`, and `discovery-to-composition.md` | Spot-check post-merge |
| Bias-guardrail propagation | `jurisdiction-profile.md` template carries the guardrail text verbatim as specified in FR-003 | Template file review at implementing PR |
| Framework primitives named | Three primitives documented in this PRD's design context and cited in both module READMEs | Module README review at implementing PR |

## Dependencies

- `platform/validators/lib/harness_registry.rb` — module enumeration (existing;
  both new modules registered via the standard profiles path).
- `platform/profiles/domains/` — the `domains/` subtree must exist or be created
  at the implementing PR; confirm during implementation whether any catalog count
  path treats `domains/` distinctly from `management/` or `agents/`.
- `platform/profiles/management/eval-gated-testing/` — sibling-module
  precedent for companion rule + review gate shape.
- Bash 3.2 + system Ruby (already in CI environment; no new gems or package
  manifests).

## Verification

The wedge is verified, not asserted:

- All 14 validators pass with both modules present on disk (manifest, module-graph
  dependency resolution of `healthcare-smart-on-fhir → healthcare-fhir`,
  required-artifacts, companions, catalog-counts, list-completeness, doc-references,
  and the rest of the chain).
- A sample composition (`platform/compositions/healthcare-fhir-app.yaml`) activates
  both modules and validates clean — its dependency closure
  (`healthcare-smart-on-fhir → healthcare-fhir → kernel/base`) resolves under
  validate-module-graph.
- markdownlint passes on all new and changed markdown.

## Open Questions

- [ ] **Exact sensitive-path regexes** — validated against OpenEMR + Tula
  source trees at implementation time. Design spec names candidates
  (`^fhir/`, `^src/FHIR/`, substrings `patient`, `observation`, `bundle`,
  `phi`, `scope`, `launch`, `token`, `oauth`); the implementing PR finalizes
  and tests the set. **Bias: use the design spec candidates as the v1 starting
  point; refine if they cause false positives on real consumer trees.**
- [ ] **Sample composition shape** — composition YAML vs full sample-project
  directory. **Bias: a single `platform/compositions/healthcare-fhir-app.yaml`
  file activating both modules is sufficient for v1.** Full sample-project is
  a v2 concern if a consumer requests a reference implementation.
- [ ] **`validate-catalog-counts.sh` ASSERTIONS bump** — do the two new domain
  modules require a bump to active-modules-reachable counts? Determined during
  implementation by running the validator before and after adding the module
  files. **Bias: yes, bump is required; implementing PR must update all
  documented sites.**
- [ ] **`domain` type recognized by `validate-module-graph.sh`** — does the
  validator currently accept `type: domain`? If not, a small validator patch is
  in scope for the implementing PR and must not break existing module-graph
  tests. **Bias: patch is low-risk; add the domain type to the recognized-set
  alongside `management`, `agents`, `architectures`, `kernel`.**
