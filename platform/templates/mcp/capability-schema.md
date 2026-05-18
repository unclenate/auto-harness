<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# MCP Capability Schema

**Owner:** [[CAPABILITY_OWNER]]
**Last updated:** YYYY-MM-DD
**Module:** `architectures/mcp-server`
**Companion artifact:** `docs/mcp/server-spec.md` (declared-capabilities subsection)

This document is the detailed expansion of the capability declaration the
server emits in its `initialize` response. It is optional under
`architectures/mcp-server` but required in spirit whenever the server
advertises any non-default capability or supports `*/listChanged`
notifications.

The MCP spec is normative on this: capability negotiation is the consumer's
contract for what the server actually supports. Declaring a capability the
server does not implement is a spec violation; implementing one without
declaring it confuses consumers who key on capability flags.

---

## Server-Declared Capabilities

What the server tells clients during `initialize`. Each subsection corresponds
to one capability field.

### `tools`

| Field | Value |
|-------|-------|
| Declared? | [[Yes / No]] |
| `listChanged` declared | [[true / false / omitted]] |
| When the list changes | [[never / on permission grant / on plugin load / etc.]] |
| Notification frequency expectation | [[within N seconds of change / batched per minute / etc.]] |

If `listChanged: true`, the server MUST emit `notifications/tools/list_changed`
when the set changes. If `listChanged: false` (or omitted), the server MUST
NOT change the tool list during a session — consumers may cache
`tools/list` indefinitely.

### `resources`

| Field | Value |
|-------|-------|
| Declared? | [[Yes / No]] |
| `listChanged` declared | [[true / false / omitted]] |
| `subscribe` declared | [[true / false / omitted]] |
| Resource URI schemes | [[file:// / db:// / project:// / etc.]] |
| Templated resources | [[Yes / No — name templates in tool-registry.md or here]] |

### `prompts`

| Field | Value |
|-------|-------|
| Declared? | [[Yes / No]] |
| `listChanged` declared | [[true / false / omitted]] |

### `logging`

| Field | Value |
|-------|-------|
| Declared? | [[Yes / No]] |
| Minimum log level the server emits | [[debug / info / warn / error]] |

---

## Client-Capability Reliance

What the server depends on from the client. The server cannot demand client
capabilities — it negotiates — so this section documents the server's
fallback behavior when a capability the server would have used is not
declared by the client.

### `sampling`

| Field | Value |
|-------|-------|
| Server uses `sampling/createMessage`? | [[Yes / No]] |
| When the server requests sampling | [[describe the trigger]] |
| Fallback if client does not declare `sampling` | [[degrade tool to error / use bundled local model / etc.]] |
| Privacy posture for sampling prompts | [[describe what data the server may include in sampling prompts]] |

### `elicitation`

| Field | Value |
|-------|-------|
| Server uses `elicitation/create`? | [[Yes / No]] |
| When the server requests elicitation | [[describe the trigger]] |
| Fallback if client does not declare `elicitation` | [[fail the tool with explanatory error / use a sensible default / etc.]] |

### `roots`

| Field | Value |
|-------|-------|
| Server reads client `roots`? | [[Yes / No]] |
| Behavior if no roots are exposed | [[describe]] |

---

## Protocol Version Handling

| Field | Value |
|-------|-------|
| Versions the server supports | [[2025-06-18, 2024-XX-XX, etc.]] |
| Default version the server proposes | `2025-06-18` |
| Negotiation behavior on mismatch | [[reject / negotiate down to common version / etc.]] |

---

## Spec Conformance Tests

Document how the project verifies its declared capabilities match runtime
behavior. The MCP Inspector tool is a good starting point.

| Check | How verified | Frequency |
|-------|--------------|-----------|
| Declared `tools.listChanged` matches notification emission | [[automated test / manual via Inspector]] | [[CI / per release]] |
| `tools/list` output matches `tool-registry.md` entries | [[automated test]] | [[CI]] |
| `protocolVersion` in `initialize` response matches `server-spec.md` | [[automated test]] | [[CI]] |

---

## References

| Resource | URL |
|----------|-----|
| Server spec | `docs/mcp/server-spec.md` |
| Tool registry | `docs/mcp/tool-registry.md` |
| MCP architecture (spec) | https://modelcontextprotocol.io/docs/learn/architecture |
| MCP Inspector | https://github.com/modelcontextprotocol/inspector |
