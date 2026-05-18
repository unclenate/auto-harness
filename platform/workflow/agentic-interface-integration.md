<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Agentic Interface Integration

Operator-facing guide for adding the `domains/agentic-interfaces` module (and, optionally,
the `architectures/agentic-ui` overlay) to a project. Covers both greenfield bootstrap and
brownfield adoption.

## The One-Paragraph Rule

> **Use `domains/agentic-interfaces` whenever your product ships an in-product agent surface.
> Use `architectures/agentic-ui` *in addition* only when the agent surface is the dominant
> topology decision** (conversational-primary products, MCP-host shells, Open-ended generative-UI
> products). For the common case — a copilot or generative UI bolted onto a SaaS web-app —
> compose `architectures/web-app + domains/agentic-interfaces` and skip the architecture overlay.

## Step 1 — Add the Module(s) to the Manifest

For the common case (copilot in a SaaS):

```yaml
modules:
  core: [kernel/base]
  delivery: [prototype]            # or production-saas
  management: [interview-driven]   # or product-lite + project-standard
  architectures: [web-app]
  domains: [agentic-interfaces]    # <-- add this
  agents: [base]
```

For a conversational-primary or MCP-host product:

```yaml
modules:
  core: [kernel/base]
  delivery: [prototype]
  management: [interview-driven]
  architectures: [agentic-ui]      # <-- topology overlay
  domains: [agentic-interfaces]    # <-- design / risk / tools / renderer
  agents: [base]
```

For an existing web-app that gains an agent surface (brownfield):

1. Add `domains: [agentic-interfaces]` to the existing manifest
2. Run the validator chain (Step 3 below). It will report two missing required artifacts (`design.md`, `risk-register.md`)
3. Use the templates to fill the artifacts (Step 4 below)
4. Re-run the validator chain. Green.

The starter composition at `platform/compositions/agentic-ui-saas.yaml` demonstrates the
common case end-to-end.

## Step 2 — Pick a Flavor

The three flavors (plus conversational-primary) are documented in
`platform/profiles/domains/agentic-interfaces/README.md` and in the
`harness-agentic-interfaces` skill. Decision heuristics:

| If your product ... | Lean toward |
|---------------------|-------------|
| Has an existing React/Next.js UI; agent is a feature | **Controlled** (CopilotKit) |
| Needs the same agent surface across web/mobile/desktop | **Declarative** (A2UI — pin v0.8 explicitly) |
| Is delivered as an app inside a host (Claude desktop, ChatGPT) | **Open-ended** (MCP Apps) |
| *Is* the chat (no surrounding application) | **Conversational-primary** |

Hybrid is expected — a CopilotKit sidebar plus an MCP-App entrypoint is common. The design
doc supports declaring multiple flavors.

## Step 3 — Run the Validator Chain

After editing the manifest:

```bash
PLATFORM=path/to/platform
bash $PLATFORM/validators/validate-manifest.sh harness.manifest.yaml
bash $PLATFORM/validators/validate-module-graph.sh harness.manifest.yaml
bash $PLATFORM/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash $PLATFORM/validators/validate-companions.sh harness.manifest.yaml .
bash $PLATFORM/validators/validate-placeholders.sh .
```

Expected failure: `validate-required-artifacts.sh` reports `docs/agentic-interface/design.md`
and `docs/agentic-interface/risk-register.md` missing. That is the prompt to create them.

## Step 4 — Fill the Required Artifacts

```bash
mkdir -p docs/agentic-interface
cp platform/templates/agentic-interface/design.md docs/agentic-interface/design.md
cp platform/templates/agentic-interface/risk-register.md docs/agentic-interface/risk-register.md
```

Fill every `[[PLACEHOLDER]]` field. The validator (`validate-placeholders.sh`) catches
unfilled placeholders.

**Order of filling:**

1. `design.md` § 1 (flavor) — bounds everything else
2. `design.md` § 2 (agent runtime), § 3 (action surface), § 4 (renderer contract)
3. `risk-register.md` — review pre-seeded rows; mark each Open/Monitoring/Mitigated; add product-specific rows
4. `design.md` § 5 (state model), § 6 (HITL), § 7 (prompt-injection defense), § 8 (upgrade posture)

## Step 5 — Add the Optional Artifacts as the Surface Grows

When the agent has more than 2-3 callable tools, or any tool has externally-visible side
effects, add the prompt-tool registry:

```bash
cp platform/templates/agentic-interface/prompt-tool-registry.md \
   docs/agentic-interface/prompt-tool-registry.md
```

When the flavor is Declarative or Open-ended (or when the Controlled catalog has
non-trivial agent-renderable components), add the renderer contract:

```bash
cp platform/templates/agentic-interface/renderer-contract.md \
   docs/agentic-interface/renderer-contract.md
```

## Step 6 — Install the Skill

```bash
# Cross-client
cp -r platform/skills/harness-agentic-interfaces .agents/skills/
# or Claude Code native
cp -r platform/skills/harness-agentic-interfaces .claude/skills/
```

Agents (Claude Code, Cursor, etc.) discover the skill on next session start. The skill
body loads when the agent is doing work in an agentic-UI codebase.

## Step 7 — Wire the Companion Rule into CI

The `validate-companions.sh` validator detects when a change to a sensitive path lacks the
required companion update. Wire it into CI alongside the other validators:

```yaml
# .github/workflows/harness.yml or equivalent
- name: harness-validate-companions
  run: bash platform/validators/validate-companions.sh harness.manifest.yaml .
```

The companion rule fires when changes touch `docs/agentic-interface/`, `src/agents/`,
`src/copilot/`, `src/agent-ui/`, `src/genui/`, `prompts/`, or any `agent.config.*` /
`copilotkit.config.*` / `a2ui.config.*` file. It is satisfied by an update to the design
doc, the risk register, the prompt-tool registry, or a new ADR.

## Integration Recipes by Flavor

### Recipe A — CopilotKit (Controlled) inside a Next.js web-app

Manifest:

```yaml
modules:
  architectures: [web-app]
  domains: [agentic-interfaces]
  stacks: [node-typescript]
```

Surface conventions (the harness sensitive paths point here):

```text
src/copilot/
  ├── actions/            # useCopilotAction definitions — each is a tool entry in the registry
  ├── readable/           # useCopilotReadable definitions — what the agent sees
  ├── components/         # CopilotChat, CopilotSidebar wrappers
  └── runtime.ts          # CopilotKit runtime configuration
copilotkit.config.ts      # framework-level config
```

In `design.md`:

- Flavor: Controlled
- Agent runtime: CopilotKit runtime, hosted server-side via Next.js route handler
- Renderer contract: see `renderer-contract.md` § A
- HITL: CopilotKit `handler` returning `confirm: true` for Tier 3+ actions

Vendor appendix: pin the CopilotKit version. Watch the AG-UI Protocol changelog.

### Recipe B — A2UI (Declarative) across web + mobile

Manifest:

```yaml
modules:
  architectures: [agentic-ui]    # topology overlay because the agent surface is dominant
  domains: [agentic-interfaces]
  stacks: [node-typescript]      # for the web client
```

Surface conventions:

```text
src/agent-runtime/        # the agent loop; emits A2UI messages
src/genui-renderer/       # A2UI client renderer (Lit on web, Flutter on mobile)
src/agent-components/     # native widget implementations the renderer maps schema to
a2ui.config.json          # schema version pin
```

In `design.md`:

- Flavor: Declarative
- Renderer contract: see `renderer-contract.md` § B
- Pin A2UI to v0.8 explicitly; document v0.9 migration in the upgrade posture section

### Recipe C — MCP Apps (Open-ended) inside a Claude / ChatGPT host

Manifest:

```yaml
modules:
  architectures: [api-service, agentic-ui]    # API for the host; topology because no traditional UI
  domains: [agentic-interfaces]
  stacks: [node-typescript]                   # or python
```

Surface conventions:

```text
src/mcp-server/           # MCP server implementation
src/renderer/             # HTML/Markdown payload generation
src/agent-actions/        # MCP tools the host exposes to the user
mcp.config.json
```

In `design.md`:

- Flavor: Open-ended
- Renderer contract: see `renderer-contract.md` § C — the host's sandbox is the boundary
- Document which host(s) you support and the sandbox configuration each provides

### Recipe D — Conversational-primary product

Manifest:

```yaml
modules:
  architectures: [agentic-ui]
  domains: [agentic-interfaces]
  stacks: [node-typescript]                   # or python
```

Surface conventions:

```text
src/agent-runtime/
src/chat-ui/              # the chat is the product
src/agent-actions/
src/citations/            # attribution UI surface
```

In `design.md`:

- Flavor: Conversational-primary
- Renderer contract: see `renderer-contract.md` § D — the chat UI itself is the contract
- HITL: confirmation cards rendered inline in the chat stream, persisted to the thread
- Model attribution: always-visible model + version in the message footer

## What Review Gates Open

When the module is active, four review gates apply (declared in the module's
`reviewGates`). Reviewers should explicitly check each on relevant PRs:

1. **Tool-addition gate** — new agent-callable action → tier classification + approval gating reviewed
2. **Renderer-contract gate** — generative-UI pathway change → catalog-bounding / sandbox isolation reviewed
3. **Model/runtime upgrade gate** — model or framework version change → UI-regression risk reviewed + golden set run
4. **HITL conformance gate** — design doc HITL checkpoint vs code parity verified

These are reviewer discipline, not validator enforcement. Add them to the PR checklist
for the project.

## Brownfield Note

If a project already ships an agentic interface and is adopting this module after the
fact, the first PR is:

1. Add `domains/agentic-interfaces` to the manifest
2. Fill `design.md` against what the code already does (not what you wish it did) — this is a fact-finding doc, not a wish list
3. Fill `risk-register.md` honestly — mark risks Open if no mitigation exists, do not pre-claim Mitigated
4. Fill `prompt-tool-registry.md` against the actual tools currently invokable by the agent
5. *Then* ship a follow-up PR (or PRs) to close the gaps the fact-finding surfaced

The temptation to fix everything in one PR is real. Resist it — the module's value is
*recognizing* the current shape so reviewers and downstream agents have a true map. Fixes
follow with a proper paper trail.

## See Also

- `platform/profiles/domains/agentic-interfaces/README.md`
- `platform/profiles/architectures/agentic-ui/README.md`
- `platform/templates/agentic-interface/README.md`
- `platform/skills/harness-agentic-interfaces/SKILL.md`
- `platform/compositions/agentic-ui-saas.yaml`
- `platform/examples/sample-projects/agentic-ui-starter/`
- `docs/adr/ADR-0007-agentic-interface-awareness.md`
- `docs/opportunities/OPP-0002-agentic-interface-awareness.md`
