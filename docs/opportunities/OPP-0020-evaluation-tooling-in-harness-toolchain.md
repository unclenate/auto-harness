<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0020 — Evaluation & Safety Tooling as Auto-Harness Toolchain Components

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-24
**Last Updated:** 2026-05-24
**Confidence:** medium-high

---

## Thesis

Auto-harness's enforcement surface today is **markdown + YAML + Bash
validators** — it checks *structure* (manifests, companion rules,
placeholders, artifact presence). It has no way to gate on *behavior*:
whether an agent skill, prompt, or model actually does what it claims, and
does so safely. A growing set of mature, open evaluation frameworks exists
to answer exactly that question:

- **[`microsoft/waza`](https://github.com/microsoft/waza)** — spec-gate /
  capability evaluation for skills and agents (binary Pass/Fail, system +
  process). Already used by a consumer (Tula) in CI.
- **GAIA benchmark** — general AI-assistant capability benchmark for
  agentic task completion.
- **[Inspect](https://github.com/UKGovernmentBEIS/inspect_ai)** — the UK AI
  Safety Institute's evaluation framework for LLM safety and dangerous-
  capability evals.

The opportunity: make auto-harness able to **use** these as first-class
toolchain components — not merely be *aware* of them. This is the inbound
complement to OPP-0001 (which exports auto-harness governance *to* runtime
harnesses): here auto-harness *consumes* evaluation/safety tooling to add a
behavioral gate alongside its structural ones.

Initial bias for the shape: a **recommended evaluation-tooling registry**
(a `platform/` reference mapping eval genres → tools → wiring patterns) plus
an **optional `validate-evals.sh` adapter** that invokes a project's
declared eval runner and gates on its exit code — analogous to how
OPP-0015's regulated-compliance module wraps an external test kit, but
generalized to the evaluation/safety genre and usable by any consumer that
declares the eval-gated testing posture (OPP-0019).

## Origin / Evidence

- **Maintainer signal (2026-05-24).** The owner, reviewing the Tula
  onboarding, observed it would be "useful to have Waza as a component part
  of the auto-harness toolchain and not just aware of it," and named GAIA
  and the AI Safety Institute's Inspect as further candidates. This OPP
  records that direction.
- **Consumer proof-of-concept: Tula.** `.waza.yaml` +
  `.github/workflows/eval-status.yml` show a working CI eval gate that
  regenerates a public status doc (`docs/evals.md`). It demonstrates the
  wiring pattern (declare runner + config → CI step → exit-code gate →
  status artifact) auto-harness would generalize.
- **Three distinct eval genres, one integration shape.** Capability/spec
  (Waza), agentic benchmark (GAIA), and safety (Inspect) differ in what
  they measure but share the integration shape auto-harness would govern:
  a declared runner, a pinned version, a CI invocation, an exit-code gate,
  and a published result artifact. The harness's job is the *governance of
  the gate*, not the eval content.
- **Internal precedent.** OPP-0015 already proposes wrapping an external
  test kit (Inferno) as a governed gate. This OPP is the same move one level
  up: a *genre* of behavioral gates (evaluation/safety) rather than a single
  compliance kit.

## Why Now

- **Behavioral gating is the harness's most-cited absent capability.** The
  trust-tier and companion-rule machinery governs *what may change and who
  approves*; nothing governs *whether the changed behavior is correct or
  safe*. As consumers ship agent-native products (OPP-0018), structural
  gates alone increasingly under-serve them.
- **Safety evals are becoming table stakes.** Government bodies (UK AISI's
  Inspect, the EU AI Act's evaluation expectations) are standardizing
  behavioral and safety evaluation. Positioning auto-harness to *wire in*
  these frameworks — rather than reinvent them — is the same
  occupy-the-governance-layer thesis as OPP-0001, applied inbound.
- **The wiring pattern already exists in a consumer.** Tula's eval CI is a
  ready reference; the marginal cost of generalizing it is low relative to
  the capability it unlocks.

## Risks / Open Questions

- **Scope creep into running evals vs. governing them.** Auto-harness must
  not become an eval *platform*. The boundary: auto-harness governs the
  *gate* (is an eval declared? pinned? invoked in CI? does its result gate
  merge?), it does not author or host the evals. PRD must hold this line
  explicitly or the surface area explodes.
- **Tool churn.** Waza, GAIA, and Inspect are young and moving. A registry
  that hard-codes invocation details will rot. Bias: the registry describes
  *genres and wiring patterns*; per-tool specifics live in version-pinned
  adapter templates the consumer fills, not in the kernel.
- **Runtime cost.** Behavioral evals can run for minutes (Inferno-style) or
  cost real model tokens (GAIA/Inspect). The adapter must distinguish
  PR-time fast gates from scheduled full runs (the same distinction OPP-0015
  raises for Inferno).
- **Does this need a programmatic surface?** OPP-0001 already flags that a
  consumable contract for runtimes likely needs a non-markdown shape. A
  `validate-evals.sh` adapter keeps this OPP within auto-harness's existing
  Bash-validator surface; a richer integration (MCP-tool-shaped eval gating)
  would be a larger, separate scope. Bias: start with the Bash adapter.
- **Relationship to OPP-0019.** OPP-0019 is the consumer *posture
  declaration*; this OPP is the *harness machinery* that executes it. They
  must compose (a project declares eval-gated testing → this provides the
  validator that runs it) without one absorbing the other.

## Disposition

<!-- Empty: status is proposed -->

## Promotion

<!-- Empty: not yet accepted -->

## Related

- Gap analysis source: consumer project (`tula`) at
  `docs/knowledge/harness-coverage-gap-analysis.md` §TG2 (toolchain
  elevation noted in the maintainer signal, beyond the consumer-posture gap)
- Pairs with: [OPP-0019](OPP-0019-eval-gated-testing-posture.md) (the
  consumer posture this machinery serves), [OPP-0018](OPP-0018-architecture-eval-gated-skill-pack.md)
  (skill packs are the first thing the gate protects)
- Inbound complement to: [OPP-0001](OPP-0001-exportable-governance-contract-for-runtime-harnesses.md)
  (outbound governance export) and [OPP-0003](OPP-0003-mcp-producer-and-exportable-governance-via-mcp.md)
- Same integration shape, narrower instance: [OPP-0015](OPP-0015-regulated-compliance-test-kits.md)
  (external regulator test kits)
- External: `github.com/microsoft/waza`,
  `github.com/UKGovernmentBEIS/inspect_ai` (UK AISI Inspect), GAIA benchmark
