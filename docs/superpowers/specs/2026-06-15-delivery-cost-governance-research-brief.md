<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Research Brief — Governing the Token Cost of Agentic Software Delivery (grounds OPP-0047)

**Status:** Research agenda + evidence artifact (web-grounded; pricing flagged volatile)
**Date:** 2026-06-15
**Grounds:** [OPP-0047](../../opportunities/OPP-0047-delivery-cost-unit-economics-governance.md)

The core question: **what does it cost — in tokens and dollars — to build a unit
of code with agents, and how do we make that a tracked, attributable, auditable
input to the build-vs-buy decision?** The token signal is already emitted on every
agent dispatch but is captured nowhere as governance evidence, and no external
standard or tool attributes it to a *unit of software delivery*. This brief scopes
the research agenda and grounds it in the current landscape.

## Research agenda (the open questions)

**1. Measurement & attribution.** What is the right *unit of delivery* (PR /
work-package / module), and how do you roll up the per-call / per-session token
data that tooling natively emits to that unit — **caching-aware**, since re-sent
repo context dominates agentic cost? What durable fields belong in a delivery-cost
record (token counts, model, cached-vs-fresh split) vs. derived/volatile ones (USD
at a dated price)?

**2. Cost-per-capability baselines.** What does a typical CRUD endpoint, schema
migration, validator, or module *cost* in tokens? Establishing reference baselines
turns a raw number into a judgment ("this PR cost 2× the median module").

**3. Scope→spend prediction.** Can a work-package's likely spend be estimated from
its lane shape (file count, `requiredChecks`, complexity) *before* building it —
enough to set a `tokenBudget` (OPP-0046) with a real basis?

**4. Dispatch-pattern cost optimization.** Which dispatch patterns — single
implementer, fan-out, controller+implementer (the patterns used across this very
repo) — are cost-optimal for a given unit, and how much does caching discipline
move the number?

**5. Decision governance.** What must a `build-vs-buy-decision.md` cite to be
credible: build cost (measured delivery tokens + projected maintenance) vs. buy
cost (license + integration + lock-in)? How do agentic-delivery numbers change a
make-vs-buy framework that historically costs "build" in human hours?

### Working hypotheses

- Token counts are the durable metric; USD is a derived, dated view — the record
  must separate them.
- Caching discipline is the largest single cost variable; two teams building the
  same unit can differ 5–10× on cost from caching alone.
- A scope→spend predictor is feasible at order-of-magnitude accuracy (enough to
  budget), not to the token.
- Build-vs-buy decisions grounded in measured delivery cost will sometimes invert
  the intuition — capabilities assumed "cheap to build" may not be once
  maintenance + iteration tokens are counted.

## Methodology & data sources

- **Source data already exists:** subagent token usage per dispatch; the workflow
  `budget` API (`budget.total`, `budget.spent()`); CI logs. No new instrumentation
  is needed to *start* — only a convention to record and attribute.
- **Attribution:** repurpose a per-session/tag identifier (the grain the tooling
  offers) keyed to the work-package / PR, then aggregate. Caching-aware: record the
  cached-input vs. fresh-input token split, not just totals.
- **Baselines:** retrospectively attribute cost across a corpus of merged PRs
  (this repo is itself a dataset — every PR this session has a dispatch trail).
- **Governance, not extraction:** the harness defines the record schema + the
  cite-the-evidence rule; the runtime/CI emits the numbers (the OPP-0047 scope
  boundary).

## External landscape (web-grounded; pricing VOLATILE — verify live)

### A. LLM token pricing (ballpark, mid-2026; re-verify before quoting)

- **Anthropic Claude:** Opus ~$5 in / ~$25 out; Sonnet ~$3 / ~$15; Haiku ~$1 / ~$5
  per million tokens — output ~5× input across tiers.
  <https://www.cloudzero.com/blog/claude-api-pricing/>
- **OpenAI GPT (flagship):** ~$2.50–$5 in / ~$15–$30 out per million.
  <https://openai.com/api/pricing/>
- **Google Gemini:** 2.5 Pro ~$1.25 in / ~$10 out; 2.5 Flash ~$0.30 / ~$2.50 per
  million. <https://ai.google.dev/gemini-api/docs/pricing>
- **Cost levers:** prompt caching cuts cached-input cost dramatically (Anthropic
  ~90% off cache reads; OpenAI ~10× cheaper cached input) and **batch is ~50%
  cheaper**. For agentic delivery — same repo context re-sent across many turns —
  caching is the single largest realistic cost reducer and **must** be modeled or
  estimates run 5–10× high. <https://www.finout.io/blog/anthropic-api-pricing>

### B. Observability standards for cost/tokens

- **OpenTelemetry GenAI semantic conventions** (`gen_ai.*`) standardize token usage
  via `gen_ai.usage.input_tokens` / `gen_ai.usage.output_tokens` (+ `gen_ai.token.type`).
  <https://opentelemetry.io/blog/2026/genai-observability/>
- **Monetary cost is NOT standardized** — the spec emits token *counts*; USD is
  left to the implementer to compute from a pricing table (often a non-standard
  `gen_ai.usage.cost_usd` attribute). Any delivery-cost metric defines its own
  USD-attribution convention. <https://github.com/open-telemetry/semantic-conventions>
- **Angle:** this is the *runtime-trace* layer (what a shipped app emits per
  inference) — orthogonal to *delivery-time* cost (what it cost to build the code).
  No standard targets the build/delivery dimension.

### C. Existing cost-observability tooling (all per call / trace / session — none per delivery unit)

- **Langfuse** — usage + USD cost at the observation level, aggregated by
  user/session/tag. <https://langfuse.com/docs/observability/features/token-and-cost-tracking>
- **LangSmith** — per-trace token/cost for LLM/agent runs.
  <https://www.langchain.com/resources/llm-observability-tools>
- **Helicone** — gateway logging cost/tokens per request.
- **AgentOps** — agent-session cost tracking + optimization.
- **OpenLLMetry / Traceloop** — vendor-neutral OTel GenAI spans for portability.
  <https://www.traceloop.com/docs/openllmetry/integrations/langfuse>
- **Gap:** the finest native unit is session/user/tag — **none** ship a per-PR /
  per-work-package cost rollup. It's a user-built convention, not a product feature.

### D. Build-vs-buy / make-vs-buy frameworks

The classic decision trades **strategic differentiation** against **total cost of
ownership** — build what differentiates, buy commodity capability at lowest
sustainable cost. TCO must include post-deployment burden (maintenance,
integration, training), often the majority of lifetime software cost; opportunity
cost is the other standard axis.
<https://umbrex.com/resources/frameworks/strategy-frameworks/make-buy-decision-framework/>
**These frameworks predate agentic delivery and cost the "build" input in human
hours — none model token spend as a build-cost line item.**

### E. Gaps the landscape does not answer (the opportunity)

- No standard attributes agentic *delivery* token cost to a unit of code.
- No cost-per-capability baselines exist to benchmark against.
- No scope→spend predictor (and caching makes naive estimates wildly off).
- Build-vs-buy frameworks don't plug in measured agentic-delivery cost.
- No governance/accounting convention treats delivery token spend as a tracked,
  attributable, auditable cost.
- Cost is non-standardized even at runtime — a delivery-cost metric defines its
  USD-attribution from scratch.

## Scope boundary

The harness governs the **contract** (delivery-cost record schema, `tokenBudget`
on the lane, the build-vs-buy cite-the-evidence rule) — not the **extraction**,
which is a runtime / CI concern. Baselines, the predictor, and dispatch-cost
optimization are *research* that informs the schema; they do not gate the wedge.

## Verify-at-implementation flags

- **All Section A pricing is volatile** (current to mid-2026) — re-verify against
  official pricing pages at use time; record token counts (durable) separately
  from any dated USD estimate.
- **OTel cost field** is non-standard — confirm the current state of the GenAI
  semconv before assuming any `cost_usd` attribute is portable.
- **Caching mechanics differ by provider** — confirm the cached-read discount and
  cache-TTL per model before building the cached-vs-fresh attribution.
