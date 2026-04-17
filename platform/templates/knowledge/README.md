# [[PROJECT_NAME]] — Knowledge Capture

**Version:** 1.0 | **Owner:** [[OWNER]] | **Last Updated:** YYYY-MM-DD

This directory is the project's durable, shared, reviewable surface for
institutional knowledge produced by participants — human and agent alike.

Three files compose it:

- `README.md` — policies and structure for this project's knowledge capture
- `shared-observations.md` — append-only structured observations
- `distilled-learnings.md` — curated longitudinal synthesis

Agents read this README on each heartbeat to know how to behave when
contributing. Humans update this README to tune the signal/noise levers
as the project evolves.

---

## Observation Structure (FOUNDATIONAL)

**Choice:** [[OBSERVATION_STRUCTURE]]
**Locked:** YYYY-MM-DD via [[LOCKING_ADR]]

Observations in `shared-observations.md` MUST follow this structure. Changes
to this choice require an ADR because the structure shapes all downstream
processing (distillation, escalation, review).

Available choices and their templates:

### Structured Template (recommended)

Each observation uses four required fields:

```markdown
### [Observation title]

- **Context:** What situation or project activity prompted this observation?
- **Observation:** What was noticed? Specific and factual.
- **Implication:** What does this suggest — for the project, team, or harness?
- **Confidence:** low | medium | high
- **Severity:** informational | governance-relevant | architectural | risk-bearing
- **Contributed by:** agent name or @handle, YYYY-MM-DD
```

### Freeform prose

Each observation is a dated paragraph with contributor name. No required
fields. Easy to write, harder to synthesize.

### Severity-prefixed findings

Each observation is an O-N row (O-1, O-2, etc.) with severity (C/H/M/L),
description, implication, status (Open / Acknowledged / Distilled /
Superseded). Most structured; most bureaucratic.

---

## Write Policy (ADJUSTABLE)

**Current mode:** [[WRITE_POLICY]]
**Last changed:** YYYY-MM-DD
**Rationale:** [[WRITE_POLICY_RATIONALE]]

Options:

- **autonomous** — Any agent may append to `shared-observations.md` at any
  time during normal work or heartbeats. Fastest capture; highest noise risk.
- **heartbeat-only** — Agents may only append during the Knowledge
  Contribution step of their heartbeat, after dreaming has distilled their
  daily logs. Paced and reflective. Recommended default.
- **draft-to-promote** — Agents draft observations in their own daily
  memory; a human reviewer promotes entries to `shared-observations.md`.
  Highest quality; requires active curation.

Change this value when the signal-to-noise ratio warrants it. Note the
change and its rationale in the metadata above. The change itself is
governance-relevant and should produce an entry in `shared-observations.md`.

---

## Distillation Cadence (ADJUSTABLE)

**Agent drafts distilled learnings:** [[DRAFT_CADENCE]]
**Team review sessions:** [[REVIEW_CADENCE]]
**Next scheduled review:** YYYY-MM-DD

Agents autonomously draft proposed distilled learnings on the draft cadence.
Humans and agents review together on the review cadence, curating drafts
into `distilled-learnings.md`. The review session is also when the Write
Policy is reconsidered if needed.

---

## Escalation Table

When an agent appends to `shared-observations.md`, the severity of the
observation determines what else the agent must update in the same
commit. The harness enforces the floor (daily memory pointer); the agent's
judgment handles the higher tiers.

| Severity | Floor (always) | Additional (by severity) |
|---|---|---|
| informational | Daily memory file | — |
| governance-relevant | Daily memory file | Revision tracker entry |
| architectural | Daily memory file | Revision tracker + new ADR draft |
| risk-bearing | Daily memory file | Revision tracker + ADR + risk register entry |

All escalations are drafts for human review. Agents do not commit these
changes without direction.

---

## References

- Module definition: `platform/profiles/management/knowledge-capture/module.yaml`
- Workflow pattern: `platform/workflow/knowledge-capture-pattern.md`
- Related modules: `management/project-standard` (revision tracker),
  `delivery/production-saas` (risk register)
