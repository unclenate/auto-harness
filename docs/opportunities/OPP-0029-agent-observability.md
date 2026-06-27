<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0029 — Agent Observability with OpenTelemetry Semantic Conventions (`architectures/agent-observability`)

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-05-25
**Last Updated:** 2026-06-27 *(`exploring` → `accepted`: v1 implementation shipped — the `architectures/agent-observability` module + `trace-contract.md`/`exporters.md` templates (grounded in the current OTel GenAI semconv, web-verified) + propagation + counts (49/58/94). v1 is declarative (no companion rule / validator — deferred to v2). Prior: 2026-06-27 PRD-0014 finalized + accepted (v1.1) — drift reconciled (`type: architecture`, new `stability: beta` field, validator count 8→20, deferred promotion § 9 → § 13). Prior: 2026-05-26 promoted `proposed` → `exploring`; PRD-0014 drafted.)*
**Confidence:** medium-high *(diagnosis); high (on the v1 scope; OTel semantic conventions are stable; healthcare-specific routing models are GA)*

---

## Thesis

Agent-native projects need to emit structured trace data with a
*specific shape* that enterprise AI foundries, observability backends
(Application Insights, Azure Monitor, Datadog, Honeycomb), and
multi-agent orchestrators consume. The shape is not generic
OpenTelemetry — there is a published, consolidating set of
**multi-agent OpenTelemetry semantic conventions** (Microsoft + Cisco
Outshift) that name the spans, attributes, and events agents emit:
inputs, tool calls, model selections, outputs, latency, cost, eval
outcomes. Auto-harness has no module that captures this surface.

Add **`architectures/agent-observability`** — an architectures-family
module declaring a project emits OpenTelemetry-shaped traces
following the multi-agent semantic conventions, with required
artifacts:

- `docs/observability/trace-contract.md` — declares which spans /
  attributes / events the project emits per skill or agent action,
  with explicit references to the upstream OTel semantic conventions.
- `docs/observability/exporters.md` — names which exporters the
  project supports (OTLP/HTTP, Azure Monitor, Application Insights,
  generic OTel collector) and whether the export is required or
  optional at each deployment tier.

Companion rule: edits to agent action surfaces (the skill code,
tool-call code, model-selection code) require a matching update to
`trace-contract.md` if a new span shape or attribute is introduced.
This is the *observability-as-part-of-the-change* discipline applied
to a defined surface.

This module is a satellite of [OPP-0027](OPP-0027-frontier-agent-posture.md);
it composes with [OPP-0028](OPP-0028-ai-foundry-target.md) (foundries
consume the trace shape this module produces),
[OPP-0030](OPP-0030-intelligent-model-routing.md) (router emits model-
selection spans), and [OPP-0031](OPP-0031-agent-defense-in-depth.md)
(identity-bound traces are the audit-substantiation half of Microsoft's
fourth defense-in-depth pattern).

## Origin / Evidence

- **Tula README § "Observability and tracing":** *"Tula runs on
  OpenClaw, which emits structured per-run logs of inputs, tool calls,
  model selections, outputs, latency, and cost. The trace surface is
  OpenTelemetry-shaped so it can be exported to Application Insights,
  Azure Monitor, or any OTel-compatible collector."* Direct field
  evidence.
- **Foundry Observability is GA and consumes this shape.** Tula cites
  the Microsoft / Cisco Outshift [multi-agent OpenTelemetry semantic
  conventions](https://learn.microsoft.com/en-us/azure/foundry/observability/concepts/trace-agent-concept)
  as the trace contract it targets. The conventions are stable,
  externally-defined, and consolidating across multiple vendors —
  exactly the kind of upstream pattern catalog-layer awareness should
  encode.
- **Observability is an *architectural* dimension, not a *delivery*
  dimension.** A prototype can emit OTel traces; a production-saas
  can omit them; the decision belongs in the architecture surface,
  not at delivery time. This places the module in `architectures/`.
- **The gap is broader than Tula.** Any agent-native product
  targeting Foundry Observability, Datadog Agent, Honeycomb agent
  views, or any future agent-orchestrator hits the same shape. The
  conventions are emerging precisely because the cross-vendor pattern
  is recognized.
- **Auto-harness has no observability primitive at any level.**
  Generic observability (metrics, dashboards, logs) is not modeled
  in the catalog; agent-specific observability is doubly absent. The
  *agent-specific* gap is the higher-leverage one to close first
  because the upstream conventions are more concrete than generic-
  observability conventions.

## Why Now

- **The semantic conventions are GA and consolidating.** Microsoft +
  Cisco Outshift have published; multi-vendor traction is visible.
  Catalog-layer adoption now carries low risk.
- **The eval-gated-testing module (OPP-0019) ships eval *results*.**
  This module ships eval *traces* — distinct but composable. Adding
  the observability module while the eval module is fresh keeps the
  pair coherent.
- **Tula needs this catalog-layer awareness to onboard cleanly
  against a future v2 intake.** First-pass Tula filings didn't cover
  this; second-pass Tula intake will profile against a real module
  if v1 lands.

## Risks / Open Questions

1. **Should `trace-contract.md` be a free-form artifact or a
   structured YAML the validator can lint?** Bias: free-form prose at
   v1 with explicit headings (`Spans`, `Attributes`, `Events`); add a
   YAML alternative in v2 if validator-checkable structure becomes
   load-bearing.
2. **Does the module require an exporter at adoption time?** Bias:
   no. The trace *contract* must be documented; the exporter is a
   deployment-time choice. A project can declare the contract and
   ship traces only in development/CI environments at first.
3. **Should the OTel semantic conventions be pinned to a specific
   version?** Bias: yes — pin to the version current at v1 of this
   module, and document an upgrade workflow when the conventions
   evolve. Avoids silent drift.
4. **What about agents that don't run on OpenTelemetry-emitting
   runtimes?** A pure Claude Code project (no OpenClaw) doesn't
   emit traces by default. Bias: the module is opt-in; projects
   adopt it when they have an emitting runtime. Don't force
   instrumentation on runtimes that don't support it.
5. **How does this interact with the agent-pack modules
   (`agents/claude-code`, `agents/openclaw`, etc.)?** The agent pack
   declares *which runtime*; the observability module declares
   *what shape the runtime emits*. They compose: openclaw + observability
   = "I run on OpenClaw AND emit OTel-shaped multi-agent traces."
   No agent pack is required to adopt this module; the module is
   runtime-agnostic but documents which runtimes support emission.
6. **Trace-shape pre-commit checking?** A lint that verifies a
   `trace-contract.md` change is paired with a code change to the
   emitting code (and vice versa) would be a v2 enhancement. v1
   ships the artifact; v2 ships the lint.
7. **What about audit-log shapes distinct from trace shapes?** OPP-
   0031's append-only action log is a different artifact than the
   OTel trace shape. They compose: traces are the runtime-emitted
   observability surface; action logs are the *operator-owned*
   replay-and-audit surface. PRD-pass for both should explicitly
   note the separation.

## Disposition

**2026-05-26 — `proposed` → `exploring`.** Promoted as the first
satellite of the OPP-0027 anchor cluster, per the cluster's recommended
sequencing in the original OPP-0027 filing PR: *"OPP-0029 (observability)
— most concrete, fewest open questions, immediate Tula utility"*.

Direction committed: **workflow-doc + trace-contract-template v1 scope.**
Ship the new module `architectures/agent-observability` with two
required artifacts (`docs/observability/trace-contract.md`, `docs/
observability/exporters.md`), the matching templates, and the
catalog-counts assertion bumps. Defer companion-rule machinery (the
"action-code change requires trace-contract update" rule) to a
follow-up OPP/PRD pair, per the *deferred-implementations* discipline
named in PRD-0013's paired observation. v1 establishes the *contract*;
v2 enforces it.

[PRD-0014 — Agent Observability with OpenTelemetry Semantic Conventions](../requirements/PRD-0014-agent-observability.md)
drafted as the paired design covering 11 must-have FRs (module
creation; trace-contract template; exporters template; SUMMARY +
docs/README + harness-onboarding SKILL updates; catalog-counts bumps;
cross-references) and 3 should-have FRs (Mermaid trace-flow diagram
in `diagrams.md`; one-line `harness-governance` SKILL reference;
optional `recommendedSkills` entry).

Acceptance criteria for OPP-0029 → `accepted`: PRD-0014 Accepted +
FR-001..FR-011 merged + all 8 validators green + at least one
consumer (Tula likely; any project with `agents/openclaw` active is
a candidate) demonstrates trace emission against the contract within
30 days (validates the contract is *load-bearing* and not just
descriptive prose).

## Promotion

See [`docs/requirements/PRD-0014-agent-observability.md`](../requirements/PRD-0014-agent-observability.md).
