<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Web3 Bootstrap Quickstart

## Standing Up a Web3 Project with the Harness

This guide is the fast path for projects with the `domains/web3` module active. It follows
the same seven-step structure as the general bootstrap quickstart, with Web3-specific
extensions at each step.

If you haven't read the [general quickstart](bootstrap-quickstart.md) yet, start there.
This guide assumes you're familiar with the base workflow and focuses on what's different.

---

## What the Web3 Module Adds

Activating `domains/web3` turns on governance controls that don't exist in other modules:

| Control | What It Does |
| ------- | ------------ |
| UNKNOWN propagation | Any unverifiable signal must return `UNKNOWN`, not zero or a default |
| Evidence requirement | Every risk flag must cite the on-chain data that produced it |
| Rate limit budget | All external API calls must be accounted for in `chain-config.md` |
| Irreversibility gate | Transaction-signing operations require Tier 5 human review |
| Scoring rule ADR | Changes to scoring logic require a companion ADR |

These are review gates enforced by `validate-companions.sh` and documented in the
`harness-web3` skill. Install the skill before your first session.

---

## Step 1 — Choose Your Composition

Use `web3-risk-analytics.yaml` as the starting composition for most Web3 projects:

```bash
cp platform/compositions/web3-risk-analytics.yaml your-project/harness.manifest.yaml
```

This composition activates: `kernel/base`, `python`, `api-service`, `relational-sql`,
`production-saas`, `discovery-intake`, `product-lite`, `project-standard`, `web3`, `base`.

Update the project block:

```yaml
project:
  id: your-project-id
  name: Your Project Name
  maturity: prototype   # prototype | mvp | production
  criticality: medium   # low | medium | high | critical
```

**Adjust for your stack:**

- Node/TypeScript backend: replace `python` with `node-typescript`
- Event-driven pipeline: add `architectures/event-driven`
- Contract deployment in scope: add `docs/web3/contract-registry.md` to `overrides.requiredArtifacts`
- Token layer: add `docs/web3/token-strategy.md` to `overrides.requiredArtifacts`
- Multi-workstream team: add `management/program-lite`

---

## Step 2 — Run the Manifest and Module Graph Validators

```bash
PLATFORM=path/to/platform

bash $PLATFORM/validators/validate-manifest.sh harness.manifest.yaml
bash $PLATFORM/validators/validate-module-graph.sh harness.manifest.yaml
```

Both should exit 0. Web3-specific failure modes:

- `domains/web3 depends on kernel/base` — ensure `core: [kernel/base]` is in the manifest
- `required artifact missing: docs/web3/chain-config.md` — create this first (see Step 3)

---

## Step 3 — Create the Chain Configuration Artifact

`docs/web3/chain-config.md` is a required artifact for the `domains/web3` module. It is
the canonical source for which chains are in scope, which APIs are used, and what the
rate limit budget is.

```bash
mkdir -p docs/web3
cp platform/templates/web3/chain-config.md docs/web3/chain-config.md
```

Fill in:

- Which chains are in scope (mainnet, testnet, L2s)
- Which explorer APIs are used and their rate limits
- The rate limit budget calculation (total calls per minute across all paths)
- Multi-chain routing strategy if applicable

Every time you add a new external API call to the codebase, update the budget here.
The rate limit gate will fail review if the budget isn't updated.

---

## Step 4 — Create All Required Artifacts

Run `validate-required-artifacts.sh` to see the full list:

```bash
bash $PLATFORM/validators/validate-required-artifacts.sh harness.manifest.yaml .
```

Web3 projects have additional required artifacts beyond the base set:

| Artifact | Template | Notes |
| -------- | -------- | ----- |
| `docs/web3/chain-config.md` | `templates/web3/chain-config.md` | Required; fill rate limit budget |
| `docs/security/risk-register.md` | `templates/risk-register.md` + `templates/web3/risk-register-web3.md` | Use both |
| `docs/architecture/overview.md` | `templates/architecture-overview.md` | Include chain data flow |
| `docs/adr/ADR-0001-chain-selection.md` | `templates/web3/adr-web3.md` | Document chain choice |
| `docs/adr/ADR-0002-data-model.md` | `templates/adr.md` | Document storage decisions |

**Optional but recommended for contract-deploying projects:**

- `docs/web3/contract-registry.md` — tracks deployed contract addresses and versions
- `docs/web3/token-strategy.md` — documents token design if applicable

---

## Step 5 — Seed the Web3 Intake Supplement

If you haven't done discovery yet, use the Web3 intake supplement alongside the standard
intake questionnaire:

```bash
cp platform/templates/web3/web3-intake-supplement.md docs/discovery/web3-intake-supplement.md
```

This supplement captures Web3-specific requirements: which chains, read vs. write scope,
wallet integration, contract deployment intent, and regulatory context.

---

## Step 6 — Validate Agent Pack and Install Skills

```bash
bash $PLATFORM/validators/validate-agent-pack.sh harness.manifest.yaml .
```

Then install both harness-native skills — Web3 projects require both:

```bash
# Cross-client (Claude Code, VS Code Copilot, Cursor, etc.)
cp -r platform/skills/harness-governance .agents/skills/
cp -r platform/skills/harness-web3 .agents/skills/
cp -r platform/skills/harness-testing .agents/skills/      # testing-standard is active in this composition

# Claude Code native path
cp -r platform/skills/harness-governance .claude/skills/
cp -r platform/skills/harness-web3 .claude/skills/
cp -r platform/skills/harness-testing .claude/skills/      # testing-standard is active in this composition
```

**The `harness-web3` skill is the governance reference for this project.** It contains:

- UNKNOWN propagation rules
- Rate limit budget enforcement
- Evidence requirement definitions
- Tier 5 gate conditions for irreversible operations
- Companion rule table for Web3 paths

### OpenClaw / ClawHub (if using OpenClaw)

Security-critical: always install `azhua-skill-vetter` before any Web3 registry skill.

```bash
clawhub install azhua-skill-vetter   # install this first, always
# Run azhua-skill-vetter against each target skill before installing
clawhub install mist-track           # AML compliance, address risk (full registry)
clawhub install dune-mcp             # on-chain data queries (full registry)
```

**Web3 skills are not in the curated list.** They come from the full ClawHub registry
and are experimental. Never connect to a live wallet or production API key without
testing in an isolated environment. See `skills-and-agents.md` → Web3 Skills Security.

---

## Step 7 — Wire Up CI with Web3-Specific Checks

Add the standard harness validators to CI. For Web3 projects, companion rule enforcement
is especially important — run it in CI to catch unaccompanied scoring rule or chain
configuration changes:

```yaml
- run: bash $PLATFORM/validators/validate-manifest.sh harness.manifest.yaml
- run: bash $PLATFORM/validators/validate-module-graph.sh harness.manifest.yaml
- run: bash $PLATFORM/validators/validate-required-artifacts.sh harness.manifest.yaml .
- run: bash $PLATFORM/validators/validate-companions.sh harness.manifest.yaml . $BASE_BRANCH
```

Set `BASE_BRANCH` to your main branch (typically `main`). The companion validator checks
that scoring rule changes have ADRs and contract surface changes have risk register or
architecture updates in the same PR.

---

## Web3 Harness Bootstrap Complete

The Web3 harness is **Bootstrap Complete** when:

1. `validate-manifest.sh` exits 0
2. `validate-module-graph.sh` exits 0
3. `validate-required-artifacts.sh` exits 0
4. `validate-placeholders.sh` exits 0
5. `docs/web3/chain-config.md` is filled with accurate rate limit budget
6. ADR-0001 (chain selection) exists and is complete
7. `harness-web3` skill is installed in `.agents/skills/` or `.claude/skills/`
8. CI workflow is wired and green on first PR

---

## Key Governance Reminders

**UNKNOWN propagation** — if a signal cannot be computed, return `UNKNOWN`. Never
substitute zero, null, `false`, or a synthetic default. Suppressing `UNKNOWN` is a
correctness bug, not a safe fallback.

**Evidence requirement** — every risk flag or scored signal in system output must
reference the on-chain data that produced it. "Score: 72" with no citation is not
acceptable output.

**Rate limit budget** — every new API call path must be counted against the budget
in `chain-config.md`. Adding RPC or explorer calls without updating the budget is
an architecture gap that will fail companion review.

**Irreversibility** — transaction-signing operations require Tier 5 review. This is
not a speed bump — it is a correctness gate. A bad write to a blockchain cannot be
undone.

---

## Common Web3 First-Run Issues

| Error | Likely Cause |
| ----- | ------------ |
| `Missing required artifact: docs/web3/chain-config.md` | Create from template (Step 3) |
| `Contract surface change requires risk register or ADR update` | Add `docs/security/risk-register.md` or ADR to the same PR |
| `Scoring rule change requires companion ADR` | Add `docs/adr/ADR-XXXX-*.md` to the same PR |
| `UNKNOWN propagation violation detected` | A signal path is returning a default value instead of `UNKNOWN` |

---

## Reference

| Resource | Path |
| -------- | ---- |
| General bootstrap quickstart | `platform/workflow/bootstrap-quickstart.md` |
| Discovery workflow | `platform/workflow/discovery-to-composition.md` |
| Web3 risk register template | `platform/templates/web3/risk-register-web3.md` |
| Web3 intake supplement | `platform/templates/web3/web3-intake-supplement.md` |
| Web3 composition | `platform/compositions/web3-risk-analytics.yaml` |
| harness-web3 skill | `platform/skills/harness-web3/SKILL.md` |
| Chain config template | `platform/templates/web3/chain-config.md` |
| Trust model | `platform/core/kernel/base/trust-model.md` |
| Skills and agents guide | `platform/workflow/skills-and-agents.md` |
