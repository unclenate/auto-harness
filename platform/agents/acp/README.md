<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# `agents/acp` — Agent Client Protocol Governance Bridge

Operating pack that makes the harness governance contract enforceable at runtime through
the [Agent Client Protocol (ACP)](https://agentclientprotocol.com/). ACP is a JSON-RPC
wire protocol (an LSP-analog) standardizing the session between a code editor and a coding
agent; it has a per-action permission prompt but — by its own spec — **no policy, no trust
tiers, and no audit**. This pack supplies exactly that layer: it maps ACP tool calls onto the
kernel trust tiers and emits only the permission options each tier allows, logging every
decision.

Per [PRD-0037](../../../docs/requirements/PRD-0037-acp-governance-bridge.md) /
[OPP-0056](../../../docs/opportunities/OPP-0056-agent-client-protocol-governance-bridge.md).

## What this pack governs

ACP standardizes the *runtime wire*; this pack governs *what the wire is allowed to do*. It
sits at one seam — ACP's `session/request_permission` — and turns a flat, policy-free prompt
into a **tiered, path-aware, audited** gate. The canonical mapping ships as
[`tier-policy.yaml`](tier-policy.yaml) and is applied by a governance proxy (or an
ACP-client that reads it directly).

## What this pack requires

An ACP-governed project declares its policy binding as **either**:

- `.acp/policy.yaml` — the machine-readable binding the proxy/client reads (extends
  `tier-policy.yaml`; may tighten, never loosen), **or**
- `docs/acp/governance.md` — a governance doc that references the binding and the tier map.

Changes to the binding (`.acp/**`, `acp-policy.yaml`) are **sensitive paths** and carry a
companion rule: they must land with an `AGENTS.md` cross-reference, an ADR, or a PRD, so the
runtime gate never drifts from the declared trust tiers.

## The policy in one screen

The bridge is a two-step function (full detail in [`tier-policy.yaml`](tier-policy.yaml)):

1. **Classify** — an ACP tool-call `kind` (+ target path + command) → a trust tier.
   `read`/`search`/`think` → Tier 0; `edit`/`move` → Tier 2 (→ Tier 5 on a governance
   entrypoint); `execute` → Tier 3 (→ Tier 1 for test/build, → Tier 4 for install, → Tier 5
   for deploy); a sensitive-path match bumps the tier and strips `allow_always`.
2. **Emit** — a trust tier → the `session/request_permission` options offered, with the safe
   default pre-selected:

| Tier | Posture | Options | Default | `allow_always` |
|------|---------|---------|---------|----------------|
| 0 | auto | `allow_once` · `allow_always` | `allow_always` | yes |
| 1 | auto | `allow_once` · `allow_always` | `allow_once` | yes |
| 2 | care | `allow_once` · `allow_always` · `reject_once` | `allow_once` | with care |
| 3 | care | `allow_once` · `reject_once` | `reject_once` | no |
| 4 | gate | `allow_once` · `reject_always` | `reject_always` | no — human auth first |
| 5 | block | `reject_always` | `reject_always` | no — blocked at the seam |

Tiers 0–1 stop nagging; Tiers 4–5 stop leaking. ACP has no second-sign-off primitive, so the
bridge **hard-blocks Tier 5 at the protocol seam** and routes it to the harness's own
authorization path.

## Implementation helpers

These are reference sketches for building the runtime, not shipped code. The pack is
declarative; the proxy/client is downstream engineering that reads the policy above.

### Helper 1 — the reference governance proxy (favored home)

The editor-agnostic option: a thin JSON-RPC proxy between the ACP client (editor) and the ACP
agent. It passes messages through untouched **except** it rewrites `session/request_permission`
option sets per policy and mirrors the `session/update` tool-call stream to the audit sink.
No per-editor code, no upstream protocol change.

```text
  ┌────────────┐   ACP/JSON-RPC   ┌───────────────────────┐   ACP/JSON-RPC   ┌────────────┐
  │ ACP client │ ───────────────▶ │  acp-governance-proxy │ ───────────────▶ │ ACP agent  │
  │  (editor)  │ ◀─────────────── │  reads tier-policy +  │ ◀─────────────── │ (claude-   │
  └────────────┘                  │  harness.manifest.yaml│                  │  code, …)  │
        ▲                         └───────────┬───────────┘                  └────────────┘
        │ tiered options,                     │ mirror session/update
        │ default pre-selected                ▼
        │                             .acp/audit/session-log.jsonl
        └──── request_permission rewritten by tier ────┘
```

### Helper 2 — the policy engine (pseudocode)

```python
# classify(kind, path, command) -> tier ; optionsFor(tier) -> permission options
def classify(call, manifest, policy):
    tier = policy.kinds[call.kind].tier                      # step 1: baseline from kind
    if call.kind == "execute":
        tier = max(tier, command_tier(call.command, policy)) # test→1, install→4, deploy→5
    if call.kind == "fetch" and call.publishes:
        tier = max(tier, 3)
    if is_governance_entrypoint(call.path, policy):
        tier = 5
    if manifest.matches_sensitive_path(call.path):           # bump + strip allow_always
        tier = min(tier + 1, 5)
        strip_allow_always = True
    return tier

def on_request_permission(call, manifest, policy):
    tier = classify(call, manifest, policy)
    opts = policy.tiers[tier]
    audit.append(call, tier, decision=None)                  # record the ask
    if opts.posture == "block":                              # Tier 5: never reaches the user
        return respond_selected(opts.options["reject_always"])
    title = call.title + companion_hint(call.path, manifest) # surface the governance cost
    return present(options=opts.options, default=opts.default, title=title)
```

### Helper 3 — example consumer binding (`.acp/policy.yaml`)

```yaml
# Extends the canonical agents/acp/tier-policy.yaml; may tighten, never loosen.
extends: agents/acp/tier-policy.yaml
overrides:
  kinds:
    fetch: { tier: 3 }          # this project treats all network egress as Tier 3
  escalation:
    governanceEntrypoint:
      paths:
        - ^infra/terraform/      # project-specific Tier-5 path
audit:
  sink: .acp/audit/session-log.jsonl
```

### Helper 4 — audit bridge (follow-on phase)

The `session/update` stream is a ready-made, standardized tool-call event log. The proxy
mirrors it to `.acp/audit/session-log.jsonl`; a follow-on phase reconciles that log into the
knowledge-capture / observation ledger (ADR-0002 shape) so ACP sessions become governance
evidence — the audit layer ACP itself lacks.

### Helper 5 — adoption checklist

1. Activate `agents/acp` in `harness.manifest.yaml`.
2. Add `.acp/policy.yaml` extending `tier-policy.yaml` (or `docs/acp/governance.md`).
3. Run the reference proxy between your ACP editor and agent (Helper 1).
4. Cross-reference the binding from `AGENTS.md` (satisfies the companion rule).
5. Point the audit sink at `.acp/audit/` and add it to `.gitignore`.

## Trust-tier deference

The ACP policy binding **declares** the mapping; it never overrides the kernel. Trust never
self-elevates: the bridge cannot lower a tier below the kernel contract, `allow_always` is
prohibited for `delete` / sensitive paths / Tier 3+, and Tier 5 is blocked at the seam and
routed to the harness's human-authorization path. See
[`harness-governance`](../../skills/harness-governance/SKILL.md) and trust-tier diagram #2.

## Relationship to other packs and to MCP

ACP (agent↔editor) and MCP (agent↔tools/context) are siblings; this pack composes with
`architectures/mcp-server` rather than competing with it. The adopter overlap is the wedge:
`claude-code`, `gemini-cli`, `codex-cli`, and `cursor` are already harness agent packs **and**
ACP participants.
