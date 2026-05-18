<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Chain Configuration

**Owner:** @owner
**Last updated:** YYYY-MM-DD
**Module:** `domains/web3`

This document is the authoritative record of every blockchain the system integrates with,
the rate limit budget each integration carries, and the phased expansion plan. It is
required by the `domains/web3` overlay and must be updated when any chain configuration,
API endpoint, or rate limit budget changes.

---

## Supported Chains

### Chain: [[CHAIN_NAME]] (MVP)

| Field | Value |
|-------|-------|
| Chain ID | [[CHAIN_ID]] |
| Network | [[mainnet / testnet]] |
| Explorer | [[BaseScan / Etherscan / Solscan / etc.]] |
| Explorer API base URL | [[https://api.basescan.org/api]] |
| RPC endpoint | [[https://mainnet.base.org]] |
| API tier | [[free / pro / enterprise]] |
| Rate limit | [[5 req/s, 100k req/day]] |
| API key env var | `[[ENV_VAR_NAME]]` |

**Rate limit budget per analysis operation:**

| Call | Purpose | Count |
|------|---------|-------|
| [[endpoint name]] | [[what it fetches]] | 1 |
| [[endpoint name]] | [[what it fetches]] | 1 |
| **Total per analysis** | | [[N]] |

**Remaining daily budget at [[N]] analyses/day:**

```text
100,000 calls/day ÷ N calls/analysis = X analyses/day before exhaustion
```

**Behavior when rate limit is exhausted:**
*(How does the system respond? Queue and retry? Fail with UNKNOWN? Return cached result?
This must be a deliberate choice, not an unhandled error.)*

---

## Planned Chain Expansion

| Phase | Chain | Chain ID | Timeline | Blocker |
|-------|-------|----------|----------|---------|
| Phase 2 | [[Ethereum mainnet]] | 1 | [[Q3 2024]] | [[Same tooling, needs chain config PR]] |
| Phase 3+ | [[Solana]] | N/A | [[TBD]] | [[Different RPC, different data model — requires new ADR]] |

**Note on EVM vs. non-EVM expansion:**
Adding an EVM-compatible chain (Ethereum, Polygon, Arbitrum, etc.) requires chain config
and rate limit updates but the same client tooling. Adding a non-EVM chain (Solana, Aptos,
etc.) requires a new client, new data models, and a new ADR before any implementation starts.

---

## Chain Client Design

*(Describe how the chain client is structured to support multi-chain expansion without
hardcoding chain assumptions.)*

Example pattern: parameterized EVM client where chain configs are registered by chain ID,
not hardcoded:

```python
CHAIN_CONFIGS = {
    8453: ChainConfig(
        name="Base",
        explorer_api="https://api.basescan.org/api",
        rate_limit=RateLimit(requests_per_second=5, daily_limit=100_000),
    ),
}
```

This design ensures that adding Ethereum mainnet in Phase 2 is a config registration,
not a code change.

---

## Rate Limit Incident History

| Date | Chain | Incident | Resolution | ADR |
|------|-------|----------|------------|-----|
| | | | | |

---

## Open Questions

*(List unresolved questions about chain integration. These must be resolved before any
production traffic is served on a new chain.)*

| ID | Question | Owner | Target |
|----|----------|-------|--------|
| | | | |
