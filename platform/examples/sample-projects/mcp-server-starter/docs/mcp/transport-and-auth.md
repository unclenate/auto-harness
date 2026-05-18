<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# MCP Transport and Authorization — team-knowledge-base

**Owner:** @unclenate
**Last updated:** 2026-05-17
**Module:** `architectures/mcp-server`
**Target MCP spec revision:** 2025-06-18

---

## Transport Decision

| Field | Value |
|-------|-------|
| Primary transport | stdio |
| Secondary transport | none |
| Decision rationale | v1 is a local-subprocess server distributed via npm; no hosted multi-tenant deployment. stdio removes the OAuth surface, the SSRF-on-metadata risk class, and the session-hijacking risk class entirely. HTTP transport is explicitly out of scope per PRD. |

### stdio

Per MCP spec: *"Implementations using an STDIO transport SHOULD NOT follow this
[authorization] specification, and instead retrieve credentials from the
environment."* This server complies.

---

## stdio Posture

| Field | Value |
|-------|-------|
| Launch command | `npx -y @example/mcp-server-team-knowledge-base` |
| Required environment variables | `KB_API_URL`, `KB_API_KEY` |
| Optional environment variables | `KB_LOG_LEVEL` (default `info`), `OTEL_EXPORTER_OTLP_ENDPOINT` |
| Secret storage expectation | Host's secret-management mechanism (Claude Desktop's environment-variable storage, VS Code's secret storage, or a project-local `.env` file with `chmod 600`) |
| Persistence beyond process lifetime | SQLite cache at `$XDG_DATA_HOME/team-knowledge-base/cache.db` — caches read-only search results for 5 minutes; deleted on first run after a server-version bump |

**Consent posture for one-click install.** Hosts implementing one-click MCP
server configuration MUST display the exact command pre-execution per MCP
spec. The launch command above is intentionally short and unambiguous:

- `npx -y` — a known npm CLI
- `@example/mcp-server-team-knowledge-base` — a single package name under a
  controlled scope

No `curl | sh`, no chained shell, no environment-dependent expansion. A
user looking at the consent dialog can verify the package name matches the
documented distribution channel.

---

## HTTP Posture

n/a — HTTP transport is not used in v1. If a future version adds HTTP
support, this section will be filled per the template's HTTP subsections
(canonical URI, OAuth posture, scope minimization, session-ID posture).

---

## Communication Security

| Requirement | Status |
|-------------|--------|
| All endpoints served over HTTPS in production | n/a — no HTTP endpoints |
| HTTP allowed only for loopback in development | n/a |
| Authorization server endpoints HTTPS | n/a — no AS |
| Redirect URIs are `localhost` or HTTPS | n/a — no OAuth flow |
| Backend KB API access over HTTPS | Yes — `KB_API_URL` must be `https://` (server validates at startup) |

---

## Secret Management

| Secret | Storage | Rotation cadence | Access policy |
|--------|---------|------------------|---------------|
| `KB_API_KEY` (backend service-account key) | Host secret store OR `.env` with 0600 perms; never committed | Quarterly; immediately on suspected leak | Server runtime only; never echoed in logs, errors, tool results, or telemetry |

Secrets never appear in: stderr logs (the server's log formatter has an
allowlist of fields, and `KB_API_KEY` is not on it), error responses
returned to the consumer, OTEL telemetry, tool result content, or any
documentation generated from the server's runtime state.

---

## SSRF Posture on Metadata

n/a — no metadata endpoints in stdio transport.

---

## Conformance Checklist

- [x] PKCE implemented and required — n/a (stdio)
- [x] RFC 8707 resource parameter required on inbound tokens — n/a (stdio)
- [x] Audience claim validated equals canonical URI — n/a (stdio)
- [x] No token-passthrough path exists — verified: backend calls use server's `KB_API_KEY`; no code path reads inbound credentials (stdio has none)
- [x] Sessions are not used for authentication — n/a (stdio)
- [x] Scope catalog is minimal; progressive elevation implemented — n/a (stdio)
- [x] Per-client consent for OAuth proxy — n/a (not a proxy)
- [x] All production endpoints HTTPS — backend KB API call validated `https://` at startup
- [x] Metadata responses never echo consumer-provided URLs — n/a (no metadata responses)

---

## References

| Resource | URL |
|----------|-----|
| Server spec | `docs/mcp/server-spec.md` |
| Risk register | `docs/mcp/risk-register.md` (R-MCP-005, R-MCP-009, R-MCP-PROJ-001) |
| MCP Authorization (spec) | https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization |
| MCP Security Best Practices (spec) | https://modelcontextprotocol.io/specification/2025-06-18/basic/security_best_practices |
