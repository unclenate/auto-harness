<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# HARNESS.md

This sample project uses the modular harness manifest at `harness.manifest.yaml`.

Source modules:

- `kernel/base`
- `node-typescript`
- `web-app`
- `relational-postgres`
- `production-saas`
- `product-lite`
- `project-standard`
- `base`
- `claude-code`

Validators live inside the mounted harness submodule. Invoke them through
`.harness/platform/...` paths, for example:

```bash
ruby -I .harness/platform/validators/lib .harness/platform/validators/test/test_harness_registry.rb
ruby -I .harness/platform/validators/lib .harness/platform/validators/test/test_validators_integration.rb
```
