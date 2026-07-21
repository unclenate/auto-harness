<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0056 — Agent Client Protocol (ACP) Governance Bridge (`agents/acp`)

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-07-20
**Last Updated:** 2026-07-20
**Confidence:** high (ACP is a live, adopted protocol whose spec explicitly lacks policy/tiers/audit — the exact layer auto-harness provides; the adopter set already overlaps the harness's existing agent-adapter modules)

---

## Thesis

The [Agent Client Protocol (ACP)](https://agentclientprotocol.com/) standardizes the
**runtime conversation** between a code editor (the *client*) and a coding agent — session
lifecycle, streamed tool-call reporting, and a per-action permission prompt — over JSON-RPC
(stdio locally; HTTP/WebSocket remote, in progress), reusing MCP's JSON types. It is an
LSP-analog for agents: created by Zed Industries (Aug 2025), co-maintained with JetBrains,
Apache-2.0, no CLA, with SDKs in Rust/TypeScript/Python/Kotlin/Java. Adopters already include
Gemini CLI, Claude Code, Goose, and Codex, inside editors Zed, JetBrains, Neovim, and Emacs.

**ACP has the permission *mechanism* but no policy, no trust tiers, and no audit — its own
spec confirms these concepts are absent.** auto-harness is the inverse: it is *all* policy
(trust tiers 0–5, companion rules, required artifacts, drift validators, audit-trail /
knowledge-capture) but has **no runtime wire** — it enforces at CI and through agent-read
governance docs. Each is precisely the other's missing half.

This OPP proposes **`agents/acp`**, a new agent-adapter module that bridges the two: it maps the
harness governance contract onto ACP's capability negotiation and permission model, so that an
ACP session running any adopted agent inside any adopted editor is governed by the harness's
tiers, companion rules, and audit ledger **at the moment of action** — not merely caught in CI
afterward. The wedge (specified in full below) is the **trust-tier → ACP permission-policy
mapping**: the adapter computes a trust tier for each ACP tool call from `(kind, target path,
command)` against the active manifest, then emits only the `session/request_permission` options
the policy allows, with the safe default pre-selected, and records the decision to the audit
ledger.

## Strategic rationale (why fast-track)

Two payoffs, both load-bearing:

1. **Accelerates development — runtime enforcement of the tiers we already declare.** Today the
   trust-tier model (ADR-0017 / PRD-0006, [`validate-trust-tier.sh`](../../platform/validators/validate-trust-tier.sh))
   is *declared* and CI-checked but **advisory at runtime**: an agent's discipline is the only
   thing between a tier-4/5 action and the working tree until a PR is opened. ACP's
   `session/request_permission` is a live per-action interception point. Bridging it turns "the
   agent should ask before installing a dependency" from a doc the agent reads into a gate the
   *client* enforces. This is a direct, partial answer to the long-standing behavioral/runtime
   enforcement gap — the harness governs by CI gate and agent-read docs, not at runtime, and
   [OPP-0020](OPP-0020-evaluation-tooling-in-harness-toolchain.md) circles the same territory.
2. **Ecosystem inducement — auto-harness as the policy layer the ACP community lacks.** ACP is
   co-maintained by JetBrains and adopted across editors and vendors, and it is deliberately a
   thin transport with no governance opinion. That is an opening: auto-harness can be **the
   governance layer that plugs into ACP's permission seam** — a portable, protocol-native way
   for any ACP editor/agent pair to acquire trust tiers, companion-rule gating, and an audit
   trail. The adopter overlap is the wedge into the community: the harness *already* ships
   agent-adapter modules for `claude-code`, `gemini-cli`, `codex-cli`, and `cursor` — the same
   agents/editors converging on ACP — so the integration targets participants who already speak
   both sides.

## The two-layer model (complementary, not competitive)

| Axis | Agent Client Protocol | auto-harness |
|------|----------------------|--------------|
| Layer | Runtime wire protocol (editor ↔ agent session) | Governance policy contract (repo-wide) |
| Analogy | LSP for AI agents | CI policy + architectural-decision framework |
| Unit | A single interactive session | A codebase's durable governance |
| Permissions | *Mechanism*: `request_permission` prompt, user decides ad hoc | *Policy*: trust tiers + companion rules decide |
| Audit | **None** (absent from spec) | Audit-trail companions + knowledge-capture ledger |
| Enforcement point | The moment of a tool call | CI merge gate + agent-read docs |
| Distribution | Editor plugins (Zed/JetBrains/Neovim/Emacs) | Submodule + `harness.manifest.yaml` + CI |

The only concern they share is permissions, and there the relationship is *mechanism vs.
policy* — complementary by construction. They occupy different layers with no competing
abstraction, so they **coexist without conflict** (see Relationship). ACP even *sharpens*
auto-harness's positioning: it is the crisp runtime-protocol foil that the harness's
"governance, not runtime" genre claim has always needed.

## The wedge — trust-tier → ACP permission-policy mapping

The adapter is a **two-step policy function** sitting behind ACP's `session/request_permission`:
first classify the tool call into a trust tier, then emit the permission options that tier
allows.

### Step 1 — ACP tool-call `kind` (+ path + command) → trust tier

ACP tags each tool call with a `kind` ∈ `{read, edit, delete, move, search, execute, think,
fetch, other}` and (optionally) the file locations it affects. The adapter infers a baseline
tier from the kind, then escalates on the target path (via the manifest's `sensitivePaths`) and,
for `execute`, on command inspection:

| ACP `kind` | Baseline tier | Escalation rules |
|------------|---------------|------------------|
| `read`, `search`, `think` | **0** Read-only | — |
| `fetch` | **2** Workspace-mutation | Network **egress that publishes** (POST/push to an external service) → **3**; pure read-fetch stays **2** |
| `edit`, `move` | **2** Workspace-mutation | Target ∈ `sensitivePaths` → **3**; target is a governance entrypoint (`HARNESS.md`/`AGENTS.md`/`CLAUDE.md`/CI) or a secrets path → **5** |
| `delete` | **2** Workspace-mutation | Target ∈ `sensitivePaths` → **3**; `allow_always` never offered for `delete` |
| `execute` | **3** Git-/shell-writing | Command inspection: `test`/`lint`/`build` → **1**; dependency install / local migration / service config → **4**; deploy / prod migration / secrets rotation / infra → **5** |
| `other` | **3** (conservative) | Requires explicit classification before any `allow_always` |

Two cross-cutting rules refine every row: **(a) `sensitivePaths` bump** — any kind touching a
manifest-declared sensitive path raises the tier by ≥1 and strips `allow_always`; **(b)
companion-rule surfacing** — if an `edit` touches a companion `triggerPath`, the permission
request's human-readable `title` names the required companion (e.g. *"editing `HARNESS.md`
requires an ADR or operating-principles change in the same commit"*), so the human decides with
the governance consequence visible.

### Step 2 — trust tier → `session/request_permission` option set

The adapter emits only the ACP permission options the tier permits, pre-selects the safe
default, and logs the outcome. ACP options are `allow_once`, `allow_always`, `reject_once`,
`reject_always`; the client returns `selected(optionId)` or `cancelled`.

| Tier | Options offered | Pre-selected default | `allow_always`? | Audit record |
|------|-----------------|----------------------|-----------------|--------------|
| **0** Read-only | `allow_once`, `allow_always` | `allow_always` (auto-approve) | yes | kind |
| **1** Local analysis | `allow_once`, `allow_always` | `allow_once` (auto-approvable) | yes | kind + command |
| **2** Workspace mutation | `allow_once`, `allow_always`, `reject_once` | `allow_once` | yes (with care) | kind + path |
| **3** Git-/shell-writing | `allow_once`, `reject_once` | `reject_once` (human must see each) | **no** | kind + path + diff/command |
| **4** Environment-altering | `allow_once`, `reject_always` | `reject_always` | **no** — `allow_once` selectable **only after** out-of-band human authorization | + human-authorizer identity |
| **5** Remote / production | `reject_always` | `reject_always` (hard block) | **no** — ACP cannot express *second sign-off*, so the adapter **blocks at the protocol seam** and surfaces the harness's tier-5 human-authorization path | + escalation notice |

**The design principle:** ACP's native permission prompt is *flat, per-call, and policy-free* —
the user decides everything from scratch every time. The adapter makes it *tiered, path-aware,
and policy-driven* — the manifest decides which options are even offered, the safe choice is the
default, sensitive paths and companion rules are surfaced inline, and every decision lands in the
audit ledger. Tiers 0–1 stop nagging (auto-approve), tiers 4–5 stop leaking (hard-gate), and the
whole stream becomes governance evidence.

## Scope (decomposed)

| Sub-component | What it does | Disposition |
|---|---|---|
| **`agents/acp` adapter module** | New `platform/agents/acp/` module (9th agent adapter) declaring the ACP capability profile + the policy binding; follows the `claude-code`/`gemini-cli` module shape | **Wedge candidate** |
| **Tier-policy engine** | The Step-1/Step-2 function above, driven by `harness.manifest.yaml` (tiers, `sensitivePaths`, `companionRules`) | **Wedge candidate (core)** |
| **`kind` × `sensitivePaths` escalation** | Cross-reference ACP tool-call kinds against manifest sensitive paths / entrypoints | Part of the engine |
| **Audit bridge** | Ingest the ACP `session/update` tool-call stream into the audit-trail / knowledge-capture ledger — the audit layer ACP lacks | High-value follow-on (own PRD phase) |
| **MCP adjacency** | Reconcile with existing `architectures/mcp-server` governance; ACP reuses MCP types and is its editor-facing sibling | Reference / alignment |
| **Remote-transport posture** | HTTP/WebSocket agents (ACP roadmap item) vs. local stdio subprocess | Deferred until ACP ships it |

## Integration architecture — where the policy runs

Three candidate homes for the tier-policy engine, to resolve at PRD time:

1. **Client-side (editor plugin) consults the manifest.** The ACP client reads
   `harness.manifest.yaml` and applies the policy when composing permission options. Cleanest
   semantics (the client already owns the prompt) but requires per-editor cooperation.
2. **A harness-provided ACP *proxy*** sitting between client and agent, rewriting
   `request_permission` option sets and mirroring `session/update` to the audit ledger. Portable
   across editors (no per-editor code) at the cost of a process in the middle.
3. **Agent-side adapter** (the agent self-limits before requesting). Weakest — it re-creates the
   advisory-at-runtime problem inside the agent, the exact gap this OPP closes.

The proxy (2) is the likely wedge: it is editor-agnostic, which maximizes the ecosystem-inducement
payoff (drop-in governance for *any* ACP pair) and needs no upstream protocol change.

## Open design questions (for the PRD)

- **Policy-engine home** (client / proxy / agent) — §10-class decision; the proxy is favored.
- **Tier computation for `execute`** — command inspection is heuristic; how conservative a
  default, and how the allow/deny lists are declared and extended.
- **`allow_always` persistence vs. tier re-evaluation** — a persisted `allow_always` must be
  scoped (per kind + path class), and must *not* let a later same-kind call to a *different*
  sensitive path ride the earlier grant.
- **Tier-4/5 human-authorization channel** — ACP has no second-sign-off primitive; how the
  adapter surfaces and records out-of-band authorization.
- **Audit format** — reuse the knowledge-capture / observation schema, or a dedicated
  session-audit artifact; how it reconciles with ADR-0002.
- **Remote transport** — defer until ACP's HTTP/WebSocket support lands.

## Risks / Open Questions

- **ACP is young and moving** (v-early, remote transport in progress). Mitigate by binding to the
  *stable* baseline methods (`initialize`, `session/prompt`, `session/request_permission`,
  `session/update`) and treating optional capabilities as feature-gated.
- **Per-editor cooperation** for the client-side option; the proxy design sidesteps it.
- **Positioning confusion** — the harness must stay clearly the *policy* layer, not re-implement
  ACP transport. The two-layer model above is the guardrail.
- **No conflict risk with MCP governance** — ACP and MCP are siblings (agent↔editor vs.
  agent↔tools); the existing `architectures/mcp-server` posture extends rather than competes.

## Relationship — coexist, no conflict

Different layers, no competing abstraction. The single shared concern (permissions) is
mechanism-vs-policy complementary. ACP gains policy + tiers + audit it explicitly lacks;
auto-harness gains a runtime enforcement surface + IDE distribution reach + a standardized
tool-call event schema it would otherwise have to invent. The pairing is symbiotic, which is
why it is safe to fast-track.

## Disposition

**Accepted (2026-07-20).** Endorsed as a strategic direction on two grounds — it converts the
declared-but-runtime-advisory trust tiers into runtime-enforced gates (development acceleration),
and it positions auto-harness as the portable governance layer for the JetBrains-co-maintained
ACP ecosystem (ecosystem inducement). **A PRD is recommended** to specify the `agents/acp`
module and the tier-policy engine, resolving the open design questions above (policy-engine home;
`execute` classification; `allow_always` scoping; tier-4/5 authorization channel; audit format).
The **tier → `request_permission` mapping in this record is the specified wedge** and the PRD's
starting point. Mirrors how OPP-0054 carried a load-bearing design table into PRD-0036.

## Promotion

Promoted via [PRD-0037 — Agent Client Protocol Governance Bridge](../requirements/PRD-0037-acp-governance-bridge.md) (2026-07-20), which ratifies the `agents/acp` module (module.yaml + canonical `tier-policy.yaml` + README implementation-helper sketches) and resolves the five open design questions (policy-engine home → editor-agnostic proxy; `execute` classification; `allow_always` scoping; tier-4/5 authorization channel; audit format). The runtime proxy and audit bridge proceed as follow-on phases (their own PRDs) reusing the `tier-policy.yaml` this establishes.
