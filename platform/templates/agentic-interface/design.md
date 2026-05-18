<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Agentic Interface Design

<!-- Source: platform/profiles/domains/agentic-interfaces/ -->
<!-- This document is required by the `domains/agentic-interfaces` module. -->
<!-- Update in the same commit as any change under src/agents/, src/copilot/, src/agent-ui/, src/genui/, prompts/, or any agent.config.* file. -->

**Owner:** [[AGENT_SURFACE_OWNER]]
**Last reviewed:** YYYY-MM-DD
**Status:** [[draft | active | deprecated]]

This document is the canonical description of the in-product agentic interface — what the
agent is, what it can do, what it can render, and what guardrails bound it. Reviewers and
downstream agents use this doc as the source of truth. If code disagrees with this doc,
either the doc is updated or the code is reverted.

---

## 1. Flavor

Pick one (or document a hybrid). Each flavor has a different renderer contract and a
different dominant risk surface — see `platform/profiles/domains/agentic-interfaces/README.md`.

- [ ] **Controlled** — agent picks UI from a developer-defined React component catalog (CopilotKit-style)
- [ ] **Declarative** — agent emits a schema; a client renderer maps to native widgets from an approved catalog (A2UI-style)
- [ ] **Open-ended** — agent emits raw HTML / Markdown rendered in a sandbox (MCP-Apps-style)
- [ ] **Conversational-primary** — the product *is* the chat; UI emerges from the conversation

**Chosen flavor:** [[FLAVOR]]

**Rationale (1-2 sentences):** [[WHY_THIS_FLAVOR]]

If multiple flavors are active (e.g. CopilotKit sidebar + Open-ended MCP App entrypoint),
list each below with its own subsection.

---

## 2. Agent Runtime

| Question | Answer |
|----------|--------|
| Where does the agent loop execute? | [[BROWSER \| EDGE \| SERVER \| WORKER]] |
| What model(s) does it call? | [[MODEL_LIST_WITH_VERSIONS]] |
| What framework drives the loop? | [[LANGGRAPH \| DEEP_AGENTS \| COPILOTKIT_RUNTIME \| AI_SDK \| CUSTOM]] |
| Is conversation state persisted? Where? | [[YES_WHERE \| NO_REASON]] |
| Is the system prompt or any credential visible to the client? | [[YES_AND_WHY \| NO]] |

**Trust-belongs-on-the-server check:** If the agent loop runs in the browser, the system
prompt, the tool definitions, and any credentials inlined for tool calls are visible to
anyone who can inspect the runtime memory. Document the threat model explicitly if so.

---

## 3. Action Surface

The set of product actions the agent can invoke. Maintain the canonical row-per-action
list in `docs/agentic-interface/prompt-tool-registry.md`; summarize the boundary here.

| Question | Answer |
|----------|--------|
| Does the agent invoke actions as the user (same auth) or as a service principal (different auth)? | [[AS_USER \| AS_SERVICE \| MIXED_EXPLAIN]] |
| Are tool calls logged? Where? | [[YES_WHERE \| NO_REASON]] |
| Is there a deny-by-default policy on new tools? | [[YES \| NO_EXPLAIN]] |
| Are any tools Tier 3 or higher? | [[YES_NAME_THEM \| NO]] |

---

## 4. Renderer Contract

Bounded by the chosen flavor. The canonical detail goes in
`docs/agentic-interface/renderer-contract.md`; summarize the boundary here.

**Catalog / schema / sandbox boundary:** [[CONCRETE_BOUNDARY_DESCRIPTION]]

**Can the agent render UI affordances for actions it is not authorized to invoke?**
[[NO_AND_HOW_PREVENTED \| YES_AND_WHY]]

**What is the rendering threat model?**
- Controlled: catalog drift, hallucinated affordances → [[MITIGATION]]
- Declarative: schema injection, version skew → [[MITIGATION]]
- Open-ended: generative-UI XSS, sandbox escape, agent-controlled navigation → [[MITIGATION]]

---

## 5. State Model

| Question | Answer |
|----------|--------|
| Who owns conversation state — client, server, agent runtime, separate store? | [[OWNER]] |
| Who owns the tool-call audit log? | [[OWNER]] |
| What state is shared between the agent and the UI (CopilotKit-style readable/writable state)? | [[STATE_SHAPE]] |
| What state is shared between agent and external systems (MCP servers, vector store, retrieval)? | [[EXTERNAL_STATE_SHAPE]] |

---

## 6. Human-in-the-Loop Checkpoints

Every checkpoint declared here must be present in code. Drift between declared and actual
approval flow is a Tier-3-or-higher governance failure.

| Checkpoint | Trigger | UI surface | Persisted? |
|-----------|---------|-----------|-----------|
| [[CHECKPOINT_NAME]] | [[WHEN_THE_AGENT_PAUSES]] | [[WHERE_USER_CONFIRMS]] | [[YES_NO]] |

**Default-deny actions** — actions the agent *never* invokes without an explicit user confirmation in the current session:

- [[ACTION_1]]
- [[ACTION_2]]

---

## 7. Prompt-Injection Defense Surface

Prompt injection through tool results is the dominant agentic-UI threat. Document the
defense surface explicitly.

| Defense layer | Description |
|--------------|-------------|
| System prompt isolation | [[HOW_USER_INPUT_IS_KEPT_OUT_OF_SYSTEM_PROMPT_ROLE]] |
| Tool-result sanitization | [[HOW_RETRIEVED_CONTENT_IS_FRAMED_BEFORE_THE_MODEL_SEES_IT]] |
| Tool-allowlist enforcement | [[HOW_TOOLS_ARE_GATED_AT_THE_RUNTIME_NOT_PROMPT_LEVEL]] |
| Output rendering allowlist | [[HOW_RENDERED_OUTPUT_IS_BOUNDED]] |
| Confirmation step for destructive actions | [[HOW_TOOLS_WITH_SIDE_EFFECTS_ARE_GATED]] |

**Known limitations:** [[WHAT_THIS_DESIGN_DOES_NOT_DEFEND_AGAINST]]

---

## 8. Model and Runtime Upgrade Posture

Model changes (e.g. Claude Sonnet 4.5 → 4.7, Gemini 2.5 → 3 Flash) and runtime changes
(e.g. CopilotKit major bump, A2UI v0.8 → v0.9) can alter agent behavior without a code
diff. Document the upgrade discipline.

| Question | Answer |
|----------|--------|
| How are model changes rolled out? | [[CANARY \| PERCENTAGE_ROLLOUT \| INSTANT_CUTOVER]] |
| Is there a rollback path? | [[YES_HOW \| NO_REASON]] |
| Are there golden interactions verified before each rollout? | [[YES_PATH_TO_LIST \| NO_REASON]] |
| Who owns the upgrade decision? | [[OWNER]] |

---

## 9. Vendor Appendix (informational only)

Vendor-specific implementation details go here. The rest of the doc is vendor-neutral.

**[[VENDOR_NAME]] version:** [[VERSION]]
**Documentation reference:** [[URL]]
**Notable vendor-specific risks or quirks:** [[NOTES]]

---

## 10. References

- `platform/profiles/domains/agentic-interfaces/README.md` — the module's three-flavor map and review gates
- `docs/agentic-interface/risk-register.md` — agentic-UI-specific risks
- `docs/agentic-interface/prompt-tool-registry.md` — agent-callable tools, one row per tool
- `docs/agentic-interface/renderer-contract.md` — the concrete catalog / schema / sandbox boundary
- A2UI — `https://a2ui.org/`
- CopilotKit + AG-UI Protocol — `https://docs.copilotkit.ai/`
- Generative UI Global Hackathon starter — `https://github.com/jerelvelarde/Generative-UI-Global-Hackathon-Starter-Kit`
