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
| `compiledFragments` | string[] | Platform docs compiled into agent context at session start |
| `recommendedSkills` | string[] | **Optional.** External AI tool skill IDs that provide domain-specific knowledge relevant to this module. These are installed by the developer in their AI tool, not enforced by validators. See `platform/workflow/skills-and-agents.md`. |
