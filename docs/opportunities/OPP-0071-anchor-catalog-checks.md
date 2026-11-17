<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0071 — Anchor the module-catalog-mirror checks (8/9/11) to the enumeration — close the prose-masking false-negative

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-11-17
**Last Updated:** 2026-11-17
**Confidence:** high (the false-negative is reproduced by mutation test against the live validator on `main`, and the § 3 claim it contradicts is a verbatim quote — both are checkable facts, not judgment calls)

---

## Thesis

Checks 8, 9, and 11 of `validate-list-completeness.sh` match with `assert_contains`'s **unanchored,
whole-file** `grep -qF`, so each passes whenever the module's slug (`<category>/<name>`, checks 8/9) or bare
name (checks 11) appears **anywhere in the target file** — including prose — not when the capability-bearing
**catalog / active-module row** is present. This reintroduces the exact OPP-0055 prose-masking false-negative
that the path-anchored record checks (1–3) and the backtick-and-table-scoped check 10 were built to avoid —
and that this same file's header (lines 56–60) documents as the reason those checks are anchored: *"a bare-id
grep would match a prose mention and pass with the nav row deleted."*

The gap is **capability-regression-shaped**, which is precisely the drift class check 8's own comment and
operating-principles § 3 refinement (c) rank **first**. Verified by mutation test (isolated copy, real
validator):

- Delete the `management/privacy-by-design` row from `harness-onboarding/SKILL.md` — making the module
  **unselectable by the onboarding allow-list**, the capability regression check 8 exists to prevent — and the
  validator passes **635/635 green**, because the slug survives in four prose mentions (lines 297/314/318/610).
- Delete the Agents `base` active-module row (and, separately, the `kernel/base` row) from `HARNESS.md`
  and check 11 passes, because `base` substring-matches `kernel/base` and a `platform/core/kernel/base/`
  path mention; the assertion total even slid 635 → 634 with no failure.
- **Control:** deleting a single-mention row (`architectures/mcp-server`) *is* caught — the check protects only
  the subset of modules mentioned exactly once.

**27 of 54 modules recur in prose in `SKILL.md`** (7 in the discovery matrix), so for over half the catalog the
stated guarantee is not delivered for the row-deletion direction. The check still catches the *add-a-new-module*
drift it was built for (a brand-new module with zero mentions anywhere — e.g. PR #232's eight unselectable
modules), so it is not worthless; the hole is the **regression** direction and any add where the new module is
name-dropped in prose before its row lands.

Two coupled doc-honesty consequences, live on `main` since #238 (OPP-0070):

1. **§ 3 refinement (a)** (line 70) claims the slug anchor was *"chosen against disk evidence per the 'token
   unique to the enumeration' discipline (OPP-0055)."* On disk the slug is **not** unique to the enumeration
   (`management/privacy-by-design` appears 5×: one row + four prose). The claim is false for checks 8/9 — the
   **inverse-overclaim class #232 fixed, now re-created in the principle layer** by the promotion that was meant
   to close understatement.
2. **§ 3 line 63** ("checks 8–12 *reconcile every* `module.yaml` *against each of those surfaces*") is true
   only in the weak "appears somewhere" sense. And § 3 refinement (c) ranks the machine-consumed allow-list
   (`SKILL.md`) as the **highest-severity** surface — yet check 8, guarding exactly that surface, is the
   **weakest** of the five.

The test suite has an explicit prose-resistance test for every check that resists prose
(`test_readme_table_bare_leaf_in_prose_does_not_satisfy` → check 10,
`test_summary_nav_bare_id_in_prose_does_not_satisfy` → checks 1–3,
`test_prose_mention_is_not_matched` → status-parity) and **none** for checks 8/9/11 — because they would fail.
The coverage asymmetry is the shape of the defect.

## Origin / Evidence

- **Adversarial pass, 2026-11-17** over the OPP-0067/0068/0069 mechanization shipped `main` @ `7143e7d`.
  Mutation tests ran the live `validate-list-completeness.sh` against an isolated repo copy; results above are
  reproduced, not asserted.
- **Fair-side:** check 10 (backtick-bounded leaf, scoped to the family-row block) and check 12 (exact
  `grep -qxF` whole-line, both directions) caught every mutation — they already apply the anchoring discipline
  this OPP would carry to 8/9/11. Check 10's own comment (lines 331–336) names the reason: *"the backticks
  prevent substring/prose false-matches."* The author had the discipline in hand for check 10 and did not carry
  it to the slug/bare-name checks.
- **Prior discipline:** OPP-0055 ("anchor on a token unique to the enumeration, never one that also appears in
  prose") — the record this OPP applies to its own siblings. The backtick-filter column idiom
  (`shared-observations.md`, 2026-11-16, the check-12 observation) is the ready-made technique for the
  HARNESS.md surface.
- No live drift today: 635 live assertions + 278/1008 ruby tests green; this is a defense-in-depth + doc-honesty
  gap, not a current failure.

## Proposed change (design-only; the scope the follow-on would settle)

Anchor the token to the **enumeration row** for each of the three weak checks, the way check 10 already does,
and add the missing prose-resistance tests:

- **Checks 8/9 (`SKILL.md` catalog, discovery matrix):** both surfaces list the module as a backtick-quoted
  slug cell in a pipe-delimited table row. Scope the match to table rows (anchor `^\|`) and/or require the
  backtick-bounded slug — mirroring check 10 — so a prose mention of the slug no longer satisfies.
- **Check 11 (`HARNESS.md` forward, active ⇒ listed):** reuse check 12's own column-2 backtick-filtered
  extraction (already present, already tested) and assert each manifest-active name **equals a module-column
  cell**, turning checks 11+12 into a true column-level set-equality instead of a substring probe. This also
  closes the `base` ⊂ `kernel/base` self-masking.
- **Tests:** add `..._in_prose_does_not_satisfy` cases for the onboarding catalog, the discovery matrix, and
  the HARNESS.md active table — the three missing siblings of the tests that already exist for 10 / nav /
  status-parity. Each fixture carries a prose mention plus (or minus) the real row.
- **Reconcile the § 3 claims** so the principle layer matches the hardened enforcement: refinement (a)'s "unique
  to the enumeration per OPP-0055" becomes *true* once the checks are row-anchored; line 63's "reconcile every
  module.yaml against each surface" stops being an overstatement. No count change (extends existing checks; stays
  27 validators).

## Why Now

The § 3 promotion (#238, 2026-11-16) made the understatement a *claim of enforcement the code does not honor* —
so the inverse-overclaim is live on `main` today, in the governance entrypoint, and in the very law
(refinement (c)) that ranks this surface's drift highest. Fixing the checks and reconciling the claim is the
same move: either harden checks 8/9/11 to deliver what § 3 asserts, or walk § 3 back — the coupling is the
forcing function, and hardening is the strictly better arm (it strengthens enforcement rather than weakening a
doctrine). The evidence is fresh (adversarial pass this session), no external pressure.

## Risks / Open Questions

- **Row-shape fragility.** Row-anchoring assumes the catalog surfaces keep their current table shape; a surface
  reshaped to list modules outside `| … |` rows would degrade to a skip (consumer-safe, like check 10's
  absent-block skip) rather than false-fail — acceptable, but the anchor must be chosen against each surface's
  real shape on disk (the OPP-0055 discipline, done right this time), not assumed.
- **Harden-all vs. accept-residual.** The maintainer may judge the add-drift coverage sufficient and prefer to
  *walk back the § 3 claim* instead of hardening all three — a legitimate lighter-touch call. The load-bearing
  part is removing the false "unique to the enumeration per OPP-0055" claim; hardening the checks is the
  higher-value arm that makes the claim true.
- **OPP-direct vs. PRD.** Scope is small and well-understood (row-scope three greps, add three tests, reconcile
  two § 3 sentences) — an OPP-direct candidate like 0067/0068/0069, not a PRD. Filed **proposed** and held at
  the gate for the maintainer's disposition.
- **Boundary.** This is a defect-fix of the OPP-0067/0068 checks, not a new surface or validator; it does not
  touch checks 1–7, 10, or 12 (all correctly anchored).

## Disposition

<!--
Empty while Status: proposed. Populated when status flips to exploring,
accepted, declined, or superseded.
-->

## Promotion

<!--
Empty until accepted. Then OPP-direct impl note or a link to PRD-NNNN.
-->
