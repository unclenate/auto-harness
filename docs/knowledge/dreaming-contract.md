<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Out-of-Band Memory Consolidation — Contract

This is the governing contract for the `management/memory-consolidation`
("dreaming") overlay (PRD-0041, promoting OPP-0058). Dreaming is a **propose-only
batch process** that mines cross-session transcripts and emits an
evidence-backed proposed diff against the knowledge tree. It is the out-of-band
**second layer** that complements — never replaces — the in-band PR-boundary
cycle-end distillation rule (PRD-0004): that rule is the floor that fires as each
cycle ends; dreaming runs between sessions, on a dedicated budget, over a corpus
no single in-band cycle can see. The overlay is opt-in; the harness ships this
contract, a template steering file, and a reference orchestrator, not an enforced
runtime (Half-enforced, reference-tool genre).

This document defines four things: the transcript-provider interface, the
steering-file schema, the proposed-diff output contract, and the propose-only
safety spine. v1 duty is the promotion-candidate scan only.

## Transcript-provider interface

A **session transcript** is the ordered event log of one agent session:
messages, tool calls (name, argument digest, result status, error), and
metadata. It is the substrate dreaming mines; without it dreaming has nothing to
see.

The provider mapping is **not** a `module.yaml` key. It lives in a
`transcriptProviders:` block inside the `dreaming-policy.yaml` steering artifact
the overlay already requires, keyed by agent-pack id. This keeps `module.yaml`
schema-clean, matches the `relational-sql` / PRD-0033 "provider config in a
declared artifact" precedent, adds no new file, and is honest that the mapping is
org-specific — which packs are active, and where their transcripts land on this
machine.

Each provider entry declares:

- `location` — a glob or path where this pack's transcripts land.
- `format` — `jsonl` / `ndjson` / `prose` (structured vs. lossy).
- `mode` — `full` / `session-only` / `prose-lossy`.
- `fields` — the capability list: which required fields the transcript carries.
- `permissionScope` — the store-scope the provider is trusted to feed; it MUST
  mirror the target memory store's permission set and MUST NOT exceed
  `corpus.permissionScope`.

**Required fields for `full` mode:** `sessionId`, `timestamp`, `agent/model`,
and a tool-call event stream carrying `status` and `error`. Tool-config failures
are only visible in that stream — the highest-signal class — so a mode without it
cannot detect them.

Per-pack mapping (design against Claude Code first):

| Pack | Source | Mode | Notes |
|------|--------|------|-------|
| `claude-code` | session JSONL transcripts | **full** | richest; the v1 target. Carries session structure already; needs **no** OPP-0057 dependency. |
| `acp` | `.acp/audit/session-log.jsonl` | **full after OPP-0057** | today lacks `sessionId` / `timestamp`; Phase-0 blocked until OPP-0057 adds them to the audit sink. |
| `openclaw` | `HEARTBEAT.md` / daily logs | **prose-lossy** | documented-degraded fallback: freeform prose, no structured tool-call records, so lower confidence and no tool-config-failure detection. |
| `gemini-cli`, `codex-cli`, `cursor` | — | **none** (declared) | honest "none" until a provider is written; the vendor-neutrality acceptance run targets one of these. |

**Degraded modes are declared, not silent.** A `prose-lossy` provider still
contributes, but the evidence bar down-weights it (`proseLossyWeight`) and
dreaming records the mode in each proposal's provenance so a reviewer knows the
confidence basis.

**Permission-scope mirroring is the hard rule.** A provider may not feed a
proposal targeting a store more privileged than the provider's own
`permissionScope`. A run that would cross that boundary is refused, not
down-weighted.

## Steering-file schema

The canonical steering file is `docs/knowledge/dreaming-policy.yaml`; a consumer
copies it from `platform/templates/memory-consolidation/dreaming-policy.yaml` and
edits it. Its blocks:

- **`budget`** — dedicated and declarative: `maxTokens`, `maxSubAgents`,
  `maxProposedChangesPerRun`, `maxCorpusSessions`. **Fail-closed** on the countable
  ceilings — the reference refuses a run whose corpus exceeds `maxCorpusSessions` or
  whose output exceeds `maxProposedChangesPerRun` (it raises rather than truncating,
  so the operator tightens the evidence bar). `maxTokens` is **consumer-implemented**
  (the stdlib reference has no tokenizer); a production runner enforces it fail-closed
  the same way (budget-runaway mitigation).
- **`evidenceBar`** — the signal thresholds: `minPrevalenceSessions` (a pattern
  must recur across at least this many **independent** sessions; default 3),
  `minCitationsPerChange`, and `proseLossyWeight` (the down-weight applied to
  prose-lossy providers).
- **`targetSurfaces`** — the files dreaming may PROPOSE to. The v1 staging
  default is `docs/knowledge/promotion-candidates.md` — dreaming proposes there,
  **never to `operating-principles.md` directly**; a human moves accepted
  candidates through the existing promotion path.
- **`noiseFilters`** — transcript content to ignore.
- **`corpus.permissionScope`** — the corpus's permission set; every provider's
  `permissionScope` must mirror and not exceed it.
- **`transcriptProviders`** — the per-agent-pack mapping described above.

**Governance is split by field-class.** Editing a **threshold value** (what
counts as signal for this org) is operator tuning and is satisfied by a
change-log audit-trail entry. Editing the steering **schema**, or adding a
**target surface** (letting dreaming propose to a new file), is a governance
change and requires an ADR or an operating-principles change — it alters what the
batch process may propose or write to. The overlay's companion rules enforce this
split: a `dreaming-policy.yaml` change requires an ADR, operating-principles, or
change-log entry in the same commit.

## Proposed-diff output contract

Dreaming's only output is a **branch diff** against the knowledge tree. Each
proposed change is a `PROPOSE` block:

```text
### PROPOSE <add | promote | retire | reclassify | re-verify> — <target file>:<location>

- change: <the concrete edit, in ADR-0002 shape for observations>
- evidence:
    - citations: >= N transcripts (sessionId + timestamp + excerpt)
    - prevalence: X independent sessions / Y total, across Z agents
    - mode-basis: full | session-only | prose-lossy
- provenance:
    - Confidence: <derived from prevalence>
    - Severity:   <ADR-0002 enum>
    - run-id, steering-policy version, corpus scope
```

`N` comes from the steering file's `minCitationsPerChange`. Once the audit log
carries `prev_hash` (OPP-0057 / PRD-0040, both merged), a citation SHOULD also
carry the cited event's hash so the citation is verifiable against an unmodified
log entry rather than trusted by count alone; until then a citation is
`sessionId` + `timestamp` + excerpt.

**The per-run manifest.** Every invocation writes one file at
`docs/knowledge/dreaming-runs/<run-id>.md` carrying every `PROPOSE` block with
its evidence, plus the run's provenance (run-id, steering-policy version, corpus
scope, proposal count). The PR body links the manifest; the overlay's companion
rule makes a run manifest require a change-log audit-trail entry in the same
commit. That rule keys on `dreaming-runs/` — a surface only dreaming writes — so
it never fires on a human's `promotion-candidates.md` or `shared-observations.md`
edit, which stay governed by the unchanged knowledge-capture rules.

**Rejected proposals are preserved (a dissent record).** When a human rejects a
proposal, the rejected `PROPOSE` block plus a `Rejected:` rationale line is
recorded back into the run manifest, not discarded. Rejection is the harness's
dissent record for machine-generated knowledge (the analog of an ADR's
rejected-alternatives). A later run's consolidation pass reads prior manifests'
rejected entries and **suppresses re-proposal** of a pattern already declined, so
the institutional reason is not lost and the human is not re-asked the same
question each cycle. A rejected pattern may be re-proposed only if materially new
evidence crosses the bar — and the manifest must then cite what changed.

**Sub-agents assess blind and independently.** Each sub-agent distills and cites
over a **disjoint** transcript partition with no cross-talk, and the orchestrator
consolidates **only after all have returned** — so a pattern's prevalence count
(`X independent sessions across Z agents`) reflects genuinely independent
observations, never one finding echoed N times by sub-agents that saw the same
material. This blind-partition discipline is what makes "prevalence across
independent sessions" an honest evidence bar rather than an artifact of the
fan-out.

## Propose-only — the safety spine

- The job runs **Tier 2**: it writes proposals to a **branch**, and **never
  merges** (Tier 3). The human merge is the gate.
- **No confidence threshold may auto-merge.** A threshold gates whether a change
  is *proposed*, never whether it is *merged*.
- **A direct machine write to the knowledge tree is rejected** — the Letta
  divergence, deliberately not taken. `operating-principles.md` in particular is
  never edited directly; dreaming proposes to the staging surface and a human
  promotes.
- **A run may propose nothing.** A run that finds nothing MUST be able to emit an
  empty proposal set — there is no minimum-output quota, which is the guard
  against cargo-cult-at-scale (manufacturing patterns to justify a budget).
- **`permissionScope` mirroring** and the **fail-closed budget** bound the blast
  radius: dreaming never writes above the corpus's scope and never exceeds its
  declared ceilings. In v1 that scope guarantee is enforced at two seams — the
  provider-vs-corpus scope check at policy-validation time, and the
  operator-authored `targetSurfaces` allowlist a proposal's target must exactly
  match (no path normalization to exploit). A **per-file `permissionScope` map**
  that would let the reference reject an individual proposal whose *target file*
  sits above the corpus scope — independent of the allowlist — is a Phase-2
  refinement; until then the operator is trusted to keep every `targetSurface`
  at or below the corpus scope.

The reviewer of a dreaming PR must: (a) verify the cited transcripts actually
support the pattern; (b) verify prevalence is across **independent** sessions,
not one session cited N times; (c) reject any proposal writing **above** the
corpus's `permissionScope`; and (d) reject a plausible-looking entry backed by
thin or circular evidence.

## v1 scope

v1 duty is the **promotion-candidate scan** only (session-shape §4 gap #1):
detect crystallized, recurring observations and propose them for promotion, as a
human-gated diff landing in the `promotion-candidates.md` staging surface. It is
operator-invoked (no scheduled cadence) and propose-only.

Deferred to their own records: the `validate-dreaming-output` evidence-block
linter; Phase 2 (the back-pressure ratio report and staleness re-verification,
plus the time-boundary trigger); Phase 3 (the §10 doctrine re-verify audit, plus
the count-boundary trigger); and the non-Claude transcript providers with the
vendor-neutrality acceptance run.
