<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0015: Add `delivery/managed-fleet` Posture

**Status:** Accepted
**Date:** 2026-05-25
**Author:** @unclenate
**Reviewers:** @unclenate
**Context sources:**

- `docs/superpowers/specs/2026-05-25-managed-fleet-delivery-posture-design.md` — the design
- Brownfield onboarding of `an IaC fleet repo` (an Ansible IaC fleet repo) surfaced the gap

## Context

The four existing delivery postures all assume the project ships an app or a
distributable. Onboarding `the-IaC-fleet-repo` — an Ansible repo that operates a
live 8-host fleet but ships no product of its own — had no good fit:

- `prototype` waives operational burden a live fleet cannot waive.
- `production-saas`'s required artifacts describe releasing *software* (environment
  inventory, release/rollback of a deployed product), not *applying config to hosts*.
- `internal-platform` is closest but mandates no operational artifacts (only
  dependency-log + milestones).
- `self-hosted-oss` is for a distributable a downstream user operates; here the team
  operates the fleet.

## Decision

Add `delivery/managed-fleet`: a production-grade posture oriented to config applied to a
fleet, requiring `docs/ops/fleet-inventory.md`, `docs/ops/change-control.md`, and
`docs/ops/config-rollback.md`. It hard-conflicts with `prototype` only; the single-posture
expectation is documented (matching `internal-platform`/`self-hosted-oss`). Its companion
rule fires on fleet-topology changes (inventory host files, `host_vars/`) rather than every
role edit, to stay low-noise in an active IaC repo. A risk register is optional but expected
at criticality ≥ medium.

## Consequences

- `HARNESS.md` Active Modules is NOT updated: it lists modules auto-harness activates in its
  own manifest, and auto-harness does not adopt managed-fleet. This is a deliberate deviation
  from the generic "propagate new module to all catalog docs" reflex — managed-fleet is a
  catalog addition, not a self-adoption.
- The catalog-counts validator's documented module/template counts are updated in the same change.
- The propagation pass also corrects pre-existing drift: the `harness-onboarding` SKILL.md
  claimed `internal-platform` has no required artifacts (it requires two), and README.md's
  delivery row omitted `self-hosted-oss`.
- Follow-up (not in this change): extend `validate-catalog-counts.sh` (or a new check) to diff
  SKILL.md prose required-artifact claims against `module.yaml`, so this drift class is caught
  structurally. Logged as a G2/maintenance item.
