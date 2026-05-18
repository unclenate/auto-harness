<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Documentation Revision Tracker

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-04-13

Tracks findings from reviews, audits, and validator runs, along with their
resolution status over time. Validator failures aren't failures — they're
the backlog.

---

| Finding ID | Severity | Description | Affected Documents | Status | Resolution | Date |
|------------|----------|-------------|--------------------|--------|------------|------|
| H-1 | High | adsclaw's ADR template has "Context source" field (names what triggered the decision); auto-harness ADR template does not | `platform/templates/adr.md` | **Resolved** | Added `Context source` field; also absorbed supersession reference pattern, stronger context framing, sectioned Alternatives format | 2026-04-13 |
| H-2 | High | auto-harness PRD template lacks the Version/Owner/Last Updated/Review Cycle header pattern used consistently across adsclaw documents | `platform/templates/product/prd.md` | **Resolved** | Added versioning header; added Cross-references section; added instruction to reference KPI dictionary instead of defining metrics inline | 2026-04-13 |
| H-3 | High | No "revision tracker" artifact — auto-harness has no way to track validator failures as a backlog with resolution status over time (adsclaw has `docs/meta/REVISION_TRACKER.md`) | `management/project-standard` | **Resolved** | Added `docs/project/revision-tracker.md` as required artifact; this file is the first instance | 2026-04-13 |
| H-4 | High | No KPI Dictionary pattern — auto-harness expects KPIs defined inline in PRDs, which leads to drift between planning and reporting (adsclaw has `docs/standards/KPI_DICTIONARY.md` as single source of truth) | `management/product-lite`, `platform/templates/` | **Resolved** | Added `platform/templates/standards/kpi-dictionary.md`; added as optional artifact on `management/product-lite`; auto-harness dogfoods at `docs/standards/kpi-dictionary.md` with 3 platform-level KPIs (Finding Resolution Velocity, Active Module Count per Manifest, Brownfield Artifact Coverage) | 2026-04-13 |
| H-5 | High | No Fallback Matrix / degraded-mode requirement for production-saas delivery (adsclaw enforces "every automated function must have a defined manual or degraded-mode fallback") | `delivery/production-saas`, `platform/templates/ops/` | **Resolved** | Added `platform/templates/ops/fallback-matrix.md`; added as optional artifact on `delivery/production-saas` with lifecycle expectations documented in module README (required before Harness Ready stage); three adoption paths documented (greenfield, brownfield, mid-project) | 2026-04-13 |
| M-6 | Medium | `harness-onboarding` skill assumes brownfield = existing codebase; fails to guide assessment of documentation-only pre-development projects like adsclaw | `platform/skills/harness-onboarding/SKILL.md` | **Resolved** | Added Step 0 (Governance Inventory); added Brownfield Variants section distinguishing code-based vs doc-only; Step 1 now detects mode and adapts; Step 3 supports EQUIVALENT status with richer notes; Step 5 supports optional Absorption Candidates section; Module Catalog updated to include `agents/openclaw` and revision-tracker.md in project-standard requirements; format-version bumped to 1.1 | 2026-04-13 |
| M-7 | Medium | `stacks/node-typescript` and `stacks/python` have `conflictsWith` but real polyglot projects (like adsclaw) use both runtimes legitimately | `platform/profiles/stacks/node-typescript/module.yaml`, `platform/profiles/stacks/python/module.yaml` | **Resolved** | Option A applied: removed `conflictsWith` entries on both stack modules; added "Polyglot Projects" sections to both READMEs explaining that multiple stacks may be activated, primary stack should be declared in `docs/architecture/overview.md`, and independent services should use separate manifests; updated `harness-onboarding` skill catalog and constraints to reflect polyglot support. Option C (primary/secondary manifest-schema semantics) captured as deferred finding L-13 for future consideration | 2026-04-13 |
| M-8 | Medium | No `docs/standards/` directory pattern — auto-harness templates don't encode the "standards = single source of truth" convention that adsclaw uses effectively | `platform/templates/`, `platform/workflow/` | **Resolved** | Created `platform/templates/standards/` directory; added Standards section to templates README; dogfooded at `docs/standards/kpi-dictionary.md`; added `platform/workflow/standards-pattern.md` documenting the convention, discipline, and when to adopt it independently of any single template | 2026-04-13 |
| L-9 | Lower | OODA Loop product pattern (adsclaw ADR-0014) — possibly domain-specific to competitive automation, but the structured handoff schema + cycle time instrumentation are generalizable concepts worth evaluating | adsclaw only (not yet in harness) | Deferred | Evaluate after Phase 3-5 absorptions complete; may warrant its own `domains/automation-loop` module | — |
| M-10 | Medium | No Review Log pattern — auto-harness has `reviewGates` declarations in module.yaml but no running log of who reviewed what, when, or with what outcome (adsclaw has `docs/meta/REVIEW_LOG.md` as dual-track governance alongside the revision tracker) | `management/project-standard`, `platform/templates/project/` | **Resolved** | Added `platform/templates/project/review-log.md`; added as optional artifact on `management/project-standard`; documented when to log (trust-tier gates, ADR status changes, PRD outcomes, material artifact changes) and explicit outcome values (Approved / Rejected / Changes Requested) | 2026-04-13 |
| M-11 | Medium | Directory naming conventions differ between auto-harness (`docs/adr/`, `docs/architecture/`, `docs/ops/`, `docs/project/`) and adsclaw (`docs/decisions/`, `docs/tooling/`, `docs/operations/`, `docs/meta/`). Decision needed on which conventions win | auto-harness conventions (authoritative); adsclaw (consumer) | **Resolved** | Decision: auto-harness conventions are authoritative for shared artifacts. adsclaw to rename: `docs/decisions/` → `docs/adr/`, `docs/operations/` → `docs/ops/`, `docs/tooling/ARCHITECTURE.md` → `docs/architecture/overview.md`, `docs/meta/REVISION_TRACKER.md` → `docs/project/revision-tracker.md`. Adsclaw keeps domain-specific dirs (`docs/gtm/`, `docs/engines/`, `docs/prompts/`). Rename work is an adsclaw action item, logged separately there | 2026-04-13 |
| H-12 | High | Absorption discovery (identifying patterns in target projects that could improve auto-harness) is a dual-use capability that could inadvertently catalog proprietary IP for export if enabled by default, creating adoption friction and reputational risk | `platform/skills/harness-onboarding/SKILL.md` | **Resolved** | Added "Absorption Discovery — Opt-in Only" section near top of skill; capability is OFF by default; explicit owner authorization required via prompt-level statement; agent must log authorization in assessment output; default-mode outputs (integration guidance, gap report, differences catalog) serve the target project only and never frame patterns as candidates for harness absorption; "distinction in practice" table makes the line concrete | 2026-04-13 |
| L-13 | Lower | Option C for polyglot stack support — primary/secondary manifest-schema semantics — was the user's preferred long-term direction but deferred in favor of simpler Option A. A future harness version could upgrade to explicit primary/secondary stack designations at the manifest level, with validator enforcement of exactly-one-primary | `harness.manifest.yaml` schema, `platform/validators/`, stack module READMEs | Deferred | Evaluate after real-world use of Option A reveals whether polyglot manifests get activated carelessly or whether primary/secondary distinction becomes operationally meaningful. Option A is a strict subset — upgrading to C later does not break existing polyglot manifests | — |
| H-14 | High | Agents lacked an explicit "halt before bypass" rule for failed governance controls. Observed in adsclaw (finding H-20 in that project's tracker): an agent worked around failed commit signing by using `--no-gpg-sign` rather than halting and surfacing the blocker to a human. The pattern generalizes beyond signing — any agent encountering a failed hook, validator, companion rule, or review gate could plausibly bypass it unless the base agent contract explicitly forbids this | `platform/agents/base/README.md`, agent operating patterns across all packs | **Resolved** | Added "Halt Before Bypass" section to the base agent pack README. Section enumerates commit signing, pre-commit hooks, CI validators, companion rules, and review gates as examples of controls that must not be bypassed. Section also defines what "halt and surface" means operationally. Rule is declared kernel-tier floor — tool-specific packs may add further halt conditions but cannot remove this one. Absorbed from adsclaw observation with Nate's authorization | 2026-04-15 |
| H-15 | High | No durable cross-agent shared knowledge surface existed. Agent institutional knowledge accumulated privately in each agent's workspace (MEMORY.md, daily logs) with no mechanism to flow across agents or become longitudinal project artifacts. The only agent-to-agent knowledge transfer was manual — Nate carrying context between JP and Bernays sessions. Without a shared surface, the harness's central thesis (that institutional knowledge becomes durable and self-improving) wasn't supported operationally | `platform/profiles/management/`, `platform/templates/`, `docs/knowledge/` | **Resolved** | Created `management/knowledge-capture` module with three required artifacts (README.md, shared-observations.md, distilled-learnings.md). Templates at `platform/templates/knowledge/`. Three companion rules enforce governance floor (observation audit trail, structure-lock ADR requirement, distillation review trail). Configuration lives in project's own knowledge README rather than manifest schema extension — policies are hot-adjustable per project while the foundational Observation Structure choice is ADR-locked. Dogfooded on auto-harness with ADR-0002 locking the Structured Template choice | 2026-04-16 |

---

## Finding ID Convention

- **C-n** — Critical: blocks release, security risk, data integrity issue
- **H-n** — High: governance gap, incomplete required artifact, broken dependency
- **M-n** — Medium: structural inconsistency, documentation gap
- **L-n** — Lower: style, naming, cross-reference improvements

## Status Values

- **Open** — finding acknowledged, no resolution yet
- **In Progress** — work underway
- **Partially Resolved** — some but not all aspects addressed
- **Resolved** — fully addressed, with resolution description and date
- **Deferred** — intentionally postponed; note when to revisit

## Resolution Format

When a finding is resolved, the Resolution column should:

- Describe what was done (e.g., "ADR-0008 accepted; credentials now via env vars")
- Reference the ADR, PR, or commit that resolved it
- Note the resolution date

---

## Summary

- **Resolved:** 13 of 15 findings
- **Partially Resolved:** 0
- **Open:** 0
- **Deferred:** 2

---

## Source Context

The initial findings in this tracker originated from JP's brownfield
assessment of the adsclaw project on 2026-04-13, using the `harness-onboarding`
skill. JP identified governance patterns in adsclaw that exceeded the
auto-harness baseline. Nate directed a methodical absorption of those
patterns back into the harness. Each resolved finding represents a
pattern absorbed.

This revision tracker is itself the first instance of a pattern absorbed
from adsclaw — a meta-outcome that demonstrates the feedback loop
auto-harness was designed for: the harness improves because it's being
used, not despite it.

---

**Document Owner:** @unclenate
