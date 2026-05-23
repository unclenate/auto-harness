<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Requirements

**Project:** *(link to `docs/product/problem-statement.md`)*
**Growth stage:** prototype / early-access / v1 / GA
**Intake source:** *(link to `docs/discovery/intake-questionnaire.md`)*
**MVP scope:** *(link to `docs/discovery/mvp-scope.md`)*
**Owner:** @owner
**Last updated:** YYYY-MM-DD

Priority tiers:

- **Must** — required for this version to deliver value; in MVP scope
- **Should** — high value but can ship without; target v1+
- **Later** — acknowledged and deferred; explicitly out of scope for now

---

## User Stories

*(Derived from personas and intake. Format: "As a [persona], I want [action] so that [value]."
Reference `docs/product/personas.md` for persona definitions.)*

| ID | As a... | I want to... | So that... | Priority |
|----|---------|-------------|------------|----------|
| US-001 | [primary persona] | [action] | [value] | Must |

---

## Functional Requirements

| ID | Requirement | Acceptance Criteria | Priority | Notes |
|----|-------------|---------------------|----------|-------|
| FR-001 | Requirement | Concrete, testable acceptance criteria | Must | Link to US-NNN if applicable |

---

## Out of Scope for This Version

*(Explicitly list what this version will NOT include. This prevents in-scope assumptions
from expanding the build silently. Reference `docs/discovery/mvp-scope.md` for the full boundary.)*

| Feature | Reason deferred | When to revisit |
|---------|----------------|----------------|
| | Not needed for core value / complexity not justified yet | After [milestone or signal] |

---

## Quality Expectations

*(Non-functional requirements calibrated to the current growth stage.
A prototype has different expectations than a production SaaS.)*

| Area | Expectation | Notes |
|------|-------------|-------|
| Performance | | e.g., "Page load < 3s on 4G" or "Not a concern at prototype stage" |
| Reliability | | e.g., "99.9% uptime SLA" or "Best-effort for internal tool" |
| Security | | e.g., "PII encrypted at rest, no credentials in logs" |
| Accessibility | | e.g., "WCAG 2.1 AA" or "Not required for internal tool" |
| Browser support | | e.g., "Modern evergreen browsers only" |

---

## Success Metrics

*(How will the team know this version succeeded? Concrete signals, not feelings.
Derived from intake questionnaire §5.5 and §6.)*

| Metric | Target | Measurement method |
|--------|--------|-------------------|
| | | |

---

## Requirements Change Log

*(Record changes to requirements after the initial version is set.
A PR that changes this file must also update `docs/project/change-log.md` or create an ADR.)*

| Date | Change | Reason | Owner |
|------|--------|--------|-------|
| | | | |
