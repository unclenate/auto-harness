---
patterns:
  - scope-containment
  - least-permissions
  - human-in-the-loop
  - agent-identity
---

<!--
Copyright {{YEAR}} {{AUTHOR}} <{{AUTHOR_EMAIL}}>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of {{PROJECT_NAME}} — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

<!-- The YAML frontmatter above is the machine-checkable mirror of the four sections
below, parsed by validate-agent-defense-in-depth.sh (PRD-0032): all four patterns must
be named. Keep it in sync with the sections. -->

# Agent Defense-in-Depth

> How **{{PROJECT_NAME}}** realizes the four mutually-reinforcing defense-in-depth
> patterns for autonomous AI agents. Fill each section with *concrete* evidence, not
> doctrine in prose. Part of the `architectures/agent-defense-in-depth` overlay
> (PRD-0030 / OPP-0031). Upstream: Microsoft's *Defense in depth for autonomous AI agents*.

## Pattern 1 — Agents as microservices (scope-containment)

One agent, one job; each agent writes only to its own cache. Declare the
scope-containment boundaries.

- **Evidence:** <!-- TODO: the per-agent / per-skill capability boundaries — what each agent's job is, and what cache/workspace it (and only it) writes to -->

## Pattern 2 — Least permissions

Each agent is granted the minimum capability set needed for its task.

- **Permission model:** <!-- TODO: for each agent, what it CAN do and what it explicitly CANNOT do (filesystem, network, tools, external actions) -->

## Pattern 3 — Deterministic human-in-the-loop on consequential actions

Draft, never auto-execute, anything with material consequence (a portal message, a
financial transaction, a code merge to main).

- **Draft-vs-autonomous ledger:** <!-- TODO: list each action type and whether it is a DRAFT (requires human approval) or AUTONOMOUS (executes without approval); a consequential action should be a draft -->

> A **non-autonomous product** (one that only ever drafts) satisfies this pattern
> trivially — everything is a draft — and may treat the append-only action log as
> not-applicable.

## Pattern 4 — Agent identity

Every action is attributable to a named agent. *Identity makes all of it auditable.*

- **Identity-binding:** <!-- TODO: how each action is attributed to a named agent in audit logs; ties to docs/security/append-only-action-log.md (the audit-substantiation) and, if active, the architectures/agent-observability trace contract's identity attributes -->

## Composition notes

- **Trust-tier (OPP-0006) is orthogonal.** Trust-tier says *what the agent may do*; this
  artifact says *how the agent structures itself to do it safely*. A Tier-3 and a Tier-4
  agent can both adopt all four patterns.
- **Healthcare:** if **{{PROJECT_NAME}}** is a patient-facing health agent, adopt this
  overlay as the umbrella **and** the patient-facing-safety surface (OPP-0022) as the
  healthcare-specific instantiation (draft-never-send on portal messages, PHI workspace
  boundary, indirect-injection-via-ingestion resistance).
- **Pre-LLM transport gate (related, distinct):** <!-- TODO: if applicable, note any defense-BEFORE-LLM input sanitization (e.g. locking inbound mail to a sender allowlist at the transport layer before any model sees it) — adjacent to least-permissions but a pre-input check, not a during-action one -->

## Update policy

Treat this as the source of truth for **{{PROJECT_NAME}}**'s agent-safety structure. When
a new action type is introduced, update the relevant pattern section in the same change.
(A companion rule and pattern-specific validators enforcing these commitments are the
`architectures/agent-defense-in-depth` v2 follow-up; v1 is the declared contract.)
