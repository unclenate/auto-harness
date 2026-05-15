<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# CLAUDE.md
## Compatibility Shim For Claude Code

Claude-specific behavior should be assembled from:

- `platform/agents/base/module.yaml`
- `platform/agents/claude-code/module.yaml`
- active stack overlays that affect command permissions

This shim exists so current harness users still have a familiar entrypoint while composition stays module-driven.
