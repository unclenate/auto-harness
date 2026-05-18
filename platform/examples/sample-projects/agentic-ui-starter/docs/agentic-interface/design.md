<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Agentic Interface Design — Lattice Copilot

<!-- Required by the `domains/agentic-interfaces` module. -->
<!-- Update in the same commit as any change under src/copilot/, src/agents/, src/agent-ui/, prompts/, or any copilotkit.config.* file. -->

**Owner:** @lattice-team
**Last reviewed:** 2026-05-17
**Status:** active

This document is the canonical description of the Lattice copilot — the in-product agent
that mediates analytical questions, renders charts, and triggers common product actions
(export, share, schedule) from within the Lattice SaaS web-app.

---

## 1. Flavor

- [x] **Controlled** — agent picks UI from a developer-defined React component catalog (CopilotKit-style)
- [ ] **Declarative**
- [ ] **Open-ended**
- [ ] **Conversational-primary**

**Chosen flavor:** Controlled

**Rationale:** The product has an existing React/Next.js UI. The copilot is a sidebar
feature, not the dominant surface. A closed component catalog gives reviewers the highest-
fidelity audit of what the agent can render, and CopilotKit's AG-UI Protocol gives us
runtime portability if we add a second client later.

---

## 2. Agent Runtime

| Question | Answer |
|----------|--------|
| Where does the agent loop execute? | SERVER — Next.js route handler at `/api/copilot/runtime` |
| What model(s) does it call? | Claude Sonnet 4.7 (primary), GPT-5 mini (fallback for cost-sensitive paths) |
| What framework drives the loop? | CopilotKit runtime v1.57.x (pinned in package.json) |
| Is conversation state persisted? Where? | Yes — per-user threads in Postgres (`conversation_threads`, `conversation_turns`) |
| Is the system prompt or any credential visible to the client? | No — runtime is server-side; client receives streamed model output and rendered components only |

**Trust-belongs-on-the-server check:** The agent runtime never executes in the browser.
The system prompt, tool definitions, and any API credentials needed for tool invocation
live exclusively in the server-side runtime. The browser receives the rendered output of
CopilotKit components, not the raw model context.

---

## 3. Action Surface

The set of product actions the copilot can invoke. Canonical list lives in
`docs/agentic-interface/prompt-tool-registry.md` (to be authored as the tool surface grows).

| Question | Answer |
|----------|--------|
| Does the agent invoke actions as the user (same auth) or as a service principal (different auth)? | As the user — every tool call is authorized against the same session that authenticated the user |
| Are tool calls logged? Where? | Yes — `tool_invocations` table in Postgres, retained 90 days |
| Is there a deny-by-default policy on new tools? | Yes — the runtime maintains the authoritative tool allowlist; a tool not in the allowlist returns an error to the model regardless of any `useCopilotAction` registration that might exist |
| Are any tools Tier 3 or higher? | Yes — `send-share-email`, `export-to-third-party-storage`. Both require explicit user confirmation in a structured UI element |

---

## 4. Renderer Contract

**Catalog / schema / sandbox boundary:** Closed catalog of 11 React components under
`src/copilot/components/`. Each component is registered with CopilotKit at runtime startup;
no off-catalog component can be rendered.

**Can the agent render UI affordances for actions it is not authorized to invoke?**
No. Every action component (Confirm, Approve, Export) verifies the underlying tool is in
the runtime tool allowlist at render time. If the allowlist check fails, the component
renders a disabled state with an error notice, not a clickable affordance.

**Rendering threat model:**

- Controlled: catalog drift, hallucinated affordances → mitigated by runtime allowlist check at render time and by the component-manifest review gate (renderer contract changes require an ADR)

(No Declarative or Open-ended surface in v1.)

---

## 5. State Model

| Question | Answer |
|----------|--------|
| Who owns conversation state? | Postgres — server-side; the client holds only the in-flight thread for display |
| Who owns the tool-call audit log? | Postgres `tool_invocations` table — server-side, write-only from the runtime |
| What state is shared between the agent and the UI? | The user's currently-open chart/dashboard (via `useCopilotReadable`). No PII fields are made readable |
| What state is shared with external systems? | Vector store (Pinecone) for retrieval-augmented question answering over the user's own analytics docs |

---

## 6. Human-in-the-Loop Checkpoints

Every checkpoint here is enforced at the runtime layer (not only the UI layer). Drift
between this section and code is a Tier-3-or-higher governance failure.

| Checkpoint | Trigger | UI surface | Persisted? |
|-----------|---------|-----------|-----------|
| Send-share confirmation | Agent invokes `send-share-email` | CopilotKit `Confirm` component showing recipient list, subject preview, and "Send" / "Cancel" | Yes — into `tool_invocations` with the user's explicit-confirm timestamp |
| Export confirmation | Agent invokes `export-to-third-party-storage` | CopilotKit `Confirm` component showing target destination, file count, and "Export" / "Cancel" | Yes — same table |
| Schedule confirmation | Agent invokes `schedule-recurring-report` | CopilotKit `Confirm` component showing cadence, recipients, and report scope | Yes — same table |

**Default-deny actions** — actions the agent *never* invokes without an explicit user confirmation in the current session:

- `send-share-email`
- `export-to-third-party-storage`
- `schedule-recurring-report`
- `delete-saved-view`

---

## 7. Prompt-Injection Defense Surface

| Defense layer | Description |
|--------------|-------------|
| System prompt isolation | System prompt is server-side only. User input enters as `user` role; tool results enter as `tool` role wrapped in `<untrusted_source>` tags |
| Tool-result sanitization | Vector-store retrieval results and any web-search results are wrapped in `<untrusted_source>` tags with explicit instructions in the system prompt that contents are data, not instructions |
| Tool-allowlist enforcement | CopilotKit runtime maintains the authoritative tool allowlist. Model-emitted tool calls for unknown tools return an error to the model, not silent failure |
| Output rendering allowlist | All rendered components are from the closed catalog. Markdown rendering uses a strict allowlist of tags |
| Confirmation step for destructive actions | All Tier-3 tools render a structured `Confirm` component. Free-text "I'd like to send" never invokes the tool |

**Known limitations:**

- A sophisticated prompt-injection payload could still cause the agent to *propose* a Tier-3 tool call that the user might then approve out of context confusion. Defense relies on the structured `Confirm` UI showing the actual payload, not the conversational claim about the payload.
- Vector-store retrieval over user-uploaded documents is the highest-risk surface. We have not yet shipped a payload-scanner; tracked as AI-001 in the risk register.

---

## 8. Model and Runtime Upgrade Posture

| Question | Answer |
|----------|--------|
| How are model changes rolled out? | Canary at 5% for 24h, then 25% for 24h, then full |
| Is there a rollback path? | Yes — model version is a runtime config value with a documented previous-version pin |
| Are there golden interactions verified before each rollout? | Yes — 30-interaction set at `tests/copilot/golden-set/`. Run in CI for every PR that touches `src/copilot/` or `copilotkit.config.ts` |
| Who owns the upgrade decision? | @lattice-team |

---

## 9. Vendor Appendix (informational only)

**CopilotKit version:** 1.57.x (pinned in package.json)
**Documentation reference:** https://docs.copilotkit.ai/
**Notable vendor-specific risks or quirks:**

- CopilotKit ships frequently; treat every major bump as a Tier-4 deployment
- AG-UI Protocol changes affect transport behavior; review the changelog of any version bump
- `useCopilotAction`'s `handler` return value can include a `confirm: true` directive — we use this for all Tier-3 tools

---

## 10. References

- `platform/profiles/domains/agentic-interfaces/README.md`
- `docs/agentic-interface/risk-register.md`
- A2UI — `https://a2ui.org/` (not currently in use; reference for future cross-client expansion)
- CopilotKit — `https://docs.copilotkit.ai/`
