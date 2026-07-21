<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0037: Agent Client Protocol Governance Bridge — `agents/acp`

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-07-20 | **Review Cycle:** On-change

**Status:** Accepted *(design + v1 implementation land together — the module is declarative governance, so the contract and its artifact ship in one pass; the runtime proxy is a reference sketch, not shipped code)*
**Date:** 2026-07-20 (filed + accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Promoting OPP: [OPP-0056](../opportunities/OPP-0056-agent-client-protocol-governance-bridge.md) — `accepted`; this PRD ratifies its `agents/acp` module and the trust-tier → permission-policy wedge, resolving the five open design questions the OPP flagged.
- Governed protocol: [Agent Client Protocol](https://agentclientprotocol.com/) — JSON-RPC editor↔agent wire protocol (Zed + JetBrains, Apache-2.0). The relevant surface is `session/request_permission` (options `allow_once` / `allow_always` / `reject_once` / `reject_always`), the `session/update` tool-call stream, and the tool-call `kind` taxonomy.
- Sibling agent packs: [`agents/gemini-cli`](../../platform/agents/gemini-cli/README.md), [`agents/claude-code`](../../platform/agents/claude-code/README.md) — the module shape this follows (adapter + companion rule translating a client's approval semantics into kernel trust tiers). ACP generalizes that translation to a *protocol* rather than one vendor's config.
- Kernel model: the trust tiers 0–5 ([`validate-trust-tier.sh`](../../platform/validators/validate-trust-tier.sh), ADR-0017 / PRD-0006) and companion rules that the bridge enforces at runtime; trust-tier diagram #2.
- Adjacent architecture: [`architectures/mcp-server`](../../platform/profiles/architectures/mcp-server/README.md) — ACP and MCP are siblings (agent↔editor vs. agent↔tools); this composes, not competes.
- Related operating-principles: § 9 (design/implementation split — relaxed here because the module is declarative; the runtime proxy is out of scope as a sketch), § 10 (this converts trust-tier enforcement for ACP tool calls from *advisory-at-runtime* toward *enforced-at-the-seam*).

## Overview

The trust-tier model is declared per module and checked in CI, but it is **advisory at
runtime**: nothing intercepts a Tier-4 dependency install or a Tier-5 deploy at the moment an
agent attempts it — the agent's own discipline is the only gate until a PR opens. ACP introduces
a runtime interception point the harness never had: `session/request_permission`, a per-tool-call
prompt every ACP editor already renders. But ACP's prompt is **flat and policy-free** — the user
re-decides everything from scratch, and the spec carries no tiers, no path-awareness, and no
audit.

`agents/acp` bridges the two. It ships a **declarative tier-policy** (`tier-policy.yaml`) that a
governance proxy (or an ACP client) reads to (1) classify each ACP tool call into a kernel trust
tier from its `kind` + target path + command, and (2) emit only the `request_permission` options
that tier allows, with the safe default pre-selected, logging every decision. Tiers 0–1
auto-approve; Tier 3 offers no blanket grant; Tiers 4–5 gate and block. This makes the declared
tiers **enforced at the moment of action** (development acceleration) and positions the harness as
the portable governance layer the JetBrains-co-maintained ACP ecosystem lacks (ecosystem
inducement) — the two goals OPP-0056 set.

The module is **declarative governance**, not a running binary: it ships the policy mapping, the
companion rule guarding the consumer's binding, and reference implementation-helper sketches (the
proxy architecture, the policy-engine pseudocode, an example binding, the audit bridge). The
runtime proxy is downstream engineering, specified here as a sketch.

## Goals & Non-Goals

**Goals:**

- Ship `platform/agents/acp/` — an agent module (`module.yaml`, `README.md`, `tier-policy.yaml`)
  following the `gemini-cli`/`claude-code` shape: a consumer policy-binding requiredArtifact
  (`oneOf` `.acp/policy.yaml` / `docs/acp/governance.md`), `sensitivePaths` on the binding, a
  companion rule requiring `AGENTS.md`/ADR/PRD alongside binding changes, and `agentAdapters` +
  `compiledFragments`.
- Ship the canonical **two-step tier-policy** as `tier-policy.yaml`: `kind → tier` (with
  sensitive-path bump, governance-entrypoint → Tier 5, `execute` command classification,
  publishing-`fetch` escalation, companion surfacing) and `tier → request_permission option set`
  (per the § 10 table below).
- Ship reference **implementation-helper sketches** in the README: the editor-agnostic governance
  proxy, the policy-engine pseudocode, an example consumer `.acp/policy.yaml`, the audit bridge,
  and an adoption checklist.
- **Documentation propagation** (the necessary updates): register the module in `SUMMARY.md`, the
  root `README.md` Module System table + directory-tree comment, `platform/README.md`, and the
  `harness-onboarding` skill's active-module + required-artifact tables; bump `modules_all`
  **61 → 62** at the two `validate-catalog-counts` assertion sites (diagrams.md "total in-tree";
  cover-back.svg "modules"). OPP-0056's Promotion section links to this PRD.
- Keep the full validator chain green: `validate-agent-pack` (adapters + compiled fragment
  exist), `validate-module-graph` / `validate-manifest`, `validate-trust-tier`,
  `validate-list-completeness` (agent module → SUMMARY; PRD → docs/README + SUMMARY nav),
  `validate-status-parity`, `validate-catalog-counts`.

**Non-Goals (deferred):**

- **The runtime proxy / client implementation.** Downstream engineering; specified as a reference
  sketch (Helper 1–2). A separate build, likely outside this repo (a companion tool).
- **The audit-bridge implementation** — mirroring `session/update` into the knowledge-capture
  ledger (ADR-0002 reconciliation). Own follow-on PRD phase; sketched as Helper 4.
- **Remote transport (HTTP/WebSocket).** Defer until ACP's remote support stabilizes; bind to the
  stable stdio baseline methods.
- **Activating `agents/acp` on the harness's own manifest.** The harness is governed by
  `claude-code`, not an ACP editor; the module ships *available* for consumers, not *active* here.
- **A new validator.** The module is guarded by the existing `validate-agent-pack` +
  `validate-companions`; no `validate-acp-policy.sh` in v1 (candidate follow-on: a shape linter
  for `.acp/policy.yaml`, noted).

## § 10 Claim Classification

| Claim ID | Claim | Current | After v1 |
|----------|-------|---------|----------|
| C-ACP-1 | An ACP tool call is gated by the kernel trust tier for its `kind` + path + command | Asserted-only (tiers are CI-checked, runtime-advisory) | **Enforced at the seam** *when a project runs the ACP bridge* — the proxy emits only the tier's permitted `request_permission` options (Half-enforced: the harness declares the policy; the consumer's proxy/client honors it at runtime) |
| C-ACP-2 | `allow_always` is never persisted for `delete`, a sensitive-path target, or Tier 3+ | Asserted-only | **Enforced** by the tier-policy (option sets omit `allow_always`) + the module review gate |
| C-ACP-3 | Tier 5 (remote/prod) is never auto-approved via ACP | Asserted-only | **Enforced** — the policy blocks Tier 5 at the seam and routes to human authorization (ACP has no second-sign-off) |
| C-ACP-4 | The consumer's ACP policy binding stays aligned with the declared trust tiers | — (no binding existed) | **Enforced** — `.acp/**` is a sensitive path with a companion rule requiring AGENTS.md/ADR/PRD |
| C-ACP-5 | The `execute` command → tier classification is correct for a given command | Asserted-only | **Unchanged** — heuristic command matching is authoring guidance, not mechanized (the module-stability boundary) |

C-ACP-1 is **Half-enforced** by design: the harness owns the policy, consumer CI/runtime honors
it — the same posture as the security-static-analysis and SAST contracts, appropriate for an
opt-in module whose enforcement point lives in the consumer's editor/proxy.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001 | `agents/acp` module ships | `platform/agents/acp/module.yaml` — `type: agent`, `stability: experimental`, `dependsOn` kernel/base + base, `requiredArtifacts` oneOf `.acp/policy.yaml` / `docs/acp/governance.md`, `sensitivePaths` + companion rule on the binding, `agentAdapters`, `compiledFragments` → README, `validators` agent-pack + companions. Passes `validate-agent-pack` / `validate-module-graph` / `validate-manifest`. |
| FR-002 | Canonical `tier-policy.yaml` | Two-step mapping present and internally consistent with the § 10 table: `kinds` (kind→tier), `escalation` (sensitive-path bump + strip `allow_always`; governance-entrypoint → 5; publishing-fetch → 3; `execute` command rules for tiers 1/4/5; companion surfacing), `tiers` (option set + default + audit per tier 0–5). |
| FR-003 | README with implementation-helper sketches | The compiled fragment documents: what the pack governs/requires, the one-screen policy table, and Helpers 1–5 (proxy architecture, policy-engine pseudocode, example `.acp/policy.yaml`, audit bridge, adoption checklist), plus trust-tier deference. |
| FR-004 | Documentation propagation | Module registered in `SUMMARY.md`, root `README.md` (Module System table + tree comment), `platform/README.md`, `harness-onboarding` SKILL (active-module + required-artifact tables). `validate-list-completeness` green (agent module → SUMMARY). |
| FR-005 | Catalog-count bump | `modules_all` **61 → 62** at both assertion sites (`docs/architecture/diagrams.md` "total in-tree"; `docs/_assets/cover-back.svg` "modules"). `validate-catalog-counts` green. |
| FR-006 | Companion rule guards the binding | `.acp/**` + `acp-policy.yaml` are sensitive paths; a change to them requires `AGENTS.md` / ADR / PRD. `validate-sensitive-paths` green (the module's own `sensitivePaths` are covered by its own `triggerPaths` — PR-#88 self-coverage). |
| FR-007 | OPP-0056 promotion | OPP-0056's Promotion section links PRD-0037; OPP-0056 stays `accepted`. |

### Should Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-S01 | MCP-adjacency note | README states ACP/MCP are siblings and this composes with `architectures/mcp-server`. |
| FR-S02 | Adopter-overlap wedge named | README/PRD name the `claude-code`/`gemini-cli`/`codex-cli`/`cursor` overlap as the ecosystem wedge. |

### Out of Scope

| Feature | Reason | Revisit |
|---------|--------|---------|
| Runtime proxy / client code | downstream engineering; declarative module only | companion tool build |
| Audit-bridge implementation | reconciles `session/update` into the ADR-0002 ledger | own follow-on PRD |
| Remote HTTP/WebSocket transport | ACP roadmap item, not stable | when ACP ships it |
| `validate-acp-policy.sh` shape linter | agent-pack + companions suffice for v1 | candidate follow-on OPP |
| Activation on the harness manifest | harness runs claude-code, not an ACP editor | consumer projects |

## Open Questions — resolved

- **Policy-engine home** → the **editor-agnostic governance proxy** (Helper 1): portable across
  ACP editors, no upstream protocol change, maximizes the ecosystem payoff. Client-side and
  agent-side remain valid alternatives a consumer may choose; the module is home-agnostic (it
  ships the policy, not the engine).
- **`execute` classification** → heuristic command matching in `tier-policy.yaml` (`command`
  rules), conservative default Tier 3; classified as Should-Have guidance (C-ACP-5), extendable
  per project.
- **`allow_always` scoping** → prohibited for `delete` / sensitive paths / Tier 3+; a persisted
  grant is scoped per `(kind, path-class)` and never rides a later call to a different sensitive
  path (C-ACP-2).
- **Tier-4/5 authorization channel** → ACP has no second-sign-off primitive, so Tier 5 is blocked
  at the seam and routed to the harness's out-of-band authorization path (C-ACP-3); Tier 4 offers
  `allow_once` only after human authorization is recorded in the audit sink.
- **Audit format** → JSONL session log (`.acp/audit/session-log.jsonl`) in v1; reconciliation
  with the ADR-0002 observation schema deferred to the audit-bridge phase.

## Technical Constraints

- The module is declarative YAML + Markdown; no new runtime dependency in the harness.
- `tier-policy.yaml` is a plain, proxy-readable schema (`schemaVersion: 1`), extendable via a
  consumer `.acp/policy.yaml` that may tighten but never loosen a tier.
- Authored prose must not trip `validate-skill-content` (the module's `humanReview` / README are
  scanned by the content validators).
- Trust never self-elevates: the policy cannot map a `kind` below the kernel tier for that action
  class; the review gates enforce this.

## CI/CD Gates

- Full validator chain green, including `validate-agent-pack` (acp adapters + compiled fragment
  exist), `validate-catalog-counts` after the 61 → 62 bump, `validate-list-completeness`,
  `validate-status-parity`, `validate-sensitive-paths`, `validate-companions`.
- markdownlint + YAML well-formedness on the new module files.

## Versioning Implications

Additive: a new *experimental* agent module + its declarative policy artifact + documentation
propagation. No change to existing modules or the kernel. `modules_all` 61 → 62. Lands in the next
minor; `stability: experimental` signals the runtime contract may still move with ACP.

## Acceptance Criteria

`agents/acp` merges with the full chain green and OPP-0056's Promotion section linking this PRD.
The runtime proxy and audit bridge proceed as follow-on phases (their own PRDs) reusing the
`tier-policy.yaml` this PR establishes.
