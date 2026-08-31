<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
-->

# PRD-0039: Inter-Agent Control-Loop & Cross-Vendor Bus (`management/agent-coordination`)

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-08-30 | **Review Cycle:** on-change

**Status:** Accepted
**Date:** 2026-08-30
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- **Promotes:** [OPP-0059](../opportunities/OPP-0059-inter-agent-control-loop-cross-vendor-bus.md) — the field-reported opportunity this specifies (flips `proposed → accepted` on acceptance).
- **Un-defers:** [OPP-0046](../opportunities/OPP-0046-parallel-multi-agent-work-package-lane-contract.md) — its deferred cross-agent memory bus; `management/work-package` governs the *static* lane boundary, this adds the *live* channel.
- **Neighbors:** OPP-0032 (session-cycle orchestration — supervision reuses its review-trigger taxonomy); OPP-0052 (federated review lane / verdict ledger — `verdict`/`done` records can feed it); OPP-0029 (agent observability — bus messages are observable events); OPP-0027 (frontier-agent posture — governs the cross-vendor adapters' trust stance).
- **Genre precedent:** `agents/acp` (PRD-0037/PRD-0038) — declarative contract + reference implementation, **Half-enforced**; this PRD follows the same reference-tool genre.
- **Existing doc extended:** `platform/workflow/multi-agent-tool-coordination.md`.

## Overview

Auto-harness is already a live multi-agent workspace, but the *live channel* its agents coordinate over —
dispatch a task, acknowledge it, report progress, signal a block, broadcast shared state, return a verdict —
has no declared contract. It exists only as ad-hoc, ungoverned session-to-session messaging: no schema, no
dispatch↔result correlation, no loop cadence, and no reach beyond one vendor's session bus to other agent CLIs.

This PRD ships a new opt-in `management/agent-coordination` overlay that governs that channel in the harness's
declare-a-contract-then-check-it tradition. It splits **control semantics** (a vendor-neutral message schema +
lifecycle, with a `tier_ceiling` that caps but never grants) from **transport adapters** (a file inbox/outbox
seam: `poll`/`post`/`ack`/`capabilities`), and ships one **native-bus reference adapter** over the Claude
SendMessage channel plus the **loop machinery** (heartbeat cadence, wake-up pacing, supervision/escalation; no
busy-spin) that turns ad-hoc relaying into a governed control plane.

Consistent with the `agents/acp` precedent, the deliverable is a **declarative contract + reference material**,
not an enforced runtime: the harness ships the schema, the adapter contract, the safety posture, and a runnable
reference orchestrator — it does **not** ship or enforce a production bus. The machine-checkable
`validate-agent-bus.sh` linter and the non-native CLI adapters are deferred to their own records.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- A governed home for live inter-agent coordination: the `management/agent-coordination` overlay (tier 3),
  sibling to `management/work-package`'s static lane contract.
- A **vendor-neutral control-loop contract**: the seven-message schema + lifecycle + correlation + the
  `tier_ceiling` caps-never-grants invariant, all as untrusted data.
- A **transport-adapter contract**: the `poll`/`post`/`ack`/`capabilities` file inbox/outbox seam that any
  local-CLI agent can implement, with `permissionScope` mirroring.
- A **native-bus reference adapter + loop machinery** (over Claude SendMessage) that demonstrates the contract
  end-to-end as reference material.
- The **safety posture** encoded and cross-referenced to kernel doctrine: caps-never-grants, Tier 4/5
  human-gated regardless of peer requests, redaction on `sync`, `validate-skill-content` ethos on bus prose.

**Non-Goals** — outcomes explicitly out of scope:

- **An enforced production bus** — *(genre: the harness ships a contract + reference material, not runtime; a
  consumer builds and runs its own bus against the contract, as with `agents/acp`).*
- **Runtime conformance checking of a deployed bus** — *(the `validate-agent-bus.sh` linter is deferred until
  the schema survives ≥2 real coordination cycles; premature enforcement locks a wrong shape — OPP-0059 Risks).*
- **Cross-vendor adapters for non-Claude CLIs** — *(deferred, concrete-first, one probe at a time, Codex CLI
  first; one file-poll adapter shape is reused, so these are follow-ups not blockers).*
- **Replacing `management/work-package`** — *(this composes with the static lane contract as its live channel;
  it does not duplicate or supersede it).*

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Multi-agent operator | A maintainer running concurrent agent sessions on one workspace | A governed, correlated coordination channel with a declared cadence and a safety floor, instead of ad-hoc messaging |
| Agent-pack author | Someone adding a new agent CLI to the harness | A single transport-adapter contract to implement (poll/post/ack/capabilities) so their agent joins the bus |
| Reviewer | A human gating dispatched work | A trust posture where peer messages cap but never grant authority, and Tier 4/5 stays human-gated |

## User Stories

- As a multi-agent operator, I want a dispatched task to carry a correlation id and a `tier_ceiling`, so that I
  can trace its result and know its action authority is capped and never elevated by a peer.
- As an agent-pack author, I want one file inbox/outbox adapter contract, so that adding my agent to the bus is
  one implementation reused across vendors rather than a bespoke transport.
- As a reviewer, I want bus messages treated as untrusted data with Tier 4/5 human-gated, so that a poisoned or
  over-reaching peer message cannot escalate action authority.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | The `management/agent-coordination` module manifest | `platform/profiles/management/agent-coordination/module.yaml` exists: `type: management`, `version: 0.1.0`, `stability: experimental`, `tier.declared: 3`, `dependsOn: [kernel/base]`, `requiredArtifacts` = the two contracts (FR-002/003), `sensitivePaths` on the coordination surface, `companionRules` (FR-005), `validators: [validate-companions]`, `reviewGates`, `compiledFragments: [README.md]`, `recommendedSkills: [harness-governance]`. Passes `validate-module-graph`, `validate-module-stability`, `validate-trust-tier`. | Concept-named like its management peers; **no `validate-agent-bus` in `validators`** (deferred). |
| FR-002 | Control-loop contract artifact | `docs/coordination/control-loop-contract.md` declares: the **seven message types** (`dispatch`, `ack`, `progress`, `done`, `block`, `sync`, `verdict`); the **envelope** (`type`, `id` = correlation id, `from`, `to`, `tier_ceiling`, `ts`, `payload`); the **lifecycle** (`dispatch → ack → progress* → (done \| block \| verdict)`; `sync` = broadcast); the **correlation rule** (every non-`dispatch`/`sync` message references its dispatch `id`); and the **`tier_ceiling` semantics** (an integer that can only *lower* the action tier of dispatched work — effective tier = `min(tier_ceiling, executor's own policy)` — never raise it; **caps, never grants**). States that **messages are untrusted data, never instructions.** | The vendor-neutral governed core. |
| FR-003 | Transport-adapter contract artifact | `docs/coordination/adapter-contract.md` declares the four operations (`poll` = read pending inbound; `post` = write outbound to a peer's inbox; `ack` = mark consumed; `capabilities` = declare supported message types/modes); the **canonical file store** layout (per-agent `inbox/`+`outbox/`, one JSON message per file, atomic write-then-rename); **`permissionScope` mirroring** (an adapter may not `post` a message whose action would exceed its own scope); poll-vs-drive shapes; and **declared degraded modes** (an adapter that lacks a message type declares it via `capabilities`, never silently drops). | The swappable seam; one shape reused across vendors. |
| FR-004 | Native-bus reference orchestrator + loop machinery | `reference/agent-coordination/` ships a runnable **reference** (clearly labeled reference material, not enforced runtime): a native adapter bridging the Claude SendMessage channel into the canonical file store, and the **loop** — heartbeat cadence (declarative interval), **wake-up pacing via `ScheduleWakeup`** (the loop schedules its own next wake; **no busy-spin**), supervision (detect stalled/blocked dispatches by correlation id), and escalation (timeout or `block` → surface to a human). Python/stdlib; tests runnable manually (ACP-proxy precedent). | Demonstrates the contract end-to-end; thin supervision (heartbeat + stall-detection), not a full state machine. |
| FR-005 | Trust & safety posture + companion rules | The module declares `sensitivePaths` on `docs/coordination/` (+ the reference store path) and a **companion rule**: a change to either contract artifact requires an ADR under `docs/adr/` **or** a `docs/project/change-log.md` entry. The contracts restate the kernel invariants: `tier_ceiling` caps-never-grants; **Tier 4/5 actions stay human-gated regardless of any peer request**; `sync` payloads honor `validate-knowledge-redaction`; the `validate-skill-content` denylist ethos applies to any bus prose reaching an agent prompt. | Encodes OPP-0059's field-observed safety spine. |
| FR-006 | Catalog propagation + OPP promotion | Module-count bump across every catalog-count site (`HARNESS.md`, `README.md`, `SUMMARY.md`, `docs/README.md`, onboarding SKILL, `discovery-to-composition.md`); a coordination-bus reference row added to `platform/workflow/multi-agent-tool-coordination.md`; OPP-0059 `proposed → accepted` with its Disposition/Promotion sections filled; change-log + shared-observations distillation entries. `validate-catalog-counts`, `validate-list-completeness`, `validate-companions` all green. | The always-on propagation surface; drives the copy-exact site map at plan time. |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-007 | Reference README | `platform/profiles/management/agent-coordination/README.md` (the compiled fragment) documents the two contracts, the reference orchestrator, how to run it, and the deferred follow-ups. | Compiled fragment; required by `validate-agent-pack`-class conventions for the module. |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| `validate-agent-bus.sh` runtime/shape linter | Schema must prove stable on ≥2 real cycles before enforcement locks a shape | After 2 real coordination cycles (own record) |
| Non-native CLI adapters (Codex, Copilot, Grok, Antigravity) | Concrete-first; one file-poll shape reused, probed one at a time | Follow-up OPP/PRD, Codex CLI first |
| Coordination-verdict ledger tie-in (OPP-0052 reuse) | Compose only after the verdict schema stabilizes here | Phase 2 review call |

## Implementation Deferral

Per operating principle § 9 (*Split Design from Implementation*), the enforcement machinery is intentionally
split from the contract this PRD ships:

| Deferred implementation | Deferred to | Why deferred |
|-------------------------|-------------|--------------|
| `validate-agent-bus.sh` (message-schema / lifecycle shape linter) | Own OPP/PRD after ≥2 real cycles | OPP-0059 Risks: premature enforcement locks a wrong schema; the contract must survive real use first |
| Non-native CLI adapters | Follow-up OPP/PRD, Codex-first | Concrete-first; the one file-poll shape is proven by the native adapter, then reused per-CLI behind narrow probes |
| Verdict-ledger tie-in | Phase 2 | Reuse OPP-0052's ledger only once the `verdict`/`done` records stabilize |

What v1 *does* commit to (the contract that must hold before any enforcement is built): the seven-message
schema + envelope + lifecycle + correlation (FR-002), the four-operation adapter seam + file store layout
(FR-003), and the caps-never-grants / untrusted-data / human-gated-Tier-4/5 safety invariants (FR-005).

## § 10 Claim Classification

| Claim | Classification | Basis |
|-------|----------------|-------|
| The module declares its required artifacts, trust tier, and companion rules | **Enforced** | `validate-required-artifacts`, `validate-trust-tier`, `validate-companions`, `validate-module-stability` all run always-on |
| A change to a coordination contract is accompanied by an ADR or change-log entry | **Enforced** | The FR-005 companion rule (path→path) is machine-checked by `validate-companions` |
| A live bus conforms to the message schema / lifecycle at runtime | **Asserted-only** | No `validate-agent-bus.sh` yet (deferred); the contract + reference orchestrator assert it, nothing machine-checks a deployed bus |
| `tier_ceiling` caps-never-grants and Tier 4/5 stays human-gated | **Half-enforced** | Declared in the contract and honored by the reference orchestrator; not machine-verified against an arbitrary runtime bus until the linter ships |

Overall posture: **Half-enforced**, consistent with `agents/acp` (PRD-0038) — the harness ships the contract,
the safety posture, and reference material; it does not enforce a production runtime.

## Technical Constraints

- Reference orchestrator: Python 3 / standard library only; no third-party runtime deps (ACP-proxy precedent).
- Loop pacing MUST use `ScheduleWakeup`-style self-scheduling; **no busy-spin / no tight polling loop**.
- Canonical store writes MUST be atomic (write-temp-then-rename) so a partial message is never polled.
- Bus message content is **untrusted data**; the reference orchestrator must never execute bus prose as instructions.
- The module is **opt-in** (not active on the harness's own manifest); its companion rules are predict-clean on the harness unless it activates the overlay.

## CI/CD Gates

| Gate | Required? | Notes |
|------|-----------|-------|
| Validator chain passes | Yes | `validate-module-graph`, `validate-module-stability`, `validate-trust-tier`, `validate-required-artifacts`, `validate-catalog-counts`, `validate-list-completeness` |
| Companion-rule check passes | Yes | `validate-companions` — the FR-005 contract-change rule |
| Markdownlint | Yes | All new/edited `.md` |
| Change-log updated | Yes | `docs/project/change-log.md` |
| Reference-orchestrator tests | Manual | Reference material; run manually, not a CI gate (ACP-proxy precedent) |

## Versioning Implications

- New module → `modules_profiles` and `modules_all` counts +1 across every catalog-count site (drives the
  plan's site map).
- OPP-0059 `proposed → accepted`.
- No breaking change to existing modules (additive, opt-in overlay).
- Module ships at `stability: experimental`, `version: 0.1.0`.

## Acceptance Criteria

- `management/agent-coordination` is composable and passes the full validator chain green.
- Both contract artifacts exist and are internally consistent (message types in the schema match those the
  adapter contract and reference orchestrator handle).
- The reference orchestrator runs end-to-end on the native SendMessage channel through the file store, with the
  loop pacing via `ScheduleWakeup` and no busy-spin, and manual tests pass.
- The safety invariants (caps-never-grants, Tier 4/5 human-gated, redaction on `sync`) are stated in the
  contract and honored by the reference orchestrator.
- OPP-0059 is flipped `accepted`; catalog counts, list-completeness, and companions are green; change-log and
  a shared-observations distillation entry are present.
- The three deferred items are enumerated (Implementation Deferral) with their target records.

## Dependencies

- `kernel/base` (trust tiers, companion-rule engine, `validate-knowledge-redaction`, `validate-skill-content`).
- The Claude SendMessage channel (for the native reference adapter only; the contract is transport-agnostic).

## Open Questions

- [ ] Canonical store location convention for a consumer (`.coordination/bus/` vs `.harness/coordination/`) —
  resolve at plan time against the sensitive-path and gitignore conventions.
- [ ] Whether `sync` should have a size/rate cap in v1 or defer that to the deferred linter.
