# Management Overlay: Program Lite

This overlay activates only when a project needs multi-workstream or multi-team coordination
records. Do not activate it for single-team projects — the overhead is real and the benefit
requires genuine cross-team dependencies to justify it.

---

## When to Activate This Overlay

Activate `program-lite` when:
- Two or more teams contribute to the same delivery milestone
- Cross-team dependencies could block or delay delivery
- A stakeholder outside engineering needs a consolidated status view
- There is a program-level risk that transcends any single team's scope

Do not activate it when:
- One team owns the entire delivery
- "Multi-team" means two people on the same team
- The coordination need is handled adequately by `project-standard`

---

## What This Overlay Requires

**`docs/program/workstream-map.md`**
A map of every active workstream: what each one owns, who leads it, and where the
cross-workstream dependencies are. Updated when workstreams are added, removed, or
when dependencies change.

**`docs/program/stakeholder-report.md`**
A periodic status summary for stakeholders outside engineering. Not a raw task list —
a synthesized view of progress, risks, and upcoming decisions that need stakeholder input.
Frequency is team-defined; existence is required.

**`docs/program/governance-cadence.md`**
The meeting and review rhythm: what standing meetings exist, their cadence, who attends,
and what decisions they're authorized to make. Governance cadence without a record
becomes tribal knowledge that evaporates when people leave.

---

## Dependency on `project-standard`

`program-lite` depends on `project-standard`. Each workstream should have its own
`project-standard` records (scope plan, milestones, change log). The program layer
aggregates across workstreams — it does not replace per-workstream delivery planning.

---

## Review Gate

Human review must confirm cross-team dependencies and stakeholder expectations are current.
Validators check file presence. Reviewers check that:
- The workstream map reflects actual team ownership, not an aspirational org chart
- Cross-workstream dependencies are named and have owners on both sides
- The stakeholder report is current (not a copy of last quarter's)
- Governance cadence reflects how the team actually operates

---

## Agent Behavior

Agents may draft workstream maps, stakeholder reports, and cadence documents. The workstream
map and dependency records must reflect real organizational structure — agents should ask for
confirmation before assuming team ownership or dependency relationships they cannot verify
from the codebase.
