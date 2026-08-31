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

if __name__ == "__main__":
    unittest.main()
