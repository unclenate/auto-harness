<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0030: Agent Defense-in-Depth (Four Patterns) — `architectures/agent-defense-in-depth`

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-27 | **Review Cycle:** On-change

**Status:** Accepted *(design-only per § 9; the implementing PR ships the module + templates)*
**Date:** 2026-06-27 (filed + accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Promoting OPP: [OPP-0031](../opportunities/OPP-0031-agent-defense-in-depth.md) — `proposed` at filing; this PRD ratifies its v1 and flips it `proposed → exploring`. OPP-0031 flips `exploring → accepted` at implementation-merge.
- Anchor OPP: [OPP-0027](../opportunities/OPP-0027-frontier-agent-posture.md) — the frontier-agent posture umbrella this module is a satellite of.
- Sibling satellites: [OPP-0029](../opportunities/OPP-0029-agent-observability.md) (`architectures/agent-observability` — **shipped**; identity-bound traces are the runtime-emitted half of pattern #4), [OPP-0030](../opportunities/OPP-0030-intelligent-model-routing.md) (routing decisions are identity-bound; designed in parallel — see [PRD-0029](PRD-0029-intelligent-model-routing.md)), [OPP-0028](../opportunities/OPP-0028-ai-foundry-target.md) (`architectures/ai-foundry-target` — **shipped**).
- Domain specialization: [OPP-0022](../opportunities/OPP-0022-patient-facing-health-agent-safety.md) — patient-facing health-agent safety is the *healthcare-specific instantiation* of patterns #3 (human-in-the-loop) and #4 (identity-bound audit). A healthcare patient-agent adopts **both**: this module as the umbrella + OPP-0022 as the healthcare overlay (same composition shape as `architectures/web-app` + `delivery/production-saas`).
- Orthogonal-but-composable: [OPP-0006](../opportunities/OPP-0006-trust-tier-enforcement.md) trust-tier — trust-tier says *what the agent is allowed to do*; defense-in-depth says *how the agent structures itself to exercise those permissions safely*. Tier-independent; the patterns apply at any tier.
- Upstream design source: Microsoft's May 2026 *Defense in depth for autonomous AI agents* — an external, stable, vendor-published four-pattern set (no fragile version to pin).
- Related operating-principles: § 9 (Split Design from Implementation), § 10 (the new module declares `stability`; the defense-in-depth claim classifies Half-enforced at v1), § 7 (the pre-LLM transport gate is a distinct change-class, named not built).

## Overview

Microsoft's *Defense in depth for autonomous AI agents* names **four mutually-reinforcing
patterns** every autonomous agent should adopt:

1. **Agents as microservices** — scope-contained; one agent, one job; each writes only
   to its own cache.
2. **Least permissions** — each agent granted the minimum capability set for its task.
3. **Deterministic human-in-the-loop** on consequential actions — draft, never
   auto-execute, anything with material consequence (a portal message, a financial
   transaction, a code merge to main).
4. **Agent identity** — every action attributable to a named agent. *Identity makes all
   of it auditable.*

The patterns are **generalizable** — they apply to any autonomous agent in any domain,
regulated or not (code-writing agents, support agents, research agents, ops agents).
Auto-harness has no module capturing this surface: OPP-0022 covers the
*healthcare-specific* slice of pattern #3 (draft-never-send for portal messages); the
broader four-pattern umbrella is unaddressed. The trust-tier model (OPP-0006) and kernel
doctrine are *governance* surfaces; this is an *agent-architecture* surface — they
compose.

This PRD specifies a v1 **opt-in `architectures/agent-defense-in-depth` module**. Like
its shipped siblings (`agent-observability`, `ai-foundry-target`), **v1 is declarative —
no companion rule, no validator** (enforcement is the v2 follow-up). It requires:

1. **`docs/security/agent-defense-in-depth.md`** (new, scaffolded from a template) — a
   **single artifact with four named sections**, one per pattern: scope-containment
   evidence (per-skill / per-agent capability boundaries), the permission model (what
   each agent can / cannot do), human-in-the-loop checkpoints (which actions are drafts
   vs. autonomous), and identity-binding (how each action is attributed in audit logs).
   A single artifact (not four) avoids the "scaffold four files, fill one" failure mode
   and preserves the unity of the four-pattern model.
2. **`docs/security/append-only-action-log.md`** — **optional** at v1, but
   **required-by-convention when the project declares any autonomous (non-draft)
   action** (enforced as a review gate in v1, since a `module.yaml` cannot express a
   conditional requirement). It declares the operator-owned audit-log shape:
   append-only, identity-tagged, snapshot-able. This is the **audit-substantiation of
   pattern #4** — without it, pattern #4 is prose without enforcement. Because it is
   load-bearing (not a mere advanced extra), the implementing PR ships a **template for
   it as well**.

## Goals & Non-Goals

**Goals:**

- Ship `platform/profiles/architectures/agent-defense-in-depth/{module.yaml,README.md}` —
  `type: architecture`, `stability: beta`, `dependsOn: [kernel/base]`,
  `requiredArtifacts: [docs/security/agent-defense-in-depth.md]`,
  `optionalArtifacts: [docs/security/append-only-action-log.md]`, **no companion rules
  in v1**, `validators: [validate-required-artifacts, validate-companions]`, and a
  `reviewGates` entry encoding the conditional-required nuance for the action log.
- Ship **two templates** in the **existing** `templates/security/` subdir (created for
  `sast-coverage.md`; no new subdir, no new list-completeness row):
  `agent-defense-in-depth.md` (four named sections, one per pattern, each with an
  evidence prompt) and `append-only-action-log.md` (the operator-owned log shape:
  append-only · identity-tagged · snapshot-able · secret-scan gate).
- Update the `harness-onboarding` SKILL so the module is offered during onboarding for
  any autonomous-agent project, with its distinct required artifact noted and the
  OPP-0022 healthcare-overlay composition called out.
- Propagation: SUMMARY architectures list, root README module table + tree,
  templates/README (rows under the existing Security area), and the catalog-count prose
  sites. **Counts recompute at implementation** against `main` (as of filing, and
  assuming it lands after PRD-0029: `modules_profiles` 51 → 52, `modules_all` 60 → 61,
  `templates` 96 → 98 for the two new templates — recompute against actual `main` at
  impl, since build order may differ).
- One paired distillation observation.

**Non-Goals (deferred):**

- **Companion rule + pattern-specific validators** (e.g. a least-permissions checker
  cross-referencing action code against the declared permission set). v1 ships the
  *contract*; v2 (a future OPP) ships enforcement — same "declare first, enforce later"
  principle as OPP-0006 trust-tier. A declarative overlay has no fixed code path to
  anchor a companion rule on.
- **Four separate artifacts (one per pattern).** Rejected — single artifact with four
  sections preserves the model's unity and avoids partial-fill.
- **The pre-LLM transport gate** (locking inbound mail to a sender allowlist at the
  transport layer before any model sees it). A *defense-before-LLM* pattern adjacent to
  least-permissions but distinct (pre-input sanitization, not a during-action permission
  check). **Named** here as a related concept; a future OPP could capture it as a
  reusable `templates/security/pre-llm-transport-gate.md`. Out of scope per § 7.
- **A new operating-principle section.**

## § 10 Claim Classification

| Claim ID | Claim | Current | After v1 |
|----------|-------|---------|----------|
| C-DID-1 | A project can declare, in catalog-governed form, how it realizes the four defense-in-depth patterns (scope-containment, least-permissions, human-in-the-loop, identity-binding) | Asserted-only (no primitive) | **Half-enforced** — the module + required artifact exist; `validate-required-artifacts` checks the artifact is present when the module is active; the *content* (that the declared permission model matches the code, that the action log is truly append-only) is not yet checked (v2) |
| C-DID-2 | Module readiness is declared | n/a | **Enforced** — `validate-module-stability.sh` requires the new module's `stability: beta` |

**Not converted:** whether the four declared patterns actually hold in the running
agent — that is a v2 enforcement concern; v1 is the declared contract.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001 | `architectures/agent-defense-in-depth` module | `module.yaml` + `README.md` present; `id: agent-defense-in-depth`, `type: architecture`, `version: 1.0.0`, `stability: beta`, `dependsOn: [kernel/base]`, `requiredArtifacts: [docs/security/agent-defense-in-depth.md]`, `optionalArtifacts: [docs/security/append-only-action-log.md]`, `companionRules: []`, `validators: [validate-required-artifacts, validate-companions]`, plus a `reviewGates` entry for the conditional-required action log. Mirrors the shipped siblings' field set. |
| FR-002 | `agent-defense-in-depth.md` template | Tokenized header; four named sections (one per pattern), each with an evidence prompt; an explicit note on the OPP-0022 healthcare composition and the trust-tier (OPP-0006) orthogonality. `<!-- TODO -->` markers; no bracketed placeholder or literal date-stub tokens. Lives in the existing `templates/security/` subdir. |
| FR-003 | `append-only-action-log.md` template | Tokenized header; the operator-owned log shape — append-only, identity-tagged, snapshot-able, with a secret-scan gate; a note that it is required-by-convention when any autonomous (non-draft) action is declared. Lives in `templates/security/`. |
| FR-004 | README | Architecture-overlay README: the four patterns, the required + optional artifacts, the conditional-required action log, the OPP-0022 domain-specialization composition, the OPP-0006 trust-tier orthogonality, the named-not-built pre-LLM transport gate, and the v2-deferred enforcement note. |
| FR-005 | Onboarding surfacing | `harness-onboarding` architectures catalog gains a row with its distinct required artifact (`docs/security/agent-defense-in-depth.md`) and the healthcare-overlay composition note. |
| FR-006 | Propagation + counts | SUMMARY, root README table + tree, templates/README (Security rows). Catalog-count prose sites bumped (recompute at impl). No new template subdir (reuses `templates/security/`). |
| FR-007 | `validate-module-stability` + chain green | The new module declares `stability` and the full validator chain passes. |

### Should Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-S01 | Non-autonomous-product carve-out | The template + README make explicit that a non-autonomous product (a copilot that only ever drafts) can declare pattern #3 as trivially satisfied (everything is a draft) and treat the action log as not-applicable. |

### Out of Scope

| Feature | Reason | Revisit |
|---------|--------|---------|
| Companion rule / pattern-specific validators | v1 declarative; declare-first | v2 follow-up |
| Four separate per-pattern artifacts | partial-fill failure mode | not planned |
| Pre-LLM transport gate template | distinct change-class | own OPP |

## Open Questions Resolved by This PRD

- **Single artifact or four?** → **Single artifact** (`agent-defense-in-depth.md`) with
  four named sections. Avoids the scaffold-four-fill-one failure; preserves the model's
  unity.
- **Enforce the patterns in v1?** → **No** — v1 ships the contract; v2 ships
  pattern-specific validators. Same principle as OPP-0006 (declare first, enforce later).
- **Interaction with trust-tier (OPP-0006)?** → **Orthogonal but composable.** Trust-tier
  = what the agent may do; defense-in-depth = how it structures itself to do it safely.
  Tier-independent.
- **Non-autonomous products?** → **Opt-in**; declare pattern #3 trivially satisfied,
  action log not-applicable. Made explicit (FR-S01).
- **Action log — required or optional in v1?** → **Optional in `module.yaml`,
  required-by-convention via a review gate when any autonomous (non-draft) action is
  declared.** It is the audit-substantiation of pattern #4, so it ships with its own
  template despite being schema-optional.
- **Composition with OPP-0022 in healthcare?** → A healthcare patient-agent adopts
  **both** — this module as the umbrella, OPP-0022 as the healthcare-specific overlay
  (draft-never-send, PHI workspace boundary, indirect-injection resistance).
- **The sender-allowlist transport gate?** → **Named as a related-but-distinct
  pre-LLM pattern**; a future OPP can capture it as a reusable template.

## CI/CD Gates

- Full validator chain (20 validators) green, including `validate-module-stability`
  (the new module declares `stability: beta`) and `validate-required-artifacts`
  (predict-clean — the harness does not activate the module).
- `validate-catalog-counts` green after the count bumps; markdownlint clean.

## Acceptance Criteria for OPP-0031 → `accepted`

OPP-0031 flips `exploring → accepted` when FR-001…FR-007 merge and the harness's own CI
passes. (PRD-0030 Status is `Accepted` on this finalization; the OPP moves to
`exploring` now and `accepted` at implementation-merge.)

## Versioning Implications

Additive: a new opt-in architecture module + two templates, no breaking change. Lands in
the next minor.
