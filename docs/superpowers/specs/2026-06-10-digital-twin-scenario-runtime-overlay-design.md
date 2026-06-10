<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Design — Digital Twin / Scenario Runtime Governance Overlay

**Status:** Draft (brainstorming output, pending user review)
**Author:** @unclenate
**Date:** 2026-06-10
**Origin:** `docs/product/Digital-Twin-Seed.txt` (a recurring digital-twin / scenario-runtime
pattern across active projects) + a TerraSim repository review that surfaced reusable
twin-governance primitives.

---

## Purpose

Convert a recurring architectural pattern — projects that **model real-world systems, run
scenarios, evaluate assumptions, publish decision-support outputs, or coordinate
agents/models/datasets around a world state** — into first-class, reusable harness machinery.

The harness should **govern** such projects (reproducibility, provenance, no-overclaiming,
interoperability, publication discipline); it must **not** become a simulation engine. A small,
serious, extensible first slice that fits the existing architecture exactly.

## Strategic context (why robust, why now)

This is not a speculative module. The municipal-twinning R&D is drawing interest from the
**real-estate development** sector, and the through-line is a **planning-lifecycle product**:
*build planning models that can be transformed into operational digital twins.* Multiple
downstream projects (Central City / Foundation OS, an AI-datacenter operations twin, civic
planning portals, healthcare/FHIR agentic workflows, TerraSim-style geospatial simulation) are
expected to rely on this research and its organizational governance to **move fast and
accurately**. The module's job is to give those projects an externally-anchored governance
contract they can adopt off the shelf, rather than each re-deriving provenance / uncertainty /
publication discipline locally.

## Settled decisions (user-confirmed in brainstorm)

1. **Sequencing: §9 design-only first.** PR #1 ships the design contract (OPP + ADR + PRD,
   design-only); PR #2 ships the scaffold (module, templates, validators, skill, composition,
   diagram, counts). Consistent with healthcare / AEC / cybersec; keeps PR #1 predict-clean.
2. **Placement: a `management/digital-twin` cross-cutting overlay**, default-OFF / opt-in —
   *not* a `domains/` vertical. See "Placement decision" below.
3. **Dual-spine governance contract:** an **interoperability / digital-thread** spine (so a
   planning model can transform into an operational twin) **and** a **governance-values** spine
   (so the twin is trustworthy, public-good, secure, well-curated). Both are externally anchored.
4. **The forcing artifact is the maturity declaration**, not a flat 10-artifact list. Required
   artifact depth scales with declared maturity; the bias guardrail is default-deny overclaiming.
5. **The latent "epistemic-discipline" category is staged, not minted.** The ADR names it and
   flags `eval-gated-testing` as a probable sibling, recording a deferred taxonomy-harvest.

## Placement decision — overlay, not domain (and the staged category)

`management/digital-twin`, a default-off opt-in overlay (contrast `privacy-by-design`, which is
default-on). Rationale, recorded in the ADR:

- **Twin-ness is orthogonal to subject matter.** A civic twin, a healthcare twin, an AEC
  operational twin, and a datacenter twin share a *discipline*, not a subject. The discipline
  *layers on top of* whatever the project is — overlay behavior, exactly like privacy. (Domains —
  healthcare, AEC, cybersec — are subject-matter identities a project *is*.)
- **The governance concern is a discipline,** not subject matter: provenance, uncertainty,
  no-overclaim, publication boundaries, interoperability conformance. Same shape as the other
  `management/` overlays.
- **Considered and rejected:** `domains/digital-twin` (the seed's suggestion) — rejected because
  the composition table below shows digital-twin always layering on a subject matter (or none),
  never *being* the subject matter.

**Staged taxonomy-harvest (deferred, maintainer-gated).** Digital-twin's governance essence —
disciplining *the gap between a model and the reality it claims to represent* (provenance,
maturity, uncertainty, world/scenario/run separation) — is a third concern-type the flat taxonomy
does not name: **representational / epistemic integrity**. `management/eval-gated-testing` shares
the shape ("don't claim behavior without graded evidence"), suggesting a latent
*epistemic-discipline* cluster (n≈2). Per the harness's own concrete-first law (we have not yet
harvested even the deep-domain framework at n=3), we **do not mint a new category now**; the ADR
records it as a named future opportunity, triggered by a third instance.

## The dual-spine governance contract

| Spine | Question it answers | Anchors |
|---|---|---|
| **Interoperability / digital thread** | *Is the data built right — can the planning model transform into an operational twin?* | the conformance declaration + technical maturity |
| **Governance values** | *Is the twin trustworthy, public-good, secure, well-curated?* | the review gates + publication policy + the no-overclaim guardrail + curation/ownership |

The two spines **interlock**: the Gemini **Federation** principle ("a standard, collective and
connected environment") *requires* the interoperability anchor, and the interoperability standards
*fulfill* it.

## Standards Anchor (verified 2026-06-10)

> Citation discipline (itself an instance of the no-overclaim guardrail): cite **published**
> standards as normative anchors; cite **under-development** ones as *emerging / to track*, never
> as ratified. iso.org blocks automated fetch — confirm byte-perfect ISO titles on the ISO OBP at
> implementation time.

### Spine 1 — Interoperability & digital thread

**Reference architecture + vocabulary**

- **ISO 23247-1…4:2021** — *Automation systems and integration — Digital twin framework for
  manufacturing* (general principles; reference architecture; digital representation; information
  exchange). **Published.** Parts **5 (Digital thread for digital twin)** and **6 (Digital twin
  composition)** at DIS (2025) — *emerging*; Part 5 is the ISO anchor for the planning→operational
  thread.
- **ISO/IEC 30173:2023** — *Digital twin — Concepts and terminology.* **Published.** The
  vocabulary anchor (also grounds the maturity ladder).
- **ISO/IEC TR 30172:2023** — *Digital twin — Use cases.* **Published** (Technical Report).
- **ISO/IEC 30188** — *Digital twin — Reference architecture.* *Under development (~2026)* —
  emerging; track, do not cite as normative. (Note: **not** ISO/IEC 30179, which is environmental
  IoT.)
- Committee: **ISO/IEC JTC 1/SC 41**, "Internet of things and digital twin."

**Asset / data model**

- **IEC 63278-1:2023** — *Asset Administration Shell for industrial applications — Part 1: AAS
  structure.* **Published** (Part 1; further parts in development). Implementable spec: the
  **IDTA "Specification of the Asset Administration Shell"** series (e.g., IDTA-01001 Metamodel,
  v3.x).

**Modeling & semantic interoperability**

- **DTDL v4** — Digital Twins Definition Language (JSON-LD / RDF; Microsoft/Azure open community
  spec; dual CC-BY-4.0 + MIT). Open/vendor, not an SDO standard.
- **W3C WoT** — *Web of Things (WoT) Thing Description 1.1* + *Architecture 1.1* (+ Discovery),
  **W3C Recommendations (2023-12-05).**
- **MIMOSA** — **OSA-CBM** (Open System Architecture for Condition-Based Maintenance; implements
  the ISO 13374 functional model) / **OSA-EAI** (Open Systems Architecture for Enterprise
  Application Integration). Industry/open.

**Digital thread (lifecycle — the transformation spine)**

- **ISO 10303 (STEP)**; **ISO 10303-242:2025 (Ed. 4)** — AP242, *Managed model-based 3D
  engineering.* **Published.**
- **QIF** — **ISO 23952:2020** / **ANSI/DMSC QIF 3.0** (QIF 4.0 in development). **Published.**

**Industry framework / maturity**

- **Digital Twin Consortium (DTC)** — a program of the Object Management Group (industry
  consortium, not an SDO). *Digital Twin System Interoperability Framework* (white paper, 2021)
  and the **Digital Twin Capabilities Periodic Table** (v1.0 2022 → v1.1 2024 → v1.2; AI-Agent CPT
  2025) — the maturity/capability cross-reference.

### Spine 2 — Governance values: the Gemini Principles

**The Gemini Principles** — Centre for Digital Built Britain (CDBB), University of Cambridge, with
the Digital Framework Task Group; **December 2018**; Bolton A, Enzer M, Schooling J *et al.* The
values foundation for the UK National Digital Twin. **Nine principles, three themes** (key
statements verbatim):

| Theme | Principle | Key statement |
|---|---|---|
| **Purpose** (must have clear purpose) | Public good | "…deliver genuine public good in perpetuity." |
| | Value creation | "…enable sustainable value creation, performance improvement and effective risk management…" |
| | Insight | "…provide determinable insight into the built environment." |
| **Trust** (must be trustworthy) | Security | "…enable security and be secure themselves." |
| | Openness | "…as open as possible, while remaining consistent with… holistic security…" |
| | Quality | "…built on data of an appropriate quality for the purpose to which it is put." |
| **Function** (must function effectively) | Federation | "…based on a standard, collective and connected environment." |
| | Curation | "…clearly and transparently owned, governed and regulated." |
| | Evolution | "…able to adapt and develop as everything evolves…" |

**Custodianship (cite honestly):** CDBB completed its mission and **closed end of September
2022**; the canonical PDF persists in the Cambridge legacy archive. Stewardship is now split — the
**Digital Twin Hub at Connected Places Catapult** (re-hosts the document) and the **DBT National
Digital Twin Programme** (which publishes its *own* separate seven 2024 principles that do not
re-reference Gemini). We cite Gemini as the **2018 foundational framework**, note the closure and
split stewardship, and do not assert a continuity the live programme has not stated. **Institutional
link:** CDBB also co-stewarded the UK's **ISO 19650** transition (with BSI + the UK BIM Alliance,
as the UK BIM Framework) — the same body behind both the Gemini Principles and the standard already
in `domains/aec-iso19650-*`.

## The forcing artifact — `docs/twin/twin-profile.md` (+ bias guardrail)

One required artifact for any active `digital-twin` overlay (mirrors `privacy-profile.md`). It
forces three declarations:

1. **Maturity level** (the ladder below) — *which rung you are at*, with the evidence for it.
2. **Standards conformance** — *which interoperability/thread standards you target, and at what
   status* (conforming-to-published vs targeting-emerging, e.g. ISO 23247-5). The status field is
   itself a no-overclaim guard: a draft may not be cited as ratified.
3. **Governing principles** — *which Gemini Principles govern this twin's outputs*, binding the
   review-gates and publication policy to an external values framework.

> **Bias guardrail = default-deny overclaiming.** You may not claim a maturity level your evidence
> does not support (no "operational twin" without live synchronization, run logs, and operational
> governance), nor cite an emerging standard as ratified, nor publish a high-impact output without
> the declared review gate. The guardrail text lives in the `twin-profile` template and is
> reinforced by Gemini **Quality** + the maturity declaration.

## Maturity ladder (grounded) + maturity-gated artifacts

The ladder is **cross-referenced**, not invented: Kritzinger *et al.* (2018) for the
model/shadow/twin data-flow distinction, ISO/IEC 30173 terminology, and the DTC Capabilities
Periodic Table; ISO 23247-5 (emerging) as the digital-thread anchor for the planning→operational
rung.

| Level | Name | Required artifacts (cumulative) |
|---|---|---|
| 1 | Digital model | `twin-profile` only |
| 2 | Digital shadow | + `data-provenance` |
| 3 | Digital twin prototype | + `scenario-manifest-spec` + `model-registry` + `agent-registry` + `uncertainty-policy` |
| 4 | Operational digital twin | + `run-log-spec` + `publication-policy` + review gates |
| 5 | Closed-loop / control twin | + `security-boundaries` + safety / second-review gates |

**v1 enforcement (real, not theater):** the **core** (twin-profile presence/shape; and at L3+ the
scenario-manifest required fields) is **Half-enforced** via module-gated WARN validators; the
**depth-by-maturity mapping** is **Asserted-only** (review-gate + template guidance) in v1, promoted
to a maturity-aware validator once the pattern is proven. We apply §10 to ourselves.

## §10 Claim Classification (preview; finalized at PRD-time)

| Claim | Class | Mechanism |
|---|---|---|
| `twin-profile` present when overlay active | Enforced | `validate-required-artifacts.sh` |
| Sensitive-path edits (scenarios/models/datasets/run-state) pair with a governance doc | Enforced | `validate-companions.sh` |
| Sensitive paths are companion-covered | Enforced | `validate-sensitive-paths.sh` |
| `twin-profile` declares a maturity level + ≥1 conformance target (w/ status) + governing principles | Half-enforced | `validate-twin-profile.sh` (module-gated WARN) |
| A scenario manifest carries required sections (datasets w/ source+version+asOf+confidence; assumptions w/ confidence+sensitivity; provenance; publication-approval for published outputs) | Half-enforced | `validate-scenario-manifest.sh` |
| Required-artifact depth matches declared maturity | Asserted-only | review gate (maturity-aware validator deferred) |
| Declared maturity matches evidence (no overclaim) | Asserted-only | review gate + Gemini Quality |
| LLM output is not treated as simulation source-of-truth | Asserted-only | template guidance + review gate |
| Canonical world state is not mutated for scenarios | Asserted-only | guidance ("branch it, run against the branch, log the run") |
| High-impact / public outputs pass review before publication | Asserted-only | publication-policy review gate (Gemini Trust + Purpose) |

## Composition

The overlay composes **with** subject-matter domains and **with** other management overlays:

| Consumer scenario | Subject-matter domain | + Overlays |
|---|---|---|
| Real-estate / municipal **planning-lifecycle twin** | `domains/aec-iso19650-im` (BIM substrate) | `digital-twin` + `privacy-by-design` |
| Healthcare patient-agent twin | `domains/healthcare-fhir` | `digital-twin` + `privacy-by-design` |
| AI-datacenter ops twin | *(none yet)* | `digital-twin` + `architectures/event-driven` |
| Civic planning portal | *(none yet)* | `digital-twin` + `privacy-by-design` |
| TerraSim geospatial sim | *(future geospatial domain)* | `digital-twin` |

The **built-environment stack** — `aec-iso19650-im` × `digital-twin` × `privacy-by-design`,
governed by the Gemini Principles — is the lead scenario for the municipal + real-estate market,
and it is institutionally coherent (CDBB authored both the Gemini Principles and the UK ISO 19650
transition). The **`eval-gated-testing` overlay** is flagged as the epistemic-discipline sibling.
Phase 2 ships a `digital-twin-prototype.yaml` sample (existing modules only).

## Two-phase governance mapping

- **PR #1 (this design, §9 design-only):** OPP + ADR + PRD (with §10 block; the ADR carries the
  overlay-vs-domain decision + the staged epistemic-category) + the four propagation satisfiers
  (candidates token, README index rows, shared-observations distillation entry, change-log).
  **Artifact numbers (OPP/ADR/PRD) allocated at plan-execution against current `main`**, not at
  design time (lesson from PR #110 — parallel PRs claim numbers).
- **PR #2 (implementation):** `management/digital-twin/` module.yaml + README; the maturity-gated
  `platform/templates/digital-twin/` set (twin-profile, scenario-manifest-spec, data-provenance,
  model-registry, agent-registry, run-log-spec, uncertainty-policy, publication-policy,
  security-boundaries, overview-with-maturity-ladder); `validate-twin-profile.sh` +
  `validate-scenario-manifest.sh` (Half-enforced; validator chain N→N+2); `harness-digital-twin`
  skill; `digital-twin-prototype.yaml`; a family diagram; SUMMARY / README / onboarding /
  discovery-to-composition propagation; catalog-count propagation; Phase-2 distillation observation.

## Non-Goals

- No simulation, geospatial, or rendering **engine** — the harness *governs* twin projects, it does
  not run them.
- No mandated ontology; no event-sourcing mandate (append-only JSONL is the v1 default per the
  seed); no operational-control-loop framework in v1.
- **No new top-level taxonomy category** (the epistemic-discipline cluster is staged, not minted).
- No maturity-aware validator in v1 (depth-by-maturity is Asserted-only first).
- No claim of operational-twin maturity without live synchronization + operational governance.

## Open questions (resolve at planning; not blocking design)

- **Three design docs (OPP + ADR + PRD) vs folding OPP into the ADR.** Lean **all three** (the
  privacy overlay used ADR + PRD; the seed explicitly asks for OPP + ADR; PRD is the harness's
  design-contract convention).
- **An operating-principle section** (like privacy's §11) now vs deferred. Lean **defer** (the ADR
  carries the decision; a numbered §-section is maintainer-domain).
- **Exact required-field set for `validate-scenario-manifest.sh`** — the seed's Phase-11 list is a
  strong v1 basis; confirm at PRD-time.
- **Default-off confirmed** (vs privacy's default-on) — an opt-in overlay activated only by
  twin/scenario projects.
- **Sensitive-path regexes** for the twin surface (`scenarios/**`, `models/**`, `agents/**`,
  `datasets/**`, `data/**`, `simulation/**`, `public/scenarios/**`, `docs/twin/**`) — validate
  against a real consumer layout at implementation.

## Self-Review

- **Placeholder scan:** no "TBD"/"TODO"; artifact numbers intentionally deferred (OPP/ADR/PRD
  allocated at plan-execution) with the reason stated. ✓
- **Internal consistency:** placement (overlay) consistent across all sections; the dual spine,
  forcing artifact, §10 table, and composition agree; maturity ladder levels match the gated-artifact
  table. ✓
- **Scope:** one focused design (a single overlay + its design contract), Phase-2 scope enumerated
  but deferred. ✓
- **Ambiguity:** "Half-enforced" vs "Asserted-only" disambiguated per claim in the §10 table;
  "emerging vs published" standard status stated per citation. ✓
