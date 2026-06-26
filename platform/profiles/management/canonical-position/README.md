<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Management Overlay: Canonical Position

**Depends on:** `kernel/base`, `management/project-standard`.
**Conflicts with:** None.

This overlay adds the single **ratified north-star** a project's other artifacts
align to. Without it, decisions, framings, and assumptions accumulate across
problem-statements, requirements, OPPs, and GTM docs as independent snapshots of
evolving thinking — they drift apart, the project loses its own ground truth, and
recovery costs a hand-rolled "canonical position" doc plus a multi-day
reconciliation. This overlay makes that reference a first-class artifact and gates
the project's strategy-shaped artifacts against it.

---

## When to activate

Activate when the project has **strategic positioning concerns** — anything where
"what we are doing and why" must stay coherent across many documents and over time:
a product with a wedge and a buyer, a research program with a thesis, an internal
platform with a mandate. Projects without a clear strategic position (a throwaway
scratch library, a one-shot script) can skip it.

It is **opt-in**: add `canonical-position` to your `harness.manifest.yaml`. It is
not a forced upgrade for existing `project-standard` consumers, and auto-harness
itself does not activate it (the framework's own positioning lives in its README /
operating-principles, not a consumer-shaped canonical-position artifact).

## What this overlay requires

**`docs/canonical-position.md`** — the ratified position. Scaffold it from
[`templates/canonical-position/canonical-position.md`](../../../templates/canonical-position/canonical-position.md).
Required sections (every project shape): identity, wedge / job-to-be-done,
boundaries, positioning, update-policy. Recommended sections (when relevant):
buyer/motion, funding, research-thesis, internal-mandate, partnership-posture. The
template ships with `<!-- TODO: ratify -->` markers so the artifact exists
structurally on day one; the citation rule fires on *citation*, not on content
completeness.

**`docs/reviews/` (optional)** — the ratification trail. Review-artifacts
(`docs/reviews/REVIEW-NNNN-slug.md`, scaffolded from
[`templates/canonical-position/review.md`](../../../templates/canonical-position/review.md))
document the review that produced each canonical revision. The directory is an
*optional* artifact so early-phase reviews don't fire the ratification rule
prematurely.

## How the two companion rules work

- **Citation rule** — when a strategy-shaped artifact (`requirements.md`,
  `release-intent.md`, `mvp-scope.md`, `problem-statement.md`, anything under
  `docs/discovery/`, `OPP-*`, `docs/partnerships/`, `docs/gtm/`) changes, the same
  PR must touch `docs/canonical-position.md` — the citation is created or updated
  against the current ratified position. (v1 satisfier is path-only; a
  content-citation check is a v2 enhancement.)
- **Ratification rule** — when `docs/canonical-position.md` changes, the same PR
  must include a `docs/reviews/REVIEW-*.md` artifact. You cannot silently revise
  the north star. The kernel-base rule already requires the change-log entry, so
  the two rules compose.

## What does *not* belong here

Keep these distinct surfaces distinct:

- **`docs/operating-principles.md`** is *how the project works* (process). The
  canonical-position is *what the project ships / is doing* (strategy). Operating
  principles change when process evolves; the canonical-position changes when
  product or strategy evolves.
- **`docs/project/scope-plan.md` / `milestones.md`** (project-standard) are the
  tactical *plan*; the canonical-position is the *position the plan serves*.
- The canonical-position is a single ratified document — not a running log. Use
  `shared-observations.md` (knowledge-capture) for accumulating thinking, and
  promote the crystallized position here via a ratified revision.

## Versioning

v1 treats the artifact as **full-document**: every ratified revision supersedes the
previous wholesale. Per-section ratification is a future enhancement if the
full-document granularity proves too coarse.
