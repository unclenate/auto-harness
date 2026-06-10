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
