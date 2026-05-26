<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Kernel Doctrine

The kernel defines rules that are durable across stacks, domains, and
delivery models. These are the principles the harness applies universally —
they are not negotiable per project, and they are what makes "this is a
harnessed project" mean anything.

## Principles

**Ownership is explicit.** Every module, validator, template, and workflow
document has a named owner. The harness is opinionated about this because
*unnamed ownership* is the dominant failure mode of long-lived projects:
nobody is responsible for the bit-rot, the security pin updates, the doc
that hasn't been current in two years. Naming the owner doesn't guarantee
the work happens, but unnamed ownership guarantees it doesn't.

**Review is a knowledge-distribution mechanism, not a rubber stamp.** A PR
review where the reviewer learns nothing wasn't a review — it was a queue
ceremony. The harness's companion rules and review gates exist to make
review *load-bearing*: every triggered rule forces a paired artifact (a
change-log entry, a memory note, an observation) that documents what was
reviewed and why. Review without knowledge distribution leaves the team
without the context to maintain what they shipped.

**Documentation is part of the change, not follow-up work.** A change that
doesn't update the docs that explain it is incomplete, regardless of how
well the code works. The companion-rule machinery encodes this directly:
edits to product-requirements artifacts demand change-log entries; edits
to a module's contract demand updates to the catalog tables that
reference it. The harness deliberately makes "ship now, document later"
the *uncommon* path — it can be done with `overrides.disabledValidations`
but the deliberate cost reminds the author that the deferred work is
real.

**Secrets never belong in tracked artifacts.** Even in test fixtures.
Even in commented-out examples. Even with a `# TODO: remove before merge`
adjacent. Once a secret enters git history, the operational cost of
removing it is high (rewrite history, force-push, invalidate every
clone) and the recovery is incomplete (any cache, fork, or local copy
made before the rewrite still has the secret). The honor-code floor is
this principle; the validators back it up with placeholder scanning and
sensitive-path companion rules.

**Migrations, releases, and incident response are operational events.**
Not coding tasks. Each has its own pre-flight, sign-off, and post-event
documentation contract — captured in `release-and-versioning.md`,
`modify-composition-mid-project.md`, and `incident-response.md`. Treating
these as ordinary commits dispenses with the witness signals that make
them recoverable when something goes wrong.

**AI acceleration increases the need for controls, not the license to
skip them.** The harness exists specifically because AI-assisted
development moves faster than the discipline that traditionally accumulated
around code changes. The acceleration is real and valuable — but the
controls (review gates, companion rules, audit-trail floors) are how the
acceleration stays *safe*. The temptation to skip them because "the
agent already verified it" is the failure mode the harness most directly
prevents.

## Boundaries

The kernel deliberately *does not* define:

- **Language or framework commands.** `npm run build` vs `pytest` vs
  `cargo test` — these belong in `stacks/` overlays. The kernel doesn't
  know what language your project uses, and shouldn't need to.
- **Path assumptions for application code.** Where `src/` lives, whether
  `tests/` is co-located or top-level, what `assets/` contains — these
  are stack and architecture concerns. The kernel governs *the
  governance surface*, not the codebase shape.
- **Vendor-specific service layouts.** Supabase, AWS, Azure, GCP — these
  are `domains/` overlays. The kernel doesn't know which vendor, and
  governance shouldn't change based on which one you picked.
- **Environment topology beyond the requirement to document and govern
  it.** The kernel doesn't say "you must have three environments" or
  "production must be on Kubernetes" — those are `delivery/` overlays.
  The kernel says only that *whatever your topology is*, it must be
  documented and governed.

The pattern: the kernel handles *what's true regardless of project
shape*, and overlays handle *what's specific to project shape*. The
moment the kernel starts encoding stack-specific or domain-specific
assumptions, it stops being universal — which is the property that
makes "this is a harnessed project" a meaningful claim. The boundary is
load-bearing.

## Related

- [Trust Model](trust-model.md) — the agent-action escalation contract
- [Enforcement Model](enforcement-model.md) — how the harness enforces
  contracts in practice
- [Audit Model](audit-model.md) — the audit-trail floor that makes
  post-hoc review possible
- [Lifecycle Controls](lifecycle-controls.md) — Bootstrap Complete,
  Harness Ready, and the lifecycle transitions
- [Operating Principles](../../../../docs/operating-principles.md) —
  how the harness platform itself is built and evolved (project-level
  truths derived from this kernel doctrine)
