<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0012: Opportunity Capture — Split Candidate Index Out of README.md

**Status:** Accepted
**Date:** 2026-05-19
**Author:** @unclenate
**Reviewers:** @unclenate
**Context source:** GitHub issue #28 ("opportunity-capture: README rule fires
on index updates; needs structural-vs-organizational distinction"), surfaced
in `bdits/municipal-brain` while landing the second OPP batch.

## Context

The `management/opportunity-capture` module ships a companion rule that
requires an ADR in the same commit as any change to
`docs/opportunities/README.md`. The rule's intent is to gate **structural**
changes — record-structure choice, write policy, status semantics, companion-
rule references — because those edits silently re-interpret every past
candidate.

In practice, consumers naturally evolve their `README.md` to include an
**organizational index of current candidates** — cluster headings ("Foundational
architecture re-examination", "Central City domain research findings") and
grouped `OPP-NNNN` line items. The companion rule cannot distinguish a
record-structure change from an index update — both look like README edits.
Every cluster-heading addition trips the ADR requirement.

This was first hit cleanly in `bdits/municipal-brain` when the second OPP
batch (cluster headings for two new candidate groupings) landed against a
tightened validator. The consumer's local workaround was a new
`ADR-0002-opportunity-capture-index-update-policy.md` ratifying the
index-update pattern in perpetuity — it works because the ADR file stays in
every branch's `git diff origin/main...HEAD`, perpetually satisfying the rule's
`requiredAny`. But every new consumer hits the same wall on first cluster
addition.

The rule's own `humanReview` text already names this exact distinction:
"*Reviewers verify the ADR explicitly addresses the structural change (not
merely a tangential README update).*" The rule text knows it; the validator
cannot enforce it.

## Decision

Split the candidate index out of `README.md` into a sibling file,
`docs/opportunities/candidates.md`, and scope the README companion rule
unchanged. `README.md` continues to hold structural policy (ADR-gated);
`candidates.md` is the organizational free-evolution surface (no ADR required).

Concrete changes:

1. **New optional artifact** in module v1.1.0:
   `docs/opportunities/candidates.md`. Listed under `optionalArtifacts` in
   `module.yaml`, with a template at
   `platform/templates/opportunity/candidates.md`. Consumers add it when
   their candidate set grows past a flat list.
2. **Sensitive-paths description** in `module.yaml` updated to call out
   explicitly that `candidates.md` is **deliberately not sensitive** — it is
   a free-evolution surface so contributors can re-cluster candidates
   without governance ceremony.
3. **README companion-rule `humanReview` text** sharpened: reviewers now
   verify the `README.md` diff is a *structural* change (record structure,
   write policy, status semantics, companion-rule references). If the diff is
   purely organizational, the change belongs in `candidates.md` and should be
   moved before merge. The trigger path itself does not change — narrowing
   it would require teaching the validator section-aware matching, which is
   over-engineering for one rule (see Rejected Alternatives § B).
4. **Template README** updated to explicitly state that the candidate index
   belongs in `candidates.md`, not in `README.md`, and to point at the
   sibling template.
5. **auto-harness own dogfooding:** `docs/opportunities/candidates.md`
   created with the three existing OPPs (0001, 0002, 0003) grouped into two
   clusters, serving as the canonical reference example for consumers.

## Why this approach

The candidate index is a **derived view** that genuinely does not belong in
the same artifact as the binding policy. ADR-gating an index update is the
governance equivalent of requiring a constitutional amendment to add a row to
a spreadsheet. The split aligns the file boundary with the change-class
boundary the rule already wants to enforce: structural changes stay in the
ADR-gated file; organizational changes move to the unguarded file. After the
split, the rule does the right thing by construction — no validator change,
no section-aware regex, no per-consumer workaround.

## Rejected Alternatives

### A. Section-aware companion-rule triggers

Add a `triggerSections` / `excludeSections` field to companion rules so the
rule scans diff hunks against named section headings inside the trigger file.
The rule would fire only when the diff overlaps a structural section
("Record Structure", "Write Policy", "Status Definitions") and ignore
index-only diffs.

- **Pro:** Most precise. No file split; consumers keep one README.
- **Con:** Significant validator lift — heading-aware diff parsing across all
  renderer dialects (ATX vs Setext, nested sections, GFM headings with anchor
  links), and it generalizes nowhere else in the module surface. The cost is
  carried by one rule.
- **Why rejected:** Over-engineering. The file boundary expresses the
  invariant more clearly than a section-scoping regex, and aligning files
  with change classes is a pattern the rest of the harness already uses
  (`docs/adr/` vs `docs/project/change-log.md` etc.).

### B. `acceptedAlternative` field for project-local ratification ADRs

Add a field to companion rules that lets a consumer point at a project-local
ADR (by slug or path) which permanently satisfies the rule without further
per-commit ADR work — codifying what `bdits/municipal-brain`'s ADR-0002 does
in spirit.

- **Pro:** Lowest implementation lift. Closest to the workaround already in
  the wild.
- **Con:** Encodes "I've thought about this once, exempt me forever" as a
  first-class governance primitive. Easy to abuse. It also doesn't fix the
  root cause — the README still mixes two change classes; consumers who
  forget to add the ratifying ADR still hit the wall.
- **Why rejected:** Treats the symptom, not the cause. If the rule's intent
  is structural-only enforcement, the right answer is to make structural and
  organizational changes live in different files, not to add a perpetual
  exemption mechanism.

### C. Move policy out of README, keep index in README

Inverse split: keep the candidate index where consumers naturally put it
(README), and move record-structure / write-policy / status-definitions into
a sibling `policy.md`. Then scope the rule to `policy.md`.

- **Pro:** Index stays in the "front-door" file most contributors open first.
- **Con:** README is the conventional entry point for a directory; moving
  structural policy *away* from the README hides the binding contract
  behind one more click. Also requires a more disruptive migration for
  existing consumers (their README content stays, but it's now policy-free).
- **Why rejected:** Worse ergonomics for the binding contract. README is the
  right home for policy; the index is the addition that needs a new home.

## Migration

**For the auto-harness repo itself:** No migration of existing content — the
repo's `docs/opportunities/README.md` never had a candidate index section.
The new `docs/opportunities/candidates.md` is additive (dogfooding the
pattern with the existing three OPPs).

**For consumers that added an index inside README.md** (e.g.,
`bdits/municipal-brain`):

1. Create `docs/opportunities/candidates.md` from the template
   (`platform/templates/opportunity/candidates.md`).
2. Move the candidate-index section from `README.md` into `candidates.md`.
   Leave the cluster headings and `OPP-NNNN` list items intact.
3. Commit the move as a single change. This commit *will* trigger the
   companion rule (because `README.md` is being edited), so it should
   reference this ADR (`ADR-0012`) in the change.
4. After the migration commit, future cluster-heading or `OPP-NNNN`
   additions land in `candidates.md` and no longer trigger the rule.

The local `ADR-0002-opportunity-capture-index-update-policy.md` workaround in
`bdits/municipal-brain` can be retired after the migration commit, or kept as
historical context — either is fine; it stops being load-bearing.

## Consequences

### Positive

- Companion rule's intent (structural-only gating) is now enforced by
  construction, not by reviewer interpretation.
- No validator-engine change needed — the regex layer continues to work as
  designed.
- Consumers no longer hit a surprise ADR requirement on first cluster
  addition.
- The split mirrors a pattern already in use elsewhere in the harness:
  binding policy lives in ADR-gated files; organizational artifacts live in
  free-evolution files.

### Negative

- One more file in `docs/opportunities/` per consumer that adopts it.
  Marginal cost; offset by the elimination of a recurring friction point.
- A bad-actor or sloppy contributor can still put policy-flavored prose into
  `candidates.md`. The "Scope of this file" callout in the template plus the
  README-side reminder are the mitigations; review remains the backstop.

### Watch

- If consumers start writing policy into `candidates.md` to escape the ADR
  requirement, the split is being abused. Spot-check the first few consumer
  migrations and tighten the template's scope callout if the pattern appears.

## References

- Issue: GitHub #28
- Module: `platform/profiles/management/opportunity-capture/module.yaml` (v1.1.0)
- Template: `platform/templates/opportunity/candidates.md`
- Dogfooded example: `docs/opportunities/candidates.md`
- Foundational ADR (record structure): `docs/adr/ADR-0004-opportunity-capture-record-structure.md`
- Related: `docs/adr/ADR-0010-cheap-satisfiers-for-routine-governance.md` (similar
  spirit — make routine governance cheap by aligning artifacts with change classes)
