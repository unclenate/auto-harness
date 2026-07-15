<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Agent Pack: Claude Code

This pack isolates Claude Code-specific behavior from the cross-agent contract defined by
`agents/base`. It manages startup sequence, scope control, permission adapters, and the
entrypoints Claude Code reads at session start.

Status: stable as of v0.5.0. This is the reference adapter pack — the harness itself is
authored under it — and is in active production use.

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

**Optional: `.claude/hooks/distillation-prompt.sh`**

A `Stop`-event hook that prompts the agent when the current branch carries
distillation-worthy work (new/modified ADR, OPP, module manifest, or
active-module catalog change relative to base) and no knowledge destination
has been touched in the same branch yet. Silent otherwise — it does **not**
fire on every Stop turn, only at end-of-session-on-a-feature-branch-with-
work. Per PRD-0035 it also **scaffolds** an ADR-0002-shaped inert stub (six
fields, `Context` and the attribution date pre-filled from git context,
judgement fields as fill-tokens) and writes a copy to a gitignored
`.claude/drafts/` file, so the agent fills a correct skeleton instead of
recalling the schema; the stub is inert until filled (it fails
`validate-observation-hygiene` and `validate-placeholders`). The in-session
counterpart to the PR-boundary companion rule on `management/knowledge-capture`
(see PRD-0004 / PRD-0035 + `platform/workflow/cycle-end-distillation.md`).

Reference implementation lives at
`platform/examples/sample-projects/node-web-saas-postgres/.claude/hooks/distillation-prompt.sh`.
Recommended for projects running both `agents/claude-code` and
`management/knowledge-capture` modules; projects running only one of the
two get partial value (the hook still works without `knowledge-capture`,
but the rule it complements is not active).

To install, copy the script to your project's `.claude/hooks/` directory
(`chmod +x` it) and register it in `.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [{ "type": "command", "command": ".claude/hooks/distillation-prompt.sh" }]
      }
    ]
  }
}
```

Override the base branch via `HARNESS_BASE_BRANCH` env var if your project
uses something other than `main` (e.g., `master`, `trunk`).

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
