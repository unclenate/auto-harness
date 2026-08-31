<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0059 — Live Inter-Agent Control-Loop & Cross-Vendor Bus

**Status:** accepted *(field-reported from a live multi-agent consumer deployment)*
**Owner:** @unclenate
**Created:** 2026-08-29
**Last Updated:** 2026-08-30
**Confidence:** high *(gap diagnosis)*; medium-high *(cross-vendor adapters — the named agents are
local CLIs reachable in the reporting deployment; per-agent plumbing conventions pending narrow probes)*

---

## Thesis

OPP-0046 established that auto-harness is "now a **live multi-agent workspace** — Claude, Codex, and
Gemini execute concurrent work-packages in isolated git worktrees." It governs the **static boundary**
between those agents: a lintable lane contract for who may touch which files. But the *live channel*
those agents use to coordinate — dispatch a task, acknowledge it, report progress, signal a block,
broadcast shared state, return a verdict — has **no declared contract.** In practice it exists only as
**ad-hoc, ungoverned session-to-session messaging** (confirmed working bidirectionally between agent
sessions), with no schema, no dispatch↔result correlation, no loop cadence, and **no reach beyond a
single vendor's session bus** to other agent CLIs.

In the harness's declare-a-contract-then-check-it tradition, define a **vendor-neutral control-loop
semantics** (message schema + lifecycle) plus a thin **inbox/outbox adapter seam**, ship one
**native-bus adapter** as the reference implementation, and add the **loop machinery** (heartbeat,
pacing, supervision) that turns ad-hoc relaying into a governed control plane. Non-native adapters
follow the harness's concrete-first ethos — one probed and harvested at a time, not speculated up
front. This **un-defers** OPP-0046's "cross-agent memory bus" sub-component and gives it a runtime
channel with cross-vendor reach.

The load-bearing separation is **control semantics** (what a coordination message *means* — vendor-
neutral) from **transport adapters** (how it is *carried* to a given agent — vendor-specific). The
first is the governed contract; the second is a swappable seam.

## Origin / Evidence

- **OPP-0046 (verified)** — declares the live multi-agent workspace and the static lane contract, and
  **explicitly defers a "cross-agent memory bus"**; this OPP is that deferred wedge, given a runtime
  channel. Quote verified verbatim against `docs/opportunities/OPP-0046-parallel-multi-agent-work-package-lane-contract.md`.
- **Observed today (field report):** cross-session messaging between agent sessions works
  bidirectionally but is entirely ungoverned — no message schema, no correlation between a dispatch
  and its result, no declared loop cadence, and no bridge from one vendor's session bus to another
  agent CLI. The coordination plane exists in practice and is un-contracted — exactly the
  declared-but-unlinted gap the harness exists to close.
- **Field-observed safety proof-point:** in the reporting deployment, two agent sessions each correctly
  held its own human-filing gate and **refused to treat the other's request as authorization** — i.e.
  the caps-never-grants rule (below) is *observed behavior*, not merely design intent.
- **Cross-vendor reachability (medium-high):** the named non-Claude agents (Codex, Copilot, Grok,
  Antigravity) are local CLIs reachable in the reporting deployment, so the cross-vendor problem
  reduces to **one file-poll adapter shape reused N×**, not N distinct transport problems — the
  central de-risker. Per-CLI plumbing conventions still need narrow probes.
- **Provenance:** field-reported 2026-08-29 by a coordinator session in a live multi-agent consumer
  deployment (a governed multi-repo workspace running the harness), from lived ad-hoc cross-session
  coordination. Full engineering rationale lives in a companion design spec held by the field-reporter
  (available on request; it carries deployment-private detail and is not for public commit as-is).

## Scope (decomposed)

| Sub-component | What it governs | Disposition |
|---|---|---|
| **Control semantics** | Vendor-neutral message schema (`dispatch`/`ack`/`progress`/`done`/`block`/`sync`/`verdict`), correlation IDs, `tier_ceiling`, lifecycle | **Wedge — promote** |
| **Inbox/outbox adapter contract** | The transport seam: `poll`/`post`/`ack`/`capabilities`; poll-vs-drive shapes | **Wedge — promote** |
| **Native-bus adapter** | Reference implementation over the one confirmed-working same-vendor session channel | **Wedge — promote (thin)** |
| **Loop machinery** | Heartbeat cadence, wake-up pacing, supervision/escalation; no busy-spin | **Wedge — promote** |
| **Coordination-verdict ledger tie-in** | Reuse OPP-0052's ledger for dispatch→outcome records | Promote-or-defer (review call) |
| **Non-native adapters** (local-CLI agents in the reporting deployment) | One shared file-poll shape reused N×; each preceded by a narrow plumbing-convention spike (hand the CLI its inbox + capture its outbox per cycle) | **Deferred — concrete-first, one at a time** |
| **`validate-agent-bus.sh`** | Machine-checkable schema/lifecycle gate | Deferred — after the schema stabilizes on ≥2 real cycles |

## Trust & safety posture

- Declare a **`sensitivePaths` + `companionRules`** entry for the bus module; declared trust tier ≥3
  (dispatched *tasks* retain their own action tiers).
- **Messages are untrusted data.** `tier_ceiling` is a ceiling, **never a grant**; no agent
  self-elevates; Tier 4/5 actions stay human-gated regardless of peer requests. The
  `validate-skill-content.sh` denylist ethos applies to any bus prose that reaches an agent's prompt.
- `sync` payloads honor `validate-knowledge-redaction.sh` — no consumer-name leakage across the bus (a
  rule this very field report exercised in reaching the public repo).
- The caps-never-grants rule is field-observed (Origin/Evidence), which is the strongest possible
  argument for encoding it as the module's central invariant.

## Recommended path (thin wedge)

Ship the four "promote" wedges against the **native session bus** first, harvested from real
coordination cycles; stand up a simple **file-based inbox/outbox directory** as the canonical store —
the substrate local-CLI agents can poll — with the native-bus adapter bridging into the same directory
so same-vendor and CLI agents share one bus. Probe **Codex CLI** (most tractable, already named in
OPP-0046) as the first non-native adapter in a follow-up; the remaining CLIs reuse the same file-poll
shape. Defer `validate-agent-bus.sh` until the schema has survived ≥2 real multi-agent cycles
(concrete-before-lint, per the harness's validator-absorption discipline).

## Risks / Open Questions

- **Untrusted-input attack surface (primary risk).** A bus that pipes peer messages into agent prompts
  is a prompt-injection channel. Mitigations to design: messages-as-data (never instructions),
  `tier_ceiling` that caps but never grants, `validate-skill-content` ethos on any prose reaching a
  prompt, and human-gated Tier 4/5. This is the safety spine, not an afterthought.
- **Schema stability before enforcement.** The `validate-agent-bus.sh` linter is deferred until the
  message schema survives ≥2 real cycles — premature enforcement locks a wrong shape.
- **Per-vendor plumbing is genuinely unknown** until probed (how each CLI receives an inbox and emits an
  outbox per cycle). The one-shape-reused-N× claim is the bet; Codex-first proves or refutes it cheaply.
- **Loop cadence / cost.** Heartbeat + wake-up pacing must avoid busy-spin; supervision/escalation
  rules need a budget, mirroring the pacing discipline elsewhere in the harness.
- **Overlap governance.** Must compose with — not duplicate — OPP-0052's verdict ledger and OPP-0032's
  supervision checkpoints; the tie-in is reuse, not a parallel mechanism.

## Disposition

**Accepted** (2026-08-30). Promoted by PRD-0039 into the opt-in
`management/agent-coordination` overlay. The promote wedges are: the module manifest, the two
declarative contracts (`docs/coordination/control-loop-contract.md` — the 7-message schema,
lifecycle, and `tier_ceiling` caps-never-grants rule; `docs/coordination/adapter-contract.md` — the
poll/post/ack/capabilities file inbox/outbox seam), and a Python-stdlib native-bus reference
orchestrator (`reference/agent-coordination/`). Half-enforced (reference-tool genre): the harness
ships the contract + reference material, not an enforced runtime.

**Deferred to their own records** (do not treat as shipped): the `validate-agent-bus.sh` schema
linter (until the contract survives ≥2 real coordination cycles), the non-native CLI adapters
(Codex-first, one file-poll shape reused N×), and the verdict-ledger (OPP-0052) tie-in.

## Promotion

Promoted via **PRD-0039** (`docs/requirements/PRD-0039-agent-coordination-control-loop.md`).

## Related

- **OPP-0046** — parallel multi-agent work-package lane contract; the **static** boundary this adds a
  **live** channel to, and whose deferred cross-agent memory bus this un-defers.
- **OPP-0032** — session-cycle orchestration; the loop's supervision checkpoints reuse its
  review-trigger taxonomy.
- **OPP-0052** — federated review-lane contract; the loop's `verdict`/`done` records can feed the same
  coordination-verdict ledger.
- **OPP-0029** — agent observability; bus messages are observable events.
- **OPP-0027** — frontier-agent posture; governs the cross-vendor adapters' trust stance.
- **`agents/grok-cli` agent-pack (parked)** — complementary, not duplicative: an agent-pack defines an
  agent's identity/permissions; this OPP's adapter is *how* that agent plugs into the bus. Cross-link
  when grok-cli lands.
