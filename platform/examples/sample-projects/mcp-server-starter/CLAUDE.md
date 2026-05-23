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

# CLAUDE.md

Claude Code must read:

1. `HARNESS.md`
2. `AGENTS.md`
3. this file
4. `docs/PRD.md` — the monolithic product requirements document
5. `docs/full-plan.md` — the decision-complete plan
6. `docs/mcp/server-spec.md` — server identity, capabilities, transport, auth
7. `docs/mcp/tool-registry.md` — exposed tools with consumer-tier mapping
8. `docs/mcp/risk-register.md` — MCP-specific risks for this server

Load the `harness-mcp` skill when working on anything under `docs/mcp/` or
`src/mcp/`. Load `harness-governance` for tier and lifecycle questions.

When implementing tools:

- Treat `docs/mcp/tool-registry.md` as the source of truth for what the
  server exposes. Code and registry must agree.
- Argue the tier per tool. A `delete_*` or `broadcast_*` at Tier 0 or 1 is
  not acceptable.
- If a tool returns externally-influenced content, ensure
  `docs/mcp/prompt-injection-test-plan.md` covers it.

When changing capabilities or transport:

- Update `docs/mcp/capability-schema.md` and `docs/mcp/transport-and-auth.md`
  in the same commit as the code change.
- Pair with `docs/mcp/risk-register.md` or an ADR per the companion rule.
