---
name: harness-onboarding
description: "Use when onboarding any existing project — codebase or documentation-only — into the development harness. Produces a governance inventory, repository inventory, module composition recommendation, artifact gap analysis, integration/translation guidance, validator runbook, and a copy-paste lite manifest. Activate with any Agent Skills-compatible client pointed at the target repository."
license: Apache-2.0
compatibility: For any Agent Skills-compatible client (Claude Code, VS Code Copilot, Cursor, WindSurf, OpenClaw, and others). Target project may be a codebase, a documentation-only pre-development project, or both. The harness platform must be accessible at platform/ relative to the harness repo root, or via the PLATFORM environment variable.
metadata:
  harness-module: kernel/base
  format-version: "1.1"
---

# harness-onboarding

> **For human developers:** This file is a structured prompt for your AI coding assistant. The body below (after the frontmatter) tells the AI how to analyze the project and what to produce. You do not need to follow these instructions yourself — give this skill to your AI tool and it will do the work.
>
> For the full workflow — including how to install this skill, interpret the output, and progress from lite to full compliance — read [`platform/workflow/brownfield-onboarding.md`](../../workflow/brownfield-onboarding.md).

---

This skill turns an existing project into a governed one. It analyzes the project's governance and (if present) codebase, recommends which harness modules to activate, identifies the documentation and artifact gaps, and produces a lite manifest the team can use immediately — before every gap is filled.

Use this skill once, at the start of onboarding. After the manifest is initialized, switch to the `harness-governance` skill for ongoing governance and the other module-specific skills as applicable.

---

## Role and Goal

You are an AI assistant performing brownfield harness onboarding. Your goal is to produce a conformance assessment and a copy-paste lite manifest that passes `validate-manifest.sh` and `validate-module-graph.sh` immediately, with `required-artifacts` disabled until the team has created the missing documentation. You produce integration guidance, gap reports, and a differences catalog — outputs that serve the target project's onboarding.

---

## Absorption Discovery — Opt-in Only

The harness-onboarding skill produces several outputs by default, all serving the target project's onboarding:

- **Integration guidance** — how to bring this project into harness conformance (which artifacts to create, where to align conventions, which modules to activate)
- **Gap report** — what the project is missing relative to harness baseline, suitable for internal planning or external communication
- **Differences catalog** — where the project does things differently but equivalently (not lesser, just structured for its own reasons)

These outputs describe the project accurately and help onboarding proceed. They do not frame the project's patterns as candidates for the harness to adopt. Describing a pattern is not the same as recommending its adoption elsewhere.

---

### The opt-in gate: absorption discovery

Absorption discovery is a secondary capability that goes beyond the default outputs. It identifies patterns in the target project that could improve auto-harness itself — and explicitly frames them as candidates for the harness to adopt. When enabled, it produces:

- An additional "Absorbable?" column in Step 3's gap analysis
- A new "Absorption Candidates" section in Step 5
- Artifact C — a structured list of patterns for harness maintainers to consider

**This capability is OFF by default.** The rationale:

- Brownfield projects often contain proprietary IP — governance patterns, templates, domain frameworks — that the project owner may not want surfaced outside the engagement
- An agent running onboarding on a client repo could inadvertently catalog IP for potential export to an open-source framework
- The decision to contribute patterns back to the harness belongs to the project owner, not the agent running the assessment
- Adoption friction matters: if the harness is known for absorbing observed patterns without explicit permission, teams will be reluctant to point it at their work

**To enable absorption discovery, the owner must explicitly state one of the following in the prompt invoking this skill:**

> "Absorption discovery is authorized for this onboarding pass."
>
> "You may surface absorption candidates from this project."
>
> "Bidirectional onboarding is approved."

Any of those (or a clear equivalent) unlocks absorption discovery. Without explicit permission, the skill produces the default outputs (integration, gaps, differences) but not the absorption-specific ones.

**When enabled, the agent must log the authorization** in the assessment output (as a header line in Section 0) so consent is visible in the record:

> `Absorption discovery: AUTHORIZED by owner (prompt-level consent)`

**When asked to enable without explicit authorization:** the agent should refuse and explain the opt-in requirement. Do not infer consent from context, team membership, or apparent project ownership — the authorization must be stated.

---

### The distinction in practice

| Statement the skill may make | Default mode? | Opt-in required? |
|------------------------------|:-------------:|:----------------:|
| "adsclaw has a KPI dictionary with 30+ entries at `docs/standards/KPI_DICTIONARY.md`" | ✓ | — |
| "adsclaw's KPI dictionary covers the same concern as the harness's optional KPI dictionary template" | ✓ | — |
| "To align with harness conventions, rename adsclaw's `docs/decisions/` to `docs/adr/`" | ✓ | — |
| "adsclaw's revision tracker is richer than the harness's current template" | ✓ | — |
| "The harness should absorb adsclaw's revision tracker pattern" | ✗ | ✓ |
| "Recommend this pattern be contributed upstream to the harness" | ✗ | ✓ |

The difference is who the output serves. Describing what exists and how it compares serves the onboarding project. Recommending adoption elsewhere serves the harness. The second requires consent.

---

## Brownfield Variants

This skill handles two brownfield patterns. Detect which applies before running the full procedure:

**Code-based brownfield** — existing codebase with working runtime, dependencies, and deployment. Governance may be minimal or absent. The skill's original focus.

**Doc-only brownfield** — documentation-rich project still in planning or design phase. No production code yet, but rich artifacts: ADRs, engine plans, architecture docs, standards. Governance may be *more* mature than harness defaults. Run Step 0 (Governance Inventory) first, then skip code-signal-only rows in Step 1.

---

## Constraints

Follow these rules throughout the assessment. They exist because the output will be used as the basis for real governance decisions.

- **Evidence only.** Base ALL recommendations on files found in this repository. Do not invent stack details, library versions, or tooling not observed in the file tree, package manifests, CI configuration, or docs.
- **UNKNOWN when uncertain.** If a fact cannot be confirmed from repository evidence, mark it as `UNKNOWN`. Do not substitute a likely guess.
- **Use the Module Catalog.** All module choices must come from the catalog in this skill. Do not invent module names.
- **Respect conflicts.** `delivery/prototype` and `delivery/production-saas` conflict — select exactly one. Stack modules (`stacks/node-typescript`, `stacks/python`) may be combined for genuinely polyglot projects; when combined, the project should declare a primary stack in `docs/architecture/overview.md`.
- **Respect dependencies.** `management/program-lite` requires `management/project-standard`. `domains/supabase` requires `data/relational-sql`. `domains/media-pipeline` requires `data/object-storage`. All modules require `core/kernel/base`.
- **Do not mark an artifact present unless you have verified its path.** PARTIAL is correct for files that exist but appear to be unfilled stubs or templates.
- **Conservative module selection.** If evidence is ambiguous, omit the module rather than include it. It is cheaper to add a module later than to inherit all its required artifacts immediately.
- **Greenfield = discovery, not composition (OPP-0042).** A new or near-empty repo with no code *and* no governance docs — even when the operator gives a one-line description of what it *will* be ("a portfolio site", "a SaaS for X") — is **greenfield**. That description is **intent, not evidence**: never assert a stack, architecture, or data module from a verbal description alone. Route greenfield to a discovery posture (`management/discovery-intake`, or the `new-product-discovery` / `interview-driven-discovery` compositions), keep `overrides.disabledValidations: [required-artifacts]`, and record intended-but-unevidenced modules as commented `# intent:` lines rather than active modules. Promote each to active — and enable its required artifacts — only when repo evidence appears (e.g. a `package.json`, a `pyproject.toml`, an actual framework config). The Conservative-module-selection rule above is brownfield-shaped (evidence = files present); greenfield has no files, so its default is the inverse — assert almost nothing until code lands. Prefer asking 2–3 scoping questions over inferring a full stack from a sentence.
- **Respect the absorption opt-in.** Absorption discovery outputs are conditional on explicit authorization. Never produce them without the stated consent described above.

---

## Assessment Procedure

Work through these steps in order. Do not skip sections. Do not merge sections.

### Step 0a — Instantiation-Location Precondition (STOP-gate)

Before any assessment or scaffolding, verify **where** you are creating/governing
the consumer. A consumer must be its **own git repository**, with auto-harness
mounted beneath it as a submodule — never a subdirectory of, or committed into,
another repo. Refuse and surface to the human if either holds:

1. **Inside the auto-harness platform repo.** The enclosing git root contains
   `platform/core/kernel/base/doctrine.md` and a `harness.manifest.yaml` whose
   `project.id` is `development-harness-framework`. (Highest-consequence: a private
   consumer's files would be committed/pushed into the platform repo.)
2. **Nested inside another git repo.** The project root is a subdirectory of a git
   working tree (its enclosing `git rev-parse --show-toplevel` is not the project
   root itself) — unless the human confirms an intentional monorepo subproject.

This mirrors the hard-fail guards in `install.sh` (see
[PRD-0020](../../../docs/requirements/PRD-0020-bootstrap-hardening-guards-and-preflight.md)).
If a consumer was already mis-created inside the platform tree, point the human at
[`platform/workflow/recover-misplaced-consumer.md`](../../workflow/recover-misplaced-consumer.md)
before continuing.

### Step 0 — Governance Inventory

Before auditing code, audit governance. Many brownfield projects have governance patterns the harness doesn't know about — some of which may match or differ from harness defaults in meaningful ways. Record what exists as evidence for later steps.

If absorption discovery was authorized, log the consent as the first line of this section:

> `Absorption discovery: AUTHORIZED by owner (prompt-level consent)`

Otherwise, Step 0 still runs — the governance inventory is needed for accurate onboarding regardless of absorption status.

**ADR conventions:**

- Look for `docs/decisions/`, `docs/adr/`, `decisions/`, `ADR-*.md`
- Count accepted/proposed ADRs
- Note template format, supersession patterns, context-source fields
- Record path and convention — auto-harness uses `docs/adr/`

**Review processes:**

- `.github/CODEOWNERS` — who reviews what at PR time
- `CONTRIBUTING.md` — contribution workflow
- `CLAUDE.md` — Claude Code review sections (named reviewers, review gate statements)
- `AGENTS.md` — agent operating contract
- `.github/PULL_REQUEST_TEMPLATE.md` — review checklist

**Standards documents (single-source-of-truth):**

- `docs/standards/`, `docs/standards.md`, or equivalent
- KPI dictionaries, SLA definitions, taxonomy, attribution models, style guides
- Check for the single-source pattern: does other documentation reference these, or redefine inline?

**Revision and review tracking:**

- Revision trackers, review logs, retrospective records
- Any meta-docs tracking findings, gaps, or historical decisions

**Agent and AI integration patterns:**

- `CLAUDE.md`, `.claude/` — Claude Code
- `.agents/skills/` — Agent Skills standard
- `.codex/`, `CODEX.md`, `AGENTS.override.md` — OpenAI Codex CLI
- `.cursor/rules` — Cursor
- `.github/copilot-instructions.md`, `.github/instructions/`, `.github/agents/` — GitHub Copilot CLI
- `GEMINI.md`, `.gemini/` — Gemini CLI
- `.aider.conf.yml` — Aider
- OpenClaw workspace files (`TOOLS.md`, `SOUL.md`, etc.)

**Documentation conventions:**

- Version / Owner / Last Updated / Review Cycle headers on docs
- Cross-reference patterns (relative links vs prose references)
- Consistent naming conventions

---

**Output of Step 0 — Governance Maturity Summary**

Present findings in three categories:

**At harness baseline:** Patterns in the project that match auto-harness expectations (ADR discipline, basic ownership, documentation standards).

**Differs from harness baseline:** Patterns in the project that are richer or simply structured differently than auto-harness defaults. Describe what they are and where they live. Do not frame them as candidates for harness adoption unless absorption discovery is authorized — in that case, flag them for Step 5's Absorption Candidates section.

**Missing vs harness baseline:** What auto-harness expects that the project doesn't have yet. These are standard gaps for Step 3.

---

### Step 1 — Repository Inventory

**Determine mode first.** Three cases, decided by what Step 0 and Step 1 actually find:

- **Greenfield** — *both* governance docs (Step 0) *and* code/runtime signals (Step 1) are absent: a new or near-empty repo, perhaps with only a verbal description of intent. Apply the greenfield rule (Constraints): route to a discovery posture, treat the description as **intent, not evidence**, and defer *all* code-dependent module selection and `required-artifacts` until code lands. Do not assert a stack/architecture/data module from the description.
- **Doc-only brownfield** — Step 0 found rich governance documentation but Step 1's package/runtime signals are all `not found` (pre-development). Record doc-signal-only rows from Step 0 in Step 1's inventory; skip code-dependent module selection (stacks, architectures, data) until implementation begins.
- **Standard brownfield** — code signals are present; select modules from the evidence as usual.

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

Based on Step 0 and Step 1 evidence only, select modules from the Module Catalog below.

For each selected module: state the file path or signal that justifies selecting it.

For each module family where no module is selected: state why (no evidence found, conflicting module chosen, or doc-only brownfield defers selection).

**Greenfield (per the mode in Step 1):** select `core/kernel/base` plus a discovery baseline — `management/discovery-intake`, or copy the `new-product-discovery` / `interview-driven-discovery` composition — and stop there. Do **not** select code-dependent families (stacks, architectures, data); list any the operator's description hints at as `# intent:` comments in the manifest, not active modules. Keep `overrides.disabledValidations: [required-artifacts]` until the first real code evidence appears, then re-run this assessment to promote the intended modules and enable their artifacts. A guessed, enforcement-on manifest produced from a one-line description is the failure this avoids.

Present the proposed composition as a structured list organized by module family: core, stacks, architectures, data, delivery, management, domains, agents.

---

### Step 2a — Privacy Posture

`management/privacy-by-design` is default-active. This step records the project's privacy posture
before the gap analysis so that `docs/privacy/privacy-profile.md` can be created as part of
onboarding.

**The 7 Cavoukian principles (brief):**

1. **Proactive, not remedial** — anticipate and prevent privacy events before they occur.
2. **Privacy as the default** — no action required by the user to protect their privacy.
3. **Privacy embedded into design** — built in as a core function, not bolted on.
4. **Full functionality** — positive-sum (privacy AND security, privacy AND utility).
5. **End-to-end security** — lifecycle protection from collection through deletion.
6. **Visibility and transparency** — open about practices; verifiable commitments.
7. **Respect for user privacy** — user-centric defaults, accurate notice, consent mechanisms.

**Walk the consumer through the following questions:**

1. Does the project collect, process, store, or transmit any personal or sensitive data?
   - If yes (or uncertain): `management/privacy-by-design` stays active. Record the applicable
     legal regime(s) (GDPR / CCPA-CPRA / LGPD / PIPEDA / PIPL / HIPAA / other) and data
     categories in `docs/privacy/privacy-profile.md`.
   - If genuinely no (e.g., internal developer tooling with no end-user accounts): keep
     `management/privacy-by-design` active in the manifest and declare `regime: none` with a
     non-empty `exemption:` line in `docs/privacy/privacy-profile.md`. Exempt mode keeps the
     companion rules firing and the profile present as the documented decision record.

2. Are there cross-border data flows or multi-jurisdiction users?
   - If yes: note which regimes apply and whether data residency restrictions exist.

3. Is a data-subject rights mechanism required (access, deletion, portability)?
   - Record the answer in `privacy-profile.md` under `## Implementation Notes`.

**Output of Step 2a:**

State the privacy posture decision: `regime: <list>` or `regime: none` with reason.
Confirm whether `docs/privacy/privacy-profile.md` exists (`EXISTS` / `MISSING`).
If MISSING, add it to the gap table in Step 3 and to the artifact creation order in the
Progression Path.

---

### Step 3 — Gap Analysis

For each required artifact declared by the active modules in the proposed composition, check whether the file exists in the repository.

Present as a table. Include the "Absorbable?" column **only if absorption discovery is authorized**:

**Default mode (no opt-in):**

| Module | Required Artifact | Status | Notes |
| ------ | ----------------- | ------ | ----- |

**With absorption discovery authorized:**

| Module | Required Artifact | Status | Notes | Absorbable? |
| ------ | ----------------- | ------ | ----- | ----------- |

**Status values:**

- `EXISTS` — file found at the expected path with apparent real content
- `MISSING` — file not found at the expected path
- `PARTIAL` — file exists but appears to be an unfilled template or near-empty stub
- `EQUIVALENT` — a different file covers the same purpose (record the actual path in Notes)

**Absorbable values (opt-in only):**

- `Yes` — the project's equivalent is richer than the harness default and could meaningfully improve the harness
- `No` — the project's equivalent matches harness defaults or is less mature
- `—` — not applicable (Status is MISSING, or the question doesn't apply)

After the table, summarize: total artifacts required, number EXISTS/MISSING/PARTIAL/EQUIVALENT.

---

### Step 4 — Validator Runbook

State the exact commands to run and what to expect given this repository's gap profile.

```bash
# Submodule consumers: default to .harness; override if your mount path differs.
HARNESS_SUBMODULE_ROOT="${HARNESS_SUBMODULE_ROOT:-.harness}"
PLATFORM="$HARNESS_SUBMODULE_ROOT/platform"

# Monorepo / subtree consumers: point PLATFORM directly at your platform/ tree.
# PLATFORM=path/to/platform

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

List items that require human judgment before the composition can be finalized or the assessment can be acted on. Organize under these headings:

**Technical risks** — signals that were ambiguous, conflicting framework evidence, missing CI configuration, unknown auth patterns, etc.

**Governance risks** — cases where the project's apparent maturity (e.g., evidence of real users, external APIs) does not match the proposed delivery module (e.g., prototype when production-saas may be more appropriate).

**Open questions** — specific questions for the team to answer before the manifest is finalized (e.g., "Is there a second service in this repo that should be a separate harness project?", "Does this project use a managed Postgres service or a containerized one?").

**Absorption candidates** — ONLY include this heading if absorption discovery is authorized. Otherwise omit entirely. When present, list patterns observed in this project that may improve auto-harness itself. For each, note what the current harness has and why the project's version is stronger. These feed back into the harness's own revision tracker as potential improvements.

---

## Output Format

Use Markdown headings matching Sections 0–5 above. Do not skip sections.

After Section 5, append a copy-paste block containing these artifacts:

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

A three-item numbered list of the highest-priority actions for this specific project, based on the gap profile from Step 3 and the risks from Step 5.

**Artifact C — Absorption Candidates** (ONLY produce if absorption discovery is authorized; otherwise omit entirely):

A numbered list of patterns this project has that the harness should consider adopting. For each:

1. Pattern name
2. Where it lives in the project (specific file path)
3. What harness capability it would enhance or create
4. Complexity of adoption (low / medium / high)

Do not produce Artifact C under any other circumstance. If no absorption candidates were found even with opt-in active, state explicitly: "Artifact C: No absorption candidates identified."

---

## Module Catalog

Use this catalog for Steps 2 and 3. Do not select modules not listed here.

> **Read each module's stability tier.** Every `module.yaml` declares
> `stability: {experimental | beta | stable}` (PRD-0027) — a readiness signal
> independent of trust tier and § 10 enforcement. Prefer `stable` modules for a
> project's load-bearing governance; treat `beta` as usable-but-unproven and
> `experimental` as adopt-with-eyes-open. v1 is informational — the harness does not
> block activating a `beta`/`experimental` module, it just makes the readiness honest.
>
> **Stack-parity note (be honest in onboarding).** The `stacks/` family is currently
> JS-skewed: `node-typescript` (the most exercised), `node-javascript`,
> `coffeescript` (`experimental`), and `python`. PHP / Go / Ruby / Rust / Java are
> not yet built (PHP is tracked in OPP-0011). For a non-JS/Python stack, onboard
> with the closest architecture/data/delivery overlays (which are stack-agnostic)
> and flag the missing stack module rather than forcing a poor fit.

---

### core (always required)

**`core/kernel/base`** — always include; no conditions; no conflicts.

Required artifacts: `HARNESS.md`, `AGENTS.md`, `docs/operating-principles.md`

---

### stacks (may combine for polyglot projects)

| Module | Select when |
| ------ | ----------- |
| `stacks/node-typescript` | `package.json` with TypeScript dependency, `tsconfig.json`, or `.nvmrc` found |
| `stacks/python` | `pyproject.toml`, `requirements.txt`, `setup.py`, or `.python-version` found |

No required artifacts for either stack module. When both are activated, the project is
polyglot — the manifest should reflect that, and `docs/architecture/overview.md` should
declare which stack is primary. If the two surfaces are genuinely independent services,
prefer separate manifests over a combined polyglot manifest.

---

### architectures (may combine)

| Module | Select when |
| ------ | ----------- |
| `architectures/web-app` | `pages/`, `app/`, view layer, SSR framework config (Next.js, SvelteKit, Nuxt) found |
| `architectures/api-service` | `src/routes/`, `src/api/`, OpenAPI spec, REST or GraphQL endpoint structure found |
| `architectures/event-driven` | Queue consumers, worker processes, background job scheduler, or event bus config found |
| `architectures/agent-skill-pack` | Authored skill collection (`skills/<name>/SKILL.md` + references + scripts) deployed to an agent runtime (OpenClaw / ClawHub, Claude Code, Cursor); eval-gated; the skills ARE the product — not an app, service, MCP server, or in-product agent UI |
| `architectures/agent-observability` | Agent activity is a first-class observable surface — the project emits OpenTelemetry agent traces a foundry or observability backend consumes (opt-in; v1 declarative) |
| `architectures/ai-foundry-target` | The project is built to drop into an enterprise AI foundry — Microsoft/Azure AI Foundry, NVIDIA, Palantir AIP, AWS Bedrock AgentCore, Google Vertex Agent Engine — and declares portable foundry-agnostic evidence (opt-in; v1 declarative) |
| `architectures/intelligent-model-routing` | The project routes different tasks to different models deliberately (capability / cost / privacy / regulatory / deployment-context) — a task→model routing table is an architectural fact, not a chatbot setting (opt-in; v1 declarative) |
| `architectures/agent-defense-in-depth` | The project runs autonomous agents and adopts Microsoft's four defense-in-depth patterns (scope-containment, least-permissions, human-in-the-loop on consequential actions, agent identity); composes with patient-facing health-agent safety in healthcare projects (opt-in; v1 declarative) |

Required artifact (web-app / api-service / event-driven / agent-skill-pack):
`docs/architecture/overview.md`. `agent-observability` instead requires
`docs/observability/trace-contract.md` + `docs/observability/exporters.md`.
`ai-foundry-target` instead requires `docs/architecture/foundry-targets.md` +
`docs/observability/trace-contract.md` (with `docs/architecture/model-routing.md`
optional). `intelligent-model-routing` instead requires
`docs/architecture/model-routing.md` (with `docs/architecture/model-routing-rationale.md`
optional). `agent-defense-in-depth` instead requires
`docs/security/agent-defense-in-depth.md` (with `docs/security/append-only-action-log.md`
optional, required-by-convention when any autonomous action is declared).

---

### data (may combine)

| Module | Select when | Dependencies |
| ------ | ----------- | ------------ |
| `data/relational-sql` | `migrations/`, Prisma `schema.prisma`, Drizzle config, or Postgres connection string found | — |
| `data/document-store` | MongoDB, Firestore, or DynamoDB client found | — |
| `data/object-storage` | S3, GCS, R2, or Supabase Storage SDK found | — |

Required artifact: `data/relational-sql` → `docs/database/migration-readiness.md`

No required artifacts for `document-store` or `object-storage`.

---

### delivery (pick exactly one)

| Module | Select when | Conflicts with |
| ------ | ----------- | -------------- |
| `delivery/prototype` | No real external users; throwaway, experimental, or purely internal | `delivery/production-saas` |
| `delivery/production-saas` | Real users, external dependencies, or data that matters; production or pre-production | `delivery/prototype` |
| `delivery/internal-platform` | Internal shared tooling with no external user-facing surface | — |
| `delivery/self-hosted-oss` | Published OSS shipped as a self-hosted deployment the user operates (not a hosted service, not throwaway); between prototype and production-saas | — |
| `delivery/managed-fleet` | Team operates configuration managing a live host fleet / hosting estate; production blast radius but no external app/distributable | `delivery/prototype` |

Required artifacts for `delivery/production-saas`: `docs/ops/environment-inventory.md`, `docs/ops/release-checklist.md`, `docs/ops/rollback-checklist.md`, `docs/security/risk-register.md`

Required artifact for `delivery/self-hosted-oss`: `docs/deployment/self-hosting-guide.md` (risk register optional; expected at criticality ≥ medium).

Required artifacts for `delivery/managed-fleet`: `docs/ops/fleet-inventory.md`, `docs/ops/change-control.md`, `docs/ops/config-rollback.md` (risk register optional; expected at criticality ≥ medium).

No required artifacts for `delivery/prototype`. Required artifacts for `delivery/internal-platform`: `docs/project/dependency-log.md`, `docs/project/milestones.md`.

---

### management (select applicable)

| Module | Select when | Required artifacts |
| ------ | ----------- | ------------------ |
| `management/discovery-intake` | Active discovery phase; requirements not yet finalized | `docs/discovery/intake-questionnaire.md`, `docs/discovery/mvp-scope.md` |
| `management/product-lite` | Any real product (non-throwaway); include for MVP and production | `docs/product/problem-statement.md`, `docs/product/requirements.md`, `docs/product/release-intent.md` |
| `management/project-standard` | Active project management, milestones, or scope tracking needed | `docs/project/scope-plan.md`, `docs/project/dependency-log.md`, `docs/project/milestones.md`, `docs/project/change-log.md`, `docs/project/revision-tracker.md` |
| `management/program-lite` | Multi-team or multi-workstream coordination | `docs/program/workstream-map.md`, `docs/program/stakeholder-report.md`, `docs/program/governance-cadence.md` |
| `management/testing-standard` | Formal test strategy and enforced coverage thresholds required | `docs/testing/test-strategy.md`, `docs/testing/coverage-thresholds.md` |
| `management/eval-gated-testing` | Quality gated on binary-graded evaluation of model/agent outputs (Waza / GAIA / UK-AISI Inspect) rather than line coverage; sibling to testing-standard, may combine | `docs/testing/eval-strategy.md` |
| `management/knowledge-capture` | Multi-participant project (agents + humans) producing longitudinal observations that crystallize into durable operating principles over time | `docs/knowledge/README.md`, `docs/knowledge/shared-observations.md` *(plus promotion into `docs/operating-principles.md` when patterns crystallize — see ADR-0014 for why `distilled-learnings.md` is no longer required)* |
| `management/opportunity-capture` | Capturing pre-PRD product candidates with explicit status, evidence linkage to observations, and a promotion path to PRDs | `docs/opportunities/README.md` (required); `docs/opportunities/candidates.md` (optional — organizational candidate index, add when the candidate set grows past a flat list) |
| `management/security-static-analysis` | Project ships software (not only docs) and SAST coverage of agent-generated code is a structural quality gate; consumer CI runs the tool, the harness validates the declaration (tool / scanPaths / severityThreshold) | `docs/security/sast-coverage.md` |
| `management/privacy-by-design` | Default-active for all projects. Encodes the 7 Cavoukian principles as governance. Opt out only by declaring `regime: none` with a documented reason. | `docs/privacy/privacy-profile.md` |
| `management/digital-twin` | Project models real-world systems, runs scenarios, or publishes decision-support (municipal/real-estate/datacenter/civic twins) | `docs/twin/twin-profile.md` |
| `management/work-package` | Dispatching two or more agents in parallel on isolated work-packages and want each agent's diff checked against its declared lane (allowedFiles / readOnlyFiles) | `docs/work-package/lane.md` |
| `management/canonical-position` | The project has strategic positioning concerns and you want a single ratified north-star every strategy-shaped artifact cites, revised only via a paired review-artifact | `docs/canonical-position.md` (+ optional `docs/reviews/`) |

Dependency: `management/program-lite` requires `management/project-standard`. `management/knowledge-capture` and `management/opportunity-capture` both depend on `management/project-standard`. `management/canonical-position` also depends on `management/project-standard`. `management/opportunity-capture` does not require `management/knowledge-capture` to be active, but its Origin / Evidence field is most useful when paired with `shared-observations.md` from `knowledge-capture`.

---

### domains (select if applicable)

| Module | Select when | Dependencies | Required artifacts |
| ------ | ----------- | ------------ | ------------------ |
| `domains/supabase` | `supabase/` directory or `@supabase/supabase-js` import found | `data/relational-sql` | none |
| `domains/media-pipeline` | `ffmpeg`, media processing jobs, or media CDN SDK found | `data/object-storage` | none |
| `domains/web3` | `ethers`, `wagmi`, `viem`, `hardhat`, `foundry`, `contracts/`, or `abi/` found | — | `docs/web3/chain-config.md` |
| `domains/gitbook` | `SUMMARY.md` at root or in `docs/`, `.gitbook.yaml` found | — | `docs/SUMMARY.md` |
| `domains/healthcare-fhir` | FHIR data layer; activate when a codebase implements FHIR resources / a FHIR server. Pairs with `domains/healthcare-smart-on-fhir`. | — | `docs/healthcare/fhir-resource-map.md`, `docs/healthcare/jurisdiction-profile.md` |
| `domains/healthcare-smart-on-fhir` | SMART app launch + OAuth scopes; activate when a codebase does SMART-on-FHIR auth (provider-launch or patient-access). | `domains/healthcare-fhir` | `docs/healthcare/smart-scope-map.md` |
| `domains/aec-iso19650-im` | ISO 19650 information delivery; activate when a project runs a CDE with information containers, a BEP, or a MIDP. | — | `docs/aec/information-management-plan.md`, `docs/aec/jurisdiction-profile.md` |
| `domains/aec-openbim-exchange` | openBIM (IFC/BCF/IDS) model exchange under an information-delivery contract. | `domains/aec-iso19650-im` | `docs/aec/exchange-requirements.md` |
| `domains/aec-iso19650-5-security` | Security-minded handling of sensitive built-asset information (BS EN ISO 19650-5). Composes with `management/privacy-by-design`. | `domains/aec-iso19650-im` | `docs/aec/sensitivity-assessment.md`, `docs/aec/security-management-plan.md` |
| `domains/geospatial-foundation` | Spatial-reference substrate; activate when a project handles GIS / mapping data, survey data, or coordinates tied to the real world. Forces a CRS / datum / epoch / units declaration. | — | `docs/geospatial/spatial-reference-profile.md`, `docs/geospatial/dataset-inventory.md` |
| `domains/geospatial-exchange` | OGC exchange formats/services (GeoJSON, GeoPackage, CityGML/CityJSON; WMS/WFS/WMTS, OGC API); publisher/consumer role axis + CRS-on-the-wire policy. | `domains/geospatial-foundation` | `docs/geospatial/exchange-profile.md` |
| `domains/geospatial-bim-georeference` | BIM↔GIS georeferencing bridge; activate when pinning a Revit/IFC model to real-world coordinates (IfcMapConversion, survey point). First cross-family dependency. | `domains/geospatial-foundation`, `domains/aec-openbim-exchange` | `docs/geospatial/georeference-map.md` |

---

### agents (select applicable)

| Module | Select when |
| ------ | ----------- |
| `agents/base` | Always include as baseline |
| `agents/claude-code` | Claude Code is the AI assistant for this project |
| `agents/codex-cli` | OpenAI Codex CLI is used with project-local approval, sandbox, or shim policy |
| `agents/copilot-cli` | GitHub Copilot CLI or custom Copilot CLI agents are used with project-local instructions |
| `agents/cursor` | Cursor is used with project-local rules or Auto-Run allowlist policy |
| `agents/gemini-cli` | Gemini CLI is used with project-local `GEMINI.md` or `.gemini/settings.json` context policy |
| `agents/generic-llm` | Another AI assistant is in use and no first-class tool pack fits yet |
| `agents/openclaw` | OpenClaw is the AI assistant for this project; requires `TOOLS.md` |

No required artifacts for `base`, `claude-code`, `codex-cli`, `copilot-cli`, `cursor`, or `generic-llm`. The `gemini-cli` pack requires either `GEMINI.md` or `.gemini/settings.json`. The `openclaw` pack requires `TOOLS.md` at project root.

---

## Progression Path

Embed a version of this roadmap in the Section 5 output, tailored to this project's specific gap profile.

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
| Standards pattern (single-source-of-truth artifacts) | `platform/workflow/standards-pattern.md` |
| All module definitions | `platform/profiles/` |
| Validator scripts | `platform/validators/` |
| Templates for missing artifacts | `platform/templates/` |
| CI integration guide | `platform/workflow/ci-integration.md` |
| Troubleshooting validator errors | `platform/workflow/troubleshooting.md` |
| harness-governance skill (ongoing governance) | `platform/skills/harness-governance/` |
| harness-testing skill (testing governance) | `platform/skills/harness-testing/` |
| Sample fully-onboarded project | `platform/examples/sample-projects/node-web-saas-postgres/` |
