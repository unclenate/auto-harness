<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0001 — Exportable Governance Contract for Runtime Harnesses

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-12
**Last Updated:** 2026-05-12
**Confidence:** medium

---

## Thesis

Define an exportable governance contract — a consumable schema, skill, or protocol — that any AI-agent runtime harness (Hive, LangGraph, CrewAI, custom) can adopt to gate state transitions and self-modifications on human approval, with audit trails compatible with auto-harness's lifecycle artifacts. The contract is auto-harness-flavored governance, decoupled from auto-harness's specific module surface, so the runtime ecosystem can compose with it rather than choosing between integrating tightly or building parallel governance.

## Origin / Evidence

- **Observation:** `docs/knowledge/shared-observations.md` — "Two harness genres exist in the AI-coding ecosystem; auto-harness is unambiguously the governance-harness genre" (architectural severity, 2026-05-12)
- **External signal:** adenhq/hive README and architecture description (Y Combinator-backed multi-agent runtime harness; "evolve graph on failure" is a self-modifying agent behavior that explicitly lacks human-approval gating in the current product surface)
- **Internal precedent:** auto-harness already encodes trust tiers, lifecycle stages, companion rules, and validators. Those primitives are repo-internal; nothing currently makes them consumable by an external runtime.

## Why Now

The runtime-harness category is consolidating around production AI workloads (Hive, LangGraph, CrewAI all currently scaling). They are all introducing self-modification behaviors (graph evolution, self-healing, autonomous task generation) without standard governance contracts. Defining the contract now lets auto-harness occupy the governance-layer position before runtime harnesses build proprietary equivalents or before "governance" becomes a feature of each runtime rather than a portable contract.

## Risks / Open Questions

- Is the contract substantial enough to be valuable, or thin enough that runtime harnesses just inline equivalent checks? Validation requires reading Hive's actual state-machine and self-modification entry points before committing to the contract shape.
- Does the contract need to be enforceable (cryptographic, MCP-shaped tool gating) or is it sufficient for it to be declarative (a YAML/JSON schema that runtime harnesses voluntarily comply with)? Two very different scopes.
- Adoption is the gating question. Even if the contract is well-designed, a contract no runtime harness adopts is dead. Initial validation should test with one runtime harness (likely Hive given its observability and self-modification behaviors) before generalizing.
- Auto-harness's existing module/manifest/validator surface is markdown-and-YAML-heavy. A "consumable contract" for runtime harnesses likely needs a different shape (programmatic API, MCP tools, protocol spec) than auto-harness currently produces. Building the contract may require expanding auto-harness's technical surface area, with its own scope tradeoffs.

## Disposition

<!-- Empty: status is proposed -->

## Promotion

<!-- Empty: not yet accepted -->
