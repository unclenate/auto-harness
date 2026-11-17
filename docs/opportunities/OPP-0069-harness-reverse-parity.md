<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0069 — Tighten check 11: flag a stale HARNESS.md Active Modules row (listed ⇒ active)

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-11-16
**Last Updated:** 2026-11-16
**Confidence:** medium (the gap is real and named in OPP-0068's Disposition, but the drift is low-frequency — deactivating a module is a deliberate edit — so the value is completeness, not a field-proven leak)

---

## Thesis

OPP-0068's **check 11** (`validate-list-completeness.sh`) gates the **forward** direction of
`HARNESS.md` ⇄ `harness.manifest.yaml` parity — every module declared active in the manifest's
`modules:` block must appear in `HARNESS.md`'s **Active Modules** table (**active ⇒ listed**). It
deliberately left the **reverse** direction ungated: a module **listed** in the `HARNESS.md`
Active Modules table that is **no longer active** in the manifest passes silently. That is the drift
of *deactivating* a module (removing it from `harness.manifest.yaml`) but leaving its stale row in
the `HARNESS.md` source-of-truth doc — `HARNESS.md` then overstates what governance is active.

This OPP tightens check 11 to assert **listed ⇒ active**: every module named in the `HARNESS.md`
Active Modules table must be present in the manifest's active set. Together with the existing
forward check it makes the two surfaces a **bidirectional set-equality**, closing the last direction
of the module-catalog mirror (OPP-0067 slug surfaces + OPP-0068 README table + forward HARNESS.md
parity).

## Why it's a micro-tightening, filed design-only

The drift this closes is **low-frequency and deliberate** — unlike the *available-catalog* surfaces
(SKILL.md / discovery / README table) that rot the instant a new module is *added* (the #232 /
`interview-driven` failure mode, which happens on routine growth), a stale `HARNESS.md` row requires
someone to *deactivate* a module and forget the doc, a rare intentional act. So this is completeness,
not an urgent leak — hence filed as its own small record rather than bundled into OPP-0068, and left
**proposed** (not self-accepted) for the maintainer to weight against the one genuine implementation
subtlety below.

## Design (proposed)

Extend check 11 with a reverse pass (or add it as check 12):

- **Extraction:** parse the rows of the `## Active Modules` table in `HARNESS.md` — each row is
  pipe-delimited, with the family in column 1, a **backtick-quoted module name** in column 2, and the
  purpose in column 3. Extract the module name from **column 2 specifically** (the first backtick-quoted
  token after the family), then assert each extracted name appears in the manifest's active `modules:`
  set (the same awk-extracted set check 11 already computes for its forward pass).
- **The one real bias (why not OPP-direct yet):** column-3 (purpose) prose contains incidental
  backticks (e.g. `` `docs/knowledge/` ``, `` `docs/opportunities/` `` in the live table), so a naive
  "first backtick token per row" is safe but a whole-row backtick scan is not — the parser must be
  anchored to the **module column**, not the row. Settle the exact column-anchoring (split on `|`,
  take field 2; or a positional regex) against the live table before implementing.
- **Posture / consumer-safety:** BLOCK, inherited; reuse check 11's existing guard (manifest present,
  `HARNESS.md` present, and a `## Active Modules` section present), so a consumer without the section
  is a no-op. Like check 11, this runs for consumers too (consumer-valuable).
- **Scope:** `HARNESS.md` only. No new validator file → count stays 27.

## Origin / Evidence

- **OPP-0068 Disposition + Risks** explicitly name this: *"Forward direction only (active ⇒ listed);
  the reverse (a stale `HARNESS.md` row) is a noted later tightening."* This OPP is that tightening.
- **`operating-principles.md` § 3** mirrored-field-drift law; the `HARNESS.md` ⇄ manifest pair is a
  two-way mirror, and OPP-0068 mechanized only one way.

## Why Now

n/a — no timing pressure. Filed now to capture the noted follow-on as a governed record while the
check-11 context is fresh, so it is not lost; implementation can wait for the maintainer's weighting.

## Risks / Open Questions

- **Low value-to-ceremony ratio (the main open question).** The drift is rare and deliberate; the
  maintainer may reasonably **decline** this as not worth even a small validator change, or defer it
  until a stale row is actually observed. Filed proposed precisely so that call is explicit.
- **Table-parsing robustness (the implementation bias above).** Must anchor on the module column, not
  a whole-row backtick scan, or the purpose column's incidental backticks cause false matches.
- **Format coupling.** The reverse parser couples to the `HARNESS.md` Active Modules *table shape*
  (pipe-delimited, module in column 2). A consumer with a differently-shaped active-module section
  would need the guard to degrade (as check 10 does for the README block) — resolve at design time.

## Disposition

**Accepted (2026-11-16), OPP-direct.** The maintainer chose to implement rather than defer. The one open
bias (column-anchoring) resolved cleanly against the live table: extract the module name from **field 3
under `awk -F'|'`** (the leading pipe makes field 1 empty, so family = field 2, module = field 3), and
**filter to rows whose module column contains a backtick** — which simultaneously skips the header
(`| Family | Module | … |`) and separator (`|---|---|`) rows and ignores the purpose column's incidental
backticks, since only the real module rows carry a backtick-quoted name in column 3. The section is bounded
from the `## Active Modules` heading to the next heading **or horizontal rule**. Disk-verified: the live
`HARNESS.md` ⇄ manifest pair is in perfect bidirectional parity (9 listed = 9 active, both set-difference
directions empty). Posture BLOCK and the consumer-safe guard are inherited from check 11; the implementing
change ships in the same PR as this record.

## Promotion

Implemented directly (OPP-direct, no PRD) in the same PR as this record:

- **Check 12** appended to `platform/validators/validate-list-completeness.sh` (listed ⇒ active): within
  check 11's shared guard, extract the HARNESS.md Active Modules table's column-2 module names
  (backtick-filtered) and assert each is in the manifest's active set (computed once, shared with the
  forward pass). On a stale row it fails with a message naming the offending module and the manifest
  ("Active Modules lists the module but it is not active in the manifest / listed ⇒ active").
- Integration coverage: the complete fixture now exercises both directions; a reverse-drift test
  (`ghost-mod` listed but not active → exit 1) plus the existing absent-section no-op.
