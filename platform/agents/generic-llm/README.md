<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Agent Pack: Generic LLM

This pack is the neutral adapter surface for non-Claude agent tooling — Cursor, Copilot,
Codeium, custom agents, or any LLM-assisted workflow that isn't Claude Code. It provides
kernel alignment without assuming any specific tool's entrypoint format.

---

## What This Pack Requires

No required artifacts beyond what `agents/base` requires (`AGENTS.md`).

`AGENTS.md` is the operative governance document for generic LLM tooling. Unlike Claude Code,
there is no standardized startup file or settings format across tools. `AGENTS.md` serves as
the portable contract that any tool can be pointed at.

---

## How to Use This Pack

For tools that support a startup or context file (Cursor's `.cursorrules`, Copilot instructions,
etc.), that file should direct the tool to read `AGENTS.md` as the authoritative operating
contract. The tool-specific file is a pointer, not a replacement.

For tools that do not support a startup file, `AGENTS.md` should be included in the context
window manually at the start of each session.

---

## Trust Tier Alignment

Generic LLM tools must respect the same trust tier model as Claude Code. The kernel defines
the tiers — the tool does not change them. If a tool cannot be configured to respect tier
boundaries, its use is limited to Tier 0–2 actions (read-only and local file edits) until
a human explicitly authorizes higher-tier actions for a specific task.

Review gate: *"Generic packs must not claim permissions higher than the kernel permits."*

---

## Relationship to `agents/base`

`generic-llm` depends on `base`. Use this pack instead of `claude-code` when the primary
AI tool is not Claude Code. Use both if the project uses multiple AI tools — they can coexist,
each adding its specific entrypoint requirements on top of the shared base contract.
