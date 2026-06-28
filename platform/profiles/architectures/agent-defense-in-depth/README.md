<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Architecture Overlay: Agent Defense-in-Depth

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay governs how an autonomous-agent project declares it adopts **Microsoft's
four mutually-reinforcing defense-in-depth patterns** for autonomous AI agents — and
records what each pattern means *concretely* for the project, rather than as doctrine in
prose. The four patterns:

1. **Agents as microservices** — scope-contained; one agent, one job; each writes only
   to its own cache.
2. **Least permissions** — each agent granted the minimum capability set for its task.
3. **Deterministic human-in-the-loop** on consequential actions — draft, never
   auto-execute, anything with material consequence (a portal message, a financial
   transaction, a code merge to main).
4. **Agent identity** — every action attributable to a named agent. *Identity makes all
   of it auditable.*

The patterns **generalize** — they apply to any autonomous agent in any domain (code,
support, research, ops), regulated or not. This is an *agent-architecture* surface,
distinct from the *governance* surfaces (trust-tier, kernel doctrine): trust-tier says
what the agent is *allowed* to do; defense-in-depth says how the agent *structures
itself* to exercise those permissions safely.

It is **opt-in** (add `agent-defense-in-depth` to your `harness.manifest.yaml`) and
composes with any `agents/*` pack. auto-harness itself does not activate it.

---

## What this overlay requires

- **`docs/security/agent-defense-in-depth.md`** (required, scaffolded from the
  [agent-defense-in-depth](../../../templates/security/agent-defense-in-depth.md)
  template) — a **single artifact with four named sections**, one per pattern, each with
  an evidence prompt: scope-containment (per-agent capability boundaries), the permission
  model (what each agent can / cannot do), human-in-the-loop checkpoints (which actions
  are drafts vs. autonomous), and identity-binding (how each action is attributed in
  audit logs). One artifact (not four) preserves the unity of the four-pattern model and
  avoids the scaffold-four-fill-one failure.
- **`docs/security/append-only-action-log.md`** (optional in the schema, but
  **required-by-convention when the project declares any autonomous, non-draft action** —
  enforced as a review gate) — scaffolded from the
  [append-only-action-log](../../../templates/security/append-only-action-log.md)
  template. It declares the operator-owned audit-log shape: append-only, identity-tagged,
  snapshot-able, with a secret-scan gate. This is the **audit-substantiation of pattern
  #4** — without it, pattern #4 is prose without enforcement. A non-autonomous product
  (one that only ever drafts) may treat the action log as not-applicable.

## How this overlay composes

- **With `architectures/agent-observability`** — identity-bound traces are the
  runtime-emitted half of pattern #4; the trace contract and the defense-in-depth
  identity section describe the same attribution from two angles.
- **With the OPP-0006 trust-tier model** — orthogonal but composable. Trust-tier = what
  the agent may do; defense-in-depth = how it structures itself to do it safely.
  Tier-independent; a Tier-3 and a Tier-4 agent can both adopt the four patterns.
- **With healthcare (`domains/healthcare-*` + OPP-0022 patient-facing safety)** — a
  healthcare patient-agent adopts **both**: this overlay as the umbrella four-pattern
  model, and the patient-facing-safety surface as the healthcare-specific instantiation
  (draft-never-send on portal messages, PHI workspace boundary, indirect-injection
  resistance). Same composition shape as `architectures/web-app` + `delivery/production-saas`.

## Related-but-distinct: the pre-LLM transport gate

Locking inbound input (e.g. mail) to a sender allowlist at the transport layer *before
any model sees it* is a **defense-before-LLM** pattern — adjacent to least-permissions
but distinct (pre-input sanitization, not a during-action permission check). It is
**named** here as a related concept; capturing it as a reusable
`templates/security/pre-llm-transport-gate.md` is a future OPP, out of scope for v1.

## v1 is declarative — enforcement is deferred

v1 establishes *what the four-pattern commitment is*. It ships **no companion rule and no
validator** — like its `agent-observability` / `ai-foundry-target` / `intelligent-model-routing`
siblings. Pattern-specific validators (e.g. a least-permissions checker cross-referencing
action code against the declared permission set) and a companion rule binding
action-execution changes to the artifact are the **v2 follow-up** (a future OPP). Declare
first, enforce later — the same principle as the OPP-0006 trust-tier model.

## Agent behavior

Agents working in a project with this overlay active treat `agent-defense-in-depth.md` as
the source of truth for the project's agent-safety structure: keep the four sections
honest and concrete, route consequential actions through the declared human-in-the-loop
checkpoints (draft, never auto-execute), and append every action to the operator-owned
log with its identity attribution.

## See also

- [`module.yaml`](module.yaml) — the module contract.
- [`templates/security/agent-defense-in-depth.md`](../../../templates/security/agent-defense-in-depth.md),
  [`append-only-action-log.md`](../../../templates/security/append-only-action-log.md) — the starters.
- Sibling: [`architectures/agent-observability`](../agent-observability/README.md) — the
  trace contract whose identity attribution is the runtime half of pattern #4.
- Upstream: Microsoft's *Defense in depth for autonomous AI agents* (the four-pattern source).
