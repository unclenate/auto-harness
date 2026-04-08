# Scope Plan

The scope plan defines what this project is responsible for delivering, the phases of
delivery, the team, and the constraints.

---

## Project Summary

| Field | Value |
| ----- | ----- |
| Project | Development Harness Framework |
| Owner | @unclenate |
| Start date | 2026-03-01 |
| Current phase | Alpha stabilization |

---

## In Scope

- Modular governance framework (kernel + overlays) with YAML-based manifest
- Shell/Ruby validators for CI integration
- Templates for all required artifacts
- ADR and PRD record types with companion rule enforcement
- Agent Skills in standard SKILL.md format
- Brownfield and greenfield onboarding workflows
- Self-governance of this repository using its own framework
- GitBook-compatible documentation structure

---

## Out of Scope

- Runtime application code (this is a governance framework, not an app)
- Trust tier enforcement at the tool level (advisory governance only)
- Multi-repo or monorepo federation
- Paid distribution or SaaS offering
- Enterprise compliance certification

---

## Phases

| Phase | Goal | Owner | Status |
| ----- | ---- | ----- | ------ |
| Monolith | Single governance prompt | @unclenate | Done |
| Modular restructure | Decompose into kernel + modules | @unclenate | Done |
| Skills and agents | Agent Skills standard, trust tiers | @unclenate | Done |
| Testing layer | Validators, test suite, CI docs | @unclenate | Done |
| Documentation polish | Templates, workflows, brownfield | @unclenate | Done |
| Alpha stabilization | Gap analyses, PRD restoration, self-governance | @unclenate | Active |

---

## Team and Responsibilities

| Role | Name / Team | Responsibilities |
| ---- | ----------- | ---------------- |
| Project owner | @unclenate | All scope decisions, architecture, implementation |

---

## Constraints

- **Timeline** — No fixed deadline; quality over speed
- **Budget** — Zero; open-source tooling only
- **Dependencies** — Ruby, Bash, ripgrep (no heavy runtime)
- **Team** — Solo contributor; AI assistants used for acceleration

---

## Reference

| Resource | Path |
| -------- | ---- |
| Requirements | `docs/product/requirements.md` |
| Milestones | `docs/project/milestones.md` |
| Change log | `docs/project/change-log.md` |
