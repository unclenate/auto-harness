<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# auto-harness — Opportunity Candidates Index

**Owner:** @unclenate | **Last Updated:** 2026-05-22

Organizational index of opportunity candidates filed in this directory. The
canonical record for each candidate is its own `OPP-NNNN-slug.md` file —
this index exists only to group, cluster, or annotate them for human readers.

> **Scope of this file.** This file is *organizational*, not *structural*.
> Editing this file does **not** require an ADR — the companion-rule floor on
> `README.md` applies only to policy changes. Add, rename, or remove cluster
> headings freely as the candidate set evolves. The audit-trail floor on
> individual `OPP-NNNN-*.md` files still applies. See ADR-0012 for the
> structural-vs-organizational split rationale.

---

## Index of Current Candidates

### Exportable governance & ecosystem interop

- [OPP-0001](OPP-0001-exportable-governance-contract-for-runtime-harnesses.md) —
  Define an exportable governance contract any AI-agent runtime harness (Hive,
  LangGraph, CrewAI) can adopt to gate state transitions on human approval,
  with audit trails compatible with auto-harness's lifecycle artifacts.
- [OPP-0003](OPP-0003-mcp-producer-and-exportable-governance-via-mcp.md) —
  Teach auto-harness to govern three MCP modes (consumer, producer, and
  exportable-governance-via-MCP) as first-class shapes, making the governance
  contract from OPP-0001 reachable through the protocol layer.

### In-product agent surfaces

- [OPP-0002](OPP-0002-agentic-interface-awareness.md) — Teach the auto-harness
  to recognize agentic interfaces (CopilotKit-style copilots, A2UI generative
  UI, conversational-primary products) as a governable shape, so consumer
  projects ship modern AI surfaces without inventing their own
  prompt-injection / action-approval / agent-attribution governance.

### Knowledge distillation & self-improvement loop

- [OPP-0004](OPP-0004-distillation-triggers.md) *(accepted 2026-05-22;
  PRD-0004 v1 fully shipped — passive companion rule + workflow doc +
  Claude Code Stop-hook adapter)* — Close the cycle-end distillation
  gap: the harness provides destinations (observations, learnings,
  operating-principles) but no triggers to reliably cause distillation
  to happen during or after work cycles. v1 ships both the PR-boundary
  floor (companion rule) and the in-session reminder (hook adapter).
  Same-day proposed → exploring → accepted trajectory driven by
  maintainer priority signal.

### Consumer onboarding & project hygiene

- [OPP-0006](OPP-0006-trust-tier-enforcement.md) *(exploring;
  PRD-0006 in flight, drafted 2026-05-23)* — Make the kernel-doctrine
  trust tier model machine-checkable. Six tiers are referenced
  everywhere (every agent pack, PR template, operating-principles)
  but zero machinery enforces them. The harness's most-cited safety
  guarantee runs on honor code. Initial bias: optional `tier` schema
  field on `module.yaml`, production-shape `sensitivePaths` inference,
  new `validate-trust-tier.sh` validator, and dogfood declarations on
  auto-harness's own modules. Closes the highest-priority gap from the
  2026-05-23 audit; named explicitly in the
  "doctrine-without-enforcement" architectural observation.

- [OPP-0005](OPP-0005-consumer-header-hygiene.md) *(accepted 2026-05-22;
  PRD-0005 v1 fully shipped — templates tokenized + bootstrap helper +
  sample-project markers + attribution drift fixed)* — Stop template
  SPDX/copyright headers from
  propagating to consumer files. 61 template files + every
  sample-project file currently ship with literal
  `Copyright 2026 Nate DiNiro <UncleNate@gmail.com>` headers, so
  consumers who scaffold their own ADR/PRD/observation from templates
  end up with files attributed to UncleNate under MIT/Apache regardless
  of their own license intent. Initial bias: tokenize template headers
  so the existing `validate-placeholders.sh` machinery gates new files,
  plus a small bootstrap helper that fills tokens project-wide. Real
  legal correctness issue, not cosmetic.

### Canonical direction & strategic alignment

- [OPP-0007](OPP-0007-canonical-position-artifact.md) *(exploring;
  PRD-0007 in flight, drafted 2026-05-24; renumbered from OPP-0006
  after the trust-tier-enforcement OPP took that slot)* —
  Introduce a canonical-position artifact as a first-class harness
  primitive. Every other strategy / product / GTM / partnership artifact
  cites it and cannot contradict it. Anchors four sibling observations
  filed in the same session (validator opt-out staleness;
  opportunity-capture backlog re-audit on canonical change; formal
  review/reconciliation artifact type; intake-vs-canonical-direction
  staleness). Identified as the highest-leverage single gap in the
  harness's artifact catalog by the four-lens project alignment audit
  (MB-REV-003) of `bdits/municipal-brain`.

---

## References

- Policy: `README.md` (this directory)
- Per-candidate template: `platform/templates/opportunity/opp-template.md`
- Module definition: `platform/profiles/management/opportunity-capture/module.yaml`
- Split rationale: `docs/adr/ADR-0012-opportunity-capture-index-split.md`
