---
name: harness-mcp
description: "Use when a harness-governed project ships or designs an MCP (Model Context Protocol) server, or when an agent reasons about exposing harness governance to runtime harnesses via MCP. Covers the three MCP modes (consumer, producer, exposed-governance), per-tool consumer-tier mapping for exposed tools, prompt-injection defense surface, capability and transport posture, and the explicit boundary against the harness-tools skill (which governs consumed tools) and the harness-governance skill (which governs trust tiers and lifecycle)."
license: Apache-2.0
compatibility: "For projects that adopt the architectures/mcp-server module in harness.manifest.yaml, or that consume third-party MCP servers at product runtime beyond the developer-tool subset covered by TOOLS.md."
metadata:
  harness-module: architectures/mcp-server
  format-version: "1.0"
---

# Harness MCP

This skill governs the producer side of Model Context Protocol (MCP) work in
a harness-governed project. It is the sibling of `harness-tools` (which
governs the consumer side for the curated developer-tool MCP subset) and of
`harness-governance` (which governs trust tiers and lifecycle independent of
MCP).

Load this skill when **any** of the following is true:

- The project's `harness.manifest.yaml` includes `architectures/mcp-server`.
- The project ships an MCP server (npm package, pip package, hosted SaaS,
  Docker image, etc.) consumed by Claude Desktop, ChatGPT, an IDE host, or
  any other MCP-compliant client.
- The project is investigating exposing harness governance contracts via an
  MCP server to runtime harnesses (Hive, LangGraph, CrewAI). See OPP-0001
  and OPP-0003.

If the project only *consumes* third-party MCP servers, load `harness-tools`
instead. The two skills are not redundant — they govern opposite sides of
the wire.

## The Three MCP Modes

| Mode | Pattern | Where covered |
| ---- | ------- | ------------- |
| **Consumer** | Project uses a third-party MCP server (Linear, Slack, ...) at dev or product runtime | `TOOLS.md` + `harness-tools` skill |
| **Producer** | Project ships an MCP server consumed by clients | `architectures/mcp-server` + this skill |
| **Exposed governance** | Auto-harness governance contracts exposed via MCP to external runtime harnesses | Named in OPP-0003 / ADR-0008; v1 read-only scope; reference server is future work |

A single project can be in more than one mode. A project that builds an MCP
server and also consumes Linear MCP for issue tracking adopts both
`architectures/mcp-server` and the existing `TOOLS.md` + `harness-tools`
pattern.

## Producer-Side Trust Tier Mapping

The harness's tier model (Tier 0 read → Tier 5 production) applies to tools
your server exposes from the *consumer's perspective*. When your server
exposes a tool, the tool registry must declare the tier the consumer should
treat that tool as. This is a producer-side commitment to the consumer.

| Tier (consumer perspective when calling your tool) | Examples of tools that warrant this tier |
| -------------------------------------------------- | --------------------------------------- |
| 0 — Read-only | `search_documents`, `get_user_profile`, `list_topics` — pure reads, no side effects |
| 1 — Local analysis | `summarize_content`, `extract_entities` — compute over inputs, no external state |
| 2 — Workspace mutation | `create_draft`, `save_note` — writes to project-scoped private state, reversible |
| 3 — Git-writing / shared-state | `publish_article`, `broadcast_team_message`, `send_email` — externally visible, affects shared state |
| 4 — Environment-altering | `install_dependency`, `apply_migration` — irreversible local environment changes |
| 5 — Remote / production | `deploy`, `rotate_secret`, `delete_production_record` — irreversible production effects |

**The review-gate rule:** every tool entry in `docs/mcp/tool-registry.md`
must carry a one-line rationale for its tier. Defaulting every tool to
Tier 2 is a placeholder, not a tier mapping. When you (or the agent) add a
tool, the rationale is mandatory.

## What This Skill Does Not Replace

- **`harness-governance`** still defines the trust tiers, lifecycle stages,
  companion-rule mechanics, and validator chain. Load it first; it is the
  governance floor.
- **`harness-tools`** still governs how the project *consumes* MCP dev tools
  (Linear, Slack, Calendar, Gmail, Canva, Ahrefs, Similarweb). When the
  project also produces a server, both skills are active simultaneously.

## Producer-Side Threat Surface

The MCP threat model is distinct from a REST API's. The model reads tool
results as input; an attacker who controls any value returned from a tool
can attempt to instruct the model. The risks fall into named classes
(see `docs/mcp/risk-register.md` for full coverage and mitigation hooks):

| Risk | Spec source | Producer's primary mitigation |
| ---- | ----------- | ----------------------------- |
| **Prompt injection via tool result** (R-MCP-001) | Implicit in tools/call semantics | Envelope returned text as untrusted; sanitize known patterns; document the consumer-side expectation in `tool-registry.md` |
| **Tool poisoning via description** (R-MCP-002) | Implicit in tools/list semantics | Tool descriptions are statically authored, reviewed in PR, never templated from runtime external content |
| **Capability-negotiation drift** (R-MCP-003) | MCP spec § lifecycle / capabilities | Static tool list OR honest `listChanged` declaration with documented notification policy |
| **Sampling-based exfiltration** (R-MCP-004) | MCP spec § sampling | Do not use sampling, OR document privacy posture and what data may end up in sampling prompts |
| **Token passthrough** (R-MCP-005) | MCP Authorization spec — normative MUST NOT | Audience-validate every inbound token; obtain own tokens for upstream calls |
| **Confused deputy at OAuth proxy** (R-MCP-006) | MCP Security Best Practices § confused-deputy | Per-client consent before forwarding; bind cookies to client_id; exact `redirect_uri` matching |
| **SSRF on metadata fetching** (R-MCP-007) | MCP Security Best Practices § SSRF | Metadata responses include only own canonical URIs |
| **Session hijacking** (R-MCP-008) | MCP spec — normative "sessions MUST NOT be used for authentication" | CSPRNG session IDs bound to user identity; auth via Bearer token on every request |
| **Local-server compromise** (R-MCP-009) | MCP Security Best Practices § local servers | Auditable launch command; minimal declared privileges; trusted distribution channel |
| **Scope inflation** (R-MCP-010) | MCP Authorization § scope minimization | Minimal baseline scope; incremental elevation via WWW-Authenticate challenges |

For the four canonical prompt-injection attack classes (AC-1 through AC-4),
see `docs/mcp/prompt-injection-test-plan.md`. The skill's stance: the
producer is responsible for documenting the project's position on each
attack class explicitly, even if the position is "out of scope for v1 with
stated reason."

## Capability Negotiation Honesty

What the server declares in its `initialize` response and what it actually
does at runtime must match. Two specific failure modes the skill flags:

- **Declared `tools.listChanged: true` but never emits the notification** —
  misleads consumers who key on the capability to decide whether to cache
  `tools/list` results.
- **Tool list grows after `initialize` without `listChanged: true`** —
  spec violation; consumer's cached tool registry is silently wrong.

When changing what the server exposes, update `docs/mcp/capability-schema.md`
in the same commit as the implementation change. The companion rule
declared in `platform/profiles/architectures/mcp-server/module.yaml`
enforces this for `docs/mcp/tool-registry.md` and `capability-schema.md`.

## Transport and Auth Discipline

| Decision | Producer obligation |
| -------- | ------------------- |
| **stdio transport** | Document the auditable launch command in `server-spec.md`; the MCP spec requires hosts to display the command pre-execution. Design the command to be readable — no chained `curl \| sh`, no obfuscated `eval`. |
| **Streamable HTTP transport** | OAuth 2.1 + PKCE + RFC 8707 resource indicators are required by spec. Audience-validate every inbound token. Never forward inbound tokens to upstream APIs. See `docs/mcp/transport-and-auth.md`. |
| **Hybrid (both)** | Document the security posture per transport. The OAuth posture applies only to HTTP; stdio uses environment credentials and the host's secret management. |

## When the Agent Is Working in This Project

The agent should:

- Treat any change to `docs/mcp/`, `src/mcp/`, `mcp.json`, or `.mcp.json`
  as triggering the companion rule. Surface the rule to the human before
  claiming the change is complete.
- For every newly added tool: require an explicit tier mapping argument in
  `docs/mcp/tool-registry.md`. Do not commit a default fill.
- For every capability declaration change: update `capability-schema.md`
  and `server-spec.md` in the same commit.
- For every transport or auth change: update `transport-and-auth.md` and
  pair with a risk-register update or ADR.
- For tools that return externally-influenced content: ensure
  `prompt-injection-test-plan.md` exists and covers AC-1 through AC-3
  (and AC-4 if sampling is used).
- Treat sampling adoption as a Tier 3+ decision. Sampling means the server
  is reaching back into the consumer's LLM with prompts the producer
  controls — the consumer cannot fully audit those prompts. Adopting
  sampling without explicit risk-register coverage (R-MCP-004) is a
  governance failure.
- Treat OAuth-proxy patterns (the server brokering credentials to a
  third-party AS) as Tier 4+ design decisions. The confused-deputy
  attack class is real and bypasses every consent screen if the proxy is
  built carelessly. Always require explicit ADR.

The agent should NOT:

- Propose adding a tool without a tier rationale. "Tier 2" with no rationale
  is a placeholder that the review gate rejects.
- Propose `delete_*` or `broadcast_*` tools at Tier 0 or 1. By definition
  these are Tier 3+; the rationale must reflect the irreversibility.
- Propose forwarding inbound tokens to upstream APIs. The MCP spec is
  normative: tokens not issued for the MCP server MUST be rejected, and
  tokens received from the client MUST NOT be passed through to upstream
  resources.
- Propose using sessions as the authentication mechanism. Bearer-token
  auth on every request is required regardless of session presence.

## Stop Conditions

Halt and surface to the human when:

- A tool is being added whose tier mapping cannot be justified in one
  sentence.
- A change to declared capabilities (in code) lacks a matching update to
  `capability-schema.md`.
- An upstream API call from the server is using the inbound client's
  Bearer token (forbidden — must use the server's own credentials).
- A new tool returns content sourced from external input (user-supplied,
  third-party API, file content) and the prompt-injection test plan does
  not cover it.
- Distribution channel for a stdio server is being changed — that affects
  the consent dialog every consumer sees and is a governance moment.

## Reference

| Resource | Path |
| -------- | ---- |
| Module | `platform/profiles/architectures/mcp-server/module.yaml` |
| Module README | `platform/profiles/architectures/mcp-server/README.md` |
| Template family | `platform/templates/mcp/` |
| Workflow guide | `platform/workflow/mcp-server-build.md` |
| Sample project | `platform/examples/sample-projects/mcp-server-starter/` |
| Consumer-side counterpart skill | `platform/skills/harness-tools/SKILL.md` |
| Trust tier governance | `platform/skills/harness-governance/SKILL.md` |
| ADR-0008 | `docs/adr/ADR-0008-mcp-awareness.md` |
| OPP-0003 | `docs/opportunities/OPP-0003-mcp-producer-and-exportable-governance-via-mcp.md` |
| OPP-0001 (related, upstream) | `docs/opportunities/OPP-0001-exportable-governance-contract-for-runtime-harnesses.md` |
| MCP architecture (spec) | <https://modelcontextprotocol.io/docs/learn/architecture> |
| MCP server concepts (spec) | <https://modelcontextprotocol.io/docs/learn/server-concepts> |
| MCP Authorization (spec) | <https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization> |
| MCP Security Best Practices (spec) | <https://modelcontextprotocol.io/specification/2025-06-18/basic/security_best_practices> |

## Installing This Skill

```bash
cp -r platform/skills/harness-mcp .agents/skills/
# or for Claude Code specifically:
cp -r platform/skills/harness-mcp .claude/skills/
```
