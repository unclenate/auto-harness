<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0038 — Adopter Artifact Attribution: Signing Governance Without Asserting Rights

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-06-02
**Last Updated:** 2026-06-02
**Confidence:** medium

---

## Thesis

When a brownfield adopter instruments a *host project they do not own* with the
harness, they author new governance artifacts — ADRs, the manifest,
operating-principles, product docs — that carry attribution fields (`Owner:`,
`Deciders:`, `Author:`) and copyright headers. **The harness provides no
convention for how an adopter should sign those artifacts.** Absent guidance, an
adopter can unintentionally:

1. **Assert false affiliation** — badge themselves with the host project's
   organization identity (e.g. `Owner: @adopter (HostOrg)`), implying they
   speak for or belong to the original owner;
2. **Overclaim ownership** — stamp `Owner:` over governance in a repository
   whose code, identity, and trademarks belong to someone else;
3. **Under-retain authorship** — conversely, erase their legitimate authorship
   of artifacts they genuinely created, out of caution.

The harness should define an **attribution convention** — and possibly a
validator — that lets an adopter *retain authorship of what they wrote* while
*never asserting rights, affiliation, or ownership over the host project's
identity, code, or trademarks*. The boundary between "artifacts the adopter
created" and "the host project's original IP" is cleanly computable
(`git log --diff-filter=A` first-add authorship), which makes a tooling-assisted
convention feasible, not merely advisory.

## Origin / Evidence

- **Concrete incident.** During a second-pass onboarding of a fork-held external
  consumer (a fork held by the harness maintainer, instrumented specifically to
  explore whether the resulting governance would be of interest to the upstream
  owner), the intake artifacts were stamped `**Owner:** @adopter (HostOrg)` /
  `**Deciders:** @adopter (HostOrg)` across nine files. `HostOrg` is the
  *original* project's company and the holder of the project's trademarks — not
  the adopter. The parenthetical silently asserted affiliation with, and rights
  under, the original owner. It was caught by the human maintainer, not by any
  validator, and corrected in the consumer repo (`@adopter (HostOrg)` →
  `@adopter`).
- **The boundary was computable.** `git log --diff-filter=A` cleanly partitioned
  the repository: the nine mis-stamped files were all first-added by the adopter
  at intake; every file carrying *legitimate* host-org references (README,
  OPEN_CORE, TRADEMARK, articles, app READMEs — correct trademark statements of
  the owner's actual rights) was first-added by the original maintainer. The
  adopter-artifact vs. original-IP split is not a judgment call; it is in the
  git history.
- **De-identified observation:** see
  [`docs/knowledge/shared-observations.md`](../knowledge/shared-observations.md)
  → *"The adopter-artifact / host-IP attribution boundary is computable from
  git first-authorship"*.

## Why Now

- Brownfield onboarding is repeatedly identified in this catalog as the harness's
  highest-leverage growth and discovery vector — and adopters are very often
  **forks held by someone other than the project's legal owner** (the existing
  brownfield consumers in `candidates.md` — YouBase, OpenEMR, Tula — were all
  maintainer-held forks of projects owned by others).
- Every such adoption hits this boundary **on its first governance commit**, when
  the intake artifacts are authored. The mistake is silent (it passes every
  current validator) and is only caught by an attentive human.
- The convention is cheap to define once and expensive to retrofit across many
  already-onboarded consumers later. Defining it before the consumer count grows
  is the low-cost moment.

## Risks / Open Questions

- **What is the right field convention?** Candidate shapes, not yet decided:
  (a) bare adopter handle (`Owner: @adopter`); (b) role-qualified
  (`Owner: @adopter (harness adopter)`); (c) a distinct field pair
  (`Host-Owner:` vs `Adopter:`); (d) leaving `Owner:` for the host and adding an
  `Authored-by:` line for the adopter.
- **Is "Owner" even the right word** for an adopter-authored artifact living in a
  repository whose IP belongs to the host? Retaining *authorship* is clearly
  legitimate; asserting *ownership* may not be. The convention must separate the
  two.
- **Could a validator enforce it?** A `validate-attribution`-style check could
  flag adopter-authored files that assert the host org's identity/trademarks —
  but it needs to know "who is the host" and "who is the adopter." That suggests
  manifest configuration: e.g. `project.hostOwner` / `project.adopter`, or a
  declared trademark denylist analogous to `.knowledge-redaction-ignore`.
- **Generalizes beyond forks.** The same boundary applies to any context where
  the harness *adopter* is not the project's legal *owner*: outside contractors,
  internal platform teams instrumenting another team's service, OSS contributors
  proposing governance upstream.
- **Design should be informed by practice.** This OPP is deliberately filed as a
  problem statement with the solution **deferred** — the convention should be
  shaped by several more real adoptions before it is fixed, to avoid encoding a
  convention that fits one fork's circumstances and not the general case.

## Disposition

<!-- Empty while Status: proposed. -->

## Promotion

<!-- Empty until accepted. Then a link to PRD-NNNN. -->
