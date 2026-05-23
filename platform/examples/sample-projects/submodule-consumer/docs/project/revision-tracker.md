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

# Documentation Revision Tracker

**Version:** 1.0 | **Owner:** @platform-team | **Last Updated:** 2024-02-10

Tracks findings from reviews, audits, and validator runs against this sample
project, along with their resolution status over time. Validator failures
aren't failures — they're the backlog.

This is a *sample project* tracker — illustrative only. A real consumer
project would log actual audit findings and validator outputs here.

---

| Finding ID | Severity | Description | Affected Documents | Status | Resolution | Date |
|------------|----------|-------------|--------------------|--------|------------|------|
| M-1 | Medium | Sample-project pedagogical placeholder tokens in prose body (illustrative; not consumer-facing drift) | `docs/project/milestones.md`, `docs/project/scope-plan.md` | Accepted | Documented as deliberate teaching content | 2024-02-10 |

---

## Finding ID Convention

- **C-n** — Critical: blocks release, security risk, data integrity issue
- **H-n** — High: governance gap, incomplete required artifact, broken dependency
- **M-n** — Medium: structural inconsistency, documentation gap
- **L-n** — Lower: style, naming, cross-reference improvements

## Status Vocabulary

- **Open** — finding logged, no resolution decided
- **Accepted** — finding acknowledged as deliberate (not a bug)
- **In Progress** — resolution underway
- **Resolved** — fix landed; finding closed
- **Superseded by [ID]** — re-classified under a different finding

## How to Use

When a review, audit, or validator surfaces a documentation finding, append
a row to the table above. Update Status as resolution progresses. Keep
historical rows after resolution — the tracker is the audit trail.

For a real consumer project, this file pairs with `docs/project/milestones.md`
and `docs/project/scope-plan.md` to give reviewers a complete picture of:
(a) what we said we'd do (milestones), (b) what we scoped (scope-plan), and
(c) what we found needs fixing along the way (this file).
