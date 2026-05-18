<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Discovery Intake Questionnaire

> **Note:** This is a filled-in example for the `node-web-saas-postgres` sample project.
> The blank template is at `platform/templates/discovery/intake-questionnaire.md`.

**Session date:** 2024-01-15
**Facilitator:** Self-interview
**Participants:** Platform team lead

---

## Section 1 — Project Identity

**Working title:** Node Web SaaS Postgres Sample

**One-sentence description:** A reference implementation of the modular harness platform applied
to a Node.js / TypeScript web application with PostgreSQL persistence.

**Primary goal:** Demonstrate that the harness platform works end-to-end for the most common
production SaaS stack — Node, TypeScript, Express or similar web framework, Postgres.

**Production URL:** N/A — sample project for documentation and testing purposes.

---

## Section 2 — Problem and Opportunity

**What problem does this solve?**
Developers reading the harness platform docs need a concrete, filled-in example to understand
what a valid manifest composition looks like in practice and how each module interacts.

**Who has this problem?**
Developers adopting the harness for the first time; developers initializing a new Node/TS/Postgres project.

**How do they solve it today?**
They read the module.yaml files and README docs and mentally assemble what a composition should
look like. This is error-prone and slow.

**Why is this worth building now?**
The platform modules exist but without a sample project, the first adopter faces a blank slate
with no reference for what "done" looks like.

---

## Section 3 — Users and Stakeholders

**Primary users:** Platform developers and engineers adopting the harness for the first time.

**Primary user goals:** Understand what a complete, valid harness manifest looks like. Copy it as
a starting point. See how validators pass on a real file layout.

**Primary user frustrations:** Reading abstract YAML schemas without a concrete example. Not
knowing if their composition is correct until validators fail.

**Who is NOT the audience:** End users of whatever product is built with the harness. This sample
is a developer reference, not a consumer-facing product.

---

## Section 4 — Starting Point

- [x] Written spec (the harness platform module docs)
- [x] Existing codebase (the platform validator library and module definitions)

No mockups, wireframes, or prototypes. This is a documentation and governance artifact, not a UI.

---

## Section 5 — Requirements Calibration

**Must exist for MVP:**

- Valid `harness.manifest.yaml` for Node/TS/Postgres stack
- All required artifacts present and populated (non-stub)
- All validators pass cleanly
- Demonstrated companion rule scenario in the ops artifacts

**Would make it great (v1+):**

- Filled-in discovery artifacts (questionnaire, MVP scope, personas)
- Filled-in product artifacts (enriched requirements, problem statement)
- A second sample project for a different stack (e.g. Python)

**Explicitly not in scope:**

- Working application code (this is a docs and governance sample only)
- Database migrations or schema
- CI pipeline for the sample project itself (the platform CI covers validators)

**Non-negotiables:**

- Validators must pass with no errors on this sample
- Required artifact paths must match exactly what module.yaml declarations specify

**Success criteria:**
A new adopter can copy this sample and run validators to green in one command.

---

## Section 6 — Scale and Growth

Not applicable — this is a sample/reference project with no real users or data.

---

## Section 7 — Team and Delivery

**Team:** Solo, platform team lead maintaining the sample alongside the platform.

**AI-assisted development:** Claude Code used for implementation.

**Timeline:** Ongoing — updated as platform modules evolve.

**Budget tier:** Internal tooling / developer experience investment.

**Deployment target:** No deployment — local reference only.

---

## Section 8 — Technical Context

**Stack:** Node.js, TypeScript, PostgreSQL (as declared in the manifest).

**Target platform:** Web application with API. Background job processing out of scope for this sample.

**Existing infrastructure:** None — this is a template/example, not a deployed system.

---

## Composition Signals Summary

| Question | Answer | Module |
|----------|--------|--------|
| Web UI needed? | Yes | `architectures/web-app` |
| Relational data / SQL? | Yes — Postgres | `data/relational-postgres` |
| Node / TypeScript? | Yes | `stacks/node-typescript` |
| Production SaaS? | Sample targets production patterns | `delivery/production-saas` |
| Always for real products | Yes | `management/product-lite` + `management/project-standard` |
| Claude Code as agent? | Yes | `agents/claude-code` |

**Selected composition:** See `harness.manifest.yaml` in the project root.
