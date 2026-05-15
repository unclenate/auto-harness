<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# auto-harness — Knowledge Capture

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-04-16

This directory is the auto-harness project's durable, shared, reviewable
surface for institutional knowledge produced by participants — human and
agent alike.

Three files compose it:

- `README.md` — policies and structure for this project's knowledge capture (this file)
- `shared-observations.md` — append-only structured observations
- `distilled-learnings.md` — curated longitudinal synthesis

Agents read this README on each heartbeat to know how to behave when
contributing. Humans update this README to tune the signal/noise levers
as the project evolves.

---

## Observation Structure (FOUNDATIONAL)

**Choice:** Structured Template
**Locked:** 2026-04-16 via ADR-0002

Observations in `shared-observations.md` MUST use this structure:

```markdown
### [Observation title]

- **Context:** What situation or project activity prompted this observation?
- **Observation:** What was noticed? Specific and factual.
- **Implication:** What does this suggest — for the project, team, or harness?
- **Confidence:** low | medium | high
- **Severity:** informational | governance-relevant | architectural | risk-bearing
- **Contributed by:** agent name or @handle, YYYY-MM-DD
```

See ADR-0002 for the rationale and rejected alternatives. Changes to this
choice require a new ADR (enforced by companion rule).

---

## Write Policy (ADJUSTABLE)

**Current mode:** heartbeat-only
**Last changed:** 2026-04-16 (initial)
**Rationale:** We're early. Signal over volume. Heartbeat-only plays
nicely with token-exhaustion concerns — if the heartbeat fails, no
rogue observations get written. Also enforces reflection: agents
contribute only after dreaming has distilled their daily logs, so
entries reflect considered judgment rather than in-the-moment reactions.

Options available:

- **autonomous** — any agent appends anytime (fast capture, noise risk)
- **heartbeat-only** — agents append only during Knowledge Contribution step after dreaming (current)
- **draft-to-promote** — agents draft in memory, humans promote to shared file (highest quality, slowest)

Adjust this value when signal-to-noise conditions warrant it. Log the
change and its rationale. The adjustment itself is governance-relevant
and should produce an entry in `shared-observations.md`.

---

## Distillation Cadence (ADJUSTABLE)

**Agent drafts distilled learnings:** weekly
**Team review sessions:** biweekly
**Next scheduled review:** 2026-04-30

Agents autonomously draft proposed distilled learnings on the draft
cadence (staged, not committed). Humans and agents review drafts on
the review cadence. Accepted distillations promote into
`distilled-learnings.md`. The review session is also when the Write
Policy is reconsidered if needed.

---

## Escalation Table

When an agent appends to `shared-observations.md`, the severity of the
observation determines what else the agent must update in the same
commit. The harness enforces the floor (daily memory pointer); the
agent's judgment handles the higher tiers.

| Severity | Floor (always) | Additional (by severity) |
|---|---|---|
| informational | Daily memory file | — |
| governance-relevant | Daily memory file | Revision tracker entry |
| architectural | Daily memory file | Revision tracker + new ADR draft |
| risk-bearing | Daily memory file | Revision tracker + ADR + risk register entry |

All escalations are drafts for human review. Agents do not commit these
changes without direction.

Note: auto-harness doesn't currently have an active risk register
(it's not a production-saas project). If an observation at
risk-bearing severity is appended here, the agent escalates to ADR
and notes that a risk register is not currently active for this
project.

---

## References

- Module definition: `platform/profiles/management/knowledge-capture/module.yaml`
- Foundational choice: `docs/adr/ADR-0002-knowledge-capture-structured-observations.md`
- Related modules: `management/project-standard` (revision tracker)

---

**Document Owner:** @unclenate
