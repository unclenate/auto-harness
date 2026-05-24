<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0010 — Domain Module for Cryptographic Identity (Non-Ethereum HD Wallets)

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-24
**Last Updated:** 2026-05-24
**Confidence:** high

---

## Thesis

The auto-harness domain catalog has `domains/web3` whose trigger signals
are explicitly Ethereum-specific (`ethers`, `wagmi`, `viem`, `hardhat`,
`foundry`, `contracts/`, `abi/`), but the broader category of
*cryptographic identity projects* — Bitcoin-style HD wallets, BIP39
mnemonic-derived keys, ECDSA-signed user-owned documents, self-sovereign
identity stacks, personal data stores in the Solid / Webnative /
Holochain lineage — has no domain module. These projects have genuinely
distinct governance concerns from Ethereum smart contracts: key custody,
mnemonic backup discipline, cryptographic library upgrade audit cadence,
encryption-mode invariants, and signature-scheme migration. Conflating
them under `domains/web3` would muddle that module's existing meaning;
omitting them leaves a structural hole. A new `domains/cryptographic-
identity` module (orthogonal to `domains/web3`, activatable together for
projects that combine both) closes the gap.

## Origin / Evidence

- **YouBase brownfield onboarding pass, 2026-05-24.** Section 2 of the
  resulting assessment notes:

  > "domains: — none selected | crypto-wallet (Bitcoin-style HD keys)
  > does not match `web3` (Ethereum) or any other catalog domain → see
  > Open Question 3"

  YouBase's identity stack is BIP39 mnemonic → BIP32 HD derivation
  (`hdkey`) → secp256k1 ECDSA (`ecdsa`, `ecc-tools`, `coinkey`,
  `coininfo`, `coinstring`, `bs58check`) → ECC-envelope wire format
  (`ecc-envelope`). Custom BIP32 purpose code `m/1337'` (not
  SLIP-0044-registered). No Ethereum touchpoint — no `ethers`, no
  `viem`, no `contracts/`, no `abi/`. The architecture overview
  documents this explicitly:

  > "Anyone migrating this codebase needs to understand [the `hardened`
  > AES-keyed-off-xpub semantics] is by design, not a bug."

  Twelve cryptographic libraries in the dependency tree; zero
  catalog-domain coverage today.

- **Module catalog confirmation.** `harness-onboarding/SKILL.md`'s
  domains table:

  | Module | Select when |
  | ------ | ----------- |
  | `domains/web3` | `ethers`, `wagmi`, `viem`, `hardhat`, `foundry`, `contracts/`, or `abi/` found |

  All seven triggers are Ethereum-specific (or near-EVM). A Bitcoin-
  style HD wallet, a `did:key` identity SDK, or a Lightning Network
  client trips zero triggers.

- **The governance concerns are genuinely distinct.** Five categories
  the cryptographic-identity domain would naturally govern, none of
  which `domains/web3` addresses today:

  1. **Encryption-mode invariants.** YouBase's `Document.encrypt` has
     three modes (`public`, `hardened`, `private`), and the `hardened`
     mode deliberately couples decryption to the BIP32 extended public
     key — a non-standard semantics that is "by design, not a bug."
     This kind of intentional cryptographic invariant deserves an ADR
     gate the harness can enforce.

  2. **Cryptographic library upgrade audit cadence.** YouBase's
     `ecdsa ~0.5.3` package has not had a meaningful update since 2014.
     Moving to `@noble/secp256k1` or `@noble/curves` is a security-
     review event, not a dependency bump. A governance module can
     codify "cryptographic primitive upgrades require an ADR plus a
     before/after fixture-test pass" as a companion rule.

  3. **Mnemonic backup and recovery policy.** Projects holding
     user-owned keys need an explicit policy on how mnemonic recovery
     is exposed, how it interacts with key rotation, and what happens
     if the underlying derivation library changes (does the user's
     existing mnemonic still derive the same keys?). This is a
     governance concern, not a UX concern.

  4. **Purpose-code / coin-type registration discipline.** YouBase uses
     `m/1337'`. SLIP-0044 lists registered coin types; an
     unregistered choice has both legitimate ("this isn't a coin, it's
     identity") and risky ("future SLIP-0044 conflict") shapes. A
     governance artifact noting *why* a non-registered code was chosen
     anchors the decision.

  5. **Signature-scheme migration.** A project using secp256k1 ECDSA
     today may need to migrate to ed25519, BLS, or post-quantum
     primitives. Such a migration is multi-year, multi-release, and
     requires data-format planning. A required artifact like
     `docs/crypto/signature-scheme.md` is the right home.

- **Category breadth.** Cryptographic-identity is not a single-consumer
  concern. Other examples that would fit:

  - Solid pod libraries (`@inrupt/solid-client`)
  - Webnative SDK (file-system-on-cryptographic-identity)
  - Holochain Holo conductors
  - Lightning wallet libraries (LDK, LND clients)
  - BIP-32 HD wallet apps (any HW-wallet companion, any seed-managing
    desktop wallet)
  - BIP-322 message-signing tools
  - Agent-identity systems using `did:key`, `did:web`, `did:plc`
  - DataCommons / personal-data-store projects in the user-sovereignty
    lineage

- **Strategic alignment.** The harness's stated purpose is to govern
  domains where correctness loss is silent and high-stakes.
  Cryptographic-identity is one of the canonical "silent and
  high-stakes" categories — a wrong derivation path, a wrong
  encryption-mode invariant, or a broken signature scheme produces
  data corruption (or worse, security loss) months later, often
  irrecoverably.

- **The product framing is having a moment.** YouBase's own fixtures
  (`HealthProfile`, `Allergy`, `Immunization` in `test/fixtures/`)
  reveal the original product framing: personal health records under
  cryptographic user control. The HIPAA-escape-hatch / EU data-
  portability / self-sovereign identity space is materially more
  active in 2026 than it was in 2016, when YouBase's original
  authoring stopped. A governance module that catches this category
  signals harness coverage of a growing surface.

## Why Now

- **First-real-brownfield-hit signal.** Third of three gaps from the
  YouBase onboarding pass (with OPP-0008, OPP-0009). The harness's
  first non-trivial brownfield consumer immediately surfaced a domain
  hole in addition to the stack and data holes.

- **Identity-stack churn is active.** The cryptographic-library
  ecosystem is in mid-migration:

  - `@noble/*` family is becoming the canonical Node crypto stack
  - `request`-style HTTP clients are being replaced by native `fetch`
  - Post-quantum signature schemes (Dilithium, Falcon) are nearing
    standardization
  - WebCrypto API coverage is filling out in browsers and Workers

  A consumer in this category needs governance *now* to anchor
  upgrade decisions during this churn — not after.

- **Differentiates auto-harness's coverage from EVM-centric
  frameworks.** Most existing governance tooling for "Web3" projects
  is EVM-shaped (Foundry's own conventions, OpenZeppelin patterns,
  Etherscan-as-source-of-truth). A first-class cryptographic-identity
  domain module signals that the harness covers the non-EVM crypto
  surface too — Bitcoin / Lightning / Solid / Holochain / personal-
  data-store projects don't have to pretend they're Ethereum projects
  to get governance.

- **Discovery-loop momentum.** Filing as part of the three-OPP YouBase
  batch keeps the brownfield-discovery pattern coherent (see OPP-0008,
  OPP-0009).

## Risks / Open Questions

### Risks

- **Scope creep into "personal data store" framing.** The
  cryptographic-identity category has a natural product-framed twin:
  *personal data stores* (PDS). PDS projects (Solid, Webnative,
  YouBase, Holochain) share most of the cryptographic-identity
  governance concerns *plus* additional ones (data-portability
  contracts, schema interoperability, federation patterns). Two
  options:
  - (A) Ship `domains/cryptographic-identity` narrowly (crypto
    primitives + key custody). PDS framing is a separate future OPP.
  - (B) Ship `domains/personal-data-store` broader from the start,
    treating crypto-identity as a sub-concern.
  Risk of (B): the module becomes a kitchen sink that loses precision.
  Risk of (A): consumers in PDS space have to activate multiple
  small modules and re-derive the data-portability governance.
  Recommend (A) for v1.

- **Overlap with `domains/web3`.** A project using BIP39 + Ethereum
  (e.g., a mnemonic-managing wallet that also signs Ethereum txns
  via secp256k1) would activate both modules. The overlap is at
  the cryptographic-primitive level — both modules care about
  `@noble/secp256k1` upgrades. This is OK in principle (modules
  compose) but the companion-rule wiring needs to avoid duplicate
  firings. Decide before shipping.

- **Required-artifact pressure on small projects.** The list of
  candidate artifacts (encryption-mode invariants, key-management
  policy, library-audit log, signature-scheme migration) is long.
  Each one is governance-valuable but also overhead. A v1 with
  zero required artifacts (matching `domains/web3`'s existing
  no-required-artifacts shape) is the right starting point;
  promote to required-artifact gates one at a time as real
  consumer pain surfaces.

- **Module is consumer-side dogfood only.** Auto-harness itself
  doesn't have a cryptographic-identity surface. The dogfood for
  this module is necessarily a consumer project (YouBase is the
  obvious candidate; bdits/municipal-brain or another consumer
  could be a second). Same caveat as OPP-0009.

### Open Questions

- **Naming.** Candidates and trade-offs:

  | Name | Captures | Misses / Risks |
  | ---- | -------- | -------------- |
  | `domains/cryptographic-identity` | Key custody + crypto primitives | "Identity" implies SSI/DID framing; some projects are HD-wallet without being identity |
  | `domains/hd-wallet` | BIP32 specifically | Misses ed25519, non-HD identity |
  | `domains/personal-data-store` | Product frame | Implies data-portability concerns; broader than crypto-identity |
  | `domains/self-sovereign-identity` | DID/VC ecosystem | Misses Bitcoin-style HD wallets that aren't framed as SSI |
  | `domains/non-eth-crypto` | Disambiguates from web3 | Negatively defined; aging poorly as the category grows |

  Recommend: `domains/cryptographic-identity`. Accept that "identity"
  has a SSI connotation but treat it as a deliberate frame (these
  projects *are* fundamentally about user-owned cryptographic identity,
  even when the product is a wallet).

- **Trigger signals.** What does the `harness-onboarding` skill look
  for to recommend the module? Candidate list:
  `bip39`, `hdkey`, `@noble/secp256k1`, `@noble/curves`, `ecdsa`,
  `ed25519`, `tweetnacl`, `@inrupt/solid-client`, `webnative`,
  `did:key`, `did-resolver`, `bls-eth-wasm`, `secp256k1`. Recommend:
  start with `bip39` OR `hdkey` OR `@noble/*` as the strongest
  signals; expand the list in PRD review.

- **Required artifacts for v1.** Options ordered by priority:
  1. `docs/crypto/library-audit-log.md` — append-only record of
     cryptographic dependency upgrades with date, reviewer, before/
     after fixture-test status
  2. `docs/crypto/encryption-modes.md` — load-bearing encryption-mode
     invariants for the project (analog of an ADR but data-format-
     anchored)
  3. `docs/crypto/key-management-policy.md` — mnemonic backup
     discipline, key rotation, recovery, custody
  4. `docs/crypto/signature-scheme.md` — current scheme, migration
     plan if any

  Recommend: ship v1 with zero required artifacts; promote one or two
  in a v2 OPP after real consumer contact (matching `domains/web3`'s
  existing posture).

- **Companion rules.** Should changes to files matching
  `^node_modules/(@noble|bip39|hdkey|ecdsa)/.*` (or the equivalent
  `package.json` deps) require an ADR in the same PR? Yes in principle
  — that's the upgrade-audit governance value. But defer to v2;
  v1 establishes the category.

- **Sensitive paths.** Anywhere `bip39`, `hdkey`, raw secp256k1 ops,
  or AES encryption with key-derived-from-pubkey-or-privkey happen
  should be marked sensitive. The list is per-project and is best
  declared in the module YAML, not hardcoded. Defer to v2.

- **Relationship to `domains/web3`.** Recommend: orthogonal, both
  activatable. A project using BIP39 + Ethereum activates both.
  Document in both modules' READMEs that they compose.

### Design Options Under Consideration

| Option | Mechanism | Coverage | Required artifacts (v1) | Blast radius |
|--------|-----------|----------|------------------------|--------------|
| **A — `domains/cryptographic-identity`** narrow | Covers BIP39/BIP32/ECDSA HD wallets + DID/SSI primitives; orthogonal to `domains/web3` | Cryptographic-identity surface | None | Tiny: new module YAML + README |
| **B — `domains/personal-data-store`** product-framed | Covers crypto-identity *plus* data-portability + federation patterns | PDS projects (Solid, Webnative, YouBase, Holochain) | None | Small: new module + README articulating PDS scope |
| **C — `domains/hd-wallet`** narrow on BIP32 | BIP32 HD wallet apps specifically | Bitcoin-style HD wallets | None | Tiny but risks proliferation (DID/SSI defers) |
| **D — Expand `domains/web3`** to non-Ethereum | Rewrite `domains/web3` triggers + scope to cover all of web3 | Cryptographic-identity + Ethereum | None | Large: muddles `domains/web3`'s well-established meaning |
| **E — Defer; document the gap** | Update the skill to explicitly say "domains: leave empty for non-Ethereum cryptographic-identity projects" | None | N/A | Tiny but punts |

**Initial bias (subject to PRD validation): A.** Ship
`domains/cryptographic-identity` as a new sibling to `domains/web3` —
narrow scope (crypto primitives + key custody, no PDS framing yet),
zero required artifacts in v1, orthogonal to `domains/web3`. The PDS
framing (Option B) is appealing but premature; it's a future OPP if
multiple PDS consumers exercise the catalog. Option D (expand web3) is
explicitly *not* preferred — "web3" has acquired a specific Ethereum
meaning in industry usage; broadening it would be a rename, not a
non-breaking change.

## Disposition

<!--
Empty while Status: proposed. Populated on transition.
-->

## Promotion

<!--
Empty until accepted; then link to PRD-NNNN.
-->
