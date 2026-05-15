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
| `AGENTS.md` | This file — agent operating contract |
| `docs/operating-principles.md` | Team operating principles |
| `docs/product/requirements.md` | Product requirements |
| `docs/adr/` | Architectural decision records |
| `docs/requirements/` | Product decision records (PRDs) |

---

## Skills

Check `recommendedSkills` in each active module's `module.yaml` for tool-specific
skill recommendations. The harness provides 5 native skills:

- `harness-governance` — trust tiers, companion rules, lifecycle controls
- `harness-testing` — test strategy, coverage, framework guidance
- `harness-web3` — chain config, contract governance (web3 projects only)
- `harness-onboarding` — brownfield and greenfield onboarding workflows
- `harness-tools` — MCP developer tool governance: tier map, Linear artifact workflow, Slack notifications (agents/openclaw active)
