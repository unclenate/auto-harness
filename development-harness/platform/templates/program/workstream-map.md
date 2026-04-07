# Workstream Map

<!-- Source: platform/profiles/management/program-lite -->
<!-- Fill in: workstream names, owners, dependencies, and status -->

A workstream is a coherent unit of work with a single owner that can be planned and tracked
independently. This map captures all active workstreams, their dependencies, and current
status. Update it at every governance cadence touchpoint.

---

## Workstream Inventory

| Workstream | Owner | Depends On | Status | Target Complete | Notes |
| ---------- | ----- | ---------- | ------ | --------------- | ----- |
| [[WORKSTREAM_1]] | [[OWNER_1]] | — | Planned / Active / Blocked / Done | YYYY-MM-DD | [[NOTE]] |
| [[WORKSTREAM_2]] | [[OWNER_2]] | [[WORKSTREAM_1]] | Planned / Active / Blocked / Done | YYYY-MM-DD | [[NOTE]] |
| [[WORKSTREAM_3]] | [[OWNER_3]] | — | Planned / Active / Blocked / Done | YYYY-MM-DD | [[NOTE]] |

**Status definitions:**

- **Planned** — Scoped and scheduled; not yet started
- **Active** — In progress; on track
- **Blocked** — Work stopped; a dependency or decision is preventing progress
- **Done** — Acceptance criteria met and verified

---

## Dependency Graph

Describe cross-workstream dependencies in plain language. Update when dependencies change.

> Example:
> - Workstream 2 cannot start until Workstream 1 completes the data schema migration.
> - Workstream 3 requires the API surface from Workstream 1 to be stable before integration.

[[DEPENDENCY_DESCRIPTION]]

---

## Blocked Workstreams

Any workstream in "Blocked" status must have an entry here with the blocker description and
a resolution target date.

| Workstream | Blocker | Resolution Owner | Target Date |
| ---------- | ------- | ---------------- | ----------- |
| [[BLOCKED_WORKSTREAM]] | [[BLOCKER_DESCRIPTION]] | [[OWNER]] | YYYY-MM-DD |

If no workstreams are blocked, write: "No blocked workstreams."

---

## Workstream Graduation Criteria

What does "Done" mean for each workstream? Define acceptance criteria upfront.

| Workstream | Done When |
| ---------- | --------- |
| [[WORKSTREAM_1]] | [[ACCEPTANCE_CRITERIA]] |
| [[WORKSTREAM_2]] | [[ACCEPTANCE_CRITERIA]] |

---

## Reference

| Resource | Path |
| -------- | ---- |
| Governance cadence | `docs/program/governance-cadence.md` |
| Stakeholder report | `docs/program/stakeholder-report.md` |
| Milestones | `docs/project/milestones.md` |
| Program-lite module | `platform/profiles/management/program-lite/` |
