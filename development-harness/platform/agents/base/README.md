# Agent Pack: Base

This pack defines the minimum cross-agent contract shared by Claude Code and other AI tooling.
Every agent operating in a harness-governed project must satisfy this contract, regardless of
which specific tool is used.

---

## What This Pack Requires

**`AGENTS.md`** at the project root.

`AGENTS.md` is the cross-agent operating manual. It tells any AI tool — Claude Code, Cursor,
Copilot, a custom agent — the same things:

- What trust tier the agent operates at by default
- What actions are in scope and out of scope
- Where to find canonical artifacts (HARNESS.md, requirements, architecture docs)
- What requires human authorization before proceeding
- What stop conditions apply (when to halt and surface to a human)

The file must exist before any agent session begins. An agent operating without `AGENTS.md`
has no contract and no governance.

---

## Trust Tier Model

The kernel defines six action tiers (0–5). The base agent pack operates at Tier 2 by default
(workspace mutation — reading, writing, editing files) and must escalate for higher tiers:

| Tier | Actions | Authorization |
|------|---------|--------------|
| 0 | Read-only inspection | Always permitted |
| 1 | Local analysis, no writes | Always permitted |
| 2 | Workspace mutation (file edits) | Default agent scope |
| 3 | Git-writing (commits, branches) | Requires explicit instruction |
| 4 | Environment-altering (installs, migrations, deploys) | Requires human authorization |
| 5 | Remote/production (production deploys, credential changes) | Requires human authorization + named owner |

---

## Review Gate

Agent packs define boundaries; humans still approve tier escalation and sensitive changes.
The base pack establishes the floor — tool-specific packs (`claude-code`, `generic-llm`)
may add constraints but cannot remove them.

---

## Relationship to Other Agent Packs

`claude-code` and `generic-llm` both depend on `base`. They extend the contract with
tool-specific entrypoints (`CLAUDE.md`, `.claude/settings.json`) but inherit all base
pack rules. The base pack governs what applies universally; tool packs govern what is
specific to one agent's configuration.
