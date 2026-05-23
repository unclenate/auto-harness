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

# MCP Risk Register — team-knowledge-base

**Owner:** @unclenate
**Last reviewed:** 2026-05-17
**Module:** `architectures/mcp-server`

Twelve canonical MCP-class risks plus project-specific entries. Reviewed on
every change to tool-registry, capability-schema, transport-and-auth, or
anything under `src/mcp/`.

---

## Open Risks

### R-MCP-001 — Prompt Injection via Tool Result

| Field | Value |
|-------|-------|
| Class | Model-layer attack |
| Description | `search_kb_articles` returns snippet text from articles authored by users. A user could write an article designed to inject instructions into the consuming agent. |
| Likelihood | Med — knowledge-base articles are user-authored |
| Impact | Med-High — depends on which higher-tier tools the consumer has loaded |
| Mitigation | Each result snippet wrapped in `<kb-content untrusted="true">` envelope; tool description tells the model to treat envelope content as data, not instructions; consumer-side recommendation in `tool-registry.md` reinforces this. Coverage in `docs/mcp/prompt-injection-test-plan.md § AC-1`. |
| Owner | @unclenate |
| Status | Mitigated |

### R-MCP-002 — Tool Poisoning via Description Field

| Field | Value |
|-------|-------|
| Class | Model-layer attack |
| Description | A poisoned tool description could steer the model. Risk is structural — all three tool descriptions are static. |
| Likelihood | Low — descriptions are statically authored in source, reviewed in PR |
| Impact | Med |
| Mitigation | Descriptions are never templated from runtime external content. PR review covers description text. |
| Owner | @unclenate |
| Status | Mitigated |

### R-MCP-003 — Capability-Negotiation Drift (Quiet Tool-List Growth)

| Field | Value |
|-------|-------|
| Class | Spec-conformance / supply-chain |
| Description | Tool list grows after `initialize` without `listChanged: true`. Server declares `listChanged: false` and the tool list is statically wired in source. |
| Likelihood | Low |
| Impact | High if it happened |
| Mitigation | Tool list is a single TypeScript array at server boot; no dynamic plugin loading; CI test diffs the live `tools/list` output against `docs/mcp/tool-registry.md` summary table. |
| Owner | @unclenate |
| Status | Mitigated |

### R-MCP-004 — Sampling-Based Exfiltration

| Field | Value |
|-------|-------|
| Class | Cross-boundary data flow |
| Description | Server uses `sampling/createMessage` to phone home. Not applicable — sampling is explicitly out of scope. |
| Likelihood | n/a |
| Impact | n/a |
| Mitigation | Sampling is not used and not declared in capabilities (see `docs/mcp/server-spec.md § Declared Capabilities`). |
| Owner | @unclenate |
| Status | Mitigated (by exclusion) |

### R-MCP-005 — Token Passthrough (Forbidden by Spec)

| Field | Value |
|-------|-------|
| Class | Authorization |
| Description | Server accepts or forwards tokens not issued for it. Stdio transport: no OAuth between client and server. Backend API: server uses its own `KB_API_KEY`, never forwards anything from the client. |
| Likelihood | Low |
| Impact | Critical if it happened |
| Mitigation | Stdio per MCP spec uses environment credentials; no inbound token surface. Backend calls use the server's own API key. No code path passes any client-supplied value into the backend `Authorization` header. |
| Owner | @unclenate |
| Status | Mitigated (by transport choice) |

### R-MCP-006 — Confused Deputy at OAuth Proxy

| Field | Value |
|-------|-------|
| Class | Authorization |
| Description | Server acts as OAuth proxy. Not applicable — stdio transport, no OAuth proxy role. |
| Likelihood | n/a |
| Impact | n/a |
| Mitigation | n/a |
| Owner | @unclenate |
| Status | Mitigated (by exclusion) |

### R-MCP-007 — SSRF on OAuth Metadata Fetching

| Field | Value |
|-------|-------|
| Class | Server-side request forgery |
| Description | Server returns OAuth metadata URLs that point inside private network. Not applicable — no OAuth metadata surface in stdio transport. |
| Likelihood | n/a |
| Impact | n/a |
| Mitigation | n/a |
| Owner | @unclenate |
| Status | Mitigated (by exclusion) |

### R-MCP-008 — Session Hijacking (Streamable HTTP Transport)

| Field | Value |
|-------|-------|
| Class | Session security |
| Description | Session ID guessed/stolen and reused. Not applicable — stdio is per-subprocess; no session ID surface. |
| Likelihood | n/a |
| Impact | n/a |
| Mitigation | n/a |
| Owner | @unclenate |
| Status | Mitigated (by exclusion) |

### R-MCP-009 — Local-Server Compromise (stdio Transport)

| Field | Value |
|-------|-------|
| Class | Supply chain / install-time |
| Description | Malicious payload in the server binary or in the launch command. Real for stdio. |
| Likelihood | Med — npm supply chain is the threat surface |
| Impact | Critical — arbitrary code execution on user's machine |
| Mitigation | Single distribution channel: `npm` under `@example/mcp-server-team-knowledge-base`. Launch command is `npx -y @example/mcp-server-team-knowledge-base` (auditable, no chained shell). 2FA on npm publish; npm provenance attestation enabled in CI; `package.json` declares only the dependencies the server actually uses, and the lockfile is committed. Hosts implementing one-click install will display the command in consent — designed to be readable. |
| Owner | @unclenate |
| Status | Monitoring |

### R-MCP-010 — Scope Inflation (Authorization)

| Field | Value |
|-------|-------|
| Class | Authorization |
| Description | Broad scope catalog. Not applicable — no OAuth surface in stdio. |
| Likelihood | n/a |
| Impact | n/a |
| Mitigation | n/a |
| Owner | @unclenate |
| Status | Mitigated (by exclusion) |

### R-MCP-011 — Dependency-Driven Tool Surface Drift

| Field | Value |
|-------|-------|
| Class | Supply chain |
| Description | SDK update silently adds tools the server exposes via plugin discovery. Server does not use plugin discovery — tools are statically wired. |
| Likelihood | Low |
| Impact | High if it happened |
| Mitigation | Static tool array in source; CI test diffs `tools/list` against `tool-registry.md`; SDK version bumps trigger companion rule via `package.json` sensitive path (`stacks/node-typescript`). |
| Owner | @unclenate |
| Status | Mitigated |

### R-MCP-012 — Tool Result Size Amplification

| Field | Value |
|-------|-------|
| Class | Cost / availability |
| Description | `search_kb_articles` could return enormous snippets that blow consumer context. |
| Likelihood | Med — depends on article sizes |
| Impact | Med |
| Mitigation | Per-result snippet capped at 1 KB (~250 tokens); full article available via a resource link the consumer fetches on demand; tool returns at most `limit` results (default 10, max 20). Limit enforced server-side regardless of input. |
| Owner | @unclenate |
| Status | Mitigated |

---

## Project-Specific Risks

### R-MCP-PROJ-001 — Knowledge-Base Backend Credential Loss

| Field | Value |
|-------|-------|
| Class | Secret management |
| Description | The `KB_API_KEY` environment variable grants broad read/write to the backend under the server's service principal. If the env is leaked (debug log, screenshot, shell history), an attacker has the same access. |
| Likelihood | Low-Med |
| Impact | High — broad access to team knowledge |
| Mitigation | Backend issues a service-account key scoped to the indexed KB only (not the broader workspace); key is rotatable; server never echoes the key in any tool result, log line, or error message; documented in `docs/mcp/transport-and-auth.md`. |
| Owner | @unclenate |
| Status | Monitoring |

---

## Closed Risks

| ID | Class | Risk | Closed Date | Resolution |
|----|-------|------|-------------|------------|

*(None yet.)*

---

## References

| Resource | Path / URL |
|----------|------------|
| Server spec | `docs/mcp/server-spec.md` |
| Tool registry | `docs/mcp/tool-registry.md` |
| Transport and auth | `docs/mcp/transport-and-auth.md` |
| Prompt-injection test plan | `docs/mcp/prompt-injection-test-plan.md` |
| MCP Security Best Practices (spec) | <https://modelcontextprotocol.io/specification/2025-06-18/basic/security_best_practices> |
| MCP Authorization (spec) | <https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization> |
