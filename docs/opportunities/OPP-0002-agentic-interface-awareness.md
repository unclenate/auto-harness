<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0002 — Agentic Interface Awareness

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-05-17
**Last Updated:** 2026-05-18
**Confidence:** medium-high

---

## Thesis

Teach the auto-harness to recognize **agentic interfaces** — in-product surfaces where AI agents are first-class actors that generate UI fragments at runtime, mediate conversation in copilot panels, or call product actions via agent-to-app protocols — as a governable shape. Ship a domain module, an optional architecture overlay, templates, a skill, and a workflow guide so any project governed by auto-harness can adopt CopilotKit-style copilots, A2UI-style generative UI, or conversational-primary products **without inventing its own governance around prompt-injection, action approval, generative-UI rendering, and agent attribution**.

This is the "anyone should be able to build projects with our harness that deliver these modern capabilities" thesis, made concrete.

## Origin / Evidence

- **External signal — A2UI v0.8 (Public Preview):** Google + CopilotKit shipped A2UI as an open protocol for "agents that generate rich, interactive UIs that render natively across web/mobile/desktop without executing arbitrary code." It explicitly frames its security model as catalog-bounded components, no code execution, smart-wrapper sandboxing for legacy embeds. Spec is moving — v0.8 stable, v0.9 in draft with `createSurface` and client-side functions. (`https://a2ui.org/`, `https://github.com/google/A2UI`)
- **External signal — CopilotKit (v1.57+, May 2026):** Self-describes as "the frontend stack for agents and generative UI." Authored the AG-UI Protocol, adopted by Google, LangChain, AWS, Microsoft. Ships first-class human-in-the-loop primitives (agents pause for user input/confirmation), backend-tool-rendering (agents call tools whose return values render as UI), and shared agent/UI state. (`https://docs.copilotkit.ai/`, `https://github.com/CopilotKit/CopilotKit`)
- **External signal — Generative UI Global Hackathon starter (jerelvelarde):** Frames the design space as a spectrum — **Controlled** (CopilotKit, predefined React components), **Declarative** (A2UI, schema-to-renderer), **Open-ended** (MCP Apps, raw HTML in sandboxed iframes). This spectrum is durable framing, not vendor noise: any agentic-UI product picks a point on it. (`https://github.com/jerelvelarde/Generative-UI-Global-Hackathon-Starter-Kit`)
- **Internal precedent:** The harness already governs:
  - **Web boundary** (`architectures/web-app`) — trust belongs on the server, UI sensitive paths trigger architecture-overview companion.
  - **Irreversible side-effects under agents** (`domains/web3`) — Tier 5 for blockchain writes, evidence-required for scored output, explicit attribution.
  - **AI-as-author** (`management/interview-driven`) — the interview/spec prompt is treated as a first-class artifact because agents work from it; PRD changes must refresh the prompt.

  The agentic-interface case is the synthesis: agents are now in-product actors with persistent UI surface area, and the harness has no module that *names* that surface or governs the new risks it introduces.

## Why Now

The "agentic interface" pattern is consolidating across the React/Next.js ecosystem in 2026:

1. **Protocols are settling.** AG-UI (CopilotKit) and A2UI (Google) are both public and being adopted across vendors. The harness can take an opinion on the renderer-contract layer now without locking to any single vendor.
2. **The threat surface is unique.** Prompt injection via tool results, hallucinated UI affordances (an agent renders a "Confirm" button for an action it shouldn't be able to take), generative-UI XSS, action-approval bypass, agent-controlled navigation, model-update regression that silently changes UI behavior — these are not covered by traditional web-app threat models or by `web3`-style irreversibility gates. They need their own template family.
3. **Consumer-side governance gap.** Teams building copilots today are wiring custom approval prompts, custom prompt-injection defenses, and ad-hoc tool registries inside their components. There is no shared "this is the design doc / risk register / tool registry shape" for an agentic interface. Auto-harness can be that shape.
4. **Coherence with OPP-0001.** OPP-0001 proposes an exportable governance contract for runtime harnesses (Hive, LangGraph, CrewAI). OPP-0002 governs the *other* end of the same stack — the in-product agent surface that a runtime harness drives. The two together let auto-harness govern both the agent runtime and the agent's user-facing surface.

## Risks / Open Questions

- **Vendor flux risk.** A2UI v0.9 changes the API. CopilotKit ships weekly. The harness must abstract — the design doc names the *flavor* and the *renderer contract* without locking to a vendor SKU. Mitigation: the templates require teams to declare the renderer contract abstractly (component catalog, action surface, state model) and only mention vendor-specific implementations in an appendix.
- **Architecture vs domain ambiguity.** Is the agentic interface a *domain* (cross-cuts web-app + api-service + event-driven) or an *architecture* (it's its own topology)? This OPP proposes **domain primary, architecture optional**. The domain is sufficient when the agent surface is bolted onto an existing web-app. The architecture overlay is right when the agent runtime, action surface, and renderer contract are the dominant topology decision — i.e. for conversational-primary products. ADR-0007 commits to the choice.
- **Over-specification risk.** A required `prompt-tool-registry.md` artifact could become busywork for a product with one chat button. Mitigation: the registry is required only when the module is active, and the module is *opt-in* via composition. Projects without an agent surface never see it.
- **Companion-rule scope.** What changes trigger the companion? Any path containing `agentic-interface` is too narrow; any path touching React components is too broad. Proposed: paths matching a configurable set of registries (the prompt registry, the tool registry, the renderer manifest) plus any docs under `docs/agentic-interface/`. ADR-0007 commits to specifics.
- **Adoption signal.** Like OPP-0001, the module's value depends on whether projects actually adopt it. The minimum-viable validation is one harness-governed sample project (`platform/examples/sample-projects/agentic-ui-starter/`) plus one external project consuming the module via submodule.
- **Relationship to MCP-as-host.** When the agent surface *is* an MCP host (Claude desktop apps, ChatGPT Apps), the renderer contract is the MCP App spec, not React. The module needs to recognize that flavor without forcing a web-app composition. Punt to follow-up if not solvable in v1 — the conversational-primary flavor names it but does not yet ship a dedicated MCP-host sub-module.

## Disposition

Accepted via ADR-0007. Module shipped in PR #5 (commit 8aef150), covered by
PR #7's documentation pass, validated through Copilot code review. The
domain/architecture split landed as proposed — `domains/agentic-interfaces`
as the primary container for cross-cutting concerns, with
`architectures/agentic-ui` as the optional overlay for conversational-primary
or MCP-host-shell topologies.

## Promotion

- Decision record: ADR-0007 (Accepted same date).
- Implementation surface: `platform/profiles/domains/agentic-interfaces/`,
  `platform/profiles/architectures/agentic-ui/`,
  `platform/templates/agentic-interface/`,
  `platform/skills/harness-agentic-interfaces/`,
  `platform/workflow/agentic-interface-integration.md`,
  `platform/compositions/agentic-ui-saas.yaml`,
  `platform/examples/sample-projects/agentic-ui-starter/`.
- Future PRDs: PRD-NNNN for any consumer-driven enhancements as they emerge
  (e.g., a Controlled-flavor component-manifest template if a Controlled
  consumer reports the template family is missing a renderer-side contract,
  or a dedicated MCP-host sub-module if a conversational-primary consumer
  needs MCP-Apps-specific governance).
