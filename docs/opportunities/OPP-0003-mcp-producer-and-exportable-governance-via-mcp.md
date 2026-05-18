<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0003 — MCP Producer Posture and Exportable Governance via MCP

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-05-17
**Last Updated:** 2026-05-18
**Confidence:** medium-high

---

## Thesis

Teach auto-harness to govern three Model Context Protocol (MCP) modes as first-class
shapes, not as ad-hoc additions to a project's docs:

1. **MCP consumer** — the project uses third-party MCP servers in its dev or runtime
   workflow. This is already partially handled by `TOOLS.md` + the `harness-tools`
   skill for the developer-tool subset (Linear, Slack, Calendar, Gmail, Canva, Ahrefs,
   Similarweb). The gap is third-party MCP servers consumed *at product runtime*, which
   today has no harness-native registry.
2. **MCP producer** — the project ships an MCP server. Today the harness has nothing
   to say about exposed tool surface, capability negotiation, transport/auth posture,
   prompt-injection defense, or consumer-side tier mapping. This is the largest gap.
3. **Exposed governance via MCP** — auto-harness's own governance contract (trust
   tiers, lifecycle conditions, companion rules, validator chain) is exposed via an
   MCP server so external runtime harnesses (Hive, LangGraph, CrewAI, custom) can
   gate state transitions and self-modification calls behind the harness contract
   without committing to auto-harness's full markdown/YAML surface. This is the
   "enforceable via MCP tool gating?" path that OPP-0001 left open as a question.

The bet: MCP is consolidating as the connective tissue between AI applications and
external systems. A governance-harness genre that knows MCP both as a *thing projects
build* and as *the protocol by which the harness itself can be consumed* is durably
positioned.

## Origin / Evidence

- **External signal — MCP specification (2025-06-18, latest as of 2026-05-17).**
  The protocol defines three server primitives (`tools`, `resources`, `prompts`),
  three client primitives (`sampling`, `elicitation`, `logging`), explicit capability
  negotiation in the initialize handshake, two transports (`stdio`, `Streamable HTTP`),
  and a full OAuth 2.1 + RFC 8707 authorization model for HTTP transports. The
  Security Best Practices document is normative: confused-deputy mitigations, token
  audience binding (`MUST NOT accept tokens not issued for the MCP server`),
  scope minimization, SSRF prevention on metadata fetching, session-ID rules
  (`MUST NOT use sessions for authentication`), local-server compromise consent.
  Source: `https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization`,
  `https://modelcontextprotocol.io/specification/2025-06-18/basic/security_best_practices`,
  `https://modelcontextprotocol.io/docs/learn/architecture`,
  `https://modelcontextprotocol.io/docs/learn/server-concepts`.
- **External signal — broad adoption.** MCP is supported as a connector model across
  Claude, ChatGPT, VS Code, Cursor, MCPJam, and the cloud-vendor agent surfaces
  (Vercel AI SDK, Cloudflare, Google A2UI tools, etc.). The reference servers repo
  (`github.com/modelcontextprotocol/servers`) is large and growing. The bet that
  projects will *build* MCP servers as a product or an internal capability is no
  longer speculative.
- **External signal — Anthropic's MCP-Apps and the "MCP host" surface.** MCP is
  evolving from a developer-tool plumbing protocol into a runtime surface that ships
  interactive UI ("MCP Apps"). That trajectory raises the governance surface of an
  MCP server beyond "what tools does it expose" into "what can it render and on
  whose authority."
- **Internal precedent — TOOLS.md + harness-tools.** The harness already maps
  exposed MCP-tool actions to trust tiers per tool (Linear at Tier 0 / Tier 2 / Tier 3
  depending on the action class; Slack send at Tier 3; Calendar/Gmail at Tier 3;
  Canva publish at Tier 3; Ahrefs/Similarweb at Tier 0). That discipline is the
  right pattern to require for tools that *we expose* via an MCP server we ship.
- **Internal precedent — OPP-0001 (Exportable Governance Contract for Runtime
  Harnesses).** OPP-0001's open question 2: *"Does the contract need to be
  enforceable (cryptographic, MCP-shaped tool gating) or is it sufficient for it to
  be declarative (a YAML/JSON schema that runtime harnesses voluntarily comply
  with)? Two very different scopes."* This OPP partially answers it: MCP gives the
  enforceable path a concrete shape. A `harness-governance` MCP server is the most
  realistic way to *expose* the contract to a runtime harness's call surface, and
  the runtime harness can gate self-modification on a tools/call to the harness
  server before proceeding.
- **Internal precedent — OPP-0002 (Agentic Interface Awareness).** The agentic
  interfaces R&D (sibling branch) covers the *in-product* agent-as-actor surface.
  This OPP covers the *protocol* by which agents reach external systems. The two
  are complementary; the only point of friction is when an agent surface IS an MCP
  host (Claude desktop, MCP Apps) — OPP-0002 punts that case forward and this OPP
  picks it up via the producer module.
- **Sibling artifact — `platform/profiles/architectures/api-service`.** API contracts
  as commitments, ADR-or-architecture-update companion rule on handler paths. The
  MCP-server architecture overlay is the same shape with an MCP-specific surface:
  the tool registry is the contract, not the HTTP route table.

## Why Now

1. **MCP is past the speculation window.** The spec has cut a stable
   2025-06-18 revision with explicit normative requirements. Reference SDKs exist
   in TypeScript, Python, Go, Rust, Kotlin. Reference servers exist. Hosts (Claude,
   ChatGPT, VS Code, Cursor) consume MCP today. A harness that recognizes "you are
   building an MCP server" can attach to a real and growing project shape.
2. **The threat surface is novel enough to need its own template family.** Prompt
   injection through tool *results* (the tool returns a string the model interprets
   as instructions), tool poisoning (a tool description that itself contains an
   injection payload), capability-negotiation drift (a server quietly adds a tool
   after `initialize`), sampling-based exfiltration (server uses the client's
   `sampling/createMessage` to phone home), and confused-deputy attacks at the
   OAuth proxy layer are not adequately covered by `api-service` or `web-app`
   threat models. They need a risk register shaped for MCP.
3. **The consumer-side governance gap is asymmetric.** Auto-harness today says a
   *lot* about how a project consumes the seven Linear-class MCP dev tools. It says
   *nothing* about a project that ships an MCP server consumed by a customer's
   Claude Desktop, or a project that consumes a third-party MCP server at product
   runtime (not just at the developer's workstation). Closing that asymmetry now
   keeps the harness's tier discipline portable across both sides of the wire.
4. **OPP-0001 is gated on this answer.** Without an MCP-server-shaped path, the
   exportable-governance contract is forced into either a (heavyweight) custom
   protocol or a (toothless) JSON-schema-by-convention. With this OPP, the contract
   has a transport that runtime harnesses already speak.

## Risks / Open Questions

- **Architecture vs domain shape.** Is an MCP server an *architecture* (its own
  topology) or a *domain* (an overlay on top of `api-service` or `stacks/node-typescript`)?
  This OPP proposes **architecture primary** because the MCP wire format, lifecycle
  handshake, primitive registry, and tier-mapped tool surface form a topology that
  doesn't reduce to "an HTTP API with a JSON-RPC envelope." A lighter optional
  *domain* overlay (`domains/mcp-integration`) governs projects that *consume* MCP
  servers at product runtime without producing one. ADR-0008 commits to the split.
- **Vendor and spec flux.** The MCP spec is moving (capability semantics, MCP Apps,
  Tasks). The harness must avoid pinning template content to a specific spec
  revision in a way that traps consumers. Mitigation: templates name the spec
  revision they were written against, declare which capabilities the project's
  server negotiates, and treat the rendered Apps surface (if any) as an optional
  appendix.
- **Tier-mapping argument burden.** Mapping each exposed tool to a tier the
  *consumer* should treat it as requires real reasoning — `read_doc` is Tier 0,
  `send_message` is Tier 3, `delete_record` is Tier 4 if irreversible. Templates
  must force the author to argue the mapping, not just check a box. Risk: the
  template becomes busywork for tiny servers with one tool. Mitigation: only the
  `mcp-server` architecture module's required artifacts force this; consumers
  declaring an MCP server informally don't need to adopt the architecture.
- **Exposed-governance scope creep.** The third mode (harness governance via MCP)
  is the largest of the three in surface area and the least proven in adoption.
  This OPP proposes **scoping the v1 to a *read-only contract surface*** — `tools`
  for "what tier is this action?", `resources` for the project's manifest and the
  module-graph, `prompts` that template a companion-rule check — and explicitly
  *not* shipping mutation tools (no "approve this action" tool, no "raise tier"
  tool) until at least one external runtime harness has wired the read-only surface
  in. ADR-0008 commits to this scope.
- **Adoption signal.** Like OPP-0001 and OPP-0002, the modules' value depends on
  whether projects adopt them. The minimum-viable validation is (a) one sample
  project under `platform/examples/sample-projects/mcp-server-starter/` that bootstraps
  green against the architecture module, and (b) one external consumer building
  an MCP server using the architecture module via submodule.
- **Relationship to OpenClaw / ClawHub.** OpenClaw ships its own skill ecosystem
  with its own registry and tier-tagging. An MCP server we govern could conceivably
  *also* be published as a ClawHub skill. The harness should not duplicate ClawHub's
  registry — `platform/skills/harness-mcp/SKILL.md` is a sibling skill to
  `harness-tools`, not a replacement for the ClawHub directory.
- **OPP-0001's "MCP-shaped tool gating?" question — partial answer.** Yes, MCP is
  a viable enforcement transport for an exportable governance contract, but only
  if the runtime harness honors `tools/call` results as gating decisions rather
  than advisory output. That is a runtime-harness adoption ask, not a harness-side
  capability ask. This OPP delivers the producer-side path; OPP-0001 stays open
  on the consumer-side commitment from any specific runtime harness.

## Disposition

Accepted. The producer-side MCP governance gap is now addressed with a first-class
`architectures/mcp-server` module, MCP template family, workflow guidance, and sample
project, and the exposed-governance path is explicitly scoped to a read-only/advisory
v1 posture. ADR-0008 records the architecture-vs-domain decision, the companion-rule
discipline for MCP producer contracts, and the deferred v2 mutation scope pending
runtime-harness adoption signal.

## Promotion

- Decision record: `docs/adr/ADR-0008-mcp-awareness.md`
- Implemented in this branch via the `feat(mcp): producer architecture + exposed-governance path (R&D)` PR changeset.
