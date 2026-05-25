<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Bootstrap Quickstart

## From Zero to a Running Harness in One Session

This is the fast path. It assumes you know what you're building and which stack you're using.
If you're starting from an idea with no stack chosen yet, start with
`platform/workflow/discovery-to-composition.md` instead.

---

## Step 0 — Choose your integration mode

**If you are using auto-harness as a git submodule (recommended for all consumer projects), you should NOT follow the rest of this document.** Instead:

```bash
cd your-repo
git submodule add <auto-harness-repo-url> .harness
bash .harness/platform/bootstrap/install.sh
```

That single command replaces Steps 1 through 6 below and is brownfield-safe. See [submodule-integration.md](submodule-integration.md) for the full flow. The rest of this quickstart applies only when auto-harness lives inside your project (Option B in [ci-integration.md](ci-integration.md)) — e.g. monorepo or subtree consumption.

---

## What You Need

- Ruby 3.0+ (`ruby --version`)
- ripgrep (`rg --version`) — for placeholder scanning only
- A git repository for your project

---

## Step 1 — Copy the Starter Manifest

Copy the closest composition file into your project root as `harness.manifest.yaml`:

```bash
# From the platform compositions directory, pick the closest match:
cp platform/compositions/new-product-discovery.yaml  your-project/harness.manifest.yaml  # discovery phase
cp platform/compositions/node-web-saas-postgres.yaml your-project/harness.manifest.yaml  # Node/TS + Postgres
cp platform/compositions/python-api-service-postgres.yaml your-project/harness.manifest.yaml  # Python API
```

Then open `harness.manifest.yaml` and update the project block:

```yaml
schemaVersion: 1
project:
  id: your-project-id          # kebab-case, unique
  name: Your Project Name
  maturity: prototype           # prototype | mvp | production | research | platform
                                #   (any non-empty string; schema does not enforce
                                #   an enum on maturity — values above are the
                                #   conventional set used across in-tree compositions)
  criticality: low              # low | medium | high | critical | platform | research | internal
                                #   (schema enforces this enum; see
                                #   platform/core/registry/manifest.schema.json)
```

Leave the `modules:` block as-is for now. Adjust it after the validators pass.

---

## Step 2 — Run the Manifest Validator

First, point `$PLATFORM_ROOT` at the `platform/` directory. The value depends on how
auto-harness sits inside your project:

```bash
# If auto-harness is a git submodule at .harness/ (recommended path; Step 0):
export PLATFORM_ROOT="$PWD/.harness/platform"

# If auto-harness is vendored in-tree (monorepo / subtree consumption):
export PLATFORM_ROOT="$PWD/platform"

# If you are running these commands from inside the auto-harness checkout itself:
export PLATFORM_ROOT="$PWD/platform"
```

This is the same `$PLATFORM_ROOT` that `ci-integration.md` uses; keeping the variable name
identical between local and CI invocations means commands copy-paste cleanly between contexts.

```bash
bash $PLATFORM_ROOT/validators/validate-manifest.sh harness.manifest.yaml
```

**Expected output:**

```text
✓ Manifest structure is valid: harness.manifest.yaml
```

If this fails, see `platform/workflow/troubleshooting.md` → Manifest Validation Errors.

---

## Step 3 — Run the Module Graph Validator

```bash
bash $PLATFORM_ROOT/validators/validate-module-graph.sh harness.manifest.yaml
```

**Expected output:**

```text
✓ Module graph is valid for harness.manifest.yaml
```

This checks that all declared modules exist, dependencies are present, and no conflicting modules
are both active (e.g., `prototype` and `production-saas` cannot coexist).

---

## Step 4 — Create Required Artifacts

The `validate-required-artifacts.sh` validator checks that files declared in active modules
actually exist in your project. Run it to see what's missing:

```bash
bash $PLATFORM_ROOT/validators/validate-required-artifacts.sh harness.manifest.yaml .
```

For a discovery-phase manifest, this validation is disabled by default. For a production
composition, you'll see output like:

```text
✗ Required artifact validation failed:
  - missing HARNESS.md
  - missing AGENTS.md
  - missing docs/operating-principles.md
  - missing docs/product/problem-statement.md
  ...
```

Create each missing file using the templates in `platform/templates/`. The match is direct:

| Missing artifact | Template |
| ---------------- | -------- |
| `docs/product/problem-statement.md` | `platform/templates/product/problem-statement.md` |
| `docs/product/requirements.md` | `platform/templates/product/requirements.md` |
| `docs/product/personas.md` | `platform/templates/product/personas.md` |
| `docs/product/release-intent.md` | `platform/templates/product/release-intent.md` |
| `docs/discovery/intake-questionnaire.md` | `platform/templates/discovery/intake-questionnaire.md` |
| `docs/discovery/mvp-scope.md` | `platform/templates/discovery/mvp-scope.md` |
| `docs/architecture/overview.md` | `platform/templates/architecture-overview.md` |
| `docs/adr/ADR-0001-*.md` | `platform/templates/adr.md` |
| `docs/requirements/PRD-0001-*.md` | `platform/templates/product/prd.md` |
| `docs/security/risk-register.md` | `platform/templates/risk-register.md` |
| `docs/ops/release-checklist.md` | `platform/templates/release-checklist.md` |
| `docs/project/scope-plan.md` | `platform/templates/project/scope-plan.md` |
| `docs/project/change-log.md` | `platform/templates/project/change-log.md` |

Copy the template and fill in the `[[PLACEHOLDER_NAME]]` fields. Run the validator again after
each batch to confirm progress.

---

## Step 5 — Scan for Unfilled Placeholders

```bash
bash $PLATFORM_ROOT/validators/validate-placeholders.sh .
```

This scans for any remaining `[[PLACEHOLDER_NAME]]` tokens (and bare `YYYY-MM-DD` placeholders)
in tracked files under the project root. The script accepts an optional project-root argument (defaults to the current directory); a
`.placeholder-ignore` file at the project root controls excluded paths. A passing run means all
templates have been filled in.

---

## Step 6 — Validate Agent Pack (if using AI tooling)

If your manifest includes `agents/claude-code` or `agents/generic-llm`:

```bash
bash $PLATFORM_ROOT/validators/validate-agent-pack.sh harness.manifest.yaml .
```

This checks that `AGENTS.md`, `CLAUDE.md`, and `.claude/settings.json` exist and are consistent.
See the `platform/agents/` directory for the expected file contents.

---

## Step 6.5 — Install Recommended Skills

Skills work in two ecosystems. Each module's `module.yaml` has a `recommendedSkills` field
listing entries from both. Install from whichever ecosystems your team uses.

### Which path should I use?

| Your situation | Install to |
| -------------- | ---------- |
| Single project, want skills available to all AI clients | `<project>/.agents/skills/` |
| Single project, Claude Code only | `<project>/.claude/skills/` |
| Skills for all your projects, all clients | `~/.agents/skills/` |
| Skills for all your projects, Claude Code only | `~/.claude/skills/` |

Project-level skills override user-level skills of the same name. Start with project-level
unless you want the skill available everywhere.

### Agent Skills format (SKILL.md directories)

[Agent Skills](https://agentskills.io/specification) is the canonical open standard for AI
agent skills, supported by Claude Code, VS Code Copilot, GitHub Copilot, Cursor, Gemini CLI,
and other compliant clients. Harness-native skills live in `platform/skills/`.

```bash
# Cross-client installation (works with all compliant clients)
cp -r platform/skills/harness-governance .agents/skills/   # all projects
cp -r platform/skills/harness-testing .agents/skills/      # testing-standard module active
cp -r platform/skills/harness-web3 .agents/skills/         # Web3 projects only
cp -r platform/skills/harness-tools .agents/skills/        # agents/openclaw active

# Claude Code native path (Claude Code also scans .claude/skills/)
cp -r platform/skills/harness-governance .claude/skills/
cp -r platform/skills/harness-testing .claude/skills/      # testing-standard module active
cp -r platform/skills/harness-web3 .claude/skills/         # Web3 projects only
cp -r platform/skills/harness-tools .claude/skills/        # agents/openclaw active
```

At session start, agents load only the skill name and description (~100 tokens per skill).
The full body loads on demand when a task matches the skill's domain — this keeps startup
context lean without losing domain expertise when it's needed.

### OpenClaw / ClawHub ecosystem

If your team uses OpenClaw as a development participant or part of the solution stack,
install the relevant ClawHub slugs. Curated directory:
`https://github.com/VoltAgent/awesome-openclaw-skills`

```bash
clawhub install <slug>
```

| Active module | Slug(s) to install |
| ------------- | ------------------ |
| `stacks/node-typescript` (Next.js) | `next-best-practices`, `next-cache-components` |
| `stacks/node-typescript` (Vercel) | `lb-vercel-skill` |
| `stacks/node-typescript` (perf) | `react-perf` |
| `domains/supabase` or Supabase data layer | `supabase` |
| `data/relational-postgres` | `postgres-perf` |
| `domains/media-pipeline` | `ffmpeg-master`, `mediaproc` |
| `domains/web3` | `azhua-skill-vetter` (first), then full-registry skills — see below |

**Web3 projects:** Web3 skills are not in the curated list — they come from the full ClawHub
registry. Always install `azhua-skill-vetter` first (`clawhub install azhua-skill-vetter`) and
run it against any Web3 skill before activation. These are experimental releases that may
contain vulnerabilities. Never connect to a live wallet or production API key without testing
in an isolated environment first. See `platform/workflow/skills-and-agents.md` → Web3 Skills Security.

Skill installation has no CI gate — it is a developer discipline step.

---

## Step 7 — Wire Up CI

Copy the minimal workflow from `platform/workflow/ci-integration.md` into
`.github/workflows/harness.yml` in your project. At a minimum:

```yaml
- run: bash $PLATFORM_ROOT/validators/validate-manifest.sh harness.manifest.yaml
- run: bash $PLATFORM_ROOT/validators/validate-module-graph.sh harness.manifest.yaml
- run: bash $PLATFORM_ROOT/validators/validate-required-artifacts.sh harness.manifest.yaml .
```

See `platform/workflow/ci-integration.md` for the full workflow including companion rule
enforcement and stack-specific checks.

---

## Harness Bootstrap Complete

The harness is **Bootstrap Complete** when:

1. `validate-manifest.sh` exits 0
2. `validate-module-graph.sh` exits 0
3. `validate-required-artifacts.sh` exits 0 (or is intentionally disabled for discovery phase)
4. `validate-placeholders.sh` exits 0
5. CI workflow is wired and green on the first PR

See `platform/core/kernel/base/lifecycle-controls.md` for the full definition of
Bootstrap Complete vs. Harness Ready.

---

## Choosing the Right Starting Composition

| Your situation | Start with |
| -------------- | ---------- |
| Raw idea, no stack chosen | `new-product-discovery.yaml` |
| Node.js + TypeScript + PostgreSQL web app | `node-web-saas-postgres.yaml` |
| Python API service with PostgreSQL | `python-api-service-postgres.yaml` |
| Python data or ML pipeline with object storage | `research-pipeline-python-object-storage.yaml` |
| None of the above | Start from `new-product-discovery.yaml` and add modules per `discovery-to-composition.md` Step 6 |

---

## Common First-Run Issues

See `platform/workflow/troubleshooting.md` for detailed fixes. Quick reference:

| Error | Likely cause |
| ----- | ------------ |
| `Missing module definition for management:X at ...` | Module `X` doesn't exist — check spelling or available modules |
| `X conflicts with active module Y` | Two conflicting modules active — remove one (e.g., remove `prototype` if adding `production-saas`) |
| `X depends on missing module Y` | A required dependency isn't declared — add `Y` to the appropriate module group |
| `missing docs/product/requirements.md` | File doesn't exist yet — copy from template and fill in |
| `[[PLACEHOLDER_NAME]] found in ...` | Template token wasn't replaced — open the file and fill it in |

---

## Reference

| Resource | Path |
| -------- | ---- |
| Discovery workflow (idea → manifest) | `platform/workflow/discovery-to-composition.md` |
| CI integration guide | `platform/workflow/ci-integration.md` |
| Troubleshooting | `platform/workflow/troubleshooting.md` |
| Skills and agents guide | `platform/workflow/skills-and-agents.md` |
| All templates | `platform/templates/` |
| All compositions | `platform/compositions/` |
| Sample project (filled in) | `platform/examples/sample-projects/node-web-saas-postgres/` |
| Lifecycle controls definition | `platform/core/kernel/base/lifecycle-controls.md` |
