<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0008: Agent Skill-Pack Architecture Module

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-05-25 | **Review Cycle:** On-change

**Status:** Accepted *(v1 module scaffolded; release marker v0.5.2)*
**Date:** 2026-05-25 (filed) | 2026-05-25 (accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Promotes: [OPP-0018](../opportunities/OPP-0018-architecture-eval-gated-skill-pack.md) — `proposed` → `accepted`
- Pairs with: [PRD-0009](PRD-0009-eval-gated-testing-module.md) (the eval gate that protects the pack), [PRD-0010](PRD-0010-self-hosted-oss-delivery.md) (skill-pack runtimes typically ship self-hosted)
- Evidence: consumer gap analysis at `tula:docs/knowledge/harness-coverage-gap-analysis.md` §TG1
- Observation: `docs/knowledge/shared-observations.md` — *"Third brownfield instance surfaces a second gap class: delivery-topology breadth for agent-native products"* (2026-05-24)
- Adjacent (opposite direction): [OPP-0001](../opportunities/OPP-0001-exportable-governance-contract-for-runtime-harnesses.md), [OPP-0002](../opportunities/OPP-0002-agentic-interface-awareness.md)

## Overview

The catalog can describe apps, services, MCP servers, and in-product agent
UIs, but not a product whose **unit of delivery is an authored agent skill
pack** loaded by a runtime the consumer does not own. OPP-0018 surfaced this
from the Tula onboarding (six skills authored to `skills/AGENTS.md`, deployed
to `~/.openclaw/workspace/skills/`, gated by Waza in CI) and from the
`jmandel/health-skillz` lineage (a standard's co-creator publishing agent
skills as the delivery vehicle).

This PRD specifies a v1 `architectures/agent-skill-pack` module: one required
artifact (an architecture overview that names the skill-loading model), an
optional authoring-conventions doc with a template, sensitive-path coverage
of skill sources, and a companion rule binding each skill to a matching eval.

## Goals & Non-Goals

**Goals**

- Ship `platform/profiles/architectures/agent-skill-pack/{module.yaml,README.md}`.
- Require `docs/architecture/overview.md` to name the runtime, the
  skill-loading model, and the workspace/permission boundary (reuses the
  existing `architecture-overview.md` template — no new architecture
  template).
- Provide `platform/templates/skills/authoring-conventions.md` for the
  optional authoring-standard artifact.
- Bind skill-source changes to a matching eval via a companion rule (the
  bridge to `management/eval-gated-testing`).
- Propagate to SUMMARY, the `harness-onboarding` skill catalog, and the
  `discovery-to-composition` rubric; bump catalog counts.

**Non-Goals**

- **A separate `domains/openclaw` module.** OPP-0018 floated a thin OpenClaw
  ecosystem overlay. Deferred: `agents/openclaw` already governs OpenClaw
  workspace files; a second OpenClaw surface would double-govern. The module
  is vendor-neutral; OpenClaw specifics stay in the agent pack. Revisit if a
  second OpenClaw-specific concern appears that the agent pack can't hold.
- **Defining the eval format.** This module only requires an eval *exists*
  per skill (companion rule); the eval's shape is PRD-0009's concern.
- **A `harness-skill-pack` skill.** Skill authoring is a separate effort; v1
  leans on `harness-governance` + `harness-testing` in `recommendedSkills`.

## Functional Requirements

### FR-001 — Module definition

`architectures/agent-skill-pack` `module.yaml`: `type: architecture`,
`dependsOn: [kernel/base]`, `conflictsWith: []`, `requiredArtifacts:
[docs/architecture/overview.md]`, optional `docs/skills/authoring-conventions.md` plus `docs/skills/skill-pack-manifest.md`.

### FR-002 — Sensitive paths

Cover skill sources (`^skills/`, `^prompts/`, `SKILL\.md$`) and the deploy
surface (`deploy-skills`, packaging).

### FR-003 — Eval companion rule

A change to `skills/**/SKILL.md`, `skills/**/scripts/`, or `prompts/` must be
paired with an eval (`^evals/`), an authoring-conventions update, or an ADR.
`humanReview` verifies scope-containment, least-permission, and
reference-don't-embed.

### FR-004 — Authoring-conventions template

`platform/templates/skills/authoring-conventions.md` with tokenized header
and `[[…]]` body tokens (priority rule, frontmatter spec, body-section order,
path conventions, reference-don't-embed, scope/permission, validation/deploy).

### FR-005 — Review gates

Scope-containment, reference-don't-embed, named skill-loading model, and
human review for any new side-effecting action.

### FR-006 — Catalog propagation

SUMMARY Module Library (Architectures); `harness-onboarding` SKILL.md
architecture catalog; `discovery-to-composition` Step 6 rubric row; README
Module System table. Counts: `modules_profiles` and `modules_all` +1 (shared
across this PRD batch), `templates` +1.

## Acceptance Criteria for OPP-0018 → `accepted`

1. This PRD `Accepted`.
2. FR-001…FR-006 merged to `main`.
3. `validate-manifest`, `validate-module-graph`, `validate-required-artifacts`,
   `validate-companions`, `validate-placeholders`, `validate-doc-references`,
   `validate-catalog-counts` green on the PR.
4. Module reachable from the `harness-onboarding` skill catalog.

## Out of Scope

- `domains/openclaw` (see Non-Goals).
- The eval format (PRD-0009).
- A worked sample-project for the module (follow-up; Tula itself is the
  living reference once its second-pass manifest activates the module).

## Risks

- **Single evidence point (Tula).** The `jmandel/health-skillz` lineage is a
  strong external signal, but a second independent skill-pack consumer
  (ideally non-health) should be sought before bumping the module past 1.x.
- **Boundary with `agents/openclaw`.** Documented in both module READMEs (the
  deploy step is the boundary). Revisit if consumers conflate them.

## Open Questions Resolved

- **Family?** → `architectures/` (it is a topology decision about where
  capability lives and how it is loaded). A thin `domains/openclaw` was
  considered and deferred (Non-Goals).
- **Required artifact?** → reuse `docs/architecture/overview.md` rather than a
  bespoke required doc; the authoring-conventions doc is optional. Keeps v1
  light, per the OPP-0013 module-sizing observation.

## Versioning Implications

Module ships at `1.0.0`. Catalog counts bump as part of the v0.5.2 batch
(see PRD-0009/PRD-0010 for the shared count math). Release marker: **v0.5.2**.
