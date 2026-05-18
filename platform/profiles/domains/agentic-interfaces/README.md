<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Domain Overlay: Agentic Interfaces

This overlay governs **in-product agentic interfaces** — surfaces where an AI agent is a
first-class actor inside the product the user is using. It is the right overlay when the
product includes any of:

- a **copilot panel / chat sidebar / command bar** that mediates user interaction with the product
- **generative UI** — UI fragments that are produced, selected, or assembled by the agent at runtime
- a **conversational-primary** experience — the product *is* the conversation; the agent is not a sidebar but the main surface
- an **action surface** the agent can invoke (frontend or backend tools) without the user clicking the underlying button themselves

This overlay does **not** govern external AI-coding agents (Claude Code, Cursor, Copilot) operating
on the repository. Those are governed by `agents/base` and `agents/openclaw`. The distinction:

- `agents/*` modules govern **the developer's agent operating on the codebase**.
- `domains/agentic-interfaces` governs **the product's agent operating on the user**.

---

## The Three-Flavor Map

Pick one flavor (or document a hybrid) in `docs/agentic-interface/design.md`. The flavor
determines the renderer contract and the dominant risk surface.

| Flavor | Renderer contract | Canonical stack | Dominant risks |
|--------|------------------|-----------------|----------------|
| **Controlled** | Developer-defined React component catalog; agent picks from a fixed set | CopilotKit + React | Hallucinated UI affordances; action-approval bypass; agent renders Confirm-style buttons for tools it shouldn't reach |
| **Declarative** | JSON schema; agent emits descriptions; client maps to native widgets from an approved catalog | A2UI (v0.8 preview), AG-UI Protocol | Catalog drift; schema-injection; renderer-vs-spec version skew across clients |
| **Open-ended** | Raw HTML / Markdown rendered in a sandbox (iframe, MCP App container) | MCP Apps in Claude desktop / ChatGPT Apps | Generative-UI XSS; sandbox-escape; agent-controlled navigation outside the boundary |
| **Conversational-primary** | The product *is* the chat; UI emerges from the conversation rather than wrapping it | ChatGPT-style, Claude desktop apps, MCP-host shells | All of the above, plus attribution drift (which assistant said what, with which version, citing which source) |

These are not mutually exclusive in practice. A SaaS product may have a Controlled copilot
sidebar (CopilotKit) *and* an Open-ended MCP App entrypoint. The design doc lets you declare
multiple flavors with one renderer-contract section each.

---

## When to Compose This Overlay

Compose `domains/agentic-interfaces` when **any** of the following is true:

- Your product imports CopilotKit, A2UI, AG-UI Protocol clients, or any in-product agent framework
- Your product exposes tools/actions to an agent (frontend or backend) that the agent can invoke without an intermediate user click
- Your product renders UI fragments produced by the model at runtime (beyond echoing markdown in a chat bubble)
- Your product is conversational-primary — the chat is the product, not a sidebar

Compose **with** `architectures/web-app` when the agent is bolted onto a SaaS web-app surface
(the common case). Compose **with** `architectures/agentic-ui` when the agent surface is the
*dominant* topology decision — i.e. conversational-primary or Open-ended/MCP-host products.

Compose **with** `delivery/prototype` if you are still iterating on the agent loop; upgrade
to `delivery/production-saas` (or your delivery posture) when the agent ships to real users.

---

## What This Overlay Requires

Two required artifacts:

| Artifact | Purpose |
|----------|---------|
| `docs/agentic-interface/design.md` | Names the flavor, agent runtime, action surface, renderer/component contract, state model, human-in-the-loop checkpoints, and prompt-injection defense surface. The canonical "what is the agent in this product, and what is it allowed to do?" doc. |
| `docs/agentic-interface/risk-register.md` | Agentic-UI-specific risks (prompt injection, hallucinated affordances, action-approval bypass, generative-UI XSS, agent-controlled navigation, attribution drift, model-update regression). Pre-seeded by the template. |

Use templates from `platform/templates/agentic-interface/` for both.

Three optional artifacts:

| Artifact | Use when |
|----------|---------|
| `docs/agentic-interface/prompt-tool-registry.md` | The agent has more than two or three callable tools, or any tool has side effects beyond reading visible state. Models the in-product equivalent of `TOOLS.md`. Strongly recommended. |
| `docs/agentic-interface/renderer-contract.md` | The product ships generative UI (Declarative or Open-ended flavor). Declares the component catalog (Controlled), schema (Declarative), or sandbox boundary (Open-ended) the agent is permitted to render through. |
| `docs/agentic-interface/component-manifest.md` | The Controlled flavor has a non-trivial number of agent-renderable components. Documents each component's purpose, props, and intended agent-side use. |

---

## Companion Rules

**Surface change → governance refresh.**
Changes under `docs/agentic-interface/`, `src/agents/`, `src/copilot/`, `src/agent-ui/`,
`src/genui/`, `prompts/`, or any `agent.config.*` / `copilotkit.config.*` / `a2ui.config.*`
file require a same-commit update to one of: the design doc, the risk register, the prompt-tool
registry, or a new ADR.

The most common failure mode this rule catches: a new agent-callable action is added to code
without being added to the registry, so reviewers and downstream agents do not know it exists.

**Renderer change → renderer-contract refresh.**
Changes under `src/renderer/`, `src/agent-components/`, `src/agent-actions/`, or any
`renderer.manifest.*` / `component.catalog.*` file require an update to the renderer contract,
the design doc, or a new ADR. The renderer contract is the agent's permission system for the
UI layer — weakening it (e.g. adding a component that bypasses HTML escaping) is equivalent
to weakening an API authorization check.

---

## Review Gates

The overlay declares four gates. They are not validator-enforced; they are reviewer-enforced
discipline that gets explicit attention in PR review.

1. **Tool-addition gate.** Any new agent-callable action must be reviewed for tier classification, side effects, and approval gating. The harness's trust-tier model applies to in-product agents the same way it applies to developer agents: a tool that sends email is Tier 3, a tool that mutates a database is Tier 4, a tool that triggers a deployment is Tier 5 — regardless of how easy it is to invoke from the chat box.

2. **Renderer-contract gate.** Generative UI pathways must be reviewed for catalog-bounding or sandbox isolation. The Open-ended flavor in particular cannot ship to production without a documented sandbox boundary (CSP, iframe-sandbox attrs, MCP App container scope).

3. **Model/runtime upgrade gate.** A model change (Gemini 2.5 → Gemini 3 Flash, Claude Sonnet 4.5 → 4.7, GPT-4o → GPT-5) or a runtime upgrade (CopilotKit major, A2UI v0.8 → v0.9) can change agent behavior without a code diff. Reviewers must explicitly check UI-regression risk and ideally run a designated set of "golden" interactions before merge.

4. **Human-in-the-loop conformance gate.** Checkpoints declared in `design.md` ("agent pauses for confirmation before sending email") must be present in code. Drift between declared and actual approval flow is a Tier-3-or-higher governance failure, not a UX bug.

---

## Trust-Tier Implications Inside This Overlay

Standard tiers apply, with these domain-local notes:

- **Tier 2** — Editing the prompt-tool registry, adding a Controlled-flavor component to the catalog, updating the design doc.
- **Tier 3** — Adding a backend tool that emits externally-visible side effects (email, Slack message, calendar event, third-party API write) to the agent's reachable surface. The companion rule and the tool-addition review gate both fire.
- **Tier 4** — Shipping a model/runtime upgrade, broadening the renderer contract (e.g. adding a component that injects raw HTML), or shipping the Open-ended flavor without a documented sandbox boundary.
- **Tier 5** — Any in-product agent that can trigger a production deployment, a payment, an irreversible data change, or a contract-signing surface. Not in scope for v1 of this overlay (and probably not in scope for most agentic interfaces) — if your agent has Tier 5 reach, surface it explicitly in the design doc and adopt the gating from the relevant domain (e.g. `domains/web3` for chain writes).

---

## How This Overlay Composes

| Pair with | When |
|-----------|------|
| `architectures/web-app` | Common case: copilot or generative UI bolted onto a SaaS web-app surface |
| `architectures/agentic-ui` | Conversational-primary or Open-ended products where the agent surface is the dominant topology decision |
| `architectures/api-service` | The product's tools are exposed as an API and the agent is an API client |
| `stacks/node-typescript` | CopilotKit, A2UI client renderers (React/Lit), Next.js |
| `stacks/python` | Agent runtime (LangChain Deep Agents, LangGraph) hosted in Python |
| `management/interview-driven` | Solo or small team; design doc and risk register may be authored as monolithic artifacts |
| `delivery/prototype` | Early agent-loop iteration |
| `delivery/production-saas` | Agent ships to real users |

Does **not** conflict with any other module.

---

## Agent Behavior

When agents (developer-side, operating on the repo) edit code under this overlay's sensitive
paths, they must:

- Update the prompt-tool registry in the same commit that adds a new agent-callable action — not in a follow-up
- Surface any change that broadens the renderer contract (new component, new schema variant, new sandbox surface) as requiring explicit human review before merge
- Flag model or runtime upgrades that affect in-product agent behavior as Tier 4 and require human authorization
- Refuse to silently remove or weaken a human-in-the-loop checkpoint declared in `design.md` — if a checkpoint is wrong, propose a design-doc update first

---

## References

- A2UI v0.8 (Public Preview) — `https://a2ui.org/`, `https://github.com/google/A2UI`
- CopilotKit + AG-UI Protocol — `https://docs.copilotkit.ai/`, `https://github.com/CopilotKit/CopilotKit`
- Generative UI Global Hackathon starter (origin of the three-flavor spectrum) — `https://github.com/jerelvelarde/Generative-UI-Global-Hackathon-Starter-Kit`
- MCP Apps (Open-ended renderer in Claude desktop / ChatGPT) — see Anthropic's MCP spec and OpenAI's ChatGPT Apps documentation

---

## See Also

- [ADR-0007: Agentic Interface Awareness](../../../../docs/adr/ADR-0007-agentic-interface-awareness.md) — why this overlay exists and the domain-vs-architecture decision
- [OPP-0002: Agentic Interface Awareness](../../../../docs/opportunities/OPP-0002-agentic-interface-awareness.md) — the thesis and evidence
- [`platform/profiles/architectures/agentic-ui/`](../../architectures/agentic-ui/) — optional architecture overlay for conversational-primary topology
- [`platform/templates/agentic-interface/`](../../../templates/agentic-interface/) — required and optional artifact templates
- [`platform/skills/harness-agentic-interfaces/`](../../../skills/harness-agentic-interfaces/) — Agent Skill for agents working in agentic-UI codebases
- [`platform/workflow/agentic-interface-integration.md`](../../../workflow/agentic-interface-integration.md) — operator-facing integration guide
- [`platform/compositions/agentic-ui-saas.yaml`](../../../compositions/agentic-ui-saas.yaml) — starter composition
- [`platform/examples/sample-projects/agentic-ui-starter/`](../../../examples/sample-projects/agentic-ui-starter/) — reference layout
