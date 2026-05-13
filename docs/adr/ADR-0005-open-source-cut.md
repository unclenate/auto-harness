# ADR-0005: Open-Source Cut — Dual MIT/Apache-2.0, Documentation Reorganization, OSS Foundation

**Status:** Accepted
**Date:** 2026-05-13
**Author:** @unclenate
**Reviewers:** @unclenate
**Context source:** Pre-launch readiness review of auto-harness preparing the repository for its public open-source cut. Audit surfaced two coupled issues: information architecture treated *adoption*, *day-to-day workflows*, and *post-adoption maintenance* as one undifferentiated "workflow" surface; and the repository had no LICENSE, no per-file licensing indicia, no CONTRIBUTING / CODE_OF_CONDUCT / SECURITY, and no issue or pull-request templates.

## Context

Auto-harness is moving from a private development phase into open-source distribution. Two distinct concerns must be resolved before the public flip:

1. **Legal foundation.** No LICENSE file, no per-file headers, no NOTICE, no community files (CONTRIBUTING / CODE_OF_CONDUCT / SECURITY), no GitHub issue or pull-request templates, no AUTHORS list. The repository is documentation-mature but legally and structurally unready for downstream consumption.

2. **Information architecture.** The README and SUMMARY conflate three distinct operator concerns under a single "Workflow Guides" heading: (a) first-time *adoption* (bootstrap, discovery, brownfield onboarding, submodule integration), (b) *day-to-day workflows* (per-PR governance, running validators during development, working with skills), and (c) *post-adoption maintenance* (upgrade flow, drift recovery, version pinning, periodic governance audits). Maintenance content in particular is fragmented across `submodule-integration.md`, `brownfield-onboarding.md`, `ci-integration.md`, and `troubleshooting.md`, with five specific topics — version pinning, rollback after breaking upstream changes, what to do when validators change upstream, drift detection in copy-mode projects, and copy-to-submodule migration — entirely undocumented despite being recurring operator needs.

The harness-governance skill's companion rule requires that any change to `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, or governance entrypoints be accompanied by either an ADR or an update to `docs/operating-principles.md`. This ADR is that companion record for the reorganization PR. The change-log entry on `docs/project/change-log.md` is companion to scope and direction; it is updated in the same PR.

## Decision

**Auto-harness ships its open-source cut under a Dual MIT / Apache-2.0 license, restructures the documentation around an *Adoption → Day-to-Day Workflows → Maintenance & Operations → Reference* axis, and establishes the standard open-source community-file foundation.**

Concrete commitments:

1. **Dual MIT / Apache-2.0 licensing.** Two LICENSE files at repository root: `LICENSE-MIT` and `LICENSE-APACHE`. Consumers select either license at their option. Per-file SPDX expression is `SPDX-License-Identifier: MIT OR Apache-2.0`. A `NOTICE` file is shipped to satisfy the Apache-2.0 attribution requirement for adopters who choose that path. CONTRIBUTING.md includes explicit dual-licensing language: contributions are accepted under both licenses.

2. **Per-file licensing indicia in the "Full Short Header" style.** Three-to-five-line headers per file, format adapted to file type (shell-comment, YAML-comment, HTML-comment for Markdown). Headers carry copyright year + maintainer email + SPDX identifier + reference to LICENSE files at repository root. Applied to: shell scripts, Ruby files, YAML configs, GitHub workflows, Markdown documentation and templates. Skipped: `.remember/` ephemera (gitignored), generated files.

3. **New top-level "Maintenance & Operations" section.** A new canonical document at `platform/workflow/maintenance-operations.md` consolidates post-adoption operational concerns: keeping the harness current (submodule and copy modes), version management (pinning + rollback), validator lifecycle after adoption, drift detection and recovery, lifecycle transitions (prototype → MVP → production), and periodic governance audits. Maintenance-flavored sections currently embedded in `submodule-integration.md` (upgrade flow), `ci-integration.md` (disabling validators per-manifest), and `brownfield-onboarding.md` (progressive compliance roadmap) are moved to this new document, with one-line cross-references left at the source locations. Five documented gap topics — version pinning, rollback, validator changes upstream, copy-mode drift, copy-to-submodule migration — are authored from scratch.

4. **Reorganized README and SUMMARY around the operator journey.** Replaces the flat "Workflow Guides" table with a four-axis structure: *Adoption Workflows* (one-time setup), *Day-to-Day Workflows* (per-PR governance, validators during development, skills), *Maintenance & Operations* (the new section), *Reference* (modules, validators, templates, troubleshooting as error catalog). SUMMARY.md mirrors the README grouping so GitBook navigation aligns with the README narrative.

5. **Open-source community files.** New files at repository root: `CONTRIBUTING.md` (referencing the harness's own companion-rule discipline; explicit dual-licensing acceptance), `CODE_OF_CONDUCT.md` (Contributor Covenant v2.1 with nate@bdits.io as enforcement contact), `SECURITY.md` (vulnerability disclosure address + expected response window), `AUTHORS` (initial maintainer list). New files under `.github/`: `ISSUE_TEMPLATE/bug_report.yml`, `ISSUE_TEMPLATE/feature_request.yml`, `ISSUE_TEMPLATE/observation.yml` (harness-native; lets external observers contribute to the knowledge-capture flow), `PULL_REQUEST_TEMPLATE.md` (companion-rule checklist + validator-run confirmation).

6. **README open-source signals.** License badge, status badge ("Alpha", aligned with HARNESS.md), contact email line, and CONTRIBUTING.md pointer added near the top of README.md.

## Consequences

### Positive

- The repository becomes legally consumable: every file has explicit licensing provenance, and the dual-license design maximizes downstream optionality (consumers can pick the license that fits their own project's distribution constraints).
- A new operator searching for "how do I keep this thing healthy after I've adopted it" has a single canonical destination instead of three fragmented sources.
- The five identified maintenance gaps (pinning, rollback, validator-upstream changes, copy-mode drift, copy-to-submodule migration) become first-class documented topics rather than recurring questions that get answered ad hoc.
- The README narrative aligns with the SUMMARY.md GitBook navigation, eliminating a structural divergence that previously required readers to mentally remap between the two surfaces.
- The community file foundation (CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, issue and PR templates) signals project maturity and lowers the activation cost for outside contributors. The `observation.yml` issue template specifically channels external contributors into the harness's own knowledge-capture surface rather than collecting drive-by suggestions in unstructured threads.

### Negative

- **Dual-license maintenance discipline.** Every contribution must remain dual-licensed. CONTRIBUTING.md states this explicitly, but it requires reviewer vigilance — a contribution that derives from a GPL or AGPL source would break the dual-license property. Practically, this risk is low for a documentation-and-shell project, but it requires PR review awareness.
- **Per-file header drift risk.** Without a CI check enforcing header presence, new files added in future PRs may forget the header. A CI header-enforcement workflow is identified as a stretch goal in the originating plan; if not landed with this PR, it should follow shortly to prevent drift.
- **Documentation move cost.** Moving sections out of `submodule-integration.md`, `ci-integration.md`, and `brownfield-onboarding.md` invalidates external links into those subsections. Cross-references at the source locations mitigate this for readers landing on the old anchors, but bookmarks and outside references will need updating.
- **Apache-2.0 NOTICE discipline.** Adopters who select Apache-2.0 are required to redistribute the NOTICE file. This is standard Apache-2.0 behavior but is one more obligation than MIT-only would impose.

### Watch

- If contributors find the dual-license CONTRIBUTING language ambiguous, an explicit DCO (Developer Certificate of Origin) sign-off requirement may need to be added. Starting without DCO to minimize friction; can add later.
- If the `Maintenance & Operations` section accumulates content quickly, it may need to be split into its own subdirectory (`platform/workflow/operations/`) rather than living as a single document. Single-file is intentionally simple at launch; split if it grows past ~600 lines.
- If the README badges or status indicator become inaccurate (e.g., the project advances past "Alpha" maturity), they should be updated as part of the milestone PR rather than letting them drift.

## Alternatives Considered

### MIT only

- Description: Single LICENSE file at repository root with standard MIT text. Per-file headers reference only MIT.
- Why rejected: MIT lacks an explicit patent grant. Auto-harness is a *governance harness* — its primary product is contracts and conventions that downstream projects adopt into their own development pipelines. The absence of a patent clause is materially weaker for that use case than for a code-snippet library. The dual MIT/Apache-2.0 pattern gives adopters the MIT option for ergonomics *and* the Apache-2.0 option for projects that care about patent protection, with negligible additional overhead.

### Apache-2.0 only

- Description: Single LICENSE file at repository root with Apache-2.0 text, NOTICE file shipped, per-file SPDX = `Apache-2.0`.
- Why rejected: Apache-2.0 alone is the right choice for many infrastructure projects, but it imposes the NOTICE-redistribution obligation on every adopter. Some downstream projects prefer to avoid that obligation when MIT-equivalent terms are available. The dual offering removes this friction at the cost of one extra LICENSE file.

### MPL-2.0

- Description: Mozilla Public License 2.0. File-level copyleft — modifications to harness files must remain MPL-2.0, but consumer projects that *use* the harness without modifying it stay un-encumbered.
- Why rejected: MPL-2.0 aligns conceptually with the "governance contract" framing (improvements to harness files flow back), but it is uncommon in the AI-developer-tooling and CNCF-adjacent ecosystems where auto-harness is positioned. Adopters unfamiliar with MPL would face an extra evaluation step, which works against the goal of low-friction adoption. The dual MIT/Apache-2.0 choice is more recognizable and imposes fewer adoption questions.

### Defer the documentation reorganization to a follow-up PR

- Description: Land only the legal foundation (LICENSE files, headers, community files) in this PR; defer TOC reorg and the new Maintenance & Operations section to a follow-up.
- Why rejected: The README is the primary front door for the open-source launch. Shipping the public cut with an information architecture that the maintainer already knows is uneven would create a worse first impression than landing both together. The two workstreams share file-touch surface (the same Markdown files need both header insertion and content edits), so combining them is more efficient than two passes.

### Single combined LICENSE file ("LICENSE")

- Description: One file at repository root named `LICENSE` containing both the MIT and Apache-2.0 texts concatenated, with a header explaining the dual choice.
- Why rejected: The Rust-ecosystem convention is two files (`LICENSE-MIT` and `LICENSE-APACHE`), and most tooling — including GitHub's license-detection heuristic — works best with the two-file convention. Concatenating would save one file at the cost of making the licensing harder for tools (and humans skimming a directory listing) to recognize.
