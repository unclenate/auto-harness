<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Agent Pack: Claude Code

This pack isolates Claude Code-specific behavior from the cross-agent contract defined by
`agents/base`. It manages startup sequence, scope control, permission adapters, and the
entrypoints Claude Code reads at session start.

---

## What This Pack Requires

**`CLAUDE.md`** at the project root.

`CLAUDE.md` is Claude Code's startup document. It runs before any task. It should tell
Claude Code, in order of reading priority:

1. What governance files to read first (HARNESS.md, AGENTS.md)
2. What the active stack and delivery overlays declare
3. Any project-specific instructions that override default Claude Code behavior

Keep `CLAUDE.md` short and directive. It is read on every session — verbosity has a cost.

**`.claude/settings.json`**

The permission adapter. Defines which tool categories Claude Code is allowed to use without
prompting (allow list) and which are blocked unconditionally (deny list).

The deny list is the security boundary. At minimum, deny:
- Destructive commands (`rm -rf`, `git reset --hard`, `DROP TABLE`)
- Credential and secrets operations
- Any command that alters remote or production state without explicit instruction

The allow list grants frictionless access to safe operations. The sample project at
`platform/examples/sample-projects/node-web-saas-postgres/.claude/settings.json` is a
working reference.

**Optional: `.claude/hooks/log-command.sh`**

A shell hook that logs every command Claude Code executes. Useful for audit trails and
debugging agent behavior. Not required but recommended for production-posture projects.

---

## Companion Rule

Changes to `CLAUDE.md` or `.claude/` trigger a companion rule requiring `AGENTS.md` or
an ADR to also be updated. Tool-specific permission changes must be cross-referenced against
the cross-agent contract — Claude Code's permissions cannot exceed what `AGENTS.md` permits.

Review gate: *"Tool-specific allowlists must not bypass kernel tier policy."*

---

## Relationship to `agents/base`

`claude-code` depends on `base`. The base pack governs trust tiers and stop conditions
universally. This pack adds the Claude-specific surface: `CLAUDE.md` startup instructions,
`.claude/settings.json` permissions, and hooks. Remove this pack if the project uses a
different AI tool; keep `base` regardless.

---

## Startup Sequence

When Claude Code begins a session in a harness-governed project, the expected read order is:

1. `CLAUDE.md` — startup instructions and reading list
2. `HARNESS.md` — manifest summary and module overview
3. `AGENTS.md` — trust tier contract and scope boundaries
4. Active stack and delivery overlay compiled fragments

An agent that skips this sequence operates outside governance. `CLAUDE.md` should enforce
the reading order explicitly.
