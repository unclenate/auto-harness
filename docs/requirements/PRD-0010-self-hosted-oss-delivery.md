<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0010: Self-Hosted OSS Delivery Posture

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-05-25 | **Review Cycle:** On-change

**Status:** Accepted *(v1 module scaffolded; release marker v0.5.2)*
**Date:** 2026-05-25 (filed) | 2026-05-25 (accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Promotes: [OPP-0021](../opportunities/OPP-0021-delivery-self-hosted-oss.md) — `proposed` → `accepted`
- Sibling postures: `platform/profiles/delivery/{prototype,production-saas,internal-platform}/`
- Composes with: [PRD-0008](PRD-0008-agent-skill-pack-architecture.md) (skill-pack runtimes ship self-hosted)
- Evidence: `tula:docs/knowledge/harness-coverage-gap-analysis.md` §TG3

## Overview

The `delivery/` family has no posture for **published OSS that ships as a
self-hosted deployment the user operates** — between `prototype` (undersells
live software handling real data) and `production-saas` (oversells with
hosted-infra ops artifacts that don't exist when every user self-hosts).
OPP-0021 surfaced this from Tula (Apache-2.0 + single-user VM reference
deployment with `deployment-guide`, `security-model`, `cost-guide`, and
operator scripts).

This PRD specifies a v1 `delivery/self-hosted-oss` posture: one required
artifact (a self-hosting guide), optional security/release artifacts that
reuse existing templates, and a companion rule binding install/deploy changes
to the operator's contract.

## Goals & Non-Goals

**Goals**

- Ship `platform/profiles/delivery/self-hosted-oss/{module.yaml,README.md}`.
- Require `docs/deployment/self-hosting-guide.md`; provide
  `platform/templates/deployment/self-hosting-guide.md`.
- Reuse existing templates for optional artifacts (`risk-register.md`,
  `product/release-intent.md`, `ops/runbook-index.md`) — no new templates
  beyond the self-hosting guide.
- Companion rule: install/deploy automation changes require a self-hosting
  guide or release-intent update.
- Review gate: criticality ≥ medium ⇒ risk register strongly expected.

**Non-Goals**

- **Symmetric `conflictsWith` edits to `prototype`/`production-saas`.** v1 uses
  `conflictsWith: []` (matching `internal-platform`) and documents the
  single-posture expectation in the README — avoids editing unrelated modules
  and bumping their versions. A future graph-level "exactly one delivery
  posture" check is the cleaner long-term home for mutual exclusivity.
- **Hosted-service artifacts.** A project that also offers a hosted edition
  models it as a separate manifest with `production-saas`.
- **Encoding maturity.** Self-hosted OSS is orthogonal to `maturity`.

## Functional Requirements

### FR-001 — Module definition

`delivery/self-hosted-oss` `module.yaml`: `type: delivery`,
`dependsOn: [kernel/base]`, `conflictsWith: []`, `requiredArtifacts:
[docs/deployment/self-hosting-guide.md]`, optional `[docs/security/risk-register.md,
docs/product/release-intent.md, docs/ops/runbook-index.md]`.

### FR-002 — Sensitive paths

Install/deploy/backup scripts, `install/`, `deploy/`, `Dockerfile`,
`docker-compose`, the release-intent doc, `CHANGELOG`.

### FR-003 — Install/deploy companion rule

Changes to install/deploy automation require a self-hosting-guide or
release-intent update (or ADR). `humanReview` flags operator-inherited
security-posture changes (default credentials, exposed ports, data
locations, backup behavior).

### FR-004 — Self-hosting-guide template

`platform/templates/deployment/self-hosting-guide.md` (tokenized header;
sections for operator model, minimum viable deployment, data locations,
inherited security posture, upgrade/versioning, backup/recovery, costs).

### FR-005 — Review gates

Operator contract completeness; risk-register expectation at criticality ≥
medium; separate-manifest rule for hosted editions; no prototype-style waiver
of secret-handling/supply-chain rules.

### FR-006 — Catalog propagation

SUMMARY Module Library (Delivery); `harness-onboarding` SKILL.md delivery
catalog (third posture); `discovery-to-composition` Step 6 rubric row. Counts:
shared module +1; `templates` +1.

## Acceptance Criteria for OPP-0021 → `accepted`

1. This PRD `Accepted`.
2. FR-001…FR-006 merged.
3. Full validator chain green on the PR.
4. Module reachable from the `harness-onboarding` skill catalog as a third
   delivery posture.

## Out of Scope

- Symmetric conflict edits / a graph-level single-posture check (future work).
- A hosted-edition posture (use `production-saas` in a separate manifest).

## Risks

- **Loose mutual exclusivity.** With `conflictsWith: []`, a manifest could
  declare both `prototype` and `self-hosted-oss`. Accepted tradeoff: matches
  the existing `internal-platform` precedent; the README states the
  single-posture expectation; a graph-level check is the proper long-term fix.
- **Required-artifact over-reach.** Mitigated by requiring only the
  self-hosting guide; risk register is optional (review-gated by criticality).

## Open Questions Resolved

- **Conflicts?** → `conflictsWith: []` (internal-platform precedent), with
  single-posture guidance in the README.
- **Required artifacts?** → one (`self-hosting-guide.md`); risk register and
  release intent optional, reusing existing templates. Keeps the posture
  "fewer and different, not absent."

## Versioning Implications

Module ships at `1.0.0`. Counts bump within the v0.5.2 batch. Release marker:
**v0.5.2**.
