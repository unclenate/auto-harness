<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0023 — Make `validate-doc-references` consumer-aware (it hard-fails for submodule consumers)

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-05-25
**Last Updated:** 2026-05-25 *(accepted; PRD-0012 drafted + implemented same-PR)*
**Confidence:** high

---

## Thesis

`validate-doc-references.sh` hard-requires a `<project-root>/platform/`
directory and exits `2` (usage error) when it is absent — so for a **submodule
consumer** (where the platform lives at `.harness/platform/`, not `./platform/`)
the validator fails on every run. Meanwhile the consumer CI template
`platform/templates/ci/github-actions.yml` **includes** a `validate-doc-references`
step, while `platform/workflow/ci-integration.md`'s "Minimal Working Workflow"
**omits** it. The template and the guide disagree, and following the template
gives a consumer a red CI on the recommended layout.

Markdown-link resolution is useful for *any* repo. Fix the validator to run its
general link-resolution pass against the consumer's own `*.md` regardless of
whether a `platform/` tree exists, treating the platform-specific bare-path
pass (Pass 1) as conditional on `platform/` being present. Then align the CI
template + guide so consumers get link validation without a spurious exit `2`.

## Origin / Evidence

- **Consumer project: Tula (`github.com/unclenate/tula` fork).** Brownfield
  onboarding 2026-05-25. Wiring the harness validator chain into CI surfaced
  this immediately: `bash .harness/platform/validators/validate-doc-references.sh .`
  from the Tula root exits `2` with `✗ ./platform does not exist — nothing to
  scan.` Recorded in the consumer's `docs/adr/ADR-0002-ci-validator-gate.md`,
  which excludes the step from Tula's CI as a workaround.
- **Code-level evidence:** `platform/validators/validate-doc-references.sh`
  lines ~92–95 hard-fail when `${PROJECT_ROOT}/platform` is absent:

  ```sh
  if [[ ! -d "${PROJECT_ROOT}/platform" ]]; then
    echo "✗ ${PROJECT_ROOT}/platform does not exist — nothing to scan." >&2
    exit 2
  fi
  ```

  Pass 1 ("bare `platform/...` references under `platform/*.md`") is
  harness-self-specific; Pass 2 (general `[text](target)` relative-link
  resolution + render-safety) is consumer-relevant but is never reached
  because the guard exits first.
- **Doc/template mismatch:** `platform/templates/ci/github-actions.yml`
  includes a `Validate doc references` step; `platform/workflow/ci-integration.md`
  "Minimal Working Workflow" lists six validators and omits doc-references.
  A consumer copying the template (the documented path) gets a failing job.

## Why Now

- The v0.5.2 agent-native delivery batch just made the harness more attractive
  to **submodule consumers**, and the first such consumer to wire CI (Tula) hit
  this on the first run. It is a low-cost fix that removes a concrete
  onboarding stumbling block exactly when submodule-consumer traffic is likely
  to grow.
- It is a self-contained defect with a clear fix; it does not depend on any
  in-flight PRD.

## Risks / Open Questions

- **Fix shape.** Two options: (a) make the validator scan consumer `*.md` and
  resolve links when no `platform/` exists (skipping Pass 1), so consumers gain
  real link validation; (b) merely remove the step from the template. **(a) is
  recommended** — it makes the validator useful for consumers rather than
  silently dropping a check — with (b)'s template/guide alignment done either
  way. PRD authoring decides.
- **Dogfood backward-compat.** auto-harness's own repo has `platform/`, so Pass
  1 still runs there; the fix must be additive (no behavior change for the
  self-run). A self-test fixture for the no-`platform/` consumer case should be
  added.
- **Ignore-file parity.** The validator already loads `.doc-reference-ignore`;
  the consumer-scan path should honor a consumer-root `.doc-reference-ignore`
  the same way.
- **Exit-code contract.** "No markdown to scan" should be a clean `0`, not a
  `2` usage error — `2` should remain reserved for genuine misuse (missing
  project root).

## Disposition

**Accepted 2026-05-25.** Promoted straight to implementation in one PR
(maintainer-directed). The fix shape resolved to **consumer-aware validator**
(remove the `platform/`-must-exist guard) rather than remove-from-template: the
Ruby was already consumer-safe (Pass 1 no-ops via empty glob; Pass 2 scans
consumer docs), so the only change was deleting the bash guard. Exit `2` is now
reserved for a missing `<project-root>`; "nothing to scan" is a clean `0`. The
old `test_missing_platform_dir_aborts` test encoded the buggy contract and was
replaced with four tests (incl. two no-`platform/` consumer fixtures). The CI
template + guide were aligned and the ripgrep install hardened (bundled, same
files). See PRD-0012 for resolved design questions.

## Promotion

- See [`docs/requirements/PRD-0012-doc-references-consumer-aware.md`](../requirements/PRD-0012-doc-references-consumer-aware.md)
- Implementation: `platform/validators/validate-doc-references.sh` (guard removed) + self-test fixtures `consumer-no-platform-{valid,broken}`

## Related

- Evidence: consumer project (`tula`) `docs/adr/ADR-0002-ci-validator-gate.md`
- Validator: `platform/validators/validate-doc-references.sh`
- Mismatch: `platform/templates/ci/github-actions.yml` (includes the step) vs
  `platform/workflow/ci-integration.md` "Minimal Working Workflow" (omits it)
- Surfaced during the Tula brownfield onboarding (OPP-0018..0022 batch, v0.5.2)
