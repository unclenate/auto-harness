# auto-harness — Shared Observations

**Structure:** Structured Template (see README.md § Observation Structure; locked by ADR-0002)
**Write Policy:** heartbeat-only (see README.md § Write Policy; adjustable)
**Last Updated:** 2026-05-20

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

### Companion-rule precision is best enforced by file boundaries, not regex sophistication

- **Context:** Issue #28 surfaced a class of companion-rule false-positive: the
  `management/opportunity-capture` README rule fired on any
  `docs/opportunities/README.md` edit, even pure organizational
  (cluster-heading / `OPP-NNNN` line-item) changes. Three upstream
  resolutions were considered: (a) section-aware triggers (heading-scoped
  regex inside the file), (b) `acceptedAlternative` field for project-local
  ratifying ADRs, (c) file split — move the candidate index to a sibling
  `docs/opportunities/candidates.md` and scope the rule to README only.
- **Observation:** Option (c) won by aligning the file boundary with the
  change-class boundary the rule wanted. The other options either added
  regex complexity that generalizes nowhere (a) or codified perpetual
  exemption as a first-class governance primitive (b). After the split, no
  validator-engine change was needed — the regex layer continued to work
  as designed because the artifact it gated now only contains the change
  class it cares about.
- **Implication:** When a companion rule needs more precision, prefer
  reshaping artifacts so file boundaries match change-class boundaries
  over teaching the validator about substructure. The companion-rule
  machinery's value is the simplicity of regex-over-paths; preserving that
  simplicity scales better than per-rule renderer-aware diff parsing. If a
  regex can't separate two change classes within one file, that's a signal
  the artifact is doing too much, not that the validator needs more brains.
- **Confidence:** medium — one decision, but the rejected alternatives
  were both seriously considered and the file-split rationale generalizes
  to similar precision problems
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-20

### Consumer-driven feedback has displaced the scheduled-review cadence as the active quality mechanism

- **Context:** Two consumer-filed issues in three days followed an identical
  shape: #24 (stale validator CLI signatures in `harness-governance` skill,
  surfaced in `bdits/municipal-brain` after PRs #15/#22 changed validator
  surface) and #28 (companion-rule false-positive on README index edits,
  also surfaced in `bdits/municipal-brain`). Both issues were filed with
  precise reproduction steps, a local workaround already in place, and 2–3
  proposed upstream resolutions with explicit tradeoffs. Both were
  merged within hours. Meanwhile, the scheduled-review cadence declared
  in `docs/knowledge/distilled-learnings.md` (set 2026-04-16, target
  2026-04-30) never fired — five weeks past, no team review held; the
  honest staleness sits in the file as governance debt.
- **Observation:** The dogfooding loop — consumer hits friction → files
  issue with proposed fix → upstream tightens module + docs within hours —
  is producing higher-signal learning than the scheduled-review pattern
  the knowledge-capture module assumes. Consumer-discovered issues are
  about *live friction* with real user models; scheduled-review distillation
  is about *latent drift*. For a solo-maintained framework with active
  consumers, the consumer loop appears to be the dominant quality engine.
- **Implication:** Two possible directions worth weighing: (a) retire the
  scheduled-review cadence in favor of an event-driven distillation
  pattern (e.g., distill after every consumer-issue closure once a
  threshold of N is reached); (b) keep the cadence but hold the review
  even when the docket feels thin — the discipline of distilling is more
  valuable than the size of any particular batch. Either is a deliberate
  choice; the current state (declared cadence quietly going untriggered)
  is the worst option because it makes the docs lie about how this
  project actually learns.
- **Confidence:** medium — two consumer-issue data points fit the
  pattern, but generalization to N>1 consumers is untested. The cadence-
  vs-event-driven choice is genuinely open.
- **Severity:** process
- **Contributed by:** @unclenate via Claude Code, 2026-05-20
