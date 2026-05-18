<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# MVP Scope

> **Note:** This is a filled-in example for the `node-web-saas-postgres` sample project.
> The blank template is at `platform/templates/discovery/mvp-scope.md`.

**Growth stage:** MVP / Early Access
**Linked requirements:** `docs/product/requirements.md`
**Last updated:** 2024-01-15

---

## MVP Definition

A complete, validators-passing reference implementation of the modular harness applied to a
Node.js / TypeScript / PostgreSQL web application, with all required artifacts populated and
a filled-in discovery record showing how the intake-to-manifest workflow was applied.

---

## In Scope

| Feature | Rationale | Acceptance Signal |
|---------|-----------|-------------------|
| Valid `harness.manifest.yaml` with full module set | Core purpose of the sample | `validate-manifest.sh` and `validate-module-graph.sh` pass with no errors |
| All required artifacts present and non-stub | Sample must model the standard, not stub it | `validate-required-artifacts.sh` passes with no warnings |
| Companion rules demonstrably enforced | Developers need to see what a triggered companion rule looks like | `validate-companions.sh` passes on the current state; README explains the trigger scenario |
| Filled-in discovery artifacts (this file, questionnaire) | Demonstrates the discovery workflow end-to-end | Files exist, are non-trivial, and reference each other correctly |
| Filled-in product artifacts (requirements, problem statement, personas) | Demonstrates product-lite workflow in practice | Files exist with real content; not placeholder text |
| Enriched requirements using Must/Should/Later tiers | Demonstrates the new template format | `requirements.md` includes user stories, tiers, and out-of-scope section |

---

## Explicitly Out of Scope

| Feature | Why deferred | When to revisit |
|---------|-------------|-----------------|
| Working application code | This is a governance reference, not a deployable app | Never — out of scope by design |
| Database schema or migrations | Would require a real application context | If a runnable sample is added later |
| CI pipeline for the sample project itself | Platform CI validates the platform; sample doesn't need its own pipeline | If the sample expands to include runnable code |
| Second stack sample (Python) | Separate sample project; this one covers Node/TS | Add as a parallel sample project when needed |
| ADR-0002 and beyond | Only ADR-0001 (stack choice) is seeded; architectural decisions require a real product context | As the sample evolves |

---

## Success Criteria

| Criterion | What it means | How to verify |
|-----------|---------------|---------------|
| Validators green | All four validator scripts exit 0 against this sample | Running `bash validators/validate-manifest.sh examples/sample-projects/node-web-saas-postgres/harness.manifest.yaml` |
| No stub content | No `[[PLACEHOLDER_NAME]]` tokens in any artifact | `validate-placeholders.sh` passes |
| Discovery chain complete | intake-questionnaire → mvp-scope → requirements are internally consistent (cross-references resolve) | Manual review |
| Usable as a copy-paste starter | A developer can copy the sample directory and have a valid project scaffold | Manual usability check |

---

## Scope Change Log

| Date | Change | Reason | Decided by |
|------|--------|--------|-----------|
| 2024-01-15 | Added filled-in discovery artifacts to MVP scope | The enriched templates were added to the platform; sample should demonstrate them | Platform team lead |
