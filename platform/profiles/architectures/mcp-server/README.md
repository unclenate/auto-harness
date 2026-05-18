<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Architecture Overlay: MCP Server

This overlay governs projects that **ship a Model Context Protocol (MCP) server** —
a program that exposes tools, resources, and/or prompts to MCP clients (Claude
Desktop, ChatGPT, Claude Code, VS Code, Cursor, MCPJam, or any other compliant
host). It is the producer-side complement to the consumer-side discipline that
`TOOLS.md` + the `harness-tools` skill already provide for projects that *use*
third-party MCP servers.

It does **not** assume the implementation language, framework, transport choice,
deployment surface, or host target — only that the project is structured as an
MCP server per the spec.

---

## When to Use This Overlay

Pick `architectures/mcp-server` when **any** of the following is true:

- The project's product (or a meaningful part of it) is an MCP server consumed by
  Claude Desktop, ChatGPT, an IDE host, or a remote MCP-compatible client.
- The project ships an internal MCP server consumed by other in-house agents
  (the agent runtime is the consumer; the server is the producer).
- The project is building an MCP server as a step toward exposing
  harness-governance contracts via MCP to runtime harnesses (see OPP-0001 and
  OPP-0003).

Do **not** pick this overlay when the project only *consumes* third-party MCP
servers — for that case, fill out `TOOLS.md` (existing pattern) and install the
`harness-tools` skill. Producer-side and consumer-side discipline are siblings;
choose the one that matches what the project actually ships.

A project can compose `mcp-server` with `api-service` if the same codebase serves
both an HTTP API and an MCP server. They are not in `conflictsWith` and do not
require each other.

---

## What This Overlay Requires

**Required artifacts:**

- `docs/mcp/server-spec.md` — the server's identity, declared capabilities,
  primitive set (tools, resources, prompts), transport (stdio / Streamable HTTP),
  auth model, runtime requirements, deployment surface, and target hosts.
- `docs/mcp/tool-registry.md` — per-tool table with name, intent, inputs/outputs,
  side effects, **consumer trust tier** (the tier the consumer should treat each
  tool as — mirror of the `TOOLS.md` discipline applied from the producer side),
  approval gating expectation, idempotency notes, audit-log expectations.
- `docs/mcp/risk-register.md` — MCP-specific risks: tool poisoning, prompt
  injection through tool results, capability scope creep, sampling-based
  exfiltration, transport TLS/auth misconfiguration, dependency-driven tool
  surface drift, confused-deputy at the OAuth proxy layer, SSRF on metadata
  fetching, session-ID guessing, local-server compromise. Each risk must have an
  owner and a mitigation hook.

**Optional artifacts:**

- `docs/mcp/capability-schema.md` — declared capabilities matrix and negotiation
  expectations. Required in spirit if the server advertises `listChanged`
  notifications or supports any non-default capability; the validator does not
  enforce this but reviewers should.
- `docs/mcp/prompt-injection-test-plan.md` — minimum test coverage for the four
  canonical attack classes (untrusted string in tool result, nested tool call
  from result, untrusted resource read, sampling-loop attack).
- `docs/mcp/transport-and-auth.md` — stdio vs Streamable HTTP, OAuth 2.1 + PKCE +
  RFC 8707 resource-indicator posture, secret management, scope minimization.
  Required in spirit if the server supports the HTTP transport with any auth
  model beyond "none."

**Sensitive paths** (companion-rule triggers):

- `docs/mcp/**` — any change to the MCP doc surface
- `src/mcp/**`, `mcp/**`, `server/mcp/**` — server implementation
- `mcp.json`, `.mcp.json`, `mcp-manifest.*` — client-installation manifests

Use the templates at `platform/templates/mcp/`.

---

## Companion Rules

**Tool registry / capability schema / server implementation changes** must be paired
in the same commit with one of:

- `docs/mcp/risk-register.md` (risk-review pairing)
- `docs/adr/ADR-*.md` (architectural rationale)
- `docs/architecture/overview.md` (system architecture refresh)

Rationale: the exposed tool surface is the producer-side contract with every
consumer. Adding a tool, changing its input schema, or removing it without a
paired risk-review or decision record is the equivalent of changing an HTTP API
route without updating the API contract — except worse, because MCP tools are
*called by the model*, so a misleading tool description or a quietly added tool
can be invoked autonomously by the consumer's LLM.

**Transport-and-auth changes** must be paired with a risk-register or ADR update.
Token audience binding (RFC 8707), PKCE posture, and scope minimization are
normative MUSTs under the MCP spec; the auth posture must not drift quietly.

---

## Core Rules

> **The exposed tool surface is a contract.** Every tool the server declares is
> a contract with every consumer. The tool registry is the canonical record of
> that contract; the consumer-tier column is the producer-side commitment about
> what the consumer should authorize.

> **Tier mapping is reasoned, not boxed.** Defaulting every tool to Tier 2 is a
> placeholder, not a tier mapping. The review gate requires reviewers to verify
> the tier reasoning per tool. A `read_doc` tool that only returns text the model
> already has access to is Tier 0; a `delete_document` tool with no undo is
> Tier 4 from the consumer's perspective.

> **Token passthrough is forbidden.** The MCP spec is explicit: *"MCP servers
> MUST NOT accept any tokens that were not explicitly issued for the MCP server."*
> If the server calls upstream APIs, it obtains its own tokens — it never
> forwards the client's token.

> **Capability negotiation must be honest.** What the server declares in the
> `initialize` response and what it actually does at runtime must match. Declaring
> `tools.listChanged` and never emitting the notification misleads consumers;
> emitting without declaring is a spec violation.

> **Prompt injection through tool results is the threat model that distinguishes
> MCP servers from REST APIs.** The model reads tool results as input. An attacker
> who controls any value returned from a tool can attempt to instruct the model.
> The `prompt-injection-test-plan.md` artifact exists to force teams to address
> this explicitly rather than rediscover it under incident.

---

## How This Overlay Composes

| Pair with | When |
|-----------|------|
| `stacks/node-typescript` | TypeScript MCP server using `@modelcontextprotocol/sdk` |
| `stacks/python` | Python MCP server using `mcp` SDK |
| `architectures/api-service` | Same codebase serves both HTTP API and MCP server |
| `architectures/event-driven` | Server emits notifications and reacts to upstream events |
| `data/relational-postgres` | Server backs tools with a relational store |
| `management/interview-driven` | Small team / prototype tier — pairs cleanly with `delivery/prototype` |
| `delivery/production-saas` | Remote MCP server (Streamable HTTP transport) deployed for many clients |

`mcp-server` **does not require** `api-service` and is not a flavor of it. The
MCP wire format, lifecycle handshake, primitive registry, and tier-mapped tool
surface form their own topology. See ADR-0008 for the rationale.

---

## Spec-Revision Pinning

The templates in `platform/templates/mcp/` were written against the
**MCP 2025-06-18 spec revision**. The `server-spec.md` template asks the author
to name the spec revision their server targets, so divergence is visible at
audit time. When a future revision lands, the template content can be updated
in place; consumers' filled artifacts will continue to reflect their target
revision.

Authoritative spec sources cited by the templates:

- Architecture overview — `https://modelcontextprotocol.io/docs/learn/architecture`
- Server concepts (tools, resources, prompts) — `https://modelcontextprotocol.io/docs/learn/server-concepts`
- Authorization — `https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization`
- Security best practices — `https://modelcontextprotocol.io/specification/2025-06-18/basic/security_best_practices`

---

## Relationship to Existing MCP Coverage

The harness already covers the **consumer** side of MCP for a curated set of
developer tools:

- `TOOLS.md` (repo root) — Linear, Slack, Calendar, Gmail, Canva, Ahrefs,
  Similarweb, each tier-mapped per action class.
- `platform/skills/harness-tools/SKILL.md` — the consumer-side skill.
- `platform/agents/openclaw/module.yaml` — references `TOOLS.md` as a sensitive
  required artifact with its own companion rule.

This overlay is the **producer** side complement. The two sides use the same
tier vocabulary applied to opposite sides of the wire. A team can adopt one,
the other, or both without conflict; the relationship is documented in the
`harness-mcp` skill and in `platform/workflow/mcp-server-build.md`.

The third mode — **harness governance exposed via MCP** so external runtime
harnesses can query trust tiers, manifest reads, and companion-rule templates
through a `harness-governance` MCP server — is named in OPP-0003 and ADR-0008
but is intentionally not shipped in v1. It is downstream of this architecture
module: when adoption signal exists, the reference server will itself be
governed by `architectures/mcp-server`.

---

## Agent Behavior

Agents working in projects that have this module active:

- Treat every change under `docs/mcp/`, `src/mcp/`, or the MCP manifest files as
  triggering the companion rule. Surface the rule to the human before claiming
  the change is complete.
- Treat every newly added tool as requiring a tier mapping argument, not a
  default fill. The `harness-mcp` skill's instructions explain why.
- Surface any change to declared capabilities, transport choice, or auth posture
  as a Tier 2+ action with explicit human review. Capability negotiation drift
  is a class of bug the consumer cannot detect from outside.
- Do not propose mutation tools that bypass consumer-side approval gates. If the
  server is going to expose a "delete" or "broadcast" tool, that requires the
  producer to commit, in the registry, to a Tier 3+ posture and to recommend
  consumer-side approval gating.

---

## See Also

- [ADR-0008: MCP Awareness](../../../../docs/adr/ADR-0008-mcp-awareness.md) — why this module exists, alternatives considered, exposed-governance scope
- [OPP-0003: MCP Producer Posture and Exportable Governance via MCP](../../../../docs/opportunities/OPP-0003-mcp-producer-and-exportable-governance-via-mcp.md) — the opportunity record this module promotes
- [OPP-0001: Exportable Governance Contract for Runtime Harnesses](../../../../docs/opportunities/OPP-0001-exportable-governance-contract-for-runtime-harnesses.md) — the upstream opportunity OPP-0003 partially answers
- [`platform/templates/mcp/`](../../../templates/mcp/) — the template family this module references
- [`platform/skills/harness-mcp/SKILL.md`](../../../skills/harness-mcp/SKILL.md) — the on-demand skill for producer-side discipline
- [`platform/workflow/mcp-server-build.md`](../../../workflow/mcp-server-build.md) — operator workflow
- [`platform/examples/sample-projects/mcp-server-starter/`](../../../examples/sample-projects/mcp-server-starter/) — reference layout
- [`TOOLS.md`](../../../../TOOLS.md) — consumer-side tool registry (existing, complements this overlay)
