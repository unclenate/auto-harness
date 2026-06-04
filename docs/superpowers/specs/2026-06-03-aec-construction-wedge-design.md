<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Design — AEC / Construction Deep-Domain Wedge (ISO 19650 + openBIM + security)

**Status:** Draft (brainstorming output, pending user review)
**Author:** @unclenate
**Date:** 2026-06-03
**Discovery evidence:** `docs/superpowers/specs/2026-06-03-construction-bim-research-brief.md`

---

## Purpose

Establish the **second built deep-industry-domain vertical** — Architecture / Engineering /
Construction (AEC) — using the reusable framework proven by healthcare. AEC both delivers
real governance value and is the **explicit second vertical the framework harvest requires**
(after which the deep-domain primitives can be promoted to a general operating-principle).

Concrete-first: build a thin **3-module wedge**, not the full 6-module family.

## Settled decisions (user-confirmed)

1. **Family prefix: `domains/aec-*`** — broader than "construction", future-proofs for
   horizontal infrastructure (IFC4.3 rail/road/bridge) and engineering sub-modules.
2. **Three-module wedge** — substrate + access layer + security spine.

## The wedge — three modules

| Module | ≈ Healthcare analog | `dependsOn` | Required artifacts |
|---|---|---|---|
| **`aec-iso19650-im`** | `healthcare-fhir` (substrate) | `kernel/base` | `information-management-plan.md`, `jurisdiction-profile.md` |
| **`aec-openbim-exchange`** | `healthcare-smart-on-fhir` (access layer; role axis) | `kernel/base`, `aec-iso19650-im` | `exchange-requirements.md` |
| **`aec-iso19650-5-security`** | (the PHI/sensitivity spine) | `kernel/base`, `aec-iso19650-im` | `sensitivity-assessment.md`, `security-management-plan.md` |

### `aec-iso19650-im` (the substrate)
- `information-management-plan.md` — CDE structure, container **status codes** (ISO 19650
  S0–S7: WIP → shared → published → archived), the actor model (appointing / lead-appointed /
  appointed party), and the status-transition policy (who may promote a container).
- `jurisdiction-profile.md` — the **compound** forcing artifact (below).
- Sensitive paths: CDE/container surfaces (`^cde/`, `^containers/`, `models`, BEP/MIDP paths).
- Companion rules: CDE-structure or status-transition-policy change → IM-plan update or ADR;
  `jurisdiction-profile.md` change → change-log or ADR.
- Review gate: promoting a container to **Published / As-Built** requires human sign-off (a
  published container is contractually binding).

### `aec-openbim-exchange` (the access/interop layer — where the role axis lives)
- `exchange-requirements.md` — IDS-style: which IFC entities / classifications / properties
  must be present; the **pinned IFC version** (an *enforced* field, given the IFC4.3 /
  4x3-ADD2 tool-support fragmentation); and the **producer / receiver / reviewer role axis**
  (ISO 19650-4 exchange roles) — who produces which container, who receives, who reviews. This
  is the exact SMART-scope-map analog (provider-launch / patient-access → producer / receiver
  / reviewer); `aec-iso19650-im`'s CDE permissions *reference* it.
- Sensitive paths: exchange/IFC surfaces (`^ifc/`, `^exchange/`, `bcf`, `federation`).
- Review gate: changing the pinned IFC version or widening an exchange grant = sign-off.

### `aec-iso19650-5-security` (the sensitivity spine)
- `sensitivity-assessment.md` (identify/classify sensitive info) + `security-management-plan.md`
  (redaction, RBAC, secure-federation, monitoring/audit) — per BS EN ISO 19650-5:2020.
- Sensitive drivers: critical infrastructure, building occupants, embedded security systems.
- Review gate: declassification, broadening access to sensitive containers, or redaction-policy
  changes = sign-off.

## The compound jurisdiction-profile (forcing artifact + bias guardrail)

`jurisdiction-profile.md` = **`{ISO 19650 National Annex} × {AHJ + code edition} ×
{classification system}`** — three axes (vs healthcare's single jurisdiction). Examples:
UK NA → Uniclass 2015 + BS EN mandate; US → no universal mandate, NBIMS-US + local AHJ +
(often) MasterFormat / OmniClass / UniFormat.

> **Bias guardrail.** Default-deny any assumption of the over-documented "UK BS EN ISO 19650
> + Uniclass" path. The module forces an explicit National-Annex / AHJ / classification
> declaration — the over-documentation of the UK path is itself the bias risk to guard against.

The **AHJ** is recorded as a jurisdiction-profile *field* in this wedge; the dedicated
`aec-permitting-ahj` module (permit-set governance + AHJ-as-review-role) is **deferred**.

## Security × privacy composition (a deliberate, documented boundary)

This wedge produces the catalog's **first domain × cross-cutting composition**:
- `aec-iso19650-5-security` governs **built-asset / infrastructure sensitivity** (the model
  reveals how to attack a building or utility).
- `management/privacy-by-design` (shipped #98) governs **personal-data privacy** (occupant PII).
- A real AEC project with occupant data activates **both**; the `sensitivity-assessment`
  references the `privacy-profile`'s declared legal regime. The spec documents the boundary so
  the two don't overlap or leave a gap.

## Templates

New `platform/templates/aec/` with five artifacts: `information-management-plan.md`,
`jurisdiction-profile.md` (carries the bias guardrail), `exchange-requirements.md`,
`sensitivity-assessment.md`, `security-management-plan.md`.

## Resolved open questions (from the research brief)

- **openBIM = one module** (IDS is the conformance contract *for* IFC exchange — one concern).
- **Role axis lives in `aec-openbim-exchange`** (documented once; referenced by `iso19650-im`).
- **AHJ = a jurisdiction-profile field now**, a dedicated `aec-permitting-ahj` module later.
- **IFC version pinning = enforced** in `exchange-requirements.md`.
- **Deferred modules:** `aec-aps-tooling` (Autodesk Platform Services / Revit OAuth scopes,
  Design-Automation elevated-automation tier), `aec-bluebeam-review` (Studio Sessions / markup),
  `aec-permitting-ahj`.
- **Verify-at-implementation flags** (carried from the brief, not wedge-blocking): current
  COBie version / NBIMS-US V4 COBie centrality; Bluebeam dev-API auth model + regional gating.

## Harvest tie-in (the strategic payoff)

Construction is the **second built domain** the harvest plan required. After it ships, the
three primitives have three independent reuse instances — healthcare (domain), privacy
(cross-cutting), construction (domain) — and construction adds two enrichments: a **compound**
forcing artifact (3 axes) and the **domain × cross-cutting composition**. This grounds a
**separate later cycle**: promote "neutral-core + forcing-artifact + bias-guardrail +
(optional) trust-role-axis" into an **operating-principle + ADR** as a general governance
primitive, and generalize the templates into a domain-neutral starter. The harvest is NOT part
of this wedge. See `project-deep-industry-domains` (memory).

## Governance mapping + sequencing (two phases, mirrors healthcare/privacy)

- **Phase 1 (design-only PR):** an **OPP** (the AEC deep-domain family opportunity, analog of
  OPP-0013; next is OPP-0038) + a **PRD** (the 3-module wedge design contract, with a §10 Claim
  Classification block; next is PRD-0019) — both citing the research brief as discovery evidence.
- **Phase 2 (implementation PR):** the 3 modules + 5 templates + discoverability (SUMMARY,
  README, onboarding skill, discovery-to-composition Step 6) + a family diagram + a sample
  composition + catalog-count propagation.

## Non-Goals

- Not the full 6-module AEC family (the 3 deferred modules are later cycles).
- Not a Revit/Bluebeam integration (the tooling modules are deferred; this wedge governs the
  standards/exchange/security layer, not vendor SDKs).
- Not the framework harvest itself (separate later cycle).

## Open questions (resolve at planning; not blocking design)

- Exact `sensitivePaths` regexes (validate against a real AEC repo at implementation).
- Whether `aec-iso19650-5-security` should `dependsOn` (or merely *compose with*)
  `management/privacy-by-design` — likely compose-with (no hard dependency), documented in both.
- OPP vs PRD-only: whether the AEC family warrants a full OPP or the research brief + a PRD
  suffices (lean OPP, given it's a 6-module family with a deferred roadmap).
