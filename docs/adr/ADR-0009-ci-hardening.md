<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0009: CI Hardening — Multi-OS Matrix, Bootstrap Test Coverage, CODEOWNERS, Dependabot

**Status:** Accepted
**Date:** 2026-05-18
**Author:** @unclenate
**Reviewers:** @unclenate
**Context source:** [Quality Audit 2026-05-18](../QUALITY-AUDIT-2026-05-18.md), Triage item #3, findings L2-01, L2-02, L1-10, L1-11, L3-04.

## Context

PR #12 discovered a pre-existing BSD-awk bug in `platform/bootstrap/install.sh` that had silently broken two macOS-only tests (`test_rerun_skips_harness_style_files`, `test_force_overwrites_harness_style_files`) for an unknown duration. The bug survived because CI ran only on `ubuntu-latest` — the project's primary consumer platform (macOS, per install.sh's Bash-4 preflight at `install.sh:60`) was never exercised in the pipeline.

The 2026-05-18 quality audit (PR #13) confirmed the broader gap:

1. **CI matrix is `ubuntu-latest` only** (L2-01). BSD-vs-GNU portability issues — including the entire class of bug PR #12 just fixed — go undetected.
2. **`test_install.rb` (23 classes / 144 assertions) and `test_link_skills.rb` are not run in CI at all** (L2-02). The consumer-facing bootstrap scripts have no automated regression gate. PR #12's bonus BSD-awk fix was caught only because the agent ran the suite locally.
3. **No `.github/CODEOWNERS`** (L1-10). Repo declares `@unclenate` as owner in `HARNESS.md` and `AUTHORS`, but GitHub's review-request automation depends on the file.
4. **No `.github/dependabot.yml`** (L1-11). CI pins `actions/checkout@v4` and `ruby/setup-ruby@v1` — these will eventually need updates. Repo-level `dependabot_security_updates` is enabled (per `gh api`), but version-update PRs don't get raised without the config file.

## Decision

Land these four CI/governance hardening changes in a single PR:

1. **CI matrix expansion.** Add `macos-latest` to both `validators` and `tests` jobs via a strategy matrix with `fail-fast: false`. Provision ripgrep per-OS (`apt` on Linux, `brew` on macOS).
2. **New `bootstrap-tests` job.** Parallel job that runs `test_install.rb` and `test_link_skills.rb` against the same `[ubuntu-latest, macos-latest]` matrix. Provision Homebrew bash on macOS so install.sh's Bash-4 requirement is satisfied at runtime.
3. **`.github/CODEOWNERS`.** Default `@unclenate` for everything, with explicit entries for governance-sensitive areas (`/platform/validators/`, `/platform/core/`, the entry-point markdown files, `/.github/`). Plain `#` comments only — GitHub's CODEOWNERS parser does not accept SPDX header comments.
4. **`.github/dependabot.yml`.** `github-actions` ecosystem at weekly cadence (Monday), commit prefix `chore(deps)`, labels `dependencies` + `github-actions`. Only ecosystem covered for now since the repo has no language manifests (Gemfile / package.json / etc.) — file comment documents the rationale so future maintainers know to extend.

## Consequences

### Positive

- BSD-vs-GNU portability regressions in shell scripts are caught at PR time, not by consumer reports.
- `install.sh` + `link-skills.sh` now have CI-enforced regression coverage. Silent breakage (the PR #12 class of bug) is no longer possible undetected.
- Review-request automation works once a second maintainer is added (CODEOWNERS lookup needs no manual configuration).
- GitHub-Actions version drift is surfaced weekly via Dependabot PRs.

### Negative

- CI cost roughly doubles (each matrix job now runs on two OSes). For an alpha-tier project with low merge volume this is negligible.
- macOS runners are slower than Linux ones; PR wall-clock time may increase by 1–3 minutes per workflow.
- `brew install ripgrep` and `brew install bash` add ~30s of setup overhead per macOS job.

### Watch

- If `macos-latest` flakes intermittently (`brew` registry hiccups, transient network), revisit whether `fail-fast: false` still serves the team. Today the answer is yes — a macOS flake should not cancel a green Linux run.
- If a `macos-latest` job exposes pre-existing macOS bugs in other validators or library code beyond what PR #12 fixed, the audit's L2-related findings will need follow-up branches.
- If Dependabot PRs become noise (e.g., minor `actions/*` bumps every week), tighten the open-PR cap or move to `monthly` cadence.

## Alternatives Considered

### macOS-only secondary CI job (no matrix)

- Add a single `macos-latest` job duplicating the Linux validator/test steps.
- Rejected: matrix is cleaner, scales to a third OS later (Windows-WSL) without job duplication, and `fail-fast: false` is exactly the safety net we want.

### Defer bootstrap-tests until install.sh stabilizes

- Wait until install.sh has fewer in-flight changes before adding CI coverage.
- Rejected: PR #12 just showed that "fewer in-flight changes" is illusory and silent regression risk compounds. The audit caught real test gaps; close them now.

### Skip CODEOWNERS until a second maintainer joins

- Add the file only when there's someone else to assign.
- Rejected: the file is one line for a solo maintainer and prevents a "we need to add this" item from drifting indefinitely. Strangers reading the repo see explicit ownership.

### Skip Dependabot until a language manifest exists

- Wait for a Gemfile / package.json before adding the config.
- Rejected: `github-actions` ecosystem alone is already worth tracking — `actions/checkout@v4`, `ruby/setup-ruby@v1` will both need version bumps eventually.

## References

- [Quality Audit 2026-05-18](../QUALITY-AUDIT-2026-05-18.md) — Triage #3
- [PR #12](https://github.com/unclenate/auto-harness/pull/12) — install.sh polish (surfaced the BSD-awk silent-failure pattern)
- [PR #13](https://github.com/unclenate/auto-harness/pull/13) — quality audit report (this ADR's source of truth)
- GitHub Actions matrix docs: <https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs>
- CODEOWNERS syntax: <https://docs.github.com/en/repositories/managing-your-repositories-settings-and-security/customizing-your-repository/about-code-owners>
- Dependabot config: <https://docs.github.com/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file>
