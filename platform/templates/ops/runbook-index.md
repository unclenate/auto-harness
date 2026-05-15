<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Runbook Index

**Owner:** @owner
**Last updated:** YYYY-MM-DD
**Module:** `domains/media-pipeline`

This index is the entry point for operational procedures. Link each runbook here when it is
created. Do not embed full runbook content in this file — keep it as an index.

---

## Active Runbooks

| Procedure | File | Last tested | Owner |
| --------- | ---- | ----------- | ----- |
| [[Reprocess batch by date range]] | [[docs/ops/runbooks/reprocess-batch.md]] | [[YYYY-MM-DD]] | @owner |
| [[Recover partial pipeline failure]] | [[docs/ops/runbooks/pipeline-recovery.md]] | [[YYYY-MM-DD]] | @owner |
| [[Promote pipeline config to production]] | [[docs/ops/runbooks/config-promotion.md]] | [[YYYY-MM-DD]] | @owner |

---

## Coverage Gaps

List known operational scenarios that do not yet have a runbook:

| Scenario | Priority | Owner | Target |
| -------- | -------- | ----- | ------ |
| [[Scenario without runbook]] | [[High / Medium / Low]] | @owner | [[YYYY-MM-DD]] |

---

## Runbook Standards

Each linked runbook should include:

- **Trigger condition** — when to use this runbook
- **Prerequisites** — access, credentials, environment context required
- **Steps** — numbered, specific, with expected output at each step
- **Verification** — how to confirm the procedure succeeded
- **Rollback** — what to do if the procedure fails or makes things worse
- **Cost note** — if the procedure incurs significant compute or storage cost, state it

A runbook that cannot be followed by someone unfamiliar with the system is not a runbook —
it is a note to self. Write for the 3am incident responder who is not you.
