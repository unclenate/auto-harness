<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Agent Pack: Cursor

This pack adapts the cross-agent contract from `agents/base` to the Cursor IDE. Cursor
reads `AGENTS.md` natively (root and subdirectories), reads the legacy `.cursorrules`
file if present, and reads the modern `.cursor/rules/<name>/RULE.md` structure. The pack
exists to govern the Auto-Run allowlist (Cursor's main divergence from per-action approval
prompts) and to keep `.cursor/rules` entries aligned with `AGENTS.md`.

Compose this pack when the project will be worked from Cursor with project-local rules or
when the team uses Auto-Run mode. For ad-hoc Cursor use against the project, `agents/base`
plus `AGENTS.md` is sufficient.

Status: version 0.1.0. The pack is R&D — refine based on field experience before
promoting to 1.0.

---

## What This Pack Requires

`AGENTS.md` is already required by `agents/base` and is read by Cursor natively. This
pack does not add a required artifact.

**Optional: `.cursor/rules/`**

The modern Cursor rules directory. Each rule lives in `.cursor/rules/<rule-name>/RULE.md`
with optional supporting files. Rules supplement `AGENTS.md` — they do not replace it.
Every rule in `.cursor/rules/` must:

1. Defer to `AGENTS.md` on any governance question
2. Stay scoped to its declared file globs or contexts
3. Not relax trust-tier policy

**Optional: `.cursorrules`**

The legacy single-file format. Still supported by Cursor but slated for deprecation.
For new projects, prefer `.cursor/rules/`. For existing projects, migrate incrementally —
do not maintain both `.cursorrules` and overlapping `.cursor/rules/` entries.

---

## Auto-Run allowlist policy

Cursor's Auto-Run mode auto-approves command execution that matches an explicit
allowlist. The harness's position:

- **An empty allowlist is prohibited for shared repositories.** A team member enabling
  Auto-Run with an empty allowlist effectively grants Cursor unsupervised command
  execution against the workspace; whether that triggers prompts at all depends on IDE
  version.
- **The allowlist contents must be committed at `.cursor/rules/auto-run-allowlist.mdc`.**
  Cursor does not publish a canonical project-local path for the Auto-Run allowlist —
  it ships as an IDE preference by default. The harness's convention is to write the
  team-agreed allowlist as a Cursor rule file (`.mdc` so it carries frontmatter and is
  picked up by Cursor's project-rules system at `.cursor/rules/`, per
  <https://cursor.com/docs/rules>). This makes the allowlist version-controlled,
  reviewable, and cross-referenceable from `AGENTS.md`. Reviewers verify the file does
  not list commands that would escalate beyond Tier 2 (workspace mutation) without
  prompts — examples to avoid: `git push`, `npm publish`, anything that touches remote
  infrastructure. Team members still need to mirror the file's contents into their
  Cursor IDE preferences for the auto-approval to take effect; the committed file is
  the source of truth and the review surface, not the runtime configuration itself.
- **Auto-Run does not change tier policy.** A command on the allowlist still operates at
  its declared tier; the allowlist only suppresses the per-call prompt. Tier 3+ commands
  on the allowlist are a configuration error.

---

## Approval mapping

| Cursor mode | Harness tier scope | Notes |
| ----------- | ------------------ | ----- |
| Agent mode, manual approval | Tier 0–2 (interactive) | Default; safe for general work |
| Agent mode, Auto-Run with allowlist | Tier 2 within allowlist; Tier 0–1 elsewhere | Allowlist must be documented and reviewed |
| Auto-Run with empty / undocumented allowlist | Tier 3+ effective scope | Prohibited for shared repositories |
| Inline edit / Composer | Tier 2 (workspace mutation) | Single-buffer edits — tracked by normal review |

---

## Companion Rule

Changes to `.cursor/` or `.cursorrules` trigger a companion rule requiring `AGENTS.md`,
an ADR, or a PRD to also be updated. Auto-Run allowlist changes are in scope for the
rule.

Review gates:

- *"Cursor Auto-Run mode requires an explicit, documented allowlist — empty allowlist is
  prohibited for shared repositories."*
- *"`.cursor/rules` entries must defer to `AGENTS.md` for trust-tier rules and stop
  conditions."*

---

## Relationship to `agents/base`

`cursor` depends on `base`. The base pack governs trust tiers and stop conditions
universally via `AGENTS.md`. This pack adds the Cursor-specific surface: `.cursor/rules`
governance and Auto-Run allowlist policy. Remove this pack if the project does not use
Cursor; keep `base` regardless.

---

## References

- Cursor rules and AGENTS.md: <https://cursor.com/docs/rules>
- Cursor CLI usage: <https://cursor.com/docs/cli/using>
- Cursor agent overview: <https://docs.cursor.com/agent>
- Harness multi-tool coordination guide: `platform/workflow/multi-agent-tool-coordination.md`
