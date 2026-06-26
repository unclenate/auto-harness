<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0050 — Module Stability Tiers & Parity Normalization

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-06-26
**Last Updated:** 2026-06-26 *(filed)*
**Confidence:** high *(the gap is field-verified: `stability`/`maturity` in 0/57 modules)*

---

## Thesis

The catalog has **uniform structural metadata** (`version`, `summary`,
`conflictsWith`, `validators`, `companionRules`, `reviewGates` in **57/57**
module.yaml files) and real **anti-sprawl discipline** (the § 12 inclusion test
gates *whether* a deep vertical exists; the candidate-stub-with-promotion-criterion
discipline gates *whether* an OPP is filed). What it has **no signal for is module
readiness** — how battle-tested a given module is. A consumer composing a manifest
cannot tell that `management/privacy-by-design` (dedicated validator, shipped,
dogfooded) is more proven than a one-off stack overlay or a thin management module.
`stability` / `maturity` is present in **0/57** modules.

Trust tier (0–5) and § 10 claim-classification are real and adjacent but answer
**different questions** — they are not a readiness signal:

- **Trust tier** = *risk / autonomy* (how much human authorization an action needs).
- **§ 10 classification** = *per-claim enforcement strength* (Enforced /
  Half-enforced / Asserted-only).
- **Stability** (this OPP) = *how proven the module itself is* (experimental / beta /
  stable). A module can be high-tier **and** experimental (powerful but new), or
  low-tier **and** stable. The axes are independent.

Introduce a per-module **`stability: {experimental | beta | stable}`** field,
backfill it across all 57 modules in one audit pass, surface it in the onboarding
catalog (+ an honest stack-parity note), and assert it with a light validator. This
**extends § 10's honesty doctrine from *claims* to *modules*** and makes the
platform's blanket "alpha" self-description (`harness.manifest.yaml: maturity:
platform`) **granular and honest** — kernel and the shipped overlays are `stable`;
a single-consumer experiment is `experimental` — instead of one caveat over
everything.

## Origin / Evidence

- **External leadership review (Claude/ChatGPT lane, 2026-06-26).** An outside-in
  platform-architecture review flagged *"module depth and enforcement maturity may
  not be consistent across overlays"* and a risk of *"expansion without enough
  normalization, parity, and ergonomic control."* Evaluated against the actual
  repo, **most of the review was already solved** — required metadata is uniform
  (57/57), compatibility declarations exist (`dependsOn` + `conflictsWith`,
  enforced by `validate-module-graph`), composition is governed (§ 12's three
  shapes + `compositions/`), and a new-module-justification gate exists (the § 12
  inclusion test). The review was a generic template applied without seeing those
  controls.
- **The narrow gap it surfaced is real and field-verified.** A direct audit of the
  57 module.yaml files:
  - `stability` / `maturity` field: **0/57** — no module-readiness signal at all.
  - Explicit trust-tier declaration: **10/57** (the rest infer from
    `sensitivePaths` — by design, but it means readiness and risk are both mostly
    implicit).
  - **Stack parity skew:** `stacks/` = `coffeescript`, `node-javascript`,
    `node-typescript`, `python` — **3 of 4 are JS-family**; PHP/Go/Ruby/Rust/Java
    absent (`OPP-0011` PHP is proposed-not-built). Real, localized to `stacks/`
    (architectures/data/domains are stack-agnostic).
- **This is the distilled, surviving 10%** of a review that was ~70%
  already-built and ~20% overstated. Filing it as its own OPP keeps the real signal
  from being lost in the noise of the parts that were already done.

## Why Now

- **The unevenness is real and growing but invisible.** 57 modules across 8
  families; deep verticals enforce via companion-rules, overlays add dedicated
  validators, some management modules are thin. That spread is partly *correct*
  (§ 12 says domains enforce via companion rules, overlays add validators) — but it
  is currently *implicit*. Make it legible before the catalog is larger.
- **Honest self-description.** The platform calls itself alpha. Module-level
  stability turns a blanket caveat into a precise, queryable claim — a § 5
  Self-Governance win.
- **It is the real prerequisite for the multi-agent dispatch the review wanted.**
  Backfilling one field across 57 files is a *perfect* `work-package` / Codex task
  — **once the schema is decided.** The schema decision is centralized (Claude
  lane); the backfill is dispatchable. This OPP is the centralized half.

## Risks / Open Questions

- **Field name.** `maturity` collides with the manifest-level `maturity: platform`
  and the digital-twin consumer twin-maturity. **Bias: `stability`** (conventional —
  npm / Node stability index / Rust feature stability; no collision; reads as
  module-readiness). Alternative: `readiness`.
- **Enum values.** **Bias: `experimental | beta | stable`**, with `deprecated`
  reserved to seed (not build) the lifecycle concern below. Resolve at PRD.
- **Declared vs inferred.** Stability *could* be inferred (has-dedicated-validator +
  is-dogfooded + age). **Bias: declared**, with authoring guidance — honesty is an
  authoring act (as § 10 classification is), and auto-inference would launder
  unearned confidence. The validator checks *presence + enum membership*, not
  *correctness of the judgment*.
- **Validator posture.** **Bias: assert the field is present and from the enum
  (BLOCK on missing/malformed)**; do **not** gate behavior on it in v1 (no "warn
  when a consumer activates an `experimental` module"). Behavior-gating is a
  deferred follow-up.
- **Stack parity — surface, don't solve.** Per § 7 (Align File Boundaries with
  Change-Class Boundaries), the *honest documentation* of the JS-skew belongs with
  this OPP's surfacing work; a *program to build PHP/Go/etc.* is `OPP-0011`/`OPP-0012`
  territory. Bundle only the parity **note**, not the parity build-out.
- **Deprecation / lifecycle policy — separate change-class.** The review also wanted
  a module deprecation policy. That is *process*, not *metadata*; bundling it would
  mix change-classes. A `deprecated` enum value seeds it, but the policy itself is a
  follow-up OPP.
- **Backfill judgment.** Assigning `experimental | beta | stable` to 57 existing
  modules is a judgment call per module; the PRD should give a rubric (e.g.,
  `stable` = shipped + has enforcement + ≥1 dogfood or consumer instance; `beta` =
  shipped, enforcement thin or single-instance; `experimental` = scaffold / single
  speculative consumer) so the backfill is mechanical against the rubric.

## Disposition

**Proposed (2026-06-26).** Design-only per § 9; no PRD this commit (the promoting
PR carries the PRD). Filed as the distilled, field-verified signal from the
2026-06-26 external leadership review — recorded honestly: the review's broad
"normalize the framework" thesis was largely already met, and this is the one
structural gap that survived contact with the files.

**V1 scope-bias** (to be ratified at PRD): the `stability` field, a rubric-driven
57-module backfill audit, an enum-presence validator, onboarding-catalog surfacing,
and one honest stack-parity note. **Deferred:** behavior-gating on stability, a full
module deprecation / lifecycle policy, and any stack build-out.

## Related

- Operating principles: [§ 10](../operating-principles.md#10-classify-claims-before-enforcing-them)
  (classify *claims* — this classifies *modules*); [§ 9](../operating-principles.md#9-split-design-from-implementation)
  (this OPP is design-only); [§ 5](../operating-principles.md#5-self-governance)
  (honest self-description); [§ 12](../operating-principles.md#12-author-deep-governance-verticals-from-the-shared-skeleton)
  (the inclusion test gates *whether* a vertical exists; stability gates *how ready*
  any module is — complementary).
- Stack-parity build-out (separate change-class): `OPP-0011` (PHP stack),
  `OPP-0012` (generalize `data/relational-postgres`).
- Sibling normalization concern: the **design-artifact-staleness** candidate stub
  (`candidates.md`) — both are "make an implicit quality signal legible."
- Multi-agent dispatch substrate (how the backfill ships once schema is set):
  `management/work-package` ([PRD-0025](../requirements/PRD-0025-work-package-lane-contract.md)).
