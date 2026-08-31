# reference/agent-coordination/loop.py
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
"""Reference supervision loop: heartbeat + stall detection. Reference material.
NO busy-spin — tick() runs once and returns next_wake_s for a ScheduleWakeup-style
scheduler to re-invoke. The caller owns cadence; this owns one heartbeat's work."""

class Loop:
    def __init__(self, bus, agent_id, heartbeat_s, now_fn):
        self.bus = bus; self.agent_id = agent_id
        self.heartbeat_s = heartbeat_s; self.now_fn = now_fn
    def stalled_dispatches(self, now):
        # Correlate dispatches THIS agent SENT (durable outbox/.sent log — NOT ack-mutated) against
        # the results it RECEIVED (inbox). A done/verdict flows back to the dispatcher's inbox, so a
        # supervisor watching only one inbox (the old bug) could never see both halves.
        sent = self.bus.sent_dispatches(self.agent_id)
        done_ids = {m["id"] for m in self.bus.poll(self.agent_id) if m["type"] in ("done", "verdict")}
        stalled = []
        for m in sent:
            deadline = m.get("payload", {}).get("deadline")   # epoch seconds (int), per the contract
            if deadline is not None and now > deadline and m["id"] not in done_ids:
                stalled.append(m["id"])
        return stalled
    def tick(self):
        # one heartbeat of supervision; NEVER a while-loop
        return {"stalled": self.stalled_dispatches(self.now_fn()),
                "next_wake_s": self.heartbeat_s}
