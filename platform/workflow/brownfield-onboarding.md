<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Brownfield Onboarding
## Bringing an Existing Codebase into the Development Harness

This guide covers the path for projects that already exist — codebases built before the harness
was in place, forks, acquired repos, or projects being migrated from another governance approach.
The goal is to reach a valid harness manifest quickly, then backfill documentation progressively
without disrupting active development.

---

## When to Use This Guide

| Your situation | Guide to use |
| -------------- | ------------ |
| Starting a new project, stack already known | [`bootstrap-quickstart.md`](bootstrap-quickstart.md) |
| Starting from an idea, mockup, or spec with no stack chosen | [`discovery-to-composition.md`](discovery-to-composition.md) |
| Existing codebase not built with the harness | **This guide** |

Brownfield onboarding is also the right path if you are evaluating a fork or external repository
against the harness before deciding whether to bring it under governance.

---

## Workflow at a Glance

```
Existing repo
    │
    ▼
Step 1   — Get oriented (read this guide)
    │
    ▼
Step 1.5 — Add auto-harness as submodule; run install.sh (recommended)
    │       See: submodule-integration.md
    │       This replaces the manual copy-in steps below for submodule consumers.
    ▼
Step 2   — Run the harness-onboarding skill with any AI coding assistant
    │
    ▼
Step 3   — Review the 5-section assessment output
    │
    ▼
Step 4   — Update harness.manifest.yaml per the assessment; re-run validators
    │
    ▼
Step 5   — Refine kernel artifacts (HARNESS.md, AGENTS.md, docs/operating-principles.md)
    │
    ▼
Step 6   — Progressive compliance: backfill docs, re-enable validators module by module
    │
    ▼
Step 7   — Wire CI when all validators pass locally
```

**Submodule consumers:** Step 1.5 produces `harness.manifest.yaml`, `HARNESS.md`, `CLAUDE.md`, `AGENTS.md` (with a cross-client marker block), and symlinks from `.agents/skills/` and `.claude/skills/` into the submodule — all brownfield-safe (never clobbers foreign or platform-artifact files). Steps 2–7 then refine what `install.sh` produced. If you skip Step 1.5 and copy files in manually, follow [bootstrap-quickstart.md](bootstrap-quickstart.md) for the manual pattern; Steps 2–7 still apply.

---

## Step 1 — Get Oriented

The harness governs a project through `harness.manifest.yaml` — a ~20-line YAML file at the
repository root. It declares which **modules** are active. Each module is a governance overlay for
a specific concern: your stack (Node/TypeScript, Python), your architecture (web app, API service),
your delivery posture (prototype, production SaaS), and so on.

When a module is active, it brings two things:

1. **Required artifacts** — documentation files the team must produce (e.g., an architecture
   overview, a risk register, a test strategy). These are living project documents, not one-time
   checkboxes.
2. **Governance rules** — companion rules that fire in CI when sensitive files change (e.g., if
   you change database migrations, the migration readiness doc must be updated in the same PR).

Shell validators enforce both, locally and in CI. The brownfield onboarding approach deliberately
starts with enforcement disabled (`required-artifacts` validation is turned off in the lite
manifest) so the team can initialize the manifest and create artifacts gradually — without
breaking existing CI or blocking active development.

You do not need to read the entire platform to start. The `harness-onboarding` skill (Step 2) will
analyze the codebase and tell you which modules apply. Your only job in this step is to have the
harness platform accessible:

```bash
# If the harness is a sibling directory or subtree in your repo:
ls platform/

# If it is a separate repo, clone it alongside the target project:
# git clone <harness-repo> development-harness
```

---

## Step 2 — Run the Harness-Onboarding Skill

The `harness-onboarding` skill is a structured AI agent prompt that analyzes the repository and
produces the five-section assessment. It works with any AI coding assistant.

### With Claude Code

```bash
# Install the skill
cp -r platform/skills/harness-onboarding .claude/skills/

# Open the target repo in Claude Code, then invoke the skill
# The skill will appear as a slash command or activate automatically when you describe the task
```

### With other Agent Skills-compatible clients (VS Code Copilot, Cursor, WindSurf, etc.)

```bash
# Install the skill for all Agent Skills-compatible clients
cp -r platform/skills/harness-onboarding .agents/skills/
```

Then reference the skill from your client's skill panel, or by name when starting a new session.

### With any AI assistant (manual method)

Open `platform/skills/harness-onboarding/SKILL.md`. Copy everything after the closing `---` of the
frontmatter block. Paste it into your AI assistant as the system prompt or opening context, then
ask the assistant to begin the brownfield assessment.

This method works with any AI tool — ChatGPT, Gemini, Claude claude.ai, or any other assistant that
accepts a long system prompt or context block.

---

## Step 3 — Review the Assessment Output

The skill produces a five-section report. Each section has a specific use:

**Section 1 — Repository Inventory**
Facts only — what the AI observed in the codebase. Review this first. Correct any errors (wrong
stack, missed framework signals, docs the AI missed) before treating Section 2 as final.

**Section 2 — Proposed Harness Composition**
The recommended module set. This is a starting point, not a final answer. Supplement it with your
team's knowledge — the AI can only observe what's in the files; it cannot know your roadmap,
infrastructure contracts, or team structure.

**Section 3 — Gap Analysis**
The work queue. Every MISSING or PARTIAL artifact becomes a task. EQUIVALENT artifacts (docs at
non-standard paths) should be reviewed: if the existing file genuinely covers the artifact's
purpose, it may be acceptable as-is or with a minor rename.

**Section 4 — Validator Runbook**
The exact commands to run. At the lite stage, only the first two validators should be run.

**Section 5 — Risks and Open Questions**
Assign an owner to each open question before the manifest is finalized. Unresolved governance
risks (e.g., the repo has real users but the AI proposed `delivery/prototype`) should be resolved
by a human before the manifest is committed.

The copy-paste block at the end of the report gives you:

- **Artifact A** — a ready-to-use `harness.manifest.yaml` (lite, with `required-artifacts` disabled)
- **Artifact B** — a three-action checklist prioritized for your specific gap profile

---

## Step 4 — Initialize the Lite Manifest

Save the AI-generated manifest as `harness.manifest.yaml` at the project root. If you need a
manifest immediately before running the assessment, copy the starter composition instead:

```bash
cp platform/compositions/brownfield-lite.yaml harness.manifest.yaml
# Then fill in project.id, project.name, maturity, criticality, and module sections
```

Run the first two validators to confirm the manifest is structurally valid:

```bash
bash platform/validators/validate-manifest.sh harness.manifest.yaml
bash platform/validators/validate-module-graph.sh harness.manifest.yaml
```

Both should exit 0 immediately. If `validate-manifest.sh` fails, the error output will tell you
exactly which field is wrong — see `platform/workflow/troubleshooting.md`.

Do not run `validate-required-artifacts.sh` yet — it is disabled in the lite manifest for a reason.

---

## Step 5 — Create Kernel Artifacts First

`core/kernel/base` is the mandatory foundation of every harness project. It requires three files:

| Artifact | Purpose | Effort |
| -------- | ------- | ------ |
| `HARNESS.md` | Governance entrypoint — lifecycle stage, trust tiers, applicable rules | Low |
| `AGENTS.md` | Agent contract — how AI assistants interact with this project | Low |
| `docs/operating-principles.md` | How this project makes decisions; escalation path | Medium |

These three files establish the governance identity of the project and unlock the `harness-governance`
skill for the rest of the work. Create them in the first session.

**HARNESS.md** — Declare the current lifecycle stage, the trust tier the team grants to AI agents,
and which harness modules are active. This is the governance entrypoint: the file any agent or
reviewer reads first to understand the rules of the road for this project. Keep it short (one page
or less); it is a pointer and a declaration, not a full policy document.

**AGENTS.md** — Define the agent operating contract: what agents are permitted to do autonomously
(Tier 3 — write code, open PRs), what requires human approval (Tier 4 — CI changes), and what is
never delegated (Tier 5 — production deploys, secrets, irreversible operations). Also note which
AI tools are in use and any project-specific agent constraints.

**docs/operating-principles.md** — Document how the team makes decisions: how scope changes are
handled, how architectural decisions are recorded (ADRs), who has approval authority, and what the
escalation path is for disagreements. This file is longer but can start as a lightweight stub and
be expanded over time.

Reference the filled-in examples for format and content guidance:

```bash
cat platform/examples/sample-projects/node-web-saas-postgres/HARNESS.md
cat platform/examples/sample-projects/node-web-saas-postgres/AGENTS.md
cat platform/examples/sample-projects/node-web-saas-postgres/docs/operating-principles.md
```

---

## Step 6 — Progressive Compliance Roadmap

Brownfield adoption is a *phased* compliance ramp, not a single bootstrap event. The high-level phases are:

| Phase | Focus | Validator state |
| ----- | ----- | --------------- |
| **Phase 1** (start) | Create kernel artifacts: HARNESS.md, AGENTS.md, docs/operating-principles.md | `required-artifacts` disabled |
| **Phase 2** (week 1–2) | Architecture overview, product problem statement and requirements | Re-enable selectively as modules are ready |
| **Phase 3** (week 2–4) | Ops docs (if `delivery/production-saas` active): environment inventory, release checklist, risk register | All validators enabled locally |
| **Phase 4** (ongoing) | CI wired; `harness-governance` skill installed; all validators green in CI | **Harness Ready** |

The detailed re-enablement walkthrough — how to selectively turn validators back on as each module's artifacts come online, and the long-term discipline of treating `disabledValidations` as visible technical debt — lives in **[Maintenance & Operations](maintenance-operations.md#re-enabling-validators-disabled-during-adoption)**. Follow this guide for adoption-phase orientation; follow the maintenance guide for the per-validator re-enablement procedure.

### Using templates for missing artifacts

Every required artifact has a template in `platform/templates/`. For example:

```bash
# Create the architecture overview from the template
mkdir -p docs/architecture
cp platform/templates/architecture-overview.md docs/architecture/overview.md

# Create the problem statement
mkdir -p docs/product
cp platform/templates/product/problem-statement.md docs/product/problem-statement.md
```

Fill in `[[PLACEHOLDER_NAME]]` tokens before committing. The `validate-placeholders.sh` validator
will catch any that remain.

---

## Step 7 — Wire CI

Once all validators pass locally with no `disabledValidations`, add them to CI. Follow
`platform/workflow/ci-integration.md` for the complete workflow.

For brownfield projects, start CI with only the two validators that pass immediately:

```yaml
- run: bash $PLATFORM/validators/validate-manifest.sh harness.manifest.yaml
- run: bash $PLATFORM/validators/validate-module-graph.sh harness.manifest.yaml
```

Add `validate-required-artifacts.sh` to CI only after it passes locally (i.e., after Phase 3).
This prevents the harness validators from blocking existing CI before the team is ready.

---

## Reference

| Resource | Path |
| -------- | ---- |
| Harness-onboarding skill (the AI assessment prompt) | `platform/skills/harness-onboarding/` |
| Brownfield lite starter composition | `platform/compositions/brownfield-lite.yaml` |
| Bootstrap quickstart (greenfield, stack known) | `platform/workflow/bootstrap-quickstart.md` |
| Discovery to composition (greenfield, no stack) | `platform/workflow/discovery-to-composition.md` |
| CI integration guide | `platform/workflow/ci-integration.md` |
| Troubleshooting validator errors | `platform/workflow/troubleshooting.md` |
| All artifact templates | `platform/templates/` |
| Sample fully-onboarded project | `platform/examples/sample-projects/node-web-saas-postgres/` |
| harness-governance skill (ongoing governance) | `platform/skills/harness-governance/` |
