<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# auto-harness — Knowledge Capture

**Version:** 1.1 | **Owner:** @unclenate | **Last Updated:** 2026-05-25 *(distilled-learnings.md sunset per ADR-0014 / PRD-0011; two files now compose this directory; operating-principles is the curated longitudinal destination)*

This directory is the auto-harness project's durable, shared, reviewable
surface for institutional knowledge produced by participants — human and
agent alike.

Two files compose it:

- `README.md` — policies and structure for this project's knowledge capture (this file)
- `shared-observations.md` — append-only structured observations

The **curated longitudinal destination** for the project — durable
how-this-project-works truths synthesized from accumulating observations —
is [`docs/operating-principles.md`](../operating-principles.md). Promotion
from observations to principles happens when patterns crystallize, driven
by evidence rather than a synthetic cadence.

> **Historical note (ADR-0014, 2026-05-25).** This directory previously
> declared a third file, `distilled-learnings.md`, as a separate
> curated-synthesis destination. It was sunset after 40 days of zero
> inbound flow; operating-principles absorbed the curated charter in
> practice. See
> [ADR-0014](../adr/ADR-0014-sunset-distilled-learnings.md) and
> [PRD-0011](../requirements/PRD-0011-distilled-learnings-disposition.md).
> The file remains as a dormancy pointer at
> [`distilled-learnings.md`](distilled-learnings.md) for external-link safety.

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

## Promotion to Operating-Principles (EVIDENCE-DRIVEN)

Patterns reach `docs/operating-principles.md` when they crystallize —
when the same pattern appears across multiple observations or when a
single observation has clearly universal scope. Promotion is not on a
fixed cadence; it is driven by evidence accumulating in
`shared-observations.md`. The Write Policy is reconsidered when
signal-to-noise conditions warrant, not on a calendar.

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
