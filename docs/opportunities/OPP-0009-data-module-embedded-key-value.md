<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0009 — Data Module for Embedded Key-Value Stores (LevelDB-class)

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-24
**Last Updated:** 2026-05-24
**Confidence:** high

---

## Thesis

The auto-harness data catalog covers `data/relational-postgres`,
`data/document-store` (Mongo/Firestore/DynamoDB), and `data/object-storage`
(S3/GCS/R2), but has no module for embedded key-value stores — the
LevelDB family, LMDB, RocksDB, SQLite-as-KV, IndexedDB, and friends. These
stores are common in Node servers, Electron apps, edge runtimes, browser
PWAs, IPFS nodes, and any project where the data layer ships with the
application rather than as an external service. The
`harness-onboarding` skill therefore cannot assign a data module to such
projects, even when the embedded-KV layer is a core architectural decision
worth governing — schema-on-code evolution, persistence-vs-cache reset
semantics, and backup discipline all need explicit treatment that a
`data/*` module is the right home for.

## Origin / Evidence

- **YouBase brownfield onboarding pass, 2026-05-24.** Section 2 of the
  resulting assessment notes:

  > "data: — none selected | LevelDB does not match any catalog data
  > module → see Open Question 2"

  YouBase's storage layer is *entirely* LevelDB-family:
  `leveldown ^4.0.1`, `levelup 4.0.0`, `memdown 3.0.0`, `encoding-down ^6.0.1`,
  `level-sublevel ^6.5.4`. Five runtime dependencies. The bundled custodian
  server boots a LevelDB at `./youbasedb/` (or whatever `--dblocation`
  specifies) and exposes it via the 5-endpoint HTTP API. There is no
  fallback path; LevelDB *is* the data layer.

- **Upstream-migration governance shape.** Four of those five packages
  are now explicitly npm-deprecated:

  | Package | npm deprecation message |
  | ------- | ----------------------- |
  | `leveldown` | "Superseded by classic-level" |
  | `levelup` | "Superseded by abstract-level" |
  | `memdown` | "Superseded by memory-level" |
  | `encoding-down` | "Superseded by abstract-level" |

  Migrating from `level*` to the `abstract-level` family is a real
  schema-and-API change for any consumer, not a `npm install` — exactly
  the kind of cross-cutting upgrade a data module's required artifacts
  should anchor. The existing `data/relational-postgres` module already
  carries `docs/database/migration-readiness.md` as its required artifact
  for analogous reasons (Postgres migrations are governance events). An
  embedded-KV module should be able to carry the same shape of artifact.

- **Category breadth.** Embedded-KV is not a single-consumer concern.
  Examples that would naturally fit such a module:

  - Every Electron app using `level` for local persistence
  - IPFS nodes (`leveldown` is foundational)
  - Lightning Network implementations using LMDB
  - Decentraland / Cosmos validator clients using RocksDB
  - Solid pods using IndexedDB on the browser side
  - SQLite-as-KV apps in mobile and edge contexts
  - Any agent storing memory locally in a key-value index
    (auto-harness's own `.remember/` is conceptually adjacent)

- **The existing catalog's shape suggests the gap is structural.** The
  current data modules cover three distinct *kinds* of stores: a SQL/RDBMS
  family (`relational-postgres`), a NoSQL-document family
  (`document-store`), and a blob family (`object-storage`). Embedded
  key-value is a fourth distinct kind, not a sub-flavor of any of the
  three.

- **Counter-example check — why this is not just "another data module."**
  The governance concerns of embedded KV are genuinely different:

  - **Schema lives in code, not in a migrations table.** Breaking changes
    are detected only on data read, often months after the change. A
    governance gate on "schema invariants change → ADR" matters more
    here than in Postgres, where migrations are usually explicit.
  - **Process-bound persistence.** Many embedded KVs live in the same
    process as the app (LevelDB uses a file lock); restart and crash
    semantics are first-class concerns. A `persistence-strategy.md`
    artifact codifying "what survives a restart" is genuinely useful.
  - **No external admin surface.** Postgres has `psql` and admin
    consoles; embedded KVs are queried only through the code path. A
    governance artifact noting "the data layer is unobservable except
    through the app" affects incident response materially.

## Why Now

- **First-real-brownfield-hit signal.** Same as OPP-0008 and OPP-0010 —
  the YouBase pass surfaced this hole the first time the skill saw a
  real consumer. Filing now lets the next brownfield consumer (which is
  likely to also need it; embedded KV is common in the codebase
  demographic the harness targets) get a clean composition.

- **The LevelDB family upstream-migration window is open.** The transition
  from `level*` to `abstract-level` is in progress. A data module that
  ships with `docs/data/migration-readiness.md` as a required artifact
  would catch consumers' upgrade-readiness state at exactly the right
  governance gate. Shipping this module *after* the LevelDB community has
  finished migrating would miss that window.

- **Edge / Bun / Workers compute trend.** 2026's runtime story
  increasingly includes embedded KV by default (Cloudflare Workers KV,
  Deno KV, Bun's built-in SQLite). The class is growing, not shrinking.
  A data-module catalog gap here ages worse over time, not better.

- **Discovery-loop momentum.** Filing as part of the three-OPP YouBase
  onboarding batch (see OPP-0008, OPP-0010) keeps the gap-discovery
  pattern coherent.

## Risks / Open Questions

### Risks

- **Scope creep across "embedded" vs. "managed" key-value.** Redis and
  managed DynamoDB are also KV but are operationally closer to
  `data/document-store` (provisioning, connection management, network
  latency) than to embedded LevelDB. Conflating them in one module
  loses governance precision. Recommend: this OPP scopes to *embedded*
  only.

- **Browser-embedded as a special case.** IndexedDB, `localStorage`,
  and the Origin Private File System (OPFS) are embedded KVs but in
  a browser process, with very different governance concerns (storage
  quota, user-eviction, no atomicity guarantees, no cross-tab
  coordination by default). Folding them under a generic
  `data/embedded-key-value` is awkward; splitting them into
  `data/browser-storage` is cleaner. Decide before naming.

- **Module sprawl risk.** A LevelDB-shaped module, a SQLite-as-KV-shaped
  module, an LMDB-shaped module, and an IndexedDB-shaped module is four
  modules where one might do. The trade-off mirrors OPP-0008's flat-vs-
  consolidated discussion. Recommend: start with one broad module;
  refactor only if specific shapes prove governance-distinct.

- **Required-artifacts choice is load-bearing.** Adding required
  artifacts (e.g., `docs/data/persistence-strategy.md`) creates ongoing
  governance overhead for every project that activates the module. The
  existing `data/document-store` has *zero* required artifacts;
  `data/relational-postgres` has *one*. Erring on the side of zero or
  one for a v1 reduces friction.

### Open Questions

- **Naming.** Candidates: `data/embedded-key-value`,
  `data/key-value-store`, `data/local-storage`, `data/embedded-store`,
  `data/local-kv`. "embedded-key-value" is the most precise (excludes
  managed KV by name) but verbose. "local-kv" is short but ambiguous
  (browser localStorage). Recommend: `data/embedded-key-value`.

- **Scope: include IndexedDB or split it out?** Two options:
  - (A) One module: `data/embedded-key-value` covering server-embedded
    (LevelDB, LMDB, RocksDB, SQLite-as-KV) *and* browser-embedded
    (IndexedDB, localStorage, OPFS). Simpler catalog.
  - (B) Two modules: `data/embedded-key-value` for server-side, plus a
    separate `data/browser-storage` for the browser case. Cleaner
    semantics; mirrors how the existing data modules treat distinct
    operational profiles separately.
  Recommend: B. The browser-storage governance concerns are real and
  separable.

- **Required artifacts for v1.** Three candidates, in order of priority:
  1. `docs/data/persistence-strategy.md` — what survives a restart;
     ephemeral cache vs. durable store; backup discipline
  2. `docs/data/schema-evolution.md` — how breaking changes are detected
     and gated (since schema lives in code, not in a migrations table)
  3. `docs/data/migration-readiness.md` — analogous to the Postgres
     module's, for when the embedded-KV library family migrates
     upstream (e.g., `level*` → `abstract-level`)

  Recommend: ship v1 with *zero* required artifacts (matching
  `data/document-store`'s shape); promote to one required artifact in a
  v2 OPP after the first real consumer exercises the module.

- **Sensitive-paths and companion rules.** Should changes to the data
  layer's encoding files (`encoding-down` config, `level-sublevel`
  patterns, schema-equivalent code) trigger a companion-rule
  requirement for an ADR or migration-readiness update? Recommend:
  defer to a v2; the v1 module establishes the category without
  imposing rules.

- **Dogfood path.** Auto-harness itself does not use an embedded KV
  (its persistent state is in flat markdown). So activating this
  module on auto-harness's own manifest is not feasible. The dogfood
  shape for this module is necessarily *consumer-side* — YouBase or
  another real consumer is the test bed. This is fine but worth
  noting; some modules have natural self-dogfood and this one does
  not.

### Design Options Under Consideration

| Option | Mechanism | Coverage | Required artifacts (v1) | Blast radius |
|--------|-----------|----------|------------------------|--------------|
| **A — Single broad `data/embedded-key-value`** | One module covering LevelDB / LMDB / RocksDB / SQLite-as-KV / IndexedDB / localStorage / OPFS | All embedded KV | None | Tiny: new module YAML + README |
| **B — Split server vs. browser** | `data/embedded-key-value` (server-side) + `data/browser-storage` (IndexedDB / localStorage / OPFS) | All embedded KV, cleaner semantics | None | Small: two new modules |
| **C — Narrow `data/leveldb`** | LevelDB family only; other embedded KVs deferred | LevelDB family | None | Tiny but risks proliferation |
| **D — Defer; document the gap** | Update the skill to explicitly say "data: leave empty for embedded-KV layers" | None | N/A | Tiny but punts |

**Initial bias (subject to PRD validation): B.** Two new modules —
`data/embedded-key-value` for server-side embedded KV (covers LevelDB,
LMDB, RocksDB, SQLite-as-KV, Bun KV, Deno KV) and `data/browser-storage`
for the browser case (IndexedDB, localStorage, OPFS). Both ship with zero
required artifacts; the governance shape is established and the
required-artifact set evolves in a follow-up OPP after real consumer
contact. Option A is acceptable as a stop-gap (one module is better than
zero) but loses the browser-vs-server distinction that's load-bearing for
governance.

## Disposition

<!--
Empty while Status: proposed. Populated on transition.
-->

## Promotion

<!--
Empty until accepted; then link to PRD-NNNN.
-->
