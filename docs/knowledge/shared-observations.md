<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# auto-harness — Shared Observations

**Structure:** Structured Template (see README.md § Observation Structure; locked by ADR-0002)
**Write Policy:** heartbeat-only (see README.md § Write Policy; adjustable)
**Last Updated:** 2026-04-16

Append-only structured observations from project participants (agents
and humans). Read this file on each heartbeat. Observations accumulate
here until distillation.

---

## Observations

### Knowledge-capture module itself is an observation-worthy design

- **Context:** Designing the `management/knowledge-capture` module
  dogfooded in auto-harness itself. The choice of write policy,
  observation structure, and cadences was deliberately made adjustable
  at the project level (rather than hardcoded by the harness).
- **Observation:** Moving configuration out of the manifest schema and
  into the project's own `docs/knowledge/README.md` produced a cleaner
  design than extending the manifest. The policy lives where the data
  lives; git history is the durable configuration trail; no schema
  extension was needed.
- **Implication:** Future harness features that need per-project
  configuration should consider this pattern (config-in-artifact)
  before extending `harness.manifest.yaml`. Not every tunable belongs
  in the manifest.
- **Confidence:** medium — the pattern works for knowledge-capture but
  generalization to other cases is untested
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-04-16

### Two harness genres exist in the AI-coding ecosystem; auto-harness is unambiguously the governance-harness genre

- **Context:** Reviewing adenhq/hive (YC-backed multi-agent runtime harness) to determine whether auto-harness should integrate with, absorb, or remain separate from it. Hive is a runtime-harness (DAG execution, state recovery, MCP tools, dashboard for agents doing business work). auto-harness is a governance-harness (trust tiers, lifecycle gates, PRD/ADR templates governing AI-assisted human coding work).
- **Observation:** The word "harness" is doing double duty in this space: runtime-harness (Hive, LangGraph, CrewAI) is not the same as governance-harness (auto-harness). Both genres exist; both call themselves "harness." Hive's "evolve graph on failure" loop is exactly the kind of self-modifying agent behavior that benefits from human-approval gates and audit trails — the governance primitives auto-harness already encodes (trust tiers, lifecycle stages, companion rules, validators).
- **Implication:** auto-harness should not absorb Hive (different layer, scope bloat, license/cadence coupling) and should not integrate tightly (couples to one runtime's product direction). The latent product opportunity is to define an exportable governance contract — a consumable schema, skill, or protocol that any runtime harness (Hive, LangGraph, CrewAI, custom) can adopt to gate state transitions and self-modifications on human approval, with audit trails compatible with auto-harness's lifecycle artifacts. This keeps auto-harness composable with the runtime ecosystem rather than betting on one runtime. Filed as OPP-0001.
- **Confidence:** medium — the genre distinction is high-confidence; the "exportable contract" opportunity is medium-confidence and warrants validation by reading Hive's actual state-machine and self-modification entry points before committing.
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-12
