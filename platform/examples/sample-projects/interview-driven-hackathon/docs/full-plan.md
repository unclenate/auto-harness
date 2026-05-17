<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Full Plan — Hackathon Sample

A decision-complete plan: scope, milestones, dependencies, and trade-offs in one file.

## Milestones

1. **Hour 0–6 — Skeleton.** Project bootstrap, harness manifest, kernel artifacts.
2. **Hour 6–24 — Core flow.** Implement the demo path from PRD §"In scope (MVP)".
3. **Hour 24–40 — Polish.** Fix the path, then visual polish. Not before.
4. **Hour 40–48 — Demo prep.** Rehearse the judge walkthrough; freeze the codebase.

## Dependencies

- Hosting: any free-tier static / serverless target. Decision deferred to Hour 0.
- AI agent: configured per `CLAUDE.md`. Prompt source is `docs/prd-interview-spec-prompt.md`.

## Trade-offs

- **Stability over features.** A working narrow demo beats a broken wide one.
- **No premature abstractions.** Hackathon code is throwaway by default. Refactors are out of scope.
- **No observability.** If something breaks during the demo, debug live rather than instrument.
