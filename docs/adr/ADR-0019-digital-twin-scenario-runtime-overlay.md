<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0019: Adopt Digital Twin / Scenario Runtime as a Management Overlay

**Status:** Accepted
**Date:** 2026-06-10
**Author:** @unclenate
**Reviewers:** @unclenate
**Context sources:**

- `docs/superpowers/specs/2026-06-10-digital-twin-scenario-runtime-overlay-design.md` — the full
  design spec: dual-spine contract, standards anchor, forcing artifact, maturity ladder, §10 map
- `docs/opportunities/OPP-0044-digital-twin-scenario-runtime.md` — the opportunity this resolves
- `docs/requirements/PRD-0023-digital-twin-scenario-runtime-overlay.md` — the build specification

## Context

Digital-twin / scenario-runtime patterns recur across active projects (municipal twinning,
real-estate planning, AI-datacenter operations, civic portals, healthcare agentic workflows,
TerraSim-style geospatial simulation). A TerraSim review exposed reusable governance primitives.
auto-harness should encode these as reusable governance rather than project-local advice.

The placement question is genuine: is this a subject-matter **domain** (like `healthcare-*`,
`aec-*`, `cybersec-*`) or a cross-cutting **management** overlay (like `privacy-by-design`,
`eval-gated-testing`)? Digital twin has a domain-flavored *runtime-structure* layer (scenario
manifests, world/scenario/run state, registries, run logs) and a management-flavored *discipline*
layer (provenance, uncertainty, no-overclaim, publication, review gates). The governance concern —
disciplining the gap between a model and the reality it claims to represent — is what is
load-bearing, and it layers orthogonally on top of subject matter.

## Decision

Adopt **`management/digital-twin`, a default-off opt-in overlay.**

Twin-ness is orthogonal to subject matter: a civic twin, a healthcare twin, an AEC operational
twin, and a datacenter twin share a discipline that layers on top of whatever the project is. The
overlay composes *with* subject-matter domains (`aec-iso19650-im`, `healthcare-fhir`,
`cybersec-osint`) and *with* other management overlays (`privacy-by-design`, `eval-gated-testing`),
never replacing them.

The overlay carries a **dual-spine governance contract**: an interoperability / digital-thread
spine (so a planning model can transform into an operational twin) anchored on ISO 23247, ISO
10303 STEP/AP242, QIF, the Asset Administration Shell, DTDL, and W3C WoT; and a governance-values
spine anchored on the Gemini Principles (CDBB, 2018). The single forcing artifact
`docs/twin/twin-profile.md` makes a project declare its maturity level, its standards conformance
(with published-vs-emerging status), and the principles governing its outputs. The validator
posture is **Half-enforced** (module-gated WARN), matching `privacy-by-design`. PRD-0023 specifies
the full build; the harness does not activate the overlay on itself (ship-as-catalog).

**Default-off, opt-in** (contrast `privacy-by-design`'s default-on): the realistic population of
consumer projects is mostly not twins, so the overlay is activated only by projects that model
real-world systems or run scenarios.

## Alternatives considered

**`domains/digital-twin` (the seed's suggestion).** Rejected: across every named consumer, digital
twin *layers on* a subject matter (civic, built-environment, datacenter, health) or none — it is
never itself the subject matter. A domain framing would force a co-active "second domain" with
muddy subject-vs-discipline semantics; the overlay framing is cleaner and matches the orthogonality.

**Minting a new top-level taxonomy category now.** The governance essence — *representational /
epistemic integrity* — is a third concern-type the flat taxonomy does not name, and
`eval-gated-testing` shares its shape (an evidence-graded, anti-overclaiming discipline with a
gating ladder), suggesting a latent cluster at n≈2. Rejected for now: the harness's concrete-first
law harvests abstractions from instances (we have not yet harvested even the deep-domain framework
at n=3), and minting a category off one new module would be the exact overclaiming this module
exists to prevent. **Staged** as a named future opportunity, triggered by a third instance.

**Kernel-mandatory / default-on.** Rejected: most projects are not twins; imposing twin ceremony
universally is dead weight, contrary to the consumer-autonomy principle. Default-off / opt-in fits.

## Consequences

**Positive:**

- Reusable, externally-anchored governance across civic, infrastructure, real-estate, healthcare,
  AI-datacenter, and simulation projects — adoptable off the shelf.
- The deep-domain primitives gain a second cross-cutting application (after privacy),
  strengthening the eventual harvest's generalization claim.
- The dual-spine + maturity-gated model reduces overclaiming and makes planning→operational
  transformation a governed conformance question.
- The built-environment stack (`aec-iso19650-im` × `digital-twin` × `privacy-by-design`) is
  institutionally coherent — CDBB authored both the Gemini Principles and the UK ISO 19650
  transition.

**Negative / costs:**

- A new opt-in overlay adds artifact obligations for projects that activate it (mitigated by the
  maturity-gated depth: L1 needs only the profile).
- v1 validators are Half-enforced and shallow by design; depth-by-maturity is Asserted-only until
  a maturity-aware validator is proven. A deliberate limitation, not an oversight.

**Watch:**

- Standards status drift — several anchors are emerging (ISO 23247-5/-6, ISO/IEC 30188); the
  profile's status field must be honored so a draft is never cited as ratified.
- If a third epistemic-discipline instance appears, revisit the staged category harvest.

## References

- `docs/superpowers/specs/2026-06-10-digital-twin-scenario-runtime-overlay-design.md` — design spec
- [OPP-0044](../opportunities/OPP-0044-digital-twin-scenario-runtime.md) — the opportunity
- [PRD-0023](../requirements/PRD-0023-digital-twin-scenario-runtime-overlay.md) — build spec
- [ADR-0018: Privacy-by-Default Posture](ADR-0018-privacy-by-default-posture.md) — sibling
  discipline-overlay ADR; shares the WARN-posture / ship-as-catalog pattern
