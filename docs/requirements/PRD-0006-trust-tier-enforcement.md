<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0006: Trust-Tier Enforcement — Making Doctrine Machine-Checkable

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-05-23 | **Review Cycle:** On-change

**Status:** Proposed
**Date:** 2026-05-23 (filed)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Related OPP: [OPP-0006](../opportunities/OPP-0006-trust-tier-enforcement.md) — `exploring`; this PRD is its promotion candidate
- Related ADRs (anticipated, may spawn from this PRD):
  - ADR-0013 — Trust-tier schema location and inference rules (TBD during implementation)
- Related observations:
  - `docs/knowledge/shared-observations.md` — *"Doctrine in prose without enforcement in code is a recurring harness gap pattern"* (2026-05-23) — the proximate motivator
  - *"Governance machinery that asserts against state-including-itself creates a free first-run self-test"* (2026-05-23) — design discipline applies here (the new validator should assert against the harness's own active modules)
- Other:
  - [`platform/core/kernel/base/trust-model.md`](../../platform/core/kernel/base/trust-model.md) — the doctrine being mechanized
  - [`docs/threat-model.md`](../threat-model.md) — adversary model A5 (compromised AI agent) names this gap explicitly
  - [`docs/operating-principles.md`](../operating-principles.md) — § 5 (Self-Governance) + § 6 (AI-Assisted Development) — principles this enforcement upholds

## Overview

Auto-harness's trust-tier model (six tiers, kernel-doctrined,
universally referenced) has zero machine-checkable enforcement. Every
agent pack's README cites the tier model. The PR template has manual
checkboxes. `docs/operating-principles.md` § 6 names tier discipline
as foundational. But no validator catches tier escalation; no
`module.yaml` schema field declares tier; no consumer-side machinery
prevents an agent from silently performing a Tier 4 / Tier 5
operation.

This PRD specifies the v1 enforcement machinery as four coordinated
additions, scoped to ship without breaking backward compatibility:

1. **Optional `tier` field on `module.yaml`** — additive schema; legacy
   modules pass validation without declaring; new modules can declare.
2. **`sensitivePaths`-based tier inference** — a curated set of
   production-shape path patterns (e.g., `^src/migrations/`,
   `^deploy/`, `^infra/`, `^.github/workflows/`) implicitly assert
   Tier 4 or Tier 5 when matched. Closes coverage for legacy modules
   without requiring schema migration.
3. **New `validate-trust-tier.sh` validator** — asserts coherence
   across declared tiers, inferred tiers, and agent-pack max-tier
   declarations. Fails CI on under-declaration (declared tier < inferred
   tier for a module) and on agent-pack max-tier violations (an active
   agent pack with declared max-tier < any active module's tier).
4. **`harness-governance` SKILL.md updates** — tier-aware guidance
   for agents reading the skill: how to check tier before acting, how
   to escalate authorization, how to interpret the validator's
   feedback.

v1 is **PR-boundary enforcement** only. Session-level enforcement
(catching an agent attempting a Tier 4 action *during* coding) is
v2+ work — it requires AI-client-specific hooks that aren't uniformly
available across Claude Code / Cursor / Copilot / Codex / Gemini.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- Add optional `tier` field to the `module.yaml` schema (additive; no
  breaking change for legacy modules).
- Define the inference ruleset for production-shape sensitivePaths
  patterns → implied tier; codify in `validate-trust-tier.sh`'s help
  text and in the validator code.
- Ship `platform/validators/validate-trust-tier.sh` — Bash 3.2
  compatible, shellcheck-clean at warning severity, 3-state exit (0
  pass / 1 violation / 2 usage error), per established validator
  conventions.
- Wire the new validator into `kernel/base` module.yaml validators
  list, CI workflow, and `harness-governance` SKILL.md (both the
  validator chain code block and the signature-notes section).
- Declare explicit tier values on auto-harness's own active modules
  (the dogfood pass) — `kernel/base` is Tier 0 by definition;
  management modules typically Tier 2 (workspace mutation);
  agent modules carry max-tier declarations matching the agent
  client's actual capabilities.
- Update `validate-catalog-counts.sh` with a new assertion for the
  validator count (8→9) and any tier-related documented claims.
- Update `harness-governance` SKILL.md with a new "Trust-Tier
  Verification" section explaining how an agent should check tier
  consistency before performing an action.
- One paired architectural observation capturing the design pressure
  of mechanizing doctrine (anticipated: the implementation pass will
  surface design questions the OPP elided, per the PR #37 pattern).

**Non-Goals** — explicitly deferred to follow-up:

- **Session-level enforcement** (agent hooks that catch Tier 4 actions
  in real time). Requires AI-client-specific hook integration; v2+.
- **Required `tier` field** on `module.yaml`. v1 is opt-in to avoid
  breaking changes. A future MAJOR release may require the field.
- **Inferred tier auto-population** of the PR template's manual
  checkboxes. v1 keeps the checkboxes manual; validator output is
  read by humans.
- **Tier-tagged commits** (per-commit tier metadata). High enforcement
  value but high ergonomic cost; revisit if v1 leaves coverage gaps.
- **Module-graph transitive tier propagation** (if A is Tier 4 and B
  depends on A, does B inherit?). v1 checks each module's declared/
  inferred tier independently; transitive analysis is v2+.
- **Cross-client allowlist reconciliation** (Cursor Auto-Run list,
  Claude Code settings.json permissions, etc.). v1 declares
  client-side declarations in `module.yaml` but does not assert
  consistency with client config files; v2+.
- **Companion-rule-level tier declaration** (Option D in OPP-0006).
  v1 puts tier at module level; per-rule tier is a follow-up if module-
  level granularity proves insufficient.

## Functional Requirements

### FR-001 — `tier` schema field

Extend the `module.yaml` schema to accept an optional top-level field:

```yaml
tier:
  declared: <0|1|2|3|4|5>           # the module's max effective tier
  rationale: "<one-line rationale>"  # required if declared > 2
```

Validation: declared must be in range 0-5; rationale required for
declared >= 3 (substantive tier needs justification).

For agent packs (`platform/agents/*/module.yaml`), an additional
field:

```yaml
maxTier: <0|1|2|3|4|5>  # the highest tier this agent client can be configured for
```

Agent-pack-specific field is independent of `tier.declared` — an
agent pack can declare maxTier 4 while its module's own tier
classification is 2 (the pack itself is configuration, not
production-altering machinery).

### FR-002 — sensitivePaths inference rules

`validate-trust-tier.sh` implements an inference table mapping path
patterns to implied tier:

| Pattern | Implied tier | Rationale |
|---------|--------------|-----------|
| `^src/migrations/` or `^db/migrations/` | 4 | Schema changes are environment-altering |
| `^deploy/`, `^.github/workflows/deploy.*`, `^infra/` | 5 | Production deployment touchpoints |
| `^.github/workflows/` (non-deploy) | 4 | CI changes affect every consumer build |
| `^.env`, `^secrets/`, `^.kube/` | 5 | Credential / secret touchpoints |
| `^Dockerfile`, `^docker-compose.*` | 4 | Environment construction |
| `^package.json`, `^pyproject.toml`, lockfiles | 4 | Dependency surface |
| `^harness.manifest.yaml`, `^platform/core/kernel/` | 5 | Kernel changes affect every consumer of every consumer |

The validator's `--help` text and a new section in
`platform/validators/README.md` document this table — the inference
rules are part of the public contract.

### FR-003 — `validate-trust-tier.sh` script

Bash 3.2-compatible script with the standard validator contract:

- `-h` / `--help` flag
- 3-state exit (0 / 1 / 2)
- Project-root argument (default cwd)
- File-level shellcheck-disable for indirect-expansion if needed
- Inline documentation of inference table

Validation steps the script performs:

1. **For each active module in `harness.manifest.yaml`:**
   - If module declares `tier.declared`, validate range (0-5) and
     rationale requirement.
   - Compute *inferred tier* from sensitivePaths patterns. Highest
     match wins.
   - Assert: declared tier >= inferred tier (no under-declaration).
   - If declared tier is missing and inferred tier > 2, log a
     warning recommending explicit declaration.

2. **For each active agent pack:**
   - Validate `maxTier` if declared.
   - Assert: agent pack's `maxTier` >= max(tier.declared OR inferred)
     across all *non-agent* active modules. If an agent pack with
     maxTier 3 is paired with a module that requires tier 4, fail.

3. **Cross-cutting checks:**
   - If any active module's declared tier is 5, require that the
     active manifest also declares a `criticality` of `production`
     or higher (catches the "Tier 5 work on a prototype" combination
     that probably indicates misconfiguration).

Exit 1 on any assertion failure; exit 0 on clean pass; exit 2 on
malformed manifest / missing dependencies / bad args.

### FR-004 — Wiring (kernel + CI + skill)

- Add `validate-trust-tier` to `platform/core/kernel/base/module.yaml`
  `validators:` list.
- Add a new step in `.github/workflows/harness.yml` between
  `validate-catalog-counts` and `validate-companions`.
- Add `validate-trust-tier.sh` to
  `platform/skills/harness-governance/SKILL.md` "Running Validators"
  code block + new signature-notes paragraph.
- Update `platform/templates/ci/github-actions.yml` and `gitlab-ci.yml`
  to include the new validator (so consumer CI inherits it).

### FR-005 — Dogfood: declare tiers on auto-harness's own active modules

Update each active module's `module.yaml` with explicit `tier.declared`
where appropriate:

- `kernel/base` — Tier 0 (read-only doctrine; modifications by humans
  only via ADR)
- `internal-platform` (delivery) — Tier 0 (configuration)
- `project-standard` (management) — Tier 2 (artifact scaffolding)
- `product-lite` (management) — Tier 2
- `knowledge-capture` (management) — Tier 2
- `opportunity-capture` (management) — Tier 2
- `base` (agent) — `maxTier: 3` (the base agent contract permits
  git-writing)
- `generic-llm` (agent) — `maxTier: 3`
- `openclaw` (agent) — `maxTier: 4` (its session-level capabilities
  extend further)

These are the v1 declarations; refinement happens through actual use.

### FR-006 — Documentation updates

- New section in `platform/core/kernel/base/trust-model.md` titled
  "Enforcement" naming what the validator checks vs. what remains
  honor-code. Honesty about the gap is more valuable than overstating
  coverage.
- Updates to `docs/threat-model.md` adversary model A5 mitigation
  list — move "machine-checked trust-tier enforcement" from the
  "Not Yet Deployed" section into "Mitigations in place" (partial)
  with the v1 scope honestly described.
- New entry in `platform/workflow/extending-the-harness.md` (validator
  authoring section) — when adding new modules, declare tier;
  guidance for inferring rationale.

### FR-007 — Update `validate-catalog-counts.sh` assertion table

Adding a 9th validator bumps the `validators` count to 9. The catalog
validator's own first run after FR-003 lands will catch the drift
across:

- `platform/reference/how-to-read.md` (two sites)
- `docs/architecture/diagrams.md` (one site)
- `docs/_assets/cover-back.svg` (one site)
- `README.md` (two sites — prose word-form + table caption)
- SUMMARY.md Validator Reference section

All bumped in the same PR per the existing pattern.

## Acceptance Criteria for OPP-0006 Promotion to `accepted`

OPP-0006 flips from `exploring` to `accepted` when **all** of the
following are met:

1. PRD-0006 status flips to `Accepted`
2. FR-001 through FR-007 implemented and merged to `main`
3. `validate-trust-tier.sh` passes against auto-harness's own
   manifest (self-dogfood)
4. CI green on the implementation PR including the new validator step
5. `docs/threat-model.md` A5 mitigation list updated to reflect the
   partial-but-real enforcement now in place

## Out of Scope

(Explicitly listed above under Non-Goals; reproduced here for
reviewer convenience.)

- Session-level enforcement
- Required `tier` field
- PR-template auto-fill from validator
- Tier-tagged commits
- Transitive tier propagation
- Cross-client allowlist reconciliation
- Companion-rule-level tier declaration

## Risks

### Risk: Under-declaration becomes the new "compliance theater"

If the validator only checks declared/inferred coherence, lazy
declarations (every module → Tier 2) pass validation while providing
no real safety. The inference table is the load-bearing defense:
production-shape paths force higher tier regardless of declaration.

**Mitigation:** Lead with inference; declaration is a refinement, not
the primary signal. Document the inference rules transparently so
adopters understand what's actually checked.

### Risk: Inference table over-fits to auto-harness's own structure

The pattern table is initially populated from auto-harness's
observation of typical project shapes. Consumer projects may have
production-shape paths in non-standard locations (e.g.,
`platform/migrations/` instead of `src/migrations/`).

**Mitigation:** Allow consumer projects to extend the inference table
via a `.trust-tier-inference` file (similar to `.placeholder-ignore`)
that augments the default rules. v1 ships the defaults; the extension
mechanism lands if/when consumers report missing coverage.

### Risk: Existing modules without `tier` field create silent gaps

Optional schema means modules can omit declarations. The validator
infers from sensitivePaths, but a module with no sensitivePaths
and no tier declaration is effectively "tier 0" by default — which
may understate.

**Mitigation:** Validator emits a warning (not failure) for modules
without explicit declarations if inferred tier > 2. Reviewers see
the warnings; declarations get added incrementally.

### Risk: Agent-pack `maxTier` conflicts with client config

An agent pack declaring `maxTier: 3` may pair with a Claude Code
client whose `settings.json` has been permissively configured (e.g.,
allowing `npm install` which is Tier 4). The harness can declare the
intent; it cannot reach into the client to enforce.

**Mitigation:** Validator output explicitly names the
declaration-vs-configuration distinction. The threat-model.md A5
update documents this gap honestly.

## Open Questions Resolved by This PRD

The OPP-0006 open questions are resolved as follows:

- **Schema location?** → **Module level for v1.** Per-rule tier (Option
  D in OPP) deferred unless v1 proves insufficient.

- **Required vs. optional?** → **Optional with inference fallback.**
  Hybrid (Option E) — additive schema avoids breaking changes;
  inference provides coverage for unmigrated modules.

- **Inference vs. declaration?** → **Both, with declaration winning
  when present.** Validator uses max(declared, inferred) so neither
  can under-state.

- **Cross-module tier propagation?** → **Out of scope for v1.** Each
  module checked independently. Transitive analysis is v2+.

- **PR-level vs. session-level?** → **PR-level only.** Session-level
  enforcement requires AI-client hooks that aren't uniformly
  available; deferred to v2+.

- **Tier-tagged commits?** → **No.** Out of scope for v1.

- **PR template manual checkboxes?** → **Keep unchanged for v1.**
  Auto-fill from validator output is a follow-up (v0.7+).

## Future Work (Not v1)

- **Session-level enforcement adapters** for Claude Code (hooks),
  Cursor (allowlist sync), Copilot CLI (config validation), etc.
- **Tier-tagged commits** if v1's PR-boundary check leaves
  significant gaps.
- **Required schema field** in a future MAJOR release once all
  in-tree and known-consumer modules have explicit declarations.
- **Transitive tier propagation** through the dependsOn graph.
- **PR template auto-fill** from validator output (eliminates manual
  checkbox drift).
- **Cross-client allowlist validators** that reconcile harness
  declarations with AI-client configuration files.
- **`tier` inheritance from companion-rule satisfier requirements**
  (e.g., a rule whose satisfier is an ADR implies the work has
  architectural weight ⇒ tier ≥ 3).

## Implementation Notes

- **Sequencing within the implementation PR:** FR-001 (schema) must
  land *with* FR-003 (validator) because the validator reads the
  schema; FR-005 (dogfood declarations) lands in the same PR so
  the validator's first CI run exercises the new declarations against
  the harness's own state — same self-stabilization pattern as PR #41.
- **Bash 3.2 compatibility:** lessons from `validate-catalog-counts.sh`
  apply — no `declare -A`, no `mapfile`, file-level shellcheck-disable
  if indirect expansion is needed.
- **Companion rule on `module.yaml`:** since `module.yaml` files
  match `^platform/.+/module\.yaml$` (a distillation trigger), the
  implementation PR will fire the distillation rule and need a paired
  observation — anticipated and budgeted.
- **Testing:** mirror `validate-catalog-counts.sh` pattern — the
  validator runs against the harness's own active modules as its
  integration test; no separate fixture project needed at v1.

## CI / CD Gates

- All 8 existing validators must pass on the implementation PR.
- New `validate-trust-tier.sh` step must pass.
- Shellcheck at `--severity=warning` on the new script.
- Markdownlint clean on any new doc content.
- The `sample-projects` job from PR #45 must continue to pass — the
  new validator runs against the harness's own manifest, not against
  samples, so this is not an additional sample-CI burden.

## Versioning Implications

- Trust-tier enforcement v1 is a **MINOR bump** to v0.7.0 (additive
  schema, new validator; no breaking change). The original plan was
  v0.6.0, but the order was swapped 2026-05-24 after the OPP-0007
  field evidence from `bdits/municipal-brain` proved a higher signal
  than the audit-identified trust-tier gap. v0.6.0 now releases
  canonical-position (PRD-0007); trust-tier follows as v0.7.0.
- The new `tier` field on `module.yaml` is documented in CHANGELOG.md
  under `### Added`.
- The dogfood declarations on auto-harness's own modules are
  documented under `### Changed` (modules transition from "tier
  undeclared" to "tier declared").
- This PRD's acceptance becomes the v0.7.0 release-marker event.
- Trust-tier v2 (session-level enforcement) deferred to v0.8+ and
  will likely cite canonical-position sections as the rationale
  surface for validator opt-outs per Observation A from the
  municipal-brain handoff.
