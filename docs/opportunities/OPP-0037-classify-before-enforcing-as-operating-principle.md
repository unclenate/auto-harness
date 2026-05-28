<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0037 — Classify-Before-Enforcing as Operating Principle

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-28
**Last Updated:** 2026-05-28
**Confidence:** medium-high

---

## Thesis

Promote the **claim-vs-enforcement classification** mechanism to a
first-class operating principle alongside §9 (*Split Design from
Implementation*). The provisional wording from the Wave 2b distillation
observation stands as the seed:

> **Classify-before-enforcing.** Every load-bearing claim a framework
> makes about its own behavior or contract integrity is either
> *Enforced* (a validator catches violations), *Half-enforced*
> (partially structurally checked), or *Asserted-only* (claimed in
> prose, not checked anywhere in code). Ship the classification
> *before* shipping the validators; the classification IS the
> next-phase roadmap. The Asserted-only cluster is the safety debt;
> the Half-enforced cluster is the upgrade-path candidate set; the
> Enforced cluster is what the framework can currently defend.

The mechanism has been documented four times in 2026-05-27/28 — the §9
three-instance bar (set by the deferred-implementations promotion path)
is exceeded. The pattern is empirically generalizable and ripe for
codification.

**This OPP ships the design contract only.** Per §9, the actual
operating-principles edit (adding the new section) is the
implementation follow-up — captured in this OPP's Disposition once the
OPP is accepted, landed via a separate PR that adds the principle
section and updates `docs/operating-principles.md`'s table of contents.

## Origin / Evidence

Four documented instances of the meta-pattern, with three distinct
discovery modes:

1. **Refresh-2 list-completeness audit** (`documentation-audit-2026-05-27/
   refresh-2.md`, audit-driven, narrow scope). The audit enumerated
   canonical-surface lists (ADRs, PRDs, OPPs, compositions,
   template-subdirs, profile-modules) and classified each catalog as
   Asserted (humans maintain it) vs Enforced (a validator checks it).
   Result was the Wave 1 validator that converted six Asserted-only
   catalogs into Enforced ones.
2. **Wave 2b safety-security-sweep** (`safety-security-sweep.md` § 2 —
   "Formal Verification — Claim-vs-Enforcement Map", audit-driven,
   framework-wide scope). The sweep enumerated **19 load-bearing
   claims** and classified each as Enforced / Half-enforced /
   Asserted-only. Result: 9 / 3 / 7. The Asserted-only seven (claims
   10–13, 15, 16) mapped directly to Wave 5's priority order in
   ADR-0017 — the classification's output IS the roadmap. First
   articulation of the principle in
   `shared-observations.md:1886-1971`; provisional title proposed
   there.
3. **Wave 5.1 mechanizing-doctrine discovery**
   (`shared-observations.md:1972-2053`, implementation-driven). The
   PRD-0006 implementation surfaced PRD-internal inconsistencies
   (FR-002 + FR-003 + FR-005 cannot simultaneously hold for the kernel
   module) that the design pass had elided. Honor-code prose can
   carry inconsistency indefinitely because no code ever checks it;
   mechanization is the first time the inconsistency is forced to
   resolve. **Third instance** of the meta-pattern; first instance
   that was implementation-driven (rather than audit-driven). Marked
   in the Wave 5.1 distillation as the §9 three-instance bar
   triggering moment.
4. **Wave 5.5 posture-design reflection**
   (`shared-observations.md:2130-2209`, prospective discovery). Authoring
   the WARN-posture validator surfaced that the *choice of absorption
   mechanism* (fix-on-impl / predict-clean / warn-defer) is itself
   downstream of how the claim was classified. The Wave 5.5
   distillation explicitly names: *"the [[claim-vs-enforcement-
   classification]] meta-pattern's fourth-instance count makes
   operating-principle promotion overdue per §9 three-instance bar."*
   Fourth instance; combines audit-driven and implementation-driven
   modes via a third (posture-driven) mode.

**The §9 codification precedent.** Section 9 ("Split Design from
Implementation") was codified after three explicit instances in one
session (2026-05-26) — PRD-0011, PRD-0013, PRD-0014. The fourth-
instance threshold was deliberately conservative; codifying after
four observed instances (the present OPP's count) follows the same
shape and exceeds the established bar.

**The auto-harness-as-meta-framework story.** Per the Wave 2b
observation's third implication: the classification mechanism is
reusable by consumer projects building their own enforcement layers.
Auto-harness ships the governance contract; consumers can run the same
audit shape against their own honor-code claims. Promoting the
mechanism to operating principle makes that reuse story
operational — instead of "this works for us," the principle becomes
"this is how a framework that claims things should reason about its
own claims."

## Why Now

- **The three-instance bar is exceeded by one.** The §9 three-instance
  bar was set deliberately — three instances rule out single-context
  artifacts and most two-context coincidences. Four documented
  instances in one session is the signal that promotion is overdue,
  not just available.
- **Waves 5.2 and 5.4 benefit from having the principle in place
  *before* they ship.** Both upcoming Wave 5 items are
  structural-enforcement work whose design pass should explicitly
  classify each claim being enforced and name the absorption
  mechanism (per OPP-0036's three-mechanisms framing in
  `feedback-validator-absorption-mechanisms`). Wave 5.2 in particular
  ships an adversarial-corpus design that needs the
  classify-before-enforcing discipline to clarify what's already
  in-scope vs new. Shipping this OPP before Wave 5.2 sets the
  vocabulary the Wave 5.2 PRD will use.
- **The mechanism is currently re-articulated each time it's used.**
  Four distillation observations in `shared-observations.md` cite the
  classification mechanism by name; each cites the *prior*
  observation. Promoting to operating principle creates one canonical
  reference instead of a chain of distillation entries that each
  partially re-derive the framing.
- **Periodic re-evaluation cadence is unclaimed.** Wave 2b's safety
  sweep §13 #3 named "Doctrine-vs-enforcement re-evaluation —
  on-change, capped at quarterly" as a discipline. The new
  operating-principle section is the natural carrier for that cadence
  claim, making it discoverable from `operating-principles.md`
  instead of buried in an audit document the framework was scheduled
  to delete.

## Risks / Open Questions

1. **Promotion shape: new section vs §9 satellite.** Bias: **new
   top-level section, §10** (proposed title: *"Classify Claims Before
   Enforcing Them"*). Rationale: the classification mechanism is
   *upstream* of the §9 design-then-implementation pattern — you
   classify a claim's enforcement state *before* deciding whether to
   ship the design or the implementation or both. Treating it as a §9
   satellite would imply subordination; it's actually peer-level
   doctrine. The Wave 2b and Wave 5.5 distillations both frame it as
   peer-level, not subordinate.
2. **Cadence claim placement.** Bias: include the periodic
   re-evaluation cadence in the new §10 body, **not** as a separate
   companion rule. Rationale: the cadence is the *output* of the
   principle — running the classification periodically. A separate
   rule would be premature; first establish the principle, then
   observe whether the cadence actually fires reliably before
   committing to companion-rule infrastructure.
3. **Auto-harness self-application.** Bias: the new section explicitly
   names that auto-harness *itself* applies the principle to its own
   claims — the Wave 2b safety sweep IS the principle's first
   self-application; Wave 5's roadmap IS the principle's first
   roadmap-from-classification output. This keeps the section
   self-witnessing, mirroring §9's "First applied" structure.
4. **Generalizability claim scope.** Bias: include the "reusable by
   consumer projects" claim as a closing paragraph. Rationale: the
   meta-framework story is documented in the Wave 2b distillation's
   third implication and is part of why the principle is worth
   codifying. Omitting it would lose signal about what the principle
   buys the project beyond self-discipline.
5. **No companion rule, no validator.** Bias: this principle is
   *honor-code* doctrine, not enforcement machinery. There is no
   `validate-classification.sh` to write — the classification is a
   reading-and-cataloguing discipline that fires during audit work
   (refresh-N audits) or during PRD-drafting work. Trying to
   mechanize it would be premature and might surface the §9
   *bundling-design-with-implementation* anti-pattern the framework
   already warns against.
6. **Status flip on acceptance.** Per
   `feedback-opp-to-implementation-no-prd`, this OPP's half-day scope
   and resolved Open Questions make it eligible for direct
   implementation without a PRD pass. Bias: **leave status at
   `proposed`** until the implementation PR (the
   `operating-principles.md` edit) opens, at which point the
   implementation PR cites this OPP and the OPP flips to `exploring`
   in the same commit per the opportunity-capture transition matrix.
   The implementation PR's commit + change-log entry will note "no
   PRD pass; half-day implementation; OPP captures full design
   contract."

## Disposition

<!-- Empty while Status: proposed. -->

## Promotion

<!--
Empty until accepted. The implementation PR will populate this with
a pointer to the commit that adds the new §10 section in
`docs/operating-principles.md`.
-->
