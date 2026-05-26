<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0015 — Regulated-Compliance Module + External Test-Kit Pattern

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-24
**Last Updated:** 2026-05-25 *(scope augmented during Tula second-pass: extend the v1 surface to cover EU AI Act compliance test-kit integration and BAA-tier LLM gateway governance as two named sub-shapes of the same pattern)*
**Confidence:** medium-high

---

## Thesis

Regulated industries — healthcare (HIPAA, ONC), finance (PCI-DSS, SOX),
government (FedRAMP, FISMA), enterprise (SOC2, ISO 27001) — all share a
common operational pattern: **external compliance test kits** integrated
into the project as a gate. The kit is owned by a third party (often the
regulator or a certifying body), distributed as a runnable test suite
(commonly via Docker), and the project's CI invokes it on a defined
schedule to demonstrate conformance.

OpenEMR exemplifies the pattern with the **Inferno ONC G10 test kit**:
mounted as a git submodule at `ci/inferno/`, orchestrated via
`compose.yml`, invoked through `run.sh`. Federally mandated by the ONC
for EHR certification, owned by HL7 / ONC, never modified by OpenEMR
itself.

The harness has no module that captures this pattern. Add a coherent
three-part contribution:

1. **`domains/regulated-compliance` module** — governs external
   compliance test-kit integration. Required artifact:
   `docs/compliance/external-test-kit-integration.md` describing the
   kit's identity, vendor, version-pinning policy, invocation script,
   pass/fail criteria, and recovery posture.

2. **Compliance templates** — `templates/compliance/risk-register-healthcare.md`
   (extends the general `risk-register.md` with regulated-industry-
   specific risk categories: PHI breach, audit gap, certification
   lapse, ePrescribing controls failure) and
   `templates/compliance/external-test-kit-integration.md` (how to
   integrate an external test kit via submodule + docker, with
   examples from Inferno).

3. **`compositions/regulated-saas.yaml`** — generalized HIPAA / PCI /
   SOC2 starter, extending `production-saas` with regulated-compliance
   activated and risk-register-healthcare prefilled. Companion to
   `healthcare-full-ehr.yaml` (proposed in OPP-0013); usable
   independently for non-healthcare regulated projects.

## Origin / Evidence

- **Consumer project: OpenEMR (`https://github.com/openemr/openemr`).**
  Brownfield onboarding session 2026-05-24 produced a gap analysis at
  `docs/knowledge/harness-coverage-gap-analysis.md` § G5, G7, G20.

- **Code-level evidence in OpenEMR — `ci/inferno/`:**

  ```text
  ci/inferno/
  ├── compose.yml                          # docker-compose orchestration
  ├── inferno-files/                       # submodule: vendored config
  ├── onc-certification-g10-test-kit/      # submodule: the federal test kit
  ├── README.md
  ├── run.sh                               # invocation script
  └── test_configs/
  ```

  `.gitmodules` declares two submodules: `ci/inferno/onc-certification-g10-test-kit`
  (cloned from `https://github.com/openemr/onc-certification-g10-test-kit`)
  and `ci/inferno/inferno-files`. The G10 kit is HL7-published; OpenEMR
  consumes it without modification.

- **The pattern generalizes well beyond healthcare:**
  - **PCI-DSS scanners** (ASV scans, internal vulnerability scanning) —
    same shape: external scanner image, scheduled invocation, gated PR
  - **SOC2 evidence harnesses** — Drata, Vanta, Secureframe agents
    embedded as collectors; same pattern of "third-party gate integrated
    via container"
  - **FedRAMP OSCAL bundles** — JSON-structured compliance artifacts
    invoked through validators
  - **OWASP ZAP / DAST scanners** in regulated finance pipelines
  - **HIPAA SRA** (Security Risk Assessment) workflows

  All exhibit the same pattern: external code/data, integrated via
  submodule or pinned image, invoked through a wrapper script, gated
  by exit code.

- **The harness has no current vocabulary for this pattern.** Existing
  modules touch adjacent concerns — `delivery/production-saas` has a
  risk-register-required artifact; `architectures/api-service` covers
  external API surface — but neither models "external test kit
  integrated as a gate."

- **Risk-register extensions need a structural home.** The existing
  `templates/risk-register.md` is generic. Healthcare projects need
  a risk register that *prompts* for PHI-specific risk categories.
  A generic template doesn't help a healthcare-onboarding consumer
  identify their actual risk surface. A
  `risk-register-healthcare.md` template (or
  `risk-register-regulated.md` more broadly) extends the parent
  with domain-shaped prompts.

## Why Now

- **Pairs with the healthcare domain family (OPP-0013).** Most
  `domains/healthcare-*` sub-modules imply an external test kit
  (Inferno for ONC; ToCKit for IHE interoperability; potentially
  HAPI FHIR validator for resource conformance). Filing the
  regulated-compliance OPP alongside OPP-0013 means the healthcare
  family can be designed against a working compliance-integration
  pattern rather than having the gap re-surface mid-PRD.

- **The composition is generally useful.** `regulated-saas.yaml`
  serves more than healthcare. Financial services, government
  contractors, healthcare SaaS, regulated B2B all benefit from a
  brownfield-lite starter that activates the regulated-industry
  posture coherently. The composition is the proof-point that the
  pattern generalizes.

- **External test kits are growing, not shrinking.** Regulator-
  published containerized test suites are becoming the norm
  (Inferno is one example; HHS's various certification bundles
  follow the pattern; FDA's premarket software testing is moving
  toward containerized validation; FedRAMP's OSCAL pipeline is
  another). The harness's window to position governance around
  this pattern is the next 12–18 months.

## Risks / Open Questions

- **Where does `domains/regulated-compliance` belong relative to
  `delivery/production-saas`?** Both touch operational posture.
  `production-saas` is about *deployment shape* (real users, real
  data); `regulated-compliance` is about *governance shape* (external
  gates apply). Reasonable to have both active simultaneously; PRD
  should validate they compose cleanly.

- **Confidence is medium-high because the pattern is real but the
  shape of the module needs concrete second-instance design.** Filing
  the OPP now anchors the gap; PRD authoring should reach for at
  least one non-healthcare example (PCI-DSS scanner integration is
  the obvious candidate) to confirm the module shape isn't
  silently healthcare-only.

- **External-test-kit integration involves submodule discipline.**
  OpenEMR's `ci/inferno/` shows the submodule-update-cadence question
  (when to pull, how to test the update, what breaks). The module
  should encode submodule-pin policy as part of the integration
  contract, not leave it to the consumer.

- **Test-kit invocation may need its own CI job, not just a
  validator.** Inferno's test kit runs for tens of minutes; running
  it on every PR is impractical. The module should distinguish
  "PR-time conformance check" from "scheduled certification dress
  rehearsal" and codify that distinction in the integration
  artifact.

## Augmentations — Tula second-pass profiling (2026-05-25)

The Tula second-pass surfaced two additional sub-shapes of the
external-compliance-test-kit pattern that v1 should explicitly cover:

**(B1) BAA-tier LLM gateway governance.** Tula and Aria target
"BAA-eligible endpoints" (HIPAA Business Associate Agreement),
"multi-tenant identity, RBAC, BAA-tier LLM gateways." This is a
*compliance-gateway* primitive distinct from generic API-key
management: the gateway enforces which models the project is
permitted to route to under its BAA, logs every call for audit, and
participates in the foundry-side governance integrations Tula cites
(Microsoft Purview, Defender, Entra). Treat as a sub-shape of the
external-compliance-test-kit pattern: the BAA gateway is owned by
the foundry vendor (or a dedicated gateway service); the project
integrates against it the same way it integrates against Inferno —
declared in `docs/security/compliance-integrations.md` with a
specific configuration the validator can sanity-check.

**(B2) EU AI Act compliance test-kit integration.** Tula cites
Microsoft Foundry pairing continuous evaluation with [governance
integrations](https://devblogs.microsoft.com/foundry/achieve-end-to-end-observability-in-azure-ai-foundry/)
for **Microsoft Purview Compliance Manager**, **Credo AI**, and
**Saidot** to align evaluation plans with frameworks like the EU AI
Act. These are externally-owned test/audit kits in the same shape
as Inferno (HIPAA/ONC): vendor-owned, runnable on a schedule,
producing a conformance report. v1 should explicitly name AI Act
alongside ONC/HIPAA/PCI/FedRAMP in the regulatory-coverage examples.

Both sub-shapes preserve the original *external-owned, project-
integrated, schedule-invoked* pattern; neither requires a new
top-level module. PRD-pass should confirm both fit naturally into
v1's required artifacts (likely as named entries in
`docs/security/compliance-integrations.md` with sub-templates for
the BAA-gateway-config and the AI-Act-evaluation-mapping shapes).

This augmentation pairs with the Tula second-pass anchor
[OPP-0027](OPP-0027-frontier-agent-posture.md) and its satellites —
specifically [OPP-0030](OPP-0030-intelligent-model-routing.md), whose
routing-table artifact is the natural place to declare BAA-tier
routing preferences. Composition: a healthcare project with
frontier-agent posture adopts OPP-0030 (declares routing table),
OPP-0015 (declares BAA-gateway + AI-Act integrations), and
OPP-0013/0016 (healthcare-specific). All four artifacts together
form the regulated-AI deployment posture.

## Disposition

<!-- Empty: status is proposed -->

## Promotion

<!-- Empty: not yet accepted -->

## Related

- Gap analysis source: consumer project (`openemr`) at
  `docs/knowledge/harness-coverage-gap-analysis.md` §§ G5, G7, G20
- Pairs with: [OPP-0013](OPP-0013-domain-family-healthcare-decomposed.md)
  — the healthcare family activates this module via the
  `healthcare-full-ehr.yaml` composition
- Existing parallel template: `platform/templates/risk-register.md`
  (which `risk-register-healthcare.md` will extend)
- Companion OPPs filed in the same session (OpenEMR canonization):
  [OPP-0011](OPP-0011-stack-module-php.md),
  [OPP-0012](OPP-0012-data-module-relational-sql-engine-generalization.md),
  [OPP-0013](OPP-0013-domain-family-healthcare-decomposed.md),
  [OPP-0014](OPP-0014-polyglot-companion-services.md),
  [OPP-0016](OPP-0016-specialist-healthcare-review-skills.md),
  [OPP-0017](OPP-0017-legacy-coexistence-template-family.md)
