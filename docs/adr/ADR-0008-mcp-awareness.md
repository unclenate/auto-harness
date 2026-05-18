<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0008: MCP Awareness — Producer Architecture, Consumer Overlay, and Path to Exposing Harness Governance via MCP

**Status:** Accepted
**Date:** 2026-05-17
**Author:** @unclenate
**Reviewers:** @unclenate
**Context source:** OPP-0003 (`docs/opportunities/OPP-0003-mcp-producer-and-exportable-governance-via-mcp.md`) — three MCP modes the harness currently does not name; producer-side governance gap; OPP-0001's open question on whether the exportable governance contract should be enforceable via MCP tool gating.

## Context

The harness today recognizes one MCP mode — *consumer of dev tools* — via `TOOLS.md`
and the `harness-tools` skill. That subset (Linear, Slack, Calendar, Gmail, Canva,
Ahrefs, Similarweb) is tier-mapped per action class and treated as sensitive in the
OpenClaw agent module's companion rules.

Two other MCP modes have no harness coverage:

1. **MCP producer.** A project that ships an MCP server. The protocol exposes
   three primitives (tools, resources, prompts) and supports two transports
   (stdio, Streamable HTTP) with a full OAuth 2.1 + RFC 8707 authorization
   model. The threat surface (prompt injection through tool results, tool
   poisoning, capability drift after `initialize`, sampling-based exfiltration,
   confused-deputy at the OAuth proxy layer, SSRF on metadata fetching, session
   hijacking) is distinct enough that an `api-service` architecture overlay does
   not adequately cover it. *Source: MCP spec 2025-06-18, Security Best Practices
   and Authorization sections.*
2. **Harness governance exposed via MCP.** OPP-0001 proposes an exportable
   governance contract for runtime harnesses (Hive, LangGraph, CrewAI). OPP-0001
   left as an open question whether the contract should be enforceable via MCP
   tool gating or stay declarative. OPP-0003 partially answers it: MCP is the
   most realistic enforcement transport because runtime harnesses already speak
   it, and a `harness-governance` MCP server can expose tier lookups, manifest
   reads, and companion-rule template prompts as a read-only contract surface.

The harness needs to (a) name all three modes, (b) ship the producer-side
governance scaffolding now, (c) cross-reference the consumer-side coverage that
already exists, and (d) frame the exposed-governance path without committing to
its full scope before adoption signal exists.

## Decision

**Add an `architectures/mcp-server` module as the producer-side primary structural
addition, ship an `mcp` template family that forces tier-mapping and risk-register
discipline, ship a `harness-mcp` skill that complements (does not replace)
`harness-tools` and `harness-governance`, and explicitly bracket the exposed-governance
path with a v1 read-only scope.**

Concrete commitments:

1. **New `architectures/mcp-server` module.** Lives at
   `platform/profiles/architectures/mcp-server/` with `module.yaml` and `README.md`.
   - **Depends on** `kernel/base`. Does **not** depend on `api-service` — the MCP
     wire format, lifecycle handshake, primitive registry, and tier-mapped tool
     surface form a topology that doesn't reduce to "an HTTP API with a JSON-RPC
     envelope." A project can compose both modules if it serves both an HTTP API
     and an MCP server, but neither requires the other.
   - **Required artifacts:** `docs/mcp/server-spec.md`, `docs/mcp/tool-registry.md`,
     `docs/mcp/risk-register.md`. These three are the minimum viable governance
     surface for an MCP server: what the server is, what it exposes, what could go
     wrong.
   - **Optional artifacts:** `docs/mcp/capability-schema.md`,
     `docs/mcp/prompt-injection-test-plan.md`, `docs/mcp/transport-and-auth.md`.
     Optional because not every server exposes all three primitives or supports
     remote transport; the templates make it cheap to add them.
   - **Sensitive paths:** `^docs/mcp/`, `^src/mcp/`, `^mcp\.json$`,
     `capability-schema`, `tool-registry`. Changes to any of these trigger the
     companion rule.
   - **Companion rule:** changes to the tool registry, capability schema, or
     server source under `src/mcp/` require updating the risk register, an ADR,
     or the architecture overview in the same commit. Rationale: the tool registry
     is the producer-side contract with every consumer; changing it without a
     paired risk-review or decision record is the equivalent of a silent breaking
     change to an HTTP API contract.
   - **Validators:** `validate-required-artifacts`, `validate-companions`.

2. **Decision: ship the architecture module, not a separate `domains/mcp-integration` overlay, in v1.**
   The consumer-side discipline for projects that *use* third-party MCP servers at
   product runtime is real, but it has only one well-evidenced shape today (the
   dev-tool subset covered by `TOOLS.md`). Adding a `domains/mcp-integration`
   module now would either duplicate `TOOLS.md` semantics or stake out a
   producer-side-adjacent contract that has no consumer evidence yet. The
   architecture module covers the producer side; a future ADR can add the domain
   overlay once a consumer pattern emerges that `TOOLS.md` cannot describe.

3. **New `platform/templates/mcp/` template family.** Six templates plus an index
   README:
   - `server-spec.md` — server identity, declared capabilities, primitive set,
     transport, auth model, runtime requirements, deployment surface.
   - `tool-registry.md` — per-tool: name, intent, inputs/outputs, side effects,
     **consumer tier mapping** (mirror of the `TOOLS.md` discipline applied
     in reverse — *we are the producer, this is the tier the consumer should
     treat us as*), approval gating expectation, idempotency, audit-log
     expectations.
   - `risk-register.md` — MCP-specific risks: tool poisoning, prompt injection
     via tool result, capability scope creep, sampling-based exfiltration,
     transport TLS/auth misconfiguration, dependency-driven tool surface
     drift, confused-deputy at OAuth proxy, SSRF on metadata fetching,
     session-ID guessing, local-server compromise.
   - `capability-schema.md` — declared capabilities matrix (server features,
     client features) and negotiation expectations.
   - `prompt-injection-test-plan.md` — minimum coverage: untrusted-string in
     tool result, nested tool call from result, untrusted resource read,
     sampling-loop attack.
   - `transport-and-auth.md` — stdio vs Streamable HTTP, OAuth 2.1 + PKCE +
     RFC 8707 resource-indicator posture, secret management, scope minimization.
   - `README.md` — index of the family, when each template applies, link to
     the architecture module.

4. **New `harness-mcp` Agent Skill** at `platform/skills/harness-mcp/SKILL.md`.
   Activation skill loaded when a project ships or designs an MCP server.
   Covers: producer vs consumer vs exposed-governance mode framing, tier
   discipline applied to *exposed* tools, prompt-injection defense surface,
   the spec touchpoints to consult, and the explicit boundary against
   `harness-tools` (which governs consumed tools) and `harness-governance`
   (which governs trust tiers and lifecycle).

5. **New workflow guide** at `platform/workflow/mcp-server-build.md`. Operator-facing:
   composing the architecture, filling the spec / tool-registry / risk-register,
   wiring validators, running the prompt-injection test plan, deployment posture,
   and the relationship to `TOOLS.md` when a downstream consumer (OpenClaw,
   another harness-governed project) integrates the server.

6. **New starter composition** at `platform/compositions/mcp-server-typescript.yaml`
   wiring `kernel/base + delivery/prototype + architectures/mcp-server +
   stacks/node-typescript + management/interview-driven + agents/base` for
   one-command bootstrap of an MCP-server prototype via
   `install.sh --composition mcp-server-typescript`.

7. **New sample project** at `platform/examples/sample-projects/mcp-server-starter/`
   modeling a hypothetical "team-knowledge-base MCP server" with three exemplar
   tools (one Tier 0 read, one Tier 2 write, one Tier 3 cross-team broadcast).
   Includes filled `docs/mcp/*.md` artifacts, `HARNESS.md`, `AGENTS.md`,
   `CLAUDE.md`, and `harness.manifest.yaml`. Validates green against the full
   validator chain.

8. **Cross-references, light touch.**
   - `TOOLS.md` gains a new bottom-of-file subsection "MCP — Producer Posture"
     pointing at the new module and skill. The existing dev-tool table is
     unchanged.
   - `platform/skills/harness-tools/SKILL.md` gains a new bottom-of-file
     subsection "Producer vs Consumer Roles" distinguishing the two and pointing
     at `harness-mcp`. The existing body is unchanged.
   - `README.md` gains a single bullet for the new architecture. `SUMMARY.md`
     and `HARNESS.md` are left to a separate doc-review pass.

9. **Exposed governance via MCP — explicit v1 scope.** The "harness governance
   exposed via MCP server" mode is **named in this ADR and in OPP-0003 but is
   not shipped in v1**. The path is bracketed as follows:
   - **v1 (this ADR):** the architecture module and templates make it trivial
     to build an MCP server. A future "harness-governance MCP server" would use
     the same module to govern itself.
   - **v2 (future ADR):** a reference implementation under
     `platform/examples/mcp-servers/harness-governance/` (or similar) exposing
     read-only tools (`get_tier_for_action`, `get_active_module_set`,
     `get_companion_rules_for_path`), read-only resources (project manifest,
     module graph), and prompts that template a companion-rule check. **No
     mutation tools in v1 of that future server** — no `approve_action`,
     no `raise_tier`. Mutations are intentionally deferred until at least one
     external runtime harness has wired the read-only surface and a real use
     case emerges for write tools.
   - This scoping partially answers OPP-0001's open question 2 ("enforceable
     via MCP tool gating?") with: *yes, MCP is the right transport; the v1
     contract is advisory (the runtime harness queries the harness server and
     chooses to gate); enforcement requires runtime-harness adoption, which is
     not this ADR's scope.*

## Consequences

### Positive

- Projects shipping MCP servers have a coherent governance surface — a spec
  doc, a tool registry with explicit consumer tier mapping, a risk register
  written for the MCP threat model, and an optional set of capability,
  prompt-injection, and transport templates — without inventing it themselves.
- The harness's consumer-side discipline (`TOOLS.md` + `harness-tools`) and
  producer-side discipline (`architectures/mcp-server` + `harness-mcp`) use the
  same tier vocabulary applied to opposite sides of the wire. A team that
  consumes an MCP server in one project and ships one in another doesn't have to
  context-switch between governance vocabularies.
- The tool-registry template forces explicit tier reasoning per tool — the same
  discipline that makes `TOOLS.md` useful is now available for any server the
  project builds.
- The risk-register template encodes the MCP spec's normative attack-class
  list (confused deputy, token passthrough, SSRF on metadata, session
  hijacking, local-server compromise, scope inflation) as named entries the
  team must address explicitly, not derive on their own.
- The exposed-governance path is named without being over-committed. Future
  work has a frame (`harness-governance` MCP server, read-only v1, mutations
  deferred to v2) that consumers and contributors can argue with on its
  merits.
- Cross-references into `TOOLS.md` and `harness-tools` are additive — existing
  consumers see the new framing in context, but nothing they relied on changes.

### Negative

- The `mcp-server` architecture is the eighth architecture module and the first
  with required artifacts under a new top-level `docs/mcp/` directory. Consumers
  who adopt it must accept a new doc directory that is sibling to (not under)
  `docs/architecture/`. The alternative — `docs/architecture/mcp/` — was rejected
  because the MCP spec's primitive structure does not collapse cleanly into the
  architecture-overview shape, and forcing it in would degrade the architecture
  overview's clarity for non-MCP servers.
- The tool-registry template is opinionated about tier mapping. Teams that don't
  want to do that reasoning will be tempted to fill every tool with Tier 2 to
  pass the placeholder validator. Mitigation: review-gate language in `module.yaml`
  requires reviewers to verify tier assignments are argued, not boxed; the skill
  reinforces this in agent-facing instructions.
- Spec-revision drift risk. The 2025-06-18 spec revision drove the template
  content. A future revision changing capability or authorization semantics
  requires template updates. Mitigation: the `server-spec.md` template names the
  spec revision the project's server targets, so drift is visible at audit time.
- The decision to omit a `domains/mcp-integration` overlay in v1 means projects
  consuming third-party MCP servers *at product runtime* (not just at the
  developer's workstation) have no shaping artifact yet. `TOOLS.md` covers the
  dev-tool subset adequately but does not address runtime consumption. If a
  consumer pattern emerges, a follow-up ADR can add the domain overlay.

### Watch

- If multiple consumers adopt `architectures/mcp-server` and develop conventions
  for tools they expose that don't map cleanly onto the six current tier
  buckets, the tier-mapping section of `tool-registry.md` may need extension.
  Add columns or sub-tiers rather than re-baselining the trust model.
- If the MCP spec changes the lifecycle handshake or capability semantics in a
  backward-incompatible way, the `capability-schema.md` template will need
  updating. Pin spec revisions in committed templates so the divergence point
  is obvious.
- If a runtime harness (Hive, LangGraph, CrewAI) signals interest in consuming
  a harness-governance MCP server, accelerate the v2 work tracked in OPP-0001
  and OPP-0003. Adoption signal is the gating input for that work.
- If teams start hand-rolling tool registries in places other than
  `docs/mcp/tool-registry.md` (e.g. inside source code as decorators), the
  validator's file-existence check will pass but the governance value will
  erode. A follow-up validator that cross-references in-code tool definitions
  with the registry document might be warranted.

## Trust-Model Implications

**None.** This change is purely additive:

- No new tiers. The existing Tier 0–5 model applies, with the producer-side
  twist that tier mapping is now reasoned about for tools the project *exposes*,
  not just for tools it *consumes*.
- No relaxation of any existing validator. The new module adds three required
  artifacts but does not change how the validator chain runs.
- No changes to the kernel's required-artifact contract. `HARNESS.md`,
  `AGENTS.md`, and `docs/operating-principles.md` remain mandatory under
  `kernel/base`.
- No changes to the OpenClaw agent module's existing sensitive paths or
  companion rules. The new architecture module adds its own paths.
- The `harness-mcp` skill is sibling to `harness-tools` and `harness-governance`
  and does not replace either. The progressive-disclosure model is unchanged.

Existing module yamls, validators, consumer manifests, and the harness's own
self-validation continue to work unchanged.

## Alternatives Considered

### Domain overlay only (`domains/mcp-protocol`), no architecture module

- Description: Treat MCP awareness as a cross-cutting domain that overlays
  whatever architecture the project already uses (web-app, api-service,
  event-driven). The domain declares MCP-related artifacts as required.
- Why rejected: An MCP server's wire format, lifecycle handshake, primitive
  registry, and tier-mapped exposed-tool surface constitute their own topology.
  Hiding them behind a domain overlay underweights how much of the project's
  governance the MCP layer actually drives. The producer's tool registry is the
  *primary* contract with every consumer, on par with an HTTP API's route table
  — and `api-service` is an architecture, not a domain. By symmetry, MCP-server
  warrants an architecture.

### Extend `architectures/api-service` to cover MCP servers

- Description: Treat an MCP server as a flavor of API service. Reuse the
  `docs/architecture/overview.md` requirement and add MCP-specific optional
  artifacts.
- Why rejected: The MCP threat model (prompt injection through tool results,
  capability negotiation drift, sampling exfiltration, confused-deputy at the
  OAuth proxy) doesn't fit the API-contract review gate. The tier-mapped
  tool registry has no analog in REST/GraphQL service-boundary thinking. The
  architecture-overview template would have to bifurcate into "API service
  flavor" and "MCP server flavor," which is worse than two crisp modules.

### Ship the exposed-governance MCP server now, in this ADR

- Description: Implement the `harness-governance` MCP server in v1, exposing
  tier lookups, manifest reads, companion-rule templates, and a small set of
  advisory tools immediately.
- Why rejected: Premature. No external runtime harness has signaled adoption
  intent. Shipping a reference server before adoption either ships the wrong
  surface (because we guessed at the consumer's needs) or ships nothing useful
  (because the consumer never showed up). The architecture module is the
  enabler; the exposed-governance server is a downstream artifact of that
  enabler. Sequencing matters.

### Make `docs/mcp/` a subdirectory of `docs/architecture/`

- Description: Place MCP artifacts under `docs/architecture/mcp/` so the
  architecture overview remains the single root for system-shape documentation.
- Why rejected: The MCP primitive set, transport handshake, and authorization
  model are not subordinate to a system architecture — they ARE a system
  architecture for an MCP-producing project. Burying them under
  `docs/architecture/` would force consumers' architecture overview to either
  duplicate the spec content or stub it. Top-level `docs/mcp/` mirrors top-level
  `docs/web3/` for the same reason: when a protocol or domain has its own
  primitive set, give it its own root.

### Require an MCP host or runtime as a module dependency

- Description: Add `dependsOn: [mcp-host]` semantics so an MCP-server-producing
  project must declare which host it targets (Claude Desktop, ChatGPT, VS Code,
  Cursor, etc.).
- Why rejected: MCP is designed to be host-agnostic. The whole point of the
  primitive set + capability negotiation is that the server doesn't know which
  client it talks to. Forcing a host-pin would be governance opposing
  interoperability. The `server-spec.md` template *does* ask the author to
  name target hosts as an interoperability note, which captures the same
  signal without making it a hard dependency.
