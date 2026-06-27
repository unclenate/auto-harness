<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Architecture Overlay: Agent Observability

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay governs how an agent-native project declares the **shape of the trace
data it emits**. Enterprise AI foundries (Microsoft / Azure AI Foundry, NVIDIA,
Palantir), observability backends (Application Insights, Datadog, Honeycomb), and
multi-agent orchestrators don't consume *generic* OpenTelemetry — they consume the
**GenAI multi-agent semantic conventions** that name the spans, attributes, and
events agents emit (model calls, tool calls, agent invocations, token usage, eval
outcomes). This overlay makes that contract a first-class, reviewable artifact.

It is **opt-in** (add `agent-observability` to your `harness.manifest.yaml`) and
composes with any `agents/*` pack without those packs depending on it. auto-harness
itself does not activate it.

---

## What this overlay requires

Two artifacts under `docs/observability/`, scaffolded from the
[trace-contract](../../../templates/observability/trace-contract.md) and
[exporters](../../../templates/observability/exporters.md) templates:

- **`docs/observability/trace-contract.md`** — declares which spans / attributes /
  events the project emits per agent action, with an explicit **pin to a specific
  OpenTelemetry GenAI semantic-conventions version**. The conventions are
  Development/Experimental and churn (e.g. `gen_ai.system` → `gen_ai.provider.name`,
  `gen_ai.prompt` → `gen_ai.input.messages`), so the pin is what keeps the contract
  unambiguous over time.
- **`docs/observability/exporters.md`** — names which exporters the project supports
  (OTLP/HTTP collector, Azure Monitor / Application Insights, Datadog, Honeycomb, …)
  and whether export is required or optional at each deployment tier.

## v1 is declarative — enforcement is deferred

v1 establishes *what the contract is*. It ships **no companion rule and no
validator**. The companion rule "an action-code change that introduces a new span
shape must update `trace-contract.md`" and a `validate-trace-contract.sh` that
checks the contract against the emitting code are the **v2 follow-up** (a separate
OPP/PRD), per the deferred-implementations discipline. Pinning the contract first,
enforcing drift second.

## How this overlay composes

- **With any `agents/*` pack** — the pack defines the agent; this overlay declares
  what that agent's runtime emits. No dependency either way.
- **With `management/privacy-by-design`** — trace *content* attributes
  (`gen_ai.input.messages`, `gen_ai.output.messages`, tool arguments/results) carry
  user data and are **opt-in, off by default** in the conventions for exactly this
  reason. A project handling personal data should pair this overlay with
  privacy-by-design and keep content capture gated.
- **With the frontier-agent posture (OPP-0027 cluster)** — the trace shape this
  overlay declares is what foundry-targeting (OPP-0028), model-routing
  (OPP-0030), and identity-bound traces (OPP-0031) build on.

## Agent behavior

Agents working in a project with this overlay active treat `trace-contract.md` as
the source of truth for emitted telemetry: when adding instrumentation, conform to
the declared spans/attributes and the pinned conventions version; when a new span
shape is genuinely needed, update the contract in the same change (the discipline
v2 will enforce mechanically).

## See also

- [`module.yaml`](module.yaml) — the module contract.
- [`templates/observability/trace-contract.md`](../../../templates/observability/trace-contract.md),
  [`exporters.md`](../../../templates/observability/exporters.md) — the starters.
- Upstream: the OpenTelemetry GenAI semantic conventions
  (`open-telemetry/semantic-conventions-genai`) and Azure AI Foundry agent tracing.
