<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# HARNESS.md

This sample project uses the modular harness manifest at `harness.manifest.yaml` with the
`management/interview-driven` overlay. Its product and project documentation lives in three
monolithic files instead of the canonical multi-file `product-lite + project-standard` set:

- `docs/PRD.md` — the single product requirements document
- `docs/full-plan.md` — the decision-complete plan (scope, milestones, dependencies, trade-offs)
- `docs/prd-interview-spec-prompt.md` — the AI-facing interview/spec prompt derived from the PRD

Source modules:

- `kernel/base`
- `prototype`
- `interview-driven`
- `base`

See [`platform/profiles/management/interview-driven/README.md`](../../profiles/management/interview-driven/README.md)
for the overlay's philosophy and upgrade path to `product-lite + project-standard`.
