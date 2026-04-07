# Skills and Agents
## How the Harness Integrates with External AI Tool Skills

The harness operates at three layers of agent knowledge. Understanding all three prevents
gaps where an agent knows governance rules but lacks domain-specific tool knowledge, or
knows a tool well but has no governance context.

---

## The Three-Layer Model

```
Layer 1 — Kernel doctrine + compiled fragments
  Provided by: harness modules (compiledFragments field)
  Contents: trust tier model, lifecycle controls, companion rules, module READMEs
  Agent reads these at session start via AGENTS.md or CLAUDE.md shims

Layer 2 — External skills
  Provided by: developer installs skills in their AI tool (Claude Code, Cursor, etc.)
  Contents: vendor-specific APIs, deployment patterns, library best practices
  Examples: vercel-plugin:nextjs, supabase-postgres-best-practices, openlaw:dune-mcp

Layer 3 — Project contract
  Provided by: project's own AGENTS.md and CLAUDE.md
  Contents: project-specific constraints, overrides, agent scope boundaries
  Agent reads this at session start
```

Layer 1 tells the agent *how to govern work*. Layer 2 tells the agent *how the tools work*.
Layer 3 tells the agent *what this specific project allows*. A project that installs Layer 2
skills without Layer 1 gets a well-informed agent with no governance. A project that enforces
Layer 1 without Layer 2 gets a well-governed agent that guesses at framework APIs.

---

## `recommendedSkills` in module.yaml

Each module can declare `recommendedSkills` — a list of external skill IDs that provide
domain-specific knowledge relevant to that module. This field is:

- **Optional.** Modules with no relevant external skills omit it.
- **Not enforced by validators.** Skills are installed by the developer, not checked by CI.
- **Informational.** The harness documents what to install; it does not install it.

Example from `domains/supabase/module.yaml`:

```yaml
recommendedSkills:
  - supabase-postgres-best-practices
```

The skill ID is the identifier used when installing the skill in your AI tool. For Claude Code,
this maps to a skill installed via the Claude Code skill registry. For other runtimes, use the
equivalent skill ID in that runtime's registry.

---

## Skill Installation by Module

The table below maps active modules to skills worth installing. Skills marked **required** are
effectively mandatory for correct agent behavior in that domain — omitting them means the agent
will rely on stale training data for critical APIs.

| Active module | Skill to install | Priority | Purpose |
| ------------- | ---------------- | -------- | ------- |
| `stacks/node-typescript` + Vercel delivery | `vercel-plugin:nextjs` | Recommended | Next.js routing, rendering, deployment |
| Any project deploying to Vercel | `vercel-plugin:vercel-cli` | Recommended | CLI, env vars, preview deployments |
| `domains/supabase` | `supabase-postgres-best-practices` | Recommended | RLS policies, auth patterns, migrations |
| `stacks/python` + Supabase | `supabase-postgres-best-practices` | Recommended | Same as above, Python client usage |
| `domains/web3` | `openlaw:skill-vetter` | **Required first** | Audits other skills before installation |
| `domains/web3` | `openlaw:goplus-agent-guard` | **Required** | Pre-execution threat blocking |
| `domains/web3` | `openlaw:mist-track` | **Required** (analytics) | AML compliance, address risk classification |
| `domains/web3` | `openlaw:dune-mcp` | Recommended | On-chain data queries via Dune MCP server |
| `domains/web3` | `openlaw:nansen` | Recommended | Wallet and token analytics |
| `domains/web3` (write-capable) | `openlaw:clawnch` | Optional | ERC-20 deployment on Base |
| `domains/web3` (write-capable) | `openlaw:okx-onchain-os` | Optional | Multi-chain wallet/transaction surface |

---

## Web3 Skills — Security

Web3 agent skills carry elevated risk because many are early experimental releases.

**Security requirements before installing any Web3 skill:**

1. Install `openlaw:skill-vetter` first — it audits other skills for vulnerabilities before
   you install them. Do not skip this step.

2. Test all Web3 skills in an isolated environment before connecting to any live wallet, contract,
   or API key with production access.

3. Skills that touch transaction signing (wallet skills, contract deployment skills) must be
   reviewed against the trust tier model in `platform/core/kernel/base/trust-model.md`.
   Transaction signing is a Tier 5 action — irreversible, permanent consequences.

4. Install `openlaw:goplus-agent-guard` before enabling any write capability. It provides
   real-time threat blocking and can abort dangerous operations before execution.

5. Most OpenClaw Web3 skills are in early experimental versions and **may contain unknown
   vulnerabilities**. Treat them as untrusted third-party code until audited.

> Read-only analytics platforms (e.g., risk scoring, address analysis, chain data indexing)
> do not require wallet or transaction skills. Install only MistTrack, Dune, and Nansen for
> a read-only analytics stack. This is the recommended default for MVP.

---

## How to Discover Which Skills to Install

After your manifest is valid and module graph is green:

1. Read the `recommendedSkills` field in each active module's `module.yaml`.
2. Cross-reference with the table above.
3. For Web3 projects: always start with `skill-vetter` and `goplus-agent-guard`.
4. Install skills in your AI tool using the skill ID listed.
5. Confirm the skill is active by checking your tool's skill/plugin registry.

There is no validator for skill installation. It is a developer discipline step, not a CI gate.

---

## Skills and the Bootstrap Sequence

Skills fit into the bootstrap sequence between agent pack validation and CI wiring:

```
Step 6 — validate-agent-pack.sh      (agent CLAUDE.md / AGENTS.md exist)
Step 6.5 — install recommended skills (this document)
Step 7 — wire up CI
```

The `bootstrap-quickstart.md` guide includes a skills discovery step after agent pack validation.

---

## Skills vs. compiledFragments

These are complementary, not competing:

| | `compiledFragments` | External skills |
| - | ------------------- | --------------- |
| Source | Harness platform docs | Vendor/ecosystem skill registries |
| Content | Governance rules, module READMEs, trust model | API patterns, library usage, deployment config |
| Installed by | Read at agent session start via AGENTS.md | Developer installs in AI tool |
| Enforced | Yes — validator can check file existence | No — informational only |
| Example | `platform/profiles/domains/supabase/README.md` | `supabase-postgres-best-practices` |

A well-configured project uses both: compiled fragments for governance context, external skills
for tool/API accuracy.

---

## Reference

| Resource | Path |
| -------- | ---- |
| Trust tier model | `platform/core/kernel/base/trust-model.md` |
| Module field reference | `platform/core/registry/module-types.md` |
| Bootstrap quickstart | `platform/workflow/bootstrap-quickstart.md` |
| Agent pack guide | `platform/agents/claude-code/README.md` |
| Web3 domain module | `platform/profiles/domains/web3/module.yaml` |
| Supabase domain module | `platform/profiles/domains/supabase/module.yaml` |
