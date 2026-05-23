<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Coverage Thresholds

<!-- Source: platform/profiles/management/testing-standard -->
<!-- Companion rule: changes here require a change-log entry or ADR -->
<!-- These thresholds must be wired into the CI tool (Jest, Pytest, etc.) -->
<!-- to take effect — documentation alone is not enforcement. -->

**Owner:** [[OWNER]]
**Last reviewed:** YYYY-MM-DD
**Delivery stage:** [[PROTOTYPE / MVP / PRODUCTION / SCALE]]

This document declares the minimum coverage percentages that must be met before a PR
can merge. These thresholds must be configured in the test framework (see Implementation
section) so that CI fails automatically — this document is the source of truth, the
framework config is the enforcement mechanism.

Changing thresholds is an architectural commitment. The companion rule requires a
change-log entry or ADR in the same PR as any threshold change.

---

## Thresholds

| Type | Layer | Minimum | Enforced in CI | Notes |
| ---- | ----- | ------- | -------------- | ----- |
| Line coverage | Unit | [[UNIT_LINE_PCT]]% | Yes / No | [[NOTE]] |
| Branch coverage | Unit | [[UNIT_BRANCH_PCT]]% | Yes / No | [[NOTE]] |
| Function coverage | Unit | [[UNIT_FUNCTION_PCT]]% | Yes / No | [[NOTE]] |
| Line coverage | Integration | [[INTEGRATION_LINE_PCT]]% | Yes / No | [[NOTE]] |
| E2E | Key flows | [[E2E_FLOW_COUNT]] flows | Yes / No | [[NOTE]] |

**Default starting values by delivery stage:**

| Stage | Unit line | Unit branch | Integration | E2E |
| ----- | --------- | ----------- | ----------- | --- |
| Prototype | 0% | 0% | Not enforced | Not enforced |
| MVP | 60% | 50% | Critical paths | 2–3 flows |
| Production | 80% | 75% | All boundaries | 5–10 flows |
| Scale | 85% | 80% | All critical paths | Full regression |

Replace the table above values with your actual thresholds once decided.

---

## Exclusions

Some files are legitimately excluded from coverage (generated code, migration files,
config stubs). List them here so the exclusion is documented and deliberate.

| Excluded path / pattern | Reason |
| ----------------------- | ------ |
| `migrations/` | Generated migration files — logic not testable at unit level |
| `src/generated/` | Code-generated from schema — source of truth is the schema |
| `**/*.config.*` | Configuration files — behavior tested via integration |
| [[EXCLUSION_PATH]] | [[REASON]] |

These exclusions must be reflected in the framework configuration (e.g., `collectCoverageFrom`
in Jest, `omit` in pytest-cov).

---

## Implementation

Wire these thresholds into the project's test framework:

### Node / TypeScript (Jest)

```javascript
// jest.config.js or jest.config.ts
coverageThreshold: {
  global: {
    lines: [[UNIT_LINE_PCT]],
    branches: [[UNIT_BRANCH_PCT]],
    functions: [[UNIT_FUNCTION_PCT]],
    statements: [[UNIT_LINE_PCT]]
  }
},
collectCoverageFrom: [
  "src/**/*.{ts,tsx}",
  "!src/generated/**",
  "!migrations/**"
]
```

### Node / TypeScript (Vitest)

```typescript
// vitest.config.ts
coverage: {
  thresholds: {
    lines: [[UNIT_LINE_PCT]],
    branches: [[UNIT_BRANCH_PCT]],
    functions: [[UNIT_FUNCTION_PCT]]
  },
  exclude: ["src/generated/**", "migrations/**"]
}
```

### Python (pytest-cov)

```toml
# pyproject.toml
[tool.pytest.ini_options]
addopts = "--cov=src --cov-fail-under=[[UNIT_LINE_PCT]] --cov-report=term-missing"

[tool.coverage.run]
omit = ["migrations/*", "src/generated/*"]
```

---

## Coverage Threshold Change Policy

Thresholds may only be lowered with:

1. A documented rationale in `docs/project/change-log.md` or a new ADR
2. Explicit human approval (not agent-initiated)
3. A plan to restore the threshold within [[RESTORATION_DEADLINE]]

Thresholds may be raised at any time without ceremony — raising them is an improvement.

---

## Reference

| Resource | Path |
| -------- | ---- |
| Test strategy | `docs/testing/test-strategy.md` |
| Change log | `docs/project/change-log.md` |
| testing-standard module | `platform/profiles/management/testing-standard/README.md` |
| CI workflow | `.github/workflows/ci.yml` |
