<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0036: Status-Parity Validator — `validate-status-parity.sh`

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-07-18 | **Review Cycle:** On-change

**Status:** Accepted *(design-only per § 9; the implementing PR ships the validator + its always-on registration + the propagation + the live-drift reconciliation the BLOCK posture requires to go green)*
**Date:** 2026-07-18 (filed + accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Promoting OPP: [OPP-0054](../opportunities/OPP-0054-status-parity-validator.md) — `proposed` at filing; this PRD ratifies the wedge and flips it `proposed → exploring`. OPP-0054 flips `exploring → accepted` at this validator's implementation-merge. The two load-bearing § 10 forks the OPP flagged (missing-annotation policy; BLOCK-vs-WARN posture) are resolved here in § 10.
- Same-species precedent (the two existing always-on structural reconcilers): [`validate-catalog-counts.sh`](../../platform/validators/validate-catalog-counts.sh) (recompute a derived *count* from the artifact set and diff) and [`validate-list-completeness.sh`](../../platform/validators/validate-list-completeness.sh) (assert every entity has its index *row*). This validator is the third instance, sitting between them: it checks each index row's *status* rather than a catalog count or row presence. The data-driven surface registry mirrors `validate-catalog-counts.sh`'s inline `ASSERTIONS` table.
- Sibling gate this session: [`validate-observation-hygiene.sh`](../../platform/validators/validate-observation-hygiene.sh) (OPP-0053 / PRD-0034) mechanized *shape*-parity on the observation ledger; this mechanizes *status*-parity on the opportunity index — both are "a ratified field drifted for want of a validator."
- Governing doctrine: [`docs/operating-principles.md`](../operating-principles.md) § 3 — the mirrored-field-drift law (*"a source-of-truth field mirrored into N derived surfaces creates N−1 unenforced drift sites — mechanize the reconciliation or stop treating the mirror as authoritative"*, promoted via PR #179). This validator is the **mechanize** arm of that law applied to the OPP-status mirror.
- Structural root cause: [ADR-0012](../adr/ADR-0012-opportunity-capture-index-split.md) — split `docs/opportunities/` into `README.md` (*structural*, ADR-gated) and `candidates.md` (*organizational*, **explicitly exempt** from the companion-rule floor so clusters regroup freely). The exemption that makes the index cheap to edit is exactly why nothing reconciles its status tokens; this validator prices that exemption.
- Related operating-principles: § 9 (Split Design from Implementation — this PRD is the design; a separate PR implements), § 10 (this validator converts the "each derived surface's status agrees with the record" claim from Asserted-only to Enforced; it asserts leading-token equality only, never that the *chosen* status is semantically correct).

## Overview

An `OPP-NNNN-slug.md` record's `**Status:**` field is the **source of truth** for that
opportunity's lifecycle state. The same state is mirrored into two *derived* surfaces that no
validator reconciles against the record:

1. `docs/opportunities/candidates.md` — the leading status token of each entry's `*(…)*`
   annotation (e.g. `*(accepted 2026-07-09; …)*`).
2. `docs/README.md` — the **status column** of the opportunities index table.

`validate-list-completeness.sh` asserts every OPP has an index *row* (presence) but never that
the row's *status* agrees with the record. The result is silent drift, arbitrarily long-lived,
and worst exactly where work moves fastest.

**The drift is field-proven this session, twice, at the maintainer's own expense** (see
OPP-0054 Origin / Evidence): PR #174 shipped OPP-0053's Layer 1 but omitted the record's
`proposed → accepted` flip, forcing a standalone #177 closeout; PR #177 then reconciled **10**
drifted `candidates.md` annotations by hand yet *silently left `docs/README.md`'s OPP-0012 row
at `proposed`*. Scoping this PRD surfaced a **third** live instance: **OPP-0002 and OPP-0003
carry record `Status: accepted` but have no status annotation at all in `candidates.md`** — a
record advanced past `proposed` while its index entry never followed.

This PRD ratifies **`validate-status-parity.sh`**, an **always-on** structural validator that,
for each OPP record, extracts the canonical `Status` token and asserts every derived surface's
status token agrees. It is the same species as `validate-catalog-counts.sh` — *recompute a
derived claim from its source and diff* — applied to **status** instead of counts, and the
natural completion of `validate-list-completeness.sh` (row *status* after row *presence*).

The two load-bearing decisions OPP-0054 flagged are resolved in § 10 and previewed here:

1. **Missing-annotation policy → treat a missing status token as an implicit `proposed`**
   (OPP-0054 option **c**). This choice is *grounded in disk state, not preference*. Under
   option (b) "match-if-present only", the live OPP-0002 / OPP-0003 drift (accepted records,
   no annotation) would pass silently — the gate would half-close. Under implicit-`proposed`,
   those two records correctly **fail** (implicit `proposed` ≠ record `accepted`, forcing the
   backfill), while a genuinely-raw entry like OPP-0001 (record `proposed`, no annotation)
   correctly **passes** (implicit `proposed` == record `proposed`). This targets precisely the
   harm — *a record advanced past `proposed` but the index did not follow* — without imposing
   ceremony annotations on entries that legitimately have no disposition yet. Option (a)
   "require an annotation on every entry" would force that ceremony and couple validator
   introduction to a blanket backfill; implicit-`proposed` closes the same class with a lighter
   footprint.
2. **Enforcement posture → BLOCK.** The two same-species always-on reconcilers
   (`validate-catalog-counts.sh`, `validate-list-completeness.sh`) both BLOCK. WARN-by-default
   is reserved in this harness for the single *fuzzy* check (`validate-knowledge-redaction.sh`,
   a denylist scan where false positives are expected). Status-parity is a **deterministic**
   leading-token comparison; a deterministic recompute-and-diff that only WARNs is theater. The
   BLOCK posture means the implementing PR must first reconcile the live OPP-0002 / OPP-0003
   drift (and any other the validator surfaces) to make the chain green — which is the point:
   shipping the gate closes the open class in the same motion.

The validator asserts **leading-token equality only** — never whether the chosen status is
*correct* for the opportunity. Honesty of the disposition is an authoring act (the
`validate-module-stability` boundary).

## Goals & Non-Goals

**Goals:**

- Ship `platform/validators/validate-status-parity.sh` — Bash 3.2, shellcheck-clean at
  `-S warning`, 3-state exit (0 pass / 1 violation / 2 usage). **Always-on** (not module-gated),
  like `validate-list-completeness.sh` and `validate-catalog-counts.sh` — opportunity-capture is
  active on the harness regardless, and the check is a structural property of the repo, not a
  consumer opt-in.
- **Source-of-truth extraction.** For each `docs/opportunities/OPP-NNNN-slug.md`, read the
  `**Status:**` line and normalize it to its **leading lowercased token** (so
  `accepted (partial promotion)` and `accepted + SHIPPED` both normalize to `accepted`,
  `proposed 2026-07-16` to `proposed`).
- **Data-driven surface registry.** Declare the derived surfaces as a `SURFACES` table of
  `(file, entry-matcher, status-extractor)` rows — mirroring the inline `ASSERTIONS` table in
  `validate-catalog-counts.sh` — so a *third* status mirror added later is covered by declaring
  a row, not re-coding. Two rows day-1:
  1. `docs/opportunities/candidates.md` — entry anchored on the exact
     `- [OPP-NNNN](OPP-NNNN-slug.md)` list item; status extracted from the **leading token of
     the following `*(…)*` annotation**, or **implicit `proposed`** when absent.
  2. `docs/README.md` — entry anchored on the exact
     `| [NNNN](opportunities/OPP-NNNN-slug.md) | … |` table row; status extracted from the
     **status column cell's leading token**, or **implicit `proposed`** when the cell is empty.
- **Anchored entry-matching (core correctness).** Match entries on the exact
  `OPP-NNNN`-plus-filename list-item / table-row anchor so a **prose mention** of an OPP is
  never mistaken for an index entry. Both false-positive classes (prose-mention capture; a bad
  extraction regex reporting phantom mismatches) were hit live while scoping OPP-0054; the
  matcher is the whole game.
- **Per-surface, per-record failure surfacing.** On mismatch, print the OPP id, the record's
  canonical token, the surface, and the surface's found (or implicit) token — so a reviewer can
  fix without re-deriving.
- **Project-root test seam** — the `[<project-root>]` positional is the test seam (as in
  `validate-list-completeness.sh`): fixture tests build a mini project root
  (`docs/opportunities/` records + `candidates.md` + `docs/README.md`) and point the validator
  at it. A single-file `--scan-file` is intentionally *not* offered — the check is inherently
  cross-file (record ↔ surface), so a lone surface file carries no source of truth to diff
  against; the project-root seam is what the two sibling always-on structural validators use.
- **Register** the validator in the harness-governance run-order chain, AGENTS.md,
  `platform/validators/README.md`, the root README validator table + mermaid box, the
  `harness-governance` SKILL.md chain, and CI.
- **Reconcile the live drift** the BLOCK posture surfaces, in the implementing PR, so the chain
  goes green: at minimum backfill OPP-0002 / OPP-0003 `candidates.md` annotations to `accepted`
  (a status flip, audit-trail-floored on the OPP records they touch — but these are annotation
  edits to `candidates.md`, the organizational index, so ADR-0012's exemption applies).
- **Validator-count propagation.** The count bumps **25 → 26** at every
  `validate-catalog-counts` ASSERTIONS site (the recipe auto-derives from the `validate-*.sh`
  file count; recompute at impl).
- **Fixture tests** in `platform/validators/test/` covering: matching annotation → pass;
  annotation-mismatch → fail; README-column mismatch → fail; **missing annotation on an
  `accepted` record → fail** (the implicit-`proposed` rule, the OPP-0002/0003 case); **missing
  annotation on a `proposed` record → pass** (the OPP-0001 case); a prose-mention-of-an-OPP →
  **not matched** (no false positive); a **wrapped annotation** on the line after the link
  read correctly; and vacuous-pass / exit-2 / dogfood cases.

**Non-Goals (deferred):**

- **PRD / ADR status surfaces.** The same drift class exists for PRD and ADR status mirrors, but
  this wedge scopes to the **OPP** index. Adding them later is a `SURFACES`-registry extension,
  not a re-code — noted, deferred.
- **`SUMMARY.md` nav-list completeness.** The nav-enumeration lag (records missing from
  `SUMMARY.md`'s OPP/PRD lists) is a *presence* drift, not a *status* drift — it belongs to the
  "mechanize" arm of the § 3 law that extends `validate-list-completeness.sh` (a separate OPP,
  the second backlog item). This validator does **not** touch `SUMMARY.md`.
- **Date-parity** (annotation date vs. record `Last Updated`). A stronger check but fragile
  against multi-date annotations (`filed X; accepted Y`); status-token parity is the wedge,
  date-parity recommended deferred.
- **Semantic correctness of the chosen status** — whether an OPP *should* be `accepted`.
  Leading-token equality only; the disposition call is an authoring act (the
  `validate-module-stability` boundary).
- **A blanket backfill of every un-annotated entry** beyond what the BLOCK posture requires to
  go green. Implicit-`proposed` means only records whose status *disagrees* with an implicit
  `proposed` must be fixed; genuinely-proposed raw entries stay annotation-free.
- **A new operating-principle section.** The governing law is already `operating-principles.md`
  § 3; this validator *is* its mechanization, not a new principle.

## § 10 Claim Classification

| Claim ID | Claim | Current | After v1 |
|----------|-------|---------|----------|
| C-SP-1 | Each OPP's `candidates.md` annotation status agrees with the record's `Status` | Asserted-only (`list-completeness` checks row presence, not row status; drift proven — 10 entries in #177, OPP-0002/0003 still un-annotated) | **Enforced (BLOCK)** — `validate-status-parity.sh` asserts leading-token equality on every record-backed entry, always-on |
| C-SP-2 | Each OPP's `docs/README.md` status-column cell agrees with the record's `Status` | Asserted-only (the #177 sweep missed OPP-0012's README row) | **Enforced (BLOCK)** |
| C-SP-3 | An index entry with **no** status token is treated as implicit `proposed` | Undefined (no gate) | **Enforced** — missing token normalizes to `proposed`; fails iff the record is past `proposed` (option **c**, disk-grounded) |
| C-SP-4 | The *chosen* status is the semantically correct disposition for the opportunity | Asserted-only | **Unchanged** — semantic correctness is an authoring act, not mechanizable |

C-SP-1 / C-SP-2's **BLOCK** posture and C-SP-3's **implicit-`proposed`** rule are this PRD's two
ratification checkpoints — the forks OPP-0054 flagged. Both are reversible, lower-commitment
levers: BLOCK follows the same-species precedent and can be relaxed to WARN by a future PRD if
status drift proves lower-harm than counts drift in practice; implicit-`proposed` was chosen
over require-annotation (option a) precisely because it closes the same class with the smaller
footprint, and can be tightened to option (a) later without changing the comparison core.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001 | `validate-status-parity.sh` ships | Bash 3.2, shellcheck-clean (`-S warning`), 3-state exit. Always-on (no module gate). Walks `docs/opportunities/OPP-*.md`, extracts each record's leading `Status` token, and checks every `SURFACES` row. `--help` documents args, the `SURFACES` registry, the implicit-`proposed` rule, and the recognized status-token set. |
| FR-002 | Source-of-truth token extraction | Per record: read the `**Status:**` line, normalize to the leading lowercased token. Recognized canonical lifecycle tokens `{proposed, exploring, accepted}` plus tolerated terminal dispositions `{rejected, superseded, deferred}` — codified inline and extended **append-only** (a future ADR that adds a lifecycle state adds the token in the same PR). An unrecognized leading token on a record fails with a "unrecognized status token" message (typo guard). The exact recognized set is finalized against the live corpus at implementation. |
| FR-003 | Data-driven `SURFACES` registry | Two rows day-1: (1) `candidates.md` — anchor `- [OPP-NNNN](OPP-NNNN-slug.md)`, status = leading token of the trailing `*(…)*` annotation or implicit `proposed`; (2) `docs/README.md` — anchor `\| [NNNN](opportunities/OPP-NNNN-slug.md) \|`, status = status-column cell's leading token or implicit `proposed`. Adding a third surface = adding a row, not code. |
| FR-004 | Anchored entry-matching (no prose false positives) | Entries matched only on the exact `OPP-NNNN`+filename list-item / table-row anchor. A prose paragraph mentioning `OPP-NNNN` is never treated as an index entry. Fixture proves it. |
| FR-005 | Implicit-`proposed` for missing tokens | A record-backed entry with no annotation / empty status cell normalizes to `proposed`; parity holds iff the record's token is also `proposed`. So `accepted`-record + no-annotation → **fail**; `proposed`-record + no-annotation → **pass**. |
| FR-006 | BLOCK posture | Default posture is **BLOCK** (exit 1 on any mismatch). No WARN default; deterministic comparison, per the catalog-counts / list-completeness precedent. |
| FR-007 | Per-surface failure surfacing | On mismatch, print OPP id, record token, surface file, and found/implicit surface token — one line per violation. |
| FR-008 | Project-root test seam | The `[<project-root>]` positional is the test seam: fixture tests build a mini project root and point the validator at it (as `validate-list-completeness.sh` is tested). A single-file `--scan-file` is intentionally not offered — the cross-file record↔surface check makes a lone surface file un-diffable. |
| FR-009 | Propagation + validator-count bump | Validator wired into the harness-governance chain, AGENTS.md, `platform/validators/README.md`, root README table + mermaid box, the SKILL.md chain, CI. Validator count **25 → 26** at every `validate-catalog-counts` ASSERTIONS site (recipe auto-derives; recompute at impl). |
| FR-010 | Live-drift reconciliation to green | The implementing PR reconciles every mismatch the BLOCK validator surfaces — at minimum OPP-0002 / OPP-0003 `candidates.md` annotations backfilled to `accepted` — so the full chain (including this validator, dogfooded on the harness) passes. |
| FR-011 | Fixture tests | `platform/validators/test/` gains a `TestValidateStatusParity` case: matching pass; annotation-mismatch fail; README-column mismatch fail; missing-annotation-on-`accepted` fail; missing-annotation-on-`proposed` pass; prose-mention-not-matched; wrapped-annotation-on-next-line read; unrecognized-token fail; vacuous pass; exit-2; harness dogfood. |

### Should Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-S01 | Suffix-tolerance hint | When a surface token matches the record's leading token but carries a richer suffix (`accepted (partial promotion)`), the validator passes silently — the hint documents in `--help` that only the leading token is compared, so authors keep human-readable suffixes. |
| FR-S02 | Drift summary line | On success, print `status-parity: N OPP records × M surfaces reconciled, 0 drift` so a green run is legible in CI logs (mirrors the count validators' summary style). |

### Out of Scope

| Feature | Reason | Revisit |
|---------|--------|---------|
| PRD / ADR status-parity surfaces | wedge scopes to the OPP index; same drift class | `SURFACES`-registry extension, later |
| `SUMMARY.md` nav-list completeness | *presence* drift, not *status* drift | the `list-completeness`-extension OPP (§ 3 "mechanize" arm) |
| Date-parity (annotation date vs. `Last Updated`) | fragile against multi-date annotations | a future stretch if status-parity proves insufficient |
| Semantic correctness of the disposition | honesty of the call is an authoring act | not planned (the module-stability boundary) |
| Blanket backfill of all un-annotated entries | implicit-`proposed` only requires fixing genuine disagreements | optional one-time cleanup |

## Technical Constraints

- **Bash 3.2 compatible** (macOS default); **shellcheck clean at `-S warning`**; **3-state exit**
  (0 / 1 / 2).
- **Pure Bash content scanning** — `[[ =~ ]]` + `BASH_REMATCH`, the same approach as
  `validate-catalog-counts.sh` and `validate-list-completeness.sh` (the two same-species
  always-on reconcilers), which use no Ruby. No new runtime dependencies (Bash only). Anchor
  and token parsing is line-oriented on the existing `- [OPP-NNNN](…)` list-item,
  `| [NNNN](opportunities/…) |` table-row, and `*(token …)*` annotation conventions. The
  `candidates.md` annotation is matched across the entry *block* (link line through the next
  bullet / blank line / heading), because long bullets wrap the `*(…)*` onto the following line.
- **Leading-token normalization** — lowercase, strip surrounding markup, take the first
  whitespace/`(`/`+`/`;`-delimited word. Compare record-token == surface-token per surface.
- **Recognized token set** codified inline `{proposed, exploring, accepted, rejected,
  superseded, deferred}`, extended append-only; finalized against the live corpus at
  implementation.
- **Always-on** — no `HarnessRegistry` module gate; the check is a structural repo property.
- **Performance** — < 2s walking the full opportunities set (≈ 54 records × 2 surfaces).
- The validator's own authored prose (`--help`, inline comments) must not trip
  `validate-skill-content.sh` (meta-§ 10 — the new validator's surface is scanned by its
  siblings).

## CI/CD Gates

- Full validator chain (now **26** validators) green, including the new validator (dogfooded on
  the harness) and `validate-catalog-counts` after the 25 → 26 bump.
- Fixture tests pass; markdownlint + shellcheck clean.
- The chain is green **only after** FR-010's live-drift reconciliation lands — the BLOCK gate
  is itself a proof the open class is closed.

## Acceptance Criteria for OPP-0054 → `accepted`

OPP-0054 flips `exploring → accepted` when FR-001…FR-011 merge and the harness's own CI passes —
`validate-status-parity.sh`, always-on and BLOCK, with the two forks resolved as classified in
§ 10 and the live OPP-0002 / OPP-0003 drift reconciled.

## Versioning Implications

Additive: a new always-on validator + chain/README/CI propagation + the two annotation
backfills. No module `module.yaml` version bump (the validator is not module-gated; it joins the
always-on structural set alongside `list-completeness` and `catalog-counts`). Validator count
25 → 26. Lands in the next minor. Existing consumers are unaffected — the check reads the
harness's own opportunity index, which consumers do not carry.
