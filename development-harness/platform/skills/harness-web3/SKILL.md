---
name: harness-web3
description: "Governance rules for blockchain-integrated systems under the development harness — UNKNOWN state propagation policy, rate limit budget enforcement, evidence requirements for risk signals, irreversibility review gates for transaction-signing, and scoring rule discipline. Use when working on Web3 data access, smart contracts, token systems, scoring rules, chain configuration, or on-chain analytics."
license: Apache-2.0
compatibility: Designed for any Agent Skills-compatible client. For projects with the domains/web3 harness module active. Applies to both read-only analytics platforms and write-capable systems; see sections below for which rules apply to each.
metadata:
  harness-module: domains/web3
  format-version: "1.0"
---

# Web3 Governance (Harness Domain Overlay)

This skill encapsulates the governance rules for the `domains/web3` harness module.
It extends the core harness governance — also install `harness-governance`.

## UNKNOWN State Propagation

The most important rule for on-chain analytics systems.

A signal that cannot be computed because data is unavailable **must return `UNKNOWN`**.

**Non-negotiable rules:**
- `UNKNOWN` must never be converted to `0`, `null`, a neutral score, or any synthetic default.
- `UNKNOWN` must be visible in output — it cannot be hidden to make results look cleaner.
- Suppressing `UNKNOWN` is a **correctness bug**, not a UX shortcut.

**Propagation rules by failure mode:**
- API call fails → `UNKNOWN` for that signal (or retry N times, then `UNKNOWN`)
- Rate limit exhausted → `UNKNOWN` propagates
- Contract unverified → `UNKNOWN` for all signals dependent on contract source
- Any required data source unavailable → `UNKNOWN` for dependent signals

**Gotcha:** "Return 0 when data is missing" is always wrong for risk scoring. A contract with
no transfer history is not the same as a contract with zero risk. The distinction is lost
if you coerce `UNKNOWN` to `0`.

Any product decision to hide or aggregate `UNKNOWN` values in the UI requires explicit
human sign-off — not an implementation shortcut.

## Rate Limit Budget

Every external API call must be counted against the declared budget in `docs/web3/chain-config.md`.

Before adding any new API call:
1. Check the current budget in `chain-config.md` (calls per analysis, daily limit).
2. Calculate: daily limit ÷ calls per operation = max operations/day.
3. Add the call to the budget table in `chain-config.md`.
4. If the new call puts the system over budget, surface this before proceeding.

**Gotcha:** Adding API calls without updating the budget is an architecture gap — not a
minor detail. A system that silently exceeds its rate limit will return `UNKNOWN` under
production load without warning.

When a rate limit tier changes (free → pro, etc.), update `chain-config.md` and create an ADR.

## Evidence Requirements

Every risk flag or scored signal must reference the specific on-chain data that produced it.

For each new signal or scoring rule:
- Document the BaseScan / RPC endpoint that provides the evidence.
- Note whether the data is always available, conditional, or rate-limited.
- Record in the ADR for the scoring rule (use `platform/templates/web3/adr-web3.md`).

Unexplained scores are not acceptable. "Trust score: 42" with no evidence is not a valid output.

## Irreversibility — Tier 5 Actions

Writing to a blockchain is irreversible. Smart contract code cannot be patched after deployment.

**Tier 5 actions for Web3 systems:**
- Smart contract deployment (any network, including testnets used as staging)
- Transaction signing and submission to mainnet
- Key rotation or wallet configuration changes
- ABI changes to deployed contracts

Never auto-execute Tier 5 actions. Stop, describe the exact operation and its permanent
consequences, and wait for explicit human authorization and second-human sign-off.

**Gotcha:** "It's just testnet" is not a reason to skip the Tier 5 protocol during development.
The habit formed in development is the one that runs in production.

## Companion Rules

| Trigger path | Required companion | Why |
| ------------ | ------------------ | --- |
| `^chain/`, `^src/chain/`, `chain_config`, `chain_registry` | ADR required | Chain selection has long-term lock-in; rate limit budget must be updated |
| `^contracts/`, `^abi/`, `^src/contracts/` | Risk register, architecture overview, or ADR | Contract changes may be irreversible |
| `^wallet/`, `^src/wallet/`, `^src/signing/` | Risk register, architecture overview, or ADR | Signing authority changes affect all transactions |
| `^src/scoring/`, `^src/signals/`, `scoring_rules`, `signal_weights` | ADR required | Scoring rules must maintain determinism and evidence requirements |

## Skill Security for Web3 Agent Skills

When installing third-party Web3 agent skills (data providers, wallet integrations, chain tools):

1. Install `azhua-skill-vetter` first — run it against any skill before activation.
2. Test in an isolated environment before connecting to any live wallet or production API key.
3. Skills that touch transaction signing require explicit Tier 5 review per this skill's rules.
4. Most Web3 agent skill registry entries are experimental — treat as untrusted until audited.

## Installing This Skill

Copy this directory alongside `harness-governance` to your project's skill directory:

```bash
cp -r platform/skills/harness-web3 .agents/skills/
# or for Claude Code:
cp -r platform/skills/harness-web3 .claude/skills/
```

Both `harness-governance` and `harness-web3` should be installed for Web3 projects.
