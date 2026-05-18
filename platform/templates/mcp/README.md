<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# MCP Template Family

Templates for projects that ship a Model Context Protocol (MCP) server. Used by
the `architectures/mcp-server` module. Written against the **MCP 2025-06-18 spec
revision**; pin the revision your server targets in `server-spec.md`.

| Template | Purpose | Required by `mcp-server` |
|----------|---------|--------------------------|
| `server-spec.md` | Server identity, capabilities, primitives, transport, auth, deployment | Yes |
| `tool-registry.md` | Per-tool table with consumer trust tier mapping, side effects, audit expectations | Yes |
| `risk-register.md` | MCP-specific risks: tool poisoning, prompt injection via tool result, capability drift, sampling exfiltration, transport misconfig, confused-deputy, SSRF, session hijacking, local-server compromise | Yes |
| `capability-schema.md` | Declared capabilities matrix, negotiation expectations | Optional |
| `prompt-injection-test-plan.md` | Coverage for the four canonical attack classes | Optional |
| `transport-and-auth.md` | stdio vs Streamable HTTP, OAuth 2.1 + PKCE + RFC 8707 posture, secret management | Optional |

## How to Use

1. Adopt `architectures/mcp-server` in your `harness.manifest.yaml`.
2. Copy the three required templates into your project's `docs/mcp/` directory.
3. Fill every `[[PLACEHOLDER_NAME]]` before committing — the placeholder validator
   will catch any you miss.
4. Add the optional templates as your server's surface grows (HTTP transport,
   declared capabilities beyond defaults, sampling support).

## Spec References

Templates cite these URLs at the points where the spec is normative:

- Architecture — https://modelcontextprotocol.io/docs/learn/architecture
- Server concepts (tools, resources, prompts) — https://modelcontextprotocol.io/docs/learn/server-concepts
- Authorization — https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization
- Security best practices — https://modelcontextprotocol.io/specification/2025-06-18/basic/security_best_practices

## See Also

- [`platform/profiles/architectures/mcp-server/`](../../profiles/architectures/mcp-server/) — the module these templates support
- [`platform/skills/harness-mcp/SKILL.md`](../../skills/harness-mcp/SKILL.md) — agent-facing guidance
- [`platform/workflow/mcp-server-build.md`](../../workflow/mcp-server-build.md) — operator workflow
- [ADR-0008: MCP Awareness](../../../docs/adr/ADR-0008-mcp-awareness.md)
