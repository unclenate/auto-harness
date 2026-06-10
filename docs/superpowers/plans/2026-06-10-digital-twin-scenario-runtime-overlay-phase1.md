# Digital Twin / Scenario Runtime Overlay — Phase 1 (design-only) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Land the **design contract** for a reusable Digital Twin / Scenario Runtime governance capability as a single pure-docs PR — OPP-0044 (the opportunity) + ADR-0019 (the placement decision) + PRD-0023 (the design contract, with a §10 Claim Classification block) — plus the four propagation satisfiers (candidates token, README index rows, shared-observations distillation entry, change-log entry).

**Architecture:** This is a §9 "split design from implementation" Phase 1. It ships **only** documents under `docs/` — no `platform/profiles/**`, no templates, no validator, no diagram, no catalog-count changes. Those are Phase 2. Because no `module.yaml` or `harness.manifest.yaml` is touched, the harness's own validator suite must stay **predict-clean** (unchanged). Creating an OPP and an ADR both fire the PRD-0004 distillation companion rule — satisfied by ONE `shared-observations.md` entry; the OPP audit-trail floor is satisfied by a `change-log.md` entry. Different files, same PR.

**Tech Stack:** Markdown governance artifacts; Bash validator suite (`platform/validators/*.sh`); `markdownlint-cli2`; `gh` CLI. No code, no new dependencies.

---

## Governing facts (verified against `origin/main` at plan-time, 2026-06-10)

- **Next numbers:** OPP-**0044**, ADR-**0019**, PRD-**0023** (current highest on main: OPP-0043, ADR-0018, PRD-0022). **RE-VERIFY at execution** — parallel maintainer PRs can claim these (lesson from PR #110, which renumbered 0040→0043). If taken, renumber to the next free and sweep `0044|0019|0023` for stragglers (including bolded `**00NN**` and bare table labels `[00NN]`).
- **Design evidence to cite:** `docs/superpowers/specs/2026-06-10-digital-twin-scenario-runtime-overlay-design.md` (placeholder-ignored path; referenced by path, committed alongside this PR).
- **Catalog counts: UNCHANGED.** Do not touch `validate-catalog-counts` sites, `SUMMARY.md`, the README "Module System" table, the onboarding skill, or `discovery-to-composition.md`. (Phase-2 work.)
- **Attribution:** every new file carries the SPDX dual-license header with `UncleNate@gmail.com` (NOT `nate@bdits.io`). Do not modify any `LICENSE-APACHE` canonical `http://` URLs.
- **Diff-mode validators** (`validate-knowledge-redaction`, `validate-companions`) fire only with a `main` base-ref arg; a non-diff local pass is not a CI prediction. Task 8 runs the full suite including both diff-mode validators against `main` on the committed branch.
- **Branch / merge posture:** feature branch; push; open PR. **Do not merge** — Tier-3 ceiling, maintainer's call.
- **markdownlint hazards** (scan the embedded blocks): no line may start with `+ ` (MD004 soft-wrap-`+`, the project's top trip — reflow `X + Y` enumerations so `+` never starts a line); table rows must have consistent column counts (MD056); no trailing blank lines (MD012); YAML-free docs (these use `**Status:**` lines, not frontmatter).

## File map

| File | Action | Responsibility |
|---|---|---|
| `docs/opportunities/OPP-0044-digital-twin-scenario-runtime.md` | Create | The Digital Twin opportunity (recurring pattern; proposed overlay/skill/validators; first slice) |
| `docs/adr/ADR-0019-digital-twin-scenario-runtime-overlay.md` | Create | The placement decision (management overlay, not domain; staged epistemic category) |
| `docs/requirements/PRD-0023-digital-twin-scenario-runtime-overlay.md` | Create | The design contract (§10 block; dual-spine standards anchor; Phase-2 scope) |
| `docs/opportunities/candidates.md` | Modify | Add the OPP-0044 index token (new cluster) + bump Last-Updated |
| `docs/README.md` | Modify | Add the ADR-0019, PRD-0023, and OPP-0044 index rows |
| `docs/knowledge/shared-observations.md` | Modify | Append the Phase-1 distillation observation (PRD-0004 satisfier) + bump Last-Updated |
| `docs/project/change-log.md` | Modify | Add the audit-trail entry (newest-first) |

---

### Task 1: Create OPP-0044 (Digital Twin / Scenario Runtime opportunity)

**Files:**
- Create: `docs/opportunities/OPP-0044-digital-twin-scenario-runtime.md`

- [ ] **Step 1: Write the file verbatim**

```markdown
<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0044 — Digital Twin / Scenario Runtime Governance Overlay

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-06-10
**Last Updated:** 2026-06-10 *(accepted — promoted to a v1 overlay via PRD-0023; see Disposition)*
**Confidence:** high

---

## Thesis

A pattern recurs across active projects: software that **models real-world systems, runs
scenarios, evaluates assumptions, publishes decision-support outputs, or coordinates
agents/models/datasets around a world state**. Today each such project re-derives the same
governance locally — provenance, world/scenario/run-state separation, model/agent registries,
run logs, uncertainty disclosure, publication boundaries, and "don't overclaim the maturity"
discipline. The harness has no reusable machinery for it.

The recurrence is concrete: municipal / civic twinning, a Central City / Foundation OS planning
substrate, an AI-datacenter operations twin, healthcare/FHIR agentic workflows, civic planning
portals, and TerraSim-style geospatial simulation. The municipal-twinning R&D is now drawing
real-estate-development interest, and the through-line is a **planning-lifecycle product**: build
planning models that can be *transformed* into operational digital twins. Multiple projects are
expected to rely on this research and its organizational governance to move fast and accurately.

Ship the capability as a **`management/digital-twin` cross-cutting overlay** (default-off,
opt-in) — not a subject-matter domain. Twin-ness is orthogonal to subject matter: a civic twin, a
healthcare twin, an AEC operational twin, and a datacenter twin share a *discipline* that layers on
top of whatever the project is. This OPP ratifies the opportunity; PRD-0023 specifies the v1
overlay and ADR-0019 records the placement decision.

## The recurring pattern (the primitives to govern)

scenario manifests · world-state vs scenario-state vs run-state separation · data provenance ·
model / agent registries · simulation / event / run logs · uncertainty and sensitivity reporting ·
public / private publication boundaries · reproducible golden scenarios · human review gates for
high-impact outputs · validators that prevent scenario / model / data drift.

The module helps a project avoid a known failure set: a dashboard masquerading as a twin;
LLM-generated truth; unversioned datasets; unreproducible runs; hidden assumptions; fake
precision; public/private boundary leakage; no source-of-truth discipline; no model registry; no
scenario manifest; no run log; no uncertainty statement; no golden-scenario tests; no review gate
before public or high-impact outputs.

## Why now

- **The harvest now has a candidate second cross-cutting concern.** After `privacy-by-design`,
  Digital Twin is a second discipline overlay built on the deep-domain primitives
  (neutral-core + forcing-artifact + bias-guardrail), generalizing them beyond industry verticals.
- **A planning-lifecycle product with dependent projects.** Robust, externally-anchored governance
  shipped now lets downstream projects align to a contract immediately rather than each
  re-deriving it.
- **The transformation thesis has standards behind it.** Interoperability and digital-thread
  standards (ISO 23247 incl. the emerging Part 5 digital-thread, ISO 10303 STEP/AP242, QIF,
  Asset Administration Shell, DTDL, W3C WoT) make planning→operational transformation a governed
  conformance question, not a marketing claim.

## Candidate consumers

Central City / Foundation OS · AI-Datacenter Operations Twin · municipal / civic planning portals
· real-estate-development planning twins · healthcare/FHIR agentic workflows · TerraSim-style
geospatial simulation · other scenario-driven agentic systems.

## Proposed shape (specified in PRD-0023)

- **Overlay:** `management/digital-twin` (default-off). Forcing artifact `docs/twin/twin-profile.md`
  declaring maturity level, standards-conformance (with status), and governing principles.
- **Bias guardrail:** default-deny overclaiming — no maturity level beyond the evidence; no
  emerging standard cited as ratified; no high-impact output published without its review gate.
- **Maturity-gated artifacts:** required-artifact depth scales with the declared level
  (model → shadow → prototype → operational → control-loop), grounded in ISO/IEC 30173 + the DTC
  Capabilities Periodic Table + Kritzinger et al.
- **Skill:** `harness-digital-twin` (Phase 2). **Validators:** `validate-twin-profile.sh` and
  `validate-scenario-manifest.sh` (Half-enforced, Phase 2). **Composition:**
  `digital-twin-prototype.yaml` (Phase 2).

## Non-goals

- Not a simulation / geospatial / rendering engine — the harness governs twin projects, it does
  not run them.
- Not a new top-level taxonomy category (the latent epistemic-discipline cluster is staged in
  ADR-0019, not minted).
- Not an event-sourcing mandate, a mandated ontology, or an operational-control-loop framework in
  v1.

## TerraSim-derived lessons

A TerraSim repository review surfaced the reusable primitives above. The lesson is the primitives,
not the product: serious twin-like systems need governed scenario manifests, world/scenario/run
separation, provenance, registries, run logs, uncertainty reporting, publication boundaries,
golden scenarios, and review gates — independent of any one simulation stack.

## Risks / Open questions

- **Artifact burden for simple prototypes.** Mitigated by the maturity-gated model: a digital
  model (L1) needs only the profile; depth is required only as maturity rises.
- **Overclaiming maturity.** The forcing artifact + the bias guardrail + Gemini "Quality" make the
  declared level evidence-bound; a maturity-aware validator is deferred to a later slice.
- **Standards status drift.** Several anchors are emerging (ISO 23247-5/-6, ISO/IEC 30188); the
  profile's status field prevents citing a draft as ratified.
- **No grounded consumer codebase committed yet.** Like AEC, grounded in standards + a real
  pattern; refine sensitive-path regexes against a real twin layout at implementation.

## Disposition

**Accepted 2026-06-10.** The `management/digital-twin` overlay is promoted to a v1 design contract
(PRD-0023); ADR-0019 records the overlay-vs-domain decision and stages the epistemic-discipline
category question. Implementation (module, templates, validators, skill, composition, diagram,
counts) is deferred to Phase 2 per § 9.

## Related

- Cross-cutting precedent: [OPP/ADR/PRD privacy-by-design](../adr/ADR-0018-privacy-by-default-posture.md) (first discipline overlay on the deep-domain primitives)
- Built-environment composition: `domains/aec-iso19650-im` (BIM substrate) — the lead municipal / real-estate stack
- Placement decision: [ADR-0019](../adr/ADR-0019-digital-twin-scenario-runtime-overlay.md)
- Design contract: [PRD-0023](../requirements/PRD-0023-digital-twin-scenario-runtime-overlay.md)
- Design spec: `docs/superpowers/specs/2026-06-10-digital-twin-scenario-runtime-overlay-design.md`
```

- [ ] **Step 2: Verify** — Run: `head -13 docs/opportunities/OPP-0044-digital-twin-scenario-runtime.md` → SPDX header then `# OPP-0044 — Digital Twin / Scenario Runtime Governance Overlay`. (No commit yet — Task 8.)

---

### Task 2: Create ADR-0019 (placement decision)

**Files:**
- Create: `docs/adr/ADR-0019-digital-twin-scenario-runtime-overlay.md`

- [ ] **Step 1: Write the file verbatim**

```markdown
<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0019: Adopt Digital Twin / Scenario Runtime as a Management Overlay

**Status:** Accepted
**Date:** 2026-06-10
**Author:** @unclenate
**Reviewers:** @unclenate
**Context sources:**

- `docs/superpowers/specs/2026-06-10-digital-twin-scenario-runtime-overlay-design.md` — the full
  design spec: dual-spine contract, standards anchor, forcing artifact, maturity ladder, §10 map
- `docs/opportunities/OPP-0044-digital-twin-scenario-runtime.md` — the opportunity this resolves
- `docs/requirements/PRD-0023-digital-twin-scenario-runtime-overlay.md` — the build specification

## Context

Digital-twin / scenario-runtime patterns recur across active projects (municipal twinning,
real-estate planning, AI-datacenter operations, civic portals, healthcare agentic workflows,
TerraSim-style geospatial simulation). A TerraSim review exposed reusable governance primitives.
auto-harness should encode these as reusable governance rather than project-local advice.

The placement question is genuine: is this a subject-matter **domain** (like `healthcare-*`,
`aec-*`, `cybersec-*`) or a cross-cutting **management** overlay (like `privacy-by-design`,
`eval-gated-testing`)? Digital twin has a domain-flavored *runtime-structure* layer (scenario
manifests, world/scenario/run state, registries, run logs) and a management-flavored *discipline*
layer (provenance, uncertainty, no-overclaim, publication, review gates). The governance concern —
disciplining the gap between a model and the reality it claims to represent — is what is
load-bearing, and it layers orthogonally on top of subject matter.

## Decision

Adopt **`management/digital-twin`, a default-off opt-in overlay.**

Twin-ness is orthogonal to subject matter: a civic twin, a healthcare twin, an AEC operational
twin, and a datacenter twin share a discipline that layers on top of whatever the project is. The
overlay composes *with* subject-matter domains (`aec-iso19650-im`, `healthcare-fhir`,
`cybersec-osint`) and *with* other management overlays (`privacy-by-design`, `eval-gated-testing`),
never replacing them.

The overlay carries a **dual-spine governance contract**: an interoperability / digital-thread
spine (so a planning model can transform into an operational twin) anchored on ISO 23247, ISO
10303 STEP/AP242, QIF, the Asset Administration Shell, DTDL, and W3C WoT; and a governance-values
spine anchored on the Gemini Principles (CDBB, 2018). The single forcing artifact
`docs/twin/twin-profile.md` makes a project declare its maturity level, its standards conformance
(with published-vs-emerging status), and the principles governing its outputs. The validator
posture is **Half-enforced** (module-gated WARN), matching `privacy-by-design`. PRD-0023 specifies
the full build; the harness does not activate the overlay on itself (ship-as-catalog).

**Default-off, opt-in** (contrast `privacy-by-design`'s default-on): the realistic population of
consumer projects is mostly not twins, so the overlay is activated only by projects that model
real-world systems or run scenarios.

## Alternatives considered

**`domains/digital-twin` (the seed's suggestion).** Rejected: across every named consumer, digital
twin *layers on* a subject matter (civic, built-environment, datacenter, health) or none — it is
never itself the subject matter. A domain framing would force a co-active "second domain" with
muddy subject-vs-discipline semantics; the overlay framing is cleaner and matches the orthogonality.

**Minting a new top-level taxonomy category now.** The governance essence — *representational /
epistemic integrity* — is a third concern-type the flat taxonomy does not name, and
`eval-gated-testing` shares its shape (an evidence-graded, anti-overclaiming discipline with a
gating ladder), suggesting a latent cluster at n≈2. Rejected for now: the harness's concrete-first
law harvests abstractions from instances (we have not yet harvested even the deep-domain framework
at n=3), and minting a category off one new module would be the exact overclaiming this module
exists to prevent. **Staged** as a named future opportunity, triggered by a third instance.

**Kernel-mandatory / default-on.** Rejected: most projects are not twins; imposing twin ceremony
universally is dead weight, contrary to the consumer-autonomy principle. Default-off / opt-in fits.

## Consequences

**Positive:**

- Reusable, externally-anchored governance across civic, infrastructure, real-estate, healthcare,
  AI-datacenter, and simulation projects — adoptable off the shelf.
- The deep-domain primitives gain a second cross-cutting application (after privacy),
  strengthening the eventual harvest's generalization claim.
- The dual-spine + maturity-gated model reduces overclaiming and makes planning→operational
  transformation a governed conformance question.
- The built-environment stack (`aec-iso19650-im` × `digital-twin` × `privacy-by-design`) is
  institutionally coherent — CDBB authored both the Gemini Principles and the UK ISO 19650
  transition.

**Negative / costs:**

- A new opt-in overlay adds artifact obligations for projects that activate it (mitigated by the
  maturity-gated depth: L1 needs only the profile).
- v1 validators are Half-enforced and shallow by design; depth-by-maturity is Asserted-only until
  a maturity-aware validator is proven. A deliberate limitation, not an oversight.

**Watch:**

- Standards status drift — several anchors are emerging (ISO 23247-5/-6, ISO/IEC 30188); the
  profile's status field must be honored so a draft is never cited as ratified.
- If a third epistemic-discipline instance appears, revisit the staged category harvest.

## References

- `docs/superpowers/specs/2026-06-10-digital-twin-scenario-runtime-overlay-design.md` — design spec
- [OPP-0044](../opportunities/OPP-0044-digital-twin-scenario-runtime.md) — the opportunity
- [PRD-0023](../requirements/PRD-0023-digital-twin-scenario-runtime-overlay.md) — build spec
- [ADR-0018: Privacy-by-Default Posture](ADR-0018-privacy-by-default-posture.md) — sibling
  discipline-overlay ADR; shares the WARN-posture / ship-as-catalog pattern
```

- [ ] **Step 2: Verify** — Run: `head -7 docs/adr/ADR-0019-digital-twin-scenario-runtime-overlay.md` → SPDX header then `# ADR-0019: Adopt Digital Twin / Scenario Runtime as a Management Overlay`.

---

### Task 3: Create PRD-0023 (design contract)

**Files:**
- Create: `docs/requirements/PRD-0023-digital-twin-scenario-runtime-overlay.md`

- [ ] **Step 1: Write the file verbatim**

```markdown
<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0023 — Digital Twin / Scenario Runtime Governance Overlay

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-10 | **Review Cycle:** On-change

**Status:** Proposed
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
```

- [ ] **Step 2: Verify** — Run: `head -15 docs/requirements/PRD-0023-digital-twin-scenario-runtime-overlay.md` → SPDX header then `# PRD-0023 — Digital Twin / Scenario Runtime Governance Overlay` and the version/status lines.

---

### Task 4: Add the OPP-0044 token to `candidates.md`

Every OPP needs a `candidates.md` index token. Add a new dated cluster (cluster headings are organizational — no ADR needed, per the file's own scope note) and bump Last-Updated.

**Files:**
- Modify: `docs/opportunities/candidates.md`

- [ ] **Step 1: Bump the Last-Updated line.** Replace (line 9):

```markdown
**Owner:** @unclenate | **Last Updated:** 2026-06-09 *(added Cybersecurity deep-domain cluster: OPP-0043)*
```

with:

```markdown
**Owner:** @unclenate | **Last Updated:** 2026-06-10 *(added Digital Twin / Scenario Runtime cluster: OPP-0044)*
```

- [ ] **Step 2: Insert the new cluster** immediately before the `### Canonical direction & strategic alignment` heading (currently ~line 504 — re-verify; use the heading text as the anchor, not the number). Insert:

```markdown
### Digital Twin / Scenario Runtime overlay (2026-06-10)

A reusable cross-cutting governance overlay for projects that model real-world
systems, run scenarios, and publish decision-support outputs. The second
discipline overlay (after privacy-by-design) built on the deep-domain
primitives; dual-spine standards anchor (interoperability/digital-thread +
the Gemini Principles); a maturity-gated forcing artifact.

- [OPP-0044](OPP-0044-digital-twin-scenario-runtime.md) *(accepted 2026-06-10; ADR-0019; PRD-0023)*
  — `management/digital-twin` (default-off opt-in) + `templates/digital-twin/` +
  `digital-twin-prototype.yaml` composition + two Half-enforced WARN validators
  (`validate-twin-profile`, `validate-scenario-manifest`) + the `harness-digital-twin`
  skill. Composes with `management/privacy-by-design` and `domains/aec-iso19650-im`
  (the municipal / real-estate planning-twin stack).

```

- [ ] **Step 3: Verify** — Run: `grep -n "OPP-0044" docs/opportunities/candidates.md` → one match in the new cluster.

---

### Task 5: Add the index rows to `docs/README.md`

Three tables: the ADR index (after the ADR-0018 row), the PRD index (after the PRD-0022 row), the OPP index (after the OPP-0043 row). Use the row text as the anchor; line numbers (~62 / ~94 / ~148) are advisory — re-verify before editing.

**Files:**
- Modify: `docs/README.md`

- [ ] **Step 1: Add the ADR-0019 row** after the ADR-0018 row. Find:

```markdown
| [0018](adr/ADR-0018-privacy-by-default-posture.md) | Privacy-by-Default Posture | Accepted |
```

Insert immediately after:

```markdown
| [0019](adr/ADR-0019-digital-twin-scenario-runtime-overlay.md) | Adopt Digital Twin / Scenario Runtime as a Management Overlay | Accepted |
```

- [ ] **Step 2: Add the PRD-0023 row** after the PRD-0022 row. Find:

```markdown
| [0022](requirements/PRD-0022-cybersec-osint-maltego-wedge.md) | Cybersecurity OSINT / Maltego Wedge | Proposed | [OPP-0043](opportunities/OPP-0043-domain-family-cybersecurity-decomposed.md) |
```

Insert immediately after:

```markdown
| [0023](requirements/PRD-0023-digital-twin-scenario-runtime-overlay.md) | Digital Twin / Scenario Runtime Overlay | Proposed | [OPP-0044](opportunities/OPP-0044-digital-twin-scenario-runtime.md) |
```

- [ ] **Step 3: Add the OPP-0044 row** after the OPP-0043 row. Find:

```markdown
| [0043](opportunities/OPP-0043-domain-family-cybersecurity-decomposed.md) | Cybersecurity Domain Family (decomposed) | accepted (partial promotion) |
```

Insert immediately after:

```markdown
| [0044](opportunities/OPP-0044-digital-twin-scenario-runtime.md) | Digital Twin / Scenario Runtime Governance Overlay | accepted |
```

- [ ] **Step 4: Verify** — Run: `grep -nE "ADR-0019|PRD-0023|OPP-0044" docs/README.md` → three matches (one per index).

---

### Task 6: Append the Phase-1 distillation observation (PRD-0004 satisfier)

Creating OPP-0044 **and** ADR-0019 each fire the PRD-0004 distillation companion rule, which requires a `shared-observations.md` (or `operating-principles.md`) entry **in this PR** — change-log does NOT satisfy it. ONE substantive observation satisfies both. It must advance the harvest evidence, not restate the OPP.

**Files:**
- Modify: `docs/knowledge/shared-observations.md`

- [ ] **Step 1: Bump the Last-Updated line** (currently line 5 — re-verify; it carries a running `Prior:` chain that must be preserved). Replace the current `**Last Updated:** 2026-06-09 *(Cybersecurity wedge Phase 1: ...)*` line with:

```markdown
**Last Updated:** 2026-06-10 *(Digital Twin overlay Phase 1: OPP-0044 + ADR-0019 + PRD-0023 design contract; appended the observation that the deep-domain primitives generalize to a SECOND cross-cutting discipline overlay (after privacy-by-design), and that a twin-governance overlay needs a dual-spine anchor — interoperability/digital-thread standards plus a governance-values framework — to make planning→operational transformation a governed conformance question. Satisfies the PRD-0004 distillation rule fired by the new `docs/opportunities/OPP-0044-digital-twin-scenario-runtime.md` and `docs/adr/ADR-0019-digital-twin-scenario-runtime-overlay.md`. Prior: 2026-06-09 cybersec wedge (OPP-0043 + PRD-0022); 2026-06-07 greenfield conservatism (PRD-0021); 2026-06-06 bootstrap hardening (PRD-0020); 2026-06-05 onboarding safety + install prerequisites; 2026-06-04 AEC wedge Phase 2; the OPP-0038 attribution-boundary observation; and consumer-adoption observations from the fork-held-consumer pin-bump session.)*
```

> Note: confirm the exact text of the current Last-Updated line at execution and preserve any `Prior:` segments the maintainer has added since this plan was written; prepend the new note, keep the full chain.

- [ ] **Step 2: Append the observation** at the end of the file (after the last `### ...` entry):

```markdown

### A twin-governance overlay generalizes the deep-domain primitives to a second cross-cutting discipline, and needs a dual-spine (interoperability + values) anchor to govern model→operational transformation

- **Context:** OPP-0044 / ADR-0019 / PRD-0023 establish `management/digital-twin` as a default-off cross-cutting overlay for projects that model real-world systems and run scenarios. It follows `privacy-by-design` as the second *discipline* overlay (not an industry vertical) built on the neutral-core + forcing-artifact + bias-guardrail primitives proven in healthcare, AEC, and cybersec.
- **Observation:** Two patterns surface that the industry verticals could not. First, the primitives generalize to a **second cross-cutting concern**: the forcing artifact (`twin-profile.md`) makes the consumer declare a maturity level the way `privacy-profile` declares a regime, and the bias guardrail (default-deny overclaiming) mirrors the no-US-default guardrail — evidence that the deep-domain primitives are not domain-specific. Second, a credible twin overlay needs a **dual-spine anchor**: an interoperability / digital-thread spine (ISO 23247, ISO 10303 STEP/AP242, QIF, Asset Administration Shell, DTDL, W3C WoT) that makes a planning model *transformable* into an operational twin, AND a governance-values spine (the Gemini Principles) that governs publication and trust — and the two interlock (Gemini "Federation" requires the standard connected environment the interoperability spine provides). The placement question also exposed a latent **epistemic-discipline** category (governing the model↔reality gap) shared with `eval-gated-testing`, staged in ADR-0019 rather than minted (concrete-first).
- **Implication:** The harvest now has a second cross-cutting data point: the operating-principle generalization should read "neutral-core + forcing-artifact + bias-guardrail works for industry domains (×3) AND discipline overlays (×2)." Future tool/standards-anchored overlays can copy the dual-spine pattern (a technical-conformance spine + a values spine that interlock). The epistemic-discipline category is a deferred taxonomy-harvest triggered by a third instance. See [[project-deep-industry-domains]] and [[project-digital-twin-overlay]].
- **Confidence:** medium. One overlay instance (digital-twin), but it contrasts cleanly with the privacy overlay and the three industry verticals, and the dual-spine + maturity-gated patterns are concrete and copyable.
- **Severity:** architecture
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-10 (Digital Twin overlay Phase 1; satisfies the PRD-0004 distillation rule fired by the new OPP-0044 and ADR-0019; substantive connection — names the second-cross-cutting-overlay generalization and the dual-spine anchor the digital-twin overlay surfaces over the prior four, advancing the harvest evidence rather than restating the OPP)
```

- [ ] **Step 3: Verify** — Run: `grep -n "generalizes the deep-domain primitives to a second cross-cutting discipline" docs/knowledge/shared-observations.md` (one heading near the tail) and `head -5 docs/knowledge/shared-observations.md | grep "Last Updated"` (carries `2026-06-10` with the `Prior:` chain preserved).

---

### Task 7: Add the change-log audit-trail entry

The OPP/ADR audit-trail floor requires a `change-log.md` entry. Newest-first: insert immediately after the `---` separator (currently line 12 — re-verify) and before the current first `## ` entry (`## 2026-06-09 — OPP-0043 + PRD-0022 filed: ...` — re-verify the head before editing).

**Files:**
- Modify: `docs/project/change-log.md`

- [ ] **Step 1: Insert the entry** after the `---` separator, before the current head entry:

```markdown

## 2026-06-10 — OPP-0044 + ADR-0019 + PRD-0023 filed: Digital Twin / Scenario Runtime overlay (design-only)

Phase-1 design contract for a reusable **Digital Twin / Scenario Runtime** governance
capability, landed as a pure-docs PR per § 9 (split design from implementation).
**OPP-0044** ratifies the opportunity (a recurring twin/scenario pattern across municipal,
real-estate, datacenter, civic, and health projects). **ADR-0019** records the placement
decision — a `management/digital-twin` cross-cutting overlay (default-off opt-in), NOT a
subject-matter domain — and stages the latent "epistemic-discipline" taxonomy category
(shared with `eval-gated-testing`) rather than minting it. **PRD-0023** specifies the v1
overlay: a single `twin-profile.md` forcing artifact, a dual-spine standards anchor
(interoperability/digital-thread + the Gemini Principles), a maturity-gated artifact model,
two Half-enforced WARN validators, a skill, a sample composition, and a diagram — with a §10
Claim Classification block. All implementation (module, templates, validators, skill,
composition, diagram, counts) is **deferred to Phase 2** per § 9.

The overlay is the second cross-cutting discipline overlay after `privacy-by-design`,
generalizing the deep-domain primitives beyond industry verticals. The lead composition is
the built-environment planning-twin stack `domains/aec-iso19650-im` × `management/digital-twin`
× `management/privacy-by-design` — institutionally coherent (CDBB authored both the Gemini
Principles and the UK ISO 19650 transition). The PRD-0004 distillation rule (fired by creating
OPP-0044 and ADR-0019) is satisfied by the second-cross-cutting-overlay observation appended to
`docs/knowledge/shared-observations.md` in the same PR. Design evidence:
`docs/superpowers/specs/2026-06-10-digital-twin-scenario-runtime-overlay-design.md`.
```

- [ ] **Step 2: Verify** — Run: `grep -n "OPP-0044" docs/project/change-log.md` → one match near the top (newest-first).

---

### Task 8: Validate, commit, push, open PR (no merge)

**Files:** none new — verification + git.

- [ ] **Step 1: Run markdownlint exactly as CI does**

Run: `npx markdownlint-cli2`
Expected: zero errors. Watch the recurring trips in the new files: MD004 (no line starting with `+ ` — the §-enumerations and "X + Y" phrases must not soft-wrap a `+` to column 1), MD056 (the §10 / FR tables must have consistent column counts), MD012 (no trailing blank lines), MD034 (emails are inside the SPDX HTML comment, fine). If MD004 fires, reflow the offending line so no `+` starts a line; re-run.

- [ ] **Step 2: Run the full validator suite, including both diff-mode validators against `main`**

```bash
bash platform/validators/validate-manifest.sh harness.manifest.yaml
bash platform/validators/validate-module-graph.sh harness.manifest.yaml
bash platform/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash platform/validators/validate-placeholders.sh .
bash platform/validators/validate-agent-pack.sh harness.manifest.yaml .
bash platform/validators/validate-doc-references.sh .
bash platform/validators/validate-catalog-counts.sh .
bash platform/validators/validate-list-completeness.sh .
bash platform/validators/validate-trust-tier.sh harness.manifest.yaml .
bash platform/validators/validate-sensitive-paths.sh harness.manifest.yaml .
bash platform/validators/validate-skill-content.sh harness.manifest.yaml .
bash platform/validators/validate-sast-coverage.sh harness.manifest.yaml .
bash platform/validators/validate-privacy-by-design.sh harness.manifest.yaml .
bash platform/validators/validate-knowledge-redaction.sh . main
bash platform/validators/validate-companions.sh harness.manifest.yaml . main
```

Expected: every validator exits 0. The diff-mode pair is the load-bearing check — the change-log + shared-observations + OPP/ADR/PRD additions must satisfy the companion rules. If `validate-companions` reds, read its message (most likely the distillation satisfier) and fix forward by adding the companion; do not weaken the rule. (Run after committing in Step 4 too — diff-mode compares the branch against `main`.)

- [ ] **Step 3: Create the feature branch, stage, and commit**

```bash
git checkout -b digital-twin-overlay-phase1
git add docs/opportunities/OPP-0044-digital-twin-scenario-runtime.md \
        docs/adr/ADR-0019-digital-twin-scenario-runtime-overlay.md \
        docs/requirements/PRD-0023-digital-twin-scenario-runtime-overlay.md \
        docs/opportunities/candidates.md \
        docs/README.md \
        docs/knowledge/shared-observations.md \
        docs/project/change-log.md \
        docs/superpowers/specs/2026-06-10-digital-twin-scenario-runtime-overlay-design.md \
        docs/superpowers/plans/2026-06-10-digital-twin-scenario-runtime-overlay-phase1.md
git status --short
```

Expected staged set: the 7 governance files + the design spec + this plan. Do NOT stage the unrelated working-tree files (`docs/doc-watch-log.md`, `docs/product/Digital-Twin-Seed.txt`).

```bash
git commit -m "$(cat <<'EOF'
[digital-twin overlay] OPP-0044 + ADR-0019 + PRD-0023 — scenario-runtime governance overlay (design-only)

Phase 1 design contract for a reusable Digital Twin / Scenario Runtime governance
capability. OPP-0044 ratifies the opportunity; ADR-0019 records the placement
decision (management/digital-twin cross-cutting overlay, default-off, NOT a domain;
stages the epistemic-discipline taxonomy category); PRD-0023 specifies the v1 overlay
(twin-profile forcing artifact, dual-spine standards anchor, maturity-gated artifacts,
two Half-enforced WARN validators, skill, composition, diagram) with a §10 Claim
Classification block. Implementation deferred to Phase 2 per § 9.

Satisfies the PRD-0004 distillation rule (OPP-0044 + ADR-0019 creation) via the
second-cross-cutting-overlay observation in shared-observations.md, and the OPP
audit-trail floor via the change-log entry.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

- [ ] **Step 4: Re-run the full suite on the committed branch** (post-commit, pre-push). Re-run Step 1 (markdownlint) and Step 2 (the 15 validators incl. diff-mode vs `main`). Expected: still all green. If anything green is now red, fix forward, amend or new-commit, re-verify. Do not push red.

- [ ] **Step 5: Push and open the PR (do NOT merge)**

```bash
git push -u origin digital-twin-overlay-phase1
gh pr create --title "[digital-twin overlay] OPP-0044 + ADR-0019 + PRD-0023 — scenario-runtime governance overlay (design-only)" --body "$(cat <<'EOF'
## Summary

Phase 1 (design-only, per operating-principle § 9) of a reusable **Digital Twin / Scenario Runtime** governance capability — a `management/digital-twin` cross-cutting overlay (default-off, opt-in).

- **OPP-0044** — ratifies the opportunity: a recurring twin/scenario pattern across municipal, real-estate, AI-datacenter, civic, and healthcare projects, with a planning-lifecycle through-line (planning models that transform into operational twins).
- **ADR-0019** — records the placement decision: a `management/` cross-cutting overlay, NOT a `domains/` subject-matter vertical (twin-ness layers orthogonally on subject matter); stages the latent "epistemic-discipline" taxonomy category (shared with `eval-gated-testing`) rather than minting it.
- **PRD-0023** — the design contract (with a §10 Claim Classification block): a single `twin-profile.md` forcing artifact (maturity + standards-conformance-with-status + governing principles), a **dual-spine standards anchor** (interoperability/digital-thread — ISO 23247, ISO 10303 STEP/AP242, QIF, Asset Administration Shell, DTDL, W3C WoT — plus the Gemini Principles), a maturity-gated artifact model, two **Half-enforced** WARN validators, a skill, a sample composition, and a diagram.

All implementation (module, templates, two validators, skill, composition, diagram, catalog-count propagation) is **deferred to Phase 2**.

## Companion-rule satisfiers (in this PR)

- **PRD-0004 distillation rule** (fired by creating OPP-0044 + ADR-0019) → second-cross-cutting-overlay observation appended to `docs/knowledge/shared-observations.md`.
- **OPP audit-trail floor** → entry in `docs/project/change-log.md`.
- **OPP index token** → new cluster in `docs/opportunities/candidates.md`; ADR/PRD/OPP index rows in `docs/README.md`.

## Validation

- Full validator suite green (including both diff-mode validators against `main`).
- markdownlint-cli2 clean.
- No `platform/**`, no catalog-count changes — harness suite predict-clean and unchanged.

Design evidence: `docs/superpowers/specs/2026-06-10-digital-twin-scenario-runtime-overlay-design.md`.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Expected: PR created. **Stop here — do not merge.** Report the PR URL and CI status; merging is the maintainer's call.

---

## Self-Review (run after writing; fix inline)

**Spec coverage** — every design-spec section maps to a task:
- Placement (overlay, not domain) + staged epistemic category → ADR-0019 (T2) + OPP-0044 (T1). ✓
- Dual-spine contract + Standards Anchor (verified) → PRD-0023 Standards Anchor + ADR-0019 Decision (T2/T3). ✓
- Forcing artifact (`twin-profile`) + bias guardrail → OPP-0044 + PRD-0023 FR-002/FR-003 (T1/T3). ✓
- Maturity ladder + maturity-gated artifacts → PRD-0023 Overview/FR-002 + §10 (T3). ✓
- §10 Claim Classification → PRD-0023 §10 table (T3). ✓
- Composition (built-environment stack) → OPP-0044 + PRD-0023 FR-006/Cross-references (T1/T3). ✓
- Two-phase mapping → PRD-0023 Implementation Deferral (T3); this plan IS Phase 1. ✓
- Distillation (second cross-cutting overlay) → T6. ✓

**Placeholder scan** — no "TBD"/"add appropriate"; artifact content is literal; numbers concrete (OPP-0044/ADR-0019/PRD-0023) with a re-verify-at-execution note. ✓

**Type/number consistency** — OPP-0044 / ADR-0019 / PRD-0023 used identically across T1–T7; filenames (`OPP-0044-digital-twin-scenario-runtime.md`, `ADR-0019-digital-twin-scenario-runtime-overlay.md`, `PRD-0023-digital-twin-scenario-runtime-overlay.md`) spelled identically in creation, README rows, change-log, candidates, and the git-add list. Module path `management/digital-twin`, forcing artifact `docs/twin/twin-profile.md`, validators `validate-twin-profile.sh` / `validate-scenario-manifest.sh`, skill `harness-digital-twin`, composition `digital-twin-prototype.yaml` consistent throughout. ✓

**Phase boundary** — no task touches `platform/**`, `SUMMARY.md`, the README Module System table, `discovery-to-composition.md`, or any catalog-count site. Pure-docs. ✓

**markdownlint pre-scan** — the embedded blocks were authored to avoid line-start `+ ` (MD004); §10 and FR tables have uniform column counts (MD056); no trailing blank lines (MD012). Task 8 Step 1 is the gate. ✓
