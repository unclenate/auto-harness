<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Full Plan — Team Knowledge Base MCP Server

A decision-complete plan: scope, milestones, dependencies, and trade-offs in one file.

## Milestones

1. **Week 1 — Scaffold + server-spec.** TypeScript project bootstrap, MCP SDK installation, `docs/mcp/server-spec.md` filled, `harness.manifest.yaml` validates green.
2. **Week 2 — Tool 1 (`search_kb_articles`, Tier 0).** Stdio transport working end-to-end against MCP Inspector. Risk register R-MCP-001 (prompt injection via search result) covered by AC-1 test.
3. **Week 3 — Tool 2 (`save_kb_draft`, Tier 2).** Per-user draft scoping. Companion-rule wired: tool-registry update paired with risk register.
4. **Week 4 — Tool 3 (`broadcast_kb_update`, Tier 3).** Audit logging on every call. Explicit consumer-side approval-gating recommendation in tool registry. Tier rationale reviewed.
5. **Week 5 — Hardening + npm publish.** Prompt-injection test plan covers AC-1, AC-2, AC-3. Risk register all 12 canonical risks have owners and status. Publish.

## Dependencies

- **MCP TypeScript SDK** (`@modelcontextprotocol/sdk`). Pinned in `package.json`. SDK upgrades trigger the companion rule on `package.json` and require a re-run of the prompt-injection test plan.
- **Knowledge-base backend.** Single endpoint, server-supplied credentials, accessed via the server's own OAuth client. Not the consumer's credentials.
- **MCP Inspector** for interactive testing during development.

## Trade-offs

- **stdio over HTTP for v1.** Simpler distribution, no OAuth surface, no SSRF risk on metadata. Loses multi-tenant deployment — explicitly out of scope per PRD.
- **No sampling, no subscriptions.** Removes two whole categories of consumer-side surprise (privacy posture on sampling prompts, subscription state management). Will revisit if a real consumer need surfaces.
- **Static tool list (`tools.listChanged: false`).** Removes capability-negotiation drift risk (R-MCP-003). Loses dynamic capability based on user permission — acceptable for v1.
- **Three tools, not thirty.** Each new tool requires a tier argument, a registry entry, and risk coverage. Three is enough to demonstrate the discipline. Future tools are governed by the same module.

## Companion-Rule Awareness

The `architectures/mcp-server` module's companion rules will fire on:

- Changes to `docs/mcp/tool-registry.md` or `docs/mcp/capability-schema.md` — risk-register update or ADR required in the same commit.
- Changes to anything under `src/mcp/` — same pairing required.
- Changes to `docs/mcp/transport-and-auth.md` — risk-register update or ADR required.

When the milestone work above adds tools, the milestones explicitly include the paired risk-register or ADR update.
