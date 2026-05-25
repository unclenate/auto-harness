<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Integrating auto-harness as a git submodule

This is the canonical guide for adopting auto-harness in a consumer repository by mounting it as a git submodule. It supersedes the copy-based flow in [bootstrap-quickstart.md](bootstrap-quickstart.md) for any consumer that wants upstream improvements to flow in automatically.

**Decision record:** [ADR-0003 — Auto-Harness Submodule Integration](../../docs/adr/ADR-0003-submodule-integration.md)

> **Visual:** [Consumer Adoption Flow diagram](../../docs/architecture/diagrams.md#6-consumer-adoption-flow) —
> end-to-end picture of submodule mount → bootstrap → headers → validate → CI.

## Why submodule mode

The copy-based flow (`cp -r platform/skills/... .claude/skills/`) makes a snapshot. When auto-harness improves a skill, a validator, or a composition, that improvement reaches copies only if someone remembers to re-copy. In practice, consumer repos drift away from upstream over time.

A git submodule keeps the `platform/` tree as a live reference. One command pulls every improvement:

```bash
git submodule update --remote .harness
```

Symlinks from `.agents/skills/` and `.claude/skills/` into the submodule mean those updates are instantly visible to your AI agents — no re-sync step required.

## Prerequisites

- **Bash 4+** (standard on Linux). **macOS ships Bash 3.2 by default** due to GPL-v3 licensing — `install.sh` uses associative arrays (`declare -A`) and will refuse to run under Bash 3. Install a newer one via `brew install bash`, then invoke through it: `/opt/homebrew/bin/bash .harness/platform/bootstrap/install.sh ...` (Apple Silicon) or `/usr/local/bin/bash ...` (Intel). The script preflights its own version and bails with a helpful message if it sees Bash 3.
- **Ruby 3.0+** (required by all eight harness validators and by `install.sh`'s manifest merge). The pure-bash `link-skills.sh` is the only tool that runs without Ruby. See [ADR-0003 Consequences > Negative](../../docs/adr/ADR-0003-submodule-integration.md) for rationale.
- **Git ≥ 2.0** with `core.symlinks=true` (the default everywhere except Windows — Windows consumers need `git config --global core.symlinks true`).

## Quick start

### 1. Add the submodule

```bash
cd your-repo
git submodule add -b main https://github.com/unclenate/auto-harness .harness
git commit -m "chore: add auto-harness as submodule"
```

The `-b main` records a tracking branch in `.gitmodules`, so the `git submodule update --remote .harness` workflow used throughout this guide follows `main` explicitly. If you omit it, `.gitmodules` has no `branch` key and `--remote` falls back to the submodule remote's default branch (its `HEAD`) — which is `main` today, but relying on that default is implicit. See [Version Management](maintenance-operations.md#version-management) for how the tracking branch interacts with pinning.

The path `.harness` is conventional — the bootstrap defaults to it — but you can mount anywhere relative to your repo root. If you prefer `vendor/auto-harness`:

```bash
git submodule add -b main https://github.com/unclenate/auto-harness vendor/auto-harness
```

The rest of this guide uses `.harness` for brevity. Substitute your mount path if different.

### 2. Run the bootstrap

```bash
bash .harness/platform/bootstrap/install.sh
```

This is brownfield-safe — it will never overwrite your existing files. See [platform/bootstrap/README.md](../bootstrap/README.md) for the full CLI. Common flags:

```bash
# Pick a richer composition for a known-stack project
bash .harness/platform/bootstrap/install.sh --composition node-web-saas-postgres

# Preview without writing anything
bash .harness/platform/bootstrap/install.sh --dry-run

# Replace harness-generated files that exist (respects foreign files)
bash .harness/platform/bootstrap/install.sh --force

# Skip a client's skill directory (e.g., you don't use .claude/)
bash .harness/platform/bootstrap/install.sh --skills harness-governance
```

You will see a five-block summary at the end:

```text
CREATED:
  - harness.manifest.yaml
  - HARNESS.md
  - CLAUDE.md
  - AGENTS.md
  - [CREATED] .agents/skills/harness-governance → ../../.harness/platform/skills/harness-governance
  - [CREATED] .claude/skills/harness-governance → ../../.harness/platform/skills/harness-governance
  - [CREATED] .agents/skills/harness-onboarding → ../../.harness/platform/skills/harness-onboarding
  - [CREATED] .claude/skills/harness-onboarding → ../../.harness/platform/skills/harness-onboarding

SKIPPED (existing):
  (none)

CONFLICTS:
  (none)

PLATFORMS OBSERVED (never modified by bootstrap):
  (none — empty repo)

MANUAL FOLLOW-UP:
  - For deeper brownfield gap analysis, run the harness-onboarding skill against this repo.
```

### 3. Verify

```bash
bash .harness/platform/validators/validate-manifest.sh harness.manifest.yaml
bash .harness/platform/validators/validate-module-graph.sh harness.manifest.yaml
```

Both should exit 0 with a `✓` line per check.

### 4. Commit

```bash
git add harness.manifest.yaml HARNESS.md CLAUDE.md AGENTS.md .agents/ .claude/
git commit -m "feat: wire auto-harness via submodule"
```

Your repo now references `platform/` content via symlinks — a tiny tree of references, not a duplicate of the framework.

### 5. Wire CI

The bootstrap prints a suggested workflow (search stdout for `Suggested CI workflow`). Copy it into `.github/workflows/harness.yml`, review it, commit it. The snippet uses `HARNESS_SUBMODULE_ROOT` parameterization and `ruby/setup-ruby@v1` — see [ci-integration.md](ci-integration.md) for the extended patterns (multi-runner, alternate CI systems, caching).

### 6. Verify fresh-clone integration

`.harness/` is a **gitlink**, not a copy. Your repo stores only the commit SHA the submodule
points at — the actual files materialize when someone runs `git submodule update --init` (or
clones with `--recurse-submodules`). Two failure modes are silent at *your* developer machine
and only surface for the second developer or in CI:

1. **Clones without `--recurse-submodules` leave `.harness/` empty.** No error — the
   directory just isn't populated. Validator commands fail with "file not found", not
   "submodule not initialized."
2. **The pinned SHA must remain reachable in the submodule's remote.** Recording an explicit
   tracking branch (`-b main`, per step 1 above) makes intent unambiguous, but the *pinned
   commit* can still go away — force-pushed history, deleted branch, archived remote, or an
   auth-gated remote the consumer can't reach. When that happens, `git submodule update --init`
   fails — sometimes with a confusing `fatal: reference is not a tree`.

Run the smoke test from a clean directory before you ask anyone else to clone:

```bash
# From a scratch directory, not your existing working tree
cd "$(mktemp -d)"
git clone --recurse-submodules <your-repo-url> smoke-test
cd smoke-test
test -f .harness/platform/validators/validate-manifest.sh \
  && bash .harness/platform/validators/validate-manifest.sh harness.manifest.yaml \
  && echo "✓ Fresh-clone integration verified"
```

If that script fails on the `test -f` check, the gitlink is broken (unreachable SHA or
submodule URL); if it fails on the validator, your manifest is broken. Either way, fix it
before announcing the integration to teammates — the silent failure mode is the worst kind
of integration debt.

Consider adding this same smoke test to your CI: see
[`platform/templates/ci/README.md`](../templates/ci/README.md) for the CI starter
templates, and look for the `submodule-smoke-test` job in the consumer CI templates
once
[OPP-0025](../../docs/opportunities/OPP-0025-consumer-integration-smoke-test.md) lands.

## The `HARNESS_SUBMODULE_ROOT` contract

The `install.sh` bootstrap and all generated artifacts reference `$HARNESS_SUBMODULE_ROOT` rather than a hardcoded `.harness/` path. This has three consequences:

1. **Your CI workflows should set `HARNESS_SUBMODULE_ROOT`** (shown in the generated snippet). Example: `${{ github.workspace }}/.harness` for GitHub Actions, or a fixed relative path for other CI systems.
2. **Moving the submodule is a bootstrap-driven operation.** If you need to change the mount path, run `git submodule deinit` / `git mv` / re-run `install.sh` with the new `--mount-path`. The generated `HARNESS.md`, `AGENTS.md`, and `CLAUDE.md` will refresh their pointers automatically.
3. **Consumers are not coupled to a specific mount path.** Every example in auto-harness's own documentation refers to `$HARNESS_SUBMODULE_ROOT` instead of `.harness` — you can read those examples against any mount and the paths still make sense.

## Upgrade flow

Pulling upstream improvements, detecting new required artifacts after an upgrade, version pinning, and rollback are covered in the dedicated **[Maintenance & Operations](maintenance-operations.md)** guide. The short form for first-time readers: `git submodule update --remote .harness` pulls upstream changes; review the diff and commit. See the maintenance guide for the full upgrade workflow.

## Brownfield integration (existing repo with other platforms)

`install.sh` co-exists with configuration from other AI platforms. It recognizes these and **never modifies** files matching their signatures:

| Platform | Signatures |
|----------|-----------|
| Cursor | `.cursorrules`, `.cursor/` |
| Windsurf | `.windsurfrules`, `.windsurf/` |
| GitHub Copilot | `.github/copilot-instructions.md`, `.github/copilot/` |
| Microsoft Copilot | `.vscode/copilot.json`, `.copilot/` |
| OpenAI Codex | `codex.yaml`, `.codex/` |
| OpenClaw | `TOOLS.md`, `SOUL.md`, `IDENTITY.md`, `HEARTBEAT.md`, `BOOT.md`, `USER.md` |
| Hermes | `hermes.yaml`, `.hermes/` |

Observed platforms appear in the `PLATFORMS OBSERVED:` summary block with the exact paths that triggered detection.

### `AGENTS.md` special-case

The cross-client [AGENTS.md](https://agents.md) convention is the one file where auto-harness *contributes* to shared surface rather than owning it. The bootstrap adds a stable-marker block:

```markdown
<!-- harness-managed-section -->
... harness governance content (auto-generated) ...
<!-- /harness-managed-section -->
```

Your existing content outside the markers is preserved verbatim. If the file didn't have the markers before, the managed block is appended at the end. Re-running the bootstrap rewrites only the content between the markers.

## Troubleshooting

Submodule-related operational issues — broken symlinks, "harness skills dir not found", Windows symlink configuration, recovering from drift, post-update re-initialization — are documented in **[Maintenance & Operations](maintenance-operations.md)**. The items below are setup-time symptoms specific to first-time integration.

### `[CONFLICT] .agents/skills/<name> is a directory`

Something put a real directory at the path where a symlink was expected. `link-skills.sh` and `install.sh` both refuse to delete real directories even with `--force` — the content could be user-authored. Move or remove the directory manually, then re-run.

### Validators fail: "missing docs/project/revision-tracker.md"

The `management/project-standard` module requires the revision tracker artifact. If you activated that module before creating the file, the validator flags it. Either create `docs/project/revision-tracker.md` (use [platform/templates/project/revision-tracker.md](../templates/project/revision-tracker.md) as a starter) or disable the `required-artifacts` validator temporarily:

```yaml
overrides:
  disabledValidations:
    - required-artifacts
```

### Validators fail: "ruby: command not found"

Install Ruby 3.0+:

- Ubuntu / Debian: `sudo apt install ruby`
- macOS: `brew install ruby` (or use the system Ruby)
- CI: `uses: ruby/setup-ruby@v1` with `ruby-version: "3.3"`

See [ADR-0003](../../docs/adr/ADR-0003-submodule-integration.md) for why Ruby is required.

## Relationship to the `harness-onboarding` skill

`install.sh` handles the *mechanical* parts of adoption — creating files, merging AGENTS.md, linking skills, running validators. It is fast, deterministic, and never modifies anything it doesn't own.

The [harness-onboarding skill](../skills/harness-onboarding/SKILL.md) handles the *analytical* parts — reading your codebase, assessing which modules (stacks, architectures, management, domains) apply, and producing an informed `harness.manifest.yaml`. It is slower, AI-driven, and answers judgment questions like "is this codebase prototype or production maturity?"

**The right order is: run `install.sh` first, then the skill.**

`install.sh` gets you a valid bootstrap; the skill refines it based on what the repo actually contains. Running the skill first is also possible but yields a manifest the consumer then has to hand-wire to files — you've done more work to the same end state.

## See also

- [platform/bootstrap/README.md](../bootstrap/README.md) — bootstrap tools reference
- [platform/workflow/ci-integration.md](ci-integration.md) — CI workflow patterns
- [platform/workflow/brownfield-onboarding.md](brownfield-onboarding.md) — deeper brownfield assessment via the harness-onboarding skill
- [platform/workflow/bootstrap-quickstart.md](bootstrap-quickstart.md) — legacy copy-based flow (superseded by this document for submodule consumers)
- [docs/adr/ADR-0003-submodule-integration.md](../../docs/adr/ADR-0003-submodule-integration.md) — design decision, alternatives considered
