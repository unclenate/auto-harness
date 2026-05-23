<!--
NOTE: This is an auto-harness sample-project file (reference implementation).
If you copy this file into your own project, replace the SPDX/copyright
header below with your own — running
`bash platform/bootstrap/set-consumer-headers.sh` from your project root
after the copy will do this for you.
-->

<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# MCP Server Spec — team-knowledge-base

**Owner:** @unclenate
**Last updated:** 2026-05-17
**Module:** `architectures/mcp-server`
**Target MCP spec revision:** 2025-06-18

The authoritative identity record for the `team-knowledge-base` MCP server.
Update whenever the server's identity, capabilities, primitives, transport,
auth, or deployment surface changes (companion rule applies).

---

## Server Identity

| Field | Value |
|-------|-------|
| Server name | `team-knowledge-base` |
| Server version (semver) | `0.1.0` |
| Implementation language | TypeScript |
| SDK / framework | `@modelcontextprotocol/sdk` ^1.0 |
| Canonical URI (HTTP transport only) | `n/a` (stdio-only in v1) |
| Distribution channel | npm — `@example/mcp-server-team-knowledge-base` |
| Source repository | `github.com/example-org/mcp-server-team-knowledge-base` |

---

## Target Hosts

| Host | Verified | Notes |
|------|----------|-------|
| Claude Desktop | Yes | Primary development target |
| Claude Code | Yes | Tested in CI |
| ChatGPT | No | Not yet tested |
| VS Code | Planned | Awaiting MCP extension parity |
| Cursor | Planned | |
| MCPJam | No | Not yet tested |
| Internal agent runtime | No | Not in v1 scope |

---

## Declared Capabilities

```json
{
  "capabilities": {
    "tools": {
      "listChanged": false
    }
  }
}
```

`resources`, `prompts`, `logging`, and sampling are intentionally not
declared in v1. See `docs/full-plan.md § Trade-offs`.

| Sampling use | not used |
| Elicitation use | not used |

---

## Primitives Inventory

### Tools

The authoritative tool registry is `docs/mcp/tool-registry.md`.

| Total tools exposed | 3 |
| Highest-tier exposed tool | Tier 3 — `broadcast_kb_update` |
| Tools with side effects on third-party systems | 1 (`broadcast_kb_update`) |
| Tools that are idempotent | 1 (`search_kb_articles`) |

### Resources

Not exposed in v1.

### Prompts

Not exposed in v1.

---

## Transport

| Field | Value |
|-------|-------|
| Primary transport | stdio |
| Secondary transport | none |
| stdio launch command | `npx -y @example/mcp-server-team-knowledge-base` |
| HTTP endpoint | n/a |
| Authorization model | environment-supplied API key for the knowledge-base backend; no OAuth between client and server (stdio per spec) |

The launch command is intentionally auditable — `npx -y` with an explicit
package name, no shell expansion, no chained installs. Hosts implementing
one-click install will display this command verbatim in the consent dialog.

---

## Runtime Requirements

| Field | Value |
|-------|-------|
| Required environment variables | `KB_API_URL`, `KB_API_KEY` |
| Required runtime permissions | Network egress to `KB_API_URL` only; no filesystem write outside `$XDG_DATA_HOME/team-knowledge-base/` |
| Persistent state | SQLite cache at `$XDG_DATA_HOME/team-knowledge-base/cache.db` |
| External service dependencies | Knowledge-base backend at `KB_API_URL` — when unavailable, all tools return `isError: true` with a clear "backend unreachable" message; no silent failures |
| Minimum host runtime version | Node.js 20 |

---

## Deployment Surface

| Field | Value |
|-------|-------|
| Deployment mode | local stdio (subprocess of the MCP host) |
| Scaling model | per-client subprocess |
| Observability hookpoints | structured stderr logs (host displays in MCP log panel); optional OTLP exporter via `OTEL_EXPORTER_OTLP_ENDPOINT` |

---

## Spec Revision and Compatibility

| Field | Value |
|-------|-------|
| Spec revision targeted | 2025-06-18 |
| Negotiated `protocolVersion` in `initialize` response | `"2025-06-18"` |
| Fallback behavior on protocol mismatch | Server returns the protocol version from the client's `initialize` request if recognized; otherwise rejects with a clear error |

---

## Out of Scope (Explicit)

| Feature | Reason | Reconsider when |
|---------|--------|-----------------|
| HTTP / Streamable HTTP transport | v1 distribution is npx-based; no hosted multi-tenant deployment | A hosted SaaS use case lands |
| `sampling/createMessage` | Adds consumer-side privacy posture surface; not needed for current tools | A tool would genuinely need consumer-LLM-quality summarization |
| `resources/subscribe` | Article changes do not need push-to-consumer semantics for current use | A consumer explicitly requests subscription |
| Cross-knowledge-base federation | One backend per install keeps the auth model trivial | Multi-tenant SaaS becomes scope |
| Dynamic tool list (`listChanged: true`) | Static set avoids capability drift class (R-MCP-003) | Per-user permission-gated tools warrant dynamic surface |

---

## References

| Resource | Path |
|----------|------|
| Tool registry | `docs/mcp/tool-registry.md` |
| Risk register | `docs/mcp/risk-register.md` |
| Capability schema | `docs/mcp/capability-schema.md` |
| Transport and auth | `docs/mcp/transport-and-auth.md` |
| Prompt-injection test plan | `docs/mcp/prompt-injection-test-plan.md` |
| MCP architecture overview (spec) | <https://modelcontextprotocol.io/docs/learn/architecture> |
| MCP server concepts (spec) | <https://modelcontextprotocol.io/docs/learn/server-concepts> |
| Module README | `platform/profiles/architectures/mcp-server/README.md` |
