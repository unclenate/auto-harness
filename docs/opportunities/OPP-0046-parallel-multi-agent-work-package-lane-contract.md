<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0046 — Parallel Multi-Agent Work-Package Lane Contract

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-06-15
**Last Updated:** 2026-06-15 *(triage of issues #121 + #122 into a single opportunity record)*
**Confidence:** high

---

## Thesis

auto-harness is now a **live multi-agent workspace** — Claude, Codex, and Gemini
execute concurrent work-packages in isolated git worktrees (see the
`project-codex-multiagent` memory). The harness governs *single-agent* and
*sequential* work well, but **parallel multi-agent execution has no
machine-checkable coordination contract**. Work-package boundaries live in prose,
so agents are left to reconcile, by hand and inconsistently, the tension between a
"hard file list," acceptance criteria, named symbol locations, worktree setup, and
per-tool defaults.

The proposal: move the work-package boundary from prose convention toward a
**lintable lane contract**, normalize worktree setup, and make the
shared-observations ledger an explicit **cross-agent memory bus** injected into the
dispatching agent's context. This is the multi-agent analog of a pattern the
harness already runs for modules — *declare a contract, then mechanically check
work against it* (`sensitivePaths` + `companionRules` + `validate-companions`).

This is a triage of two field reports (issues #121 + #122) into one opportunity.
Per the harness's concrete-first ethos, the recommended path is a thin wedge
harvested from the real multi-agent cycles, not a speculative full framework.

### Sub-components (decomposed)

| Sub-component | What it governs | Source | Disposition |
|---|---|---|---|
| **WP lane-contract schema + lint** | A machine-readable lane block on work-package specs (`branch`, `base`, `prMode`, `allowedFiles`, `readOnlyFiles`, `requiredChecks`, `forbiddenCommands`) + a validator that diffs the actual change against the declared lane | #121.1 | **Wedge candidate** |
| **Contract-vs-lane conflict protocol** | Agent-onboarding rule: if an acceptance criterion or named symbol requires a file outside `allowedFiles`, **stop and report** — never silently honor the lane too narrowly *or* silently expand it | #121.2, #122 (the ACP `CAPABILITY_RULES` mismatch) | **Wedge candidate** |
| **Idempotent worktree runbook** | Normalized `git worktree add -b <branch> <path> <base>` (the bare form fails when the branch is absent); never mutate the shared checkout's branch state; re-attach if the worktree already exists | #121.3, #122.2 | **Wedge candidate** |
| **Sibling-worktree validator fallback** | Standard guidance for running validators from a sibling worktree where `.harness` may be empty (point at the main checkout's `platform/`) | #121.4 | **Wedge candidate (doc)** |
| **PR-mode normalization** | `prMode: draft\|ready` in the lane so agents don't infer differently (Codex defaults to draft) | #121.5 | **Wedge candidate (schema field)** |
| Cross-agent memory bus auto-load | Load `shared-observations.md` into the *dispatching/planner* agent's context so it injects relevant project learnings as hard constraints into executing agents' prompts | #122.3 | Deferred |
| Interface-first contract-stub phase | For parallel fullstack, normalize the inter-agent type dependency (a type-only stub) *before* branching, so an agent isn't blocked compiling against a module another agent hasn't written | #122.1 | Deferred |
| Symlinked `node_modules` verification rule | "Verify with tsc + eslint, NOT `next build`" inside symlinked-`node_modules` worktrees (Turbopack module-resolution failure) | #121.6, #122.3 | Deferred (project-specific → consumer `shared-observations.md`) |

## Origin / Evidence

- **Issue #121** (machine-readable WP lane contracts; Codex handoff from the
  PlanAtlas ACP-server package). The sharp edge: a spec required a
  `CAPABILITY_RULES` entry while the hard file list omitted
  `lib/identity/capabilities.ts` where it actually lives — Codex honored the lane
  too narrowly, then had to patch the contract afterward.
- **Issue #122** (field observation, 2026-06-14, `central-city-web`): a fullstack
  parallel build where Claude planned, Gemini built the UI, and Codex built the
  backend in isolated worktrees. Three robust patterns: parallel fullstack needs
  an interface-first contract phase; worktree-init syntax must be normalized
  across LLMs; and `shared-observations.md` **already functions as a cross-agent
  memory bus** (Gemini logged a constraint, the next dispatch injected it). Marked
  **High confidence — seen repeatedly**.
- **Internal precedent.** The lane contract is the multi-agent analog of the
  module declare-then-enforce contract (`sensitivePaths`/`companionRules`, OPP-0034
  / ADR-0017); the conflict protocol is a trust-tier-style *stop-and-report* on
  scope (the agent must not silently exceed its declared lane); the memory bus is
  the structured-observations ledger (ADR-0002) used as an inter-agent channel.

## Why Now

- **auto-harness is already the workspace this governs.** The patterns are not
  hypothetical — they recurred across PlanAtlas and `central-city-web` multi-agent
  cycles, with concrete failures (lane/file-list mismatch; cross-LLM worktree-init
  failures; planner not auto-loading project learnings).
- **The cost of prose-only lanes scales with agent count.** Each added executing
  agent multiplies the reconciliation surface; a machine-checkable lane turns a
  silent mis-scope into a linted, reportable mismatch.
- **One primitive is already proven in the field** (the memory bus), which lowers
  the risk of generalizing — harvest, don't speculate.

## Risks / Open Questions

- **Scope — this is a family, not a half-day item.** Eight sub-components; the
  wedge (lane schema + lint validator + worktree runbook + conflict protocol)
  warrants a PRD with a §10 claim classification, not direct implementation. The
  deferred items each need their own promotion.
- **Lane-schema home.** Is the lane a new artifact type, frontmatter on
  work-package specs, or a sibling YAML? Needs design — and the lint validator
  needs a defined base (the WP spec) to diff the actual change against.
- **Enforced vs. asserted boundary.** The lint-the-diff check is mechanizable
  (Enforced); the conflict protocol is partly agent behavior routed through the
  onboarding skill (Asserted-only / Half-enforced). Classify at PRD time.
- **Harness-scope boundary.** The memory-bus *auto-load* and the interface-first
  stub touch *dispatch/planner runtime behavior*, which is closer to how agents
  are orchestrated than to what the harness governs as documents. Some of this may
  belong in agent packs / the dispatching skill rather than a validator — flag for
  the PRD to draw the line.
- **Project-specific vs. platform learnings.** Rules like the
  symlink-`node_modules` constraint are consumer-project facts and belong in the
  consumer's `shared-observations.md`, not the platform catalog. The opportunity is
  the *mechanism* (memory bus), not hard-coding any one project's rule.

## Disposition

**Proposed 2026-06-15.** Triaged from issues #121 + #122 into one opportunity. No
promotion yet. Recommended next step: a PRD promoting a **thin wedge** — the WP
lane-contract schema, a lane-vs-diff lint validator, the idempotent worktree
runbook, and the conflict-protocol onboarding rule — harvested from the real
PlanAtlas / `central-city-web` lane specs. The cross-agent memory-bus auto-load,
the interface-first contract-stub phase, and project-specific rules stay
`proposed` pending that wedge and a harness-scope decision.

## Related

- Source issues: #121 (machine-readable WP lane contracts + cross-agent conflict
  protocol), #122 (inter-agent variance in parallel fullstack execution).
- Memory: `project-codex-multiagent` (auto-harness as a live multi-agent
  workspace; branch-namespace = actor signal).
- Declare-then-enforce precedent: OPP-0034 / ADR-0017 (`validate-sensitive-paths`),
  the module `companionRules` contract.
- Cross-agent memory channel: ADR-0002 (structured shared observations).
- Adjacent but distinct: OPP-0029 (agent observability — *watching* agents, not
  *coordinating* their lanes).
