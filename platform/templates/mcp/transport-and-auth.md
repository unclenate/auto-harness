<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# MCP Transport and Authorization

**Owner:** [[TRANSPORT_OWNER]]
**Last updated:** YYYY-MM-DD
**Module:** `architectures/mcp-server`
**Companion artifacts:** `docs/mcp/server-spec.md`, `docs/mcp/risk-register.md` (R-MCP-005, R-MCP-006, R-MCP-007, R-MCP-008, R-MCP-010)
**Target MCP spec revision:** 2025-06-18

This document is the detailed transport and authorization posture for the MCP
server. It is optional under `architectures/mcp-server` but required in
spirit when the server supports any HTTP transport or any non-trivial auth
model.

The MCP spec is normative on a lot of this surface — RFC 8707 resource
indicators, PKCE, audience validation, token-passthrough prohibition. Where
this document quotes a MUST, the MUST is normative and a project that
deviates is non-conformant.

---

## Transport Decision

| Field | Value |
|-------|-------|
| Primary transport | [[stdio / Streamable HTTP]] |
| Secondary transport | [[stdio / Streamable HTTP / none]] |
| Decision rationale | [[E.g. "stdio for local desktop hosts; HTTP for remote tenant SaaS"]] |

### stdio

- Used for local subprocess servers spawned by the host (Claude Desktop,
  VS Code MCP, Cursor).
- No OAuth flow per spec: *"Implementations using an STDIO transport SHOULD
  NOT follow this [authorization] specification, and instead retrieve
  credentials from the environment."*
- Credentials are environment variables, set by the host before launch.
- Launch command is auditable; consumers see it before approving install.

### Streamable HTTP

- Used for remote servers (multi-tenant SaaS, internal hosted service).
- Requires OAuth 2.1 authorization per spec.
- Bearer token in `Authorization` header on every request — *"Note that
  authorization MUST be included in every HTTP request from client to
  server, even if they are part of the same logical session."*
- Tokens MUST NOT appear in the URI query string.

---

## stdio Posture (if applicable)

| Field | Value |
|-------|-------|
| Launch command | `[[npx -y @org/mcp-server-foo]]` |
| Required environment variables | [[`FOO_API_KEY`, `BAR_URL`]] |
| Optional environment variables | [[`FOO_DEBUG=1`]] |
| Secret storage expectation | [[host's secret-management mechanism / .env file with documented permissions / etc.]] |
| Persistence beyond process lifetime | [[none / SQLite at $XDG_DATA_HOME/foo / etc.]] |

**Consent posture for one-click install (MCP spec normative).** Hosts
implementing one-click MCP server configuration MUST display the exact
command pre-execution and require explicit user approval. The server's
distribution channel and launch command in `server-spec.md` should be
designed so the consent dialog is meaningful — no obfuscated commands,
no chained pipe-to-shell installs.

---

## HTTP Posture (if applicable)

### Canonical Server URI

| Field | Value |
|-------|-------|
| Canonical URI | `[[https://mcp.example.com/mcp]]` |
| URI form policy | [[without trailing slash unless semantically significant]] |

This value is what MCP clients put in the OAuth `resource` parameter
(RFC 8707). Clients MUST send it on every authorization and token request.
Servers MUST validate that inbound tokens carry this value (or an equivalent)
in their audience claim.

### Authorization Server Discovery

The server MUST implement OAuth 2.0 Protected Resource Metadata (RFC 9728).
On a 401 response, the server MUST include a `WWW-Authenticate` header per
RFC 9728 §5.1 indicating the resource-metadata URL.

| Field | Value |
|-------|-------|
| Protected Resource Metadata endpoint | `/.well-known/oauth-protected-resource` |
| Authorization server URL(s) | `[[https://auth.example.com]]` |
| Supports Dynamic Client Registration (RFC 7591)? | [[Yes / No — if No, document how clients obtain client_id]] |

### OAuth Flow Requirements

| Requirement | Value |
|-------------|-------|
| PKCE (RFC 7636) | **MUST** be implemented by clients; the server MUST reject token requests without `code_verifier` |
| Resource parameter (RFC 8707) | **MUST** be included by clients in authorization and token requests |
| Token audience validation | Server MUST validate that the `aud` claim equals the canonical URI |
| Token type | Bearer in `Authorization` header — MUST NOT be in URI query string |
| Redirect URI validation | Exact string match against registered URI; no pattern/wildcards |
| State parameter | Cryptographically secure; single-use; short expiration (≤ 10 min) |

### Token Passthrough — Prohibited

**MCP spec, normative:** *"MCP servers MUST NOT accept any tokens that were
not explicitly issued for the MCP server."*

If the server calls upstream APIs (third-party services, internal
microservices), it obtains its own tokens via its own OAuth client
credentials. It NEVER forwards the inbound client's token to an upstream
API. The two token contexts must be kept separate.

| Upstream system | Server's auth posture |
|-----------------|-----------------------|
| [[Third-party API]] | [[OAuth 2.1 with separate client_id; token cached server-side per upstream principal]] |
| [[Internal service]] | [[mTLS / signed service token / etc.]] |

### Scope Posture

The MCP spec recommends progressive scope elevation rather than broad
upfront grants.

| Field | Value |
|-------|-------|
| Baseline scope | `[[mcp:tools-basic]]` — read-only / low-risk discovery |
| Elevation scopes | `[[mcp:tools-write]]`, `[[mcp:resources-subscribe]]` |
| Wildcard / omnibus scopes | **Must not exist** — no `*`, `all`, or `full-access` |
| Elevation challenge mechanism | `WWW-Authenticate: scope="mcp:tools-write"` on the specific failing call |

### Session ID Posture (Streamable HTTP)

**MCP spec, normative:** *"MCP servers MUST NOT use sessions for
authentication."*

| Field | Value |
|-------|-------|
| Session IDs generated by | [[CSPRNG — UUIDv4 or equivalent]] |
| Session ID bound to user identity in storage | `[[<user_id>:<session_id>]]` |
| Session expiration | [[N minutes idle / N hours max]] |
| Session rotation policy | [[after auth changes / after N hours / never]] |

Every inbound HTTP request validates the Bearer token regardless of session
presence. The session is a correlation handle, not an authentication
mechanism.

### Confused-Deputy Posture (if server is an OAuth proxy)

**Applicable only if the server proxies authorization to a third-party AS
using a static client ID.** If not, mark this section N/A.

| Requirement | Status |
|-------------|--------|
| Per-client consent stored before forwarding | [[Yes / N/A]] |
| MCP-level consent screen identifies requesting client by name | [[Yes / N/A]] |
| Consent cookies use `__Host-` prefix, `Secure`, `HttpOnly`, `SameSite=Lax` | [[Yes / N/A]] |
| Consent cookies bound to specific `client_id`, not generic "user consented" | [[Yes / N/A]] |
| `redirect_uri` exact-match validation, no pattern matching | [[Yes / N/A]] |
| `state` parameter generated cryptographically, single-use, ≤ 10 min expiry | [[Yes / N/A]] |
| `state` cookie set only AFTER user approves MCP-level consent | [[Yes / N/A]] |

---

## Communication Security

| Requirement | Status |
|-------------|--------|
| All endpoints served over HTTPS in production | [[Yes]] |
| HTTP allowed only for loopback (localhost/127.0.0.1/::1) in development | [[Yes]] |
| Authorization server endpoints HTTPS | [[Yes]] |
| Redirect URIs are `localhost` or HTTPS | [[Yes]] |

---

## Secret Management

| Secret | Storage | Rotation cadence | Access policy |
|--------|---------|------------------|---------------|
| OAuth client secret (to upstream AS) | [[secrets manager — Vault / SSM / etc.]] | [[quarterly / on incident]] | [[server runtime only]] |
| Third-party API keys (used in tool calls) | [[secrets manager]] | [[per-vendor policy]] | [[server runtime only]] |
| Session signing keys (if applicable) | [[secrets manager]] | [[monthly]] | [[server runtime only]] |

Secrets never appear in: logs, error responses, telemetry, tool result
content, sampling prompts, capability declarations.

---

## SSRF Posture on Metadata

If the server returns OAuth metadata documents containing URLs, those URLs
MUST point only to the server's own resources. The server never echoes
consumer-provided URLs in metadata responses. This protects consumers from
the SSRF attack class documented in `docs/mcp/risk-register.md` § R-MCP-007.

---

## Conformance Checklist

Before declaring transport-and-auth ready for production, verify each item.
Failures bind back to specific risk-register entries.

- [ ] PKCE implemented and required (R-MCP-006)
- [ ] RFC 8707 resource parameter required on inbound tokens (R-MCP-005)
- [ ] Audience claim validated equals canonical URI (R-MCP-005)
- [ ] No token-passthrough path exists (R-MCP-005)
- [ ] Sessions are not used for authentication (R-MCP-008)
- [ ] Scope catalog is minimal; progressive elevation implemented (R-MCP-010)
- [ ] Per-client consent for OAuth proxy (R-MCP-006) — or N/A
- [ ] All production endpoints HTTPS (R-MCP-007 indirect)
- [ ] Metadata responses never echo consumer-provided URLs (R-MCP-007)

---

## References

| Resource | URL |
|----------|-----|
| Server spec | `docs/mcp/server-spec.md` |
| Risk register | `docs/mcp/risk-register.md` |
| MCP Authorization (spec) | <https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization> |
| MCP Security Best Practices (spec) | <https://modelcontextprotocol.io/specification/2025-06-18/basic/security_best_practices> |
| OAuth 2.1 draft | <https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1-13> |
| RFC 8707 — Resource Indicators | <https://www.rfc-editor.org/rfc/rfc8707.html> |
| RFC 9728 — Protected Resource Metadata | <https://datatracker.ietf.org/doc/html/rfc9728> |
| RFC 7591 — Dynamic Client Registration | <https://datatracker.ietf.org/doc/html/rfc7591> |
