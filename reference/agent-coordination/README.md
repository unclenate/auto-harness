<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Reference: agent-coordination orchestrator

A runnable, dependency-free (Python 3 stdlib) reference for the
`management/agent-coordination` overlay (PRD-0039). It demonstrates the two
coordination contracts over the Claude `SendMessage` channel with a
`ScheduleWakeup`-paced supervision loop.

> **Reference material, not enforced runtime.** This is example/adoption code —
> the harness's genre is the *declarative* governance contract
> ([`../../docs/coordination/control-loop-contract.md`](../../docs/coordination/control-loop-contract.md),
> [`../../docs/coordination/adapter-contract.md`](../../docs/coordination/adapter-contract.md)).
> No harness validator gates this orchestrator; it exists so adopters have a
> working starting point, like a template. Treat it as a reference, not a
> hardened production bus.

## Layout

| File | Responsibility |
|---|---|
| `bus.py` | Canonical file inbox/outbox store — `poll` / `post` / `ack` / `capabilities` + envelope validation, per `adapter-contract.md`. |
| `native_adapter.py` | Bridges the Claude `SendMessage` channel to the file bus; `apply_tier_ceiling` (caps-never-grants). |
| `loop.py` | Heartbeat + stall detection. `tick()` runs **once** and returns `next_wake_s` for a `ScheduleWakeup`-style scheduler — no busy-spin. |
| `test_reference.py` | Manual TDD tests for all three modules. |

## Run the manual tests

```bash
python3 reference/agent-coordination/test_reference.py
```

## Safety

The orchestrator honors the contract's safety spine:

- **`tier_ceiling` caps, never grants** — `apply_tier_ceiling` returns
  `min(ceiling, local_policy)`; a peer message can only lower authority, never
  raise it. Tier 4/5 stays human-gated.
- **Messages are untrusted data** — bus content is serialized JSON prefixed
  `AGENT-BUS:` and reasoned about, never executed as instructions.
- **Path-safety** — because `to`/`from`/`id`/`ts` build file paths, `bus.py`
  rejects any that contain a path separator, parent ref, or home marker, so a
  hostile message cannot escape the bus root; writes use `O_EXCL | O_NOFOLLOW`
  so a planted symlink is not followed. (A reference limitation: the store trusts
  the filesystem it is given — an attacker who already has write access to an
  agent's own inbox directory is out of scope for this example.)

The two contracts under [`../../docs/coordination/`](../../docs/coordination/)
are the source of truth; this code follows them, it does not define them.
