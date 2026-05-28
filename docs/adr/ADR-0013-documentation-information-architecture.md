<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0013: Documentation Information Architecture — Front-Door Restructure and Visual Program

**Status:** Accepted (Phases 0–2 shipped; Phases 3–4 superseded by [ADR-0016](ADR-0016-documentation-ia-phase-3-4-target-structure.md))
**Date:** 2026-05-25
**Author:** @unclenate
**Reviewers:** @unclenate
**Context source:** `docs/QUALITY-AUDIT-2026-05-24-documentation.md` —
independent five-pass review of the authored documentation surface (362
markdown files), surfacing 4 critical findings, 7 high findings, 9 medium
findings, and 5 low findings about how the documentation lands for the
priority audience (the curious newcomer).

## Context

Auto-harness's documentation has accumulated substantial high-quality
content — 11 polished Mermaid diagrams, a normative glossary, 12 ADRs +
7 PRDs, eighteen workflow guides, a kernel doctrine — but the
*sequencing and surfacing* of that content does not serve newcomers.
The audit's headline finding (§ 3 of QUALITY-AUDIT-2026-05-24-documentation):

> "The hook exists. It is just buried under the navigation."

Specifically:

- The value proposition sits ~80 lines deep in the README, behind a
  17-row TOC and a 5-way "pick your path" branch.
- The core vocabulary (*module, composition, overlay, manifest, kernel,
  trust tier*) is used dozens of times before definition.
- The 11 diagrams sit in `docs/architecture/diagrams.md` and are
  embedded into the concept docs that explain them at exactly two sites
  (the `harness-governance` SKILL.md callouts for diagrams 2 and 3).
- The README's "How It Works" section contains a YAML block and a bash
  block but no diagram.
- The docs ship at least two factual contradictions on countable facts
  (validator count, diagram count) — small bugs that quietly erode
  trust in every claim around them.

Editing README.md, HARNESS.md, AGENTS.md triggers the kernel/base
governance-entrypoint companion rule (per the harness's own
self-governance). The rule's `requiredAny` lists ADR, PRD,
operating-principles, change-log, and dependency-log. Without a
single ADR covering the planned restructure, each commit in the
restructure work would need its own companion artifact — adding
friction file-by-file when the design decision is unified.

This ADR records the unified decision so the restructure can proceed
across multiple commits with a single cited rationale.

## Decision

Restructure the documentation information architecture in five phases
as enumerated in QUALITY-AUDIT-2026-05-24-documentation § 9, with the
following architectural commitments:

### Phase 0 — Truth & wiring (~half day; immediate)

Correct the factual drift before any other documentation work lands.
Specifically:

- Validator count: 8 (currently said "six" / "seven" in different
  documents — actual disk count is 8)
- Diagram count: 11 (currently said "six" in HARNESS.md — actual disk
  count is 11)
- The dangling `docs/architecture/overview.md` references (ADR-0007,
  ADR-0008, OPP-0008, PRD-0001/0002/0003, revision-tracker.md) —
  reconciled either by creating the file or by updating each citation
- ADR-0004 status flipped from `Proposed` to `Accepted`
- `submodule-integration.md` added to the recommended-path routing
  pages (`how-to-read.md`, `index.md`)
- `$PLATFORM` / `$PLATFORM_ROOT` variable name standardized
- Empty `TOOLS.md` stubs filled or removed

### Phase 1 — The 60-second front door (~1-2 days)

Rebuild the top of `README.md` as an on-ramp, not a manual:

- Lead with the project's actual name (`auto-harness`) as the wordmark
  (the audit's M2 finding: H1 currently says "Development Harness"
  while the repo and badges say `auto-harness`)
- One plain-language "what this is" sentence + one concrete two-line
  example, above the TOC
- Promote "What It Does" and "Who This Is For" above the TOC; collapse
  the TOC to 6-8 anchors or a `<details>` block
- Embed a hero graphic at the top (`docs/_assets/proposed-visuals/`
  contains a designed mockup; commission a finalized version)
- Embed Diagram 1 (Component Composition) in the "How It Works"
  section
- Move the 5-way path branch below the value section — context before
  the fork
- Add a "New here? Start with the README" banner to HARNESS.md and
  SUMMARY.md

### Phase 2 — Make the mental model click (~2-3 days)

Define the core vocabulary at the point of contact:

- A five-definition "Core Concepts" block (module, composition,
  overlay, manifest, kernel, trust tier) at the top of
  `platform/core/registry/module-types.md` and referenced from the
  README
- Inline glossary links on first use of the six core terms, repo-wide
- Expand `platform/core/kernel/base/trust-model.md` from spec (27
  lines) to explanation — keep the table, add the *why*, embed the
  ladder visual from `docs/_assets/proposed-visuals/`
- Add rationale (not just rules) to `doctrine.md`, `audit-model.md`,
  `enforcement-model.md`, `lifecycle-controls.md`
- Close the glossary gaps: *Bootstrap Complete*, *Harness Ready*, *lite
  manifest*, *install.sh*, *overlay*
- One worked "anatomy of a module" walkthrough of a real `module.yaml`

### Phase 3 — The visual program (~3-5 days; parallelizable)

- Surface all 11 existing diagrams: embed each in the concept doc it
  explains, not only in `docs/architecture/diagrams.md`
- Add high-value missing visuals: newcomer routing decision tree (in
  `how-to-read.md`), "How It Works" pipeline (in `README.md` per
  Phase 1), agent-pack inheritance tree (in
  `platform/agents/base/README.md`), "anatomy of the harness" panel,
  lifecycle state diagram
- Commission the two designed hero SVGs from the proposed mockups in
  `docs/_assets/proposed-visuals/`
- **Extend `validate-catalog-counts.sh` to cover diagram labels** —
  close the blind spot that let the diagram count rot in HARNESS.md
  in the first place

### Phase 4 — Navigation & catalog hygiene (~2-3 days)

- Create `docs/README.md` — one-table ADR/PRD/OPP index with status
  (highest-leverage navigational fix; bundled into this ADR's
  shipping PR as Phase 4-a)
- Standardize the module READMEs across `platform/profiles/**`: one
  uniform lead heading, a fixed-position "Depends on / Conflicts with"
  callout, a "See Also" block on each
- Refresh `platform/examples/README.md` with all 5 sample projects;
  narrate at least one as an end-to-end walkthrough
- Add "for contributors, not first-time users" banners to the
  governance docs a newcomer might wander into (`docs/adr/`,
  `docs/requirements/`, `docs/opportunities/`)
- Rewrite `platform/validators/README.md` user-first, with a worked
  failing-run example; move the Ruby-internals content to a contributor
  section

## Scope boundaries (what this ADR does *not* change)

Per QUALITY-AUDIT-2026-05-24-documentation § 11:

- **The ADRs, PRDs, and doctrine docs are not rewritten into
  "friendly" prose.** They are correctly pitched at contributors and
  remain so. The fix is signposting, indexing, and surrounding context
  — not a tone shift.
- **The `docs/` governance tree is not expanded for newcomers.** It
  remains contributor-targeted. The fix is the banner that signposts
  it as "not for you yet."
- **No binary image assets are introduced** beyond the two designed
  hero SVGs (which are text-based vector format and trackable by the
  validator). Per operating-principles § 8, the prefer-text discipline
  holds.
- **No validator logic or trust-tier boundaries change in the name of
  clarity.** This is a documentation effort. The governance contract
  is not in scope.
- **The five root entrypoints (README, HARNESS, AGENTS, CLAUDE, TOOLS)
  are not collapsed.** The separation is deliberate and correct. The
  fix is a clearer *map*, surfaced earlier — not a merge.

## Consequences

**Positive:**

- The 60-second test (Headline finding § 3 of audit) is fixed without
  rewriting any content. The fix is pure reorder + surfacing + correct.
- Brownfield consumers (currently three active: YouBase, OpenEMR,
  Tula) onboard against vocabulary they can find at first use,
  reducing the friction that turns each onboarding into an OPP-filing
  pass.
- The validator-coverage gap for Mermaid diagram labels (Phase 3
  validator hardening) closes the drift class structurally — the
  factual fixes from Phase 0 stay fixed without manual discipline.
- One ADR covers a multi-phase, multi-commit restructure cleanly. The
  governance-entrypoint companion rule's `requiredAny` is satisfied by
  citation to this record from each subsequent commit; no scattered
  change-log stubs.

**Negative / costs:**

- Phases 1-4 total ~50 hours of part-time work over ~6 weeks. During
  that time, brownfield and governance-PRD workstreams will be running
  in parallel; cognitive load is non-trivial.
- The Phase 3 visual program may produce diagrams that PRD-0007 and
  PRD-0006 implementations also want to update; coordination needed to
  avoid collision.
- One designed SVG cover image is being commissioned (`hero-before-
  after.svg`); if the commissioning falls through, the fallback is the
  unmodified mockup (which is acceptable but not polished).

**Risk:**

- If Phase 1 lands without Phase 0's count corrections, the new README
  amplifies the existing factual drift (the reorder will be reviewed
  carefully and the bad counts will be more visible). Mitigation: Phase
  0 is a hard prerequisite — every commit citing this ADR must verify
  Phase 0 is complete on the branch.

## Alternatives considered

**Per-commit companion artifacts.** Each README/HARNESS edit could file
its own change-log entry. Rejected: produces a scattered paper trail
for one design decision. The audit explicitly recommends a single ADR
(§ 10) for exactly this reason.

**Wait for v1.0 to do the documentation work.** Defer doc fixes until
all governance PRDs and brownfield batches are shipped. Rejected: the
factual drift erodes trust *now* (a reader who notices one wrong number
distrusts everything around it). Phase 0 is cheap and shipping it
later means each new artifact ships into a context that's already
leaking trust.

**Rewrite the prose from scratch.** Rejected: the content is genuinely
strong (per audit § 1: "auto-harness does not have a documentation
*quality* problem; it has a documentation *sequencing and surfacing*
problem"). Rewriting would risk losing the precision the existing prose
has earned.

**Outsource the doc restructure to a documentation specialist.**
Rejected for this maturity stage: the maintainer's understanding of
the harness's governance shape is load-bearing on the restructure
decisions (e.g., which terms are load-bearing vs. ornamental, which
diagrams belong with which concepts). Outsourcing would slow the
restructure, not speed it.

## References

- [`docs/QUALITY-AUDIT-2026-05-24-documentation.md`](../QUALITY-AUDIT-2026-05-24-documentation.md) — the originating audit with findings, evidence, and the five-phase roadmap
- [`docs/_assets/proposed-visuals/hero-before-after.svg`](../_assets/proposed-visuals/hero-before-after.svg) — proposed designed README hero
- [`docs/_assets/proposed-visuals/trust-tier-ladder.svg`](../_assets/proposed-visuals/trust-tier-ladder.svg) — proposed designed trust-tier ladder
- [`docs/operating-principles.md`](../operating-principles.md) § 8 (Prefer Text Representations) — the constraint that bounds the visual program
- [`platform/core/kernel/base/module.yaml`](../../platform/core/kernel/base/module.yaml) — the kernel companion rule this ADR satisfies for Phase 1-2 commits
- [`docs/roadmap.md`](../roadmap.md) — broader sequencing context (this ADR's phases interleave with governance PRDs and brownfield batches)
