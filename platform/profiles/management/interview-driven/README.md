<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Management Overlay: Interview-Driven

This overlay governs projects whose product and project documentation lives in **monolithic, interview-driven artifacts** rather than the canonical multi-file set produced by `discovery-intake` + `product-lite` + `project-standard`.

It is the right overlay when the team has converged on:

- **One PRD file** (e.g. `docs/PRD.md` or `docs/PRD-v2-revised.md`) instead of a separate problem statement, requirements doc, and release intent
- **One decision-complete plan** (e.g. `docs/full-plan.md`) instead of a scope plan, milestone doc, change log, dependency log, and revision tracker spread across `docs/project/`
- **A downstream interview/spec prompt** (e.g. `docs/prd-interview-spec-prompt.md`) that turns the PRD into structured prompts for code-generation agents — a pattern with no analog in `product-lite` or `project-standard`

---

## When to Use This Overlay

Pick `interview-driven` when **all** of the following are true:

- The team is small (solo, pair, or hackathon-sized) and the per-PRD ceremony of `product-lite + project-standard` would slow them down more than it would help
- Product decisions live in one PRD, not three docs that drift apart
- The plan is decision-complete — the same file lists scope, milestones, dependencies, and trade-offs — and splitting it across five files would obscure rather than clarify
- AI agents are part of the loop, and an interview-driven prompt is the bridge between human intent and machine implementation

Pick `product-lite + project-standard` instead when:

- The team is large enough that distinct files for problem framing, requirements, release intent, scope plan, milestones, change log, and dependency log are read and edited by different people
- Decisions and rationale need ADR-level granularity that doesn't fit into a single plan file
- The project has progressed past prototype maturity and needs more formal governance artifacts

---

## What This Overlay Requires

Two required artifact slots, each satisfied by **any one** of a list of canonical paths:

**PRD slot** — one of:

- `docs/PRD.md`
- `docs/PRD-*.md` (e.g. `docs/PRD-v2-revised.md`)
- `docs/requirements/PRD-*.md` (matches the `platform/templates/product/prd.md` template path convention)
- `docs/product/requirements.md` (allows upgrade overlap with `product-lite` without breakage)

**Plan slot** — one of:

- `docs/full-plan.md`
- `docs/plan.md`
- `docs/project/scope-plan.md` (allows upgrade overlap with `project-standard`)

Two optional artifact slots:

- **Interview/spec prompt** — one of `docs/*interview*.md` or `docs/*spec-prompt*.md`. This is the AI-facing bridge document. It is optional because not every team uses an AI agent; when present, the companion rule treats its update as legitimate companion evidence for a PRD change.
- **Problem statement** — `docs/product/problem-statement.md`. Kept optional so that a future upgrade to `product-lite` does not require regressing this overlay's required-set.

---

## Companion Rule: PRD Changes Need Decision Evidence

When the PRD changes — under any of the recognized PRD paths — the same commit must also touch at least one of:

- `docs/project/change-log.md` (the canonical change record)
- A new `docs/adr/ADR-*.md` (architectural rationale)
- `docs/full-plan.md`, `docs/plan.md`, or `docs/project/scope-plan.md` (downstream plan refresh)
- A `docs/*interview*.md` or `docs/*spec-prompt*.md` file (downstream prompt refresh)

The human review gate requires reviewers to verify that the change is intentional, that explicit out-of-scope items remain named, and that downstream prompts have been refreshed so agents do not work from a stale derivation. This is the most common failure mode for the monolithic-PRD style: the PRD updates, the prompt does not, and the agent silently builds against the old spec.

---

## Compatibility With Canonical Overlays

`interview-driven` is intentionally compatible with `discovery-intake`, `product-lite`, and `project-standard`. It does not list them under `conflictsWith`. A project can:

- Start with `interview-driven` while the docs are monolithic
- Add `product-lite` and `project-standard` later, once the team grows or the docs need to be split, without first removing `interview-driven`
- Run all four simultaneously during a migration window — required artifacts compose by union, so the project simply has to satisfy both sets while transitioning

There is no automatic content migration. When the project upgrades, the team copies content from the monolithic PRD into the split product-lite files and from the full plan into the split project-standard files. The interview-driven overlay can then be removed from the manifest.

---

## Trust-Tier Implications

None. This overlay is **additive**: it expands what the harness can recognize as a valid governance shape. It does not weaken any existing rule, does not introduce new sensitive paths, and does not change the kernel's trust model. The `oneOf` semantics it relies on is governed by the same validator chain as literal-path required artifacts.

---

## Relationship to `discovery-intake`

`discovery-intake` produces multiple discovery artifacts (`intake-questionnaire.md`, `mvp-scope.md`, `starting-assets.md`) and is itself a separate management overlay. `interview-driven` does not replace it — a project can adopt both. Discovery artifacts feed the monolithic PRD just as they feed the split product-lite files. If your team has done formal discovery, keep `discovery-intake` active. If your team is moving fast enough that the discovery conversation happens directly inside the interview-driven prompt file, omit `discovery-intake` and let the prompt carry the provenance.

---

## Example Manifest

```yaml
schemaVersion: 1
project:
  id: example-hackathon
  name: Example Hackathon Project
  maturity: prototype
  criticality: low
modules:
  core: [kernel/base]
  delivery: [prototype]
  management: [interview-driven]
  agents: [base]
overrides:
  requiredArtifacts: []
  disabledValidations: []
```

See `platform/compositions/interview-driven-discovery.yaml` for the starter composition and `platform/examples/sample-projects/interview-driven-hackathon/` for a complete reference layout.

---

## See Also

- [ADR-0006: Interview-Driven Management](../../../../docs/adr/ADR-0006-interview-driven-management.md) — why this overlay exists and how it relates to `product-lite + project-standard`
- [`platform/profiles/management/product-lite/`](../product-lite/) — split-file product overlay (upgrade target)
- [`platform/profiles/management/project-standard/`](../project-standard/) — split-file project overlay (upgrade target)
- [`platform/profiles/management/discovery-intake/`](../discovery-intake/) — formal discovery overlay (compatible)
