<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# HARNESS.md

This sample project demonstrates a harness-governed **MCP-server-producing**
project. It models a hypothetical "team-knowledge-base MCP server" with three
exemplar tools that span trust tiers:

- `search_kb_articles` — Tier 0 read
- `save_kb_draft` — Tier 2 workspace write
- `broadcast_kb_update` — Tier 3 cross-team shared-state write

The project uses the modular harness manifest at `harness.manifest.yaml` and
composes these modules:

- `kernel/base` — governance floor
- `stacks/node-typescript` — TypeScript implementation
- `architectures/mcp-server` — MCP-producer architecture overlay (the focus of
  this sample)
- `delivery/prototype` — early-validation delivery posture
- `management/interview-driven` — monolithic-docs management overlay
- `agents/base` — base agent pack

The MCP-specific governance artifacts live under `docs/mcp/`:

- `docs/mcp/server-spec.md` — server identity, capabilities, transport, auth
- `docs/mcp/tool-registry.md` — the three exemplar tools with tier mappings
- `docs/mcp/risk-register.md` — MCP-specific risks for this server
- `docs/mcp/transport-and-auth.md` — stdio posture (HTTP not used in v1)
- `docs/mcp/capability-schema.md` — declared capabilities matrix
- `docs/mcp/prompt-injection-test-plan.md` — coverage for AC-1 through AC-3
  (AC-4 N/A — sampling not used)

The management overlay's monolithic-doc artifacts live at the project root:

- `docs/PRD.md` — the single product requirements document
- `docs/full-plan.md` — the decision-complete plan

See:

- [`platform/profiles/architectures/mcp-server/README.md`](../../profiles/architectures/mcp-server/README.md) — the architecture module's philosophy and usage
- [`platform/workflow/mcp-server-build.md`](../../workflow/mcp-server-build.md) — operator workflow
- [ADR-0008: MCP Awareness](../../../docs/adr/ADR-0008-mcp-awareness.md) — design rationale
