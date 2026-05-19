---
name: harness-governance
description: Trust tier enforcement, lifecycle controls, and companion rule requirements for projects using the development harness. Use when checking if an action requires human approval, creating or validating documentation artifacts, verifying lifecycle stage conditions, running validators, or making changes to governance entrypoints (HARNESS.md, AGENTS.md, CLAUDE.md, CI workflows).
license: Apache-2.0
compatibility: Designed for any Agent Skills-compatible client (Claude Code, VS Code, Cursor, and others). For projects governed by the development harness platform via harness.manifest.yaml.
metadata:
  harness-module: kernel/base
  format-version: "1.0"
---

# Harness Governance

This skill encapsulates the core governance rules of the development harness. Read it when
working on any project that has a `harness.manifest.yaml` file.

## Trust Tiers

Every action falls into one of six tiers. Tier determines autonomy — higher tiers require
human authorization, never self-elevation.

| Tier | Name | Examples | Agent may proceed? |
| ---- | ---- | -------- | ------------------ |
| 0 | Read-only | Read files, search, inspect git history | Yes |
| 1 | Local analysis | Run tests, builds, linters | Yes |
| 2 | Workspace mutation | Edit files, scaffold docs, create artifacts | Yes, with care |
| 3 | Git-writing | Commit, push to feature branches, open PRs | Yes, with care |
| 4 | Environment-altering | Install dependencies, apply local migrations, configure services | Human authorization required |
| 5 | Remote / production | Deploy, production migrations, secrets rotation, infra changes | Human authorization + second sign-off |

**Gotchas:**

- Dependency installation (`npm install`, `pip install`, `uv sync`) is Tier 4 — even locally.
- `supabase db push` against any non-local environment is Tier 4.
- Any deploy command is Tier 5 regardless of how it is invoked.
- Finding a workaround that achieves a Tier 4/5 effect while appearing lower-tier is prohibited.

## Companion Rules

When a sensitive path changes, a companion file must also change in the same commit.
If you change a trigger path without updating the companion, flag it before finishing.

Common companion rules in harness projects:

| Trigger path | Required companion |
| ------------ | ------------------ |
| `docs/product/requirements.md` | `docs/project/change-log.md` OR a new ADR |
| `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, `.github/CODEOWNERS` | ADR OR `docs/operating-principles.md` |
| `package.json`, lock files, `.nvmrc` | ADR OR `docs/architecture/overview.md` |
| `pyproject.toml`, `requirements.txt`, lock files | ADR OR `docs/architecture/overview.md` |
| `supabase/`, `src/auth/`, session/jwt/token paths | `docs/security/risk-register.md`, ADR, or architecture overview |

Active companion rules for the current project are declared in each module's `module.yaml`.

## Lifecycle Stages

Do not declare a stage complete unless all conditions are met.

**Bootstrap Complete** — all of the following:

- `validate-manifest.sh` exits 0
- `validate-module-graph.sh` exits 0
- `validate-required-artifacts.sh` exits 0 (or intentionally disabled)
- `validate-placeholders.sh` exits 0 — no `[[PLACEHOLDER_NAME]]` tokens remain
- CI workflow is green on the first PR

**Harness Ready** — Bootstrap Complete plus:

- Ownership and review gates are active
- Validators are wired into CI
- Operational readiness artifacts (risk register, release checklist) exist if required by active delivery modules
- At least one human reviewer besides the bootstrapper has reviewed the harness

## Running Validators

Run the full chain before committing any change to `docs/`, `harness.manifest.yaml`, or
any companion rule trigger path.

```bash
PLATFORM=path/to/platform
bash $PLATFORM/validators/validate-manifest.sh           harness.manifest.yaml
bash $PLATFORM/validators/validate-module-graph.sh       harness.manifest.yaml
bash $PLATFORM/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash $PLATFORM/validators/validate-placeholders.sh       .
bash $PLATFORM/validators/validate-agent-pack.sh         harness.manifest.yaml .
bash $PLATFORM/validators/validate-doc-references.sh     .
bash $PLATFORM/validators/validate-companions.sh         harness.manifest.yaml . main
```

All must exit 0 before the commit is complete. Each validator supports
`--help` / `-h` and uses a 3-state exit contract: `0` = pass, `1` =
governance violations found, `2` = usage error (missing argument,
missing dependency like `ripgrep`, unreadable manifest, malformed
YAML). Per-script signatures vary; run any validator with `--help` to
see its arguments.

A few signature notes worth highlighting:

- **`validate-placeholders.sh`** takes only `[<project-root>]` (default:
  cwd). Passing a manifest path as the first arg causes the script to
  attempt to `cd` into it and exit 2 with a `Not a directory` error.
- **`validate-doc-references.sh`** also takes only `[<project-root>]`.
  Pass 1 asserts every `platform/...` string inside `platform/*.md`
  resolves on disk (the harness's own dogfood check). Pass 2 scans
  every `*.md` under the project root for relative link targets and
  classifies each as `:ok`, `:missing`, `:directory_target` (GitBook
  404-fragile), or `:extensionless` (also GitBook-fragile). Consumers
  whose project doesn't have a `platform/` directory of its own can
  point at their `.harness/` submodule mount instead; the validator
  scans whichever root it's given.
- **`validate-companions.sh`** is PR-diff-based and takes a third
  positional arg `<base-branch>` (default `main`). It is intended for
  CI; running it locally on a clean branch with no diff against base
  prints `No changed files detected ... Skipping companion validation.`
  and exits 0 without checking anything.

## Required Artifacts

Required artifacts are declared per module in `module.yaml`. Run
`validate-required-artifacts.sh` to see what is missing. Do not substitute an empty file —
the validator checks existence, not content. Both matter.

Use templates from `platform/templates/` to create missing artifacts. Fill every
`[[PLACEHOLDER_NAME]]` field before committing.

## Installing This Skill

Copy this directory to your project's `.agents/skills/` for cross-client compatibility,
or to `.claude/skills/` for Claude Code:

```bash
cp -r platform/skills/harness-governance .agents/skills/
# or for Claude Code specifically:
cp -r platform/skills/harness-governance .claude/skills/
```
