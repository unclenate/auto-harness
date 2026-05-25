<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0025 — Consumer-Side Integration Smoke Test

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-25
**Last Updated:** 2026-05-25 *(filed as OPP-0023 in working tree; renumbered to OPP-0025 after PR #59 took the OPP-0023 slot — same renumbering pattern as the OPP-0006 → OPP-0007 collision earlier this session)*
**Confidence:** medium-high

---

## Thesis

When a consumer adopts auto-harness via the submodule path (`install.sh`,
`HARNESS_SUBMODULE_ROOT` contract, recommended by `submodule-integration.md`),
two integration-time failure modes are **silent on the first developer's
machine** and only surface for the second developer, in CI, or when a
contributor's clone fails to find validator scripts:

1. **`.harness/` is a gitlink, not a copy.** Cloning the consumer repo without
   `--recurse-submodules` leaves the directory empty — no error, just an
   unpopulated submodule. Validator commands then fail with "file not found"
   instead of "submodule not initialized."
2. **The pinned submodule SHA must remain reachable in the upstream remote.**
   Recording an explicit tracking branch (PR #58's `-b main` improvement)
   clarifies intent but does not provide a check: the SHA can still be
   force-pushed away, the branch can be deleted, or the remote can become
   auth-gated. `git submodule update --init` fails — sometimes with
   `fatal: reference is not a tree`.

The auto-harness CI itself cannot see either failure mode by construction —
the harness *is* the upstream the consumer pins to, so it has no
consumer-side execution path to test. Today's mitigation is *prose advice*
in `submodule-integration.md` (Step 6, added in this same hotfix bundle).
That prose advice can drift; a mechanical check cannot.

Add a **consumer-side integration smoke test** as a first-class harness
primitive: a tiny CI workflow template + a recipe documented in the workflow
guide. The CI template clones the consumer repo from scratch with
`--recurse-submodules`, asserts the submodule materialized, runs one
validator against the consumer's manifest, and fails the build on either
defect. Consumers add it to their CI in one paste; it then runs on every
PR and catches the silent-failure modes the moment they appear.

## Origin / Evidence

- **Maintainer initialization-session insight (2026-05-25).** Filed mid-bundle:
  *"One thing to verify on a fresh clone: `.harness` is a gitlink pointing at
  unclenate/auto-harness at a specific SHA. Anyone cloning this repo needs
  `git submodule update --init` to materialize it — and that SHA must be
  reachable in the submodule's remote. Worth a `git clone
  --recurse-submodules` smoke test from a clean directory when convenient."*
  The insight came from initialization of a fresh
  `repo → harness → Website Design plan` session, exactly the scenario the
  smoke test would protect.
- **The structural argument:** this is the *cross-repo* instance of a pattern
  the project has already named in `docs/knowledge/shared-observations.md`
  (*"Doctrine in prose without enforcement in code is a recurring harness
  gap."*). The intra-repo instance is catalog-count drift in unwatched files
  (M-j in the 2026-05-25 audit refresh; candidate OPP for list-completeness
  validation). Both share the shape: a declaration with no mechanical check
  against its referent. See the paired observation
  [*Cross-repo declarations have the same silent-drift failure mode...*](
  ../knowledge/shared-observations.md#cross-repo-declarations-have-the-same-silent-drift-failure-mode-as-intra-repo-doctrine-without-enforcement-and-the-harnesss-own-ci-cannot-see-them).
- **Adjacent prior art in this repo:** the `sample-projects` CI job added in
  Wave 3-B (2026-05-23) runs validators against in-tree sample projects on
  every PR. That job validates that the *upstream-side* of the integration
  contract works. The smoke test is the *consumer-side* counterpart:
  validates that the integration *as-cloned-fresh* works.
- **Adjacent prior art outside this repo:** the broader pattern of
  "consume your own artifact in a clean environment to catch packaging
  bugs" — `npm pack` smoke tests, container-image cold-pull verification,
  Homebrew tap clean-VM tests. All operate on the same diagnosis (the
  developer's machine carries hidden state that masks real consumer
  failures); auto-harness's version is just the submodule-shaped one.
- **PR #58 (in flight as of 2026-05-25) is complementary, not redundant.**
  It records the tracking branch explicitly (closes one root cause:
  ambiguous default-branch tracking). The smoke test catches failure modes
  PR #58 does not address: SHA-on-deleted-branch, force-push, auth-gated
  remote, fresh-clone-without-recurse-submodules. Both belong; they are
  different layers of the same defense.

## Why Now

The maintainer's insight came from a *real* initialization session this
session — not a theoretical concern. Smoke-test gaps tend to accumulate
silently until a real cross-machine failure surfaces; the discipline-cost
of fixing this *before* a consumer hits it is one hour of work; the cost
of fixing it *after* is a debugging session in someone else's CI logs.

Also, auto-harness is currently approaching v1.0 with an expanding
consumer surface (YouBase, OpenEMR Phase 1 planned, Tula self-hosted-oss,
and the Website Design plan that triggered this insight). Each additional
consumer is a new opportunity for the silent-failure mode to surface
embarrassingly. Shipping the smoke test in the v0.6/0.7 window keeps the
discipline-debt small.

## Risks / Open Questions

1. **Where does the CI template live?** Two reasonable options. (a) Inside
   `platform/templates/ci/` next to `github-actions.yml` and `gitlab-ci.yml`
   added in Wave 3-B — pure additive, low risk, but consumers must
   discover it. (b) Inlined into `submodule-integration.md` § 6 as a copy-
   pasteable block — higher discoverability, but creates a maintenance
   surface in the doc that drifts from the template file. PRD-pass should
   decide; bias toward (a) with a copy-pasteable example reproduced in (b),
   the same pattern `ci-integration.md` uses today.
2. **Should the smoke test be a separate job or extend the existing
   harness CI?** Separate job is cleaner (run-on-clean-checkout semantics
   is what gives the smoke test its value); inline extension risks the
   smoke test inheriting the developer's hidden state. Bias toward
   separate job.
3. **What does the smoke test assert beyond "submodule materialized"?**
   Options: just `test -f .harness/platform/validators/validate-manifest.sh`
   (minimal); + a single validator run against the consumer's manifest
   (recommended); + the full validator chain (heavy, but most thorough).
   Bias toward the middle option in v1 — proves the integration is live
   and the simplest contract holds; heavier chains can layer on.
4. **Should the smoke test live as a callable workflow (GitHub Actions
   reusable workflow) so consumers reference rather than copy?** Long-term
   yes; v1 no, because consumer projects use many CI systems and a
   reusable-workflow primitive doesn't translate cross-platform. Ship the
   templated copy in v1; revisit reusable-workflow in v2 if GitHub
   Actions consumers dominate.
5. **What about non-GitHub consumers?** GitLab CI template should ship
   in parallel (mirrors the existing Wave 3-B `gitlab-ci.yml`). Other
   systems (Jenkins, CircleCI, BitBucket Pipelines) are deferred to a
   follow-up OPP if demand emerges.
6. **Does the smoke test belong inside the harness's own CI?** Tempting,
   but no — the harness has no consumer to clone. The smoke test
   targets *consumer projects*. The harness's own CI already validates
   the upstream side via the `sample-projects` job.
7. **What about the deeper M-j list-completeness gap (intra-repo
   declarations without inbound checks)?** That is a separate, sibling
   OPP candidate captured in the paired shared-observation. The two
   compose naturally as anchor + satellite: same architectural root
   cause, two different surface manifestations. PRD-pass for OPP-0025
   should explicitly note the relationship so the satellite OPP can
   anchor on it.

## Disposition

<!--
Empty while Status: proposed.
-->

## Promotion

<!--
Empty until accepted. Then a link to PRD-NNNN.
-->
