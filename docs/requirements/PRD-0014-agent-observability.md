<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0014: Agent Observability with OpenTelemetry Semantic Conventions

**Version:** 1.1 | **Owner:** @unclenate | **Last Updated:** 2026-06-27 | **Review Cycle:** On-change

**Status:** Accepted
**Date:** 2026-05-26 (filed) | 2026-06-27 (finalized + accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

> **2026-06-27 finalization (v1.1).** Reconciled month-old drift against current
> `main` and accepted as the v1 design contract. The core design — a new opt-in
> `architectures/agent-observability` module declaring an OTel-multi-agent
> trace contract via two required-artifact templates, no v1 enforcement — is
> unchanged. Changes: (1) **`type: architecture`** (singular), not `architectures`
> — the family directory is plural, the `type` value is singular (FR-001). (2) The
> module **must declare `stability: beta`** — a required field added *after* this
> PRD was drafted (PRD-0027 / OPP-0050, 2026-06-26); `validate-module-stability.sh`
> now blocks any module without it. `beta` is correct per the rubric (shipped, no
> consumer instance yet). (3) Validator count **8 → 20**. (4) The deferred
> *rationale-expansion* operating-principle promotion targets **§ 13** (next free),
> not § 9 (now "Split Design from Implementation"). (5) FR-012's Mermaid diagram
> stays **Should-Have and is biased to defer** — no new diagram in v1, to avoid the
> diagram-count cascade (consistent with the canonical-position v1). (6) The OTel
> semantic-conventions version pin (FR-003 / Technical Constraints) is **re-verified
> at implementation** against the current published conventions, not assumed from
> the draft's 2026-05-15 example.

## Cross-references

- Related OPP: [OPP-0029](../opportunities/OPP-0029-agent-observability.md) — `exploring`; this PRD is its promotion candidate
- Anchor OPP: [OPP-0027](../opportunities/OPP-0027-frontier-agent-posture.md) — the umbrella that this module is one satellite of
- Sibling satellites: [OPP-0028](../opportunities/OPP-0028-ai-foundry-target.md) (foundries consume the trace shape this module produces), [OPP-0030](../opportunities/OPP-0030-intelligent-model-routing.md) (model-selection spans are part of the trace contract), [OPP-0031](../opportunities/OPP-0031-agent-defense-in-depth.md) (identity-bound traces are the runtime-emitted half of pattern #4)
- Upstream design source: Microsoft + Cisco Outshift [multi-agent OpenTelemetry semantic conventions](https://learn.microsoft.com/en-us/azure/foundry/observability/concepts/trace-agent-concept); [Foundry Observability is GA](https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/generally-available-evaluations-monitoring-and-tracing-in-microsoft-foundry/4502760)
- Field evidence: [Tula README § "Observability and tracing"](https://github.com/unclenate/tula/blob/main/README.md) — *"skills emit OpenTelemetry-shaped traces"*
- Related operating-principles: § 3 (Documentation as Part of the Change), § 7 (Align File Boundaries with Change-Class Boundaries)
- Discipline references:
  - The *deferred-implementations* pattern (PRD-0013's paired observation, 2026-05-25) — v1 ships the contract; v2 enforces it via companion rules
  - The *rationale-expansion-without-rule-change* pattern (PRD-0014 inherits no rule changes — adds a *new* contract surface; the existing kernel doctrine and trust-tier model are unaffected)

## Overview

Agent-native projects need to emit structured trace data with a
*specific shape* that enterprise AI foundries (Microsoft / Azure AI
Foundry, NVIDIA AI Foundry, Palantir AIP), observability backends
(Application Insights, Azure Monitor, Datadog, Honeycomb), and
multi-agent orchestrators consume. The shape is not generic
OpenTelemetry — there is a published, consolidating set of
**multi-agent OpenTelemetry semantic conventions** (Microsoft + Cisco
Outshift) that names the spans, attributes, and events agents emit:
inputs, tool calls, model selections, outputs, latency, cost, eval
outcomes. Auto-harness has no module that captures this surface
today.

PRD-0014 specifies v1 as a new module — `architectures/agent-observability` —
declaring that a project emits OpenTelemetry-shaped traces following the
multi-agent semantic conventions. The module requires two artifacts that
*declare the project's trace contract*:

1. **`docs/observability/trace-contract.md`** — declares which spans /
   attributes / events the project emits per skill or agent action,
   with explicit references to the upstream OTel semantic conventions.
2. **`docs/observability/exporters.md`** — names which exporters the
   project supports (OTLP/HTTP, Azure Monitor, Application Insights,
   generic OTel collector) and whether the export is required or
   optional at each deployment tier.

v1 does *not* ship companion-rule enforcement. The companion-rule
"action-code change requires trace-contract update if a new span shape
is introduced" is **deferred to v2 (follow-up OPP/PRD)**, per the
deferred-implementations discipline named in PRD-0013's paired
observation. v1 establishes the declarative contract; v2 enforces it.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- Ship a new `architectures/agent-observability` module declaring two
  required artifacts that establish the project's trace contract.
- Provide templates for both required artifacts so consumers scaffold
  consistent shapes.
- Reference the Microsoft + Cisco Outshift multi-agent OpenTelemetry
  semantic conventions as the *upstream design source* — pin to a
  specific version of the conventions to avoid silent drift.
- Make the module composable with existing `agents/*` packs without
  requiring any agent pack to declare a dependency on it. (The
  observability module is *opt-in*; an `agents/claude-code` project
  can adopt it or not.)
- Update `harness-onboarding` SKILL so the module is offered during
  onboarding for any project with an `agents/*` pack active.
- Increment the catalog count assertions so the new module + new
  templates are mechanically tracked.

**Non-Goals** — outcomes explicitly out of scope:

- **Implementing the trace-contract-update companion rule.** *(Why
  excluded: per PRD-0013's deferred-implementations discipline. v2 OPP/PRD
  will handle. v1 establishes *what the contract is*; v2 enforces *that
  changes update the contract*.)*
- **Implementing a `validate-trace-contract.sh` validator.** *(Why
  excluded: same deferral. The trace contract is a markdown artifact
  at v1; mechanical validation that the contract matches the emitting
  code is v2+ work.)*
- **Picking a specific OpenTelemetry export backend.** *(Why excluded:
  the exporters template names *which backends are supported*; the
  *specific deployment-target backend* is a consumer-project choice.
  v1 doesn't constrain.)*
- **Generating instrumentation code.** *(Why excluded: code generation is
  a separate concern from contract declaration. The module declares
  the contract; instrumentation is the consumer's responsibility,
  potentially with help from a future code-generator OPP if demand
  surfaces.)*
- **Forcing agents to emit traces.** *(Why excluded: the module is
  opt-in by design. A prototype agent with no observability tooling
  doesn't adopt the module; a frontier-agent-posture project per
  OPP-0027 does.)*
- **Promoting the *rationale-expansion-without-rule-change* discipline
  to a new operating-principle section in this PRD.** *(Why excluded: PRD-0014
  is itself an instance of the discipline applied to a *new* contract
  surface — the discipline is exercised here; promotion to the next free
  section (§ 13; the draft said "§ 9", since taken by "Split Design from
  Implementation") is a separate discipline-codification PR.)*

> Distinction from `Functional Requirements > Out of Scope` below: the
> bullets above are *outcomes* this PRD does not commit to delivering;
> the table below names *specific features* that are explicitly not in
> v1.

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Consumer-project author building an agent-native product | Wants to ship traces that an enterprise foundry will consume | A documented contract surface + a starter template + cross-references to the upstream OTel conventions |
| Harness maintainer | Owns the module catalog + the agent observability module | A coherent v1 that doesn't bundle implementation details with declaration; clean separation of v1 contract vs. v2 enforcement |
| Future-PRD author (the v2 enforcement work) | Drafting `validate-trace-contract.sh` or the companion rule | A clear v1 contract to enforce against; explicit deferral notes naming what v2 owns |
| Agent (Claude Code, OpenClaw) loading workflow docs | Needs to understand what the trace contract requires | A concise module README + the trace-contract template with structured sections |

## User Stories

- As a **consumer-project author**, I want to declare which spans my agent emits in a structured document so the enterprise foundry consuming my traces knows what to expect.
- As the **harness maintainer**, I want the module to ship without companion-rule machinery so I can validate the contract shape against real consumers before locking enforcement.
- As an **agent**, I want a defined contract template structure so I can scaffold a project's trace-contract artifact deterministically from the template.
- As a **foundry-side reviewer evaluating a consumer project**, I want to read one canonical document that names the project's trace shape rather than archaeologically reconstructing it from the emitting code.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | Create `platform/profiles/architectures/agent-observability/module.yaml` | File exists; valid per module schema; declares `id: agent-observability`, `type: architecture` (singular — matches the family convention), `version: 1.0.0`, `stability: beta` (required since PRD-0027 / `validate-module-stability.sh`); depends on `kernel/base`; lists the two required artifacts; no companion rules in v1 | The canonical module declaration |
| FR-002 | Create `platform/profiles/architectures/agent-observability/README.md` as the compiled fragment | File exists; SPDX header; describes the module's role, the upstream OTel multi-agent semantic conventions citation, the two required artifacts, and the deferred-to-v2 enforcement note | Compiled fragment loaded into agent context |
| FR-003 | Create `platform/templates/observability/trace-contract.md` template | File exists; sections for *Spans* (per agent-action), *Attributes* (cross-cutting), *Events* (notable runtime events), *OTel-semantic-conventions version pin*, *Examples* with realistic span shapes; all placeholder tokens (the harness's `[[…]]` convention) are valid per `validate-placeholders.sh` | The trace-contract starter |
| FR-004 | Create `platform/templates/observability/exporters.md` template | File exists; sections for *supported exporters*, *required-vs-optional per deployment tier*, *foundry-side notes* (Azure Monitor / Application Insights / Datadog / Honeycomb / OTLP collector / OpenSearch), *configuration-shape examples* | The exporters starter |
| FR-005 | Update `platform/templates/README.md` directory map | New "Observability" section with the two new templates registered | Closes M-j list-completeness pre-emptively for the new templates |
| FR-006 | Update `SUMMARY.md` Module Library section | New "Architectures > Agent Observability" entry pointing at the module README | Index-completeness |
| FR-007 | Update `docs/README.md` ADR table — no change; just confirm no ADR needed | n/a (ADR not warranted at v1; the new module is opt-in additive) | Documentation discipline; ADR is reserved for substantive design decisions, not module additions |
| FR-008 | Update `platform/skills/harness-onboarding/SKILL.md` architectures-family table | New row: `architectures/agent-observability` with adoption-trigger language and required artifacts cited | The skill needs the new module visible during onboarding |
| FR-009 | Update `platform/skills/harness-governance/SKILL.md` if it references the architectures family | One-line addition if applicable; verify by grep before edit | The governance skill names the module families |
| FR-010 | Bump `validate-catalog-counts.sh` assertion sites: `modules_profiles` (+1), `modules_all` (+1), `templates` (+2) | Every assertion site in the validator's table updated; full sweep across `how-to-read.md`, `diagrams.md`, `cover-back.svg`, and any other documented count claims | Closes the M-j drift class pre-emptively |
| FR-011 | Run `validate-required-artifacts.sh` against the harness's own manifest and confirm green | The new module isn't active in the harness's own manifest yet, but the module-graph still validates; required-artifacts still passes | Self-dogfood |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-012 | Add a Mermaid diagram to `docs/architecture/diagrams.md` showing the trace-flow (agent action → span emission → exporter → backend consumption) | New numbered diagram, follows the pass/fail color convention; one-paragraph caption; cross-reference from the module README | Visual aid; aligns with the Phase 3 ADR-0013 work for visual program |
| FR-013 | Update `harness-onboarding` and `harness-governance` SKILL.md with a one-line reference to the new trace-contract vocabulary | Agents loading the governance skill see the OTel semantic-conventions reference | Aspirational; the SKILLs are heavily used |
| FR-014 | Optional `recommendedSkills` entry on the new module pointing at a `harness-observability` skill (deferred to a follow-up SKILL OPP) | Field present in module.yaml as `[]` at v1; documented as a placeholder for the follow-up skill | The skill itself is v2 work; the field signals intent |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| Companion-rule "action-code change requires trace-contract update" | Per PRD-0013 deferred-implementations discipline | Follow-up OPP/PRD after PRD-0014 lands and at least one consumer adopts |
| `validate-trace-contract.sh` validator (programmatic check the contract matches emitting code) | Same deferral; mechanical validation is v2+ work | After v1 contract stabilizes |
| `harness-observability` SKILL (deeper domain guidance) | Distinct change class; deferred to a follow-up SKILL OPP | After v1 module adoption proves the contract shape |
| Code-generation tools (scaffold instrumentation from the trace contract) | Code-gen is separate from contract declaration | If consumer demand surfaces |
| Specific exporter recommendation (e.g., "use Azure Monitor for Microsoft Foundry projects") | The exporters template names *supported* exporters; *recommendation* is consumer-project decision | If a strong cross-vendor pattern emerges |
| Cost-tracking instrumentation (token cost, latency cost per agent action) | Adjacent concern; distinct contract surface | Follow-up OPP if demand surfaces |

## Technical Constraints

- The module must compose cleanly with all existing `agents/*` packs without modifying any of them. Adoption is opt-in via the consumer's manifest.
- The trace-contract template's OTel-semantic-conventions version pin must be explicit and concrete (e.g., "v1.0 of `trace-agent` conventions per Microsoft + Cisco Outshift, 2026-05-15") rather than left generic. Silent version drift is the failure mode the version pin prevents.
- The exporters template must list at least: OTLP/HTTP (generic), Azure Monitor, Application Insights, Datadog, Honeycomb. The list is open-ended; v1 names the most common to seed consumer projects.
- No `module.yaml` changes to existing modules beyond `harness-onboarding/SKILL.md` and the `harness-governance/SKILL.md` (FR-008 / FR-009).
- All edits are confined to: `platform/profiles/architectures/agent-observability/` (new dir), `platform/templates/observability/` (new dir), `SUMMARY.md`, `docs/README.md`, `platform/templates/README.md`, `platform/skills/harness-onboarding/SKILL.md`, `platform/skills/harness-governance/SKILL.md`, `platform/validators/validate-catalog-counts.sh`, plus the catalog-count assertion sites the validator names.

## CI/CD Gates

| Gate | Required? | Notes |
|------|-----------|-------|
| Lint passes | Yes | markdownlint clean across all new files |
| Validator chain passes | Yes | The full validator chain (20 validators); the catalog-counts bump must be reflected in every assertion site or the validator fails; `validate-module-stability.sh` requires the new module's `stability` field |
| Companion-rule check passes | Yes | Touches OPP-0029 + new PRD file → cycle-end distillation rule fires; satisfier is the paired observation in `shared-observations.md` |
| Change-log updated | Yes | Bundle entry citing PRD-0014, OPP-0029 |
| Module-graph passes | Yes | New module declared properly; depends on kernel/base; no conflicts |

## Success Metrics

| KPI | Target | How measured |
|-----|--------|-------------|
| Trace-contract artifact adoption | ≥1 consumer ships a `trace-contract.md` against v1 within 30 days | Direct observation (Tula is the most likely first adopter) |
| OTel-semantic-conventions version pin | Stable for ≥90 days | The version-pin string in the template is unchanged; if it changes, the change needs documentation |
| Module-graph cleanliness | Zero conflicts with existing `agents/*` packs | `validate-module-graph.sh` green on every PR; tested fixture exists |
| v2 OPP filing trigger | Follow-up OPP for the trace-contract-update companion rule filed within 60 days | The deferred work either graduates or the deferral is re-examined |

## Dependencies

- OPP-0029 must remain at `exploring` until this PRD lands; flips to `accepted` on merge.
- Composes with the OPP-0027 anchor cluster; the other satellites (0028, 0030, 0031) are independent and can land in any order.
- No new validator code at v1; `validate-catalog-counts.sh` gains new assertion sites but no new logic.

## Open Questions

- [ ] **Should the OTel-semantic-conventions version pin live in the module.yaml (machine-readable) or in the template (markdown)?** Bias: markdown at v1 for ease of update; a v2 OPP could move it to a `module.yaml` field if multi-version support becomes load-bearing.
- [ ] **Should the trace-contract template require the consumer to enumerate every span, or just provide structure?** Bias: provide structure with worked examples; require nothing exhaustive. A consumer with 50 skills shouldn't have to write 50 span definitions; the template should let them describe span *classes* if appropriate.
- [ ] **Does the module conflict with anything in the existing `architectures/` family?** Initial review: no — `agent-observability` is orthogonal to `web-app`, `api-service`, `event-driven`, `agentic-ui`, `mcp-server`, `agent-skill-pack`. Verify during implementation.
- [ ] **Should this module declare a `recommendedSkills` entry pointing at a `harness-observability` skill that doesn't exist yet?** Bias: yes, with the skill deferred to a follow-up OPP (FR-014). The module signals intent; the skill follows.
- [ ] **Does Tula need to ship its trace-contract artifact to validate the v1 module?** Bias: no — v1 ships independently. Tula adoption is the *success metric*, not the acceptance criterion.
- [ ] **Should FR-012 (Mermaid trace-flow diagram) be Must Have rather than Should Have?** Bias: keep as Should Have at v1; visual program work is Phase 3 of ADR-0013 and that PR can absorb the diagram if not added here.

## Acceptance Criteria for OPP-0029 → `accepted`

(Mirrors the pattern from PRD-0007 / PRD-0011 / PRD-0013.)

OPP-0029 flips from `exploring` → `accepted` when:

- PRD-0014 Status flips to `Accepted` (this document) *(done — 2026-06-27 finalization)*
- FR-001..FR-011 merged (Must Have)
- The full validator chain (20 validators) green on the implementing PR, including
  `validate-module-stability.sh` (the new module declares `stability: beta`)
- The implementing PR includes a paired observation in `shared-observations.md` confirming the module *exists and is referenced* by the harness's own onboarding skill
- At least one consumer (Tula or any agent-native consumer) demonstrates trace emission against the contract within 30 days of merge (validates the contract is *load-bearing* and not just descriptive prose — if no consumer adopts in 30 days, the contract may be misaligned with field needs and a revision pass is warranted)

FR-012..FR-014 (Should Have) can land in the implementing PR or a follow-up; they are not gates for the `accepted` flip.
