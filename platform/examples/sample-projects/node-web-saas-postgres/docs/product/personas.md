<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Personas

> **Note:** This is a filled-in example for the `node-web-saas-postgres` sample project.
> The blank template is at `platform/templates/product/personas.md`.

**Last updated:** 2024-01-15
**Linked requirements:** `docs/product/requirements.md`

---

## Primary Persona — The First-Time Adopter

**Name:** Alex (composite)
**Role:** Senior software engineer joining a team that uses the harness, or a solo developer
evaluating it for a new project.

**Context:** Alex has read the platform README, knows the harness exists, and needs to initialize
a project. Alex has never used this platform before.

**Goals:**
- Understand what a valid composition looks like without reading every module.yaml
- Get to a green validator run quickly
- Know what artifacts to create and in what order

**Frustrations:**
- Abstract documentation without a concrete example
- Running validators and getting cryptic errors with no path forward
- Not knowing if the manifest is correct until something breaks in CI

**Success criteria:** Alex can copy the sample project, adapt the manifest to their stack, and
reach a passing validator run in under 30 minutes.

**Quoted voice:** "Just show me what a real one looks like and I can figure out the rest."

---

## Secondary Persona — The Platform Maintainer

**Name:** Morgan (composite)
**Role:** The engineer responsible for maintaining the harness platform — adding modules,
updating validators, evolving the schema.

**Context:** Morgan uses the sample project as a regression check. If platform changes break
the sample, something is wrong.

**Goals:**
- Sample project stays green as the platform evolves
- Sample demonstrates every significant module type and rule
- Sample serves as documentation for platform behavior

**Frustrations:**
- Sample goes stale silently after platform changes
- Sample is too minimal to catch real-world module interaction issues

**Success criteria:** Every platform release is validated against the sample. The sample covers
enough of the platform surface area to catch regressions.

---

## Out-of-Scope Personas

| Persona | Reason not the audience |
|---------|------------------------|
| End users of applications built with the harness | The sample is a developer reference; it has no UI and is not a deployed product |
| Non-technical stakeholders | The governance model serves engineering teams; stakeholder-facing artifacts are the product of the harness, not the harness itself |
| Developers on stacks other than Node/TS/Postgres | Other stacks warrant their own sample projects with appropriate module compositions |

---

## Persona Change Log

| Date | Change | Reason |
|------|--------|--------|
| 2024-01-15 | Initial personas defined | First population of product-lite artifacts for sample project |
