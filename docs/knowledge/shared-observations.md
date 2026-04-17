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
