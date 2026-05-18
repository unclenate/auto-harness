---
name: harness-agentic-interfaces
description: "Use when working in a harness-governed project that ships an in-product agentic interface — copilots (CopilotKit-style), generative UI (A2UI-style), or conversational-primary surfaces (MCP Apps, ChatGPT Apps). Covers the three-flavor map (Controlled / Declarative / Open-ended / Conversational-primary), tier discipline for agent-callable actions, prompt-injection and generative-UI threat model, renderer-contract decision guidance, CopilotKit vs A2UI vs MCP-Apps vs custom selection, and how human-in-the-loop checkpoints declared in the design doc are kept in sync with code."
license: Apache-2.0
compatibility: "For Claude Code and OpenClaw sessions in projects with domains/agentic-interfaces declared in harness.manifest.yaml."
metadata:
  harness-module: domains/agentic-interfaces
  format-version: "1.0"
---

# Harness Agentic Interfaces

This skill governs how to work in a project that ships an **in-product agentic interface** —
a copilot panel, a generative-UI surface, an MCP-host shell, or a conversational-primary
product. It complements `harness-governance` (which covers trust tiers, companion rules,
and lifecycle controls in general) and is **specific to the in-product agent surface**.

**Critical distinction:** This skill is about *the product's agent operating on the user*.
It is not about *the developer's agent operating on the codebase* — that is governed by
`agents/base`, `agents/openclaw`, and `harness-tools`.

## The Three-Flavor Map (Plus One)

Every agentic interface picks a point on this spectrum. The flavor determines the renderer
contract and the dominant risk surface.

| Flavor | What it looks like | Canonical stack | Renderer contract type |
|--------|--------------------|-----------------|------------------------|
| **Controlled** | Agent picks from a developer-defined React component catalog | CopilotKit + React | Closed catalog; agent selects |
| **Declarative** | Agent emits a JSON schema; client maps to native widgets from an approved catalog | A2UI v0.8, AG-UI Protocol | Schema → catalog map |
| **Open-ended** | Agent emits raw HTML / Markdown rendered in a sandbox | MCP Apps in Claude desktop / ChatGPT Apps | Sandbox boundary |
| **Conversational-primary** | The product *is* the chat; UI emerges from the conversation | ChatGPT-style, Claude desktop, MCP-host shells | The chat UI itself |

**Hybrid is expected.** A SaaS product may have a Controlled copilot sidebar (CopilotKit)
*and* an Open-ended MCP-App entrypoint. The design doc handles multiple flavors with one
renderer-contract section each.

## Decision Guidance: Picking the Stack

When the team has not yet picked a stack, the heuristics are:

| If ... | Lean toward |
|--------|-------------|
| The product has an existing React/Next.js UI and the agent is a feature | **Controlled — CopilotKit**. Tight integration with existing components; uses the AG-UI Protocol for runtime portability. |
| The product needs the *same* agent surface to render across web, mobile, and desktop | **Declarative — A2UI**. Schema-based; client-side renderers in Lit/Flutter; React/SwiftUI/Compose planned. v0.8 is preview — pin the version. |
| The product is delivered as an app inside a host (Claude desktop, ChatGPT, IDE) | **Open-ended — MCP Apps**. The host enforces the sandbox; the product ships the agent + the renderer payload. |
| The product *is* the chat — there is no surrounding application | **Conversational-primary**. Decide separately whether to host your own surface (web app or PWA) or to ship inside a host (MCP / ChatGPT). |
| Three or more clients need the same agent | **Declarative**, plus accept the v0.8-preview risk |
| Only one client, and it's React, and time-to-ship is dominant | **Controlled**, with CopilotKit if you want the AG-UI ecosystem; custom if you want minimal dependencies |

**Never tell the team "use vendor X" without surfacing the renderer-contract implications.**
The renderer contract is the agent's permission system for the UI layer; vendor choice is
the implementation, not the contract.

## Tier Discipline for Agent-Callable Actions

The harness Tier 0–5 model applies to the in-product agent the same way it applies to the
developer-side agent. A tool's tier is determined by its real-world side effects, not by
how easy it is to invoke from the chat box.

| Tool side effect | Tier | Required approval gating |
|------------------|------|--------------------------|
| Read state already visible to the user (search visible items, summarize current page) | 0 | None |
| Local analysis with no externally-visible effect (classify, score, summarize) | 1 | None |
| Workspace mutation visible to the user (create draft, edit doc the user owns) | 2 | Inline confirm |
| Externally visible / shared (send email, post message, create calendar event, update Linear) | **3** | **Explicit user auth via structured UI element** |
| Environment-altering (install, configure, migrate) | 4 | Human review out-of-band |
| Production / irreversible (deploy, payment, contract sign, blockchain write) | 5 | Human review + second sign-off |

**Tier-3-or-higher rules for in-product agents:**

- Confirmation must be rendered in a structured UI element (a button, a confirm card) — not in a free-text reply that the user might miss
- The confirmation surface must show the *actual* target, payload, and consequence — not a paraphrase
- The confirmation must be *per-action*, not "approve all future emails to this address" by default

**Tier-4 cases for in-product agents are rare but real:** a tool that lets the agent install
an MCP server on behalf of the user, an integration that the agent can wire up, a setting
that the agent can change project-wide. Treat these the same way the developer-side trust
model treats `npm install` — human authorization required.

**Tier-5 is almost certainly out of scope** for a typical in-product agent. If your design
has one (e.g. an agent that triggers a deployment, completes a payment, signs a contract),
flag it explicitly in `design.md` and compose the relevant domain (e.g. `domains/web3` for
chain writes) so its irreversibility gates apply.

## Prompt-Injection Threat Model

Prompt injection through tool results is the dominant agentic-UI threat. The model is given
content from an external source (web page, document, API response, retrieved record) and
treats embedded instructions in that content as if they came from the user.

**Where injection lives:**

1. **Untrusted tool results** — anything retrieved from outside the project's trust boundary (web search results, documents the user uploaded, third-party API responses, RAG retrieval against indexed external content)
2. **User-provided content** — the user pastes content that contains injection (uncommon to be malicious but common to be confusing)
3. **Conversation history** — a prior turn's tool result persists in the context; a later turn re-activates it
4. **System-prompt leakage** — the system prompt or tool definitions leak (debug logs, browser-side runtime); attacker tailors injection accordingly

**Defenses to look for in code review:**

| Defense | What it looks like |
|---------|-------------------|
| Tool-result framing | Tool results are passed to the model wrapped in a separate role or explicit `<untrusted>` tags, with the system prompt explicitly telling the model not to treat their contents as instructions |
| Runtime tool allowlist | The agent runtime maintains the authoritative tool list. The model can *ask* for a tool; the runtime decides whether to invoke. A model that emits a tool call for an unknown tool gets an error, not silent failure |
| Output structure validation | Tool calls go through a structured-output validator (JSON schema). Free-text "I'd like to call tool X" never invokes a tool |
| Confirmation step for destructive actions | Tier 3+ tools require user confirmation in a structured UI element, regardless of conversational context. "The user already said yes" is not a defense against injection |
| Tool-result trust labels | Each tool's results are labeled trusted/untrusted/mixed in `prompt-tool-registry.md`. Untrusted results get framing; trusted results may not |
| Periodic injection testing | A test set of known-injection payloads is run against the agent loop on a cadence. Regressions are detected before users find them |

**If code review reveals that an LLM-routed flow has none of these, flag it.** A copilot
that calls an email-sending tool based on free-text intent extraction, with no confirmation
step and no tool-result framing, is one prompt-injection payload away from sending an
attacker-authored email.

## Generative-UI Rendering Threats

Specific to Declarative and Open-ended flavors.

**Declarative (A2UI-style):**

- Schema injection: a model emits a schema fragment that the renderer accepts but that means something different than the agent thought
- Catalog drift: the client renderer adds a component that the agent doesn't know about (or vice versa); the mapping silently mis-renders
- Version skew: agent and renderer disagree on schema version

**Open-ended (MCP-Apps-style):**

- Sandbox escape via injection (HTML that breaks out of the iframe / WebView / WASM container)
- Sandbox-permitted-but-dangerous (the sandbox permits something the design assumed it would deny — e.g. cross-origin requests to an unintended origin)
- Top-level navigation hijack (the sandbox permits the agent to redirect the host)
- Embedded-resource exfiltration (the sandbox loads attacker-controlled resources that leak data)

**The renderer-contract document is the canonical answer to what is permitted.** When
agentic-UI code is reviewed, the question is not "is this rendered output safe?" — it is
"does the renderer contract allow this rendered output?" If it does, the contract or the
rendered output is wrong.

## Human-in-the-Loop Conformance

Every HITL checkpoint declared in `design.md` § "Human-in-the-Loop Checkpoints" must be
present in code. Drift between declared and actual approval flow is a Tier-3-or-higher
governance failure, not a UX bug.

When reviewing agentic-UI code:

1. Open `docs/agentic-interface/design.md` to the HITL section
2. For each declared checkpoint, locate the code that enforces it
3. If a checkpoint cannot be located, either the design doc is stale or the code is wrong — surface explicitly, do not silently move on

When *writing* agentic-UI code:

1. If a feature requires a new HITL checkpoint, update `design.md` first
2. If a feature removes an existing HITL checkpoint, the change requires explicit human review and a design-doc update in the same commit
3. Never assume the conversational context substitutes for a checkpoint — "the user just asked me to send the email" is a model-side claim, not a UI-side confirmation

## Renderer-Contract Decision Tree

When asked to add a new agent-renderable affordance, walk this decision tree:

1. **Is this action invokable by the agent?** If no, the affordance might still be rendered, but it's not a tool — it's UI sugar. Confirm it cannot trigger an action by being clicked unexpectedly.
2. **If yes — is the underlying tool in `prompt-tool-registry.md`?** If no, add it there *first*. The companion rule fires when surface code changes; updating the registry in the same commit satisfies the rule.
3. **Is the tool Tier 3 or higher?** If yes, the affordance must include a structured confirmation step — not a free-text reply.
4. **Does the affordance involve rendering content from a tool result?** If yes — and the tool result is untrusted — the rendered content must go through the sanitization step declared in the renderer contract.
5. **Does the affordance broaden the renderer contract** (new component, new schema variant, new sandbox capability)? If yes, update `docs/agentic-interface/renderer-contract.md` in the same commit and surface the change as a Tier-4 review.

## Model and Runtime Upgrade Discipline

A model change (Claude Sonnet 4.5 → 4.7, Gemini 2.5 → 3 Flash, GPT-4o → GPT-5) or a runtime
upgrade (CopilotKit major bump, A2UI v0.8 → v0.9, AG-UI Protocol revision) can change agent
behavior without a code diff. Treat these as Tier-4 deployments:

- Model version pinned and bumped via PR (not by vendor auto-upgrade)
- Golden interaction set run before merge
- Rollback path documented
- Changelog reviewed and noted in the design doc's vendor appendix

If the project does not have a golden set, the first model/runtime upgrade is a good
forcing function to author one.

## Stop Conditions

Halt and surface to a human when:

- A new agent-callable action is being added to code without a corresponding entry in `prompt-tool-registry.md`
- A renderer change would broaden the catalog/schema/sandbox boundary without an update to `renderer-contract.md`
- An HITL checkpoint declared in `design.md` cannot be located in code
- A Tier 3+ tool is being added with no confirmation step
- A model or runtime upgrade is being made without a rollback path or a golden set
- The agent runtime is being moved from the server to the browser/edge
- An Open-ended rendering surface is being shipped without a documented sandbox boundary

## Relationship to Other Skills

- **`harness-governance`** — covers trust tiers, companion rules, lifecycle controls in general. This skill applies them to in-product agent surfaces. Load both; this skill does not replace the governance skill.
- **`harness-tools`** — covers developer-agent MCP tools (Linear, Slack, Google Calendar, Gmail, Canva, Ahrefs). Distinct from this skill. The trust-tier discipline maps across, but the tool inventory does not.
- **`harness-testing`** — when this project has testing-standard active, the same testing discipline applies to the agent loop. Include the golden interaction set under that module's test plan.
- **`harness-web3`** — if your in-product agent can trigger blockchain writes, both this skill and `harness-web3` apply. The Tier 5 gates from `harness-web3` are not optional for chain-writing agents.

## Installing This Skill

```bash
cp -r platform/skills/harness-agentic-interfaces .agents/skills/
# or for Claude Code specifically:
cp -r platform/skills/harness-agentic-interfaces .claude/skills/
```

## References

- Module README — `platform/profiles/domains/agentic-interfaces/README.md`
- ADR-0007 — `docs/adr/ADR-0007-agentic-interface-awareness.md`
- OPP-0002 — `docs/opportunities/OPP-0002-agentic-interface-awareness.md`
- Workflow guide — `platform/workflow/agentic-interface-integration.md`
- A2UI — `https://a2ui.org/`, `https://github.com/google/A2UI`
- CopilotKit + AG-UI Protocol — `https://docs.copilotkit.ai/`, `https://github.com/CopilotKit/CopilotKit`
- Generative UI Global Hackathon starter — `https://github.com/jerelvelarde/Generative-UI-Global-Hackathon-Starter-Kit`
- Trust model — `platform/core/kernel/base/trust-model.md`
