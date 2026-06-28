<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0031: Trace-Contract Content Validator — `validate-trace-contract.sh`

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-28 | **Review Cycle:** On-change

**Status:** Accepted *(design-only per § 9; the implementing PR ships the validator + the template frontmatter + propagation)*
**Date:** 2026-06-28 (filed + accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Promoting OPP: [OPP-0051](../opportunities/OPP-0051-frontier-agent-cluster-v2-enforcement.md) — `proposed` at filing; this PRD ratifies its **first concrete deliverable** (the artifact-content half, anchored on the trace contract) and flips it `proposed → exploring`. OPP-0051 flips `exploring → accepted` at this validator's implementation-merge; the foundry-target / model-routing / defense-in-depth content validators are **follow-on phases** that reuse the shape-assertion skeleton this PRD establishes.
- Anchor OPP: [OPP-0027](../opportunities/OPP-0027-frontier-agent-posture.md) — the frontier-agent cluster; this is the first **v2 enforcement** step for it.
- Sibling-validator precedent: [`validate-sast-coverage.sh`](../../platform/validators/validate-sast-coverage.sh) (PRD-0016) — the module-gated, predict-clean, artifact-frontmatter-shape validator with a `--scan-file` fixture mode that this one mirrors exactly.
- Gated-on modules: [`architectures/agent-observability`](../../platform/profiles/architectures/agent-observability/module.yaml) (PRD-0014 — owns `docs/observability/trace-contract.md`) and [`architectures/ai-foundry-target`](../../platform/profiles/architectures/ai-foundry-target/module.yaml) (PRD-0028 — reuses the same artifact via the deferred-dependency model). The validator activates when **any active module requires `docs/observability/trace-contract.md`**.
- Related operating-principles: § 9 (Split Design from Implementation — this PRD is the design; a separate PR implements), § 10 (this validator converts the artifact-*shape* portion of the `agent-observability` central claim from Half-enforced toward Enforced; the validator asserts presence + shape only, never the human judgment, exactly as `validate-module-stability` does).

## Overview

`architectures/agent-observability` shipped declarative-v1: it requires
`docs/observability/trace-contract.md` to **exist** (`validate-required-artifacts`), but
nothing checks the artifact is **internally well-formed**. PRD-0014 deferred enforcement
to a v2 OPP; OPP-0051 opened that thread and split "enforcement" into a buildable
**artifact-content** half and a still-deferred **code-cross-reference** half. This PRD
ratifies the artifact-content half's first deliverable: **`validate-trace-contract.sh`**,
a module-gated content validator that asserts the trace contract declares the load-bearing
invariants that make it consumable by foundries and observability backends.

The validator mirrors the shipped `validate-sast-coverage.sh` exactly — module-gated
(no-op when no active module requires the artifact, so **predict-clean** on the harness's
own CI), parses a small **YAML frontmatter block** on the artifact (the machine-checkable
mirror of the prose sections), 3-state exit, Bash 3.2 + inline Ruby `YAML.safe_load`, and
a `--scan-file` fixture-test seam. It asserts **presence + shape only** — never that the
declared spans match the emitted telemetry (that is the code-cross-reference half, which
stays deferred because a declarative overlay has no fixed consumer code path).

To give the validator something parseable, the implementing PR adds a small frontmatter
block to the `trace-contract.md` template carrying the three machine-checkable fields
(`semconv_version`, `spans`, `content_capture`); the existing prose sections (the version
pin narrative, the spans/attributes tables) remain the human detail. This is the same
frontmatter-mirrors-prose shape `sast-coverage.md` already uses.

## Goals & Non-Goals

**Goals:**

- Ship `platform/validators/validate-trace-contract.sh` — Bash 3.2, shellcheck-clean at
  warning severity, 3-state exit (0 pass / 1 violation / 2 usage). When **no active module
  requires `docs/observability/trace-contract.md`**: exit 0 with a "no active module
  requires the trace contract — skipping" message on stderr (predict-clean). When active:
  read the artifact, parse its frontmatter, and assert the three invariants below.
- The three load-bearing invariants (presence + shape, never exhaustive correctness):
  1. **`semconv_version:`** present and non-empty — the OpenTelemetry GenAI semantic-conventions
     version pin exists (the conventions are Development/Experimental and churn; an unpinned
     contract is ambiguous).
  2. **`spans:`** is a non-empty list, and **at least one** declared span names a
     conventional GenAI operation from the recommended set (`chat`, `invoke_agent`,
     `execute_tool`, `create_agent`, `embeddings`, `invoke_workflow`) — the contract
     declares at least one span in the conventional shape.
  3. **`content_capture:`** present and from the enum `{opt-in, none}` — the
     privacy-sensitive content-attribute posture is declared explicitly (content
     attributes are opt-in/off-by-default in the conventions for privacy reasons).
- Add the frontmatter block to `platform/templates/observability/trace-contract.md`
  (`semconv_version`, `spans`, `content_capture`) as the machine-checkable mirror of the
  prose; keep the prose sections.
- Ship a `--scan-file <path>` test-seam that validates an arbitrary trace-contract-shaped
  file without active-module gating (fixture-firing tests), per the validator-test-seam pattern.
- Propagation: the validator joins the harness-governance run-order chain, AGENTS.md,
  `platform/validators/README.md`, root README validator table + mermaid box, the
  `harness-governance` SKILL.md chain, and CI; the validator-count prose bumps **20 → 21**
  at every `validate-catalog-counts` ASSERTIONS site (recompute at impl).
- Fixture tests in `platform/validators/test/` covering: inactive no-op pass, well-formed
  pass, missing/empty `semconv_version`, empty `spans`, no conventional operation in
  `spans`, and a `content_capture` outside the enum.
- One paired distillation observation.

**Non-Goals (deferred):**

- **The code-cross-reference half** — asserting the emitted spans match the declared
  contract. Still needs a fixed consumer code path to anchor a companion rule on; stays
  deferred per OPP-0051.
- **A companion rule** binding instrumentation-code changes to `trace-contract.md`. Same
  reason — deferred.
- **The other three content validators** (`validate-foundry-target.sh`,
  `validate-model-routing.sh`, `validate-agent-defense-in-depth.sh`). Follow-on phases of
  OPP-0051 that reuse this validator's shape-assertion skeleton; each is its own PRD.
- **Exhaustive correctness** — that every emitted attribute is conventional, that the
  pinned version is the latest, that examples are valid. v1 asserts the three load-bearing
  invariants; deeper conformance is out of scope.
- **A new operating-principle section.**

## § 10 Claim Classification

| Claim ID | Claim | Current | After v1 |
|----------|-------|---------|----------|
| C-TRACE-1 | A project's declared trace contract is internally well-formed (pins a semconv version, declares a conventional span, states its content-capture posture) | Asserted-only (the artifact must exist, but its content is unchecked) | **Enforced (shape axis)** when an active module requires the artifact — `validate-trace-contract.sh` asserts the three invariants; predict-clean when no module requires it |
| C-TRACE-2 | The declared spans match the telemetry the code actually emits | Asserted-only | **Unchanged** — the code-cross-reference half stays deferred (no fixed consumer code path) |

This is the artifact-shape portion of PRD-0014's central claim moving from Half-enforced
toward Enforced; the runtime-conformance portion (C-TRACE-2) remains the deferred v2
code-cross-reference work.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001 | `validate-trace-contract.sh` ships | Bash 3.2, shellcheck-clean (`-S warning`), 3-state exit. Inactive (no active module requires `docs/observability/trace-contract.md`) → exit 0 + skip message. Active → parses the artifact frontmatter and runs FR-002 checks. `--help` documents args + the three invariants. |
| FR-002 | The three invariant checks | (1) `semconv_version:` present + non-empty; (2) `spans:` non-empty list with ≥1 conventional GenAI operation from the recommended set; (3) `content_capture:` ∈ `{opt-in, none}`. Per-field surfacing on failure. |
| FR-003 | Activation gate spans both requiring modules | The validator activates when **any** active module declares `docs/observability/trace-contract.md` in `requiredArtifacts` (today: `architectures/agent-observability` or `architectures/ai-foundry-target`), via the same `HarnessRegistry` active-module library the sibling validators use. |
| FR-004 | Template frontmatter | `platform/templates/observability/trace-contract.md` gains a YAML frontmatter block (`semconv_version`, `spans`, `content_capture`) as the machine-checkable mirror of the prose; prose sections retained; no bracketed placeholder or literal date-stub tokens (the `validate-placeholders` set). |
| FR-005 | `--scan-file` test seam | `--scan-file <path>` validates an arbitrary trace-contract-shaped file without active-module gating, per the validator-test-seam pattern. |
| FR-006 | Propagation + validator-count bump | Validator wired into the harness-governance chain, AGENTS.md, `platform/validators/README.md`, root README table + mermaid box, CI. Validator-count prose bumps 20 → 21 at every `validate-catalog-counts` ASSERTIONS site (recompute at impl). |
| FR-007 | Fixture tests | `platform/validators/test/` gains a `TestValidateTraceContract` case covering inactive no-op, well-formed pass, and the four failure modes (missing version, empty spans, no conventional operation, bad content_capture). |
| FR-008 | Chain stays green; predict-clean on the harness | The full validator chain passes; the harness does not activate either requiring module, so the new validator no-ops on the harness's own CI. |

### Should Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-S01 | Recommended-operation hint | When `spans:` declares no conventional operation, stderr lists the recommended GenAI operation set with a "→ name at least one conventional operation" hint. |

### Out of Scope

| Feature | Reason | Revisit |
|---------|--------|---------|
| Code-cross-reference (spans match emitted telemetry) | no fixed consumer code path | v2 / a future OPP |
| Companion rule on instrumentation code | same | v2 |
| Foundry-target / model-routing / defense-in-depth content validators | follow-on phases | own PRDs under OPP-0051 |
| Exhaustive attribute/version/example conformance | v1 asserts load-bearing invariants only | v2 if a consumer surfaces the need |

## Technical Constraints

- **Bash 3.2 compatible** (macOS default); **shellcheck clean at `-S warning`**; **3-state
  exit** (0 / 1 / 2).
- **Ruby for content scanning** — inline `ruby -e`, `YAML.safe_load` for the frontmatter,
  same approach as `validate-sast-coverage.sh` / `harness_registry.rb`. No new runtime
  dependencies (Bash + system Ruby only).
- **Recommended GenAI operation set** (codified here as the canonical source):
  `chat`, `invoke_agent`, `execute_tool`, `create_agent`, `embeddings`, `invoke_workflow`.
  Append-only; new operations added in PRs that also update the template + validator `--help`.
- **Active-module detection** — `HarnessRegistry` active-module set; the validator checks
  whether any active module lists `docs/observability/trace-contract.md` in
  `requiredArtifacts` before doing content work (predict-clean otherwise).
- **Performance** — < 1s on the harness's own (inactive) run; < 2s on a consumer activation.
- The validator's own authored prose (`--help`, inline comments) must not trip
  `validate-skill-content.sh` (meta-§10 — the new validator's surface is scanned by its siblings).

## CI/CD Gates

- Full validator chain (now **21** validators) green, including the new validator
  (predict-clean on the harness) and `validate-catalog-counts` after the 20 → 21 bump.
- Fixture tests pass; markdownlint + shellcheck clean.

## Acceptance Criteria for OPP-0051 → `accepted`

OPP-0051 flips `exploring → accepted` when FR-001…FR-008 merge and the harness's own CI
passes — the trace-contract content validator is OPP-0051's named first concrete
deliverable. The remaining three content validators proceed as follow-on phases (their own
PRDs) reusing the shape-assertion skeleton this PR establishes.

## Versioning Implications

Additive: a new validator + a frontmatter block on an existing template. The frontmatter
is a **content tightening** for the `trace-contract.md` artifact — a consumer adopting v2
enforcement regenerates or adds the frontmatter when they opt in; existing consumers are
unaffected until they activate the (predict-clean) check, consistent with the cluster's
monotonic-tightening discipline. Lands in the next minor. Validator count 20 → 21.
