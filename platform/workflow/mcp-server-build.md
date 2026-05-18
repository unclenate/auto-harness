<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Building an MCP Server Under the Harness

Operator workflow for projects that ship a Model Context Protocol (MCP)
server. Pairs with `architectures/mcp-server`, the `platform/templates/mcp/`
template family, and the `harness-mcp` skill.

This is **not** a "how to write an MCP server" tutorial — the MCP SDK
documentation covers that. It is a "how to govern an MCP-producing project
under the harness" guide: which artifacts to fill, which validators to
wire, which review gates to honor, and how to compose with consumer-side
discipline when the same project also uses third-party MCP servers.

## When to Adopt the Architecture Module

Adopt `architectures/mcp-server` when your project's product (or a
meaningful part of it) is an MCP server. Signals that the time is right:

- You are about to publish an npm/pip/Docker package whose primary
  interface is MCP.
- You are about to add a Streamable HTTP endpoint that speaks MCP.
- An internal agent runtime in your org is going to consume your server.
- You are starting work toward exposing harness governance contracts via
  MCP (see OPP-0001 / OPP-0003 — future work, but the architecture module
  is the right place to start).

Don't adopt it when you are only *using* third-party MCP servers. Fill out
`TOOLS.md` (existing pattern) and install the `harness-tools` skill instead.

## Bootstrap Sequence

```text
1. Add to harness.manifest.yaml: modules.architectures: [mcp-server]
2. Add a stack module (node-typescript / python)
3. Add a delivery posture (prototype / production-saas)
4. Add a management overlay (interview-driven / product-lite + project-standard)
5. Copy templates: cp platform/templates/mcp/*.md docs/mcp/
6. Fill the three required artifacts: server-spec, tool-registry, risk-register
7. Install the harness-mcp skill (and harness-tools if also consuming MCP servers)
8. Run the validator chain
```

A starter composition wires steps 1–4 in one command:

```bash
bash platform/bootstrap/install.sh --composition mcp-server-typescript
```

## Filling the Required Artifacts

The three required artifacts under `architectures/mcp-server` are the
minimum viable governance surface.

### `docs/mcp/server-spec.md`

Fill in this order:

1. **Server identity** — name, version, language, SDK, canonical URI (for
   HTTP transport).
2. **Target hosts** — which clients you're designing for. Informational;
   does not pin the implementation, but shapes interop expectations.
3. **Declared capabilities** — what the server says in `initialize`. Be
   honest: only declare what you actually implement, and only declare
   `listChanged` flags you actually emit.
4. **Primitives inventory** — counts and pointers. The detailed list of
   tools goes in `tool-registry.md`.
5. **Transport** — stdio, Streamable HTTP, or both. The launch command (for
   stdio) or canonical URI (for HTTP) is auditable.
6. **Runtime requirements, deployment surface, spec revision, out-of-scope** —
   straightforward, but the explicit out-of-scope section is the governance
   discipline that distinguishes a spec from a roadmap.

### `docs/mcp/tool-registry.md`

For each tool the server exposes:

- **Wire name** — exactly what `tools/list` returns.
- **Intent** — one line, plain language.
- **Side effects** — what changes in the world when this tool is called.
- **Consumer tier** — Tier 0–5 with a one-line rationale. **The review
  gate rejects placeholder fills.** A `delete_*` tool at Tier 0 fails
  review; a `read_*` tool at Tier 5 fails review.
- **Approval gating expectation** — what you (the producer) recommend the
  consumer do before invoking. "None" is acceptable for Tier 0; Tier 3+
  typically recommends explicit consumer-side approval per call.
- **Idempotency** — yes/no. Non-idempotent tools warrant clearer warning
  in the description.
- **Audit-log expectation** — does the server log the call? Does the
  consumer? Or both?
- **Threat-class notes** — tool poisoning and prompt-injection-via-result
  posture. If your tool returns externally-influenced content, this is
  where you state the mitigation.

The summary table at the end is a compact view for review. Keep it in
sync.

### `docs/mcp/risk-register.md`

Twelve canonical MCP-class risks are seeded in the template (R-MCP-001
through R-MCP-012). You don't get to delete them — you get to fill in:

- **Likelihood and Impact** for your project specifically.
- **Mitigation** — what your project does. "Not applicable, server is
  stdio with no upstream API" is a fine mitigation if it is true.
- **Owner** — name a human.
- **Status** — Open, Monitoring, or Mitigated.

Add project-specific risks beyond the canonical twelve as you find them.

## Wiring the Validators

The architecture module declares two validators in `module.yaml`:

```yaml
validators:
  - validate-required-artifacts
  - validate-companions
```

Both run as part of the standard harness validator chain. Run before every
commit that touches `docs/mcp/`, `src/mcp/`, `harness.manifest.yaml`, or
any companion trigger path:

```bash
PLATFORM=path/to/platform
bash $PLATFORM/validators/validate-manifest.sh harness.manifest.yaml
bash $PLATFORM/validators/validate-module-graph.sh harness.manifest.yaml
bash $PLATFORM/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash $PLATFORM/validators/validate-companions.sh harness.manifest.yaml .
bash $PLATFORM/validators/validate-placeholders.sh .
```

All must exit 0 before the commit is complete. The placeholder validator
catches any `[[PLACEHOLDER_NAME]]` tokens left unfilled in the MCP
artifacts.

## Running the Prompt-Injection Test Plan

If `docs/mcp/prompt-injection-test-plan.md` is present, the project is
committing to the test coverage it declares. Run the suite:

- On every PR that touches `src/mcp/` or `docs/mcp/tool-registry.md`.
- On every MCP SDK version bump.
- Quarterly, with fixture refresh.

The MCP Inspector (`https://github.com/modelcontextprotocol/inspector`) is
a good interactive driver for AC-1 through AC-4 scenarios. For CI, a
programmatic MCP client SDK is better.

## Composing with Consumer-Side Discipline

Most projects that ship an MCP server *also* consume third-party MCP
servers — Linear for issue tracking, Slack for notifications, etc. The two
disciplines are siblings:

| Side | Artifact | Skill |
| ---- | -------- | ----- |
| Consumer (incoming MCP tools) | `TOOLS.md` | `harness-tools` |
| Producer (outgoing MCP tools) | `docs/mcp/tool-registry.md` | `harness-mcp` |

Both can be active in the same project. The tier vocabulary is identical;
the direction of the contract is opposite.

When your server's tools eventually appear in another harness-governed
project's `TOOLS.md` — i.e. someone consumes your server — your
`tool-registry.md`'s tier mapping is the source they should copy. The
producer's published tier is the consumer's starting commitment.

## Deployment Posture

### stdio server (local subprocess)

- Distribution channel goes in `server-spec.md`. npm and PyPI are typical.
- The launch command is auditable. Avoid `curl | sh`. Avoid obfuscation.
- Credentials are environment variables; the host sets them.
- The MCP spec requires one-click-install hosts to display the launch
  command pre-execution and require explicit consent — design your
  command to be readable in that consent dialog.

### Streamable HTTP server (hosted SaaS or internal service)

- The canonical URI goes in `server-spec.md` and is what consumers put in
  the OAuth `resource` parameter (RFC 8707).
- The server returns a `WWW-Authenticate` header on 401 per RFC 9728 §5.1,
  pointing to its Protected Resource Metadata document at
  `/.well-known/oauth-protected-resource`.
- Audience-validate every inbound token. Reject any token whose `aud`
  claim is not the canonical URI.
- For upstream API calls, the server uses its OWN tokens. Never forward
  the inbound client's Bearer token.
- Scope catalog is minimal; elevate progressively via `WWW-Authenticate`
  challenges.

## Migration: Existing MCP Server Without the Module

If you have an MCP server already and want to adopt the module, follow
this order:

1. Inventory exposed tools and write `docs/mcp/tool-registry.md` from
   live `tools/list` output. Argue each tier.
2. Write `docs/mcp/server-spec.md` from the actual code (declared
   capabilities, transport, runtime requirements).
3. Walk the risk register entries against current code. Mark each as
   Mitigated, Monitoring, or Open with a real mitigation plan.
4. Add `architectures/mcp-server` to `harness.manifest.yaml`.
5. Run the validator chain. Fix anything red.
6. From that point on, the companion rules enforce that future tool /
   capability / transport changes touch the right artifacts.

Do **not** declare `disabledValidations: [required-artifacts]` to skip
filling the docs. The shape of the harness is to recognize what you
actually have, not to be talked out of validating.

## Relationship to OpenClaw / ClawHub

OpenClaw is one possible AI participant in the stack — it has its own
skill registry (ClawHub) which is *separate* from MCP. An MCP server you
ship can co-exist with OpenClaw skills; the two ecosystems do not
collide. The harness's `harness-mcp` skill is sibling to `harness-tools`,
not a replacement for the ClawHub directory. If you also ship a ClawHub
skill, the OpenClaw module's existing `TOOLS.md` discipline still applies
to the tools that skill consumes; the `architectures/mcp-server` module
governs the tools your MCP server exposes.

## Exposed Governance Path (Forward-Looking)

ADR-0008 and OPP-0003 name a third mode: a `harness-governance` MCP server
that exposes auto-harness's own governance contracts to external runtime
harnesses (Hive, LangGraph, CrewAI). The v1 scope is read-only —
`get_tier_for_action`, `get_active_module_set`, `get_companion_rules_for_path`
as tools; project manifest and module graph as resources; companion-rule
templates as prompts.

That server is **not shipped in v1**. When it ships, it will itself be
governed by `architectures/mcp-server` and use this workflow.

## Reference

| Resource | Path |
| -------- | ---- |
| Module | `platform/profiles/architectures/mcp-server/module.yaml` |
| Module README | `platform/profiles/architectures/mcp-server/README.md` |
| Templates | `platform/templates/mcp/` |
| Skill | `platform/skills/harness-mcp/SKILL.md` |
| Sample project | `platform/examples/sample-projects/mcp-server-starter/` |
| Starter composition | `platform/compositions/mcp-server-typescript.yaml` |
| Consumer-side counterpart workflow | `TOOLS.md` + `platform/skills/harness-tools/SKILL.md` |
| ADR-0008 | `docs/adr/ADR-0008-mcp-awareness.md` |
| OPP-0003 | `docs/opportunities/OPP-0003-mcp-producer-and-exportable-governance-via-mcp.md` |
| Bootstrap quickstart | `platform/workflow/bootstrap-quickstart.md` |
| MCP architecture (spec) | <https://modelcontextprotocol.io/docs/learn/architecture> |
| MCP server concepts (spec) | <https://modelcontextprotocol.io/docs/learn/server-concepts> |
| MCP Authorization (spec) | <https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization> |
| MCP Security Best Practices (spec) | <https://modelcontextprotocol.io/specification/2025-06-18/basic/security_best_practices> |
| MCP Inspector | <https://github.com/modelcontextprotocol/inspector> |
