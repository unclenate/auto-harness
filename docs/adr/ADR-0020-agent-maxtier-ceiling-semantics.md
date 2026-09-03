<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0020: Agent `maxTier` is an Upper Ceiling (Caps, Never Grants)

**Status:** Accepted
**Date:** 2026-09-03
**Author:** @unclenate
**Reviewers:** @unclenate
**Context sources:**

- `platform/core/kernel/base/trust-model.md` — the Agent-pack ceiling rule
- `platform/validators/validate-trust-tier.sh` — the enforcement
- `docs/project/change-log.md` (2026-09-02, audit PR-3) — where the finding
  (AH-ADV-04) was recorded and deferred as "a semantic decision"
- PRD-0006 / ADR-0017 Wave 5.1 — the original trust-tier enforcement this
  amends

## Context

`validate-trust-tier.sh` (PRD-0006) validated each active agent module's
`maxTier` by asserting `maxTier >= max_active_tier` — the highest declared or
inferred tier of any active **non-agent** module — and treated a shortfall as a
hard violation ("an under-capacity agent paired with a higher-tier workload is a
misconfiguration").

The 2026-09-01 adversarial audit (finding AH-ADV-04) flagged this as an
inversion, and the audit-PR-3 remediation deferred it explicitly as a semantic
decision rather than patch it under time pressure.

The name — `maxTier`, "ceiling" — denotes an **upper bound**. The harness's own
inter-agent bus encodes the same concept as `tier_ceiling` and describes it as
"**caps but never grants**." But the validator asserted the opposite relation: a
**lower** bound (`maxTier >=` the workload). The two readings collide.

The collision has a concrete, harmful consequence. The harness's own kernel
(`kernel/base`) declares tier 5 (it governs CI workflows and governance
entrypoints), so on the harness's own manifest `max_active_tier == 5`. Under the
old rule an agent could only pass by declaring `maxTier: 5` — the **maximum**
possible autonomy ceiling. All three shipped agent packs (`agents/base`,
`agents/generic-llm`, `agents/openclaw`) do exactly that (`tier.declared: 2,
maxTier: 5`), not because tier-5 autonomy is intended but because anything lower
**failed the check**. An operator who wanted a genuinely restricted agent —
`maxTier: 2`, "may not git-write autonomously" — could not express it without
tripping a validation error. The rule made the least-privilege choice fail and
pressured every agent to the maximum ceiling: the exact inverse of what a
ceiling is for.

## Decision

`maxTier` is an **upper ceiling on the agent's autonomous reach**. It **caps but
never grants**: the per-tier human-authorization gates at Tier 4 and Tier 5
apply independently of the ceiling and are never satisfied by declaring a high
one. The ceiling constrains how far an agent proceeds *without* a human; it does
not confer authority.

`validate-trust-tier.sh` now asserts, for each active agent module:

1. `maxTier` is an integer in range `0..5` (unchanged).
2. `maxTier` is **not below the agent's own `tier.declared`** baseline — a
   ceiling cannot sit beneath the tier the agent routinely operates at
   (a new, genuinely ceiling-shaped coherence check).

A missing `maxTier` remains a **warning** (the ceiling is unbounded and the
check cannot run) — unchanged from the audit-PR-3 fix.

A `maxTier` **below** the manifest's highest non-agent tier is **no longer a
violation**. It is a valid least-privilege configuration: that higher-tier work
simply defers to the human-authorization gate (which Tier 4/5 require
regardless). The validator emits an **informational note** so the deferral is
visible, and exits `0` on that account.

The decision logic is centralized as a pure, unit-tested helper
`HarnessRegistry.agent_maxtier_status(max_tier, declared_tier)` returning `:ok`
/ `:out_of_range` / `:below_declared`, so the corrected semantics are covered by
fixture-free unit tests (the validator itself is platform-root-fixed and not
directly fixture-testable — a constraint PRD-0006 already records).

No shipped agent module changes: `maxTier: 5, tier.declared: 2` remains coherent
(`5 >= 2`, and `5` is not below the workload, so no note fires). The change is
non-breaking for the harness's own manifest.

## Alternatives considered

**Keep the floor, rename it honestly.** Treat the check as a *capability
adequacy* floor ("the agent must be permitted to perform the highest-tier work
the manifest declares") and simply stop calling it a ceiling. Rejected: it
contradicts the word `maxTier` and the harness's own `tier_ceiling`
caps-never-grants doctrine, and it preserves the least-privilege inversion —
an operator still could not declare a restricted agent. "Capability adequacy"
is not a governance property the harness needs to assert: under-capacity is not
a safety failure, because the shortfall is covered by the human gate, which is
strictly *more* conservative.

**Delete the maxTier check entirely.** Rejected: it would leave `maxTier` with
no assertion beyond range, and drop the genuinely ceiling-shaped coherence
property (a ceiling below the agent's own baseline is incoherent).

**Add "high ceiling requires rationale" (mirroring `tier.declared >= 3`).**
Considered and deferred. A ceiling reaching the human-gated tiers is arguably
worth a written justification, but adding it now would retrofit rationales onto
the three shipped packs and mix a new *policy* into an *inversion* fix. Tracked
as a possible follow-on; this ADR keeps the change scoped to correcting the
direction of the existing check.

## Consequences

**Positive:**

- Least-privilege becomes expressible: an operator can declare a restricted
  agent (`maxTier: 2`) on a high-tier manifest without a validation error.
- The validator's `maxTier` semantics now match its name, the model doc, and
  the harness's own `tier_ceiling` caps-never-grants doctrine — one coherent
  concept across the codebase.
- The new `maxTier >= tier.declared` check is a real ceiling property, replacing
  a check that asserted the inverse.
- The informational note makes the human-gate deferral visible rather than
  silent.

**Negative / costs:**

- The shipped agent packs keep `maxTier: 5` (non-breaking), so the visible
  least-privilege benefit accrues to future/consumer agents, not the harness's
  own manifest today. Whether to lower the shipped packs' ceilings is a separate
  configuration decision, out of scope here.

**Watch:**

- The deferred "high ceiling requires rationale" policy: if broad agent ceilings
  proliferate without justification, revisit it as its own change.
- Cross-client allowlist reconciliation (whether the actual AI-client config
  honors the declared ceiling) remains deferred per PRD-0006 v2+; the ceiling is
  still a *declaration*, not a runtime enforcement.

## References

- `platform/core/kernel/base/trust-model.md` — Agent-pack ceiling rule (updated
  by this ADR)
- `platform/validators/validate-trust-tier.sh` — enforcement
- [ADR-0017: Safety Hardening Roadmap](ADR-0017-safety-hardening-roadmap.md) —
  the trust-tier enforcement track this amends
- `docs/knowledge/shared-observations.md` — the distilled lesson (a "ceiling"
  that asserts a lower bound is a least-privilege inversion; name and check must
  agree)
