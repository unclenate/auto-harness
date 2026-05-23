<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Project Change Log

<!-- Source: platform/profiles/management/project-standard -->
<!-- Update this log whenever scope, plan, or direction changes. -->
<!-- Companion rule: requirements.md changes require a new entry here OR a new ADR. -->

This log records material changes to project scope, plan, timeline, or technical direction.
It is not a git commit log — it captures *decisions and their rationale*, not code diffs.

A good entry answers: what changed, why, and what was explicitly deferred or dropped as a
result. This gives future contributors (and AI agents) context for why the project looks the
way it does.

---

## Log

| Date | Type | Change | Reason | Owner | ADR |
| ---- | ---- | ------ | ------ | ----- | --- |
| YYYY-MM-DD | Scope / Plan / Technical / Priority | [[WHAT_CHANGED]] | [[WHY]] | [[OWNER]] | ADR-XXXX or — |

**Type definitions:**

- **Scope** — something added to or removed from the project boundary
- **Plan** — timeline, phasing, or milestone change
- **Technical** — architecture or technology direction change (should also have an ADR)
- **Priority** — feature or work item reprioritized or deferred

---

## What Belongs Here

Add an entry when:

- A requirement is added, removed, or significantly changed
- A milestone is moved or dropped
- An architectural decision changes direction
- A feature is explicitly deferred to a future release
- A third-party dependency changes (vendor, API, integration)

Do NOT add entries for:

- Routine code changes (use git history)
- Minor wording or formatting fixes to docs
- Bug fixes that don't change scope or direction

---

## Reference

| Resource | Path |
| -------- | ---- |
| Requirements | `docs/product/requirements.md` |
| MVP scope | `docs/discovery/mvp-scope.md` |
| ADR directory | `docs/adr/` |
| Milestones | `docs/project/milestones.md` |
