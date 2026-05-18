<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0007: Agentic Interface Awareness (Domain Primary, Architecture Optional)

**Status:** Proposed
**Date:** 2026-05-17
**Author:** @unclenate
**Reviewers:** @unclenate
**Context source:** OPP-0002 (Agentic Interface Awareness) and an R&D pass against CopilotKit (`https://docs.copilotkit.ai/`, `https://github.com/CopilotKit/CopilotKit`), A2UI v0.8 Public Preview (`https://a2ui.org/`, `https://github.com/google/A2UI`), and the Generative UI Global Hackathon starter kit (`https://github.com/jerelvelarde/Generative-UI-Global-Hackathon-Starter-Kit`). Promotes OPP-0002 from proposed to accepted.

## Context

Agentic interfaces — in-product surfaces where AI agents are first-class actors that generate UI fragments at runtime, mediate conversation in copilot panels, or call product actions via agent-to-app protocols — are a distinct shape with distinct governance needs. The harness currently has no module that names this shape or governs its risks. Teams adopting CopilotKit, A2UI, MCP Apps, or custom agent surfaces are reinventing prompt-injection defense, action-approval flows, generative-UI rendering policy, and agent-attribution discipline per-project.

OPP-0002 makes the case for adding awareness. This ADR commits to *how*.

The Generative UI Global Hackathon starter frames the design space as a three-point spectrum that has held up across vendors and that the harness should adopt as its mental model:

1. **Controlled** — agent picks from a developer-defined set of pre-built components. Canonical: CopilotKit + React components.
2. **Declarative** — agent emits a schema; a renderer maps the schema to native widgets from an approved catalog. Canonical: A2UI.
3. **Open-ended** — agent emits raw HTML/Markdown rendered in a sandbox. Canonical: MCP Apps in Claude desktop / ChatGPT.

The harness needs to recognize all three without taking sides between them. Today's CopilotKit-flavored copilot may be tomorrow's A2UI-rendered surface inside an MCP-host shell — and the design doc, risk register, and tool registry should survive that migration.

The non-trivial decision is whether agentic-interface awareness belongs as a **domain** (cross-cuts existing architectures), as an **architecture** (its own topology), or as both.

## Decision

**Ship agentic-interface awareness as a `domain` module primary, with a thin optional `architecture` overlay for projects where the agent surface is the dominant topology decision, plus a template family, an Agent Skill, a workflow guide, a starter composition, and a sample project.**

Concrete commitments:

1. **New `domains/agentic-interfaces` module** at `platform/profiles/domains/agentic-interfaces/`.
   - **Required artifacts:** `docs/agentic-interface/design.md` and `docs/agentic-interface/risk-register.md`.
   - **Optional artifacts:** `docs/agentic-interface/prompt-tool-registry.md`, `docs/agentic-interface/renderer-contract.md`, `docs/agentic-interface/component-manifest.md`, `docs/architecture/overview.md`.
   - **Sensitive paths:** any path containing `agentic-interface`, plus the conventional in-product agent registry locations (`src/agents/`, `src/copilot/`, `src/agent-ui/`, `src/genui/`, `prompts/`, `agent.config.*`).
   - **Companion rule:** changes to those paths require updating one of `docs/agentic-interface/design.md`, `docs/agentic-interface/risk-register.md`, `docs/agentic-interface/prompt-tool-registry.md`, or a new `docs/adr/ADR-*.md`. Human-review clause requires reviewers to confirm prompt-injection surface, action-approval gating, and renderer contract are still accurately described.
   - **Review gates:**
     - Any new agent-callable action must be reviewed for tier classification and approval gating.
     - Generative UI rendering pathways must be reviewed for catalog-bounding (Controlled/Declarative) or sandbox isolation (Open-ended).
     - Model or runtime upgrades that affect agent behavior must be reviewed for UI-regression risk before merge.
   - `dependsOn: kernel/base`. `conflictsWith: []` — composes with any architecture.

2. **New `architectures/agentic-ui` module** at `platform/profiles/architectures/agentic-ui/`.
   - **Use only when** the agent runtime, action surface, and renderer contract are the *dominant* topology choice — i.e. conversational-primary products and Open-ended/MCP-Apps projects. For a copilot bolted onto a SaaS web-app, use `architectures/web-app + domains/agentic-interfaces` and skip this overlay.
   - **Required artifact:** `docs/architecture/overview.md` (must describe agent runtime location, action-surface boundary, and renderer contract — beyond what `web-app` requires).
   - **Sensitive paths:** the agent runtime location plus the action surface (additive to `web-app`/`api-service` if either is also composed).
   - **Companion rule:** changes to the agent runtime require updating the architecture overview or a new ADR.
   - `dependsOn: kernel/base`. `conflictsWith: []` — co-exists with `web-app` and `api-service` (the same way `web-app + api-service` co-exist today).

3. **Template family** at `platform/templates/agentic-interface/`:
   - `design.md` — the canonical agentic-interface design doc. Declares flavor (Controlled / Declarative / Open-ended / Conversational-primary), agent runtime, action surface, renderer/component contract, state model, human-in-the-loop checkpoints, prompt-injection defense surface.
   - `risk-register.md` — agentic-UI-specific risks pre-seeded: prompt injection via tool results, hallucinated UI affordances, action-approval bypass, generative-UI XSS, agent-controlled navigation, attribution drift, model-update regression.
   - `prompt-tool-registry.md` — list of tools/actions the in-product agent can invoke; one row per tool with tier classification, side effects, approval gating. Models `TOOLS.md` at the in-product-agent level rather than at the developer-agent level.
   - `renderer-contract.md` — declares the component catalog (Controlled), schema (Declarative), or sandbox boundary (Open-ended) the agent is allowed to render through.
   - `README.md` — index for the template family.

4. **Agent Skill** at `platform/skills/harness-agentic-interfaces/SKILL.md`. Frontmatter follows the existing convention (`harness-tools/SKILL.md`). Body covers the three-flavor map, tier discipline for agent-callable actions, the prompt-injection / generative-UI threat model, CopilotKit-vs-A2UI-vs-custom decision guidance, and how the skill complements (does not replace) `harness-governance`.

5. **Workflow guide** at `platform/workflow/agentic-interface-integration.md`. Operator-facing: how to add the module to an existing project, how to fill the design doc, how to integrate CopilotKit / A2UI / MCP Apps / custom into a web-app or api-service project, how validators fire, what review gates open.

6. **Starter composition** at `platform/compositions/agentic-ui-saas.yaml`. Wires `kernel/base + delivery/prototype + management/interview-driven + architectures/web-app + domains/agentic-interfaces + agents/base`. Demonstrates the *common case* — copilot bolted onto a SaaS — rather than the architecture-overlay case.

7. **Sample project** at `platform/examples/sample-projects/agentic-ui-starter/`. Minimal skeleton matching `interview-driven-hackathon`: `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, `harness.manifest.yaml`, and `docs/agentic-interface/design.md` + `docs/agentic-interface/risk-register.md` filled in for a hypothetical CopilotKit-flavored copilot. Validates green against the full validator chain without `disabledValidations` overrides.

## Consequences

### Positive

- Projects adopting CopilotKit, A2UI, MCP Apps, or custom agentic surfaces inherit governance for the new risk surface (prompt injection, action approval, renderer contract, model-update regression) instead of reinventing it.
- The three-flavor map (Controlled / Declarative / Open-ended) gives reviewers and agents a shared vocabulary for the design space without locking the harness to any vendor.
- The renderer-contract artifact is vendor-portable: when a team migrates from CopilotKit to A2UI (or vice versa), the design doc, risk register, and tool registry stay; only the renderer-contract appendix changes.
- The domain/architecture split mirrors the existing `web-app` vs `web3` precedent: cross-cutting concerns go in domains; topology-defining concerns go in architectures. Teams adopt the domain by default and reach for the architecture only when the agent surface *is* the product.
- The skill (`harness-agentic-interfaces`) gives agents working in a harness-governed project a single load target for "I am working in an agentic-UI codebase — what governance applies?" — same pattern as `harness-web3`.
- The companion rule prevents the most common silent failure: a tool is added to the in-product agent's reachable set without being recorded in the registry, so reviewers and downstream agents do not know it exists.

### Negative

- Two new modules increase the catalog surface. Some maintenance cost, especially as A2UI v0.9 and CopilotKit's AG-UI Protocol continue to evolve. Mitigation: the templates carry the vendor-specific detail; the modules themselves stay abstract.
- The architecture vs domain decision will trip up first-time consumers. Mitigation: the workflow doc opens with a one-paragraph "use the domain unless ..." rule; the composition demonstrates the common case (domain only).
- Required-artifact list (design + risk register) is non-trivial for a tiny copilot. Mitigation: the overlay is *opt-in via composition*. A project that does not adopt `domains/agentic-interfaces` is unaffected.
- `oneOf` semantics from ADR-0006 is not used here — every artifact has a canonical path. If consumers report alternative path conventions later, the schema is ready to accommodate.
- The prompt-injection threat model in `risk-register.md` is current as of mid-2026. Mitigation noted in template comments: this is a fast-moving area; treat the template as a starting set and update as new attack classes are documented.

### Watch

- If A2UI v0.9 ships breaking changes (new message envelope, `createSurface`, client-side functions), the design-doc template's renderer-contract appendix may need updating. The module's required-artifact list should not need to change.
- If consumers report the architecture overlay is unused — i.e. nobody hits the "agent surface is the dominant topology" case — collapse it back into the domain in a future ADR. Do not preserve the overlay for symmetry alone.
- If the companion rule's `requiredAny` set turns out to be too permissive (a stylistic copilot tweak counted as legitimate companion evidence for a tool addition), tighten the regex anchors or add a "tools changed → registry must change" sub-rule. The current rule errs toward usable rather than maximally strict; revisit if drift is observed.
- If consumers using MCP Apps as their primary surface report the conversational-primary flavor needs a dedicated sub-module (MCP-host-specific renderer contract, ChatGPT-Apps-specific tool registry), spawn that as a follow-up. Today the conversational-primary flavor is *recognized* in the design-doc template but not *specialized*.

## Trust-Model Implications

Additive. No changes to the Tier 0–5 model or to any existing module. New sensitive paths are added, but they only apply when the domain module is active.

The module *raises the tier* of certain actions inside its scope:

- Adding a new agent-callable action (a new entry in the prompt-tool registry) is Tier 2 (workspace mutation) for the registry edit, plus the human-review gate from the companion rule.
- Deploying a model/runtime change that affects in-product agent behavior is Tier 4 (environment-altering) — same tier as a dependency upgrade — because of the silent UI-regression risk.
- Shipping a generative-UI surface in Open-ended mode (raw HTML in a sandbox) requires the renderer-contract artifact to declare the sandbox boundary; deploying that surface without the boundary documented is a Tier 4 gate, not Tier 3.

These are domain-local rules; they do not change the kernel's trust model for any other project.

## Alternatives Considered

### Architecture only (no domain)

- **Description:** Make `architectures/agentic-ui` the single module; require it for any project with an agent surface.
- **Why rejected:** Forces a topology decision the consumer often does not need. A SaaS web-app that adds a copilot still wants the `web-app` architecture's trust-belongs-on-server posture. Layering `agentic-ui` as a second architecture creates double-required artifacts for an architecture overview that mostly repeats. The domain is the right primary container for the cross-cutting agent-surface concerns.

### Domain only (no architecture overlay)

- **Description:** Skip `architectures/agentic-ui`. Let conversational-primary products use `web-app` or `api-service` for topology and `domains/agentic-interfaces` for the agent-surface governance.
- **Why rejected:** Conversational-primary products (the product *is* the conversation; the chat box is not a sidebar) have topology decisions — agent runtime location, action surface boundary, renderer contract — that don't fit the "browser/server/edge" framing of `web-app` or the "request/response" framing of `api-service`. The architecture overlay is small and optional, and it gives those products a place to document topology without contorting `web-app`.

### One vendor-specific module per ecosystem (copilotkit, a2ui, mcp-apps)

- **Description:** Three modules, one per vendor stack, with vendor-specific required artifacts and tool registries.
- **Why rejected:** Vendor lock-in at the harness level. CopilotKit and A2UI both ship monthly. MCP Apps are early. A consumer who migrates between vendors would have to swap modules and rewrite governance artifacts. The flavor enum + renderer-contract pattern keeps governance vendor-neutral while letting templates carry vendor-specific guidance.

### Bake into `architectures/web-app` as additional optional artifacts

- **Description:** Add `docs/agentic-interface/*` as optional artifacts under `web-app` with a recognizing-it-when-present validator.
- **Why rejected:** Optional artifacts are not enforced today (per ADR-0006's "Negative" consequences). Burying agentic-interface governance under `web-app` would make it invisible — no module activation signal, no required artifacts, no companion rule. The whole point of recognizing the shape is to make it *opt-in but enforced when opted in*. That requires its own module.

### Defer until after one external consumer asks

- **Description:** Wait for an external project to file an issue requesting agentic-interface governance, then design against their specific needs.
- **Why rejected:** OPP-0001 took the wait-for-consumer path and OPP-0002's R&D pass surfaced that the design space has consolidated enough (three flavors, two protocols, one shared threat model) that a harness opinion is defensible now. Waiting also cedes the framing position — consumers will adopt either CopilotKit's defaults, A2UI's defaults, or their own ad-hoc patterns, and the harness will be retrofitting governance to whatever they shipped. Better to ship the framing now and iterate against the first consumer than to ship reactively.
