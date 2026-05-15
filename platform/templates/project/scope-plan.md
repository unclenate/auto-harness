<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Scope Plan

<!-- Source: platform/profiles/management/project-standard -->
<!-- Fill in: scope boundaries, phases, team, and constraints. -->
<!-- This is the planning contract for the project. Update it when scope changes; -->
<!-- log every change in docs/project/change-log.md. -->

The scope plan defines what this project is responsible for delivering, the phases of
delivery, the team, and the constraints. It is the reference artifact for deciding whether
a new request is in scope or a change request.

---

## Project Summary

| Field | Value |
| ----- | ----- |
| Project | [[PROJECT_NAME]] |
| Owner | [[PROJECT_OWNER]] |
| Sponsor | [[SPONSOR]] |
| Start date | YYYY-MM-DD |
| Target completion | YYYY-MM-DD |
| Current phase | [[CURRENT_PHASE]] |

---

## In Scope

What this project will deliver. Be specific — vague scope boundaries cause scope creep.

- [[IN_SCOPE_ITEM_1]]
- [[IN_SCOPE_ITEM_2]]
- [[IN_SCOPE_ITEM_3]]

---

## Out of Scope

What this project explicitly will NOT deliver. Naming out-of-scope items is as important
as naming in-scope items — it prevents assumptions from becoming requirements.

- [[OUT_OF_SCOPE_ITEM_1]] — deferred to [[FUTURE_PHASE_OR_PROJECT]]
- [[OUT_OF_SCOPE_ITEM_2]] — owned by [[OTHER_TEAM_OR_SYSTEM]]

---

## Phases

| Phase | Goal | Owner | Exit Criteria | Target Date |
| ----- | ---- | ----- | ------------- | ----------- |
| [[PHASE_1]] | [[GOAL]] | [[OWNER]] | [[EXIT_CRITERIA]] | YYYY-MM-DD |
| [[PHASE_2]] | [[GOAL]] | [[OWNER]] | [[EXIT_CRITERIA]] | YYYY-MM-DD |

---

## Team and Responsibilities

| Role | Name / Team | Responsibilities |
| ---- | ----------- | ---------------- |
| Project owner | [[OWNER]] | Final scope decisions, stakeholder communication |
| Tech lead | [[TECH_LEAD]] | Architecture decisions, technical review |
| Delivery lead | [[DELIVERY_LEAD]] | Milestone tracking, blocker escalation |
| [[ROLE]] | [[NAME]] | [[RESPONSIBILITIES]] |

---

## Constraints

Constraints that affect delivery. These are non-negotiable conditions the project must
operate within.

- **Timeline** — [[FIXED_DEADLINE_OR_NONE]]
- **Budget** — [[BUDGET_TIER_OR_CONSTRAINT]]
- **Compliance** — [[REGULATORY_OR_SECURITY_CONSTRAINT]]
- **Integration** — [[SYSTEMS_THAT_CANNOT_CHANGE]]
- **Team** — [[STAFFING_CONSTRAINTS]]

---

## Assumptions

Conditions assumed to be true. If an assumption turns out to be false, the scope plan
must be revisited.

- [[ASSUMPTION_1]]
- [[ASSUMPTION_2]]

---

## Reference

| Resource | Path |
| -------- | ---- |
| Requirements | `docs/product/requirements.md` |
| MVP scope | `docs/discovery/mvp-scope.md` |
| Milestones | `docs/project/milestones.md` |
| Change log | `docs/project/change-log.md` |
