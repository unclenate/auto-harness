# Bootstrap Quickstart

## From Zero to a Running Harness in One Session

This is the fast path. It assumes you know what you're building and which stack you're using.
If you're starting from an idea with no stack chosen yet, start with
`platform/workflow/discovery-to-composition.md` instead.

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
  maturity: prototype           # prototype | mvp | production
  criticality: low              # low | medium | high | critical
```

Leave the `modules:` block as-is for now. Adjust it after the validators pass.

---

## Step 2 — Run the Manifest Validator

```bash
PLATFORM=path/to/development-harness/platform

bash $PLATFORM/validators/validate-manifest.sh harness.manifest.yaml
```

**Expected output:**

```text
✓ Manifest structure is valid: harness.manifest.yaml
```

If this fails, see `platform/workflow/troubleshooting.md` → Manifest Validation Errors.

---

## Step 3 — Run the Module Graph Validator

```bash
bash $PLATFORM/validators/validate-module-graph.sh harness.manifest.yaml
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
bash $PLATFORM/validators/validate-required-artifacts.sh harness.manifest.yaml .
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
| `docs/security/risk-register.md` | `platform/templates/risk-register.md` |
| `docs/ops/release-checklist.md` | `platform/templates/release-checklist.md` |
| `docs/project/scope-plan.md` | `platform/templates/project/scope-plan.md` |
| `docs/project/change-log.md` | `platform/templates/project/change-log.md` |

Copy the template and fill in the `[[PLACEHOLDER_NAME]]` fields. Run the validator again after
each batch to confirm progress.

---

## Step 5 — Scan for Unfilled Placeholders

```bash
bash $PLATFORM/validators/validate-placeholders.sh harness.manifest.yaml .
```

This scans for any remaining `[[PLACEHOLDER_NAME]]` tokens in tracked files. A passing run means
all templates have been filled in.

---

## Step 6 — Validate Agent Pack (if using AI tooling)

If your manifest includes `agents/claude-code` or `agents/generic-llm`:

```bash
bash $PLATFORM/validators/validate-agent-pack.sh harness.manifest.yaml .
```

This checks that `AGENTS.md`, `CLAUDE.md`, and `.claude/settings.json` exist and are consistent.
See the `platform/agents/` directory for the expected file contents.

---

## Step 6.5 — Install Recommended Skills

After the agent pack validates, check which external skills your active modules recommend.
Each module's `module.yaml` has a `recommendedSkills` field listing relevant skill IDs.

Quick lookup by module:

| Active module | Skill to install |
| ------------- | ---------------- |
| `stacks/node-typescript` + Vercel | `vercel-plugin:nextjs`, `vercel-plugin:vercel-cli` |
| `domains/supabase` | `supabase-postgres-best-practices` |
| `domains/web3` | `openlaw:skill-vetter` (first), `openlaw:goplus-agent-guard`, `openlaw:mist-track` |
| `domains/web3` + data layer | `openlaw:dune-mcp`, `openlaw:nansen` |

**Web3 projects:** Install `openlaw:skill-vetter` before any other Web3 skill. Web3 agent skills
are early experimental releases and may contain vulnerabilities. Test in an isolated environment
before connecting to any live wallet, contract, or production API key. See
`platform/workflow/skills-and-agents.md` for the full security guidance.

Skills are installed in your AI tool (Claude Code skill registry, etc.). There is no CI gate
for skill installation — it is a developer discipline step.

---

## Step 7 — Wire Up CI

Copy the minimal workflow from `platform/workflow/ci-integration.md` into
`.github/workflows/harness.yml` in your project. At a minimum:

```yaml
- run: bash $PLATFORM/validators/validate-manifest.sh harness.manifest.yaml
- run: bash $PLATFORM/validators/validate-module-graph.sh harness.manifest.yaml
- run: bash $PLATFORM/validators/validate-required-artifacts.sh harness.manifest.yaml .
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
