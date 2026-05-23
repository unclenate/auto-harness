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

# CLAUDE.md

Claude Code must read:

1. `HARNESS.md`
2. `AGENTS.md`
3. this file
4. active stack and delivery overlays declared in `harness.manifest.yaml`

The harness itself is mounted as a git submodule at `.harness/`. Governance
fragments, skills, and templates referenced by the manifest resolve under that
prefix — for example:

- `.harness/platform/core/kernel/base/` — kernel doctrine
- `.harness/platform/skills/harness-governance/` — governance skill (also
  symlinked into `.claude/skills/` and `.agents/skills/`)
- `.harness/platform/templates/` — artifact templates
- `.harness/platform/validators/` — validator scripts
