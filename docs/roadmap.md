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

> **Updated:** 2026-06-27 *(factual-freshness pass — a large governance +
> catalog wave shipped to `main` since the 2026-05-25 revision but was never
> release-tagged, so the "Planned" section below described shipped work as
> proposed. The now-shipped items are flagged inline and summarized under
> **Shipped since v0.5.0** below. **The release-version sequencing — which tag
> (v0.6.0 / v0.7.0 / …) covers which shipped work — is a maintainer decision and
> has not been re-assigned here;** this pass corrects facts, not the version plan.
> Prior: 2026-05-25 post-prioritization-examination.)*

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

## Shipped since v0.5.0 (not yet release-tagged)

A large governance-machinery and deep-domain-catalog wave merged to `main` after
the v0.5.0 tag. It is **not yet assigned to release tags** (a maintainer pass owns
that). Summarized here so the roadmap reflects reality; several items below appear
as "Planned" further down because that text predates their shipping.

**Governance machinery (validators 8 → 20):**

- Trust-tier enforcement — `validate-trust-tier.sh` (PRD-0006). Listed as "v0.7.0
  planned" below; **shipped.**
- The safety-hardening validators — `validate-skill-content.sh`,
  `validate-sensitive-paths.sh`, `validate-sast-coverage.sh`,
  `validate-knowledge-redaction.sh` (Wave 5 / ADR-0017).
- `validate-publication-boundary.sh` (PRD-0026) — always-on `do-not-publish` leak gate.
- `validate-module-stability.sh` (PRD-0027) — per-module `stability` tier across all
  modules; a third governance axis distinct from trust tier and § 10.
- `validate-lane-integrity.sh` (PRD-0025) — the `management/work-package` parallel
  multi-agent lane contract.

**Deep-domain catalog (the § 12 skeleton, six instances):**

- Domain families: `domains/healthcare-*` (PRD-0017), `domains/aec-*` (PRD-0019),
  `domains/geospatial-*` (PRD-0024); cross-cutting overlays
  `management/privacy-by-design` (PRD-0018) and `management/digital-twin` (PRD-0023).
  Cybersec (PRD-0022) is designed, not built.
- The harvest: operating-principle **§ 12** + the authoring playbook (OPP-0049).

**Strategic + agent-native overlays:**

- `management/canonical-position` (PRD-0007) — ratified north-star. "v0.6.0 planned"
  below; **shipped.**
- `architectures/agent-observability` (PRD-0014) — OpenTelemetry trace contract; the
  first frontier-agent-cluster satellite. `architectures/ai-foundry-target` (PRD-0028)
  is **shipped** (the second satellite). The remaining two satellites are **designed
  (design-only PRDs accepted, not yet built):** `architectures/intelligent-model-routing`
  (PRD-0029 / OPP-0030) and `architectures/agent-defense-in-depth` (PRD-0030 / OPP-0031).

**Doctrine:** operating-principles §§ 9 (Split Design from Implementation), 10
(Classify Claims Before Enforcing Them), 11 (Privacy by Design), 12 (Author Deep
Governance Verticals).

> **Release-tagging is the open maintainer task here** — deciding which of the above
> lands under v0.6.0 / v0.7.0 / a consolidated tag, and cutting the GitHub releases.

---

## Planned

### v0.5.1 — YouBase Brownfield Catalog Patch (OPP-0008 + OPP-0009 + OPP-0010)

**Status:** Three OPPs `proposed`; small patch release; ready to pick
up as a single bundled PR.

The v0.5.1 patch closes the three catalog gaps surfaced by the YouBase
brownfield onboarding (2026-05-24) without introducing new governance
machinery. Pure catalog growth — three small modules, each with zero
required artifacts.

| Module | Source OPP | What |
|--------|------------|------|
| `stacks/node-javascript` (+ `stacks/coffeescript`) | OPP-0008 | Sibling to the existing `stacks/node-typescript`; no required artifacts |
| `data/embedded-key-value` (+ `data/browser-storage`) | OPP-0009 | LevelDB/LMDB/RocksDB/SQLite-as-KV (server) + IndexedDB/localStorage/OPFS (browser); no required artifacts |
| `domains/cryptographic-identity` | OPP-0010 | BIP32/BIP39 HD wallets + DID/SSI + key-custody primitives (orthogonal to `domains/web3`); no required artifacts |

**Effort estimate:** ~3 hours engineering + ~1-2 hours dogfood
validation. Single PR, single working session.

**Why this is a v0.5.1 patch (not v0.6.0):** zero new validators, zero
new templates with placeholders, zero schema changes. Pure catalog
addition. Does not compete with the governance-machinery work for
v0.6/v0.7 sequencing — it slots in as a fast-follow that costs
essentially no calendar time.

### v0.5.2 — Tula Agent-Native Delivery Catalog Patch (OPP-0018 + OPP-0019 + OPP-0021)

**Status:** Three OPPs `accepted`; modules implemented; **PR #55 in review**.
Same release class as the v0.5.1 YouBase patch — pure catalog growth, no new
machinery.

The v0.5.2 patch closes three of the gaps surfaced by the Tula brownfield
onboarding (2026-05-24) — the *delivery-topology* gaps for agent-native
products, distinct from the YouBase / OpenEMR *stack-breadth* gaps. Pure
catalog growth: three small modules + three templates, **zero new validators
and zero schema changes**.

| Module | Source OPP / PRD | What |
|--------|------------------|------|
| `architectures/agent-skill-pack` | OPP-0018 / PRD-0008 | Authored, eval-gated skill pack as a delivery topology (requires `docs/architecture/overview.md`) |
| `management/eval-gated-testing` | OPP-0019 / PRD-0009 | Binary-graded eval quality gate, sibling to `testing-standard` (requires `docs/testing/eval-strategy.md`) |
| `delivery/self-hosted-oss` | OPP-0021 / PRD-0010 | Posture between `prototype` and `production-saas` (requires `docs/deployment/self-hosting-guide.md`) |

Deferred behind the **US-healthcare-bias guardrail** (international
second-evidence required before freezing healthcare artifacts): OPP-0022
(patient-agent safety), OPP-0020 (eval/safety tooling in the harness
toolchain), and the OPP-0013 healthcare-fhir / smart-on-fhir sub-modules.

**Why this is a v0.5.2 patch (not v0.8.0):** v0.8.0 is OpenEMR Phase 1 per the
2026-05-24 prioritization examination. The Tula agent-native batch is the same
pure-catalog-growth, zero-machinery class as the v0.5.1 YouBase patch — the
eval-gate posture is a sibling module (not a `testing-standard` mode-field) and
the self-hosted-oss posture declares no conflicts, so nothing here requires
validator or schema work. It ships in the patch lane rather than competing with
the v0.6/v0.7 governance-machinery sequencing.

### v0.6.0 — Canonical-Position Artifact (PRD-0007)

**Status:** ✅ **SHIPPED to `main` 2026-06-26** (PRD-0007 `Accepted`; OPP-0007
`accepted`; module + templates + citation/ratification rules live) — **not yet
release-tagged.** Two FRs below changed at implementation: FR-006 (the § 9
reconciliation-load promotion) was **split out** to a § 13 follow-up as orthogonal,
and FR-007's counts were recomputed against `main`. The rest shipped as specified.

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

**Status:** ✅ **SHIPPED to `main`** (PRD-0006 `Accepted`; `validate-trust-tier.sh`
live since the Wave 5.1 safety-hardening sprint) — **not yet release-tagged.** Was
originally planned as v0.6.0, re-prioritized 2026-05-24 to v0.7.0 after the OPP-0007
field evidence; both have since shipped.

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

### v0.8.0 — OpenEMR Brownfield Catalog Phase 1 (OPP-0011 + OPP-0012 + OPP-0013 core)

**Status:** Seven OPPs `proposed`; Phase 1 is a 3-OPP minimum viable
subset. Internal dependency tree confirmed by the 2026-05-24
prioritization examination.

Phase 1 is the minimum viable PHP-healthcare catalog — the smallest
subset that unblocks OpenEMR consumer adoption:

| OPP | What |
|-----|------|
| OPP-0011 | `stacks/php` module + `harness-php` skill + `validate-php-strict-types.sh` + `validate-conventional-commits.sh` |
| OPP-0012 | Generalize `data/relational-postgres` → `data/relational-sql` with engine sub-field (postgres / mysql / mariadb / sqlite) |
| OPP-0013 core | Healthcare domain family with the *core* sub-modules (FHIR, HL7v2, audit-log, PHI-encryption, patient-portal) — not all 12; the rest land in v0.9+ Phase 2 |

**Effort estimate:** ~4-6 weeks for Phase 1. OPP-0013 should be
promoted to `exploring` and get its own PRD pass when the time comes
(it's the cluster's anchor; warrants the OPP→PRD discipline).

Phase 2 (v0.9.0+) lands the remaining healthcare sub-modules (CCDA,
SMART, ePrescribing, CDR, CQM, Direct, EHI-export) + OPP-0014
(polyglot-companion-services) + OPP-0015 (regulated-compliance) +
OPP-0016 (specialist healthcare review skills) + OPP-0017 (legacy-
coexistence templates).

### v0.8+ — Sibling-Observation Follow-ups (after PRD-0007 + PRD-0006 land)

Three follow-up OPPs will be filed that each anchor on OPP-0007 as
their prerequisite:

- **Observation A — Validator opt-out staleness pressure.** Needs
  trust-tier (PRD-0006) machinery to land first; the override
  citation works cleanest once tier declarations exist.
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
