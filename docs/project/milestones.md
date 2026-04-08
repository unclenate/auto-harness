# Milestones

---

## Milestone Table

| Milestone | Owner | Status | Exit Criteria |
| --------- | ----- | ------ | ------------- |
| Modular restructure | @unclenate | Done | Kernel + 20 modules with module.yaml contracts |
| Validator suite | @unclenate | Done | 6 validators, 49+ tests, 0 failures |
| Template coverage | @unclenate | Done | Every required artifact has a corresponding template |
| PRD restoration | @unclenate | Done | PRDs as first-class records with companion rule integration |
| Self-governance | @unclenate | Done | Harness governs itself; 0 disabled validations; all required artifacts exist |
| First consumer project | @unclenate | Planned | One real project onboarded using the harness |

---

## Milestone Detail

### Self-governance

The harness repository uses its own module system to govern itself. All required artifacts
declared by active modules exist with real content (not placeholder tokens). All validators
pass against the repo root. No validations are disabled in the manifest.

**Exit criteria:**

- [x] `harness.manifest.yaml` declares all appropriate modules
- [x] `HARNESS.md` and `AGENTS.md` exist at root
- [x] `docs/operating-principles.md` exists with real content
- [x] Product artifacts exist (problem-statement, requirements, release-intent)
- [x] Project artifacts exist (scope-plan, milestones, change-log, dependency-log)
- [x] At least one ADR and one PRD exist
- [x] `validate-required-artifacts` enabled and passing
- [x] `validate-agent-pack` enabled and passing

---

### First consumer project

Apply the harness to a real software project (not the harness itself) to validate the
onboarding workflow, template quality, and validator behavior in a consumer context.

**Exit criteria:**

- [ ] Consumer project bootstrapped from a starter composition
- [ ] All active validators pass
- [ ] At least 3 ADRs and 1 PRD created during development
- [ ] Feedback incorporated into harness templates or workflows

---

## Reference

| Resource | Path |
| -------- | ---- |
| Scope plan | `docs/project/scope-plan.md` |
| Change log | `docs/project/change-log.md` |
| Dependency log | `docs/project/dependency-log.md` |
