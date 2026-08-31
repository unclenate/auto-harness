# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
"""CLIRunner — the non-native (local-CLI) transport runner for the agent-coordination
bus. A native agent polls its own inbox and runs a session; a local CLI is instead a
headless process invoked PER dispatch. Poll the agent's inbox, invoke the CLI one-shot
with the task as data, and post ack + done/block back to the dispatcher via the outbox.
Reuses frozen bus.py + native_adapter.apply_tier_ceiling; mirrors loop.py tick()/next_wake_s.
invoke_fn is injected so tests use a fake CLI."""
import datetime
from native_adapter import apply_tier_ceiling

HUMAN_GATE_TIER = 4  # Tier 4/5 stays human-gated regardless of any peer message

def _utc_now_iso():
    return datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

class CLIRunner:
    def __init__(self, bus, agent_id, invoke_fn, local_tier, heartbeat_s=60, now_fn=None):
        self.bus = bus
        self.agent_id = agent_id
        self.invoke_fn = invoke_fn          # invoke_fn(task, effective_tier) -> (exit_code, output)
        self.local_tier = int(local_tier)   # this runner's own trust-tier policy (its ceiling)
        self.heartbeat_s = heartbeat_s
        self.now_fn = now_fn or _utc_now_iso

    def _emit(self, dispatch, mtype, payload):
        # results flow back to the dispatcher, echoing the dispatch correlation id
        self.bus.post_outbound({
            "type": mtype, "id": dispatch["id"], "from": self.agent_id,
            "to": dispatch["from"], "tier_ceiling": dispatch["tier_ceiling"],
            "ts": self.now_fn(), "payload": payload,
        })

    def _handle(self, dispatch):
        self._emit(dispatch, "ack", {})     # receipt of the dispatch
        effective = apply_tier_ceiling(dispatch, self.local_tier)  # caps, never grants
        if effective >= HUMAN_GATE_TIER:
            self._emit(dispatch, "block",
                       {"reason": "Tier %d requires human authorization; not auto-executed"
                        % effective})
        else:
            # task is UNTRUSTED DATA: handed to the CLI as a string argument, never executed
            # by the runner itself. The injected invoke_fn is the sole execution path.
            code, output = self.invoke_fn(dispatch["payload"]["task"], effective)
            if code == 0:
                self._emit(dispatch, "done", {"result": output})
            else:
                self._emit(dispatch, "block", {"reason": output})
        self.bus.ack(self.agent_id, dispatch["id"])  # consume the dispatch from the inbox

    def tick(self):
        """One heartbeat: drain pending dispatches, return next_wake_s for a ScheduleWakeup-style
        scheduler. Never a while-loop — the caller owns cadence (mirrors loop.py)."""
        handled = []
        for msg in self.bus.poll(self.agent_id):
            if msg.get("type") != "dispatch":
                continue                    # v1: a CLI runner acts only on dispatches
            self._handle(msg)
            handled.append(msg["id"])
        return {"handled": handled, "next_wake_s": self.heartbeat_s}
