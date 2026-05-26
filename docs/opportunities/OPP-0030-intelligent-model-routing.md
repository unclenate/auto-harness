<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0030 — Intelligent Model Routing as Architectural Primitive (`architectures/intelligent-model-routing`)

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-25
**Last Updated:** 2026-05-25
**Confidence:** medium-high

---

## Thesis

Agent-native projects of any non-trivial complexity route different
*tasks* to different *models* based on capability, cost, privacy
posture, regulatory constraints, and deployment context. Tula calls
this "deployment-context-aware model routing" and provides a concrete
table: clinical reasoning → Claude Sonnet 4.6; general tasks →
gpt-4o-mini; medical text → MedGemma 27B; medical imaging →
MedImageInsight / CXRReportGen; medical speech → MedASR; air-gapped
deployments → MedGemma 4B local via vLLM. The routing decision is
not a chatbot setting — it is an *architectural* fact about the
project that determines its cost model, privacy posture, and
foundry-portability.

Auto-harness has no module that captures model routing as a first-class
architectural primitive. Agent-pack modules (`agents/claude-code`,
`agents/openclaw`, etc.) name *which agent runtime* the project uses;
none of them captures *which models the runtime routes to and why*.

Add **`architectures/intelligent-model-routing`** — an architectures-
family module declaring a project routes between multiple models
deliberately, with required artifacts:

- `docs/architecture/model-routing.md` — declares the routing table
  (task → model), the routing decision criteria (capability / cost /
  privacy / regulatory / deployment-context), the providers in scope
  (Anthropic, OpenAI, Azure OpenAI, Google Gemini, Mistral, DeepSeek,
  Cohere, vLLM open-weight, healthcare-specific MedGemma/MedASR/etc.),
  and the foundry-routing seams.
- `docs/architecture/model-routing-rationale.md` *(optional)* —
  evidence and benchmarks substantiating non-obvious routing choices
  (e.g., why this specific task goes to MedGemma 27B rather than
  Claude); appropriate for healthcare, regulated, or
  cost-sensitive projects.

Companion rule: edits to routing-decision code require a matching
update to `model-routing.md`. Routing is a *contract* with the
deployment-context-aware behavior the project promises; silent
drift is exactly the failure mode the cycle-end distillation pattern
warns against.

This module composes with [OPP-0028](OPP-0028-ai-foundry-target.md)
(foundries are the routing-target environment),
[OPP-0029](OPP-0029-agent-observability.md) (model-selection spans
are part of the trace contract), and [OPP-0031](OPP-0031-agent-defense-in-depth.md)
(routing decisions are agent-identity-bound). Satellite of
[OPP-0027](OPP-0027-frontier-agent-posture.md).

## Origin / Evidence

- **Tula README § "Frontier model providers Tula routes to":**
  enumerates Anthropic Claude (Sonnet 4.6, Opus 4.7), OpenAI (GPT
  family, o-series, Whisper), Google Gemini (incl Gemini Live for
  voice), xAI Grok, Mistral, DeepSeek, Cohere, open-weight via vLLM
  (MedGemma 4B local, Llama, Mistral, Qwen). Plus the foundry-routing
  layer: "Routing is deployment-context-aware: each task is directed
  to the most capable, cost-effective, and privacy-appropriate model
  available in *that* foundry, in *that* deployment, at *that*
  moment."
- **Healthcare-specific routing as an in-roadmap surface.** Tula's
  "Planned healthcare-specific routing": voice loop → Gemini Live;
  medical text → MedGemma 27B / Claude in Azure AI Foundry; medical
  imaging → MedGemma 4B / MedImageInsight / CXRReportGen; medical
  speech → MedASR / Azure Speech Services. This is a *concrete
  contract* that the catalog should support.
- **The pattern is not Tula-specific.** Any agent-native project
  with cost or privacy constraints develops a routing table. Open-
  weight + frontier-API hybrid deployments (Tula's air-gapped vs.
  cloud modes) are increasingly common. The routing layer is the
  surface where the deployment posture (OPP-0021 self-hosted-OSS),
  trust tier (OPP-0006), and foundry target (OPP-0028) all
  intersect.
- **Auto-harness has no routing primitive at any level.** Agent
  packs don't capture it; delivery modules don't capture it;
  architectures modules don't capture it. The gap is structural —
  not "we forgot a row in a table" but "this dimension of the
  consumer's architecture has no catalog representation."
- **Field signal beyond Tula.** Anthropic, OpenAI, Google, and
  Microsoft Foundry all publish multi-model routing patterns. The
  pattern is consolidating; encoding it now is durable.

## Why Now

- **Tula needs this for clean second-pass intake.** Same reasoning
  as OPP-0029.
- **The cost-sensitivity argument is timely.** Frontier-API costs
  and open-weight inference costs differ by 1–2 orders of magnitude;
  any non-trivial agent product has a real routing decision to
  document. Catalog-layer awareness lets consumers declare the
  routing intent and (later, via PRD-pass) lets validators check
  the routing-code matches the declaration.
- **Healthcare-specific routing models are GA.** MedGemma 4B/27B,
  MedASR, MedImageInsight, CXRReportGen are all available; the
  catalog can name them without naming a moving target.

## Risks / Open Questions

1. **Routing table format: prose, table, or YAML?** Bias: structured
   markdown table at v1 (task → model → rationale → constraints);
   add YAML alternative in v2 if validator-checkable structure
   becomes load-bearing. Same reasoning as OPP-0029.
2. **Provider list: enum or free-form?** Bias: free-form with a
   suggested list at v1; an enum constrains too tightly given the
   provider landscape is still expanding (DeepSeek and xAI are
   recent additions; future models will keep landing).
3. **Should this module include cost-tracking?** Bias: no, defer to
   a future module. Routing declares *which model for which task*;
   *how much each task costs* is a separate concern (cost-budgets,
   alerts, attribution) that warrants its own OPP if/when consumer
   demand surfaces.
4. **Does this conflict with `agents/openclaw`'s `copilot-sdk`
   integration claim?** No. The agent pack says *I run on OpenClaw
   and OpenClaw can route to copilot-sdk-supported providers*. This
   module says *here is the project's explicit routing table*. They
   compose; openclaw doesn't force a specific routing table.
5. **What about routing *between agents* (multi-agent routing) vs
   routing *between models* (single-agent multi-model)?** v1 covers
   the latter — model-routing within a single agent. Multi-agent
   routing (which agent handles which user request) is a different
   problem and a candidate for a separate future OPP if it surfaces.
6. **Does this need a `validate-model-routing.sh` validator?**
   Bias: no at v1 — just the artifact. v2 can check that
   `model-routing.md` references models the project's dependencies
   actually support (cross-reference against package manifests).
7. **Healthcare-specific routing: bundle in v1 or defer?** Bias:
   *name* the healthcare models in the suggested-providers list at
   v1 (MedGemma, MedASR, MedImageInsight, CXRReportGen); *require*
   nothing healthcare-specific. Projects in healthcare can adopt the
   names; projects outside can ignore.

## Disposition

<!--
Empty while Status: proposed. Satellite of OPP-0027.
-->

## Promotion

<!--
Empty until accepted. Anchor: OPP-0027.
-->
