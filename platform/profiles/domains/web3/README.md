<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Domain Overlay: Web3

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay governs systems that read from or write to a blockchain — risk analytics platforms,
token-integrated products, on-chain data consumers, and contract-deploying applications. It
isolates a set of architectural concerns that have no analog in traditional software and which,
if treated as edge cases, will produce correctness failures, security incidents, or community
trust damage.

Activate this overlay for any project where a blockchain is a first-class data source, a
transaction surface, or an organizational infrastructure layer (token, governance, treasury).

---

## What Makes Web3 Architecturally Different

These are not preferences — they are hard requirements derived from the nature of the technology.

### 1. The Blockchain Is Not Your Database

The source of truth for on-chain data is the chain itself, accessed through explorer APIs
(BaseScan, Etherscan, Solana RPC, etc.). You do not own this database. You cannot fix its
data. You cannot guarantee its availability.

**Required behavior:**

- Missing data is not the same as data that doesn't exist. A rate limit error and a genuinely
  absent record are different failure modes and must be represented differently.
- `UNKNOWN` is a first-class output state, not an error. A signal that cannot be computed
  because data is unavailable must return `UNKNOWN` — not null, not zero, not a synthetic
  default. Suppressing `UNKNOWN` to produce cleaner-looking output is a correctness failure.
- Data has freshness. A holder distribution fetched two hours ago may not reflect current
  state. The system must represent data timestamps honestly.

### 2. Deployed Smart Contracts Cannot Be Patched

A contract deployed to a blockchain is immutable. If dangerous functionality is baked in at
deployment, that is a permanent fact about that contract. Code review and auditing happen
before deployment — not after.

**Required behavior:**

- Any change to contract source code, ABI, or deployment parameters requires human review
  before the change is applied. The companion rule enforces this.
- "Verified contract" means the deployer published source code to an explorer. It does not
  mean the code is safe. These are different claims.
- Agent-generated contract code requires explicit human authorization before any deployment.
  Deployment is a Tier 5 action — irreversible and permanent.

### 3. Pseudonymous Actors

Deployers, holders, and counterparties are wallet addresses, not registered entities. A single
actor may control multiple wallets across multiple projects. Attribution is probabilistic based
on behavioral patterns — it is never certain.

**Required behavior:**

- "Deployer history" means contract deployment behavior linked to an address, not a person.
- Connections between addresses must be reported as what the chain shows, not what is inferred.
  Do not fabricate connections the data does not support.
- Attribution language must be explicit about certainty level: "same deployer pattern" is
  not the same as "same legal entity."

### 4. Rate Limits Are a First-Class Architectural Constraint

Blockchain explorer APIs impose hard rate limits (e.g., BaseScan free tier: 5 req/s,
100k req/day). Each analysis operation may require 7–11 API calls. Rate limits are not edge
cases — they are load-bearing constraints that shape the entire async architecture.

**Required behavior:**

- Every API call must be counted against the declared rate limit budget in `docs/web3/chain-config.md`.
  Adding calls without updating the budget is an architecture gap, not a detail.
- Rate limiting must be implemented with an async semaphore or equivalent mechanism. Never
  assume unlimited throughput.
- The rate limit budget must be re-evaluated in review any time new API calls are added.

### 5. UNKNOWN Must Propagate Explicitly

This deserves its own section separate from point 1 because it is the most common correctness
failure in analytical Web3 systems.

**The rule:** If a signal cannot be computed, it must return `UNKNOWN`, and that `UNKNOWN`
must propagate up through any aggregation that depends on it.

- An aggregate score computed from partial signals with suppressed `UNKNOWN` values is
  not an aggregate score — it is a misleading number.
- `UNKNOWN` is not a bug state to be caught and handled — it is a valid, honest output.
- Systems that hide `UNKNOWN` to produce smoother outputs will eventually produce
  confident-looking wrong results. That is worse than showing `UNKNOWN`.

### 6. Token and Governance Layers Are Optional but Structural

Some Web3 projects include a token with transaction fees, contributor vesting, community
governance, or on-chain treasury management. These create organizational structures, incentive
models, and legal exposure — not just product features.

**When a token is planned:** `docs/web3/token-strategy.md` must exist before any
token-related code is written. Token strategy has legal, community, and incentive implications
that compound over time and cannot be reversed easily after launch.

### 7. Community Trust Is a Product Metric

In Web3, community trust is built through observable behavior: shipping product before tokens,
transparent incremental delivery, and verifiable on-chain evidence in every output. This
directly determines whether a community commits resources, promotes the product, and tolerates
early rough edges.

**Required behavior:**

- Every scored output must include a disclaimer that it is not financial advice.
- Evidence must be visible and linked to the specific on-chain data that produced it.
  Black-box scores erode trust. Explainable scores build it.
- `UNKNOWN` must be shown, not hidden. A system that suppresses uncertainty looks more
  confident than it is — exactly the wrong signal for a trust-sensitive audience.

### 8. Regulatory Ambiguity Is Structural, Not Temporary

Financial advice regulations, token issuance law, and liability for shared reports are unclear
and evolving across jurisdictions. Design for the ambiguity — don't assume clarity is coming.

**Required behavior:**

- Every output includes a disclaimer: "Not financial advice."
- The system reports signals — it does not issue verdicts. "HIGH risk" is not "this is a scam."
- `UNKNOWN` is never suppressed to produce cleaner output. Honest uncertainty is a legal
  and ethical requirement, not just a UX preference.
- Legal review is required before any public external exposure involving scored output.

---

## Required Artifact: `docs/web3/chain-config.md`

Documents every chain the system integrates with:

- Chain ID, name, and explorer API endpoint
- Rate limit budget per tier (free, pro, enterprise)
- Estimated API calls per analysis operation
- Phased expansion plan (MVP chain → next chain → long-term)
- Behavior when rate limit budget is exhausted

Use the template at `platform/templates/web3/chain-config.md`.

---

## Optional Artifacts

**`docs/web3/contract-registry.md`** — activate when the system deploys or tracks specific
contracts. Documents addresses (immutable facts), verification status, and analysis scope.

**`docs/web3/token-strategy.md`** — activate when a token is planned. Documents utility,
fee allocation, vesting, and governance. Must exist before token-related code is written.

---

## Companion Rules

**Chain configuration changes → ADR required.**
Chain selection has long-term lock-in. Any change to chain config, explorer endpoint, or
multi-chain routing requires an ADR documenting rationale and rate limit implications.

**Contract or wallet changes → risk register or architecture update or ADR required.**
Smart contract changes are irreversible. Any change to contract source, ABI, or wallet
signing surface requires a companion update to the risk register, architecture overview,
or an ADR.

**Scoring/signal rule changes → ADR required.**
Scoring rules are locked decisions in analytical systems. Changes must be recorded as ADRs
to preserve determinism, explainability, and auditability. A score that changes for
unexplained reasons destroys community trust.

---

## Review Gates

1. **Irreversibility gate** — Any write to a blockchain is Tier 5. Human authorization
   required. Read-only analysis does not trigger this gate.

2. **UNKNOWN propagation gate** — Reviewers verify that `UNKNOWN` values propagate
   correctly and are not suppressed at any aggregation boundary.

3. **Evidence gate** — Every flag or scored signal references specific on-chain data.
   No unexplained scores ship.

4. **Rate limit gate** — Every new API call counted against the declared budget.
   Budget updated before merge.

---

## How This Overlay Composes

| Pair with | When |
|-----------|------|
| `stacks/python` | Python is the dominant Web3 analysis stack (httpx, Pydantic, FastAPI) |
| `architectures/api-service` | Analytics exposed as a REST or GraphQL API |
| `architectures/event-driven` | On-chain event indexing and stream processing |
| `data/relational-sql` | Primary structured store for results and contract metadata |
| `delivery/production-saas` | Platform serves real users with real money at stake |
| `delivery/prototype` | Early signal validation — UNKNOWN and security rules still apply |

---

## Agent Behavior in Web3 Context

Beyond the standard trust tier model, agents must observe:

- **Never write to a blockchain** without explicit human authorization and a named owner.
  Contract deployment and transaction signing are Tier 5 regardless of manifest maturity.
- **Never suppress `UNKNOWN`** to produce cleaner output. If data is unavailable, say so.
- **Never fabricate on-chain connections.** Attribution between addresses is observational —
  "same pattern" is not "same entity."
- **Never add API calls without declaring them** in `docs/web3/chain-config.md`.
  Rate limit budget is a hard constraint.
- **Treat all contract data as potentially adversarial.** Token source code is published
  by the deployer — it may be designed to mislead. Validate at every boundary.

---

## Web3-Specific Templates

| Template | Use when |
|----------|---------|
| `platform/templates/web3/chain-config.md` | Documenting chain integrations and rate limits |
| `platform/templates/web3/contract-registry.md` | Tracking deployed or analyzed contracts |
| `platform/templates/web3/token-strategy.md` | Planning a token component |
| `platform/templates/web3/adr-web3.md` | Recording chain, scoring, or contract architecture decisions |
| `platform/templates/web3/web3-intake-supplement.md` | Extending discovery intake for Web3 projects |

See `platform/compositions/web3-risk-analytics.yaml` for the reference composition.

---

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- Skill: [`harness-web3`](../../../skills/harness-web3/SKILL.md)
- Templates: `platform/templates/web3/`
- Related module: [`domains/cryptographic-identity`](../cryptographic-identity/README.md)
