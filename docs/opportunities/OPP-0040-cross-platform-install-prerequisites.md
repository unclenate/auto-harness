<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0040 — Cross-Platform Install Prerequisites: Surface and Preflight Them at First Contact

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-06-05
**Last Updated:** 2026-06-05
**Confidence:** medium

---

## Thesis

The harness has real, hard runtime prerequisites for its install path — **Bash
4+, Ruby 3.0+, ripgrep, and Git with `core.symlinks=true`** — but a first-time
adopter does not reliably learn about them until they are *already mid-install
and hitting a failure*. The requirements are documented, but only in reference
sections a newcomer reaches *after* the quickstart, and the install tooling
preflights them **asymmetrically**: `install.sh` hard-checks Bash up front (clean
exit with guidance) while a missing Ruby surfaces only as a late follow-up after
the validator smoke test, and ripgrep / git-symlinks are not preflighted at all.
The harness should (a) consolidate a **cross-platform prerequisites matrix**
(macOS / Linux / Windows-WSL) surfaced at the point of first contact, and
(b) make `install.sh` **preflight all dependencies up front** and emit a single
actionable report rather than failing piecemeal.

## Origin / Evidence

- **Distilled observation.** See
  [`docs/knowledge/shared-observations.md`](../knowledge/shared-observations.md)
  → *"A declared prerequisite that lives only in reference docs and is preflighted
  asymmetrically is, in effect, undeclared at the moment it matters"* — the
  generalized learning behind this candidate (filed in the same PR).
- **Operator-reported friction (this session).** A maintainer adopting the harness
  on macOS hit two prerequisites — Bash 3.2 → 4+ and a too-old/absent Ruby —
  *only once already working with the harness*, not at first contact. Their words:
  the install has "a couple dependencies that are not mentioned until I am into
  working with the harness," and the same is likely true, unexamined, on Windows
  and Linux.
- **Prerequisites are scattered, with no consolidated cross-platform matrix.** The
  same prereq set is stated three times, none of them at the quickstart's point of
  first contact: `platform/workflow/submodule-integration.md` § Prerequisites,
  `platform/bootstrap/README.md` § Requirements, and `README.md` § Integrating into
  Your Repo. The root `README.md` "Getting Started" 6-step flow leads with
  `cp`/`validate` commands and never names a prerequisite.
- **Asymmetric preflighting in `install.sh`.** Bash is hard-preflighted
  (`BASH_VERSINFO[0] -lt 4` → clean exit with a `brew install bash` message). Ruby
  is *not* preflighted — a missing `ruby` is only discovered when the post-install
  validator smoke test runs, and is reported as a deferred `FOLLOWUPS+=(...)` line.
  So a consumer with Bash 4 but no Ruby gets a confusing late failure instead of an
  up-front "install Ruby 3.0+ first."
- **ripgrep is an undocumented-in-the-install-path dependency — and the docs
  contradict each other.** `README.md` § Validators declares "Ruby 3.0+ and ripgrep
  are the only runtime requirements"; `validate-placeholders.sh` does use `rg`. Yet
  `README.md` § Integrating into Your Repo (the Prerequisites paragraph)
  cross-references the ripgrep prerequisite to
  `submodule-integration.md#prerequisites` — a section that **does not list
  ripgrep at all**. A consumer following the canonical pointer never learns ripgrep
  is required until a validator fails.
- **Cross-platform coverage is thin outside macOS.** The macOS Bash-3.2 sharp edge
  is well covered. Windows gets a single line (`core.symlinks=true`); Linux is
  assumed fine, but several still-supported LTS distros ship Ruby < 3.0 and don't
  carry ripgrep in their base install. There is no WSL recommendation, no Git-Bash
  vs PowerShell guidance, and no per-platform package-manager command set
  (`brew` / `apt` / `dnf` / `choco` / `winget`).

## Why Now

- Adoption / onboarding is repeatedly named in this catalog (OPP-0023, OPP-0025,
  OPP-0038) as the harness's highest-leverage growth and discovery vector.
  First-contact install friction is the cheapest place to lose an adopter — they
  bounce before they ever see the value.
- The gap is partially evidenced by an **internal documentation inconsistency**
  (the ripgrep cross-reference points at a section that omits it), which means it
  is also a correctness defect, not only an ergonomics wish.
- The fix is cheap to do once and gets more expensive as the consumer count and
  the number of supported platforms grow. Defining the matrix and the preflight
  before broad Windows/Linux adoption is the low-cost moment.

## Risks / Open Questions

- **Where should the consolidated matrix live?** Candidate shapes, not yet decided:
  (a) a single root-level `PREREQUISITES.md` linked from every adoption-path doc;
  (b) a shared `platform/workflow/prerequisites.md` partial that each guide
  transcludes-by-link; (c) a short "Before you start" block prepended to the
  quickstart and the README Getting Started flow, pointing to one canonical detail
  page. Risk of (a)/(b): another doc to keep in sync — would benefit from a
  `validate-catalog-counts`-style check or a single-source-of-truth generator.
- **Should `install.sh` gain a `--preflight` / `doctor` mode?** A single up-front
  pass that checks Bash version, Ruby presence *and* version (≥ 3.0), ripgrep, and
  `git config core.symlinks`, then prints one actionable report with per-platform
  install commands — instead of the current Bash-hard / Ruby-late / rg-silent
  asymmetry. Open question: hard-fail vs warn-and-continue for each (Bash must be
  hard; Ruby/ripgrep are only needed for validators, so a skeleton install could
  warn).
- **Per-platform package commands risk staleness.** Encoding `brew` / `apt` /
  `dnf` / `choco` / `winget` invocations means maintaining them. Mitigation: keep
  the matrix to "what + minimum version + canonical install pointer," not full
  copy-paste recipes for every distro.
- **Windows is the least-exercised path.** Is the supported answer "use WSL2" (and
  document only that), or do we commit to native Git-Bash support? The
  `declare -A` / symlink / ripgrep assumptions all lean toward a WSL-first
  recommendation; that should be a deliberate, stated stance, not an accident.
- **Overlap with existing surfaces.** `troubleshooting.md` already solves several
  of these *after* they fail (ruby-not-found, missing artifacts). This OPP is the
  *before-it-fails* complement; the design should de-duplicate against
  troubleshooting rather than restate it.
- **Generalizes a recurring pattern.** This is another instance of the catalog's
  "declaration without enforcement / declaration without first-contact surfacing"
  motif (cf. OPP-0025's silent submodule failures): a real requirement exists, but
  nothing surfaces it at the moment the operator needs it. A paired
  shared-observation may be warranted if a second instance accrues.

## Disposition

<!-- Empty while Status: proposed. -->

## Promotion

<!-- Empty until accepted. Then a link to PRD-NNNN. -->
