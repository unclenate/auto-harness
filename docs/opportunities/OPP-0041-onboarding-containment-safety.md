<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0041 — Onboarding Containment Safety: Never Instantiate or Commit a Consumer Inside the Platform Repo

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-06-05
**Last Updated:** 2026-06-06
**Confidence:** high

---

## Thesis

The bootstrap and onboarding flow will instantiate and govern a consumer project
wherever it is invoked, with **no check that the consumer's root is its own git
repository, distinct from the auto-harness platform repo**. When run from inside
(or into a subdirectory of) the platform working tree, it scaffolds the consumer
as a plain subdirectory and **commits the consumer's files into the platform's own
git history** — and mounts the platform back into itself as a submodule. The
harness should detect this containment and **refuse (or loudly hard-warn)**,
because a consumer must be its own git root with auto-harness mounted *as a
submodule beneath it* — never a subdirectory living *inside* the platform.

## Origin / Evidence

- **Concrete incident, this session (since fully reverted).** A contextless
  greenfield consumer (`unclenate.com`, described only as "a portfolio site for
  me") was bootstrapped from *within* the auto-harness working tree. The result:
  - `unclenate.com/` became a **plain subdirectory** of auto-harness with **no
    `.git` of its own** — not a separate repository.
  - Its scaffold was **committed into auto-harness's own history** by two commits
    (`chore: add auto-harness as submodule`, `feat: wire auto-harness via
    submodule` — the stock `install.sh` messages).
  - The root `.gitmodules` gained a `unclenate.com/.harness` entry, and
    `unclenate.com/.harness` was a gitlink pointing at auto-harness's **own**
    HEAD — i.e. auto-harness mounted inside auto-harness.
- **It was caught by a human, not a check.** The conflation only surfaced when a
  routine "commit this" was about to push the operator's personal-website files
  *up into the platform repo*. Every validator passed — the consumer's files were
  individually "valid"; nothing flagged that they were in the wrong repository.
- **The detection signal is unambiguous and local.** The enclosing git repo is
  the platform iff its root contains `platform/core/kernel/` and a manifest whose
  `project.id` is `development-harness-framework` (more generally: any repo whose
  root already owns a `platform/` tree + `harness.manifest.yaml`). The mistake is
  computable at bootstrap time, before a single file is written.
- **Distilled observation (this PR).** The generalized learning behind this
  candidate is recorded at
  [`docs/knowledge/shared-observations.md`](../knowledge/shared-observations.md)
  → *"Onboarding validates a consumer's file content but never its location /
  repository identity — the highest-consequence install failures are silent and
  location-dependent"* (shared with OPP-0042).

## Why Now

- Onboarding is repeatedly named in this catalog (OPP-0023, OPP-0025, OPP-0038,
  OPP-0040) as the harness's highest-leverage growth and discovery vector — and
  the install path is exactly where a first-time operator is *least* able to
  notice the platform-vs-consumer conflation.
- The failure is **silent, outward-facing, and high-consequence**: it can result
  in a private project's files being committed (and potentially pushed) into a
  *public* platform repository. That is a confidentiality/IP exposure, not only an
  ergonomics wart.
- The guard is cheap to add once and composes directly with the up-front
  preflight proposed in OPP-0040 (cross-platform install prerequisites).
  Adding it before consumer adoption scales is the low-cost moment.

## Risks / Open Questions

- **Hard-fail vs. warn.** A platform-containment hit should almost certainly be a
  **hard stop** (exit 2) with a clear remedy ("consumers must be their own
  repository — `cd` to a fresh directory outside the platform and re-run"), not a
  warn-and-continue. An explicit `--inside-platform` escape hatch is still needed
  for the self-dogfood example projects under `platform/examples/`.
- **Generic nested-repo smell.** Should the guard also catch instantiating a
  consumer inside *any* unrelated git repo (not just the platform)? A consumer
  created inside someone else's repo is nearly always a mistake — perhaps warn for
  generic nesting, hard-fail for platform-containment specifically.
- **Submodule self-reference.** Separately detectable: mounting auto-harness as a
  submodule whose URL/commit resolves to the *platform repo itself*. Worth
  flagging as its own smell.
- **Where the check lives.** `install.sh` preflight (composes with OPP-0040)
  and/or the `harness-onboarding` skill's first step. Likely both — the skill for
  the AI-driven path, the script for the deterministic path.
- **Recovery runbook.** The harness has no documented "extract a mis-created
  consumer to its own repo and back the scaffold out of the platform" recipe. This
  incident produced exactly that procedure (reset unpushed scaffold commits, drop
  `.gitmodules` entry, remove `.git/modules/<path>`, rebase dependent branches);
  shipping it as a runbook is a natural part of this OPP.
- **Sibling pattern.** This is another instance of the catalog's
  "declaration/inference without enforcement, surfaced only by an attentive human"
  motif (cf. OPP-0025 silent submodule failures, OPP-0040 late-surfaced
  prerequisites) — captured as the paired shared-observation this PR adds (linked
  under Origin / Evidence).

## Disposition

**Accepted 2026-06-06.** Promoted to PRD-0020 and implemented in the same PR.
`install.sh` now hard-fails before any write when the consumer is inside the
auto-harness platform repo (Guard A) or nested inside another git repo (Guard B),
with narrow escape hatches (`--inside-platform`, `--allow-nested`) for the rare
intentional cases. The detection signal is local and unambiguous (enclosing root
owns `platform/core/kernel/base/doctrine.md` + a `development-harness-framework`
manifest). The `harness-onboarding` skill carries the same refusal as a first
step. The recovery runbook
([`recover-misplaced-consumer.md`](../../platform/workflow/recover-misplaced-consumer.md))
ships alongside. Both guards are covered by the bootstrap test suite.

## Promotion

- See [`docs/requirements/PRD-0020-bootstrap-hardening-guards-and-preflight.md`](../requirements/PRD-0020-bootstrap-hardening-guards-and-preflight.md)
