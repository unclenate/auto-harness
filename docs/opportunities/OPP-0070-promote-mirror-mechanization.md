<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0070 — Promote the module-catalog-mirror mechanization into operating-principles § 3

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-11-16
**Last Updated:** 2026-11-16
**Confidence:** high (the pattern is crystallized across five shipped, CI-validated shared-observations records and three merged PRs; the § 3 understatement is a concrete, verifiable doc-honesty gap, not a judgment call)

---

## Thesis

`operating-principles.md` § 3 states the mirrored-field-drift law (line 70): *"a source-of-truth field
mirrored into N derived surfaces creates N−1 unenforced drift sites — **mechanize the reconciliation** or
stop treating the mirror as authoritative."* This cycle (PRs #233 / #234 / #236, OPP-0067 / 0068 / 0069)
**mechanized the module-catalog mirror** — the law's severest unmechanized instance — as checks 8–12 of
`validate-list-completeness.sh`, bidirectionally, across all five surfaces. § 3 has not caught up, and is now
**understated about its own enforcement** in two specific places:

1. **Line 63** still states the five-surface module-catalog propagation (`HARNESS.md`, `SUMMARY.md`,
   `README.md`, `harness-onboarding/SKILL.md`, `discovery-to-composition.md`) as a purely **manual
   "in the same pass" obligation** — reading as honor-system when it is now machine-enforced. This is the
   **inverse of the overclaim class #232 fixed** (§ 10 applied inward): the doc now *under*-states what the
   harness actually enforces, which is its own kind of drift — a reader can't tell the propagation is
   gated, and the "mechanize the reconciliation" law sitting seven lines below has a completed instance it
   doesn't point at.

2. **Line 70** names only `validate-status-parity.sh` (OPP-0054) as a worked instance of the law. The
   module-catalog mirror is now a **second, richer instance** — five heterogeneous surfaces, bidirectional
   set-equality — and the three refinements it surfaced are not recorded in the durable principle layer,
   only in the append-only observation ledger.

This OPP promotes that crystallized material from `shared-observations.md` into `operating-principles.md`
§ 3 — the deliberate **destination-side promotion** the OPP-0037 → § 10 recipe established (a design-only OPP
that proposes the promotion, then a half-day section-impl PR that edits the principle). It is filed because
promoting to a governance entrypoint is maintainer-gated, not an automatic consequence of the per-PR
distillation (which was already satisfied — five records landed in `shared-observations.md`).

## What to promote (the crystallized refinements)

The five session observations (lines ~3873–3900 of `shared-observations.md`) distill to three additions the
§ 3 law should carry, as its second worked instance:

- **A multi-surface mirror mechanizes into a FAMILY of per-surface checks, not one check** — each surface
  has its own *anchor* (full slug / bare leaf / manifest-name) chosen against disk evidence (the OPP-0055
  "token unique to the enumeration" discipline), and its own *authorship* that flips the check's reach
  (platform-authored surface = consumer no-op; consumer-authored surface = gates the consumer).
- **A bidirectional mirror's two directions have asymmetric drift-frequency by triggering-edit** — the
  forward direction (every real thing is catalogued) drifts on *add* (frequent, silent → mechanize
  eagerly); the reverse (every catalogued thing still exists) drifts on *remove/deactivate* (rare,
  deliberate → a declinable, lighter-touch follow-on). "Complete the mirror for symmetry" is not an
  automatic yes.
- **Severity is set by what the surface GOVERNS, not its format** — a machine-consumed allow-list
  (`harness-onboarding/SKILL.md`, which forbids selecting an unlisted module) drifting is a *capability
  regression*, not a cosmetic doc lag; rank the "mechanize vs. remove" backlog by the surface's consumer.

## Scope (the § 3 edits the follow-on would make)

- **Reconcile line 63:** note that the five-surface propagation is now mechanized by
  `validate-list-completeness.sh` checks 8–12 (OPP-0067 / 0068 / 0069) — keep the obligation, drop the
  honor-system reading.
- **Extend line 70 (or add a sibling bullet):** add the module-catalog mirror as the law's second worked
  instance, carrying the three refinements above, and note the bidirectional `HARNESS.md` ⇄ manifest
  set-equality (checks 11–12) as the completed "mechanize" arm for that surface pair.
- **No validator / code change** — this is a principle-layer edit only. The companion rule for an
  `operating-principles.md` edit (a `change-log.md` entry or an ADR in the same commit) is the follow-on
  PR's satisfier.

## Origin / Evidence

- **Five CI-validated records** in `docs/knowledge/shared-observations.md` (2026-11-09 → 2026-11-16), one per
  PR #230 / #233 / #234 / #235 / #236 — the per-PR PRD-0004 distillation, already satisfied.
- **The merged mechanization:** `validate-list-completeness.sh` checks 8–12 on `main` (`4bbc5ae`), 632
  assertions, bidirectional `HARNESS.md` parity.
- **Precedent:** OPP-0037 → § 10 ("Classify Claims Before Enforcing Them") is the established two-PR
  promotion recipe (design-only OPP, then half-day section impl) — see
  [`feedback_operating_principle_promotion_workflow`] in the maintainer's notes and § 3's own 2026-06-11
  "Last updated" trail, which records prior § 3 promotions the same way.

## Why Now

The mechanization just merged, so § 3's understatement is live on `main` *today*; promoting while the five
observations and the three PRs are fresh keeps the principle accurate and captures the refinements before
they fade into the ledger's history. No external pressure.

## Risks / Open Questions

- **Maintainer may prefer a lighter touch** — e.g. reconcile line 63 only (the honesty fix) and leave the
  three refinements in the observation ledger rather than promoting them to § 3. Filed proposed so that
  scope call is explicit; the honesty fix (line 63) is the load-bearing part, the refinements are the
  value-add.
- **§ 3 length.** § 3 is already dense; the follow-on should *extend the existing law bullet* with a
  worked-instance clause rather than add a fourth standalone bullet, to avoid sprawl.
- **No new drift site introduced** — the promotion adds prose to a governance entrypoint, which
  `validate-catalog-counts` does not count and `validate-doc-references` only link-checks; no numeric claim
  is added.

## Disposition

**Accepted (2026-11-16), OPP-direct.** The maintainer chose to implement the § 3 edits in the same PR as the
acceptance (collapsing the OPP-0037 → § 10 two-PR recipe to one, since the scope was settled and the edit is
prose-only). Both edits landed: line 63 reconciled to state the five-surface propagation is now
machine-enforced by `validate-list-completeness.sh` checks 8–12 (closing the § 10-inward understatement), and
the mirror-drift law bullet extended with the module-catalog mirror as its second worked instance carrying
all three crystallized refinements (per-surface anchor + authorship; add-rot-vs-remove-rot asymmetry;
govern-not-format severity). The § 3 "Last updated" trail records the promotion per the file's convention.

## Promotion

Implemented directly (OPP-direct) in the same PR as this record:

- `docs/operating-principles.md` § 3 — line 63 reconciled (propagation is machine-enforced), the mirror-drift
  law extended with the module-catalog second instance + three refinements, and the § 3 "Last updated" trail
  updated.
- Companion satisfier for the `operating-principles.md` edit: a `docs/project/change-log.md` entry in the
  same commit. No validator/code change (principle-layer prose only).
