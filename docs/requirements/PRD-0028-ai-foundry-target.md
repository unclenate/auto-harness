<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0028: Enterprise AI Foundry Target Awareness — `architectures/ai-foundry-target`

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-27 | **Review Cycle:** On-change

**Status:** Accepted *(design-only per § 9; the implementing PR ships the module + template)*
**Date:** 2026-06-27 (filed + accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Promoting OPP: [OPP-0028](../opportunities/OPP-0028-ai-foundry-target.md) — `proposed`; this PRD ratifies its v1. OPP-0028 flips `proposed → accepted` at implementation-merge.
- Anchor OPP: [OPP-0027](../opportunities/OPP-0027-frontier-agent-posture.md) — the frontier-agent posture umbrella this module is a satellite of.
- Sibling satellites: [OPP-0029](../opportunities/OPP-0029-agent-observability.md) (`architectures/agent-observability` — **shipped**; this module reuses its `trace-contract.md` as the portable trace-evidence axis), [OPP-0030](../opportunities/OPP-0030-intelligent-model-routing.md) (model-routing — **not built**; its `model-routing.md` is an *optional* artifact here until it ships), [OPP-0031](../opportunities/OPP-0031-agent-defense-in-depth.md).
- Sibling-module precedent: [`architectures/agent-observability`](../../platform/profiles/architectures/agent-observability/module.yaml) (PRD-0014) — the just-shipped same-family module this mirrors exactly (bare id, `type: architecture`, `stability: beta`, declarative v1, no companion rule/validator).
- Related operating-principles: § 9 (Split Design from Implementation — this PRD is the design; a separate PR implements), § 10 (the new module declares `stability` per `validate-module-stability.sh`), § 7 (Align File Boundaries with Change-Class Boundaries — model-routing is OPP-0030's change-class, kept optional here).
- Field-grounding (web-verified 2026-06-27): the foundry landscape and the `foundries` enum below were verified against the current vendor docs — Microsoft Foundry (formerly Azure AI Foundry) Control Plane + agent registration; NVIDIA NIM/NeMo/DGX; Palantir AIP/Foundry Ontology; AWS Bedrock AgentCore (GA 2025-10); Google Vertex AI Agent Engine. The names are current as of filing.

## Overview

A growing class of agent-native projects is built to drop into an **enterprise AI
foundry** — Microsoft Foundry (formerly Azure AI Foundry), NVIDIA AI Foundry,
Palantir AIP/Foundry, AWS Bedrock AgentCore, Google Vertex AI Agent Engine —
alongside the identity, audit, compliance, and observability plumbing the foundry
provides. This is a **deployment-target** dimension, distinct from `delivery/`
(*how* the project ships) and `agents/` (*which* AI runtime it uses). No
auto-harness module captures it today.

This PRD specifies a v1 **opt-in `architectures/ai-foundry-target` module** that
declares which foundries a project commits to landing in and what portable evidence
substantiates each. Like its just-shipped sibling `architectures/agent-observability`
(PRD-0014), **v1 is declarative — no companion rule, no validator** (enforcement is
the v2 follow-up). It requires:

1. **`docs/architecture/foundry-targets.md`** (new, scaffolded from a template) —
   declares, per foundry, the `foundries` identifier, whether it is a *live* or
   *roadmap* target, the per-foundry portability gradient, and the **three portable
   "foundry-agnostic" evidence axes** that cut across all of them:
   - **OpenTelemetry GenAI trace conformance** — emit conformant `create_agent` /
     `invoke_agent` / `execute_tool` spans (the single strongest cross-foundry
     anchor: Microsoft Foundry *requires* `invoke_agent` spans for evaluation;
     Bedrock AgentCore and Vertex emit OTel; NVIDIA NeMo is OTel-instrumented).
   - **Portable evaluation suite** — a model/framework-agnostic eval set.
   - **Open-protocol model-routing + interop seam** — an OpenAI-compatible
     inference endpoint plus MCP (tools) / A2A (agent-to-agent) support.
2. **`docs/observability/trace-contract.md`** — required; the trace-evidence axis,
   reusing the artifact owned by the shipped `architectures/agent-observability`
   module (the two compose naturally).
3. **`docs/architecture/model-routing.md`** — **optional** at v1. Its owning module
   (`architectures/intelligent-model-routing`, OPP-0030) is not built yet; making
   it required would block this module on unbuilt work. It becomes required-by-
   convention once OPP-0030 ships (a v2 / companion-rule concern).

The `foundries` enumeration lives **in the artifact** (`foundry-targets.md`
frontmatter / declared section), not as a `module.yaml` field — the module schema
does not carry arbitrary fields, and the consumer's declaration belongs in the
consumer's artifact. The template provides the canonical enum.

## Goals & Non-Goals

**Goals:**

- Ship `platform/profiles/architectures/ai-foundry-target/{module.yaml,README.md}` —
  `type: architecture`, `stability: beta`, `dependsOn: [kernel/base]`,
  `requiredArtifacts: [docs/architecture/foundry-targets.md, docs/observability/trace-contract.md]`,
  `optionalArtifacts: [docs/architecture/model-routing.md]`, **no companion rules in v1**,
  `validators: [validate-required-artifacts, validate-companions]`.
- Ship a `foundry-targets.md` template (placement per the concern-named template-subdir
  convention — resolved at implementation) declaring: the `foundries` enum, a
  live-vs-roadmap status per foundry, a `portability` note per foundry, and the
  three portable evidence axes with a "what evidence substantiates this" prompt for each.
- The v1 `foundries` enum (web-verified, with a `custom` escape hatch):
  `azure-ai-foundry`, `nvidia-ai-foundry`, `palantir-aip`, `aws-bedrock-agentcore`,
  `google-vertex-agent-engine`, `custom`. *(The OPP's older `microsoft-ai-foundry` /
  `palantir-foundry` names are updated to the current vendor naming; `azure-ai-foundry`
  is kept as the stable identifier despite the "Microsoft Foundry" rebrand.)*
- Update `harness-onboarding` SKILL so the module is offered during onboarding for
  any project that targets an enterprise foundry, with its distinct required artifacts noted.
- Propagation: SUMMARY architectures list, root README module table + tree,
  templates/README (+ any new subdir's list-completeness row), and the catalog-count
  prose sites. **Counts recompute at implementation** against `main` (as of filing:
  `modules_profiles` 49 → 50, `modules_all` 58 → 59, `templates` 94 → 95 for the one
  new template).
- One paired distillation observation.

**Non-Goals (deferred):**

- **Companion rule + `validate-foundry-target.sh`.** v1 is declarative, like
  agent-observability. Enforcing that the declared evidence actually exists / matches
  is v2.
- **Hard-requiring `model-routing.md`.** Optional until OPP-0030 ships
  `architectures/intelligent-model-routing`.
- **Validating the `foundries` enum mechanically.** v1 documents the enum in the
  template; a validator asserting membership is v2.
- **Foundry-specific sub-postures.** Per-foundry deep governance (Palantir Ontology
  binding, Microsoft Purview/Entra wiring, the Aria multi-tenant BAA tier) is each its
  own change-class — out of scope. v1 captures the *target declaration*, not the
  per-foundry integration spec.
- **A new operating-principle section.**

## §10 Claim Classification

| Claim ID | Claim | Current | After v1 |
|----------|-------|---------|----------|
| C-FND-1 | A project can declare, in catalog-governed form, which enterprise AI foundries it targets | Asserted-only (no primitive) | **Half-enforced** — the module + required artifact exist; `validate-required-artifacts` checks the artifact is present when the module is active; the *content* (enum membership, evidence truth) is not yet checked (v2) |
| C-FND-2 | Module readiness is declared | n/a | **Enforced** — `validate-module-stability.sh` requires the new module's `stability: beta` |

**Not converted:** whether the declared foundry evidence (trace conformance, evals,
routing seam) actually holds — that is a v2 enforcement concern; v1 is the declared
contract.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001 | `architectures/ai-foundry-target` module | `module.yaml` + `README.md` present; `id: ai-foundry-target`, `type: architecture`, `version: 1.0.0`, `stability: beta`, `dependsOn: [kernel/base]`, `requiredArtifacts: [docs/architecture/foundry-targets.md, docs/observability/trace-contract.md]`, `optionalArtifacts: [docs/architecture/model-routing.md]`, `companionRules: []`. Mirrors `agent-observability`'s field set. |
| FR-002 | `foundry-targets.md` template | Tokenized header; sections: the `foundries` enum + a per-foundry block (identifier · live/roadmap · portability note), the three portable evidence axes (OTel trace conformance, portable eval suite, open-protocol routing/MCP/A2A) each with an evidence prompt, and a foundry-agnostic-vs-foundry-specific split. `<!-- TODO -->` markers; no `[[…]]`/`YYYY-MM-DD` tokens. |
| FR-003 | README | Architecture-overlay README: what the module governs, the foundry-target dimension vs `delivery/`/`agents/`, the required + optional artifacts, the compose-with-`agent-observability` note, the v2-deferred enforcement note. |
| FR-004 | Onboarding surfacing | `harness-onboarding` architectures catalog gains a row with its distinct required artifacts (`foundry-targets.md` + `trace-contract.md`, not `architecture/overview.md`). |
| FR-005 | Propagation + counts | SUMMARY, root README table + tree, templates/README (+ list-completeness row for any new template subdir). Catalog-count prose sites bumped (recompute at impl; the validator names every stale site). |
| FR-006 | `validate-module-stability` + chain green | The new module declares `stability` and the full validator chain passes. |

### Should Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-S01 | `model-routing.md` cross-reference | The template + README note that when `architectures/intelligent-model-routing` (OPP-0030) ships, `model-routing.md` moves from optional to expected. |

### Out of Scope

| Feature | Reason | Revisit |
|---------|--------|---------|
| Companion rule / `validate-foundry-target.sh` | v1 declarative | v2 follow-up |
| Hard `model-routing.md` requirement | OPP-0030 unbuilt | when OPP-0030 ships |
| Foundry-enum membership validator | v1 documents the enum | v2 |
| Per-foundry integration specs (Palantir Ontology, Purview/Entra, Aria BAA tier) | each a distinct change-class | own OPPs |

## Open Questions Resolved by This PRD

- **`foundries` enum vs free-form?** → **Enum + `custom`**, declared in the artifact
  (not module.yaml). v1 set is the five web-verified foundries + `custom`.
- **Must declared foundries be live?** → **No** — a foundry may be `live` or
  `roadmap`, with evidence appropriate to each (the template carries the status field).
- **All three artifacts required?** → **No** — `foundry-targets.md` +
  `trace-contract.md` required; `model-routing.md` optional until OPP-0030.
- **Standalone module or overlay on `agent-skill-pack`?** → **Standalone** —
  foundry-targeting is meaningful for any agent architecture, not just skill packs.
- **`architectures/` or `delivery/`?** → **`architectures/`** — it declares *what
  the product is built to drop into*, not *how it is distributed*.
- **AWS Bedrock / Vertex / watsonx in the enum?** → **Bedrock + Vertex in v1**
  (both GA, both OTel-portable); `ibm-watsonx-orchestrate` deferred to the `custom`
  hatch until field demand surfaces.

## CI/CD Gates

- Full validator chain (20 validators) green, including `validate-module-stability`
  (the new module declares `stability: beta`) and `validate-required-artifacts`
  (the harness does not activate the module, so its artifacts aren't required on the
  harness — predict-clean via inactivity).
- `validate-catalog-counts` green after the count bumps; markdownlint + (if touched)
  shellcheck clean.

## Acceptance Criteria for OPP-0028 → `accepted`

OPP-0028 flips `proposed → accepted` when FR-001…FR-006 merge and the harness's
own CI passes. (PRD-0028 Status is `Accepted` on this finalization.)

## Versioning Implications

Additive: a new opt-in architecture module + one template, no breaking change.
Lands in the next minor.
