<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# do-not-publish Marker

Mark a parked working file (a private spec, brief, or export) so the
publication-boundary gate (`validate-publication-boundary.sh`, PRD-0026) **fails
CI / pre-commit if the file is ever git-tracked**. The marker travels with the
artifact and needs no corpus of private names. While the file stays **untracked**
the marker is invisible to `git ls-files` and nothing fails — that is the intended
steady state.

## How to apply

Add **one** of the two accepted forms as a line, at the **start of the line**
(a mid-sentence mention does not count):

**HTML-comment sentinel** — works anywhere in any markdown file, renders invisibly,
and does not collide with a license-header comment block. Preferred for
content-bearing files:

```text
<!-- do-not-publish: true -->
```

**YAML frontmatter key** — for files that already carry frontmatter (must be in the
`---` fenced block at the very top):

```text
---
do-not-publish: true
---
```

## What it does NOT do

- It does not redact private *names* from a file's content — that is the content
  scanner's job (`validate-knowledge-redaction.sh`, and OPP-0048 mechanism 2).
- It does not infer sensitivity of an unmarked file — the marker is an
  author-asserted intent.
- It does not scrub git history — it gates the *first* publish only.

## Removing the marker

If a file becomes intentionally publishable, delete the marker line and commit
normally. The gate only objects while the marker is present **and** the file is
tracked.
