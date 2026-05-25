<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Data Overlay: Embedded Key-Value

This overlay governs server-side projects whose data layer is an
**embedded** key-value store — the database runs in-process as a
library dependency, not as a separate network service.

**Spec source:** [OPP-0009](../../../../docs/opportunities/OPP-0009-data-module-embedded-key-value.md)

## When to activate this module

Activate when the project uses any of:

- **LevelDB family** — `level`, `levelup`, `leveldown`, `level-rocksdb`,
  `subleveldown`, `level-mem` (Node)
- **LMDB** — `lmdb-js`, `node-lmdb` (Node); `lmdb-rs` (Rust)
- **RocksDB** — `rocksdb-go`, `rocksdb-rs`
- **SQLite-as-KV** — `better-sqlite3` used purely as KV
- **Bun-KV** — Bun's built-in KV store
- **Deno-KV** — Deno's built-in KV store
- **IPFS / Helia datastore** — `interface-datastore`-compatible stores

Browser-side embedded storage (IndexedDB, localStorage, OPFS) is a
separate concern; activate [`data/browser-storage`](../browser-storage/README.md) for that.

Network-service databases (Postgres, Redis, MongoDB) use the
relational, document-store, or domain overlays, not this one.

## What this overlay produces

- **Sensitive-path declarations** on package manifests so KV-library
  changes are surfaced
- **Review gates** reminding the project to document schema-on-code
  evolution and backup-recovery semantics (these vary substantially
  per engine)
- **Two optional artifacts** the project can scaffold when ready:
  - `docs/data/persistence-strategy.md` — engine choice, schema
    versioning, migration approach
  - `docs/data/backup-recovery.md` — backup cadence, recovery testing,
    restore procedure

## What this overlay does NOT do

- It does not require any artifacts in v1 (zero-friction adoption)
- It does not prescribe a specific KV engine
- It does not impose a schema-versioning scheme (the project decides)
- It does not police backup strategy (review gate is human-text only)

These intentional omissions match the pattern of other zero-required-
artifact data modules ([`data/document-store`](../document-store/README.md))
and reflect the fact that the embedded-KV ecosystem is mid-migration
in 2025-2026 (LevelDB → abstract-level; many libraries deprecated).

## Composition

| Combine with | Pattern |
|--------------|---------|
| `stacks/node-javascript` | Node + LevelDB-family (YouBase shape) |
| `stacks/node-typescript` | Modern Node + LMDB / better-sqlite3 |
| `stacks/python` | Python + plyvel / LMDB |
| `domains/cryptographic-identity` | KV-backed wallet / identity stores |
| `architectures/event-driven` | Embedded-KV event sourcing |

## See Also

- [OPP-0009](../../../../docs/opportunities/OPP-0009-data-module-embedded-key-value.md) — originating opportunity
- [`data/browser-storage/README.md`](../browser-storage/README.md) — browser-side companion module
- [`data/document-store/README.md`](../document-store/README.md) — sibling module (similar zero-artifacts shape)
