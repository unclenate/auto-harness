# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
"""TDD tests for CLIRunner. Tests use a FAKE invoke_fn (injected, like native_adapter's
send_fn) — NO real CLI is ever called. The frozen bus.py store is reused verbatim."""
import tempfile, unittest
from bus import FileBus
from cli_runner import CLIRunner


def _dispatch(**kw):
    m = {"type": "dispatch", "id": "c1", "from": "supervisor", "to": "codex",
         "tier_ceiling": 3, "ts": "2026-08-31T00:00:00Z", "payload": {"task": "list the files"}}
    m.update(kw); return m


class FakeCLI:
    """Records how it was invoked and returns a scripted (exit_code, output)."""
    def __init__(self, exit_code=0, output="done ok"):
        self.calls = []
        self.exit_code = exit_code
        self.output = output

    def __call__(self, task, effective_tier):
        self.calls.append({"task": task, "effective_tier": effective_tier})
        return (self.exit_code, self.output)


class TestCLIRunner(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()
        self.bus = FileBus(self.dir)

    def _runner(self, cli, local_tier=3):
        return CLIRunner(self.bus, "codex", invoke_fn=cli, local_tier=local_tier,
                         heartbeat_s=60, now_fn=lambda: "2026-08-31T00:00:01Z")

    def _outbox_types(self):
        return [m["type"] for _, m in self.bus.drain_outbox("codex")]

    def test_dispatch_acked_then_done_on_success(self):
        cli = FakeCLI(exit_code=0, output="a.txt b.txt")
        self.bus.post(_dispatch())
        self._runner(cli).tick()
        out = {m["type"]: m for _, m in self.bus.drain_outbox("codex")}
        self.assertIn("ack", out)
        self.assertIn("done", out)
        self.assertEqual(out["done"]["payload"]["result"], "a.txt b.txt")
        self.assertEqual(out["done"]["id"], "c1")
        self.assertEqual(out["done"]["to"], "supervisor")

    def test_dispatch_consumed_from_inbox(self):
        self.bus.post(_dispatch())
        self._runner(FakeCLI()).tick()
        self.assertEqual(self.bus.poll("codex"), [])

    def test_failing_cli_produces_block_not_done(self):
        cli = FakeCLI(exit_code=1, output="command failed")
        self.bus.post(_dispatch())
        self._runner(cli).tick()
        types = self._outbox_types()
        self.assertIn("block", types)
        self.assertNotIn("done", types)

    def test_tier_ceiling_caps_effective_tier(self):
        cli = FakeCLI()
        self.bus.post(_dispatch(tier_ceiling=5))
        self._runner(cli, local_tier=2).tick()
        self.assertEqual(cli.calls[0]["effective_tier"], 2)

    def test_tier_ceiling_lowers_below_local(self):
        cli = FakeCLI()
        self.bus.post(_dispatch(tier_ceiling=1))
        self._runner(cli, local_tier=3).tick()
        self.assertEqual(cli.calls[0]["effective_tier"], 1)

    def test_tier_4_or_higher_blocked_without_invoking_cli(self):
        cli = FakeCLI()
        self.bus.post(_dispatch(tier_ceiling=5))
        self._runner(cli, local_tier=5).tick()
        self.assertEqual(cli.calls, [])
        self.assertIn("block", self._outbox_types())

    def test_task_passed_to_cli_as_data(self):
        cli = FakeCLI()
        self.bus.post(_dispatch(payload={"task": "rm -rf / ; echo pwned"}))
        self._runner(cli).tick()
        self.assertEqual(cli.calls[0]["task"], "rm -rf / ; echo pwned")

    def test_tick_returns_next_wake_and_never_spins(self):
        rep = self._runner(FakeCLI()).tick()
        self.assertEqual(rep["next_wake_s"], 60)
        self.assertIn("handled", rep)

    def test_duplicate_id_dispatch_invoked_once(self):
        # two same-id dispatch FILES in one poll (distinct ts -> distinct filenames). The first
        # _handle acks EVERY id-matching file, so the runner must not re-invoke on the duplicate.
        self.bus.post(_dispatch(id="dup", ts="2026-08-31T00:00:00Z"))
        self.bus.post(_dispatch(id="dup", ts="2026-08-31T00:00:01Z"))
        cli = FakeCLI()
        self._runner(cli).tick()
        self.assertEqual(len(cli.calls), 1)   # one dispatch id -> one CLI invocation, not two

    def test_non_dispatch_message_left_untouched(self):
        self.bus.post({"type": "ack", "id": "c9", "from": "supervisor", "to": "codex",
                       "tier_ceiling": 3, "ts": "2026-08-31T00:00:00Z", "payload": {}})
        cli = FakeCLI()
        self._runner(cli).tick()
        self.assertEqual(cli.calls, [])
        self.assertEqual(len(self.bus.poll("codex")), 1)


if __name__ == "__main__":
    unittest.main()
