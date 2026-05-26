<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0012: `validate-doc-references` Consumer-Aware Scan

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-05-25 | **Review Cycle:** On-change

**Status:** Accepted *(v1 implemented in the same PR)*
**Date:** 2026-05-25 (filed) | 2026-05-25 (accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Promotes: [OPP-0023](../opportunities/OPP-0023-doc-references-consumer-scan.md) — `proposed` → `accepted`
- Evidence: consumer project `tula` at `docs/adr/ADR-0002-ci-validator-gate.md` (excluded the step as a workaround)
- Sibling: [OPP-0025](../opportunities/OPP-0025-consumer-integration-smoke-test.md) (consumer-side integration robustness)
- Observation: `docs/knowledge/shared-observations.md` — *"A validator that hard-requires the harness's own repo layout is a consumer-onboarding stumbling block"* (2026-05-25)

## Overview

`validate-doc-references.sh` hard-required a `<project-root>/platform/` directory
and exited `2` when it was absent. For a **submodule consumer** — the harness's
own recommended layout, where the platform lives at `.harness/platform/` — there
is no top-level `platform/`, so the validator failed on every run, never reaching
its general markdown-link-resolution pass on the consumer's own docs. The
consumer CI template (`templates/ci/github-actions.yml`) included a doc-references
step while `ci-integration.md`'s minimal workflow omitted it, so a consumer
following the template got a red CI on the recommended layout.

Surfaced by the Tula brownfield onboarding (OPP-0023); recorded consumer-side in
`tula:docs/adr/ADR-0002`, which excluded the step as a workaround.

The fix is small because the Ruby was already consumer-safe: Pass 1 (the v1
`platform/...` bare-path dogfood) globs `platform/**/*.md` and naturally no-ops
when the directory is absent; Pass 2 scans every `*.md` under the project root
regardless. Only the bash guard forced the failure.

## Goals & Non-Goals

**Goals**

- Make `validate-doc-references.sh` validate a submodule consumer's own docs
  without a top-level `platform/`, while leaving the harness dogfood unchanged.
- Reserve exit `2` for a genuinely missing `<project-root>`; "nothing to scan"
  is a clean exit `0`.
- Lock the new contract with self-tests (incl. a no-`platform/` consumer fixture).
- Align the consumer CI template + guide; harden the ripgrep install.

**Non-Goals**

- **The M-j list-completeness validator-hardening** (make `validate-catalog-counts`
  assert index completeness) — separate, Phase 3 of the 2026-05-25 audit.
- **Module-README standardization (M-b)** — separate, Phase 4.
- Changing Pass 1 / Pass 2 link-classification semantics — purely additive scope.

## Functional Requirements

### FR-001 — Remove the `platform/`-must-exist guard

Delete the `[[ ! -d "${PROJECT_ROOT}/platform" ]] → exit 2` guard. Pass 1
no-ops via an empty glob when `platform/` is absent; Pass 2 scans the
consumer's `*.md`. The `<project-root>`-missing guard (exit `2`) remains — it
is the only genuine usage error. An existing root with no markdown at all
resolves to a clean exit `0`.

### FR-002 — Self-tests for the new contract

Replace `test_missing_platform_dir_aborts` (which asserted the *old, buggy*
exit-`2`-on-missing-`platform/` contract) with:

- `test_missing_project_root_aborts` — nonexistent root → exit `2`.
- `test_empty_dir_has_nothing_to_scan_and_passes` — empty dir → exit `0`.
- `test_consumer_without_platform_dir_valid_passes` — fixture
  `consumer-no-platform-valid` (no `platform/`, resolving links) → exit `0`.
- `test_consumer_without_platform_dir_broken_is_flagged` — fixture
  `consumer-no-platform-broken` (no `platform/`, a broken link) → exit `1`,
  broken path in stderr.

The dogfood test (`test_runs_clean_against_harness_repo`) is unchanged and
still passes — Pass 1 still guards the harness's own `platform/` tree.

### FR-003 — Align the consumer CI surface

Add `validate-doc-references` to `ci-integration.md`'s validators table and its
"Minimal Working Workflow" (it is now consumer-safe), matching
`templates/ci/github-actions.yml`, which already includes the step.

### FR-004 — Harden the ripgrep install (bundled adjacent fix)

`sudo apt-get install -y ripgrep` → `sudo apt-get update && sudo apt-get
install -y ripgrep` in `templates/ci/github-actions.yml` and the four example
workflows in `ci-integration.md` (avoids intermittent failures on GitHub-hosted
runners with stale package indexes). `templates/ci/gitlab-ci.yml` already runs
`apt-get update`. Bundled because FR-003 already edits these exact CI files and
the theme is identical (consumer-CI reliability).

### FR-005 — Promotion & propagation

OPP-0023 → `accepted` (Disposition + Promotion populated); `SUMMARY.md` PRD
list gains PRD-0012; `candidates.md` OPP-0023 status bumped; change-log audit
row; one paired `shared-observations` entry.

## Acceptance Criteria for OPP-0023 → `accepted`

1. This PRD `Accepted`.
2. FR-001…FR-005 merged to `main`.
3. Full self-test suite green (incl. the new no-`platform/` fixtures) on
   ubuntu + macos; shellcheck clean on the validator; the harness's own
   doc-references run still green.
4. The consumer CI template and the `ci-integration.md` minimal workflow agree.

## Out of Scope

- M-j list-completeness hardening; M-b module-README standardization (separate
  audit phases).
- Re-adding doc-references to *tula's* CI — that's a consumer-side choice for
  the tula repo, not part of this harness change.

## Risks

- **Behavior change to a shared validator.** Mitigated: the change is removing
  a guard the Ruby never needed; the dogfood test and the full 76-run
  integration suite pass unchanged; the one removed test encoded the *buggy*
  contract and is replaced with four asserting the correct one.
- **"Nothing to scan" masking a real miss.** A consumer with zero `*.md` exits
  `0` — correct (nothing to validate is success), and an empty repo is not a
  state the validator should fail.

## Open Questions Resolved

- **Fix shape — consumer-aware validator vs. remove-from-template?** →
  **consumer-aware.** Link validation is useful for any repo and the Ruby was
  already consumer-safe; removing the step from the template would drop a
  useful check. Both template and guide now include it.
- **Exit-code contract?** → `2` only for a missing `<project-root>`; `0` for
  nothing-to-scan.
- **Self-test for the no-`platform/` path?** → two fixtures + four tests added
  (the dogfood's own `platform/` previously masked this path).

## Versioning Implications

Validator bugfix; no module/schema change and no catalog-count change. Ships as
a **v0.5.3** patch (validator-reliability lane, alongside the v0.5.1/v0.5.2
catalog patches). The maintainer may re-sequence.
