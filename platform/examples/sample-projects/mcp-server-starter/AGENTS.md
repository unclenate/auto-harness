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

# AGENTS.md

Cross-agent operating rules are derived from the kernel trust model and the
`agents/base` agent pack declared in `harness.manifest.yaml`. This sample
co-exists with other AI platforms (Cursor, Windsurf, GitHub Copilot, OpenAI
Codex) — `install.sh` writes the harness-managed section between
`<!-- harness-managed-section -->` markers and leaves the rest of `AGENTS.md`
to the consumer.

## MCP Producer-Side Discipline (Architecture: mcp-server)

This project is an **MCP-server-producing** project. When working in it,
agents must honor the discipline established by the `architectures/mcp-server`
module and the `harness-mcp` skill:

- **Adding a tool** requires an entry in `docs/mcp/tool-registry.md` with a
  one-line argued trust tier. Defaulting to Tier 2 is a placeholder, not a
  tier mapping; the review gate rejects it.
- **Changing the tool registry, capability schema, or anything under
  `src/mcp/`** triggers the companion rule: the same commit must update
  `docs/mcp/risk-register.md`, an ADR, or `docs/architecture/overview.md`.
- **Adding a tool that returns externally-influenced content** requires
  `docs/mcp/prompt-injection-test-plan.md` coverage for AC-1 (untrusted
  string in result), and likely AC-2 (nested tool call).
- **Capability declarations** in code and `docs/mcp/capability-schema.md`
  must match. Declaring `tools.listChanged: true` but never emitting the
  notification is misleading; the inverse is a spec violation.
- **Token passthrough is forbidden** by the MCP spec. The server obtains its
  own tokens for upstream API calls. Agents proposing to forward inbound
  Bearer tokens must be told no.

## PRD / Plan Discipline (Management: interview-driven)

When the PRD or plan changes, follow the companion-rule contract from the
`interview-driven` overlay: refresh the downstream plan in the same commit so
agents and engineers do not work from a stale derivation.

## Stop Conditions

Halt and surface to the human when:

- A new tool's tier mapping cannot be argued in one sentence.
- A change to declared capabilities lacks a matching update to
  `capability-schema.md`.
- An upstream API call is being routed through an inbound client token.
- A tool returns externally-influenced content but has no coverage in the
  prompt-injection test plan.
