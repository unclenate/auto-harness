<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Agent Pack: OpenClaw

This pack extends the cross-agent contract defined by `agents/base` with the OpenClaw-specific
workspace file requirements. It declares `TOOLS.md` as the environment-specific tool registry
that OpenClaw reads to understand what MCP integrations and local devices are available, and
maps each tool to the harness trust tier it operates at.

---

## What This Pack Requires

**`TOOLS.md`** at the project root.

`TOOLS.md` is the OpenClaw environment cheat sheet. It tells the OpenClaw agent what tools
are available in this project's context — not general documentation, but a concise annotated
inventory of active MCP integrations, local devices, and environment-specific shortcuts, each
tagged with the trust tier at which they operate.

Keep `TOOLS.md` short and specific. It is loaded on demand, not on every turn, so verbosity
is less costly here than in `AGENTS.md` — but accuracy matters more. An out-of-date tool
entry is worse than a missing one.

A `TOOLS.md` template is available at `platform/templates/tools.md`.

**`AGENTS.md`** is inherited from `agents/base` and remains the operative governance document.
OpenClaw reads `AGENTS.md` as its authoritative operating contract — the same file that
Claude Code, Cursor, and other tools use.

**Optional workspace files** (`SOUL.md`, `IDENTITY.md`, `HEARTBEAT.md`, `BOOT.md`) are
declared as optional artifacts so the harness is aware of them but does not enforce their
existence. They govern OpenClaw's persona and periodic behavior; they are outside harness
governance scope but must respect kernel trust tier policy if they invoke tools or run commands.

---

## Companion Rule

Changes to `TOOLS.md`, `SOUL.md`, or `BOOT.md` trigger a companion rule requiring `AGENTS.md`
or an ADR to also be updated. Workspace file changes that grant new tool access or relax tier
constraints must be cross-referenced against the cross-agent contract.

Review gate: *"OpenClaw workspace permissions must not exceed kernel tier policy."*

---

## Relationship to `agents/base`

`openclaw` depends on `base`. The base pack governs trust tiers and stop conditions
universally via `AGENTS.md`. This pack adds the OpenClaw-specific surface: `TOOLS.md` as
the tool registry and the optional personality workspace files. Remove this pack if the project
does not use OpenClaw; keep `base` regardless.

---

## Startup Sequence

When OpenClaw begins a session in a harness-governed project, the expected read order is:

1. `AGENTS.md` — trust tier contract, scope, stop conditions (from `agents/base`)
2. `HARNESS.md` — active modules and governance artifact map
3. `TOOLS.md` — available MCP tools and local environment capabilities (on demand)

An agent that invokes tools without consulting `TOOLS.md` for tier requirements operates
outside governance. `AGENTS.md` should direct OpenClaw to read `TOOLS.md` before using
any MCP integration.

---

## Trust Tier Alignment for MCP Tools

MCP developer tools are subject to the same six-tier model as all other agent actions.
The distinction that matters most for tool use:

| Tier | Applies to |
| ---- | ---------- |
| 0 | Reading data from any tool API (Linear issues, Slack channels, Ahrefs metrics) |
| 2 | Creating or editing content within a private workspace (Linear docs, Canva designs) |
| 3 | Actions visible to others or that affect shared state (Slack messages, Linear issue status changes, calendar invites, emails) |
| 4 | Tool configuration or permission changes |
| 5 | Anything touching production credentials or external infrastructure |

The `harness-tools` skill provides per-tool tier guidance and Linear artifact workflow
patterns. Install it alongside this pack:

```bash
cp -r platform/skills/harness-tools .agents/skills/
```
