<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0023: Digital Twin / Scenario Runtime Governance Overlay

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-10 | **Review Cycle:** On-change

**Status:** Accepted
**Date:** 2026-06-10
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- **Origin OPP:** [OPP-0044](../opportunities/OPP-0044-digital-twin-scenario-runtime.md) — Digital
  Twin / Scenario Runtime opportunity.
- **Placement ADR:** [ADR-0019](../adr/ADR-0019-digital-twin-scenario-runtime-overlay.md) —
  management overlay (not domain); staged epistemic-discipline category.
- **Design context:** `docs/superpowers/specs/2026-06-10-digital-twin-scenario-runtime-overlay-design.md`.
- **Cross-cutting precedent:** [ADR-0018](../adr/ADR-0018-privacy-by-default-posture.md) /
  PRD-0018 — `management/privacy-by-design`; the overlay composes with it.
- **Built-environment substrate:** `domains/aec-iso19650-im` — the lead municipal / real-estate
  composition (`aec-iso19650-im` × `digital-twin` × `privacy-by-design`).
- **Related operating principles:**
  - [§ 9 Split Design from Implementation](../operating-principles.md#9-split-design-from-implementation)
    — this PRD ships the design contract; Phase 2 ships the scaffolding.
  - [§ 10 Classify Claims Before Enforcing Them](../operating-principles.md#10-classify-claims-before-enforcing-them)
    — see the §10 Claim Classification block below.

## Overview

The harness has no reusable governance for projects that model real-world systems, run scenarios,
or publish decision-support outputs. This PRD specifies a thin v1 **`management/digital-twin`**
overlay: a single forcing artifact (`docs/twin/twin-profile.md`), a dual-spine standards anchor, a
maturity-gated artifact model, two Half-enforced module-gated WARN validators, a skill, a sample
composition, and a diagram. v1 is **design-only** per § 9; the implementing PR (Phase 2) builds the
scaffolding. The overlay is default-off / opt-in and catalog-only (the harness does not activate it
on itself).

## §10 Claim Classification

Per the [§10 operating principle](../operating-principles.md#10-classify-claims-before-enforcing-them),
each load-bearing claim and its enforcement mechanism (mechanisms ship in Phase 2):

| Claim | Class | Mechanism |
|-------|-------|-----------|
| `twin-profile.md` exists when the overlay is active | Enforced | `validate-required-artifacts.sh` |
| Sensitive-path edits (scenarios/models/agents/datasets/run-state) pair with a governance doc | Enforced | `validate-companions.sh` |
| Sensitive paths are companion-rule covered | Enforced | `validate-sensitive-paths.sh` |
| The `digital-twin → kernel/base` dependency resolves cleanly | Enforced | `validate-module-graph.sh` |
| `twin-profile` declares a maturity level, at least one conformance target with status, and governing principles | Half-enforced | `validate-twin-profile.sh` (module-gated WARN) |
| A scenario manifest carries its required sections (datasets w/ source+version+asOf+confidence; assumptions w/ confidence+sensitivity; provenance; publication-approval for published outputs) | Half-enforced | `validate-scenario-manifest.sh` (module-gated WARN) |
| Required-artifact depth matches the declared maturity level | Asserted-only | review gate (maturity-aware validator deferred) |
| The declared maturity level matches the evidence (no overclaim) | Asserted-only | review gate + bias-guardrail text |
| LLM output is not treated as simulation source-of-truth | Asserted-only | template guidance + review gate |
| Canonical world state is not mutated for scenario experiments | Asserted-only | guidance: branch it, run against the branch, log the run |
| High-impact / public outputs pass review before publication | Asserted-only | publication-policy review gate (Gemini Trust + Purpose) |

**Claims explicitly NOT converted by v1** (remain Asserted-only): the depth-by-maturity mapping;
maturity-vs-evidence honesty; the LLM-not-source-of-truth rule; world-state immutability; and the
publication review gate. These are human review-gate behaviors v1 does not mechanize.

## Standards Anchor (verified 2026-06-10)

Cite **published** standards as normative; cite **under-development** ones as emerging, never as
ratified. (Confirm byte-perfect ISO titles on the ISO OBP at implementation.)

**Interoperability / digital thread:** ISO 23247-1…4:2021 (digital twin framework for
manufacturing; Parts 5 digital-thread + 6 composition emerging); ISO/IEC 30173:2023 (concepts &
terminology); ISO/IEC 30188 (reference architecture, emerging); IEC 63278-1:2023 + IDTA Asset
Administration Shell; DTDL v4 (JSON-LD); W3C WoT Thing Description 1.1 + Architecture 1.1 (REC
2023); MIMOSA OSA-CBM/OSA-EAI; ISO 10303-242:2025 STEP/AP242; QIF (ISO 23952:2020 / ANSI-DMSC QIF
3.0); DTC Digital Twin System Interoperability Framework + Capabilities Periodic Table.

**Governance values:** the Gemini Principles (CDBB, 2018) — nine principles, three themes (Purpose:
public good, value creation, insight; Trust: security, openness, quality; Function: federation,
curation, evolution). Cited as the 2018 foundational framework; CDBB closed 2022, stewardship split
(DT Hub at Connected Places Catapult; DBT National Digital Twin Programme).

## Goals & Non-Goals

**Goals** — outcomes the Phase-2 implementing PR commits to:

- Ship `platform/profiles/management/digital-twin/` (`module.yaml` + `README.md`): `type:
  management`, `dependsOn: [kernel/base]`, required artifact `docs/twin/twin-profile.md`, sensitive
  paths, companion rules, and the maturity-gated artifact guidance.
- Ship `platform/templates/digital-twin/` (the maturity-gated set): `twin-profile.md`,
  `overview.md` (the maturity ladder), `scenario-manifest-spec.md`, `data-provenance.md`,
  `model-registry.md`, `agent-registry.md`, `run-log-spec.md`, `uncertainty-policy.md`,
  `publication-policy.md`, `security-boundaries.md`.
- Ship two **Half-enforced** module-gated WARN validators: `validate-twin-profile.sh` and
  `validate-scenario-manifest.sh` (validator chain N→N+2). Both no-op when the overlay is inactive
  so the harness's own CI stays predict-clean.
- Ship the `harness-digital-twin` skill (activates on twin / simulation / scenario / world-state /
  run-log / model-registry / provenance tasks).
- Ship a sample composition `platform/compositions/digital-twin-prototype.yaml` (existing modules
  only).
- Add one Digital Twin family diagram to `docs/architecture/diagrams.md`.
- Close discoverability: SUMMARY.md, catalog README Module table, `harness-onboarding/SKILL.md`,
  and `discovery-to-composition.md`.
- Pass the full validator suite with the overlay on disk (catalog-only; predict-clean).

**Non-Goals:**

- No simulation / geospatial / rendering engine; no event-sourcing mandate; no mandated ontology;
  no operational-control-loop framework in v1.
- No new top-level taxonomy category (the epistemic-discipline cluster is staged in ADR-0019).
- No maturity-aware validator in v1 (depth-by-maturity is Asserted-only).
- The abstract framework operating-principle is deferred to the later harvest pass.

## Target Audience

| Persona | Who they are | What they need |
|---------|-------------|----------------|
| Harness maintainer | Repository owner | A reusable twin-governance overlay that dependent projects adopt off the shelf, anchored on real standards. |
| Twin-project consumer | A team building a municipal / real-estate / datacenter / health twin | A profile that forces maturity + conformance honesty; validators that surface missing provenance/manifest; discoverability from onboarding. |
| Real-estate / civic planner | Runs a planning-lifecycle product | A path from planning model to operational twin governed by the digital thread, with publication review gates. |
| Harness contributor | Adds future twin templates/validators | A concrete precedent for the maturity-gated artifact pattern. |

## User Stories

- As a **twin-project consumer**, I want activating `management/digital-twin` to require a
  `twin-profile.md` declaring my maturity level, standards conformance, and governing principles,
  so my project cannot silently overclaim.
- As a **planner**, I want the maturity ladder to gate required artifacts, so a digital model is
  not burdened with operational-twin ceremony, and an operational twin cannot ship without run
  logs and publication review.
- As a **twin-project consumer**, I want a WARN validator that fires when a scenario manifest is
  missing provenance, dataset versions, or assumption confidence, so unreproducible runs are
  surfaced in CI.
- As a **consumer handling personal / civic data**, I want `digital-twin` to compose with
  `privacy-by-design`, so collection and personal-data handling are both governed.
- As a **harness maintainer**, I want the overlay catalog-only (not activated on this repo), so the
  full validator suite stays predict-clean.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | `management/digital-twin` scaffolding | `module.yaml` + `README.md`; `type: management`, `dependsOn: [kernel/base]`, `requiredArtifacts: [docs/twin/twin-profile.md]`, sensitive paths, companion rules. README documents the dual spine + composition. | Default-off opt-in overlay. |
| FR-002 | `platform/templates/digital-twin/` maturity-gated set | Ten templates (profile, overview/ladder, scenario-manifest-spec, data-provenance, model-registry, agent-registry, run-log-spec, uncertainty-policy, publication-policy, security-boundaries), tokenized SPDX headers. `twin-profile.md` carries the maturity declaration + standards-conformance (with status) + governing-principles fields + the no-overclaim bias guardrail. | Depth required by maturity level. |
| FR-003 | `validate-twin-profile.sh` (Half-enforced) | Module-gated WARN; asserts the profile exists and declares a maturity level, ≥1 conformance target with status, and governing principles. No-ops when the overlay is inactive. | §10: Half-enforced. |
| FR-004 | `validate-scenario-manifest.sh` (Half-enforced) | Accepts a scenario YAML path; fails (WARN) if required top-level sections are missing, datasets lack source/version/asOf/confidence, assumptions lack confidence/sensitivity, provenance is missing, or publication approval is missing for outputs marked published. | §10: Half-enforced. Seed Phase-11 field list. |
| FR-005 | `harness-digital-twin` skill | Activates on twin/simulation/scenario/world-state/run-log/model-registry/provenance tasks; instructs: classify maturity, separate world/scenario/run state, require provenance + manifest + registries + run log + uncertainty + publication boundary, never treat LLM output as source-of-truth, never let visualization substitute for simulation. | Existing Agent Skills format. |
| FR-006 | Sample composition | `digital-twin-prototype.yaml` activates `digital-twin` + `privacy-by-design` (+ existing architecture/data modules only); listed in `platform/compositions/README.md` and root `README.md`. | Existing modules only. |
| FR-007 | Digital Twin family diagram | One diagram in `docs/architecture/diagrams.md`: the overlay, the forcing artifact, the maturity ladder, and the composition edges to `aec-iso19650-im` + `privacy-by-design`. | Index + prose counts updated. |
| FR-008 | Discoverability propagation | Overlay appears in `SUMMARY.md`, catalog README Module table, `harness-onboarding/SKILL.md`, and `discovery-to-composition.md`. | Companion-rule propagation per `CLAUDE.md`. |
| FR-009 | Catalog-count + full-suite | All count sites updated for +1 module, +10 templates, +2 validators, +1 diagram; full validator suite exits 0 with the overlay on disk (catalog-only, predict-clean). | Exact site list in the Phase-2 plan. |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-S01 | Phase-2 distillation observation | Phase 2 captures the second-cross-cutting-overlay evidence (the deep-domain primitives generalize to a second discipline; the dual-spine standards+values anchor). | A Phase-1 distillation observation ships in *this* PR per PRD-0004 (fired by OPP-0044 + ADR-0019). |
| FR-S02 | "When to activate" guidance in the README | Names the twin/scenario concern it governs and when a consumer activates it (projects that model real-world systems or run scenarios). | Reinforces the opt-in posture. |

### Out of Scope

| Feature | Reason | When to revisit |
|---------|--------|-----------------|
| Simulation / geospatial engine | The harness governs, it does not run twins | Never (by design) |
| Maturity-aware required-artifacts validator | v1 enforces profile + manifest core; depth is Asserted-only | When the maturity-gating pattern is proven |
| New top-level taxonomy category | Staged in ADR-0019 | At a third epistemic-discipline instance |
| Abstract deep-domain framework operating-principle | Authored post-overlay in the harvest pass | After the harvest precondition is exercised |

## Implementation Deferral

Per § 9, this PRD ships the design contract; the implementing PR (Phase 2) adds the module,
templates, validators, skill, composition, diagram, discoverability, counts, and the Phase-2
distillation observation.

| Deferred implementation | Deferred to | Why |
|-------------------------|-------------|-----|
| `digital-twin` module YAML + README | Phase 2 | Design-first per § 9 |
| Ten digital-twin templates | Phase 2 | Same |
| Two Half-enforced validators | Phase 2 | Same |
| `harness-digital-twin` skill | Phase 2 | Same |
| Composition + diagram + discoverability + counts | Phase 2 | Same |
| Phase-2 distillation observation (FR-S01) | Phase 2 | Captured during implementation |

## Technical Constraints

- **Module type: `management`** — already accepted by `validate-module-graph.sh`.
- **Catalog-only overlay** — not added to `harness.manifest.yaml`; the harness's own suite stays
  predict-clean. Default-off / opt-in.
- **Per-module sensitive-path self-coverage** — `sensitivePaths` fully overlapped by
  `companionRules.triggerPaths` so an activating consumer passes `validate-sensitive-paths.sh`.
- **Module-gated validators** — both new validators no-op (exit 0) when no `digital-twin` overlay
  is active.
- **Bash + system Ruby** — no new dependencies. **SPDX dual-license headers** on all new files;
  `UncleNate@gmail.com`.

## CI/CD Gates

| Gate | Required? | Notes |
|------|-----------|-------|
| markdownlint + shellcheck | Yes | All new `.md` pass; new validators pass shellcheck |
| Full validator suite exits 0 | Yes | N+2 validators after FR-003/FR-004; predict-clean on the harness's own CI |
| `validate-catalog-counts.sh` correct after bumps | Yes | Module/templates/diagram/validator bumped exactly |
| `validate-list-completeness.sh` exits 0 | Yes | Overlay in SUMMARY; templates dir indexed; composition in both READMEs |
| Change-log updated | Yes | One entry per PR |

## Success Metrics

| KPI | Target | How measured |
|-----|--------|-------------|
| Dogfood pass rate at implementing PR | 100% — full suite passes (overlay present, not activated) | Phase-2 CI |
| Sample composition validates clean | `digital-twin` + privacy active; suite exits 0 | `digital-twin-prototype.yaml` |
| Profile validator behaves | WARN when active + profile missing/incomplete; no-op when inactive | Validator fixture test (`--scan-file` seam) |
| Manifest validator behaves | WARN on a manifest missing provenance/version/confidence | Validator fixture test |
| Discoverability coverage | Overlay reachable from onboarding skill, SUMMARY, discovery-to-composition | Spot-check post-merge |

## Dependencies

- `platform/validators/lib/harness_registry.rb` — module enumeration (existing).
- `management/privacy-by-design` (shipped) — the cross-cutting the overlay composes with.
- `domains/aec-iso19650-im` — the built-environment substrate for the lead composition.
- Bash + system Ruby.

## Verification

The overlay is verified, not asserted (at Phase 2):

- All validators pass with the overlay on disk (module-graph resolves the dependency;
  required-artifacts, companions, sensitive-paths, the two new validators, catalog-counts,
  list-completeness, doc-references, and the rest).
- The new validators no-op when no `digital-twin` overlay is active (harness CI green) and WARN on
  fixtures where the overlay is active with a missing/incomplete profile or manifest
  (`--scan-file` seam).
- The sample composition's dependency closure resolves.
- markdownlint passes on all new and changed markdown; shellcheck passes the validators.

## Open Questions

- [ ] **Exact scenario-manifest required-field set** for `validate-scenario-manifest.sh` — the
  seed's Phase-11 list is the v1 basis; confirm at implementation.
- [ ] **Sensitive-path regexes** for the twin surface (`scenarios/**`, `models/**`, `agents/**`,
  `datasets/**`, `data/**`, `simulation/**`, `public/scenarios/**`, `docs/twin/**`) — validate
  against a real twin layout. **Bias: use the spec candidates as v1.**
- [ ] **`digital-twin` composition with `privacy-by-design`** — compose-with (no hard dependency),
  documented in the README and the sample composition.
- [ ] **One validator vs two** — whether profile + manifest checks are one validator or two.
  **Bias: two, to keep the concerns separable; confirm the §10 posture at implementation.**
