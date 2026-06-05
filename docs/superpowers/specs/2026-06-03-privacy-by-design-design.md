<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Design — Privacy by Design, by Default

**Status:** Draft (brainstorming output, pending user review)
**Author:** @unclenate
**Date:** 2026-06-03

---

## Purpose

Make **privacy by design (PbD)** a concept the harness understands, practices in its
own construction, and helps consumer projects implement **by default** — warning users
of the privacy implications of their choices and validating the outcomes. PbD is a
**cross-cutting concern**, not a vertical domain: it composes with every domain overlay
(healthcare PHI, the future construction ISO 19650-5 security-minded BIM, web3 keys).

## Four settled decisions (the approach)

1. **Posture: default-on, opt-out.** Every bootstrapped project gets PbD active. A
   project with genuinely no personal/sensitive data may opt out — but opt-out is
   **explicit and recorded**, not silent (see the active-but-exempt mechanism below).
2. **Enforcement: layered.** A validator **warns** on privacy-risk patterns (advisory);
   companion rules **enforce** that privacy artifacts exist/update when data-handling
   paths change (the floor); review gates **prevent** risky merges via required human
   sign-off.
3. **Framework anchor: Cavoukian's 7 Foundational Principles of Privacy by Design** as
   the **always-on, jurisdiction-neutral spine** (the review-gate checklist). Legal-regime
   variance (GDPR / CCPA-CPRA / LGPD / PIPEDA / PIPL / …) is a **consumer-declared choice
   at initialization**, captured in a forcing artifact — reusing the jurisdiction-neutral
   core + forcing-artifact + bias-guardrail primitives from the deep-domain (healthcare)
   framework.
4. **Init-time guided choice with a warned "none".** At onboarding the harness *educates*
   (plain-language explainer of the 7 principles) then asks the consumer to pick a legal
   regime — or `none`, which is allowed but requires a one-line documented exemption and a
   recorded warning. A later change that introduces data-handling re-triggers the choice.

### Cavoukian's 7 principles (the spine)

1. Proactive, not reactive — prevent privacy problems at design time, not post-incident.
2. Privacy as the default setting — protected even if the user does nothing.
3. Privacy embedded into design — built into architecture, not bolted on.
4. Full functionality, positive-sum — reject false privacy-vs-features / privacy-vs-security
   trade-offs.
5. End-to-end security, full lifecycle — protect data from collection → use → secure
   destruction.
6. Visibility and transparency — open and verifiable about what is collected and why.
7. Respect for user privacy — strong defaults, real consent, user-centric controls.

Principle #2 *is* the default-on posture; #1 and #3 are why a design-time governance
harness is the natural place to enforce PbD at all.

## Goals / Non-Goals

**Goals**

- An operating principle (§11), an ADR (the posture decision), a default-active management
  overlay, a validator, privacy templates, and init-flow education.
- "No legal regime is the default" — the principles are the universal floor; the statute is
  the consumer's declared choice.
- Warn about privacy implications of choices; validate that privacy artifacts/outcomes exist
  and are internally consistent.

**Non-Goals**

- Not a legal-compliance engine. The harness governs *design discipline*, not certified
  legal conformance; it points at the consumer's declared regime, it does not adjudicate it.
- Not kernel-mandatory. PbD is default-active and opt-out, not unconditionally inherited by
  every project (rejected alternative — recorded in the ADR).
- Not a runtime data-scanner. The validator inspects repo/diff text patterns and artifact
  presence/consistency, not live data flows.

---

## Architecture — five cooperating pieces

| Piece | What it is |
|-------|------------|
| **Operating Principle §11 — "Privacy by Design, by Default"** | New section in `docs/operating-principles.md`. Codifies the stance: the platform is built around the 7 principles; consumer projects get PbD on by default; explains the spine + init-choice + opt-out. |
| **ADR-0018 — privacy-by-default posture** | Records why default-on/opt-out was chosen over opt-in or kernel-mandatory. |
| **`management/privacy-by-design` overlay** | Default-active at bootstrap. Required/optional artifacts, companion rules (floor), review gates. |
| **`validate-privacy-by-design.sh`** | The WARN (advisory risk detection) + VALIDATE (artifact presence/consistency) layers. Joins the suite (14→15) + the three CI workflows. |
| **`platform/templates/privacy/`** | `privacy-profile.md` (init-choice artifact: 7-principle explainer + regime choice + bias guardrail + `none` exemption), `data-inventory.md`, optional `privacy-impact-assessment.md`. |

Plus init-flow touchpoints: `harness-onboarding/SKILL.md`, `discovery-to-composition.md`,
`intake-questionnaire.md`, `bootstrap-quickstart.md`.

### Default-on, opt-out mechanism (load-bearing detail)

The overlay is added to the **default manifest template** at bootstrap, so it is *active*
on every new project. "Opt-out" does **not** remove the module — it stays active in
**exempt mode**, recorded by `privacy-profile.md` declaring `regime: none` + a one-line
exemption. The validator keeps watching: if data-handling patterns appear later despite the
exemption, it warns and prompts re-choosing a regime. Removal-from-manifest is possible but
discouraged; exempt-mode is the recommended opt-out.

## The overlay — `management/privacy-by-design`

| Field | Value |
|-------|-------|
| `id` / `type` | `privacy-by-design` / `management` |
| `dependsOn` | `kernel/base` |
| `conflictsWith` | none |
| **Required** artifacts | `docs/privacy/privacy-profile.md` — the only always-required artifact (so an exempt project satisfies the overlay with one file) |
| **Optional** artifacts | `docs/privacy/data-inventory.md`, `docs/privacy/privacy-impact-assessment.md` |
| `sensitivePaths` | data-handling surfaces: paths matching `pii`, `personal`, `user-data`, `consent`, `analytics`, `telemetry`, `tracking`, `auth`, third-party SDK/vendor config |
| `companionRules` | **(1)** data-handling sensitive-path change → require a `privacy-profile.md` **or** `data-inventory.md` update **or** ADR (floor); **(2)** `privacy-profile.md` regime/exemption change → require change-log or ADR (governance decision) |
| `reviewGates` | human sign-off for: broadening data collection, adding third-party data egress, weakening a declared privacy default, changing legal regime, logging PII-shaped data |
| `validators` | `validate-privacy-by-design`, `validate-companions` |

Making `data-inventory.md` optional is the trick that lets a `none`-exemption project pass
with one file, while companion rule (1) pulls it in the moment a data-handling path changes.

## The validator — `validate-privacy-by-design.sh`

**VALIDATE (enforced — fails CI when overlay active):**

- `privacy-profile.md` must exist and be filled (regime declared, **or** `none` + a one-line
  exemption).
- Consistency: if `data-inventory.md` lists personal data but the profile says `regime: none`
  → fail (contradiction). If sensitive-data paths exist but the profile is `none` with no
  `data-inventory` → warn-and-prompt ("data-handling appeared despite your exemption").

**WARN (advisory — exit 0, reported; WARN-posture precedent: `validate-knowledge-redaction.sh`):**

- Scans for privacy-risk patterns and names the implication: new analytics/telemetry SDKs,
  third-party data egress, PII-shaped logging, new data-collection fields, data collection
  with no nearby consent handling. This is the literal "warn users of the implications of
  their choices."

**§10 Claim Classification:** `privacy-profile` presence = **Enforced**; risk-pattern
detection = **Half-enforced** (best-effort); privacy *outcomes* = **Asserted-only** (review
gate). A `--scan-file` test seam for fixture-firing tests (validator-test-seam pattern).

### Bias guardrail (reused primitive)

`privacy-profile.md` carries:

> **Bias guardrail.** No legal regime is the default. Declare yours below. Do not assume
> GDPR, US (CCPA/CPRA), or any single regime applies — privacy law is jurisdictional and the
> principles (Cavoukian's 7) are the universal floor, not any one country's statute.

## Init-time choice flow + templates

The harness's "initialization" is the bootstrap/onboarding interview, so the guided choice
lives there:

- **`privacy-profile.md` template** — four blocks: (1) plain-language 7-principle explainer;
  (2) regime-choice block (GDPR / CCPA-CPRA / LGPD / PIPEDA / PIPL / multiple / `decide-later`
  / `none`+exemption); (3) bias guardrail; (4) which principles are in force and how.
- **`data-inventory.md` template** — what personal data, where it flows, retention/destruction.
- **optional `privacy-impact-assessment.md` template** — DPIA-style, higher-risk projects.
- **`harness-onboarding/SKILL.md`** — privacy step: teach the 7 principles, walk the regime
  choice (or warned `none`), record in `privacy-profile.md`.
- **`discovery-to-composition.md`** — intake gains the regime question; Step 6 notes PbD is
  default-active.
- **`intake-questionnaire.md` + `bootstrap-quickstart.md`** — privacy section in intake;
  "privacy-profile present" added to Bootstrap-Complete.
- *(Optional, deferrable)* a `harness-privacy` skill for on-demand deep guidance, like
  `harness-testing`.

## Governance mapping + sequencing

Two phases (mirrors healthcare):

- **Phase 1 (design-only PR):** ADR-0018 (posture) + PRD-0018 (the overlay+validator+init-flow
  design contract, with §10 Claim Classification) + Operating Principle §11 addition.
- **Phase 2 (implementation PR):** overlay + validator + templates + init-flow edits +
  catalog-count propagation (validators 14→15, +1 module, +2–3 templates) + CI wiring
  (harness.yml, github-actions, gitlab-ci) + the dogfood/manifest decision.

PRD-0004 distillation note: ADR/module.yaml edits in each phase fire the cycle-end
distillation rule — pair each with a `shared-observations.md` (or operating-principles)
entry, not just a change-log entry.

## Harvest tie-in (strategic payoff)

PbD is the **first cross-vertical reuse** of the deep-domain framework's three primitives —
jurisdiction-neutral core, forcing artifact, bias guardrail — applied to a *cross-cutting
concern* rather than a domain. It is a third data point (with healthcare, and the planned
construction vertical) that the primitives generalize, strengthening the eventual harvest of
the framework into an operating principle.

## Open questions (resolve at planning/implementation; not blocking design)

- **Dogfood/manifest:** does auto-harness activate `privacy-by-design` in its own
  `harness.manifest.yaml` (true dogfood — writes its own `privacy-profile.md`), or ship it as
  a catalog overlay with self-activation deferred? This is a `harness.manifest.yaml` change =
  maintainer-authorized. Default: ship-as-catalog, dogfood-deferred, unless directed otherwise.
- Exact `sensitivePaths` / WARN regex set (validated against real consumer trees at
  implementation).
- Whether to ship the optional `harness-privacy` skill in Phase 2 or defer.
- Whether a PbD flow diagram is added to `docs/architecture/diagrams.md` (count impact).
