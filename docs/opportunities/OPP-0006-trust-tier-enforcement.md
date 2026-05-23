<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0006 — Trust-Tier Enforcement (Doctrine → Machinery)

**Status:** exploring
**Owner:** @unclenate
**Created:** 2026-05-23
**Last Updated:** 2026-05-23 *(promoted to exploring; PRD-0006 drafted same day)*
**Confidence:** high

---

## Thesis

The trust-tier model
([`platform/core/kernel/base/trust-model.md`](../../platform/core/kernel/base/trust-model.md))
defines six tiers of agent autonomy (0: read-only → 5: remote /
production) with explicit kernel rules: *agents may not self-elevate*,
*Tier 4 requires explicit human direction*, *Tier 5 requires second-
human sign-off*. The trust tier is **the harness's most-cited safety
mechanism** — referenced from every agent pack's README, embedded in
the PR template's manual checkboxes, named in operating-principles,
and documented as the foundational guarantee in trust-model.md.

**Zero machinery enforces any of this.** Tier classifications are
prose. The PR template has manual checkboxes. No `module.yaml` field
declares tier. No validator catches tier escalation. No skill
guidance is tier-aware in a checkable way. The harness's most
load-bearing claim runs on honor code.

The 2026-05-23 audit (synthesized in observation
*"Doctrine in prose without enforcement in code is a recurring harness
gap pattern"*) named this as the audit's #1 critical finding. This
OPP captures the gap and scopes the response.

## Origin / Evidence

- **2026-05-23 audit synthesis** — explicit identification of
  trust-tier enforcement as the highest-priority Wave 3 work:
  > "Trust tier model... is doctrine in kernel/base/trust-model.md.
  > It's referenced in every agent module's README, embedded in the
  > PR template, and stated as law. But no code enforces it. ...
  > The trust tier is the core safety guard for AI agents. A Tier 5
  > operation (production deployment) should *never* happen because a
  > validator was skipped or disabled. Yet there's no mechanism to
  > enforce tier declarations."
  > — 2026-05-23 audit synthesis (the audit lived as an inline
  > analysis in PR-context; findings were synthesized into
  > observation form in `docs/knowledge/shared-observations.md`
  > rather than saved as a separate audit document).

- **Observation:** [`docs/knowledge/shared-observations.md`](../knowledge/shared-observations.md)
  *"Doctrine in prose without enforcement in code is a recurring
  harness gap pattern"* (2026-05-23, architectural severity).
  Generalizes from four instances — *trust-tier enforcement* listed
  as the foremost — and recommends prioritizing machinery-of-claim
  over additional prose documentation.

- **Mechanical confirmation:**
  - `grep -rE "trustTier|trust_tier|tier:" platform/profiles/**/module.yaml` returns nothing — no schema field exists.
  - PR template (`.github/PULL_REQUEST_TEMPLATE.md`) has unchecked manual checkboxes for "Tier 4 (environment-altering)" / "Tier 5 (remote / production)" — purely advisory.
  - All eight validators run without any tier awareness.
  - Agent packs reference tiers in prose only (e.g., `platform/agents/cursor/README.md` says "Maps Auto-Run allowlist to harness trust tiers" but the mapping is prose, not config).

- **Adversary model evidence:** `docs/threat-model.md` (Wave 2)
  explicitly calls out the gap under adversary model A5 (compromised
  AI agent): *"No machine-checked trust-tier enforcement... An agent
  that **chooses** to perform a Tier 4 action is caught only by the
  maintainer reviewing the PR. Closing this gap is highest-priority
  Wave 3 work."*

- **Genre fit:** Per [[project_harness_genre]] memory and the
  *governance-harness* identity documented in
  `docs/knowledge/shared-observations.md`, auto-harness's
  differentiation from runtime harnesses (Hive, LangGraph, CrewAI)
  is precisely the gating discipline. Letting the gating discipline
  run on honor code undermines the differentiation.

## Why Now

- **v0.5.0 just shipped** (Wave 3-A). The release-and-versioning
  policy from Wave 2 explicitly lists *trust-tier enforcement gap is
  deliberate pre-1.0 scope*. Addressing this is on the v1.0 path.

- **Documentation expansion is largely done.** Waves 1 and 2 + the
  small Wave 3-B bundle have closed the documentation gaps that were
  filling the "low-hanging fruit" backlog. Remaining work is
  machinery, and tier-enforcement is the largest single item.

- **Cost of further delay scales.** Each new agent pack added without
  tier-aware schema (Cursor pack v0.1.0, Copilot pack v0.1.0, Gemini
  pack v0.1.0, Codex pack v0.1.0 — all current) accumulates more
  surface that will need retrofitting. Closing the gap before more
  agent packs land is cheaper than closing it after.

- **Catalog count validator + sample CI shipped first.** The audit's
  "drift bounded by validators" insight (PR #41) gives us safety net
  infrastructure to add a `validate-trust-tier.sh` script with
  confidence the rest of the chain catches its own drift.

## Risks / Open Questions

### Risks

- **Over-scoping invites paralysis.** Tier enforcement touches: module
  schema, validator chain, agent packs, PR template, skill content,
  CI workflow, kernel doctrine. Easy to spec a Big Bang change that
  never ships. v1 must be scope-disciplined — establish the floor,
  iterate.

- **Backward compatibility.** Existing modules and agent packs have no
  tier declarations. Adding a required schema field would break every
  consumer manifest. Strategies: (a) tier is *optional* at v1 with
  default-tier inference from module type; (b) tier is required only
  for new modules added post-v0.6.

- **Validator complexity creep.** A naive validator that just checks
  "is the tier field present" is low-value. A useful validator must
  understand *tier-coherence*: an agent pack declaring max-tier-3
  cannot adapt a module that declares trigger paths requiring tier 4.
  Tier-coherence requires graph analysis (similar to `module-graph`)
  and may need its own schema vocabulary.

- **False sense of security.** Even with a validator, the *enforcement
  surface* is at PR time. An agent that just *does* a Tier 4 action
  during a session (modifying env vars, installing deps locally,
  pushing to a non-protected branch) isn't caught by any
  PR-boundary validator. v1 should be honest about what's enforced
  and what remains honor-code, vs. claiming complete coverage.

- **Coupling to AI client config.** Some agent clients (Claude Code
  settings.json, Cursor allowlists, Copilot CLI config) have their
  own permission models. Tier enforcement that ignores those models
  may produce conflicting signals. Strategies: declare tier-to-client
  mappings in the agent-pack module YAMLs; the validator asserts
  consistency without dictating one or the other.

### Open Questions

- **Schema location.** Does `tier` live as a top-level `module.yaml`
  field, as a per-rule field on companion rules, or as a per-trigger-
  path attribute? Different placements give different enforcement
  semantics.

- **Required vs. optional at v1.** If required, breaking change ⇒
  v1.0.0 of every existing module. If optional, the validator skips
  modules without declarations ⇒ enforcement gap stays open for
  legacy modules.

- **Inference vs. declaration.** Can tier be inferred from artifact
  patterns? E.g., a module that has companion rules on
  `^src/migrations/` is probably Tier 4. Inferred tiers are
  retroactively applicable to existing modules; declared tiers
  require migration work.

- **Cross-module tier propagation.** If module A has Tier 4 rules and
  module B's companion rules trigger A's, does B's effective tier
  rise? This is a transitive-closure problem similar to
  `dependsOn` graph analysis.

- **PR-level enforcement vs. session-level enforcement.** PR-time
  enforcement is feasible (a validator can run). Session-level (an
  agent attempting a Tier-4 action *during* coding) requires
  client-side hooks. Are both in scope for v1?

- **Tier-tagged commits.** A commit could be tagged with the highest
  tier its changes touch. The validator asserts the commit's tag
  matches the contents. This is the *most enforceable* but also the
  most ergonomically costly (manual tier tagging on every commit).

- **What about the PR template's manual checkboxes?** Keep, evolve
  into auto-fill from the validator, or retire? They're the only
  current surface; removing without replacement is regression.

### Design Options Under Consideration

| Option | Mechanism | Friction | Coverage | New machinery |
|--------|-----------|----------|----------|---------------|
| **A — Optional schema + validator-coherence-check** | New optional `tier` field on `module.yaml`; new `validate-trust-tier.sh` checks coherence when present, skips otherwise | Low (opt-in); legacy modules unaffected | New modules only at v1 | Schema field + 1 validator |
| **B — Required schema + retrofit migration** | `tier` becomes required; one-time PR retrofits all existing modules | High (breaking change; all consumer manifests need updating) | All modules from v1 | Schema + validator + migration script |
| **C — Inferred tier with override** | Validator infers tier from artifact patterns; modules can override via optional field | Low-medium (mostly automatic) | All modules; legacy via inference | Inference engine + validator + optional schema |
| **D — Companion-rule level tier** | `tier` lives on each `companionRule`, not the module — finer-grained but more declarations needed | Medium | Tier-aware rules; tier-unaware rules ignored | Schema + validator |
| **E — Hybrid: A + path-pattern inference for sensitivePaths** | Optional tier on module; inference on `sensitivePaths` regexes as fallback; validator combines both | Medium | Good coverage; clean migration | Schema + inference + validator |

**Initial bias (subject to PRD validation): E — Hybrid.**

The Hybrid path:

- Adds an optional `tier` field on `module.yaml` (additive, no
  breaking change)
- Infers tier from `sensitivePaths` patterns for modules without an
  explicit declaration (e.g., paths matching `^src/migrations/`,
  `^deploy/`, `^infra/` → Tier 4 or 5)
- Ships `validate-trust-tier.sh` that asserts (a) declared tier ≥
  inferred tier (no under-declaration), (b) agent-pack max-tier ≥ any
  active module's tier, (c) `sensitivePaths` matching production-shape
  regexes carry tier ≥ 4
- Updates `harness-governance` SKILL.md with the new tier-aware
  guidance
- Keeps the PR template's manual checkboxes initially, then auto-fills
  them from validator output in a v0.7 follow-up

This option preserves backward compatibility (existing modules ship
unchanged), adds enforcement immediately for the high-risk path
patterns (Tier 4/5 inference catches the dangerous cases), and scopes
v1 small enough to actually ship.

## Disposition

**2026-05-23 (proposed → exploring):** Same-day flip per established
maintainer-priority cadence (audit's #1 finding; named explicitly in
the doctrine-without-enforcement observation; threat-model.md A5
mitigation gap). Direction set on **Option E (Hybrid)** from the five
candidates in the OPP. PRD-0006 drafted same day with the v1 scope
specified.

The "doctrine-without-enforcement" pattern observation (PR #42)
predicted that pursuing trust-tier enforcement would surface
additional gap candidates as a side effect — that hypothesis is now
testable, with this OPP/PRD pair the first instance.

## Promotion

- See [PRD-0006](../requirements/PRD-0006-trust-tier-enforcement.md) —
  drafted 2026-05-23; status `Proposed` (acceptance contingent on
  landing the v1 implementation: optional `tier` field + inference
  for sensitivePaths + `validate-trust-tier.sh` + skill update).
