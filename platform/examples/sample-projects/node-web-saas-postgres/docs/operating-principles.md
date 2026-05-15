<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Operating Principles

**Owner:** @platform-team
**Last updated:** 2024-01-15

These principles govern how the platform team makes decisions, resolves disagreements, and
maintains the harness. They apply to both human contributors and AI agents working on this project.

---

## Decision-Making

**Scope changes require a change-log entry or ADR.** Any decision that changes what the platform
does, what modules it ships, or what governance it enforces must be recorded — either as a
change-log entry (for smaller decisions) or an ADR (for architectural choices). Silent scope
changes are not permitted.

**Evidence over opinion.** Design decisions must be grounded in observable facts about how teams
use governance tooling — not theoretical ideals. If a module's required artifacts are never
actually filled in by governed projects, that is evidence the artifact requirement should be
reconsidered.

**Conservative defaults, opt-in depth.** The platform defaults to the minimum governance that is
useful. Additional ceremony (program-lite, testing-standard, web3 domain) is opt-in via the
manifest. Do not add required artifacts to the base kernel without strong justification.

---

## Ownership

**Ownership is explicit.** Every artifact has an owner recorded in its header. An artifact without
an owner is a governance gap — assign one before merging.

**The release owner is accountable end-to-end.** The person listed as release owner on the release
checklist is accountable for the release outcome, including rollback decisions. This is not a
collective responsibility.

---

## AI Agent Behavior

**Documentation is part of the change.** AI agents may not merge a PR that changes governance
behavior (modules, validators, templates) without updating the relevant documentation in the same
PR. Code and docs ship together.

**Sensitive delivery changes require human review.** Any change to validators, module.yaml files,
or governance compiled fragments is a Tier 4 action — it requires a human approver before merge.
AI agents propose; humans decide.

**Agents do not self-elevate.** An AI agent may not grant itself additional trust tier permissions,
modify AGENTS.md to expand its own scope, or bypass companion rule requirements. These are always
Tier 5 actions requiring explicit human authorization.

---

## Escalation Path

Disagreements about governance decisions: raise in the team's primary communication channel with
a clear proposal and the evidence behind it. If unresolved after one discussion cycle, the
platform-team lead makes the call and records it as an ADR.

Security concerns: flag immediately to @platform-team; do not merge until resolved.
