<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0011: Markdownlint Policy — Configuration, CI Gate, Disabled Rules

**Status:** Accepted
**Date:** 2026-05-18
**Author:** @unclenate
**Reviewers:** @unclenate
**Context source:** Quality-audit Lane 5 (`docs/QUALITY-AUDIT-2026-05-18.md`) — 8 findings, including 68 MD060 hits, 0 closed at audit time. User-flagged MD060, MD032, MD038 explicitly. This ADR codifies which rules the project enforces, which it disables (with justification), and how the gate runs in CI.

## Context

Lane 5 of the 2026-05-18 audit was the largest open lane: 0 of 8 findings closed. The repo had no markdownlint configuration, no `.editorconfig`, and no CI gate against markdown drift. Initial sweep (no config) produced 349 findings across 14 rule IDs. Most were auto-fixable; a few were intentional template/governance patterns that the default ruleset misclassifies as problems.

The risk of leaving Lane 5 open: every new markdown contribution silently widens whatever drift the repo accumulates, and the audit's own counts (68 MD060, 115 MD032, etc.) keep growing until either a stranger reports them publicly or a future maintainer has to do a much-larger sweep. The risk of enabling too aggressively: false-positive noise teaches reviewers to ignore the gate.

## Decision

Ship a tuned `.markdownlint-cli2.jsonc` at repo root + a markdownlint CI job + `.editorconfig` for IDE consistency.

### Rules enabled (default + explicit tuning)

- All `default: true` rules, except those explicitly disabled below
- **MD024** (`siblings_only: true`) — allow `### Positive` / `### Negative` / `### Watch` repeats across ADRs
- **MD033** (`allowed_elements: ["!--", "br", "details", "summary", "img", "a"]`) — permit SPDX comment blocks + intentional HTML
- **MD046** (`fenced`) — fenced code blocks only, no 4-space-indent
- **MD048** (`backtick`) — `` ``` `` fences, no `~~~`
- **MD049 / MD050** (`asterisk`) — `*italic*` and `**bold**`, not `_italic_` / `__bold__`
- **MD055** (`leading_and_trailing`) — tables require leading + trailing `|`
- **MD056** (column-count match) — table rows must match header column count
- **MD060** (`leading_and_trailing`, `aligned_delimiter: false`) — matches the repo's existing convention

### Rules disabled (with justification)

- **MD013** (line-length) — hard wrapping ruins markdown tables, code examples, and most ADR/PRD prose. Long lines render fine in any modern renderer.
- **MD028** (no-blanks-blockquote) — the rule warns about a typo class (forgetting `>` to continue a blockquote), but separating blockquote paragraphs with a blank line is the intentional markdown convention for multiple distinct quoted thoughts. The repo uses this in profile READMEs for grouped notes; the rule produced false-positives faster than it caught the typo.
- **MD036** (no-emphasis-as-heading) — templates use parenthesized italic text as guidance (`"(One sentence. Ruthlessly scoped.)"`) and ADRs/PRDs use bold inline labels (`"**Status:**"`). Both are stylistic, not heading-replacements; MD036 misclassifies the template pattern. Real heading-vs-bold judgment stays with the author.
- **MD041** (first-line-heading) — every file starts with the SPDX HTML comment block before the `H1` (which is correct per OSS convention); MD041 misreads this as a missing heading.

### CI gate

New `markdownlint` job in `.github/workflows/harness.yml`. Linux-only (markdownlint output is identical on macOS); installs `markdownlint-cli2` via `npm install -g`; runs `markdownlint-cli2` against the repo using the `.markdownlint-cli2.jsonc` config. Blocks on errors; warnings non-blocking (the config produces only errors for tuned rules).

### `.editorconfig`

Codifies the existing convention (LF, no trailing whitespace, spaces over tabs) so IDE drift cannot silently introduce CRLF or tabs. Markdown gets `trim_trailing_whitespace = false` to preserve the two-space-then-newline "line break" syntax. Makefiles get `indent_style = tab` per POSIX.

## Consequences

### Positive

- **Lane 5 closed.** All 8 findings either fixed or explicitly disabled with reason. Repo-wide error count: 0 across 248 files.
- **Future drift is caught at PR time.** No more 68-hit accumulations.
- **IDE drift bounded by `.editorconfig`.** A contributor's VSCode or Cursor cannot silently emit CRLF or tabs into committed files.
- **Disabled-rule rationale is captured here**, not buried in config-file comments. Reviewers can read this ADR to understand why each disable exists.

### Negative

- **One more CI job to keep green.** Cost: ~1 minute per PR run.
- **`npm install -g` adds a CI step** that depends on Node + npm being available on the runner (they are on `ubuntu-latest` by default; no extra setup needed).
- **Maintainers must run `markdownlint-cli2 --fix` locally** before pushing to avoid CI rejections on auto-fixable issues. Mitigation: a pre-commit hook would automate this; deferred to a follow-up since the current contributor flow is solo-maintainer with PR previews.

### Watch

- **If new contributor PRs frequently get rejected** for auto-fixable issues, add a pre-commit hook or a CI step that runs `--fix` and commits back. Don't switch to "warn-only" — that would defeat the gate.
- **If a disabled rule starts catching real bugs** that MD-rule-NNN would have prevented, re-enable. The disables here are based on current repo patterns; patterns change.
- **If GitBook or another renderer fails on a pattern the linter allows**, treat it as a new finding and either re-enable the rule or update the renderer-aware validator (`validate-doc-references.sh v2`) to catch the specific class.

## Alternatives Considered

### Use the default ruleset unchanged

- Run `markdownlint-cli2` with no config; accept all default rules.
- **Rejected:** 349 findings on first sweep, most false-positives for the project's template + ADR style. Would either be ignored (teaching reviewers to skip the gate) or trigger a long manual config-suppression process per repo.

### Use `prettier --check` for markdown instead

- Prettier formats markdown to a canonical style.
- **Rejected:** prettier is opinionated and reformats whitespace + line wrapping aggressively. Would force a much larger one-time diff and wouldn't catch rule classes markdownlint exists for (e.g., MD034 bare URLs, MD040 missing language tags, MD056 table column count).

### Ship rules disabled "for now" and tighten over time

- Disable the noisy rules (MD036, MD028) initially with "TODO: re-enable" comments; tighten in follow-ups.
- **Rejected:** the rationale for each disable in this ADR is concrete and grounded in the project's intentional patterns, not a "we haven't gotten around to fixing it" admission. The current state IS the long-term state for these rules.

### Don't suppress MD060; fix every table to use a specific style

- Instead of `MD060: { style: "leading_and_trailing" }`, force one canonical style and reformat every table.
- **Accepted as configured** — that's exactly what we did. The repo's existing tables overwhelmingly use leading-and-trailing pipes already; the config matches that and 0 MD060 hits remain.

## References

- [Quality Audit 2026-05-18](../QUALITY-AUDIT-2026-05-18.md) — Lane 5 (8 findings)
- [markdownlint rule reference](https://github.com/DavidAnson/markdownlint/blob/v0.40.0/doc/Rules.md)
- [`.markdownlint-cli2.jsonc`](../../.markdownlint-cli2.jsonc) — the active config
- [`.editorconfig`](../../.editorconfig) — IDE-level convention pin
- [ADR-0009](ADR-0009-ci-hardening.md) — CI hardening predecessor (matrix + bootstrap-tests)
- [ADR-0010](ADR-0010-cheap-satisfiers-for-routine-governance.md) — companion-rule satisfier policy this ADR's CI job is satisfied by
