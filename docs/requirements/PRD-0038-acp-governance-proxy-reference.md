<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0038: ACP Governance Proxy — Reference Implementation

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-07-20 | **Review Cycle:** On-change

**Status:** Accepted *(design + implementation land together — a runnable reference tool ships with its tests in one pass)*
**Date:** 2026-07-20 (filed + accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Parent OPP / prior phase: [OPP-0056](../opportunities/OPP-0056-agent-client-protocol-governance-bridge.md) and [PRD-0037](PRD-0037-acp-governance-bridge.md) — PRD-0037 shipped the *declarative* `agents/acp` module (module.yaml + `tier-policy.yaml` + helper *sketches*) and explicitly deferred the runtime proxy as a reference sketch (its Helper 1–2). This PRD ratifies and builds that reference into a **runnable, tested implementation**.
- Governed protocol surface: [Agent Client Protocol](https://agentclientprotocol.com/) — `session/request_permission` (options `allow_once`/`allow_always`/`reject_once`/`reject_always`), `session/update` tool-call stream, JSON-RPC over stdio.
- Policy source of truth: [`platform/agents/acp/tier-policy.yaml`](../../platform/agents/acp/tier-policy.yaml) — the reference proxy's `policy.py` mirrors it as `DEFAULT_POLICY`.
- Related operating-principles: § 9 (design/impl split — relaxed; a reference tool is small enough to land with its design), § 10 (unchanged from PRD-0037: the runtime claim is **Half-enforced** — the reference makes the enforcement point concrete, but it runs in the consumer's environment, not the harness's CI).

## Overview

PRD-0037 put the ACP governance bridge into the harness as a **declarative** module and
deferred the runtime as sketches. This phase makes the runtime real: a **runnable reference
proxy** at [`platform/agents/acp/reference-proxy/`](../../platform/agents/acp/reference-proxy/README.md)
that sits between an ACP client and an ACP agent and enforces the tier-policy at
`session/request_permission` — the concrete proof that the integration works, and the starting
point adopters (JetBrains/ACP vendors) build on.

**Genre boundary (load-bearing).** A governance harness ships a *declarative contract* plus
*reference/example material* (templates, samples) — it does not ship enforced runtime. This
proxy is reference material, exactly like a template: no validator gates it, it is clearly
marked "not the enforced contract," and it exists to demonstrate and enable adoption. This keeps
the harness in its layer (policy) while giving the ecosystem-inducement goal a working artifact
(see the distilled pattern in `docs/knowledge/shared-observations.md`, 2026-07-20).

The implementation is Python 3 **stdlib-only** (matching the harness's Bash/Ruby no-dependency
ethos), so it runs immediately with the policy embedded. The valuable, directly-testable core is
the policy engine (`classify` + `options_for` + `rewrite_permission_request`); the proxy loop is
a thin bidirectional stdio pump around it.

## Goals & Non-Goals

**Goals:**

- Ship `platform/agents/acp/reference-proxy/policy.py` — the tier-policy engine mirroring
  `tier-policy.yaml`: `classify(kind, path, command, sensitive_paths)` → trust tier (with the
  `execute`-command classification, governance-entrypoint → Tier 5, sensitive-path bump, and
  publishing-`fetch` escalation) and `options_for(tier, kind, sensitive)` → the ACP option set
  (stripping `allow_always` for delete / sensitive paths / Tier 3+, repairing the default), plus
  `rewrite_permission_request(params)` returning `(new_params, decision)` and an optional
  `load_policy` override loader.
- Ship `platform/agents/acp/reference-proxy/proxy.py` — a dependency-free stdio JSON-RPC proxy:
  spawns the agent, forwards client↔agent verbatim, and on the agent→client path rewrites
  `session/request_permission` per policy (auto-rejecting **Tier 5 at the seam**, never showing
  it to the client) and mirrors `session/update` tool calls to a JSONL audit sink.
- Ship `test_policy.py` — unit tests for the enforcement core (kind→tier including the
  test/build/install/deploy `execute` cases; the `allow_always` bans; the Tier-5 auto-reject;
  the sensitive-path withholding; well-formed ACP option shape).
- Ship the reference-proxy README with run/test instructions and the explicit genre note.
- Register PRD-0038 in `docs/README.md` + `SUMMARY.md` nav.

**Non-Goals (deferred):**

- **Production hardening** — Content-Length framing as an alternative to newline-delimited JSON;
  reconnection; backpressure. The reference uses ndjson (the common ACP stdio convention).
- **Manifest auto-loading of `sensitivePaths`** — v1 takes `--sensitive` regexes on the CLI; a
  helper that reads them from `harness.manifest.yaml` is a follow-on.
- **The Tier-4 human-authorization channel** — the reference records the requirement in the
  audit; the out-of-band authorization UX is consumer/editor-specific.
- **The audit bridge** — reconciling the JSONL session log into the knowledge-capture ledger
  (ADR-0002) is its own follow-on phase (PRD-0037 Helper 4).
- **Wiring the Python tests into the harness CI** — the harness CI is Bash/Ruby; the reference
  tests are run manually (documented). Keeping them out of CI preserves the genre boundary
  (reference tool, not enforced runtime).

## § 10 Claim Classification

| Claim ID | Claim | Current | After this phase |
|----------|-------|---------|------------------|
| C-ACP-1 | An ACP tool call is gated by the kernel trust tier for its `kind`+path+command | Half-enforced (declarative policy; PRD-0037) | **Half-enforced, now with a runnable reference** — the enforcement point is concrete and demonstrable; it still runs in the consumer's environment, not the harness CI |
| C-ACP-3 | Tier 5 is never auto-approved via ACP | Enforced by policy | **Demonstrated** — the reference proxy auto-rejects Tier 5 at the seam (test + smoke-verified) |
| C-ACP-PXY | The reference proxy correctly classifies and rewrites | — | **Enforced by `test_policy.py`** for the policy core; the stdio loop is smoke-verified, not CI-gated (reference tool) |

The genre boundary is this PRD's ratification checkpoint: the proxy is reference material, so its
correctness is guaranteed by its own tests, not by the harness validator chain — the same status
as a template's example content.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001 | Policy engine | `policy.py`: `classify` returns the correct tier for every kind + the `execute` command classes + governance entrypoints + sensitive-path bump; `options_for` returns the tier's option set with `allow_always` correctly banned and default repaired; `rewrite_permission_request` returns `(new_params, decision)` with well-formed ACP options. Stdlib-only. |
| FR-002 | Proxy loop | `proxy.py`: bidirectional stdio pump; rewrites `session/request_permission` per policy; auto-rejects Tier 5 at the seam (client never sees it, agent receives `reject_always`); mirrors `session/update` to the audit sink; passes unparseable lines through. Stdlib-only. `--help` documents args. |
| FR-003 | Tests | `test_policy.py`: ≥ 15 unit cases covering classification, option bans, Tier-5 auto-reject, sensitive-path withholding, ACP option shape — all pass under `python3 -m unittest`. |
| FR-004 | README + genre note | Reference-proxy README documents run/test and states explicitly it is reference material, not the enforced contract. |
| FR-005 | PRD registered | PRD-0038 in `docs/README.md` + `SUMMARY.md` nav (list-completeness green). |

### Should Have

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-S01 | Override loader | `load_policy` merges a consumer `.acp/policy.yaml` (PyYAML if present) or `.json` onto the default. |
| FR-S02 | Companion surfacing in the prompt | The rewritten request carries a `_governance.titleHint` naming the tier/sensitivity consequence. |

### Out of Scope

| Feature | Reason | Revisit |
|---------|--------|---------|
| Content-Length framing / production hardening | reference uses ndjson | production proxy build |
| Manifest `sensitivePaths` auto-load | CLI `--sensitive` suffices for the reference | follow-on helper |
| Audit → knowledge-capture reconciliation | own follow-on phase (PRD-0037 Helper 4) | ADR-0002 bridge PRD |
| Python tests in harness CI | genre boundary; CI is Bash/Ruby | if the proxy graduates from reference to shipped tool |

## Technical Constraints

- **Python 3 standard library only** (no PyYAML required unless a `.yaml` override is supplied).
- Newline-delimited JSON framing; agent launched as a subprocess; a lock guards agent-stdin
  writes (the proxy writes auto-responses on the agent→client thread).
- The proxy must never *lower* a tier below the policy or offer an option the tier bans (trust
  never self-elevates).

## CI/CD Gates

- The harness validator chain stays green (the reference proxy adds `.py` files under
  `platform/agents/acp/`; no validator scans them, `validate-agent-pack` checks only the module's
  declared adapters/fragments). PRD-0038 satisfies `validate-list-completeness`.
- markdownlint clean on the new docs. The Python tests are run manually (documented in the
  reference README), not in the harness CI.

## Versioning Implications

Additive: reference/example material under an existing experimental module. No change to the
enforced contract or catalog counts (a reference tool is not a module/validator/skill/template/
workflow). Lands in the next minor.

## Acceptance Criteria

`policy.py` + `proxy.py` + `test_policy.py` + the reference README merge with the policy tests
passing and a smoke test confirming Tier-5 block-at-seam + audit. Follow-on phases (production
hardening; the audit bridge) proceed under their own PRDs.
