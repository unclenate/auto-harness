<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0047 — Delivery-Cost & Unit-Economics Governance

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-06-15
**Last Updated:** 2026-06-30 *(linkage update — stays `proposed` (the wedge is unbuilt), but [PRD-0025](../requirements/PRD-0025-work-package-lane-contract.md) (`work-package-lane-contract`, accepted) formally **adopted this OPP as a deferred v2 phase**: the economic contract (`tokenBudget` + delivery-cost record) is folded into the `management/work-package` module's v2 phase. So OPP-0047 is now tracked-but-deferred inside an accepted PRD, not free-floating. Prior: 2026-06-15 filed.)*
**Confidence:** medium-high

---

## Thesis

The harness governs **what** code gets built (quality, safety, trust tiers,
required artifacts) but not **what it costs to build it**. As agentic delivery
becomes the normal mode — including auto-harness's own development — the token
spend to produce a unit of code (a PR, a work-package, a module) is **directly
observable but ungoverned and unattributed**. Every subagent dispatch already
reports its token usage; the workflow runtime already tracks a spend budget.
Nothing captures that as first-class, attributable governance evidence, and
nothing ties it to the **build-vs-buy decision** — whether to build a capability
in-house or integrate/buy it.

The proposal: make **delivery cost** a governed, attributable artifact, and
require build-vs-buy decisions to cite it. As with OPP-0046, the harness governs
the **contract**, not the **extraction** — the agent-runtime / CI emits the token
numbers; the harness defines the record schema, the budget, and the rule that a
build-vs-buy decision must cite real delivery-cost evidence rather than asserting
"cheaper to build" from intuition.

This **composes directly with OPP-0046**: the work-package lane is the *unit of
delivery*; this OPP adds the *economic contract* (cost, budget) to that unit's
*scope contract* (`allowedFiles`, `requiredChecks`). Lane = scope; cost record =
economics; together they are one governance object.

A research brief is committed alongside this OPP scoping the open questions
(baselines, prediction, dispatch-cost optimization) — see Related.

### Sub-components (decomposed)

| Sub-component | What it governs | Disposition |
|---|---|---|
| **Delivery-cost record schema** | A structured record attributing tokens / model / cached-vs-fresh split / USD estimate to a delivery unit (PR / work-package / module). Must define its **own** USD-attribution convention — OTel GenAI semconv standardizes token *counts*, not dollar cost | **Wedge candidate** |
| **Token budget on the WP lane** | Extend OPP-0046's lane with a `tokenBudget` field + a spend-vs-budget check (the economic sibling of the lane-vs-diff lint) | **Wedge candidate (composes OPP-0046)** |
| **Build-vs-buy decision artifact + companion** | A `build-vs-buy-decision.md` artifact type that **must cite** a delivery-cost record (+ a projected-maintenance estimate); a companion rule gives it governance teeth — no cost claim without evidence | **Wedge candidate** |
| Cost-attribution convention | How to roll up the per-call / per-session token data the tooling natively emits to a *delivery unit*, **caching-aware** (caching is the dominant cost lever and breaks naive sums) | Deferred (needs runtime/CI integration) |
| Cost-per-capability baselines | Reference baselines — what a typical CRUD endpoint / migration / module costs in tokens — to benchmark against | Deferred → research |
| Scope→spend predictor | Estimate a work-package's likely spend from its lane shape *before* building it | Deferred → research |
| Dispatch-pattern cost optimization | Which dispatch patterns (single implementer vs. fan-out vs. controller+implementer) are cost-optimal for a given unit | Deferred → research |

## Origin / Evidence

- **Raised 2026-06-15** in a build-vs-buy governance discussion (integrate an
  existing capability vs. build one's own capacity). The insight: understanding
  token spend and budget per unit of delivery would add governance value to the
  build-vs-buy decision.
- **The raw data already exists.** Every subagent dispatch in this very repo
  reports `subagent_tokens`; the workflow runtime exposes a `budget` API
  (`budget.total`, `budget.spent()`). The cost signal is present and unused for
  governance.
- **External landscape confirms a real gap** (research brief,
  `2026-06-15-delivery-cost-governance-research-brief.md`): OTel GenAI
  conventions standardize token counts but **not** dollar cost; cost-observability
  tools (Langfuse, LangSmith, Helicone, AgentOps, OpenLLMetry) attribute cost per
  *call / session / tag*, **none** to a "unit of software delivery"; and
  make-vs-buy frameworks still cost the "build" side in human hours, never in
  measured agentic-delivery tokens.
- **Internal precedent.** Same harness-native shape as OPP-0046 — govern the
  contract, not the extraction — and the same declare-then-cite teeth as the
  module/companion contract.

## Why Now

- **Agentic delivery is the harness's own mode.** This session alone produced
  five merged PRs subagent-driven; the cost was observable on every dispatch and
  captured nowhere.
- **OPP-0046 just defined the unit to attribute cost to.** Without a machine-
  readable work-package, "cost per unit of delivery" has no unit; with it, the
  cost record has a natural home.
- **Build-vs-buy decisions are being made without cost evidence.** The strategic
  payoff is auditable build-vs-buy reasoning grounded in real numbers instead of
  intuition.

## Risks / Open Questions

- **Harness-scope boundary (same as OPP-0046).** Extraction is a runtime / CI
  concern; the harness governs the record schema + the cite-the-evidence rule,
  not the token capture. The PRD must draw this line so the OPP doesn't drift into
  "the harness runs the agents."
- **Cost is non-standardized.** OTel emits token counts, not USD; the schema must
  carry its own pricing-table-derived attribution, and **pricing is volatile** —
  the convention must separate token counts (durable) from a dated $ estimate.
- **Caching breaks naive cost math.** Prompt caching (re-sent repo context) is the
  single largest realistic cost reducer for agentic delivery; a record that sums
  fresh-input pricing will overstate cost 5–10×. The schema must capture the
  cached-vs-fresh split.
- **Attribution grain mismatch.** Tooling natively attributes per call / session;
  rolling that up to a PR / work-package is a net-new convention (repurposed tags),
  not a product feature — design work, not configuration.
- **Sensitivity.** Delivery-cost data can reveal effort, strategy, or vendor
  economics; treat it with the same care as other governed-but-sensitive records.
- **Research vs. governance split.** Baselines, the scope→spend predictor, and
  dispatch-cost optimization are *research*, not v1 governance — they inform the
  schema but should not gate the wedge.

## Disposition

**Proposed 2026-06-15; adopted as a deferred phase by an accepted PRD 2026-06-30.**
The recommended **thin wedge** — the delivery-cost record schema, a `tokenBudget`
extension to the work-package lane with a spend-vs-budget check, and a
`build-vs-buy-decision.md` artifact with a cite-the-evidence companion — was taken up by
[PRD-0025](../requirements/PRD-0025-work-package-lane-contract.md): that PRD (accepted,
shipping the `management/work-package` lane contract) **folds this OPP's economic contract
in as the module's v2 phase**. So the wedge now has a home and a sequence; it remains
unbuilt (the v2 phase is not yet implemented), which is why OPP-0047 stays `proposed`. The
cost-attribution convention and the three research items (baselines, predictor, dispatch
optimization) stay deferred pending that v2 implementation and a research pass. The
companion **research brief** is committed alongside this OPP.

## Related

- **Composes with:** [OPP-0046](OPP-0046-parallel-multi-agent-work-package-lane-contract.md)
  (the work-package lane — the *unit of delivery* this OPP attaches cost to).
- Research brief: `docs/superpowers/specs/2026-06-15-delivery-cost-governance-research-brief.md`.
- Adjacent but distinct: [OPP-0029](OPP-0029-agent-observability.md) / PRD-0014
  (agent observability — the *consumer app's runtime* inference cost via OTel
  traces, not the *delivery-time* cost of building the code).
- Strategic build-vs-integrate framing: [OPP-0001](OPP-0001-exportable-governance-contract-for-runtime-harnesses.md),
  [OPP-0007](OPP-0007-canonical-position-artifact.md).
- Declare-then-cite precedent: the module `companionRules` contract; ADR-0002
  (structured observations).
