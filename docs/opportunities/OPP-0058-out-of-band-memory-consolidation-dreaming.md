<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0058 — Out-of-Band Memory Consolidation ("Dreaming")

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-08-11
**Last Updated:** 2026-08-11
**Confidence:** medium (the failure class is repo-documented and the design has convergent cross-lab precedent; the open variables are packaging, budget/cadence, and the transcript substrate — which depends on OPP-0057)

---

## Thesis

Auto-harness has guardrailed destinations for institutional memory (`shared-observations.md`,
`operating-principles.md`) and exactly **one fully-wired trigger-class** — the PR-boundary
cycle-end distillation rule (PRD-0004). It has **no out-of-band consolidation process**: nothing
with a *dedicated budget* and *cross-session visibility* mines session transcripts for recurring
patterns, proposes promotions, retires stale entries, or reports back-pressure. The harness's own
review-trigger audit (`session-shape.md` § 4) names three synthesis reviews that are *declared in
prose but fired by no automation* — the operating-principles promotion scan (#1), the knowledge-tree
back-pressure audit (#3), and the periodic §10 doctrine audit (#4) — and every one of them wants a
session-, time-, or count-boundary trigger the harness has not built.

Define and ship a **governed out-of-band memory-consolidation process** — scheduled/operator-invoked,
batch, transcript-grounded, steerable per org, and strictly **propose-only** — whose output is a
branch PR against the knowledge tree carrying, per change, an *evidence block* (cited transcripts +
prevalence stats + ADR-0002 provenance), flowing through the existing companion-rule and review-gate
machinery. **One well-specified module fires all three declared-but-unfired synthesis reviews.** It
complements the PR-boundary cycle-end rule — it consumes what in-band capture produces and proposes
what a single in-band session structurally *cannot* see — and it never replaces or weakens it.

## The two-layer model (in-band capture vs. out-of-band consolidation)

| Axis | In-band capture (shipped: PRD-0004) | Out-of-band consolidation (this OPP) |
|------|-------------------------------------|--------------------------------------|
| When | At PR boundary, inside the working session | Between sessions, on its own cadence |
| Budget | Shares the task session's context/budget | **Dedicated** budget, separate from any task |
| Visibility | One session's own work | **Cross-session / cross-agent** corpus of transcripts |
| Produces | A single observation, authored in-flow | A *proposed diff* of many changes, each evidence-backed |
| Write authority | Human authors, human merges | Machine **proposes only**; human merges (Tier 2, never Tier 3) |
| Failure mode it fixes | Decision without rationale | Declared-but-unfired synthesis (the 40-day dormancy) |

The two are complementary layers, not rivals: in-band capture cannot see patterns recurring *across*
sessions (structural visibility limit), and forcing cross-session synthesis into a task session buys
it at the cost of the task's own attention budget (the "split focus" problem). Out-of-band
consolidation is the missing second layer. This mirrors the harness's own genre discipline — the
same way `agents/acp` added a runtime layer without the harness leaving its policy layer.

## Origin / Evidence

- **`session-shape.md` § 4 (verified)** — the harness's own audit of *declared-but-unfired* reviews.
  Gap **#1** (operating-principles promotion scan, `docs/knowledge/README.md:87` "not on a fixed
  cadence"), gap **#3** (knowledge-tree back-pressure audit, `OPP-0032:23`), and gap **#4** (periodic
  §10 doctrine audit — `operating-principles.md` §10 declares re-evaluation "at a quarterly cap
  if no on-change trigger has fired," but no automation fires that cadence half) are each
  declared with **no automation firing them** (the on-change half fires; the periodic half does not). § 3 confirms the positive baseline is *entirely*
  PR-boundary; § 2 states PR-boundary is the only trigger-class the harness has built. § 5 lists
  these as advisory follow-up OPPs — this OPP is their unifying implementation (one out-of-band
  process is the common mechanism the three synthesis gaps share).
- **ADR-0014 (verified)** — `distilled-learnings.md` reached **40 days with zero content entries**
  because its "dedicated review sessions … nothing schedules" never fired. Canonical in-repo evidence
  that declared-but-unfired synthesis dies. This is the failure class this OPP closes.
- **`cycle-end-distillation.md` § Anti-Patterns (verified)** — "Cargo-cult observations": the
  documented in-repo cost of forcing synthesis in-band at PR time. (The "split focus" framing is the
  external articulation of the same observed local cost.)
- **OPP-0057 (merged, `agents/acp` audit → knowledge-capture bridge)** — its Precondition § records
  that the ACP audit sink's two schemas diverge and **neither carries `sessionId`/`timestamp`**, so
  per-session rollup is impossible on today's ACP output. That fix is this OPP's **Phase-0
  precondition** for the ACP transcript provider specifically. OPP-0057 is a **committed sibling and
  dependency, not a competitor**: it produces the transcript substrate this OPP consumes. *(Repo note:
  the source brief described OPP-0057 as an untracked draft; it merged in #189 (`2a04c48`) before this
  record was written.)*
- **OPP-0032 (parent)** — this OPP is a follow-up to the session-cycle-orchestration taxonomy
  (PRD-0013 shipped `session-shape.md`), which explicitly deferred "per-rule PRD passes for any new
  companion rules the taxonomy recommends." This is one of those, consolidated.
- **`agents/openclaw` (verified, with correction)** — OpenClaw's `HEARTBEAT.md` / `SOUL.md` /
  `BOOT.md` are **optional workspace files the harness is "aware of but does not enforce … outside
  harness governance scope."** The closest thing to "dreaming" today is therefore *per-agent,
  single-session-visibility, and ungoverned periodic behavior*. *(Repo note: the source brief claimed
  OpenClaw runs a "nightly distillation of its own daily logs"; the README documents only optional,
  ungoverned "periodic behavior" — the specific nightly-distillation practice is not repo-grounded, so
  the claim here is limited to what the README supports.)*
- **External signal — convergent cross-lab practice (cite multiple lineages in the ADR).**
  **Anthropic** (Mukta, AI DevCon): dreaming as a batch transcript-mining process producing
  evidence-backed *proposed* memory diffs, with a production guardrail list (versioning+provenance,
  concurrency control, permissioning, staleness passes) that maps onto the harness's existing kernel
  doctrine. **Letta** (sleep-time compute, arXiv 2504.13171): a dedicated offline consolidation agent
  with its own budget/cadence/model — **but it writes memory directly; this OPP is propose-only, a
  deliberate divergence to record in the ADR.** **Google** (Sessions & Memory whitepaper): async
  extraction → consolidation (dedup, conflict resolution, confidence scoring) → storage, with a
  provenance trust hierarchy (user-stated > observed pattern > single observation > inference).
  **Manus**: file-system-as-externalized-memory and error-preservation production evidence. The
  multi-lineage citation is a deliberate vendor-neutrality guard — out-of-band consolidation with
  provenance, confidence, and human-gated writes is field consensus, not one vendor's paradigm.

## Why Now

- **OPP-0057 just merged.** Its audit-schema fix is designed but unbuilt; naming this OPP as the
  consumer means that fix gets specified against a real downstream contract instead of speculatively.
- **The ACP integration just completed (#184–#189).** The ACP audit sink is a *second* transcript
  source beyond Claude Code session logs, which makes the per-agent-pack transcript-provider contract
  testable across two lineages on day one (the vendor-neutrality acceptance criterion).
- **The knowledge tree grows append-only** with no staleness or back-pressure machinery; the cost of
  deferral compounds — this is precisely the ADR-0014 dormancy class, now structural rather than
  hypothetical.
- **Cross-lab convergence de-risks the design** — the primitives (propose-only, provenance, evidence
  bar, dedicated budget) are field consensus, so the harness is codifying a settled pattern
  deterministically, not betting on a paradigm.

## Scope (decomposed)

| Sub-component | What it does | Disposition |
|---|---|---|
| **Transcript-provider contract** | Declared per-agent-pack interface: what a session transcript is, where it lands, required fields (`sessionId`, `timestamp`, tool-call records), and declared degraded modes | **Core** |
| **Steering file** | Declarative per-org policy: signal thresholds (min prevalence / independent-session count), noise filters, dedicated budget, target surfaces, evidence bar | **Core** |
| **Dreaming job (reference orchestrator)** | Operator-invoked batch: orchestrator fans sub-agents over the transcript corpus → consolidates against the current store → emits a proposed diff. Reference material, not enforced runtime | **Core (reference)** |
| **Proposed-diff output contract** | The branch-PR anatomy: per-change evidence block + provenance; the dreaming-output companion rule that gates it | **Core** |
| **Promotion-candidate scan (gap #1)** | Surface crystallized observations → propose promotion to operating-principles | **v1 duty** |
| **Back-pressure audit (gap #3)** | Report accumulation-vs-promotion ratio; propose synthesis/retirement | **Phase 2** |
| **Periodic §10 doctrine audit (gap #4)** | Re-verify Enforced/Half/Asserted classifications against transcript evidence on cadence | **Phase 3** |
| **Staleness re-verification** | `last-verified` stamping; retirement proposals for unconfirmed entries | **Phase 2** |
| **`validate-dreaming-*` linter(s)** | Shape-lint the steering file and the proposed-diff evidence blocks | **Follow-on (own record)** |
| Direct machine write to the knowledge tree | Machine merges its own proposals | **Rejected** — propose-only is load-bearing (the Letta divergence) |

## Risks / Open Questions

- **Packaging — new `management/dreaming` overlay vs. `knowledge-capture` v2.** Apply operating
  principle § 7 (*file boundaries = change-class boundaries*): in-band capture (observation schema +
  PR-boundary rule) and out-of-band consolidation (transcript mining + proposed-diff contract) are
  **distinct change classes**, and knowledge-capture is active on consumers that have *no* transcript
  substrate. A separate opt-in overlay (dependsOn knowledge-capture) keeps the base module stable.
  **Recommendation: separate overlay.** Resolve at PRD/ADR time.
- **Write authority MUST be propose-only** — Tier 2 on a branch; a human merges. The dreaming job is
  **never** granted Tier 3+ and never writes `operating-principles.md` directly. Mukta's
  poisoned-org-context scenario applies doubly to a batch process with fleet visibility. The
  divergence from Letta's direct-write model is deliberate and belongs in the ADR.
- **Prompt injection via transcripts.** Dreaming reads untrusted session content at scale; a poisoned
  transcript proposing a memory change is the new attack surface. Mitigations to design: an
  **evidence bar** (prevalence across *independent* sessions — one injected transcript can't clear
  it), a **redaction pass** (`validate-knowledge-redaction` precedent), an adversarial-content scan on
  the corpus (`validate-skill-content` precedent), transcript content treated as **data, not
  instructions**, and `humanReview` text that names the attack.
- **Permission scoping.** The transcript corpus selection must **mirror the permission set of the
  target memory store** (Mukta): dreaming must not mine transcripts more privileged than the store it
  proposes writing to. Concretely for a single-maintainer repo this is trivial; for a consumer org it
  needs a declared scope in the provider contract — spell out both.
- **Transcript availability varies by pack** — Claude Code JSONL (rich), ACP audit sink (full *after*
  OPP-0057's `sessionId`/`timestamp` fix), OpenClaw daily logs (prose-lossy fallback), others (none).
  The provider contract needs declared degraded modes and honest "none" declarations.
- **Cost / cadence.** Dedicated budget, but how much and how often? **Recommendation: operator-invoked
  v1** (calibrate the evidence bar against real runs), time-boundary (scheduled CI) v2, count-boundary
  v3 — mirroring `session-shape.md` § 5's "prove the taxonomy is load-bearing before adding a
  count-boundary primitive."
- **Steering-file governance.** Editing signal/noise **thresholds** is operator tuning (audit-trail /
  change-log entry); editing the steering **schema** or adding a **target surface** is a governance
  change (ADR). **Recommendation: split governance by field-class** — confirm at PRD time.
- **Composition.** Must not duplicate the cycle-end rule's enforcement. Dreaming *consumes* what
  in-band capture produces and *proposes* what in-band capture cannot see; the PR-boundary floor
  (PRD-0004) is unchanged.
- **Vendor-neutrality.** Canonical name **"out-of-band memory consolidation"** ("dreaming" as
  documented alias); proposed module id `management/memory-consolidation`. Acceptance criterion: one
  end-to-end run on a **non-Claude** pack (gemini-cli or codex-cli transcripts).

## Disposition

**Proposed (filed 2026-08-31).** A PRD is anticipated; the two-layer model, the transcript-provider
contract, and the propose-only + evidence-bar output contract are the specified starting point, and the
smallest-useful v1 is promotion-scan-only (gap #1) on Claude Code transcripts, operator-invoked. See the
pre-PRD design notes at `docs/superpowers/plans/2026-08-11-dreaming-module.md`.

Two design questions the notes flagged for maintainer confirmation were resolved to their recommended
defaults at filing (Nate's direction): **Q3 — promotion target = staging-only** (dreaming writes to a
reviewable staging surface a human promotes from; never direct-to-`operating-principles.md`), and **Q9 —
framing = unified** (a single `management/memory-consolidation` overlay covering the session-shape gaps,
not three separate OPPs). Both are re-openable at PRD time if the shape proves wrong.

## Promotion

*(empty)*

## Related

- **OPP-0057** — ACP audit → knowledge-capture bridge (the Phase-0 transcript-substrate dependency).
- **OPP-0032** / **PRD-0013** — session-cycle orchestration + the review-trigger taxonomy this fires.
- **ADR-0014** — the `distilled-learnings` dormancy that motivates it.
- **PRD-0004** — the in-band cycle-end rule this complements (never replaces).
- **ADR-0002** — the observation schema whose fields carry the provenance dreaming must produce.
