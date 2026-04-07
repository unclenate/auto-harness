# Delivery Overlay: Prototype

This overlay keeps documentation and ops expectations intentionally light while preserving
kernel governance and audit boundaries. Use it for throwaway experiments, early validation,
and projects where the primary goal is learning — not production operation.

---

## What This Overlay Does (and Doesn't) Require

**No required artifacts** beyond what `kernel/base` demands (HARNESS.md, AGENTS.md,
docs/operating-principles.md). The prototype posture explicitly waives the ops artifacts
that `production-saas` requires — no environment inventory, no release checklist, no risk
register.

**Conflicts with `production-saas`.** The two postures cannot coexist. When a project
graduates from prototype to production, replace `prototype` with `production-saas` in the
manifest and create the required ops artifacts before accepting real user traffic.

---

## Core Rule: Prototype Does Not Waive Security

Lighter governance does not mean lighter security.

The review gate is explicit: *"Prototype mode does not waive security or secret-handling rules."*

A prototype that handles real credentials, real user data, or real payment information is no
longer a prototype in any meaningful sense. If the system touches data that would be painful
to lose or expose, it has already graduated beyond prototype posture regardless of what the
manifest says.

---

## When to Graduate to Production Posture

Switch `prototype` to `production-saas` when any of the following become true:

- Real users with real accounts
- Any data that would be painful to lose
- Any external stakeholder dependency on uptime
- Credentials or secrets that are shared or non-rotatable
- Any regulatory or compliance requirement

Switching delivery module triggers required artifact validation for ops artifacts. This is
intentional — create those artifacts before the switch, not after.

---

## How This Overlay Composes

Prototype pairs with any stack, architecture, and data module. The composition signals
summary in the intake questionnaire will route here for budget tier "throwaway prototype"
or "MVP validation."

---

## Agent Behavior

In prototype posture, agents operate under the same trust tier model as production. Tier 4
and Tier 5 actions (environment-altering, remote/production) still require human authorization.
The prototype posture relaxes documentation requirements, not operational safety boundaries.
