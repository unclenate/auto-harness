<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Skills and Agents

## How the Harness Integrates with Agent Skills and External Ecosystems

The harness operates at three layers of agent knowledge. Understanding all three prevents
gaps where an agent knows governance rules but lacks domain-specific tool knowledge, or
knows a tool well but has no governance context.

---

## The Three-Layer Model

```text
Layer 1 — Kernel doctrine + compiled fragments
  Provided by: harness modules (compiledFragments field)
  Contents: trust tier model, lifecycle controls, companion rules, module READMEs
  Agent reads at session start via AGENTS.md or CLAUDE.md shims
  Always loaded — provides the governance floor

Layer 2 — Skills (Agent Skills format + external ecosystems)
  Provided by: developer installs skill directories in the project or agent tool
  Contents: domain-specific instructions, vendor APIs, tool patterns
  Agent discovers at startup, loads full body on activation
  Progressively disclosed — loaded on demand, not upfront

Layer 3 — Project contract
  Provided by: project's own AGENTS.md and CLAUDE.md
  Contents: project-specific constraints, overrides, agent scope boundaries
  Agent reads at session start
```

Layer 1 tells the agent *how to govern work*. Layer 2 tells the agent *how the tools work*.
Layer 3 tells the agent *what this specific project allows*.

---

## The Agent Skills Standard

Agent Skills is an **open format maintained by Anthropic** for giving agents new capabilities
and expertise. It is the canonical standard for skills in Claude Code, VS Code Copilot,
GitHub Copilot, Cursor, Gemini CLI, OpenAI Codex, and other compliant clients.

**Specification:** `https://agentskills.io/specification`

A skill is a directory containing a `SKILL.md` file:

```text
.agents/skills/
└── skill-name/
    ├── SKILL.md          # Required: YAML frontmatter + Markdown instructions
    ├── scripts/          # Optional: executable code
    ├── references/       # Optional: additional documentation
    └── assets/           # Optional: templates and static resources
```

**`SKILL.md` frontmatter** (see spec for full rules):

```yaml
---
name: skill-name               # required; kebab-case; must match directory name
description: "When to use..."  # required; 1-1024 chars; quoted if it contains colons
license: Apache-2.0            # optional
compatibility: "For..."        # optional; describe environment requirements
---
```

**Progressive disclosure:** At session start, agents load only `name` + `description` (~100
tokens per skill). When a task matches, the full body loads. Referenced scripts and docs load
on demand. This is more context-efficient than loading everything at startup.

**Installation paths** (agents scan these at startup):

| Scope | Path | Notes |
| ----- | ---- | ----- |
| Project (cross-client) | `<project>/.agents/skills/` | Standard cross-client location |
| Project (Claude Code) | `<project>/.claude/skills/` | Claude Code native location |
| User (cross-client) | `~/.agents/skills/` | Available across all projects |
| User (Claude Code) | `~/.claude/skills/` | Available in all Claude Code sessions |

Project-level skills override user-level skills of the same name.

**Validation:** Use `skills-ref` from the agentskills repo to validate SKILL.md files:

```bash
pip install skills-ref
skills-ref validate ./my-skill
```

---

## Harness-Native Skills

The harness provides five skills in Agent Skills format, defined at `platform/skills/`.
These encapsulate governance knowledge as first-class skills that any compliant agent can
discover and activate.

| Skill | Directory | Purpose |
| ----- | --------- | ------- |
| `harness-governance` | `platform/skills/harness-governance/` | Trust tiers, companion rules, lifecycle controls, validator chain |
| `harness-testing` | `platform/skills/harness-testing/` | Test strategy patterns, coverage enforcement, framework-specific guidance |
| `harness-web3` | `platform/skills/harness-web3/` | UNKNOWN propagation, rate limit budgets, evidence requirements, Tier 5 gates |
| `harness-onboarding` | `platform/skills/harness-onboarding/` | Brownfield assessment, gap analysis, lite manifest generation |
| `harness-tools` | `platform/skills/harness-tools/` | MCP developer tool governance: trust tier map, Linear artifact workflow, Slack notifications, analytics tools |

**Why skills instead of (only) compiled fragments?**

Compiled fragments are always loaded — they form the governance floor regardless of task.
Skills are loaded on demand — they provide deeper, domain-specific guidance when the task
needs it. Both serve different purposes and complement each other.

Compiled fragments = always-on governance enforcement
Skills = on-demand domain expertise

### Installing Harness-Native Skills

During project bootstrap (after Step 6 in the quickstart), copy harness skills to your
project's skill directory:

```bash
# Cross-client (works with Claude Code, VS Code Copilot, Cursor, etc.)
cp -r platform/skills/harness-governance .agents/skills/
cp -r platform/skills/harness-testing .agents/skills/     # testing-standard active
cp -r platform/skills/harness-web3 .agents/skills/        # Web3 projects only
cp -r platform/skills/harness-onboarding .agents/skills/  # brownfield onboarding

# Claude Code native path
cp -r platform/skills/harness-governance .claude/skills/
cp -r platform/skills/harness-testing .claude/skills/     # testing-standard active
cp -r platform/skills/harness-web3 .claude/skills/        # Web3 projects only
```

Skills installed in `.agents/skills/` are automatically discovered by all compliant clients.
Skills in `.claude/skills/` are Claude Code specific.

---

## `recommendedSkills` in module.yaml

Each module declares `recommendedSkills` — a list of skill names that provide relevant
domain knowledge. The field uses two namespaces:

**Agent Skills format entries** — skill directory names, installable per the paths above:

```yaml
recommendedSkills:
  - harness-governance   # Agent Skills format; source: platform/skills/
  - harness-testing      # Agent Skills format; source: platform/skills/
  - harness-web3         # Agent Skills format; source: platform/skills/
```

**OpenClaw / ClawHub entries** — commented slugs for the OpenClaw ecosystem:

```yaml
  # --- OpenClaw / ClawHub ecosystem (clawhub install <slug>) ---
  - supabase             # Supabase database ops (curated list)
```

The field is **not enforced by validators** — skill installation is a developer discipline
step, not a CI gate.

---

## OpenClaw / ClawHub Ecosystem

OpenClaw is a separate locally-running AI assistant with its own skill registry (ClawHub).
It is one possible development participant or technology in the stack. Its skills are installed
via `clawhub install <slug>` and live in `~/.openclaw/skills/` (not in `.agents/skills/`).

**Curated skill directory:** `https://github.com/VoltAgent/awesome-openclaw-skills`
(~5,200 curated skills from the full ClawHub registry of ~13,700)

**Installation:**

```bash
clawhub install <slug>
# or: copy skill folder to ~/.openclaw/skills/ (global) or <project>/skills/ (workspace)
```

### Module-to-Slug Mapping (OpenClaw)

| Active module | Slug | Purpose |
| ------------- | ---- | ------- |
| `stacks/node-typescript` | `next-best-practices` | Next.js conventions, RSC, async APIs |
| `stacks/node-typescript` | `next-cache-components` | Next.js 16 PPR, use cache directive |
| `stacks/node-typescript` (Vercel) | `lb-vercel-skill` | Vercel CLI, deployments, env vars |
| `stacks/node-typescript` (perf) | `react-perf` | React and Next.js performance |
| `domains/supabase` or Supabase data layer | `supabase` | Database ops, vector search, storage |
| `data/relational-postgres` | `postgres-perf` | PostgreSQL performance optimization |
| `domains/media-pipeline` | `ffmpeg-master` | Video and audio processing |
| `domains/media-pipeline` | `mediaproc` | Batch media processing in a locked container |
| `domains/web3` (security, first) | `azhua-skill-vetter` | Vet other skills before installation |
| `domains/web3` (analytics) | `mist-track` | AML compliance, address risk (full registry) |
| `domains/web3` (data) | `dune-mcp` | On-chain data queries (full registry) |
| `domains/web3` (data) | `nansen` | Wallet and token analytics (full registry) |

### Web3 Skills Security

Web3 skills are **not in the curated list** — they come from the full ClawHub registry.

Before installing any Web3 registry skill:

1. Install `azhua-skill-vetter` first (`clawhub install azhua-skill-vetter`) and run it
   against the target skill.
2. Test in an isolated environment before connecting to live wallets, contracts, or production
   API keys.
3. Skills touching transaction signing require Tier 5 review — see `harness-web3` skill.
4. Most Web3 registry entries are experimental — treat as untrusted until audited.

---

## Skills and the Bootstrap Sequence

```text
Step 6 — validate-agent-pack.sh
Step 6.5 — install skills
    a. Copy harness-governance to .agents/skills/ (all projects)
    b. Copy harness-testing to .agents/skills/ (testing-standard active)
    c. Copy harness-web3 to .agents/skills/ (Web3 projects)
    d. Copy harness-onboarding to .agents/skills/ (brownfield onboarding)
    e. Install OpenClaw skills per module table above (if using OpenClaw)
Step 7 — wire up CI
```

---

## Relationship Between Skills and compiledFragments

| | `compiledFragments` | Agent Skills |
| - | ------------------- | ------------ |
| Source | Harness platform docs | SKILL.md directories |
| Loaded | Always, at session start | On demand, when task matches |
| Enforced | Yes — validator checks file existence | No — developer installs |
| Token cost | Full content every session | ~100 tokens at startup; full body only when activated |
| Best for | Governance rules that must always be in context | Domain-specific guidance loaded when needed |
| Example | `platform/core/kernel/base/trust-model.md` | `platform/skills/harness-governance/SKILL.md` |

---

## Multi-Tool Context — How the Three-Layer Model Composes Across Tools

The three-layer model is tool-agnostic by design, but multiple tools driving the same
repository need a shared discipline on *where* each layer lives.

- **Layer 1 (kernel doctrine + compiled fragments)** is identical across every tool. The
  compiled fragments are files on disk; any tool that can read the repository reads them
  the same way. No per-tool variation.
- **Layer 2 (skills)** uses the Agent Skills format — an open standard supported in
  some form by Claude Code, Gemini CLI, Codex, Copilot CLI, Cursor, and others, though
  the *discovery path* varies per tool and is the place where cross-tool portability
  is currently uneven. The harness's working position:
  - `.agents/skills/` is the harness-native install path and works today for tools that
    auto-discover the Agent Skills format from that directory — currently Gemini CLI,
    Codex (via Agent Skills compatibility), Copilot CLI, and Cursor (Cursor 2.4+
    auto-loads from `.agents/skills/` and `.cursor/skills/`, per
    <https://cursor.com/docs/skills>).
  - Tool-native paths are still the durable fallback when a tool either does not yet
    discover from `.agents/skills/` (e.g. Claude Code, which loads from `.claude/skills/`)
    or when the project wants a tool-specific skill variant. Mirror to
    `.claude/skills/`, `.cursor/skills/`, or ClawHub locations as needed; the canonical
    copy stays under `.agents/skills/`.
  - For Cursor specifically, the durable governance surface for rules remains
    `.cursor/rules/` (a separate concept from skills) — see the per-tool table in
    `platform/workflow/multi-agent-tool-coordination.md` for the full picture.
- **Layer 3 (project contract)** is where tool divergence is real. `AGENTS.md` is the
  shared cross-agent contract — every major tool now reads it natively or can be configured
  to. Per-tool *shims* (`CLAUDE.md`, `GEMINI.md`, `CODEX.md`, `TOOLS.md`) exist only when
  a tool's session or approval model needs translation into the harness's trust-tier
  vocabulary. A shim that just restates `AGENTS.md` is overhead and a drift risk.

For the full per-tool table (file conventions, skill loading paths, approval/session
models, trust-tier mappings, and known stop conditions), see
`platform/workflow/multi-agent-tool-coordination.md`. That document is the operator
reference when a project will be worked by more than one AI tool.

The harness's existing `agents/base`, `agents/claude-code`, `agents/generic-llm`, and
`agents/openclaw` modules already implement this layered convention. New per-tool adapter
modules (Gemini CLI, Codex CLI, Copilot CLI, Cursor, etc.) follow the same module-yaml
shape — see the multi-agent coordination guide for the criteria that distinguish "needs
its own adapter module" from "covered by `agents/generic-llm`."

---

## Reference

| Resource | Path |
| -------- | ---- |
| Agent Skills specification | `https://agentskills.io/specification` |
| Harness-native skills | `platform/skills/` |
| Module field reference | `platform/core/registry/module-types.md` |
| Bootstrap quickstart | `platform/workflow/bootstrap-quickstart.md` |
| Multi-tool coordination | `platform/workflow/multi-agent-tool-coordination.md` |
| AGENTS.md specification | `https://agents.md/` |
| Curated OpenClaw skills | `https://github.com/VoltAgent/awesome-openclaw-skills` |
| Trust tier model | `platform/core/kernel/base/trust-model.md` |
