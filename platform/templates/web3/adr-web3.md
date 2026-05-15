<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-NNNN: [Title]

**Status:** Proposed / Accepted / Superseded / Deprecated
**Date:** YYYY-MM-DD
**Author:** @owner
**Reviewers:** @owner
**Module:** `domains/web3`

> This is the Web3 variant of the ADR template. Use it for decisions involving chains,
> contracts, scoring rules, data providers, or token architecture. It extends the base
> ADR template with Web3-specific fields. Delete this instruction block before committing.

---

## Context

*(State the problem, constraints, and why a decision is needed. For Web3 ADRs, include:
which chain(s) are affected, whether the decision involves writing to a blockchain, and
what the rate limit or data availability constraints are.)*

---

## Decision

*(State the decision in one or two crisp sentences.)*

---

## Web3-Specific Fields

| Field | Value |
|-------|-------|
| Chain(s) affected | [[Base / Ethereum / Solana / All EVM / etc.]] |
| Involves writing to chain | [[Yes — Tier 5, irreversible / No — read-only]] |
| Reversible after deployment | [[Yes / No — immutable contract / Partial — see consequences]] |
| New API calls added | [[Yes — N calls, see rate limit impact / No]] |
| Rate limit impact | [[+N calls per analysis — budget updated in chain-config.md / None]] |
| UNKNOWN propagation affected | [[Yes — see consequences / No]] |

---

## Consequences

### Positive

- *(Outcome supported by this decision.)*

### Negative

- *(Tradeoff introduced. For Web3 decisions, explicitly address irreversibility: if a contract
  is deployed, can this decision be changed later? If not, say so.)*

### Watch

- *(Conditions that should trigger reevaluation. For Web3, include: rate limit tier changes,
  chain deprecation or migration, regulatory changes in relevant jurisdictions.)*

---

## Alternatives Considered

| Alternative | Why rejected |
|-------------|--------------|
| *(Option)* | *(Reason — include why this alternative would have been worse for the specific Web3 constraints: rate limits, irreversibility, UNKNOWN propagation, determinism)* |

---

## Evidence Requirement

*(For scoring or signal decisions: what specific on-chain data supports this decision?
List the BaseScan or RPC endpoints that provide the evidence this ADR relies on.)*

| Evidence | Source | Availability |
|---------|--------|-------------|
| *(on-chain signal)* | *(API endpoint)* | *(always available / conditional / rate-limited)* |

---

## UNKNOWN Handling

*(For any decision that affects how signals are computed: how does this decision handle
the case where data is unavailable? UNKNOWN must propagate — it cannot be suppressed.)*

- When data source returns an error: *(UNKNOWN propagates / retry N times then UNKNOWN / ...)*
- When rate limit is hit: *(UNKNOWN propagates / queue and retry / ...)*
- When contract is unverified: *(UNKNOWN for all source-dependent signals / ...)*
