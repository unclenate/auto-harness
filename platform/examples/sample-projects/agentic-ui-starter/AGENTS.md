<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# AGENTS.md

Cross-agent operating rules are derived from the kernel trust model and the `agents/base`
agent pack declared in `harness.manifest.yaml`. This sample co-exists with other AI platforms
(Cursor, Windsurf, GitHub Copilot, OpenAI Codex) — `install.sh` writes the harness-managed
section between `<!-- harness-managed-section -->` markers and leaves the rest of `AGENTS.md`
to the consumer.

## Two Agent Surfaces in This Project

There are **two** distinct agent surfaces in this project. Do not conflate them.

1. **Developer-side agents** (Claude Code, Cursor, etc.) operate on the codebase. They are
   governed by `agents/base` and by the standard harness trust-tier model (0–5).
2. **The in-product agent** (the Lattice copilot, defined under `src/copilot/`) operates on
   the user. It is governed by `domains/agentic-interfaces`. Its callable tools, renderer
   contract, HITL checkpoints, and prompt-injection defenses are declared in
   `docs/agentic-interface/design.md`.

When making changes that touch `src/copilot/`, `src/agents/`, `src/agent-ui/`, `prompts/`,
or any `copilotkit.config.*`, the companion rule from `domains/agentic-interfaces` fires —
the same commit must update one of: the design doc, the risk register, the prompt-tool
registry, or a new ADR.

## Adding a New In-Product Agent Tool

The most common operation:

1. Update `docs/agentic-interface/prompt-tool-registry.md` with the new tool (one row, with tier and approval gating)
2. If the tool is Tier 3+, confirm the design doc's HITL section names a corresponding checkpoint
3. Implement the tool in `src/copilot/actions/` and register it in `src/copilot/runtime.ts`
4. If the tool's results are untrusted (external API, retrieved content), confirm the design doc's prompt-injection section names the framing applied
5. Commit. The companion rule is satisfied because the registry was updated alongside the code change.

## Skills Installed

Per `recommendedSkills` in the active modules:

- `harness-governance` — trust tiers, companion rules, lifecycle controls
- `harness-agentic-interfaces` — three-flavor map, tool-tier discipline, prompt-injection threat model, renderer-contract guidance
