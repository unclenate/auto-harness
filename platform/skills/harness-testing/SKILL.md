---
name: harness-testing
description: "Testing governance and practice guidance for projects using the development harness testing-standard module. Use when writing tests, analyzing coverage, choosing a testing strategy, configuring test frameworks, or evaluating whether a PR meets the project's declared coverage thresholds."
license: Apache-2.0
compatibility: Designed for any Agent Skills-compatible client (Claude Code, VS Code, Cursor, and others). For projects with the management/testing-standard harness module active.
metadata:
  harness-module: management/testing-standard
  format-version: "1.0"
---

# harness-testing

This skill provides testing practice guidance for projects governed by the
`management/testing-standard` harness module. It covers test strategy patterns, coverage
analysis, framework configuration, and the agent discipline rules that apply to testing.

---

## Agent Discipline

Before any testing task, read the project's declared thresholds:

```bash
cat docs/testing/coverage-thresholds.md
cat docs/testing/test-strategy.md
```

**You must not:**

- Mark an implementation task complete without writing or verifying tests
- Reduce declared coverage thresholds without human approval and a companion change-log entry
- Remove or skip tests without flagging the gap in the PR description
- Merge code that breaks existing tests
- Declare a milestone complete if coverage is below the threshold in `coverage-thresholds.md`

**You must:**

- Write tests when adding a new function, class, or endpoint
- Run the test suite before requesting review: `[[TEST_RUN_COMMAND]]`
- Check coverage after running tests and compare against thresholds
- Flag skipped or pending tests explicitly

**Tier guidance:**

- Tier 3 — commit test files alongside implementation
- Tier 4 — modifying CI test configuration (coverage settings, environment variables) requires explicit human direction

---

## Testing Pyramid Quick Reference

| Layer | What it tests | Speed | When to write |
| ----- | ------------ | ----- | -------------- |
| Unit | Single function/class in isolation | < 100ms/test | Every non-trivial function, every edge case |
| Integration | Components working together (real DB, real I/O) | Seconds | Every service boundary, every DB query layer |
| E2E | Full system from outside (browser, real API) | Minutes | Critical user journeys only — 5–10 flows max |
| Contract | API surface vs. published spec | Fast | When external consumers depend on your API |

---

## What Belongs at Each Layer

### Unit tests

A function belongs at the unit layer if:

- Its logic can be tested without I/O
- The behavior is determined by its inputs and internal state alone

**Good unit test targets:** data transformation functions, validation logic, calculation
engines, state machines, error handling branches, utility functions.

**Anti-pattern:** mocking a database call in a unit test just to test that the mock was
called. That tests the mock, not the code.

### Integration tests

An interaction belongs at the integration layer if:

- It crosses a system boundary (database, filesystem, external service, message queue)
- The behavior depends on the state of the external system

**Good integration test targets:** repository/DAO layers, API endpoints (against a running
server with test DB), message queue producers/consumers, file I/O handlers.

**Setup pattern:** use a dedicated test database, seeded with fixtures. Roll back or
truncate between tests. Never share state with the development database.

### E2E tests

A flow belongs at the E2E layer if:

- It represents a complete user journey from the outside
- Breaking it means the product is demonstrably unusable

**Good E2E targets:** sign-up → verify → first action, checkout flow, admin content
creation, password reset. Not every feature — only the top 5–10 flows.

**Fragility budget:** every E2E test you add is a maintenance liability. Write them for
stability, not completeness.

---

## Framework-Specific Patterns

### Jest / Vitest (Node/TypeScript)

**Coverage run:**

```bash
npx jest --coverage
# or
npx vitest run --coverage
```

**Check thresholds are configured:**

```javascript
// jest.config.js
coverageThreshold: { global: { lines: 80, branches: 75 } }
```

**Test file conventions:**

- Unit: `src/**/__tests__/*.test.ts` or `src/**/*.test.ts`
- Integration: `tests/integration/**/*.test.ts`
- E2E: `tests/e2e/**/*.spec.ts` (Playwright) or `cypress/e2e/**/*.cy.ts`

**Snapshot tests:** Use sparingly. Snapshots that capture implementation details (not
user-visible output) become maintenance debt. If a snapshot test fails after a refactor
that didn't change behavior, the snapshot is testing the wrong thing.

### Pytest (Python)

**Coverage run:**

```bash
pytest --cov=src --cov-report=term-missing
```

**Threshold enforcement:**

```toml
# pyproject.toml
[tool.pytest.ini_options]
addopts = "--cov=src --cov-fail-under=80"
```

**Test file conventions:**

- Unit: `tests/unit/test_*.py`
- Integration: `tests/integration/test_*.py`
- Fixtures: `tests/conftest.py` — shared fixtures, DB setup/teardown

**Async tests (FastAPI):**

```python
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_endpoint(async_client: AsyncClient):
    response = await async_client.get("/health")
    assert response.status_code == 200
```

**Database isolation:** Use `pytest-asyncio` + transaction rollback per test, or
a separate test schema that is truncated between runs.

---

## Coverage Analysis

When coverage drops below threshold, identify the gap before writing tests:

```bash
# Jest: open HTML report
npx jest --coverage --coverageReporters=html
open coverage/index.html

# Pytest: show missing lines
pytest --cov=src --cov-report=term-missing
```

**Prioritize coverage of:**

1. Error paths — `if err != nil`, exception handlers, validation failures
2. Branch conditions — `if/else`, `switch`, ternary with non-obvious paths
3. Public API surface — every exported function/class

**Don't chase 100%:** Generated code, migration scripts, and config files should be
excluded (see `coverage-thresholds.md` exclusions). 100% coverage of business logic
is a reasonable goal; 100% of every file is not.

---

## Writing Testable Code

When implementing features, structure code so that:

1. **Pure functions are separated from I/O** — a function that transforms data should
   not also write to a database. Test the transformation; test the write separately.

2. **Dependencies are injectable** — classes and functions should accept their dependencies
   as arguments (or constructor parameters) rather than constructing them internally.
   This makes mocking possible without framework magic.

3. **Side effects are at the boundary** — database writes, external API calls, and file I/O
   belong at the outer layers of the system. The inner layers (business logic) should be
   pure and fast.

---

## Pre-Review Checklist

Before requesting human review on any implementation PR:

- [ ] `[[TEST_RUN_COMMAND]]` passes with exit 0
- [ ] Coverage meets or exceeds `docs/testing/coverage-thresholds.md`
- [ ] No new skipped or pending tests without a linked issue
- [ ] Integration tests cover new service boundaries (if any)
- [ ] E2E tests updated if a critical user journey changed (if applicable)
- [ ] Test files committed in the same PR as implementation (not a follow-up PR)

---

## Harness Integration Points

This skill complements two compiled fragments that are always loaded:

- `platform/profiles/management/testing-standard/README.md` — the governance floor
  (what must exist, what agents must not do)
- `docs/testing/test-strategy.md` — the project's specific testing decisions

The compiled fragments tell the agent what rules apply. This skill provides the
practice knowledge to apply them well.

---

## Reference

| Resource | Path |
| -------- | ---- |
| testing-standard module | `platform/profiles/management/testing-standard/README.md` |
| Test strategy template | `platform/templates/testing/test-strategy.md` |
| Coverage thresholds template | `platform/templates/testing/coverage-thresholds.md` |
| harness-governance skill | `platform/skills/harness-governance/SKILL.md` |
| CI integration guide | `platform/workflow/ci-integration.md` |
