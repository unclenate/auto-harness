<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0006: Interview-Driven Management Overlay and `oneOf` Required-Artifact Semantics

**Status:** Accepted
**Date:** 2026-05-17
**Author:** @unclenate
**Reviewers:** @unclenate
**Context source:** Consumer-side discovery on `unclenate/permissable` (a Portland event-permitting hackathon docs repo). The team's actual documentation lives in three monolithic interview-driven artifacts (a single PRD, a single decision-complete plan, and an AI-facing interview/spec prompt) instead of the eleven-plus canonical files required by the active `discovery-intake + product-lite + project-standard` triple. The consumer set `overrides.disabledValidations: [required-artifacts]` to suppress validator failures and ultimately removed the harness submodule. The harness pipeline needs to be able to recognize and govern that documentation shape natively, without consumer-side override hacks.

## Context

The harness's canonical management overlays (`product-lite + project-standard`) require eleven-plus files at fixed canonical paths under `docs/product/`, `docs/project/`, and (when `discovery-intake` is active) `docs/discovery/`. This structure works well for teams large enough that distinct files for problem framing, requirements, release intent, scope plan, milestones, change log, dependency log, and revision tracker are read and edited by different people. It does not work well for small teams or hackathon-tier projects whose docs have intentionally converged into a single monolithic PRD, a single decision-complete plan, and a single AI-facing prompt.

The `unclenate/permissable` consumer is the forcing function. Its actual artifacts are:

- `docs/PRD-v2-revised.md` — the monolithic PRD (one file, not three)
- `docs/full-plan.md` — the decision-complete plan (one file, not five)
- `docs/prd-interview-spec-prompt.md` — the AI-facing interview/spec prompt (no analog in the canonical overlays)

The harness's `validate-required-artifacts.sh` validator fails this layout because the artifact list is hard-coded to literal paths like `docs/product/requirements.md` and `docs/project/scope-plan.md`. The consumer's workaround — `overrides.disabledValidations: [required-artifacts]` — silences the validator but also silently disables the entire required-artifact contract for the project. This is a code smell: the harness is supposed to *recognize* legitimate governance shapes, not be talked out of enforcing them. Consumer-side overrides should be reserved for edge cases, not normal operating modes.

The governance question this ADR answers: *should the harness be extended to natively recognize interview-driven, monolithic-docs projects as a first-class shape, and if so, how?*

## Decision

**Add a new `management/interview-driven` overlay and extend the `requiredArtifacts` schema with `oneOf` semantics and glob support, so the harness can validate monolithic-docs and interview-driven projects natively without `disabledValidations` overrides.**

Concrete commitments:

1. **Schema extension — `oneOf` and globs in `requiredArtifacts`.** Each entry in a module's `requiredArtifacts` list may now be either a literal path string (current behavior, unchanged) **or** an object of the form `{ oneOf: [<path-or-glob>, ...] }` satisfied when at least one alternative exists. Glob characters (`*`, `?`, `[...]`) are honored in either form via `Dir.glob`. The change lives in `HarnessRegistry.artifact_satisfied?` and `HarnessRegistry.artifact_label`; the shell validator (`validate-required-artifacts.sh`) calls the helper instead of inlining `File.exist?`.

2. **New `management/interview-driven` module.** Lives at `platform/profiles/management/interview-driven/` with a `module.yaml` (using the new `oneOf` semantics for the PRD slot and the plan slot, plus optional slots for an interview/spec prompt and a problem statement) and a `README.md` describing the philosophy and upgrade path. The module depends only on `kernel/base`. It does **not** conflict with `discovery-intake`, `product-lite`, or `project-standard` — projects can adopt it standalone, alongside discovery, or layered with `product-lite + project-standard` during migration.

3. **Companion rule at least as strict as `product-lite`.** When the PRD changes (under any recognized PRD path), the same commit must touch one of: `docs/project/change-log.md`, a new `docs/adr/ADR-*.md`, the decision-complete plan, or the interview/spec prompt. The human-review clause requires reviewers to verify the change is intentional, that out-of-scope items remain named, and that downstream prompts have been refreshed — the most common failure mode for this style is the PRD updating but the prompt not, so the agent silently builds against a stale spec.

4. **Starter composition.** New file `platform/compositions/interview-driven-discovery.yaml` couples `kernel/base + delivery/prototype + management/interview-driven + agents/base` for one-command bootstrap via `install.sh --composition interview-driven-discovery`.

5. **Reference sample project.** New directory `platform/examples/sample-projects/interview-driven-hackathon/` with a complete reference layout: manifest, governance entrypoints (HARNESS, AGENTS, CLAUDE), operating principles, and short stubs for the three interview-driven docs. Validates green against the full validator chain without `disabledValidations` overrides.

6. **AGENTS.md managed-section reminder.** `install.sh`'s `build_agents_managed_block` now appends a short "Keeping the harness up to date" subsection pointing consumers at `git submodule update --remote` and `platform/workflow/maintenance-operations.md`. The content sits inside the existing `<!-- harness-managed-section -->` markers, so re-running `install.sh` continues to be idempotent.

7. **Documentation updates.** New ADR (this file), SUMMARY.md entries for the new module / composition / sample / ADR, and a one-paragraph mention of the interview-driven path in `platform/workflow/brownfield-onboarding.md` as a soft-entry option for monolithic-docs consumers.

## Consequences

### Positive

- Monolithic-docs and interview-driven consumers can adopt the harness without `disabledValidations` overrides. The validator chain enforces real artifact presence (just with a more flexible notion of *which* file satisfies the slot) instead of being silenced.
- `oneOf` semantics is a general-purpose schema extension. Future modules can use it for any artifact whose canonical location varies across the consumer base — e.g. test plans, architecture diagrams, runbooks — without requiring a new module per variant.
- The upgrade contract from `interview-driven` to `product-lite + project-standard` is now explicit: the new module includes the canonical paths (`docs/product/requirements.md`, `docs/project/scope-plan.md`) as `oneOf` alternatives, so a project that has migrated half-way still validates while the migration completes. There is no flag day.
- The `permissable` consumer (and any future consumer with the same shape) can adopt the harness as a *governance contract* rather than as a contract they need to argue with.
- Glob support lets modules express versioned-file conventions cleanly (`docs/PRD-*.md`) without explosion of literal-path alternatives.

### Negative

- The `requiredArtifacts` schema is now polymorphic — entries are either strings or hashes. Documentation needs to be clear that the literal-string form remains valid (and is still the right default for canonical-path modules). The README for the new module models the intended usage.
- Glob matching uses `Dir.glob` against the project root, which is filesystem-cost cheap but theoretically slower than `File.exist?` on enormous trees. Not a practical concern for the file counts involved.
- Optional-artifact slots also accept `oneOf` (since they reuse the same aggregation pipeline if a future validator surfaces them), but optional artifacts are not enforced today. Behavior of optional `oneOf` entries is therefore "informational only" until or unless a future validator reads them.
- Human-review discipline becomes more important for the new module. The validator can confirm *some* PRD exists, but it cannot confirm the PRD is *good*. Review gates in `module.yaml` carry the load that file presence does for canonical modules.

### Watch

- If multiple consumers adopt the `interview-driven` overlay and develop conventions that diverge from this initial schema (e.g. PRDs at `docs/spec/` instead of `docs/`), the `oneOf` alternative lists may need to grow. Lean toward adding alternatives rather than reshaping the slot semantics.
- If the companion rule's `requiredAny` list becomes too permissive (a PRD edit being satisfied by an unrelated `*-interview-*.md` rename, say), tighten the regex anchors. Current patterns require `^docs/...` prefix and `\.md$` suffix, which is strict enough for the initial use case.
- If the consumer base for the new overlay grows past prototype maturity in aggregate, consider whether `interview-driven` should gain a `delivery/production-saas`-style strictness mode rather than always being prototype-tier in spirit. Defer until a concrete consumer signals the need.

## Trust-Model Implications

**None.** This change is purely additive:

- No new sensitive paths.
- No changes to the trust-tier model (Tier 0–5 unchanged).
- No relaxation of any existing validator.
- No new module families.
- No changes to the kernel's required-artifact contract — `HARNESS.md`, `AGENTS.md`, and `docs/operating-principles.md` remain mandatory under `kernel/base`.

Existing module yamls, validators, consumer manifests, and the harness's own self-validation continue to work unchanged.

## Alternatives Considered

### Extend `discovery-intake` with optional interview-prompt and monolithic-PRD shapes

- Description: Add `oneOf` semantics to the existing `discovery-intake` module's required-artifact list so it natively recognizes monolithic PRD shapes.
- Why rejected: `discovery-intake` is semantically about *pre-project discovery* — the questionnaire-and-MVP-scope conversation that precedes building. Conflating that with "this project's whole product+project documentation is one PRD plus one plan" muddies the module's purpose. A separate `interview-driven` overlay keeps each module's intent crisp and lets consumers choose whichever combination matches their reality.

### Make `disabledValidations: [required-artifacts]` a first-class supported pattern

- Description: Accept that some consumers will run with required-artifact validation off, document it as a legitimate choice, and stop trying to recognize their shape natively.
- Why rejected: This is the path of least resistance, and it is wrong. The harness's whole value proposition is *recognizing legitimate governance shapes and enforcing them in CI*. Once consumers learn that the prescribed remedy for "the harness doesn't fit me" is to silence the validator, they silence other validators too, and the contract erodes from the consumer side. Better to expand what the harness recognizes than to legitimize silencing it.

### Schema with regex patterns instead of glob patterns

- Description: Allow `requiredArtifacts` entries like `{ pattern: "^docs/PRD-.+\\.md$" }`, matching files against regex rather than glob.
- Why rejected: Regex is a power tool that the module-author audience does not consistently know. Globs (`docs/PRD-*.md`) are universal across CLI users, more obvious in module YAML, and sufficient for the actual variants observed. Companion-rule paths still use regex (where the precision matters), but required-artifact patterns stay glob-only.

### Single combined "monolithic" overlay covering PRD + plan + program data

- Description: One module that bundles all the monolithic-doc patterns the harness needs to recognize, including program-management variants and decision-record-style shapes.
- Why rejected: Premature generalization. The `interview-driven` overlay is the only well-evidenced shape from the consumer discovery. If similar patterns surface for other doc surfaces (e.g. monolithic risk register, monolithic architecture diagram), add separate overlays then — keep each module's scope tight.

### Generate the new module's required-artifact list dynamically from the consumer's `harness.manifest.yaml`

- Description: Let the consumer declare their actual file paths in the manifest overrides, and have the module dynamically use those paths.
- Why rejected: This is what `overrides.requiredArtifacts` already does, and it produces no governance value beyond "consumer says they have these files." The point of a module is to *declare the shape the harness will recognize*, not to mirror whatever the consumer happened to author. The schema extension (`oneOf` + globs) lets the module declare a coherent shape that varies in surface detail — that is the right level of flexibility.
