<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0003: Auto-Harness Submodule Integration

**Status:** Accepted
**Date:** 2026-04-20
**Author:** @unclenate
**Reviewers:** @unclenate
**Context source:** Design session on how consumer repos should integrate auto-harness; originated during adsclaw documentation work when the project surfaced the need for a mechanism that (a) lets multiple downstream repos adopt the framework without copy-paste drift and (b) lets upstream improvements flow back to every adopter automatically.

## Context

Until now, adopting auto-harness meant copying `platform/` fragments into a consumer repo per the `bootstrap-quickstart.md` workflow — a `cp -r` of compositions, skills, and templates, followed by manual edits. This model has three problems that compound over time:

1. **Upstream drift.** Consumers fork a snapshot. When auto-harness improves a skill or validator, adopters don't see the improvement unless they re-copy and hand-merge. The further a consumer's snapshot ages, the higher the cost of catching up, and in practice most never do.
2. **Brownfield fragility.** The current bootstrap assumes a greenfield-ish target. Running it in a repo that already has `CLAUDE.md`, `AGENTS.md`, or a `harness.manifest.yaml` would either clobber files or produce confusing merge conflicts — neither is acceptable.
3. **Coexistence with other platforms.** Many real-world repos already host configuration from Cursor, Windsurf, GitHub Copilot, OpenAI Codex, OpenClaw, or the cross-client AGENTS.md convention. A naive integration would step on their toes; a good one would observe, integrate where it helps, and absorb conventions the repo has already settled.

Exploration against the current code confirmed one important fact: auto-harness is *mostly* submodule-safe today. Validators resolve `HARNESS_ROOT` via `SCRIPT_DIR/../..`, which works correctly from any mount point; manifest paths are passed explicitly on the CLI. What's missing is the *consumer-facing ergonomics* — a bootstrap that respects pre-existing state, documentation that reflects the submodule shape, and a skill-delivery mechanism that preserves the upstream-update benefit of using a submodule in the first place.

## Decision

**Auto-harness supports first-class consumption as a git submodule, mounted at a consumer-chosen path (default `.harness/`), with a brownfield-safe bootstrap and symlink-based skill delivery.**

Concrete commitments:

1. **Mount path is pluggable via env var `HARNESS_SUBMODULE_ROOT` with default `.harness/`.** Consumer-facing docs and generated artifacts reference the env var, not a hardcoded path. The framework itself (self-dogfood) continues to use `platform/...` references directly.
2. **Skills flow via relative symlinks.** The primary link target is `.agents/skills/<name>` (the cross-client convention). A parallel `.claude/skills/<name>` symlink is created as a Claude Code alias. Both resolve to `$HARNESS_SUBMODULE_ROOT/platform/skills/<name>`. Upstream updates propagate through `git submodule update` with no consumer action required.
3. **One bootstrap entrypoint, `platform/bootstrap/install.sh`, that is brownfield-safe and platform-aware.** It classifies every relevant file as `ABSENT`, `HARNESS_STYLE`, `FOREIGN`, or `PLATFORM_ARTIFACT`, never overwrites `FOREIGN` or `PLATFORM_ARTIFACT` files, and reports everything it saw or skipped in a five-block summary.
4. **Other AI platforms are observed, integrated, or absorbed — never modified.** The bootstrap enumerates a signature-file catalog spanning Claude Code, Cursor, Windsurf, GitHub Copilot, MS Copilot, OpenAI Codex, OpenClaw, Hermes, and cross-client AGENTS.md. Files on that catalog are `PLATFORM_ARTIFACT` and excluded from writes. Where the harness has something useful to add to a cross-client file (specifically `AGENTS.md`), it merges via a stable marker comment rather than replacing content.
5. **No manifest schema change.** `harness.manifest.yaml` describes governance posture, not deployment topology; mount path stays out of it. This avoids coupling a governance-record file to a mechanical decision that may change without warranting a new ADR.

## Consequences

### Positive

- Consumers get automatic upstream flow — improvements to skills, validators, compositions, and templates reach every adopter without manual re-sync
- Brownfield onboarding becomes safe: no existing file is clobbered, and foreign configuration (other platforms, custom conventions) is preserved verbatim
- The framework-root-vs-consumer-root distinction is made explicit through `HARNESS_SUBMODULE_ROOT`, eliminating a long-standing source of confusion in docs
- Coexistence with other AI platforms becomes a first-class property, not a discovery accident
- The ADR itself is cite-able from consumer repos that want to document *why* they adopted the submodule pattern

### Negative

- **Consumers need Ruby 3.0+ available wherever the harness runs.** Every validator shell script (`validate-manifest.sh`, `validate-module-graph.sh`, `validate-required-artifacts.sh`, `validate-companions.sh`, `validate-agent-pack.sh`) is a thin bash wrapper around a Ruby heredoc that does the actual YAML parsing and validation. The `install.sh` bootstrap inherits the same constraint because it uses Ruby to merge pre-existing consumer manifests. This is not new with submodule integration — it has been true since the validators were written — but submodule adoption makes it more salient because consumers now run these scripts *inside their own repos* rather than reading about them. [`platform/workflow/ci-integration.md`](../../platform/workflow/ci-integration.md) already prescribes `uses: ruby/setup-ruby@v1` with `ruby-version: "3.3"` in every example workflow; this ADR makes the requirement explicit at the decision-record level so consumers setting up new CI pipelines don't miss it. The only bootstrap component that doesn't require Ruby is [`link-skills.sh`](../../platform/bootstrap/link-skills.sh), which is pure bash.
- Consumers on Windows must enable `core.symlinks=true` in their git config, or the skill symlinks won't function. This is a one-time configuration but easy to miss.
- Choosing a mount path at bootstrap time commits the consumer to that path relatively. Moving the submodule later requires re-bootstrapping (not strictly a breaking change, but a chore).
- Downstream repos must run `git submodule update --remote` periodically; the propagation is *automatic when invoked*, but nothing forces the invocation. Consumers who never update their submodule effectively opt out of the upstream-flow benefit.
- The bootstrap's platform-detection catalog is a moving target — new AI platforms emerge, existing ones change their signature files. The catalog will need periodic revisits.

### Watch

- If the `[CONFLICT]` rate on brownfield bootstraps is high, the `HARNESS_STYLE` detection heuristics may be too strict (over-detecting FOREIGN) or too lax (under-detecting harness-generated files). Both failure modes are recoverable but erode trust.
- If consumers start editing files inside the submodule directly (instead of raising upstream PRs), the separation this ADR tries to establish breaks down. Worth monitoring via occasional `git diff HEAD` inside consumer submodule directories.
- If `.agents/skills/` adoption stalls across the AI-agent ecosystem and it turns out to be a dead convention, the primary symlink target may need to shift back to `.claude/skills/` or to a successor convention. The dual-target design means the cost of that shift is a CLI flag default, not a rewrite.

## Alternatives Considered

### Copy-in (current `bootstrap-quickstart.md` flow)

- Description: Consumer copies `platform/` fragments into their repo at adoption time and edits from there.
- Why rejected: Discards the upstream-flow benefit entirely. Every bug fix and skill improvement requires the consumer to remember to re-copy, which in practice nobody does. Over time, deployed snapshots drift so far from upstream that the "framework" identity is effectively lost.

### Git subtree

- Description: Use `git subtree` instead of submodule — fragments live inside the consumer's git history directly.
- Why rejected: The subtree/submodule trade-off is a known one, and the decisive factor here is that auto-harness is a living *dependency* of the consumer, not a one-time imported fragment. Submodules express that relationship correctly; subtree flattens it. Also, subtree makes "pull upstream changes" harder than submodule does, which works against the primary goal.

### Separate sibling checkout

- Description: Consumer clones auto-harness into a sibling directory (`../auto-harness/`) and their repo references it by out-of-tree path.
- Why rejected: Works for individual developers but breaks everything CI-shaped, because CI environments don't have a sibling directory pre-cloned. Would require every consumer to add an extra checkout step to every CI workflow — strictly worse than submodule, which GitHub Actions handles with a single flag.

### Package-manager distribution (npm, pip, gem)

- Description: Publish auto-harness as a package in one or more ecosystems.
- Why rejected: Three showstoppers. (a) Auto-harness is multi-language by design — binding it to one ecosystem (npm or pip) penalizes users of other stacks. (b) The content of auto-harness is mostly markdown, YAML, and shell — it's not "code a package would install" but "governance and convention a repo adopts." (c) Package distribution hides the source directory, which is hostile to the whole premise of "read the SKILL.md to understand what the governance does." Keeping it as readable git content preserves transparency.

### Bootstrap-as-AI-skill only

- Description: No shell script; the `harness-onboarding` skill guides Claude Code (or another agent) through the bootstrap interactively in every adopting repo.
- Why rejected: The `harness-onboarding` skill is still the right tool for *analysis* (does this repo need testing-standard? product-lite? which stack overlay matches?), but the mechanical parts (copy templates, create symlinks, merge AGENTS.md) are deterministic and don't require judgment. Pushing deterministic work through an AI adds latency, cost, and non-determinism for no benefit. The two tools complement: `install.sh` handles the mechanical side; the skill handles the analytical side.

### Monorepo (consumer repos merged into auto-harness)

- Description: Fold adsclaw, Bernays, and future adopters into a single repository with auto-harness, each as a top-level directory. Everyone shares one git history; upstream changes are always visible; no submodule mechanics needed.
- Why rejected: Three compounding objections. (a) Consumer repos are authored by different teams and projects with independent release cadences, private-vs-public policies, license constraints, and access-control needs — forcing a merge would violate all of those. (b) Monorepo tooling (build orchestration, selective CI, dependency graphs) is a substantial investment that auto-harness has no reason to adopt for a governance-framework use case. (c) The whole *point* of auto-harness is that it's a reusable substrate consumed by unrelated projects; collapsing those projects into one repo erases the substrate-vs-consumer distinction that motivates the framework's existence.

### Vendored copy with automated sync bot

- Description: Consumers copy `platform/` into their repo (as in the current bootstrap), but a scheduled GitHub Actions bot opens a PR against each consumer whenever upstream auto-harness changes. Consumers review and merge the bot's PRs to stay current.
- Why rejected: It mimics the submodule's upstream-flow property at much higher complexity. The bot would need credentials to push to every consumer repo, a per-consumer config describing which files to sync, merge-conflict heuristics for consumer-modified files, and a dashboard to see which consumers are behind. That's a multi-month engineering investment to reinvent what `git submodule update --remote` already does with one command. Additionally, a sync bot creates drift *during the window between upstream change and bot PR merge* — submodules have no such window; the consumer updates on their own cadence by invoking one command. The only scenario where a sync bot wins is if the consumer refuses to use submodules at all (e.g., a git workflow that forbids them), in which case package-manager distribution is a better fallback anyway.
