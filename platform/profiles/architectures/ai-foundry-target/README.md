<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Architecture Overlay: AI Foundry Target

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay governs how an agent-native project declares **which enterprise AI
foundries it is built to drop into** — and what portable evidence substantiates each.
A growing class of projects ship explicitly to land in Microsoft Foundry (formerly
Azure AI Foundry), NVIDIA AI Foundry, Palantir AIP/Foundry, AWS Bedrock AgentCore, or
Google Vertex AI Agent Engine, alongside the identity, audit, compliance, and
observability plumbing the foundry already provides. This overlay makes that
deployment-target commitment a first-class, reviewable artifact.

**This is a deployment-target dimension, distinct from two it is often confused with:**

- `delivery/*` captures *how* the project ships (prototype / production-saas /
  self-hosted-oss / internal-platform).
- `agents/*` captures *which AI runtime* the project uses.
- This overlay captures *what the product is built to drop into* — the foundry it
  targets and the portable evidence that keeps it foundry-agnostic.

It is **opt-in** (add `ai-foundry-target` to your `harness.manifest.yaml`) and
composes with any `agents/*` pack and with `architectures/agent-observability`.
auto-harness itself does not activate it.

---

## What this overlay requires

- **`docs/architecture/foundry-targets.md`** (required, scaffolded from the
  [foundry-targets](../../../templates/architecture/foundry-targets.md) template) —
  declares, per foundry, the `foundries` identifier, whether it is a **live** or
  **roadmap** target, a per-foundry portability note, and the **three portable
  "foundry-agnostic" evidence axes** that cut across all of them:
  - **OpenTelemetry GenAI trace conformance** — emit conformant `create_agent` /
    `invoke_agent` / `execute_tool` spans. This is the single strongest cross-foundry
    anchor: Microsoft Foundry *requires* `invoke_agent` spans for evaluation, and
    Bedrock AgentCore, Vertex Agent Engine, and NVIDIA NeMo are all OTel-instrumented.
  - **Portable evaluation suite** — a model/framework-agnostic eval set.
  - **Open-protocol routing + interop seam** — an OpenAI-compatible inference endpoint
    plus MCP (tools) / A2A (agent-to-agent) support.
- **`docs/observability/trace-contract.md`** (required) — the trace-evidence axis,
  reusing the artifact owned by the shipped `architectures/agent-observability`
  overlay. The two compose naturally: observability declares *the trace shape*, this
  overlay declares *which foundries consume it*.
- **`docs/architecture/model-routing.md`** (optional at v1) — the open-protocol
  routing seam in artifact form. Its owning module
  (`architectures/intelligent-model-routing`, OPP-0030) is not built yet; requiring it
  would block this overlay on unbuilt work. When OPP-0030 ships, `model-routing.md`
  moves from optional to expected (a v2 / companion-rule concern).

The `foundries` enumeration lives **in the artifact** (`foundry-targets.md`), not as a
`module.yaml` field — the module schema does not carry arbitrary fields, and the
consumer's declaration belongs in the consumer's artifact. The template provides the
canonical enum: `azure-ai-foundry`, `nvidia-ai-foundry`, `palantir-aip`,
`aws-bedrock-agentcore`, `google-vertex-agent-engine`, `custom`.

## v1 is declarative — enforcement is deferred

v1 establishes *what the target declaration is*. It ships **no companion rule and no
validator** — exactly like its `agent-observability` sibling. A
`validate-foundry-target.sh` that checks the declared evidence actually exists /
matches, and a companion rule binding evidence changes to the declaration, are the
**v2 follow-up** (a separate OPP/PRD), per the deferred-implementations discipline.
Declaring the target first, enforcing the evidence second.

## How this overlay composes

- **With `architectures/agent-observability`** — that overlay owns `trace-contract.md`;
  this one requires it as the portable trace-evidence axis. Activate both when a
  project both emits a declared trace contract and targets a foundry that consumes it.
- **With any `agents/*` pack** — the pack defines the agent runtime; this overlay
  declares which foundries that runtime is built to land in. No dependency either way.
- **With the frontier-agent posture (OPP-0027 cluster)** — this is the
  deployment-target satellite. It builds on the trace shape from observability
  (OPP-0029), anticipates the routing seam from model-routing (OPP-0030), and pairs
  with identity-bound traces from defense-in-depth (OPP-0031).

## Agent behavior

Agents working in a project with this overlay active treat `foundry-targets.md` as the
source of truth for the project's foundry commitments: when adding a foundry
integration, use the current vendor identifier from the enum (or the `custom` hatch),
mark it `live` or `roadmap` honestly, and keep the portable evidence axes substantiated
rather than aspirational.

## See also

- [`module.yaml`](module.yaml) — the module contract.
- [`templates/architecture/foundry-targets.md`](../../../templates/architecture/foundry-targets.md) — the starter.
- Sibling: [`architectures/agent-observability`](../agent-observability/README.md) — the
  trace-contract overlay this one reuses and mirrors.
- Upstream: Microsoft Foundry agent tracing, AWS Bedrock AgentCore, Google Vertex AI
  Agent Engine, NVIDIA NIM/NeMo, and the OpenTelemetry GenAI semantic conventions.
