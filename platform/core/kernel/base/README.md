<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Core Module: Kernel Base

The governance kernel is the foundation of the modular harness. Every project composition
includes it. Every other module — stacks, architectures, data, delivery, management, domains,
agents — inherits its rules and cannot override them.

The kernel defines what is durable across all project types: ownership must be explicit,
documentation is part of the change, AI acceleration increases the need for controls, and
secrets never belong in tracked artifacts. These principles are not configurable.

---

## Compiled Fragments

The kernel loads seven compiled fragments into agent context at every session start.
These are the always-on governance floor — not optional reading, not on-demand skills.

| Fragment | What It Establishes |
|----------|-------------------|
| `doctrine.md` | Six durable operating principles that apply across all stacks and domains |
| `trust-model.md` | Six-tier action model (Tier 0 read-only through Tier 5 production) with escalation rules |
| `lifecycle-controls.md` | Bootstrap-complete and harness-ready state definitions |
| `enforcement-model.md` | Five enforcement categories (doctrine, template, artifact, validator, review gate) kept distinct |
| `canonical-records.md` | Canonical vs. derivative record classification — what is authoritative and what is not |
| `audit-model.md` | Required audit surfaces and explicit non-goals |
| `ops-readiness.md` | Operational readiness dimensions every project must decide on (ownership, rollback, incidents, risks, environments) |

---

## Required Artifacts

| Artifact | Purpose |
|----------|---------|
| `HARNESS.md` | Project-level governance entrypoint — declares what harness composition is active and where to find everything |
| `AGENTS.md` | Cross-agent operating manual — trust tiers, scope, stop conditions, and escalation rules for all AI tooling |
| `docs/operating-principles.md` | Project-specific operating principles derived from kernel doctrine and team context |

---

## Sensitive Paths

The kernel watches two categories of paths for elevated review:

**Governance entrypoints** — `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, `.github/CODEOWNERS`
**Governance automation** — `.github/workflows/`, `scripts/`

Changes to these paths trigger a companion rule requiring either an ADR or an update to
`docs/operating-principles.md`. Governance changes need governance rationale.

---

## Validators

The kernel activates four validators:

- `validate-manifest` — schema and structure of the manifest file
- `validate-module-graph` — dependency resolution, conflict detection, type consistency
- `validate-placeholders` — no unfilled `[[PLACEHOLDER]]` or `YYYY-MM-DD` tokens
- `validate-companions` — companion rule enforcement across PR diffs

---

## Review Gate

*"Human review is mandatory for governance entrypoint changes. Validator success never
replaces ownership review for protected governance files."*

Validators check structure and presence. Humans check intent, quality, and risk. The kernel
makes this distinction explicit: a green CI run does not mean a governance change is approved.

---

## Relationship to Other Modules

All modules depend on the kernel, directly or transitively. The kernel does not define
language commands, framework paths, vendor layouts, or environment topology — those belong
in overlays. The kernel defines the rules that overlays cannot break.
