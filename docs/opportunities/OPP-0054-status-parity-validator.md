<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0054 — Status-Parity Validator (OPP record status vs. derived index surfaces)

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-07-16
**Last Updated:** 2026-07-18
**Confidence:** high (field-proven this session — the drift is real, recurring, and I missed a surface myself; see Origin / Evidence)

---

## Thesis

An OPP record's `Status` metadata field is the **source of truth** for that
opportunity's lifecycle state, but the same state is mirrored into at least two
*derived* surfaces that no validator reconciles against the record:

1. `docs/opportunities/candidates.md` — the cluster **annotation** token
   (`*(accepted 2026-07-09; …)*`) following each OPP link.
2. `docs/README.md` — the **status column** of the opportunities index table.

`validate-list-completeness.sh` asserts every OPP has an index *row* (presence)
but never that the row's *status* agrees with the record. The result is silent
drift: a record flips `proposed → accepted` and one or both derived surfaces keep
reading the old state — arbitrarily long, and worst exactly where work moves
fastest.

The proposal ships an **always-on structural validator** (working name
`validate-status-parity.sh`) that extracts each `OPP-NNNN-*.md` record's canonical
`Status` and asserts every derived surface's status token agrees. It is the same
species as `validate-catalog-counts.sh` — *recompute a derived claim from its
source and diff* — applied to **status** instead of counts, and the natural
completion of `validate-list-completeness.sh`, which already checks row presence
but not row status. Third instance of a pattern the harness already runs twice.

### Scope (decomposed)

| Sub-component | What it governs | Disposition |
|---|---|---|
| **Record → `candidates.md` annotation parity** | Leading status token of each entry's `*(…)*` annotation must match the record's `Status` | **Wedge candidate** |
| **Record → `docs/README.md` column parity** | The opportunities-table status cell must match the record's `Status` (tolerating richer suffixes, e.g. `accepted (partial promotion)`) | **Wedge candidate** |
| **Surface registry (data-driven)** | Surfaces declared as `(file, entry-matcher, status-extractor)` rows so a *third* surface added later is covered by declaring it, not re-coding — mirrors the `ASSERTIONS` table in `validate-catalog-counts.sh` | Recommended shape |
| Missing-annotation policy | Whether an index entry with **no** status token passes, fails, or defaults | **Load-bearing § 10 decision (see Risks)** |
| Date-parity (annotation date vs. record `Last Updated`) | Stronger check; fragile against multi-date annotations (`filed X; accepted Y`) | Asserted / deferred |

## Origin / Evidence

**Field-proven this session, twice, at my own expense.**

- **PR #174** shipped OPP-0053's Layer 1 but omitted the `proposed → accepted`
  status flip that its own PRD's acceptance criteria named — forcing a standalone
  #177-class closeout. (Distilled: *a status flip belongs in the implementing PR*,
  `docs/knowledge/shared-observations.md`, 2026-07-12.)
- **PR #177** then reconciled **10** drifted `candidates.md` annotations by hand
  (OPP-0012 / 0025 / 0027–0032 / 0051 / 0053, several stale 6+ weeks). That same
  careful manual sweep **silently left `docs/README.md`'s OPP-0012 row at
  `proposed`** — discovered only while scoping *this* OPP. One reconciliation pass,
  one surface fixed, a second surface still drifted.
- Compounding the case: my **own two prior observations** (2026-07-12 and
  2026-07-15) each described the drift correctly for a *different* member of the
  README family — `docs/README.md` (which **does** carry a status column) vs.
  `docs/opportunities/README.md` (which does **not**) — and the second "corrected"
  the first into confusion. A human tracking N status surfaces from memory
  misattributes and misses; that is not a discipline failure to be scolded away,
  it is the structural signature of an unmechanized derived view.

**Root cause is structural, not clerical.** ADR-0012 deliberately split the
opportunity directory: `docs/opportunities/README.md` is *structural* (ADR-gated)
and `candidates.md` is *organizational* — **explicitly exempt** from the
companion-rule floor so clusters can be regrouped freely. The exemption that makes
the index cheap to edit is precisely why nothing reconciles it. This is the same
failure `validate-catalog-counts.sh` was built to close for *counts*, with no
equivalent gate for *status*.

- **Internal precedent.** `validate-catalog-counts.sh` (recompute counts from the
  artifact set) and `validate-list-completeness.sh` (assert every entity has its
  index row) are the two existing always-on structural reconcilers; this is the
  third, sitting between them — row *status* rather than row *presence* or catalog
  *count*.
- **Sibling gate this session.** `validate-observation-hygiene.sh` (OPP-0053 /
  PRD-0034) mechanized shape-parity on the *observation* ledger; this mechanizes
  status-parity on the *opportunity* index — both are "a ratified field drifted for
  want of a validator."

## Why Now

- **The cost has landed twice in one session** (#174 → #177 closeout; #177 → the
  missed `docs/README.md` row this OPP fixes), which is the strongest kind of
  timing signal: recurring, concrete, self-inflicted.
- **The surfaces are multiplying.** Two are known today; the moment a third status
  mirror is added (a dashboard, a generated index), unmechanized parity degrades
  further. A data-driven surface registry future-proofs the check.
- **A same-species sibling just shipped.** `validate-observation-hygiene.sh` proved
  the recompute-and-diff structural gate end-to-end this session; the marginal cost
  of the third instance is low while the pattern is fresh.

## Risks / Open Questions

- **Missing-annotation policy (load-bearing § 10 fork).** `candidates.md`
  top-section entries (e.g. OPP-0001 / 0002 / 0003) carry **no** status annotation
  at all. The validator must choose: **(a)** require an annotation on every entry
  (forces a small backfill, closes the gap fully), **(b)** match-if-present only
  (gentler wedge, but a *missing* token escapes silently), or **(c)** treat missing
  as an implicit `proposed`. Classify precisely at PRD time — this is the decision
  that determines whether the gate actually closes the class or only half-closes it.
- **Enforcement posture: BLOCK vs. WARN.** `validate-catalog-counts.sh` BLOCKs;
  status drift is arguably lower-harm (misleading, not breaking). Decide the posture
  in a § 10 claim table.
- **Status-token parser robustness (core implementation risk).** Annotations are
  freeform prose and `docs/README.md` cells carry richer labels
  (`accepted (partial promotion)`). The validator must extract the **leading
  canonical status token** and match on that, tolerating suffixes — and must anchor
  entry-matching on the exact `^- [OPP-NNNN](<exact-filename>)` list item /
  `[NNNN](opportunities/<exact-filename>)` table row so it never mistakes a **prose
  mention** of an OPP for an index entry. Both false-positive classes were hit live
  while scoping this OPP; getting the matcher right is the whole game.
- **Surfaces in scope + registry shape.** Wedge may hardcode the two known
  surfaces; the durable design declares them in a table (like catalog-counts'
  `ASSERTIONS`). Decide wedge vs. registry at PRD time.
- **Always-on vs. module-gated.** `list-completeness` and `catalog-counts` are
  always-on structural checks and this is the same species → always-on is the
  natural home (opportunity-capture is active on the harness regardless).
- **Date-parity (stretch).** Also asserting the annotation date matches the
  record's `Last Updated` catches more but is fragile against multi-date
  annotations; recommend deferring — status-token parity is the wedge.
- **catalog-counts propagation (implementation, not this OPP).** Shipping a new
  `validate-*.sh` takes the validator count **25 → 26**, dragging the full
  count-propagation surface (`how-to-read.md` ×2, `diagrams.md`, `cover-back.svg`,
  `README.md` ×3, the validators README, CI, kernel/base, SKILL, tests). Noted for
  the PRD; **out of scope here per § 9 (design-only)**.

## Disposition

**Accepted (2026-07-18).** `validate-status-parity.sh` shipped per PRD-0036 — always-on, BLOCK, pure-Bash, implicit-`proposed` missing-annotation policy, over the two known surfaces via anchored entry-matching. The BLOCK gate's first run surfaced the live OPP-0002 / OPP-0003 drift (reconciled) plus three parser false positives (wrapped annotations, fixed by whole-block parsing). Validator count 25 → 26; eleven fixture tests. Prior:

**Exploring (2026-07-18).** Promoted to a short PRD — [PRD-0036](../requirements/PRD-0036-status-parity-validator.md) — which resolves the two § 10 forks the proposal flagged: **missing-annotation policy = implicit `proposed`** (OPP-0054 option **c**, chosen on disk evidence — OPP-0002 / OPP-0003 carry record `Status: accepted` with no `candidates.md` annotation, a live drift that option (b) "match-if-present" would pass silently), and **posture = BLOCK** (the same-species always-on reconcilers `validate-catalog-counts.sh` / `validate-list-completeness.sh` both BLOCK; WARN is reserved for the fuzzy denylist check). Flips `exploring → accepted` at the validator's implementation-merge. Prior:

**Proposed (2026-07-16).** Harvested from this session's two self-inflicted
status-drift misses (#174 → #177 closeout; #177 → the `docs/README.md` OPP-0012
row this PR also fixes). Recommended promotion path: a **short PRD, not
OPP-direct** — because there are ≥ 2 genuinely unresolved § 10 forks (the
missing-annotation policy and the BLOCK-vs-WARN posture), and the
OPP-to-implementation-without-PRD discipline holds only when the biases are
pre-resolved. The wedge to specify: an always-on `validate-status-parity.sh`
matching the **leading canonical status token** across the two known surfaces
(`candidates.md` annotation + `docs/README.md` column) via a data-driven surface
registry, status-only (date-parity deferred), with the two forks classified in a
§ 10 claim table. Mirrors how `validate-catalog-counts.sh` and
`validate-list-completeness.sh` were specified — thin structural reconciler, one
load-bearing posture decision.

## Promotion

Promoted via [PRD-0036 — Status-Parity Validator (`validate-status-parity.sh`)](../requirements/PRD-0036-status-parity-validator.md) (2026-07-18, design-only per § 9). The PRD ratifies the wedge, resolves the two § 10 forks (implicit-`proposed` missing-annotation policy; BLOCK posture), and specifies the data-driven `SURFACES` registry over the two known surfaces. OPP-0054 flips `exploring → accepted` when the validator merges and the harness CI passes.
