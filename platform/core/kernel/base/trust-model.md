<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Trust Model

All agents operating against a harnessed project move within a six-tier action
model. Each tier names a *class of action* — what kind of change an agent can
make, and what the blast radius is if the action is wrong. The model is the
load-bearing safety contract underneath every agent pack, every PR template,
and every operating-principle the harness ships.

This document defines:

- The six tiers and what each authorizes
- The kernel rules that govern motion between tiers
- The rationale (*"why six?"*) and the patterns the model encodes
- The enforcement floor today (honor code; see OPP-0006 / PRD-0006 for the
  machine-checkable enforcement work in flight)

## The Six Tiers

| Tier | Name | What it authorizes | Blast radius if wrong |
|------|------|--------------------|-----------------------|
| **0** | Read-only inspection | Read files, search, inspect git history, browse module declarations | None — pure observation |
| **1** | Local analysis | Run tests, builds, linters, validators; read outputs; produce reports | None — read-only side effects, no state change |
| **2** | Workspace mutation | Edit files, create artifacts, scaffold local docs, modify configuration | Local — your working tree; recoverable via git |
| **3** | Git-writing | Commit and push to non-protected feature branches; open PRs | Repo — but PR review gate stands between this and merge |
| **4** | Environment-altering | Local migrations, dependency installation, environment changes; mutate things outside the repo | Developer machine + ecosystem deps; recoverable but tedious |
| **5** | Remote or production | Deployments, production migrations, infra changes, secrets rotation, anything irreversible | Production users; potentially irreversible |

Tiers form a strict ordering: tier 5 includes everything tier 4 authorizes,
which includes everything tier 3 authorizes, and so on down. An agent
operating at tier 3 is implicitly authorized to act at tiers 0, 1, and 2.

## Kernel Rules

- **Default permitted tier is declared by the active agent adapter.** The
  agent pack module (`agents/claude-code`, `agents/openclaw`, etc.) sets the
  ceiling. The user can lower it for a specific session; they cannot
  silently raise it via configuration.
- **Agents may always operate at a lower tier.** A tier-3-authorized agent
  doing pure inspection is operating at tier 0 — the *authorization* is the
  ceiling, the *actual action* is the floor.
- **Agents must never self-elevate.** An action that requires a higher tier
  than the agent currently holds must be refused or paused for explicit
  human direction; the agent does not unilaterally cross the line.
- **Tier 4 requires explicit human direction for each action.** "I am going
  to run the migration" does not authorize "I am going to also clean up
  unused dependencies." Each tier-4 action is its own decision.
- **Tier 5 requires explicit human direction *and* second-human sign-off.**
  The irreversibility threshold demands a witness; one human is not enough
  authorization for production-side actions.

## Why Six Tiers (and Not Three, or Twelve)

The number of tiers is the result of three competing pressures:

**Coarser models lose the distinctions that matter.** A two-tier model
(*read* vs. *write*) collapses the meaningful difference between "edit a
file in my working tree" (tier 2; recoverable) and "deploy to production"
(tier 5; potentially not). A three-tier model (*read* / *write-local* /
*write-remote*) is closer, but misses the difference between "commit to a
feature branch" (tier 3; PR review will catch mistakes) and "install a
dependency" (tier 4; my machine's state has changed, the PR process
doesn't catch it). The distinctions that drive the rules — *who reviews*,
*when*, *what's recoverable* — need their own tiers, or the rules don't
attach.

**Finer models add cost without adding safety.** A twelve-tier model
forces decisions agents (and humans) can't reliably make. Is "modify a
file in `.github/workflows/`" a different tier from "modify a file in
`src/`?" Both are workspace mutations (tier 2) that flow through PR review
(tier 3 to land). Adding a sub-tier for workflow files would require
agents to recognize the path-class — a brittle distinction that's better
captured by *companion rules* and *sensitive paths* declared per-module
than by a tier change.

**Six tiers is the smallest set that captures the *transitions where
authorization actually changes hands***. Tier 0 → 1: no change (still
observation-only). Tier 1 → 2: still local, but state mutates; the user's
working tree is now different. Tier 2 → 3: the change leaves the local
machine; the team sees it. Tier 3 → 4: the change leaves the repo; the
environment is different. Tier 4 → 5: the change leaves the developer's
domain entirely; production users are affected. Each transition is where
the safety contract changes, and the number of transitions (five) plus
the starting tier (0) gives six.

## What the Model Encodes

**The blast-radius principle.** Tier number tracks how much can break if
the action is wrong. Higher tier = more downstream effects; higher tier =
stronger pre-action checks demanded. This is the inverse of capability
(where higher tier = more power); the harness explicitly biases against
"capability for capability's sake" — tier-elevation has to be earned by a
human signal, not assumed by an agent.

**The two-human-witness threshold at tier 5.** Production-side actions
demand a witness because one human (the agent's operator) is the same
human who could be wrong about the action's safety. The second human is
not a redundant approver; they're an *independent observer* of the
decision context. The reason single-human authorization is enough up
through tier 4 and not at tier 5: at tier 4 and below, the repo's history
and CI's logs preserve enough state to recover from a mistake. At tier 5,
the production state itself is the artifact at risk, and there's no PR
history to roll back to.

**Authorization is per-session, not per-agent.** A given agent pack
declares a default ceiling; the user can lower the ceiling for a specific
session ("today this agent is read-only"). The ceiling can be lowered
without configuration changes; raising it requires changing the agent
pack or the manifest. This asymmetry is deliberate: caution moves are
cheap; permissive moves require deliberation.

**The model is invariant across agent runtimes.** Claude Code, OpenClaw,
Cursor, Codex CLI — each agent pack declares its default tier ceiling,
but the *tier model itself* is identical across runtimes. A tier-3
action means the same thing whether a human is running it through Claude
Code or a script is running it through OpenClaw. The cross-runtime
invariance is what makes the model load-bearing: every agent
interaction speaks the same vocabulary about what kind of action is
underway.

## Enforcement Today: Honor Code

As of v0.5.x, the trust-tier model is **doctrinally normative but not
machine-enforced**. Agent packs cite the tier model in their `AGENTS.md`
content; PR templates ask the human contributor to declare which tier
their changes operate at; reviewers verify the declaration. There is no
validator today that asserts a PR's diff matches the tier its author
declared, and no kernel mechanism prevents an agent from silently
crossing a tier boundary.

This is a known gap. [OPP-0006](../../../../docs/opportunities/OPP-0006-trust-tier-enforcement.md)
and [PRD-0006](../../../../docs/requirements/PRD-0006-trust-tier-enforcement.md)
specify the v1 machinery to close it: an optional `tier` field on
`module.yaml`, production-shape inference from `sensitivePaths`, a new
`validate-trust-tier.sh` validator, and dogfood declarations on the
harness's own modules. The gap is named explicitly in
`docs/knowledge/shared-observations.md`'s
*"Doctrine in prose without enforcement in code is a recurring harness
gap"* observation; PRD-0006 is the closure.

Until PRD-0006 implementation lands, the model relies on the same
discipline every other doctrine document relies on: agents that read the
doctrine, humans that enforce the contract at review time, and the
audit-trail floor that lets a missed elevation be reconstructed after
the fact via git history.

## Related

- [Doctrine](doctrine.md) — the kernel-doctrine context the trust model sits
  inside
- [Enforcement Model](enforcement-model.md) — how the harness enforces
  contracts in general; the trust model is one specific contract
- [Audit Model](audit-model.md) — the audit-trail floor that makes
  post-hoc reconstruction possible when honor-code enforcement misses
- [OPP-0006 — Trust-Tier Enforcement](../../../../docs/opportunities/OPP-0006-trust-tier-enforcement.md)
- [PRD-0006 — Trust-Tier Enforcement — Making Doctrine Machine-Checkable](../../../../docs/requirements/PRD-0006-trust-tier-enforcement.md)
- Glossary: [Trust Tier](../../../reference/glossary.md#trust-tier)
- Architectural visual: [Diagram 2 — Trust Tier Decision Flow](../../../../docs/architecture/diagrams.md#2-trust-tier-decision-flow)
