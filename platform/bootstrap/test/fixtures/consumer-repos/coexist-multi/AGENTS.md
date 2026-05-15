<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# AGENTS.md — Custom project conventions

## About this codebase

This is a data-pipeline monorepo. Agents should understand that modifying any
file in `src/etl/` may affect downstream analytics.

## Review checklist

Before approving a PR, check:
- Pipeline tests pass
- Downstream schema compatibility verified
- CHANGELOG updated
