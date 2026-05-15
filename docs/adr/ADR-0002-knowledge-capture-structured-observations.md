<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0002: Knowledge Capture — Observation Structure Choice

**Status:** Accepted
**Date:** 2026-04-16
**Author:** @unclenate
**Reviewers:** @unclenate
**Context source:** Design session on cross-agent shared knowledge surface (Gap 2 in the knowledge-flow architecture); companion to the auto-harness adoption of `management/knowledge-capture` module.

## Context

The auto-harness framework now captures institutional knowledge from
agents (JP, Bernays) and humans through the `management/knowledge-capture`
module. That module requires each adopting project to make one foundational
governance choice that cannot be changed without a subsequent ADR: the
structure of entries in `docs/knowledge/shared-observations.md`.

Three options were considered:

1. **Freeform prose.** Low write-friction, hard to synthesize, weak signal
   when distilling.
2. **Structured template.** Required fields (Context, Observation,
   Implication, Confidence, Severity, Contributor). Medium write-friction,
   strong support for downstream distillation and severity-driven companion
   rule escalation.
3. **Severity-prefixed findings.** Full format parity with the revision
   tracker (O-1, O-2...). Highest write-friction, most bureaucratic, risks
   conflating "observations" (signals that may or may not matter yet) with
   "findings" (specific tracked issues).

The choice shapes every downstream step: how agents contribute, how
distillation drafts are produced, how companion rule escalation applies.

## Decision

**Observation entries in auto-harness adopt the Structured Template.**

Each entry MUST include these fields:

- `Context:` What situation or project activity prompted this observation?
- `Observation:` What was noticed? Specific and factual.
- `Implication:` What does this suggest for the project, team, or harness?
- `Confidence:` `low`, `medium`, or `high`
- `Severity:` `informational`, `governance-relevant`, `architectural`, or `risk-bearing`
- `Contributed by:` agent name or @handle, plus the date in ISO format

Freeform prose is rejected: it defeats the synthesis purpose. Severity-prefixed
findings are rejected: they collapse the useful distinction between a
working-signal observation and a tracked finding in the revision tracker.

## Consequences

### Positive

- Forces the useful thinking: what was noticed vs what it implies vs how
  confident the contributor is
- Implication + Confidence together drive the escalation table
  (governance-relevant → revision tracker; architectural → ADR;
  risk-bearing → risk register)
- Distillation into `distilled-learnings.md` can operate on structured
  fields rather than prose parsing
- Separates observation (signal) from finding (tracked issue), preserving
  both concepts rather than collapsing them

### Negative

- Higher write-friction than freeform — agents and humans must think in
  four dimensions rather than just writing what they noticed
- A poorly-written observation under the structure (vague Implication,
  unjustified Confidence) can look rigorous when it isn't

### Watch

- If observation volume drops noticeably after adoption, the structure
  may be over-friction — revisit the write policy or consider a lighter
  variant for informational-severity entries
- If distillation quality doesn't improve over freeform-era notes from
  similar projects, the structure isn't earning its keep

## Alternatives Considered

### Freeform prose

- Description: Each observation is a timestamped paragraph with
  contributor name; no required fields.
- Why rejected: The whole purpose of the shared-observations surface is
  to accumulate signal that can be distilled. Freeform prose forces the
  distillation step to do prose parsing first, which degrades the
  signal-to-noise ratio at every downstream stage.

### Severity-prefixed findings

- Description: Each observation is an O-N entry with severity prefix
  (C-1, H-1, M-1, L-1), status (Open / Acknowledged / Distilled /
  Superseded), format-identical to revision tracker findings.
- Why rejected: Conflates observation (a signal that may or may not
  become a finding) with finding (a tracked issue in the revision
  tracker). Also bureaucratically heavy — agents would be reluctant to
  contribute minor signals if every entry needed a severity decision
  and lifecycle status. The distinction between observation and finding
  is the source of the value: observations are the raw material from
  which findings, ADRs, risk entries, and backlog items are distilled.
