<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# auto-harness Roadmap

This page shows where the project is and where it's going. It is the
human-readable companion to [`CHANGELOG.md`](../CHANGELOG.md)
(per-release history) and
[`docs/opportunities/candidates.md`](opportunities/candidates.md) (the
OPP backlog).

**Maturity:** Alpha; pre-1.0. Versions are semver-disciplined per
[`platform/workflow/release-and-versioning.md`](../platform/workflow/release-and-versioning.md).

> **Updated:** 2026-05-24 *(post-PRD-0007 drafting; prioritization
> swap captured)*

---

## Released

### [v0.5.0](https://github.com/unclenate/auto-harness/releases/tag/v0.5.0) — 2026-05-23

**First versioned release.** Establishes the semantic-versioning
baseline. Consumers should pin to `v0.5.0` (or later) instead of
commit hashes.

Headline additions:

- Cycle-end distillation triggers (PRD-0004 v1) — companion rule +
  Claude Code Stop-hook adapter
- Consumer header hygiene (PRD-0005 v1) — 61 templates tokenized +
  `set-consumer-headers.sh` bootstrap helper
- Six architecture diagrams in `docs/architecture/diagrams.md`
- GitBook PDF/print cover SVGs in `docs/_assets/`
- `validate-catalog-counts.sh` — the 8th validator; closes the
  count-drift class
- Operating-principles § 8 (Prefer Text Representations)
- Five new workflow + threat-model docs (Wave 2 of the audit)

Full release notes:
<https://github.com/unclenate/auto-harness/releases/tag/v0.5.0>

---

## Planned

### v0.6.0 — Canonical-Position Artifact (PRD-0007)

**Status:** PRD `Proposed`; OPP `exploring`; ready to pick up.

The v0.6.0 release-marker is the **canonical-position artifact** —
the highest-leverage single addition identified by the
`bdits/municipal-brain` reconciliation handoff. Auto-harness's
management profiles produce a rich artifact set but lack a single
ratified north-star that every other artifact must cite. v0.6.0
introduces a new lightweight overlay module
(`management/canonical-position`) that supplies the primitive plus a
citation companion rule plus a ratification flow.

**Eight FRs per PRD-0007:**

| FR | What |
|----|------|
| FR-001 | New `management/canonical-position` module |
| FR-002 | Canonical-position template (5 required + 4 recommended sections) |
| FR-003 | Citation rule — strategy artifacts must cite canonical position |
| FR-004 | Ratification rule — canonical-position edits require review-artifact |
| FR-005 | Review-artifact template (Observation C; bundled) |
| FR-006 | Operating-principles § 9 additions (Observation E patterns) |
| FR-007 | Catalog-count assertion bumps (26→27, 56→58) |
| FR-008 | Documentation updates (SKILL, SUMMARY, discovery-rubric) |

**Reading order for the spec:**

- [`docs/opportunities/OPP-0007-canonical-position-artifact.md`](opportunities/OPP-0007-canonical-position-artifact.md) — the gap + design options
- [`docs/requirements/PRD-0007-canonical-position-artifact.md`](requirements/PRD-0007-canonical-position-artifact.md) — the spec
- [Diagram 10 — Canonical-Position Artifact Flow](architecture/diagrams.md#10-canonical-position-artifact-flow) — visual contract

### v0.7.0 — Trust-Tier Enforcement (PRD-0006)

**Status:** PRD `Proposed`; OPP `exploring`; was originally planned
as v0.6.0; **re-prioritized 2026-05-24** to v0.7.0 after the
OPP-0007 field evidence proved a higher signal than the audit-
identified trust-tier gap.

The v0.7.0 release-marker is **machine-checkable trust-tier
enforcement**. The trust-tier model (six tiers, kernel-doctrined in
`platform/core/kernel/base/trust-model.md`) is referenced everywhere
but enforced nowhere — the harness's most-cited safety mechanism
runs on honor code.

**Seven FRs per PRD-0006:**

| FR | What |
|----|------|
| FR-001 | Optional `tier` field on `module.yaml` |
| FR-002 | `sensitivePaths` → tier inference table |
| FR-003 | New `validate-trust-tier.sh` validator |
| FR-004 | Wiring (kernel/CI/skill) |
| FR-005 | Dogfood — tier declarations on auto-harness's own 9 active modules |
| FR-006 | Documentation updates (trust-model.md "Enforcement" section, threat-model.md A5 mitigation move) |
| FR-007 | Catalog-counts assertion bump (validators 8→9) |

**Reading order for the spec:**

- [`docs/opportunities/OPP-0006-trust-tier-enforcement.md`](opportunities/OPP-0006-trust-tier-enforcement.md)
- [`docs/requirements/PRD-0006-trust-tier-enforcement.md`](requirements/PRD-0006-trust-tier-enforcement.md)

### v0.8+ — Sibling-Observation Follow-ups

After PRD-0007's v0.6.0 lands, three follow-up OPPs will be filed
that each anchor on OPP-0007 as their prerequisite:

- **Observation A — Validator opt-out staleness pressure.** Needs
  trust-tier (PRD-0006) machinery to land first; the override
  citation works cleanest once tier declarations exist. Likely
  v0.8 work.
- **Observation B — Opportunity-capture backlog re-audit on canonical
  change.** Needs canonical-change-detection mechanism
  (content-hash compare); separate scope.
- **Observation D — Discovery-intake canonical-SHA pinning.** Needs
  the canonical-position artifact + companion rule + intake schema
  update.

Each will be filed as its own OPP citing OPP-0007 as prerequisite
when the parent ships.

### Toward v1.0

**Audit findings not yet on the explicit release path:**

- Knowledge curation workflow (the deeper portion of the
  "knowledge management is write-only" gap; query helper v1
  shipped in v0.5.0)
- Sample-project comprehensive cleanup (placeholders + unfilled
  pedagogical tokens — sample CI presently exempts placeholders)
- Validator code-span awareness (so PRD docs don't need
  `.placeholder-ignore` exemptions for prose token mentions)
- Mermaid diagram label drift coverage (current
  `validate-catalog-counts.sh` covers `<br/>`-boundary patterns;
  body-text patterns are still un-asserted)
- Trust-tier session-level enforcement (PRD-0006 v2 — Claude Code
  hooks, Cursor allowlist sync, etc.)
- Consumer-side migration tool for projects that already inherited
  bad headers (PRD-0005 future-work)
- PR-template auto-fill from trust-tier validator output

**v1.0 readiness signal:** the four "critical" audit findings
addressed (trust-tier enforcement, knowledge-management curation,
versioning baseline, consumer module operations) + at least one
external consumer reporting "we use auto-harness in production and
the trajectory feels stable."

---

## How the Roadmap Stays Honest

The roadmap is rebuilt when:

1. A new PRD is accepted → version-marker assigned + entry added
2. A version ships → moves from `Planned` to `Released`
3. Prioritization swaps (like the 2026-05-24 PRD-0006 ↔ PRD-0007
   swap) → the change is captured in `docs/project/change-log.md`
   with rationale and reflected here

What the roadmap doesn't promise:

- Specific dates. Auto-harness ships when work is ready, not on a
  fixed cadence (per
  [`platform/workflow/release-and-versioning.md`](../platform/workflow/release-and-versioning.md)).
- Feature lists frozen at PRD time. v1 scope is what
  the PRD's FRs specify; the eventual implementation PR may bundle
  or defer based on what surfaces during build.
- That items in "Toward v1.0" land in the order listed. The
  current rough order is informed by dependency relationships
  (e.g., trust-tier session-level wants canonical-position
  citations as override rationale, so v0.6 ↔ v0.7 sequencing
  matters; the rest are mostly independent).

---

## References

- [`CHANGELOG.md`](../CHANGELOG.md) — per-release history
  (externally-visible changes)
- [`docs/project/change-log.md`](project/change-log.md) — per-
  decision audit log (governance rationale, including
  prioritization decisions)
- [`docs/opportunities/candidates.md`](opportunities/candidates.md) — OPP backlog with cluster groupings
- [`platform/workflow/release-and-versioning.md`](../platform/workflow/release-and-versioning.md) — versioning policy
- [`docs/architecture/diagrams.md`](architecture/diagrams.md) — visual references including the OPP → PRD design-pressure cascade and the anchor-satellite filing pattern
