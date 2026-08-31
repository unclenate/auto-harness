# reference/agent-coordination/bus.py
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
"""Reference file inbox/outbox bus. Reference material, not enforced runtime.
Implements docs/coordination/adapter-contract.md over a local directory.

SECURITY MODEL (explicit design properties, not defects):
- No cryptographic sender authentication. `from` is self-asserted; a local file bus trusts the
  local filesystem's own access control and each runner's `local_tier` policy. Cross-machine
  authentication is an ADAPTER's job, not this store's. Stated so a reviewer does not mistake
  the absence for an oversight.
- Untrusted message fields (`to`/`from`/`id`/`ts`) build filesystem paths, so they are guarded
  against traversal, symlink escape, and control characters below. A message is never executed;
  its payload is data handed to a consumer."""
import json, os

TYPES = ["dispatch", "ack", "progress", "done", "block", "sync", "verdict"]
_REQUIRED = ["type", "id", "from", "to", "tier_ceiling", "ts", "payload"]

def _read_json(path):
    with open(path) as fh:
        return json.load(fh)

def _check_path_component(field, value):
    """Message fields are UNTRUSTED DATA (control-loop-contract.md), yet `to`/`from`/`id`/`ts`
    are used to build filesystem paths (inbox dir + `<ts>-<id>-<type>.json`). Guard them so a
    hostile message can never escape the bus root via traversal: reject path separators, parent
    refs, and home markers. `*` is allowed ONLY as the sync-broadcast recipient."""
    if not isinstance(value, str) or not value:
        raise ValueError("%s must be a non-empty string" % field)
    # null byte / control chars: reject early rather than let the FS fail late (or truncate at \x00)
    if any(ord(c) < 0x20 for c in value):
        raise ValueError("control character in %s: %r" % (field, value))
    if value == "*":
        return
    if ("/" in value or "\\" in value or os.sep in value
            or (os.altsep and os.altsep in value)
            or ".." in value or value in (".", "..") or value.startswith("~")):
        raise ValueError("unsafe path component in %s: %r" % (field, value))

def _atomic_write(path, data):
    """Write-then-rename, refusing to follow a symlink planted at the temp path.
    O_EXCL fails if the temp name already exists; O_NOFOLLOW (POSIX) refuses a symlink."""
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL | getattr(os, "O_NOFOLLOW", 0)
    fd = os.open(path, flags, 0o600)
    try:
        with os.fdopen(fd, "w") as fh:
            fh.write(data)
    except BaseException:
        os.unlink(path)
        raise

def _free_name(path):
    """A path that does not yet exist: if `path` is taken, disambiguate with a `-N` suffix before
    the extension. Guarantees a second same-second / same-id / same-type message never silently
    clobbers a queued one (the store contract: never silently drops a message)."""
    if not os.path.exists(path):
        return path
    base, ext = os.path.splitext(path)
    i = 1
    while os.path.exists("%s-%d%s" % (base, i, ext)):
        i += 1
    return "%s-%d%s" % (base, i, ext)

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
    # path-safety: these fields build file paths — an untrusted value must never traverse the root
    _check_path_component("from", msg["from"])
    _check_path_component("to", msg["to"])
    _check_path_component("ts", msg["ts"])
    if msg.get("id"):
        _check_path_component("id", msg["id"])

class FileBus:
    def __init__(self, root):
        self.root = root
    def _safe_subdir(self, agent_id, leaf):
        """Resolve <root>/<agent_id>/<leaf>, refusing a symlinked directory component. O_NOFOLLOW
        in _atomic_write guards only the leaf FILE; a symlinked <agent_id> or <leaf> DIRECTORY
        would let makedirs/os.open write outside the bus root, so refuse those and assert the
        created directory still resolves to inside root."""
        _check_path_component("agent_id", agent_id)  # defense-in-depth: poll/ack pass it directly
        agent_dir = os.path.join(self.root, agent_id)
        if os.path.islink(agent_dir):
            raise ValueError("agent directory is a symlink (refused): %r" % agent_id)
        p = os.path.join(agent_dir, leaf)
        if os.path.islink(p):
            raise ValueError("%s directory is a symlink (refused): %r" % (leaf, agent_id))
        os.makedirs(p, exist_ok=True)
        root_real = os.path.realpath(self.root)
        if os.path.commonpath([root_real, os.path.realpath(p)]) != root_real:
            raise ValueError("%s directory escapes the bus root (refused): %r" % (leaf, agent_id))
        return p
    def _inbox(self, agent_id):
        return self._safe_subdir(agent_id, "inbox")
    def post(self, msg):
        validate_envelope(msg)
        inbox = self._inbox(msg["to"])
        name = "%s-%s-%s.json" % (msg["ts"], msg["id"], msg["type"])
        final = _free_name(os.path.join(inbox, name)); tmp = final + ".tmp"
        _atomic_write(tmp, json.dumps(msg))
        os.replace(tmp, final)  # atomic — a partial file is never polled
        return os.path.basename(final)
    def poll(self, agent_id):
        inbox = self._inbox(agent_id)
        files = sorted(f for f in os.listdir(inbox) if f.endswith(".json"))
        out = []
        for f in files:
            path = os.path.join(inbox, f)
            try:
                msg = _read_json(path)
                validate_envelope(msg)   # re-validate: a file written outside post() must not
            except (ValueError, json.JSONDecodeError):   # KeyError the whole tick (DoS)
                rejected = os.path.join(inbox, ".rejected"); os.makedirs(rejected, exist_ok=True)
                os.replace(path, os.path.join(rejected, f))  # quarantine visibly, never silent-drop
                continue
            out.append(msg)
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
        return self._safe_subdir(agent_id, "outbox")
    def post_outbound(self, msg):
        """Queue a message FROM msg['from'] for a remote peer; an adapter bridges it out."""
        validate_envelope(msg)
        outbox = self._outbox(msg["from"])
        name = "%s-%s-%s.json" % (msg["ts"], msg["id"], msg["type"])
        final = _free_name(os.path.join(outbox, name)); tmp = final + ".tmp"
        _atomic_write(tmp, json.dumps(msg))
        os.replace(tmp, final); return os.path.basename(final)
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
