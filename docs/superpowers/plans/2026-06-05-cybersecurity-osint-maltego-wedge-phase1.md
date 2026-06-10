# Cybersecurity OSINT / Maltego Wedge — Phase 1 (design-only) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Land the **design contract** for the third deep-domain vertical (Cybersecurity) and its first wedge (OSINT) as a single pure-docs PR — OPP-0043 (family) + PRD-0022 (OSINT wedge, with a §10 Claim Classification block) — plus the four propagation satisfiers (candidates token, README index rows, distillation observation, change-log entry).

**Architecture:** This is a §9 "split design from implementation" Phase 1. It ships **only** documents under `docs/` — no `platform/profiles/**`, no templates, no validator, no diagram, no catalog-count changes. Those are Phase 2 (a separate later plan). Because no `module.yaml` or `harness.manifest.yaml` is touched, the harness's own 15-validator suite must stay **predict-clean** (15/15 green, unchanged). Two companion rules fire on this PR — the PRD-0004 distillation rule (creating `OPP-0043`) and the OPP audit-trail floor — satisfied by a `shared-observations.md` entry and a `change-log.md` entry respectively, both in this PR.

**Tech Stack:** Markdown governance artifacts; Bash 3.2 validator suite (`platform/validators/*.sh`); `markdownlint-cli2`; `gh` CLI. No code, no new dependencies.

---

## Governing facts (verified against the tree at plan-time)

- **Next numbers:** OPP-**0043**, PRD-**0022** (current highest on main after the maintainer's #103–#109 series: OPP-0042, PRD-0021 — re-verify the next-free numbers at execution time). Diagram #14 and validator #16 are **Phase 2**, not this PR.
- **Design evidence to cite:** `docs/superpowers/specs/2026-06-05-cybersecurity-osint-maltego-wedge-design.md` (committed in a prior session; placeholder-ignored, so it is *referenced by path*, not added by this PR).
- **Catalog counts:** **UNCHANGED** by this PR. Do **not** touch `validate-catalog-counts` sites, `SUMMARY.md`, the README Module System table, the onboarding skill, or `discovery-to-composition.md`. (Those are Phase-2 work.)
- **Attribution:** every new file carries the SPDX dual-license header with `UncleNate@gmail.com` (NOT `nate@bdits.io`). Do **not** modify any `LICENSE-APACHE` canonical `http://` URLs.
- **Two diff-mode validators** (`validate-knowledge-redaction`, `validate-companions`) fire only with a base-ref arg; a 13/13 non-diff local pass is **not** a CI prediction. Task 7 runs the full 15 including both diff-mode validators against `main`.
- **Branch / merge posture:** work on a feature branch; push and open a PR. **Do not merge** — merge is the maintainer's call (Tier 3 ceiling).

## File map

| File | Action | Responsibility |
|---|---|---|
| `docs/opportunities/OPP-0043-domain-family-cybersecurity-decomposed.md` | Create | The Cybersecurity domain-family opportunity (ratifies family shape; promotes the OSINT wedge) |
| `docs/requirements/PRD-0022-cybersec-osint-maltego-wedge.md` | Create | The OSINT-wedge design contract (§10 block; Phase-2 scope) |
| `docs/opportunities/candidates.md` | Modify | Add the OPP-0043 index token (new dated cluster) + bump Last-Updated |
| `docs/README.md` | Modify | Add the PRD-0022 row (PRD index) and the OPP-0043 row (OPP index) |
| `docs/knowledge/shared-observations.md` | Modify | Append the Phase-1 distillation observation (PRD-0004 satisfier) + bump Last-Updated |
| `docs/project/change-log.md` | Modify | Add the audit-trail entry (newest-first) |

---

### Task 1: Create OPP-0043 (Cybersecurity domain family)

**Files:**
- Create: `docs/opportunities/OPP-0043-domain-family-cybersecurity-decomposed.md`

- [ ] **Step 1: Write the file verbatim**

```markdown
<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0043 — Cybersecurity Domain Family (decomposed `domains/cybersec-*`)

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-06-05
**Last Updated:** 2026-06-05 *(accepted — partial promotion: cybersec-osint promoted to a v1 wedge via PRD-0022; the deferred sibling modules (cybersec-red, cybersec-blue) remain proposed within this OPP; Purple is a documented composition, never a module; see Disposition)*
**Confidence:** high

---

## Thesis

The harness has no `domains/cybersec-*` (offensive / defensive security operations)
coverage. The two existing "security" surfaces govern adjacent but different
concerns — `management/security-static-analysis` (SAST — scanning generated code)
and `domains/aec-iso19650-5-security` (built-asset sensitivity) — neither of which
governs *security engagements*: authorized reconnaissance, adversary emulation, and
defensive detection. Cybersecurity is a large, standards-rich, governance-shaped
discipline (MITRE ATT&CK supplies a shared technique taxonomy; PTES supplies an
execution spine whose pre-engagement phase is where *authorization* is established).

It is also the **third built deep-domain vertical** after healthcare and AEC — a
third independent instance of the jurisdiction-neutral-core + forcing-artifact +
bias-guardrail primitives, plus one enrichment the first two could not surface: a
**single family-wide forcing artifact** (`engagement-charter.md`) shared across
not-yet-built sibling modules, versus healthcare/AEC where each module carried its
own artifact.

Apply the harness's per-concern module granularity and ship Cybersecurity as a
**decomposed family**. This OPP ratifies the family shape; PRD-0022 promotes the thin
single-module OSINT wedge and the dogfooded Maltego tool entry.

### Sub-modules (each per-activation, each gated by the family-wide charter)

| Sub-module | What it governs | Required artifact(s) | Disposition |
|---|---|---|---|
| `domains/cybersec-osint` | Reconnaissance + cyber threat intelligence — OSINT collection scope, sources/selectors/transforms, subjects-in-scope, intelligence handling | `engagement-charter.md`, `osint-collection-plan.md` | **Wedge (PRD-0022)** |
| `domains/cybersec-red` | Offensive / adversary emulation — ATT&CK technique execution against an authorized target | `engagement-charter.md`, `attack-plan.md` (proposed) | Deferred |
| `domains/cybersec-blue` | Defensive — detection + response, ATT&CK technique coverage and gaps | `engagement-charter.md`, `detection-coverage.md` (proposed) | Deferred |
| *Purple* | The red × blue feedback loop (emulate → detect → tune) | *(documented composition of cybersec-red and cybersec-blue — never a standalone module)* | Composition |

### The family-wide forcing artifact

`engagement-charter.md` (PTES pre-engagement, modeled once for the whole family):
authorization + validity window; scope / Rules of Engagement (in-scope, out-of-scope,
allowed techniques); a **declared lawful basis** (CFAA / CMA / contract / documented
consent — silence is not a basis); a dual-use posture acknowledgement (authorized
testing / CTF / research / defensive, not malicious); and intelligence
handling / minimization rules (the seam into `management/privacy-by-design`).

> **Bias guardrail.** Default-deny any collection or person-entity pivot the charter
> does not cover. The bias to guard against here is **scope creep** — OSINT tooling
> makes pivoting from an authorized target to an unrelated person trivial; the charter
> forces the boundary to be declared, and the (Phase-2) WARN validator surfaces
> activity with no charter behind it. This is the OSINT analog of the
> healthcare/AEC bias clauses.

### Templates

A new `platform/templates/cybersec/` directory. Two wedge templates ship with
PRD-0022 (`engagement-charter.md`, `osint-collection-plan.md`); deferred sub-modules
add their own when promoted.

### Convenience composition

A `platform/compositions/cybersec-osint-engagement.yaml` starter that activates
`cybersec-osint` together with `management/privacy-by-design` — the catalog's
**second** domain × cross-cutting composition (after AEC × privacy): investigative
collection scope versus personal-data handling for the people who appear in collected
intelligence.

### The Maltego tool entry (the concrete, dogfooded anchor)

Maltego is a real OSINT / investigations graph platform the maintainer operates (it
has an MCP server and a skill). It enters as a **governed tool entry**, not as the
module: a `TOOLS.md` entry carrying the stop-condition *"no person-entity transforms
without an active engagement charter"*, and a `platform/skills/harness-tools/SKILL.md`
Trust-Tier-Map row noting it composes with `cybersec-osint`. The tool entry is
**dogfooded** (live usage); the `cybersec-osint` module stays **catalog-only**
(predict-clean) — the one novel wrinkle versus healthcare/AEC.

## Origin / Evidence

- **Design spec:** `docs/superpowers/specs/2026-06-05-cybersecurity-osint-maltego-wedge-design.md`
  — the user-confirmed family decomposition (3 modules + Purple-as-composition),
  the MITRE ATT&CK + PTES anchor, the single family-wide `engagement-charter.md`
  (Half-enforced), and the tool/module dogfood split.
- **Backlog origin:** the OSINT / Maltego initiative (`project-maltego-osint` memory)
  — a real operator tool flagged for an OPP → PRD cycle, reframed mid-brainstorm from
  "add Maltego as a tool" into "establish a Cybersecurity domain family of which OSINT
  is one aspect."
- **Structural analog (grounding, not speculation).** OSINT is the **substrate**
  aspect (recon precedes emulation and detection) — the `cybersec-osint` ≈
  `aec-iso19650-im` ≈ `healthcare-fhir` position. The deferred siblings map cleanly:
  `cybersec-red` is the active/operational layer (≈ `aec-openbim-exchange`),
  `cybersec-blue` is the protective spine (≈ `aec-iso19650-5-security`). Purple is the
  *interaction* of red and blue, modeled as a composition exactly as AEC modeled
  security × privacy.
- **Internal precedent for module granularity.** As with `delivery/`, the
  `healthcare-*`, and the `aec-*` families, a consumer doing recon-only work does not
  need detection-coverage artifacts; bundling would force irrelevant required-artifact
  debt. OSINT / red / blue are distinct, observable operational concerns.

## Why Now

- **The harvest now has a candidate third built domain.** Healthcare + AEC already met
  the harvest precondition (two built domains + a cross-cutting reuse). Cybersecurity
  exceeds it and adds fresh evidence — a single family-wide forcing artifact shared
  across unbuilt siblings — strengthening the eventual "neutral-core +
  forcing-artifact + bias-guardrail" operating-principle generalization.
- **A real, dogfoodable tool anchors the vertical.** Unlike healthcare (brownfield) or
  AEC (standards-only), Cybersecurity enters through a tool the maintainer actually
  runs (Maltego), producing a concrete tool-entry surface alongside the catalog module.
- **Authorization is an unmodeled, high-stakes boundary.** OSINT and adversary-emulation
  techniques are dual-use; the harness has no artifact that forces an engagement to
  declare its authorization, scope, and lawful basis before activity. The charter is
  that artifact.

## Risks / Open Questions

- **Dual-use bias (cross-cutting, architectural).** The same techniques serve
  authorized testing and abuse. **Required before freezing any artifact:** the
  `engagement-charter.md` template default-denies un-authorized activity (no charter ⇒
  no authorized activity) and forces an explicit lawful-basis declaration. The
  harness's posture is defensive / authorized-testing only; the charter encodes that.
- **Scope creep in collection.** OSINT pivots are frictionless; the charter's
  subjects-in-scope and the Phase-2 WARN validator are the guardrail. Refine
  sensitive-path regexes against a real investigations layout when one is available.
- **Tooling vs standards anchor.** Maltego is a vendor tool; the wedge governs the
  *engagement* (charter + collection plan), not the Maltego API. The tool entry carries
  the stop-condition; the module governs the artifacts.
- **No grounded consumer codebase yet.** Like AEC, the wedge is grounded in a
  standard-shaped discipline (ATT&CK / PTES) + a real operator tool, not a brownfield
  onboarding. Initial bias: ship the charter-anchored wedge; refine sensitive-path
  regexes against a real engagement repo when one onboards.

## Disposition

**Accepted 2026-06-05 — partial promotion.** The OSINT wedge sub-module —
`domains/cybersec-osint` — is promoted to a v1 wedge (see PRD-0022). The deferred
sibling sub-modules (`cybersec-red`, `cybersec-blue`) stay `proposed` pending demand.
Purple remains a documented composition, never a standalone module.

## Promotion

Promoted sub-module: `domains/cybersec-osint` (PRD-0022, 2026-06-05). The single
family-wide `engagement-charter.md` (shared across unbuilt siblings) and the
tool-entry / catalog-module dogfood split are the enrichments slated for the
deep-domain framework harvest (a separate later cycle; see
`project-deep-industry-domains` memory).

## Related

- Predecessor verticals: [OPP-0013](OPP-0013-domain-family-healthcare-decomposed.md) (first built domain), [OPP-0039](OPP-0039-domain-family-aec-decomposed.md) (second built domain)
- Cross-cutting reused by the OSINT wedge: `management/privacy-by-design` (PRD-0018, shipped)
- Adjacent "security" surfaces (disambiguated): `management/security-static-analysis` (SAST), `domains/aec-iso19650-5-security` (built-asset sensitivity)
- Design spec: `docs/superpowers/specs/2026-06-05-cybersecurity-osint-maltego-wedge-design.md`
- Wedge design contract: [PRD-0022](../requirements/PRD-0022-cybersec-osint-maltego-wedge.md)
```

- [ ] **Step 2: Verify the file is well-formed**

Run: `head -13 docs/opportunities/OPP-0043-domain-family-cybersecurity-decomposed.md`
Expected: SPDX header (UncleNate@gmail.com) then `# OPP-0043 — Cybersecurity Domain Family ...`

(No commit yet — commit once with all artifacts in Task 7.)

---

### Task 2: Create PRD-0022 (OSINT / Maltego wedge design contract)

**Files:**
- Create: `docs/requirements/PRD-0022-cybersec-osint-maltego-wedge.md`

- [ ] **Step 1: Write the file verbatim**

```markdown
<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0022 — Cybersecurity OSINT / Maltego Wedge

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-05 | **Review Cycle:** On-change

**Status:** Proposed
**Date:** 2026-06-05
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- **Origin OPP:** [OPP-0043](../opportunities/OPP-0043-domain-family-cybersecurity-decomposed.md) —
  Cybersecurity domain family (decomposed). This PRD is a partial promotion:
  `cybersec-osint` only. The two deferred OPP-0043 sub-modules (`cybersec-red`,
  `cybersec-blue`) stay `proposed`; Purple is a documented composition.
- **Design context:** `docs/superpowers/specs/2026-06-05-cybersecurity-osint-maltego-wedge-design.md` —
  the brainstorming spec grounding this PRD (family map, charter spine, dogfood split).
- **Predecessor verticals:** [PRD-0017](PRD-0017-healthcare-fhir-smart-wedge.md) and
  [PRD-0019](PRD-0019-aec-iso19650-openbim-wedge.md) — the first two deep-domain
  wedges; this PRD mirrors their two-phase structure and §10 vocabulary.
- **Cross-cutting reused:** [PRD-0018](PRD-0018-privacy-by-design.md) —
  `management/privacy-by-design`; the OSINT wedge composes with it (investigative
  collection scope vs personal-data handling). This is the catalog's second domain ×
  cross-cutting composition.
- **Related operating principles:**
  - [§ 9 Split Design from Implementation](../operating-principles.md#9-split-design-from-implementation) —
    this PRD ships the design contract; the implementing PR ships the module,
    templates, validator, tool entries, composition, diagram, and propagation.
  - [§ 10 Classify Claims Before Enforcing Them](../operating-principles.md#10-classify-claims-before-enforcing-them) —
    see §10 Claim Classification block below.

## Overview

The harness has no `domains/cybersec-*` coverage of security *engagements* —
authorized reconnaissance, adversary emulation, and defensive detection — distinct
from the existing SAST (`management/security-static-analysis`) and built-asset
(`aec-iso19650-5-security`) "security" surfaces. This PRD specifies a thin
single-module OSINT wedge (`domains/cybersec-osint`), its family-wide
`engagement-charter.md` forcing artifact, a **Half-enforced** module-gated WARN
validator, the dogfooded Maltego tool entry, the privacy composition, a diagram, and a
sample composition. v1 is **design-only** per § 9; the implementing PR (Phase 2) builds
the scaffolding.

The wedge is intentionally minimal — the deferred OPP-0043 sub-modules (`cybersec-red`,
`cybersec-blue`) and Purple (a composition) are out of scope — so the implementing PR is
a single bounded unit and the family primitives emerge from a working OSINT module
rather than speculation.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits the Phase-2 implementing PR to delivering:

- Ship `platform/profiles/domains/cybersec-osint/` (`module.yaml` + `README.md`)
  declaring `type: domain`, `dependsOn: [kernel/base]`, the two required artifacts
  (`engagement-charter.md`, `osint-collection-plan.md`), sensitive paths, companion
  rules, and the collection-scope review gate.
- Ship `platform/templates/cybersec/` with two tokenized templates:
  `engagement-charter.md` (carrying the dual-use bias guardrail + lawful-basis prompt)
  and `osint-collection-plan.md`.
- Ship a **Half-enforced** module-gated WARN validator (provisionally
  `validate-engagement-charter.sh`, validator chain 15→16) that fires only when a
  `cybersec-*` module is active and the charter is missing/incomplete — enforcing the
  charter's *presence and shape*, warning on gaps. Half-enforced because the binding
  signal (is the activity actually authorized?) lives in the consumer's process.
- Ship the **Maltego tool entry**: a `TOOLS.md` entry carrying the stop-condition *"no
  person-entity transforms without an active engagement charter"*, and a
  `platform/skills/harness-tools/SKILL.md` Trust-Tier-Map row noting it composes with
  `cybersec-osint`. This surface is **dogfooded** (real tool, live usage).
- **Document the security × privacy composition boundary** in the `cybersec-osint`
  README and the `engagement-charter.md` template (investigative collection scope vs
  personal-data handling; the charter's intelligence-handling section references the
  `privacy-profile`'s declared regime).
- Ship a sample composition (`platform/compositions/cybersec-osint-engagement.yaml`)
  activating `cybersec-osint` + `management/privacy-by-design`.
- Add one Cybersecurity domain family diagram (`## 14.`) to
  `docs/architecture/diagrams.md`.
- Close the discoverability gap: the module appears in `SUMMARY.md`, the catalog
  `README.md` Module table, `harness-onboarding/SKILL.md`, and
  `discovery-to-composition.md` Step 6.
- Pass the full validator suite (16 after the new validator) with the module on disk —
  the harness does not *activate* `cybersec-osint` (predict-clean), while the Maltego
  tool entry is dogfooded.

**Non-Goals** — explicitly out of scope:

- **The deferred OPP-0043 sub-modules** (`cybersec-red`, `cybersec-blue`) and **Purple**
  (a documented composition, never a standalone module). Each module is a future PRD.
- **A Maltego integration build** (no transform-server code, no MCP wiring). Maltego
  enters as a governed tool entry, not as software this repo ships.
- **"Activating" `cybersec-osint` on this repo.** The module is catalog-only; only the
  Maltego tool entry is dogfooded.
- **The abstract deep-domain framework operating-principle / ADR.** Authored in the
  later harvest pass once the third domain ships.
- **A live transform allow/deny enforcement mechanism.** The Phase-2 validator enforces
  charter *presence/shape*; it does not intercept Maltego transforms at runtime.

## §10 Claim Classification

Per the [§10 operating principle](../operating-principles.md#10-classify-claims-before-enforcing-them),
this PRD names each load-bearing claim and its enforcement mechanism (mechanisms ship in Phase 2):

| Claim | Class | Mechanism |
|-------|-------|-----------|
| Required artifacts exist when `cybersec-osint` is active | Enforced | `validate-required-artifacts.sh` |
| Sensitive-path edits (OSINT collection surfaces) pair with a governance document | Enforced | `validate-companions.sh` |
| The `cybersec-osint → kernel/base` dependency resolves cleanly | Enforced | `validate-module-graph.sh` |
| Sensitive paths are companion-rule covered | Enforced | `validate-sensitive-paths.sh` (per-module self-coverage) |
| An active engagement carries a present, well-shaped `engagement-charter.md` | Half-enforced | `validate-engagement-charter.sh` (module-gated WARN; consumer CI cooperation required) |
| The charter declares a lawful basis, scope/RoE, and dual-use posture | Half-enforced | `validate-engagement-charter.sh` (shape check) + bias-guardrail text in the `engagement-charter.md` template |
| No person-entity transform is run without an active charter (Maltego) | Asserted-only | TOOLS.md stop-condition + tool-entry review gate |
| Collection stays within subjects-in-scope | Asserted-only | review gate on `osint-collection-plan.md` scope edits |
| Investigative collection and personal-data privacy are governed without overlap or gap | Asserted-only | documented composition boundary (OSINT README + charter references the `privacy-profile` regime) |

**Claims explicitly NOT converted by v1** (remain Asserted-only):

- **The engagement is actually authorized.** The validator checks that a charter exists
  and declares an authorization + lawful basis; it cannot verify the declared
  authorization is genuine. That is a human review-gate behavior.
- **Collected intelligence is lawfully obtained and minimized.** v1 requires the
  charter's handling section exists and references a privacy regime; it does not audit
  the actual collection.
- **A given Maltego transform is in-scope.** The TOOLS.md stop-condition is an
  operator instruction, not a runtime interceptor.

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Harness maintainer | Repository's primary owner | The third deep-domain wedge lands, adding a single family-wide forcing artifact and a dogfooded tool-entry / catalog-module split to the harvest evidence. |
| Security-engagement consumer | A team adopting auto-harness for authorized OSINT / pentest / threat-intel work | A catalog module with a clear charter requirement; a WARN validator that surfaces missing authorization; a Maltego stop-condition; discoverability from onboarding. |
| Harness contributor | Outside contributor adding `cybersec-red`/`cybersec-blue` later | A concrete precedent for the family-wide charter and the per-aspect module pattern. |
| Maltego operator (the maintainer) | Runs Maltego for investigations | A governed tool entry whose stop-condition encodes the default-deny charter rule in the workflow they actually use. |

## User Stories

- As a **security-engagement consumer**, I want to activate `domains/cybersec-osint`
  and have the harness require `engagement-charter.md` and `osint-collection-plan.md`,
  so contributors cannot start collection without a declared authorization, scope, and
  lawful basis.
- As a **security-engagement consumer**, I want a WARN validator that fires when
  `cybersec-osint` is active but the charter is missing or incomplete, so missing
  authorization is surfaced in CI rather than discovered after the fact.
- As a **Maltego operator**, I want the TOOLS.md entry to carry an explicit
  stop-condition (*no person-entity transforms without an active charter*), so the
  default-deny rule lives in the tool surface I use daily.
- As a **security-engagement consumer handling personal data**, I want `cybersec-osint`
  to compose with `management/privacy-by-design`, so collection scope and personal-data
  handling are both governed without a gap.
- As a **harness maintainer**, I want the module to pass the full validator suite clean
  (module present, not activated), with only the one new module-gated WARN validator
  added, so the wedge lands without harness-side churn.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | `domains/cybersec-osint` scaffolding | `module.yaml` + `README.md` at the module path. `module.yaml` declares `type: domain`, `dependsOn: [kernel/base]`, `requiredArtifacts: [docs/cybersec/engagement-charter.md, docs/cybersec/osint-collection-plan.md]`, sensitive paths, companion rules, and the collection-scope review gate. README documents the security × privacy composition boundary. | The substrate aspect (≈ `aec-iso19650-im`). |
| FR-002 | `platform/templates/cybersec/` with two templates | `engagement-charter.md` (dual-use bias guardrail + lawful-basis prompt + intelligence-handling section referencing the privacy regime) and `osint-collection-plan.md` (sources, selectors, transforms-to-run, subjects-in-scope). Both carry tokenized SPDX headers. | Bias-guardrail text: default-deny un-authorized activity; force an explicit lawful-basis declaration. |
| FR-003 | Half-enforced charter validator | `validate-engagement-charter.sh` — module-gated (fires only when a `cybersec-*` module is active), WARN-posture, asserting the charter exists and carries its required sections. Validator chain 15→16. Harness's own suite predict-clean (module not activated). | §10: Half-enforced. Confirm new-validator vs extend-existing at implementation. |
| FR-004 | Maltego tool entry | `TOOLS.md` entry with the stop-condition *"no person-entity transforms without an active engagement charter"*; `harness-tools/SKILL.md` Trust-Tier-Map row noting composition with `cybersec-osint`. | Dogfooded surface (real tool). |
| FR-005 | Sample composition | `platform/compositions/cybersec-osint-engagement.yaml` activates `cybersec-osint` + `management/privacy-by-design`; listed in `platform/compositions/README.md` and root `README.md`. | Second domain × cross-cutting composition. |
| FR-006 | Cybersecurity domain family diagram | One diagram `## 14. Cybersecurity Domain Family` in `docs/architecture/diagrams.md`: `cybersec-osint` (built) + `cybersec-red`/`cybersec-blue` (deferred) under the shared `engagement-charter`, Purple as the red×blue composition edge, and the privacy-by-design composition edge. | Index table updated 13→14; prose "Thirteen"→"Fourteen". |
| FR-007 | Discoverability propagation | `cybersec-osint` appears in `SUMMARY.md`, catalog `README.md` Module table, `harness-onboarding/SKILL.md` domain catalog, and `discovery-to-composition.md` Step 6. | Companion-rule propagation per `CLAUDE.md`. |
| FR-008 | Catalog-count propagation | All catalog-count sites updated for: +1 module, +2 templates, +1 diagram, +1 validator. `validate-catalog-counts.sh` and `validate-list-completeness.sh` exit 0. | Exact site list enumerated in the Phase-2 plan. |
| FR-009 | Full validator suite passes | All validators (16 after FR-003) exit 0 with the module on disk; harness does not activate it (predict-clean). | The Maltego tool entry is dogfooded; the module is catalog-only. |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-S01 | One distillation observation in `docs/knowledge/shared-observations.md` | Phase-2 captures the third-domain harvest evidence: the single family-wide forcing artifact (shared across unbuilt siblings) and the tool-entry / catalog-module dogfood split. | A separate Phase-1 distillation observation ships in *this* PR per the PRD-0004 rule fired by creating OPP-0043. |
| FR-S02 | "When to activate" guidance in the module README | Names the OSINT concern it governs and when a consumer activates it (authorized recon / threat-intel engagements only). | Reduces activation friction; reinforces the authorized-only posture. |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| `cybersec-red`, `cybersec-blue` modules | Deferred OPP-0043 sub-modules | Per OPP-0043 / consumer demand |
| Purple as a standalone module | It is the interaction of red and blue; modeled as a composition | Never (composition by design) |
| Maltego transform-server / MCP integration build | Vendor tooling; the wedge governs the engagement, not the API | If a consumer wires Maltego transforms into CI |
| Runtime transform allow/deny enforcement | v1 enforces charter presence/shape | If an interception seam proves mechanizable |
| Abstract deep-domain framework operating-principle | Authored post-wedge in the harvest pass | After the third domain ships and validates |

## Implementation Deferral

Per § 9, this PRD ships the design contract; the implementing PR (Phase 2) adds the
module, templates, validator, tool entries, composition, diagram, discoverability, and
the Phase-2 distillation observation.

| Deferred implementation | Deferred to | Why deferred |
|-------------------------|-------------|--------------|
| `cybersec-osint` module YAML + README | Implementing PR (Phase 2) | Design-first per § 9 |
| Two cybersec templates | Implementing PR (Phase 2) | Same |
| `validate-engagement-charter.sh` (Half-enforced) | Implementing PR (Phase 2) | Same |
| Maltego TOOLS.md + harness-tools entries | Implementing PR (Phase 2) | Same |
| Composition + diagram + discoverability + counts | Implementing PR (Phase 2) | Same |
| Phase-2 distillation observation (FR-S01) | Implementing PR (Phase 2) | Captured during implementation |
| Abstract framework operating-principle | Post-wedge harvest pass | Must be grounded in three shipped domains first |

## Technical Constraints

- **Module type: `domain`** — already accepted by `validate-module-graph.sh`. No
  validator patch needed for the type.
- **Catalog-only module.** `cybersec-osint` is NOT added to `harness.manifest.yaml`;
  the harness's own suite stays predict-clean. The Maltego tool entry *is* dogfooded.
- **Per-module sensitive-path self-coverage.** The module's `sensitivePaths` must be
  fully overlapped by its own `companionRules.triggerPaths` so a consumer activating it
  passes `validate-sensitive-paths.sh`.
- **New validator is module-gated.** `validate-engagement-charter.sh` must no-op (exit
  0) when no `cybersec-*` module is active, so the harness's own CI stays green.
- **Bash 3.2 + system Ruby** — no new dependencies.
- **SPDX dual-license headers** on all new files; `UncleNate@gmail.com`.

## CI/CD Gates

| Gate | Required? | Notes |
|------|-----------|-------|
| markdownlint + shellcheck | Yes | All new `.md` pass; the new validator passes shellcheck |
| Full validator suite exits 0 | Yes | 16 validators after FR-003; predict-clean on the harness's own CI |
| `validate-catalog-counts.sh` correct after bumps | Yes | Module/templates/diagram/validator bumped exactly |
| `validate-list-completeness.sh` exits 0 | Yes | Module in SUMMARY; templates dir indexed; composition in both READMEs |
| Change-log updated | Yes | One entry per PR |

## Success Metrics

| KPI | Target | How measured |
|-----|--------|-------------|
| Dogfood pass rate at implementing PR | 100% — full suite passes (module present, not activated) | Implementing PR CI |
| Sample composition validates clean | `cybersec-osint` + privacy active; suite exits 0 | `cybersec-osint-engagement.yaml` |
| Charter validator behaves | WARN when active+missing; no-op when no `cybersec-*` active | Validator fixture test (`--scan-file` seam) |
| Discoverability coverage | Module reachable from onboarding skill, SUMMARY, discovery-to-composition | Spot-check post-merge |
| Maltego stop-condition propagation | TOOLS.md + harness-tools carry the default-deny rule verbatim | Entry review |

## Dependencies

- `platform/validators/lib/harness_registry.rb` — module enumeration (existing).
- `management/privacy-by-design` (shipped PRD-0018) — the cross-cutting the OSINT
  module composes with.
- `platform/profiles/domains/healthcare-*` and `domains/aec-*` — the structural
  precedents.
- `platform/skills/harness-tools/` (gated on `agents/openclaw`) — host of the Maltego
  Trust-Tier-Map row.
- Bash 3.2 + system Ruby.

## Verification

The wedge is verified, not asserted (at Phase 2):

- All validators (16) pass with the module on disk (module-graph resolves the
  dependency; required-artifacts, companions, sensitive-paths, the new charter
  validator, catalog-counts, list-completeness, doc-references, and the rest).
- The new validator no-ops when no `cybersec-*` module is active (harness CI green) and
  WARNs on a fixture where the module is active with a missing charter
  (`--scan-file` seam).
- The sample composition's dependency closure
  (`cybersec-osint → kernel/base`; `management/privacy-by-design`) resolves.
- markdownlint passes on all new and changed markdown; shellcheck passes the validator.

## Open Questions

- [ ] **New validator vs extend existing** — whether `validate-engagement-charter.sh`
  is a new validator or an extension of an existing module-gated validator. **Bias:
  new, to keep the charter concern separable from privacy; confirm the §10 posture
  wording at implementation.**
- [ ] **Exact sensitive-path regexes** — validated against a real investigations layout
  at implementation. Design spec names candidates (`^osint/`, substrings `subjects`,
  `dossier`, `recon`). **Bias: use the spec candidates as v1; refine if false
  positives appear.**
- [ ] **`cybersec-osint` dependency on privacy** — `dependsOn` vs compose-with.
  **Bias: compose-with (no hard dependency), documented in both the OSINT README and
  the `cybersec-osint-engagement.yaml` composition** (mirrors the AEC × privacy
  resolution).
- [ ] **Final Maltego stop-condition wording** in TOOLS.md — reviewed with the
  maintainer before Phase 2 lands.
```

- [ ] **Step 2: Verify the file is well-formed**

Run: `head -15 docs/requirements/PRD-0022-cybersec-osint-maltego-wedge.md`
Expected: SPDX header then `# PRD-0022 — Cybersecurity OSINT / Maltego Wedge` and the version/status lines.

---

### Task 3: Add the OPP-0043 token to `candidates.md`

Every OPP needs a `candidates.md` index token. Add a new dated cluster (cluster headings are organizational — no ADR needed, per the file's own scope note) and bump Last-Updated.

**Files:**
- Modify: `docs/opportunities/candidates.md`

- [ ] **Step 1: Bump the Last-Updated line**

Replace (line 9):

```markdown
**Owner:** @unclenate | **Last Updated:** 2026-05-24 *(added Tula cluster: OPP-0018..0022 + OPP-0013/0016 augmentation)*
```

with:

```markdown
**Owner:** @unclenate | **Last Updated:** 2026-06-09 *(added Cybersecurity deep-domain cluster: OPP-0043)*
```

(The `2026-05-24` Find anchor above is still current on main — the maintainer's series added clusters lower in the file without bumping this top line.)

- [ ] **Step 2: Insert the new cluster** immediately before the `### Canonical direction & strategic alignment` heading (currently around line 485 — re-verify; the maintainer's OPP-0040/0041/0042 clusters pushed it down). Insert:

```markdown
### Cybersecurity deep-domain vertical — OSINT / Maltego (2026-06-05)

The third built deep-domain vertical after healthcare (OPP-0013) and AEC
(OPP-0039). Standards/tool-anchored (MITRE ATT&CK + PTES, anchored on the
real operator tool Maltego) rather than brownfield-derived. Adds a single
family-wide forcing artifact (`engagement-charter.md`, shared across unbuilt
siblings) and a tool-entry (dogfooded) / catalog-module (predict-clean) split.

- [OPP-0043](OPP-0043-domain-family-cybersecurity-decomposed.md) *(accepted 2026-06-05; PRD-0022; partial promotion — cybersec-osint)*
  — Decomposed `domains/cybersec-*` family (`cybersec-osint` built as a v1
  wedge; `cybersec-red` + `cybersec-blue` deferred; Purple is a documented
  red × blue composition, never a module) + `templates/cybersec/` +
  `cybersec-osint-engagement.yaml` composition + a Half-enforced
  `engagement-charter` WARN validator + the dogfooded Maltego tool entry.
  Disambiguated from `management/security-static-analysis` (SAST) and
  `aec-iso19650-5-security` (built-asset sensitivity). Composes with
  `management/privacy-by-design` — the catalog's second domain × cross-cutting
  composition.

```

- [ ] **Step 2: Verify**

Run: `grep -n "OPP-0043" docs/opportunities/candidates.md`
Expected: one match in the new cluster.

---

### Task 4: Add the index rows to `docs/README.md`

Two tables: the PRD index (add the PRD-0022 row after the PRD-0021 row — the current last PRD row) and the OPP index (add the OPP-0043 row after the OPP-0042 row — the current last OPP row). The maintainer's #103–#109 series added PRD-0020/0021 and OPP-0040/0041/0042, so insert after those, not after the AEC rows.

**Files:**
- Modify: `docs/README.md`

- [ ] **Step 1: Add the PRD-0022 row** after the PRD-0021 row (currently line 93 — re-verify before editing):

Find:

```markdown
| [0021](requirements/PRD-0021-greenfield-onboarding-conservatism.md) | Greenfield Onboarding Conservatism — Route Contextless Greenfield to Discovery | Accepted | [OPP-0042](opportunities/OPP-0042-greenfield-onboarding-conservatism.md) |
```

Insert the following line immediately after it:

```markdown
| [0022](requirements/PRD-0022-cybersec-osint-maltego-wedge.md) | Cybersecurity OSINT / Maltego Wedge | Proposed | [OPP-0043](opportunities/OPP-0043-domain-family-cybersecurity-decomposed.md) |
```

- [ ] **Step 2: Add the OPP-0043 row** after the OPP-0042 row (currently line 146 — re-verify before editing):

Find:

```markdown
| [0042](opportunities/OPP-0042-greenfield-onboarding-conservatism.md) | Greenfield Onboarding Conservatism: Route Contextless Greenfield to Discovery | accepted |
```

Insert the following line immediately after it:

```markdown
| [0043](opportunities/OPP-0043-domain-family-cybersecurity-decomposed.md) | Cybersecurity Domain Family (decomposed) | accepted (partial promotion) |
```

- [ ] **Step 3: Verify**

Run: `grep -nE "PRD-0022|OPP-0043" docs/README.md`
Expected: two matches (one PRD-index row, one OPP-index row).

---

### Task 5: Append the Phase-1 distillation observation (PRD-0004 satisfier)

Creating `OPP-0043` fires the PRD-0004 distillation companion rule, which requires a `shared-observations.md` (or `operating-principles.md`) entry **in this PR** — change-log does NOT satisfy it. The observation must be substantive (advance the harvest evidence), not restate the OPP.

**Files:**
- Modify: `docs/knowledge/shared-observations.md`

- [ ] **Step 1: Bump the Last-Updated line** (currently **line 5** — re-verify; the maintainer's series moved it). Replace the existing `**Last Updated:** 2026-06-07 *(Greenfield conservatism (PRD-0021): ...)*` line (the current head, which carries a running `Prior:` chain) with the following — note the new entry **prepends** the cybersec note and **preserves the entire prior chain**:

```markdown
**Last Updated:** 2026-06-09 *(Cybersecurity wedge Phase 1: OPP-0043 + PRD-0022 design contract; appended the third-built-domain observation (a deep-domain vertical can be anchored on a real operator tool, producing a single family-wide forcing artifact shared across unbuilt siblings and a tool-entry/catalog-module dogfood split), satisfying the PRD-0004 distillation rule fired by the new `docs/opportunities/OPP-0043-domain-family-cybersecurity-decomposed.md`. Prior: 2026-06-07 greenfield conservatism (PRD-0021); 2026-06-06 bootstrap hardening (PRD-0020); 2026-06-05 onboarding safety + install prerequisites; 2026-06-04 AEC wedge Phase 2; the OPP-0038 attribution-boundary observation; and consumer-adoption observations from the fork-held-consumer pin-bump session.)*
```

- [ ] **Step 2: Append the observation** at the end of the file (after the last `### ...` entry):

```markdown

### A deep-domain vertical can be anchored on a real operator tool — producing a single family-wide forcing artifact and a tool-entry / catalog-module dogfood split

- **Context:** OPP-0043 designates Cybersecurity as the third built deep-domain vertical and promotes a single-module OSINT wedge (`domains/cybersec-osint`, PRD-0022). Healthcare (OPP-0013) was grounded in two consumer codebases; AEC (OPP-0039) in a standard + research brief. Cybersecurity is grounded differently again — in a standard-shaped discipline (MITRE ATT&CK + PTES) **anchored on a real tool the maintainer operates** (Maltego, which has an MCP server and a skill).
- **Observation:** A real operator tool can be the concrete anchor for a deep-domain vertical, and doing so surfaces two patterns the first two domains could not. First, a **single family-wide forcing artifact**: `engagement-charter.md` (PTES pre-engagement — authorization, scope/RoE, lawful basis, dual-use posture, intelligence handling) is shared across `cybersec-osint` and the not-yet-built `cybersec-red`/`cybersec-blue` siblings, versus healthcare/AEC where each module carried its own artifact — the forcing-artifact primitive scales from per-module to per-family without changing the bias-guardrail mechanism (here, default-deny un-authorized activity / scope creep). Second, a **tool-entry / catalog-module dogfood split**: the Maltego `TOOLS.md` entry is dogfooded (live usage, with a default-deny stop-condition), while the `cybersec-osint` module stays catalog-only (predict-clean) — the tool half is real, the module half is composable-but-unactivated.
- **Implication:** With healthcare and AEC already meeting the harvest precondition, Cybersecurity adds two generalizable patterns for the eventual operating-principle: (1) a forcing artifact can be scoped per-family (not just per-module) when sibling modules share an authorization/scope spine, and (2) a vertical anchored on an operator tool naturally splits into a dogfooded tool surface plus a catalog module, which keeps the harness's own CI predict-clean while still exercising the tool in practice. Future tool-anchored verticals (e.g., other investigation/observability platforms) can copy both. The harvest remains a separate, maintainer-gated cycle. See [[project-deep-industry-domains]] and [[project-maltego-osint]].
- **Confidence:** medium. One instance (Cybersecurity/OPP-0043), but it contrasts cleanly with both prior grounding patterns (code-grounded healthcare, standard-grounded AEC) and the family-wide-artifact + dogfood-split patterns are concrete and copyable.
- **Severity:** architecture
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-05 (Cybersecurity wedge Phase 1; satisfies the PRD-0004 distillation rule fired by the new `docs/opportunities/OPP-0043-domain-family-cybersecurity-decomposed.md`; substantive connection — names the tool-anchored grounding pattern and the per-family forcing artifact the third domain surfaces over the first two, advancing the harvest evidence rather than restating the OPP)
```

- [ ] **Step 3: Verify**

Run: `grep -n "anchored on a real operator tool" docs/knowledge/shared-observations.md` and `head -5 docs/knowledge/shared-observations.md | grep "Last Updated"`
Expected: the new `### ...` heading appears once near the tail; the Last-Updated line carries `2026-06-09` (file-edit date) while the observation's own `Contributed by` line carries `2026-06-05` (authored date) — the chain's `Prior:` list is preserved.

---

### Task 6: Add the change-log audit-trail entry

The OPP audit-trail floor requires a `change-log.md` entry. Newest-first: insert immediately after the `---` on line 12, before the current first `## ` entry.

**Files:**
- Modify: `docs/project/change-log.md`

- [ ] **Step 1: Insert the entry** after the `---` separator on line 12 (before the current first entry `## 2026-06-07 — QA + documentation pass...` — re-verify the head entry before editing). The entry is dated **2026-06-09** (the filing date) so it sorts correctly at the top of the newest-first log; the OPP/PRD artifacts themselves retain their 2026-06-05 design date.

```markdown

## 2026-06-09 — OPP-0043 + PRD-0022 filed: Cybersecurity OSINT / Maltego wedge (design-only)

Phase-1 design contract for the **third deep-domain vertical** (Cybersecurity),
landed as a pure-docs PR per § 9 (split design from implementation). **OPP-0043**
ratifies the decomposed `domains/cybersec-*` family — `cybersec-osint` (recon + CTI,
promoted to a v1 wedge), `cybersec-red` and `cybersec-blue` (deferred), and Purple
(a documented red × blue composition, never a module) — anchored on MITRE ATT&CK +
PTES and on the real operator tool Maltego. **PRD-0022** specifies the OSINT wedge:
the module, a single family-wide `engagement-charter.md` forcing artifact, a
Half-enforced module-gated WARN validator, the dogfooded Maltego tool entry, and the
`management/privacy-by-design` composition (the catalog's second domain × cross-cutting
composition). All implementation — module, templates, validator (chain 15→16), tool
entries, diagram (#14), composition, and catalog-count propagation — is **deferred to
Phase 2** per § 9.

The family name `domains/cybersec-*` is deliberately disambiguated from the two
existing "security" surfaces: `management/security-static-analysis` (SAST) and
`domains/aec-iso19650-5-security` (built-asset sensitivity). The PRD-0004 distillation
rule (fired by creating OPP-0043) is satisfied by the third-built-domain observation
appended to `docs/knowledge/shared-observations.md` in the same PR. Design evidence:
`docs/superpowers/specs/2026-06-05-cybersecurity-osint-maltego-wedge-design.md`.
```

- [ ] **Step 2: Verify**

Run: `grep -n "OPP-0043" docs/project/change-log.md`
Expected: one match near the top of the file (newest-first).

---

### Task 7: Validate, commit, push, open PR (no merge)

**Files:** none new — verification + git.

- [ ] **Step 1: Run the full 15-validator suite, including both diff-mode validators against `main`**

Run (from repo root):

```bash
for v in manifest "module-graph" ; do bash platform/validators/validate-$v.sh harness.manifest.yaml; done
bash platform/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash platform/validators/validate-placeholders.sh .
bash platform/validators/validate-agent-pack.sh harness.manifest.yaml .
bash platform/validators/validate-doc-references.sh .
bash platform/validators/validate-catalog-counts.sh .
bash platform/validators/validate-list-completeness.sh .
bash platform/validators/validate-trust-tier.sh harness.manifest.yaml .
bash platform/validators/validate-sensitive-paths.sh harness.manifest.yaml .
bash platform/validators/validate-skill-content.sh harness.manifest.yaml .
bash platform/validators/validate-sast-coverage.sh harness.manifest.yaml .
bash platform/validators/validate-privacy-by-design.sh harness.manifest.yaml .
bash platform/validators/validate-knowledge-redaction.sh . main
bash platform/validators/validate-companions.sh harness.manifest.yaml . main
```

Expected: every validator exits 0. The diff-mode pair (`knowledge-redaction`, `companions`) is the load-bearing check — the change-log + shared-observations + OPP/PRD additions must satisfy the companion rules. If `validate-companions` reds, read its message: it names the missing companion (most likely a distillation or audit-trail satisfier) — fix forward by adding it, do not weaken the rule.

- [ ] **Step 2: Run markdownlint exactly as CI does**

Run: `npx markdownlint-cli2`
Expected: zero errors. (Plans and specs are excluded by config; the OPP/PRD/README/change-log/observations files are NOT — they must pass. Watch the thrice-confirmed MD004/MD012/MD018/MD032/MD022 trips and the soft-wrap-`+` MD-list gotcha.)

- [ ] **Step 3: Create the feature branch, stage, and commit**

```bash
git checkout -b cybersec-osint-wedge-phase1
git add docs/opportunities/OPP-0043-domain-family-cybersecurity-decomposed.md \
        docs/requirements/PRD-0022-cybersec-osint-maltego-wedge.md \
        docs/opportunities/candidates.md \
        docs/README.md \
        docs/knowledge/shared-observations.md \
        docs/project/change-log.md \
        docs/superpowers/specs/2026-06-05-cybersecurity-osint-maltego-wedge-design.md \
        docs/superpowers/plans/2026-06-05-cybersecurity-osint-maltego-wedge-phase1.md
git status --short
```

Expected staged set: the 6 governance files + the (previously untracked) design spec + this plan. (The spec and plan live under placeholder-ignored paths but should still be committed to the tree as the design/plan of record — confirm `git status` shows them staged, not ignored.)

```bash
git commit -m "$(cat <<'EOF'
[cybersec wedge] OPP-0043 + PRD-0022 — third deep-domain vertical (design-only)

Phase 1 design contract for the Cybersecurity deep-domain family and its OSINT
wedge. OPP-0043 ratifies the decomposed domains/cybersec-* family (osint built;
red/blue deferred; Purple as composition); PRD-0022 specifies the OSINT wedge
(engagement-charter forcing artifact, Half-enforced WARN validator, dogfooded
Maltego tool entry, privacy-by-design composition) with a §10 Claim
Classification block. Implementation deferred to Phase 2 per § 9.

Satisfies the PRD-0004 distillation rule (OPP-0043 creation) via the
third-built-domain observation in shared-observations.md, and the OPP
audit-trail floor via the change-log entry.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

- [ ] **Step 4: Re-run the full suite on the committed state** (post-commit, pre-push — the standing rule)

Run the Step-1 block again. Expected: still 15/15 green. If anything that was green is now red, the commit is broken — fix forward, amend, re-verify. Do not push red.

- [ ] **Step 5: Push and open the PR (do NOT merge)**

```bash
git push -u origin cybersec-osint-wedge-phase1
gh pr create --title "[cybersec wedge] OPP-0043 + PRD-0022 — third deep-domain vertical (design-only)" --body "$(cat <<'EOF'
## Summary

Phase 1 (design-only, per operating-principle § 9) of the **third deep-domain vertical** — Cybersecurity — and its first wedge (OSINT), anchored on the real operator tool **Maltego** (MITRE ATT&CK + PTES discipline).

- **OPP-0043** — ratifies the decomposed `domains/cybersec-*` family: `cybersec-osint` (built as a v1 wedge), `cybersec-red` + `cybersec-blue` (deferred), Purple (a documented red × blue composition, never a module). Disambiguated from `management/security-static-analysis` (SAST) and `aec-iso19650-5-security` (built-asset sensitivity).
- **PRD-0022** — the OSINT wedge design contract (with a §10 Claim Classification block): the module, a **single family-wide `engagement-charter.md`** forcing artifact (authorization / scope / lawful basis / dual-use posture / intelligence handling), a **Half-enforced** module-gated WARN validator, the **dogfooded Maltego tool entry** (stop-condition: no person-entity transforms without an active charter), and the **`management/privacy-by-design` composition** (the catalog's second domain × cross-cutting composition).

All implementation — module, templates, validator (chain 15→16), Maltego entries, diagram #14, composition, catalog-count propagation — is **deferred to Phase 2** (a separate PR).

## Companion-rule satisfiers (in this PR)

- **PRD-0004 distillation rule** (fired by creating OPP-0043) → third-built-domain observation appended to `docs/knowledge/shared-observations.md`.
- **OPP audit-trail floor** → entry in `docs/project/change-log.md`.
- **OPP index token** → new cluster in `docs/opportunities/candidates.md`; index rows in `docs/README.md`.

## Validation

- Full 15-validator suite green (including both diff-mode validators against `main`).
- markdownlint-cli2 clean.
- No `platform/**`, no catalog-count changes — harness suite predict-clean and unchanged.

Design evidence: `docs/superpowers/specs/2026-06-05-cybersecurity-osint-maltego-wedge-design.md`.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Expected: PR created. **Stop here — do not merge.** Report the PR URL and CI status to the maintainer; merging is the maintainer's call.

---

## Self-Review (run after writing; fix inline)

**Spec coverage** — every spec section maps to a task:
- Settled decisions (naming, ATT&CK+PTES, 3 modules + Purple-as-composition, half-enforced charter) → OPP-0043 (T1) + PRD-0022 §10/Goals (T2). ✓
- Family map → OPP-0043 sub-modules table (T1). ✓
- Guardrail spine (`engagement-charter.md`, bias guardrail) → OPP-0043 + PRD-0022 FR-002/FR-003 (T1/T2). ✓
- OSINT wedge + privacy composition → PRD-0022 FR-001/FR-005 (T2). ✓
- Maltego tool entry (stop-condition) → PRD-0022 FR-004 (T2). ✓
- Dogfood split → OPP-0043 + PRD-0022 Goals/Constraints + the distillation observation (T1/T2/T5). ✓
- Two-phase governance mapping → PRD-0022 Implementation Deferral (T2); this plan IS Phase 1. ✓
- Harvest tie-in → OPP-0043 Promotion + the distillation observation (T1/T5). ✓

**Placeholder scan** — no "TBD"/"add appropriate"/"similar to" in any step; every artifact is literal. ✓

**Type/number consistency** — OPP-0043 / PRD-0022 / diagram #14 / validator 15→16 used consistently; `domains/cybersec-osint` / `engagement-charter.md` / `osint-collection-plan.md` / `cybersec-osint-engagement.yaml` / `validate-engagement-charter.sh` spelled identically across T1, T2, T3, T5, T6. ✓

**Phase boundary** — no Task touches `platform/**`, `SUMMARY.md`, the README Module System table, `discovery-to-composition.md`, or any catalog-count site. This PR is pure-docs. ✓
