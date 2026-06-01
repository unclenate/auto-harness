<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Design — Deep Industry Domains: Healthcare Wedge (FHIR + SMART on FHIR)

**Status:** Draft (brainstorming output, pending user review)
**Author:** @unclenate
**Date:** 2026-06-01
**Origin OPPs:** OPP-0013 (healthcare family), OPP-0016 (review skills), OPP-0022 (patient safety)

---

## Purpose

Establish how auto-harness governs **deep, regulated industry domains** — using
**healthcare** as the first concrete instance, and **FHIR + SMART on FHIR** as
the first buildable wedge of healthcare. The wedge is intentionally thin so the
*generalizable framework* (applicable later to finance, logistics & supply
chain, manufacturing, cyber/physical security) is **harvested from a working
example rather than speculated in the abstract**.

Two consumers ground the wedge:

- **OpenEMR** — provider/operator-side EHR (server/provider-launch SMART role).
- **Tula** — patient-authorized client (patient-access SMART role; patient is
  the resource owner).

The wedge is the smallest slice exercised by *both* consumers, which is exactly
where the role and global-jurisdiction questions bite.

## Goals / Non-Goals

**Goals**

- Ship two catalog domain modules: `domains/healthcare-fhir` and
  `domains/healthcare-smart-on-fhir`.
- Keep the module core **jurisdiction-agnostic**; force the consumer to declare
  jurisdiction via a required artifact. No jurisdiction (including US) is the
  default.
- Model SMART's two trust roles (provider-launch, patient-access) as a
  **documented axis** inside one module, not as duplicate modules.
- Name and capture three reusable framework primitives so the later
  generalization pass is deliberate.
- Close the human + agent discoverability gaps for healthcare.

**Non-Goals (explicitly out of this wedge)**

- The other ten OPP-0013 sub-modules (hl7v2, ccda, ePrescribing, cdr, cqm,
  phi-encryption, audit-log, direct-messaging, ehi-export, patient-portal).
- OPP-0022's patient-facing **agent-safety** overlay — different governance
  (agent behavior, not SMART mechanics). Stays a separate future module.
- The abstract framework operating-principle/ADR — authored in a *later* pass,
  harvested from this wedge (see "Harvest plan").
- Specialist review skills (OPP-0016) beyond a minimal onboarding pointer.

## Sequencing decision

**Concrete-first.** Build the healthcare wedge, then extract the general
deep-domain framework from it. Rationale: an abstraction built without a real
instance misfits its first real vertical; this also matches how the harness
already grew (web3 → cryptographic-identity emerged as a pattern, not a
top-down taxonomy). Risk — framework over-fit to one example — is mitigated by
explicitly stress-testing the harvested pattern against finance/logistics on
paper before promoting it to an operating-principle.

---

## Architecture

Two new catalog modules under `platform/profiles/domains/`:

```
domains/healthcare-fhir              (dependsOn: kernel/base)
        ▲
        │  depends on (SMART sits on top of FHIR)
        │
domains/healthcare-smart-on-fhir     (dependsOn: kernel/base, healthcare-fhir)
```

The intra-family dependency (`smart-on-fhir` → `fhir`) is itself a teaching
example of composition, mirroring `supabase` → `relational-postgres`.

### Module: `domains/healthcare-fhir`

| Aspect | Design |
|---|---|
| `id` / `type` | `healthcare-fhir` / `domain` |
| `dependsOn` | `kernel/base` |
| `conflictsWith` | none |
| Required artifacts | `docs/healthcare/fhir-resource-map.md` (resources, FHIR version, profiles implemented); `docs/healthcare/jurisdiction-profile.md` (the forcing artifact) |
| Optional artifacts | `docs/healthcare/bulk-export-readiness.md` |
| Sensitive paths | `^fhir/`, `^src/FHIR/`, path-substrings `patient`, `observation`, `bundle`, `phi` |
| Companion rules | (a) edits to `fhir-resource-map.md` or `jurisdiction-profile.md` → require `docs/adr/ADR-` or `docs/project/change-log.md`; (b) PHI-schema-touching changes → require `docs/security/risk-register.md` |
| Review gate | any change widening PHI exposure, or changing a declared jurisdiction profile, = human sign-off |

### Module: `domains/healthcare-smart-on-fhir`

| Aspect | Design |
|---|---|
| `id` / `type` | `healthcare-smart-on-fhir` / `domain` |
| `dependsOn` | `kernel/base`, `healthcare-fhir` |
| `conflictsWith` | none |
| Required artifacts | `docs/healthcare/smart-scope-map.md` — explicit **provider-launch** and **patient-access** sections + a **trust-model** note (who owns the resource per role) |
| Sensitive paths | `^src/FHIR/SMART/`, `^auth/`, path-substrings `scope`, `launch`, `token`, `oauth` |
| Companion rules | (a) scope-map changes → ADR or change-log; (b) any change to **patient-access** scopes → require `docs/security/risk-register.md` (patient = resource owner, higher bar) |
| Review gate | scope grants, launch-context changes, and any provider↔patient scope-boundary edit = human sign-off |

---

## The harvested framework primitives

Named now so the later generalization is deliberate, not accidental:

1. **Jurisdiction-profile forcing artifact.** A required `jurisdiction-profile.md`
   that makes the consumer declare region(s) and applicable profiles
   (US Core / IPS / UK / AU …). Generalizes directly: finance →
   PCI-DSS/PSD2/SOX; logistics → customs/Incoterms regimes; manufacturing →
   regional safety standards.

2. **Bias guardrail.** A first-class checklist block embedded in the
   jurisdiction-profile template, reusable near-verbatim across verticals:
   > *This module makes no jurisdiction the default. Declare yours below. Do
   > not assume US (or any single region) norms, code sets, or legal regimes.*

3. **Decomposition + trust-role pattern.** "A deep vertical decomposes into
   technology-bounded sub-modules; where one technology serves multiple trust
   roles, model role as a documented axis within one module, not as duplicate
   modules." This sentence becomes the seed of the future operating-principle.

---

## Documentation & visualization layer

- **Templates:** new `platform/templates/healthcare/` containing
  `fhir-resource-map.md`, `jurisdiction-profile.md` (carrying the bias
  guardrail), and `smart-scope-map.md`. Each gets the standard SPDX header.
- **Human navigation:** add both modules + a short "Healthcare domain family"
  orientation to `SUMMARY.md` (TOC) and the catalog in `HARNESS.md`; fix the
  pre-existing OPP-0022 TOC omission.
- **Agent navigation:** add FHIR/SMART awareness to
  `platform/skills/harness-onboarding/SKILL.md` so an agent onboarding a
  healthcare codebase routes to these modules and their artifacts.
- **Visualization:** one diagram in `docs/architecture/diagrams.md` — the
  healthcare domain family tree (`fhir ← smart-on-fhir`, the role axis, the
  jurisdiction overlay) — authored so it doubles as the **template diagram for
  any deep-domain family**.

---

## Governance mapping (native harness flow)

This brainstorming spec is the design context. It maps onto the harness's own
artifacts as follows:

- A **PRD** (next sequential `PRD-00NN`) becomes the design contract for the
  wedge, citing OPP-0013 as origin and applying operating-principles §9
  (design-first) and §10 (claim classification for any enforced behavior).
- On acceptance, **OPP-0013 disposition** updates to *partially accepted* —
  `healthcare-fhir` + `healthcare-smart-on-fhir` promoted; the other ten
  sub-modules remain `proposed`. OPP-0016 and OPP-0022 stay `proposed`.
- The companion-rule reflex requires same-pass propagation of any new module to:
  `HARNESS.md` (if activated), `SUMMARY.md`, the catalog `README`/Module table,
  `platform/skills/harness-onboarding/SKILL.md`, and
  `platform/workflow/discovery-to-composition.md`.

## Validators & testing

- New modules and templates must pass the full **14-validator** suite —
  notably module-graph (dependency resolution of `smart-on-fhir → fhir`),
  required-artifacts, companions, catalog-counts, and list-completeness.
- New template files carry SPDX headers (header-hygiene).
- A sample composition (e.g.,
  `platform/compositions/healthcare-fhir-app.yaml` or a sample project under
  `platform/examples/sample-projects/`) activates both modules and validates
  clean — this is the wedge's "integration test", since the modules are
  governance (markdown/YAML), not runtime code.

## Harvest plan (the generalization pass, later)

After the wedge ships and is validated:

1. Stress-test the three primitives on paper against **finance** and
   **logistics** (do the jurisdiction-profile + role-axis patterns hold?).
2. Promote the decomposition + trust-role pattern to a new
   **operating-principle** section + an **ADR** recording the deep-domain
   framework decision.
3. Generalize the bias-guardrail and jurisdiction-profile templates into a
   domain-neutral `platform/templates/<vertical>/` starter pattern.

This pass is **out of scope for the wedge implementation** and gets its own
spec → plan cycle.

---

## Open questions (resolve during planning, not blocking design)

- Exact sensitive-path regex set per module (validated against OpenEMR + Tula
  trees during implementation).
- Whether the sample artifact lives as a `compositions/*.yaml` entry or a full
  `examples/sample-projects/` directory.
- PRD number assignment (next sequential at authoring time).
