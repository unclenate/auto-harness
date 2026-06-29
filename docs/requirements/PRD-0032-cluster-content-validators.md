<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0032: Frontier-Agent Cluster Content Validators (Phases 2–4) — foundry-target / model-routing / defense-in-depth

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-28 | **Review Cycle:** On-change

**Status:** Accepted *(design-only per § 9; the implementing PR(s) ship the validators + the template frontmatter + propagation)*
**Date:** 2026-06-28 (filed + accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Parent OPP: [OPP-0051](../opportunities/OPP-0051-frontier-agent-cluster-v2-enforcement.md) — `accepted`; phase 1 (`validate-trace-contract.sh`) shipped via PRD-0031. This PRD ratifies **phases 2–4**: the remaining three artifact-content validators, which OPP-0051 named as follow-on phases reusing the shape-assertion skeleton.
- Skeleton precedent: [PRD-0031](PRD-0031-validate-trace-contract.md) / [`validate-trace-contract.sh`](../../platform/validators/validate-trace-contract.sh) — the shipped artifact-content validator these three mirror **exactly** (Bash 3.2 + inline Ruby `YAML.safe_load`, 3-state exit, `--scan-file` fixture seam, the **requirement-set activation gate**, frontmatter-shape assertion, predict-clean). This PRD specifies only what differs per validator; everything else is the PRD-0031 contract.
- Sibling-validator precedent: [`validate-sast-coverage.sh`](../../platform/validators/validate-sast-coverage.sh) (PRD-0016) — the original artifact-frontmatter-shape validator.
- Gated-on modules: [`ai-foundry-target`](../../platform/profiles/architectures/ai-foundry-target/module.yaml) (PRD-0028), [`intelligent-model-routing`](../../platform/profiles/architectures/intelligent-model-routing/module.yaml) (PRD-0029), [`agent-defense-in-depth`](../../platform/profiles/architectures/agent-defense-in-depth/module.yaml) (PRD-0030).
- Related operating-principles: § 9 (design split from implementation), § 10 (each validator converts the artifact-shape sub-axis of its module's central claim from Asserted toward Enforced; presence + shape only, never the human judgment — same discipline as `validate-module-stability`), § 7 (the three validators are one change-class — the artifact-content-shape pattern applied three times — so they share a PRD).

## Overview

OPP-0051 split the cluster's v2 enforcement into a buildable **artifact-content** half and
a deferred **code-cross-reference** half, and shipped the content half's anchor
(`validate-trace-contract.sh`, PRD-0031). This PRD ratifies the **other three** content
validators — one per remaining cluster satellite that owns a declarative artifact:

| Validator | Artifact | Gated-on module (requirement-set) |
|---|---|---|
| `validate-foundry-target.sh` | `docs/architecture/foundry-targets.md` | `architectures/ai-foundry-target` |
| `validate-model-routing.sh` | `docs/architecture/model-routing.md` | `architectures/intelligent-model-routing` |
| `validate-agent-defense-in-depth.sh` | `docs/security/agent-defense-in-depth.md` | `architectures/agent-defense-in-depth` |

Each mirrors `validate-trace-contract.sh` exactly — same skeleton, same
**requirement-set activation gate** (activate when any active module declares the artifact
in `requiredArtifacts`; predict-clean otherwise — the harness activates none of these),
same Bash 3.2 + Ruby + 3-state + `--scan-file` contract, same "presence + shape only"
discipline. Each asserts a small set of load-bearing invariants over a machine-checkable
YAML frontmatter block added to the corresponding template (as PRD-0031 did for
`trace-contract.md`). The **code-cross-reference half and companion rules stay deferred**
for all three (no fixed consumer code path).

## Goals & Non-Goals

**Goals:**

- Ship the three validators under `platform/validators/`, each per the PRD-0031 skeleton
  (requirement-set gate, Bash 3.2, shellcheck-clean, 3-state exit, `--scan-file`).
- Add a machine-checkable YAML frontmatter block to each of the three templates
  (`foundry-targets.md`, `model-routing.md`, `agent-defense-in-depth.md`) as the
  mirror of the prose, with real example values so the template self-validates.
- The per-validator invariants (presence + shape only — see the FR table).
- Fixture tests per validator (well-formed pass + each failure mode + inactive skip +
  missing-arg usage error), in `platform/validators/test/`.
- Propagation per validator into every surface the chain touches (CI, AGENTS.md,
  harness-governance SKILL chain + bullet, validators/README table + run + test lists,
  `kernel/base` validators catalog, root README table + mermaid + word-form counts,
  SUMMARY). Validator-count prose bumps **per validator** (21 → 22 → 23 → 24 if all three
  land; recompute at impl against `main`).
- One paired distillation observation (may be shared across the family if implemented together).

**Non-Goals (deferred):**

- **The code-cross-reference half** (declarations match running code) + companion rules —
  still need a fixed consumer code path; deferred per OPP-0051 for all three.
- **Enum membership for free-form fields** — `model-routing` providers are deliberately
  free-form (PRD-0029 OQ#2); the validator asserts route *shape*, not provider membership.
- **Exhaustive correctness** — that declared foundries are reachable, routes optimal, or
  defense patterns truly realized. v1 asserts the load-bearing shape invariants only.
- **A new operating-principle section.**

## § 10 Claim Classification

| Claim ID | Claim | Current | After v1 |
|----------|-------|---------|----------|
| C-FND-shape | The foundry-target declaration is well-formed (≥1 foundry from the enum, each with a live/roadmap status) | Asserted-only | **Enforced (shape axis)** when `ai-foundry-target` is active |
| C-ROUTE-shape | The model-routing declaration is well-formed (≥1 task→model route) | Asserted-only | **Enforced (shape axis)** when `intelligent-model-routing` is active |
| C-DID-shape | The defense-in-depth declaration is well-formed (all four patterns named) | Asserted-only | **Enforced (shape axis)** when `agent-defense-in-depth` is active |

Each converts the artifact-shape sub-axis of its module's central claim (PRD-0028 / 0029 /
0030) from Asserted toward Enforced; the runtime-conformance sub-axis stays deferred (the
per-claim sub-axis decomposition established by PRD-0031).

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001 | `validate-foundry-target.sh` | PRD-0031 skeleton + requirement-set gate on `docs/architecture/foundry-targets.md`. Frontmatter `foundries:` is a non-empty list; each entry is a map with `id` ∈ `{azure-ai-foundry, nvidia-ai-foundry, palantir-aip, aws-bedrock-agentcore, google-vertex-agent-engine, custom}` and `status` ∈ `{live, roadmap}`. |
| FR-002 | `validate-model-routing.sh` | PRD-0031 skeleton + requirement-set gate on `docs/architecture/model-routing.md`. Frontmatter `routes:` is a non-empty list; each entry is a map with a non-empty `task` and a non-empty `model`. Providers are free-form — **no** provider-enum check. |
| FR-003 | `validate-agent-defense-in-depth.sh` | PRD-0031 skeleton + requirement-set gate on `docs/security/agent-defense-in-depth.md`. Frontmatter `patterns:` is a list naming **all four** canonical patterns `{scope-containment, least-permissions, human-in-the-loop, agent-identity}` (missing any one fails). |
| FR-004 | Template frontmatter (×3) | Each template gains a YAML frontmatter block (line 1, before the copyright comment, real example values so the template self-validates), mirroring the prose; no bracketed placeholder or literal date-stub tokens. |
| FR-005 | `--scan-file` + fixture tests (×3) | Each validator supports `--scan-file <path>`; each gets a `Test…` case covering well-formed pass, each failure mode, inactive skip, and missing-arg usage error. |
| FR-006 | Propagation + validator-count bumps | Each validator wired into all chain surfaces; validator-count prose bumped per validator (recompute at impl). |
| FR-007 | Chain green; predict-clean | The full chain passes; the harness activates none of the three modules, so all three no-op on the harness's own CI. |

### Should Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-S01 | Implementation sequencing | The three may ship in **one PR** (shared skeleton, three small validators) or staged one-per-PR; the controller picks at implementation time. If staged, each PR is self-contained (validator + template frontmatter + tests + propagation + count bump). |

### Out of Scope

| Feature | Reason | Revisit |
|---------|--------|---------|
| Code-cross-reference + companion rules | no fixed consumer code path | v2 / future OPP |
| model-routing provider-enum check | providers free-form by design | not planned |
| Exhaustive correctness (reachability, optimality, true realization) | v1 asserts shape only | v2 if a consumer surfaces the need |

## Technical Constraints

All three inherit the PRD-0031 / `validate-trace-contract.sh` constraints verbatim: Bash
3.2 compatible, shellcheck clean at `-S warning`, 3-state exit, inline Ruby
`YAML.safe_load`, `HarnessRegistry` requirement-set activation gate, no new runtime
dependencies, predict-clean on the harness, and the validator's own authored prose must
not trip `validate-skill-content.sh`. The canonical enums/keys are codified in the FR
table above (the `foundries` enum matches PRD-0028; the four pattern keys match PRD-0030).

## CI/CD Gates

- Full validator chain green after each validator lands (count bumped); fixture tests
  pass; markdownlint + shellcheck clean.

## Acceptance Criteria

OPP-0051 is already `accepted` (phase 1). These phases are complete when FR-001…FR-007
merge (in one or more PRs) and the harness's own CI passes. On completion, the cluster's
**artifact-content** v2 enforcement is fully built across all four satellites; only the
code-cross-reference half remains deferred.

## Versioning Implications

Additive: three new validators + frontmatter on three existing templates (a content
tightening per the cluster's monotonic-tightening discipline — consumers regenerate or
add the frontmatter when they opt into the predict-clean check). Validator count
21 → 24 across the three. Lands in the next minor.
