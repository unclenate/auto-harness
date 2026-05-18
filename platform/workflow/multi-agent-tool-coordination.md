<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Multi-Agent Tool Coordination

## Why this exists

A single repository is rarely worked by a single AI tool. One engineer drives Claude Code,
another runs Gemini CLI, a third uses Codex CLI inside their IDE, and the CI pipeline
delegates to GitHub Copilot's coding agent. Each tool reads project context differently,
ships its own approval semantics, and (until recently) expected its own bespoke instruction
file. The harness's job is to make the *governance contract* — trust tiers, companion rules,
stop conditions, audit expectations — identical across every tool, while leaving each tool
free to translate that contract into its own session and permission vocabulary.

This document tells operators (a) which file conventions each major tool follows today,
(b) the harness's recommended layered convention for projects that need to support more
than one tool, (c) how each tool's session/approval model maps to the six-tier action
model, and (d) what to do when tools genuinely disagree.

---

## Per-tool file conventions, current state

The table is current as of 2026-05. Where a cell is "evolving" or "unclear," the upstream
documentation is sparse, conflicting, or in active flight — adopt the conservative reading
described below the table.

| Tool | Project-context file | Skill loading | Session / approval model | AGENTS.md status |
| ---- | -------------------- | ------------- | ------------------------ | ---------------- |
| Claude Code | `CLAUDE.md` (root + subdirs) | `.claude/skills/` or `.agents/skills/` (Agent Skills format) | `.claude/settings.json` allow/deny lists; per-tool approval prompts | Reads `AGENTS.md` when referenced from `CLAUDE.md`; not auto-loaded |
| Gemini CLI | `GEMINI.md` (hierarchical: `~/.gemini/`, workspace, subdirs); `settings.json` can re-point `context.fileName` to `["AGENTS.md", "GEMINI.md"]` | `.agents/skills/` (Agent Skills format) | `--approval-mode` = `default` / `auto_edit` / `yolo`; sandbox via Docker image; `Ctrl+Y` toggles YOLO mid-session | Supported via configured fallback filename |
| OpenAI Codex CLI | `AGENTS.md` (native); `AGENTS.override.md` precedence; merged root-down with later files winning | Agent Skills format via `.agents/skills/` (compatible) | `approval_policy` = `untrusted` / `on-request` / `never`; `sandbox_mode` = `read-only` / `workspace-write` / `danger-full-access`; `--full-auto` is a shortcut for `on-request` + `workspace-write` | Native primary convention |
| GitHub Copilot CLI | `AGENTS.md` (primary); also reads `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, `.github/instructions/*.instructions.md`; honors `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` | Agent Skills format; custom CLI agents in `.github/copilot/agents/` | Per-prompt confirmation; explicit "Explore" / "Task" sub-agents; conflict resolution between multiple instruction files is non-deterministic — avoid overlap | Native primary convention as of 2025-08 |
| Cursor | `.cursor/rules/<name>/RULE.md` (current); `.cursorrules` (legacy, still read); `AGENTS.md` (root + subdirs, native support) | Cursor "Skills" (Agent Skills format adoption in flight); `.cursor/rules/` is the durable surface | IDE-mediated approval per tool call; Auto-Run mode auto-approves command execution within a workspace allowlist | Natively supported alongside `.cursor/rules` |
| OpenClaw | `TOOLS.md` (workspace MCP registry); `SOUL.md` / `BOOT.md` (persona/lifecycle) | ClawHub skills in `~/.openclaw/skills/` or `<project>/skills/`; Agent Skills format also accepted in `.agents/skills/` | Permission model declared in workspace files; trust tiers documented in `TOOLS.md` per entry | Reads `AGENTS.md` as the operative governance document |
| VS Code agent extensions (Copilot, Continue) | `.github/copilot-instructions.md` (Copilot), `.continue/rules/*.md` (Continue); both increasingly honor `AGENTS.md` | Continue rules live next to project; Copilot Agent Skills loaded per-IDE | IDE prompts per action; per-extension settings | Continue: convergence pending (open RFC); Copilot: supported in coding agent and CLI surfaces |
| Aider | `CONVENTIONS.md` loaded via `--read` flag or `.aider.conf.yml`; community usage of `AGENTS.md` is growing | No formal skill loader; convention-file-driven | Per-command confirmation in `--no-auto-commits` mode; `--yes-always` disables prompts | Listed as an `agents.md` supporter; loading mechanism is operator-driven (use `--read AGENTS.md`) |

Convergence: `AGENTS.md` is now stewarded by the Agentic AI Foundation (a Linux Foundation
directed fund) and is supported, in some form, by every tool in the table above. The shared
convention is real. The places where it is *not* yet universal are skill loading paths
(Agent Skills format is the de facto standard but install locations still vary) and
approval/sandbox vocabulary (each tool invents its own).

---

## The recommended layered convention

The harness adopts a three-file pattern for project context, mirroring the three-layer model
already documented in `platform/workflow/skills-and-agents.md`:

1. **`AGENTS.md`** — the shared cross-agent contract. One file, authoritative, owned by the
   `agents/base` module. Every tool either reads it natively or can be pointed at it.
2. **Per-tool shim** — an *optional* file that translates tool-specific session and approval
   semantics into the harness's trust-tier vocabulary. The shim does **not** duplicate
   `AGENTS.md`; it links to it and adds only the tool-specific overlay. Examples:
   - `CLAUDE.md` (Claude Code) — references `AGENTS.md`, points at `.claude/settings.json`
   - `GEMINI.md` (Gemini CLI) — references `AGENTS.md`, calls out YOLO-mode prohibition
     for any session not also running in the sandbox image
   - `CODEX.md` (only if the team chooses; Codex reads `AGENTS.md` natively so a separate
     shim is usually unnecessary)
   - `TOOLS.md` (OpenClaw) — already an established workspace artifact in `agents/openclaw`
3. **Skills** — Agent Skills format directories under `.agents/skills/` (cross-tool) or
   tool-native paths. Loaded on demand. Carry domain knowledge, not governance.

Create a shim file **only if the tool's approval/session model needs translation** into
tier vocabulary, or **only if the tool will not honor `AGENTS.md` without an entrypoint
file pointing at it**. A shim that just re-states `AGENTS.md` is overhead and a drift
liability — companion rules already exist to catch the case where someone edits the shim
without touching `AGENTS.md`, but the cheapest way to avoid that drift is to not write
the shim in the first place.

---

## Per-tool trust-tier mapping

The harness's six tiers (0 read-only → 5 production/credential) are the canonical
vocabulary. The translation below is how each tool's UI/CLI maps to those tiers.
Where a cell is ambiguous, use the conservative read in the right-hand column.

| Tool | Tier 0–1 (read / local analysis) | Tier 2 (workspace mutation) | Tier 3 (git-writing) | Tier 4+ (env-altering / remote) | Conservative read when unclear |
| ---- | -------------------------------- | --------------------------- | -------------------- | ------------------------------- | ------------------------------ |
| Claude Code | Default tool calls allow-listed in `.claude/settings.json`; Tier 0 actions never prompt | Edit / Write tools; prompt-gated outside the allowlist | `git commit`, `git push` — require explicit instruction; should be allow-listed only for feature branches | Bash deploy/install commands must be deny-listed unless human-authorized | Treat any tool call not in the explicit allow list as Tier 3+; halt before bypass |
| Gemini CLI | `default` approval-mode is Tier 0/1 safe — prompts before every tool call | `auto_edit` approval-mode permits Tier 2 file edits without prompt | Shell commands still prompt under `auto_edit` | `yolo` mode bypasses all prompts — Tier 4+ unless paired with the sandbox Docker image | Never run `--yolo` outside the sandbox image; treat `yolo` + no-sandbox as Tier 5 |
| Codex CLI | `approval_policy=untrusted` + `sandbox_mode=read-only` ≈ Tier 0–1 only | `sandbox_mode=workspace-write` + `approval_policy=on-request` ≈ Tier 2 (the `--full-auto` shortcut) | Commits require shell access; treat as Tier 3 even if sandbox permits | `sandbox_mode=danger-full-access` or `approval_policy=never` outside CI sandboxes ≈ Tier 4+ | Never combine `danger-full-access` with `approval_policy=never` outside a disposable environment |
| Copilot CLI | Per-prompt confirmation, "Explore" sub-agent is read-only ≈ Tier 0–1 | "Task" sub-agent edits and runs commands — Tier 2 | `gh`-mediated git operations — Tier 3 | Any command altering production state or secrets — Tier 4+ | Treat multi-instruction-file conflicts as Tier 3 — non-deterministic resolution is itself a governance risk |
| Cursor | Manual approval per tool call ≈ Tier 0–2 in normal Agent mode | Auto-Run mode within the workspace allowlist ≈ Tier 2 | Git commits and pushes prompt unless explicitly allow-listed — Tier 3 | Deploy commands, environment changes — Tier 4+ | Treat Auto-Run with an empty allowlist as Tier 3; require an explicit allowlist before granting workspace-wide auto-approval |
| OpenClaw | `TOOLS.md` tier annotations are authoritative — every MCP entry must declare its tier | Workspace file edits at Tier 2 | Slack / Linear status changes ≈ Tier 3 (see `harness-tools` skill) | Production tool configuration, secret rotation ≈ Tier 4+ | If `TOOLS.md` does not declare a tool's tier, treat as Tier 3 and surface for review |

---

## Cross-tool coordination patterns

Two engineers, one repo, different tools — the harness keeps the contract consistent
through three existing mechanisms:

1. **One `AGENTS.md`, many readers.** Every tool either loads `AGENTS.md` natively
   (Codex, Copilot CLI, Cursor), can be configured to load it (Gemini CLI via
   `context.fileName`), or has a shim that references it (Claude Code via `CLAUDE.md`,
   OpenClaw via the read order documented in `agents/openclaw/README.md`). The tier
   table in `AGENTS.md` is the single source of truth; per-tool shims describe how the
   tool's controls *honor* the table, never how they override it.
2. **Companion rules catch drift across shims.** The `claude-code` and `openclaw` modules
   already declare companion rules that fire when their tool-specific files
   (`CLAUDE.md`, `.claude/`, `TOOLS.md`) change without a matching update to `AGENTS.md`
   or an ADR. New per-tool adapter modules should follow the same pattern — see the
   `agents/claude-code/module.yaml` companion rule as the template.
3. **Validators run identically regardless of tool.** `validate-agent-pack`,
   `validate-companions`, `validate-required-artifacts`, and the rest of the validator
   chain run from `bash` and care only about repository state — not which tool was
   driving the agent. A pull request opened by a Cursor user, a Claude Code user, and
   a Codex CLI user goes through the same gate.

---

## Stop conditions and known issues

Places where tool semantics genuinely conflict with harness tier discipline:

- **YOLO / `--full-auto` / `danger-full-access` without sandboxing.** Gemini CLI's `yolo`
  mode and Codex CLI's `danger-full-access` sandbox both disable the approval prompts
  that would otherwise gate Tier 3+ actions. The harness's position: these modes are
  acceptable only inside a disposable sandbox (CI runner, Docker image, ephemeral VM).
  Running them against a developer workstation that holds production credentials is a
  Tier 5 action regardless of what the tool's UI says. Mitigation: declare the
  prohibition in the project's per-tool shim and in `AGENTS.md`'s stop-condition list.
- **Cursor Auto-Run with an empty allowlist.** Cursor's Auto-Run mode auto-approves any
  command that matches its allowlist; if the allowlist is empty, the behavior depends on
  IDE version. Mitigation: require an explicit allowlist in the project's `.cursor/`
  rules before enabling Auto-Run; document the allowlist contents in `AGENTS.md`.
- **Copilot CLI multi-instruction conflict.** When `AGENTS.md`, `.github/copilot-instructions.md`,
  and `CLAUDE.md` all exist, Copilot CLI's resolution between conflicting instructions
  is non-deterministic. Mitigation: keep the per-tool shim minimal and have it explicitly
  defer to `AGENTS.md` for any rule that could conflict.
- **Gemini CLI hierarchical merge across user-global and project files.** A user's global
  `~/.gemini/GEMINI.md` is concatenated with the project's context. A user-global
  instruction that disables a safety check will silently apply to harness-governed
  projects. Mitigation: the project's per-tool shim should explicitly reassert the
  harness's stop conditions, on the principle that a user's global config is outside the
  harness's governance scope and the project file must win on conflict.
- **Codex `AGENTS.override.md` precedence.** Codex reads `AGENTS.override.md` before
  `AGENTS.md` and lets it win. Mitigation: do not commit `AGENTS.override.md` to the
  repository; add it to `.gitignore` for projects that use Codex, and document the
  exclusion in the per-tool shim or in `AGENTS.md`.

---

## References

- AGENTS.md spec, governance, and supporter list: <https://agents.md/>
- AGENTS.md upstream repository: <https://github.com/agentsmd/agents.md>
- Gemini CLI context files (`GEMINI.md`): <https://geminicli.com/docs/cli/gemini-md/>
- Gemini CLI configuration (`context.fileName` override): <https://geminicli.com/docs/reference/configuration/>
- OpenAI Codex CLI `AGENTS.md` loader: <https://developers.openai.com/codex/guides/agents-md>
- OpenAI Codex CLI sandbox and approval modes: <https://developers.openai.com/codex/concepts/sandboxing>
- OpenAI Codex CLI agent approvals and security: <https://developers.openai.com/codex/agent-approvals-security>
- GitHub Copilot CLI custom instructions: <https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions>
- Cursor rules and AGENTS.md: <https://cursor.com/docs/rules>
- Continue rules format: <https://docs.continue.dev/customize/rules>
- Aider conventions: <https://aider.chat/docs/usage/conventions.html>
- Anthropic Agent Skills specification: <https://agentskills.io/specification>
- Harness three-layer model: `platform/workflow/skills-and-agents.md`
- Per-tool adapter modules: `platform/agents/`
