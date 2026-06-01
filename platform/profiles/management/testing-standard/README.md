<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Management Overlay: Testing Standard

**Depends on:** `kernel/base`.
**Conflicts with:** None.

The `testing-standard` management module provides testing governance for projects where
quality is a delivery requirement. It declares the artifacts an agent (or a human) must
produce and maintain, the thresholds that must be met before production milestones, and
the companion rules that prevent coverage regressions from slipping through silently.

This module does not prescribe a specific framework — it governs the *decisions* about
testing, not the implementation. The `harness-testing` skill (see `platform/skills/`)
provides framework-specific guidance on demand.

---

## What This Module Activates

### Required Artifacts

| Artifact | Purpose |
| -------- | ------- |
| `docs/testing/test-strategy.md` | Documents the testing pyramid layers in use, what is enforced in CI, and what is deferred to manual review |
| `docs/testing/coverage-thresholds.md` | Declares minimum coverage percentages by type (unit, integration, E2E) and which fail CI if not met |

### Companion Rules

| Trigger | Required Companion |
| ------- | ------------------ |
| `docs/testing/coverage-thresholds.md` changes | `docs/project/change-log.md` or a new ADR |
| `docs/testing/test-strategy.md` changes | `docs/project/change-log.md` or a new ADR |

Coverage thresholds are architectural commitments. Lowering them silently is the same as
silently removing a feature gate. The companion rule forces a documented decision.

### Review Gates

- Coverage thresholds must be met before a `production-saas` delivery milestone is marked complete.
- Test strategy must explicitly name which pyramid layers are enforced in CI.
- Agents must not reduce declared coverage thresholds without human approval.

---

## Agent Discipline: What Agents Must Not Do

This is the compiled fragment governance floor for AI agents operating on projects with
`testing-standard` active.

**Agents must not:**

- Write or modify code that reduces coverage below declared thresholds without flagging it
- Skip writing tests when implementing a new feature or fixing a bug, except in prototype delivery mode
- Remove or comment out tests without a rationale in the PR description
- Declare a milestone complete if test coverage is below the threshold declared in `docs/testing/coverage-thresholds.md`
- Lower coverage thresholds without human approval and a companion change-log entry

**Agents must:**

- Write tests when adding a new function, class, or API endpoint
- Verify test coverage before declaring an implementation task complete
- Run the test suite before requesting human review
- Flag any test that is skipped, pending, or marked TODO as a known gap in the PR description

**At Tier 3 (git-writing):** Agents may commit test files alongside implementation. They
may not merge code that breaks existing tests.

**At Tier 4:** Modifying CI test configuration (e.g., changing Jest/Pytest coverage
settings, adding test environment variables) requires explicit human direction.

---

## Testing Pyramid Guidance

The test strategy artifact must declare which layers of the testing pyramid are in use.
Use this as a reference for what belongs at each layer:

### Unit Tests

Test individual functions, classes, and modules in isolation. No external I/O, no
database, no network calls. Fast — should run in milliseconds per test.

**When to write:** Every non-trivial function. Every edge case. Every error path.

**Coverage target:** Typically 80–90% line/branch coverage of business logic.

### Integration Tests

Test that components work together correctly. May use a real database (test instance),
real file I/O, or real service clients against a local environment. Slower than unit tests.

**When to write:** For every database query layer, every API client, every service
boundary. Test the interaction, not the internals.

**Coverage target:** All critical paths through the service boundary. Not every permutation.

### End-to-End (E2E) Tests

Test the system from the outside — a real browser, a real API client, or a real CLI
invocation against a running instance. Slowest. Most maintenance burden.

**When to write:** For the most critical user journeys only. Not for every feature.

**Coverage target:** 5–10 key flows that, if broken, would mean the product is down.

### Contract Tests (if applicable)

For API services with external consumers: verify that the API surface matches the
published contract (OpenAPI spec or consumer-driven contract). Run in CI. Block deploy
if contract breaks.

---

## Growth Stage Calibration

Coverage expectations should match delivery posture:

| Stage | Unit | Integration | E2E | Notes |
| ----- | ---- | ----------- | --- | ----- |
| Prototype | 0% enforced | Optional | Optional | Speed over rigor; test what matters most |
| MVP / Early access | 60%+ | Critical paths | 2–3 key flows | CI must be green; manual QA still active |
| Production (v1) | 80%+ | All service boundaries | 5–10 flows | Automated coverage gate blocks merge |
| Scale | 85%+ | All critical paths | Full regression | Flaky test SLA; coverage dashboard |

The `delivery/prototype` module explicitly does not enforce coverage gates. When switching
to `delivery/production-saas`, update `coverage-thresholds.md` to reflect the new posture.

---

## Sensitive Path Patterns

The `testing-standard` module declares sensitive paths for both Node/TypeScript and Python
test configuration files (`jest.config`, `vitest.config`, `pytest.ini`, `pyproject.toml`,
`setup.cfg`). This is intentional — the module is stack-agnostic.

In practice, only the patterns relevant to your stack will ever match. A Node project
will never have `pytest.ini`; a Python project will never have `vitest.config`. The union
of patterns means the module works correctly regardless of which stack is active — no
extra configuration needed.

If your project has both stacks (rare), all patterns apply.

---

## How This Integrates with CI

Coverage enforcement belongs in CI, not just in the test strategy document. After declaring
thresholds in `docs/testing/coverage-thresholds.md`, wire them into the CI tool:

**Jest (Node/TypeScript):**

```json
// jest.config.js
coverageThreshold: {
  global: { lines: 80, branches: 75, functions: 80, statements: 80 }
}
```

**Pytest (Python):**

```ini
# pytest.ini or pyproject.toml
[tool.pytest.ini_options]
addopts = "--cov=src --cov-fail-under=80"
```

Changes to these configuration files are governed by the `testing-standard` sensitive path
patterns — the companion rule will fire if `docs/testing/coverage-thresholds.md` isn't
updated in the same PR.

---

## See Also

| Resource | Path |
| -------- | ---- |
| Test strategy template | `platform/templates/testing/test-strategy.md` |
| Coverage thresholds template | `platform/templates/testing/coverage-thresholds.md` |
| harness-testing skill | `platform/skills/harness-testing/SKILL.md` |
| Trust model | `platform/core/kernel/base/trust-model.md` |
| CI integration guide | `platform/workflow/ci-integration.md` |
