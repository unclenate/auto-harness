<!--
NOTE: This is an auto-harness sample-project file (reference implementation).
If you copy this file into your own project, replace the SPDX/copyright
header below with your own — running
`bash platform/bootstrap/set-consumer-headers.sh` from your project root
after the copy will do this for you.
-->

<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Project Change Log

**Owner:** @platform-team

Changes that affect scope, architecture, delivery posture, or governance are logged here.
Minor implementation decisions do not require a change-log entry — only changes that would
affect how a new team member understands the project's direction or constraints.

Companion rule: when `docs/product/requirements.md` changes, this file must be updated in the
same PR or an ADR must be filed instead.

---

| Date | Change | Reason | Owner |
| ---- | ------ | ------ | ----- |
| 2024-01-10 | Initial composition established (node-typescript, web-app, relational-sql, production-saas) | Stack and delivery model confirmed in intake session | @platform-team |
| 2024-01-15 | Added `management/testing-standard` module | Team agreed coverage thresholds are a delivery requirement, not optional | @platform-team |
| 2024-01-22 | Scoped out web UI dashboard from v1 | Complexity vs. benefit ratio does not justify v1 effort; CLI governance sufficient | @platform-team |
| 2024-02-01 | Added `domains/gitbook` module | Documentation site chosen as the primary distribution format for the platform | @platform-team |
| 2024-02-14 | Delivery maturity upgraded from prototype to production | First governed external project onboarded; governance must be production-grade | @platform-team |
| 2024-03-01 | Added brownfield onboarding path (harness-onboarding skill + workflow guide) | Team identified brownfield as the dominant adoption scenario for existing projects | @platform-team |
