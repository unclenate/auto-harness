<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# CLAUDE.md

## Claude Code Load Order — auto-harness

This file is the Claude Code entrypoint for the auto-harness repository itself
(the harness governing the harness). It is intentionally thin. The canonical
governance contract is composed from the files this one points at.

Claude Code must read, in this order:

1. [HARNESS.md](HARNESS.md) — active modules, governance artifacts, source of truth
2. [AGENTS.md](AGENTS.md) — cross-agent operating manual, trust tier model, scope, stop conditions, first-session workflow
3. this file
4. [TOOLS.md](TOOLS.md) — environment-specific tool registry (load on demand when invoking MCP developer tools)
5. [docs/operating-principles.md](docs/operating-principles.md) — how the harness platform itself is built and evolved
6. The skills referenced under "Skills" in `AGENTS.md` — load on demand per task

## When to load which harness skill

Skills live at `platform/skills/<name>/SKILL.md` and are loaded on demand by
the client when their description matches the active task:

- **`harness-governance`** — any task touching `platform/core/kernel/`, `platform/profiles/**/module.yaml`, validators, or the trust tier discussion
- **`harness-onboarding`** — repository assessment, brownfield onboarding, gap analysis, lite-manifest generation
- **`harness-testing`** — only when the consumer project has the `testing-standard` management overlay active
- **`harness-web3`** — only when consumer project has any `domains/web3` module active
- **`harness-tools`** — when working with the MCP developer tool surface (Linear, Slack, Calendar, Gmail, Canva, Ahrefs, Similarweb) on a project that has `agents/openclaw` active
- **`harness-agentic-interfaces`** — when working in a consumer project that ships an in-product agent surface (`domains/agentic-interfaces` active)
- **`harness-mcp`** — when working in a consumer project that produces its own MCP server (`architectures/mcp-server` active)
- **`harness-digital-twin`** — only when the consumer project has the `management/digital-twin` overlay active (twin-profile maturity ladder, scenario epistemic-discipline contract)

## Companion-Rule Reflex

When editing files in this repository, watch for governance entrypoint changes:

- Edits to `HARNESS.md`, `AGENTS.md`, or this file require either an ADR under `docs/adr/` or an update to `docs/operating-principles.md` in the **same commit**.
- Edits to `platform/profiles/**/module.yaml` (companion rules, required artifacts, sensitive paths) require a `docs/project/change-log.md` entry or an ADR in the same commit.
- Any new module added to the active catalog must propagate to `HARNESS.md` Active Modules, `SUMMARY.md`, `README.md` Module System table, `platform/skills/harness-onboarding/SKILL.md`, and `platform/workflow/discovery-to-composition.md` in the same pass (see `docs/operating-principles.md` § 3).

## What this file is not

This file is **not** an alternative governance source. It does not override or
shortcut `HARNESS.md` or `AGENTS.md`. It exists so Claude Code has a
predictable load order at the root of the repo — nothing more.

For the Claude-Code-specific behavior overlay (command permissions, hook
configuration, settings), the canonical source is the `agents/claude-code`
module: [`platform/agents/claude-code/`](platform/agents/claude-code/README.md).
