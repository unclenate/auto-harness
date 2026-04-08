# Problem Statement

**Owner:** @unclenate
**Last updated:** 2026-04-07

---

## Problem

Teams using AI coding assistants (Claude Code, Cursor, Copilot, Codex) have no consistent
governance framework for controlling what agents do, ensuring documentation stays current,
or maintaining institutional memory of decisions made during AI-assisted development.

Each tool has its own configuration format, but none provide a portable, composable governance
layer that works across tools and project types. The result: agents operate without contracts,
documentation drifts, architectural and product decisions go unrecorded, and the codebase
accumulates implicit knowledge that only the original developer holds.

---

## Value Proposition

A modular governance framework that any project can adopt — regardless of stack, domain,
or AI tool — to enforce documentation discipline, decision recording (ADRs and PRDs),
operational readiness, and agent trust boundaries. Projects get a portable governance
contract that survives tool switches and team changes.

---

## Users and Personas

| Persona | Role / context | Primary need |
|---------|---------------|-------------|
| Primary | Solo developer or small team using AI assistants | Governance that scales from prototype to production without enterprise overhead |
| Secondary | Team lead onboarding an existing codebase | Brownfield adoption path that doesn't require rewriting existing docs |
| Out of scope | Enterprise compliance teams | Full audit trail automation; the harness provides structure, not compliance tooling |

---

## Why Now

AI coding assistants have reached a capability level where they can make significant
architectural and product decisions during a session. Without governance, these decisions
are invisible — buried in chat logs or lost between sessions. The harness exists because
the need for governance scales with agent capability, not the other way around.

---

## Opportunity Hypothesis

If we provide a modular, self-documenting governance framework for AI-assisted development,
then teams will maintain better decision records, catch documentation drift earlier, and
onboard new contributors (human or AI) faster.

---

## Known Constraints

| Constraint | Source |
|------------|--------|
| Must work without runtime dependencies beyond Ruby and shell | Adoption friction; teams won't install a governance SDK |
| Must be tool-agnostic | Different teams use different AI assistants; lock-in defeats the purpose |
| Must scale down to solo projects | Enterprise-only governance gets skipped by the people who need it most |
