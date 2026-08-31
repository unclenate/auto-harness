<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0057 — ACP Audit → Knowledge-Capture Bridge (`agents/acp` follow-on)

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-08-03
**Last Updated:** 2026-08-31
**Confidence:** medium (the source and target artifacts both exist and are stable — the ACP proxy's audit JSONL and the ADR-0002 observation schema; the open question is the *distillation policy* between them, not whether the endpoints are real)

---

## Thesis

The [`agents/acp`](../../platform/agents/acp/README.md) reference proxy (PRD-0038) already
writes an append-only **runtime audit** — every intercepted `session/request_permission` and
`session/update` tool call lands in `.acp/audit/session-log.jsonl` with its governance context
(`kind`, `path`, `tier`, `posture`, `sensitive`, `autoDecision`). This is the audit layer ACP
itself lacks. But today that log is a **dead end**: it records what the tiers decided at runtime
and nothing reads it back. The harness's institutional memory — `docs/knowledge/shared-observations.md`
under the ADR-0002 structured-observation schema — never learns from it.

This OPP proposes the **audit → knowledge-capture bridge**: a session-boundary distillation step
that reconciles the governance-relevant subset of the ACP proxy's runtime audit into ADR-0002
observations. It **closes the loop** — runtime enforcement decisions (a tier-5 action blocked at
the seam, an agent repeatedly hitting a tier-4 gate, a sensitive-path near-miss) become durable
governance knowledge that can, in turn, drive tier and companion-rule refinement. It is the
scoped "Audit bridge" follow-on called out in [OPP-0056](OPP-0056-agent-client-protocol-governance-bridge.md)
§ Scope and deferred by [PRD-0037](../requirements/PRD-0037-acp-governance-bridge.md) /
PRD-0038 to its own record.

## Why now

The two endpoints are built and stable, which is exactly the precondition this bridge needed:

- **Source exists.** PRD-0038 shipped the proxy's `_AuditSink` — a JSONL session log with two
  record shapes (`permission` and `tool_call`), sequence-numbered and append-only. Its schema is
  concrete, not hypothetical.
- **Target exists and is enforced.** ADR-0002 fixes the observation structure; `management/knowledge-capture`
  is active on the harness; `validate-observation-hygiene.sh` gates each newly-added observation
  against the schema with **enforce-as-locked** enums (PRD-0034 § 10). Any bridge output must land
  on that schema or fail CI.
- **The pattern is precedented.** The harness already has a cycle-end distillation workflow
  (`platform/workflow/cycle-end-distillation.md`) and a review-trigger taxonomy
  (`platform/workflow/session-shape.md`) whose **session-boundary** class is the natural trigger
  for this bridge. It is a new *source* feeding an existing *discipline*, not a new discipline.

## The two artifacts it reconciles

| | Source — ACP proxy audit JSONL | Target — ADR-0002 observation |
|---|---|---|
| Location | `.acp/audit/session-log.jsonl` | `docs/knowledge/shared-observations.md` |
| Author | Machine (the proxy) | Human / agent (curated) |
| Grain | Per tool call (high volume) | Per synthesis-worthy signal (low volume) |
| Shape | Reference proxy *currently emits* `{event, kind, path, tier, posture, sensitive, autoDecision, seq}` (permission) / `{event, toolCallId, title, kind, status, seq}` (tool_call); the *declared contract* (`tier-policy.yaml` → `audit.record`) is `[timestamp, sessionId, toolCallId, kind, targetPath, tier, optionSelected, humanAuthorizer]` — see Precondition § | Context, Observation, Implication, Confidence, Severity, Contributed by |
| Discipline | Append-only ledger (structured-agent-ledger species) | Structured template, enforce-as-locked enums |
| Purpose | Runtime evidence of what the tiers decided | Durable, synthesis-grade institutional knowledge |

The gap between them is **distillation**, not translation: the source is exhaustive machine
telemetry; the target is a curated signal. Mapping one row to one observation would flood the
ledger and defeat ADR-0002's synthesis purpose (its stated "over-friction" and
"looks-rigorous-when-it-isn't" negatives). The bridge's whole job is deciding **what is worth
promoting, at what grain, with what honesty about confidence.**

## The bridge design

### 1. What crosses (the governance waterline)

Only the governance-relevant subset is promoted; routine low-tier traffic stays in the raw log:

| Runtime signal in the audit log | Promote? |
|---|---|
| Tier 0–1 auto-approvals (read/search/test/build) | **No** — below the waterline; noise |
| Tier 2 workspace mutations, ordinary | **No** (aggregate count only, as context) |
| Tier 3+ escalation via `sensitivePaths` / entrypoint | **Yes** |
| Any `reject_*` decision (a gate actually fired) | **Yes** |
| Sensitive-path touch (`sensitive: true`) | **Yes** |
| Tier-5 block-at-seam (a remote/prod action was attempted and hard-blocked) | **Yes — always** |
| Recurring pattern (same gate hit N times in a session) | **Yes** (as a single rolled-up signal) |

### 2. Grain — per-session rollup at the session boundary

The bridge runs at the **session boundary** (the existing review-trigger class), reads the
session's JSONL, and emits **one draft observation per notable governance theme** in that session
— not one per event. A session with three tier-4 dependency-install gates and one tier-5 block
yields at most two draft observations (the recurring tier-4 pattern; the tier-5 block), not four.

### 3. Severity — mechanical map; Confidence honest-low

The bridge mechanically populates the fields it can and defers the one that needs judgment:

| Field | How the bridge fills it |
|---|---|
| `Context` | Mechanical — session id, agent, the triggering run of events |
| `Observation` | Mechanical — the specific factual signal (kind, path, tier, decision, counts) |
| `Implication` | **Left as a draft prompt** — the one field that genuinely needs synthesis; the ratifier writes it |
| `Confidence` | Defaults **`low`** — machine-inferred, awaiting human ratification (honest per ADR-0002's "unjustified Confidence" negative) |
| `Severity` | Mechanical tier→Severity map (see below), overridable by the ratifier |
| `Contributed by` | The bridge tool name + ISO date, amended to the ratifier on acceptance |

Tier → Severity map (lands on the enforce-as-locked enum):

- Tier 5 block-at-seam → **`risk-bearing`**
- Tier 4 environment-altering authorization, or a tier-3+ escalation that reveals a *missing*
  gate → **`architectural`**
- Tier 3 git/shell escalation, recurring denials → **`governance-relevant`**
- Everything else that crosses the waterline → **`informational`**

Because the map targets the ADR-0002 **enforce-as-locked** enum by construction, the bridge
*cannot* mint off-enum Severities — a small structural win against the live off-enum drift the
enum lock was introduced to stop (existing hand-authored observations still carry off-enum values
such as `Severity: process`).

### 4. Posture — draft-then-ratify, never auto-append

The bridge **never writes directly** to the enforced `shared-observations.md`. It emits observation
**drafts** to a staging surface; a human or agent ratifies them into the ledger (where
`validate-observation-hygiene.sh` then gates them normally). This preserves ADR-0002's curation
guarantee and matches the [reference-tool genre boundary](../requirements/PRD-0038-acp-governance-proxy-reference.md)
established for the proxy: the harness ships a **declarative contract** (which events cross, the
tier→Severity map) plus a **reference helper** (the distillation script) — **not** an enforced
auto-writer. Recommended § 10 classification: **Half-enforced** (the harness owns the promotion
policy; the consumer runs the helper and ratifies) — confirmed with a § 10 claim table at PRD time,
as OPP-0056 deferred.

### 5. Precondition — the audit log must carry `sessionId` + `timestamp`

Per-session grain and the mechanical `Context` field both require the source records to carry a
**`sessionId`** (to slice "this session") and a **`timestamp`** (to order and date the resulting
observation). Today the two audit schemas in the shipped `agents/acp` module diverge and neither is
sufficient as-is:

- **Declared contract** (`tier-policy.yaml` → `audit.record`) *does* list `timestamp` and
  `sessionId` (plus `targetPath`, `optionSelected`, `humanAuthorizer`).
- **Reference proxy** (`_AuditSink`) *actually emits* `path`/`autoDecision`/`seq` and carries
  **neither `sessionId` nor `timestamp`**.

So this bridge has a hard dependency: the audit log must first be reconciled to a single
authoritative schema that includes `sessionId` + `timestamp`. Recommended resolution — treat the
`tier-policy.yaml` `audit.record` as the **contract of record** and extend the reference proxy to
emit it (this is the natural home in the *production-hardening* follow-on, or a precondition task of
this one). The `validate-acp-audit.sh` linter (separate follow-on) is what durably keeps proxy
output and the contract from drifting again. Until the schema is reconciled, the bridge cannot do
per-session rollup — this is the first thing the PRD must sequence.

## Scope (decomposed)

| Sub-component | What it does | Disposition |
|---|---|---|
| **Promotion contract** | Declarative spec: the governance waterline, the tier→Severity map, the draft-then-ratify rule | **Core** |
| **Distillation helper** | Reference script reading `.acp/audit/session-log.jsonl` → emits ADR-0002 observation drafts (stdlib, like the proxy) | **Core (reference material)** |
| **Staging surface** | Where drafts land for ratification (a drafts file / the `query-observations.sh` path) — resolve at PRD time | Core |
| **Recurring-pattern rollup** | Collapse repeated same-gate events into one signal | Part of the helper |
| **Audit-schema linter** | `validate-acp-audit.sh` — lints the JSONL records against the proxy's audit schema | **Separate follow-on** (structured-agent-ledger sibling; own OPP) |
| **Auto-ratification / CI auto-append** | Machine writes straight to the enforced ledger | **Rejected** — defeats ADR-0002 curation |

## Approaches considered

1. **Session-boundary distillation, draft-then-ratify (recommended).** A reference helper run at
   the session boundary produces observation drafts a human/agent ratifies. Honest about
   confidence, preserves curation, reuses the existing distillation discipline, respects the
   reference-tool genre. Cost: it is advisory — nothing forces the ratification to happen.
2. **Real-time bridge inside the proxy.** The proxy emits observations as governance events occur.
   Tighter loop, but couples the runtime wire to the knowledge ledger, floods it without
   session-level aggregation, and violates the genre boundary (the proxy would become an enforced
   writer). Rejected.
3. **Fully mechanical auto-append gated only by observation-hygiene.** Zero human step; the map is
   the whole policy. Fastest, but produces exactly the "looks rigorous when it isn't" observations
   ADR-0002 warns against, and the enforce-as-locked validator checks *shape*, not *judgment*.
   Rejected as the default; the mechanical fields are reused *inside* approach 1 as draft scaffolding.

## Open design questions (for the PRD)

- **Audit-schema reconciliation (sequence first).** Which schema is authoritative — the
  `tier-policy.yaml` `audit.record` contract or the reference proxy's current output — and how the
  proxy is extended to emit `sessionId` + `timestamp` (see Precondition §). Nothing downstream works
  until this is settled.
- **Staging surface** — a dedicated drafts artifact, vs. routing through `query-observations.sh`,
  vs. an agent-read prompt at session end. Where do drafts live before ratification?
- **Session-boundary trigger mechanics** — hook, manual invocation, or agent-cycle step; how the
  bridge knows a session ended and which JSONL slice is "this session."
- **Recurring-pattern threshold** — how many repeats collapse into one rolled-up signal, and how
  that count is expressed in the `Observation`.
- **`Implication` drafting** — leave blank for the ratifier, or have an agent propose it (and if
  so, how to keep Confidence honest).
- **Relationship to the audit-schema linter** — this OPP assumes `validate-acp-audit.sh` is a
  separate record; confirm the split at PRD time.
- **Feedback into policy** — the aspirational end state: promoted observations that recur
  (e.g. a tier-4 gate hit every session) should *suggest* a tier or companion-rule change. Is that
  in scope for the first PRD or a third phase?

## Risks / Open Questions

- **Advisory-at-runtime, again.** Draft-then-ratify means the loop only closes if someone ratifies.
  Mitigate by making the session-boundary trigger part of the cycle-end discipline, not an opt-in
  afterthought — but accept it is a nudge, not a gate (consistent with the harness genre).
- **Noise vs. signal calibration.** Too low a waterline floods the ledger; too high and the bridge
  captures nothing. The waterline table above is the starting calibration, to tune against real
  session logs.
- **Confidence inflation.** A mechanical draft that *looks* authored can smuggle unjustified
  confidence into the ledger. Mitigated by defaulting `Confidence: low` and requiring a human
  `Implication`.
- **Schema drift between endpoints.** Already live: the `tier-policy.yaml` `audit.record` contract
  and the reference proxy's emitted fields diverge today (see Precondition §), and neither yet
  carries `sessionId`/`timestamp`. If they drift again after reconciliation the bridge breaks
  silently. The separate `validate-acp-audit.sh` linter (own OPP) is the durable guard; until it
  exists the bridge pins to whichever schema the PRD ratifies as authoritative.

## Relationship — closes the runtime → policy loop

OPP-0056 mapped policy **onto** the runtime (tiers → permission options). This bridge maps the
runtime **back into** policy (audit → knowledge → tier/rule refinement). Together they make the
`agents/acp` integration a full cycle: the harness governs the session at the moment of action,
*and* learns from what happened. It composes with `management/knowledge-capture` (the target
ledger), extends the structured-agent-ledger gate species (the audit JSONL is itself an
append-only ledger), and stays inside the reference-tool genre boundary the proxy established —
no new enforced runtime.

## Disposition

**Proposed (2026-08-03).** Recommended for a PRD that specifies the promotion contract (the
governance waterline + tier→Severity map + draft-then-ratify rule) and the reference distillation
helper, resolving the open questions above (staging surface; session-boundary trigger; recurring-
pattern threshold; `Implication` drafting; the audit-schema-linter split; whether policy-feedback
is in the first phase). The waterline and Severity map in this record are the specified starting
point, mirroring how OPP-0056 carried its wedge table into PRD-0037. The PRD must **sequence the
audit-schema reconciliation first** (Precondition §) — per-session distillation is blocked until the
log carries `sessionId` + `timestamp`. Half-day-to-day-scoped per sub-component; the audit-schema
linter and the policy-feedback phase remain their own records.

## Promotion

**Accepted (2026-08-31)** — promoted via **PRD-0040** (`docs/requirements/PRD-0040-acp-audit-bridge.md`).
The PRD sequences the audit-schema reconciliation first (adopting the `tier-policy.yaml` `audit.record`
as the contract of record and extending the reference proxy to emit `sessionId` + `timestamp`, which are
declared but not currently emitted — a schema *divergence*, not a flat absence), and bakes G6
tamper-evidence into the record's first authoritative definition (`actor` + a keyless `prev_hash` chain;
cryptographic signatures deferred). It is named the shared dependency of dreaming (OPP-0058), the
coordination bus (PRD-0039), and the verdict ledger (OPP-0052). Implementation (proxy extension + bridge
transform + reference chain-verify helper) is a subsequent phase; the audit-schema linter and the
policy-feedback phase remain their own records.
