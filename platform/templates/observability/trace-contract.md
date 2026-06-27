<!--
Copyright {{YEAR}} {{AUTHOR}} <{{AUTHOR_EMAIL}}>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of {{PROJECT_NAME}} — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Trace Contract

> The declared shape of the OpenTelemetry trace data **{{PROJECT_NAME}}** emits for
> agent activity. Foundries and observability backends consume *this* shape — fill
> it in for your project, pin the conventions version, and keep it current. Part of
> the `architectures/agent-observability` overlay (PRD-0014).

## Semantic-conventions version pin

The OpenTelemetry **GenAI** semantic conventions are **Development / Experimental**
(no stable release) and they churn — pin an explicit version so this contract stays
unambiguous.

- **Pinned to:** <!-- TODO: e.g. OpenTelemetry GenAI semantic conventions (Development), semconv v1.42.0, dedicated repo open-telemetry/semantic-conventions-genai -->
- **Verified on:** <!-- TODO: the date you last checked the pin against upstream -->
- **Known churn to watch:** `gen_ai.system` → `gen_ai.provider.name`;
  `gen_ai.prompt` / `gen_ai.completion` → `gen_ai.input.messages` /
  `gen_ai.output.messages`. Re-verify the pin when you upgrade instrumentation.

## Spans (per agent action)

Declare the spans your runtime emits. Span name follows the convention
`{gen_ai.operation.name} {discriminator}`.

| Operation (`gen_ai.operation.name`) | Span name | Span kind | When emitted |
|---|---|---|---|
| `chat` | `chat {gen_ai.request.model}` | CLIENT | <!-- TODO: per model inference call --> |
| `invoke_agent` | `invoke_agent {gen_ai.agent.name}` | CLIENT or INTERNAL | <!-- TODO: per agent invocation (CLIENT = remote agent service; INTERNAL = in-process loop) --> |
| `execute_tool` | `execute_tool {gen_ai.tool.name}` | INTERNAL | <!-- TODO: per tool/function call --> |
| `create_agent` | `create_agent {gen_ai.agent.name}` | CLIENT | <!-- TODO: per agent creation (Azure Foundry registration looks for this span) --> |
| <!-- TODO: add embeddings / invoke_workflow / plan / execute_task or project-specific operations --> | | | |

## Attributes (cross-cutting)

| Attribute | Required? | Notes |
|---|---|---|
| `gen_ai.operation.name` | required | the operation discriminator above |
| `gen_ai.provider.name` | required | e.g. `openai`, `anthropic`, `azure.ai.inference` (replaces the deprecated `gen_ai.system`) |
| `gen_ai.request.model` / `gen_ai.response.model` | conditional | the requested / actual model |
| `gen_ai.usage.input_tokens` / `gen_ai.usage.output_tokens` | recommended | token accounting (add `gen_ai.usage.reasoning.output_tokens` if applicable) |
| `gen_ai.agent.name` / `gen_ai.agent.id` | conditional | on agent spans |
| `gen_ai.conversation.id` | recommended | ties spans into a conversation |
| `gen_ai.tool.name` / `gen_ai.tool.call.id` | conditional | on `execute_tool` spans |
| <!-- TODO: project-specific attributes --> | | |

> **Content attributes are privacy-sensitive and OPT-IN.**
> `gen_ai.input.messages`, `gen_ai.output.messages`, `gen_ai.system_instructions`,
> and tool arguments/results carry user data and are **off by default** in the
> conventions. If {{PROJECT_NAME}} captures them, gate the capture explicitly and
> pair this overlay with `management/privacy-by-design`.

## Events

<!-- TODO: declare notable runtime events you emit, e.g. an Evaluation event
(name / error.type / label) for agent-quality scoring, or
gen_ai.client.inference.operation.details as an alternate carrier for message
content instead of putting it on the span. -->

## Examples (realistic span shapes)

<!-- TODO: one or two concrete worked examples — an invoke_agent span with child
chat + execute_tool spans, showing the attributes above populated with real values
for {{PROJECT_NAME}}. A reader should be able to match these against the emitted
traces. -->

## Update policy

Treat this as the source of truth for emitted telemetry. When instrumentation adds
a new span shape, update this contract in the same change, and re-check the version
pin on every conventions upgrade. (A companion rule enforcing this is the
`architectures/agent-observability` v2 follow-up; v1 is the declared contract.)
