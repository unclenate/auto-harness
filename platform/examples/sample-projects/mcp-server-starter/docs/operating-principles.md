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

# Operating Principles

Small-team operating principles for an MCP-server-producing project at prototype tier.

- **The tool registry is the contract.** `docs/mcp/tool-registry.md` is the source of truth for every tool the server exposes. Code that diverges from the registry is a bug, not a feature.
- **Tier mapping is reasoned, not boxed.** Every tool carries a one-line tier rationale. A `delete_*` tool at Tier 0 is rejected on review. A `read_*` tool at Tier 5 is rejected on review.
- **Capability declarations are honest.** What the server declares in `initialize` must match runtime behavior. Declaring `listChanged` without emitting notifications misleads consumers; emitting without declaring is a spec violation.
- **Token passthrough is forbidden.** Inbound tokens whose audience is not this server are rejected. Upstream API calls use the server's own credentials.
- **Prompt injection through tool results is the threat model.** Tools that return externally-influenced content must envelope or sanitize that content; `docs/mcp/prompt-injection-test-plan.md` covers AC-1 through AC-4 as applicable.
- **PRD is the source of truth.** All scope, intent, and constraints flow from `docs/PRD.md`. If the PRD does not say it, it does not ship.
- **Plan stays decision-complete.** `docs/full-plan.md` must reflect every PRD change.
- **Out-of-scope is named explicitly.** Unnamed scope expands during prototyping.
