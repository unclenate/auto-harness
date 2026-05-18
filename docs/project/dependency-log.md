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
| Ruby (>= 3.0) | Infra | @unclenate | Resolved | Validators cannot run | Required by all 7 validators and test suite; CI pins 3.3 (matches `CONTRIBUTING.md`, `platform/validators/README.md`, `.github/workflows/harness.yml`) |
| ripgrep (rg) | Infra | @unclenate | Resolved | Placeholder validator skips file scanning | Required by validate-placeholders.sh |
| Bash (>= 4.0) | Infra | @unclenate | Resolved | Validators cannot run | Required by all validator shell scripts |

---

## Resolved Dependencies

| Dependency | Type | Resolved Date | Resolution Notes |
| ---------- | ---- | ------------- | ---------------- |
| ripgrep | Infra | 2026-04-07 | Installed locally; documented as requirement in validator README |

---

## Reference

| Resource | Path |
| -------- | ---- |
| Milestones | `docs/project/milestones.md` |
| Change log | `docs/project/change-log.md` |
