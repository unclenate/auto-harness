# Module Types

The modular harness uses a small set of stable module families.

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
