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
