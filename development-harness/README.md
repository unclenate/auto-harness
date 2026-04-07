# Development Harness

A modular governance framework for AI-assisted software development. It gives AI agents
(Claude Code, Cursor, GitHub Copilot, and others) a structured operating contract — so they
know what they're allowed to do, what artifacts must exist, when human review is required,
and what companion documentation must accompany every significant change.

> **Starting a new project?** Go straight to
> [`platform/workflow/bootstrap-quickstart.md`](platform/workflow/bootstrap-quickstart.md).
> Starting from just an idea? Use
> [`platform/workflow/discovery-to-composition.md`](platform/workflow/discovery-to-composition.md).
> Web3 project? Use
> [`platform/workflow/bootstrap-web3-quickstart.md`](platform/workflow/bootstrap-web3-quickstart.md).

---

## What It Does

The harness solves a specific problem: as AI agents become capable of writing, committing,
and deploying code, the guardrails that previously slowed things down (human review, change
documentation, governance gates) become more important, not less. Without them, agents
accelerate toward production at the speed of inference — with no paper trail, no ownership,
and no recovery path when something goes wrong.

The harness provides those guardrails without requiring you to write them from scratch for
every project. You declare which modules are active in a `harness.manifest.yaml`, and the
harness provides:

- **A trust tier model** — six tiers from read-only to production, with explicit rules for
  what agents can do at each tier and when human sign-off is required
- **Companion rules** — when file A changes, file B must also change in the same PR (e.g.,
  a requirements change must be reflected in the change log or an ADR)
- **Artifact requirements** — the files that must exist for a module to be considered active
  and governed (problem statement, ADRs, risk register, release checklist, etc.)
- **Sensitive path governance** — patterns that trigger elevated human review when changed
- **Validator chain** — six shell scripts you run locally or in CI that enforce all of the above
- **Agent adapters** — `CLAUDE.md`, `AGENTS.md`, and `.claude/settings.json` shims that load
  the governance rules into agent context at session start

---

## How It Works

### 1. Declare your modules

A project uses a `harness.manifest.yaml` at its root. This file says which modules are
active. Modules are composable — you pick the stack, architecture, data layer, delivery
model, and agent tooling that match your project:

```yaml
schemaVersion: 1
project:
  id: my-app
  name: My App
  maturity: mvp
  criticality: medium
modules:
  core:
    - kernel/base
  stacks:
    - node-typescript
  architectures:
    - web-app
  data:
    - relational-postgres
  delivery:
    - production-saas
  management:
    - product-lite
    - project-standard
  domains:
    - supabase
  agents:
    - claude-code
```

### 2. Run the validators

The validator chain checks your manifest and project against the declared modules:

```bash
PLATFORM=development-harness/platform

bash $PLATFORM/validators/validate-manifest.sh harness.manifest.yaml
bash $PLATFORM/validators/validate-module-graph.sh harness.manifest.yaml
bash $PLATFORM/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash $PLATFORM/validators/validate-placeholders.sh harness.manifest.yaml .
bash $PLATFORM/validators/validate-agent-pack.sh harness.manifest.yaml .  # if agents/* modules are active
bash $PLATFORM/validators/validate-companions.sh harness.manifest.yaml main
```

Each exits 0 on pass, 1 on failure, with a specific error message per issue.

### 3. Wire CI

Add the validators to `.github/workflows/harness.yml`. They run on every PR and catch
governance gaps before merge — missing artifacts, unaccompanied changes to sensitive paths,
or unfilled template placeholders.

### 4. Install agent skills

Harness-native skills in [Agent Skills](https://agentskills.io/specification) format load
the governance rules into your AI agent's context on demand:

```bash
cp -r platform/skills/harness-governance .agents/skills/
cp -r platform/skills/harness-web3 .agents/skills/   # Web3 projects only
```

When Claude Code (or any compliant client) detects a governance-relevant task, it activates
the skill and loads the full rule set — trust tiers, companion rules, validator commands,
and artifact guidance.

---

## Trust Tier Model

Every action an agent can take is classified into one of six tiers:

| Tier | Name | Examples | Gate |
| ---- | ---- | -------- | ---- |
| 0 | Read-only | Read files, search, inspect git history | None |
| 1 | Local analysis | Run tests, builds, linters | None |
| 2 | Workspace mutation | Edit files, create artifacts, scaffold docs | None |
| 3 | Git-writing | Commit, push to feature branches | None |
| 4 | Environment-altering | Run migrations, install deps, change env vars | Human direction required |
| 5 | Remote / production | Deploy, production migrations, secrets rotation | Human direction + second sign-off |

Agents may always operate at a lower tier than their adapter declares. They may never
self-elevate. This model is the kernel — it applies regardless of which other modules
are active.

---

## Module System

Modules are the building blocks. Each module is a directory with a `module.yaml` that
declares its governance contract. You compose them to match your project.

### Module Families

| Family | Purpose | Examples |
| ------ | ------- | ------- |
| **Core** | Universal doctrine — always active | `kernel/base` |
| **Stacks** | Language and framework adaptations | `node-typescript`, `python` |
| **Architectures** | Deployment and interaction patterns | `web-app`, `api-service`, `event-driven` |
| **Data** | Storage overlays | `relational-postgres`, `document-store`, `object-storage` |
| **Delivery** | Lifecycle posture | `prototype`, `production-saas`, `internal-platform` |
| **Management** | Product, project, and program governance | `discovery-intake`, `product-lite`, `project-standard`, `program-lite` |
| **Domains** | Vendor or specialist overlays | `supabase`, `web3`, `media-pipeline`, `gitbook` |
| **Agents** | AI-tool operating packs | `base`, `claude-code`, `generic-llm` |

### What a Module Declares

Each `module.yaml` specifies:

- **`requiredArtifacts`** — files that must exist (e.g., `docs/product/requirements.md`)
- **`sensitivePaths`** — path patterns that trigger elevated review (e.g., `migrations/`)
- **`companionRules`** — when X changes, Y must also change in the same PR
- **`validators`** — which validator IDs apply
- **`reviewGates`** — human review conditions
- **`compiledFragments`** — docs loaded into agent context at every session start
- **`recommendedSkills`** — Agent Skills and OpenClaw/ClawHub skills for this module

---

## Starter Compositions

Pre-built manifests for common project types. Copy the closest match and adjust:

| Composition | Stack | Use When |
| ----------- | ----- | -------- |
| [`new-product-discovery.yaml`](platform/compositions/new-product-discovery.yaml) | Stack TBD | Discovery phase — idea to first manifest |
| [`node-web-saas-postgres.yaml`](platform/compositions/node-web-saas-postgres.yaml) | Node / TS | Web app with PostgreSQL |
| [`python-api-service-postgres.yaml`](platform/compositions/python-api-service-postgres.yaml) | Python | API service with PostgreSQL |
| [`research-pipeline-python-object-storage.yaml`](platform/compositions/research-pipeline-python-object-storage.yaml) | Python | Data / ML pipeline |
| [`web3-risk-analytics.yaml`](platform/compositions/web3-risk-analytics.yaml) | Python | Blockchain-integrated platform |

```bash
cp platform/compositions/node-web-saas-postgres.yaml harness.manifest.yaml
```

---

## Workflow Guides

| Guide | What It Covers |
| ----- | -------------- |
| [`bootstrap-quickstart.md`](platform/workflow/bootstrap-quickstart.md) | Zero to running harness in one session |
| [`bootstrap-web3-quickstart.md`](platform/workflow/bootstrap-web3-quickstart.md) | Web3-specific bootstrap with chain config and skill setup |
| [`discovery-to-composition.md`](platform/workflow/discovery-to-composition.md) | Idea / mockup / spec → `harness.manifest.yaml` in 8 steps |
| [`skills-and-agents.md`](platform/workflow/skills-and-agents.md) | Agent Skills standard, harness-native skills, OpenClaw ecosystem |
| [`ci-integration.md`](platform/workflow/ci-integration.md) | Wiring validators into GitHub Actions |
| [`troubleshooting.md`](platform/workflow/troubleshooting.md) | Every validator error, cause, and fix |

---

## Companion Rules

Companion rules are the harness's paper-trail mechanism. They enforce the discipline that
documentation is part of the change, not follow-up work.

**Example:** The `product-lite` module declares this companion rule:

> When `docs/product/requirements.md` changes, either `docs/project/change-log.md` or a
> new `docs/adr/ADR-XXXX-*.md` must also be in the same PR.

This means a product requirements change cannot be merged silently. It must either be
logged in the change log (lightweight) or escalated to an ADR (for architectural impact).

The `validate-companions.sh` validator enforces this in CI by diffing the PR against the
base branch and checking every changed file against active companion rules.

Key companion rules by domain:

- **Requirements change** → change-log entry or ADR
- **Database migration** → migration readiness doc in same PR
- **Smart contract surface** → risk register or architecture update
- **Scoring rules change** → ADR required
- **Claude adapter change** → `AGENTS.md` or ADR in same PR

---

## Templates

Every required artifact has a template. Templates use `[[PLACEHOLDER_NAME]]` tokens
for fields that must be filled. The `validate-placeholders.sh` validator fails if any
token remains in a tracked file.

Template categories:

- **Discovery** — intake questionnaire, MVP scope, starting assets log
- **Product** — problem statement, personas, requirements, release intent
- **Project** — scope plan, milestones, change log, dependency log
- **Program** — workstream map, stakeholder report, governance cadence
- **Architecture and Ops** — ADR, architecture overview, release checklist, risk register,
  incident response, ownership map, runbook index, runbook template
- **Web3** — chain config, contract registry, token strategy, Web3 risk register, Web3 ADR

See [`platform/templates/README.md`](platform/templates/README.md) for the full placeholder
reference and a table mapping each template to the module that requires it.

---

## Agent Skills

The harness provides two skills in [Agent Skills](https://agentskills.io/specification) format
— the open standard supported by Claude Code, VS Code Copilot, GitHub Copilot, Cursor,
Gemini CLI, and others:

| Skill | Install When | Provides |
| ----- | ------------ | -------- |
| [`harness-governance`](platform/skills/harness-governance/SKILL.md) | All projects | Trust tiers, companion rules, lifecycle controls, validator commands |
| [`harness-web3`](platform/skills/harness-web3/SKILL.md) | Web3 projects | UNKNOWN propagation, rate limit budgets, evidence requirements, Tier 5 gates |

Skills are progressively disclosed — agents load only the name and description (~100 tokens)
at startup. The full body loads on demand when a task matches the skill's domain.

```bash
# Cross-client installation
cp -r platform/skills/harness-governance .agents/skills/
cp -r platform/skills/harness-web3 .agents/skills/   # Web3 only

# Claude Code native path
cp -r platform/skills/harness-governance .claude/skills/
```

---

## Validators

Six validators, each targeting a specific governance layer:

| Validator | What It Checks |
| --------- | -------------- |
| `validate-manifest.sh` | Schema, required project fields, valid module categories |
| `validate-module-graph.sh` | Module existence, dependency chain, conflict detection |
| `validate-required-artifacts.sh` | Every required artifact exists on disk |
| `validate-placeholders.sh` | No unfilled `[[PLACEHOLDER]]` tokens in tracked files |
| `validate-agent-pack.sh` | Agent adapter files exist and are consistent |
| `validate-companions.sh` | PR diff satisfies all active companion rules |

All validators are pure shell + Ruby (no external service calls). Ruby 3.0+ and ripgrep
are the only runtime requirements.

---

## Platform Structure

```text
development-harness/
├── platform/                    # Source of truth for the harness framework
│   ├── core/                    # Kernel doctrine, trust model, schemas, registry
│   │   └── kernel/base/         # trust-model.md, doctrine.md, lifecycle-controls.md
│   ├── profiles/                # All module definitions
│   │   ├── stacks/              # node-typescript, python
│   │   ├── architectures/       # web-app, api-service, event-driven
│   │   ├── data/                # relational-postgres, document-store, object-storage
│   │   ├── delivery/            # prototype, production-saas, internal-platform
│   │   ├── management/          # discovery-intake, product-lite, project-standard, program-lite
│   │   └── domains/             # supabase, web3, media-pipeline, gitbook
│   ├── agents/                  # Agent operating packs: base, claude-code, generic-llm
│   ├── skills/                  # Harness-native Agent Skills: harness-governance, harness-web3
│   ├── templates/               # Artifact skeletons for every required file
│   ├── validators/              # validate-*.sh scripts + Ruby harness_registry lib
│   ├── compositions/            # Starter manifests for common project types
│   ├── examples/                # Sample project with all artifacts filled in
│   ├── workflow/                # Guides: bootstrap, discovery, CI, troubleshooting
│   ├── SUMMARY.md               # Full GitBook table of contents
│   └── README.md                # Platform front door
└── legacy/v3/                   # Frozen v3 harness — preserved as historical baseline
```

---

## Getting Started

**Step 1 — Pick your starting point:**

| Situation | Where to go |
| --------- | ----------- |
| Raw idea, no stack chosen | [`workflow/discovery-to-composition.md`](platform/workflow/discovery-to-composition.md) |
| Know your stack, ready to build | [`workflow/bootstrap-quickstart.md`](platform/workflow/bootstrap-quickstart.md) |
| Web3 project | [`workflow/bootstrap-web3-quickstart.md`](platform/workflow/bootstrap-web3-quickstart.md) |
| Already have a manifest | Run `validate-manifest.sh` and go from there |

**Step 2 — Copy a starter composition:**

```bash
cp platform/compositions/node-web-saas-postgres.yaml harness.manifest.yaml
# or: new-product-discovery.yaml, python-api-service-postgres.yaml, web3-risk-analytics.yaml
```

**Step 3 — Run validators:**

```bash
PLATFORM=development-harness/platform
bash $PLATFORM/validators/validate-manifest.sh harness.manifest.yaml
bash $PLATFORM/validators/validate-module-graph.sh harness.manifest.yaml
```

**Step 4 — Create required artifacts:**

```bash
bash $PLATFORM/validators/validate-required-artifacts.sh harness.manifest.yaml .
# Follow the output — each missing file maps to a template in platform/templates/
```

**Step 5 — Install agent skills:**

```bash
cp -r platform/skills/harness-governance .agents/skills/
```

**Step 6 — Wire CI and you're done.**

The harness is Bootstrap Complete when all validators exit 0 and your CI is green.

---

## Design Principles

These principles are from the kernel doctrine and apply across all modules:

- **Ownership is explicit.** Every domain has a named primary and secondary owner.
- **Review is knowledge distribution, not a rubber stamp.** Reviewers verify real things.
- **Documentation is part of the change.** Companion rules enforce this mechanically.
- **Secrets never belong in tracked artifacts.** No exceptions.
- **Migrations, releases, and incidents are operational events.** They require runbooks,
  checklists, and a paper trail.
- **AI acceleration increases the need for controls, not the license to skip them.**

---

## Reference

| Resource | Path |
| -------- | ---- |
| Platform table of contents | [`platform/SUMMARY.md`](platform/SUMMARY.md) |
| Bootstrap quickstart | [`platform/workflow/bootstrap-quickstart.md`](platform/workflow/bootstrap-quickstart.md) |
| Discovery workflow | [`platform/workflow/discovery-to-composition.md`](platform/workflow/discovery-to-composition.md) |
| All templates | [`platform/templates/`](platform/templates/) |
| All compositions | [`platform/compositions/`](platform/compositions/) |
| Skills guide | [`platform/workflow/skills-and-agents.md`](platform/workflow/skills-and-agents.md) |
| Troubleshooting | [`platform/workflow/troubleshooting.md`](platform/workflow/troubleshooting.md) |
| Sample project | [`platform/examples/sample-projects/node-web-saas-postgres/`](platform/examples/sample-projects/node-web-saas-postgres/) |
| Legacy v3 harness | [`legacy/v3/`](legacy/v3/) |
