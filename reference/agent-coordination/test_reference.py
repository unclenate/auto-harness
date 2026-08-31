# reference/agent-coordination/test_reference.py
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
import tempfile, os, unittest
from bus import FileBus, validate_envelope, TYPES

def _msg(**kw):
    m = {"type": "dispatch", "id": "c1", "from": "a", "to": "b",
         "tier_ceiling": 3, "ts": "2026-08-30T00:00:00Z", "payload": {"task": "x"}}
    m.update(kw); return m

class TestBus(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp(); self.bus = FileBus(self.dir)
    def test_post_then_poll_roundtrips(self):
        self.bus.post(_msg())
        got = self.bus.poll("b")
        self.assertEqual(len(got), 1); self.assertEqual(got[0]["id"], "c1")
    def test_poll_is_oldest_first(self):
        self.bus.post(_msg(id="c1", ts="2026-08-30T00:00:01Z"))
        self.bus.post(_msg(id="c2", ts="2026-08-30T00:00:00Z"))
        ids = [m["id"] for m in self.bus.poll("b")]
        self.assertEqual(ids, ["c2", "c1"])
    def test_ack_removes_from_poll(self):
        self.bus.post(_msg()); self.bus.ack("b", "c1")
        self.assertEqual(self.bus.poll("b"), [])
    def test_unknown_type_rejected(self):
        with self.assertRaises(ValueError):
            validate_envelope(_msg(type="frobnicate"))
    def test_missing_field_rejected(self):
        bad = _msg(); del bad["tier_ceiling"]
        with self.assertRaises(ValueError):
            validate_envelope(bad)
    def test_ack_matches_exact_id_not_ts_substring(self):
        # id "08" must NOT match the "-08-" inside the 2026-08-30 timestamp of the OTHER message
        self.bus.post(_msg(id="08", to="b")); self.bus.post(_msg(id="zz", to="b"))
        self.bus.ack("b", "08")
        self.assertEqual([m["id"] for m in self.bus.poll("b")], ["zz"])
    def test_ack_does_not_overack_dash_ids(self):
        self.bus.post(_msg(id="c1", to="b")); self.bus.post(_msg(id="c1-2", to="b"))
        self.bus.ack("b", "c1")
        self.assertEqual([m["id"] for m in self.bus.poll("b")], ["c1-2"])
    def test_tier_ceiling_rejects_bool(self):
        with self.assertRaises(ValueError):
            validate_envelope(_msg(tier_ceiling=True))
    def test_result_requires_correlation_id(self):
        with self.assertRaises(ValueError):
            validate_envelope(_msg(type="done", id="", payload={"result": "ok"}))
    def test_seven_types(self):
        self.assertEqual(TYPES, ["dispatch","ack","progress","done","block","sync","verdict"])

from native_adapter import NativeAdapter, apply_tier_ceiling

class TestNativeAdapter(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp(); self.bus = FileBus(self.dir); self.sent = []
    def test_bridge_out_drains_outbox_to_peer(self):
        # b produces a message FOR peer d -> outbox; bridge must deliver it to d, not back to b
        self.bus.post_outbound(_msg(**{"from": "b", "to": "d"}))
        NativeAdapter(self.bus, lambda to, text: self.sent.append((to, text))).bridge_out("b")
        self.assertEqual(len(self.sent), 1)
        self.assertEqual(self.sent[0][0], "d")   # delivered to the PEER, never self-addressed
        self.assertTrue(self.sent[0][1].startswith("AGENT-BUS:"))
    def test_tier_ceiling_only_lowers(self):
        self.assertEqual(apply_tier_ceiling(_msg(tier_ceiling=5), 3), 3)  # local policy binds
        self.assertEqual(apply_tier_ceiling(_msg(tier_ceiling=2), 3), 2)  # ceiling lowers
    def test_tier_ceiling_never_grants(self):
        # a high ceiling cannot raise a low local policy
        self.assertEqual(apply_tier_ceiling(_msg(tier_ceiling=5), 1), 1)

from loop import Loop

class TestLoop(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp(); self.bus = FileBus(self.dir)
    def test_tick_reports_next_wake_and_never_spins(self):
        loop = Loop(self.bus, "b", heartbeat_s=60, now_fn=lambda: 1000)
        rep = loop.tick()
        self.assertEqual(rep["next_wake_s"], 60)   # returns cadence for ScheduleWakeup
        self.assertIn("stalled", rep)
    def _send_dispatch(self, frm, to, deadline):
        # dispatcher `frm` queues a dispatch to `to` and marks it sent (durable log)
        self.bus.post_outbound(_msg(**{"from": frm, "to": to},
                                    payload={"task": "x", "deadline": deadline}))
        self.bus.mark_sent(frm, self.bus.drain_outbox(frm)[0][0])
    def test_stalled_dispatch_detected_after_deadline(self):
        self._send_dispatch("d", "b", deadline=500)   # d dispatched to b, got no result
        loop = Loop(self.bus, "d", heartbeat_s=60, now_fn=lambda: 999)
        self.assertEqual(loop.stalled_dispatches(now=999), ["c1"])
    def test_done_clears_stall(self):
        self._send_dispatch("d", "b", deadline=500)
        # b's done flows BACK to d's inbox (the correct routing) — must clear the stall
        self.bus.post(_msg(type="done", id="c1", payload={"result": "ok"}, **{"from": "b", "to": "d"}))
        loop = Loop(self.bus, "d", heartbeat_s=60, now_fn=lambda: 999)
        self.assertEqual(loop.stalled_dispatches(now=999), [])

if __name__ == "__main__":
    unittest.main()
