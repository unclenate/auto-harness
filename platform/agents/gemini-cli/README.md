<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Agent Pack: Gemini CLI

This pack adapts the cross-agent contract from `agents/base` to Google's Gemini CLI.
It declares the `GEMINI.md` shim, optional `.gemini/settings.json` overrides, and the
companion rule that keeps Gemini's hierarchical context system aligned with the harness
tier model.

Compose this pack when the project will be worked from Gemini CLI sessions. If Gemini CLI
is used only occasionally without project-specific configuration, `agents/generic-llm`
plus `AGENTS.md` is sufficient — only adopt this pack when the project needs to declare
sandbox or approval-mode constraints.

Status: version 0.1.0. The pack is R&D — refine based on field experience before
promoting to 1.0.

---

## What This Pack Requires

This pack requires **either** a `GEMINI.md` shim **or** a `.gemini/settings.json` that
points `context.fileName` at `AGENTS.md`. Either path satisfies the module's required
artifact — pick one and stay with it; do not maintain both surfaces in parallel.

The two integration paths:

### Path A — `GEMINI.md` shim at the project root

`GEMINI.md` is Gemini CLI's default hierarchical context file. The CLI concatenates
context from `~/.gemini/GEMINI.md` (user-global), all `GEMINI.md` files between the
workspace root and the current working directory, and (just-in-time) any `GEMINI.md`
discovered when a tool accesses a specific directory.

In a harness-governed project, the workspace-root `GEMINI.md` is the **Gemini CLI shim**.
It must:

1. Reference `AGENTS.md` as the operative governance contract — every trust-tier rule
   lives there, not here
2. Explicitly reassert the harness's stop conditions (the user's global
   `~/.gemini/GEMINI.md` is concatenated into context and may otherwise override them)
3. Declare the project's sandbox / approval-mode posture (see "Approval-mode mapping" below)

Keep the shim short. A long `GEMINI.md` competes with `AGENTS.md` for authority and
creates a drift surface that companion rules then have to police.

Because Gemini walks subdirectories looking for nested `GEMINI.md` files, the sensitive
path / companion rule in this pack matches `GEMINI.md` at **any depth**, not only the
root. A nested `GEMINI.md` that re-introduces policy a parent file had removed is in
scope for review.

### Path B — `.gemini/settings.json` with `context.fileName: ["AGENTS.md"]` (shim-free)

When the project prefers a single source of truth and does not want a `GEMINI.md` shim,
commit a `.gemini/settings.json` that points Gemini CLI directly at `AGENTS.md`:

```json
{
  "context": {
    "fileName": ["AGENTS.md"]
  }
}
```

Per Gemini CLI's configuration reference
(<https://geminicli.com/docs/reference/configuration/>), `context.fileName` accepts an
array of file names that override the default `GEMINI.md` lookup. With this setting in
place, no `GEMINI.md` is needed — `AGENTS.md` plays both roles. This is the cleanest
integration when the project already runs an `AGENTS.md`-first governance model and the
shim would otherwise be a near-empty forwarder.

If the team wants Gemini to load *both* files (for example to keep tool-specific notes in
`GEMINI.md` while letting `AGENTS.md` carry the governance contract), use
`["AGENTS.md", "GEMINI.md"]`. In that case keep the `GEMINI.md` shim as well — Path A
governs it.

The module declares its required artifact as `oneOf: [GEMINI.md, .gemini/settings.json]`,
so either path satisfies validation. The harness does not prefer one approach — pick the
one that matches how your team mentally models project context, and document the choice
in `AGENTS.md`.

---

## Approval-mode mapping

Gemini CLI's approval modes translate to harness trust tiers as follows:

| Gemini CLI mode | Harness tier scope | Notes |
| --------------- | ------------------ | ----- |
| `default` (prompt per tool call) | Tier 0–2 (interactive) | The safe default for a developer workstation |
| `auto_edit` | Tier 2 (workspace mutation) | Edit tools auto-approve; shell commands still prompt |
| `yolo` / `--yolo` | Tier 4+ unless sandboxed | Prohibited outside the official sandbox Docker image; use only in disposable environments |

The shim should state which mode is permitted by default in this project and which
require human authorization to enable.

---

## Companion Rule

Changes to `GEMINI.md` or `.gemini/` trigger a companion rule requiring `AGENTS.md`,
an ADR, or a PRD to also be updated. Any change that relaxes approval-mode policy or
expands sandbox permissions is in scope for the rule.

Review gate: *"GEMINI.md must defer to AGENTS.md for trust-tier rules and stop
conditions."*

---

## Relationship to `agents/base`

`gemini-cli` depends on `base`. The base pack governs trust tiers and stop conditions
universally. This pack adds the Gemini-specific surface: hierarchical context, approval
modes, sandbox image policy. Remove this pack if the project does not use Gemini CLI; keep
`base` regardless.

---

## References

- Gemini CLI context files: <https://geminicli.com/docs/cli/gemini-md/>
- Gemini CLI configuration (`context.fileName`): <https://geminicli.com/docs/reference/configuration/>
- Harness multi-tool coordination guide: `platform/workflow/multi-agent-tool-coordination.md`
