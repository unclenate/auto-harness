<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Operating Principles — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

These principles govern how the team builds and ships [[PROJECT_NAME]]. They are derived
from the kernel doctrine and adapted to this project's context. Changes to this file
should be deliberate and logged.

---

## 1. Ownership

Every artifact, service, and decision area has a named owner.

- Primary owner: [[OWNER]]
- Backup: [[BACKUP]]
- Ownership map: `docs/ops/ownership-map.md` (if applicable)

Ownership means you are the person who gets asked, not the person who does all the work.

---

## 2. Review Discipline

Review is a knowledge-distribution mechanism, not a rubber stamp.

- PRs require at least one reviewer who is not the author
- Governance-sensitive paths (HARNESS.md, AGENTS.md, CLAUDE.md, CI workflows) require the primary owner or backup
- Reviewer approval means "I understand this change and believe it is correct," not "I glanced at it"

---

## 3. Documentation as Part of the Change

Documentation is not follow-up work. A change is not complete until its documentation is current.

- Requirements changes require a change-log entry or ADR
- Architecture decisions require an ADR
- Operational changes require updated runbooks or checklists

---

## 4. Secrets and Credentials

Secrets never belong in tracked artifacts.

- No API keys, tokens, passwords, or connection strings in committed files
- Environment variables or secret managers only
- `.env` files must be in `.gitignore`

---

## 5. Operational Awareness

The team explicitly decides and documents:

- Who owns release decisions
- Who owns rollback authority
- How incidents are recorded
- Where risks are tracked

These decisions are not deferred to "when we need them."

---

## 6. AI-Assisted Development

AI acceleration increases the need for controls, not the license to skip them.

- Agents operate within the trust tier model defined in `AGENTS.md`
- Agent output is reviewed to the same standard as human output
- Agents do not self-elevate permissions or bypass review gates
