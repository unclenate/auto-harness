<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Operating Principles — Development Harness Framework

> Owner: @unclenate
> Last updated: 2026-05-22

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
