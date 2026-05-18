<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0010: Cheap Companion-Rule Satisfiers for Routine Governance Updates

**Status:** Accepted
**Date:** 2026-05-18
**Author:** @unclenate
**Reviewers:** @unclenate
**Context source:** Dependabot PR #17 (`actions/checkout v4 → v6`) failed the kernel/base companion rule because the rule's `requiredAny` only accepts `ADR-`, `operating-principles.md`, or `PRD-` as governance satisfiers. Dependabot has no way to author any of those.

## Context

PR #14 enabled Dependabot for the `github-actions` ecosystem. PR #17 is the first auto-generated dep-bump PR. It modifies `.github/workflows/harness.yml` — a path in the kernel/base `triggerPaths` for the rule "Governance changes require governance rationale or operating-model update." The rule's `requiredAny` (ADR / PRD / operating-principles) is too heavy for routine version bumps. Result: every Dependabot PR will indefinitely fail CI until a maintainer either:

1. Manually adds an ADR / PRD / operating-principles edit to each Dependabot branch (high friction)
2. Uses `--admin` to bypass the rule (weakens the governance contract)
3. Disables companion validation for Dependabot in CI (hides the bypass, weakens auditability)

None of those are good. The underlying issue: the kernel rule conflates *substantive* governance changes (new auth model, new CI surface) with *routine* mechanical updates (version bumps, CODEOWNERS line additions). Both currently demand the same heavyweight rationale artifact.

## Decision

Expand the kernel/base companion rule's `requiredAny` to accept **two additional cheap satisfiers** alongside the existing three:

```yaml
requiredAny:
  - ^docs/adr/ADR-           # substantive architectural decision
  - ^docs/operating-principles\.md$  # general policy update
  - ^docs/requirements/PRD-  # product/scope decision
  - ^docs/project/change-log\.md$    # routine maintenance entry
  - ^docs/project/dependency-log\.md$  # dependency / version-bump entry
```

The rule still fires on every `.github/workflows/`, `.github/CODEOWNERS`, or entry-point edit — review is still required. But for routine maintenance the maintainer can satisfy via a one-line `change-log` or `dependency-log` entry naming the change and the reviewer, instead of authoring a full ADR.

The `humanReview` clause is rewritten to distinguish which kind of change deserves which satisfier:

> Substantive decisions (new authentication model, new CI surface, new ownership boundary) require ADR / PRD / operating-principles. Routine maintenance (Dependabot version bumps, CODEOWNERS line additions for new maintainers, minor workflow ergonomics) may satisfy via change-log or dependency-log entry that names the change and the reviewer.

## Consequences

### Positive

- **Dependabot PRs become mergeable** with a one-line dep-log entry added by the maintainer before merge. The audit trail is captured in `docs/project/dependency-log.md` — searchable, reviewable, attributable.
- **The kernel rule still fires.** Auditability is preserved — no silent bypass in CI, no exempt-by-author logic. Every `.github/workflows/` change still demands a paired artifact.
- **Maintainer effort matches change weight.** A `(a+)+` ReDoS-fix in `validate-companions.sh` (substantive) still demands an ADR. A `actions/checkout v4 → v6` bump (routine) demands a dep-log line.
- **Reviewers get clearer guidance.** The expanded `humanReview` clause tells them what's substantive vs routine, instead of leaving the categorization implicit.

### Negative

- **A determined low-effort maintainer can downgrade substantive changes** to a change-log entry instead of authoring the right ADR. The `humanReview` clause is the only guard. (Tradeoff accepted: the alternative — heavyweight artifact for every change — produces real friction that breeds bypass habits.)
- **One more category of artifact** for new contributors to learn (dependency-log vs change-log vs ADR vs PRD vs operating-principles). Mitigation: the `humanReview` clause explicitly names the right satisfier per change shape.

### Watch

- If `docs/project/dependency-log.md` becomes a dumping ground for skipped governance review (e.g., maintainer authoring "v4 → v6, fine" with no actual review), tighten by requiring the dep-log entry to cite a reviewer name + commit hash. Or revert this ADR and force ADR-per-change.
- If Dependabot PR volume grows past ~5/week, consider auto-injection (a GitHub Action that appends the dep-log entry on PR open) so the maintainer doesn't have to touch each PR.
- If a non-Dependabot PR uses the cheap satisfier to ship a substantive workflow change without an ADR, that's an audit failure — escalate as a governance miss in a future quality audit pass.

## Alternatives Considered

### CI-level skip for `github.actor == 'dependabot[bot]'`

- Add an `if:` to the Validate-companions step that skips when the actor is Dependabot.
- **Rejected:** weakens the kernel rule by hiding the bypass in workflow YAML. An auditor reading `module.yaml` wouldn't see the exemption unless they also read the workflow. Also doesn't help any other automation (Renovate, custom bots, etc.) — would need a per-bot list.

### Auto-inject dep-log entry into Dependabot PRs via a GitHub Action

- A workflow triggers on Dependabot PR open, computes the dep-log line, pushes back to the Dependabot branch.
- **Rejected for v1:** requires a GitHub App with write access to PRs (or a fine-grained token). More engineering than the immediate need. Reserved as a follow-up if PR volume justifies it (see Watch above).

### Tighten `triggerPaths` to exclude `.github/workflows/` entirely

- Remove `^\.github/workflows/` from the kernel rule's triggers.
- **Rejected:** workflow changes are a real governance surface (auth model, secret scope, runner image, third-party action trust). Removing the trigger would let a substantive workflow change slip through without any review gate.

### Manual `--admin` bypass for every Dependabot PR

- Keep the rule as-is; the maintainer admin-merges each Dependabot PR.
- **Rejected:** trains the maintainer to ignore the validator, accumulates pressure to bypass for non-Dependabot PRs too, and produces no audit trail of *what was reviewed* for each bump.

## References

- [PR #14](https://github.com/unclenate/auto-harness/pull/14) — enabled Dependabot for `github-actions` ecosystem
- [PR #17](https://github.com/unclenate/auto-harness/pull/17) — first Dependabot auto-PR (the one that surfaced this) — `actions/checkout v4 → v6`
- [QUALITY-AUDIT-2026-05-18](../QUALITY-AUDIT-2026-05-18.md) — surfaced repo-hardening gaps that led to enabling Dependabot
- [ADR-0009](ADR-0009-ci-hardening.md) — the CI matrix + CODEOWNERS + Dependabot decision this ADR refines
- [`platform/core/kernel/base/module.yaml`](../../platform/core/kernel/base/module.yaml) — where the rule lives
