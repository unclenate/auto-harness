<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# MCP Server Spec

**Owner:** [[SERVER_OWNER]]
**Last updated:** YYYY-MM-DD
**Module:** `architectures/mcp-server`
**Target MCP spec revision:** 2025-06-18

This document is the authoritative identity record for the MCP server this project
ships. It is required by the `architectures/mcp-server` overlay and must be updated
whenever the server's identity, capabilities, primitives, transport, auth, or
deployment surface changes.

---

## Server Identity

| Field | Value |
|-------|-------|
| Server name | `[[SERVER_NAME]]` |
| Server version (semver) | `[[SERVER_VERSION]]` |
| Implementation language | [[LANGUAGE]] |
| SDK / framework | [[SDK_NAME_AND_VERSION]] |
| Canonical URI (HTTP transport only) | `[[https://mcp.example.com/mcp or n/a for stdio]]` |
| Distribution channel | [[npm package / pip package / Docker image / hosted SaaS / etc.]] |
| Source repository | `[[github.com/org/repo path]]` |

The canonical URI is the value clients put in the OAuth `resource` parameter
(RFC 8707). For stdio servers it is `n/a` — local stdio servers do not use
OAuth authorization per the MCP spec.

---

## Target Hosts

List the MCP hosts the server is designed to be consumed by. This is
informational — MCP is host-agnostic by spec — but it shapes interoperability
expectations.

| Host | Verified | Notes |
|------|----------|-------|
| Claude Desktop | [[Yes / No / Planned]] | [[any host-specific config notes]] |
| Claude Code | [[Yes / No / Planned]] | |
| ChatGPT | [[Yes / No / Planned]] | |
| VS Code | [[Yes / No / Planned]] | |
| Cursor | [[Yes / No / Planned]] | |
| MCPJam | [[Yes / No / Planned]] | |
| Internal agent runtime | [[Yes / No / Planned]] | [[name the runtime]] |

---

## Declared Capabilities

What this server tells clients it supports during the `initialize` handshake.
Capability negotiation must be honest — declaring `tools.listChanged` and never
emitting the notification misleads consumers; emitting without declaring is a
spec violation.

```json
{
  "capabilities": {
    "tools": {
      "listChanged": [[true | false]]
    },
    "resources": {
      "listChanged": [[true | false]],
      "subscribe": [[true | false]]
    },
    "prompts": {
      "listChanged": [[true | false]]
    },
    "logging": {}
  }
}
```

Mark each primitive present (`tools`, `resources`, `prompts`, `logging`) or omit
it from the declaration entirely. Do not declare a primitive the server cannot
serve.

If the server uses `sampling/createMessage` (asks the client's LLM for
completions on the server's behalf), name it here and explain why — this is the
class of feature most likely to trigger consumer-side suspicion because the
server is reaching back into the client's model.

| Sampling use | [[describe / "not used"]] |
| Elicitation use | [[describe / "not used"]] |

---

## Primitives Inventory

### Tools

This section is a count and link only. The authoritative tool registry is at
`docs/mcp/tool-registry.md`.

| Total tools exposed | [[N]] |
| Highest-tier exposed tool | [[Tier N — name]] |
| Tools with side effects on third-party systems | [[N]] |
| Tools that are idempotent | [[N]] |

### Resources

| Total resources exposed | [[N]] |
| Resource URI schemes used | [[file:// / db:// / project:// / etc.]] |
| Resources with parameterized templates | [[N]] |
| Resources that support `resources/subscribe` | [[N]] |

For dynamic resources, name the resource template URIs the server exposes
(e.g. `team-kb://articles/{slug}`, `team-kb://topics/{topic}`).

### Prompts

| Total prompts exposed | [[N]] |

For each prompt, name it and the arguments it accepts. Prompts are
user-controlled (the user explicitly invokes them), so they are the
lowest-risk primitive to add — but the prompt body's content is still under
your control and visible to the consumer's model.

---

## Transport

| Field | Value |
|-------|-------|
| Primary transport | [[stdio / Streamable HTTP]] |
| Secondary transport | [[stdio / Streamable HTTP / none]] |

If `stdio`: the server is launched as a subprocess by the client. Document the
exact launch command users will configure (`npx`, `uvx`, `docker run`, etc.).
Note that the MCP spec requires hosts implementing one-click install to display
this command verbatim pre-execution; design the command to be auditable.

If `Streamable HTTP`: the server is reached over HTTPS. See
`docs/mcp/transport-and-auth.md` for the OAuth posture.

| stdio launch command (if applicable) | `[[npx -y @org/mcp-server-foo or similar]]` |
| HTTP endpoint (if applicable) | `[[https://mcp.example.com/mcp]]` |
| Authorization model | [[none (stdio with env credentials) / OAuth 2.1 / API key in header / etc.]] |

---

## Runtime Requirements

| Field | Value |
|-------|-------|
| Required environment variables | [[`FOO_API_KEY`, `BAR_URL`]] |
| Required runtime permissions | [[network egress to api.example.com / filesystem read of ~/Documents / etc.]] |
| Persistent state | [[none / SQLite at $XDG_DATA_HOME/foo / etc.]] |
| External service dependencies | [[name them; for each, what happens when unavailable]] |
| Minimum host runtime version | [[Node 20 / Python 3.11 / etc.]] |

---

## Deployment Surface

| Field | Value |
|-------|-------|
| Deployment mode | [[local stdio / single-tenant remote / multi-tenant remote SaaS]] |
| Scaling model | [[per-client subprocess / shared HTTP service / serverless]] |
| Observability hookpoints | [[OpenTelemetry / stdout structured logs / etc.]] |

For multi-tenant remote deployments, name how tenant isolation is enforced
(separate auth contexts? per-tenant API keys at the server's upstream calls?
tenant-scoped session IDs?).

---

## Spec Revision and Compatibility

| Field | Value |
|-------|-------|
| Spec revision targeted | 2025-06-18 |
| Negotiated `protocolVersion` in `initialize` response | `"2025-06-18"` |
| Fallback behavior on protocol mismatch | [[reject connection / negotiate down to 2024-XX-XX / etc.]] |

The MCP spec is evolving (capability semantics, MCP Apps, Tasks). Pin the
revision the server is built against here so consumers and reviewers see the
divergence point.

---

## Out of Scope (Explicit)

| Feature | Reason | Reconsider when |
|---------|--------|-----------------|
| [[e.g. sampling/createMessage]] | [[no model-independence concern; would add server-side LLM dependency]] | [[when a tool genuinely needs LLM-quality summarization at the server tier]] |
| [[e.g. resources/subscribe]] | [[consumers do not need live updates for v1]] | [[when a consumer requests subscription semantics]] |

Naming explicit out-of-scope items is a governance discipline, not a roadmap
hedge — it tells consumers what they can rely on the server NOT doing.

---

## References

| Resource | Path |
|----------|------|
| Tool registry | `docs/mcp/tool-registry.md` |
| Risk register | `docs/mcp/risk-register.md` |
| Capability schema (if used) | `docs/mcp/capability-schema.md` |
| Transport and auth (if HTTP) | `docs/mcp/transport-and-auth.md` |
| Prompt-injection test plan (if used) | `docs/mcp/prompt-injection-test-plan.md` |
| MCP architecture overview (spec) | <https://modelcontextprotocol.io/docs/learn/architecture> |
| MCP server concepts (spec) | <https://modelcontextprotocol.io/docs/learn/server-concepts> |
| Module README | `platform/profiles/architectures/mcp-server/README.md` |
