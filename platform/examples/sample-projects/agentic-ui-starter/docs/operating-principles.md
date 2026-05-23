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

Small-team operating principles for a SaaS web-app that ships an in-product agentic interface.

- **Design doc is the source of truth for the agent surface.** `docs/agentic-interface/design.md` describes what the in-product agent is, what it can call, what it can render, and what guardrails bound it. If the doc does not name a tool, the agent does not have that tool.
- **Tool registry stays current.** When a new agent-callable action is added under `src/copilot/`, the prompt-tool registry (once present) is updated in the same commit. The companion rule from `domains/agentic-interfaces` enforces this; the human-review gate confirms the tier classification.
- **Renderer contract is a permission system.** Broadening the catalog/schema/sandbox boundary is a Tier-4 change requiring explicit human review, the same way moving validation logic into the browser is a Tier-4 change. It is not a refactor.
- **HITL checkpoints are not optional.** Every checkpoint declared in `design.md` § 6 must be enforced in code at the runtime layer (not the UI layer). A UI-only confirmation can be bypassed.
- **Untrusted tool results are untrusted.** Web searches, retrieved documents, third-party API responses re-enter the model context wrapped — not as plain prompt input.
- **Model and runtime version are pinned.** No vendor auto-upgrade. Bumps go through a PR with the golden-set interactions run and the changelog reviewed.
- **Two agent surfaces.** Developer-side agents (Claude Code, etc.) operate on the codebase under `agents/base` discipline. The Lattice copilot operates on the user under `domains/agentic-interfaces` discipline. Do not conflate them.
