<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Changelog

All notable changes to **auto-harness** are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) once it reaches
v1.0.

This file summarizes *externally visible* changes — what a consumer sees when
they update their submodule pin. For the *internal* per-decision audit trail
(rationale, reviewer, ADR/PRD links), see
[`docs/project/change-log.md`](docs/project/change-log.md).

## [Unreleased]

### Added

- **`validate-trust-tier.sh`** (Wave 5.1 / PRD-0006 / ADR-0017) — 10th
  validator. Asserts each active module's optional `tier.declared` field
  (range 0–5; rationale required for ≥3) is coherent with the inferred
  tier (computed from `sensitivePaths` regexes against representative
  production-shape sample paths); agent-pack `maxTier` ≥ highest active
  non-agent tier; cross-cutting criticality check (relaxed for
  `maturity: platform`). Wired into CI validators job + consumer CI
  templates + harness-governance SKILL.md.
- **`tier` and `maxTier` schema fields on `module.yaml`** — additive,
  optional. `tier.declared` (0–5) declares the highest tier of work a
  module governs; `tier.rationale` required for declared ≥3. Agent
  modules additionally declare `maxTier` (capability ceiling).

### Changed

- **Active modules carry explicit tier declarations** (dogfood). Kernel
  declared tier 5 with rationale (governs CI workflows + governance
  entrypoints). Management modules tier 2; delivery/internal-platform
  tier 0; agents declared tier 2 + `maxTier: 5`. The declared kernel
  tier reflects PRD-0006 FR-003's strict "declared >= inferred" rule;
  it is a reinterpretation of FR-005's "Tier 0" descriptor (which
  describes the doctrine surface, not the governance ceiling). See
  `docs/project/change-log.md` Wave 5.1 entry for the full
  reconciliation rationale.
- **Trust-model documentation** (`platform/core/kernel/base/trust-model.md`)
  — "Enforcement Today" section restructured from "Honor Code" to
  "Partial Machine Enforcement (v1)" with an explicit what-is-now-
  enforced vs what-remains-honor-code split.
- **Threat-model A5 (Compromised AI agent)** updated: the
  `validate-trust-tier.sh` mitigation moves from acknowledged-gap to
  mitigations-in-place; v2+ enforcement gaps (session-level, transitive,
  cross-client allowlist) documented honestly.

---

## [v0.5.0] — 2026-05-23

First versioned release of auto-harness. Establishes the semantic-versioning
baseline; everything before this tag is pre-versioned development history
(see [`docs/project/change-log.md`](docs/project/change-log.md) for the
granular per-decision audit log of pre-v0.5.0 work).

Consumers should pin to `v0.5.0` (or later) instead of commit hashes going
forward.

### Added

- **Cycle-end distillation triggers** — paired machinery turning the
  aspirational "heartbeat with Knowledge Contribution step" prose into
  actionable contracts. Companion rule on `management/knowledge-capture`
  fires at PR boundary when distillation-worthy work is committed (new
  ADR, OPP, module manifest, or active-module catalog change); satisfied
  by an entry in any knowledge destination
  (`shared-observations.md` / `operating-principles.md` /
  `distilled-learnings.md`). Optional Claude Code `Stop`-event hook
  adapter at
  [`platform/examples/sample-projects/node-web-saas-postgres/.claude/hooks/distillation-prompt.sh`](platform/examples/sample-projects/node-web-saas-postgres/.claude/hooks/distillation-prompt.sh)
  emits a structured in-session prompt. Canonical workflow at
  [`platform/workflow/cycle-end-distillation.md`](platform/workflow/cycle-end-distillation.md).
  Spec: [PRD-0004](docs/requirements/PRD-0004-distillation-triggers.md),
  [OPP-0004](docs/opportunities/OPP-0004-distillation-triggers.md).

- **Consumer header hygiene v1** — 61 templates under
  `platform/templates/**` had literal SPDX/copyright headers replaced
  with `YEAR`, `OWNER_NAME`, `OWNER_EMAIL`, `SPDX_LICENSE` placeholder
  tokens (in `[[…]]` brackets per the template convention). New
  [`set-consumer-headers.sh`](platform/bootstrap/set-consumer-headers.sh)
  bootstrap helper (interactive + flag-driven; writes
  `.harness-headers.yaml` project-local config) substitutes tokens
  project-wide for consumer adopters. Spec:
  [PRD-0005](docs/requirements/PRD-0005-consumer-header-hygiene.md),
  [OPP-0005](docs/opportunities/OPP-0005-consumer-header-hygiene.md).

- **Six architecture diagrams** at
  [`docs/architecture/diagrams.md`](docs/architecture/diagrams.md) —
  composition, trust tier flow, companion rule firing, OPP/PRD/ADR
  lifecycle, distillation trigger composition, consumer adoption.
  Mermaid in Markdown so they render in GitHub web view + GitBook
  natively. Cross-linked from HARNESS.md, harness-governance SKILL,
  cycle-end-distillation, opportunity-capture, submodule-integration,
  and SUMMARY.md.

- **GitBook PDF / print cover assets** at
  [`docs/_assets/cover-front.svg`](docs/_assets/cover-front.svg) and
  `cover-back.svg` — 1600×2400, bold-typography + nested-rectangle
  module-composition motif. Self-documenting in
  [`docs/_assets/README.md`](docs/_assets/README.md).

- **8th validator: `validate-catalog-counts.sh`** — runs inline recipes
  (`find platform/profiles -name module.yaml | wc -l`, etc.) for seven
  catalog metrics; iterates a 23-row assertion table mapping
  `(file, regex, count-key)` to documented claim sites; reports drift
  with file-and-key context. `normalize_count()` handles English number
  words (one through twenty). Closes the count-drift class identified
  in `docs/knowledge/shared-observations.md`.

- **Operating-principles § 8: Prefer Text Representations** — codifies
  the existing pattern (YAML modules, Bash validators, Markdown
  SKILL/docs/templates, Mermaid diagrams, SVG covers) as durable
  doctrine with explicit rationale, applied-vs-rejected table, and
  three legitimate exception classes.

- **Five new authoritative workflow + threat-model docs** —
  [`extending-the-harness.md`](platform/workflow/extending-the-harness.md)
  (module / validator / skill / template / agent-pack author guide),
  [`modify-composition-mid-project.md`](platform/workflow/modify-composition-mid-project.md)
  (add / change / remove modules in active manifests),
  [`incident-response.md`](platform/workflow/incident-response.md)
  (five-phase operational workflow using the existing `incident.md`
  template),
  [`release-and-versioning.md`](platform/workflow/release-and-versioning.md)
  (the policy backing this release), and
  [`threat-model.md`](docs/threat-model.md) (companion to SECURITY.md
  with adversary models, attack surfaces, deployed mitigations).

- **opportunity-capture v1.1** — candidate index split out of
  README.md into sibling `candidates.md` per ADR-0012
  (file-boundaries-as-precision pattern; first formalized in
  operating-principles § 7).

- **knowledge-capture v1.1** — adds the cycle-end distillation companion
  rule.

- **claude-code v1.1** — adds the Stop-hook adapter as optionalArtifact.

### Changed

- **Validator count: 7 → 8** (added `validate-catalog-counts.sh`).
- **Workflow count: 14 → 18** (added extending-the-harness,
  modify-composition-mid-project, incident-response,
  release-and-versioning; cycle-end-distillation was already there).
- **`validate-companions.sh`** companion-rule regex on
  `management/knowledge-capture` broadened from
  `^platform/profiles/.+/module\.yaml$` to `^platform/.+/module\.yaml$`
  — covers agent-pack and kernel modules, not just profile modules.
  (Caught by the hook adapter's regex-mirror during PR #34.)
- **SUMMARY.md** reorganized — Day-to-Day Workflows gains four new
  rows; Maintenance & Operations gains release-and-versioning; new
  "Contributing & Extension" section adds extending-the-harness +
  threat-model; all 12 ADRs, 5 PRDs, 5 OPPs now listed under their
  respective sections (was lagging by 9 artifacts).
- **README.md** Reference section gains
  `docs/architecture/diagrams.md` entry; validator-count claims
  updated; validators table gains the new row.
- **`.gitignore`** scoped negation
  (`!platform/examples/sample-projects/*/.claude/`) so checked-in
  reference implementations under sample-projects ship alongside the
  consumer-runtime `.claude/` ignore.

### Fixed

- **`platform/bootstrap/add-license-headers.sh`** attribution drift at
  two sites (line 2 header + line 64 `AUTHOR=` variable) — both now
  use the canonical personal email matching every other source file.
- **Catalog count drift** at multiple call sites in
  `platform/reference/how-to-read.md`,
  `docs/architecture/diagrams.md`, `docs/_assets/cover-back.svg`,
  and `README.md` (now structurally prevented by the new
  `validate-catalog-counts.sh`).
- **`.placeholder-ignore`** scoped exemption for PRD-0005 (which
  legitimately specifies token names that the validator would
  otherwise catch).

### Architectural observations captured

Each observation in
[`docs/knowledge/shared-observations.md`](docs/knowledge/shared-observations.md)
generalizes a v0.5.0 design pressure into durable institutional
knowledge:

- *Distillation triggers can land without bootstrap exception when the
  introducing PR carries genuine learning*
- *Paired-mechanism implementation is a free correctness check on the
  governance side of the pair*
- *Harness primitives that don't compose toward the consumer-side
  surface are silent governance gaps*
- *PRD drafts surface questions the originating OPP successfully
  elided — the OPP→PRD pipeline is a discipline, not a redundancy*
- *Header-token classes split cleanly along project-wide vs.
  per-record axis*
- *Each new artifact asserting a catalog count is a new place that
  fact can drift*
- *Governance machinery that asserts against state-including-itself
  creates a free first-run self-test*
- *Doctrine in prose without enforcement in code is a recurring
  harness gap pattern* (the meta-finding driving Wave 3 work)
- (Earlier this release, pre-Wave) *Maintainer "I thought that was
  already happening" is the highest-signal gap-discovery pattern*

### Known limitations

- **No machine-checked trust-tier enforcement.** Tiers 0–5 remain
  honor-code; trust-tier-enforcement OPP is filed for v0.6+.
- **Knowledge management is write-only.** No query interface over
  observations; `distilled-learnings.md` curation workflow is
  aspirational. Smaller knowledge query tooling lands in v0.5.x; full
  curation workflow deferred to v0.6+.
- **Mermaid diagram labels** are not yet covered by the catalog-counts
  validator's assertion table for all sites (covered for diagram-1's
  `<br/>` boundary patterns but not for arbitrary diagram body text).
  Diagram-label drift remains a human-discipline concern in the gap.
- **No consumer-side migration tool** for projects that already
  inherited bad template headers before v0.5.0 — manual remediation
  pattern documented in `set-consumer-headers.sh` help text.

### Upgrade notes (from pre-v0.5.0 commit-pinned consumption)

If your project pinned to a commit hash on `main` between 2026-05-18
and 2026-05-22, you can move to `v0.5.0` cleanly — no breaking
changes in this release. The migration is essentially:

```bash
cd .harness
git fetch --tags
git checkout v0.5.0
cd ..
git add .harness
git commit -m "chore: pin auto-harness to v0.5.0 first release"
```

If you have template-derived files in your project with literal
auto-harness headers (`Copyright 2026 Nate DiNiro <UncleNate@gmail.com>`),
run `bash .harness/platform/bootstrap/set-consumer-headers.sh` to fill
the now-tokenized header forms with your project's identity.

## 2026-05-18 — Post-OSS-launch hardening sprint

### Added

- **CI hardening (PR #14, ADR-0009):** macOS-latest added to the validators
  - tests matrix (catches BSD-vs-GNU portability bugs that previously slipped
  through). New `bootstrap-tests` job runs `test_install.rb` + `test_link_skills.rb`
  against both OSes. `.github/CODEOWNERS` + `.github/dependabot.yml` added.
- **Quality audit (PR #13):** `docs/QUALITY-AUDIT-2026-05-18.md` — 56 findings
  across public-launch embarrassment risk, code correctness, security posture,
  onboarding friction, and markdownlint hygiene.
- **Cheap companion-rule satisfiers (PR #19, ADR-0010):** Kernel rule's
  `requiredAny` expanded to accept `docs/project/change-log.md` and
  `docs/project/dependency-log.md` alongside the heavyweight ADR / PRD /
  operating-principles. Routine governance maintenance (Dependabot bumps,
  CODEOWNERS additions) no longer demands a full architectural decision record.
- **Validator polish (PR #15):** Uniform `--help` / `-h` flag across all 7
  validators (previously crashed with raw Ruby stack traces). 3-state exit
  contract adopted (`0` = pass, `1` = violations, `2` = usage/dependency
  error). `HarnessRegistry::ManifestShapeError` typed exception replaces
  `NoMethodError` leaks on malformed input.

### Changed

- **Repo hardening enabled at the GitHub-settings level** via post-merge
  `gh api` calls: branch protection on `main` (6 required status checks +
  1 review + CODEOWNERS + no force-push + no deletion); secret scanning +
  push protection + auto-delete branches; squash-only merge style.
- **Catalog reconciliation across entry-point docs (PR #16):** README, HARNESS,
  AGENTS, platform/README, how-to-read all aligned to current state
  (5→7 skills, 6→7 validators, 7→9 starter compositions); fixed broken
  `validate-companions` command at README:148; replaced `YOUR-ORG` placeholder
  with `unclenate`; added macOS Bash 4 prerequisite warning.

### Fixed

- `actions/checkout v4 → v6` (PR #17, Dependabot): first auto-PR through the
  new Dependabot config. Reviewed per ADR-0010's satisfier-scales-with-change-
  weight policy.
- Two broken relative-link bugs (PR #18):
  `sample-projects/interview-driven-hackathon/HARNESS.md` (wrong `../` count);
  `docs/superpowers/plans/2026-05-12-...md` (wrong `../` count).
- `NOTICE` line 11 OSI canonical URL fix (PR #11): `/licenses/MIT` →
  `/license/MIT` per OSI's URL restructure.
- `platform/bootstrap/install.sh` (PR #12): preserves consumer `project.id` /
  `project.name` / `maturity` / `criticality` across `--force --composition`
  (was clobbering with the composition's example values). 3-state exit
  codes (informational CLAUDE.md conflict no longer exits 1). Bonus: BSD
  awk `-v` multi-line bug fix that had silently broken two macOS-only tests.

## 2026-05-17 — Agentic Interfaces + MCP awareness

### Added

- **Agentic Interfaces awareness (PR #5, ADR-0007, OPP-0002):**
  `domains/agentic-interfaces` module + optional `architectures/agentic-ui`
  overlay + template family + `harness-agentic-interfaces` Agent Skill +
  starter composition + sample project. Vendor-neutral (Controlled /
  Declarative / Open-ended / Conversational-primary flavor map); CopilotKit,
  A2UI, MCP Apps cited as canonical implementations.
- **MCP producer architecture (PR #6, ADR-0008, OPP-0003):**
  `architectures/mcp-server` module + 6-file template family +
  `harness-mcp` Agent Skill + starter composition + reference MCP server
  sample project. Cross-references existing TOOLS.md consumer-side coverage
  via new "Producer vs Consumer Roles" subsection.

## 2026-05-15 — Entry-point clarity + state-alignment + multi-AI-tool support

### Added

- **GitBook + entry-points refresh (PR #7):** First-Session Workflow in
  AGENTS.md; new root CLAUDE.md (thin Claude Code load-order shim);
  sibling-pointers blocks across HARNESS / AGENTS / README so each
  entry-point declares its job.
- **Multi-AI-tool coordination (PR #9):** New
  `platform/workflow/multi-agent-tool-coordination.md` + adapter modules
  for Gemini CLI, Codex CLI, Copilot CLI, Cursor. Each adapter maps the
  tool's specific approval/sandbox vocabulary onto harness trust tiers.

### Fixed

- **State-alignment audit (PR #8):** Drift fixes across module READMEs,
  workflow guides, validator + template inventories. Notable: two literally-
  broken validator invocations in bootstrap quickstart docs (`validate-companions`
  - `validate-placeholders` missing args).

## 2026-05-14 — Governance validators + forbidden-paths

### Added

- **`validate-doc-references.sh` (PR #10):** New validator catching stale
  `platform/...` path strings in markdown. Honors `.doc-reference-ignore`;
  skips fenced code blocks; dogfood test against own repo.
- **`forbiddenPatterns` companion-rule field (PR #10):** Schema + library +
  validator extension. Hard-fails `validate-companions.sh` regardless of
  `requiredAny` satisfaction. Forbidden-first ordering. Applied to codex-cli
  module to enforce the `AGENTS.override.md` ban (previously documentary).

### Changed

- **OPP-0002, OPP-0003, ADR-0007 promoted from Proposed to Accepted (PR #10)**
  with full Disposition + Promotion fields populated.

## 2026-05-13 — Interview-driven management overlay

### Added

- **Interview-driven management profile (PR #4, ADR-0006):** Monolithic-docs
  management overlay for hackathon-tier projects. Recognizes single PRD +
  decision-complete plan + AI-facing interview prompt. Co-exists with
  product-lite + project-standard for upgrade-later compatibility.
- **`oneOf` required-artifact semantics (PR #4):** `module.yaml` can now declare
  `requiredArtifacts` as an array of `oneOf` lists, satisfying the rule when
  any one of the alternatives exists.

## 2026-05-12 — OSS-readiness cut

### Added

- **Open-source-cut foundation (PR #3, ADR-0005):** Dual MIT/Apache-2.0
  licensing; per-file SPDX headers via `add-license-headers.sh`; full
  community-file foundation (`CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`,
  `SECURITY.md`, `AUTHORS`, `NOTICE`); GitHub issue forms + PR template
  embedding companion-rule discipline; TOC reorganization around
  Adoption → Day-to-Day → Maintenance → Reference axis.
- **Opportunity-capture module (PR #1, ADR-0004):** Forward-looking pre-PRD
  candidate records (`docs/opportunities/OPP-NNNN-*.md`) with promotion-to-PRD
  contract. First record: OPP-0001 (Exportable Governance Contract for
  Runtime Harnesses).

## Earlier — Pre-public history

For pre-public commits (modular governance bootstrap, knowledge-capture module,
submodule integration, web3 templates, etc.), see the [`git log`](https://github.com/unclenate/auto-harness/commits/main)
on `main` and the ADR series at [`docs/adr/`](docs/adr/).
