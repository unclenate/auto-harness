<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Review Log

**Version:** 1.0 | **Owner:** [[OWNER]] | **Last Updated:** YYYY-MM-DD

Running record of governance reviews on this project — who reviewed what,
when, and with what outcome. Complements (does not replace) git history.
Git shows what changed; the review log shows who authorized the change
and what they examined.

---

## When to Log a Review

Log a review when:

- A trust-tier-gated action was authorized (Tier 3+ commits, Tier 4
  environment changes, Tier 5 production changes)
- An ADR status changes (proposed → accepted, accepted → superseded)
- A PRD is approved or rejected
- A required artifact is materially changed (scope, requirements,
  architecture, risk register)
- A review gate is invoked from a module's `reviewGates` field

Do not log:

- Routine edits that don't cross a review gate
- Self-reviews with no separate reviewer
- Typo fixes, formatting, or purely editorial changes

---

## Review Entries

| Date | Reviewer | What Reviewed | Context | Outcome | Notes |
|------|----------|---------------|---------|---------|-------|
| YYYY-MM-DD | [[REVIEWER]] | [[REVIEW_SUBJECT]] | [[REVIEW_CONTEXT]] | Approved \| Rejected \| Changes Requested | [[REVIEW_NOTES]] |

---

## Outcome Values

- **Approved** — reviewer accepts the change as-is
- **Rejected** — change should not proceed; see notes for reason
- **Changes Requested** — approved pending specific changes; relink to a
  follow-up entry when those changes land

---

## Cross-references

- Finding backlog: `docs/project/revision-tracker.md`
- Change history: `docs/project/change-log.md`
- Architectural decisions: `docs/adr/`
- Product decisions: `docs/requirements/`

---

**Document Owner:** [[OWNER]]
