<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0040: ACP Audit → Knowledge-Capture Bridge, with a Tamper-Evident Audit Record

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-08-31 | **Review Cycle:** on-change

**Status:** Accepted
**Date:** 2026-08-31
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- **Promotes:** [OPP-0057](../opportunities/OPP-0057-acp-audit-knowledge-capture-bridge.md) — ACP audit → knowledge-capture bridge (flips `proposed → accepted` on acceptance).
- **Keystone for:** OPP-0058 (dreaming) names this bridge its **Phase-0 precondition** for the ACP transcript provider; `management/agent-coordination` (PRD-0039) coordination bus; OPP-0052 federated verdict ledger. All three build integrity concerns on the reconciled audit record, which is why the tamper-evidence field (`prev_hash`) lands in the record's **first** authoritative definition here, not as a later migration on a shared format.
- **Genre precedent:** `agents/acp` (PRD-0037 / PRD-0038) — declarative contract + reference implementation, **Half-enforced**; this PRD follows the same reference-tool genre.
- **Design input (external):** Kang & Diponegoro, "Governance Gaps in Agent Interoperability Protocols" (arXiv:2606.31498, Jun 2026) — dimension **G6 (audit/replay)** is the external justification for designing the record tamper-evident up front. That paper's "ACP" is IBM's Agent *Communication* Protocol; this PRD's ACP is the Agent *Client* Protocol (`agents/acp`) — a documented acronym collision, not the same protocol.

## Problem

OPP-0057 identified a hard dependency: turning the ACP proxy's audit log into per-session knowledge-capture observations requires each record to carry a **`sessionId`** (to slice "this session") and a **`timestamp`** (to order and date the resulting observation). Today the ACP audit surface is **internally divergent** — not flatly missing the fields:

- The **declared contract** (`platform/agents/acp/tier-policy.yaml` → `audit.record`) already lists `[timestamp, sessionId, toolCallId, kind, targetPath, tier, optionSelected, humanAuthorizer]`.
- The **reference proxy** (`platform/agents/acp/reference-proxy/proxy.py`, `_AuditSink`) actually emits `[event, id, kind, path, tier, posture, sensitive, autoDecision, seq]` for permission records and `[event, toolCallId, title, kind, status, seq]` for tool-call records — carrying **neither `sessionId` nor `timestamp`**.

So the bridge cannot run until the two are reconciled to one authoritative schema. Separately, the record is trustworthy today only because nobody edits it — there is no tamper-evidence and no replay guarantee. Three downstream consumers (dreaming, the coordination bus, the verdict ledger) will each build integrity concerns on top of this record; adding a hash chain after they lock in is a migration on a shared format.

## Goals

1. Reconcile the ACP audit surface to a single authoritative `audit.record` schema.
2. Make that record **tamper-evident by design** (G6) in the same pass — before any consumer depends on the format.
3. Define the **audit → observation** transform (the OPP-0057 bridge) sliced per `sessionId`.
4. Compose with — never duplicate — the correlation disciplines already load-bearing elsewhere (the bus's dispatch-minted `id`; the verdict ledger's canonical shared `taskId`).

## Functional Requirements

| FR | Requirement | §10 classification |
|---|---|---|
| FR-001 | **Contract of record.** Adopt the `tier-policy.yaml` `audit.record` as the single authoritative schema; extend the reference proxy `_AuditSink` to emit it in full (adds `sessionId` + `timestamp`, currently absent from emission). | Enforced *when a project runs the ACP bridge* (the proxy emits the record); Asserted in the harness (declarative contract). Half-enforced. |
| FR-002 | **Tamper-evident record (G6-by-design).** The authoritative record gains two fields in the same reconciliation: `actor` (the acting agent id, distinct from `humanAuthorizer` = the approver) and `prev_hash` (a **keyless SHA-256** over a deterministic serialization of the immediately-prior record in the same `sessionId` chain). This yields an ordered, replayable, reconstructible log — integrity beyond wall-clock `timestamp` sorting — with **zero key management**. An optional cryptographic `signature` is **explicitly deferred** as future hardening (it needs actor-key custody the reference must not pretend to solve — the `validate-agent-bus.sh` deferral discipline). | Enforced at emission (the proxy computes `prev_hash`); chain-verification is a reference helper, not a CI gate in v1. |
| FR-003 | **Audit → observation bridge.** A transform reads the reconciled audit log, slices by `sessionId`, and emits ADR-0002-shaped knowledge-capture observations (the OPP-0057 core). Each observation's provenance cites `sessionId` + `timestamp` + the event `prev_hash`, so a downstream verifier can confirm the cited event exists **unmodified**. | Reference material (Half-enforced); the observation output still passes `validate-observation-hygiene`. |
| FR-004 | **Compose with existing correlation.** The record's `sessionId` is the **per-session actor-log** axis; it is distinct from, and composes with, the coordination bus's cross-agent `id` and the verdict ledger's `taskId` (the cross-task thread axis). `prev_hash` chains *within* a `sessionId`; the bus `id` / verdict `taskId` thread *across* sessions. Stated explicitly so consumers do not mint a third correlation primitive. | Asserted (documented relationship). |
| FR-005 | **Consumer forward-references.** OPP-0058 (dreaming) evidence citations, the coordination-bus audit trail, and the OPP-0052 verdict ledger each reference this record as their integrity substrate; this PRD is named their shared dependency. | Doc-only. |

## Out of scope / deferred to their own records

- **Cryptographic signatures** (`signature` field) — future hardening; needs key custody. Keyless `prev_hash` is the v1 floor.
- **A `validate-audit-chain.sh` CI gate** — deferred until the record survives at least one real bridge cycle (the `validate-agent-bus.sh` discipline). v1 ships a reference chain-verify helper, not a gate.
- **Cross-vendor audit adapters** (non-ACP transports emitting the record) — the coordination bus already carries `from` / `ts` / `id`; mapping those onto the record is a follow-on.
- **Implementation** (the proxy extension, the bridge transform, the reference chain-verify helper) is a subsequent phase; this PRD ratifies the reconciled schema and the G6-by-design decision so downstream consumers can depend on the shape now.

## §10 posture

**Half-enforced**, consistent with `agents/acp` (PRD-0038): the harness ships the reconciled **contract** plus a reference proxy/bridge that honors it; a consumer running the bridge gets the enforced emission. Tamper-evidence is a *design property of the record*, enforced at emission by the reference and assertable by any consumer, not a harness CI gate in v1.

## Open questions

1. Is `sessionId` a newly-minted id, or does the ACP proxy already carry a session handle (ACP's `session/new` establishes one) it should reuse? Bias: **reuse** — do not mint a parallel id.
2. Pin the canonical hash serialization (sorted keys, no insignificant whitespace) so `prev_hash` is reproducible across languages — otherwise the chain is unverifiable from a non-Python adapter.
3. Chain scope: `prev_hash` over the `sessionId` chain (per-actor log) is the v1 proposal; whether a *cross-session* chain keyed on `taskId` is also wanted is an OPP-0052 question, not this PRD's.
