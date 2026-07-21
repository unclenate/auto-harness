#!/usr/bin/env python3
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — reference implementation, NOT part of the enforced governance contract.
"""ACP governance proxy (reference implementation) — PRD-0038.

A thin, dependency-free JSON-RPC proxy that sits between an ACP client (editor)
and an ACP agent, enforcing the harness tier-policy at the permission seam:

    editor ──stdio JSON-RPC──▶ acp-governance-proxy ──stdio──▶ agent
                              (rewrites request_permission,
                               mirrors session/update to audit)

Messages pass through verbatim EXCEPT:
  * ``session/request_permission`` (agent → client): the option set is rewritten
    to only the options the tool call's trust tier allows, with the safe default
    surfaced; Tier 5 is auto-rejected at the seam and never shown to the user.
  * ``session/update`` (agent → client): tool-call updates are appended to the
    audit log (the audit layer ACP itself lacks).

Framing: newline-delimited JSON (one JSON-RPC object per line), the common ACP
stdio convention. Run with ``--help`` for usage. This is a reference to build on,
not a hardened production proxy.
"""

import argparse
import json
import subprocess
import sys
import threading

import policy as pol


def main(argv=None):
    args = _parse_args(argv)
    loaded = pol.load_policy(args.policy) if args.policy else pol.DEFAULT_POLICY
    sensitive = args.sensitive or []
    audit = _AuditSink(args.audit)

    agent = subprocess.Popen(
        args.agent, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
        text=True, bufsize=1,
    )
    agent_stdin_lock = threading.Lock()

    def write_agent(obj):
        with agent_stdin_lock:
            agent.stdin.write(json.dumps(obj) + "\n")
            agent.stdin.flush()

    # client → agent: forward verbatim (prompts, and permission responses for
    # tiers the proxy did NOT auto-answer).
    def pump_client_to_agent():
        for line in sys.stdin:
            with agent_stdin_lock:
                agent.stdin.write(line if line.endswith("\n") else line + "\n")
                agent.stdin.flush()
        try:
            agent.stdin.close()
        except (OSError, ValueError):
            pass

    # agent → client: intercept, rewrite, audit, forward.
    def pump_agent_to_client():
        for line in agent.stdout:
            msg = _try_parse(line)
            if msg is None:
                _emit(line)                     # unparseable → pass through
                continue
            method = msg.get("method")
            if method == "session/request_permission":
                _handle_permission(msg, sensitive, loaded, audit, write_agent)
            elif method == "session/update":
                audit.record_update(msg)
                _emit_obj(msg)
            else:
                _emit_obj(msg)

    t1 = threading.Thread(target=pump_client_to_agent, daemon=True)
    t2 = threading.Thread(target=pump_agent_to_client, daemon=True)
    t1.start()
    t2.start()
    agent.wait()
    t2.join(timeout=1)
    audit.close()
    return agent.returncode or 0


def _handle_permission(msg, sensitive, loaded, audit, write_agent):
    """Rewrite the permission request; auto-reject Tier 5 at the seam."""
    params = msg.get("params", {})
    new_params, decision = pol.rewrite_permission_request(params, sensitive, loaded)
    gov = new_params.get("_governance", {})
    audit.record_permission(msg, gov, decision)

    if decision is not None:
        # Tier 5 block: answer the agent directly, never show the client.
        option_id = _resolve_blocked_option(new_params, decision)
        write_agent({
            "jsonrpc": "2.0",
            "id": msg.get("id"),
            "result": {"outcome": {"outcome": "selected", "optionId": option_id}},
        })
        return
    # Present the rewritten request to the client.
    forwarded = dict(msg)
    forwarded["params"] = new_params
    _emit_obj(forwarded)


def _resolve_blocked_option(new_params, decision):
    for opt in new_params.get("options", []):
        if opt.get("optionId") == decision:
            return decision
    # Fall back to the first reject option present.
    for opt in new_params.get("options", []):
        if str(opt.get("optionId", "")).startswith("reject"):
            return opt["optionId"]
    return decision


class _AuditSink:
    """Appends governance decisions to a JSONL session log (the audit ACP lacks)."""

    def __init__(self, path):
        self._path = path
        self._fh = open(path, "a") if path else None
        self._lock = threading.Lock()
        self._seq = 0

    def _append(self, record):
        if not self._fh:
            return
        with self._lock:
            self._seq += 1
            record["seq"] = self._seq
            self._fh.write(json.dumps(record) + "\n")
            self._fh.flush()

    def record_permission(self, msg, gov, decision):
        self._append({
            "event": "permission",
            "id": msg.get("id"),
            "kind": gov.get("kind"),
            "path": gov.get("path"),
            "tier": gov.get("tier"),
            "posture": gov.get("posture"),
            "sensitive": gov.get("sensitive"),
            "autoDecision": decision,
        })

    def record_update(self, msg):
        update = (msg.get("params") or {}).get("update") or {}
        if update.get("sessionUpdate") == "tool_call" or "toolCallId" in update:
            self._append({
                "event": "tool_call",
                "toolCallId": update.get("toolCallId"),
                "title": update.get("title"),
                "kind": update.get("kind"),
                "status": update.get("status"),
            })

    def close(self):
        if self._fh:
            self._fh.close()


def _try_parse(line):
    line = line.strip()
    if not line:
        return None
    try:
        return json.loads(line)
    except json.JSONDecodeError:
        return None


def _emit(line):
    sys.stdout.write(line if line.endswith("\n") else line + "\n")
    sys.stdout.flush()


def _emit_obj(obj):
    sys.stdout.write(json.dumps(obj) + "\n")
    sys.stdout.flush()


def _parse_args(argv):
    p = argparse.ArgumentParser(
        description="ACP governance proxy — enforce harness trust tiers at the ACP permission seam.",
    )
    p.add_argument("--agent", nargs=argparse.REMAINDER, required=True,
                   help="Command to launch the ACP agent (everything after --agent).")
    p.add_argument("--policy", default=None,
                   help="Path to a .acp/policy.yaml|.json override (default: built-in tier-policy).")
    p.add_argument("--sensitive", action="append", default=[],
                   help="A sensitivePaths regex (repeatable); typically sourced from harness.manifest.yaml.")
    p.add_argument("--audit", default=None,
                   help="JSONL audit sink path (default: no audit log).")
    return p.parse_args(argv)


if __name__ == "__main__":
    sys.exit(main())
