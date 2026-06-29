---
foundries:
  - id: azure-ai-foundry
    status: roadmap
---

<!--
Copyright {{YEAR}} {{AUTHOR}} <{{AUTHOR_EMAIL}}>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of {{PROJECT_NAME}} — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

<!-- The YAML frontmatter above is the machine-checkable mirror of the prose below,
parsed by validate-foundry-target.sh (PRD-0032): one entry per targeted foundry, each
with an `id` from the enum and a `status` of `live` or `roadmap`. Keep it in sync. -->

# Foundry Targets

> Which enterprise AI foundries **{{PROJECT_NAME}}** is built to drop into, and the
> portable evidence that keeps it foundry-agnostic. Part of the
> `architectures/ai-foundry-target` overlay (PRD-0028 / OPP-0028). Pair it with
> `docs/observability/trace-contract.md` (the trace-evidence axis).

## Foundries enum

Declare each target using one of the canonical identifiers below (or the `custom`
hatch for a foundry not yet enumerated). The names track current vendor branding —
re-verify when you update this file.

| Identifier | Foundry | Notes |
|---|---|---|
| `azure-ai-foundry` | Microsoft Foundry (formerly Azure AI Foundry) | Foundry Control Plane + agent registration; kept as the stable id despite the rebrand |
| `nvidia-ai-foundry` | NVIDIA AI Foundry | NIM inference microservices, NeMo, DGX Cloud |
| `palantir-aip` | Palantir AIP / Foundry | Ontology, lineage, role-and-permission-governed data layer |
| `aws-bedrock-agentcore` | AWS Bedrock AgentCore | GA 2025-10; OTel-portable |
| `google-vertex-agent-engine` | Google Vertex AI Agent Engine | OTel-portable |
| `custom` | Any foundry not enumerated above | Name it explicitly in the per-foundry block |

## Targeted foundries (per-foundry declaration)

Declare one block per foundry **{{PROJECT_NAME}}** targets. Status is `live` (you
deploy there today) or `roadmap` (committed, not yet shipped) — be honest about which.

### <!-- TODO: foundry identifier from the enum, e.g. azure-ai-foundry -->

- **Status:** <!-- TODO: live | roadmap -->
- **Portability note:** <!-- TODO: what is foundry-specific about landing here (e.g. Foundry Control Plane registration, Purview/Entra wiring) vs. carried by the portable axes below -->
- **Foundry-specific capabilities committed to:** <!-- TODO: the integrations you land in on this foundry (control plane, observability backend, identity/audit plumbing, inference microservices, ontology binding, …) -->

<!-- TODO: repeat the block above for each additional targeted foundry. -->

## Portable evidence axes (foundry-agnostic)

These three axes are what let the same product land in any of the foundries above
without a per-foundry rewrite. For each, state what evidence substantiates it today.

### 1. OpenTelemetry GenAI trace conformance

The single strongest cross-foundry anchor — Microsoft Foundry *requires* `invoke_agent`
spans for evaluation; Bedrock AgentCore, Vertex Agent Engine, and NVIDIA NeMo are all
OTel-instrumented. Declare the trace shape in `docs/observability/trace-contract.md`
(the `architectures/agent-observability` overlay) and reference it here.

- **Evidence:** <!-- TODO: link to trace-contract.md + which conformant spans you emit (create_agent / invoke_agent / execute_tool) and the pinned semconv version -->

### 2. Portable evaluation suite

A model/framework-agnostic eval set that runs the same regardless of which foundry
hosts the model — so eval results transfer across targets.

- **Evidence:** <!-- TODO: where the eval suite lives, what it grades, and that it is not bound to any one foundry's eval harness -->

### 3. Open-protocol model-routing + interop seam

An OpenAI-compatible inference endpoint plus MCP (tools) and A2A (agent-to-agent)
support, so model and agent interop are not foundry-locked.

- **Evidence:** <!-- TODO: the routing/interop seam — OpenAI-compatible endpoint, MCP tool surface, A2A support. When architectures/intelligent-model-routing (OPP-0030) ships, capture the routing detail in docs/architecture/model-routing.md and link it here. -->

## Foundry-agnostic vs. foundry-specific split

Keep an explicit ledger of what is portable (carried by the three axes above, lands on
any target) versus what is foundry-specific (re-done per foundry). The portable column
is the product's hedge against foundry lock-in.

| Concern | Foundry-agnostic (portable) | Foundry-specific (per target) |
|---|---|---|
| Telemetry | OTel GenAI spans (trace-contract.md) | Backend wiring (App Insights, CloudWatch, …) |
| Evaluation | Portable eval suite | Foundry-native eval harness mapping |
| Model access | OpenAI-compatible endpoint + MCP/A2A | Foundry inference service binding |
| Identity / audit | <!-- TODO --> | <!-- TODO: Purview/Entra, IAM, ontology RBAC, … --> |
| <!-- TODO: add rows --> | | |

## Update policy

Treat this as the source of truth for **{{PROJECT_NAME}}**'s foundry commitments. When
you add or drop a foundry, update the per-foundry block and the split ledger in the
same change, and re-verify the enum identifiers against current vendor branding. (A
companion rule and a `validate-foundry-target.sh` enforcing that the declared evidence
exists are the `architectures/ai-foundry-target` v2 follow-up; v1 is the declared
contract.)
