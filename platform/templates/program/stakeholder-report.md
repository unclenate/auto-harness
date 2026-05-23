<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Stakeholder Report

<!-- Source: platform/profiles/management/program-lite -->
<!-- Frequency: bi-weekly or per governance cadence -->
<!-- Fill in: status, decisions, risks, and milestone progress -->

This report is the primary artifact for communicating program health to stakeholders and
sponsors. Publish on cadence. Keep it short — one page or less. Detailed evidence lives in
linked ADRs, the change log, and workstream updates.

---

## Report Metadata

| Field | Value |
| ----- | ----- |
| Program | [[PROGRAM_NAME]] |
| Reporting period | YYYY-MM-DD to YYYY-MM-DD |
| Author | [[PROGRAM_MANAGER]] |
| Status | On track / At risk / Off track |

---

## Summary

State current status, the single biggest risk or blocker, and the next milestone.

> [[TWO_TO_THREE_SENTENCE_SUMMARY]]
>
> Example: "The data migration workstream is on track for the April 15 cutover. The primary
> risk is the third-party API rate limit — we've filed a quota increase request and have a
> workaround ready if it doesn't arrive in time. Next milestone: staging environment
> validation complete by April 10."

---

## Milestone Status

| Milestone | Target Date | Status | Owner | Notes |
| --------- | ----------- | ------ | ----- | ----- |
| [[MILESTONE_1]] | YYYY-MM-DD | On track / At risk / Done | [[OWNER]] | [[NOTE]] |
| [[MILESTONE_2]] | YYYY-MM-DD | On track / At risk / Done | [[OWNER]] | [[NOTE]] |

---

## Decisions Needed

Decisions that require stakeholder or sponsor input. Each should be resolved within
5 business days. Unresolved decisions older than 5 days are escalated automatically.

| Decision | Context | Needed By | Owner | Options |
| -------- | ------- | --------- | ----- | ------- |
| [[DECISION_1]] | [[BRIEF_CONTEXT]] | YYYY-MM-DD | [[OWNER]] | A / B / Defer |

If no decisions are needed this cycle, write: "No decisions pending."

---

## Risk Register Summary

Top risks this period. Full detail in `docs/security/risk-register.md`.

| Risk | Likelihood | Impact | Mitigation | Owner |
| ---- | ---------- | ------ | ---------- | ----- |
| [[RISK_1]] | High / Med / Low | High / Med / Low | [[MITIGATION]] | [[OWNER]] |

---

## Workstream Pulse

One-line status for each active workstream. Full detail in `docs/program/workstream-map.md`.

| Workstream | Lead | Status | Blockers |
| ---------- | ---- | ------ | -------- |
| [[WORKSTREAM_1]] | [[LEAD]] | On track / At risk | None or [[BLOCKER]] |

---

## What Changed This Period

Key decisions, shipped milestones, or changes to scope. Link to ADRs for architecture changes.

- [[CHANGE_1]] — [[brief description, with ADR-XXXX if applicable]]
- [[CHANGE_2]]

---

## Reference

| Resource | Path |
| -------- | ---- |
| Governance cadence | `docs/program/governance-cadence.md` |
| Workstream map | `docs/program/workstream-map.md` |
| Risk register | `docs/security/risk-register.md` |
| Change log | `docs/project/change-log.md` |
