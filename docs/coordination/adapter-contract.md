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

## Non-native (local-CLI) adapters

The native adapter bridges a Claude session that **polls its own inbox and runs a session**. A **local
CLI** agent (Codex, Copilot, Grok, …) is a different shape: a **headless process invoked *per dispatch***,
not a long-lived poller. A non-native adapter therefore runs a **runner** that, per pending dispatch:
posts `ack` → applies `tier_ceiling` (caps-never-grants) → invokes the CLI **headlessly with the task as
a single un-shell-interpreted argument** (`shell=False`; the task is untrusted data, never executed by the
runner) → posts `done{result}` on success or `block{reason}` on failure → `ack`s the dispatch out of the
inbox. **A dispatch whose effective tier is ≥4 is auto-blocked** (the human gate), never invoked. The
argv builder is a **defense-in-depth second gate**: it refuses to construct any Tier ≥4 or sandbox-bypass
command, so even a mis-capped dispatch cannot become a full-access CLI spawn. The gate also closes the
**argv layer**: the untrusted `task` is bound so it can never separate into its own flag token (codex
after a `--` end-of-options separator; grok/copilot as one `=`-joined value). Without this, a leading-dash
task (`--dangerously-bypass-approvals-and-sandbox`) parses as an *option* and re-opens the sandbox beneath
the tier check, which inspects only the tier number — never the task string.

Three constraints every non-native adapter MUST honor (verified against real CLIs, OPP-0060):

1. **Vendor headless modes are asymmetric on trust tier — declare the gap, never silently over-permit.**
   A vendor's headless flags do not map uniformly onto the six trust tiers. Codex maps ~1:1 (`-s
   read-only` / `-s workspace-write`). **Copilot's non-interactive mode *forces* broad tool permission
   (`--allow-all-tools`) — there is no true read-only headless tier.** An adapter that cannot honor a
   `tier_ceiling` (here, a read-only cap) MUST **declare the gap via `capabilities`** — the same rule the
   "Degraded modes" section below states for a missing message type — and the consumer runs such an
   adapter only at a deliberately low `local_tier` in a scoped working directory. Silently accepting a
   read-only dispatch on a CLI that will auto-approve every tool is a caps-never-grants violation at the
   transport layer. The reference goes one step further and **refuses to construct** such a dispatch: its
   argv builder declares a per-CLI minimum tier (`CLI_MIN_TIER`, copilot ≥ 2) and raises below it, so the
   floor is enforced in code rather than resting on the operator's `local_tier` choice alone.
2. **Reach is bounded by the vendor's headless surface.** No headless CLI → no adapter (e.g. an IDE-only
   vendor). Cross-vendor reach is a function of what each vendor exposes headlessly, not of the contract;
   the contract governs the *shape* of participation, not its *availability*.
3. **Model / account selection is operator configuration, not adapter logic.** Pass the model per-call
   (e.g. Codex `-c model=…`), never bake it into the adapter, and let an account/model failure surface as
   a **`block`** (never swallowed). A restricted account rejecting a model is an operator-environment
   condition the adapter reports honestly — not an adapter defect.

**Reference:** `reference/agent-coordination/cli_runner.py` (`CLIRunner`) + `cli_invokers.py`
(`build_argv`) demonstrate this over the frozen store — reference material, not enforced runtime. Vendors
(`bus.py` / `native_adapter.py` / `loop.py`) are reused verbatim; a non-native adapter is two small stdlib
files, no contract change.

## Degraded modes

- An adapter that cannot carry a given message type declares the gap via
  `capabilities` — it **never silently drops** a message.
- A recipient that cannot honor a `tier_ceiling` (it has no local tier policy)
  MUST treat the effective tier as the **most restrictive**, not ignore the
  ceiling. Absence of a policy is never a licence to act unbounded.
