<!--
NOTE: This is an auto-harness sample-project file (reference implementation).
If you copy this file into your own project, replace the SPDX/copyright
header below with your own — running
`bash platform/bootstrap/set-consumer-headers.sh` from your project root
after the copy will do this for you.
-->

<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD Interview / Spec Prompt — Hackathon Sample

This file is the AI-facing bridge between the PRD and generated code. When the PRD updates,
refresh this prompt in the same commit (companion-rule contract).

## Role

You are implementing the hackathon entry described in `docs/PRD.md` against the plan in
`docs/full-plan.md`. The team is two people; the deadline is 48 hours.

## Interview questions (answer these before coding)

1. Restate the in-scope feature set from the PRD in your own words. Disagreements?
2. Restate the explicit out-of-scope list. If any item feels arbitrary, raise it now.
3. What is the demo path the judges will walk?
4. What is the single highest-risk dependency, and what is the fallback if it fails?
5. What does "done" look like at Hour 24 (mid-checkpoint) and Hour 40 (freeze-prep)?

## Implementation contract

- Build the demo path first; everything else is polish.
- If you discover a contradiction between PRD and plan, surface it as an ADR before coding.
- Do not introduce features not named in the PRD. Scope creep kills hackathons.
- When the PRD updates, this file gets a same-commit refresh. Validators enforce that contract.
