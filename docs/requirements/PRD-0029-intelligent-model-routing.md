<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0029: Intelligent Model Routing as Architectural Primitive — `architectures/intelligent-model-routing`

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-27 | **Review Cycle:** On-change

**Status:** Accepted *(design-only per § 9; the implementing PR ships the module + template)*
**Date:** 2026-06-27 (filed + accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Promoting OPP: [OPP-0030](../opportunities/OPP-0030-intelligent-model-routing.md) — `proposed` at filing; this PRD ratifies its v1 and flips it `proposed → exploring`. OPP-0030 flips `exploring → accepted` at implementation-merge.
- Anchor OPP: [OPP-0027](../opportunities/OPP-0027-frontier-agent-posture.md) — the frontier-agent posture umbrella this module is a satellite of.
- Sibling satellites: [OPP-0028](../opportunities/OPP-0028-ai-foundry-target.md) (`architectures/ai-foundry-target` — **shipped**; lists `docs/architecture/model-routing.md` as an *optional* artifact that this module **owns** — see Deferred-dependency closure below), [OPP-0029](../opportunities/OPP-0029-agent-observability.md) (`architectures/agent-observability` — **shipped**; model-selection spans are part of its trace contract), [OPP-0031](../opportunities/OPP-0031-agent-defense-in-depth.md) (routing decisions are agent-identity-bound; designed in parallel — see [PRD-0030](PRD-0030-agent-defense-in-depth.md)).
- Sibling-module precedent: [`architectures/ai-foundry-target`](../../platform/profiles/architectures/ai-foundry-target/module.yaml) (PRD-0028) and [`architectures/agent-observability`](../../platform/profiles/architectures/agent-observability/module.yaml) (PRD-0014) — the just-shipped same-family modules this mirrors exactly (bare id, `type: architecture`, `stability: beta`, declarative v1, no companion rule / no validator).
- Related operating-principles: § 9 (Split Design from Implementation — this PRD is the design; a separate PR implements), § 10 (the new module declares `stability` per `validate-module-stability.sh`; the routing-declaration claim classifies Half-enforced at v1), § 7 (Align File Boundaries with Change-Class Boundaries — cost-tracking is a separate change-class, kept out).

## Overview

Agent-native projects of any non-trivial complexity route different **tasks** to
different **models** based on capability, cost, privacy posture, regulatory constraint,
and deployment context. This is not a chatbot setting — it is an **architectural fact**
about the project that determines its cost model, privacy posture, and
foundry-portability. No auto-harness module captures model routing as a first-class
architectural primitive: agent-pack modules (`agents/claude-code`, `agents/openclaw`,
…) name *which agent runtime* a project uses; none captures *which models the runtime
routes to and why*.

This PRD specifies a v1 **opt-in `architectures/intelligent-model-routing` module**
that declares a project routes between multiple models deliberately. Like its
just-shipped siblings `architectures/agent-observability` (PRD-0014) and
`architectures/ai-foundry-target` (PRD-0028), **v1 is declarative — no companion rule,
no validator** (enforcement is the v2 follow-up). It requires:

1. **`docs/architecture/model-routing.md`** (new, scaffolded from a template) — declares
   the **routing table** (task → model → rationale → constraints), the **routing
   decision criteria** (capability / cost / privacy / regulatory / deployment-context),
   the **providers in scope** (free-form, with a suggested list), and the
   **foundry-routing seams** (how routing changes per deployment target).
2. **`docs/architecture/model-routing-rationale.md`** — **optional** at v1. An
   evidence/benchmark doc substantiating non-obvious routing choices (e.g. why a task
   goes to a domain-specific open-weight model rather than a frontier API), appropriate
   for healthcare, regulated, or cost-sensitive projects. Optional because most projects
   need the table, not the benchmark dossier.

The **provider list is free-form, not an enum** (Open Question 2): the provider
landscape is still expanding (recent entrants keep landing), so an enum would constrain
too tightly and rot. The template carries a *suggested* list — Anthropic, OpenAI, Azure
OpenAI, Google Gemini, Mistral, DeepSeek, Cohere, xAI, open-weight via vLLM, and
named healthcare-specific models (MedGemma, MedASR, MedImageInsight, CXRReportGen) — as
guidance, not a closed set.

### Deferred-dependency closure

`architectures/ai-foundry-target` (PRD-0028, shipped) lists `docs/architecture/model-routing.md`
as an **optional** artifact precisely because *this* module did not exist yet — the
deferred-dependency model: require the shipped sibling's artifact, make the unbuilt
sibling's artifact optional. Shipping this module makes `model-routing.md` a real,
owned artifact. Per PRD-0028's own statement, that artifact then "moves from optional to
expected" for foundry-target consumers who also route — a **v2 / companion-rule concern
for foundry-target**, *not* a breaking change introduced here. This PRD does not modify
`ai-foundry-target`; it simply closes the loop the cluster was designed to close.

## Goals & Non-Goals

**Goals:**

- Ship `platform/profiles/architectures/intelligent-model-routing/{module.yaml,README.md}` —
  `type: architecture`, `stability: beta`, `dependsOn: [kernel/base]`,
  `requiredArtifacts: [docs/architecture/model-routing.md]`,
  `optionalArtifacts: [docs/architecture/model-routing-rationale.md]`, **no companion
  rules in v1**, `validators: [validate-required-artifacts, validate-companions]`.
  Mirrors the `ai-foundry-target` / `agent-observability` field set.
- Ship a `model-routing.md` template in the **existing** `templates/architecture/`
  subdir (created for `foundry-targets.md`; no new subdir, no new list-completeness
  row): a structured routing table (task · model · rationale · constraints), a
  routing-criteria section (capability / cost / privacy / regulatory / deployment-context),
  a free-form providers-in-scope section with the suggested list, and a
  foundry-routing-seams section noting how the table changes per deployment target.
- Update the `harness-onboarding` SKILL so the module is offered during onboarding for
  any project that routes between multiple models, with its distinct required artifact noted.
- Propagation: SUMMARY architectures list, root README module table + tree,
  templates/README (a row under the existing Architecture/Foundry area), and the
  catalog-count prose sites. **Counts recompute at implementation** against `main` (as
  of filing: `modules_profiles` 50 → 51, `modules_all` 59 → 60, `templates` 95 → 96 for
  the one new template).
- One paired distillation observation.

**Non-Goals (deferred):**

- **Companion rule + `validate-model-routing.sh`.** v1 is declarative, like its two
  shipped siblings. A declarative architecture overlay has no fixed consumer code path
  to anchor a `triggerPaths` regex on, so the OPP-proposed "routing-code edits require a
  `model-routing.md` update" rule is not well-formed at v1. Enforcing that the declared
  table matches the routing code (and that referenced models exist in the project's
  dependency manifests) is v2.
- **Cost-tracking / budgets / attribution.** Routing declares *which model for which
  task*; *how much each task costs* is a separate change-class (see OPP-0047) — out of
  scope per § 7.
- **A provider enum.** v1 documents a *suggested* free-form list; mechanically
  validating provider membership is explicitly rejected (the landscape moves).
- **Multi-agent routing** (which agent handles which user request). v1 covers
  model-routing *within a single agent*; multi-agent routing is a distinct problem and
  its own future OPP.
- **A new operating-principle section.**

## § 10 Claim Classification

| Claim ID | Claim | Current | After v1 |
|----------|-------|---------|----------|
| C-ROUTE-1 | A project can declare, in catalog-governed form, its task→model routing table and the criteria behind it | Asserted-only (no primitive) | **Half-enforced** — the module + required artifact exist; `validate-required-artifacts` checks the artifact is present when the module is active; the *content* (table correctness, that referenced models exist) is not yet checked (v2) |
| C-ROUTE-2 | Module readiness is declared | n/a | **Enforced** — `validate-module-stability.sh` requires the new module's `stability: beta` |

**Not converted:** whether the declared routing table actually matches the project's
routing code, and whether the referenced models exist in its dependency manifests —
that is a v2 enforcement concern; v1 is the declared contract.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001 | `architectures/intelligent-model-routing` module | `module.yaml` + `README.md` present; `id: intelligent-model-routing`, `type: architecture`, `version: 1.0.0`, `stability: beta`, `dependsOn: [kernel/base]`, `requiredArtifacts: [docs/architecture/model-routing.md]`, `optionalArtifacts: [docs/architecture/model-routing-rationale.md]`, `companionRules: []`, `validators: [validate-required-artifacts, validate-companions]`. Mirrors `ai-foundry-target`'s field set. |
| FR-002 | `model-routing.md` template | Tokenized header; sections: a structured routing table (task · model · rationale · constraints), a routing-criteria section (capability / cost / privacy / regulatory / deployment-context), a free-form providers-in-scope section with the suggested list, and a foundry-routing-seams section. `<!-- TODO -->` markers; no bracketed placeholder or literal date-stub tokens (the `validate-placeholders` set). Lives in the existing `templates/architecture/` subdir. |
| FR-003 | README | Architecture-overlay README: what the module governs, the routing dimension vs `agents/` (runtime) and `delivery/` (distribution), the required + optional artifacts, the deferred-dependency closure with `ai-foundry-target`, the compose-with-`agent-observability` note, the v2-deferred enforcement note. |
| FR-004 | Onboarding surfacing | `harness-onboarding` architectures catalog gains a row with its distinct required artifact (`model-routing.md`, not `architecture/overview.md`). |
| FR-005 | Propagation + counts | SUMMARY, root README table + tree, templates/README. Catalog-count prose sites bumped (recompute at impl; the validator names every stale site). No new template subdir (reuses `templates/architecture/`). |
| FR-006 | `validate-module-stability` + chain green | The new module declares `stability` and the full validator chain passes. |

### Should Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-S01 | Deployment-context cross-reference | The template + README note that the routing table is deployment-context-aware — the same task may route to a different model in an air-gapped vs. cloud deployment — and tie that to the `delivery/` posture and the `ai-foundry-target` foundry. |

### Out of Scope

| Feature | Reason | Revisit |
|---------|--------|---------|
| Companion rule / `validate-model-routing.sh` | v1 declarative; no fixed code path | v2 follow-up |
| Cost-tracking / budgets | distinct change-class | OPP-0047 |
| Provider enum membership validator | landscape moves; v1 free-form | v2 (cross-ref dependency manifests) |
| Multi-agent routing | distinct problem | own OPP |

## Open Questions Resolved by This PRD

- **Routing table format — prose, table, or YAML?** → **Structured markdown table** at
  v1 (task → model → rationale → constraints); a YAML alternative is a v2 concern if
  validator-checkable structure becomes load-bearing.
- **Provider list — enum or free-form?** → **Free-form with a suggested list.** An enum
  constrains too tightly given the expanding provider landscape.
- **Cost-tracking in v1?** → **No** — separate change-class (OPP-0047 territory).
- **Companion rule in v1?** → **No** — deferred to v2, consistent with the two shipped
  siblings; a declarative overlay has no fixed `triggerPaths` to anchor on.
- **`validate-model-routing.sh` in v1?** → **No** — just the artifact; v2 can
  cross-reference referenced models against dependency manifests.
- **Healthcare-specific routing — bundle or defer?** → ***Name* the healthcare models
  in the suggested list (MedGemma, MedASR, MedImageInsight, CXRReportGen); *require*
  nothing healthcare-specific.** Healthcare projects adopt the names; others ignore them.
- **Model-routing vs multi-agent routing?** → **v1 covers model-routing within a single
  agent.** Multi-agent routing is a separate future OPP.

## CI/CD Gates

- Full validator chain (20 validators) green, including `validate-module-stability`
  (the new module declares `stability: beta`) and `validate-required-artifacts` (the
  harness does not activate the module, so its artifact isn't required on the harness —
  predict-clean via inactivity).
- `validate-catalog-counts` green after the count bumps; markdownlint clean.

## Acceptance Criteria for OPP-0030 → `accepted`

OPP-0030 flips `exploring → accepted` when FR-001…FR-006 merge and the harness's own
CI passes. (PRD-0029 Status is `Accepted` on this finalization; the OPP moves to
`exploring` now and `accepted` at implementation-merge — the same two-step the cluster's
shipped satellites followed.)

## Versioning Implications

Additive: a new opt-in architecture module + one template, no breaking change. Lands in
the next minor.
