<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# MCP Capability Schema — team-knowledge-base

**Owner:** @unclenate
**Last updated:** 2026-05-17
**Module:** `architectures/mcp-server`
**Companion artifact:** `docs/mcp/server-spec.md`

Detailed expansion of the capability declaration emitted in the server's
`initialize` response.

---

## Server-Declared Capabilities

### `tools`

| Field | Value |
|-------|-------|
| Declared? | Yes |
| `listChanged` declared | false |
| When the list changes | never |
| Notification frequency expectation | n/a — static list |

`tools.listChanged: false` means consumers may cache the result of
`tools/list` for the lifetime of the connection. The server commits to not
mutating the list mid-session.

### `resources`

| Field | Value |
|-------|-------|
| Declared? | No |

The server does not expose resources in v1. Article content is delivered
inline in `search_kb_articles` results (via the snippet field) and via
text in `save_kb_draft` confirmation responses. A future version may
introduce resources for full article content; that change requires a new
capability declaration and a coordinated update to `server-spec.md`.

### `prompts`

| Field | Value |
|-------|-------|
| Declared? | No |

### `logging`

| Field | Value |
|-------|-------|
| Declared? | No |

Server logs to stderr (visible in the host's MCP log panel) but does not
expose the spec's `logging` capability for client-driven log-level control.

---

## Client-Capability Reliance

### `sampling`

| Field | Value |
|-------|-------|
| Server uses `sampling/createMessage`? | No |
| Fallback if client does not declare `sampling` | n/a |

### `elicitation`

| Field | Value |
|-------|-------|
| Server uses `elicitation/create`? | No |
| Fallback if client does not declare `elicitation` | n/a |

### `roots`

| Field | Value |
|-------|-------|
| Server reads client `roots`? | No |

---

## Protocol Version Handling

| Field | Value |
|-------|-------|
| Versions the server supports | 2025-06-18 |
| Default version the server proposes | 2025-06-18 |
| Negotiation behavior on mismatch | Server returns the client's `protocolVersion` if recognized as 2025-06-18; otherwise rejects connection with a clear error pointing at supported version |

---

## Spec Conformance Tests

| Check | How verified | Frequency |
|-------|--------------|-----------|
| Declared `tools.listChanged: false` matches behavior (no notifications ever emitted) | unit test asserts the server's notification emitter has no path that emits `notifications/tools/list_changed` | CI |
| `tools/list` output matches `docs/mcp/tool-registry.md § Summary Table` | integration test using MCP SDK client — runs server, calls `tools/list`, diffs against parsed Markdown table | CI |
| `protocolVersion` in `initialize` response equals `"2025-06-18"` | unit test against `initialize` handler | CI |

---

## References

| Resource | URL |
|----------|-----|
| Server spec | `docs/mcp/server-spec.md` |
| Tool registry | `docs/mcp/tool-registry.md` |
| MCP architecture (spec) | <https://modelcontextprotocol.io/docs/learn/architecture> |
| MCP Inspector | <https://github.com/modelcontextprotocol/inspector> |
