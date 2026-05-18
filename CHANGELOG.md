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

- Top-level `CHANGELOG.md` (this file) — quality-audit finding L1-09.
- Validator-level ReDoS defense: `Regexp.timeout = 1.0` set unconditionally
  in `platform/validators/lib/harness_registry.rb`. Compiled user-supplied
  regexes from `module.yaml` (companion rule paths + forbidden patterns) and
  `.doc-reference-ignore` can no longer wedge a validator. Quality-audit
  finding L2-07.
- Renderer-aware link fixes across entry-point docs: license links now use
  absolute GitHub URLs so they resolve correctly in GitBook (which treats
  bare extensionless paths as directories and 404s on `LICENSE-MIT/README.md`).
  Twenty directory-target links (trailing slash) in profile/template/sample
  READMEs now point at specific files (`README.md` / `SKILL.md` / `HARNESS.md`)
  for the same reason. Quality-audit finding L1-14 and the LICENSE-link issue
  surfaced post-audit.

### Changed

- `platform/validators/README.md` Bash-version requirement reworded to remove
  self-contradiction. The seven `validate-*.sh` scripts delegate to Ruby and
  work on Bash 3.2 (macOS default) + 4+; only the bootstrap scripts
  (`install.sh`, `link-skills.sh`, `add-license-headers.sh`) require Bash 4+.
  Quality-audit finding L1-08.

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
