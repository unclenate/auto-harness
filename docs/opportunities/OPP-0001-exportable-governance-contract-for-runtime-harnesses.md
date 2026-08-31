<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0001 — Exportable Governance Contract for Runtime Harnesses

**Status:** exploring
**Owner:** @unclenate
**Created:** 2026-05-12
**Last Updated:** 2026-08-31
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

**Exploring (2026-08-31).** This OPP sat in the strategic backlog "awaiting framing"; an external
development supplied both the framing and a clock. Kang & Diponegoro, "Governance Gaps in Agent
Interoperability Protocols" (arXiv 2606.31498, Jun 2026), argues governance is a missing architectural
**Layer 4** *above* coordination — the interop protocols (A2A, MCP, IBM's Agent Communication Protocol)
transport governance messages but cannot interpret/validate/enforce them — and estimates the gap will be
standardized "particularly via A2A's extension mechanism" within 6–12 months, with no one having done so
yet. Auto-harness already *is* a Layer-4 implementation (see `docs/knowledge/shared-observations.md`, the
Layer-4 observation), which reframes OPP-0001 concretely: package the control-loop message envelope +
trust-tier escalation + (via OPP-0057/PRD-0040) tamper-evident audit as a candidate **cross-vendor
governance extension**, neutral above A2A and MCP by construction — the cleanest anti-vendor-bias move,
since A2A is Google/Linux-Foundation lineage and MCP is Anthropic lineage.

**First deliverable (cheap, clarifying regardless of standardization):** the G1–G6 mapping of the
harness's governance primitives → [`docs/architecture/governance-layer-mapping.md`](../architecture/governance-layer-mapping.md).
It names exactly what the harness would propose as neutral (envelope + escalation + audit shapes) vs. keep
proprietary (the trust-tier policy). **Next:** register interest with the A2A extensions process and
watch for governance-extension activity (the doc-watch entry for arXiv 2606.31498) — do not rush a
half-formed proposal to a standards body; the window is the paper's estimate, and the mapping clarifies
the contribution either way. (Acronym note: the paper's "ACP" is IBM's Agent *Communication* Protocol,
not the harness's `agents/acp` Agent *Client* Protocol.)

## Promotion

<!-- Empty: not yet accepted -->
