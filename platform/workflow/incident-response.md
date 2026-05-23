<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Incident Response

## Operational Workflow for Production Incidents and Postmortems

An *incident* is any unplanned event where the system behaves
differently than intended in a way that affects users, data, or
operational integrity. This workflow defines how to respond, how to
document, and how to feed learning back into the harness's
institutional memory.

The harness ships a record template
([`platform/templates/incident.md`](../templates/incident.md)) but
prior to this workflow there was no process around using it. This
document is the process — *when* to file, *who* to involve, *what* to
capture, *how* to follow up.

> **Visual:** the [Trust Tier Decision Flow diagram](../../docs/architecture/diagrams.md#2-trust-tier-decision-flow)
> covers what agents may do autonomously vs. what requires human
> authorization. Incidents almost always involve Tier 4 or Tier 5
> operations; the trust tier model governs what humans must approve
> during response.

---

## When to File an Incident Record

File whenever **any** of the following is true:

- A production service is degraded or down
- User-visible data was lost, corrupted, or exposed
- A safety property the project claims (security, compliance,
  availability SLO) was violated
- A Tier 4 or Tier 5 operation produced an unintended effect
- An agent (AI or human) took an action that should have required
  authorization but didn't
- A validator chain failed in a way that produced a false-positive
  merge of broken code

Do *not* file an incident record for:

- Caught bugs in development that never reached production
- Validator failures that correctly blocked a bad merge (those are
  the system working)
- Routine operational events that the runbook anticipates

---

## Response Phases

### Phase 1: Stabilize

Goal: stop the bleeding. Tier escalation rules apply throughout —
agents may not self-elevate to Tier 4/5 even during incidents.

1. **Acknowledge.** Whoever notices files an `INC-<date>-<slug>.md`
   stub in `docs/incidents/` (create the directory if it doesn't
   exist; the harness doesn't currently require it but this is the
   right place). Use the template at
   [`platform/templates/incident.md`](../templates/incident.md).

2. **Communicate.** Notify the relevant Slack channel / on-call /
   stakeholders per the project's runbooks (`docs/ops/runbook-*.md`
   if your project has the ops module active).

3. **Mitigate.** Apply the smallest change that stops the harm.
   *Prefer rollback over forward-fix* in the stabilization phase —
   forward-fixes during an active incident introduce more
   uncertainty.

4. **Confirm stable.** Verify the user-visible symptom is gone before
   declaring stabilization complete. Watch for ~15-30 minutes
   minimum.

Throughout: document timestamps, decisions, and people involved in
the incident record. The record is the canonical artifact of the
incident's history.

### Phase 2: Investigate

Goal: understand the root cause without time pressure.

1. **Preserve evidence.** Logs, screenshots, configurations as they
   were at incident time. Snapshot before any cleanup actions.

2. **Reconstruct the timeline.** What changed? When? Who deployed
   what? Cross-reference git log, deployment history, monitoring
   data.

3. **Identify proximate cause** — the immediate trigger. The
   commit, the config push, the dependency upgrade, the data corruption.

4. **Identify root cause** — *why* the proximate cause was possible.
   This is almost always a system-level question, not a person-level
   one. "Why did our validation not catch this?" is more useful than
   "who pushed this commit?"

5. **Identify contributing factors** — anything that made the
   incident worse, longer, or harder to detect.

### Phase 3: Document

Complete the incident record before closing the response. Required
sections (per the template):

- **Summary** — one paragraph; what happened, when, what was the
  impact
- **Timeline** — timestamped events from detection through resolution
- **Root cause** — the system-level *why*
- **Proximate cause** — the immediate *what*
- **Mitigation** — what stopped the bleeding
- **Long-term fix** — what's being done to prevent recurrence (may
  span multiple PRs / follow-up work)
- **Lessons** — what generalizable knowledge does this incident produce?

The lessons section is the bridge to the harness's institutional
memory — see Phase 4.

### Phase 4: Distill

Goal: turn the incident into durable knowledge the project will
encounter again.

1. **File an observation** in
   [`docs/knowledge/shared-observations.md`](../../docs/knowledge/shared-observations.md)
   capturing the generalizable learning. Cite the incident record as
   Context.

2. **File an ADR** if the incident motivated a substantive design
   decision (e.g., "we will never deploy on Fridays" / "all migrations
   must run in a transaction"). The ADR codifies the decision; the
   observation captures the *why*.

3. **File an OPP** if the incident revealed a gap that warrants a new
   harness capability (e.g., "we need a Tier 4 escalation audit log").

4. **Update operating-principles** only if the lesson is a durable
   project-wide truth applicable to all future work.

5. **Update runbooks** if a step would have caught or prevented the
   incident — the runbook is the closest-to-runtime documentation.

### Phase 5: Close

1. **Verify the long-term fix landed** (or has a tracked timeline).
2. **Update the incident record status** to `resolved`.
3. **Conduct a blameless postmortem** if the incident was significant
   — a structured conversation among the people involved, not just
   the doc.
4. **File a follow-up review** in 30/60/90 days to confirm the fix
   held and the lessons were absorbed.

---

## Blameless Postmortem Discipline

Postmortems are *system reviews*, not *people reviews*. The harness
codifies this stance because AI-assisted development creates new
failure modes (agent-driven Tier escalation, validator-suppressed
bugs, etc.) that require system-level analysis.

Postmortem rules:

- **No individual is the cause.** "User X pushed bad code" is not a
  root cause; "the validator did not catch this class of error" is.
- **Every contributing factor is a question.** "Why did this happen?
  Why did *that* happen? Why did *that*?" — five-whys discipline.
- **The output is a learning, not a verdict.** Observations,
  operating-principles edits, ADRs — not performance reviews.
- **Confidential to the project's review log.** Postmortems may
  reference people; the *learning* that exits the postmortem must be
  decoupled from individuals.

---

## Incident Types and Their Typical Distillation

| Incident type | Typical distillation |
|---------------|----------------------|
| Validator failed to catch a real bug | New validator OR new companion rule OR test fixture |
| Companion rule fired on routine work (false positive) | Refine rule's triggerPaths OR file-boundary split |
| Agent escalated to Tier 4/5 without authorization | OPP for trust-tier enforcement; ADR for the boundary |
| Template scaffolded with wrong attribution | (Covered by PRD-0005 v1 — header hygiene machinery) |
| Distillation rule fired with no real learning to capture | Refine trigger set; see PR #34/35 lineage |
| Dependency update broke validators | Add dependency-log entry; consider pinning pattern |
| Documentation drift (claim doesn't match reality) | New assertion in `validate-catalog-counts.sh` OR new validator |

---

## Severity Levels

Suggested mapping for projects that adopt this workflow without their
own severity scale:

| Severity | Triggers | Response time | Postmortem required? |
|----------|----------|---------------|----------------------|
| **SEV-1** — service down or data loss | User-facing service unavailable; data corruption | Immediate; all hands | Yes; within 7 days |
| **SEV-2** — significant impairment | Major feature broken; safety property violated; security issue | Within 1 hour | Yes; within 14 days |
| **SEV-3** — degraded but functional | Minor feature broken; intermittent errors; performance issue | Within 4 hours | Optional; case-by-case |
| **SEV-4** — administrative | Process gap, internal-only impact | Next business day | No; lesson capture only |

Projects with their own severity model should use that instead.

---

## References

- Template: [`platform/templates/incident.md`](../templates/incident.md)
- Trust tier model: [`platform/core/kernel/base/trust-model.md`](../core/kernel/base/trust-model.md)
- Distillation workflow: [`cycle-end-distillation.md`](cycle-end-distillation.md)
- Knowledge destinations: [`docs/knowledge/`](../../docs/knowledge/README.md)
- Security disclosure: [`SECURITY.md`](../../SECURITY.md) (incident response ≠ security disclosure; the latter is the protocol for *receiving* an external vulnerability report)
