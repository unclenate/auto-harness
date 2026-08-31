<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Management Overlay: Out-of-Band Memory Consolidation ("Dreaming")

**Depends on:** `kernel/base`, `knowledge-capture`.
**Conflicts with:** None.

This overlay governs an **out-of-band second layer** of memory
consolidation — a propose-only batch process that mines cross-session
transcripts and proposes evidence-backed changes to the knowledge tree. It
**complements, never replaces,** the in-band cycle-end distillation rule
(PRD-0004): that rule remains the PR-boundary floor that fires as each cycle
ends; dreaming runs **between** sessions, on a **dedicated budget**, over a
**cross-session corpus** that no single in-band cycle can see. It is a
default-off, opt-in cross-cutting concern (OPP-0058).

Its change class is *out-of-band consolidation* — the transcript-provider
contract, the batch job's budget/steering, the proposed-diff output contract,
and the evidence bar. That is a distinct change class from
`knowledge-capture`'s *in-band capture* (the observation schema and the
PR-boundary rule), which is why dreaming is a separate overlay that `dependsOn`
`knowledge-capture` rather than a `knowledge-capture` v2.

## What This Overlay Governs

The out-of-band mining loop: select a transcript corpus (respecting its
permission scope), partition it, fan blind sub-agents over disjoint slices,
consolidate their distilled returns against the *current* store, and emit a
proposed diff plus a run manifest. v1 duty is the **promotion-candidate scan**
only (session-shape §4 gap #1) — detecting crystallized, recurring observations
and proposing them for promotion, always as a human-gated diff, never a direct
write.

## What This Overlay Requires

One declarative forcing artifact:

- **`docs/knowledge/dreaming-policy.yaml`** — the steering file: the budget
  (fail-closed), the evidence bar (`minPrevalenceSessions`,
  `minCitationsPerChange`, `proseLossyWeight`), the target surfaces dreaming
  may propose to, the noise filters, the corpus `permissionScope`, and the
  per-agent-pack `transcriptProviders` mapping. A template a consumer copies
  and edits lives at
  [`platform/templates/memory-consolidation/`](../../../templates/memory-consolidation/dreaming-policy.yaml).

## Contract

The governing contract is
[`docs/knowledge/dreaming-contract.md`](../../../../docs/knowledge/dreaming-contract.md) —
the transcript-provider interface, the steering-file schema, the proposed-diff
output contract, and the propose-only / evidence-bar safety rules. It is the
source of truth; this fragment and the reference orchestrator both defer to it.

## Reference orchestrator

A thin, runnable **reference** lives at
[`reference/dreaming/`](../../../../reference/dreaming/README.md) — a Python 3
stdlib policy loader + evidence bar, a blind fan-out consolidation pass over an
injected `distill_fn` sub-agent seam, and an operator-invoked run that emits a
proposed diff + a run manifest, with manual TDD tests. It is **reference
material, not enforced runtime** (the `agents/acp` proxy precedent): it
demonstrates the governed shape, it does not police it.

## Trust posture

- **tier.declared 2 — propose-only.** The job writes proposals to a **branch**
  and **never merges** (Tier 3). A human promotes. This makes the "never Tier
  3" thesis a manifest fact the trust-tier validator can see, not prose-only —
  it mirrors the `knowledge-capture` parent.
- **A direct machine write to the knowledge tree is rejected** — this is the
  Letta divergence, deliberately not taken. No confidence threshold may
  auto-merge; a threshold gates whether a change is *proposed*, never whether it
  is *merged*.
- **The evidence bar is the safety spine.** A proposed change must recur across
  `minPrevalenceSessions` genuinely **independent** sessions with
  `minCitationsPerChange` verifiable citations. Prose-lossy providers are
  down-weighted, not silently trusted.
- **`permissionScope` mirroring is the hard rule.** A provider may not feed a
  proposal targeting a store more privileged than the provider's own scope.
- **Degraded modes are declared, not silent** — a `prose-lossy` provider still
  contributes, but each proposal records its mode-basis so a reviewer knows the
  confidence basis.

## §10 claim classification

Half-enforced (reference-tool genre). The contract + `validate-companions`
(a steering-schema change needs an ADR/operating-principles; a run manifest
needs a change-log entry) are **Enforced**; the evidence bar and the
proposed-diff shape are honored by the reference orchestrator and confirmed at
review — **Asserted-only** in v1 until the deferred `validate-dreaming-output`
linter checks a live run manifest. This mirrors how `management/agent-coordination`
deferred its `validate-agent-bus.sh` linter out of the shipped `validators:`
list.

## Deferred to their own records

- **`validate-dreaming-output`** — the evidence-block content lint (module-gated,
  diff-scoped to `dreaming-runs/`, `--scan-file`-seamed), deferred to its own
  record; the manifest's `validators:` list is `[validate-companions]` only.
- **Phase 2** — the back-pressure ratio report (gap #3) + staleness
  re-verification, and the time-boundary (scheduled CI) trigger.
- **Phase 3** — the §10 doctrine re-verify audit (gap #4) + the count-boundary
  trigger.
- **Non-Claude transcript providers** — `acp` (after OPP-0057), `openclaw`
  (prose-lossy), and the other packs, with the vendor-neutrality acceptance run.

## When to activate

Activate on a consumer that has a **transcript substrate** and wants a governed,
out-of-band consolidation loop over its cross-session corpus. Not needed where
no transcripts exist — the in-band cycle-end rule remains the floor there.
