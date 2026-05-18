<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Operating Principles — Development Harness Framework

> Owner: @unclenate
> Last updated: 2026-05-17

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

---

## 3. Documentation as Part of the Change

Documentation is not follow-up work. A change is not complete until its documentation is current.

- New modules require README.md and module.yaml in the same commit
- Template changes require templates/README.md directory map update
- Workflow changes require SUMMARY.md and cross-reference updates
- Active-module catalog changes propagate to HARNESS.md, SUMMARY.md, README.md (directory tree), `platform/skills/harness-onboarding/SKILL.md` (module catalog), and `platform/workflow/discovery-to-composition.md` (decision rubric) in the same pass
- Repo-root governance entrypoints (`README.md`, `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, `TOOLS.md`) each carry a distinct job statement; when one is edited to change scope, the others' job statements and the SUMMARY.md "Entry Points by Audience" block are reviewed in the same pass

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
