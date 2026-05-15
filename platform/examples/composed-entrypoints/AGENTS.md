<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# AGENTS.md

## Compatibility Shim For Cross-Agent Rules

Read kernel trust and lifecycle rules from:

- `platform/core/kernel/base/trust-model.md`
- `platform/core/kernel/base/lifecycle-controls.md`
- `platform/core/kernel/base/enforcement-model.md`

Then read active agent packs declared in the manifest.

## Skills

External skills supplement harness governance with vendor- and tool-specific domain knowledge.
The harness provides governance context (Layer 1). External skills provide API accuracy (Layer 2).

Check `recommendedSkills` in each active module's `module.yaml` to determine which skills to
install. The full mapping and installation guidance is in `platform/workflow/skills-and-agents.md`.

**Web3 projects:** Install `openlaw:skill-vetter` before any other Web3 skill.
Web3 agent skills are experimental — test in isolation before connecting to live systems.
