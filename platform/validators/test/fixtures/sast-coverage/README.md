<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# SAST coverage fixtures

These fixtures exercise `validate-sast-coverage.sh --scan-file <path>`
mode for the Wave 5.4 implementation per PRD-0016 FR-S03. Each file
demonstrates one expected validator outcome:

| Fixture | Expected exit | Why |
|---------|---------------|-----|
| `valid.md` | 0 | Well-formed: recommended tool + non-empty scanPaths + non-empty severityThreshold |
| `missing-tool.md` | 1 | Frontmatter omits `tool:` |
| `unknown-tool.md` | 1 | `tool:` value not in RECOMMENDED_TOOLS |
| `missing-scan-paths.md` | 1 | Frontmatter omits `scanPaths:` |
| `empty-scan-paths.md` | 1 | `scanPaths:` present but empty |
| `missing-threshold.md` | 1 | Frontmatter omits `severityThreshold:` |
| `no-frontmatter.md` | 1 | File has no YAML frontmatter block |

**Discipline:** append-only. When `RECOMMENDED_TOOLS` is extended in
`validate-sast-coverage.sh`, no fixture changes are required; the new
tool name is implicitly accepted. When a new validation rule is added,
add a fixture demonstrating the failure mode in the same PR.
