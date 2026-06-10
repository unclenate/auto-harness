<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Design — Cybersecurity Deep-Domain Family + OSINT / Maltego Wedge

**Status:** Draft (brainstorming output, pending user review)
**Author:** @unclenate
**Date:** 2026-06-05
**Origin:** OSINT / Maltego backlog item (memory `project-maltego-osint`), reframed
mid-brainstorm into a **Cybersecurity domain family** of which OSINT is one aspect.

---

## Purpose

Establish the **third built deep-industry-domain vertical** — Cybersecurity — using the
reusable framework proven by healthcare (FHIR+SMART) and AEC (ISO 19650). The concrete entry
point is the real tool the user already runs for investigations — **Maltego** — but the request
decomposed into a multi-aspect domain (Red / Blue / Purple teaming alongside OSINT), so the
design lands the **family** and builds **one thin wedge** (OSINT) this cycle.

Concrete-first: build the **OSINT wedge only** (one module + the Maltego tool entry), not the
full Red/Blue/Purple family. Purple is documented as a composition, not a module.

## Settled decisions (user-confirmed in brainstorm)

1. **Family prefix: `domains/cybersec-*`** — deliberately disambiguated from the two existing
   "security" surfaces: `management/security-static-analysis` (SAST — code scanning) and
   `aec-iso19650-5-security` (built-asset sensitivity). "cybersec" names the offensive/defensive
   *operations* domain, not code-hygiene or physical-asset security.
2. **Anchoring standards: MITRE ATT&CK + PTES.** ATT&CK supplies the TTP vocabulary (the shared
   technique taxonomy across red/blue/purple); PTES supplies the execution spine — critically its
   **pre-engagement** phase, which is where *authorization* is established. (NIST CSF 2.0, the
   NICE Framework, and OSSTMM were considered and set aside as either too org-level or too
   methodology-narrow for the forcing artifact.)
3. **Aspect taxonomy: 3 modules + Purple-as-composition** — `cybersec-osint` (built this cycle),
   `cybersec-red` (deferred), `cybersec-blue` (deferred); **Purple = a documented red × blue
   composition**, not its own module (it is the *interaction* of the two, not a separate concern).
4. **Guardrail = a single `engagement-charter.md`, half-enforced** — one forcing artifact across
   the whole family carries authorization + scope; enforcement is **Half-enforced** (a
   module-gated WARN validator that requires consumer-CI cooperation), mirroring privacy-by-design.

## The family map

| Module | Aspect | Status this cycle | ≈ Prior-vertical analog |
|---|---|---|---|
| **`cybersec-osint`** | Reconnaissance + CTI (open-source intelligence) | **Built (the wedge)** | `aec-iso19650-im` — the substrate the others reference |
| **`cybersec-red`** | Offensive / adversary emulation (ATT&CK execution) | **Deferred** | `aec-openbim-exchange` — the active/operational layer |
| **`cybersec-blue`** | Defensive / detection + response (ATT&CK coverage) | **Deferred** | `aec-iso19650-5-security` — the protective spine |
| **Purple** | Red × Blue feedback loop | **Documented composition, not a module** | (the AEC security × privacy composition pattern) |

OSINT is the right wedge: it is the **substrate** aspect (recon precedes emulation and detection),
it is where the **authorization + privacy** guardrails bite hardest (it touches real people), and
it is the aspect with a **real dogfoodable tool** (Maltego) the user operates today.

## The guardrail spine — `engagement-charter.md` (forcing artifact + bias guardrail)

A single required artifact for any active `cybersec-*` module, modeled on PTES pre-engagement:

- **Authorization** — who authorized this engagement, against which assets/scope, with a
  validity window. (No charter ⇒ no authorized activity. This is the default-deny analog.)
- **Scope / Rules of Engagement** — in-scope targets, explicit out-of-scope, allowed techniques.
- **Lawful basis** — declared per-engagement: CFAA (US) / CMA (UK) / contract / documented
  consent. The *forcing* move is that the consumer must name one — silence is not a basis.
- **Dual-use posture** — an explicit acknowledgement that the techniques are dual-use and the
  engagement is authorized-testing / CTF / research / defensive, not malicious.
- **Intelligence handling / minimization** — retention, redaction, and minimization rules for
  collected data (this is the seam into `management/privacy-by-design`).

> **Bias guardrail (the OSINT analog of the healthcare/AEC bias clauses).** Default-deny any
> collection or person-entity pivot that the charter does not cover. The bias to guard against
> here is *scope creep* — OSINT tooling makes it trivially easy to pivot from an authorized
> target to an unrelated person; the charter forces the boundary to be declared, and the WARN
> validator surfaces activity that has no charter behind it.

**Enforcement = Half-enforced** (§10 vocabulary): a module-gated WARN validator that fires only
when `cybersec-*` is active and a charter is missing/incomplete. Half-enforced (not Enforced)
because the binding signal — "is this real-world activity actually authorized?" — lives in the
consumer's process, not in files the platform can fully verify; the platform enforces *presence
and shape* of the charter and warns on gaps. This is the same posture privacy-by-design uses.

## The wedge — `cybersec-osint`

- **`module.yaml`** — `type: domain`; `dependsOn: kernel/base`; `requiredArtifacts:
  engagement-charter.md` + `osint-collection-plan.md` (the OSINT-specific collection scope:
  sources, selectors, transforms-to-run, subjects-in-scope); `sensitivePaths` covering the
  collection surface (`^osint/`, `subjects`, `dossier`, `recon`).
- **`README.md`** — purpose, the charter requirement, the privacy composition, the Maltego note.
- **Companion rules** — collection-plan or sensitivePath change ⇒ collection-plan update or ADR;
  charter change ⇒ change-log or ADR (mirrors the AEC security-spine companion shape).
- **Templates** — new `platform/templates/cybersec/`: `engagement-charter.md` (carries the bias
  guardrail + lawful-basis prompt) and `osint-collection-plan.md`.

### Security × privacy composition (second domain × cross-cutting instance)

`cybersec-osint` **composes with `management/privacy-by-design`** (shipped #98), producing the
catalog's **second** domain × cross-cutting composition (AEC×privacy was the first):

- `cybersec-osint` governs **investigative collection** (what may be gathered, on whom, under
  what authorization).
- `management/privacy-by-design` governs **personal-data handling** (minimization, retention,
  subject rights) for the people who appear in the collected intelligence.
- The `engagement-charter`'s *intelligence-handling* section **references the `privacy-profile`'s
  declared regime** — the charter says "what we may collect", the privacy-profile says "how we
  must treat it once collected". The spec documents the boundary so neither leaves a gap.

## The Maltego tool entry (the concrete, dogfooded surface)

Maltego is a real OSINT/investigations graph platform the user runs (it has an MCP server and a
skill). It enters the harness as a **tool**, not as the module:

- **`TOOLS.md`** — a richer entry than the flat Ahrefs/Similarweb rows, carrying a
  **stop-condition**: *no person-entity transforms without an active engagement charter.* (This
  is the tool-surface expression of the module's default-deny guardrail.)
- **`platform/skills/harness-tools/SKILL.md`** — a Trust Tier Map row for Maltego, noting it
  **composes with `cybersec-osint`** (the tool is governed by the module's charter when that
  module is active). Gated, as the whole skill is, on `agents/openclaw`.

## Dogfood split (a deliberate asymmetry)

- The **Maltego TOOLS.md / harness-tools entry IS dogfooded** — it is a real tool in the user's
  real workflow, so it describes live usage and its stop-condition is a real guardrail.
- The **`cybersec-osint` module stays catalog-only** — like every other profile module, it is a
  composable unit the validators enumerate but this repo does not *activate* on itself. Its
  validators therefore **predict-clean** (the warn-defer-via-posture / predict-clean mechanism),
  not dogfood-fire.

This split is the design's one genuinely novel wrinkle vs healthcare/AEC: the tool half is live,
the module half is catalog. It is called out so the implementation plan does not try to "activate"
the module to make a dogfood test pass.

## Harvest tie-in (the strategic payoff)

Cybersecurity is the **third built domain** (after healthcare and AEC). The harvest precondition
(two built domains + a cross-cutting reuse) was already met by AEC; this vertical *exceeds* it and
adds a fresh enrichment — a **single family-wide forcing artifact** (`engagement-charter`) shared
across not-yet-built sibling modules, vs healthcare/AEC where each module carried its own. That is
new evidence for the harvest's "neutral-core + forcing-artifact + bias-guardrail + (optional)
trust-role-axis" generalization. The harvest itself remains a **separate later cycle** and is
maintainer-gated — not part of this wedge. See `project-deep-industry-domains` (memory).

## Governance mapping + sequencing (two phases, mirrors healthcare / AEC / privacy)

- **Phase 1 (design-only PR):** an **OPP-0043** (the Cybersecurity deep-domain family
  opportunity, with its `candidates.md` token) + a **PRD-0022** (the OSINT-wedge design contract,
  carrying a **§10 Claim Classification** block that names the Half-enforced charter validator) —
  both citing this spec as discovery evidence. Plus the **PRD-0004 distillation entry** in
  `docs/knowledge/shared-observations.md` (an OPP/PRD-creating PR must carry it) and a
  `change-log` entry.
- **Phase 2 (implementation PR):** the `cybersec-osint` module + 2 templates + the Half-enforced
  WARN validator (catalog 15→16 validators) + the Maltego TOOLS.md / harness-tools entries + the
  privacy composition wiring + **diagram #14** (Cybersecurity Domain Family) + a sample
  composition + catalog-count propagation + discoverability (SUMMARY, README Module System,
  onboarding skill, discovery-to-composition Step 6).

## Non-Goals

- Not the full Red/Blue/Purple family (`cybersec-red` and `cybersec-blue` are later cycles;
  Purple is a documented composition, never a standalone module).
- Not a Maltego *integration build* (no transform-server code) — Maltego enters as a governed
  **tool entry**, not as software this repo ships.
- Not "activating" `cybersec-osint` on this repo — the module is catalog-only (see Dogfood split).
- Not the framework harvest itself (separate, maintainer-gated, later cycle).

## Open questions (resolve at planning; not blocking design)

- Exact `sensitivePaths` regexes for the OSINT collection surface (validate against a real
  investigations layout at implementation).
- Whether the charter validator is a **new** validator or an extension of an existing
  module-gated validator (lean new, to keep the privacy/charter concerns separable — but confirm
  the §10 posture wording at PRD-time).
- Whether `cybersec-osint` should `dependsOn` (vs merely *compose with*) `privacy-by-design` —
  likely compose-with (no hard dependency), documented in both, exactly as AEC×privacy resolved.
- Final Maltego stop-condition wording in TOOLS.md (the "no person-entity transforms without an
  active charter" rule) — phrasing reviewed with the user before Phase 2.
