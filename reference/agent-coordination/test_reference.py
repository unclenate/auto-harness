# reference/agent-coordination/test_reference.py
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
import tempfile, os, json, unittest
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
    def test_rejects_path_traversal_in_recipient(self):
        # untrusted 'to' must never escape the bus root via a traversal segment
        with self.assertRaises(ValueError):
            self.bus.post(_msg(to="../../../../tmp/evil"))
    def test_rejects_path_traversal_in_id(self):
        # untrusted 'id' feeds the filename — a separator/parent-ref must be rejected
        with self.assertRaises(ValueError):
            self.bus.post(_msg(id="../../etc/passwd"))
    def test_sync_broadcast_star_recipient_allowed(self):
        # '*' is the one allowed non-identifier recipient (sync broadcast)
        self.bus.post(_msg(type="sync", id="", to="*", payload={"state": {}}))
        self.assertEqual(len(self.bus.poll("*")), 1)
    def test_seven_types(self):
        self.assertEqual(TYPES, ["dispatch","ack","progress","done","block","sync","verdict"])
    def test_rejects_control_char_in_path_field(self):
        # L1: a null byte / control char in a path-building field is rejected early, not late
        with self.assertRaises(ValueError):
            self.bus.post(_msg(id="a\x00b"))
        with self.assertRaises(ValueError):
            self.bus.post(_msg(to="a\tb"))
    def test_refuses_symlinked_agent_dir(self):
        # H2: a symlinked <agent_id> directory would let makedirs/os.open write OUTSIDE the root;
        # O_NOFOLLOW only guards the leaf temp file, so the store must refuse the symlinked dir
        outside = tempfile.mkdtemp()
        os.symlink(outside, os.path.join(self.dir, "victim"))
        with self.assertRaises(ValueError):
            self.bus.post(_msg(to="victim"))
    def test_same_name_message_not_silently_clobbered(self):
        # M1: two same ts/id/type messages must both survive (never silently drops)
        self.bus.post(_msg(id="c1", ts="2026-08-30T00:00:00Z", type="progress",
                           payload={"note": "first"}))
        self.bus.post(_msg(id="c1", ts="2026-08-30T00:00:00Z", type="progress",
                           payload={"note": "second"}))
        self.assertEqual(len(self.bus.poll("b")), 2)
    def test_poll_quarantines_malformed_and_does_not_crash(self):
        # M3: a file written directly into the inbox (bypassing post) that fails validation must
        # be quarantined, not KeyError the whole tick (DoS)
        self.bus.post(_msg(id="good"))
        inbox = os.path.join(self.dir, "b", "inbox")
        with open(os.path.join(inbox, "zzz-bad-dispatch.json"), "w") as fh:
            json.dump({"type": "dispatch"}, fh)   # valid JSON, missing required fields
        got = self.bus.poll("b")                   # must NOT raise
        self.assertEqual([m["id"] for m in got], ["good"])
        self.assertTrue(os.path.isdir(os.path.join(inbox, ".rejected")))
    def test_poll_survives_scalar_json_and_json_dir(self):
        # M3 hardening: a scalar-JSON file (TypeError) and a *.json DIRECTORY (IsADirectoryError)
        # are the exact "file written outside post()" DoS vectors — poll must quarantine, not crash
        self.bus.post(_msg(id="good"))
        inbox = os.path.join(self.dir, "b", "inbox")
        with open(os.path.join(inbox, "zzz-scalar-dispatch.json"), "w") as fh:
            fh.write("42")                          # valid JSON, non-object -> TypeError in validate
        os.makedirs(os.path.join(inbox, "yyy-dir-dispatch.json"))  # dir -> IsADirectoryError on open
        got = self.bus.poll("b")                    # must NOT raise
        self.assertEqual([m["id"] for m in got], ["good"])

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
