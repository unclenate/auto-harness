<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0021: The Merge Gate on `main` Is CI, Not Code-Owner Review (A Single-Maintainer Repo Cannot Approve Its Own PRs)

**Status:** Accepted
**Date:** 2026-11-18
**Author:** @unclenate
**Reviewers:** @unclenate
**Context sources:**

- PR #244 (`harden(validators)`: cloud-identifier redaction class) — the PR that
  surfaced the deadlock; merged `3f53adc` via administrator bypass
- `.github/CODEOWNERS` — `@unclenate` on `*` plus `/platform/validators/`,
  `/platform/core/`, `/docs/knowledge/`, `/docs/operating-principles.md`,
  `/.github/`, and the governance entrypoints
- `AGENTS.md` → Operating discipline — "merges to `main` always require the
  maintainer's explicit, PR-named authorization"
- `platform/core/kernel/base/module.yaml` → `reviewGates` — "Validator success
  never replaces ownership review for protected governance files"
- GitHub branch-protection API on `main`, read 2026-11-18

## Context

Branch protection on `main` required **one approving review from a code owner**
(`required_approving_review_count: 1`, `require_code_owner_reviews: true`)
alongside ten required status checks.

`.github/CODEOWNERS` assigns `@unclenate` to `*` and, specifically, to
`/platform/validators/` and `/docs/knowledge/` — two paths that almost every
substantive change to this repository touches.

`@unclenate` is the repository's only maintainer. GitHub does not permit a pull
request's author to approve their own pull request: on one's own PR the
"Approve" option is not offered at all. Combined with the above, this produced a
gate that **no PR authored by the only person who can satisfy it could ever
pass**.

This was not a latent theoretical problem. PR #244 passed all ten required
checks, had its code reviewed and its guards mutation-verified, and still
reported `mergeStateStatus: BLOCKED` / `reviewDecision: REVIEW_REQUIRED` with
zero recorded reviews. The maintainer attempted to approve it; GitHub recorded
nothing, because there was nothing to record. The merge completed only through
`gh pr merge --admin`, which is possible here because `enforce_admins` is
`false`.

That outcome is the real finding, and it is worse than the configuration it came
from. A gate that is unsatisfiable is not a strong control — it is a control
whose **actual** steady-state behaviour is "administrator bypass, every time."
The repository's declared posture said ownership review gated every merge; its
observed posture was that ownership review gated nothing and was routinely
overridden. Under `docs/operating-principles.md` § 10 that is the gap between an
asserted control and an enforced one, found in this repository's own
configuration rather than in a consumer's.

A second consideration weighed against simply leaving the bypass in place as the
working practice. Routine bypass erodes the signal of the bypass itself: once
`--admin` is the normal path, it stops being a deliberate act and an operator
loses the ability to distinguish an ordinary merge from one that genuinely
skipped review. Keeping a control that must be overridden on every use trains
exactly the habit the control exists to prevent.

## Decision

**The merge gate on `main` is the required status-check set, not code-owner
review.** `required_approving_review_count` is set to `0` and
`require_code_owner_reviews` to `false`. All ten required status checks, the
up-to-date-branch requirement (`strict`), required conversation resolution, and
the force-push and deletion prohibitions are retained unchanged.

`.github/CODEOWNERS` is deliberately **not** changed. `@unclenate` continues to
be auto-requested as a reviewer on every PR; that request is now advisory rather
than blocking. Ownership review remains the practice, enforced socially and by
`AGENTS.md`, and the file stays accurate and ready for the moment a second
reviewer exists.

Dropping the count to `0` while leaving `require_code_owner_reviews: true` was
explicitly rejected as a non-fix: GitHub continues to demand a CODEOWNERS
approval on any PR touching an owned path regardless of the count, so that
combination would have preserved the deadlock while appearing to resolve it.

**`AGENTS.md`'s human-authorization discipline is unchanged and now carries the
whole weight of the pre-merge human gate.** An agent still waits for explicit
human instruction before any commit, push, or PR, and merges to `main` still
require the maintainer's explicit, PR-named authorization. What changed is
*where* that gate lives: it was never really in branch protection for a
single-maintainer repository, and pretending otherwise produced the bypass
habit. It lives in the operating discipline, and CI enforces the mechanical
floor beneath it.

## Consequences

### Positive

- A PR authored by the maintainer can merge through the normal path. The
  administrator bypass returns to being an exceptional act rather than the
  routine one, which restores its signal value.
- The declared posture and the observed posture agree. The merge gate that
  actually runs — ten required checks across two operating systems, including
  `shellcheck`, the validator chain, and the self-tests — is the one the
  configuration names.
- `CODEOWNERS` stays complete and correct, so re-enabling the review
  requirement is a single setting flip once a second reviewer exists.

### Negative

- No mechanical gate now stands between a green PR and `main`. The protection
  against an ill-advised merge is CI plus the maintainer's own judgement, and
  for agent-authored work, `AGENTS.md`'s explicit-authorization rule.
- The kernel's `reviewGates` statement — "Validator success never replaces
  ownership review for protected governance files" — is now, for this
  repository specifically, an operating-discipline commitment rather than a
  branch-protection fact. The statement remains the correct guidance for
  consumers, who typically have more than one maintainer; this ADR is the
  record that the platform repository itself cannot mechanically honour it
  while it has exactly one.
- Required checks become load-bearing in a way they were not before. A gap in
  CI coverage is now a gap in the merge gate, not merely a missed signal.

### Watch

- **A second maintainer or regular reviewer joins.** Restore
  `required_approving_review_count: 1` and `require_code_owner_reviews: true`
  immediately; the deadlock was an artifact of having one person, not a
  judgement that review is unnecessary.
- **Any `--admin` merge after this ADR.** With reviews no longer required, a
  bypass now means a *required check* was overridden, which is a materially
  more serious act than the one this ADR retires. Each occurrence belongs in
  `docs/project/change-log.md` with its reason.
- **Required-check drift.** Checks are now the only mechanical gate, so a new
  CI job that is not added to the ten required contexts silently fails to
  gate. Adding a job to `.github/workflows/harness.yml` should be paired with
  a protection update.
- **Consumer-facing wording.** If a consumer reads the kernel `reviewGates`
  line as a branch-protection guarantee, the platform's own configuration is a
  counterexample. Worth revisiting the wording if the question comes up.

## Alternatives Considered

### Keep the requirement and bypass with `--admin` each time

- The status quo that PR #244 exposed: leave protection as-is and use
  administrator privileges on every merge.
- Rejected. It makes the bypass routine, which destroys its signal and trains
  the habit the control exists to prevent, and it leaves the repository
  asserting a control it never actually applies. It also requires an
  authorization conversation on every merge for a gate that can never be
  satisfied, which is pure friction with no safety return.

### Add a second reviewer or a review-bot account

- Add a collaborator (human or machine) who can approve the maintainer's PRs,
  keeping the review gate mechanically real.
- Rejected for now, not on principle — this is the right answer and the Watch
  condition above commits to it. It was rejected as the resolution *today*
  because it cannot be conjured on demand: a bot account approving its own
  ecosystem's PRs is review theatre, and a human reviewer is a staffing
  decision, not a configuration one. Blocking all merges until one exists was
  not acceptable.

### Set the count to `0` but keep `require_code_owner_reviews: true`

- The literal reading of "drop required reviews to zero."
- Rejected as a non-fix. GitHub still requires a CODEOWNERS approval on any PR
  touching an owned path when this flag is set, independent of the count, so
  the deadlock would have survived while the configuration looked resolved —
  the worst of both outcomes.

### Remove the paths from `CODEOWNERS`

- Narrow `CODEOWNERS` so that fewer PRs trigger the code-owner requirement.
- Rejected. It would make the file a lie about who owns the validator and
  knowledge surfaces in order to work around a platform constraint, and it
  would quietly reduce ownership signal on exactly the paths that most need
  it. The ownership claim is correct; the gate built on it was not.
