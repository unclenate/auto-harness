<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0061 — `validate-agent-bus.sh`: a contract-conformance linter for the agent-coordination bus

**Status:** accepted
**Owner:** @unclenate · **Created/Updated:** 2026-09-01
**Confidence:** high (design; the check-set is a direct transcription of a shipped, stable contract)
**Parent:** PRD-0039 / management/agent-coordination (promotes OPP-0059)

## Thesis

PRD-0039 shipped the agent-coordination overlay with its message-schema, lifecycle, and `tier_ceiling`
semantics classified **§10 Asserted-only** — honored by adapters and confirmed at review, but with no
mechanism that *checks* a bus session against the contract. Three surfaces name the same deferred fix:
the module README ("Asserted-only in v1 until the deferred `validate-agent-bus.sh` linter checks a live
cycle"), `control-loop-contract.md` (the `sync` size/rate caps are "deferred to the `validate-agent-bus.sh`
linter"), and PRD-0040 (the "`validate-agent-bus.sh` deferral discipline"). This OPP is that record: build
the linter, move the schema/lifecycle/`tier_ceiling` checks from **Asserted-only → checkable**, and set the
`sync` caps the contract deferred to it.

**Deferral criterion met.** OPP-0059's candidate stub deferred the linter "until the schema survives ≥ 2
real cycles." The schema is now shipped and stable (PRD-0039 merged; OPP-0060 proved a live non-Claude
round-trip; the native adapter drives it in-repo), so formalizing a conformance check no longer risks
over-fitting a moving schema.

## Design

### Scan model — a fixture-tested runtime linter (reference-tool genre)

Bus messages are **runtime, gitignored, ephemeral** (`.coordination/bus/`), so there is no committed bus
log for a per-PR CI gate to read. The linter is therefore shaped like `validate-observation-hygiene`:

- **`--scan-file <bus-transcript.jsonl>`** — validate every message (one JSON object per line) against the
  contract. This is the primary mode: an operator points it at a live `.coordination/bus/**/inbox|outbox`
  session (or a captured transcript) to check a real cycle.
- **CI-tested against committed fixtures.** `platform/validators/test/fixtures/agent-bus/` gains a
  `valid.jsonl` (a full `dispatch→ack→progress→done` + a `verdict` + a `sync` cycle) and per-violation
  invalid fixtures; a self-test asserts the linter accepts the valid transcript and rejects each violation
  with a non-zero exit. CI runs the self-test, proving the linter works — it does **not** gate every PR
  against a live bus (there is none to gate).

**§10 effect:** this moves the message-schema / lifecycle / `tier_ceiling` checks from **Asserted-only →
Half-enforced** (an operator-run, fixture-tested mechanism now exists), consistent with the overlay's
reference-tool genre. It does **not** claim full per-PR *Enforced* status — that would require a committed
bus artifact the runtime model does not produce.

### Check-set (a direct transcription of `control-loop-contract.md`)

1. **Envelope:** the seven fields present; `type` ∈ the seven; `tier_ceiling` an `int` (reject `bool` — the
   `bus.py` rule); `ts` a parseable ISO-8601 stamp; `to`/`from`/`id` non-empty (or `to == "*"` for `sync`).
2. **Per-type required payload keys:** `dispatch→task` (optional integer `deadline`); `progress→note`;
   `done→result`; `block→reason`; `sync→state`; `verdict→decision ∈ {approve, reject, revise}` + `rationale`;
   `ack→` none.
3. **Correlation:** every message except `dispatch` and `sync` carries a non-empty `id`.
4. **Lifecycle (per correlation `id`):** a valid ordered chain `dispatch → ack → progress* →
   (done | block | verdict)`; at most one terminal per id; a post-`block` `dispatch` reusing the same `id`
   (retry) is valid; `sync` is out-of-band and exempt. Flag an orphan response (no dispatch for the id),
   a double-terminal, or a response before its `ack`.
5. **`tier_ceiling` sanity:** integer in `0..5`; a dispatch with `tier_ceiling ≥ 4` is flagged as
   human-gated (informational — the caps-never-grants arithmetic needs the recipient's own policy, which a
   transcript does not carry, so the linter checks form + flags the high-tier case rather than re-deriving
   the effective tier).
6. **`sync` shape:** `to == "*"`, `state` present. (Payload *redaction* stays the job of
   `validate-knowledge-redaction`, which the contract already binds `sync` to — not duplicated here.)

### `sync` caps (the contract defers these to this linter)

The contract states "v1 no cap." This OPP proposes concrete, **configurable** defaults, reported at
**WARN** severity in v1 (exit 2, not a hard fail), so the caps become *visible and tunable* without
breaking an existing operator who was told there was no cap:

- **`maxSyncStateBytes`** (default **8192**) — the serialized `state` of one `sync` message.
- **`maxSyncPerSenderPerWindow`** (default **1 per tick-equivalent**, i.e. coalesce) — a rate signal that a
  sender is broadcasting faster than a supervisor can absorb.

Both live in the transcript-provider/steering surface an operator supplies to `--scan-file` (a small
`agent-bus-policy` block, or CLI flags), not hard-coded. **Q1 for ratification:** the values, and
WARN-vs-ENFORCE in v1.

## Open questions (biases to resolve at ratification)

> **Ratified 2026-09-01 — accepted as proposed.** Q1: caps 8 KiB / coalesce at
> **WARN** in v1 (advisory, non-blocking). Q2: **ERROR** on structural breaches
> (orphan response, double-terminal, response-before-ack, bad envelope/payload),
> **WARN** on soft signals (Tier ≥ 4 dispatch, `sync` caps). Q3: JSONL
> `--scan-file` only in v1; the live-`.coordination/`-tree walker is deferred.
> Implemented in the same change as this acceptance.

- **Q1 — `sync` cap values + severity.** Are 8 KiB / coalesce sensible, and should v1 WARN (recommended,
  honors "no cap in v1" continuity) or hard-ENFORCE?
- **Q2 — lifecycle strictness.** Reject an orphan/double-terminal as an ERROR, or WARN? Recommendation:
  ERROR for structural violations (double-terminal, orphan response), since those are unambiguous contract
  breaches; WARN for the softer signals (high tier, caps).
- **Q3 — transcript source shape.** Standardize on a concatenated JSONL of a session's inbox+outbox
  messages (recommended, simplest), vs. teaching the linter to walk a live `.coordination/bus/` tree
  directly. Recommendation: JSONL `--scan-file` only in v1; a live-tree walker is a thin follow-up.

## Scope

**In:** `platform/validators/validate-agent-bus.sh` (`--scan-file` mode); the fixture corpus + self-test;
the §10 reclassification (Asserted-only → Half-enforced) in the module README and `control-loop-contract.md`
(remove the "deferred to the linter" language, state the caps); a catalog-count bump
(`validators 26 → 27`) with its coupled entrypoint/count propagation.

**Deferred to their own records:** a live-`.coordination/`-tree walker (Q3); a long-running daemon/`--watch`
mode; the `.acked`/`.sent` symlink-guard residual (a separate Low bus-hardening item, unrelated to the
linter); a non-Claude live acceptance run of the linter against a real cross-vendor cycle.

## Disposition

**Accepted and implemented 2026-09-01** (OPP → implementation without a PRD, per the harness cadence for a
single self-contained validator; design contract = this OPP). Delivered in the accepting change:
`platform/validators/validate-agent-bus.sh` (`--scan-file` mode implementing the full check-set above), a
committed fixture corpus (`platform/validators/test/fixtures/agent-bus/`: a valid transcript incl. a
`block`→retry, plus per-violation invalid fixtures and a `sync`-cap WARN fixture) with a
`TestValidateAgentBus` self-test in the integration harness, the §10 reclassification (Asserted-only →
Half-enforced) in the module README and `control-loop-contract.md` (`sync` caps now stated, not deferred),
and the coupled `validators 26 → 27` count propagation. Deferred to their own records as listed in Scope
(live-tree walker, `--watch`, the `.acked`/`.sent` symlink residual, a non-Claude live acceptance run).
