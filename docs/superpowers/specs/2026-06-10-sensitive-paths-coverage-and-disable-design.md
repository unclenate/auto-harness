# Design — `validate-sensitive-paths`: composition coverage + disable lever (Issue #88)

> Status: draft for review · Author: Claude Code (claude-opus-4-8) · Date: 2026-06-10
> Issue: [#88](https://github.com/unclenate/auto-harness/issues/88) ·
> Related: PR #114 (privacy-by-design self-coverage — same doctrine, first instance)

## Problem

Two compounding defects make `validate-sensitive-paths` unsatisfiable for consumers
and for auto-harness's own shipped compositions.

- **Bug A — modules ship `sensitivePaths` that no companion rule covers.** Reproduced
  on current `main`: **8 of 13** shipped `platform/compositions/*.yaml` fail, across
  **7 modules** (not the 2 named in the issue). The validator requires every active
  `sensitivePath` to be overlapped by some active `companionRules.triggerPaths` regex;
  these modules declare sensitive paths they never enforce.
- **Bug B — `validate-sensitive-paths.sh` ignores `overrides.disabledValidations`.**
  Unlike `validate-required-artifacts.sh` / `validate-companions.sh` /
  `validate-agent-pack.sh`, it has no `HarnessRegistry.disabled_validation?` early-return,
  so the one documented consumer escape hatch is a no-op. This is the more serious half:
  a consumer hitting Bug A cannot ship green even by disabling the check.

### Complete reproduced orphan set (current `main`)

| Module | Uncovered `sensitivePaths` |
|--------|----------------------------|
| `digital-twin` | `^data/`, `^public/scenarios/` |
| `node-typescript` | `^tsconfig\.` |
| `testing-standard` | `^jest\.config`, `^vitest\.config`, `^pytest\.ini$`, `^pyproject\.toml$`, `^setup\.cfg$` |
| `web3` | `^src/agents/` |
| `healthcare-fhir` | `patient`, `observation`, `bundle`, `phi` |
| `healthcare-smart-on-fhir` | `launch`, `token`, `oauth` |
| `self-hosted-oss` | `^docs/product/release-intent\.md$`, `^CHANGELOG` |

## Root cause

The validator is **correct by design**. Its stated purpose (OPP-0034 / ADR-0017 Wave 5.3,
closing safety-sweep §2 claim 12) is to close the *sold-as-policy-but-never-checked* gap:
"a path declared sensitive MUST be under elevated review via at least one companion rule."
The failing modules are the defect — they declared `sensitivePaths` they never wired to a
companion rule. This is the same class PR #114 fixed for `privacy-by-design`.

Inspection shows `sensitivePaths` is being used for two superficially-similar but distinct
purposes: **path-prefix markers** (`^tsconfig\.`, `^data/` — "review changes under this
shape") and **content-keyword markers** (`patient`, `oauth` — unanchored substrings,
"flag files mentioning this term"). The overlap invariant is coherent only for the former.
The content-keyword markers (healthcare PHI/auth) are the genuinely debatable cases.

## Decision

**Affirm one meaning for `sensitivePaths`** — *"path-shapes requiring companion-backed
elevated review"* — and resolve every orphan by **self-coverage**: fold each uncovered
pattern into its *own declaring module's* companion rule (the PR #114 doctrine), so each
module is correct in isolation rather than by ambient cross-module coverage.

Rejected alternatives:

- **Two-tier validator** (anchored = enforced, unanchored = advisory-exempt) — reopens the
  *never-checked* gap by design and changes the validator's contract (maintainer doctrine).
- **New `awarenessMarkers` schema field** — schema churn across modules + a new validator
  or purely-documentary field; loses the simple single invariant.
- **Relax overlap for `optionalArtifact` paths** (issue's option 2) — an indirect proxy
  that doesn't map cleanly to the path-vs-content distinction.

Self-coverage needs **no validator change and no schema change** for Bug A — only module
`companionRules.triggerPaths` edits. It is the least-invasive, most doctrine-conservative,
fully-reversible option, and it matches the precedent set one PR earlier.

## Workstreams

### A — Module self-coverage

For each orphan, add the pattern to the semantically-correct existing companion rule on the
declaring module (creating one rule only where none fits the surface):

| Module | Orphan(s) | Target companion rule → `requiredAny` |
|--------|-----------|----------------------------------------|
| `digital-twin` | `^data/`, `^public/scenarios/` | "scenario/model/agent/dataset" rule → twin artifact / ADR |
| `node-typescript` | `^tsconfig\.` | "major dependency or runtime changes" rule → ADR / architecture / PRD |
| `testing-standard` | `^jest\.config`, `^vitest\.config`, `^pytest\.ini$`, `^pyproject\.toml$`, `^setup\.cfg$` | quality-gate rule → change-log / ADR / PRD (extend coverage-thresholds rule or add a "test/build config" rule) |
| `web3` | `^src/agents/` | "scoring and signal rules" companion rule (add a `requiredAny` if that block lacks one) |
| `healthcare-fhir` | `patient`, `observation`, `bundle`, `phi` | existing "PHI-schema-touching changes require a risk-register update" rule |
| `healthcare-smart-on-fhir` | `launch`, `token`, `oauth` | existing "SMART implementation and auth-surface changes" rule → risk-register / ADR |
| `self-hosted-oss` | `^docs/product/release-intent\.md$` | add/extend a release-surface rule → self-hosting-guide / change-log / ADR |

**Maintainer-judgment items (defaults stated; confirm at review):**

1. **`^CHANGELOG` (self-hosted-oss)** — requiring a companion to *edit the changelog* is
   semantically backwards (the changelog is itself the audit record). **Default: remove
   `^CHANGELOG` from `sensitivePaths`** rather than enforce it. (Keep `release-intent.md`,
   which is a genuine release-decision surface.)
2. **`bundle` / `token` (healthcare)** — broad bare substrings (`bundle` also matches JS
   bundles; `token` matches many things). **Default: enforce as-is** — these are opt-in
   domain modules whose purpose is heightened PHI/auth governance; narrowing/anchoring the
   substrings is a separate, non-blocking maintainer follow-up.

Every edited `module.yaml` is a PRD-0004 distillation trigger, so Workstream A's PR carries
**one** `docs/knowledge/shared-observations.md` entry (the systemic self-coverage finding —
generalizing the #114 single-module observation to a catalog-wide audit) plus a
`docs/project/change-log.md` audit-trail entry (the paired companion cascade; see PR #114).

### B — Disable lever (Bug B)

Add to `validate-sensitive-paths.sh`, immediately after manifest load, matching
`validate-required-artifacts.sh`:

```bash
if HarnessRegistry.disabled_validation?(manifest, "sensitive-paths")
  puts "✓ Sensitive-paths validation disabled by manifest override"
  exit 0
end
```

The disable key is `"sensitive-paths"` (the validator's short name, matching the issue's
documented `overrides.disabledValidations: [sensitive-paths]` and the sibling convention).
No effect on the harness's own CI (its manifest does not disable the check).

### C — Prevention

Run the validator over the shipped compositions so the project's own examples gate this
class:

- A **CI step** (in the Validators job) iterating `platform/compositions/*.yaml` through
  `validate-sensitive-paths.sh`, failing the build on any uncovered pattern.
- A **Minitest integration test** asserting every `platform/compositions/*.yaml` passes
  `validate-sensitive-paths.sh` (exit 0), co-located with the existing validator tests.
- A **regression fixture/test** for Bug B: a manifest with
  `overrides.disabledValidations: [sensitive-paths]` exits 0 with the override message.

Workstream C can only go green after Workstream A is complete, so it sequences last.

## Sequencing (finalized in the plan)

1. **B** — validator escape-hatch + disable test. Independent, doctrine-neutral, immediate
   consumer value. Smallest first increment.
2. **A** — module self-coverage edits + distillation + change-log. Resolves all compositions.
3. **C** — composition CI step + integration test + Bug-B regression test. Depends on A.

Whether this ships as one PR with ordered commits or 2–3 PRs is a planning decision.

## Testing strategy

- **Bug B:** TDD — failing test (disabled manifest → expect exit 0 + override message)
  before the early-return.
- **Bug A:** the existing `validate-sensitive-paths.sh` run over each composition is the
  acceptance test (red → green per composition); no new validator logic to unit-test.
- **Prevention:** the composition-sweep integration test is itself the regression guard.

## Acceptance criteria (from the issue)

- [ ] `validate-sensitive-paths` passes on all shipped `platform/compositions/*.yaml`.
- [ ] `overrides.disabledValidations: [sensitive-paths]` makes the validator exit 0 with a
      "disabled by manifest override" message.
- [ ] CI runs `validate-sensitive-paths` over the shipped compositions.
- [ ] No regression in the harness's own 17-validator suite (146 runs / 591 assertions).

## Out of scope

- The broader audit of "11+ of 17 validators lack the disable early-return" (issue's
  Bug-B follow-up) — confirm which are intentionally non-disableable; separate pass.
- Narrowing over-broad content-keyword substrings (`bundle`, `token`) — maintainer follow-up.
- Any change to the overlap-matching algorithm (the 3-tier approximation stays).
