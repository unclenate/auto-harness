<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Architecture Overlay: Agentic UI

This overlay covers products where the **agentic surface is the dominant topology decision** —
the agent runtime, the action surface, and the renderer contract are the load-bearing
architectural choices, not features layered onto a web-app or api-service topology.

It is the right overlay for:

- **Conversational-primary products** — the chat box *is* the product (ChatGPT-style, Claude desktop apps)
- **MCP-host shells** — the product is a host for MCP Apps that render UI inside a sandboxed container
- **Open-ended generative-UI products** — the agent's output is rendered as raw HTML / Markdown inside a sandbox, and the sandbox boundary is the central topology question
- **Pure agent-native apps** with no traditional UI surface to layer onto

It is **not** the right overlay for:

- A SaaS web-app that adds a copilot sidebar (use `architectures/web-app + domains/agentic-interfaces`)
- A web product that embeds a CopilotKit panel as one of many features (same as above)
- An API service that exposes tools to an external agent (use `architectures/api-service + domains/agentic-interfaces`)

The rule of thumb: if removing the agent surface would leave a coherent product, you don't
need this overlay. If removing the agent surface would leave nothing, you do.

---

## What This Overlay Governs

**Required artifact:** `docs/architecture/overview.md`

The architecture overview must explicitly answer:

1. **Where does the agent runtime execute?** Browser, edge, server, dedicated worker. Trust-belongs-on-the-server applies to the agent runtime: running prompt assembly in the browser exposes the system prompt and any inlined credentials.
2. **What is the action surface boundary?** What authorization check does the agent cross to invoke a product action? Is it the same boundary the user crosses, or a parallel one with different rules?
3. **What is the renderer contract?** Controlled (component catalog), Declarative (schema → catalog), Open-ended (raw HTML in a sandbox)? What is the catalog or sandbox boundary?
4. **What is the state model?** Who owns conversation state — the client, the server, a separate state store, the agent runtime?
5. **What is the human-in-the-loop topology?** Where in the loop does the agent pause for confirmation? Where are confirmations rendered? Where are they persisted?

This is additive to whatever `web-app` or `api-service` require if either is also composed —
the architecture overview must answer the agentic-UI questions *in addition to* the
web-app or api-service questions, not instead of.

---

## Core Rule: The Agent Runtime Is a Trust Boundary

The non-negotiable governance principle for this architecture:

> The agent runtime is a privilege boundary. Moving it closer to the user (server → edge,
> edge → browser) without an ADR is the agentic-UI analog of moving validation logic into
> browser code. The system prompt, the tool definitions, and any credentials in scope at
> runtime are exposed to whoever can read the runtime's memory.

This is enforced by the first review gate:
*"Human review is required for any change that moves the agent runtime closer to the user."*

---

## Why This Is an Overlay, Not a Replacement

This overlay does not replace `web-app` or `api-service`. It adds the agentic-UI topology
layer. The expected configurations are:

| Configuration | When |
|---------------|------|
| `architectures/agentic-ui` alone | Pure agent-native app, no traditional UI surface; conversational-primary; MCP-host shell |
| `architectures/agentic-ui + architectures/web-app` | Product has a real browser UI *and* the agent surface is dominant — e.g. Claude desktop's chat + canvas pattern |
| `architectures/agentic-ui + architectures/api-service` | Pure agent serves over an API; multiple clients render |

Always pair with `domains/agentic-interfaces`. The architecture overlay covers topology;
the domain overlay covers the design doc, risk register, prompt-tool registry, and renderer
contract artifacts. They are designed to be active together for this class of product.

---

## How This Overlay Composes

| Pair with | When |
|-----------|------|
| `domains/agentic-interfaces` | Always — they are designed to compose |
| `architectures/web-app` | Product has a real browser UI in addition to the agent surface |
| `architectures/api-service` | The agent serves over an API and multiple clients render |
| `stacks/node-typescript` | React/Lit renderers, CopilotKit, AG-UI Protocol |
| `stacks/python` | Agent runtime hosted in Python (LangChain Deep Agents, LangGraph) |
| `data/relational-postgres` | Conversation state, persistent threads, tool-call audit log |
| `delivery/prototype` | Early agent-loop iteration |
| `delivery/production-saas` | Agent ships to real users |

Does **not** conflict with any other module.

---

## Architecture Overview Expectations

The required `docs/architecture/overview.md` should answer the standard web-app/api-service
topology questions plus these agentic-UI-specific ones:

- Where is the agent loop executing on each request? (Single canonical location, or distributed?)
- What is the trust boundary the agent crosses to call a tool? (Same auth as the user? Service-account auth? Separate scopes?)
- What is the renderer contract? Catalog name and version, schema spec and version, sandbox configuration (CSP, iframe-sandbox attrs, MCP App container scope).
- What is the threat model for the renderer? Specifically: can the agent emit a component, schema fragment, or HTML payload that escapes the intended boundary?
- What is the audit posture? Are tool calls logged? Are model outputs persisted? For how long?
- What is the model/runtime upgrade posture? How are model changes rolled out? Is there a canary path? A rollback path?

Use the template at `platform/templates/architecture-overview.md` as the base, then add an
"Agentic UI topology" section answering the above. The design doc at
`docs/agentic-interface/design.md` (required by `domains/agentic-interfaces`) covers the
*surface* design; this architecture overview covers the *topology*.

---

## Agent Behavior

Agents operating under this overlay must treat:

- Any change that moves the agent runtime closer to the user as a Tier-4-or-higher action requiring explicit human authorization, *not* a refactor
- Any change to the action surface that adds a new authorization-bypass path as a Tier-4 action — the action surface is the agent's privilege boundary
- Any change to the renderer contract that broadens what the agent can render as a Tier-4 action requiring the renderer-contract artifact to be updated in the same commit
- Any model or runtime upgrade that changes in-product agent behavior as a Tier-4 deployment requiring a canary or golden-set verification before merge

---

## See Also

- [`platform/profiles/domains/agentic-interfaces/`](../../domains/agentic-interfaces/README.md) — required pair; covers design doc, risk register, prompt-tool registry, renderer contract
- [ADR-0007: Agentic Interface Awareness](../../../../docs/adr/ADR-0007-agentic-interface-awareness.md) — why this overlay exists separately from the domain
- [`platform/templates/architecture-overview.md`](../../../templates/architecture-overview.md) — base template (add an "Agentic UI topology" section)
- [`platform/workflow/agentic-interface-integration.md`](../../../workflow/agentic-interface-integration.md) — integration guide
