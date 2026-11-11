<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0067 — Module-Enumeration Parity Validator (gate the catalog mirror the propagation reflex can't enforce)

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-11-10
**Last Updated:** 2026-11-11
**Confidence:** high (the drift is field-proven — PR #232 hand-fixed an 8-module catalog lag that no validator caught; the gap is named in that PR's own change-log entry and in OPP-0055's "last uncovered surface" framing)

---

## Thesis

The set of selectable modules on disk (`platform/profiles/**/module.yaml`) is **mirrored into
five derived surfaces** by the `CLAUDE.md` Companion-Rule Reflex — *"Any new module added to the
active catalog must propagate to `HARNESS.md` Active Modules, `SUMMARY.md`, `README.md` Module
System table, `platform/skills/harness-onboarding/SKILL.md`, and
`platform/workflow/discovery-to-composition.md` in the same pass."* Of those five, **exactly one
is machine-reconciled**: `validate-list-completeness.sh` checks `platform/profiles/**/module.yaml`
→ `SUMMARY.md` (and agent modules likewise). The other **four surfaces drift silently** — no
validator asserts a module on disk appears in them.

PR #232 (2026-11-09) is the field proof: the `harness-onboarding/SKILL.md` module catalog listed
**46 of 54** modules — and it *forbids* an onboarding agent from selecting a module not in the
catalog — while `discovery-to-composition.md` Step 6 was missing the same eight
(`mcp-server`, `agentic-ui`, `agentic-interfaces`, `cryptographic-identity`, `browser-storage`,
`embedded-key-value`, `node-javascript`, `coffeescript`). The lag was invisible to the full
validator chain and had to be hand-reconciled. That PR's own change-log entry names the gap:
*"`validate-catalog-counts` checks numeric count-sites but not module enumerations … an
enumeration-aware validator (sibling of `validate-list-completeness` / OPP-0054) is recommended as
a follow-on OPP."* This OPP is that follow-on.

This is the **"mechanize the reconciliation" arm** of the `operating-principles.md` § 3
mirrored-field-drift law (*"a source-of-truth field mirrored into N derived surfaces creates N−1
unenforced drift sites — mechanize the reconciliation or stop treating the mirror as
authoritative"*), applied to the **module-catalog** mirror. It is the direct successor to the two
record-surface reconcilers already shipped:

- **`validate-list-completeness.sh`** (OPP-0055) reconciles each record's and module's *presence*
  in its index — but for modules only the `SUMMARY.md` surface.
- **`validate-status-parity.sh`** (OPP-0054) reconciles each OPP's *status* across its surfaces.
- **This** reconciles each module's *presence across the catalog-enumeration surfaces* the
  propagation reflex names but no validator gates.

## Why this matters more than a stale doc (the severity hook)

Unlike the record-nav drift OPP-0055 closed (where a missing `SUMMARY.md` row degrades navigation
UX), a missing module-catalog entry is a **functional regression**:
`platform/skills/harness-onboarding/SKILL.md` instructs the onboarding agent that it **may only
select modules listed in the catalog**. A shipped, selectable, fully-built module that is absent
from that enumeration is therefore **unselectable** by a conforming onboarding pass — the governance
doc actively hides a capability the harness provides. The mirror is not decorative; it is the
onboarding agent's allow-list. That raises the drift from cosmetic to capability-suppressing, which
is why mechanizing this particular reconciliation is higher-value than its record-nav sibling.

## The mechanize-vs-remove fork (leaning mechanize)

The § 3 law offers two closures: **mechanize** the reconciliation, or **remove the mirror**. The
four catalog surfaces are *not* pure restatement — each serves an independent reader:
`README.md`'s Module System table orients a first-time human reader, `harness-onboarding/SKILL.md`
is the onboarding agent's selection allow-list, `discovery-to-composition.md` Step 6 is the
discovery→composition decision matrix, and `HARNESS.md` Active Modules is this harness's own
manifest manifest-of-record. None can be collapsed to a single link without regressing its
purpose, so the fork leans **mechanize** — consistent with OPP-0055's resolution. (Confirm per
surface at design time; see open questions.)

## Design (proposed — biases NOT yet resolved, so this is design-only)

Unlike OPP-0055 (which shipped OPP-direct because its one subtlety was settled by disk evidence),
this record is filed **design-only**: three genuine design biases remain unresolved, each of which
changes the implementation shape. Implementation is a follow-on (PRD or OPP→impl pass) once these
are decided.

**The core check (the part that is settled):** for each `platform/profiles/<category>/<name>/module.yaml`
on disk, assert its canonical `<category>/<name>` identifier appears in each gated catalog-enumeration
surface. Always-on, BLOCK, recompute-and-diff — the same species
`validate-list-completeness.sh` already embodies. Consumer-safe by construction: a project whose
surface files are absent discovers zero obligations → vacuous pass (the existing per-check pattern).

**Open design biases (why a PRD may be warranted):**

1. **Active-vs-available surface semantics.** The five surfaces split into two sets. Three are
   **available-catalog** surfaces — every module *on disk* is selectable, so every module must be
   listed (`README.md` Module System table, `harness-onboarding/SKILL.md` catalog,
   `discovery-to-composition.md` Step 6). `SUMMARY.md` is already gated (available-catalog) by
   list-completeness. But `HARNESS.md` **Active Modules** is **manifest-relative** — it lists the
   modules *this* manifest activates, a subset of what is on disk, so the check there is the
   inverse pair (every manifest-active module is listed, and every listed one is active), not
   "every on-disk module appears." Scoping decision: ship the three available-catalog surfaces
   first (where #232's rot actually lived) and treat `HARNESS.md` as a separate, later check — or
   do both in one pass. **Recommended: available-catalog surfaces first.**

2. **Per-surface anchoring (the OPP-0055 discipline, harder here).** The catalog surfaces are
   heterogeneous narrative/table prose, not uniform index rows, and a module's leaf name
   (`node-javascript`, `mcp-server`) can appear in surrounding prose. Each surface needs an anchor
   unique to its *enumeration* (the full `<category>/<name>` slug, or the surface's row shape),
   never a bare leaf-id grep — exactly the false-negative OPP-0055 had to avoid. This must be
   settled per surface against disk evidence (count the slug occurrences) before implementation.

3. **Extension vs. new validator.** The catalog-surface checks are the same always-on
   structural-reconciler species as `validate-list-completeness.sh`, arguing for *extension*
   (checks 8–10). But the surfaces are prose/skill docs rather than the record indexes that
   validator already walks, and the `HARNESS.md` active/available split is a different predicate,
   arguing a *new* `validate-module-enumeration.sh` keeps concerns clean. **Leaning extension for
   the catalog surfaces; new validator only if `HARNESS.md` is folded in.**

## Origin / Evidence

- **PR #232 (2026-11-09)** hand-reconciled an **8-module** catalog lag (`harness-onboarding/SKILL.md`
  at 46/54 + the matching `discovery-to-composition.md` Step 6 gaps) that drifted silently because
  no validator gates the catalog enumerations. The PR's change-log entry explicitly names this OPP
  as the recommended follow-on.
- **OPP-0055's disposition** frames list-completeness as reconciling records "across all record
  surfaces," but its module coverage stops at `SUMMARY.md` — the catalog-enumeration surfaces were
  always out of its scope. This OPP extends the *same* always-on reconciler discipline to the
  module mirror.
- **`operating-principles.md` § 3** is the governing law; the `CLAUDE.md` Companion-Rule Reflex is
  the hand-maintained statement of the five-surface obligation this validator would mechanize.
- **Internal precedent:** `validate-list-completeness.sh` (presence) + `validate-status-parity.sh`
  (status) + `validate-catalog-counts.sh` (counts) are the three always-on structural reconcilers;
  this closes the one mirror class — module enumeration across catalog surfaces — that all three
  skip.

## Why Now

The drift is no longer hypothetical — #232 proved a real, capability-suppressing lag reached `main`
undetected, and the recommendation is already recorded in the change-log and in memory. Filing the
OPP now converts that recommendation into a first-class governed record before the next module add
re-opens the same gap, and sets up the implementing pass. No external timing pressure.

## Risks / Open Questions

- **Heterogeneous-surface anchoring (open bias 2).** The chief implementation risk: anchoring on a
  token that also appears in prose yields false negatives (a deleted enumeration row masked by a
  prose mention). Mitigate with the OPP-0055 path/slug-anchor discipline, settled per surface
  against disk counts. Documented, not blocking the *design*.
- **`HARNESS.md` active/available predicate split (open bias 1).** Folding `HARNESS.md` into the
  same check conflates two different assertions; keeping it separate risks it staying ungated.
  Resolve at design time; the recommendation is to ship catalog surfaces first.
- **Surface churn.** Narrative surfaces (Step 6 matrix, README table) carry per-module descriptive
  prose, so the validator asserts *presence*, never description accuracy (the
  `validate-module-stability` boundary — honesty is an authoring act). A module present but
  mis-described still passes; that is correct scope.
- **Catalog-count coupling.** `validate-catalog-counts.sh` already asserts the *numeric* module
  count; this asserts the *membership*. The two are complementary (count vs. enumeration) and must
  not be conflated — a surface can show the right count with the wrong members, or vice versa.

## Disposition

**Accepted (2026-11-11), OPP-direct.** Disk-grounding the three biases against the live surfaces
resolved them cleanly enough to implement in the same PR (the OPP-0055 pattern), with a principled
scope split rather than a PRD:

- **Bias 1 — which surfaces (resolved: the two clean-slug, proven-drift surfaces now; README + HARNESS.md
  deferred).** The five surfaces split by anchor convention, measured on disk:
  `discovery-to-composition.md` carries every module by full `<category>/<name>` slug (**54/54**),
  `harness-onboarding/SKILL.md` likewise (**53/54** — see the live finding below), `SUMMARY.md` is already
  gated, `README.md`'s Module System table lists modules by **leaf name inside category-grouped rows**
  (slug 11/54, leaf 54/54), and `HARNESS.md` Active Modules is **manifest-relative** (a subset, the inverse
  membership check). The two drift surfaces #232 actually hand-fixed are SKILL.md and the discovery matrix —
  exactly the two that share the clean full-slug anchor — so gate those now. **README** (leaf-in-category
  anchor, a different and fuzzier mechanism) and **HARNESS.md** (manifest-relative predicate) are a
  documented follow-on; folding a heuristic leaf-match into the same pass would mix a certain check with an
  uncertain one. README never actually drifted (54/54 by leaf), so the deferral carries low risk.
- **Bias 2 — anchoring (resolved: full `<category>/<name>` slug).** Verified unique across all 54 profile
  modules (`sort | uniq -d` empty), and it is the exact token both gated surfaces use — so a fixed-string
  grep is both sufficient and safe (no prose-collision false-pass of the kind OPP-0055 guarded against,
  because the slug form appears only in the enumeration, not in prose).
- **Bias 3 — extension vs. new validator (resolved: extension).** Shipped as **checks 8–9 appended to
  `validate-list-completeness.sh`** — the same always-on, BLOCK, recompute-and-diff species it already
  embodies for the module→SUMMARY surface — with existence-guards so a consumer lacking the platform-only
  surface files is a vacuous no-op. No new validator file → validator count unchanged (27) → no
  catalog-count or inventory churn.

**Live finding during implementation (a third drift instance, confirming the thesis).** Grounding the
SKILL.md check surfaced that `management/interview-driven` — a `beta` overlay on disk since 2026-06-26 —
was **absent from the onboarding catalog** (the management section listed 15 of 16 modules), i.e. a shipped
module was unselectable by a conforming onboarding pass, undetected by #232. Fixed in the same PR by adding
its catalog row (the implementing analog of #232 adding its eight), bringing SKILL.md to 54/54.

## Promotion

Implemented directly (OPP-direct, no PRD) in the same PR as this record:

- Checks 8–9 appended to `platform/validators/validate-list-completeness.sh` (profile module →
  `harness-onboarding/SKILL.md` + `discovery-to-composition.md`, full-slug-anchored, existence-guarded),
  with integration coverage: a complete-fixture pass exercising both surfaces, a drift test per surface,
  and an absent-surfaces no-op test.
- The live `management/interview-driven` catalog gap fixed in `platform/skills/harness-onboarding/SKILL.md`.
- **Deferred follow-on (README Module System table + HARNESS.md Active Modules):** a future OPP for the
  leaf-in-category anchor and the manifest-relative membership check — the two surfaces this pass
  deliberately scoped out.
