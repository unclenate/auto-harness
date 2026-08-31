<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Transport-Adapter Contract

A **transport adapter** is the swappable seam that carries
[control-loop](control-loop-contract.md) messages to and from a given agent.
The control-loop contract defines *what* a message is (its seven types and
envelope); this contract defines *how* one moves — one shape, reused across
vendors (Claude `SendMessage`, a file poll, a future CLI bridge), so the control
semantics never have to be redefined per transport.

## Operations

Every adapter implements exactly four operations:

| Operation | Signature | Behavior |
|---|---|---|
| `poll` | `poll(agent_id) → [messages]` | Read and return pending inbound messages for `agent_id`, **oldest first**. |
| `post` | `post(message) → None` | Write an outbound message to its recipient's inbox (`message.to`). |
| `ack` | `ack(agent_id, message_id) → None` | Mark a polled message consumed so a later `poll` no longer returns it. Matches the exact `message_id` (the envelope `id`), never a filename fragment. |
| `capabilities` | `capabilities(agent_id) → {types, modes}` | Declare which message types and transport modes the adapter supports. |

## Canonical file store

The reference transport is a local directory tree — one JSON file per message:

```text
.coordination/bus/
  <agent_id>/
    inbox/                 # messages addressed TO this agent
      <ts>-<id>-<type>.json
      .acked/              # consumed messages (audit trail; ack MOVES here, never deletes)
    outbox/                # messages this agent produced FOR remote peers
      <ts>-<id>-<type>.json
      .sent/               # bridged-out messages (durable dispatcher log)
```

- **One message per file**, named `<ts>-<id>-<type>.json` (the sort key is the
  filename, which is why `poll` returns oldest-first by `ts`).
- **Atomic write:** write `<name>.tmp`, then `os.replace` it to `<name>.json`.
  A partial file is never observable by a concurrent `poll`.
- **`ack` moves, never deletes:** a consumed inbox file is moved to
  `inbox/.acked/`, preserving an audit trail.
- **Runtime, not governed.** `.coordination/` is ephemeral runtime state
  (gitignored); the governed artifacts are the two contracts under
  `docs/coordination/`.

## permissionScope mirroring

An adapter MUST NOT `post` a message whose dispatched action would exceed its
own declared permission scope. The store root's permission set is the **ceiling**
for what may be posted into it — mirroring the `tier_ceiling` rule at the
transport layer: a transport can narrow reach, never widen it.

## Poll vs drive

Two interaction shapes:

- **Poll** — the agent asks for its own inbound mail on its own cadence. This is
  the reference loop's default and the v1 shape.
- **Drive** — an orchestrator writes to an agent's inbox and pings it to look.

Both use the same four operations; they differ only in who initiates the read.
v1 reference uses poll.

## Degraded modes

- An adapter that cannot carry a given message type declares the gap via
  `capabilities` — it **never silently drops** a message.
- A recipient that cannot honor a `tier_ceiling` (it has no local tier policy)
  MUST treat the effective tier as the **most restrictive**, not ignore the
  ceiling. Absence of a policy is never a licence to act unbounded.
