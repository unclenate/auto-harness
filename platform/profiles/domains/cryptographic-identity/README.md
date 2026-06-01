<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Domain Overlay: Cryptographic Identity

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay governs projects whose surface includes cryptographic
identity primitives — HD wallets, decentralized identifiers (DIDs),
self-sovereign identity (SSI), key custody, signature schemes — and
which are **not** Ethereum smart-contract projects.

**Spec source:** [OPP-0010](../../../../docs/opportunities/OPP-0010-domain-module-cryptographic-identity.md)

## Why this is distinct from `domains/web3`

[`domains/web3`](../web3/README.md) is Ethereum-specific:
ethers, wagmi, viem, hardhat, smart-contract auditing concerns.

This module covers the **wider cryptographic-identity surface**:
Bitcoin-style HD wallets (BIP32/BIP39 derivation), DID/SSI methods
(W3C DID, did:key, did:web, did:peer), key custody primitives
(secp256k1 / Ed25519 / Curve25519 signature schemes), and Solid /
WebNative / personal-data-store identity layers.

A project can activate **both** modules if it has Ethereum exposure
AND broader cryptographic identity concerns (e.g., a wallet that
supports both Ethereum and Bitcoin-style HD chains).

## When to activate this module

- Projects with BIP39 mnemonic handling
- Projects with BIP32 hierarchical key derivation
- DID / SSI consumers or producers (did:key, did:web, did:peer, etc.)
- Personal-data-store projects (YouBase, Solid pods, Webnative)
- Lightning Network clients
- Holochain DHT participants
- Any project where silently changing a cryptographic library could
  alter signature semantics in a way users would notice

## What this overlay produces

- **Sensitive-path declarations** on package manifests (across npm,
  Cargo, Go, Python) so cryptographic library updates are visible to
  reviewers
- **Companion rule** requiring ADR / architecture / library-audit-log
  context for cryptographic library upgrades — silent failures here
  have outsized stakes
- **Three review gates**: encryption-mode invariants, mnemonic-handling
  tier discipline, signature-scheme migration ADR recommendations
- **Three optional artifacts** projects can scaffold as they mature:
  - `docs/crypto/library-audit-log.md` — when each library was last
    audited, against what threat model, with what outcome
  - `docs/crypto/key-management-policy.md` — how keys are generated,
    stored, rotated, and recovered
  - `docs/crypto/signature-scheme.md` — which scheme is in use, why,
    and what migration would entail

## What this overlay does NOT do

- It does not require any artifacts (zero-friction adoption)
- It does not prescribe a specific cryptographic library
- It does not police implementation correctness (no test fixtures or
  validators check cryptographic operations)
- It does not handle Ethereum smart-contract auditing — that's
  [`domains/web3`](../web3/README.md)'s scope

## Composition

| Combine with | Pattern |
|--------------|---------|
| `stacks/node-javascript` / `node-typescript` | Node-based wallet / identity stores (YouBase shape) |
| `stacks/python` | Python-based DID consumers |
| `data/embedded-key-value` | Wallet state in LevelDB / LMDB |
| `data/browser-storage` | Browser-side wallets / identity stores |
| `domains/web3` | Both Ethereum and broader crypto-identity |
| `architectures/api-service` | Identity-provider API services |
| `delivery/production-saas` | Production-deployed identity services |

## See Also

- [OPP-0010](../../../../docs/opportunities/OPP-0010-domain-module-cryptographic-identity.md) — originating opportunity
- [`domains/web3/README.md`](../web3/README.md) — orthogonal Ethereum-specific module
