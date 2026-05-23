<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Web3 Risk Register

<!-- Source: platform/profiles/domains/web3 -->
<!-- Use alongside the main risk register (templates/risk-register.md). -->
<!-- This supplement captures blockchain-specific risks that the general register -->
<!-- does not adequately model. -->
<!-- Security note: Web3 skills from the full ClawHub registry are not curated — -->
<!-- run azhua-skill-vetter before installing any Web3 registry skill. -->

**Owner:** [[RISK_OWNER]]
**Last reviewed:** YYYY-MM-DD
**Chain(s) in scope:** [[CHAIN_NAMES]] (see `docs/architecture/chain-config.md`)

---

## Open Risks

| ID | Category | Risk | Likelihood | Impact | Mitigation | Owner | Status |
| -- | -------- | ---- | ---------- | ------ | ---------- | ----- | ------ |
| W-001 | Key management | Private key compromise | Low | Critical | Hardware wallet or HSM; no plaintext keys in env vars | [[OWNER]] | Open |
| W-002 | Smart contract | Logic vulnerability in [[CONTRACT]] | Med | High | Audit before mainnet; formal verification if value > $1M | [[OWNER]] | Open |
| W-003 | Smart contract | Reentrancy attack | Med | High | Checks-effects-interactions pattern enforced; static analysis in CI | [[OWNER]] | Open |
| W-004 | Oracle | Price feed manipulation / stale data | Med | High | Multi-oracle aggregation; circuit breaker at [[DEVIATION_THRESHOLD]]% | [[OWNER]] | Open |
| W-005 | MEV / Frontrunning | Transaction ordering exploitation | Med | Med | Commit-reveal where applicable; slippage tolerance [[TOLERANCE]]% | [[OWNER]] | Open |
| W-006 | Gas | Gas price spike blocking critical operations | Med | Med | Gas price oracle; fallback RPC; user-facing retry guidance | [[OWNER]] | Open |
| W-007 | Upgrade | Proxy upgrade introduces regression | Low | High | Upgrade dry-run on fork; Tier 5 review gate active | [[OWNER]] | Open |
| W-008 | Liquidity | Liquidity withdrawal causing slippage | Med | Med | Liquidity monitoring; circuit breaker at [[THRESHOLD]] | [[OWNER]] | Open |
| W-009 | Regulatory | Jurisdiction-specific compliance exposure | Low | High | Legal review for target markets; geo-blocking if required | [[OWNER]] | Open |
| W-010 | Wallet | User wallet drained via malicious approval | Low | Critical | Approval amount limits; revoke guidance in docs; security warnings in UI | [[OWNER]] | Open |

Add or remove rows. Delete risk categories that do not apply to this project.

---

## Category Reference

### Key Management

Risks involving private keys, seed phrases, and signing authority. Any compromise is
typically irreversible — funds or contract control cannot be recovered.

**Required controls for production:** Hardware wallet or HSM for high-value keys;
no private keys in `.env` files; key rotation policy documented.

### Smart Contract

Risks from code vulnerabilities. On-chain logic is immutable after deployment (unless
upgradeable proxy pattern is used); bugs cannot be patched without a migration.

**Required controls before mainnet:** Static analysis (Slither or equivalent); manual
audit for contracts holding > [[AUDIT_THRESHOLD]] in value; test coverage ≥ 90%.

### Oracle

Risks from price feeds or external data sources. A manipulated oracle can drain funds
through arbitrage or trigger incorrect liquidations.

**Required controls:** Multiple oracle sources; deviation threshold with circuit breaker;
staleness check (reject data older than [[STALENESS_LIMIT]] seconds).

### MEV / Frontrunning

Risks from transaction ordering. Miners and validators can reorder transactions to
extract value from users.

**Applicable when:** DEX trades, liquidations, Dutch auctions, or any operation where
order affects outcome.

### Upgrade Risk

Risks from proxy contract upgrades. An incorrect upgrade can corrupt storage, brick
the contract, or introduce vulnerabilities.

**Required controls:** All upgrades require Tier 5 review (see `harness-web3` skill);
upgrade tested on a mainnet fork before execution; rollback plan documented.

---

## UNKNOWN State Propagation

Per the `harness-web3` skill governance rules: any risk signal that cannot be verified
with on-chain evidence must be recorded as UNKNOWN, not assumed safe. UNKNOWN risks
that affect Tier 4+ operations block deployment until resolved.

| Signal | Current State | Evidence | Resolved |
| ------ | ------------- | -------- | -------- |
| [[RISK_SIGNAL]] | UNKNOWN / Verified safe / Verified risky | [[EVIDENCE_LINK_OR_NONE]] | Yes / No |

---

## Closed Risks

| ID | Category | Risk | Closed Date | Resolution |
| -- | -------- | ---- | ----------- | ---------- |
| W-00X | [[CATEGORY]] | [[RISK]] | YYYY-MM-DD | [[HOW_RESOLVED]] |

---

## Reference

| Resource | Path |
| -------- | ---- |
| Main risk register | `docs/security/risk-register.md` |
| Chain configuration | `docs/architecture/chain-config.md` |
| Contract registry | `docs/architecture/contract-registry.md` |
| Web3 governance skill | `platform/skills/harness-web3/SKILL.md` |
| Web3 ADR template | `platform/templates/web3/adr-web3.md` |
| Trust model | `platform/core/kernel/base/trust-model.md` |
