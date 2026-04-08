# AGENTS.md

## Cross-Agent Operating Manual — Development Harness Framework

This document governs all AI agent tooling used on this repository.

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
skill recommendations. The harness provides 4 native skills:

- `harness-governance` — trust tiers, companion rules, lifecycle controls
- `harness-testing` — test strategy, coverage, framework guidance
- `harness-web3` — chain config, contract governance (web3 projects only)
- `harness-onboarding` — brownfield and greenfield onboarding workflows
