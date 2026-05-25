<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Operating Principles — Development Harness Framework

> Owner: @unclenate
> Last updated: 2026-05-22 *(§ 8 added: prefer text representations)*

These principles govern how the harness platform itself is built and evolved.
They are derived from the kernel doctrine and adapted to this project's context.

---

## 1. Ownership

Every module, validator, template, and workflow document has a named owner.

- Primary owner: @unclenate
- The harness is currently a solo project. As contributors join, ownership will be
  distributed per module family.

---

## 2. Review Discipline

Review is a knowledge-distribution mechanism, not a rubber stamp.

- All governance changes (HARNESS.md, AGENTS.md, module.yaml companion rules,
  validator logic) require deliberate review
- AI agent output is reviewed to the same standard as human output
- Gap analyses from multiple AI tools are cross-verified before acting
- **Companion-rule satisfiers scale with change weight.** Substantive decisions
  (new authentication model, new CI surface, new ownership boundary) require an
  ADR / PRD / operating-principles update. Routine maintenance (Dependabot
  version bumps, CODEOWNERS line additions, minor workflow ergonomics) may
  satisfy the kernel rule via a `docs/project/change-log.md` or
  `docs/project/dependency-log.md` entry that names the change and the
  reviewer. See [ADR-0010](adr/ADR-0010-cheap-satisfiers-for-routine-governance.md)
  for the rationale and the kernel rule definition.

---

## 3. Documentation as Part of the Change

Documentation is not follow-up work. A change is not complete until its documentation is current.

- New modules require README.md and module.yaml in the same commit
- Template changes require templates/README.md directory map update
- Workflow changes require SUMMARY.md and cross-reference updates
- Active-module catalog changes propagate to HARNESS.md, SUMMARY.md, README.md (directory tree), `platform/skills/harness-onboarding/SKILL.md` (module catalog), and `platform/workflow/discovery-to-composition.md` (decision rubric) in the same pass
- Repo-root governance entrypoints (`README.md`, `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, `TOOLS.md`) each carry a distinct job statement; when one is edited to change scope, the others' job statements and the SUMMARY.md "Entry Points by Audience" block are reviewed in the same pass
- **Module-text reads in stripped contexts.** `module.yaml` `description`, `humanReview`, and similar prose fields appear in validator output, CI logs, and onboarding docs without their surrounding file context. Use fully-qualified repo-relative paths (`docs/opportunities/README.md`) in rule text, not bare basenames (`README.md`) — the YAML reads unambiguous to the author but the CI log line does not. Catch in review; this is not validator-enforceable.
- **Cycle-end distillation is the trigger-side counterpart to destination-side audit trails.** Existing companion rules require an audit trail when a *destination* (`shared-observations.md`, `distilled-learnings.md`, etc.) is touched. The cycle-end distillation rule (PRD-0004; landed in `management/knowledge-capture` v1.1.0) is the inverse: when *distillation-worthy work* is in a PR diff (new ADR, new OPP, OPP `proposed` flip, new module manifest, catalog change), at least one knowledge destination must be touched in the same diff. Two rules, two satisfiers, one coherent PR. See [`platform/workflow/cycle-end-distillation.md`](../platform/workflow/cycle-end-distillation.md) for the satisfier decision tree.

---

## 4. Secrets and Credentials

Secrets never belong in tracked artifacts.

- This platform repo contains no runtime secrets — it is a governance framework,
  not an application
- Consumer projects using the harness must follow the kernel's secrets doctrine

---

## 5. Self-Governance

The harness governs itself using its own module system.

- `harness.manifest.yaml` declares active modules
- Validators run against this repo's own artifacts
- Disabled validations are documented and justified — not silently skipped
- The gap between declared governance and practiced governance should be zero

---

## 6. AI-Assisted Development

AI acceleration increases the need for controls, not the license to skip them.

- Multiple AI tools are used for gap analysis (Claude Code, Cursor, Copilot, Codex)
- Cross-tool findings are verified against disk before acting
- Agents operate within the trust tier model defined in AGENTS.md
- Every significant product decision gets a PRD; every architectural decision gets an ADR

---

## 7. Align File Boundaries with Change-Class Boundaries

When a companion rule needs to distinguish two classes of edit (structural vs.
organizational; binding vs. routine; policy vs. derived view), reshape the
artifact so each class lives in its own file rather than teaching the regex
layer about substructure.

- The companion-rule machinery's value is the simplicity of regex-over-paths.
  File shape determines the regex's precision; if a regex can't separate two
  change classes within one file, the artifact is doing too much.
- Prefer file splits over section-aware triggers, per-rule renderer parsers,
  or perpetual-exemption mechanisms — those add complexity that generalizes
  nowhere or codifies governance escape hatches as first-class primitives.
- First applied in [ADR-0012](adr/ADR-0012-opportunity-capture-index-split.md):
  the `management/opportunity-capture` README rule was firing on pure
  organizational edits; the fix was splitting the candidate index into a
  sibling `candidates.md` so the ADR-gated file holds only policy. No
  validator-engine change was needed.
- When evaluating a new companion rule, ask: *does the file this rule
  guards contain exactly one change class?* If not, split it before
  writing the rule.

---

## 8. Prefer Text Representations

When a new harness artifact can be expressed as text (YAML, Markdown,
Mermaid, SVG, plain bash) or as binary / proprietary format (PNG, JPG,
Figma file, Word doc, GUI-tool project file), choose text. The default
is overwhelming: every binary asset introduced is a maintenance and
governance debt the harness pays continuously.

- **Versionable** — text diffs are reviewable; binary diffs are opaque.
  A reviewer can see exactly what changed in a Mermaid diagram or SVG
  cover; a reviewer cannot meaningfully review a PNG diff.
- **Toolchain-free** — text artifacts edit in any editor on any
  platform. Binary artifacts couple the project to specific tooling
  (Figma seats, Photoshop licenses, Sketch on macOS-only) and to
  specific people who have that tooling.
- **CI-friendly** — validators can read, parse, and assert against
  text. They cannot meaningfully inspect a binary. Companion rules,
  placeholder validators, and link checkers all assume text input.
- **Diffable in PR review** — the same property that makes text
  reviewable in commits makes it reviewable in PR comments, where
  reviewers can quote specific lines.
- **Future-proof** — text representations survive tool deprecation.
  A 2026 Figma project may not open in 2036; a Mermaid block in a
  Markdown file will.

**Applied in the harness:**

| Surface | Text choice | Rejected alternative |
|---------|-------------|----------------------|
| Module contracts | `module.yaml` | GUI module-builder UI |
| Validators | Bash + Ruby scripts | Compiled binary tool |
| Architecture diagrams | Mermaid in Markdown | Static PNG / Figma export |
| Book covers | SVG (text-based) | PNG / JPG / InDesign |
| Skill definitions | Markdown SKILL.md | Compiled skill bundle |
| ADRs / PRDs / OPPs | Markdown | Confluence / Notion pages |
| Documentation diagrams | Mermaid blocks | Diagram-tool exports |
| Configuration | `.harness-headers.yaml`, etc. | TUI / config UI |

**When to break the rule:**

- **Photography or illustration** that genuinely requires raster (logos
  with photographic elements, screenshots of real product UIs, charts
  with thousands of data points). Even then, store the *source* of the
  artifact (Lightroom catalog, raw photo, screenshot recipe) alongside
  the rendered binary so the regeneration path is documented.
- **Render targets** for downstream tools that don't accept text (some
  print services need PNG / TIFF; some browsers can't render SVG
  filters). Generate from text source on demand rather than committing
  the binary. See `docs/_assets/README.md` for the rsvg-convert recipe
  that produces PNG covers from the SVG sources.
- **Tool-specific binary that must round-trip** (e.g., a `.psd` whose
  layers carry information the rendered PNG flattens away). Document
  the round-trip dependency explicitly so the rule's exception is
  legible.

**When introducing a new artifact, ask:** *can this be expressed as
text without losing essential meaning?* If yes, do so even if the text
representation is slightly less polished than the binary alternative;
the maintenance + governance gains compound across the project's
lifetime. If no, document the exception and the regeneration path
alongside the artifact.

- Derived from accumulated evidence in
  `docs/knowledge/shared-observations.md`: YAML manifests + bash
  validators + Markdown SKILL files + Mermaid diagrams + SVG covers
  each introduced under their own design pressure; the *pattern across
  all of them* is what this principle codifies. See specifically the
  observation *"Each new artifact asserting a catalog count is a new
  place that fact can drift"* (2026-05-22) which articulated the
  downstream cost of replicating facts across new artifacts —
  manageable when those artifacts are text (greppable, diffable, CI-
  assertable), much less so when they are binary.

**Markdown table caveat — never put a raw `|` inside backticks inside a
table cell.** Markdown is a preferred text representation, but its table
syntax has a sharp edge that costs review cycles: a literal `|` inside an
inline code span within a table cell is parsed by the renderer as a column
delimiter. It silently breaks the table (extra columns — `markdownlint`
MD056) and cascades into spurious "spaces inside code span" warnings
(MD038). When a table cell must show pipe-containing content — enum unions
like `a / b / c`, shell pipelines — use one of:

- **slashes:** `a / b / c`
- **prose:** "a, b, or c"
- **escaped pipes:** `a \| b \| c`

This bit the auto-harness change-log twice in one session (the
OPP-0011..0017 batch, 2026-05-24): an `engine` enum code span listing four
SQL engines inside a table row reported nine columns where six were
expected. The fix was slashes. The caveat is a corollary of this section,
not an exception to it — Markdown remains the right choice; the table
sub-syntax just has a trap worth naming so future authors don't re-pay the
review cycles.
