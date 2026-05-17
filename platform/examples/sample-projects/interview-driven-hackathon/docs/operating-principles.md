<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Operating Principles

Small-team operating principles for an interview-driven, hackathon-tier project.

- **PRD is the source of truth.** All scope, intent, and constraints flow from `docs/PRD.md`.
  If the PRD does not say it, it does not ship.
- **Plan stays decision-complete.** `docs/full-plan.md` must reflect every PRD change. Drift
  between PRD and plan is the most common failure mode for this style.
- **Prompt stays current.** When the PRD changes, refresh `docs/prd-interview-spec-prompt.md`
  in the same commit. AI agents derive implementation from the prompt, not the PRD directly.
- **Out-of-scope is named explicitly.** Unnamed scope expands during a hackathon.
- **Upgrade is intentional.** When the team grows or the docs need to be split, replace the
  `interview-driven` overlay with `product-lite + project-standard` in a single change. Do
  not let the two coexist indefinitely.
