<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# HARNESS.md
## Compatibility Shim For The Modular Harness

This file represents the repo-facing compatibility entrypoint that older harness consumers expect.

The source of truth now lives in the modular platform:

- `platform/core/kernel/base/*.md`
- active module metadata in `platform/profiles/**/module.yaml`
- active agent packs in `platform/agents/**/module.yaml`

Use `harness.manifest.yaml` to declare which modules are active. The current implementation keeps this document as a maintained compatibility layer instead of a generated output.
