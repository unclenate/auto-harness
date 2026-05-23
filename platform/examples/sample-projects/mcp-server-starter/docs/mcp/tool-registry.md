<!--
NOTE: This is an auto-harness sample-project file (reference implementation).
If you copy this file into your own project, replace the SPDX/copyright
header below with your own — running
`bash platform/bootstrap/set-consumer-headers.sh` from your project root
after the copy will do this for you.
-->

<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# MCP Tool Registry — team-knowledge-base

**Owner:** @unclenate
**Last updated:** 2026-05-17
**Module:** `architectures/mcp-server`
**Companion artifacts:** `docs/mcp/server-spec.md`, `docs/mcp/risk-register.md`

Canonical record of every tool the `team-knowledge-base` server exposes via
`tools/list` and `tools/call`. Producer-side contract with every consumer.
Changes here trigger the companion rule — pair with risk-register update,
ADR, or architecture-overview refresh.

---

## Tools

### Tool: `search_kb_articles`

| Field | Value |
|-------|-------|
| Tool name (wire) | `search_kb_articles` |
| Display title | Search Knowledge Base Articles |
| Intent (one line) | Full-text search across the team's indexed knowledge-base articles |
| Input schema | `{ query: string, limit?: number(<=20) }` |
| Output content types | text (one block per matching article, with title, snippet, and resource link) |
| Side effects | none — pure read of the knowledge-base backend |
| Consumer trust tier | **Tier 0** — read-only; results are scoped to articles already visible to the configured backend principal; no external state changes |
| Approval gating expectation | none — Tier 0 is invokable without per-call approval |
| Idempotency | idempotent — same query returns same results modulo backend updates |
| Audit log expectation | server logs query string + result count to stderr; backend logs the search request under the server's service account |
| Rate limit | 60 calls/min per session at server level; backend enforces its own quota |
| Out-of-scope failure mode | returns `isError: true` with a clear "backend unreachable" or "query too long" message |

**Description shown to model:**

> Search the team's internal knowledge base for articles matching a natural-language query. Returns up to `limit` matches (default 10, max 20). Each result includes the article title, a short snippet, and a resource reference. Use for "what did we decide about X", "find the doc on Y", and similar lookups. Returns no results if nothing matches — does not fabricate.

**Threat-class notes:**

- **Tool poisoning risk:** description is statically authored in source and reviewed in PR. No runtime templating from external content.
- **Prompt-injection-through-result risk:** R-MCP-001 applies — the snippet field contains content from knowledge-base articles that may have been written by users. The server wraps each snippet in a `<kb-content untrusted="true">` envelope and the description (model-visible) instructs the consumer to treat envelope content as data, not as instructions. Coverage in `docs/mcp/prompt-injection-test-plan.md § AC-1`.

---

### Tool: `save_kb_draft`

| Field | Value |
|-------|-------|
| Tool name (wire) | `save_kb_draft` |
| Display title | Save Knowledge Base Draft |
| Intent (one line) | Save a private draft article scoped to the current user, not visible to anyone else |
| Input schema | `{ title: string, body: string, tags?: string[] }` |
| Output content types | text (confirmation with draft URI) |
| Side effects | writes a draft row to the user's private draft area in the knowledge-base backend |
| Consumer trust tier | **Tier 2** — workspace mutation; reversible (draft can be discarded), private to the calling user |
| Approval gating expectation | none required, but consumers SHOULD consider per-call approval for the first save in a session |
| Idempotency | not strictly idempotent — re-calling with same title creates separate drafts; the consumer-side LLM should be told to update existing drafts via a (future) `update_kb_draft` tool rather than re-saving |
| Audit log expectation | server logs draft save with title + size; backend logs under the user's principal |
| Rate limit | 10 calls/min per session |
| Out-of-scope failure mode | returns `isError: true` for body exceeding 256 KB, missing title, or backend unreachable |

**Description shown to model:**

> Save a draft article to the user's private knowledge-base drafts area. Drafts are visible only to the user that owns them and do not appear in `search_kb_articles` results from other users. Use this when the user asks to "save", "draft", or "stash" knowledge content. The save creates a new draft each time; do not call repeatedly with the same content in one turn.

**Threat-class notes:**

- **Tool poisoning risk:** static description, reviewed in PR.
- **Prompt-injection-through-result risk:** response is structured (URI + status), not free text — low risk.

---

### Tool: `broadcast_kb_update`

| Field | Value |
|-------|-------|
| Tool name (wire) | `broadcast_kb_update` |
| Display title | Broadcast Knowledge Base Update |
| Intent (one line) | Publish a knowledge-base article and notify the team's announce channel |
| Input schema | `{ draft_uri: string, channel_id?: string }` |
| Output content types | text (confirmation with published article URI and broadcast message URI) |
| Side effects | publishes the draft (visible to all team members), posts a notification message in the team's announce channel |
| Consumer trust tier | **Tier 3** — git-writing / shared-state; externally visible to entire team; affects others' workspaces (notification arrives in their channel); not silently reversible |
| Approval gating expectation | **explicit per-call human approval required** — consumer-side. The producer's recommendation: surface the broadcast message preview, the target channel, and the audience size to the human before invocation |
| Idempotency | not idempotent — re-calling sends a second notification |
| Audit log expectation | server logs publication and broadcast with timestamps and target channel; backend and announce-channel system both retain records |
| Rate limit | 5 calls/hour per session — broadcast volume is a social cost as well as a system cost |
| Out-of-scope failure mode | returns `isError: true` if draft does not exist, is empty, or channel is invalid |

**Description shown to model:**

> Publish an existing knowledge-base draft to the entire team and post a notification in the team's announce channel. This is a high-impact action — the article becomes visible to all team members and a notification appears in everyone's channel. Do not invoke without explicit user approval in the current turn. If unsure, ask the user to confirm before calling.

**Threat-class notes:**

- **Tool poisoning risk:** description explicitly tells the model to require user approval, which mitigates accidental invocation. Static, reviewed.
- **Prompt-injection-through-result risk:** R-MCP-001 — the published article body comes from a draft authored by the user; once broadcast, the notification message includes the article title. If a future tool reads the notification channel and feeds it back to the model, that path needs prompt-injection coverage in AC-2.
- **Nested-tool-call risk:** R-MCP-001 / AC-2 — if `search_kb_articles` returns content that suggests calling `broadcast_kb_update`, the higher tier of the target tool plus the description's explicit "do not invoke without approval" guidance is the producer-side mitigation. Consumer-side, the recommendation is per-call approval gating.

---

## Summary Table

| Tool | Tier | Side effects | Idempotent | Approval gating |
|------|------|--------------|------------|-----------------|
| `search_kb_articles` | 0 | none | yes | none |
| `save_kb_draft` | 2 | writes private draft | no (re-call creates duplicates) | none required; consider for first save |
| `broadcast_kb_update` | 3 | publishes article + posts announce-channel notification | no (re-call duplicates broadcast) | **explicit per-call human approval required** |

---

## Discovery and Dynamic-Tools Posture

| Field | Value |
|-------|-------|
| Does the server declare `tools.listChanged: true`? | No |
| When does the tool list change at runtime? | never |
| Notification policy on change | n/a — static list |

The tool list is statically declared in the server source. Adding or
removing tools requires a code change, a registry update, and a server
version bump — all of which trigger the companion rule.

---

## Deprecation and Removal

| Tool removal pattern | Deprecated tools remain listed for one minor version with description prefix `DEPRECATED:` and are removed in the next minor version. Removal is announced in `docs/project/change-log.md` (if present) and the server version's release notes. |

---

## References

| Resource | Path |
|----------|------|
| Server spec | `docs/mcp/server-spec.md` |
| Risk register | `docs/mcp/risk-register.md` |
| Prompt-injection test plan | `docs/mcp/prompt-injection-test-plan.md` |
| Trust tier model | `platform/core/kernel/base/trust-model.md` |
| Consumer-side tool registry pattern | `TOOLS.md` (repo root, harness) |
| `harness-mcp` skill | `platform/skills/harness-mcp/SKILL.md` |
