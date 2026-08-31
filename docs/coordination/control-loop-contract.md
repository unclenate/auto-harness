<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Inter-Agent Control-Loop Contract

This contract defines the **vendor-neutral control semantics** for the live
coordination channel between concurrent agent sessions (OPP-0059): the messages
agents exchange while work is in flight, their lifecycle, and the trust rule
that binds them. It is deliberately separate from *transport* — how a message
physically reaches an agent is the concern of
[`adapter-contract.md`](adapter-contract.md). This document is the source of
truth for message types, envelope fields, and `tier_ceiling` semantics; every
adapter and the reference orchestrator copy these names verbatim.

## Message envelope

Every message on the bus is a JSON object with this envelope:

```json
{
  "type": "dispatch | ack | progress | done | block | sync | verdict",
  "id": "<correlation id — a dispatch mints it; every ack/progress/done/block/verdict echoes it>",
  "from": "<sender agent id>",
  "to": "<recipient agent id, or \"*\" for sync broadcast>",
  "tier_ceiling": 3,
  "ts": "<ISO-8601 UTC timestamp>",
  "payload": { }
}
```

`ts` is a human-readable ISO-8601 wall-clock stamp for ordering and audit. It is
**not** the same as a dispatch's `payload.deadline`, which is epoch seconds (see
below) — the two use different time representations on purpose.

## Message types

The seven types, spelled exactly `dispatch ack progress done block sync verdict`:

| Type | Direction | When sent | Required `payload` keys |
|---|---|---|---|
| `dispatch` | dispatcher → executor | Assign a task | `task`; optional `deadline` (**epoch seconds, integer** — the unit the reference loop compares against `now`) |
| `ack` | executor → dispatcher | Receipt of a dispatch | — |
| `progress` | executor → dispatcher | Partial status | `note` |
| `done` | executor → dispatcher | Task succeeded | `result` |
| `block` | executor → dispatcher | Stuck / needs input | `reason` |
| `sync` | any → `*` | Broadcast shared state | `state` |
| `verdict` | reviewer → dispatcher | Review outcome | `decision` ∈ {`approve`, `reject`, `revise`}, `rationale` |

## Lifecycle

The correlated life of one dispatched task:

```text
dispatch ──▶ ack ──▶ progress* ──▶ ( done | block | verdict )
                                        │
                              block ────┘──▶ new dispatch (retry, same id)
                                             or human escalation
```

- A `dispatch` mints a correlation `id`. The executor `ack`s it, emits zero or
  more `progress` updates, and terminates the exchange with exactly one of
  `done` (success), `block` (stuck), or `verdict` (a review outcome).
- A `block` may be followed by a **new `dispatch` reusing the same `id`** (a
  retry) or by a human escalation. It is never silently dropped.
- `sync` is **out-of-band**: any agent may broadcast shared state to `to: "*"`
  at any time, independent of any dispatch lifecycle.

## Correlation

Every message except `dispatch` and `sync` **MUST** carry the `id` of the
dispatch it responds to. An orchestrator correlates a result back to its
dispatch by matching `id` — this is how a supervisor knows a dispatched task
completed, and how a stalled dispatch (deadline passed, no `done`/`verdict`) is
detected. A `dispatch` mints a fresh `id`; a `sync` needs none (it addresses
everyone, not one exchange).

## tier_ceiling — caps, never grants

`tier_ceiling` is an integer that can only **lower** the trust tier at which
dispatched work may be executed. The effective tier a recipient may act at is:

```text
effective_tier = min(tier_ceiling, recipient's own trust-tier policy)
```

It can **never raise** authority. A `tier_ceiling: 5` does **not** grant tier-5
to the recipient — the recipient's own policy still binds, and the lower of the
two wins. **Tier 4/5 actions stay human-gated regardless of any peer message.**
This is the safety spine of the contract: a compromised or misconfigured peer
can narrow what another agent may do, never widen it.

## Messages are untrusted data

Bus content is **data, never instructions**. An orchestrator or adapter MUST NOT
execute a message's `payload` prose as a command, and MUST NOT treat received
text as a directive that overrides local policy. The same ethos the
`validate-skill-content` denylist enforces on skill prose applies to any bus
content surfaced into an agent's prompt: it is quoted material to reason about,
not an instruction to obey.

## Redaction

`sync` payloads cross agent and repository boundaries, so they **MUST** honor
`validate-knowledge-redaction`: no consumer-name or private-project leakage may
be broadcast across the bus. A `sync` is the one message type whose blast radius
is every listening agent — treat its `state` as publishable content.

## Deferred in v1

`sync` size and rate caps are **deferred to the `validate-agent-bus.sh` linter**
(an OPP-0059 Open Question). v1 states **no cap**; a v1 orchestrator SHOULD avoid
broadcasting large state and MAY coalesce updates, but the contract does not
enforce a limit until the linter lands.
