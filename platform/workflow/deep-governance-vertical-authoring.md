<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Authoring a Deep Governance Vertical

This is the **step-by-step playbook** for building the next deep governance
vertical from the shared skeleton. It is the procedure;
[operating-principles § 12](../../docs/operating-principles.md#12-author-deep-governance-verticals-from-the-shared-skeleton)
is the doctrine it implements. Read § 12 for *why* the skeleton has the shape it
has and what counts as an extension; read this doc for *how* to lay down each
ingredient, in what order, wired to which validator, with a worked reference per
vertical already in the catalog.

> **Do not re-derive the skeleton.** Five verticals were built one at a time and
> the pattern was harvested only after the evidence accumulated (the same
> harvest-after-evidence discipline § 9 and § 10 followed). Authoring the next
> one is now a *copy-the-skeleton* exercise, not a design-from-scratch one. If
> you find yourself inventing a new ingredient or a new composition shape, that
> is a signal to **extend § 12**, not to fork the skeleton silently.

## Step 0 — Run the inclusion test first

Before writing a line, confirm the candidate **is** a deep governance vertical.
A module qualifies only if it has all three of:

1. **A jurisdiction-neutral core** — a universal floor that assumes no specific
   jurisdiction, legal regime, or standard *version*.
2. **A forcing artifact** — a single required file where the consumer declares
   their specific choices, and which a validator reads.
3. **A standards anchor** — a real external standard (or pair of standards) the
   vertical is built around.

If it fails any of the three, **stop** — it is a thinner module. Build it via
[`discovery-to-composition.md`](discovery-to-composition.md) and
[`extending-the-harness.md`](extending-the-harness.md) instead, and do not borrow
the vertical scaffold it does not need. The canonical negative case is
`management/work-package`: it reuses only the predict-clean-validator ingredient
(a lane validator) and has no neutral core, forcing artifact, or standards
anchor — so it is a thin overlay, not a deep vertical (see
[`work-package-worktree-runbook.md`](work-package-worktree-runbook.md)).

## The six build steps

Each step lays down one skeleton ingredient. Build them in order — the forcing
artifact (step 2) is meaningless without the neutral core (step 1) it records
choices against, and the enforcement (step 6) reads the forcing artifact.

### 1. Author the jurisdiction-neutral core

Write the module `summary`/`README` so the universal floor names **no** specific
jurisdiction, regime, or standard version. The applicable specific is always
consumer-declared at initialization, never assumed.

- *Healthcare:* FHIR-neutral (no bound version/profile).
- *AEC:* ISO-19650-neutral (the information-management substrate, no national
  annex baked in).
- *Geospatial:* CRS-neutral (no datum/epoch assumed).
- *Privacy:* Cavoukian's 7 principles as the neutral floor; the legal regime is
  consumer-declared.

### 2. Add the one forcing artifact

A single required file turns the vertical into a governed conformance question.
It declares the consumer's specific choices and is what the validator reads. Add
it as a `requiredArtifact` in `module.yaml` and ship a `platform/templates/`
template with `[[PLACEHOLDER]]` fields.

| Vertical | Forcing artifact |
|---|---|
| healthcare | `docs/healthcare/jurisdiction-profile.md` |
| aec | `docs/aec/jurisdiction-profile.md` |
| geospatial | `docs/geospatial/spatial-reference-profile.md` (compound, temporal) |
| privacy | `docs/privacy/privacy-profile.md` |
| digital-twin | `docs/twin/twin-profile.md` (maturity-gated) |
| cybersec *(designed)* | `docs/cybersec/engagement-charter.md` |

### 3. Encode a default-deny bias guardrail

State, in the template and the module's `humanReview` text, that the consumer may
not claim a maturity, conformance, or coverage their evidence does not support;
emerging standards are cited as emerging, not ratified. Overclaiming is the
failure mode the guardrail blocks (PHI-exposure widening, promoting a container
to Published/As-Built, a CRS-conformance claim, a privacy/twin maturity claim,
the cybersec dual-use + lawful-basis prompt).

### 4. Decompose into single-concern sub-modules

If the vertical governs more than one seam, split it into focused sub-modules,
each governing one seam, composed by `dependsOn` — do not build a monolith.

- *AEC:* `aec-iso19650-im` → `aec-openbim-exchange` → `aec-iso19650-5-security`.
- *Geospatial:* `geospatial-foundation` → `geospatial-exchange` →
  `geospatial-bim-georeference`.
- *Healthcare:* `healthcare-fhir` → `healthcare-smart-on-fhir`.

A single-seam vertical (privacy, digital-twin) is one module — decomposition is
*single-concern*, not *mandatory-plural*.

### 5. Pick one of the three composition shapes

Wire the module into a `platform/compositions/*.yaml` example using exactly one
shape:

| Shape | What depends on what | Worked example |
|---|---|---|
| **Intra-family** | Sub-modules depend within the family | `aec-bim-project.yaml`, `healthcare-fhir-app.yaml` |
| **Domain × cross-cutting overlay** | A domain composes with privacy or digital-twin | `geospatial-bim-twin.yaml` (geospatial × digital-twin) |
| **Cross-family bridge** | A module depends across two families | `geospatial-bim-georeference` × `aec-openbim-exchange` |

The cross-family bridge was the geospatial family's contribution to the
skeleton; if your vertical needs a *fourth* shape, that extends § 12.

### 6. Wire predict-clean, module-gated enforcement

The vertical's machine enforcement must **no-op when the module is inactive**, so
the harness's own CI is a clean pass and consumer CI honors it (the § 10
Half-enforced posture). Two mechanisms satisfy this — pick by vertical type:

- **Domain families** enforce the forcing artifact with a **companion rule**
  (`triggerPaths` → required satisfier) checked by the universal
  `validate-companions`, plus `validate-required-artifacts` asserting the file
  exists. Because companion rules are read only from *active* modules, an
  inactive domain contributes nothing to the harness's own CI — predict-clean by
  construction.
- **Cross-cutting overlays** additionally ship a **dedicated module-gated
  validator** that exits 0 when the module is inactive
  (`validate-privacy-by-design`, `validate-twin-profile`,
  `validate-scenario-manifest`; the designed cybersec vertical adds
  `validate-engagement-charter`). Model the gating on those scripts: read the
  manifest, return early with a "module inactive" message when absent.

Either way the **property** § 12 ingredient 6 names — predict-clean and
module-gated — must hold. Add any new dedicated validator to the run-chain in
[`harness-governance`](../skills/harness-governance/SKILL.md) and to
`platform/validators/test/test_validators_integration.rb`.

## Worked-examples matrix

One column per vertical already in the catalog. **Five are built**; cybersec is
**designed against the skeleton** (PRD-0022, module pending) — included to show
the skeleton applies at design time, before a line of the module exists.

| Ingredient | healthcare | aec | geospatial | privacy *(overlay)* | digital-twin *(overlay)* | cybersec *(designed)* |
|---|---|---|---|---|---|---|
| 1 · Neutral core | FHIR-neutral | ISO-19650-neutral | CRS-neutral | Cavoukian-7 floor | interop-standard-neutral | ATT&CK / PTES-neutral |
| 2 · Forcing artifact | jurisdiction-profile | jurisdiction-profile | spatial-reference-profile | privacy-profile | twin-profile | engagement-charter |
| 3 · Bias guardrail | PHI overclaim | publish-status overclaim | CRS-conformance | privacy-maturity | twin-maturity | dual-use + lawful-basis |
| 4 · Decomposition | `-{fhir, smart}` | `-{im, openbim, security}` | `-{foundation, exchange, georef}` | single | single | designed |
| 5 · Composition shape | intra-family | intra-family | intra-family + cross-family bridge | domain × overlay | domain × overlay | designed |
| 6 · Enforcement | companion + required-artifact | companion + required-artifact | companion + required-artifact | `validate-privacy-by-design` | `validate-twin-profile` + `validate-scenario-manifest` | `validate-engagement-charter` |
| Spine | single | single | single | **dual** (regimes + Cavoukian-7) | **dual** (interop + Gemini Principles) | **dual** (ATT&CK/PTES + lawful-basis) |

## Domains vs overlays — the dual-spine decision

A subject-matter **domain** (healthcare, AEC, geospatial, cybersec) carries a
**single** standards spine. A cross-cutting **overlay** (privacy, digital-twin)
carries a **dual spine**: a technical/interoperability spine *and* a
governance-values spine (digital-twin = interoperability standards + the Gemini
Principles; privacy = data-protection regimes + Cavoukian's 7). If you are
building an overlay, add the second spine in steps 1 and 3 — name the
values-framework alongside the technical standard, and let the guardrail enforce
both. This is the one documented divergence; everything else in the skeleton is
identical across domains and overlays.

## Propagation checklist (a new module is a catalog-wide edit)

Adding a module is never a single-file change. Per operating-principles § 3 and
the enumeration-drift bullet, propagate **in the same pass**:

- [ ] `HARNESS.md` Active Modules
- [ ] `SUMMARY.md` (module rows + any workflow row)
- [ ] `README.md` Module System table / directory tree
- [ ] `platform/skills/harness-onboarding/SKILL.md` module catalog
- [ ] `platform/workflow/discovery-to-composition.md` decision rubric
- [ ] `docs/architecture/diagrams.md` if you add a family diagram (couples a
      diagram-count bump → cascades to HARNESS.md / README / SVG)
- [ ] Catalog counts: `validate-catalog-counts.sh .` names every stale numeric
      and word-form site; treat it as a fix-this oracle, not just a gate
- [ ] Index rows: `validate-list-completeness.sh .` names every missing
      ADR/PRD/OPP/composition/template-subdir/profile-module/agent-module row
- [ ] Distillation (PRD-0004): a new OPP/ADR/module triggers the cycle-end rule —
      pair it with `shared-observations.md` or an `operating-principles.md` section

> **Counts and member-lists are separate surfaces.** `validate-catalog-counts.sh`
> guards numeric *totals*; the validator/skill *member lists* (README/SUMMARY
> tables, the run-chain) are guarded by neither. Bump the number *and* add the
> row everywhere it is enumerated — see the § 3 enumeration-drift note for the
> Digital-Twin precedent (#112) where a dozen tables read 15/7 while the totals
> said 17/8.

## Definition of done

- [ ] Inclusion test passes (neutral core + forcing artifact + standards anchor).
- [ ] Forcing artifact has a template with `[[PLACEHOLDER]]` fields and a
      companion rule on its path.
- [ ] Bias guardrail is in the template and the `humanReview` text.
- [ ] Decomposition is single-concern (or a justified single module).
- [ ] Exactly one composition shape is wired in `platform/compositions/`.
- [ ] Enforcement is predict-clean and module-gated; the harness's own CI is a
      no-op pass; any new validator is in the run-chain and the integration test.
- [ ] Overlay only: the second spine is named and guarded.
- [ ] Full validator chain exits 0 (see `harness-governance` run-chain), and the
      propagation checklist above is discharged.

## Cross-references

- [operating-principles § 12](../../docs/operating-principles.md#12-author-deep-governance-verticals-from-the-shared-skeleton)
  — the doctrine this playbook implements (the six ingredients, the inclusion
  test, the dual-spine divergence, the extend-don't-fork rule).
- [OPP-0049](../../docs/opportunities/OPP-0049-deep-governance-vertical-harvest.md)
  — the harvest design contract; this playbook is its Phase 3.
- [`discovery-to-composition.md`](discovery-to-composition.md) /
  [`extending-the-harness.md`](extending-the-harness.md) — where to go if the
  inclusion test *fails* (thin module, not a vertical).
- The five built instances: PRD-0017 (healthcare), PRD-0019 (aec), PRD-0024
  (geospatial), § 11 (privacy), PRD-0023 (digital-twin); the designed sixth:
  PRD-0022 (cybersec).

> **This playbook evolves with the skeleton.** It captures the skeleton as of
> five built verticals. If the next vertical needs a seventh ingredient or a
> fourth composition shape, record the extension in § 12 first, then update the
> steps here to match.
