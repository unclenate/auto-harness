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
| Management | `project-standard` | Scope, milestones, change tracking |
| Management | `product-lite` | Problem framing, requirements, release intent, PRDs |
| Agents | `base` | Cross-agent trust tier contract |
| Agents | `generic-llm` | Neutral adapter for non-Claude AI tooling |

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
