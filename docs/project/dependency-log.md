<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Dependency Log

This log tracks external dependencies that affect delivery.

---

## Active Dependencies

| Dependency | Type | Owner | Status | Impact if Delayed | Notes |
| ---------- | ---- | ----- | ------ | ----------------- | ----- |
| Ruby (>= 3.0) | Infra | @unclenate | Resolved | Ruby-backed validators cannot run | Required by 6 of 8 validators (Ruby-backed: `validate-manifest`, `-module-graph`, `-required-artifacts`, `-agent-pack`, `-companions`, `-doc-references`) and the full test suite. Shell-only validators (`validate-placeholders`, `validate-catalog-counts`) do not invoke Ruby. CI pins 3.3 (matches `CONTRIBUTING.md`, `platform/validators/README.md`, `.github/workflows/harness.yml`) |
| ripgrep (rg) | Infra | @unclenate | Resolved | Placeholder validator skips file scanning | Required by validate-placeholders.sh |
| Bash (>= 4.0) | Infra | @unclenate | Resolved | Validators cannot run | Required by all validator shell scripts |

---

## Resolved Dependencies

| Dependency | Type | Resolved Date | Resolution Notes |
| ---------- | ---- | ------------- | ---------------- |
| ripgrep | Infra | 2026-04-07 | Installed locally; documented as requirement in validator README |

---

## CI / GitHub Actions Version Bumps

Tracks Dependabot-raised version bumps to actions used in `.github/workflows/`. Each row satisfies the `kernel/base` companion rule per ADR-0010 (the lightweight satisfier for routine dep maintenance).

| Date | Action | From → To | Source | Reviewer | Notes |
| ---- | ------ | --------- | ------ | -------- | ----- |
| 2026-05-18 | `actions/checkout` | v4 → v6 | Dependabot PR #17 | @unclenate | Major-version jump skipping v5. Reviewed: (1) v5 changelog — default Node 20→22 (matches our runner's Node version, no concern); (2) v6 changelog — no breaking changes flagged for our usage pattern (we use only `fetch-depth`, no sparse-checkout, no custom tokens, no LFS); (3) all 6 CI jobs (Validators × 2, Self-Tests × 2, Bootstrap Tests × 2) pass on both `ubuntu-latest` and `macos-latest` against the bumped action — verified on PR #17. |

---

## Reference

| Resource | Path |
| -------- | ---- |
| Milestones | `docs/project/milestones.md` |
| Change log | `docs/project/change-log.md` |
