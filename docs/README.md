<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# `docs/` — auto-harness Governance Records Index

This directory holds the **project's own self-governance records** —
ADRs, PRDs, OPPs, knowledge captures, operating principles, threat
model, audits, and the project-level change log. These are
contributor- and maintainer-targeted; **first-time users should start
at the [repository README](../README.md)**, not here.

The auto-harness project applies its own harness machinery to itself:
this is the artifact tree the kernel and management modules govern.

> **New here?** Read [`../README.md`](../README.md) first for the value
> proposition. The records in this tree are for understanding why
> decisions were made, what's planned, and how the project audits
> itself — not for evaluating whether to adopt the harness.

---

## Quick navigation

- [Architecture Decision Records](#architecture-decision-records-adrs) — what we decided and why
- [Product Requirements Documents](#product-requirements-documents-prds) — specifications for substantive new capabilities
- [Opportunity Records](#opportunity-records-opps) — pre-PRD candidates with promotion contract
- [Knowledge surfaces](#knowledge-surfaces) — observations, distilled learnings, operating principles
- [Project tracking](#project-tracking) — change log, milestones, scope plan, dependency log, revision tracker
- [Product framing](#product-framing) — problem statement, requirements, release intent, personas
- [Security & quality](#security--quality) — threat model, quality audits
- [Roadmap](roadmap.md) — what's released, what's planned, what's toward v1.0

---

## Architecture Decision Records (ADRs)

Decisions that shape how the harness works. ADRs are immutable once
Accepted; supersession is recorded by status flip + a new ADR.

| # | Title | Status |
|---|-------|--------|
| [0001](adr/ADR-0001-modular-governance.md) | Modular Governance | Accepted |
| [0002](adr/ADR-0002-knowledge-capture-structured-observations.md) | Knowledge Capture — Structured Observations | Accepted |
| [0003](adr/ADR-0003-submodule-integration.md) | Submodule Integration | Accepted |
| [0004](adr/ADR-0004-opportunity-capture-record-structure.md) | Opportunity Capture — Record Structure | Accepted |
| [0005](adr/ADR-0005-open-source-cut.md) | Open-Source Cut | Accepted |
| [0006](adr/ADR-0006-interview-driven-management.md) | Interview-Driven Management | Accepted |
| [0007](adr/ADR-0007-agentic-interface-awareness.md) | Agentic Interface Awareness | Accepted |
| [0008](adr/ADR-0008-mcp-awareness.md) | MCP Awareness | Accepted |
| [0009](adr/ADR-0009-ci-hardening.md) | CI Hardening | Accepted |
| [0010](adr/ADR-0010-cheap-satisfiers-for-routine-governance.md) | Cheap Satisfiers for Routine Governance | Accepted |
| [0011](adr/ADR-0011-markdownlint-policy.md) | Markdownlint Policy | Accepted |
| [0012](adr/ADR-0012-opportunity-capture-index-split.md) | Opportunity Capture — Index Split | Accepted |
| [0013](adr/ADR-0013-documentation-information-architecture.md) | Documentation Information Architecture | Accepted (Phases 3–4 superseded by ADR-0016) |
| [0014](adr/ADR-0014-sunset-distilled-learnings.md) | Sunset `distilled-learnings.md` | Accepted |
| [0015](adr/ADR-0015-managed-fleet-delivery-posture.md) | Add `delivery/managed-fleet` Posture | Accepted |
| [0016](adr/ADR-0016-documentation-ia-phase-3-4-target-structure.md) | Documentation IA — Phase 3–4 Target Structure | Accepted |
| [0017](adr/ADR-0017-safety-hardening-roadmap.md) | Safety Hardening Roadmap | Accepted |
| [0018](adr/ADR-0018-privacy-by-default-posture.md) | Privacy-by-Default Posture | Accepted |
| [0019](adr/ADR-0019-digital-twin-scenario-runtime-overlay.md) | Adopt Digital Twin / Scenario Runtime as a Management Overlay | Accepted |

---

## Product Requirements Documents (PRDs)

Specifications for substantive new capabilities, paired with their
originating opportunity records.

| # | Title | Status | OPP |
|---|-------|--------|-----|
| [0001](requirements/PRD-0001-restore-prd-support.md) | Restore PRD Support | Accepted | — |
| [0002](requirements/PRD-0002-extend-prd-template-execution-sections.md) | Extend PRD Template Execution Sections | Accepted | — |
| [0003](requirements/PRD-0003-opportunity-capture-module.md) | Opportunity Capture Module | Accepted | — |
| [0004](requirements/PRD-0004-distillation-triggers.md) | Distillation Triggers | Accepted | [OPP-0004](opportunities/OPP-0004-distillation-triggers.md) |
| [0005](requirements/PRD-0005-consumer-header-hygiene.md) | Consumer Header Hygiene | Accepted | [OPP-0005](opportunities/OPP-0005-consumer-header-hygiene.md) |
| [0006](requirements/PRD-0006-trust-tier-enforcement.md) | Trust-Tier Enforcement | Accepted | [OPP-0006](opportunities/OPP-0006-trust-tier-enforcement.md) |
| [0007](requirements/PRD-0007-canonical-position-artifact.md) | Canonical-Position Artifact | Proposed | [OPP-0007](opportunities/OPP-0007-canonical-position-artifact.md) |
| [0008](requirements/PRD-0008-agent-skill-pack-architecture.md) | Agent Skill-Pack Architecture | Accepted | [OPP-0018](opportunities/OPP-0018-architecture-eval-gated-skill-pack.md) |
| [0009](requirements/PRD-0009-eval-gated-testing-module.md) | Eval-Gated Testing Module | Accepted | [OPP-0019](opportunities/OPP-0019-eval-gated-testing-posture.md) |
| [0010](requirements/PRD-0010-self-hosted-oss-delivery.md) | Self-Hosted OSS Delivery | Accepted | [OPP-0021](opportunities/OPP-0021-delivery-self-hosted-oss.md) |
| [0011](requirements/PRD-0011-distilled-learnings-disposition.md) | Sunset `distilled-learnings.md` | Accepted | [OPP-0026](opportunities/OPP-0026-distilled-learnings-disposition.md) |
| [0012](requirements/PRD-0012-doc-references-consumer-aware.md) | `validate-doc-references` Consumer-Aware Scan | Accepted | [OPP-0023](opportunities/OPP-0023-doc-references-consumer-scan.md) |
| [0013](requirements/PRD-0013-session-cycle-orchestration.md) | Session-Cycle Orchestration and Review-Trigger Taxonomy | Accepted | [OPP-0032](opportunities/OPP-0032-session-cycle-orchestration.md) |
| [0014](requirements/PRD-0014-agent-observability.md) | Agent Observability with OpenTelemetry Semantic Conventions | Proposed | [OPP-0029](opportunities/OPP-0029-agent-observability.md) |
| [0015](requirements/PRD-0015-validate-skill-content.md) | Skill Content Safety Validator (`validate-skill-content.sh`) | Accepted | [OPP-0033](opportunities/OPP-0033-validate-skill-content.md) |
| [0016](requirements/PRD-0016-security-static-analysis-module.md) | Security Static Analysis Module (`management/security-static-analysis`) | Accepted | [OPP-0035](opportunities/OPP-0035-security-static-analysis.md) |
| [0017](requirements/PRD-0017-healthcare-fhir-smart-wedge.md) | Healthcare FHIR + SMART-on-FHIR Wedge | Accepted | [OPP-0013](opportunities/OPP-0013-domain-family-healthcare-decomposed.md) |
| [0018](requirements/PRD-0018-privacy-by-design.md) | Privacy-by-Design Module (`management/privacy-by-design`) | Accepted | — |
| [0019](requirements/PRD-0019-aec-iso19650-openbim-wedge.md) | AEC ISO 19650 + openBIM Wedge | Accepted | [OPP-0039](opportunities/OPP-0039-domain-family-aec-decomposed.md) |
| [0020](requirements/PRD-0020-bootstrap-hardening-guards-and-preflight.md) | Bootstrap Hardening — Instantiation-Boundary Guards + Dependency Preflight | Accepted | [OPP-0041](opportunities/OPP-0041-onboarding-containment-safety.md), [OPP-0040](opportunities/OPP-0040-cross-platform-install-prerequisites.md) |
| [0021](requirements/PRD-0021-greenfield-onboarding-conservatism.md) | Greenfield Onboarding Conservatism — Route Contextless Greenfield to Discovery | Accepted | [OPP-0042](opportunities/OPP-0042-greenfield-onboarding-conservatism.md) |
| [0022](requirements/PRD-0022-cybersec-osint-maltego-wedge.md) | Cybersecurity OSINT / Maltego Wedge | Proposed | [OPP-0043](opportunities/OPP-0043-domain-family-cybersecurity-decomposed.md) |
| [0023](requirements/PRD-0023-digital-twin-scenario-runtime-overlay.md) | Digital Twin / Scenario Runtime Overlay | Accepted | [OPP-0044](opportunities/OPP-0044-digital-twin-scenario-runtime.md) |
| [0024](requirements/PRD-0024-geospatial-gis-wedge.md) | Geospatial / GIS Wedge (CRS + OGC exchange + BIM↔GIS georeferencing) | Accepted | [OPP-0045](opportunities/OPP-0045-domain-family-geospatial-decomposed.md) |
| [0025](requirements/PRD-0025-work-package-lane-contract.md) | Work-Package Lane Contract (`management/work-package`) | Accepted | [OPP-0046](opportunities/OPP-0046-parallel-multi-agent-work-package-lane-contract.md) |

---

## Opportunity Records (OPPs)

Forward-looking pre-PRD candidates managed by the
`opportunity-capture` module. See
[`opportunities/candidates.md`](opportunities/candidates.md) for the
clustered backlog with framing.

| # | Title | Status |
|---|-------|--------|
| [0001](opportunities/OPP-0001-exportable-governance-contract-for-runtime-harnesses.md) | Exportable Governance Contract for Runtime Harnesses | proposed |
| [0002](opportunities/OPP-0002-agentic-interface-awareness.md) | Agentic Interface Awareness | accepted |
| [0003](opportunities/OPP-0003-mcp-producer-and-exportable-governance-via-mcp.md) | MCP Producer and Exportable Governance via MCP | accepted |
| [0004](opportunities/OPP-0004-distillation-triggers.md) | Distillation Triggers | accepted |
| [0005](opportunities/OPP-0005-consumer-header-hygiene.md) | Consumer Header Hygiene | accepted |
| [0006](opportunities/OPP-0006-trust-tier-enforcement.md) | Trust-Tier Enforcement | accepted |
| [0007](opportunities/OPP-0007-canonical-position-artifact.md) | Canonical-Position Artifact | exploring |
| [0008](opportunities/OPP-0008-stack-module-node-javascript-and-coffeescript.md) | Stack Module — Node-JavaScript + CoffeeScript | accepted |
| [0009](opportunities/OPP-0009-data-module-embedded-key-value.md) | Data Module — Embedded Key-Value | accepted |
| [0010](opportunities/OPP-0010-domain-module-cryptographic-identity.md) | Domain Module — Cryptographic Identity | accepted |
| [0011](opportunities/OPP-0011-stack-module-php.md) | Stack Module — PHP | proposed |
| [0012](opportunities/OPP-0012-data-module-relational-sql-engine-generalization.md) | Data Module — Relational SQL Engine Generalization | proposed |
| [0013](opportunities/OPP-0013-domain-family-healthcare-decomposed.md) | Domain Family — Healthcare Decomposed | accepted (partial promotion) |
| [0014](opportunities/OPP-0014-polyglot-companion-services.md) | Polyglot Companion Services | proposed |
| [0015](opportunities/OPP-0015-regulated-compliance-test-kits.md) | Regulated Compliance + External Test Kits | proposed |
| [0016](opportunities/OPP-0016-specialist-healthcare-review-skills.md) | Specialist Healthcare Review Skills | proposed |
| [0017](opportunities/OPP-0017-legacy-coexistence-template-family.md) | Legacy Coexistence Template Family | proposed |
| [0018](opportunities/OPP-0018-architecture-eval-gated-skill-pack.md) | Authored Eval-Gated Agent Skill-Pack (Tula) | accepted |
| [0019](opportunities/OPP-0019-eval-gated-testing-posture.md) | Binary-Eval Testing Posture (Tula) | accepted |
| [0020](opportunities/OPP-0020-evaluation-tooling-in-harness-toolchain.md) | Evaluation & Safety Tooling in Toolchain (Tula) | proposed |
| [0021](opportunities/OPP-0021-delivery-self-hosted-oss.md) | Delivery — Self-Hosted OSS (Tula) | accepted |
| [0022](opportunities/OPP-0022-patient-facing-health-agent-safety.md) | Patient-Facing Health-Agent Safety (Tula) | proposed |
| [0023](opportunities/OPP-0023-doc-references-consumer-scan.md) | `validate-doc-references` Consumer-Aware Scan | accepted |
| [0025](opportunities/OPP-0025-consumer-integration-smoke-test.md) | Consumer-Side Integration Smoke Test | proposed |
| [0026](opportunities/OPP-0026-distilled-learnings-disposition.md) | `distilled-learnings.md` Disposition (Sunset/Revive/Clarify) | accepted |
| [0027](opportunities/OPP-0027-frontier-agent-posture.md) | Frontier-Agent Posture (Management Overlay; Cluster Anchor) | proposed |
| [0028](opportunities/OPP-0028-ai-foundry-target.md) | Enterprise AI Foundry Target Awareness | proposed |
| [0029](opportunities/OPP-0029-agent-observability.md) | Agent Observability with OpenTelemetry Semantic Conventions | exploring |
| [0030](opportunities/OPP-0030-intelligent-model-routing.md) | Intelligent Model Routing as Architectural Primitive | proposed |
| [0031](opportunities/OPP-0031-agent-defense-in-depth.md) | Agent Defense-in-Depth (Microsoft's Four Patterns) | proposed |
| [0032](opportunities/OPP-0032-session-cycle-orchestration.md) | Session-Cycle Orchestration and Review-Trigger Taxonomy | accepted |
| [0033](opportunities/OPP-0033-validate-skill-content.md) | Content-Safety Validator (`validate-skill-content.sh`) | accepted |
| [0034](opportunities/OPP-0034-validate-sensitive-paths.md) | Sensitive-Paths Overlap Validator (`validate-sensitive-paths.sh`) | accepted |
| [0035](opportunities/OPP-0035-security-static-analysis.md) | Security Static Analysis Module (`management/security-static-analysis`) | accepted |
| [0036](opportunities/OPP-0036-validate-knowledge-redaction.md) | Knowledge-Redaction Validator + CODEOWNERS | accepted |
| [0037](opportunities/OPP-0037-classify-before-enforcing-as-operating-principle.md) | Classify-Before-Enforcing as Operating Principle | accepted |
| [0038](opportunities/OPP-0038-adopter-artifact-attribution-boundary.md) | Adopter Artifact Attribution: Signing Governance Without Asserting Rights | proposed |
| [0039](opportunities/OPP-0039-domain-family-aec-decomposed.md) | AEC Domain Family (decomposed) | accepted (partial promotion) |
| [0040](opportunities/OPP-0040-cross-platform-install-prerequisites.md) | Cross-Platform Install Prerequisites: Surface and Preflight Them at First Contact | accepted |
| [0041](opportunities/OPP-0041-onboarding-containment-safety.md) | Onboarding Containment Safety: Never Instantiate or Commit a Consumer Inside the Platform Repo | accepted |
| [0042](opportunities/OPP-0042-greenfield-onboarding-conservatism.md) | Greenfield Onboarding Conservatism: Route Contextless Greenfield to Discovery | accepted |
| [0043](opportunities/OPP-0043-domain-family-cybersecurity-decomposed.md) | Cybersecurity Domain Family (decomposed) | accepted (partial promotion) |
| [0044](opportunities/OPP-0044-digital-twin-scenario-runtime.md) | Digital Twin / Scenario Runtime Governance Overlay | accepted |
| [0045](opportunities/OPP-0045-domain-family-geospatial-decomposed.md) | Geospatial / GIS Domain Family (decomposed) | accepted |
| [0046](opportunities/OPP-0046-parallel-multi-agent-work-package-lane-contract.md) | Parallel Multi-Agent Work-Package Lane Contract | accepted (partial promotion) |
| [0047](opportunities/OPP-0047-delivery-cost-unit-economics-governance.md) | Delivery-Cost & Unit-Economics Governance | proposed |
| [0048](opportunities/OPP-0048-redaction-scope-and-publication-boundary-hardening.md) | Redaction-Scope & Publication-Boundary Hardening | proposed |
| [0049](opportunities/OPP-0049-deep-governance-vertical-harvest.md) | Deep Governance Vertical: Authoring-Pattern Harvest | proposed |

---

## Knowledge surfaces

- [`knowledge/shared-observations.md`](knowledge/shared-observations.md) —
  append-only severity-tagged observations from project participants
- [`knowledge/distilled-learnings.md`](knowledge/distilled-learnings.md) —
  curated longitudinal synthesis (heavyweight; review-required)
- [`operating-principles.md`](operating-principles.md) — durable how-this-
  project-works truths derived from observations

---

## Project tracking

- [`project/change-log.md`](project/change-log.md) — per-decision audit
  log (different from the externally-visible `CHANGELOG.md` at repo
  root, which covers releases)
- [`project/milestones.md`](project/milestones.md)
- [`project/scope-plan.md`](project/scope-plan.md)
- [`project/dependency-log.md`](project/dependency-log.md)
- [`project/revision-tracker.md`](project/revision-tracker.md)
- [`project/implementation-log-submodule.md`](project/implementation-log-submodule.md)

---

## Product framing

- [`product/problem-statement.md`](product/problem-statement.md)
- [`product/requirements.md`](product/requirements.md)
- [`product/release-intent.md`](product/release-intent.md)

---

## Security & quality

- [`../SECURITY.md`](../SECURITY.md) — disclosure process and supported versions
- [`threat-model.md`](threat-model.md) — adversary models, attack surfaces, mitigations
- [`QUALITY-AUDIT-2026-05-18.md`](QUALITY-AUDIT-2026-05-18.md) — quality-audit 5-lane pass (Wave 1 onboarding readiness)
- [`QUALITY-AUDIT-2026-05-24-documentation.md`](QUALITY-AUDIT-2026-05-24-documentation.md) — documentation-IA audit + 5-phase improvement plan (drives ADR-0013)
- [`QUALITY-AUDIT-2026-05-25-documentation-refresh.md`](QUALITY-AUDIT-2026-05-25-documentation-refresh.md) — Refresh #1: confirms Phase 0+1 closed; merges still-open 2026-05-18 findings; surfaces list-completeness drift class (M-j)
- [`standards/kpi-dictionary.md`](standards/kpi-dictionary.md) — review cadence and quality metrics

---

## How the records cross-reference each other

Most ADRs cite their originating PRD (when one exists). Most PRDs cite
their originating OPP. Most OPPs cite the observations that motivated
them. Reading order for understanding *why* a feature exists:

```text
Observation (insight, severity-tagged)
     │
     ▼
OPP (gap captured, options enumerated, status proposed)
     │  Disposition flipped — exploring
     ▼
PRD (specification, FRs, scope decisions, acceptance criteria)
     │  Status flipped — Accepted
     ▼
ADR (decision recorded, alternatives explained, consequences known)
     │
     ▼
Implementation (the actual code/doc change)
```

See [Diagram 4 — Opportunity → PRD → ADR Lifecycle](architecture/diagrams.md#4-opportunity--prd--adr-lifecycle) and [Diagram 8 — OPP → PRD Design-Pressure Cascade](architecture/diagrams.md#8-opp--prd-design-pressure-cascade) for the visual references.

---

## When to add a new record

- **Observation** when you notice something worth keeping (severity:
  architectural / process / informational / security)
- **OPP** when an observation has crystallized into a candidate
  capability worth scoping
- **PRD** when an OPP has been promoted to `exploring` and the design
  space is ready to commit
- **ADR** when a substantive decision has been made (typically as part
  of PRD acceptance, sometimes standalone)

See [`platform/workflow/extending-the-harness.md`](../platform/workflow/extending-the-harness.md) § Submitting Your Contribution for the OPP→PRD→ADR cadence the project follows.
