<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0024: Geospatial / GIS Wedge (CRS Foundation + OGC Exchange + BIM↔GIS Georeferencing)

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-12 | **Review Cycle:** On-change

**Status:** Accepted
**Date:** 2026-06-12
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- **Origin OPP:** [OPP-0045](../opportunities/OPP-0045-domain-family-geospatial-decomposed.md) —
  Geospatial domain family (decomposed). This PRD is a partial promotion:
  `geospatial-foundation`, `geospatial-exchange`, and
  `geospatial-bim-georeference` only. The four deferred OPP-0045 sub-modules stay
  `proposed`.
- **Standards research brief:** `docs/superpowers/specs/2026-06-12-geospatial-gis-research-brief.md` —
  the web-grounded CRS/datum/epoch, OGC exchange, IFC georeferencing, and
  sensitivity facts grounding this PRD (committed in the same design PR).
- **Predecessor verticals:** [PRD-0017](PRD-0017-healthcare-fhir-smart-wedge.md)
  (first deep-domain wedge) and [PRD-0019](PRD-0019-aec-iso19650-openbim-wedge.md)
  (third; AEC). This PRD mirrors their two-phase structure, intra-family
  dependency shape, and §10 vocabulary, and adds the first cross-family
  dependency.
- **Cross-cutting + cross-family reused:**
  [PRD-0019](PRD-0019-aec-iso19650-openbim-wedge.md) — the georeference module
  depends on `domains/aec-openbim-exchange`;
  [PRD-0023](PRD-0023-digital-twin-scenario-runtime-overlay.md) and
  [PRD-0018](PRD-0018-privacy-by-design.md) — the composition reuses
  `management/digital-twin` and `management/privacy-by-design` for geospatial
  sensitivity (compose-don't-build).
- **Related operating principles:**
  - [§ 9 Split Design from Implementation](../operating-principles.md#9-split-design-from-implementation) —
    this PRD ships the design contract; the implementing PR ships the modules,
    templates, and propagation.
  - [§ 10 Classify Claims Before Enforcing Them](../operating-principles.md#10-classify-claims-before-enforcing-them) —
    see §10 Claim Classification block below.

## Overview

The harness has no `domains/geospatial-*` coverage. GIS / mapping work is governed
by coordinate reference systems (datum + vertical datum + epoch + units), OGC
exchange formats and services, and — where BIM meets GIS — model georeferencing.
This PRD specifies a thin three-module wedge plus templates, discoverability, a
diagram, and a sample composition. v1 is **design-only** per § 9; the implementing
PR builds the scaffolding.

The wedge is intentionally minimal — the four deferred OPP-0045 sub-modules
(`geospatial-imagery-raster`, `geospatial-cadastre-parcel`,
`geospatial-realtime-sensor`, `geospatial-routing-network`) are out of scope — so
the implementing PR is a single bounded unit and the framework primitives emerge
from a fourth working domain rather than speculation.

Two structural firsts distinguish this wedge from healthcare and AEC: the
georeference module is the catalog's **first cross-family dependency** (a `domain`
module depending on a module in a *different* domain family), and the sample
composition is the **first 4-way domain × domain × cross-cutting × cross-cutting**
composition.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- Ship `platform/profiles/domains/geospatial-foundation/` (`module.yaml` +
  `README.md`) declaring `type: domain`, `dependsOn: [kernel/base]`, the two
  required artifacts (`spatial-reference-profile.md`, `dataset-inventory.md`),
  sensitive paths, companion rules, and the CRS/datum-change review gate.
- Ship `platform/profiles/domains/geospatial-exchange/` declaring
  `dependsOn: [kernel/base, geospatial-foundation]`, the `exchange-profile.md`
  artifact, the publisher/consumer role-axis and CRS-on-the-wire sensitive
  paths/companion rules, and the published-service-grant review gate. The
  intra-family dependency teaches the composition pattern (as
  `smart-on-fhir → fhir` and `openbim-exchange → iso19650-im` did).
- Ship `platform/profiles/domains/geospatial-bim-georeference/` declaring
  `dependsOn: [kernel/base, geospatial-foundation, aec-openbim-exchange]`, the
  `georeference-map.md` artifact, georeferencing-parameter sensitive
  paths/companion rules, and the georeferencing-change review gate. README
  documents the BIM↔GIS bridge and the cross-family dependency rationale.
- Ship `platform/templates/geospatial/` with four tokenized templates:
  `spatial-reference-profile.md` (carrying the compound + temporal bias
  guardrail), `dataset-inventory.md`, `exchange-profile.md`, `georeference-map.md`.
- Close the discoverability gap: all three modules appear in `SUMMARY.md`, the
  catalog `README.md` Module table, `platform/skills/harness-onboarding/SKILL.md`,
  and `platform/workflow/discovery-to-composition.md` Step 6.
- Add one geospatial domain family diagram (`## 15.`) to
  `docs/architecture/diagrams.md`.
- Ship a sample composition (`platform/compositions/geospatial-bim-twin.yaml`)
  that activates all three modules plus `aec-openbim-exchange`,
  `management/digital-twin`, and `management/privacy-by-design`.
- **Document the compose-don't-build sensitivity boundary** in the
  `geospatial-foundation`/`geospatial-bim-georeference` READMEs and the
  composition: geospatial sensitivity (critical-infrastructure location, precise
  geolocation as personal data, indigenous data sovereignty, cadastral privacy)
  is governed by composing Digital-Twin + privacy, not a built spine.
- Pass the full 17-validator suite with all three modules on disk (predict-clean:
  the harness does not activate them).

**Non-Goals** — explicitly out of scope:

- **The four deferred OPP-0045 sub-modules.** Each is a separate future PRD.
- **A built `geospatial-sensitivity` spine module.** Sensitivity is composed
  (Digital-Twin + privacy) until a consumer needs it outside a twin context.
- **An Esri ArcGIS / Autodesk Platform Services integration.** The wedge governs
  the open standards/exchange/georeferencing layer, not vendor SDKs (mirrors the
  deferred `aec-aps-tooling` decision).
- **The abstract deep-domain framework operating-principle / ADR.** Authored in a
  later harvest pass; geospatial is its fourth grounding instance.
- **A new geospatial-specific validator.** All enforced claims are expressed
  through the existing 17-validator chain.

## §10 Claim Classification

Per the [§10 operating principle](../operating-principles.md#10-classify-claims-before-enforcing-them),
this PRD names each load-bearing claim and its enforcement mechanism:

| Claim | Class | Mechanism |
|-------|-------|-----------|
| Required artifacts exist when a geospatial module is active | Enforced | `validate-required-artifacts.sh` |
| Sensitive-path edits (CRS / exchange / georeferencing surfaces) pair with a governance document | Enforced | `validate-companions.sh` |
| Intra-family + cross-family dependencies resolve (`exchange → foundation`; `geospatial-bim-georeference → {foundation, aec-openbim-exchange}`) | Enforced | `validate-module-graph.sh` |
| Sensitive paths are companion-rule covered | Enforced | `validate-sensitive-paths.sh` (per-module self-coverage) |
| Horizontal CRS / vertical datum / epoch / units are declared, never assumed | Asserted-only | review gate + bias-guardrail text in `spatial-reference-profile.md` template |
| The declared CRS is preserved across exchange boundaries (not silently dropped) | Asserted-only | review gate + CRS-on-the-wire policy in `exchange-profile.md` |
| Publisher / consumer exchange boundary is respected | Asserted-only | review gate on published-service-grant edits |
| Model georeferencing (datum / origin / rotation / scale) is human-signed-off | Asserted-only | review gate (`humanReview`) on `georeference-map.md` changes |
| Geospatial sensitivity is governed via composition without overlap or gap | Asserted-only | documented composition boundary (`geospatial-bim-twin` + module READMEs) |

**Claims explicitly NOT converted by v1** (remain Asserted-only):

- **Geometry actually lies in the declared CRS.** v1 validates the governance
  *declaration* (`spatial-reference-profile.md` exists and declares a CRS); it
  does not reproject or check coordinates. Runtime conformance is out of scope.
- **The georeferencing is numerically correct.** v1 requires the
  `georeference-map.md` artifact exists and links the declared CRS; it does not
  verify the map-conversion parameters place the model correctly. That is a
  review-gate behavior.
- **The declared CRS is geodetically appropriate for the area of interest.** The
  bias guardrail forces an explicit datum/epoch/units declaration; it does not
  verify the declared CRS suits the project's location or accuracy needs.

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Harness maintainer | Repository's primary owner | The fourth deep-domain wedge lands, grounding the framework harvest with the first cross-family dependency and a temporal forcing-artifact axis. |
| Geospatial consumer maintainer | A team adopting auto-harness for GIS / mapping / BIM↔GIS work | Catalog modules with clear required artifacts; a template that forces a CRS/datum/epoch/units declaration; discoverability from the onboarding skill. |
| BIM↔GIS integrator | Someone pinning a Revit/IFC model into a real-world CRS | A governed `georeference-map.md` artifact + review gate so a mislocated federated model cannot land silently. |
| Future vertical designer | Someone designing the next deep-domain wedge | The cross-family dependency and the compound + temporal forcing artifact are the two enrichments the harvest generalizes. |

## User Stories

- As a **geospatial consumer maintainer**, I want to activate
  `domains/geospatial-foundation` and have the harness require
  `spatial-reference-profile.md` and `dataset-inventory.md`, so contributors
  cannot silently assume WGS84 or omit dataset provenance.
- As a **geospatial consumer maintainer**, I want `domains/geospatial-exchange` on
  top of `geospatial-foundation` to require `exchange-profile.md` with the
  publisher/consumer role axis and a CRS-on-the-wire policy, so exchange
  boundaries are documented and the declared CRS is never lost on the wire.
- As a **BIM↔GIS integrator**, I want `domains/geospatial-bim-georeference` to
  require `georeference-map.md` (map-conversion parameters, survey-point origin,
  target georeferencing level, linked CRS) and gate georeferencing changes, so a
  wrong map conversion cannot mislocate the whole federated model.
- As a **harness maintainer**, I want all three modules to pass the full
  17-validator suite clean (no new validators, no weakened assertion), so the
  wedge lands without harness-side churn.
- As a **future vertical designer**, I want the cross-family dependency
  (`geospatial-bim-georeference → aec-openbim-exchange`) to be a copyable
  precedent for governing a seam between two domain families.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | `domains/geospatial-foundation` scaffolding | `module.yaml` + `README.md`. `module.yaml` declares `type: domain`, `dependsOn: [kernel/base]`, `requiredArtifacts: [docs/geospatial/spatial-reference-profile.md, docs/geospatial/dataset-inventory.md]`, sensitive paths, companion rule(s), and the CRS/datum-change review gate. | The substrate module (≈ `healthcare-fhir`, `aec-iso19650-im`). |
| FR-002 | `domains/geospatial-exchange` scaffolding | `module.yaml` + `README.md`. Declares `type: domain`, `dependsOn: [kernel/base, geospatial-foundation]`, `requiredArtifacts: [docs/geospatial/exchange-profile.md]`, sensitive paths, companion rule(s), and the published-service-grant review gate. | Intra-family dependency must resolve in `validate-module-graph.sh`. |
| FR-003 | `domains/geospatial-bim-georeference` scaffolding | `module.yaml` + `README.md`. Declares `type: domain`, `dependsOn: [kernel/base, geospatial-foundation, aec-openbim-exchange]`, `requiredArtifacts: [docs/geospatial/georeference-map.md]`, sensitive paths, companion rule(s), and the georeferencing-change review gate. README documents the cross-family dependency rationale. | **First cross-family dependency** — must resolve in `validate-module-graph.sh`. |
| FR-004 | `platform/templates/geospatial/` with four templates | `spatial-reference-profile.md` (compound + temporal bias guardrail), `dataset-inventory.md`, `exchange-profile.md` (CRS-on-the-wire policy), `georeference-map.md` (references the spatial-reference-profile). All carry tokenized SPDX headers. | Bias-guardrail text: default-deny an assumed CRS; force an explicit `{horizontal datum/CRS} × {vertical datum} × {epoch} × {units}` declaration. |
| FR-005 | Discoverability propagation | All three modules appear in `SUMMARY.md`, catalog `README.md` Module table, `harness-onboarding/SKILL.md` domain catalog, and `discovery-to-composition.md` Step 6. | Companion-rule propagation per `CLAUDE.md`. |
| FR-006 | Geospatial domain family diagram | One diagram `## 15. Geospatial Domain Family` in `docs/architecture/diagrams.md`: the `foundation ← {exchange, bim-georeference}` dependencies, the cross-family edge to `aec-openbim-exchange`, the publisher/consumer role axis, and the CRS/temporal overlay. | Index table updated 14→15; prose "Fourteen"→"Fifteen". |
| FR-007 | Sample composition | `platform/compositions/geospatial-bim-twin.yaml` activates all three modules + `aec-openbim-exchange` + `management/digital-twin` + `management/privacy-by-design`; listed in `platform/compositions/README.md` and root `README.md`. | First 4-way domain × domain × cross-cutting × cross-cutting composition. |
| FR-008 | Catalog-count propagation | All catalog-count sites updated: profile modules 43→46 / total 52→55, templates 84→88, diagrams 14→15, compositions 13→14. `validate-catalog-counts.sh` and `validate-list-completeness.sh` exit 0. | Exact site list re-derived against `main` at implementation time. |
| FR-009 | Full 17-validator suite passes | All 17 validators exit 0 with the three modules on disk; the harness does not activate them (predict-clean). | No new validator added. |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-S01 | One distillation observation in `docs/knowledge/shared-observations.md` | Captures the fourth-domain harvest evidence: the first cross-family dependency and the temporal forcing-artifact axis as the two enrichments earlier verticals could not surface. | Mirrors the PRD-0017/PRD-0019 knowledge-capture convention; also satisfies the PRD-0004 distillation rule fired by the new module YAML. |
| FR-S02 | "When to activate" guidance in each module README | Each README names the geospatial concern it governs and when a consumer activates it. | Reduces activation friction. |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| Coordinate reprojection / geometry conformance validation | Runtime concern; v1 governs declarations | If a consumer mounts a geometry/CRS validator in CI |
| `geospatial-imagery-raster`, `geospatial-cadastre-parcel`, `geospatial-realtime-sensor`, `geospatial-routing-network` | Deferred OPP-0045 sub-modules | Per OPP-0045 decomposition / consumer demand |
| A built `geospatial-sensitivity` module | Sensitivity composed via Digital-Twin + privacy | If a consumer needs geospatial sensitivity outside a twin context |
| Abstract deep-domain framework operating-principle | Authored post-wedge in the harvest pass | After the fourth wedge ships and validates |
| A new geospatial-specific validator | Existing chain covers all enforced claims | If a geospatial-specific structural assertion proves mechanizable |

## Implementation Deferral

Per § 9, this PRD ships the design contract; the implementing PR adds the
scaffolding, templates, discoverability, diagram, composition, and distillation.

| Deferred implementation | Deferred to | Why deferred |
|-------------------------|-------------|--------------|
| Three module YAML + README files | Implementing PR (Phase 2) | Design-first per § 9 |
| Four geospatial templates | Implementing PR (Phase 2) | Same |
| Discoverability + diagram + composition + counts | Implementing PR (Phase 2) | Same |
| Distillation observation (FR-S01) | Implementing PR (Phase 2) | Captured during implementation |
| Abstract framework operating-principle + harvest generalization | Post-wedge harvest pass | Must be grounded in the fourth shipped domain first |

## Technical Constraints

- **Module type: `domain`** — already accepted by `validate-module-graph.sh`
  (healthcare and AEC ship as `domain`). No validator patch needed.
- **Cross-family dependency.** `geospatial-bim-georeference` depends on
  `aec-openbim-exchange`, which transitively requires `aec-iso19650-im`. A
  consumer activating the bridge therefore also activates the AEC exchange
  substrate and inherits its required artifacts. This is intended — the bridge
  governs the seam, which presupposes both sides — and must resolve cleanly in
  `validate-module-graph.sh`.
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
| Full 17-validator suite exits 0 | Yes | Predict-clean on the harness's own CI |
| `validate-catalog-counts.sh` correct after bumps | Yes | Modules/templates/diagrams/compositions bumped exactly |
| `validate-list-completeness.sh` exits 0 | Yes | New modules in SUMMARY; templates dir indexed; composition in both READMEs |
| `validate-companions.sh` (PR-diff mode) | Yes | The new module YAML + OPP trigger companion + distillation satisfiers in the same PR |
| Change-log updated | Yes | One entry per PR |

## Success Metrics

| KPI | Target | How measured |
|-----|--------|-------------|
| Dogfood pass rate at implementing PR | 100% — harness's 17-validator suite passes (modules present, not activated) | Implementing PR CI |
| Sample composition validates clean | All three geospatial modules + AEC exchange + DT + privacy active; suite exits 0 | `geospatial-bim-twin.yaml` |
| Discoverability coverage | All three modules reachable from onboarding skill, SUMMARY, discovery-to-composition | Spot-check post-merge |
| CRS guardrail propagation | `spatial-reference-profile.md` carries the compound + temporal declaration + bias guardrail verbatim | Template review |
| Cross-family dependency resolves | `geospatial-bim-georeference → aec-openbim-exchange → aec-iso19650-im → kernel/base` closure resolves | `validate-module-graph.sh` |

## Dependencies

- `platform/validators/lib/harness_registry.rb` — module enumeration (existing).
- `domains/aec-openbim-exchange` (shipped PRD-0019) — the cross-family dependency
  target.
- `management/digital-twin` (shipped PRD-0023) and `management/privacy-by-design`
  (shipped PRD-0018) — the cross-cutting overlays the composition reuses.
- `platform/profiles/domains/healthcare-*` and `domains/aec-*` — the structural
  precedents.
- Bash 3.2 + system Ruby.

## Verification

The wedge is verified, not asserted:

- All 17 validators pass with the three modules on disk (module-graph resolves the
  intra-family `exchange → foundation` and the cross-family
  `geospatial-bim-georeference → aec-openbim-exchange` dependencies;
  required-artifacts, companions, sensitive-paths, catalog-counts,
  list-completeness, doc-references, and the rest of the chain).
- The sample composition's dependency closure resolves
  (`geospatial-exchange → geospatial-foundation → kernel/base`;
  `geospatial-bim-georeference → {geospatial-foundation, aec-openbim-exchange →
  aec-iso19650-im} → kernel/base`).
- markdownlint passes on all new and changed markdown.

## Open Questions

- [ ] **Exact sensitive-path regexes** — validated against a real GIS/Revit repo
  at implementation time. Design names candidates (`^geo/`, `^gis/`,
  `^data/spatial/`, `^exchange/`, `^services/`, `^georef/`, substrings
  `coordinate`, `projection`, `crs`, `geometry`, `wfs`, `wms`, `geojson`,
  `tiles`, `mapconversion`, `projectedcrs`, `surveypoint`, `sharedcoordinates`).
  **Bias: use the candidates as v1; refine if false positives appear.**
- [ ] **`geospatial-bim-georeference` dependency on AEC** — hard `dependsOn` vs
  compose-with (as the AEC security module composes-with privacy). **Bias: hard
  `dependsOn aec-openbim-exchange` — the bridge is meaningless without the BIM
  exchange side, unlike sensitivity which is genuinely optional.** Documented in
  the module README.
- [ ] **Composition required artifacts** — compositions are not required-artifact-
  checked in CI (confirmed: healthcare/AEC compositions reference nonexistent docs
  and CI is green). **Bias: ship `geospatial-bim-twin.yaml` with the
  required-artifact references; no `docs/geospatial/*` files needed in the harness
  tree.**
- [ ] **OPP / PRD / diagram numbers** — re-derive next-free against `main` at
  implementation time (maintainer/Codex parallel work may have claimed numbers
  since filing).
