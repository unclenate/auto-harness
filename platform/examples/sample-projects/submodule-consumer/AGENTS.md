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

# AGENTS.md

Cross-agent operating rules are derived from the kernel trust model and active agent packs declared in `harness.manifest.yaml`.

<!-- harness-managed-section -->
The block between the `harness-managed-section` markers is owned by the harness
bootstrap. It is regenerated from the modules resolved out of
`harness.manifest.yaml` and the kernel fragments published under
`.harness/platform/core/kernel/base/`. Hand-edits inside this block will be
overwritten on the next bootstrap run — put consumer-specific guidance outside
the markers.

Active agent packs (resolved from the manifest):

- `base` — cross-agent operating rules (trust tiers, halt-before-bypass,
  evidence over assertion)
- `claude-code` — Claude Code-specific overlay (permissions, hooks, skills)

Canonical references inside the submodule:

- `.harness/platform/core/kernel/base/` — kernel doctrine and trust model
- `.harness/platform/agents/base/` — shared agent pack
- `.harness/platform/agents/claude-code/` — Claude Code overlay
<!-- /harness-managed-section -->
