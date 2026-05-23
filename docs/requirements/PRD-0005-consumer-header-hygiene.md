<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0005: Consumer Header Hygiene — Stop Template Attribution Leakage

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-05-22 | **Review Cycle:** On-change

**Status:** Proposed
**Date:** 2026-05-22 (filed)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Related OPP: [OPP-0005](../opportunities/OPP-0005-consumer-header-hygiene.md) — `exploring`; this PRD is its promotion candidate
- Related ADRs:
  - [ADR-0005](../adr/ADR-0005-open-source-cut.md) — open-source cut establishing dual MIT/Apache-2.0 licensing and the SPDX-header convention now being mis-propagated to consumers
  - [ADR-0010](../adr/ADR-0010-cheap-satisfiers-for-routine-governance.md) — cheap-satisfier discipline; informs why v1 leans on existing primitives
  - [ADR-0012](../adr/ADR-0012-opportunity-capture-index-split.md) — file-boundaries-as-precision; informs the templates-vs-sample-projects distinction below
- Related observations:
  - `docs/knowledge/shared-observations.md` — *"Harness primitives that don't compose toward the consumer-side surface are silent governance gaps"* (2026-05-22) — the diagnosis that motivates this PRD
- Other: `platform/templates/**` (tokenized in v1); `platform/bootstrap/add-license-headers.sh` (extended in v1; attribution drift fixed); new `platform/bootstrap/set-consumer-headers.sh` (v1 deliverable); `platform/validators/validate-placeholders.sh` (composes with the tokenization — no validator change)

## Overview

Auto-harness ships 61 template files in `platform/templates/**` and every
file under `platform/examples/sample-projects/*/` with literal SPDX and
copyright headers attributing each file to the maintainer under dual
MIT/Apache-2.0. Consumers who copy a template to scaffold their own
ADR / PRD / observation / risk-register entry end up with files **born
with the wrong attribution and license** — a legal-correctness issue
that scales silently with adoption.

The harness already has the two primitives needed to close the gap:

- `platform/validators/validate-placeholders.sh` already exists and fails
  CI on any unfilled `[[…]]` token in tracked files.
- `platform/bootstrap/add-license-headers.sh` already exists and inserts
  SPDX/copyright headers idempotently — but only into auto-harness's own
  tree.

Neither is composed with the templates or with the consumer bootstrap
flow. This PRD specifies the v1 composition as four coordinated changes:

1. **Tokenize template headers** in `platform/templates/**` — replace the
   maintainer's attribution + SPDX line with `[[…]]`-style tokens so the
   existing placeholder validator fails CI when a consumer copies without
   filling in.
2. **Ship a consumer-facing bootstrap helper** at
   `platform/bootstrap/set-consumer-headers.sh` — prompts once for
   owner / email / year / license, writes a small project-local config
   (`.harness-headers.yaml`), and substitutes tokens across any
   template-derived files the consumer points it at.
3. **Sample-projects keep their attribution** but gain a leading-comment
   marker explaining that derivative copies must re-attribute. Sample-
   projects are worked examples, not scaffolding sources — tokenizing
   them would erase the pedagogical value of showing the finished shape.
4. **Fix internal drift in `add-license-headers.sh`** — line 2 of the
   script currently attributes itself to a work email rather than the
   maintainer's personal email per the project's own attribution rule.
   Folded into the same PR.

The pieces dogfood themselves on the auto-harness repo immediately and
inherit naturally into any consumer project that uses templates.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- Replace literal SPDX + copyright lines in every template under
  `platform/templates/**` with token forms that fail
  `validate-placeholders.sh` when unfilled.
- Ship `platform/bootstrap/set-consumer-headers.sh` — interactive (and
  flag-driven, for CI / scripted use) helper that fills tokens
  project-wide based on a small `.harness-headers.yaml` config.
- Document the consumer onboarding flow in
  `platform/bootstrap/README.md` so the helper is discoverable.
- Make `add-license-headers.sh` self-consistent with the project's own
  attribution rule.
- Add a leading-comment marker to every sample-project file warning
  that derivative copies must re-attribute (mechanical sed pass).

**Non-Goals** — explicitly deferred to follow-up:

- **Migration of consumer projects that already inherited bad headers.**
  Tracked separately; pointer documented in this PRD's "Future Work" so
  the gap is visible but not blocking v1.
- **A new `management/header-hygiene` module.** Considered (Option C in
  OPP-0005); deferred unless a second header-related pain point shows up
  that the primitive composition can't address. Premature primitive-
  creation violates the cheap-satisfier discipline.
- **Stripping headers from templates entirely** (Option D in OPP-0005).
  Templates lose too much pedagogical value when they no longer show
  what a finished header looks like.
- **Language-specific header detection beyond the existing extension
  list** in `add-license-headers.sh` (`.sh`, `.rb`, `.yml/.yaml`, `.md`).
  Out of scope unless / until consumers raise the need.
- **A separate `validate-headers.sh`** that detects misattributed
  headers (e.g., consumer file still says "Nate DiNiro"). Considered
  cheaper to gate at the template-creation boundary (token validator) +
  bootstrap-time substitution than to scan-and-flag after the fact. May
  revisit if v1 leaks.
- **Auto-detection of consumer license / owner** from external sources
  (GitHub API, npm metadata, etc.). The bootstrap helper prompts the
  consumer directly; deferring auto-detection avoids guessing wrong.

## Functional Requirements

### FR-001 — Template tokenization

Every file under `platform/templates/**` whose current first few lines
include a copyright/SPDX header block must have those lines replaced
with token forms:

- `Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>`
- `SPDX-License-Identifier: [[SPDX_LICENSE]]`
- The `Part of [[PROJECT_NAME]] — see ...` line either tokenizes the
  project name or is removed (it's auto-harness-specific framing and
  consumer projects shouldn't claim derivation from auto-harness).

The token names use uppercase + underscore so they match
`validate-placeholders.sh`'s `\[\[[A-Z0-9_]+\]\]` regex and fail CI when
unfilled.

### FR-002 — Bootstrap helper

A new script at `platform/bootstrap/set-consumer-headers.sh`:

- **Interactive mode (default):** prompts the consumer for
  `OWNER_NAME`, `OWNER_EMAIL`, `YEAR` (defaults to current year),
  `SPDX_LICENSE` (defaults to `MIT OR Apache-2.0` with prompt
  acknowledgment), and `PROJECT_NAME` (or "skip" to remove the project-
  reference line).
- **Non-interactive mode:** accepts the same values via flags
  (`--owner-name="..."`, `--owner-email="..."`, etc.) or via an existing
  `.harness-headers.yaml` config file in the project root.
- **Writes `.harness-headers.yaml`** in the consumer project root
  capturing the chosen values, so subsequent template-copies can
  auto-fill without re-prompting.
- **Substitutes tokens** in any file the consumer points it at (default:
  scan whole tree for files containing matching tokens; flag
  `--files=path1,path2,...` for targeted substitution).
- **Idempotent + safe** — re-running on an already-substituted file is a
  no-op; running on a file with partial tokens fills only the matching
  ones.
- **Exit contract** matching other validators / bootstrap scripts: `0`
  success, `1` user-error (e.g., invalid email format), `2` usage-error
  (missing arg, malformed config, ripgrep not installed).
- **Help flag** (`-h` / `--help`) per project convention.

### FR-003 — Sample-projects keep attribution + add re-attribution marker

Every file under `platform/examples/sample-projects/*/` that currently
carries the auto-harness header retains the header (these are worked
examples; the maintainer authored them) but gains an additional
**leading comment** before the SPDX block:

```text
NOTE: This is an auto-harness sample-project file (reference
implementation). If you copy this file into your own project, replace
the SPDX/copyright header with your own — running
`bash platform/bootstrap/set-consumer-headers.sh` from your project
root after the copy will do this for you.
```

Comment format adapts to file type (`#` for shell/yaml, HTML-comment for
markdown) using the same per-extension logic
`add-license-headers.sh` already encodes.

### FR-004 — `add-license-headers.sh` self-consistency

Line 2 of `platform/bootstrap/add-license-headers.sh` currently reads:

```bash
# Copyright 2026 Nate DiNiro <nate@bdits.io>
```

It must be updated to use the personal email matching every other source
file in the repo:

```bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
```

No other files exhibit this drift (verified via grep at OPP-filing time);
this is a one-line fix that ships in the same PR as v1.

### FR-005 — Documentation

`platform/bootstrap/README.md` gains a new section "Setting Consumer
Project Headers" documenting:

- When to run `set-consumer-headers.sh` (at consumer onboarding, after
  copying templates, or any time the consumer's owner / license changes)
- The interactive flow (one-shot prompt) vs. non-interactive flow
  (config + flags for CI / scripted scaffolding)
- The role of `.harness-headers.yaml` (project-local config that captures
  the chosen values once)
- Cross-link to `validate-placeholders.sh` as the enforcement floor
  ("CI will fail on unfilled tokens; the bootstrap helper is the
  ergonomic way to fill them")

`platform/templates/README.md` gains a note explaining that template
headers ship tokenized and *must* be filled before commit; cross-links
to the bootstrap helper.

### FR-006 — `.harness-headers.yaml` schema

The project-local config file written by the bootstrap helper:

```yaml
# Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
# SPDX-License-Identifier: [[SPDX_LICENSE]]
owner_name: "Jane Smith"
owner_email: "jane@example.com"
year: 2026
spdx_license: "MIT"
project_name: "my-project"  # or null/empty to drop the project-reference line
```

The file's own header is tokenized so it dogfoods the very pattern it
configures. The helper writes both the config keys and a header on the
config file itself (chicken-and-egg solved by the helper substituting on
its own output).

## Acceptance Criteria for OPP-0005 Promotion to `accepted`

OPP-0005 flips from `exploring` to `accepted` when **all** of the
following are met:

1. PRD-0005 status flips to `Accepted`
2. All FR-001 through FR-005 are implemented and merged to `main`
3. The auto-harness repo itself dogfoods the change — templates are
   tokenized, validators pass, and an exemplary run of
   `set-consumer-headers.sh` on a test fixture is documented
4. At least one downstream consumer (or test-fixture project under
   `platform/examples/sample-projects/`) is verified to bootstrap
   cleanly under the new flow

FR-006 (config-file schema) is implicit in FR-002 and considered shipped
when FR-002 is.

## Out of Scope

- Migrating consumer projects that already have files inheriting
  auto-harness's headers. Captured as future work (see "Future Work"
  below).
- Detecting and flagging *existing* mis-attributed headers in consumer
  projects (a `validate-headers.sh` validator). The token-validator gate
  at template-creation time is the v1 floor.
- Language coverage beyond the existing extension list in
  `add-license-headers.sh`. If consumers need Python / Rust / Go header
  conventions, that's a follow-up extending the per-extension logic
  uniformly — not a v1 dependency.
- A `management/header-hygiene` module. Re-examine if v1 leaks or if a
  second header-related pain point emerges that the primitive
  composition can't address.

## Risks

### Risk: Existing consumers silently carry bad headers indefinitely

v1 forward-fixes templates but doesn't audit consumer state. A consumer
that adopted auto-harness six months ago and scaffolded ten ADRs from
templates still has ten files with the wrong attribution. The PRD's
position is that this risk is real but bounded — the maintainer's known
consumer set is small, the fix is mechanical (sed-style substitution of
known-bad strings), and shipping the migration tool as v1 delays the
upstream fix that prevents the problem from growing.

**Mitigation:** Document the manual remediation pattern in the
v1 PR's CHANGELOG entry + a one-paragraph "Known issue" callout in
`platform/bootstrap/README.md`. The follow-up migration tool can land
as a discrete PR.

### Risk: Token-in-prose collision (validator false-positives)

`validate-placeholders.sh` cannot distinguish "real token needing fill"
from "literal `[[NAME]]` notation used as prose example." Hit during
OPP-0005 drafting itself — every prose mention of token names tripped
the validator. The PRD-text-vs-validator-payload boundary is fragile.

**Mitigation:** Document the convention in `validate-placeholders.sh`'s
help text and in `platform/templates/README.md` — use `[[…]]` ellipsis-
form or `[[`NAME`]]` split-backtick form in any prose that needs to
*reference* the token shape without *being* a token. Long-term, the
validator could learn to skip fenced code blocks (matches the pattern
`validate-doc-references.sh` v2 already implements for inline-code
spans) — captured as a separate possible enhancement, not v1 scope.

### Risk: Bootstrap helper UX surprises

A consumer running `set-consumer-headers.sh` with `--owner-name="..."`
expects sensible defaults for unspecified flags. The PRD's position:
fall back to interactive prompt for any missing required field, fail
cleanly with usage-error exit 2 if running in a TTY-less context
without all required flags.

**Mitigation:** Lifted directly from `add-license-headers.sh`'s
dry-run/apply pattern; add explicit TTY-detection logic.

### Risk: Sample-project marker comment becomes noise

Every sample-project file gains a leading comment. If the comment is
too prominent it overwhelms the worked-example content; if too quiet
it's missed by exactly the consumers it's meant to warn.

**Mitigation:** Place the marker as a *second* comment block after the
SPDX header (so it's near the attribution but doesn't replace it), keep
it terse (3-4 lines), and cross-link to the bootstrap helper rather
than restating the rule.

## Open Questions Resolved by This PRD

The OPP-0005 open questions are resolved as follows:

- **Tokenize SPDX too, or only copyright + email?**
  → **Tokenize SPDX too.** Consumer's licensing is genuinely their
  choice; defaulting to MIT/Apache when the consumer intends GPL or
  proprietary is the same misrouting problem in a different field. The
  bootstrap helper prompt defaults to MIT/Apache (matching auto-harness)
  but requires explicit acknowledgment.

- **Config file vs. per-prompt?**
  → **Config file (`.harness-headers.yaml`).** Write once at onboarding,
  reuse for subsequent template scaffolds. Lower friction, regeneratable.
  Per-prompt would re-ask on every template-copy and consumers would
  skip it.

- **Module placement — kernel/base vs. new module?**
  → **Neither — script in `platform/bootstrap/`.** Header hygiene is a
  *consumer-onboarding* concern, not a *governance-policy* concern. The
  bootstrap script directory is the natural home; no module wrapper
  needed. Re-evaluate if the policy surface grows enough to justify
  modularization.

- **Should v1 explicitly *not* fix consumer-side state?**
  → **Correct — out of scope.** Forward-fix templates; document
  migration pattern; defer migration tool to follow-up. Scope
  discipline preserved.

- **Does `validate-placeholders.sh` already reject template files with
  tokens?**
  → **No (verified).** The validator scans all tracked files including
  `platform/templates/**` but currently passes because templates don't
  *yet* contain tokens. After FR-001 lands, templates will contain
  tokens and the validator scan will fail on the auto-harness repo
  unless templates are exempted. Exemption added in the same PR via
  `.placeholder-ignore` glob entry: `platform/templates/**`. This is
  the same pattern already used to exempt
  `platform/validators/test/fixtures/`.

## Future Work (Not v1)

- **Consumer-migration tool** — a script that scans a consumer project
  for files carrying auto-harness's literal header and offers to rewrite
  them based on `.harness-headers.yaml`. Effectively
  `set-consumer-headers.sh` operating on already-substituted files in
  reverse-then-forward.
- **`validate-headers.sh`** — a project-level validator that detects
  misattributed headers (e.g., file says "Nate DiNiro" but
  `.harness-headers.yaml` says owner is someone else). Captures drift
  after v1 ships.
- **Validator awareness of code-span boundaries** —
  `validate-placeholders.sh` learns to skip inline backticks and fenced
  code blocks, eliminating the prose-vs-payload collision documented in
  the second risk above. Same pattern as `validate-doc-references.sh`
  v2.
- **Language coverage** — Python / Rust / Go / TypeScript header
  conventions added to the per-extension logic in `add-license-headers.sh`
  and the bootstrap helper's substitution layer.

## Implementation Notes

- **Sequencing:** FR-001 (tokenize templates) must land *with* the
  `.placeholder-ignore` exemption update for templates — otherwise the
  validator fails on the auto-harness repo itself between the two
  commits. Both in the same PR.
- **Bootstrap helper hosting:** scripts live in `platform/bootstrap/`
  per established convention; help-text + README link added to
  `platform/bootstrap/README.md`.
- **Companion rules:** template files are not currently a trigger path
  for any companion rule (verified). No companion rule additions
  required for v1.
- **Testing:** `add-license-headers.sh` already has tests under
  `platform/bootstrap/test/`; mirror that structure for
  `set-consumer-headers.sh` (fixture project + substitution assertion).

## CI / CD Gates

- `validate-manifest`, `validate-module-graph`, `validate-required-artifacts`,
  `validate-placeholders`, `validate-agent-pack`, `validate-doc-references`,
  `validate-companions` — all must pass on the v1 PR.
- `shellcheck` — runs against the new `set-consumer-headers.sh`; must
  pass at `--severity=warning` per the existing CI gate.
- Bootstrap tests — new tests added for `set-consumer-headers.sh` join
  the existing matrix run on macos + ubuntu.
- Markdownlint — applies to any new doc content.

No new CI jobs are introduced; the v1 work uses the existing matrix.

## Versioning Implications

- `platform/bootstrap/` doesn't itself version (it's not a module), but
  the bootstrap-test fixture-set version conventions established by
  prior PRs apply.
- No module bumps required for v1 — the work lives in templates +
  bootstrap + validator-ignore-list, none of which are inside a module's
  `module.yaml` version field.
- If a future iteration introduces `management/header-hygiene`, that
  would be a new module at v1.0.0 with its own lifecycle.
