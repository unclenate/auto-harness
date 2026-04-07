# Scope Plan

**Owner:** @platform-team
**Last updated:** 2024-01-15
**Intake source:** `docs/discovery/intake-questionnaire.md` §7–8

---

## Delivery Scope

This project delivers the modular development harness as a production-ready governance platform.
The scope covers the platform itself (validators, profiles, templates, skills, compositions, workflow
guides) and the CI integration layer that governed projects use to enforce compliance.

Governed projects (downstream consumers) are not in scope here — this plan covers only the platform's
own development and release.

---

## In Scope

| Area | Description | Rationale |
| ---- | ----------- | --------- |
| Core validators | Six shell validator scripts covering manifest, module graph, artifacts, companions, placeholders, agent pack | Primary enforcement mechanism |
| Module profiles | Full set of stack, architecture, data, delivery, management, domain, and agent overlays | Required for governed project adoption |
| Governance documents | Doctrine, trust model, lifecycle controls, enforcement model, audit model, operational readiness | Compiled fragments injected into governed projects |
| Templates | All required and optional artifact templates with [[PLACEHOLDER]] tokens | Reduces friction for governed projects |
| Skills (Agent Skills format) | harness-governance, harness-testing, harness-web3, harness-onboarding | Governance depth for AI-assisted development |
| Starter compositions | New product discovery, Node SaaS, Python API, research pipeline, Web3, brownfield lite | Entry-point manifests for common project types |
| Workflow guides | Bootstrap quickstart, discovery-to-composition, brownfield onboarding, CI integration, troubleshooting | Human-readable operational paths |
| Test suite | Ruby unit tests (registry logic) + integration tests (validator scripts against fixtures) | Platform self-verification |
| CI integration | GitHub Actions workflow templates for governed projects | Adoption path for CI enforcement |

---

## Explicitly Out of Scope

| Item | Why deferred | When to revisit |
| ---- | ------------ | --------------- |
| Web-based harness UI or dashboard | CLI and file-based governance is the target; UI adds maintenance burden | Post v1 if team adoption signals demand |
| Package registry or install mechanism | Platform is adopted via subtree, submodule, or clone; a registry adds complexity | When external project count justifies it |
| Automatic manifest upgrade tooling | Manual migration is acceptable at current scale | When breaking schema changes occur |
| Cloud-hosted validator service | Local shell scripts are sufficient; serverless hosting adds ops cost | If enterprise customers require remote enforcement |
| Multi-language validator ports | Ruby is adequate; Node or Python ports would fragment maintenance | If Ruby adoption is a blocker for a target team |

---

## Constraints

- All validators must run as plain bash + Ruby stdlib (no gem install required)
- Manifests must be human-readable YAML; schema version must increment on breaking changes
- All templates must be fillable without platform tooling (copy, edit, commit)
- Skill documents must conform to the Agent Skills open standard (SKILL.md frontmatter)
