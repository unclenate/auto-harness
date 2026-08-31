# reference/agent-coordination/bus.py
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
"""Reference file inbox/outbox bus. Reference material, not enforced runtime.
Implements docs/coordination/adapter-contract.md over a local directory."""
import json, os

TYPES = ["dispatch", "ack", "progress", "done", "block", "sync", "verdict"]
_REQUIRED = ["type", "id", "from", "to", "tier_ceiling", "ts", "payload"]

def _read_json(path):
    with open(path) as fh:
        return json.load(fh)

def validate_envelope(msg):
    for f in _REQUIRED:
        if f not in msg:
            raise ValueError("missing envelope field: %s" % f)
    if msg["type"] not in TYPES:
        raise ValueError("unknown message type: %s" % msg["type"])
    # bool is a subclass of int in Python — reject it explicitly
    if not isinstance(msg["tier_ceiling"], int) or isinstance(msg["tier_ceiling"], bool):
        raise ValueError("tier_ceiling must be an int")
    # correlation rule (control-loop-contract.md): every non-dispatch/sync message echoes a dispatch id
    if msg["type"] not in ("dispatch", "sync") and not msg.get("id"):
        raise ValueError("%s message must carry a correlation id" % msg["type"])

class FileBus:
    def __init__(self, root):
        self.root = root
    def _inbox(self, agent_id):
        p = os.path.join(self.root, agent_id, "inbox")
        os.makedirs(p, exist_ok=True); return p
    def post(self, msg):
        validate_envelope(msg)
        inbox = self._inbox(msg["to"])
        name = "%s-%s-%s.json" % (msg["ts"], msg["id"], msg["type"])
        final = os.path.join(inbox, name); tmp = final + ".tmp"
        with open(tmp, "w") as fh:
            json.dump(msg, fh)
        os.replace(tmp, final)  # atomic — a partial file is never polled
        return name
    def poll(self, agent_id):
        inbox = self._inbox(agent_id)
        files = sorted(f for f in os.listdir(inbox) if f.endswith(".json"))
        out = []
        for f in files:
            with open(os.path.join(inbox, f)) as fh:
                out.append(json.load(fh))
        return out
    def ack(self, agent_id, message_id):
        inbox = self._inbox(agent_id)
        acked = os.path.join(inbox, ".acked"); os.makedirs(acked, exist_ok=True)
        for f in os.listdir(inbox):
            if not f.endswith(".json"):
                continue
            path = os.path.join(inbox, f)
            with open(path) as fh:
                # match the EXACT id field, never a filename substring (the ts is full of dashes,
                # so a substring match mis-acks on ts fragments and dash-bearing ids)
                if json.load(fh).get("id") == message_id:
                    os.replace(path, os.path.join(acked, f))
    def capabilities(self, agent_id):
        return {"types": list(TYPES), "modes": ["poll"]}
    # --- outbox: messages an agent produced for REMOTE peers (drained by an adapter) ---
    def _outbox(self, agent_id):
        p = os.path.join(self.root, agent_id, "outbox"); os.makedirs(p, exist_ok=True); return p
    def post_outbound(self, msg):
        """Queue a message FROM msg['from'] for a remote peer; an adapter bridges it out."""
        validate_envelope(msg)
        outbox = self._outbox(msg["from"])
        name = "%s-%s-%s.json" % (msg["ts"], msg["id"], msg["type"])
        final = os.path.join(outbox, name); tmp = final + ".tmp"
        with open(tmp, "w") as fh:
            json.dump(msg, fh)
        os.replace(tmp, final); return name
    def drain_outbox(self, agent_id):
        outbox = self._outbox(agent_id)
        return [(f, _read_json(os.path.join(outbox, f)))
                for f in sorted(os.listdir(outbox)) if f.endswith(".json")]
    def mark_sent(self, agent_id, filename):
        outbox = self._outbox(agent_id)
        sent = os.path.join(outbox, ".sent"); os.makedirs(sent, exist_ok=True)
        os.replace(os.path.join(outbox, filename), os.path.join(sent, filename))
    def sent_dispatches(self, agent_id):
        """Durable log of dispatches this agent sent — NOT subject to inbox ack-removal."""
        sent = os.path.join(self._outbox(agent_id), ".sent")
        if not os.path.isdir(sent):
            return []
        out = [_read_json(os.path.join(sent, f))
               for f in sorted(os.listdir(sent)) if f.endswith(".json")]
        return [m for m in out if m["type"] == "dispatch"]
