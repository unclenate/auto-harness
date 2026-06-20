<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0049 — Deep Governance Vertical: Authoring-Pattern Harvest

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-06-20
**Last Updated:** 2026-06-20 *(filed)*
**Confidence:** high *(the pattern is proven six times; the open question is the form of the harvest, not whether the pattern exists)*

---

## Thesis

The harness has built **six deep governance verticals** on one implicit
skeleton — four subject-matter **domain families** (`domains/healthcare-*`,
`domains/aec-*`, `domains/cybersec-*`, `domains/geospatial-*`) and two
cross-cutting **discipline overlays** (`management/privacy-by-design`,
`management/digital-twin`). Each one was built by re-deriving the same moves:
find the jurisdiction-neutral core, pick the one forcing artifact, write the
default-deny bias guardrail, decompose into single-concern sub-modules, choose a
composition shape, and ship a predict-clean module-gated validator.

That skeleton is **proven but undocumented**. It lives as scattered prose across
six module READMEs, the build plans under `docs/superpowers/plans/`, and a single
passing reference in `operating-principles.md` (§ 11 calls privacy "the first
cross-vertical reuse of the deep-domain ... pattern"). There is **no operating
principle that codifies it and no authoring playbook that teaches it**. The
consequence: the seventh vertical re-derives the skeleton from memory, a new
contributor cannot find it, and the cross-vertical generalization the codebase
has already demonstrated is invisible to anyone who didn't build all six.

This OPP proposes to **harvest** that skeleton: extract it from the six worked
instances into (1) a codifying operating principle (**§ 12**) and (2) an
authoring playbook workflow doc. It is **design-only** per operating-principle
§ 9 — this record frames the design space and commits a promotion plan; the
principle and the playbook land in separate implementing PRs.

## The pattern being harvested (the six-ingredient skeleton)

The harvest codifies a **deep governance vertical** — a focused, standards-
anchored governance capability layered onto the kernel, whether it governs a
*subject-matter domain* (healthcare, AEC) or a *cross-cutting discipline*
(privacy, digital twins). All six built verticals share this skeleton:

| # | Ingredient | What it is | Proven in |
|---|-----------|------------|-----------|
| 1 | **Jurisdiction-neutral core** | The universal floor that assumes no jurisdiction, legal regime, or standard *version*. The applicable specific is consumer-declared at init, never assumed. | FHIR-neutral healthcare; ISO-19650-neutral AEC; Cavoukian-7 as the neutral privacy floor; PTES/ATT&CK-neutral cybersec |
| 2 | **Forcing artifact** | The *one* required file that turns the vertical into a governed conformance question. It declares the consumer's specific choices and is what the validator reads. | `twin-profile.md`, `spatial-reference-profile.md`, `jurisdiction-profile.md`, `privacy-profile.md`, the engagement-charter |
| 3 | **Bias guardrail (default-deny overclaim)** | You may not claim a maturity / conformance / coverage your evidence does not support; emerging standards are cited as emerging, not ratified. | digital-twin emerging-as-published guard; healthcare bias guardrails; the maturity ladder's default-deny |
| 4 | **Decomposition into single-concern sub-modules** | The family splits into focused modules, each governing one seam, composed by `dependsOn`. | `aec-{iso19650-im, openbim-exchange, iso19650-5-security}`; `geospatial-{foundation, exchange, bim-georeference}`; `healthcare-{fhir, smart-on-fhir}` |
| 5 | **Composition shape** | One of three proven shapes: **intra-family** (sub-modules depend within the family), **domain × cross-cutting overlay** (a domain composes with privacy / digital-twin), **cross-family bridge** (a module depends across two families). | all four domains + both overlays; the geospatial-bim-georeference × aec-openbim-exchange bridge is the first cross-family case |
| 6 | **Predict-clean, module-gated validator** | The vertical's machine enforcement no-ops when the module is inactive — the harness does not activate it, so its own CI is a clean pass; consumer CI honors it (the § 10 Half-enforced posture). | `validate-twin-profile`, `validate-scenario-manifest`, `validate-privacy-by-design`, `validate-lane-integrity` |

A **secondary, overlay-specific** ingredient is the **dual-spine standards
anchor** — a cross-cutting overlay anchors to *two* spines, an interoperability /
technical-standard spine and a governance-values spine (digital-twin =
interoperability standards + the Gemini Principles; privacy = data-protection
regimes + Cavoukian's 7). The playbook notes this as the place domains (one
spine) and overlays (two spines) diverge.

## Origin / Evidence

Six independent instances, well past the § 9 three-instance generalizability bar:

- **Healthcare** (`domains/healthcare-*`, OPP-0013 / PRD-0017) — the first deep
  domain; established neutral-core (FHIR-neutral) + forcing artifact
  (jurisdiction-profile) + bias guardrail.
- **AEC** (`domains/aec-*`, OPP-0039 / PRD-0019) — first 3-way decomposition;
  added the compound forcing artifact and the first domain × cross-cutting
  composition (with privacy).
- **Cybersecurity** (`domains/cybersec-*`, OPP-0043 / PRD-0022) — per-family
  forcing artifact (engagement-charter) + a tool-anchored grounding split.
- **Geospatial** (`domains/geospatial-*`, OPP-0045 / PRD-0024) — first
  **cross-family bridge** (`geospatial-bim-georeference` depends on
  `aec-openbim-exchange`); a temporal forcing artifact.
- **Privacy** (`management/privacy-by-design`, § 11 / PRD-0018) — `operating-
  principles.md` § 11 explicitly names this the *"first cross-vertical reuse of
  the deep-domain ... pattern"* — the proof the skeleton generalized off domains.
- **Digital Twin** (`management/digital-twin`, OPP-0044 / PRD-0023) — the second
  overlay; introduced the dual-spine anchor and the maturity-gated forcing
  artifact.

The pattern is also visible in the negative: the work-package lane
(`management/work-package`, PRD-0025) is *not* a deep governance vertical — it
has no neutral-core/forcing-artifact/standards-anchor — and it reuses only
ingredient 6 (the predict-clean validator). That boundary case sharpens what the
skeleton is and is not.

## Why Now

- **The precondition is met and over-met.** The pattern needed three instances to
  generalize (§ 9); it has six. Each new vertical that ships without the playbook
  is a re-derivation tax and a missed chance to harvest while the build is fresh.
- **The reference already exists but is a stub.** `operating-principles.md` § 11
  *names* the pattern in one sentence without defining it — a dangling forward
  reference that this harvest resolves.
- **The seventh vertical is foreseeable.** The OPP backlog and the domain-family
  trajectory make a 7th vertical likely; codifying now means it is authored *from*
  the playbook rather than *into* a future one.
- **It feeds the session-shape taxonomy.** This is itself a worked example of the
  "operating-principles promotion-candidate scan" that `session-shape.md`
  (PRD-0013) names as a declared-but-unfired review — promoting a six-instance
  pattern is exactly that review firing.

## Promotion plan (staged; § 9 split-design-from-implementation)

This OPP commits to the following phases. Each is its own PR.

| Phase | Deliverable | Notes |
|-------|-------------|-------|
| **1 (this record)** | OPP-0049 — frames the harvest, defines the six-ingredient skeleton, commits this plan. Design-only; status `proposed`. | No principle/playbook text in this PR. |
| **2** | **Operating-principle § 12** — codifies the skeleton as doctrine: scope = *deep governance verticals* (domains **and** cross-cutting overlays); the six ingredients; the three composition shapes; the dual-spine divergence for overlays. Cites the six instances. Resolves the § 11 dangling reference. | Mirrors the OPP-0037 → § 10 promotion recipe. |
| **3** | **`platform/workflow/deep-governance-vertical-authoring.md`** — the step-by-step playbook: how to find the neutral core, pick the forcing artifact, write the bias guardrail, decompose, choose a composition shape, ship a predict-clean validator — with a worked column from each of the six verticals and a "domains vs overlays diverge here" callout. Registered in SUMMARY.md; workflow count bumped. | The accelerant. |
| **4 (deferred; revisit-bar)** | A meta-template / `harness-onboarding` SKILL hook that scaffolds a new vertical's sub-modules + forcing artifact. | **YAGNI-deferred.** A vertical is authored ~quarterly; a generator may be over-engineering until the playbook proves the scaffold is the bottleneck. Revisit after the 7th vertical is authored from the playbook. |

## Risks / Open Questions

- **Over-abstraction risk.** Codifying a pattern can ossify it. Mitigation: the
  § 12 doctrine describes the skeleton and the *three composition shapes* as
  proven options, not a mandate; the playbook is explicitly advisory (the
  `session-shape.md` precedent). A vertical that needs a fourth composition shape
  extends the doctrine, it doesn't violate it.
- **Domains-vs-overlays divergence.** The two classes are not identical (overlays
  add the dual-spine anchor; domains decompose by subject seam, overlays by
  discipline concern). Risk: a single doctrine that flattens the difference.
  Mitigation: § 12 names the shared skeleton and the **one** documented
  divergence (single vs dual spine); the playbook carries the worked columns that
  make the divergence concrete.
- **The work-package boundary.** Not every new module is a deep governance
  vertical. The doctrine must state the **inclusion test** (neutral core + forcing
  artifact + standards anchor) so the pattern is not over-applied to thin
  management overlays like work-package. Captured as an explicit § 12 boundary.
- **Phase-4 scope creep.** The meta-template is the most speculative piece;
  binding it into Phases 2–3 would conflate proven harvest with unproven tooling.
  Mitigation: it is deferred with an explicit revisit-bar, not committed.

## Disposition

**2026-06-20 — filed `proposed`.** Design-only per § 9. The pattern is
six-times-proven; this record commits the promotion plan above (Phase 2 § 12
doctrine + Phase 3 playbook; Phase 4 deferred). Status flips to `accepted` when
Phase 2 (the § 12 PRD/section) lands, mirroring the OPP-0037 → § 10 recipe. No
PRD is required in this commit because the OPP is `proposed`, not `accepted`.

## Promotion

Phase 2 (operating-principle § 12) and Phase 3 (the authoring playbook) are the
implementing artifacts; this section will link them as they land.

## Related

- Positive-template recipe: [OPP-0037](OPP-0037-classify-before-enforcing-as-operating-principle.md)
  — the design-only-OPP → operating-principle promotion this harvest mirrors.
- The six instances: [OPP-0013](OPP-0013-domain-family-healthcare-decomposed.md),
  [OPP-0039](OPP-0039-domain-family-aec-decomposed.md),
  [OPP-0043](OPP-0043-domain-family-cybersecurity-decomposed.md),
  [OPP-0045](OPP-0045-domain-family-geospatial-decomposed.md),
  [OPP-0044](OPP-0044-digital-twin-scenario-runtime.md), and the privacy
  principle ([§ 11](../operating-principles.md#11-privacy-by-design-by-default)).
- The dangling reference this resolves: `operating-principles.md` § 11
  ("first cross-vertical reuse of the deep-domain ... pattern").
- Boundary case (what the skeleton is *not*): [OPP-0046](OPP-0046-parallel-multi-agent-work-package-lane-contract.md)
  / `management/work-package` — reuses only the predict-clean validator ingredient.
- Related operating principles: § 9 (Split Design from Implementation),
  § 7 (Align File Boundaries with Change-Class Boundaries).
