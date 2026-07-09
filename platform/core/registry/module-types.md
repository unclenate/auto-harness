<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Module Types

The modular harness uses a small set of stable module families. This document is the
authoritative reference for the eight families and for every field a `module.yaml`
supports. If you have never read about the harness before, start with the **Core
Concepts** block immediately below — it names the five terms every other section
assumes you know.

---

## Core Concepts

These are the words this entire reference assumes. If you skip them, the rest reads
as jargon. See [`platform/reference/glossary.md`](../../reference/glossary.md) for
the full canonical glossary.

- **Module** — a directory containing a `module.yaml` file declaring a governance
  contract (required artifacts, sensitive paths, companion rules, validators, etc.).
  The unit the harness composes from. Each module is *opt-in* via the manifest,
  except for the kernel.
- **Manifest** (`harness.manifest.yaml`) — the declaration file at a project's root
  that names which modules are active for that project. The harness reads this file
  to decide what governance applies.
- **Composition** — a *starter manifest* under `platform/compositions/` for a common
  project type. You copy one to your project root and adjust it; the composition is
  a starting point, not a runtime dependency.
- **Overlay** — a `management/`-family module (or any module whose purpose is to
  *add discipline on top of* an existing stack/architecture). Overlays can be added
  or removed mid-project without re-architecting.
- **Kernel** — the non-optional governance foundation at `platform/core/kernel/`.
  Every harnessed project inherits the kernel's doctrine, trust-tier model, and
  lifecycle controls. Unlike profile modules, kernel content applies universally.
- **Trust Tier** — one of six escalation levels (0 through 5) classifying agent
  actions by blast radius. Tier 0 is read-only; tier 5 is production / irreversible.
  See [`platform/core/kernel/base/trust-model.md`](../kernel/base/trust-model.md)
  for the full model.

With those six terms, the rest of this document — the family taxonomy, the field
reference, the anatomy walkthrough — should read straight through.

---

## Anatomy of a Module — Worked Example

Before the family taxonomy and field reference, a concrete look at what a real
module looks like. The shortest, most-cited module in the catalog is
`platform/profiles/architectures/web-app/module.yaml`. Its full text (~25 lines)
illustrates every conceptual move the harness makes.

```yaml
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
id: web-app
type: architectures
version: 1.0.0
summary: "Web application architecture overlay — frontend + API + session model."
dependsOn:
  - kernel/base
conflictsWith:
  - architectures/api-service
  - architectures/event-driven
requiredArtifacts:
  - docs/architecture/overview.md
optionalArtifacts: []
sensitivePaths: []
companionRules: []
validators:
  - validate-required-artifacts
reviewGates: []
agentAdapters: []
compiledFragments: []
recommendedSkills: []
```

Reading top-to-bottom, the module says:

- **`id: web-app`, `type: architectures`** — *what family this module is* (governance
  pattern for an interaction and deployment shape).
- **`version: 1.0.0`** — *what version of this module's contract* — modules version
  their contracts so consumers can pin and upgrade deliberately.
- **`summary:`** — *one-line human description* — the harness's catalog tools
  (`SUMMARY.md`, `docs/README.md` tables, the onboarding skill) read this to give
  humans a quick sense of what each module is for.
- **`dependsOn: [kernel/base]`** — *what other modules must be active for this one to
  work*. The kernel is always required; profile modules can also require other
  profile modules (e.g., a `domains/healthcare-*` module might depend on the
  `data/relational-sql` module).
- **`conflictsWith: [architectures/api-service, architectures/event-driven]`** —
  *which modules cannot coexist*. A project that is a web app isn't simultaneously
  a pure API service or a pure event-driven system; the architecture family has
  mutually-exclusive choices.
- **`requiredArtifacts: [docs/architecture/overview.md]`** — *what the project must
  ship on disk* for this module to be satisfied. `validate-required-artifacts.sh`
  checks every entry exists.
- **`validators: [validate-required-artifacts]`** — *which validators apply* to
  this module's contract. Most modules use just one or two; the harness's eight
  validators each handle a specific dimension of the governance contract.
- **The empty fields** (`optionalArtifacts`, `sensitivePaths`, `companionRules`,
  `reviewGates`, `agentAdapters`, `compiledFragments`, `recommendedSkills`) — this
  module is intentionally lightweight: a thin governance overlay that asserts
  "this project commits to web-app architecture and ships an overview doc." More
  substantial modules (e.g., `management/knowledge-capture`) populate more fields.

Every module in the catalog follows this same shape. Reading any one tells you
*what governance the module commits to*; reading the
[Module Field Reference](#module-field-reference) below tells you *what each field
can express*.

---

## Core

Universal doctrine and lifecycle controls that apply across project types.

## Stacks

Language, runtime, framework, package, and CI adaptations for a technical stack.

## Architectures

Interaction and deployment patterns such as web apps, API services, or event-driven systems.

## Data

Storage and state-management overlays such as relational databases, document stores, or object storage.

## Delivery

Lifecycle and operational posture overlays such as prototype, production SaaS, or internal platform.

## Management

Product, project, and program context overlays that declare delivery artifacts and governance expectations.

## Domains

Vendor, ecosystem, or specialist overlays such as Supabase, Web3, or media pipelines.

## Agents

AI-tool packs that describe operating constraints, compatibility fragments, and local adapter expectations.

---

## Module Field Reference

Each `module.yaml` file supports the following fields. All fields except `recommendedSkills` are required.

| Field | Type | Purpose |
| ----- | ---- | ------- |
| `id` | string | Unique identifier, kebab-case, optional `/` namespace (e.g., `kernel/base`) |
| `type` | enum | One of the module families above |
| `version` | semver | Module definition version |
| `summary` | string | One-line human description |
| `dependsOn` | string[] | Modules that must be active when this one is active |
| `conflictsWith` | string[] | Modules that cannot coexist with this one |
| `requiredArtifacts` | string[] | File paths that must exist in the project |
| `optionalArtifacts` | string[] | File paths that are expected but not enforced |
| `sensitivePaths` | pathRule[] | Path patterns that trigger elevated review when changed |
| `companionRules` | companionRule[] | When trigger paths change, these companion paths must also change |
| `validators` | string[] | Validator IDs that apply to this module |
| `reviewGates` | string[] | Human review conditions that this module activates |
| `agentAdapters` | string[] | Files or module paths that configure agent tooling |
| `compiledFragments` | string[] | Platform docs loaded into agent context at every session start — always-on governance floor. Distinct from skills: compiled fragments are mandatory context; skills are loaded on demand when a task matches. |
| `recommendedSkills` | string[] | **Optional.** Skill names and ecosystem slugs relevant to this module. Two namespaces: (1) Agent Skills format skill names installable as `SKILL.md` directories (source: `platform/skills/`); (2) OpenClaw/ClawHub slugs installed via `clawhub install`. Not enforced by validators — developer discipline step. See `platform/workflow/skills-and-agents.md`. |

---

## compiledFragments vs. recommendedSkills

These two fields are complementary, not redundant. A module can and often does list the
same domain in both fields. They serve different purposes:

| | `compiledFragments` | `recommendedSkills` |
| - | ------------------- | ------------------- |
| Loaded | Always, at every session start | On demand — only when a task matches the skill |
| Enforced | Yes — validator checks that the file exists | No — developer installs the skill |
| Token cost | Full content every session | ~100 tokens at startup; full body only on activation |
| Purpose | Governance rules that must always be in context | Deeper domain guidance loaded when the task needs it |
| Example | `platform/core/kernel/base/trust-model.md` | `platform/skills/harness-governance/SKILL.md` |

**Example:** `kernel/base` lists `trust-model.md` as a compiled fragment (always-on, ensures
every session starts with trust tier rules in context) AND lists `harness-governance` in
`recommendedSkills` (on-demand, loads full companion rule detail and validator commands only
when a governance task is active). The fragment provides the floor; the skill provides depth.

---

## JSON Schema Reference

JSON Schema files (`manifest.schema.json`, `module.schema.json`) in this directory describe
the canonical structure of manifests and modules for editor validation and documentation.
Runtime enforcement uses inline checks in the validator scripts (`platform/validators/`).
