<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Agent Pack: Codex CLI

This pack adapts the cross-agent contract from `agents/base` to OpenAI's Codex CLI.
Codex reads `AGENTS.md` natively, so this pack does **not** require a separate shim file —
`AGENTS.md` already serves as the project context. The pack exists to declare Codex's
unique controls (`approval_policy`, `sandbox_mode`, `AGENTS.override.md` precedence) and
the harness rules that govern them.

Compose this pack when the project will be worked from Codex CLI sessions with project-
or team-specific approval or sandbox configuration. For ad-hoc Codex CLI use without
project-local config, `agents/base` plus `AGENTS.md` is sufficient.

Status: version 0.1.0. The pack is R&D — refine based on field experience before
promoting to 1.0.

---

## What This Pack Requires

`AGENTS.md` is already required by `agents/base`. This pack does not add a required
artifact — Codex reads `AGENTS.md` directly, walking from the Git root down to the current
working directory and concatenating each `AGENTS.md` it finds (with later files
overriding earlier ones).

**Optional: `.codex/config.toml`**

When the project needs to lock down Codex's default `approval_policy` or `sandbox_mode`,
commit a project-local `.codex/config.toml`:

```toml
approval_policy = "on-request"
sandbox_mode = "workspace-write"
```

This is the Tier 2 default — Codex prompts for shell commands but executes file edits
inside the workspace sandbox. Other valid combinations:

- `approval_policy = "untrusted"` + `sandbox_mode = "read-only"` — Tier 0–1 only
- `approval_policy = "never"` + `sandbox_mode = "workspace-write"` — `--full-auto` equivalent
- `approval_policy = "never"` + `sandbox_mode = "danger-full-access"` — **prohibited
  outside disposable environments**; see review gate

**Optional: `CODEX.md`**

A `CODEX.md` shim is *not* recommended for most projects — Codex already reads `AGENTS.md`,
and adding `CODEX.md` creates a drift surface that companion rules then have to police.
Adopt `CODEX.md` only if your team needs Codex-specific guidance that meaningfully diverges
from the cross-agent contract and cannot live in `AGENTS.md` itself.

---

## `AGENTS.override.md` is prohibited in the repository

Codex CLI reads `AGENTS.override.md` *before* `AGENTS.md` at every level of its file walk
and lets the override win. If `AGENTS.override.md` is committed, it silently overrides the
project's governance contract for every Codex user. The harness treats this as a Tier 4+
configuration change.

**Mitigations:**

1. Add `AGENTS.override.md` to the project's `.gitignore`
2. The companion rule fires if `AGENTS.override.md` ever appears in a change set —
   reviewers must verify it is local-only and remove it from the index before merge

---

## Approval mode and sandbox mapping

| Codex setting | Harness tier scope | Notes |
| ------------- | ------------------ | ----- |
| `approval_policy=untrusted` + `sandbox_mode=read-only` | Tier 0–1 | Read-only inspection; safe default for first contact |
| `approval_policy=on-request` + `sandbox_mode=workspace-write` (`--full-auto`) | Tier 2 | Workspace mutation with shell-command prompts |
| `approval_policy=never` + `sandbox_mode=workspace-write` | Tier 2–3 | Acceptable in CI; risky on a developer workstation with git credentials |
| `sandbox_mode=danger-full-access` (any approval policy) | Tier 4+ | Prohibited outside disposable environments — Docker, CI runner, ephemeral VM |
| `approval_policy=never` + `sandbox_mode=danger-full-access` | Tier 5 | Equivalent to handing the agent root shell on the host |

---

## Companion Rule

Changes to `.codex/`, `CODEX.md`, or the appearance of `AGENTS.override.md` trigger a
companion rule requiring `AGENTS.md`, an ADR, or a PRD to also be updated. Any relaxation
of `approval_policy` or `sandbox_mode` is in scope for the rule.

Review gates:

- *"approval_policy=never combined with sandbox_mode=danger-full-access is prohibited
  outside disposable environments."*
- *"AGENTS.override.md must not be committed — Codex lets it silently win over
  AGENTS.md."*

---

## Relationship to `agents/base`

`codex-cli` depends on `base`. The base pack governs trust tiers and stop conditions
universally via `AGENTS.md`. This pack adds the Codex-specific surface: configuration,
sandbox policy, and the `AGENTS.override.md` exclusion. Remove this pack if the project
does not use Codex CLI; keep `base` regardless.

---

## References

- Codex CLI `AGENTS.md` loader: <https://developers.openai.com/codex/guides/agents-md>
- Codex CLI sandboxing: <https://developers.openai.com/codex/concepts/sandboxing>
- Codex CLI agent approvals and security: <https://developers.openai.com/codex/agent-approvals-security>
- Harness multi-tool coordination guide: `platform/workflow/multi-agent-tool-coordination.md`
