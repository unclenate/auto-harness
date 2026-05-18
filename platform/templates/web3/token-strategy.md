<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Token Strategy

**Owner:** @owner
**Last updated:** YYYY-MM-DD
**Status:** [[Planned / Designed / Deployed]]
**Module:** `domains/web3`

This document defines the token component of the project. It must exist and be reviewed
before any token-related code is written. Token strategy has legal, community, and incentive
implications that compound over time and are difficult to reverse after launch.

If a token is not planned, delete this file and remove it from the module's optional artifacts.

---

## Token Overview

| Field | Value |
|-------|-------|
| Token name | [[TOKEN_NAME]] |
| Token symbol | `[[SYMBOL]]` |
| Chain | [[Base / Ethereum / etc.]] |
| Standard | [[ERC-20 / ERC-721 / SPL / etc.]] |
| Contract status | [[Not deployed / Deployed at 0x...]] |
| Launch strategy | [[Product first — no token until product ships / TBD]] |

**One-sentence utility statement:**
*(What does holding or using this token enable? Be specific. "Governance and fees" is not
specific enough.)*

---

## Fee Structure

*(If the token has a transaction tax or fee mechanism, document it here. Every fee
allocation must have a named recipient and a rationale.)*

| Fee type | Rate | Recipient | Rationale |
|----------|------|-----------|-----------|
| [[Transaction fee]] | [[X%]] | [[Development treasury]] | [[Funds ongoing development]] |
| [[Transaction fee]] | [[X%]] | [[Community allocation]] | [[Rewards contributors and early holders]] |
| [[Transaction fee]] | [[X%]] | [[External cause (e.g., SWC Foundation)]] | [[Community trust signal — see below]] |
| **Total** | **[[X%]]** | | |

**External cause rationale:**
*(If a portion of fees is allocated to an external cause or nonprofit, document the
community trust rationale here. This is a public commitment — it must be honored consistently.)*

---

## Contributor Vesting

*(If contributors are compensated in vested tokens rather than cash, define the vesting
schedule and governance here.)*

| Contributor role | Allocation | Vesting schedule | Cliff |
|-----------------|-----------|-----------------|-------|
| [[Engineering lead]] | [[X% of supply]] | [[24 months linear]] | [[6 months]] |
| [[Community lead]] | [[X% of supply]] | [[24 months linear]] | [[6 months]] |
| [[Community contributors]] | [[X% of supply]] | [[Per milestone — see below]] | [[None]] |

**Milestone-based vesting (contributors):**

| Milestone | Token allocation | Trigger condition |
|-----------|-----------------|-------------------|
| [[Phase 1 delivery]] | [[X tokens]] | [[PR merged and validators green]] |
| [[Community beta launch]] | [[X tokens]] | [[N users onboarded]] |

---

## Community Governance

*(Describe the governance model if token holders have voting rights over product direction,
treasury allocation, or other decisions.)*

**Governance scope:**

- What can token holders vote on?
- What is explicitly outside governance scope? (e.g., security decisions, legal compliance)
- What quorum is required for a vote to be valid?
- What is the voting period?

**Governance tooling:** [[Snapshot / On-chain voting / Forum-based / TBD]]

---

## Supply Schedule

| Allocation | Amount | % of supply | Vesting |
|-----------|--------|-------------|---------|
| [[Team]] | | | [[see above]] |
| [[Community / airdrop]] | | | |
| [[Treasury]] | | | |
| [[Liquidity provision]] | | | |
| [[Public sale]] | | | |
| **Total supply** | **[[N]]** | **100%** | |

---

## Legal and Regulatory Status

| Question | Status | Notes |
|----------|--------|-------|
| Securities law review | [[Not started / In progress / Reviewed — see docs/legal/]] | |
| Jurisdiction | [[US / International / TBD]] | |
| KYC/AML requirements | [[Not applicable / Required for sale]] | |
| "Not financial advice" disclaimer in all outputs | [[Yes / No — must be Yes]] | |

**Required before public token launch:**

- [ ] Legal review completed and documented
- [ ] Disclaimer present in all scored outputs
- [ ] Token strategy reviewed by all named contributors

---

## Open Decisions

| ID | Question | Owner | Target |
|----|----------|-------|--------|
| | [[Is a token planned? When? What utility?]] | | |
| | [[Which chain for token deployment?]] | | |
| | [[Governance tooling selection]] | | |
