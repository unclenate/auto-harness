<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Problem Statement

**Intake source:** `docs/discovery/intake-questionnaire.md` §2–3
**Owner:** @platform-team
**Last updated:** 2024-01-15

---

## Problem

Developer teams adopting AI-assisted development lack a structured governance model that
works with their tools rather than around them. Existing approaches either over-specify
ceremony (heavyweight process documentation that nobody reads) or under-specify boundaries
(no governance at all, leaving agents free to take irreversible actions).

The result: teams either reject governance as overhead, or they experience avoidable incidents
when an AI agent takes a Tier 4 or Tier 5 action without human authorization.

---

## Value Proposition

A modular, manifest-driven harness that teams compose to their actual project needs — not a
one-size-fits-all checklist. Governance scales with the project's stage and complexity.
A prototype gets lightweight boundaries. A production SaaS gets enforced operational readiness.
AI agents operate within defined trust tiers in both cases.

---

## Users and Personas

| Persona | Role / context | Primary need |
|---------|---------------|-------------|
| Primary | Developer / tech lead | Initialize governance for a new project without heavyweight ceremony |
| Secondary | Engineering manager | Confidence that agent actions are bounded and auditable |
| Out of scope | Non-technical stakeholders | Platform is developer tooling; stakeholder artifacts are its output, not its audience |

---

## Why Now

AI-assisted development (Claude Code, Cursor, Copilot) has moved from experiment to daily
practice for many teams. The tooling outpaced the governance model — most teams have agents
that can write and commit code but no defined boundaries for what the agent should and should
not do autonomously.

---

## Opportunity Hypothesis

If we build a modular harness platform for teams using AI-assisted development, then developers
will initialize governance-compliant projects faster and agents will operate within safe
boundaries without requiring per-session human supervision of every action.

---

## Known Constraints

| Constraint | Source |
|------------|--------|
| Must work without requiring a specific framework or hosting vendor | Discovery intake §8 |
| Must support Ruby 3.0+ for validators (no gem dependencies) | Technical context §8 |
| Discovery phase must be usable before stack is chosen | Discovery intake §4 |
