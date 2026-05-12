# ADR-0004: Opportunity Capture — Record Structure Choice

**Status:** Proposed
**Date:** 2026-05-12
**Author:** @unclenate
**Reviewers:** @unclenate
**Context source:** Design session on closing the gap between forward-looking ideas and backward-looking observations; companion to PRD-0003 (Opportunity Capture module).

## Context

PRD-0003 introduces a new module, `management/opportunity-capture`, that adds a per-project surface (`docs/opportunities/`) for pre-PRD candidate records. Following the precedent established by ADR-0002 for `knowledge-capture`, the module requires each adopting project to make one foundational governance choice that cannot be changed without a subsequent ADR: the structure of per-candidate records in `docs/opportunities/OPP-NNNN-slug.md`.

The choice matters because the record structure shapes every downstream behavior: which companion rules can be encoded as path patterns, how reviewers verify "accepted means PRD-spawned," whether the evidence link to `docs/knowledge/shared-observations.md` is durable, and how an accepted candidate's `Promotion` field connects to the PRD.

Three options were considered:

1. **Minimal record.** Just `Title`, `Status`, and a free-form body. Lowest write-friction, but reviewers and tooling have no anchored fields to verify against — the "PRD spawned on accept" contract becomes hard to enforce because there's no required Promotion slot.
2. **Structured record (proposed).** Fixed metadata block (Status, Owner, Created, Last Updated, Confidence) plus six required sections (Thesis, Origin / Evidence, Why Now, Risks / Open Questions, Disposition, Promotion). Mirrors the structured approach taken by ADR-0002 for observations. Medium write-friction, strong support for path-pattern companion rules and reviewer verification.
3. **Pre-PRD-shaped record.** The candidate file is itself a stripped-down PRD template — same section names (Goals, Functional Requirements, Open Questions), filled at a lower fidelity. Single mental model with PRDs; trivial promotion-by-rename. Heaviest write-friction; loses the distinction between "candidate under consideration" and "committed product requirement."

## Decision

**Opportunity records in auto-harness adopt the Structured Record.**

Each `OPP-NNNN-slug.md` file MUST include the following metadata fields in a header block:

- `Status:` one of `proposed | exploring | accepted | declined | superseded`
- `Owner:` `@handle` of the person accountable for moving the candidate through its lifecycle
- `Created:` ISO date the candidate was first filed
- `Last Updated:` ISO date of the most recent edit
- `Confidence:` `low | medium | high`

And the following required sections:

- `## Thesis` — One to three sentences: what the opportunity is, in plain language.
- `## Origin / Evidence` — Links to observations in `docs/knowledge/shared-observations.md`, external signals, or an explicit `thesis-only` marker with stated reason. This is the gap-closer: explicit forward-to-backward linkage when grounded.
- `## Why Now` — Timing signal (or `n/a`).
- `## Risks / Open Questions` — What would have to be true; what could kill it.
- `## Disposition` — Empty while `Status: proposed`; populated when status flips to `exploring | accepted | declined | superseded`, capturing rationale and any pointer (e.g., to the spawned PRD or the superseding OPP).
- `## Promotion` — Empty until `accepted`; then a link to `PRD-NNNN`.

Minimal records are rejected: the "accepted means PRD-spawned" contract requires anchored fields for path-pattern enforcement, and freeform bodies degrade reviewer verification.

Pre-PRD-shaped records are rejected: collapsing the OPP shape into a PRD shape loses the useful distinction between candidate (open question, may be killed) and PRD (committed direction). It also forces premature filling of PRD-style detail (Functional Requirements, Acceptance Criteria) on candidates that should be allowed to live at a thesis level.

## Consequences

### Positive

- The required metadata block (Status, Confidence, dates) supports path-pattern companion rules — the `validate-companions` validator can enforce "new OPP file → audit-trail entry" and "status changes → Disposition populated" by file-presence and edit-presence checks alone, with no new validator code.
- The `Origin / Evidence` field makes the gap-closing explicit and inspectable: a reviewer can verify at a glance whether a candidate cites real observations or is marked `thesis-only` with stated reason.
- The `Promotion` field gives reviewers a concrete artifact to check when status changes to `accepted` — there is a binding contract, not a status string.
- Separating candidate (this file) from PRD (the spawned artifact) preserves the historical record: "this was once a candidate," with its original Thesis and Disposition, persists even after the PRD takes over.

### Negative

- Higher write-friction than a minimal record — agents and humans must fill metadata and at least the Thesis and Origin / Evidence sections to land a candidate.
- The structure does not validate content quality. A `thesis-only` marker without a real reason, or a vague `Disposition` rationale, can pass the path-pattern companion check while being substantively weak. Content quality remains a human review gate.
- The `Origin / Evidence` field requires per-link maintenance: if the underlying observation in `shared-observations.md` is later distilled or restructured, the OPP's reference may become stale. (Observations are append-only by ADR-0002, so the reference doesn't break — but the anchor target may shift if the file is reorganized.)

### Watch

- If candidate volume drops noticeably after adoption, the structure may be over-friction — revisit the Write Policy first (autonomous vs. heartbeat-only vs. draft-to-promote), and only revisit the record structure if Write Policy adjustments don't recover signal.
- If the `thesis-only` marker is used for the majority of candidates, the gap-closing benefit isn't being realized in practice — investigate whether the Observation Write Policy is producing too few observations to ground forward-looking ideas against, or whether the contributors are skipping the link rather than reaching for it.
- If reviewers find the `Promotion` field's path-pattern companion rule too loose (false-positives when an unrelated PRD is touched in the same commit), tighten the rule by requiring a literal back-link from the OPP to the PRD number, verified by a content grep in a new validator.

## Alternatives Considered

### Minimal record

- Description: Each candidate file contains only `Title`, `Status`, and a free-form body. No structured metadata, no fixed sections.
- Why rejected: The "accepted → PRD spawned" companion rule depends on stable, path-detectable structure. With a free-form body, the validator has no anchor for "Disposition is populated" or "Promotion points to a real PRD"; reviewer verification becomes ad-hoc and inconsistent. The lower write-friction is not worth losing the contract.

### Pre-PRD-shaped record

- Description: Each candidate file uses the PRD template at lower fidelity (Goals, Functional Requirements, Acceptance Criteria filled lightly). Promotion is a rename rather than spawning a new file.
- Why rejected: Collapses the useful distinction between candidate (under consideration; may be killed; thesis-level) and PRD (committed direction; functional requirements; acceptance criteria). Also creates a single-file evolution path where the "candidate phase" is overwritten when the file becomes a PRD — the historical record of why the candidate was considered, the Disposition, the rejected alternatives — is lost except in git log. Two records preserves more durable institutional knowledge than one mutating record.
