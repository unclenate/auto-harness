<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# `platform/bootstrap/` — consumer-side bootstrap for auto-harness

Two peer tools for integrating auto-harness into a consumer repo that has mounted auto-harness as a git submodule:

| Tool | Purpose | Language |
|------|---------|----------|
| [`install.sh`](install.sh) | One-shot brownfield-safe setup: write harness-managed files, merge `AGENTS.md`, delegate skill-linking, smoke-test validators | Bash + Ruby heredoc |
| [`link-skills.sh`](link-skills.sh) | Standalone skill-symlink creator. Can run independently to add or repair skill links | Pure bash |

Both tools share one philosophy: **observe before write**. They never modify platform-artifact files from other AI clients (Cursor, Windsurf, Copilot, Codex, OpenClaw, Hermes, …) and report everything they see in a `PLATFORMS OBSERVED:` summary block. The rationale is recorded in [ADR-0003](../../docs/adr/ADR-0003-submodule-integration.md).

## Quick reference

### Fresh install (greenfield consumer repo)

```bash
cd your-repo
git submodule add <auto-harness-repo> .harness
bash .harness/platform/bootstrap/install.sh
```

Creates `harness.manifest.yaml`, `HARNESS.md`, `CLAUDE.md`, `AGENTS.md`, and symlinked skill entries under `.agents/skills/` and `.claude/skills/`. Prints a suggested CI workflow to stdout (you decide whether to commit it).

### Brownfield consumer repo (existing files, possibly from other platforms)

Same command. The bootstrap is *safe by default*:

- Existing harness-style files (with a valid harness signature) are **skipped** and reported in `SKIPPED (existing):`. Use `--force` to replace them.
- Existing foreign files (your own `CLAUDE.md`, a custom `harness.manifest.yaml`, etc.) are **never overwritten**. They appear in `CONFLICTS:` with guidance.
- Existing platform-artifact files (`.cursorrules`, `.github/copilot-instructions.md`, `codex.yaml`, etc.) are **observed and preserved**. They appear in `PLATFORMS OBSERVED:` with the paths that triggered detection.
- `AGENTS.md` is merged via a stable `<!-- harness-managed-section -->` marker — your existing content is preserved verbatim outside the markers.

### Re-run after upstream updates

```bash
git submodule update --remote .harness
bash .harness/platform/bootstrap/install.sh    # idempotent; re-checks everything
```

Skills symlinked via `link-skills.sh` already reflect the updated submodule content — no re-sync needed. The bootstrap re-run only regenerates the `AGENTS.md` managed section (refreshing the marker block) and validates that harness-managed files are still in sync.

### Adding more skills after initial bootstrap

```bash
bash .harness/platform/bootstrap/link-skills.sh harness-tools harness-testing
```

Supports the same `--project-root`, `--mount-path`, `--force` flags as `install.sh` plus `--targets .agents/skills,.claude/skills`. See `link-skills.sh --help` for the full CLI.

## Exit codes (both tools)

| Code | Meaning |
|------|---------|
| `0` | Completed successfully, no conflicts |
| `1` | Completed with one or more conflicts (see summary) |
| `2` | Usage error — bad flag, missing submodule, unknown composition/skill, etc. |

## The five-block summary (`install.sh`)

Every run ends with:

```
CREATED:
  - (files newly written and symlinks newly created)
SKIPPED (existing):
  - (harness-style files left intact; use --force to replace)
CONFLICTS:
  - (foreign files that would have been written; left intact)
PLATFORMS OBSERVED (never modified by bootstrap):
  - cursor (.cursorrules)
  - github-copilot (.github/copilot-instructions.md)
MANUAL FOLLOW-UP:
  - (guidance and deferred actions)
```

The block is always present even when empty (shows `(none)`) — consistency makes output diffable across runs.

## Platform signature catalog

The bootstrap recognizes these other-AI platforms and will never modify files matching their signatures:

| Platform | Signatures |
|----------|-----------|
| Cursor | `.cursorrules`, `.cursor/` |
| Windsurf | `.windsurfrules`, `.windsurf/` |
| GitHub Copilot | `.github/copilot-instructions.md`, `.github/copilot/` |
| Microsoft Copilot | `.vscode/copilot.json`, `.copilot/` |
| OpenAI Codex | `codex.yaml`, `.codex/` |
| OpenClaw | `TOOLS.md`, `SOUL.md`, `IDENTITY.md`, `HEARTBEAT.md`, `BOOT.md`, `USER.md` (all at repo root) |
| Hermes | `hermes.yaml`, `.hermes/` |

Claude Code (`.claude/settings.json`, `.claude/skills/`) and the cross-client AGENTS.md convention are handled separately — the harness *contributes* to those surfaces rather than treating them as untouchable, because they are the intended integration points.

## Requirements

- **Bash 4+** (for associative arrays; standard on Linux/macOS).
- **Ruby 3.0+** for `install.sh`'s manifest-merge logic and for running the harness validators that `install.sh` invokes as a smoke test. `link-skills.sh` alone needs no Ruby.
- **`git submodule`** available (trivially true wherever git ≥ 1.5 is installed).
- **`core.symlinks=true`** enabled in git on Windows consumers (macOS and Linux default to true).

## Tests

```bash
# Run each suite individually:
ruby platform/bootstrap/test/test_install.rb
ruby platform/bootstrap/test/test_link_skills.rb
```

Test fixtures live at [`test/fixtures/consumer-repos/`](test/fixtures/consumer-repos/):

- `coexist-cursor/` — only `.cursorrules` pre-seeded
- `coexist-copilot/` — only `.github/copilot-instructions.md` pre-seeded
- `coexist-multi/` — Cursor + Copilot + custom `AGENTS.md` without marker block
- `coexist-openclaw/` — full OpenClaw setup (`TOOLS.md`, `SOUL.md`, etc.)

Each fixture verifies the bootstrap doesn't modify pre-existing platform files (mtime assertions) and correctly reports them in `PLATFORMS OBSERVED:`.

## See also

- [`platform/workflow/submodule-integration.md`](../workflow/submodule-integration.md) — full narrative of the submodule integration flow
- [`docs/adr/ADR-0003-submodule-integration.md`](../../docs/adr/ADR-0003-submodule-integration.md) — decision record covering tradeoffs and alternatives
- [`platform/workflow/ci-integration.md`](../workflow/ci-integration.md) — CI setup patterns with `HARNESS_SUBMODULE_ROOT`
- [`platform/workflow/brownfield-onboarding.md`](../workflow/brownfield-onboarding.md) — using the `harness-onboarding` skill for deeper gap analysis after `install.sh`
