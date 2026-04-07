# Contract Registry

**Owner:** @owner
**Last updated:** YYYY-MM-DD
**Module:** `domains/web3`

This document tracks every smart contract the system deploys or analyzes at a structural
level. Contract addresses are immutable facts — once a contract is deployed, its address
and bytecode are permanent. This registry is the provenance record for what is deployed
where and what the system knows about it.

---

## Deployed Contracts

*(Fill in one block per contract this system deploys. If the system only reads contracts
deployed by others, use the "Analyzed Contracts" section below and leave this empty.)*

### Contract: [[CONTRACT_NAME]]

| Field | Value |
|-------|-------|
| Chain | [[Base / Ethereum / etc.]] |
| Chain ID | [[8453]] |
| Address | `[[0x...]]` |
| Deployment date | [[YYYY-MM-DD]] |
| Deployed by | `[[0x...]]` (deployer wallet) |
| Verified on explorer | [[Yes / No]] |
| Explorer link | [[https://basescan.org/address/0x...]] |
| Source code | `[[contracts/ContractName.sol]]` |
| ABI | `[[abi/ContractName.json]]` |
| Audit status | [[Unaudited / Audited by X on YYYY-MM-DD]] |
| Upgrade mechanism | [[None — immutable / Proxy pattern — see ADR-XXXX]] |

**Dangerous functions present:**

| Function | Risk | Notes |
|----------|------|-------|
| [[function name]] | [[description of risk]] | [[e.g., owner-only, can drain, can pause]] |

**Deployment ADR:** [ADR-XXXX](../adr/ADR-XXXX-contract-deployment.md)

---

## Analyzed Contracts

*(For systems that analyze contracts deployed by others — e.g., risk analytics platforms —
track which contract types and surfaces are in scope for analysis.)*

### Analysis Scope

| Signal category | What is analyzed | Data source |
|-----------------|-----------------|-------------|
| [[Contract verification]] | [[Is source code published on explorer?]] | [[BaseScan /api?module=contract&action=getsourcecode]] |
| [[Dangerous functions]] | [[Presence of mint, pause, blacklist functions in source]] | [[Source code analysis]] |
| [[Holder distribution]] | [[Top-10 holder concentration, deployer in holders]] | [[BaseScan token holders endpoint]] |
| [[Deployer lineage]] | [[Prior contracts deployed by same address]] | [[BaseScan address tx history]] |

**Out of scope for analysis (current phase):**

| Feature | Why deferred | ADR / reference |
|---------|-------------|-----------------|
| [[Bytecode analysis for unverified contracts]] | [[No source means pattern matching only]] | [[ADR-XXXX]] |
| [[Cross-chain deployer tracking]] | [[Multi-chain expansion not yet in scope]] | [[docs/web3/chain-config.md Phase 3]] |

---

## Contract Change Log

| Date | Contract | Change | On-chain consequence | ADR | Approved by |
|------|----------|--------|---------------------|-----|-------------|
| | | | | | |

**Note:** Any change to this registry that reflects a new deployed contract must be
accompanied by a deployment ADR. Contract deployments are Tier 5 actions — irreversible
and permanently visible on-chain.
