<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Agent Pack: Copilot CLI

This pack adapts the cross-agent contract from `agents/base` to GitHub Copilot CLI.
Copilot CLI reads `AGENTS.md` natively (as primary instructions) and also reads any
`.github/copilot-instructions.md`, `.github/instructions/*.instructions.md`, `CLAUDE.md`,
and `GEMINI.md` files it finds — and resolution between conflicting instructions is
documented by GitHub as non-deterministic.

The pack exists primarily to manage that conflict surface. The default recommendation is
**do not add Copilot-specific instruction files in addition to `AGENTS.md`** — let the
single shared contract drive the agent. Adopt `.github/copilot-instructions.md` only when
the project needs Copilot-specific guidance that cannot live in `AGENTS.md`.

Status: version 0.1.0. The pack is R&D — refine based on field experience before
promoting to 1.0.

---

## What This Pack Requires

`AGENTS.md` is already required by `agents/base` and is treated by Copilot CLI as the
primary instruction surface. This pack does not add a required artifact.

**Optional: `.github/copilot-instructions.md`**

Use only when the project needs Copilot-specific instructions that genuinely diverge from
the cross-agent contract — for example, a GitHub-flavored review workflow that does not
apply to other tools. The file should explicitly defer to `AGENTS.md` on every governance
question (tiers, scope, stop conditions) and add only the Copilot-specific layer.

If the file restates anything that is also in `AGENTS.md`, you have created a drift
liability that the companion rule will flag on every change. Prefer to put the rule in
`AGENTS.md` once.

**Optional: `.github/instructions/*.instructions.md`**

Path-scoped Copilot instructions. Same rules apply — defer to `AGENTS.md`, add only the
path-specific layer.

**Optional: `.github/agents/`**

Custom Copilot CLI agents (Explore, Task, and any project-defined sub-agents). Each
custom agent must declare its default tool access and the trust tier it operates at.
The review gate fires if a custom agent's tool access exceeds what `AGENTS.md` permits.

---

## Multi-instruction-file conflict policy

When `AGENTS.md`, `.github/copilot-instructions.md`, and any `CLAUDE.md` / `GEMINI.md` all
exist, Copilot CLI's resolution between conflicting instructions is non-deterministic.
The harness's position:

1. **`AGENTS.md` is authoritative.** Every other instruction file in the repository must
   defer to it on tiers, scope, and stop conditions.
2. **Minimize overlap.** A rule that appears in two places will eventually diverge. Pick
   one home — `AGENTS.md` by default — and link to it from the others.
3. **No silent overrides.** A Copilot-specific instruction that would change agent
   behavior in a way `AGENTS.md` does not anticipate is a governance change and goes
   through the companion rule.

---

## Approval mapping

Copilot CLI's session model is per-prompt confirmation with two built-in sub-agents:

| Copilot surface | Harness tier scope | Notes |
| --------------- | ------------------ | ----- |
| Explore sub-agent | Tier 0–1 | Read-only codebase analysis; safe to delegate |
| Task sub-agent | Tier 2–3 | Edits, builds, tests; treat as Tier 3 when it invokes `gh` for PRs |
| Custom CLI agent | Declared by the agent | Custom agents must declare their tier; review gate enforces |
| `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` env var | Outside repo governance | A user setting this var can inject instructions the harness does not see — document the prohibition in `AGENTS.md` |

---

## Companion Rule

Changes to `.github/copilot-instructions.md`, `.github/instructions/`,
`.github/agents/`, `CLAUDE.md`, or `GEMINI.md` trigger a companion rule requiring
`AGENTS.md`, an ADR, or a PRD to also be updated. `CLAUDE.md` and `GEMINI.md` are
included because Copilot CLI also reads them at the repo root
([source](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions)),
so they are part of the same multi-file conflict surface this pack governs.

Review gates:

- *"Copilot CLI instruction files must not contradict AGENTS.md — when both exist,
  Copilot's resolution is non-deterministic."*
- *"Custom Copilot CLI agents under `.github/agents/` must declare their default
  tool access and tier scope."*

---

## Relationship to `agents/base`

`copilot-cli` depends on `base`. The base pack governs trust tiers and stop conditions
universally via `AGENTS.md`. This pack adds the Copilot-specific surface: instruction
file precedence management, custom CLI agents, and the `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`
exclusion. Remove this pack if the project does not use Copilot CLI; keep `base`
regardless.

---

## References

- GitHub Copilot CLI custom instructions: <https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions>
- Creating custom agents for Copilot CLI: <https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-custom-agents-for-cli>
- Copilot coding agent + AGENTS.md announcement: <https://github.blog/changelog/2025-08-28-copilot-coding-agent-now-supports-agents-md-custom-instructions/>
- Harness multi-tool coordination guide: `platform/workflow/multi-agent-tool-coordination.md`
