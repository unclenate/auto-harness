<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0066 — `management/accessibility-standard` overlay (WCAG conformance gate for web-app / agentic-ui)

**Status:** proposed
**Owner:** @unclenate · **Created/Updated:** 2026-10-11
**Confidence:** high (the gap is real and the implementation pattern is a proven template — `security-static-analysis`); medium (the exact declaration fields + recommended-tool set are review choices)
**Source:** GitHub issue #93 (filed 2026-06-02) — harness-native capture
**Parent / model:** OPP-0035 / PRD-0016 (`management/security-static-analysis`); sibling of `testing-standard`

## Thesis

Accessibility is effectively **absent from the harness as a governed concern** — a repo-wide search finds it
only as a single weak release-checklist line ("documentation accessible and renders correctly") and an
incidental intake-questionnaire mention. No module, validator, skill, or companion rule. Yet for any
`architectures/web-app` or `domains/agentic-ui` consumer shipping to the public, **WCAG conformance is a real
launch gate** — exactly the kind of structural quality commitment the harness already models for tests
(`testing-standard`) and static analysis (`security-static-analysis`).

Add an opt-in **`management/accessibility-standard`** overlay, modeled directly on
`management/security-static-analysis`. **Tool-neutral:** the harness validates the consumer's *declaration*;
running the audit (axe-core / Lighthouse / pa11y / WAVE) stays in consumer CI — the same §10 **Half-enforced**
boundary as SAST (harness owns the contract; consumer CI honors it for end-to-end enforcement).

## Design (sketch — the implementation pass firms these)

**`module.yaml`** (opt-in `management` overlay, `dependsOn: kernel/base`, `stability: experimental` at v1):

- `requiredArtifacts: docs/quality/accessibility.md` — the conformance declaration.
- `optionalArtifacts: docs/quality/accessibility-reports/` — the evidence trail.
- `sensitivePaths:` `^docs/quality/accessibility\.md$` — changes move the a11y gate.
- `companionRules:` changes to UI/source paths (`^app/`, `^src/`, `^components/`) require an updated
  `accessibility.md` **or** a change-log entry — silently extending the UI surface without re-checking
  conformance weakens the gate.

**`validate-accessibility.sh`** — modeled on `validate-sast-coverage.sh` (module-gated, `--scan-file`,
predict-clean so the harness's own CI is a no-op pass since it does not activate the overlay). When active,
parses `docs/quality/accessibility.md` YAML frontmatter and asserts:

- `targetLevel:` from `{WCAG 2.1 A, WCAG 2.1 AA, WCAG 2.1 AAA, WCAG 2.2 A, WCAG 2.2 AA, WCAG 2.2 AAA}`
- `auditTool:` from a recommended set `{axe-core, lighthouse, pa11y, wave}` (tool-neutral, like the SAST tool enum)
- `scope:` non-empty (which routes/components the commitment covers)
- `lastAudited:` a date + result (presence + shape only — never the semantic correctness of the audit, the
  same `validate-module-stability` boundary SAST observes)

**Template** `platform/templates/quality/accessibility.md` with the frontmatter + the usual unfilled
placeholder fields (the harness's `[[…]]` fill-before-commit convention).

## Scope & disposition

Design-only, `proposed`. Implementation (the `module.yaml` + `validate-accessibility.sh` +
`validate-accessibility`-chain entry + template + the mandatory catalog propagation to `SUMMARY.md` /
`docs/README.md` module table / `harness-onboarding` SKILL / `discovery-to-composition.md` per operating-
principles § 3) is a follow-on PRD or a direct OPP→implementation pass — half-day-scoped because it is a
near-mechanical copy of the SAST overlay. Advancing to `accepted` is the maintainer's call. Closes GitHub
issue #93 when it ships.

## Open questions

1. **Declaration field set** — the four fields above, or also a `knownGaps:` / `exceptions:` list (documented
   non-conformances with a remediation date)?
2. **WCAG version default** — recommend `WCAG 2.2 AA` as the documented default target, or stay silent and
   require the consumer to state it?
3. **PRD or direct impl** — given it mirrors `security-static-analysis` almost exactly, ship via a short PRD
   (like PRD-0016) or a direct OPP→impl pass?
4. **Scope of companion trigger** — the generic `^app/|^src/|^components/` UI-path set, or let the consumer
   declare its own UI roots (some consumers keep UI under `packages/*/`)?

## Neighbors

- **OPP-0035 / PRD-0016** (`security-static-analysis`) — the direct model; this is the same declare-validate /
  consumer-CI-enforces pattern applied to accessibility.
- **`testing-standard`** — the other member of the consumer-declared quality-gate overlay family.
- **`architectures/web-app` / `domains/agentic-ui`** — the consumers this overlay serves.

## Provenance

Harness-native capture of **GitHub issue #93** (a well-formed module proposal by @unclenate, 2026-06-02),
filed as an OPP so the design is a first-class governed record on the catalog surfaces. The design is
corroborated by the shipped `security-static-analysis` precedent — no new enforcement mechanism is invented,
only a new declaration contract instantiated from the existing quality-gate-overlay template. No external
claims pending; no private names in this record.
