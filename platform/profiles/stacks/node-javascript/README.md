<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Stack Overlay: Node — Plain JavaScript

This overlay governs Node.js projects that do **not** use TypeScript.
It is the sibling to [`stacks/node-typescript`](../node-typescript/README.md)
and carries the same machinery (companion rules on
`package.json`/lockfiles, sensitive-path declarations for dependency
edits) without the TypeScript-specific bits.

**Spec source:** [OPP-0008](../../../../docs/opportunities/OPP-0008-stack-module-node-javascript-and-coffeescript.md)

## When to activate this module

- Pre-TypeScript-era Node codebases (2014-2017 vintage; LevelDB-class
  data stores; older Express/Hapi applications)
- Modern Bun or Deno projects that explicitly decline TypeScript
- ESM-only plain-JavaScript projects (Node 14+) that have chosen JSDoc
  over `.ts`
- Brownfield projects where the harness onboarding skill correctly
  refuses to claim `stacks/node-typescript` because no TypeScript
  evidence exists

If your project has a `tsconfig.json`, activate
[`stacks/node-typescript`](../node-typescript/README.md) instead.

If your project is CoffeeScript-era, activate
[`stacks/coffeescript`](../coffeescript/README.md) (which depends on
this module — CoffeeScript projects always sit on top of plain Node
runtime governance).

## What this overlay produces

Same as `stacks/node-typescript`:

- **Sensitive-path declarations** on `package.json`, lockfiles, and
  `.nvmrc` so reviewers see dependency edits explicitly
- **Companion rule** demanding ADR / architecture / PRD context for
  major dependency or runtime changes
- **Tier-4 reminder** in review gates: dependency installation
  (`npm install`, `bun install`, etc.) remains a Tier 4 action

## What this overlay does NOT do

- It does not require any artifacts (`requiredArtifacts: []`).
  Adoption friction is intentionally zero; a project gets governance
  surfaces without being asked to scaffold a doc set.
- It does not prescribe a package manager. npm, pnpm, yarn, bun all
  match the sensitivePaths regex.
- It does not impose ESM-vs-CJS module-system requirements. The
  project's own `package.json` `"type"` field is the authority.

## Composition with other modules

| Combine with | Pattern |
|--------------|---------|
| `architectures/web-app` | Plain-JS Node web applications |
| `architectures/api-service` | Plain-JS REST/RPC services |
| `data/embedded-key-value` | Node + LevelDB/LMDB/SQLite-as-KV (YouBase shape) |
| `data/relational-postgres` | Node + Postgres |
| `domains/cryptographic-identity` | Node + BIP32/BIP39 wallets, DID/SSI primitives |
| `delivery/production-saas` | Plain-JS production deployments |
| `delivery/prototype` | Plain-JS prototypes / discovery work |

## See Also

- [OPP-0008](../../../../docs/opportunities/OPP-0008-stack-module-node-javascript-and-coffeescript.md) — originating opportunity
- [`stacks/node-typescript/README.md`](../node-typescript/README.md) — TypeScript sibling
- [`stacks/coffeescript/README.md`](../coffeescript/README.md) — CoffeeScript-era sibling
