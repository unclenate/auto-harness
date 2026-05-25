<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Stack Overlay: CoffeeScript

This overlay governs legacy CoffeeScript projects compiling `.coffee`
to JavaScript. It depends on
[`stacks/node-javascript`](../node-javascript/README.md) because
CoffeeScript projects always sit on plain-Node runtime governance.

**Spec source:** [OPP-0008](../../../../docs/opportunities/OPP-0008-stack-module-node-javascript-and-coffeescript.md)

## When to activate this module

- The project has `.coffee` source files compiled to JavaScript
- Vintage 2010-2016 Node codebases written before the TypeScript era
  matured
- Forks or maintenance branches of CoffeeScript-original projects

If your project has *both* `.coffee` and `.ts` source files, this is
typically a transition project; consider activating both modules
during the migration and dropping this one once the transition is
complete.

## What this overlay produces

- **Sensitive-path declarations** on `.coffeelintrc*` and `.coffee`
  files so lint-config or compile-target language changes are
  surfaced
- **Companion rule** demanding ADR or architecture context for
  CoffeeScript migrations away from the language
- **Review-gate reminder** that CoffeeScript is a legacy language as
  of 2025 — modernization paths should be considered

## What this overlay does NOT do

- It does not enforce a CoffeeScript version
- It does not require any artifacts
- It does not prescribe a migration path; that decision is per-project

## Composition

This module depends on `stacks/node-javascript` (always-on for any
CoffeeScript project). Combine with the same architectures, data, and
delivery overlays the plain-JS sibling combines with.

## See Also

- [OPP-0008](../../../../docs/opportunities/OPP-0008-stack-module-node-javascript-and-coffeescript.md) — originating opportunity
- [`stacks/node-javascript/README.md`](../node-javascript/README.md) — the parent stack module
