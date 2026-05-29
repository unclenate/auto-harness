<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Agent Pack: Base

This pack defines the minimum cross-agent contract shared by Claude Code and other AI tooling.
Every agent operating in a harness-governed project must satisfy this contract, regardless of
which specific tool is used.

Status: stable as of v0.5.0. This pack defines the cross-agent contract and is the foundation
all other agent packs depend on; its shape is not expected to churn.

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

## Halt Before Bypass

When a governance control is unavailable or failing, an agent MUST halt and surface the
blocker to a human. Bypassing, skipping, or working around a failed control is equivalent
to bypassing the trust tier that control enforces.

This rule applies to — but is not limited to:

- **Commit signing** — if `commit.gpgsign=true` is configured and signing fails (e.g., the
  signing helper is unavailable or the credential store is locked), do not use
  `--no-gpg-sign` or `-c commit.gpgsign=false` to work around it. Halt and report.
- **Pre-commit hooks** — if a hook fails, do not use `--no-verify`. Fix the underlying
  issue or halt.
- **CI validators** — if a validator starts failing and the cause is not immediately
  obvious, do not disable the validator or add it to a skip list. Halt and report.
- **Companion rules** — if a companion rule would need to be removed or bypassed to
  land a change, the change is out of scope without explicit human direction.
- **Review gates** — if a change would bypass a declared `reviewGates` entry, halt.

The principle: a control that is inconvenient in the moment exists because a past
human decided it mattered. Agents do not have standing to override that decision.
Surface the conflict; let the human decide whether the control still applies.

**What "halt and surface" means in practice:**

- Stop the task at the point of failure
- Report: what was being attempted, what control failed, what the error was, what
  options exist (fix the control, wait for it to be available, modify the approach
  to not need it)
- Do not continue until a human has explicitly directed next steps

This rule is a **kernel-tier floor** — tool-specific agent packs may add further halt
conditions but cannot remove this one.

---

## Relationship to Other Agent Packs

`claude-code` and `generic-llm` both depend on `base`. They extend the contract with
tool-specific entrypoints (`CLAUDE.md`, `.claude/settings.json`) but inherit all base
pack rules. The base pack governs what applies universally; tool packs govern what is
specific to one agent's configuration.
