# reference/agent-coordination/native_adapter.py
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
"""Reference native-bus adapter: bridges the Claude SendMessage channel to the file bus.
Reference material, not enforced runtime. send_fn is injected so tests use a fake."""
import json

BUS_PREFIX = "AGENT-BUS:"

def apply_tier_ceiling(msg, local_policy_tier):
    """caps-never-grants: effective tier = min(ceiling, local policy). Never raises."""
    return min(int(msg["tier_ceiling"]), int(local_policy_tier))

class NativeAdapter:
    def __init__(self, bus, send_fn):
        self.bus = bus; self.send_fn = send_fn
    def bridge_out(self, agent_id):
        """Drain agent_id's OUTBOX (messages it produced for REMOTE peers) and deliver each to its
        recipient via send_fn. (Draining the inbox and sending to msg['to'] would re-address inbound
        mail back to self — the bug the adversarial pass caught.) Bus content is untrusted DATA —
        serialized + prefixed, never executed as prose. mark_sent only AFTER send_fn returns."""
        for filename, msg in self.bus.drain_outbox(agent_id):
            self.send_fn(msg["to"], BUS_PREFIX + json.dumps(msg))
            self.bus.mark_sent(agent_id, filename)
