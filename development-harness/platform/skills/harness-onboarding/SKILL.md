---
name: harness-onboarding
description: "Use when onboarding an existing (brownfield) codebase into the development harness. Produces a repository inventory, module composition recommendation, artifact gap analysis, validator runbook, and a copy-paste lite manifest. Activate with any Agent Skills-compatible client pointed at the target repository."
license: Apache-2.0
compatibility: For any Agent Skills-compatible client (Claude Code, VS Code Copilot, Cursor, WindSurf, and others). Target repository may use any stack. The harness platform must be accessible at development-harness/platform/ relative to the project root, or via the PLATFORM environment variable.
metadata:
  harness-module: kernel/base
  format-version: "1.0"
---

# harness-onboarding

> **For human developers:** This file is a structured prompt for your AI coding assistant. The body below (after the frontmatter) tells the AI how to analyze the repository and what to produce. You do not need to follow these instructions yourself — give this skill to your AI tool and it will do the work.
>
> For the full workflow — including how to install this skill, interpret the output, and progress from lite to full compliance — read [`platform/workflow/brownfield-onboarding.md`](../../workflow/brownfield-onboarding.md).

---

This skill turns an existing codebase into a governed project. It analyzes the repository, recommends which harness modules to activate, identifies the documentation and artifact gaps, and produces a lite manifest the team can use immediately — before every gap is filled.

Use this skill once, at the start of onboarding. After the manifest is initialized, switch to the `harness-governance` skill for ongoing governance and the other module-specific skills as applicable.

---

## Role and Goal

You are an AI assistant performing brownfield harness onboarding. Your goal is to produce a five-section conformance assessment and a copy-paste lite manifest that passes `validate-manifest.sh` and `validate-module-graph.sh` immediately, with `required-artifacts` disabled until the team has created the missing documentation.

---

## Constraints

Follow these rules throughout the assessment. They exist because the output will be used as the basis for real governance decisions.

- **Evidence only.** Base ALL recommendations on files found in this repository. Do not invent stack details, library versions, or tooling not observed in the file tree, package manifests, CI configuration, or docs.
- **UNKNOWN when uncertain.** If a fact cannot be confirmed from repository evidence, mark it as `UNKNOWN`. Do not substitute a likely guess.
- **Use the Module Catalog.** All module choices must come from the catalog in this skill. Do not invent module names.
- **Respect conflicts.** `stacks/node-typescript` and `stacks/python` conflict — select at most one. `delivery/prototype` and `delivery/production-saas` conflict — select exactly one.
- **Respect dependencies.** `management/program-lite` requires `management/project-standard`. `domains/supabase` requires `data/relational-postgres`. `domains/media-pipeline` requires `data/object-storage`. All modules require `core/kernel/base`.
- **Do not mark an artifact present unless you have verified its path.** PARTIAL is correct for files that exist but appear to be unfilled stubs or templates.
- **Conservative module selection.** If evidence is ambiguous, omit the module rather than include it. It is cheaper to add a module later than to inherit all its required artifacts immediately.

---

## Assessment Procedure

Work through these steps in order. Do not skip sections. Do not merge sections.

### Step 1 — Repository Inventory

Scan the repository before making any recommendations. For each item, record the actual file path where evidence was found, or `not found`.

**Package manager and runtime:**

- `package.json` → Node.js project
- `pyproject.toml`, `setup.py`, `requirements.txt`, `uv.lock`, `poetry.lock` → Python project
- `go.mod` → Go project
- `Gemfile` → Ruby project
- `Cargo.toml` → Rust project

**Framework signals:**

- `next.config.*`, `app/` or `pages/` directory → Next.js
- `vite.config.*`, `src/` SPA structure → Vite / React / Vue
- `svelte.config.*` → SvelteKit
- `fastapi`, `uvicorn` in dependencies → FastAPI
- `django` in dependencies → Django
- `flask` in dependencies → Flask
- `express` in `package.json` dependencies → Express

**Database and data signals:**

- `migrations/`, `db/migrate/`, Prisma `schema.prisma`, Drizzle config → relational/SQL
- `supabase/` directory, `@supabase/supabase-js` import → Supabase
- MongoDB client (`mongoose`, `mongodb`) → document store
- DynamoDB or Firestore SDK imports → document store
- S3/GCS/R2 SDK (`@aws-sdk/client-s3`, `google-cloud/storage`, `@cloudflare/r2`) → object storage

**CI and deployment signals:**

- `.github/workflows/*.yml` → extract job names, deploy targets, test commands
- `vercel.json`, `.vercel/` → Vercel deployment
- `fly.toml` → Fly.io deployment
- `railway.toml`, `railway.json` → Railway deployment
- `Dockerfile`, `docker-compose.*` → containerized
- `terraform/`, `*.tf` → infrastructure as code
- `Procfile` → Heroku / process-based

**Existing documentation:**

- List every file found under `docs/`, `documentation/`, `.github/`
- Note presence/absence of: `README.md`, `AGENTS.md`, `HARNESS.md`, `CLAUDE.md`, `AGENTS.md`, `docs/operating-principles.md`, `docs/architecture/overview.md`

**Test infrastructure:**

- `jest.config.*`, `vitest.config.*` → Jest or Vitest
- `pytest.ini`, `pyproject.toml [tool.pytest.*]` → pytest
- Coverage threshold configuration (look in jest config and pyproject.toml)
- Presence of `__tests__/`, `test/`, `spec/` directories

**Web3 signals:**

- `ethers`, `wagmi`, `viem` in dependencies → Ethereum client
- `hardhat`, `foundry`, `contracts/`, `abi/` → smart contract development
- On-chain data queries (The Graph, Alchemy SDK, Moralis)

**Multi-team signals:**

- `.github/CODEOWNERS` → multiple teams or code owners
- Monorepo structure (`packages/`, `apps/`, `services/` at root) → program-level coordination
- Multiple deployment targets in CI for different services

---

### Step 2 — Proposed Harness Composition

Based on Step 1 evidence only, select modules from the Module Catalog below.

For each selected module: state the file path or signal that justifies selecting it.

For each module family where no module is selected: state why (no evidence found, or a conflicting module was chosen).

Present the proposed composition as a structured list organized by module family: core, stacks, architectures, data, delivery, management, domains, agents.

---

### Step 3 — Gap Analysis

For each required artifact declared by the active modules in the proposed composition, check whether the file exists in the repository.

Present as a table:

| Module | Required Artifact | Status | Notes |
| ------ | ----------------- | ------ | ----- |

**Status values:**

- `EXISTS` — file found at the expected path with apparent real content
- `MISSING` — file not found at the expected path
- `PARTIAL` — file exists but appears to be an unfilled template or near-empty stub
- `EQUIVALENT` — a different file covers the same purpose (record the actual path in Notes)

After the table, summarize: total artifacts required, number EXISTS/MISSING/PARTIAL/EQUIVALENT.

---

### Step 4 — Validator Runbook

State the exact commands to run and what to expect given this repository's gap profile.

```bash
PLATFORM=path/to/development-harness/platform  # adjust to actual location

# Step 1 — Manifest structure (should pass immediately with the lite manifest)
bash $PLATFORM/validators/validate-manifest.sh harness.manifest.yaml

# Step 2 — Module graph: dependencies and conflicts (should pass immediately)
bash $PLATFORM/validators/validate-module-graph.sh harness.manifest.yaml

# Step 3 — Required artifacts (will fail until disabledValidations is cleared)
bash $PLATFORM/validators/validate-required-artifacts.sh harness.manifest.yaml .

# Step 4 — Companion rules (requires a PR diff — skip locally on a clean branch)
# bash $PLATFORM/validators/validate-companions.sh harness.manifest.yaml . main

# Step 5 — Placeholder scan (requires ripgrep; skip if rg not installed)
bash $PLATFORM/validators/validate-placeholders.sh .

# Step 6 — Agent pack (only if agents/claude-code or agents/generic-llm is active)
bash $PLATFORM/validators/validate-agent-pack.sh harness.manifest.yaml .
```

For each MISSING artifact identified in Step 3, note which validator will catch it and at what phase it should be re-enabled. Indicate what "green" means at the lite stage (Steps 1–2 pass) vs. the full compliance stage (all validators pass).

---

### Step 5 — Risks and Open Questions

List items that require human judgment before the composition can be finalized or the assessment can be acted on. Organize under three headings:

**Technical risks** — signals that were ambiguous, conflicting framework evidence, missing CI configuration, unknown auth patterns, etc.

**Governance risks** — cases where the repository's apparent maturity (e.g., evidence of real users, external APIs) does not match the proposed delivery module (e.g., prototype when production-saas may be more appropriate).

**Open questions** — specific questions for the team to answer before the manifest is finalized (e.g., "Is there a second service in this repo that should be a separate harness project?", "Does this project use a managed Postgres service or a containerized one?").

---

## Output Format

Use Markdown headings matching Sections 1–5 above. Do not skip sections.

After Section 5, append a copy-paste block containing two artifacts:

**Artifact A — Lite manifest** (save as `harness.manifest.yaml` at the project root):

```yaml
schemaVersion: 1
project:
  id: [infer from repo name, package.json name, or directory name — kebab-case]
  name: [infer from README title or package.json name]
  maturity: [prototype | mvp | production — infer from delivery signals; default to prototype if uncertain]
  criticality: [low | medium | high — low if no real users; medium if production SaaS; high if financial/health data]
modules:
  [compose from Step 2 findings — include all selected modules]
overrides:
  requiredArtifacts: []
  disabledValidations:
    - required-artifacts
```

**Artifact B — Next three actions** (ordered by priority):

A three-item numbered list of the highest-priority actions for this specific repository, based on the gap profile from Step 3 and the risks from Step 5.

---

## Module Catalog

Use this catalog for Steps 2 and 3. Do not select modules not listed here.

---

### core (always required)

**`core/kernel/base`** — always include; no conditions; no conflicts.

Required artifacts: `HARNESS.md`, `AGENTS.md`, `docs/operating-principles.md`

---

### stacks (pick at most one)

| Module | Select when | Conflicts with |
| ------ | ----------- | -------------- |
| `stacks/node-typescript` | `package.json` with TypeScript dependency, `tsconfig.json`, or `.nvmrc` found | `stacks/python` |
| `stacks/python` | `pyproject.toml`, `requirements.txt`, `setup.py`, or `.python-version` found | `stacks/node-typescript` |

No required artifacts for either stack module.

---

### architectures (may combine)

| Module | Select when |
| ------ | ----------- |
| `architectures/web-app` | `pages/`, `app/`, view layer, SSR framework config (Next.js, SvelteKit, Nuxt) found |
| `architectures/api-service` | `src/routes/`, `src/api/`, OpenAPI spec, REST or GraphQL endpoint structure found |
| `architectures/event-driven` | Queue consumers, worker processes, background job scheduler, or event bus config found |

Required artifact (all three): `docs/architecture/overview.md`

---

### data (may combine)

| Module | Select when | Dependencies |
| ------ | ----------- | ------------ |
| `data/relational-postgres` | `migrations/`, Prisma `schema.prisma`, Drizzle config, or Postgres connection string found | — |
| `data/document-store` | MongoDB, Firestore, or DynamoDB client found | — |
| `data/object-storage` | S3, GCS, R2, or Supabase Storage SDK found | — |

Required artifact: `data/relational-postgres` → `docs/database/migration-readiness.md`

No required artifacts for `document-store` or `object-storage`.

---

### delivery (pick exactly one)

| Module | Select when | Conflicts with |
| ------ | ----------- | -------------- |
| `delivery/prototype` | No real external users; throwaway, experimental, or purely internal | `delivery/production-saas` |
| `delivery/production-saas` | Real users, external dependencies, or data that matters; production or pre-production | `delivery/prototype` |
| `delivery/internal-platform` | Internal shared tooling with no external user-facing surface | — |

Required artifacts for `delivery/production-saas`: `docs/ops/environment-inventory.md`, `docs/ops/release-checklist.md`, `docs/ops/rollback-checklist.md`, `docs/security/risk-register.md`

No required artifacts for `delivery/prototype` or `delivery/internal-platform`.

---

### management (select applicable)

| Module | Select when | Required artifacts |
| ------ | ----------- | ------------------ |
| `management/discovery-intake` | Active discovery phase; requirements not yet finalized | `docs/discovery/intake-questionnaire.md`, `docs/discovery/mvp-scope.md` |
| `management/product-lite` | Any real product (non-throwaway); include for MVP and production | `docs/product/problem-statement.md`, `docs/product/requirements.md`, `docs/product/release-intent.md` |
| `management/project-standard` | Active project management, milestones, or scope tracking needed | `docs/project/scope-plan.md`, `docs/project/dependency-log.md`, `docs/project/milestones.md`, `docs/project/change-log.md` |
| `management/program-lite` | Multi-team or multi-workstream coordination | `docs/program/workstream-map.md`, `docs/program/stakeholder-report.md`, `docs/program/governance-cadence.md` |
| `management/testing-standard` | Formal test strategy and enforced coverage thresholds required | `docs/testing/test-strategy.md`, `docs/testing/coverage-thresholds.md` |

Dependency: `management/program-lite` requires `management/project-standard`.

---

### domains (select if applicable)

| Module | Select when | Dependencies | Required artifacts |
| ------ | ----------- | ------------ | ------------------ |
| `domains/supabase` | `supabase/` directory or `@supabase/supabase-js` import found | `data/relational-postgres` | none |
| `domains/media-pipeline` | `ffmpeg`, media processing jobs, or media CDN SDK found | `data/object-storage` | none |
| `domains/web3` | `ethers`, `wagmi`, `viem`, `hardhat`, `foundry`, `contracts/`, or `abi/` found | — | `docs/web3/chain-config.md` |
| `domains/gitbook` | `SUMMARY.md` at root or in `docs/`, `.gitbook.yaml` found | — | `docs/SUMMARY.md` |

---

### agents (select applicable)

| Module | Select when |
| ------ | ----------- |
| `agents/base` | Always include as baseline |
| `agents/claude-code` | Claude Code is the AI assistant for this project |
| `agents/generic-llm` | Another AI assistant (Cursor, Copilot, Windsurf, Gemini CLI) is in use |

No required artifacts for any agent module.

---

## Progression Path

Embed a version of this roadmap in the Section 5 output, tailored to this repository's specific gap profile.

**Phase 1 — Lite (start here)**
Manifest validates (structure + module graph green). `required-artifacts` disabled.
First artifacts to create: `HARNESS.md`, `AGENTS.md`, `docs/operating-principles.md` (kernel/base — low effort, high governance value).

**Phase 2 — Selective compliance (week 1–2)**
Create the cheapest-to-produce artifacts first. Typically: `docs/architecture/overview.md` (architecture modules), `docs/product/problem-statement.md` and `requirements.md` (management/product-lite).
Remove specific items from `disabledValidations` as each module's artifacts are completed.

**Phase 3 — Full compliance (week 2–4)**
All required artifacts exist. Remove `required-artifacts` from `disabledValidations` entirely.
Run all validators locally: all should exit 0.

**Phase 4 — CI gate**
Wire validators to CI per `platform/workflow/ci-integration.md`.
Install `harness-governance` skill: `cp -r platform/skills/harness-governance .agents/skills/` (or `.claude/skills/` for Claude Code).
All validators passing in CI = **Harness Ready**.

---

## Reference

| Resource | Path |
| -------- | ---- |
| Brownfield onboarding workflow guide | `platform/workflow/brownfield-onboarding.md` |
| Brownfield lite starter composition | `platform/compositions/brownfield-lite.yaml` |
| All module definitions | `platform/profiles/` |
| Validator scripts | `platform/validators/` |
| Templates for missing artifacts | `platform/templates/` |
| CI integration guide | `platform/workflow/ci-integration.md` |
| Troubleshooting validator errors | `platform/workflow/troubleshooting.md` |
| harness-governance skill (ongoing governance) | `platform/skills/harness-governance/` |
| harness-testing skill (testing governance) | `platform/skills/harness-testing/` |
| Sample fully-onboarded project | `platform/examples/sample-projects/node-web-saas-postgres/` |
