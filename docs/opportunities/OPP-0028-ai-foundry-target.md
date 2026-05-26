<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0028 — Enterprise AI Foundry Target Awareness (`architectures/ai-foundry-target`)

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-25
**Last Updated:** 2026-05-25
**Confidence:** medium-high

---

## Thesis

A growing class of agent-native projects ship explicitly designed to
drop into **enterprise AI Foundries** — Microsoft / Azure AI Foundry,
NVIDIA AI Foundry, Palantir Foundry/AIP, and the analogous platforms
emerging from other vendors — alongside identity, audit, compliance,
and observability plumbing the foundry already provides. This is a
*deployment-target* dimension distinct from the `delivery/` family
(which captures *how* the project ships — prototype / production-saas
/ self-hosted-oss / internal-platform) and from the `agents/` family
(which captures *which AI runtime* the project uses).

Tula 2026-05-25 explicitly targets all three of the major enterprise
foundries and declares **foundry-agnostic** as a property: "skills
emit OpenTelemetry-shaped traces, ship binary-graded evaluation
suites, and route through a model-provider seam that any of these
enterprise foundries can consume." The README enumerates the foundry-
specific capabilities the project commits to landing in (Foundry
Control Plane, Foundry Observability, Purview/Defender/Entra
integrations on the Microsoft side; NIM inference microservices on
NVIDIA DGX Cloud on the NVIDIA side; ontology / lineage / role-and-
permission-governed data layer on the Palantir side).

No auto-harness module captures this dimension today.

Add **`architectures/ai-foundry-target`** as a `architectures/`-family
module with an enumerated `foundries:` sub-field naming which
enterprise foundries the project commits to landing in. Required
artifacts capture the foundry-portability evidence:

- `docs/architecture/foundry-targets.md` — declares which foundries
  the project supports, what evidence substantiates each
  (trace-shape, eval-publication, model-routing seam), and what
  features are foundry-specific vs. foundry-agnostic.
- `docs/architecture/model-routing.md` — required (overlaps with
  OPP-0030 `intelligent-model-routing` — composes naturally).
- `docs/observability/trace-contract.md` — required (overlaps with
  OPP-0029 `agent-observability` — composes naturally).

The module composes with `architectures/agent-observability` (OPP-0029),
`architectures/intelligent-model-routing` (OPP-0030), and
`architectures/agent-defense-in-depth` (OPP-0031) — the four
together substantiate the umbrella posture in
[OPP-0027](OPP-0027-frontier-agent-posture.md).

## Origin / Evidence

- **Tula README § "Foundry-agnostic and provider-portable":**
  enumerates Microsoft / Azure AI Foundry (Foundry Control Plane,
  healthcare AI foundation models — MedImageInsight, CXRReportGen,
  MedASR, MedGemma 4B/27B; Foundry Observability, Purview/Defender/Entra),
  NVIDIA AI Foundry (NIM inference microservices, NVIDIA DGX Cloud,
  Nemotron family, customer-tuned domain models), and Palantir
  Foundry / AIP (ontology, lineage, role-and-permission-governed data
  layer, structured outputs shaped to land cleanly into Foundry
  ontology). Three independent foundry vendors with distinct shapes
  but a common "this is an enterprise-AI-platform target" pattern.
- **The pattern generalizes beyond Tula.** Aria (Tula's commercial
  extension) is foundry-targeted at Microsoft. Any healthcare AI
  project pursuing hospital deployment via Azure AI Foundry hits the
  same shape. Any defense / national-security AI project targeting
  Palantir AIP hits the same shape. The foundries themselves are
  consolidating around a small set of published patterns (Foundry
  Control Plane, Foundry Observability, NIM, AIP ontology) so
  catalog-layer awareness is durable.
- **Auto-harness lacks any catalog primitive for "this project
  targets one or more enterprise AI foundries."** The closest
  neighbors — `delivery/production-saas`, `delivery/self-hosted-oss`,
  `agents/openclaw`, `architectures/agent-skill-pack` — all answer
  different questions.
- **The trace-shape, eval-publication, and model-routing surfaces
  the satellites cover (OPP-0029/0030) are the substantive primitives
  foundries consume.** This module is the *target declaration*; the
  satellites are *what makes the target real*. Without this module,
  consumers have nowhere to declare which foundries their project
  commits to.

## Why Now

- **Tula explicitly names this dimension.** Field evidence is
  primary.
- **The three named foundries are stable references.** Microsoft AI
  Foundry, NVIDIA AI Foundry, and Palantir Foundry/AIP are all GA
  products with published agent patterns; the catalog can encode
  them without risk of naming a moving target.
- **Catalog-layer awareness unlocks the satellite modules.** The
  observability + routing + defense-in-depth modules (OPP-0029..0031)
  are useful on their own, but they're *most* useful when paired
  with an explicit foundry-target declaration — because the trace
  shapes, eval suites, and model-routing seams the satellites
  produce are exactly what the foundries consume.

## Risks / Open Questions

1. **Should `foundries:` be an enum on the module or free-form?**
   Initial bias: enum at v1 (`microsoft-ai-foundry`, `nvidia-ai-foundry`,
   `palantir-foundry`) with a `custom` escape hatch for emerging
   targets. Avoids "every consumer invents a new foundry name"; allows
   forward growth.
2. **Does the module require *all* foundry targets the project
   declares to be live?** Bias: no. A project can declare
   `microsoft-ai-foundry` as the current target and
   `nvidia-ai-foundry` as a roadmap target, with evidence appropriate
   to each.
3. **What's the relationship to the trust-tier model (OPP-0006)?**
   Foundry targeting is a *capability declaration*; trust-tier is an
   *enforcement contract*. They compose: a Tier-4 (paid SaaS) Microsoft
   AI Foundry deployment looks different from a Tier-5 (production)
   one in audit posture, but the foundry-target declaration is the
   same.
4. **Does Aria-the-commercial-extension warrant a *separate* sub-
   posture beyond Tula's open-source declaration?** Probably yes
   eventually — the multi-tenant, BAA-tier, per-tenant audit-aggregation
   Aria adds isn't captured by foundry-targeting alone. Defer to
   either OPP-0015 augmentation (BAA-LLM-gateway) or a future
   posture-extension OPP.
5. **What about non-AI-foundry deployment targets that have similar
   "drop into governed enterprise platform" shape — e.g., AWS Bedrock
   Agents, Google Vertex AI Agents, IBM watsonx Orchestrate?** Bias:
   add them to the enum at v1 (`aws-bedrock-agents`, `google-vertex-agents`,
   `ibm-watsonx-orchestrate`) — they share the architectural shape.
   PRD-pass should weigh which to ship in v1 vs defer.
6. **Could this become an overlay on existing `architectures/`
   modules rather than a standalone module?** E.g., extend
   `agent-skill-pack` (OPP-0018) with a `foundry-targets:` sub-field?
   Considered; rejected for v1 because foundry-targeting is
   meaningful even for non-skill-pack agent architectures (a chatbot,
   a copilot, a multi-agent system). Standalone module preserves
   composability.
7. **Should this be `architectures/` or `delivery/`?** It captures
   *what the product is built to drop into*, not *how the product is
   distributed* — closer to `architectures/`. PRD-pass should weigh
   if `delivery/` ergonomics fit better.

## Disposition

<!--
Empty while Status: proposed. Satellite of OPP-0027.
-->

## Promotion

<!--
Empty until accepted. Anchor: OPP-0027.
-->
