# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
"""LIVE smoke test — the ONE place a real external CLI is actually spawned. NOT a unit test.
Run manually, with explicit human authorization (sends a prompt to the named CLI's LLM).
    python3 smoke_live.py [codex|grok|copilot] [model]"""
import subprocess, tempfile, sys, os
from bus import FileBus
from cli_runner import CLIRunner
from cli_invokers import build_argv

TASK = "What is 2+2? Answer with just the number."
TIER = 1  # read-only sandbox


def subprocess_invoke_fn(cli, sandbox_cwd, model):
    def _invoke(task, effective_tier):
        argv = build_argv(cli, task, effective_tier, cwd=sandbox_cwd, model=model)
        print("  spawning: %r (cwd=%s)" % (argv, sandbox_cwd))
        try:
            proc = subprocess.run(argv, cwd=sandbox_cwd, capture_output=True,
                                  text=True, timeout=180, stdin=subprocess.DEVNULL)
        except subprocess.TimeoutExpired:
            return (124, "timed out after 180s")
        out = (proc.stdout or "").strip()
        if proc.returncode != 0:
            return (proc.returncode, (proc.stderr or out or "nonzero exit").strip())
        return (0, out)
    return _invoke


def main():
    cli = sys.argv[1] if len(sys.argv) > 1 else "codex"
    model = sys.argv[2] if len(sys.argv) > 2 else (os.environ.get("SMOKE_MODEL") or None)
    bus_root = tempfile.mkdtemp(prefix="cc-bus-")
    sandbox = tempfile.mkdtemp(prefix="cc-sandbox-")
    bus = FileBus(bus_root)

    print("cli      : %s   model: %s" % (cli, model))
    print("dispatch : task=%r tier_ceiling=%d -> agent %r\n" % (TASK, TIER, cli))
    bus.post({
        "type": "dispatch", "id": "smoke-1", "from": "supervisor", "to": cli,
        "tier_ceiling": TIER, "ts": "2026-08-31T00:00:00Z", "payload": {"task": TASK},
    })

    runner = CLIRunner(bus, cli, invoke_fn=subprocess_invoke_fn(cli, sandbox, model),
                       local_tier=3, heartbeat_s=60)
    rep = runner.tick()
    print("\ntick handled: %s\n\noutbox (results flowing back to the dispatcher):" % rep["handled"])

    outcome = {}
    for _, msg in bus.drain_outbox(cli):
        reason = str(msg["payload"])
        print("  %-6s id=%s payload=%s" % (msg["type"], msg["id"],
                                           reason if len(reason) < 300 else reason[:300] + "…"))
        outcome[msg["type"]] = msg

    ok = "ack" in outcome and "done" in outcome
    print("\nRESULT: %s" % ("PASS — live round-trip (ack + done) succeeded" if ok
                            else "FAIL — no done (see block above)"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
