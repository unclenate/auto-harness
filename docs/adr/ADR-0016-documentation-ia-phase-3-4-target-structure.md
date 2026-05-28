<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0016: Documentation IA — Phase 3–4 Target Structure

**Status:** Accepted
**Date:** 2026-05-27
**Author:** @unclenate
**Reviewers:** @unclenate
**Supersedes:** Phases 3–4 of [ADR-0013](ADR-0013-documentation-information-architecture.md)
**Context sources:**

- `documentation-audit-2026-05-27/ia-restructure-proposal.md` — the target-tree design, narrative-arc analysis, and three companion diagrams
- `documentation-audit-2026-05-27/refresh-2.md` — Phase-status ledger confirming Phases 0–2 of ADR-0013 are shipped; Phases 3–4 are in-progress / pending
- `documentation-audit-2026-05-27/execution-roadmap.md` § 5 — sequencing of this ADR (Wave 2a) and its sibling ADR-0017 (Wave 2b, Safety Hardening Roadmap)

## Context

ADR-0013 ("Documentation Information Architecture — Front-Door Restructure
and Visual Program") committed the project to a five-phase documentation
restructure. **Phases 0, 1, and 2 have shipped** (count corrections; README
front-door rebuild; vocabulary + trust-model + doctrine rationale —
respectively PRs #56/#58, PR #56 + follow-ups, PR #68). Phases 3 and 4
were sketched in prose — *"embed diagrams in concept docs," "standardize
module READMEs," "refresh examples README," "governance-doc banners,"
"validators/README rewrite"* — but described surface-level edits to the
*existing* IA, not a structural restructure of the GitBook nav itself.

Between ADR-0013's drafting and 2026-05-27, three things shifted the
problem statement:

1. **The nav grew**, not shrank. Eight modules, four PRDs, nine OPPs, three
   audit deliverables, and one new operating principle (§ 9 Split Design
   from Implementation) all landed. The IA proposal quantifies the result:
   **15 top-level GitBook sections, ~290 visible leaves, max depth 4** —
   the front door is over-loaded by a factor of two against the standard
   7±2 heuristic, and the section that *teaches what the framework is*
   (Kernel — Governance Foundation) sits at position 6, after the reader
   has already been asked to choose an Adoption workflow, run Day-to-Day
   operations, and consider Maintenance. The current IA teaches the wrong
   order: *how* before *why*.

2. **The IA Restructure Proposal** (`ia-restructure-proposal.md`) authored
   2026-05-27 surfaced *four breaks in the narrative arc* and *four
   coverage gaps* a learner experiences, and proposed a target 9-section
   tree (max depth 3) that resolves both. The proposal is design-only —
   concrete enough to argue with, without a per-file move plan. ADR-0013's
   Phase 3–4 prose did not anticipate this depth of structural change.

3. **The structural-enforcement insight** crystallized across the three
   2026-05-27 audit deliverables (refresh-2, IA proposal, safety sweep):
   every recurring drift class lands because enforcement is structural-
   only. The IA migration itself is one of three concrete shapes for the
   same architectural move — turning honor-code into code-code — and
   benefits from the same companion-rule shelter pattern ADR-0013
   established for its first three phases.

ADR-0013's authors did not have the proposal's target tree to commit to;
its Phase 3 / Phase 4 prose remains correct as *direction* but does not
record the *target structure*. This ADR fills that gap and gives Wave 6
(IA migration, per execution-roadmap § 9) the multi-commit shelter that
ADR-0013 gave Phases 0–2.

## Decision

Adopt the 9-section target tree from `ia-restructure-proposal.md` § 6 as
the documentation IA going forward. Supersede Phases 3 and 4 of ADR-0013
with this target structure.

### The 9-section target tree

1. **Start Here** *(ORIENT)* — what is auto-harness, who it's for, pick
   your path, **30-Minute Hello World** *(new)*
2. **Concepts** *(TEACH, NEW HUB)* — the four-layer model, trust tiers,
   modules and composition, companion rules, the lifecycle of a change,
   **Visual Tour** *(lifted from `docs/architecture/diagrams.md`)*
3. **Adopt** *(CHOOSE)* — collapsed from current Adoption Workflows +
   Day-to-Day onboarding + Contributing routing; decision chart routes
   the reader to *exactly one* of five paths
4. **Operate** *(RUN)* — Day-to-Day + Maintenance, fused; **Cookbook**
   *(new — ~10 named recipes)*
5. **Catalog** *(BROWSE)* — curated hub-page architecture for Modules,
   Compositions, Skills, Validators, Templates (35 modules don't appear
   as 35 nav rows; the hub lists them with "core three to start" guidance)
6. **Examples** *(LEARN BY DOING)* — lifted out of Compositions to its
   own top-level home (currently buried at depth 4)
7. **Extend & Contribute** *(AUTHOR)* — extending the harness, skill
   authoring, contributing guide, security disclosure, code of conduct,
   threat model
8. **Reference** *(LOOK UP)* — glossary, topic index, how-to-read,
   roadmap, **curated ADR shortlist**, full governance records (the
   demoted ADR/PRD/OPP catalog), operating principles
9. **Entry points** *(DISAMBIGUATE)* — README / HARNESS / AGENTS /
   CLAUDE / TOOLS explained side-by-side as a single explainer leaf

**Top-level count: 9** (down from 15). **Max depth: 3** (down from 4).
**Total visible leaves after curation: target ~80–100** (down from ~290),
achieved by demoting full ADR/PRD/OPP enumerations and the full template
tree into hub pages rather than removing them.

### Architectural commitments

- **Source of truth stays put.** Kernel doctrine remains in
  `platform/core/kernel/base/`. § 2 Concepts holds *curated teaching
  content* that links to the kernel source; it does not duplicate or
  fork the doctrine. The kernel directory is the authority; § 2 is the
  on-ramp.
- **Repo-root entry points remain separate files.** § 9 explains
  README / HARNESS / AGENTS / CLAUDE / TOOLS side-by-side as a unit but
  does not merge them. The five-file separation is deliberate (per
  ADR-0013 scope boundary "the five root entrypoints are not collapsed")
  and stands.
- **ADR-0013's Phases 0–2 stand as historical record.** Their shipped
  artifacts (PR #56, PR #58, PR #68) remain valid. This ADR supersedes
  Phase 3 and Phase 4 *only* — the surface-level edit list those phases
  enumerated is reframed as part of the target-tree migration.
- **Migration approach is parallel-then-redirect-then-sunset** per IA
  proposal § 11: build the new 9 sections as siblings of the existing 15
  (prefixed `[NEW]` during transition); move content with one-line
  redirect stubs at old paths; sunset the duplicate `[NEW]` prefix and
  old structure after a 2–3 week quiet period.

### Curated ADR shortlist (per IA proposal § 13 open question 3)

§ 2 Concepts cites a curated "core ADRs" subset rather than enumerating
all 16+. Per the proposal's recommendation and this ADR's commitment:

- **ADR-0001** — Modular Governance *(the founding)*
- **ADR-0003** — Submodule Integration *(the adoption pattern)*
- **ADR-0005** — Open-Source Cut *(the licensing decision)*
- **ADR-0008** — MCP Awareness *(the agent-surface decision)*
- **ADR-0013** — Documentation Information Architecture *(the meta-decision)*
- **ADR-0016** — *this record (the structural-IA decision)*

The full chronological list lives in § 8 Reference → Governance records.

## Implementation Deferral

Per operating principle § 9 ("Split Design from Implementation"), this
ADR ships the *design* at v1 and defers the multi-PR migration machinery
to follow-up work. A deferred implementation that is not written down is
indistinguishable from a forgotten one; each one is enumerated below.

| Deferred implementation | Deferred to | Why deferred |
|---|---|---|
| Build the 9 new top-level `SUMMARY.md` sections as siblings of the existing 15 (Phase 6.1 of roadmap) | **Wave 6.1** (IA migration, parallel structure first) | Multi-week multi-PR; needs its own sequencing per execution-roadmap § 9 |
| Author the missing hub pages — `concepts/index.md`, `cookbook/index.md`, `30-minute-hello-world.md`, the five § 5 Catalog hubs | **Wave 6.1** | Same scope as above; the hub authoring is the bulk of Phase 6.1's effort |
| Move content from current locations to target sections with one-line redirect stubs at old paths | **Wave 6.2** | `validate-doc-references.sh` becomes load-bearing here — every move is a potential link breakage; must merge green at each step |
| Sunset duplicate `[NEW]`-prefixed structure once new tree is in nav for 2–3 weeks with no inbound link breakage | **Wave 6.3** | Quiet-period dependent; cannot be sequenced before Wave 6.2 |
| **Extend `validate-list-completeness.sh` SUMMARY.md coverage** from modules-only (currently) to also assert ADRs, PRDs, OPPs, compositions, and template subdirectories appear in their respective `SUMMARY.md` sections | **Wave 6** (alongside the IA migration that finalizes `SUMMARY.md`'s shape) | The Wave 1 validator was scoped to the roadmap § 4 contract which named only `docs/README.md` + `candidates.md` + `compositions/README.md` + root `README.md` + `templates/README.md` + `SUMMARY.md` (for modules only). PR #73 surfaced empirically that `SUMMARY.md` is *also* a canonical surface for the other five entity types — and ADR-0015 is already missing from `SUMMARY.md`'s ADR section as a result. Extending the validator now would lock in a `SUMMARY.md` shape that Wave 6 reshapes wholesale. Defer until the target tree exists, then extend the validator against the final structure. *In the interim*, this PR closes the empirical ADR-0015 + ADR-0016 drift manually as a one-time fix. |

What v1 *does* commit to (the contract that must hold before any
enforcement is built): the 9-section target tree above, the four
architectural commitments, and the curated ADR shortlist composition.
The migration sequence (Wave 6.1 → 6.2 → 6.3) is fixed by this ADR;
the per-step enforcement machinery is not.

## Consequences

**Positive:**

- The narrative arc the IA proposal § 7 enumerates — *Curious →
  Convinced → First Try → Daily Operator → Contributor* — gains a
  primary home per waypoint, with clean transitions. The current IA
  scatters each waypoint across multiple sections; the target IA
  routes each one through a dedicated section.
- The four coverage gaps the IA proposal § 4 names — no Concepts hub,
  no 30-Minute Hello World, no Cookbook, no Visual Tour — each gains
  a target home, making them concrete deliverables for Wave 6.
- The visual program work originally scoped under ADR-0013 Phase 3
  is reframed: most diagram embeds become part of the § 2 Concepts hub
  rather than scattered across existing concept docs, reducing the
  diagram-placement bikeshedding that the original Phase 3 invited.
- The five repo-root entry points get a side-by-side explainer at
  § 9 instead of a banner at the top — addressing the five-entrypoint
  confusion ADR-0013 § scope-boundaries acknowledged but did not solve.
- One ADR covers a multi-PR multi-week IA migration cleanly, mirroring
  ADR-0013's role as companion-rule shelter for Phases 0–2.

**Negative / costs:**

- Wave 6 is estimated at 3–4 weeks of multi-PR work (per execution-
  roadmap § 9). Until Wave 6 lands, the GitBook nav remains in its
  current 15-section / 290-leaf state. Phase 0–2 fixes do not
  retroactively repair the IA; only Wave 6 does.
- The migration produces a temporary period of duplicated nav (the
  `[NEW]`-prefixed parallel structure) that may confuse readers
  mid-transition. Per IA proposal § 11, this is acceptable.
- External backlinks targeting old GitBook anchors will break during
  Wave 6.2. Per IA proposal § 11 mitigation: redirect stubs hold for
  Wave 6.3's quiet period; longer for any high-traffic anchors.
- The `validate-list-completeness.sh` SUMMARY.md gap (see *Implementation
  Deferral* above) means new ADRs/PRDs/OPPs/compositions/templates landing
  between this ADR and Wave 6 must add their SUMMARY.md row manually.
  The two-row precedent (ADR-0015 + ADR-0016) is established by this PR.

**Risk:**

- If Wave 6 stalls (e.g., other priorities preempt), the target IA
  remains aspirational. Mitigation: the Wave 1 validator already
  enforces existing index completeness; new content cannot drop on
  the floor in the meantime. The structural-enforcement layer holds
  even if the IA migration delays.

## Alternatives considered

**Amend ADR-0013 in place.** Update ADR-0013's Phase 3–4 prose to point
at the target tree without authoring a new ADR. Rejected: ADRs are
immutable once Accepted (per `docs/README.md` ADR table guidance);
supersession by sibling is the project's documented pattern. Amending
also loses the auditability of *what was decided 2026-05-25 vs 2026-05-27*.

**Defer the IA decision until Wave 6 begins.** Skip Wave 2a; let Wave 6's
first PR carry the target-tree rationale inline. Rejected: Wave 6 is
multi-PR; without a shelter ADR, each commit would need its own
governance satisfier, reproducing the friction ADR-0013 was authored to
prevent. The same logic that justified ADR-0013 in the first place
justifies ADR-0016.

**Adopt a different target tree** (e.g., keep 15 sections but reorder).
Rejected: the IA proposal's quantitative analysis (§ 2 — ~290 leaves,
15 top-level, max depth 4) shows reordering alone cannot solve the
over-load. The structural reduction to 9 sections is load-bearing.

**Collapse the five repo-root entry points** into fewer files
(README/HARNESS merge; AGENTS/CLAUDE merge). Rejected: the separation
serves distinct readers (humans, governance, agents-generic, agents-Claude)
and ADR-0013 explicitly preserved it as a scope boundary. § 9 disambiguates
without merging.

## References

- [IA Restructure Proposal](../../documentation-audit-2026-05-27/ia-restructure-proposal.md) — the originating design document
- [Refresh #2](../../documentation-audit-2026-05-27/refresh-2.md) — Phase-status ledger
- [Execution Roadmap](../../documentation-audit-2026-05-27/execution-roadmap.md) § 5 (this ADR's sequencing) and § 9 (Wave 6 migration plan)
- [ADR-0013: Documentation Information Architecture](ADR-0013-documentation-information-architecture.md) — Phases 0–2 record (this ADR supersedes Phases 3–4)
- [Operating principle § 9 — Split Design from Implementation](../operating-principles.md) — the deferral pattern this ADR uses
