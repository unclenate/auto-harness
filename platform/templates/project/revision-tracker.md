<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Documentation Revision Tracker

**Version:** 1.0 | **Owner:** [[OWNER]] | **Last Updated:** YYYY-MM-DD

Tracks findings from reviews, audits, and validator runs, along with their
resolution status over time. Validator failures aren't failures — they're
the backlog.

---

| Finding ID | Severity | Description | Affected Documents | Status | Resolution | Date |
|------------|----------|-------------|--------------------|--------|------------|------|
| C-1 | Critical | [[FINDING_DESCRIPTION]] | [[AFFECTED_DOCS]] | Open | — | — |
| H-1 | High | [[FINDING_DESCRIPTION]] | [[AFFECTED_DOCS]] | Open | — | — |
| M-1 | Medium | [[FINDING_DESCRIPTION]] | [[AFFECTED_DOCS]] | Open | — | — |
| L-1 | Lower | [[FINDING_DESCRIPTION]] | [[AFFECTED_DOCS]] | Open | — | — |

---

## Finding ID Convention

- **C-n** — Critical: blocks release, security risk, data integrity issue
- **H-n** — High: governance gap, incomplete required artifact, broken dependency
- **M-n** — Medium: structural inconsistency, documentation gap
- **L-n** — Lower: style, naming, cross-reference improvements

## Status Values

- **Open** — finding acknowledged, no resolution yet
- **In Progress** — work underway
- **Partially Resolved** — some but not all aspects addressed
- **Resolved** — fully addressed, with resolution description and date
- **Deferred** — intentionally postponed; note when to revisit

## Resolution Format

When a finding is resolved, the Resolution column should:

- Describe what was done (e.g., "ADR-0008 accepted; credentials now via env vars")
- Reference the ADR, PR, or commit that resolved it
- Note the resolution date

---

## Summary

- **Resolved:** 0 of 0 findings
- **Partially Resolved:** 0
- **Open:** 0
- **Deferred:** 0

---

**Document Owner:** [[OWNER]]
