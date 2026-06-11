<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0019: AEC ISO 19650 + openBIM Wedge

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-04 | **Review Cycle:** On-change

**Status:** Accepted
**Date:** 2026-06-04
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- **Origin OPP:** [OPP-0039](../opportunities/OPP-0039-domain-family-aec-decomposed.md) —
  AEC domain family (decomposed). This PRD is a partial promotion:
  `aec-iso19650-im`, `aec-openbim-exchange`, and `aec-iso19650-5-security`
  only. The three deferred OPP-0039 sub-modules stay `proposed`.
- **Design context:** `docs/superpowers/specs/2026-06-03-aec-construction-wedge-design.md`
  and `docs/superpowers/specs/2026-06-03-construction-bim-research-brief.md` —
  the brainstorming spec and research brief grounding this PRD.
- **Predecessor vertical:** [PRD-0017](PRD-0017-healthcare-fhir-smart-wedge.md) —
  the first deep-domain wedge; this PRD mirrors its two-phase structure, its
  intra-family dependency shape, and its §10 vocabulary.
- **Cross-cutting reused:** [PRD-0018](PRD-0018-privacy-by-design.md) —
  `management/privacy-by-design`; the security module composes with it (built-asset
  sensitivity vs occupant personal data).
- **Related operating principles:**
  - [§ 9 Split Design from Implementation](../operating-principles.md#9-split-design-from-implementation) —
    this PRD ships the design contract; the implementing PR ships the modules,
    templates, and propagation.
  - [§ 10 Classify Claims Before Enforcing Them](../operating-principles.md#10-classify-claims-before-enforcing-them) —
    see §10 Claim Classification block below.

## Overview

The harness has no `domains/aec-*` coverage. The built environment is governed by
ISO 19650 (information management over the asset life cycle), openBIM (IFC/BCF/IDS
model exchange), and — for critical assets — ISO 19650-5 (security-minded
information handling). This PRD specifies a thin three-module wedge plus templates,
discoverability, a diagram, and a sample composition. v1 is **design-only** per § 9;
the implementing PR builds the scaffolding.

The wedge is intentionally minimal — the three deferred OPP-0039 sub-modules
(`aec-aps-tooling`, `aec-bluebeam-review`, `aec-permitting-ahj`) are out of scope —
so that the implementing PR is a single bounded unit and the framework primitives
emerge from a second working domain rather than speculation.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- Ship `platform/profiles/domains/aec-iso19650-im/` (`module.yaml` + `README.md`)
  declaring `type: domain`, `dependsOn: [kernel/base]`, the two required artifacts,
  sensitive paths, companion rules, and the Published/As-Built review gate.
- Ship `platform/profiles/domains/aec-openbim-exchange/` declaring
  `dependsOn: [kernel/base, aec-iso19650-im]`, the exchange-requirements artifact,
  the pinned-IFC-version and role-axis sensitive paths/companion rules, and the
  IFC-version / exchange-grant review gate. The intra-family dependency teaches the
  composition pattern (as `smart-on-fhir → fhir` did).
- Ship `platform/profiles/domains/aec-iso19650-5-security/` declaring
  `dependsOn: [kernel/base, aec-iso19650-im]`, the two security artifacts,
  sensitivity/classification sensitive paths/companion rules, and the
  declassification review gate.
- Ship `platform/templates/aec/` with five tokenized templates:
  `information-management-plan.md`, `jurisdiction-profile.md` (carrying the
  compound bias guardrail), `exchange-requirements.md`, `sensitivity-assessment.md`,
  `security-management-plan.md`.
- Close the discoverability gap: all three modules appear in `SUMMARY.md`, the
  catalog `README.md` Module table, `platform/skills/harness-onboarding/SKILL.md`,
  and `platform/workflow/discovery-to-composition.md` Step 6.
- Add one AEC domain family diagram (`## 13.`) to `docs/architecture/diagrams.md`.
- Ship a sample composition (`platform/compositions/aec-bim-project.yaml`) that
  activates all three modules plus `management/privacy-by-design`.
- **Document the security × privacy composition boundary** in the
  `aec-iso19650-5-security` README and the `sensitivity-assessment.md` template
  (built-asset sensitivity vs personal-data privacy; the sensitivity-assessment
  references the privacy-profile's declared regime).
- Pass the full 15-validator suite with all three modules on disk (predict-clean:
  the harness does not activate them).

**Non-Goals** — explicitly out of scope:

- **The three deferred OPP-0039 sub-modules** (`aec-aps-tooling`,
  `aec-bluebeam-review`, `aec-permitting-ahj`). Each is a separate future PRD.
- **A Revit / Bluebeam / Autodesk Platform Services integration.** The wedge
  governs the standards/exchange/security layer, not vendor SDKs.
- **A dedicated `aec-permitting-ahj` module.** The AHJ is a jurisdiction-profile
  field in this wedge.
- **The abstract deep-domain framework operating-principle / ADR.** Authored in a
  later harvest pass once the AEC wedge ships and the primitives have a second
  domain instance.
- **A new AEC-specific validator.** All enforced claims are expressed through the
  existing 15-validator chain.

## §10 Claim Classification

Per the [§10 operating principle](../operating-principles.md#10-classify-claims-before-enforcing-them),
this PRD names each load-bearing claim and its enforcement mechanism:

| Claim | Class | Mechanism |
|-------|-------|-----------|
| Required artifacts exist when an AEC module is active | Enforced | `validate-required-artifacts.sh` |
| Sensitive-path edits (CDE / IFC / security surfaces) pair with a governance document | Enforced | `validate-companions.sh` |
| Intra-family dependencies (`openbim-exchange → iso19650-im`, `iso19650-5-security → iso19650-im`) resolve cleanly | Enforced | `validate-module-graph.sh` |
| Sensitive paths are companion-rule covered | Enforced | `validate-sensitive-paths.sh` (per-module self-coverage) |
| National Annex / AHJ / classification system is declared, never assumed | Asserted-only | review gate + bias-guardrail text in `jurisdiction-profile.md` template |
| The pinned IFC version is honored on exchange | Asserted-only | review gate (`humanReview`) on any IFC-version change |
| Producer / receiver / reviewer exchange boundary is respected | Asserted-only | review gate on exchange-grant edits |
| Publishing a container (Published / As-Built) is human-signed-off | Asserted-only | review gate (`humanReview`) on container promotion |
| Built-asset sensitivity and personal-data privacy are governed without overlap or gap | Asserted-only | documented composition boundary (security README + `sensitivity-assessment` references the `privacy-profile` regime) |

**Claims explicitly NOT converted by v1** (remain Asserted-only):

- **IFC payloads structurally conform to the pinned schema.** v1 validates the
  governance *declaration* (`exchange-requirements.md` exists and pins a version);
  it does not invoke an IFC/IDS validator. Runtime conformance is out of scope.
- **The sensitivity classification is complete and correct.** v1 requires the
  `sensitivity-assessment.md` artifact exists; it does not assess whether every
  sensitive element was identified. That is a review-gate behavior.
- **The declared jurisdiction is legally sufficient.** The bias guardrail forces
  an explicit National Annex / AHJ / classification declaration; it does not verify
  the declared regime's legal requirements are met.

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Harness maintainer | Repository's primary owner | The second deep-domain wedge lands, grounding the framework harvest with a compound forcing artifact and a domain × cross-cutting composition. |
| AEC consumer maintainer | A team adopting auto-harness for an ISO 19650 / openBIM delivery | Catalog modules with clear required artifacts; templates that force a National-Annex/AHJ/classification declaration and an IFC-version pin; discoverability from the onboarding skill. |
| Harness contributor | Outside contributor adding an AEC module or template | A second concrete precedent for deep-domain family modules and the intra-family dependency pattern. |
| Future vertical designer | Someone designing the next deep-domain wedge | The compound (3-axis) forcing artifact and the documented security × privacy composition boundary are the two enrichments the harvest generalizes. |

## User Stories

- As an **AEC consumer maintainer**, I want to activate `domains/aec-iso19650-im`
  and have the harness require `information-management-plan.md` and
  `jurisdiction-profile.md`, so contributors cannot silently omit the CDE/actor
  model or assume a National Annex.
- As an **AEC consumer maintainer**, I want `domains/aec-openbim-exchange` on top
  of `aec-iso19650-im` to require `exchange-requirements.md` with a pinned IFC
  version and the producer/receiver/reviewer role axis, so exchange boundaries are
  documented and reviewable.
- As an **AEC consumer maintainer building critical infrastructure**, I want
  `domains/aec-iso19650-5-security` to require a sensitivity assessment and a
  security-management plan, and to compose with `management/privacy-by-design` for
  occupant data, so asset sensitivity and personal-data privacy are both governed
  without a gap.
- As a **harness maintainer**, I want all three modules to pass the full
  15-validator suite clean (no new validators, no weakened assertion), so the wedge
  lands without harness-side churn.
- As a **future vertical designer**, I want the compound `jurisdiction-profile.md`
  template (3 axes) to be copyable as the pattern for multi-axis jurisdictions in
  other domains.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | `domains/aec-iso19650-im` scaffolding | `module.yaml` + `README.md` at the module path. `module.yaml` declares `type: domain`, `dependsOn: [kernel/base]`, `requiredArtifacts: [docs/aec/information-management-plan.md, docs/aec/jurisdiction-profile.md]`, sensitive paths, two companion rules, and the Published/As-Built review gate. | The substrate module (≈ `healthcare-fhir`). |
| FR-002 | `domains/aec-openbim-exchange` scaffolding | `module.yaml` + `README.md`. Declares `type: domain`, `dependsOn: [kernel/base, aec-iso19650-im]`, `requiredArtifacts: [docs/aec/exchange-requirements.md]`, sensitive paths, two companion rules, and the IFC-version/exchange-grant review gate. | Intra-family dependency must resolve in `validate-module-graph.sh`. |
| FR-003 | `domains/aec-iso19650-5-security` scaffolding | `module.yaml` + `README.md`. Declares `type: domain`, `dependsOn: [kernel/base, aec-iso19650-im]`, `requiredArtifacts: [docs/aec/sensitivity-assessment.md, docs/aec/security-management-plan.md]`, sensitive paths, two companion rules, and the declassification review gate. README documents the security × privacy composition boundary. | The sensitivity spine. |
| FR-004 | `platform/templates/aec/` with five templates | `information-management-plan.md`, `jurisdiction-profile.md` (compound bias guardrail), `exchange-requirements.md`, `sensitivity-assessment.md` (references the privacy-profile regime), `security-management-plan.md`. All carry tokenized SPDX headers. | Bias-guardrail text: default-deny the UK BS EN + Uniclass path; force an explicit National-Annex/AHJ/classification declaration. |
| FR-005 | Discoverability propagation | All three modules appear in `SUMMARY.md`, catalog `README.md` Module table, `harness-onboarding/SKILL.md` domain catalog, and `discovery-to-composition.md` Step 6. | Companion-rule propagation per `CLAUDE.md`. |
| FR-006 | AEC domain family diagram | One diagram `## 13. AEC Domain Family` in `docs/architecture/diagrams.md`: the `iso19650-im ← {openbim-exchange, iso19650-5-security}` dependency, the role axis, the compound jurisdiction overlay, and the privacy-by-design composition edge. | Index table updated 12→13; prose "Twelve"→"Thirteen". |
| FR-007 | Sample composition | `platform/compositions/aec-bim-project.yaml` activates all three modules + `management/privacy-by-design`; listed in `platform/compositions/README.md` and root `README.md`. | Integration reference for the intra-family dependency. |
| FR-008 | Catalog-count propagation | All catalog-count sites updated: modules 39→42 / 48→51, templates 69→74, diagrams 12→13. `validate-catalog-counts.sh` and `validate-list-completeness.sh` exit 0. | See plan's "Governing facts" for the exact site list. |
| FR-009 | Full 15-validator suite passes | All 15 validators exit 0 with the three modules on disk; the harness does not activate them (predict-clean). | No new validator added. |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-S01 | One distillation observation in `docs/knowledge/shared-observations.md` | Captures the second-domain harvest evidence: the compound (3-axis) forcing artifact and the domain × cross-cutting composition as the two enrichments healthcare could not surface. | Mirrors the PRD-0017 knowledge-capture convention. |
| FR-S02 | "When to activate" guidance in each module README | Each README names the ISO 19650 concern it governs and when a consumer activates it. | Reduces activation friction. |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| IFC/IDS payload conformance validation | Runtime concern; v1 governs declarations | If a consumer mounts an IDS validator in CI |
| `aec-aps-tooling`, `aec-bluebeam-review`, `aec-permitting-ahj` | Deferred OPP-0039 sub-modules | Per OPP-0039 decomposition / consumer demand |
| Abstract deep-domain framework operating-principle | Authored post-wedge in the harvest pass | After the wedge ships and validates |
| A new AEC-specific validator | Existing chain covers all enforced claims | If an AEC-specific structural assertion proves mechanizable |

## Implementation Deferral

Per § 9, this PRD ships the design contract; the implementing PR adds the
scaffolding, templates, discoverability, diagram, composition, and distillation.

| Deferred implementation | Deferred to | Why deferred |
|-------------------------|-------------|--------------|
| Three module YAML + README files | Implementing PR (Phase 2) | Design-first per § 9 |
| Five AEC templates | Implementing PR (Phase 2) | Same |
| Discoverability + diagram + composition + counts | Implementing PR (Phase 2) | Same |
| Distillation observation (FR-S01) | Implementing PR (Phase 2) | Captured during implementation |
| Abstract framework operating-principle + finance/logistics stress-test | Post-wedge harvest pass | Must be grounded in two shipped domains first |

## Technical Constraints

- **Module type: `domain`** — already accepted by `validate-module-graph.sh`
  (healthcare ships as `domain`). No validator patch needed.
- **Catalog-only.** The three modules are NOT added to `harness.manifest.yaml`;
  the harness's own suite stays predict-clean.
- **Per-module sensitive-path self-coverage.** Each module's `sensitivePaths`
  patterns must be fully overlapped by its own `companionRules.triggerPaths` so a
  consumer activating any single module passes `validate-sensitive-paths.sh`.
- **Bash 3.2 + system Ruby** — no new dependencies.
- **SPDX dual-license headers** on all new files; `UncleNate@gmail.com`.

## CI/CD Gates

| Gate | Required? | Notes |
|------|-----------|-------|
| markdownlint + shellcheck | Yes | All new `.md` pass; no new shell scripts |
| Full 15-validator suite exits 0 | Yes | Predict-clean on the harness's own CI |
| `validate-catalog-counts.sh` correct after bumps | Yes | Modules/templates/diagrams bumped exactly |
| `validate-list-completeness.sh` exits 0 | Yes | New modules in SUMMARY; templates dir indexed; composition in both READMEs |
| Change-log updated | Yes | One entry per PR |

## Success Metrics

| KPI | Target | How measured |
|-----|--------|-------------|
| Dogfood pass rate at implementing PR | 100% — harness's 15-validator suite passes (modules present, not activated) | Implementing PR CI |
| Sample composition validates clean | All three modules + privacy active; suite exits 0 | `aec-bim-project.yaml` |
| Discoverability coverage | All three modules reachable from onboarding skill, SUMMARY, discovery-to-composition | Spot-check post-merge |
| Compound guardrail propagation | `jurisdiction-profile.md` carries the 3-axis declaration + bias guardrail verbatim | Template review |
| Composition boundary documented | Security README + sensitivity-assessment reference the privacy regime | README review |

## Dependencies

- `platform/validators/lib/harness_registry.rb` — module enumeration (existing).
- `management/privacy-by-design` (shipped PRD-0018) — the cross-cutting the
  security module composes with.
- `platform/profiles/domains/healthcare-*` — the structural precedent.
- Bash 3.2 + system Ruby.

## Verification

The wedge is verified, not asserted:

- All 15 validators pass with the three modules on disk (module-graph resolves
  both intra-family dependencies; required-artifacts, companions, sensitive-paths,
  catalog-counts, list-completeness, doc-references, and the rest of the chain).
- The sample composition's dependency closure
  (`aec-openbim-exchange → aec-iso19650-im → kernel/base`;
  `aec-iso19650-5-security → aec-iso19650-im → kernel/base`) resolves.
- markdownlint passes on all new and changed markdown.

## Open Questions

- [ ] **Exact sensitive-path regexes** — validated against a real ISO 19650 / IFC
  repo at implementation time. Design spec names candidates (`^cde/`,
  `^containers/`, `^ifc/`, `^exchange/`, substrings `models`, `bep`, `midp`, `bcf`,
  `federation`, `sensitive`, `classified`, `redaction`). **Bias: use the spec
  candidates as v1; refine if false positives appear.**
- [ ] **`aec-iso19650-5-security` dependency on privacy** — `dependsOn` vs
  compose-with. **Bias: compose-with (no hard dependency), documented in both the
  security README and the `aec-bim-project.yaml` composition.**
- [ ] **Composition required artifacts** — compositions are not required-artifact-
  checked in CI (confirmed: healthcare composition references nonexistent docs and
  CI is green). **Bias: ship `aec-bim-project.yaml` with the required-artifact
  references; no `docs/aec/*` files needed in the harness tree.**
