<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Extending the Harness

## Authoring Custom Modules, Validators, Skills, and Templates

This guide is for **contributors and consumer-organizations who need
to extend auto-harness** — adding a new module (e.g., a domain or
stack overlay), a new validator, a new skill, or a new template family.

Consumer projects that just want to *use* the harness should start at
[`bootstrap-quickstart.md`](bootstrap-quickstart.md) or
[`submodule-integration.md`](submodule-integration.md). This document
is for the contributor side.

> **Visual:** the [Component Composition diagram](../../docs/architecture/diagrams.md#1-component-composition)
> shows how modules, validators, skills, and templates compose. This
> workflow explains how to *add* to each layer.

---

## Decision: What Are You Extending?

| If you want to… | Add a… | Read |
|------------------|--------|------|
| Govern a new stack, architecture, data layer, delivery posture, management overlay, or domain | **Module** | [Module Authoring](#module-authoring) below |
| Add a new automated check at PR / CI time | **Validator** | [Validator Authoring](#validator-authoring) below |
| Add cross-client agent guidance (Claude Code, Cursor, Copilot, etc.) | **Skill** | [Skill Authoring](#skill-authoring) below |
| Add a new artifact scaffold (consumer-fill template) | **Template** | [Template Authoring](#template-authoring) below |
| Add an integration adapter for a specific AI agent (Cursor pack, Copilot pack, etc.) | **Agent pack** | [Agent Pack Authoring](#agent-pack-authoring) below |

Most contributions only need one of these. If you find yourself adding
two or three at once, you're probably designing a coherent feature —
file an OPP first ([`docs/opportunities/`](../../docs/opportunities/README.md))
to align on direction, then a PRD ([`docs/requirements/`](../../docs/requirements/PRD-0001-restore-prd-support.md))
to specify the contract.

---

## Module Authoring

A module is the harness's unit of governance composition. Each module
is a directory containing a `module.yaml` (the contract) plus a
`README.md` (when-to-use + tradeoffs) plus any optional artifacts
(templates, sub-docs).

### Where modules live

```text
platform/
├── core/                       # kernel — universal foundation
│   └── kernel/base/
├── profiles/                   # composable overlays
│   ├── stacks/                 # language / runtime / framework
│   ├── architectures/          # topology / interaction patterns
│   ├── data/                   # storage / state management
│   ├── delivery/               # lifecycle / operational posture
│   ├── management/             # product / project / program
│   └── domains/                # vendor / ecosystem / specialist
└── agents/                     # AI-tool operating packs
```

Pick the family that matches the change-class your module governs.
When in doubt, read the existing modules in each family —
[`platform/profiles/management/knowledge-capture/`](../profiles/management/knowledge-capture/README.md)
is a particularly well-developed example.

### module.yaml fields

```yaml
id: family/module-slug          # required — must match directory path
type: management                # required — one of: core, management, stack, architecture, data, delivery, domain, agent
version: 1.0.0                  # required — semver; bump for breaking changes
stability: beta                 # required — readiness tier: experimental | beta | stable (see rubric below)
summary: "One-line purpose."    # required — surfaces in catalogs

dependsOn: []                   # other modules required for this one to work
conflictsWith: []               # modules that cannot coexist

requiredArtifacts:              # files the consumer project must have
  - docs/path/to/artifact.md

optionalArtifacts: []           # files the consumer may have

sensitivePaths:                 # extra-review-weight patterns
  - description: "..."
    patterns:
      - "^path/regex$"

companionRules:                 # trigger → required satisfier
  - description: "..."
    triggerPaths:
      - "^changed-file-regex$"
    requiredAny:
      - "^satisfier-file-regex$"
    forbiddenPatterns:          # optional hard-fail list
      - "..."
    humanReview: "Reviewer guidance prose."

validators:                     # which validators care about this module
  - validate-companions
  - validate-required-artifacts

agentAdapters:                  # which agent packs apply
  - platform/agents/base

reviewGates:                    # human-text gates (informational; not validated)
  - "Reviewers should..."

compiledFragments:              # READMEs that get composed into agent context
  - platform/profiles/family/module-slug/README.md
```

The full schema is enforced by `validate-manifest.sh` and
`validate-module-graph.sh`. Run them locally before opening a PR; both
fail loud on contract violations.

### Stability tier (the `stability` field)

Every module declares its **readiness** — a third axis, independent of trust tier
(*risk*) and the § 10 enforcement ladder (*per-claim enforcement*): *how proven is
this module?* `validate-module-stability.sh` (always-on) asserts the field is
present and from the enum; it does **not** judge whether your assignment is correct
— that is an honest authoring act, like § 10 claim classification. Assign against
this rubric:

| Tier | Use when |
| ---- | -------- |
| `stable` | Shipped **and** machine-enforced (a dedicated validator or companion rule) **and** foundational (kernel) **or** with ≥ 1 real consumer / dogfood instance |
| `beta` | Shipped and structurally complete, but enforcement is thin/companion-only **or** it has no real consumer instance yet |
| `experimental` | A scaffold, a speculative single-consumer overlay, or a niche module not battle-tested |

Be honest and lean conservative: an inflated `stable` is worse than an accurate
`beta`. There is no `deprecated` tier in v1 (module lifecycle/deprecation is a
separate, not-yet-designed concern).

### README.md content

Each module's README answers four questions:

1. **What does this module add to a project?** One paragraph; what
   governance / structure does it produce that wouldn't exist otherwise?
2. **When should I activate this module?** Concrete signals — "if your
   project does X" / "if you ship Y" / "if you're regulated by Z."
3. **What does it require?** Required artifacts (link to templates),
   companion rules, conflicts with other modules.
4. **What does it not do?** Out-of-scope claims that prevent misuse.

Aim for 100–200 lines. Use existing well-developed modules as the bar
(`management/knowledge-capture`, `management/opportunity-capture`,
`architectures/mcp-server` are strong examples).

### Required catalog updates when adding a module

A new module triggers updates in:

- `SUMMARY.md` Module Library section (under the right family heading)
- `HARNESS.md` Active Modules table (only if this repo activates the
  module — most new modules don't, since auto-harness self-dogfoods only
  a small set)
- `platform/skills/harness-onboarding/SKILL.md` family catalog (if it's
  a generic-applicability module)
- `platform/workflow/discovery-to-composition.md` decision rubric (if
  the module addresses a discovery question)

`validate-catalog-counts.sh` will catch any missed catalog update
that's already in its assertion table.

---

## Validator Authoring

Validators are bash scripts in `platform/validators/` named
`validate-<thing>.sh`. They enforce a specific aspect of the
governance contract at PR / CI time.

### Required interface

Every validator must:

- Support `-h` / `--help` returning the usage text and exiting 0
- Follow the 3-state exit contract: `0` pass, `1` violation found,
  `2` usage error (missing dep, bad arg, etc.)
- Be self-documenting at the top of the file (purpose, usage, exit
  codes) — see existing validators for the convention
- Be Bash 3.2 compatible (macOS system bash; no `declare -A`, no
  `mapfile`, no `${var,,}`)
- Pass shellcheck at `--severity=warning`

### When to write a new validator vs. extend an existing one

| You want to enforce | Use |
|---------------------|-----|
| A new YAML field or relationship in `harness.manifest.yaml` | Extend `validate-manifest.sh` or `validate-module-graph.sh` |
| A new path-based rule (trigger → satisfier) | Add a companion rule to the relevant module's `module.yaml`; existing `validate-companions.sh` handles it |
| A new file-content check across the project | New validator |
| A new catalog-count assertion site | Extend `validate-catalog-counts.sh` ASSERTIONS table — one line, no new script |

When introducing a new validator, design it so its assertion includes
the new validator itself (per the operating-principle: machinery that
asserts against state-including-itself gets a free first-run self-test).

### Wiring a new validator

A new validator needs to be added in three places:

1. `platform/core/kernel/base/module.yaml` `validators:` list (if it's
   universally applicable) or the specific module's `validators:` list
2. `.github/workflows/harness.yml` — add a new step in the validators
   job
3. `platform/skills/harness-governance/SKILL.md` — the "Running
   Validators" code block + the per-script signature notes

`validate-catalog-counts.sh` will catch any documented validator-count
claim that drifts as a result.

---

## Skill Authoring

Skills live in `platform/skills/<name>/SKILL.md`. They are
cross-client agent guidance discoverable by Claude Code, Cursor,
Copilot, Codex, and any other Agent-Skills-compatible client.

### Skill file structure

```markdown
---
name: skill-name
description: One-sentence description used to decide when to load
license: Apache-2.0
compatibility: Designed for any Agent Skills-compatible client...
metadata:
  harness-module: family/module
  format-version: "1.0"
---

# Skill Display Name

Prose explaining when this skill applies and how to use it.
```

The `description` field is **load-bearing** — clients use it to
decide when to surface the skill to the agent. Make it specific and
trigger-rich (verbs of the user intent, names of the surfaces it
covers).

### When to write a new skill vs. extend an existing one

| You want to provide | Use |
|----------------------|-----|
| Cross-client guidance on a new harness feature | New skill OR extend an existing skill if scope is close |
| Module-specific operational guidance | Module README, not skill |
| Validator error solutions | Extend `harness-governance` SKILL.md's troubleshooting section |
| Tool-specific behavior (Claude Code hooks, Cursor rules) | Agent pack adapter, not skill |

Aim for skills that target *cross-client intents* (e.g., "verify a
project follows governance rules") rather than tool-specific behavior
(which belongs in agent packs).

---

## Template Authoring

Templates live in `platform/templates/`. Each is a Markdown scaffold
with `[[…]]` placeholder tokens that the consumer fills.

### Two classes of token

Per [`platform/templates/README.md`](../templates/README.md):

- **Header tokens** (`[[YEAR]]`, `[[OWNER_NAME]]`, `[[OWNER_EMAIL]]`,
  `[[SPDX_LICENSE]]`, `[[PROJECT_NAME]]`) appear in every template's
  SPDX/copyright header. Filled *once* via
  [`set-consumer-headers.sh`](../bootstrap/set-consumer-headers.sh).
- **Per-record tokens** (`[[OWNER]]`, `[[ADR_TITLE]]`, `[[OPP_TITLE]]`,
  etc.) appear in template bodies. Filled per-artifact when the
  consumer scaffolds.

When adding a new template, follow the existing header convention
(four-line HTML comment block with tokenized header) and use the
two-class taxonomy for body tokens.

### Template `validate-placeholders.sh` interaction

The placeholder validator scans tracked files for unfilled `[[…]]`
tokens. `platform/templates/**` is exempted by `.placeholder-ignore`
so templates can ship with tokens visible. *Consumer-derived* copies
will then fail the validator until filled.

---

## Agent Pack Authoring

Agent packs live in `platform/agents/<tool>/`. They map the harness's
universal governance contract to a specific AI tool's configuration
surface — `.claude/settings.json`, `.cursor/rules`, `.github/copilot-
instructions.md`, etc.

Adding a new agent pack typically means:

1. New directory `platform/agents/<tool>/` with `module.yaml`,
   `README.md`, and any compiled fragments
2. Pack files (settings JSON, rules MD, etc.) under a subdirectory
3. Cross-link from `HARNESS.md` and `AGENTS.md`
4. New `harness-<tool>` skill if the tool has a unique governance
   surface

See `platform/agents/claude-code/` as the most fully-developed example.

---

## Submitting Your Contribution

1. **Open an OPP** for substantive additions (new module families,
   new validators with novel semantics, new agent packs). Skip the OPP
   for cosmetic / drift-fix work.
2. **Consider the anchor-satellite filing shape.** If your
   contribution surfaces multiple related gaps (an audit pass, a
   reconciliation handoff, a multi-finding investigation), file the
   central gap as the anchor OPP and the dependent gaps as satellite
   observations in `shared-observations.md`. See
   [Diagram 11 — Anchor-Satellite Filing Pattern](../../docs/architecture/diagrams.md#11-anchor-satellite-filing-pattern)
   for the structural advantages and when to use vs. avoid this shape.
3. **Draft the PRD** if accepted. Take positions on the design
   questions the OPP leaves open.
4. **Implement** following the contracts in this guide. Run the full
   validator chain locally before opening the PR.
5. **Update catalog claims** wherever the contribution adds to a count.
   `validate-catalog-counts.sh` will catch what you miss.
6. **Pair with a distillation** if your contribution produced a
   durable architectural or process learning — see
   [`cycle-end-distillation.md`](cycle-end-distillation.md).

---

## References

- [Component Composition diagram](../../docs/architecture/diagrams.md#1-component-composition) — visual reference for how the layers fit together
- [`platform/core/kernel/base/`](../core/kernel/base/README.md) — kernel doctrine, trust model, schemas
- [`platform/validators/README.md`](../validators/README.md) — validator overview + library reference
- [`platform/templates/README.md`](../templates/README.md) — template conventions + placeholder reference
- [`platform/skills/harness-governance/SKILL.md`](../skills/harness-governance/SKILL.md) — skill example
- [`platform/agents/claude-code/README.md`](../agents/claude-code/README.md) — agent pack example
- [`docs/opportunities/README.md`](../../docs/opportunities/README.md) — opportunity-record workflow
- [`CONTRIBUTING.md`](../../CONTRIBUTING.md) — repo-wide contribution norms
