<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Data Overlay: Browser Storage

This overlay governs projects whose primary data layer is in the
browser — IndexedDB, localStorage, sessionStorage, or OPFS (Origin
Private File System).

**Spec source:** [OPP-0009](../../../../docs/opportunities/OPP-0009-data-module-embedded-key-value.md) (browser-storage companion module)

## When to activate this module

- Browser-first applications with IndexedDB persistence (Solid pods,
  PouchDB clients, Logseq-style local-first apps)
- localStorage / sessionStorage as the primary persistence layer
- OPFS-backed file operations in the browser
- WebRTC peer-to-peer apps with browser-side state

Server-side embedded KV uses [`data/embedded-key-value`](../embedded-key-value/README.md) (LevelDB, LMDB, etc.) — distinct concerns because browser storage has tab-isolation, quota, and user-clear-data semantics.

## What this overlay produces

- **Two review-gate reminders** about browser-storage operational
  realities:
  - User-clearable: incognito mode, "clear browsing data" wipes state
  - Quota-limited: varies per browser; medium-criticality projects
    should test under quota pressure
- **One optional artifact** for projects that mature into structured
  documentation:
  - `docs/data/browser-storage-strategy.md` — schema versioning,
    quota-pressure handling, recovery expectations

## What this overlay does NOT do

- It does not require artifacts (zero-friction adoption)
- It does not prescribe IndexedDB / localStorage / OPFS choice
- It does not handle service-worker caching (separate concern; not
  data-overlay scope)

## Composition

| Combine with | Pattern |
|--------------|---------|
| `architectures/web-app` | Browser-first web applications |
| `architectures/agentic-ui` | In-product agent surfaces with browser-side persistence |
| `stacks/node-typescript` or `stacks/node-javascript` | The serving side; browser-storage is independent of the language compiling the bundle |
| `domains/cryptographic-identity` | Browser-side wallet / DID stores |

## See Also

- [OPP-0009](../../../../docs/opportunities/OPP-0009-data-module-embedded-key-value.md) — originating opportunity (covers both server-side embedded-KV and this browser-storage companion)
- [`data/embedded-key-value/README.md`](../embedded-key-value/README.md) — server-side sibling
