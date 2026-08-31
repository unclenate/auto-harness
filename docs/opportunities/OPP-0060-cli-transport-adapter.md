<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0060 — Non-Native (Local-CLI) Transport Adapter for the Agent-Coordination Bus

**Status:** proposed *(field-reported with a working, live-validated prototype; independently re-verified before filing — integration-smoke-tested against the frozen bus, redaction re-scrubbed)*
**Owner:** @unclenate · **Created/Updated:** 2026-08-31
**Confidence:** high (design + live proof: a real non-Claude CLI completed a full bus round-trip)
**Parent:** PRD-0039 / management/agent-coordination (promotes OPP-0059)

## Thesis

PRD-0039 shipped the overlay: the two coordination contracts + a native-bus reference adapter (Claude
SendMessage). Its module summary explicitly defers "non-native CLI adapters to their own records." This
OPP is that record. It delivers the deferred piece: a local-CLI transport runner that lets a headless CLI
agent (Codex, Copilot, Grok, …) participate in the bus. A native agent polls its own inbox and runs a
session; a local CLI is instead a headless process invoked per dispatch. The runner bridges that gap over
the FROZEN store and contracts — no contract change — and has been validated live: a real non-Claude CLI
completed a full dispatch→ack→done round-trip.

## Design (reference prototype)

Two new modules atop the vendored, unmodified `bus.py`/`native_adapter.py`/`loop.py`:

- **CLIRunner** — one heartbeat (mirrors `loop.py`: `tick()` returns `next_wake_s`, never busy-spins). Per
  pending dispatch: post `ack` → apply `tier_ceiling` (reuses `native_adapter.apply_tier_ceiling`,
  caps-never-grants) → invoke the CLI headlessly with the task as DATA → post `done{result}` on exit 0 or
  `block{reason}` on failure → `ack` the dispatch out of the inbox. A dispatch whose effective tier is ≥4
  is auto-blocked (human gate), never invoked.
- **build_argv(cli, task, effective_tier, cwd, model)** — maps the already-capped effective tier onto each
  vendor's headless invocation. A defense-in-depth second gate: refuses to construct any Tier ≥4 or
  sandbox-bypass command, and emits the task as a single, un-shell-interpreted argument (spawned
  `shell=False`).

The task never reaches a shell and is never executed by the runner — the injected invoker is the sole
execution path (the contract's untrusted-data rule, enforced in code).

## Verified CLI matrix (headless invocation, real machines, 2026-08-31)

- **Grok:** `grok -p "task"` (+ `--always-approve` above read-only). ✅ clean; live round-trip PASS.
- **Codex:** `codex exec -s <read-only|workspace-write> --skip-git-repo-check "task"`. ✅ sandbox maps ~1:1
  to trust tiers (best); needs `--skip-git-repo-check` in a non-git workdir + closed stdin + a per-call
  `-c model=`.
- **Copilot:** `copilot -p "task" --allow-all-tools`. 🟡 non-interactive FORCES broad tool permission — no
  true read-only headless tier.
- **Antigravity:** — ❌ no headless CLI found (IDE-only).

## Live validation

- **Grok ✅ PASS:** `grok -p "What is 2+2?…"` → dispatch→ack→done{result:"4"} end-to-end through the file bus.
- **Codex — loop proven, model-blocked:** the runner spawned Codex with the correct argv, captured its real
  output/exit, and posted a `block`. A successful result was blocked by an operator-environment condition,
  not the adapter: a Codex ChatGPT-account login rejected both the config default and the codex-tuned model
  ("model not supported when using Codex with a ChatGPT account"). Model selection is therefore an
  operator/account concern, surfaced by the adapter rather than swallowed.

## Findings worth encoding

1. Vendor headless modes are asymmetric on trust tier. Codex maps trust tiers onto its `-s` sandbox ~1:1;
   Copilot's headless mode REQUIRES auto-approving all tools, so it cannot honor a read-only cap — a
   contract-vs-vendor gap the adapter contract should acknowledge (declare via `capabilities`, never
   silently over-permit).
2. Reach is bounded by what a vendor exposes headlessly. No CLI → no adapter (Antigravity). Cross-vendor
   reach is a function of vendor headless surfaces, not of the contract.
3. Model/account selection is operator config, not adapter logic. Pass per-call (`-c model=`), never bake
   it in; let failure surface as a `block`.

## Trust & safety posture (inherited + hardened)

- Inherits the spine verbatim: `tier_ceiling` caps-never-grants; Tier 4/5 human-gated regardless of any
  peer message; messages are untrusted data.
- Adds a second gate in `build_argv`: even a mis-capped dispatch cannot become an env-altering /
  sandbox-bypass invocation — a peer message can never become a full-access CLI spawn.
- Reuses the frozen store's path-safety (`O_EXCL|O_NOFOLLOW`, traversal guards) unchanged.

## Neighbors

- PRD-0039 / OPP-0059 — parent; fills its deferred non-native-adapter slot with no contract change.
- OPP-0052 — a `done`/`block`/`verdict` record can feed the same verdict ledger.
- `agents/grok-cli` agent-pack (parked) — complementary: agent-pack = an agent's identity/permissions;
  this = how that agent plugs into the bus. Grok being the first proven adapter is a natural convergence
  point.
- `validate-agent-bus.sh` (still deferred upstream) — a machine gate for the schema; unaffected.

## Recommended path

Promote the CLIRunner + build_argv shape as the reference non-native adapter, ported into
`reference/agent-coordination/` alongside the native adapter (it already vendors the store verbatim; the
diff is two small stdlib files + tests). Land Grok first (proven), Codex once the operator supplies an
account-supported model, Copilot behind an explicit `capabilities` declaration of its read-only gap. Keep
Antigravity out until a headless surface exists.

## Provenance

Field-reported 2026-08-31 by a coordinator session in a live multi-agent consumer deployment (a governed
multi-repo workspace running the harness), with a working prototype developed test-first (unit suites use
a fake invoker — no external calls — and pass alongside the upstream store's own regression tests) and one
human-authorized live round-trip per named CLI. Portable reference (stdlib Python, no deployment-private
data) available to port on request.

## Disposition

**Proposed (filed 2026-08-31).** Field-reported by the OPP-0059 field-reporter session with a
live-validated prototype, and **independently re-verified before filing** in the maintainer session:
integration-smoke-tested against main's frozen `bus.py`/`native_adapter.py` (round-trip + Tier-4
auto-block + `build_argv` second-gate + task-as-data all correct), API-compatible (no contract change),
number deconflicted (0060 next-free), and redaction re-scrubbed clean. This is half-day-scoped and may
ship directly (no PRD): the **implementation follow-on** ports `cli_runner.py` + `cli_invokers.py` into
`reference/agent-coordination/` alongside the native adapter, adds a "non-native adapters" section to
`docs/coordination/adapter-contract.md` (encoding the three findings — especially the copilot
`--allow-all-tools` read-only gap → declared via `capabilities`), and re-runs the prototype's own test
suites (relayed on greenlight) alongside the 19 upstream regression tests before landing. Land Grok first
(proven), Codex once the operator supplies an account-supported model, Copilot behind an explicit
`capabilities` declaration of its read-only gap; keep Antigravity out until a headless surface exists.

## Promotion

*(none yet — proposed. Implementation is a direct half-day port, no PRD anticipated; the adapter-contract
amendment is the governance artifact.)*
