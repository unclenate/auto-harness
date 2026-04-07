# Web3 Discovery Intake — Supplement

**Use with:** `platform/templates/discovery/intake-questionnaire.md` Section 8 (Technical Context)

Complete this supplement when the intake questionnaire reveals the project is Web3-integrated —
meaning a blockchain is a data source, transaction surface, or organizational layer (token,
governance, treasury). Fill in this supplement before moving to requirements capture.

If the answer to "Does this project read from or write to a blockchain?" is no, discard this
supplement.

---

## Section 9 — Blockchain Integration

### 9.1 — Read or Write?

- [ ] **Read-only** — the system consumes on-chain data (analysis, display, indexing)
- [ ] **Write** — the system submits transactions or deploys contracts
- [ ] **Both** — reads data and writes state

> **Why this matters:** Read-only and write systems have fundamentally different risk and
> governance profiles. A read-only analytics platform has no Tier 5 actions. A system that
> writes to chain has permanent, irreversible consequences for every deployment and transaction.

**If write:** What does the system write?
*(contract deployment / token transfer / vote submission / other — describe)*

---

### 9.2 — Which Chain(s)?

**MVP chain:**

| Field | Answer |
|-------|--------|
| Chain name | |
| Chain ID | |
| EVM compatible? | [ ] Yes [ ] No |
| Explorer API | [[BaseScan / Etherscan / Solscan / other]] |
| Explorer API tier | [[Free (5 req/s) / Pro / Enterprise / Unknown]] |

**Planned expansion chains:**

*(List any chains after MVP, with rough timeline. If unknown, say so explicitly.)*

| Chain | Timeline | EVM? | Blocker |
|-------|----------|------|---------|
| | | | |

---

### 9.3 — Data Provider and Rate Limits

**Primary data source:** *(BaseScan, Etherscan, custom node, other)*

| Question | Answer |
|----------|--------|
| API tier | [[Free / Pro / Enterprise]] |
| Requests per second | |
| Daily request limit | |
| Estimated API calls per analysis/operation | |
| Max operations/day within budget | *(calculated: daily limit ÷ calls per op)* |

**What happens when rate limit is exhausted?**
*(This must be answered before architecture begins — it determines whether queuing,
caching, or graceful degradation is needed.)*

---

### 9.4 — UNKNOWN State Policy

> This is the most important question for analytical Web3 systems. A signal that cannot
> be computed because data is unavailable must return `UNKNOWN`. How should the system
> behave?

**When a required data call fails or returns no data:**

- [ ] Return `UNKNOWN` for that signal only — aggregate continues with remaining signals
- [ ] Return `UNKNOWN` for the entire analysis if any signal is unknown
- [ ] Retry N times, then return `UNKNOWN`
- [ ] Other: *(describe)*

**What must the user see when `UNKNOWN` is present?**
*(Describe the UX or API response — must UNKNOWN be visible, or can it be hidden?)*

**Non-negotiable:** `UNKNOWN` values must never be silently converted to 0, null, or a
neutral default to produce cleaner-looking output. If the project's UX requires hiding
`UNKNOWN`, that is a product design decision that requires explicit human sign-off, not
an implementation shortcut.

---

### 9.5 — Smart Contracts

**Does this project deploy smart contracts?**
- [ ] Yes — this project deploys contracts
- [ ] No — this project only analyzes contracts deployed by others
- [ ] Planned for later phase — not in MVP scope

**If yes or planned:**

| Question | Answer |
|----------|--------|
| Contract type | [[ERC-20 token / ERC-721 NFT / logic contract / other]] |
| Upgrade mechanism | [[None — immutable / Proxy / TBD]] |
| Audit planned | [[Yes — before deployment / No / TBD]] |
| Dangerous functions (mint, pause, blacklist) | [[Present — describe / None / TBD]] |

---

### 9.6 — Token Component

**Is a token planned?**
- [ ] Yes — token is part of MVP
- [ ] Yes — token is planned for a later phase
- [ ] No — no token planned
- [ ] Unknown — team input needed

**If yes or planned:**

| Question | Answer |
|----------|--------|
| Token standard | [[ERC-20 / other]] |
| Launch strategy | [[Product first, then token / Simultaneous / TBD]] |
| Transaction fee mechanism | [[Yes — X% / No / TBD]] |
| Contributor vesting in tokens | [[Yes / No / TBD]] |
| Community governance via token | [[Yes / No / TBD]] |
| External cause allocation (e.g., nonprofit) | [[Yes — describe / No / TBD]] |
| Legal review status | [[Not started / In progress / Completed]] |

---

### 9.7 — Community and Trust

*(Web3 community trust is a product metric, not a marketing concern. These questions shape
the product's evidence and transparency requirements.)*

**Who is the initial community?**
*(Existing crypto community, new audience, enterprise, mixed)*

**How does this community evaluate trust?**

- [ ] Product shipped before token
- [ ] Verifiable on-chain evidence in every output
- [ ] Transparent, incremental public delivery
- [ ] Third-party audit
- [ ] Public team identity
- [ ] Other: *(describe)*

**"Not financial advice" disclaimer required?**
- [ ] Yes — in every scored or analytical output
- [ ] Not applicable — no financial signals in output

---

### 9.8 — Regulatory Posture

| Question | Answer |
|----------|--------|
| Primary jurisdiction | [[US / EU / International / TBD]] |
| Does output constitute financial advice? | [[No — signals only / Unclear — legal review needed]] |
| Token issuance in scope? | [[Yes / No / Planned later]] |
| Legal review conducted or planned | [[Yes — completed / Planned for phase X / Not yet]] |
| Compliance requirements | [[None identified / KYC-AML / GDPR / Other — describe]] |

---

### 9.9 — Composition Signals for Web3

Based on the answers above, the following module selections are indicated:

| Intake answer | Module |
|--------------|--------|
| Python stack | `stacks/python` |
| API service surface | `architectures/api-service` |
| Blockchain data source | `domains/web3` |
| Relational storage for results | `data/relational-postgres` |
| Real users / production | `delivery/production-saas` |
| Token governance layer | add `docs/web3/token-strategy.md` as optional artifact |
| Contract deployment | add `docs/web3/contract-registry.md` as optional artifact |

**Starter composition:** `platform/compositions/web3-risk-analytics.yaml`
