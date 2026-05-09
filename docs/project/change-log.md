# Project Change Log

This log records material changes to project scope, plan, timeline, or technical direction.
It is not a git commit log — it captures *decisions and their rationale*, not code diffs.

---

## Log

| Date | Type | Change | Reason | Owner | ADR/PRD |
| ---- | ---- | ------ | ------ | ----- | ------- |
| 2026-05-09 | Scope | Extended PRD template with optional execution-spec sections (Goals & Non-Goals, Tech Stack, API & Data, UI/UX Notes, CI/CD Gates) | A talk on hackathon-style PRDs surfaced gaps where the template, optimized as a governance record, doesn't constrain AI-agent build choices. Single template with "when applicable" sections supports both flavors; PRD-0001 backfilled to demonstrate `N/A — governance PRD` convention; companion rules unchanged. | @unclenate | PRD-0002 |
| 2026-04-21 | Technical | Adopted git submodule as first-class consumption model with brownfield-safe bootstrap and multi-platform coexistence | Copy-in adoption caused upstream drift; consumers rarely re-synced; multi-platform repos needed explicit coexistence guarantees. Shipped: `install.sh` + `link-skills.sh` bootstrap tools, `submodule-integration.md` guide, `TestSubmoduleMount` proof, doc updates across `ci-integration.md` / `bootstrap-quickstart.md` / `brownfield-onboarding.md` / `SKILL.md` / `README.md`. | @unclenate | ADR-0003 |
| 2026-04-20 | Technical | Added CI self-governance workflow and installed `harness-governance` skill for self-application | Harness now enforces its own validator chain and self-tests on every PR/push to main, and agents working on the harness operate under the governance skill it provides to projects | @unclenate | — |
| 2026-04-08 | Technical | Bootstrapped `AGENTS.md` as the workspace-instructions entrypoint | Keep one cross-tool source of truth for agent guidance and avoid duplicated Copilot-specific instructions | @unclenate | — |
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
