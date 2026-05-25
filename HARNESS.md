<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# HARNESS.md

> **New to auto-harness?** Start with the [repository README](README.md) for the
> value proposition, hero graphic, and adoption paths. This file is the
> *self-governance entrypoint* — it describes what governance is active on
> this repository, not how to adopt auto-harness for your own project.

## Development Harness Framework — Self-Governance Entrypoint

This repository IS the modular governance platform. It governs itself using its own
module system, validators, and companion rules.

> **Visual reference:** [Architecture Diagrams](docs/architecture/diagrams.md) — eleven
> Mermaid diagrams covering composition, trust tier flow, companion rule firing,
> opportunity-to-decision lifecycle, distillation triggers, consumer adoption,
> paired-mechanism dynamic, OPP→PRD design-pressure cascade, catalog-counts
> assertion flow, canonical-position artifact flow, and the anchor-satellite
> filing pattern.

**Manifest:** `harness.manifest.yaml`
**Maturity:** Platform (Alpha)
**Owner:** @unclenate
**License:** Dual MIT / Apache-2.0 at consumer option — see [LICENSE-MIT](https://github.com/unclenate/auto-harness/blob/main/LICENSE-MIT), [LICENSE-APACHE](https://github.com/unclenate/auto-harness/blob/main/LICENSE-APACHE), and [ADR-0005](docs/adr/ADR-0005-open-source-cut.md)
**Contributing:** see [CONTRIBUTING.md](CONTRIBUTING.md) · **Security:** see [SECURITY.md](SECURITY.md) · **Conduct:** see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)

### Sibling entrypoints at the repo root

This file states *what governance is active*. The other root files each have a distinct job:

- [`README.md`](README.md) — repo and GitBook front door for human readers
- [`AGENTS.md`](AGENTS.md) — cross-agent operating manual (trust tiers, scope, stop conditions, first-session workflow)
- [`CLAUDE.md`](CLAUDE.md) — Claude Code load-order shim
- [`TOOLS.md`](TOOLS.md) — environment-specific tool registry for MCP developer tools

---

## Active Modules

| Family | Module | Purpose |
|--------|--------|---------|
| Core | `kernel/base` | Governance kernel — doctrine, trust tiers, lifecycle controls |
| Delivery | `internal-platform` | Internal platform delivery posture |
| Management | `project-standard` | Scope, milestones, change tracking, revision tracker, review log |
| Management | `product-lite` | Problem framing, requirements, release intent, PRDs |
| Management | `knowledge-capture` | Append-only shared observations and distilled longitudinal learnings (`docs/knowledge/`) |
| Management | `opportunity-capture` | Forward-looking pre-PRD candidate records with promotion-to-PRD contract (`docs/opportunities/`) |
| Agents | `base` | Cross-agent trust tier contract |
| Agents | `generic-llm` | Neutral adapter for non-Claude AI tooling |
| Agents | `openclaw` | OpenClaw agent pack (self-dogfood) |

---

## Governance Artifacts

| Artifact | Path |
|----------|------|
| Operating principles | `docs/operating-principles.md` |
| Problem statement | `docs/product/problem-statement.md` |
| Requirements | `docs/product/requirements.md` |
| Release intent | `docs/product/release-intent.md` |
| Scope plan | `docs/project/scope-plan.md` |
| Milestones | `docs/project/milestones.md` |
| Change log | `docs/project/change-log.md` |
| Dependency log | `docs/project/dependency-log.md` |
| Revision tracker | `docs/project/revision-tracker.md` |
| Shared observations | `docs/knowledge/shared-observations.md` |
| Curated longitudinal knowledge | `docs/operating-principles.md` *(historical pointer at `docs/knowledge/distilled-learnings.md` — see ADR-0014)* |
| Opportunity records | `docs/opportunities/` (policy README + `OPP-NNNN-slug.md` per candidate) |
| ADRs | `docs/adr/` |
| PRDs | `docs/requirements/` |

---

## Source of Truth

The governance rules live in the modular platform:

- Kernel doctrine and trust model: `platform/core/kernel/base/`
- Module contracts: `platform/profiles/**/module.yaml`
- Agent packs: `platform/agents/**/module.yaml`
- Validators: `platform/validators/`
- Templates: `platform/templates/`

This file is the project-level entrypoint. The platform modules are the authority.

---

## Consuming auto-harness in other projects

Auto-harness can be mounted as a git submodule in downstream projects, with `install.sh` providing brownfield-safe bootstrap and `link-skills.sh` providing symlink-based skill delivery.

| Phase | Guide |
| ----- | ----- |
| Adoption (one-time setup) | [platform/workflow/submodule-integration.md](platform/workflow/submodule-integration.md) |
| Day-to-day governance | [platform/workflow/skills-and-agents.md](platform/workflow/skills-and-agents.md) and [platform/workflow/ci-integration.md](platform/workflow/ci-integration.md) |
| Long-term maintenance | [platform/workflow/maintenance-operations.md](platform/workflow/maintenance-operations.md) — upgrades, version pinning, drift recovery, periodic governance audits |
| Design rationale | [docs/adr/ADR-0003-submodule-integration.md](docs/adr/ADR-0003-submodule-integration.md) |
