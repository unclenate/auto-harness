<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Test Strategy

<!-- Source: platform/profiles/management/testing-standard -->
<!-- Fill in: testing pyramid layers, enforcement posture, and framework choices -->
<!-- Companion rule: changes here require a change-log entry or ADR -->

**Owner:** [[OWNER]]
**Last reviewed:** YYYY-MM-DD
**Delivery stage:** [[PROTOTYPE / MVP / PRODUCTION / SCALE]]

This document declares the testing approach for [[PROJECT_NAME]]. It defines which layers
of the testing pyramid are active, what is enforced in CI, what is deferred to manual
review, and what frameworks are in use.

---

## Testing Pyramid

### Unit Tests

**Status:** Active / Deferred / Not applicable

**Framework:** [[JEST / VITEST / PYTEST / MOCHA / OTHER]]

**Scope:** What is covered by unit tests in this project.

> Example: All pure business logic functions, utility modules, and data transformation
> layers. External I/O is mocked. Tests must run in under 100ms each.

[[UNIT_TEST_SCOPE_DESCRIPTION]]

**CI enforcement:** Yes — blocks merge if tests fail or coverage drops below threshold.

---

### Integration Tests

**Status:** Active / Deferred / Not applicable

**Framework:** [[JEST / PYTEST / SUPERTEST / HTTPX / OTHER]]

**Scope:** What is covered by integration tests in this project.

> Example: Database query layer (against a real test PostgreSQL instance), API endpoint
> handlers (against a running server with test DB), and service client adapters.

[[INTEGRATION_TEST_SCOPE_DESCRIPTION]]

**Test environment:** [[DESCRIBE_TEST_DB_OR_SERVICE_SETUP]]

**CI enforcement:** Yes / No — [[IF_NO_EXPLAIN_WHY]]

---

### End-to-End (E2E) Tests

**Status:** Active / Deferred / Not applicable

**Framework:** [[PLAYWRIGHT / CYPRESS / SELENIUM / OTHER]]

**Scope:** Which user journeys or API flows are covered.

> Example: User registration flow, checkout flow, admin dashboard login. Not every feature —
> only the flows that, if broken, mean the product is unusable.

[[E2E_SCOPE_DESCRIPTION]]

**CI enforcement:** Yes / No — [[IF_NO_EXPLAIN_WHY]]

---

### Contract Tests (if applicable)

**Status:** Active / Not applicable

**Framework:** [[PACT / OPENAPI-VALIDATOR / OTHER]]

**Scope:** Which APIs have external consumers whose contracts are verified.

[[CONTRACT_TEST_SCOPE_DESCRIPTION]]

---

## What Is NOT Tested Automatically

Be explicit about what is deferred to manual review or not tested. This prevents the
assumption that "CI is green = everything is correct."

- [[MANUAL_REVIEW_ITEM_1]] — verified by [[HOW]]
- [[MANUAL_REVIEW_ITEM_2]] — verified by [[HOW]]
- [[OUT_OF_SCOPE_ITEM]] — out of scope because [[WHY]]

---

## Test Execution

### Running tests locally

```bash
# Unit and integration tests
[[TEST_RUN_COMMAND]]

# E2E tests (requires running server)
[[E2E_RUN_COMMAND]]

# With coverage report
[[COVERAGE_COMMAND]]
```

### CI execution

Tests run in the `stack` job of `.github/workflows/ci.yml`. See
`platform/workflow/ci-integration.md` for the full workflow.

---

## Flaky Test Policy

A flaky test (fails intermittently without code changes) must be:
1. Triaged within [[FLAKY_TRIAGE_SLA]] of detection
2. Either fixed or marked `skip` with a linked issue
3. Not allowed to accumulate — an untracked flaky test is a blocked release

---

## Reference

| Resource | Path |
| -------- | ---- |
| Coverage thresholds | `docs/testing/coverage-thresholds.md` |
| CI workflow | `.github/workflows/ci.yml` |
| harness-testing skill | `platform/skills/harness-testing/SKILL.md` |
| testing-standard module | `platform/profiles/management/testing-standard/README.md` |
