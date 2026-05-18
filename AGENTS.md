<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# AGENTS.md

## Cross-Agent Operating Manual — Development Harness Framework

This document governs all AI agent tooling used on this repository.
It is also the workspace-instructions entrypoint for this repo; keep it as the single
shared guidance file instead of creating a duplicate `.github/copilot-instructions.md`.

---

## First-Session Workflow

Run these steps once at the start of any session before touching code or governance files. They take less than a minute and prevent the most common operator errors.

1. **Orient.** Read [`HARNESS.md`](HARNESS.md) for the active module set. Read this file (`AGENTS.md`) for the trust tier model, scope, and stop conditions. If you are Claude Code, also read [`CLAUDE.md`](CLAUDE.md) for the load order.
2. **Confirm the manifest.** Open `harness.manifest.yaml`. The modules listed there are the *only* governance overlays in force; do not assume any other module's rules apply unless you see it here.
3. **Verify validators are green on `main` before you start.** Run the chain in the **Build and Test** section below. If any validator fails before you've made changes, surface that to the human first instead of fixing it implicitly.
4. **Identify which skill matches your task.** See the **Skills** section. Load only the skills whose triggering conditions match the work you're about to do — do not pre-load everything.
5. **Decide your operating tier.** The default is Tier 2 (workspace mutation). If your task requires Tier 3 or above (commits, env changes, deploys), say so to the human and wait for explicit direction.
6. **Watch for companion rules.** Any change to `platform/profiles/**/module.yaml`, validators, governance entrypoints (HARNESS.md / AGENTS.md / CLAUDE.md), or active-module catalog requires a paired update — usually a `docs/project/change-log.md` entry or an ADR in the **same commit**. Plan the paired edit before you start the primary edit.

---

## Repository Shape

This repository is a modular governance framework, not a deployable application service.
Most work happens in:

- `platform/core/kernel/base/` — kernel doctrine, trust model, and operating principles
- `platform/profiles/**/module.yaml` and `platform/agents/**/module.yaml` — module contracts
- `platform/validators/` — shell validators plus the shared Ruby registry and tests
- `platform/templates/` and `platform/workflow/` — artifact templates and operating guides
- `docs/` — the platform's own requirements, ADRs, PRDs, and project records

Treat `legacy/` and `platform/validators/test/fixtures/` as historical or test data,
not as the source of truth.

---

## Build and Test

Run checks from the repository root. There is no app build or runtime server in this repo;
verification means running the validator chain and Ruby tests:

```bash
bash platform/validators/validate-manifest.sh harness.manifest.yaml
bash platform/validators/validate-module-graph.sh harness.manifest.yaml
bash platform/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash platform/validators/validate-placeholders.sh .
bash platform/validators/validate-agent-pack.sh harness.manifest.yaml .
bash platform/validators/validate-companions.sh harness.manifest.yaml . main
ruby -I platform/validators/lib platform/validators/test/test_harness_registry.rb
ruby -I platform/validators/lib platform/validators/test/test_validators_integration.rb
```

For validator behavior, troubleshooting, and CI wiring, link to:
`platform/validators/README.md`, `platform/workflow/troubleshooting.md`, and
`platform/workflow/ci-integration.md`.

---

## Working Conventions

- Follow **link, don't embed**: reference existing docs instead of duplicating long guidance
- When changing modules, validators, templates, or workflows, update the nearby README,
  `SUMMARY.md`, and any ADR/PRD/change-log artifact needed to keep governance current
- Preserve trust-tier boundaries and companion rules; do not weaken them without explicit
  human direction
- Use `platform/examples/` for good examples; validator fixtures intentionally include broken cases

---

## Trust Tier Model

All agents operate within the kernel's six-tier action model:

| Tier | Actions | Authorization |
|------|---------|--------------|
| 0 | Read-only inspection | Always permitted |
| 1 | Local analysis (tests, builds, linters) | Always permitted |
| 2 | Workspace mutation (file edits) | Default agent scope |
| 3 | Git-writing (commits, branches) | Requires explicit instruction |
| 4 | Environment-altering (installs, migrations) | Requires human authorization |
| 5 | Remote/production (deploys, secrets) | Requires human authorization + named owner |

Default operating tier: **Tier 2** (workspace mutation).

---

## Scope

**In scope for agents:**

- Reading, analyzing, and editing platform files (modules, validators, templates, docs)
- Running validators and test suite
- Creating and editing governance artifacts (ADRs, PRDs, READMEs)
- Proposing module changes (companion rules, required artifacts, sensitive paths)

**Out of scope for agents without explicit human direction:**

- Pushing to remote (Tier 3+)
- Modifying CI/CD configuration
- Changing `harness.manifest.yaml` active modules
- Removing or weakening existing governance rules

---

## Stop Conditions

Agents must halt and surface to a human when:

- A proposed change would weaken governance controls
- A validator starts failing and the fix is not obvious
- A companion rule would need to be removed or bypassed
- The change affects trust tier boundaries or review gates

---

## Canonical Artifacts

| Artifact | Authority |
|----------|-----------|
| `harness.manifest.yaml` | Active module composition |
| `HARNESS.md` | Project-level governance entrypoint |
| `AGENTS.md` | This file — cross-agent operating contract |
| `CLAUDE.md` | Claude Code load-order shim — points at the canonical files above |
| `TOOLS.md` | Environment-specific tool registry (loaded on demand for MCP developer tools) |
| `docs/operating-principles.md` | Team operating principles |
| `docs/product/requirements.md` | Product requirements |
| `docs/adr/` | Architectural decision records |
| `docs/requirements/` | Product decision records (PRDs) |

---

## Skills

Check `recommendedSkills` in each active module's `module.yaml` for tool-specific
skill recommendations. Load skills on demand; do not pre-load. The harness provides
seven native skills:

- `harness-governance` — trust tiers, companion rules, lifecycle controls (all projects)
- `harness-onboarding` — brownfield and greenfield onboarding workflows (during onboarding)
- `harness-testing` — test strategy, coverage, framework guidance (`testing-standard` active)
- `harness-web3` — chain config, contract governance (Web3 projects only)
- `harness-tools` — MCP developer tool governance: tier map, Linear artifact workflow, Slack notifications (`agents/openclaw` active)
- `harness-agentic-interfaces` — in-product copilot / generative-UI / conversational-primary surfaces (`domains/agentic-interfaces` active)
- `harness-mcp` — producer-side MCP work (`architectures/mcp-server` active)
