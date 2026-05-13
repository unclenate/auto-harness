# HARNESS.md

## Development Harness Framework — Self-Governance Entrypoint

This repository IS the modular governance platform. It governs itself using its own
module system, validators, and companion rules.

**Manifest:** `harness.manifest.yaml`
**Maturity:** Platform (Alpha)
**Owner:** @unclenate

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
| Distilled learnings | `docs/knowledge/distilled-learnings.md` |
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

Auto-harness can be mounted as a git submodule in downstream projects, with `install.sh` providing brownfield-safe bootstrap and `link-skills.sh` providing symlink-based skill delivery. See [platform/workflow/submodule-integration.md](platform/workflow/submodule-integration.md) for the canonical guide and [docs/adr/ADR-0003-submodule-integration.md](docs/adr/ADR-0003-submodule-integration.md) for the design rationale.
