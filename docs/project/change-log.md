# Project Change Log

This log records material changes to project scope, plan, timeline, or technical direction.
It is not a git commit log — it captures *decisions and their rationale*, not code diffs.

---

## Log

| Date | Type | Change | Reason | Owner | ADR/PRD |
| ---- | ---- | ------ | ------ | ----- | ------- |
| 2026-04-07 | Scope | Restored PRDs as first-class record type | PRD process was lost in monolith-to-modular decomposition; product decisions had no structured rationale record | @unclenate | PRD-0001 |
| 2026-04-07 | Scope | Added self-governance artifacts | Harness should eat its own dog food; declared modules but had no artifacts | @unclenate | ADR-0001 |
| 2026-04-07 | Scope | Added product-lite module to manifest | Required for PRD companion rules and product artifact tracking | @unclenate | — |
| 2026-04-07 | Technical | Repo renamed from ai-prompts to auto-harness | Name better reflects the project's purpose as a governance framework | @unclenate | — |
| 2026-04-07 | Technical | Promoted development-harness/ to repo root | Eliminated unnecessary nesting; simplified all internal path references | @unclenate | — |

---

## What Belongs Here

Add an entry when:

- A requirement is added, removed, or significantly changed
- A milestone is moved or dropped
- An architectural decision changes direction
- A feature is explicitly deferred to a future release
- A third-party dependency changes

Do NOT add entries for routine code changes, minor doc fixes, or bug fixes that don't
change scope or direction.

---

## Reference

| Resource | Path |
| -------- | ---- |
| Requirements | `docs/product/requirements.md` |
| ADR directory | `docs/adr/` |
| PRD directory | `docs/requirements/` |
| Milestones | `docs/project/milestones.md` |
