<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0021: Greenfield Onboarding Conservatism — Route Contextless Greenfield to Discovery

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-07 | **Review Cycle:** On-change

**Status:** Accepted *(v1 shipped in the same PR — skill-guidance change)*
**Date:** 2026-06-07
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Originating OPP: [OPP-0042 — Greenfield Onboarding Conservatism](../opportunities/OPP-0042-greenfield-onboarding-conservatism.md)
- Sibling shipped work: [PRD-0020 — Bootstrap Hardening](PRD-0020-bootstrap-hardening-guards-and-preflight.md) (instantiation-location guards)
- Affected surface: [`platform/skills/harness-onboarding/SKILL.md`](../../platform/skills/harness-onboarding/SKILL.md)

## Overview

The `harness-onboarding` skill's "conservative module selection" rule is
*brownfield-shaped*: its notion of evidence is "files present in the repo," which
is empty for a greenfield project. So from a one-line description ("a portfolio
site for me") the skill asserted `node-typescript` + `web-app` as active modules,
authored a full `docs/` tree, and re-enabled `required-artifacts` — before any
code existed, while its own generated comments admitted it was inferring intent.

This PRD adds an explicit **greenfield mode** to the skill: a contextless or
near-empty repo routes to a **discovery posture** rather than a guessed,
enforcement-on composition. A verbal description is treated as **intent, not
evidence**; code-dependent modules and `required-artifacts` are deferred until
real repo evidence appears.

## Goals & Non-Goals

**Goals**

- Make the skill recognize greenfield (no code *and* no governance docs) as a
  distinct mode alongside doc-only and standard brownfield.
- Treat an operator's verbal description as intent, never as evidence for a
  stack/architecture/data module.
- Route greenfield to a discovery baseline (`management/discovery-intake` or the
  `new-product-discovery` / `interview-driven-discovery` compositions); keep
  `required-artifacts` disabled until code evidence lands.
- Record intended-but-unevidenced modules as `# intent:` comments, not active modules.

**Non-Goals**

- **A first-class `intent:` manifest schema field** — *(deferred: the OPP's open
  question; v1 uses commented `# intent:` lines. Revisit if the comment convention
  proves insufficient.)*
- **A mechanical validator for greenfield over-assertion** — *(excluded: onboarding
  is AI-judgment work; the skill instruction is the right lever. Classified
  Half-enforced below.)*
- **Changing `install.sh`'s default composition** — *(excluded: `brownfield-lite`
  already ships with `required-artifacts` disabled; the over-assertion came from the
  skill, not the script.)*

## §10 Claim Classification

| Claim | Classification |
|-------|----------------|
| The skill routes contextless greenfield to discovery, not a guessed enforced composition | **Half-enforced** (skill instruction; agent-followed, not mechanically gated) |
| A verbal description is not used as evidence for code-dependent modules | **Half-enforced** (skill instruction) |
| `required-artifacts` stays disabled for greenfield until code lands | **Half-enforced** (skill instruction; the validator itself is honored once enabled) |

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Onboarding agent | Claude/other agent running `harness-onboarding` on a new repo | An explicit greenfield rule so it routes to discovery instead of inventing a stack |
| Solo founder (greenfield) | "Vibecoding an MVP" from an idea | A conservative starting manifest, not day-zero artifact debt |

## User Stories

- As an onboarding agent, I want a defined greenfield mode, so that I don't assert a full enforced module set from a one-sentence description.
- As a solo founder, I want onboarding to ask a couple of scoping questions rather than guess my stack, so that my manifest reflects reality.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | Greenfield mode in Constraints | SKILL.md Constraints gains a "Greenfield = discovery, not composition" rule: description is intent not evidence; route to discovery; keep `required-artifacts` disabled; record intent as comments. | Names the inverse-of-brownfield default. |
| FR-002 | Mode determination names three cases | SKILL.md Step 1 distinguishes greenfield / doc-only brownfield / standard brownfield, with greenfield = no docs *and* no code. | Extends the prior two-case text. |
| FR-003 | Step 2 greenfield routing | SKILL.md Step 2 instructs: greenfield → `core/kernel/base` + discovery baseline only; code-dependent families listed as `# intent:`; `disabledValidations: [required-artifacts]` retained until evidence; re-run on first code. | The concrete composition output. |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| `intent:` manifest schema field | v1 uses comments | If comments prove insufficient |
| Greenfield over-assertion validator | AI-judgment surface | If a mechanical check becomes feasible |

## Success Metrics

| Metric | Target | Source |
|--------|--------|--------|
| Greenfield named as a distinct mode in the skill | Yes | SKILL.md Step 1 |
| Greenfield routes to discovery with `required-artifacts` deferred | Yes | SKILL.md Constraints + Step 2 |

## Open Questions

- Does the `# intent:` comment convention need to become a structured manifest
  field for tooling to read it later? Deferred to a follow-up if a consumer needs
  machine-readable intent.

## Acceptance Criteria for OPP-0042 → `accepted`

OPP-0042 flips to `accepted` in this PR with this PRD in its Promotion field when
FR-001–FR-003 ship in `platform/skills/harness-onboarding/SKILL.md`.
