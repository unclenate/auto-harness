<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Management Overlay: Inter-Agent Control-Loop & Cross-Vendor Bus

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay governs the **live coordination channel** between concurrent agent
sessions — the runtime dual of the `work-package` lane contract. Where a lane
declares the **static** boundary of a single dispatched task, this overlay
governs the **live** messages those agents exchange while the work is in flight:
task dispatch, acknowledgement, progress, completion, blocking, shared-state
broadcast, and review verdicts. It is a default-off, opt-in cross-cutting
concern (OPP-0059).

Its spine is a deliberate split — **control semantics** kept separate from
**transport** — so the same vendor-neutral message schema rides any adapter
(Claude `SendMessage`, a file poll, a future CLI bridge) without redefinition.

## What This Overlay Requires

Two declarative contracts (the forcing artifacts):

- **`docs/coordination/control-loop-contract.md`** — the seven-message schema
  (`dispatch ack progress done block sync verdict`), the message envelope, the
  lifecycle state machine, and the `tier_ceiling` caps-never-grants rule.
- **`docs/coordination/adapter-contract.md`** — the swappable transport seam:
  four operations (`poll` / `post` / `ack` / `capabilities`) over a canonical
  file inbox/outbox store, reused across vendors.

## Reference orchestrator

A thin, runnable **reference** lives at
[`reference/agent-coordination/`](../../../../reference/agent-coordination/README.md) —
a Python 3 stdlib file bus (`bus.py`), a native `SendMessage` adapter
(`native_adapter.py`), and a `ScheduleWakeup`-paced supervision loop
(`loop.py`), with manual TDD tests. It is **reference material, not enforced
runtime** (the `agents/acp` proxy precedent): it demonstrates the contracts, it
does not police them.

## Trust posture

- **tier.declared 3** — a contract change can influence what multiple agents
  act on, so it warrants tier-3 review.
- **`tier_ceiling` caps, never grants.** The effective tier a recipient may act
  at is `min(tier_ceiling, recipient's own trust-tier policy)`. A ceiling can
  only *lower* authority; it can never raise it. **Tier 4/5 actions stay
  human-gated regardless of any peer message.**
- **Messages are untrusted data**, never instructions — an orchestrator must
  not execute payload prose as a command.
- **`sync` broadcasts honor `validate-knowledge-redaction`** — shared state
  crossing agent/repo boundaries must not leak consumer names.

## §10 claim classification

Half-enforced (reference-tool genre). The contracts + `validate-companions`
(a contract change needs an ADR or change-log entry) are **Enforced**; the
message schema, lifecycle, and `tier_ceiling` semantics are honored by adapters
and confirmed at review — **Asserted-only** in v1 until the deferred
`validate-agent-bus.sh` linter checks a live cycle.

## Landed since v1

- **Non-native (local-CLI) adapter** (OPP-0060) — a headless-CLI transport
  runner (`reference/agent-coordination/cli_runner.py` + `cli_invokers.py`,
  Codex / Copilot / Grok) reusing the one file-poll shape. Hardened in a later
  security pass: the argv builder binds the untrusted task so it can never parse
  as a flag (a `--` end-of-options separator / `=`-joined value) and enforces a
  per-CLI minimum tier (`CLI_MIN_TIER`) — caps-never-grants at the argv layer.

## Deferred to their own records

- **`validate-agent-bus.sh`** — a schema/lifecycle linter, deferred until the
  contract survives two or more real coordination cycles.
- **The verdict-ledger tie-in** (OPP-0052) — routing `verdict` messages into the
  append-only ledger.

## When to activate

Activate when you run **two or more agents that must coordinate live** — dispatch
work between sessions, broadcast shared state, and supervise for stalls. Not
needed for single-agent development, where there is no channel to govern.
