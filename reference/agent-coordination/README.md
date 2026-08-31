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
| `test_reference.py` | Manual TDD tests for the native store/adapter/loop. |
| `cli_runner.py` | **Non-native adapter** — drives a local CLI agent (Codex/Copilot/Grok) as a headless process, one invocation per dispatch: poll → `ack` → apply `tier_ceiling` → invoke the CLI with the task as data → `done`/`block`. Tier ≥4 auto-blocks; `tick()` returns `next_wake_s` (no busy-spin). |
| `cli_invokers.py` | `build_argv(cli, task, effective_tier, cwd, model)` — per-vendor headless argv; a defense-in-depth second gate that refuses any Tier ≥4 or sandbox-bypass command; task is a single un-shell-interpreted arg. |
| `test_cli_runner.py`, `test_cli_invokers.py` | Manual TDD tests for the non-native adapter (fake invoker, zero external calls). |
| `smoke_live.py` | The one place a real external CLI is spawned — **manual, human-authorized** (`python3 smoke_live.py [codex\|grok\|copilot] [model]`). Not a unit test. |

## Run the manual tests

```bash
cd reference/agent-coordination
python3 test_reference.py         # native store/adapter/loop (19)
python3 test_cli_runner.py        # non-native runner (9)
python3 test_cli_invokers.py      # non-native argv builder (12)
```

## Non-native (local-CLI) adapter

`cli_runner.py` + `cli_invokers.py` demonstrate the piece PRD-0039 / OPP-0059 defers — a **non-native**
adapter for a headless local CLI (Codex/Copilot/Grok), driven as a process *per dispatch* rather than a
polling session. It reuses the frozen `bus.py` store + `native_adapter.apply_tier_ceiling` verbatim (no
contract change) and honors the same spine: `tier_ceiling` caps-never-grants, Tier 4/5 auto-blocks to the
human gate, task-as-untrusted-data, and a `build_argv` **second gate** that refuses to construct any Tier
≥4 or sandbox-bypass command. See the non-native section of
[`../../docs/coordination/adapter-contract.md`](../../docs/coordination/adapter-contract.md) for the
governed constraints (OPP-0060).

**Verified CLI matrix (headless `--help`, 2026-08-31):**

The untrusted `task` is bound so it can **never be parsed as a flag**: codex places it after a `--`
end-of-options separator; grok and copilot pass it as one `=`-joined value. (Without this a leading-dash
task like `--dangerously-bypass-approvals-and-sandbox` would re-open the sandbox beneath the tier gate.)

- **Codex** — `codex exec -s <read-only|workspace-write> --skip-git-repo-check -- "task"`; sandbox maps
  ~1:1 to trust tiers (cleanest). Live: loop proven; a successful `done` needs a model the operator's
  account permits (set `SMOKE_MODEL`).
- **Grok** — `grok --single="task" [--always-approve]`. Live: **PASS** — full
  `dispatch→ack→done{result:"4"}` round-trip through the file bus.
- **Copilot** — `copilot --prompt="task" --allow-all-tools`; non-interactive **forces**
  `--allow-all-tools`, so there is no true read-only headless tier. `build_argv` therefore **refuses** a
  copilot dispatch below tier 2 (`CLI_MIN_TIER`) rather than run it over-permissioned — caps-never-grants
  enforced in code, not merely declared.
- **Antigravity** — no headless CLI (IDE-only); reach is bounded by the vendor's headless surface.

## Safety

The orchestrator honors the contract's safety spine:

- **`tier_ceiling` caps, never grants** — `apply_tier_ceiling` returns
  `min(ceiling, local_policy)`; a peer message can only lower authority, never
  raise it. Tier 4/5 stays human-gated.
- **Messages are untrusted data** — bus content is serialized JSON prefixed
  `AGENT-BUS:` and reasoned about, never executed as instructions.
- **Path-safety** — because `to`/`from`/`id`/`ts` build file paths, `bus.py`
  rejects any that contain a path separator, parent ref, home marker, or control
  character, so a hostile message cannot escape the bus root; leaf writes use
  `O_EXCL | O_NOFOLLOW` and a symlinked agent/inbox/outbox **directory** is
  refused with a containment check (a leaf-file guard alone does not cover a
  symlinked directory component). Filenames are collision-safe so a same-second
  message is never silently clobbered, and `poll` re-validates each file,
  quarantining a malformed one to `.rejected` rather than crashing the tick.
  (A stated design property, not a defect: there is no cryptographic sender
  authentication — a local file bus trusts the filesystem's own access control
  and each runner's `local_tier`; cross-machine auth is an adapter's job.)

The two contracts under `docs/coordination/` are the source of truth — the
[control-loop contract](../../docs/coordination/control-loop-contract.md) and the
[adapter contract](../../docs/coordination/adapter-contract.md); this code follows
them, it does not define them.
