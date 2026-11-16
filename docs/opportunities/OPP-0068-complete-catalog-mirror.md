<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0068 — Complete the Module-Catalog Mirror (README table + HARNESS.md active-module parity)

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-11-16
**Last Updated:** 2026-11-16
**Confidence:** high (the two remaining mirror surfaces were explicitly named as a deferred follow-on in OPP-0067's Disposition; both checks are disk-verified to pass on the current tree and reuse the always-on reconciler species OPP-0067 shipped)

---

## Thesis

OPP-0067 mechanized the module-catalog mirror for the **two full-slug surfaces** where PR #232's drift
occurred (`harness-onboarding/SKILL.md` + `discovery-to-composition.md`, checks 8–9 of
`validate-list-completeness.sh`) and **deferred the other two** mirror surfaces because each uses a different
anchor convention: the `README.md` **Module System table** (modules listed by **leaf name** inside
category-grouped rows) and `HARNESS.md` **Active Modules** (a **manifest-relative** subset, not the full
disk catalog). This OPP closes those last two, completing the five-surface mirror the `CLAUDE.md`
propagation reflex names.

Two checks, two different predicates — both fitting the always-on `validate-list-completeness.sh` species
(discover an entity set, assert each member appears in its index), each resolved by disk-grounding:

- **Check 10 — README Module System table (available-catalog, leaf-anchored, table-scoped).** For each
  `platform/profiles/**/module.yaml`, assert its **`` `<leaf>` ``** backtick-token appears in the README's
  family-row block (the eight `| **Family** | … |` rows). Leaf names are **disk-verified unique** across all
  54 profile modules (`sort | uniq -d` empty) and the backtick bounds the match, so there is no
  substring/prose false-pass. The search is **scoped to the family-row block** (not the whole README), and
  **degrades to a skip when that block is absent** — so a copy-mode consumer whose README has a different
  shape is never false-failed (consistent with the validator's "absent index → no-op" contract).
- **Check 11 — HARNESS.md Active Modules (manifest-relative parity).** For each module declared active in
  `harness.manifest.yaml`'s `modules:` block, assert its name appears in `HARNESS.md`. This is the inverse
  surface of checks 8–10: not "every disk module is cataloged" but "every **manifest-active** module is
  reflected in the active-module source-of-truth doc." Unlike checks 8–10 (platform-only, consumer no-op),
  this one is **consumer-valuable** — a consumer has both a manifest and a `HARNESS.md`, so it gates their
  active-module doc parity too. Guarded on the `## Active Modules` section being present (skip if absent).

## Why this is a separate OPP, not a reopening of OPP-0067

OPP-0067's Disposition deliberately scoped these out — "folding a heuristic leaf-match into the same pass
would mix a certain check with an uncertain one" — and named "a future OPP for the leaf-in-category anchor
and the manifest-relative membership check." This is that OPP. Grounding the two surfaces (README table
54/54 by leaf-in-table; HARNESS.md 9/9 by manifest-parity) showed both anchors are, in fact, clean enough
to ship once isolated from the slug checks — the leaf anchor is safe because leaves are unique and
backtick-bounded, and the manifest-parity check is a well-formed set-membership assertion. Shipping them as
their own record keeps each anchor convention's rationale legible.

## Design (accepted — OPP-direct)

Half-day scoped, biases pre-resolved by OPP-0067's grounding + this record's disk verification, so
OPP-direct (the implementing change ships in the same PR):

- **Two checks appended to `validate-list-completeness.sh`** (checks 10–11), same always-on / BLOCK /
  recompute-and-diff species as checks 1–9.
- **Check 10 anchoring:** backtick-bounded leaf (`` `<leaf>` ``), search scoped to the family-row block;
  skip when the block is absent (consumer-safe degradation). Guarded on `platform/profiles/` existing (a
  submodule consumer without it is a vacuous no-op, like checks 6/8/9).
- **Check 11 anchoring:** extract active module names from the manifest `modules:` block (dependency-free
  awk, no YAML library — the block is a flat `family: [- name]` structure), assert each appears in
  `HARNESS.md`; guarded on the manifest + the `## Active Modules` section existing.
- **Direction:** check 11 ships the **forward** assertion (active ⇒ listed), which catches the primary drift
  (activate a module, forget to update `HARNESS.md`). The reverse (a `HARNESS.md` row for a deactivated
  module) is a possible later tightening, noted below.

## Origin / Evidence

- **OPP-0067 Disposition** (accepted 2026-11-11) explicitly names this follow-on and its two surfaces.
- **PR #232** is the upstream field proof that catalog mirrors rot silently; OPP-0067 added a third live
  instance (`management/interview-driven`). The README table and HARNESS.md are the last two mirror surfaces
  left ungated.
- **`operating-principles.md` § 3** mirrored-field-drift law is the governing principle; the `CLAUDE.md`
  Companion-Rule Reflex enumerates all five surfaces this validator now fully covers.

## Why Now

Immediate sequencing follow-on to OPP-0067's merge (#233): the two deferred checks are the same validator,
so they build cleanly on `main` only once #233 landed. With that done, completing the mirror now — while the
design context is fresh and both surfaces are disk-verified green — closes the drift class in full before the
next module add can reopen any surface.

## Risks / Open Questions

- **Copy-mode consumer README shape (mitigated).** A copy-mode consumer (platform/ copied into root) could
  have a README without the harness's Module System table; check 10's "skip when the family-row block is
  absent" degradation prevents a false-fail there, at the cost of silently not gating such a consumer's
  table (acceptable — the harness's own CI still gates the canonical table).
- **HARNESS.md reverse direction (deferred).** Check 11 asserts active ⇒ listed, not listed ⇒ active, so a
  stale `HARNESS.md` row for a since-deactivated module would pass. Low-value (deactivation is a deliberate
  edit) and a clean later tightening; noted, not blocking.
- **Manifest parsing without a YAML library.** The awk extraction assumes the flat `modules:` block shape
  (`family:` then `- name`); a radically reshaped manifest could mis-parse. The manifest schema is fixed
  (`schemaVersion: 1`) and validated by `validate-manifest.sh`, so this is low-risk; a regression fixture
  covers the shape.

## Disposition

**Accepted (2026-11-16), OPP-direct.** The two surfaces OPP-0067 deferred are closed as checks 10–11 of
`validate-list-completeness.sh`, completing the five-surface module-catalog mirror. Both are disk-verified to
pass on the current tree (README table 54/54 by leaf; HARNESS.md 9/9 by manifest-parity); the implementing
change ships in the same PR as this record.

## Promotion

Implemented directly (OPP-direct, no PRD) in the same PR as this record:

- Checks 10–11 appended to `platform/validators/validate-list-completeness.sh` (profile module → README
  Module System table, leaf-anchored + table-scoped + absent-block skip; manifest-active module → HARNESS.md,
  dependency-free manifest extraction + Active-Modules-section guard).
- Integration coverage: a complete-fixture pass exercising both surfaces, a drift test per surface, and
  absent-surface no-op tests (README-without-table, HARNESS-without-Active-Modules).
