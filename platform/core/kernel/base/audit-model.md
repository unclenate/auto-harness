<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Audit Model

Auditability comes from explicit records and predictable control points. The
audit model defines what *counts as evidence* when reconstructing why a
project is in its current state — what's authoritative, what's
illustrative-only, and what surfaces must be present for the reconstruction
to be possible at all.

The model is load-bearing because the harness assumes *post-hoc
reconstruction*: at any point in a project's life, a contributor (human or
agent) should be able to walk back through the audit surfaces and answer
"why is this code shaped this way?" without depending on the original
author's memory.

## Required Audit Surfaces

Every harnessed project ships these surfaces, and every project decision
should be reconstructable by reading them together:

**Manifest declaring active modules** (`harness.manifest.yaml`). The
manifest is the *what's governed how* surface — which modules apply,
which validators run, which review gates fire. If the manifest changes,
the governance contract changed; the change-log entry that accompanies
the manifest edit is the "why" record.

**Module metadata declaring validators and review gates**
(`platform/profiles/**/module.yaml`, `platform/core/kernel/base/module.yaml`).
This is the *what the harness checks and demands* surface. A reviewer
answering "did this PR follow the rules?" reads the active modules'
metadata to answer "what were the rules?"

**Project-facing canonical records** (`docs/` artifacts: ADRs, PRDs,
change-log, knowledge observations, opportunity records). These are the
*what was decided, by whom, when* surface. The harness deliberately
keeps the canonical-records set small and stable; a project's actual
state should be reconstructable from these, not from arbitrary
unstructured notes.

**CI or local validation results.** The validator chain's exit codes
are the *was the contract satisfied?* surface. A green run is a
verifiable claim that, at the time of the run, every active module's
required artifacts existed, placeholders were resolved, doc references
were live, and companion rules fired their required satisfiers. CI logs
are the timestamped version of this.

**Version control history and review discussions** (git log, PR
review threads). The *who saw what, when* surface. The harness's
canonical-records discipline produces *summary* records of decisions;
git history and PR threads are the *substantive* record of how those
decisions were made.

Together these surfaces let any future contributor reconstruct: what
the project committed to (manifest + modules), what discipline the
harness enforced (validators), what decisions humans made (canonical
records), and what conversation produced those decisions (history +
threads). The five-surface set is intentionally small; growing it
should require an ADR.

## Non-Goals

The audit model *deliberately does not* treat these as canonical:

**Command logs are helpful but not canonical.** A bash session
transcript or an agent's tool-use trace is *evidence of action*, but
not *evidence of decision*. The decision is captured in the canonical
record the action produces (the commit, the ADR, the change-log entry).
Treating session logs as canonical creates a perverse incentive: detail
in the log substitutes for substance in the record, and the record
degrades.

**Generated summaries do not replace approvals.** An agent's
end-of-session summary, however well-structured, is *the agent's*
account of what happened. It can be a useful starting point for a
canonical record but is not itself one — the canonical-record format
(ADR, PRD, change-log row) requires human shaping and approval to
become authoritative. Auto-generated text that bypasses this is the
audit-trail equivalent of a rubber-stamp review.

**Validator success does not certify production readiness on its
own.** Green CI says the *governance contract* is satisfied — every
required artifact exists, every companion rule fired its satisfier,
every placeholder is resolved. It does not say the *product* is
ready: that the tests cover the right cases, that the security model
holds under adversarial input, that the deployment will survive its
first thousand users. The validators verify the discipline; the
product readiness is a separate, project-specific evaluation that
sits on top of the green validator baseline.

The pattern: the audit model captures *the discipline*; the canonical
records capture *the decisions*; product readiness is what the team
proves on top of both, not what either layer claims on its own.

## Related

- [Doctrine](doctrine.md) — the principles the audit model
  operationalizes (especially "Review is a knowledge-distribution
  mechanism" and "Documentation is part of the change")
- [Enforcement Model](enforcement-model.md) — how the harness enforces
  the audit-surface contracts in practice
- [Canonical Records](canonical-records.md) — the specific canonical
  record types and what makes each authoritative
- [Trust Model](trust-model.md) — at tier 4 and 5, the audit-trail
  floor is what makes recoverable mistakes possible
