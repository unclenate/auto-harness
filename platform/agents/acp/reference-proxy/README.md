<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ACP Governance Proxy — Reference Implementation

A runnable, dependency-free reference for the `agents/acp` bridge (PRD-0038). It sits
between an ACP client (editor) and an ACP agent and enforces the harness trust tiers at
ACP's `session/request_permission` seam.

> **Reference material, not the enforced contract.** This is example/adoption code
> — the harness's genre is the *declarative* governance contract
> ([`../module.yaml`](../module.yaml), [`../tier-policy.yaml`](../tier-policy.yaml)).
> No harness validator gates this proxy; it exists so adopters have a working starting
> point, like a template. Treat it as a reference, not a hardened production proxy.

```text
  editor ──stdio JSON-RPC──▶ proxy.py ──stdio──▶ agent
                            (rewrites request_permission per tier;
                             mirrors session/update to the audit log)
```

## What it does

- **Rewrites `session/request_permission`** — for each tool call it computes a trust
  tier from `(kind, target path, command)` and offers only the options that tier allows,
  with the safe default surfaced. Tiers 0–1 auto-approvable; Tier 3 loses `allow_always`;
  Tier 4 gates; **Tier 5 is auto-rejected at the seam and never shown to the user**.
- **Audits `session/update`** — appends each tool call and permission decision to a JSONL
  session log (the audit layer ACP itself lacks).

## Files

| File | Role |
|------|------|
| `policy.py` | The tier-policy engine: `classify(kind, path, command)` → tier, `options_for(tier)` → option set, `rewrite_permission_request(params)`. Mirrors `../tier-policy.yaml`; dependency-free. |
| `proxy.py` | The stdio JSON-RPC proxy loop that applies `policy.py` and mirrors the audit stream. |
| `test_policy.py` | Unit tests for the policy engine (17 cases). |

## Run

```bash
# Wrap any ACP agent. Everything after --agent is the agent launch command.
python3 proxy.py \
  --audit .acp/audit/session-log.jsonl \
  --sensitive '^\.acp/' --sensitive '(^|/)secrets?/' \
  --agent <acp-agent-command> [agent args...]
```

- `--policy PATH` — load a consumer `.acp/policy.yaml` (needs PyYAML) or `.json` override
  of the built-in `tier-policy.yaml`; omit to use the built-in default.
- `--sensitive REGEX` — a `sensitivePaths` pattern (repeatable); source these from your
  `harness.manifest.yaml` so an edit to a sensitive path bumps the tier and withholds
  `allow_always`.
- `--audit PATH` — JSONL audit sink; omit for no log.

Point your editor's ACP agent command at this proxy instead of the agent directly, and
pass the real agent via `--agent`.

## Test

```bash
python3 -m unittest discover -s platform/agents/acp/reference-proxy
```

## Scope & extension points

Framing is newline-delimited JSON (the common ACP stdio convention). This reference
covers the permission + audit path; production hardening (Content-Length framing option,
manifest auto-loading of `sensitivePaths`, the Tier-4 human-authorization channel, and
reconciling the audit JSONL into the knowledge-capture ledger per ADR-0002) are the
follow-on items noted in PRD-0038.
