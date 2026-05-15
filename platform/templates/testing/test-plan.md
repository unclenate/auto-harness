<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Test Plan

<!-- Source: platform/profiles/management/testing-standard (optional artifact) -->
<!-- Use this when a milestone or release requires a formal, time-bound test plan. -->
<!-- The test strategy (docs/testing/test-strategy.md) is evergreen and stack-wide. -->
<!-- This test plan is scoped to a specific release, milestone, or integration event. -->

**Milestone / Release:** [[MILESTONE_OR_RELEASE_NAME]]
**Owner:** [[OWNER]]
**Test period:** YYYY-MM-DD to YYYY-MM-DD
**Status:** Draft / Active / Complete

---

## Scope

What is being tested in this plan. Reference the milestone or release intent document.

**In scope:**

- [[FEATURE_OR_FLOW_1]]
- [[FEATURE_OR_FLOW_2]]

**Out of scope:** (what is deferred to a later test cycle or verified by other means)

- [[OUT_OF_SCOPE_ITEM]] — verified by [[HOW]]

---

## Environment Setup

| Environment | URL / Host | Database | Notes |
| ----------- | ---------- | -------- | ----- |
| Staging | [[STAGING_URL]] | Staging DB (seeded from fixture) | Use for integration and E2E |
| Local | `localhost:[[PORT]]` | Test DB | Use for unit and integration |

**Data seeding:**

```bash
# How to seed the test database for this test plan
[[SEED_COMMAND]]
```

**Prerequisites:**

- [ ] Staging environment is deployed and healthy
- [ ] Test data is seeded
- [ ] Access credentials are available (see `docs/ops/environment-inventory.md`)
- [ ] CI is green on the feature branch

---

## Test Cases

### Automated (CI)

These run on every PR and are not re-run manually. They are listed for completeness.

| Test type | Coverage target | Command | Status |
| --------- | --------------- | ------- | ------ |
| Unit | ≥ [[UNIT_PCT]]% lines | `[[UNIT_CMD]]` | CI enforced |
| Integration | Critical paths | `[[INTEGRATION_CMD]]` | CI enforced |
| E2E | [[E2E_FLOW_COUNT]] flows | `[[E2E_CMD]]` | CI enforced |

### Manual Test Cases

| ID | Area | Test case | Steps | Expected result | Tester | Status |
| -- | ---- | --------- | ----- | --------------- | ------ | ------ |
| TC-001 | [[AREA]] | [[TEST_CASE_NAME]] | [[STEPS]] | [[EXPECTED]] | [[TESTER]] | Not started / Pass / Fail |
| TC-002 | [[AREA]] | [[TEST_CASE_NAME]] | [[STEPS]] | [[EXPECTED]] | [[TESTER]] | Not started / Pass / Fail |

**Exploratory testing:**

Areas to explore without scripted cases (time-boxed to [[EXPLORATION_TIME]]):

- [[EXPLORATORY_AREA_1]]
- [[EXPLORATORY_AREA_2]]

---

## Defect Tracking

Defects found during this test plan are tracked in [[ISSUE_TRACKER_LINK]].

| ID | Severity | Summary | Status | Owner |
| -- | -------- | ------- | ------ | ----- |
| [[ISSUE_ID]] | Critical / High / Med / Low | [[SUMMARY]] | Open / In progress / Fixed / Closed | [[OWNER]] |

**Severity definitions:**

- **Critical** — blocks the release; no workaround
- **High** — significant user impact; workaround exists but is unacceptable for release
- **Med** — limited impact; acceptable for release with known issue documentation
- **Low** — cosmetic or minor; acceptable for release

---

## Exit Criteria

The milestone is considered tested and ready when:

- [ ] All CI checks green on the release branch
- [ ] Coverage ≥ declared thresholds in `docs/testing/coverage-thresholds.md`
- [ ] All Manual Test Cases status = Pass or formally deferred with documented rationale
- [ ] Zero Critical defects open
- [ ] High defects resolved or explicitly accepted with owner sign-off
- [ ] Test plan status updated to Complete

---

## Sign-off

| Role | Name | Date |
| ---- | ---- | ---- |
| Test owner | [[OWNER]] | YYYY-MM-DD |
| Product owner | [[PRODUCT_OWNER]] | YYYY-MM-DD |
| Tech lead | [[TECH_LEAD]] | YYYY-MM-DD |

---

## Reference

| Resource | Path |
| -------- | ---- |
| Test strategy (evergreen) | `docs/testing/test-strategy.md` |
| Coverage thresholds | `docs/testing/coverage-thresholds.md` |
| Release intent | `docs/product/release-intent.md` |
| Release checklist | `docs/ops/release-checklist.md` |
| testing-standard module | `platform/profiles/management/testing-standard/README.md` |
