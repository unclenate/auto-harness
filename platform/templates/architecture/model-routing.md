<!--
Copyright {{YEAR}} {{AUTHOR}} <{{AUTHOR_EMAIL}}>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of {{PROJECT_NAME}} — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Model Routing

> How **{{PROJECT_NAME}}** routes different tasks to different models, and why. The
> routing table is an architectural fact — it determines the cost model, privacy
> posture, and foundry-portability. Part of the `architectures/intelligent-model-routing`
> overlay (PRD-0029 / OPP-0030). Pair it with `docs/architecture/foundry-targets.md`
> when the project targets an enterprise AI foundry.

## Routing table

Declare one row per task class. Name a real model for each — not an aspiration. The
**rationale** says *why this model for this task*; the **constraints** capture privacy /
regulatory / deployment limits that bind the choice.

| Task class | Model | Rationale | Constraints |
|---|---|---|---|
| <!-- TODO: e.g. complex reasoning --> | <!-- TODO: e.g. Claude Sonnet 4.6 --> | <!-- TODO: why this model --> | <!-- TODO: e.g. none / cloud-only --> |
| <!-- TODO: e.g. high-volume cheap tasks --> | <!-- TODO: e.g. a small fast model --> | <!-- TODO: cost --> | <!-- TODO --> |
| <!-- TODO: e.g. sensitive-data tasks --> | <!-- TODO: e.g. local open-weight via vLLM --> | <!-- TODO: privacy --> | <!-- TODO: e.g. air-gapped / on-prem only --> |
| <!-- TODO: add task classes (speech, vision, domain-specific, …) --> | | | |

## Routing criteria

State which criteria drive the table, and how they trade off. Reference the row above
where a criterion is load-bearing.

- **Capability:** <!-- TODO: which tasks demand a frontier model vs. a smaller/cheaper one -->
- **Cost:** <!-- TODO: where cost sensitivity routes volume tasks to cheaper/open-weight models (frontier-API vs. open-weight inference can differ by 1–2 orders of magnitude) -->
- **Privacy:** <!-- TODO: which data classes must stay on local/on-prem inference; tie to management/privacy-by-design if active -->
- **Regulatory:** <!-- TODO: jurisdiction / compliance constraints on where inference may run -->
- **Deployment-context:** <!-- TODO: how the table changes per deployment (air-gapped vs. cloud vs. a specific foundry) -->

## Providers in scope

Free-form — name the providers **{{PROJECT_NAME}}** actually routes to. Suggested set
(not a closed list; the landscape keeps expanding):

- **Frontier APIs:** Anthropic (Claude), OpenAI (GPT / o-series), Google Gemini,
  Azure OpenAI, Mistral, DeepSeek, Cohere, xAI.
- **Open-weight (self-hosted, e.g. via vLLM):** Llama, Mistral, Qwen, and small local
  models for air-gapped modes.
- **Domain-specific (name as applicable):** e.g. healthcare — MedGemma (4B/27B), MedASR,
  MedImageInsight, CXRReportGen.
- <!-- TODO: the actual providers/models this project uses; drop the rest -->

## Foundry-routing seams

If the project targets one or more enterprise AI foundries (see `foundry-targets.md`),
declare how routing changes per target — the same task may route to a different model or
endpoint in each foundry, in each deployment, at each moment.

- <!-- TODO: per-foundry / per-deployment routing differences, or "single deployment, no per-foundry variance" -->

## Update policy

Treat this as the source of truth for task→model selection. When a routing decision
changes, update the table in the same change, state the criterion behind any non-obvious
choice, and keep deployment-context-aware routing explicit. (A companion rule and a
`validate-model-routing.sh` enforcing that the table matches the routing code are the
`architectures/intelligent-model-routing` v2 follow-up; v1 is the declared contract.)
