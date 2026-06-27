<!--
Copyright {{YEAR}} {{AUTHOR}} <{{AUTHOR_EMAIL}}>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of {{PROJECT_NAME}} — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Trace Exporters

> Which backends **{{PROJECT_NAME}}** exports its OpenTelemetry agent traces to, and
> whether export is required or optional at each deployment tier. The trace *shape*
> is declared in [`trace-contract.md`](trace-contract.md); this file declares where
> those traces *go*. Part of the `architectures/agent-observability` overlay.

## Supported exporters

OTLP-shaped GenAI traces are vendor-neutral — the same spans can fan out to several
backends. Declare which ones {{PROJECT_NAME}} supports.

| Exporter / backend | Supported? | Transport | Notes |
|---|---|---|---|
| OTLP/HTTP → OpenTelemetry Collector | <!-- TODO yes/no --> | OTLP | Baseline; fan out to other backends from the collector |
| Azure Monitor / Application Insights | <!-- TODO --> | OTLP / Azure exporter | First-class for Azure AI Foundry; content capture gated by an explicit env flag (off by default) |
| Datadog LLM Observability | <!-- TODO --> | OTLP intake / agent | Natively consumes the GenAI semconv; auto-maps `gen_ai.*` |
| Honeycomb | <!-- TODO --> | OTLP | Consumes via OTLP |
| New Relic | <!-- TODO --> | OTLP | Consumes via OTLP |
| <!-- TODO: project-specific backend --> | | | |

## Required vs optional per deployment tier

Declare, per environment, whether trace export is mandatory or best-effort — so a
prototype isn't blocked on observability it doesn't need, while production is.

| Deployment tier | Export | Backend(s) |
|---|---|---|
| Local / development | <!-- TODO: optional? console exporter? --> | <!-- TODO --> |
| Staging | <!-- TODO --> | <!-- TODO --> |
| Production | <!-- TODO: required? --> | <!-- TODO --> |

## Configuration shape

<!-- TODO: the concrete config {{PROJECT_NAME}} uses — e.g. the OTLP endpoint env
vars (OTEL_EXPORTER_OTLP_ENDPOINT), the Application Insights connection string var,
any content-recording opt-in flag, and the sampling strategy. Keep secrets out of
this file; reference where they are configured. -->

## Privacy note

Whichever backend receives traces also receives any **content attributes** the
trace contract opts into (messages, tool arguments/results). Confirm the receiving
backend's data-handling posture matches {{PROJECT_NAME}}'s privacy obligations
before enabling content capture, and keep it gated (see
`management/privacy-by-design`).
