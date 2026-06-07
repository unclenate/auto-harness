<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# `platform/bootstrap/` — consumer-side bootstrap for auto-harness

Tools for integrating auto-harness into a consumer repo that has mounted auto-harness as a git submodule:

| Tool | Purpose | Language |
|------|---------|----------|
| [`install.sh`](install.sh) | One-shot brownfield-safe setup: write harness-managed files, merge `AGENTS.md`, delegate skill-linking, smoke-test validators | Bash + Ruby heredoc |
| [`link-skills.sh`](link-skills.sh) | Standalone skill-symlink creator. Can run independently to add or repair skill links | Pure bash |
| [`set-consumer-headers.sh`](set-consumer-headers.sh) | Fill template-header tokens (`[[YEAR]]` / `[[OWNER_NAME]]` / `[[OWNER_EMAIL]]` / `[[SPDX_LICENSE]]` / `[[PROJECT_NAME]]`) in template-derived files; writes a project-local `.harness-headers.yaml` config so subsequent scaffolds auto-fill | Pure bash |
| [`query-observations.sh`](query-observations.sh) | Filter and surface observations from `docs/knowledge/shared-observations.md` by severity / topic / date — addresses the "knowledge management is write-only" gap | Pure bash |
| [`add-license-headers.sh`](add-license-headers.sh) | Maintainer tool — inserts SPDX/copyright headers into auto-harness's own source files (not used by consumers) | Pure bash |

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

### Setting consumer project headers

Templates under `platform/templates/**` ship with **tokenized** SPDX/copyright headers:

```text
<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->
```

When you copy a template into your project (e.g., `cp .harness/platform/templates/adr.md docs/adr/ADR-0001-foo.md`), the resulting file inherits the tokens. **`validate-placeholders.sh` will fail CI** on any unfilled token — that's the floor.

`set-consumer-headers.sh` is the ergonomic way to fill them:

```bash
# First-time setup — interactive prompts; writes .harness-headers.yaml
bash .harness/platform/bootstrap/set-consumer-headers.sh

# Subsequent scaffolds — re-run after copying templates; defaults loaded from config
bash .harness/platform/bootstrap/set-consumer-headers.sh --non-interactive
```

Token set the script fills (and only these):

| Token | What it captures |
|-------|------------------|
| `[[YEAR]]` | Copyright year (default: current year) |
| `[[OWNER_NAME]]` | Person or organization |
| `[[OWNER_EMAIL]]` | Contact email |
| `[[SPDX_LICENSE]]` | SPDX license identifier (e.g., `MIT`, `Apache-2.0`, `MIT OR Apache-2.0`) |
| `[[PROJECT_NAME]]` | Project name (or empty to leave the field blank) |

Other `[[…]]` tokens (e.g. `[[OWNER]]`, `[[OPP_TITLE]]`, `[[ADR_TITLE]]`) are *deliberately* left alone — those are per-artifact fields that the consumer fills when scaffolding a specific ADR / OPP / observation. The header tokens are project-wide; the per-artifact tokens are per-record.

The script supports `--dry-run`, `--non-interactive`, `--files=p1,p2,...` for targeted substitution, and `--scan=DIR` to scope the scan. See `set-consumer-headers.sh --help` for the full CLI.

> **Composition with `validate-placeholders.sh`.** The validator gates at PR boundary; the bootstrap helper is the ergonomic way to satisfy the gate. They are paired primitives: the validator enforces, the helper fulfills.

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
| `2` | Usage error — bad flag, missing submodule, unknown composition/skill, **or a blocked dependency preflight / instantiation guard** |

## Instantiation guards & dependency preflight (`install.sh`)

Before writing anything, `install.sh` runs two safety checks (PRD-0020). Both
hard-fail (exit 2) with a remedy; each has a narrow, explicit escape hatch.

**Instantiation-boundary guards.** A consumer must be its *own* git repository
with auto-harness mounted beneath it — never a subdirectory of, or committed
into, another repo.

- *Inside the platform repo* (you ran `install.sh` from within an auto-harness
  checkout): refused. Override with `--inside-platform` (intentional in-tree
  example only). Recover an already-mis-created consumer with
  [`../workflow/recover-misplaced-consumer.md`](../workflow/recover-misplaced-consumer.md).
- *Nested inside another git repo*: refused. Override with `--allow-nested`
  (intentional monorepo subproject).

The guards run only when the target is inside a git repo; a not-yet-`init`'d
consumer directory trips neither.

**Dependency preflight.** Checks Bash 4+, Ruby ≥ 3.0, ripgrep, and git up front
and reports every gap together with per-platform install commands, rather than
failing partway through.

- `--install-deps` opts into auto-installing the deps that can be fixed safely
  (git, ripgrep) via the detected package manager (brew / apt-get / dnf / pacman).
  This is **environment-altering** (Tier 4), so it is **off by default**. **Ruby
  is never auto-installed** — a system Ruby commonly shadows a package-manager
  Ruby; use a version manager (rbenv/asdf) instead.
- `HARNESS_SKIP_DEPCHECK=1` skips **only** the dependency preflight (not the
  guards) — for the test harness, CI images that provision their own toolchain,
  and advanced users managing dependencies out-of-band.

## The five-block summary (`install.sh`)

Every run ends with:

```text
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

Canonical, per-platform list: [`platform/reference/prerequisites.md`](../reference/prerequisites.md).
`install.sh` preflights all of these and `--install-deps` can auto-install git + ripgrep. In short:

- **Bash 4+** (for associative arrays; standard on Linux; macOS ships 3.2 — `brew install bash`).
- **Ruby 3.0+** for `install.sh`'s manifest-merge logic and for running the harness validators that `install.sh` invokes as a smoke test. `link-skills.sh` alone needs no Ruby.
- **ripgrep (`rg`)** for `validate-placeholders.sh` and other validators.
- **`git submodule`** available (trivially true wherever git ≥ 1.5 is installed), with **`core.symlinks=true`** (the default except on Windows).

## Tests

```bash
# Run each suite individually:
ruby platform/bootstrap/test/test_install.rb
ruby platform/bootstrap/test/test_link_skills.rb
```

Test fixtures live at `test/fixtures/consumer-repos/` (browse on GitHub — no canonical landing file):

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
