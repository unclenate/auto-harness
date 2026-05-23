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
4. `docs/operating-principles.md`
5. `docs/agentic-interface/design.md` (the canonical description of the in-product agent surface)
6. `docs/agentic-interface/risk-register.md` (agentic-UI-specific risks)

## In-Product Agent Discipline

This project ships an in-product agent (the Lattice copilot). When editing code under
`src/copilot/`, `src/agents/`, `src/agent-ui/`, `prompts/`, or `copilotkit.config.*`:

- **Tool additions:** update `docs/agentic-interface/prompt-tool-registry.md` (when present) in the same commit. The companion rule from `domains/agentic-interfaces` fires on these paths and is satisfied by a registry update.
- **Renderer changes:** if the change broadens the catalog/schema/sandbox boundary, update `docs/agentic-interface/renderer-contract.md` (when present) and surface as a Tier-4 review.
- **HITL drift:** any change that removes or weakens a checkpoint declared in `design.md` § 6 requires explicit human review *and* a same-commit design-doc update.
- **Model/runtime upgrades:** treat as Tier 4. Run the golden-set interactions before merge. Pin the model + framework version explicitly.

## Skill Load Order

Load these skills when starting work in this codebase:

1. `harness-governance` — always
2. `harness-agentic-interfaces` — when touching any agent-surface path

The `harness-agentic-interfaces` skill carries the three-flavor map, tool-tier discipline,
prompt-injection threat model, and renderer-contract decision tree.
