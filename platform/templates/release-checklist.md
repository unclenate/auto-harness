<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Release Checklist

<!-- Source: platform/profiles/delivery/production-saas -->
<!-- Complete this checklist before every production release. -->
<!-- If a line item is not applicable, mark it N/A and note why. -->

**Release version:** [[RELEASE_VERSION]]
**Release owner:** [[RELEASE_OWNER]]
**Second approver:** [[SECOND_APPROVER]]
**Scheduled release window:** YYYY-MM-DD HH:MM UTC
**Rollback authority:** [[ROLLBACK_AUTHORITY]]

This checklist gates every production release. The release owner is accountable for completing each
section. The second approver independently verifies the Readiness section before deployment begins.
Complete sections in order — a blocking item in one section stops progress to the next.

---

## 1. Readiness

These items must be verified before any deployment action begins.

**Governance**

- [ ] All harness validators pass: `validate-manifest.sh`, `validate-module-graph.sh`, `validate-required-artifacts.sh`
- [ ] Companion validation passes for this PR (all companion rules satisfied)
- [ ] No open items in `docs/security/risk-register.md` classified High likelihood + High impact without an approved mitigation plan
- [ ] `docs/database/migration-readiness.md` is current if this release includes database migrations

**Code quality**

- [ ] All automated tests pass in CI (unit, integration, E2E if applicable)
- [ ] Code coverage meets declared thresholds in `docs/testing/coverage-thresholds.md`
- [ ] No unresolved critical or high-severity linting or type errors
- [ ] Dependency versions pinned; no floating `latest` in production code paths

**Artifacts and documentation**

- [ ] `CHANGELOG.md` or `docs/project/change-log.md` updated with changes in this release
- [ ] `docs/product/release-intent.md` reflects the current release goal
- [ ] Any new required artifacts are present (not stubs with unfilled `[[PLACEHOLDER]]` tokens)
- [ ] Runbooks updated if operational procedures changed

**Operations**

- [ ] Rollback plan is documented and rollback owner has been briefed
- [ ] On-call or operational owner identified for the release window
- [ ] Monitoring dashboards reviewed; no unexplained anomalies in the past 24 hours
- [ ] External dependency health confirmed (third-party APIs, infrastructure services)

**Human approvals**

- [ ] Second approver has reviewed and signed off on Readiness section
- [ ] Any required stakeholder notifications sent

---

## 2. Deployment

Complete these steps in order during the release window.

**Pre-deployment**

- [ ] Feature flags set for partial rollout if applicable
- [ ] Maintenance mode or traffic throttling in place if needed for zero-downtime migration

**Database migrations (if applicable)**

- [ ] Migration script reviewed and tested against a staging snapshot
- [ ] Rollback script verified
- [ ] Migration run against staging within the past 48 hours with no errors
- [ ] Migration runtime measured; acceptable within the release window

**Deployment execution**

- [ ] Deployment initiated via approved pipeline (not manual push)
- [ ] Deployment log captured
- [ ] Health checks green within expected timeframe after deploy

**Post-deploy validation**

- [ ] Key user workflows tested in production (per test plan or smoke test script)
- [ ] Error rates and latency reviewed — within normal bounds
- [ ] Alerts reviewed — no unexpected firings
- [ ] Feature flags re-enabled / rollout expanded if staged

---

## 3. Verification and Close

Complete within 30 minutes of deployment completing.

- [ ] All post-deploy smoke tests pass
- [ ] No incidents opened during the release window
- [ ] Release version tagged in version control
- [ ] Release owner confirms release complete
- [ ] Rollback authority stands down

**Notes / issues encountered during this release:**

*Record any deviations, near-misses, or follow-up actions here. These feed the post-release review.*

---

## Release Outcome

- [ ] **Successful** — no rollback required
- [ ] **Successful with issues** — deployed but with deviations noted above
- [ ] **Rolled back** — see `docs/ops/rollback-checklist.md`

**Signed off by:** __________________ **Date:** __________________
