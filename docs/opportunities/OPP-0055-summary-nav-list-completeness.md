<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0055 — SUMMARY Nav-List Completeness (gate the last unguarded record mirror)

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-07-19
**Last Updated:** 2026-07-19
**Confidence:** high (the drift is field-proven — PR #179 hand-fixed a 6-record SUMMARY nav lag that no validator caught; the fix is a mechanical extension of an existing always-on validator)

---

## Thesis

`SUMMARY.md`'s per-record navigation lists — the OPP, PRD, and ADR nav rows GitBook
renders as the published sidebar — are **derived mirrors** of the record files on disk, and
they are the **last mirror in the record family that no validator reconciles**.
`validate-list-completeness.sh` already asserts every ADR / PRD / OPP has its row in
`docs/README.md` (and OPPs additionally in `candidates.md`), and every profile/agent *module*
has its SUMMARY nav entry — but it never asserts that ADR / PRD / OPP *records* have their
SUMMARY nav row. The gap is why PR #179 had to hand-reconcile a **6-record lag**
(OPP-0052/0053/0054 plus PRD-0033/0034/0035) that had accumulated silently:
`validate-list-completeness` gates the `docs/README.md` index and the SUMMARY *module* lists,
not the SUMMARY record-nav enumeration.

This is the **"mechanize the reconciliation" arm** of the `operating-principles.md` § 3
mirrored-field-drift law (*"a source-of-truth field mirrored into N derived surfaces creates
N−1 unenforced drift sites — mechanize the reconciliation or stop treating the mirror as
authoritative"*), applied to the SUMMARY record-nav mirror, and the natural sibling of the
status-parity gate shipped this cycle (PRD-0036 / OPP-0054):

- **`validate-status-parity.sh`** reconciles each OPP record's *status* across `candidates.md`
  and `docs/README.md` (row value).
- **This** reconciles each ADR/PRD/OPP record's *presence* in the SUMMARY nav (row existence),
  completing `validate-list-completeness.sh` for the one record surface it skips.

Ship it as **three new checks in `validate-list-completeness.sh`** (ADR / PRD / OPP →
`SUMMARY.md`), not a new validator — it is the same always-on, BLOCK, recompute-and-diff
species the validator already embodies for six other entity classes.

## The mechanize-vs-remove fork (resolved)

The § 3 law offers two ways to close a drifting mirror: **mechanize** the reconciliation, or
**remove the mirror** (here: replace the per-record SUMMARY nav rows with a single link to the
`docs/README.md` index, so there is nothing to drift). This fork resolves decisively to
**mechanize**, because the SUMMARY nav rows are not redundant restatement — GitBook publishes
`SUMMARY.md` as the sidebar, so each per-record row *is* the reader's navigation affordance
(a clickable OPP/PRD/ADR entry in the published sidebar). Removing them to kill the drift would
regress real reader UX to save a maintenance cost a validator can eliminate outright. When a
mirror serves an independent purpose (here: navigation), mechanize; reserve "remove the mirror"
for mirrors that are pure restatement.

## Design (decided — OPP-direct, no PRD)

Half-day scoped, biases pre-resolved, so this ships OPP-direct (the OPP is the design contract):

- **Three checks appended to `validate-list-completeness.sh`:** for each `ADR-*.md` /
  `PRD-*.md` / `OPP-*.md` on disk, assert `SUMMARY.md` references it. Mirrors the existing
  checks 6–7 (profile/agent module → SUMMARY) in structure.
- **Anchor on the link-target PATH, not the bare record id (load-bearing).** A bare-id
  `grep` is **unsafe** here: SUMMARY module *descriptions* cite records in prose (e.g.
  `…v1 declarative (PRD-0014)` on the Agent-Observability line, `…(PRD-0007 / OPP-0007)` on the
  Canonical-Position line), so `PRD-0014` / `OPP-0007` each appear **twice** — once in prose,
  once in the nav row. A bare-id check would pass even with the nav row deleted (false
  negative). The link-target path `](docs/opportunities/OPP-NNNN-slug.md)` appears **exactly
  once per record** (verified: 53/36/19 occurrences = the 53 OPP / 36 PRD / 19 ADR nav rows),
  so the check asserts `SUMMARY.md` contains the record's `<dir>/<filename>` path. This is the
  same anchoring discipline the status-parity validator needed (match a token unique to the
  surface, never a token that also appears in prose) — its third recurrence this thread.
- **Posture: BLOCK**, inherited from `validate-list-completeness.sh` (always-on structural
  reconciler; WARN is reserved for the fuzzy denylist check).
- **Consumer-safe:** like the existing checks, a project whose `SUMMARY.md` or record
  directories are absent yields zero discovered records → the check is a vacuous no-op.

## Origin / Evidence

- **PR #179 (2026-07-17)** hand-reconciled a **6-record** SUMMARY nav lag (OPP-0052/0053/0054 +
  PRD-0033/0034/0035) that had drifted silently because no validator gates the nav enumeration.
  That PR's own change-log entry names the gap: *"No validator gates those nav lists
  (`validate-list-completeness.sh` enforces only the `docs/README.md` index and SUMMARY's
  module lists)."* This OPP closes exactly that named gap.
- **Named as a follow-on** in OPP-0054's disposition and in `operating-principles.md` § 3 (the
  "mechanize" arm) — this is the scheduled completion of the status-parity thread, not a new
  direction.
- **Internal precedent:** `validate-list-completeness.sh` (row presence) + the newly-shipped
  `validate-status-parity.sh` (row status) + `validate-catalog-counts.sh` (row counts) are the
  three always-on structural reconcilers; this extends the first to its last uncovered surface.

## Risks / Open Questions

- **Prose cross-link masking (residual, low).** If a future SUMMARY line adds a prose *link* to
  a specific record file (not just a bare-id mention), that record's path would appear twice and
  a missing nav row could be masked. Today no such cross-links exist (counts are exact). Mitigate
  by anchoring on the path (already the plan) and, if it ever bites, tightening to the nav-row
  shape (`* [OPP-NNNN:` at line start). Documented, not blocking.
- **ADR inclusion.** The handoff named OPP/PRD; ADRs mirror disk in SUMMARY identically (19/19),
  so all three record classes are gated for symmetry — no reason to leave ADR nav ungated.

## Disposition

**Accepted (2026-07-19).** OPP-direct: half-day-scoped extension of an existing always-on
validator, the mechanize-vs-remove fork resolved to mechanize (GitBook nav UX), the one
technical subtlety (path-anchor vs. bare-id) settled by disk evidence, BLOCK posture inherited.
The implementing change ships in the same PR as this record. Closes the SUMMARY record-nav
drift class and completes `validate-list-completeness.sh` across all record surfaces.

## Promotion

Implemented directly (OPP-direct, no PRD) in the same PR: three checks appended to
`platform/validators/validate-list-completeness.sh` (ADR / PRD / OPP → `SUMMARY.md`,
path-anchored), with fixture coverage including the bare-id-in-prose false-negative case.
