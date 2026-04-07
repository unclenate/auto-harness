# Governance Cadence

<!-- Source: platform/profiles/management/program-lite -->
<!-- Fill in: cadence owners, meeting names, and any program-specific cadences -->

This document defines the recurring governance touchpoints for the program. Each cadence has a
specific audience, purpose, and owner. Review this at program kickoff and update when teams or
delivery rhythms change.

---

## Cadence Table

| Cadence | Frequency | Audience | Purpose | Owner | Format |
| ------- | --------- | -------- | ------- | ----- | ------ |
| [[CADENCE_NAME_1]] | Weekly | Workstream leads | Delivery progress, blockers, dependency flags | [[DELIVERY_LEAD]] | 30-min standup or async update |
| [[CADENCE_NAME_2]] | Bi-weekly | Stakeholders + sponsors | Status summary, decisions needed, risk review | [[PROGRAM_MANAGER]] | Written report + 30-min review |
| [[CADENCE_NAME_3]] | Monthly | Executive sponsors | Program health, milestone tracking, escalations | [[EXECUTIVE_SPONSOR]] | Dashboard + 20-min review |
| Architecture sync | As needed | Engineers + leads | Cross-workstream architecture decisions | [[TECH_LEAD]] | RFC or async ADR review |
| Retrospective | Per milestone | All contributors | What's working, what to change | [[DELIVERY_LEAD]] | 60-min structured retro |

Add or remove rows for cadences specific to this program.

---

## Cadence Health Signals

Use these signals to assess whether the governance rhythm is working:

- **Blockers unresolved > 2 weeks** — escalate at next stakeholder review
- **Decisions outstanding > 5 business days** — flag to program manager
- **Missed retrospective** — schedule makeup before next milestone begins
- **Stakeholder report skipped > 1 cycle** — notify sponsors, resume next cycle

---

## Decisions Log

Track decisions made in governance touchpoints here. Non-trivial decisions should also produce
an ADR at `docs/adr/ADR-XXXX-*.md`.

| Date | Decision | Cadence | Owner | ADR |
| ---- | -------- | ------- | ----- | --- |
| YYYY-MM-DD | [[DECISION_SUMMARY]] | [[CADENCE_NAME]] | [[OWNER]] | ADR-XXXX or — |

---

## Escalation Path

| Trigger | Escalate To | Within |
| ------- | ----------- | ------ |
| Blocked dependency between workstreams | [[PROGRAM_MANAGER]] | 24 hours |
| Budget or timeline risk | [[EXECUTIVE_SPONSOR]] | 48 hours |
| Security or compliance issue | [[SECURITY_OWNER]] | Immediate |
| Architecture conflict unresolved in 48h | [[TECH_LEAD]] + [[PROGRAM_MANAGER]] | 48 hours |

---

## Reference

| Resource | Path |
| -------- | ---- |
| Workstream map | `docs/program/workstream-map.md` |
| Stakeholder report template | `docs/program/stakeholder-report.md` |
| Change log | `docs/project/change-log.md` |
| Program-lite module | `platform/profiles/management/program-lite/` |
