<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0031 — Agent Defense-in-Depth (Microsoft's Four Patterns) (`architectures/agent-defense-in-depth`)

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-25
**Last Updated:** 2026-05-25
**Confidence:** medium-high

---

## Thesis

Microsoft's May 2026 *Defense in depth for autonomous AI agents* blog
names **four mutually-reinforcing patterns** every autonomous agent
should adopt:

1. **Agents as microservices** — scope-contained; one agent, one job;
   each agent writes only to its own cache.
2. **Least permissions** — each agent is granted the minimum capability
   set needed for its task.
3. **Deterministic human-in-the-loop** on consequential actions —
   draft, never auto-execute, anything with material consequence (a
   portal message, a financial transaction, a code merge to main).
4. **Agent identity** — every action is attributable to a named agent.
   *"Identity makes all of it auditable."*

The patterns are *generalizable* — they apply to any autonomous agent
in any domain, regulated or not. Tula adopts all four explicitly:
skills are scope-contained, least-permission (workspace-bounded
caches), human-in-the-loop on portal messages (drafts never auto-sent),
and identity-bound (every action attributable to the named agent).

Auto-harness has no module that captures this surface. OPP-0022
(patient-facing health-agent safety) covers the *healthcare-specific*
slice of pattern #3 (draft-never-send for portal messages); the
broader four-pattern model is unaddressed.

Add **`architectures/agent-defense-in-depth`** — an architectures-
family module declaring a project adopts all four patterns, with
required artifacts:

- `docs/security/agent-defense-in-depth.md` — declares how the
  project realizes each of the four patterns: scope-containment
  evidence (per-skill capability boundaries), permission model
  (what each agent can/cannot do), human-in-the-loop checkpoints
  (which actions are drafts vs. autonomous), and identity-binding
  (how each action is attributed in audit logs).
- `docs/security/append-only-action-log.md` — declares the
  operator-owned audit log shape: append-only, identity-tagged,
  snapshot-able (per Tula's `agent-backup.sh` pattern). This is
  the *audit-substantiation* of pattern #4.

The two artifacts together substantiate the Microsoft defense-in-depth
claim with concrete project-specific evidence — exactly the
*doctrine-in-prose-without-enforcement-in-code* gap the project's
own observations warn against. The artifacts themselves don't ship
enforcement; they ship the *contract* that future validators
(v2 OPP candidate) can check against.

Companion rule: edits to action-execution code require a matching
update to `agent-defense-in-depth.md` if a new action type is
introduced. The four patterns are *promises*; the artifact is the
record of what those promises mean concretely.

Satellite of [OPP-0027](OPP-0027-frontier-agent-posture.md). Composes
with [OPP-0029](OPP-0029-agent-observability.md) (identity-bound
traces are the runtime-emitted half of pattern #4) and
[OPP-0022](OPP-0022-patient-facing-health-agent-safety.md)
(patient-facing safety is a *domain specialization* of patterns #3
and #4 for healthcare consumers).

## Origin / Evidence

- **Tula README § "Defense in depth for autonomous agents":** *"Tula
  implements all four of Microsoft's published patterns for
  autonomous AI agents: skills are scope-contained (one skill, one
  job), least-permission (each skill writes only to its own cache),
  human-in-the-loop on consequential actions (portal-message drafts
  are *drafts*, never auto-sent), and identity-bound (every action
  is attributable to the named agent)."* Direct field evidence.
- **Microsoft's May 2026 [Defense in depth for autonomous AI agents](https://www.microsoft.com/en-us/security/blog/2026/05/14/defense-in-depth-autonomous-ai-agents/)
  is the upstream design source.** External, stable, vendor-published
  pattern set. Catalog-layer adoption now carries low risk; the
  four-pattern model is consolidating across multiple agent vendors.
- **The patterns generalize beyond healthcare.** Any autonomous-
  agent project — code-writing agents, customer-support agents,
  research agents, ops/devops agents — faces the same four risks.
  OPP-0022 covers the healthcare slice; this OPP covers the umbrella.
- **The "append-only action log" sub-pattern is its own primitive.**
  Tula calls out *"All agent actions land in append-only logs the
  operator owns... every change reproducible via `agent-backup.sh`
  snapshots with a regex secret-scan gate."* The log shape is
  generalizable; the secret-scan gate is generalizable; the
  operator-ownership boundary is generalizable. The artifact
  captures these as concrete promises.
- **Auto-harness has no agent-safety primitive at the umbrella
  level.** The trust-tier model (OPP-0006) and the kernel doctrine
  are *governance* surfaces; this is an *agent-architecture*
  surface. They compose: trust-tier says what the agent is *allowed*
  to do; defense-in-depth says how the agent *structures itself* to
  exercise those permissions safely. Both are needed.
- **Adjacency to OPP-0022 (patient-facing-health-agent safety).**
  OPP-0022's draft-never-send, PHI-workspace-boundary, indirect-
  injection-via-ingestion-resistance are *concrete instantiations*
  of patterns #3 (human-in-loop) and #4 (identity-bound audit) for
  healthcare. v1 of this OPP should explicitly note OPP-0022 as a
  *domain specialization* and explain how a healthcare project
  adopts both: defense-in-depth as the umbrella + patient-facing-
  safety as the healthcare-specific overlay.

## Why Now

- **The four-pattern model is published and stable.** Microsoft's
  blog is the canonical reference; the patterns are not vendor-
  internal moving targets.
- **Tula is the first consumer to surface all four patterns
  explicitly.** First-pass Tula filings caught only the healthcare-
  specific slice (OPP-0022); second-pass surfaces the umbrella.
- **The agent-pack catalog is mature enough to compose against
  this.** Eight agent packs (claude-code, cursor, codex-cli,
  copilot-cli, gemini-cli, generic-llm, openclaw, base) means any
  consumer adopting this module can pair it with its agent runtime
  of choice; no agent-pack gap blocks adoption.
- **The eval-gated-testing module (OPP-0019) covers eval *outcomes*;
  this module covers the *structural prerequisites* for safe agent
  behavior.** They compose: defense-in-depth declares the
  agent-shape commitment, eval-gated-testing verifies the agent
  meets the contract on every PR.

## Risks / Open Questions

1. **Single artifact or four artifacts (one per pattern)?** Bias:
   single artifact (`agent-defense-in-depth.md`) with four named
   sections at v1. Avoids the "consumer scaffolds four files, fills
   only one" failure mode; preserves the unity of the four-pattern
   model. PRD-pass can revisit.
2. **Should the four patterns be *enforced* by validators in v1?**
   Bias: no. v1 ships the *contract* — the artifact declares the
   commitments. v2 (a future OPP) can ship pattern-specific
   validators (e.g., a least-permissions checker that cross-
   references action code against the declared permission set).
   Same principle as OPP-0006 trust-tier-enforcement: declare first,
   enforce later.
3. **How does this interact with the trust-tier model
   (OPP-0006)?** They are orthogonal but composable. Trust-tier
   says *what the agent is allowed to do*. Defense-in-depth says
   *how the agent's structure prevents misuse of those
   permissions*. A Tier-3 agent and a Tier-4 agent can both adopt
   defense-in-depth; the patterns are tier-independent. PRD-pass
   should explicitly note the separation (mirror of OPP-0027's
   Open Question 7).
4. **What about non-autonomous AI products (a copilot that only
   ever drafts and never autonomously acts)?** Bias: the module
   is opt-in; a non-autonomous product can declare pattern #3
   (human-in-loop) as trivially satisfied (everything is a draft)
   and ignore the rest. PRD-pass should make this explicit.
5. **The "append-only action log" artifact: required or optional
   in v1?** Bias: required when the project declares any
   autonomous (non-draft) action; optional otherwise. Action logs
   are the *audit-substantiation* of pattern #4 — without them,
   pattern #4 is prose without enforcement.
6. **How does this compose with OPP-0022 (patient-facing health-
   agent safety) in healthcare projects?** v1 should explicitly
   describe the composition: a healthcare patient-agent adopts both
   modules; OPP-0031 covers the umbrella four patterns, OPP-0022
   covers the healthcare-specific instantiations (draft-never-send
   on portal messages, PHI workspace boundary, indirect-injection-
   via-ingestion resistance). Same composition shape as `architectures/
   web-app` + `delivery/production-saas`.
7. **Cross-reference to the Tula sender-allowlist transport-layer
   gate.** Tula's *"email router locks inbound mail to a sender
   allowlist at the **Exchange transport layer** before any model
   ever sees it"* is a *defense-before-LLM* pattern — adjacent to
   defense-in-depth's least-permissions pattern but distinct (it's
   a *pre-input* sanitization, not a *during-action* permission
   check). v1 should *name* the pattern as a related concept; a
   future OPP could capture it as a reusable
   `templates/security/pre-llm-transport-gate.md`.

## Disposition

<!--
Empty while Status: proposed. Satellite of OPP-0027.
-->

## Promotion

<!--
Empty until accepted. Anchor: OPP-0027.
-->
