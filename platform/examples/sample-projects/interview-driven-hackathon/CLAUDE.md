<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# CLAUDE.md

Claude Code must read:

1. `HARNESS.md`
2. `AGENTS.md`
3. this file
4. `docs/PRD.md` (the monolithic product requirements document)
5. `docs/full-plan.md` (the decision-complete plan)
6. `docs/prd-interview-spec-prompt.md` (the AI-facing interview/spec prompt)

When implementing features, treat the interview/spec prompt as the bridge between the PRD and
generated code. If the PRD has been updated since the prompt was last refreshed, flag the
drift before writing code — silently coding against a stale prompt is the most common failure
mode for this style.
