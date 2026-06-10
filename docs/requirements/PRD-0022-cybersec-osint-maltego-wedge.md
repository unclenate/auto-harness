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
