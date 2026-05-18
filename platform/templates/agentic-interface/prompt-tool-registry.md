<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Prompt-Tool Registry

<!-- Source: platform/profiles/domains/agentic-interfaces/ -->
<!-- This document is optional but strongly recommended once the in-product agent has more than 2-3 callable tools or any tool with side effects. -->
<!-- Update in the same commit as any change that adds, removes, or changes the side-effect surface of an agent-callable tool. -->
<!-- This file is the in-product equivalent of TOOLS.md (which governs developer-agent MCP tools). -->

**Owner:** [[AGENT_SURFACE_OWNER]]
**Last reviewed:** YYYY-MM-DD
**Agent runtime version:** [[RUNTIME_VERSION]]
**Model:** [[MODEL_NAME_AND_VERSION]]

This document is the canonical list of tools the in-product agent can invoke. Reviewers
use this to verify trust-tier discipline. The harness companion rule fires when agent
surface paths change; the rule is satisfied (in part) by updating this file.

---

## Tool Registry

One row per tool. Tier follows the harness Tier 0–5 model (`platform/core/kernel/base/trust-model.md`).

| Tool ID | Surface | Side effects | Tier | Approval gating | Owner | Status |
| ------- | ------- | ------------ | ---- | --------------- | ----- | ------ |
| [[TOOL_ID]] | [[FRONTEND \| BACKEND \| MCP_SERVER \| EXTERNAL_API]] | [[NONE \| READ_ONLY \| WRITES_X \| SENDS_X]] | 0 / 1 / 2 / 3 / 4 / 5 | [[NONE \| INLINE_CONFIRM \| EXPLICIT_USER_AUTH \| HUMAN_REVIEW]] | [[OWNER]] | active / deprecated / draft |

**Tier discipline reminders:**

- **Tier 0** — read-only against state already visible to the user (search visible items, read calendar the user already opened)
- **Tier 1** — local analysis with no user-visible side effects (run a search, summarize, classify)
- **Tier 2** — workspace mutation visible to the user (create a draft, edit a doc the user owns)
- **Tier 3** — externally visible / shared state (send email, post message, create a calendar event, update a Linear issue)
- **Tier 4** — environment-altering (install, configure, migrate). Rare for in-product agents — flag explicitly if you have one
- **Tier 5** — production / irreversible (deploy, payment, contract sign, blockchain write). Almost certainly out of scope for an in-product agent — if you have one, surface it in `design.md` and adopt the gating from the relevant domain

---

## Approval Gating Patterns

The "Approval gating" column should pick one:

| Pattern | When to use |
|---------|-------------|
| `none` | Tier 0–1 only. Read-only / local analysis. |
| `inline-confirm` | Tier 2 with low blast radius. Agent renders a Confirm button before invoking; the same UI surface shows what will happen. |
| `explicit-user-auth` | Tier 3. Confirmation rendered in a structured UI element (not a free-text reply) showing target, payload, and consequence. User clicks. |
| `human-review` | Tier 4–5. Action is queued, not invoked; a human reviewer (the user or a designated reviewer) inspects and approves out-of-band before invocation. |

A tool whose row says Tier 3 + `none` is a governance failure, not a design choice.

---

## Default-Deny Actions

Actions the agent *never* invokes without an explicit user confirmation in the current
session, regardless of conversational context. Mirror this list in `design.md` §6.

- [[ACTION_1]]
- [[ACTION_2]]

---

## Tool-Result Trust Notes

For each tool whose results re-enter the model context, document the trust posture:

| Tool ID | Result trust | Sanitization step |
| ------- | ------------ | ----------------- |
| [[TOOL_ID]] | [[TRUSTED \| UNTRUSTED \| MIXED]] | [[HOW_RESULT_IS_FRAMED_BEFORE_RE-ENTERING_MODEL_CONTEXT]] |

A tool result is **untrusted** if it includes any content authored outside the project's trust
boundary — web pages, retrieved documents, third-party API responses, user-provided files.
Prompt injection rides on untrusted tool results. Untrusted results must be framed (separate
role, explicit wrapper) so the model treats their content as data, not instructions.

---

## Change Log

Append a row whenever this registry changes. The companion rule depends on this file being
updated alongside agent-code changes.

| Date | Change | PR | Reviewer |
| ---- | ------ | -- | -------- |
| YYYY-MM-DD | [[CHANGE_DESCRIPTION]] | [[PR_LINK]] | [[REVIEWER]] |

---

## Reference

| Resource | Path |
| -------- | ---- |
| Module README | `platform/profiles/domains/agentic-interfaces/README.md` |
| Design doc | `docs/agentic-interface/design.md` |
| Risk register | `docs/agentic-interface/risk-register.md` |
| Renderer contract | `docs/agentic-interface/renderer-contract.md` |
| Trust model | `platform/core/kernel/base/trust-model.md` |
| TOOLS.md (developer-agent equivalent) | `TOOLS.md` |
