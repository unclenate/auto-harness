<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Architecture Overlay: Agent Skill Pack

**Depends on:** `kernel/base`.
**Conflicts with:** None.

## What this module adds

This overlay governs products whose **unit of delivery is an authored agent
skill pack** — a collection of conventioned skills (a `SKILL.md` spec,
progressive-disclosure `references/`, and deterministic `scripts/`) authored
to a standard, gated by evals, and deployed to an **agent runtime the
consumer does not own** (OpenClaw / ClawHub, Claude Code, Cursor,
agentskills.io). The skills *are* the product; the runtime loads them.

It makes three things explicit that no other module covers:

1. **The skill-loading model** — which runtime loads the pack, from where,
   under what trust tier — named in `docs/architecture/overview.md`.
2. **Skill-scoping and permission discipline** — one skill, one job;
   least-permission workspace caches; reference-don't-embed for personal
   data — enforced as review gates.
3. **The eval-as-gate contract** — a new or changed skill must be paired with
   a matching eval (or, failing that, an authoring-conventions update or an
   ADR), via a companion rule (pairs with
   `management/eval-gated-testing`).

## When to activate

Activate `architectures/agent-skill-pack` when:

- Your repository's primary artifact is a set of agent skills authored to a
  spec and deployed to a runtime (not an app you serve, not a service you
  host, not an MCP server you expose).
- Skills are loaded by an agent runtime at runtime (OpenClaw workspace,
  Claude Code / Cursor skill directories, agentskills.io-compatible host).
- You gate skill quality with evaluations rather than (or in addition to)
  conventional tests.

**Do not** activate it for:

- A copilot or generative-UI surface embedded *in your own product* — that
  is `domains/agentic-interfaces` (optionally `architectures/agentic-ui`).
- A project that *produces an MCP server* — that is
  `architectures/mcp-server`.
- A project that merely *consumes* third-party skills or MCP servers as dev
  tooling — that is the `agents/*` packs plus `harness-tools`.

## What it requires

- **Required:** `docs/architecture/overview.md` — must name the runtime, the
  skill-loading model, and the workspace/permission boundary. (Reuses the
  `architecture-overview.md` template.)
- **Optional:** `docs/skills/authoring-conventions.md` — the pack's authoring
  standard (frontmatter spec, body-section order, reference-don't-embed,
  token discipline). Template provided at
  `platform/templates/skills/authoring-conventions.md`.
- **Optional:** `docs/skills/skill-pack-manifest.md` — an inventory of the
  shipped skills, their scopes, and their workspace caches.
- **Companion rule:** a new/changed skill source (`skills/**/SKILL.md`,
  `skills/**/scripts/`, `prompts/`) must be paired with a matching eval, an
  authoring-conventions update, or an ADR.

## Relationship to other modules

| Concern | Module |
|---------|--------|
| The skills are the product, loaded by a runtime you don't own | **this module** |
| OpenClaw-specific workspace files (`TOOLS.md`, `SOUL.md`, `HEARTBEAT.md`) | `agents/openclaw` |
| The eval gate that protects the pack | `management/eval-gated-testing` |
| An in-product copilot / generative-UI surface | `domains/agentic-interfaces` |
| A product that ships its own MCP server | `architectures/mcp-server` |

`agents/openclaw` and this module compose cleanly: the agent pack governs the
runtime *workspace files*; this module governs the *authored skills* that are
deployed into that workspace. The boundary is the deploy step — a skill in
`skills/` is a source artifact this module governs; once deployed to
`~/.openclaw/workspace/skills/` it is a workspace artifact the OpenClaw pack
governs.

## What it does not do

- It does not pick a runtime or vendor. The overview declares the runtime;
  vendor-specific workspace conventions live in the matching `agents/*` pack.
- It does not define the eval format — that is
  `management/eval-gated-testing`. This module only requires that an eval
  *exists* for each skill (the companion rule); the eval's shape is the
  testing module's concern.
- It does not govern an in-product agent UI's prompt-injection or renderer
  surface — that is `domains/agentic-interfaces`. A skill pack that *also*
  ships a UI activates both.

---

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- Spec: [`docs/requirements/PRD-0008-agent-skill-pack-architecture.md`](../../../../docs/requirements/PRD-0008-agent-skill-pack-architecture.md)
