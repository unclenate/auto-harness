<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0042 — Greenfield Onboarding Conservatism: Route Contextless Greenfield to Discovery, Don't Over-Assert Modules or Enforcement

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-06-05
**Last Updated:** 2026-06-07
**Confidence:** medium

---

## Thesis

For a complete **greenfield** project with near-zero context (a one-line
description, no code, no `package.json`), the onboarding flow nonetheless asserts a
full *enforced* module set and authors a complete artifact tree. The
`harness-onboarding` skill's "conservative module selection" rule is
evidence-based, but its notion of evidence is **brownfield-shaped** (files present
in the repo). Greenfield has no files, so "no evidence" should resolve to "almost
nothing is assertable yet" → **route to a discovery-stage manifest**
(`new-product-discovery` / `interview-driven`), not a guessed, enforcement-on
composition. The harness should make greenfield-with-minimal-context **default to
discovery**, keep **intent-only modules out of the active/enforced set** until
evidence exists, and **not flip `required-artifacts` on** until the modules that
require those artifacts are actually grounded.

## Origin / Evidence

- **Concrete incident, this session (since fully reverted).** From the single
  prompt "a portfolio site for me," the greenfield onboarding produced a manifest
  that:
  - asserted `stacks: node-typescript` and `architectures: web-app` as **active
    modules**;
  - authored a complete `docs/` tree (operating-principles, `ADR-0001`,
    privacy-profile, product problem-statement / requirements / release-intent,
    architecture overview);
  - **re-enabled `required-artifacts` enforcement** (removed it from
    `disabledValidations`) — all *before any code existed*.
- **The flow admitted it was guessing.** The generated manifest comments read
  *"intent: React Native (Expo / react-native-web); enforcement deferred until
  package.json exists"* and *"greenfield scoping; artifacts deferred to Phase 2"* —
  yet the inferred modules were still written in as active and enforcement was
  still turned on. The skill knew it was inferring a whole stack from one sentence
  and committed to it anyway.
- **Distilled observation (this PR).** The generalized learning behind this
  candidate is recorded at
  [`docs/knowledge/shared-observations.md`](../knowledge/shared-observations.md)
  → *"Onboarding validates a consumer's file content but never its location /
  repository identity — the highest-consequence install failures are silent and
  location-dependent"* (shared with OPP-0041; the greenfield over-assertion is its
  second failure mode).

## Why Now

- Greenfield-from-a-sentence is the most common "solo founder vibecoding an MVP"
  entry point — explicitly named in the README's "Who This Is For." Letting it
  over-commit produces **day-zero artifact debt and false governance signal**
  (a manifest that looks decided when nothing has been).
- The right destinations already exist — `new-product-discovery.yaml`,
  `interview-driven-discovery.yaml`, and `discovery-to-composition.md` — plus the
  intent-vs-evidence distinction. Onboarding simply doesn't **gate on them** for
  the contextless-greenfield case. This is routing/defaults work, not new
  machinery.
- Cheap to correct before greenfield adoption scales; it pairs naturally with the
  containment guard in [OPP-0041](OPP-0041-onboarding-containment-safety.md) (same
  incident, same install moment).

## Risks / Open Questions

- **Where is the line** between "enough context to compose" and "route to
  discovery"? Candidate rule: assert no `stacks`/`architectures` module until at
  least one concrete evidence artifact exists (`package.json`, `pyproject.toml`, a
  framework the operator explicitly affirms); otherwise discovery-only.
- **Intent vs. active in the schema.** Should the manifest gain a first-class home
  for intent-only modules — a structured `intent:` block distinct from `modules:`,
  or a recognized commented form — so guesses are *recorded* without being
  *enforced*? Ties into OPP-0040's preflight and the manifest schema.
- **Don't flip `required-artifacts` on** until the triggering modules are
  grounded. The greenfield default should keep
  `disabledValidations: [required-artifacts]` through the discovery phase and lift
  it per-module as evidence lands.
- **Interview depth.** Contextless greenfield arguably should trigger a short
  `interview-driven` intake (a handful of questions) rather than silent inference.
  How many questions before it becomes friction the vibecoder bounces off?
- **De-duplicate, don't reinvent.** This is about making onboarding *route to* the
  existing discovery surfaces by default; the design must avoid restating
  `discovery-to-composition.md`.
- **Sibling pattern.** Another instance of "inference without evidence" (sibling of
  OPP-0040's late-surfaced prerequisites and OPP-0041's containment gap, all from
  the same onboarding incident) — captured as the paired shared-observation this PR
  adds (linked under Origin / Evidence).

## Disposition

**Accepted 2026-06-07.** Promoted to PRD-0021 and implemented in the same PR as a
skill-guidance change. `harness-onboarding` SKILL.md now names **greenfield** as a
distinct mode (no code *and* no governance docs), treats an operator's verbal
description as **intent, not evidence**, routes greenfield to a discovery posture
(`management/discovery-intake` / `new-product-discovery` / `interview-driven`),
records intended-but-unevidenced modules as `# intent:` comments, and keeps
`required-artifacts` disabled until real code evidence appears. The
`intent:` *manifest schema field* is deferred (v1 uses comments); no validator is
added because onboarding is AI-judgment work (the claim is Half-enforced via the
skill instruction). `install.sh` is unchanged — `brownfield-lite` already ships
`required-artifacts` disabled, and the over-assertion originated in the skill.

## Promotion

- See [`docs/requirements/PRD-0021-greenfield-onboarding-conservatism.md`](../requirements/PRD-0021-greenfield-onboarding-conservatism.md)
