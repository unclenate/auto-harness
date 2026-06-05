<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0039 — AEC Domain Family (decomposed `domains/aec-*`)

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-06-04
**Last Updated:** 2026-06-04 *(accepted — partial promotion: iso19650-im + openbim-exchange + iso19650-5-security promoted to a v1 wedge via PRD-0019; the deferred sub-modules remain proposed within this OPP; see Disposition)*
**Confidence:** high

---

## Thesis

The harness has no `domains/aec-*` (Architecture / Engineering / Construction)
coverage. AEC is one of the largest information-governed industries — the built
environment runs on ISO 19650 information management, openBIM (IFC/BCF/IDS)
exchange, and (for critical assets) ISO 19650-5 security-minded handling. It is
the **explicit second built deep-domain vertical** the framework harvest requires
after healthcare: a second independent instance of the jurisdiction-neutral-core +
forcing-artifact + bias-guardrail + trust-role primitives, plus two enrichments a
single domain could not surface — a **compound** forcing artifact and a **domain ×
cross-cutting composition**.

Apply the harness's per-concern module granularity (as healthcare did) and ship
AEC as a **decomposed family**. This OPP ratifies the family shape; PRD-0019
promotes the thin three-module wedge.

### Sub-modules (each per-activation, each with its own required artifacts)

| Sub-module | What it governs | Required artifact(s) | Disposition |
|---|---|---|---|
| `domains/aec-iso19650-im` | CDE structure, information-container status codes (S0–S7), the appointing/lead-appointed/appointed-party actor model, status-transition policy | `information-management-plan.md`, `jurisdiction-profile.md` | **Wedge (PRD-0019)** |
| `domains/aec-openbim-exchange` | IDS-style exchange requirements, the pinned IFC version, the producer/receiver/reviewer role axis (ISO 19650-4) | `exchange-requirements.md` | **Wedge (PRD-0019)** |
| `domains/aec-iso19650-5-security` | Security-minded sensitivity assessment + security-management plan for built-asset / infrastructure sensitivity | `sensitivity-assessment.md`, `security-management-plan.md` | **Wedge (PRD-0019)** |
| `domains/aec-aps-tooling` | Autodesk Platform Services / Revit OAuth scopes, Design-Automation elevated-automation tier | `aps-scope-map.md` (proposed) | Deferred |
| `domains/aec-bluebeam-review` | Bluebeam Studio Sessions / markup review surface | `review-session-policy.md` (proposed) | Deferred |
| `domains/aec-permitting-ahj` | Permit-set governance + AHJ-as-review-role (extracted from the jurisdiction-profile field) | `permit-set-map.md` (proposed) | Deferred |

### Templates

A new `platform/templates/aec/` directory. Five wedge templates ship with
PRD-0019; deferred sub-modules add their own when promoted.

### Convenience composition

A `platform/compositions/aec-bim-project.yaml` starter that activates the
three wedge modules together (plus `management/privacy-by-design` for occupant
personal data — the first domain × cross-cutting composition in the catalog).

## Origin / Evidence

- **Research brief:** `docs/superpowers/specs/2026-06-03-construction-bim-research-brief.md`
  (committed alongside this OPP) — cites ISO 19650 parts 1–6, the UK National
  Annex / BS EN, openBIM (IFC4 / IFC4.3, BCF, IDS, COBie), Autodesk Platform
  Services, and Bluebeam Studio. The wedge boundary is lifted from its
  substrate / access-layer / security-spine analysis.
- **Design spec:** `docs/superpowers/specs/2026-06-03-aec-construction-wedge-design.md`
  — the user-confirmed three-module wedge, the compound jurisdiction-profile,
  and the security × privacy composition boundary.
- **Structural analog (grounding, not speculation).** The wedge mirrors the
  proven healthcare shape one-to-one: `aec-iso19650-im` ≈ `healthcare-fhir`
  (substrate); `aec-openbim-exchange` ≈ `healthcare-smart-on-fhir` (access
  layer carrying the trust-role axis); `aec-iso19650-5-security` is the
  sensitivity spine (the PHI-handling analog). The intra-family dependency
  (`openbim-exchange → iso19650-im`) is the same pattern as
  `smart-on-fhir → fhir` and `supabase → relational-postgres`.
- **Internal precedent for module granularity.** As with `delivery/` and the
  `healthcare-*` family, a consumer doing IFC-exchange-only work does not need
  the security-management plan; bundling would force irrelevant required-artifact
  debt. The decomposition matches observable subsystem boundaries in real AEC
  delivery (CDE / model-exchange / security are distinct ISO 19650 concerns).

## Why Now

- **The harvest needs a second built domain.** Healthcare alone cannot ground a
  general "deep-domain framework" operating-principle. AEC is the designated
  second vertical; once it ships, the three primitives have three independent
  reuse instances (healthcare domain, privacy cross-cutting, AEC domain) and two
  new enrichments (compound forcing artifact; domain × cross-cutting composition),
  which is the evidence bar the design spec set for promotion.
- **AEC is a large, standards-rich, governance-shaped industry.** ISO 19650,
  IFC/BCF/IDS, and ISO 19650-5 are well-defined international standards with
  jurisdictional national annexes — exactly the neutral-core + forcing-artifact
  shape the harness governs well.
- **Security × privacy is a real, unmodeled boundary.** A built-asset model can
  reveal how to attack a building; occupant data is personal data. The catalog
  has `management/privacy-by-design` (shipped #98) but no asset-sensitivity
  counterpart, and no documented boundary between them. The wedge produces both.

## Risks / Open Questions

- **UK / BS EN over-documentation bias (cross-cutting, architectural).** The
  most heavily documented ISO 19650 path is the UK National Annex + Uniclass +
  BS EN mandate. There is a real risk of baking UK norms into module shapes as
  if universal. **Required before freezing any artifact:** the
  `jurisdiction-profile.md` template default-denies the UK path and forces an
  explicit `{National Annex} × {AHJ + code edition} × {classification system}`
  declaration. See the AEC-bias observation slated for `shared-observations.md`.
- **AHJ as field vs module.** The Authority Having Jurisdiction is recorded as a
  jurisdiction-profile *field* in the wedge; a dedicated `aec-permitting-ahj`
  module (permit-set governance + AHJ-as-review-role) is deferred until a
  grounded consumer surfaces permit-set workflows.
- **Tooling modules deferred.** `aec-aps-tooling` (Autodesk Platform Services)
  and `aec-bluebeam-review` are vendor-SDK surfaces; the wedge governs the
  standards/exchange/security layer, not vendor APIs. Verify-at-implementation
  flags carried from the brief (not wedge-blocking): current COBie version /
  NBIMS-US V4 COBie centrality; Bluebeam dev-API auth model + regional gating.
- **No grounded consumer codebase yet.** Unlike healthcare (OpenEMR + Tula), the
  AEC wedge is grounded in standards + the research brief, not a brownfield
  onboarding. Initial bias: ship the standards-anchored wedge; refine
  sensitive-path regexes against a real AEC repo when one onboards.

## Disposition

**Accepted 2026-06-04 — partial promotion.** The three wedge sub-modules —
`domains/aec-iso19650-im`, `domains/aec-openbim-exchange`, and
`domains/aec-iso19650-5-security` — are promoted to a v1 wedge (see PRD-0019).
The deferred sub-modules (`aec-aps-tooling`, `aec-bluebeam-review`,
`aec-permitting-ahj`) stay `proposed` pending consumer demand.

## Promotion

Promoted sub-modules: `domains/aec-iso19650-im`, `domains/aec-openbim-exchange`,
`domains/aec-iso19650-5-security` (PRD-0019, 2026-06-04). The compound
jurisdiction-profile and the domain × cross-cutting (security × privacy)
composition are the two enrichments slated for the deep-domain framework harvest
(a separate later cycle; see `project-deep-industry-domains` memory).

## Related

- Predecessor vertical (first built domain): [OPP-0013](OPP-0013-domain-family-healthcare-decomposed.md)
- Cross-cutting reused by the security spine: `management/privacy-by-design` (PRD-0018, shipped)
- Design spec: `docs/superpowers/specs/2026-06-03-aec-construction-wedge-design.md`
- Research brief: `docs/superpowers/specs/2026-06-03-construction-bim-research-brief.md`
- Wedge design contract: [PRD-0019](../requirements/PRD-0019-aec-iso19650-openbim-wedge.md)
