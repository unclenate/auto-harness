<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Architecture Overlay: Intelligent Model Routing

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay governs how an agent-native project declares that it **routes different
tasks to different models deliberately** — based on capability, cost, privacy posture,
regulatory constraint, and deployment context. The routing decision is not a chatbot
setting; it is an **architectural fact** about the project that determines its cost
model, privacy posture, and foundry-portability. This overlay makes that routing table
a first-class, reviewable artifact.

**This is a routing dimension, distinct from two it is often confused with:**

- `agents/*` captures *which AI runtime* a project uses (Claude Code, OpenClaw, …).
- `delivery/*` captures *how* the project is distributed.
- This overlay captures *which models the runtime routes to, for which tasks, and why*.

It is **opt-in** (add `intelligent-model-routing` to your `harness.manifest.yaml`) and
composes with any `agents/*` pack, with `architectures/agent-observability`
(model-selection spans are part of the trace contract), and with
`architectures/ai-foundry-target` (the foundry is the routing-target environment).
auto-harness itself does not activate it.

---

## What this overlay requires

- **`docs/architecture/model-routing.md`** (required, scaffolded from the
  [model-routing](../../../templates/architecture/model-routing.md) template) — declares:
  - the **routing table** — a structured `task → model → rationale → constraints` map;
  - the **routing criteria** — capability / cost / privacy / regulatory /
    deployment-context, stated per non-obvious choice;
  - the **providers in scope** — a **free-form** list (with a suggested set), because
    the provider landscape keeps expanding and an enum would rot;
  - the **foundry-routing seams** — how the table changes per deployment target (the
    same task may route to a different model in an air-gapped vs. cloud deployment).
- **`docs/architecture/model-routing-rationale.md`** (optional) — an evidence/benchmark
  dossier substantiating non-obvious routing choices (e.g. why a task goes to a
  domain-specific open-weight model rather than a frontier API). Appropriate for
  healthcare, regulated, or cost-sensitive projects; most projects need the table, not
  the dossier.

The provider list is **free-form, not an enum**: an enum would constrain too tightly
given the expanding landscape. The template carries a *suggested* set — Anthropic,
OpenAI, Azure OpenAI, Google Gemini, Mistral, DeepSeek, Cohere, xAI, open-weight via
vLLM, and named healthcare-specific models (MedGemma, MedASR, MedImageInsight,
CXRReportGen) — as guidance, not a closed set.

## Relationship to `architectures/ai-foundry-target`

This overlay **owns** `docs/architecture/model-routing.md`, which the shipped
`ai-foundry-target` overlay lists as an *optional* artifact (the deferred-dependency
model: require a shipped sibling's artifact, make an unbuilt sibling's artifact
optional). A project that both targets a foundry and routes between models should
activate **both** overlays; the routing table is the open-protocol-routing evidence axis
that foundry-targeting references.

## v1 is declarative — enforcement is deferred

v1 establishes *what the routing table is*. It ships **no companion rule and no
validator** — exactly like its `agent-observability` / `ai-foundry-target` siblings. A
`validate-model-routing.sh` that checks the declared table against the routing code (and
that referenced models exist in the project's dependency manifests), plus a companion
rule binding routing-code changes to the table, are the **v2 follow-up** (a separate
OPP/PRD). Declaring the routing first, enforcing drift second.

## Agent behavior

Agents working in a project with this overlay active treat `model-routing.md` as the
source of truth for task→model selection: when adding or changing a routing decision,
update the table in the same change, state the criterion behind a non-obvious choice,
and keep deployment-context-aware routing (air-gapped vs. cloud) explicit.

## See also

- [`module.yaml`](module.yaml) — the module contract.
- [`templates/architecture/model-routing.md`](../../../templates/architecture/model-routing.md) — the starter.
- Sibling: [`architectures/ai-foundry-target`](../ai-foundry-target/README.md) — the
  foundry-target overlay whose optional `model-routing.md` this overlay owns.
- Sibling: [`architectures/agent-observability`](../agent-observability/README.md) —
  model-selection spans belong in its trace contract.
