<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# auto-harness

[![License: MIT OR Apache-2.0](https://img.shields.io/badge/License-MIT_OR_Apache--2.0-blue.svg)](#license)
[![Status: Alpha](https://img.shields.io/badge/Status-Alpha-orange.svg)](HARNESS.md)
[![Contributions: Welcome](https://img.shields.io/badge/Contributions-Welcome-brightgreen.svg)](CONTRIBUTING.md)

![auto-harness — without it vs with it](docs/_assets/proposed-visuals/hero-before-after.svg)

**A modular governance framework for AI-assisted software development.**

Without it, AI agents can write, commit, and deploy at the speed of inference — with no paper trail, no ownership, and no recovery path when something breaks. With it, the same agents work under a structured operating contract: trust tiers, companion rules, required artifacts, and validators that fail CI when documentation drifts.

Here is what a project's harness looks like in a `harness.manifest.yaml`:

```yaml
modules:
  core:
    - kernel/base
  stacks:
    - node-typescript
  delivery:
    - production-saas
  agents:
    - claude-code
```

That declares which governance modules are active. The validator chain reads it, the companion rules fire on PR diffs, and AI agents (Claude Code, Cursor, Copilot, Codex, Gemini, OpenClaw) load the harness's rules into context at session start.

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
- **Validator chain** — fourteen shell scripts you run locally or in CI that enforce all of the above
- **Agent adapters** — `CLAUDE.md`, `AGENTS.md`, and `.claude/settings.json` shims that load
  the governance rules into agent context at session start

---

## Who This Is For

- **Solo founder vibecoding an MVP** — you want guardrails so your AI agents don't merge themselves into a corner. Adopt the smallest composition (`brownfield-lite` or `interview-driven-discovery`), wire one CI job, and grow from there.
- **Senior dev adding discipline to a growing project** — you want module governance you can opt into incrementally without rewriting your repo. Pick the composition closest to your stack, run the validators, and tune `disabledValidations` until you're ready to enable each one.
- **AI agent (Claude Code, Cursor, Copilot, OpenClaw, Gemini)** — read [`AGENTS.md`](AGENTS.md) first; it states the trust tier model, what you can and cannot do, when to stop, and the first-session workflow.

---

## Adoption paths

Pick the one that fits your situation:

- **New project, stack chosen?** [`platform/workflow/bootstrap-quickstart.md`](platform/workflow/bootstrap-quickstart.md)
- **Just an idea?** [`platform/workflow/discovery-to-composition.md`](platform/workflow/discovery-to-composition.md)
- **Existing codebase?** [`platform/workflow/brownfield-onboarding.md`](platform/workflow/brownfield-onboarding.md)
- **Web3 project?** [`platform/workflow/bootstrap-web3-quickstart.md`](platform/workflow/bootstrap-web3-quickstart.md)
- **Already adopted, need to update or audit?** [`platform/workflow/maintenance-operations.md`](platform/workflow/maintenance-operations.md)
- **Want the recommended consumption pattern?** [`platform/workflow/submodule-integration.md`](platform/workflow/submodule-integration.md) — mount auto-harness as a git submodule for automatic upstream updates

---

**Maintainer:** Nate DiNiro · <UncleNate@gmail.com>
**Contributing:** see [CONTRIBUTING.md](CONTRIBUTING.md) · **Security:** see [SECURITY.md](SECURITY.md) · **Conduct:** see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)

<details>
<summary>Full table of contents — 17 sections; expand for navigation</summary>

- [What It Does](#what-it-does)
- [Who This Is For](#who-this-is-for)
- [Adoption paths](#adoption-paths)
- [Entry Points at the Repo Root](#entry-points-at-the-repo-root)
- [How It Works](#how-it-works)
- [Concepts](#concepts) — Trust Tier Model, Module System, Companion Rules
- [Starter Compositions](#starter-compositions)
- [Operator Workflows](#operator-workflows) — Adoption, Day-to-Day, Maintenance & Operations
- [Agent Skills](#agent-skills)
- [Validators](#validators)
- [Templates](#templates)
- [Getting Started](#getting-started)
- [Integrating into Your Repo](#integrating-into-your-repo)
- [Platform Structure](#platform-structure)
- [Design Principles](#design-principles)
- [Contributing](#contributing)
- [License](#license)
- [Reference](#reference)

</details>

---

## Entry Points at the Repo Root

Five files share the repo root. Each has a distinct job — read the one that matches your role first, then read the others as needed.

| File | Role | Best for |
| ---- | ---- | -------- |
| [`README.md`](README.md) | Repo and GitBook front door | First-time human reader |
| [`HARNESS.md`](HARNESS.md) | Project-level governance entrypoint — active modules, governance artifacts, source-of-truth pointers | Anyone auditing what governance is actually active on this repo |
| [`AGENTS.md`](AGENTS.md) | Cross-agent operating manual — trust tiers, scope, stop conditions, first-session workflow | Any AI tool (Cursor, Copilot, Codex, OpenClaw, Gemini, etc.) |
| [`CLAUDE.md`](CLAUDE.md) | Claude Code load-order shim | Claude Code specifically; it points at the three files above in order |
| [`TOOLS.md`](TOOLS.md) | Environment-specific tool registry for MCP developer tools | Agents using Linear, Slack, or other MCP tools; loaded on demand |

---

## How It Works

The harness is composed of four cooperating layers — a manifest declaring active modules, the modules' own contracts, the validators that enforce those contracts at PR time, and the consumer-facing surfaces (skills, templates, workflows) that support the contract:

```mermaid
flowchart TD
    Manifest["<b>harness.manifest.yaml</b><br/>project-local activation"]

    subgraph CATALOG["Active Catalog (per project)"]
        Manifest --> Modules["<b>Modules</b><br/>core · profiles · agents"]
    end

    subgraph CONTRACT["Per-Module Contract (module.yaml)"]
        Modules --> Required["<b>requiredArtifacts</b><br/>files that must exist"]
        Modules --> Companions["<b>companionRules</b><br/>trigger paths → required satisfiers"]
        Modules --> Sensitive["<b>sensitivePaths</b><br/>extra review weight"]
    end

    subgraph ENFORCE["Enforcement (CI)"]
        Validators["<b>Validators</b><br/>14 scripts"]
        Validators -.reads.-> Manifest
        Validators -.reads.-> Companions
        Validators --> CIGate["<b>CI gates merge</b>"]
    end

    subgraph SURFACE["Consumer-Facing Surfaces"]
        Skills["Skills"]
        Templates["Templates"]
        Workflows["Workflows"]
    end

    Modules -.supports.-> Skills
    Modules -.scaffolds via.-> Templates
    Modules -.documented in.-> Workflows
```

For the full set of architecture diagrams (eleven in total — covering trust tier flow, companion rule firing, the OPP/PRD/ADR lifecycle, and more) see [`docs/architecture/diagrams.md`](docs/architecture/diagrams.md).

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
bash platform/validators/validate-manifest.sh harness.manifest.yaml
bash platform/validators/validate-module-graph.sh harness.manifest.yaml
bash platform/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash platform/validators/validate-placeholders.sh .
bash platform/validators/validate-agent-pack.sh harness.manifest.yaml .  # if agents/* modules are active
bash platform/validators/validate-companions.sh harness.manifest.yaml . main
bash platform/validators/validate-doc-references.sh .
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

## Concepts

### Trust Tier Model

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

### Module System

Modules are the building blocks. Each module is a directory with a `module.yaml` that
declares its governance contract. You compose them to match your project.

| Family | Purpose | Examples |
| ------ | ------- | ------- |
| **Core** | Universal doctrine — always active | `kernel/base` |
| **Stacks** | Language and framework adaptations | `node-typescript`, `python` |
| **Architectures** | Deployment and interaction patterns | `web-app`, `api-service`, `event-driven`, `mcp-server` |
| **Data** | Storage overlays | `relational-postgres`, `document-store`, `object-storage` |
| **Delivery** | Lifecycle posture | `prototype`, `production-saas`, `internal-platform`, `self-hosted-oss`, `managed-fleet` |
| **Management** | Product, project, program, knowledge, opportunity, and testing governance | `discovery-intake`, `product-lite`, `project-standard`, `program-lite`, `testing-standard`, `knowledge-capture`, `opportunity-capture` |
| **Domains** | Vendor or specialist overlays | `supabase`, `web3`, `media-pipeline`, `gitbook` |
| **Agents** | AI-tool operating packs | `base`, `claude-code`, `generic-llm`, `openclaw` |

Each `module.yaml` specifies:

- **`requiredArtifacts`** — files that must exist (e.g., `docs/product/requirements.md`)
- **`sensitivePaths`** — path patterns that trigger elevated review (e.g., `migrations/`)
- **`companionRules`** — when X changes, Y must also change in the same PR
- **`validators`** — which validator IDs apply
- **`reviewGates`** — human review conditions
- **`compiledFragments`** — docs loaded into agent context at every session start
- **`recommendedSkills`** — Agent Skills and OpenClaw/ClawHub skills for this module

### Companion Rules

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
- **Governance entrypoint change** (HARNESS.md, AGENTS.md) → ADR or `docs/operating-principles.md` update

---

## Starter Compositions

Pre-built manifests for common project types. Copy the closest match and adjust:

| Composition | Stack | Use When |
| ----------- | ----- | -------- |
| [`brownfield-lite.yaml`](platform/compositions/brownfield-lite.yaml) | Any | Existing codebase — assessment pending |
| [`new-product-discovery.yaml`](platform/compositions/new-product-discovery.yaml) | Stack TBD | Discovery phase — idea to first manifest |
| [`interview-driven-discovery.yaml`](platform/compositions/interview-driven-discovery.yaml) | Stack TBD | Monolithic-PRD or hackathon-style intake — one structured interview produces the artifact spine |
| [`node-web-saas-postgres.yaml`](platform/compositions/node-web-saas-postgres.yaml) | Node / TS | Web app with PostgreSQL |
| [`python-api-service-postgres.yaml`](platform/compositions/python-api-service-postgres.yaml) | Python | API service with PostgreSQL |
| [`research-pipeline-python-object-storage.yaml`](platform/compositions/research-pipeline-python-object-storage.yaml) | Python | Data / ML pipeline |
| [`web3-risk-analytics.yaml`](platform/compositions/web3-risk-analytics.yaml) | Python | Blockchain-integrated platform |
| [`agentic-ui-saas.yaml`](platform/compositions/agentic-ui-saas.yaml) | Node / TS | SaaS web-app shipping an in-product agentic interface (copilot or generative UI) |
| [`mcp-server-typescript.yaml`](platform/compositions/mcp-server-typescript.yaml) | Node / TS | Projects shipping their own MCP server (producer-side: tools, transports, prompt-injection defense) |
| [`mcp-server-typescript-oss.yaml`](platform/compositions/mcp-server-typescript-oss.yaml) | Node / TS | OSS-released MCP server (producer-side + `delivery/self-hosted-oss` + project-standard + knowledge-capture) |

```bash
cp platform/compositions/node-web-saas-postgres.yaml harness.manifest.yaml
```

---

## Operator Workflows

The harness journeys split into three phases. Use the right guide for the right phase:

### Adoption Workflows — One-Time Setup

How to *start* using the harness on a project. You generally walk through one of these once per project.

| Guide | What It Covers |
| ----- | -------------- |
| [`bootstrap-quickstart.md`](platform/workflow/bootstrap-quickstart.md) | Zero to running harness in one session (stack known, copy-mode flow) |
| [`bootstrap-web3-quickstart.md`](platform/workflow/bootstrap-web3-quickstart.md) | Web3-specific bootstrap with chain config and skill setup |
| [`discovery-to-composition.md`](platform/workflow/discovery-to-composition.md) | Idea / mockup / spec → `harness.manifest.yaml` in 8 steps |
| [`brownfield-onboarding.md`](platform/workflow/brownfield-onboarding.md) | Bring an existing codebase into the harness progressively |
| [`submodule-integration.md`](platform/workflow/submodule-integration.md) | **Recommended** consumption pattern — auto-harness as a git submodule, with `install.sh` brownfield-safe bootstrap |

### Day-to-Day Workflows — Active Development

How to *use* the harness during normal development on a project that has already adopted it.

| Guide | What It Covers |
| ----- | -------------- |
| [`skills-and-agents.md`](platform/workflow/skills-and-agents.md) | Agent Skills standard, harness-native skills, OpenClaw ecosystem |
| [`ci-integration.md`](platform/workflow/ci-integration.md) | Wiring validators into GitHub Actions and other CI systems |
| [`standards-pattern.md`](platform/workflow/standards-pattern.md) | Standards governance workflow |

Running validators locally before each commit, honoring companion rules per PR, and keeping skills active are the day-to-day practices that the validator chain enforces.

### Maintenance & Operations — Keeping It Healthy

How to *keep the harness itself healthy* after adoption — upgrade flow, version pinning, drift recovery, governance audits.

| Guide | What It Covers |
| ----- | -------------- |
| [`maintenance-operations.md`](platform/workflow/maintenance-operations.md) | Upstream improvements, version pinning, rollback, validator lifecycle after adoption, drift detection, copy-to-submodule migration, lifecycle transitions, periodic governance audits |
| [`troubleshooting.md`](platform/workflow/troubleshooting.md) | Validator error solver — per-error cause and fix reference |

A consumer project that adopts the harness once needs the maintenance guide indefinitely. Treat it as the long-term operator manual.

---

## Agent Skills

The harness provides seven skills in [Agent Skills](https://agentskills.io/specification) format
— the open standard supported by Claude Code, VS Code Copilot, GitHub Copilot, Cursor,
Gemini CLI, and others:

| Skill | Install When | Provides |
| ----- | ------------ | -------- |
| [`harness-governance`](platform/skills/harness-governance/SKILL.md) | All projects | Trust tiers, companion rules, lifecycle controls, validator commands |
| [`harness-testing`](platform/skills/harness-testing/SKILL.md) | Projects with `testing-standard` active | Test strategy patterns, coverage enforcement, framework-specific guidance |
| [`harness-web3`](platform/skills/harness-web3/SKILL.md) | Web3 projects | UNKNOWN propagation, rate limit budgets, evidence requirements, Tier 5 gates |
| [`harness-onboarding`](platform/skills/harness-onboarding/SKILL.md) | Brownfield onboarding | Repository assessment, gap analysis, lite manifest generation |
| [`harness-tools`](platform/skills/harness-tools/SKILL.md) | Projects with `agents/openclaw` active | MCP developer tool governance: trust tier map, Linear artifact workflow, Slack notifications, analytics tools |
| [`harness-agentic-interfaces`](platform/skills/harness-agentic-interfaces/SKILL.md) | Projects with `domains/agentic-interfaces` active | In-product copilot / generative-UI / conversational-primary governance: flavor map, tier discipline for agent-callable actions, prompt-injection and renderer-contract threat model |
| [`harness-mcp`](platform/skills/harness-mcp/SKILL.md) | Projects with `architectures/mcp-server` active | Producer-side MCP work: three-mode map (consumer / producer / exposed-governance), per-tool consumer-tier mapping, prompt-injection defense surface, capability and transport posture |

Skills are progressively disclosed — agents load only the name and description (~100 tokens)
at startup. The full body loads on demand when a task matches the skill's domain.

```bash
# Cross-client installation (all projects)
cp -r platform/skills/harness-governance .agents/skills/

# Install additional skills based on active modules
cp -r platform/skills/harness-testing .agents/skills/    # testing-standard active
cp -r platform/skills/harness-web3 .agents/skills/       # Web3 projects
cp -r platform/skills/harness-onboarding .agents/skills/ # brownfield onboarding
cp -r platform/skills/harness-tools .agents/skills/      # agents/openclaw active

# Claude Code native path
cp -r platform/skills/harness-governance .claude/skills/
```

---

## Validators

Fourteen validators, each targeting a specific governance layer:

| Validator | What It Checks |
| --------- | -------------- |
| `validate-manifest.sh` | Schema, required project fields, valid module categories |
| `validate-module-graph.sh` | Module existence, dependency chain, conflict detection |
| `validate-required-artifacts.sh` | Every required artifact exists on disk |
| `validate-placeholders.sh` | No unfilled `[[PLACEHOLDER]]` tokens in tracked files |
| `validate-agent-pack.sh` | Agent adapter files exist and are consistent |
| `validate-companions.sh` | PR diff satisfies all active companion rules |
| `validate-doc-references.sh` | Markdown links to `platform/...` paths resolve on disk — catches stale path strings as the catalog evolves |
| `validate-catalog-counts.sh` | Documented catalog counts (modules, validators, skills, templates, workflows, diagrams) match canonical recipes — closes the count-drift class |
| `validate-list-completeness.sh` | Every ADR / PRD / OPP / composition / template subdirectory / profile module on disk is referenced by its canonical index file — closes the list-completeness drift class |
| `validate-trust-tier.sh` | Each active module's declared trust tier (0–5) is coherent with its inferred tier (from `sensitivePaths`); agent `maxTier` ceilings respect the active manifest's highest non-agent tier — closes safety claims 10–11 (no self-elevation; tier-ceiling fixed) |
| `validate-sensitive-paths.sh` | Every declared `sensitivePaths` regex is overlapped by at least one `companionRules.triggerPaths` regex on some active module — closes safety claim 12 (sensitive-paths from Asserted-only to Enforced) |
| `validate-skill-content.sh` | Scans authored prose in active modules (description / summary / reviewGates / humanReview + SKILL.md bodies + compiledFragments markdown) against a denylist of prompt-injection and tier-bypass patterns (default BLOCK; `.skill-content-ignore` for exemptions) — closes safety-security-sweep §3 vectors V1/V2/V4-partial/V6 |
| `validate-knowledge-redaction.sh` | Surfaces consumer-name hits in new lines added to `docs/knowledge/shared-observations.md` and `docs/operating-principles.md` (default WARN; `--block` for hard fail) — closes the §8 cross-pollination + §9 upstream-propagation pathways |
| `validate-sast-coverage.sh` | Opt-in: when `management/security-static-analysis` is active, validates `docs/security/sast-coverage.md` declares a recommended-set tool (`semgrep` / `codeql` / `bandit` / `gosec` / `eslint-plugin-security` / `snyk-code`), scan paths, and a severity threshold — half-enforces sweep §11 (consumer CI honors the contract for end-to-end enforcement) |

All validators are pure shell + Ruby (no external service calls). Ruby 3.0+ and ripgrep
are the only runtime requirements.

---

## Templates

Every required artifact has a template. Templates use `[[PLACEHOLDER_NAME]]` tokens
for fields that must be filled. The `validate-placeholders.sh` validator fails if any
token remains in a tracked file.

Template categories:

- **Discovery** — intake questionnaire, MVP scope, starting assets log
- **Product** — problem statement, personas, requirements, release intent, PRD
- **Project** — scope plan, milestones, change log, dependency log, revision tracker, review log
- **Knowledge** — shared observations, distilled learnings
- **Opportunity** — opportunity record (OPP-NNNN) for pre-PRD candidates
- **Program** — workstream map, stakeholder report, governance cadence
- **Testing** — test strategy, coverage thresholds, test plan
- **Governance** — operating principles, tools registry
- **Standards** — KPI dictionary
- **Architecture and Ops** — ADR, architecture overview, release checklist, risk register,
  incident response, ownership map, runbook index, runbook template, fallback matrix
- **Database** — migration readiness
- **Web3** — chain config, contract registry, token strategy, Web3 risk register, Web3 ADR, Web3 intake supplement

See [`platform/templates/README.md`](platform/templates/README.md) for the full placeholder
reference and a table mapping each template to the module that requires it.

---

## Getting Started

**Step 1 — Pick your starting point:**

| Situation | Where to go |
| --------- | ----------- |
| Raw idea, no stack chosen | [`workflow/discovery-to-composition.md`](platform/workflow/discovery-to-composition.md) |
| Know your stack, ready to build | [`workflow/bootstrap-quickstart.md`](platform/workflow/bootstrap-quickstart.md) |
| Existing codebase, not harness-compliant | [`workflow/brownfield-onboarding.md`](platform/workflow/brownfield-onboarding.md) |
| Web3 project | [`workflow/bootstrap-web3-quickstart.md`](platform/workflow/bootstrap-web3-quickstart.md) |
| Already have a manifest | Run `validate-manifest.sh` and go from there |

**Step 2 — Copy a starter composition:**

```bash
cp platform/compositions/node-web-saas-postgres.yaml harness.manifest.yaml
# or: new-product-discovery.yaml, python-api-service-postgres.yaml, web3-risk-analytics.yaml
```

**Step 3 — Run validators:**

```bash
bash platform/validators/validate-manifest.sh harness.manifest.yaml
bash platform/validators/validate-module-graph.sh harness.manifest.yaml
```

**Step 4 — Create required artifacts:**

```bash
bash platform/validators/validate-required-artifacts.sh harness.manifest.yaml .
# Follow the output — each missing file maps to a template in platform/templates/
```

**Step 5 — Install agent skills:**

```bash
cp -r platform/skills/harness-governance .agents/skills/
```

**Step 6 — Wire CI and you're done.**

The harness is Bootstrap Complete when all validators exit 0 and your CI is green.

After adoption, the [Maintenance & Operations guide](platform/workflow/maintenance-operations.md) is the operator manual you return to for upgrades, audits, and lifecycle transitions.

---

## Integrating into Your Repo

The steps above show the "platform-at-root" / self-dogfood pattern — auto-harness's `platform/` tree lives inside the repo. For consumer projects, the recommended pattern is **auto-harness as a git submodule**:

**Prerequisites.** macOS ships Bash 3.2 by default (GPL-v3 licensing reasons), which `install.sh` refuses to run under because it relies on associative arrays. Install Bash 4+ via Homebrew before bootstrapping: `brew install bash`. The script will exit cleanly with a helpful message if it detects Bash <4, but installing upfront avoids a confusing first run. Linux users typically have Bash 4+ already. Other prerequisites — Ruby 3.0+, ripgrep, Git with `core.symlinks=true` — are documented in [`platform/workflow/submodule-integration.md`](platform/workflow/submodule-integration.md#prerequisites).

```bash
cd your-repo
git submodule add https://github.com/unclenate/auto-harness .harness
bash .harness/platform/bootstrap/install.sh
```

The bootstrap is brownfield-safe — it never overwrites pre-existing files from other AI platforms (Cursor, Windsurf, Copilot, Codex, OpenClaw, Hermes) and merges the cross-client `AGENTS.md` via a stable marker block. Skills are delivered as relative symlinks into `.agents/skills/` and `.claude/skills/`, so `git submodule update --remote .harness` pulls upstream improvements automatically with no re-sync step.

- Adoption guide: [`platform/workflow/submodule-integration.md`](platform/workflow/submodule-integration.md)
- Decision record: [`docs/adr/ADR-0003-submodule-integration.md`](docs/adr/ADR-0003-submodule-integration.md)
- Bootstrap tools reference: [`platform/bootstrap/README.md`](platform/bootstrap/README.md)
- Long-term maintenance: [`platform/workflow/maintenance-operations.md`](platform/workflow/maintenance-operations.md)

---

## Platform Structure

```text
./
├── README.md                        # This file — repo and GitBook front door
├── SUMMARY.md                       # GitBook table of contents
├── HARNESS.md                       # Self-governance entrypoint (this repo)
├── AGENTS.md                        # Cross-agent operating manual (this repo)
├── CONTRIBUTING.md                  # Contribution guide
├── CODE_OF_CONDUCT.md               # Community standards (Contributor Covenant v2.1 by reference)
├── SECURITY.md                      # Vulnerability disclosure policy
├── LICENSE-MIT, LICENSE-APACHE      # Dual-license at consumer option
├── NOTICE, AUTHORS                  # Attribution and maintainer list
├── .gitbook.yaml                    # GitBook configuration
├── harness.manifest.yaml            # Meta-manifest (governs the harness itself)
├── platform/                        # Source of truth for the harness framework
│   ├── core/                        # Kernel doctrine, trust model, schemas, registry
│   │   └── kernel/base/             # trust-model.md, doctrine.md, lifecycle-controls.md
│   ├── profiles/                    # All module definitions
│   │   ├── stacks/                  # node-typescript, python
│   │   ├── architectures/           # web-app, api-service, event-driven
│   │   ├── data/                    # relational-postgres, document-store, object-storage
│   │   ├── delivery/                # prototype, production-saas, internal-platform
│   │   ├── management/              # discovery-intake, product-lite, project-standard, program-lite, testing-standard, knowledge-capture, opportunity-capture
│   │   └── domains/                 # supabase, web3, media-pipeline, gitbook
│   ├── agents/                      # Agent operating packs: base, claude-code, generic-llm, openclaw
│   ├── skills/                      # Agent Skills: harness-governance, harness-testing, harness-web3, harness-onboarding, harness-tools, harness-agentic-interfaces, harness-mcp
│   ├── templates/                   # Artifact skeletons for every required file
│   ├── validators/                  # validate-*.sh scripts, Ruby library, test suite
│   ├── compositions/                # Starter manifests for common project types
│   ├── examples/                    # Sample project with all artifacts filled in
│   ├── reference/                   # Glossary, how-to-read guide, topic index
│   ├── workflow/                    # Adoption, day-to-day, and maintenance guides
│   └── README.md                    # Platform overview
└── legacy/                          # Archived historical files
```

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

## Contributing

auto-harness welcomes contributions. The full guide lives in [CONTRIBUTING.md](CONTRIBUTING.md) — it covers issue filing, the pull-request workflow, the validator chain you must run before submitting, companion-rule discipline, and the project's dual-license inbound-equals-outbound convention.

Quick links:

- **File an issue:** [bug report](.github/ISSUE_TEMPLATE/bug_report.yml) &middot; [feature request](.github/ISSUE_TEMPLATE/feature_request.yml) &middot; [structured observation](.github/ISSUE_TEMPLATE/observation.yml)
- **Code of Conduct:** [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) (Contributor Covenant v2.1 by reference)
- **Security issues:** see [SECURITY.md](SECURITY.md) — do not file public issues for vulnerabilities

This repository has two README files with distinct roles:

- **Root `README.md`** (this file) — the repository and GitBook front door. Comprehensive
  overview for someone discovering the project for the first time.
- **`platform/README.md`** — the platform overview. Focused on the `platform/` directory
  structure, operating model, and quick links to key reference pages.

If you update the opening blurb or feature list in one, check whether the other needs a
corresponding update. They should complement each other, not duplicate.

For shared terminology, see the [Glossary](platform/reference/glossary.md).

---

## License

auto-harness is dual-licensed at your option under:

- The **[MIT License](https://github.com/unclenate/auto-harness/blob/main/LICENSE-MIT)**, or
- The **[Apache License, Version 2.0](https://github.com/unclenate/auto-harness/blob/main/LICENSE-APACHE)**

Either license is sufficient — consumers select the one that fits their own project's distribution constraints. See [NOTICE](https://github.com/unclenate/auto-harness/blob/main/NOTICE) for attribution requirements and [ADR-0005](docs/adr/ADR-0005-open-source-cut.md) for the rationale behind the dual-license choice.

Contributions are accepted under both licenses on the same terms. See [CONTRIBUTING.md](CONTRIBUTING.md#licensing--contributor-agreement) for details.

---

## Reference

| Resource | Path |
| -------- | ---- |
| Table of contents | [`SUMMARY.md`](SUMMARY.md) |
| Architecture diagrams | [`docs/architecture/diagrams.md`](docs/architecture/diagrams.md) — composition, trust tier flow, companion rule firing, OPP/PRD/ADR lifecycle, distillation, consumer adoption |
| Glossary | [`platform/reference/glossary.md`](platform/reference/glossary.md) |
| How to read the docs | [`platform/reference/how-to-read.md`](platform/reference/how-to-read.md) |
| Adoption — Bootstrap quickstart | [`platform/workflow/bootstrap-quickstart.md`](platform/workflow/bootstrap-quickstart.md) |
| Adoption — Discovery workflow | [`platform/workflow/discovery-to-composition.md`](platform/workflow/discovery-to-composition.md) |
| Adoption — Brownfield onboarding | [`platform/workflow/brownfield-onboarding.md`](platform/workflow/brownfield-onboarding.md) |
| Adoption — Submodule integration | [`platform/workflow/submodule-integration.md`](platform/workflow/submodule-integration.md) |
| Day-to-day — Skills and agents | [`platform/workflow/skills-and-agents.md`](platform/workflow/skills-and-agents.md) |
| Day-to-day — CI integration | [`platform/workflow/ci-integration.md`](platform/workflow/ci-integration.md) |
| Maintenance & Operations | [`platform/workflow/maintenance-operations.md`](platform/workflow/maintenance-operations.md) |
| Validator error solver | [`platform/workflow/troubleshooting.md`](platform/workflow/troubleshooting.md) |
| All templates | [`platform/templates/`](platform/templates/README.md) |
| All compositions | [`platform/compositions/`](platform/compositions/README.md) |
| Sample project | [`platform/examples/sample-projects/node-web-saas-postgres/`](platform/examples/sample-projects/node-web-saas-postgres/HARNESS.md) |
| Self-governance entrypoint | [`HARNESS.md`](HARNESS.md) |
| Cross-agent operating manual | [`AGENTS.md`](AGENTS.md) |
| Open-source cut decision | [`docs/adr/ADR-0005-open-source-cut.md`](docs/adr/ADR-0005-open-source-cut.md) |
| Legacy / archived files | `legacy/` (no canonical landing file; browse on GitHub) |
