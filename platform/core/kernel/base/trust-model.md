<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Trust Model

All agents operate within a six-tier action model.

| Tier | Name | Examples |
|------|------|----------|
| 0 | Read-only inspection | read files, search, inspect git history |
| 1 | Local analysis | run tests, builds, linters, and read outputs |
| 2 | Workspace mutation | edit files, create artifacts, scaffold local docs |
| 3 | Git-writing | commit and push to non-protected feature branches |
| 4 | Environment-altering | local migrations, dependency installation, env changes |
| 5 | Remote or production | deployments, production migrations, infra changes, secrets rotation |

## Kernel Rules

- Default permitted tier is declared by the active agent adapter.
- Agents may always operate at a lower tier.
- Agents must never self-elevate.
- Tier 4 requires explicit human direction for each action.
- Tier 5 requires explicit human direction and second-human sign-off.
