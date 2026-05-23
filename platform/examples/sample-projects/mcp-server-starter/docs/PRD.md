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

# PRD — Team Knowledge Base MCP Server

**Problem.** Small product teams accumulate knowledge — decisions, retros,
ad-hoc design notes — across Slack threads, Notion pages, and Google Docs.
When an AI agent (Claude Desktop, Cursor, an internal coding agent) needs
that context to be useful, the team has to either paste excerpts into every
conversation or grant the agent broad credentialed access to each system.
Neither scales.

**In scope (MVP).** An MCP server, distributable as an npm package and
launchable over stdio, that exposes a small, well-scoped surface over the
team's knowledge base:

- `search_kb_articles` — Tier 0 — full-text search over indexed articles
- `save_kb_draft` — Tier 2 — save a private draft article scoped to the user
- `broadcast_kb_update` — Tier 3 — publish an article to the team channel

The server connects to a single canonical knowledge-base backend (read by
the server using its own credentials, NOT credentials provided by the
client).

**Out of scope (explicit).**

- HTTP transport. v1 is stdio-only; consumers run the server locally.
- Multi-tenant SaaS deployment. v1 is single-tenant per install.
- Sampling (`sampling/createMessage`). The server does not call back into
  the consumer's LLM.
- Resource subscriptions (`resources/subscribe`). Article changes are not
  pushed to consumers.
- Cross-knowledge-base federation. One backend per server install.
- Tool list mutation at runtime. `tools.listChanged: false` is declared.

**Success metric.** A team can use Claude Desktop with this MCP server
installed and have the agent answer "what did we decide about X" by calling
`search_kb_articles`, with no other context provided in the conversation.

**Target hosts (v1).** Claude Desktop, Claude Code, VS Code (via MCP
extension), Cursor.

**Open questions.** None at PRD time. Raise as ADRs if they emerge during
implementation.
