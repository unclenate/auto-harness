<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Renderer Contract

<!-- Source: platform/profiles/domains/agentic-interfaces/ -->
<!-- This document is optional but effectively required for Declarative and Open-ended flavors. -->
<!-- Update in the same commit as any change under src/renderer/, src/agent-components/, src/agent-actions/, or any renderer.manifest.* / component.catalog.* file. -->
<!-- This is the agent's permission system for the UI layer. Treat changes here with the same rigor as changes to an API authorization check. -->

**Owner:** [[AGENT_SURFACE_OWNER]]
**Last reviewed:** YYYY-MM-DD
**Flavor:** [[FLAVOR]] (allowed: CONTROLLED, DECLARATIVE, OPEN_ENDED, CONVERSATIONAL_PRIMARY)
**Renderer version:** [[VERSION]]

---

## Boundary Statement

In one paragraph: what is the renderer allowed to render, and what is it not allowed to
render? This statement is the contract — the rest of the doc concretizes it.

> [[BOUNDARY_PARAGRAPH]]

---

## Section A — Controlled flavor (CopilotKit-style)

Fill this section if the flavor is Controlled. Otherwise skip to Section B / C / D.

**Component catalog source of truth:** [[FILE_OR_DIR]]

| Component | Purpose | Props the agent can set | Props the agent cannot set | Approval gating |
| --------- | ------- | ------------------------ | -------------------------- | --------------- |
| [[COMPONENT_NAME]] | [[WHAT_IT_IS]] | [[ALLOWED_PROPS]] | [[FORBIDDEN_PROPS]] | [[NONE \| INLINE_CONFIRM \| etc]] |

**Rules:**

- The agent may only render components from this catalog. Off-catalog component rendering must fail closed.
- A component that wraps a tool invocation must verify the tool is in the prompt-tool registry at render time, not at invocation time. (Prevents hallucinated affordances.)
- No catalog component renders content via mechanisms that bypass framework HTML escaping unless the rendered payload is explicitly sanitized.

---

## Section B — Declarative flavor (A2UI-style)

Fill this section if the flavor is Declarative. Otherwise skip.

**Schema source of truth:** [[A2UI_VERSION_OR_SPEC_URL]]
**Client renderers in use:** [[WEB_RENDERER \| FLUTTER_RENDERER \| OTHER]]
**Client component catalog:** [[FILE_OR_DIR]]

| Schema component | Mapped to | Constraints | Approval gating |
| ---------------- | --------- | ----------- | --------------- |
| [[SCHEMA_COMPONENT]] | [[NATIVE_WIDGET]] | [[VALIDATION_RULES]] | [[NONE \| INLINE_CONFIRM \| etc]] |

**Rules:**

- The schema validator runs server-side on every agent message before transport to the client.
- Unknown schema components fail closed — they are dropped, not rendered as a fallback.
- Version pinning: the agent and the client renderer must agree on the schema version. Document the pinning policy below.

**Version-skew handling:** [[POLICY]]

---

## Section C — Open-ended flavor (MCP-Apps-style)

Fill this section if the flavor is Open-ended. Otherwise skip.

**Sandbox technology:** [[IFRAME \| WEBVIEW \| MCP_APP_CONTAINER \| WASM \| OTHER]]
**Sandbox configuration:**

```text
[[CONCRETE_SANDBOX_CONFIG — iframe sandbox attrs, CSP header, container scope, WASM imports]]
```

**Permitted from inside the sandbox:**

- [[CAPABILITY_1 — e.g. read display dimensions]]
- [[CAPABILITY_2]]

**Forbidden from inside the sandbox:**

- Top-level navigation (the sandbox cannot redirect the host)
- Cross-origin requests outside the explicit allowlist
- Access to host cookies, storage, or credentials
- [[OTHER_FORBIDDEN_CAPABILITIES]]

**Allowlist of permitted external origins (for fetch / link):**

- [[ORIGIN_1]]
- [[ORIGIN_2]]

**Threat model notes:**

- A successful prompt injection that produces hostile HTML must not escape the sandbox.
- A successful sandbox-escape must not yield credentials.
- The user must be able to identify when content is sandbox-rendered (visual indicator).

---

## Section D — Conversational-primary flavor

Fill this section if the flavor is Conversational-primary. Otherwise skip.

The renderer contract for this flavor is the chat UI itself. Document:

- What markdown features the renderer supports (code, tables, math, embedded media)
- What attachments the agent can emit (files, structured cards, tool-result widgets)
- What attribution UI is rendered (citations, source links, model name + version)
- What "ambient" UI elements are present (input box, voice toggle, thread sidebar)
- How HITL checkpoints are rendered inside the chat stream

**Citations and attribution UI:** [[DESCRIBE]]

**Model-version surfacing to the user:** [[ALWAYS_VISIBLE \| ON_DEMAND \| NEVER_VISIBLE]]

---

## Cross-Flavor Rules

These apply regardless of flavor:

1. The renderer never escalates the agent's privileges. A rendered Confirm button does not authorize the underlying action — the runtime tool allowlist does.
2. The renderer never silently extends the catalog. New components require a renderer-contract update in the same commit.
3. The renderer logs every rendered fragment (or a sampled subset) for audit and regression-detection.
4. The renderer surfaces model output that fails validation as an error to the user, not as a silent fallback.

---

## Reference

| Resource | Path |
| -------- | ---- |
| Module README | `platform/profiles/domains/agentic-interfaces/README.md` |
| Design doc | `docs/agentic-interface/design.md` |
| Prompt-tool registry | `docs/agentic-interface/prompt-tool-registry.md` |
| Risk register | `docs/agentic-interface/risk-register.md` |
| A2UI spec | `https://a2ui.org/` |
| CopilotKit | `https://docs.copilotkit.ai/` |
| MCP spec | `https://modelcontextprotocol.io/` |
