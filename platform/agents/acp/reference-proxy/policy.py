# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — reference implementation, NOT part of the enforced governance contract.
"""Tier-policy engine for the ACP governance bridge (PRD-0038 / PRD-0037 / OPP-0056).

Pure, dependency-free logic that turns an ACP tool call into a trust tier and a
trust tier into the ``session/request_permission`` option set the proxy is allowed
to offer. The canonical declarative policy lives in ``../tier-policy.yaml``; the
DEFAULT_POLICY below mirrors it so the reference proxy runs with zero external
files or dependencies. A consumer may pass an override loaded from
``.acp/policy.yaml`` (see ``load_policy``).

The two public entry points are :func:`classify` and :func:`options_for`, composed
by :func:`rewrite_permission_request`.
"""

import re

# ACP tool-call kinds → baseline trust tier (mirrors tier-policy.yaml `kinds`).
DEFAULT_POLICY = {
    "kinds": {
        "read": {"tier": 0},
        "search": {"tier": 0},
        "think": {"tier": 0},
        "fetch": {"tier": 2},
        "edit": {"tier": 2},
        "move": {"tier": 2},
        "delete": {"tier": 2, "allow_always": False},
        "execute": {"tier": 3},
        "other": {"tier": 3},
    },
    # tier (int) → permission option set offered to the client.
    "tiers": {
        0: {"posture": "auto", "options": ["allow_once", "allow_always"], "default": "allow_always"},
        1: {"posture": "auto", "options": ["allow_once", "allow_always"], "default": "allow_once"},
        2: {"posture": "care", "options": ["allow_once", "allow_always", "reject_once"], "default": "allow_once"},
        3: {"posture": "care", "options": ["allow_once", "reject_once"], "default": "reject_once", "allow_always": False},
        4: {"posture": "gate", "options": ["allow_once", "reject_always"], "default": "reject_always",
            "allow_always": False, "requires_human_authorization": True},
        5: {"posture": "block", "options": ["reject_always"], "default": "reject_always",
            "allow_always": False, "block_at_seam": True},
    },
    # Governance entrypoints / secrets: an edit/move/delete here is Tier 5.
    "governance_entrypoints": [
        r"^HARNESS\.md$", r"^AGENTS\.md$", r"^CLAUDE\.md$",
        r"^\.github/workflows/", r"(^|/)\.env", r"(^|/)secrets?/",
    ],
    # execute command classification (first match wins, highest tier applied).
    "command_rules": [
        (1, r"\b(test|lint|eslint|ruff|build)\b|(pytest|jest|go test|cargo test)"),
        (4, r"\b(install|add|sync)\b|migrat|docker (build|run)"),
        (5, r"deploy|kubectl|terraform apply|\bprod\b|secret(s)? (rotate|set)|helm (install|upgrade)"),
    ],
}

READABLE_KINDS = {"read", "search", "think"}


def _matches_any(path, patterns):
    return any(re.search(p, path) for p in patterns)


def classify(kind, path="", command="", sensitive_paths=None, policy=None):
    """Return the trust tier (0–5) for an ACP tool call.

    ``sensitive_paths`` is the list of manifest-declared ``sensitivePaths`` regexes.
    A sensitive-path match bumps the tier by one and strips ``allow_always`` (the
    strip is applied in :func:`options_for` via the returned tier's rules plus the
    ``sensitive`` flag surfaced by :func:`rewrite_permission_request`).
    """
    policy = policy or DEFAULT_POLICY
    sensitive_paths = sensitive_paths or []
    kind = kind or "other"
    tier = policy["kinds"].get(kind, policy["kinds"]["other"])["tier"]

    if kind == "execute" and command:
        # The command determines the tier (test/build LOWER it to 1; install → 4;
        # deploy → 5), defaulting to the baseline only when no rule matches. When
        # several rules match, the riskiest (highest) wins.
        matched = [t for t, pattern in policy["command_rules"] if re.search(pattern, command)]
        if matched:
            tier = max(matched)
    if kind == "fetch" and _publishes(command):
        tier = max(tier, 3)
    if kind in ("edit", "move", "delete") and path and _matches_any(path, policy["governance_entrypoints"]):
        tier = 5
    if path and _matches_any(path, sensitive_paths):
        tier = min(tier + 1, 5)
    return tier


def _publishes(command):
    # A fetch "publishes" when it POSTs/pushes rather than reads. The ACP tool call
    # carries this in its params; the reference proxy passes a hint via `command`.
    return bool(command) and bool(re.search(r"\b(POST|PUT|push|publish|upload)\b", command, re.I))


def options_for(tier, kind=None, sensitive=False, policy=None):
    """Return the permission option set for a tier, honoring the allow_always bans.

    ``allow_always`` is removed for delete, for any sensitive-path target, and for
    Tier 3 and above — even if the tier's base option set lists it.
    """
    policy = policy or DEFAULT_POLICY
    spec = dict(policy["tiers"][tier])
    options = list(spec["options"])
    ban_allow_always = (
        spec.get("allow_always") is False
        or sensitive
        or kind == "delete"
        or tier >= 3
    )
    if ban_allow_always and "allow_always" in options:
        options.remove("allow_always")
        if spec.get("default") == "allow_always":
            spec["default"] = options[0] if options else "reject_once"
    spec["options"] = options
    return spec


def rewrite_permission_request(params, sensitive_paths=None, policy=None):
    """Rewrite an ACP ``session/request_permission`` params object per policy.

    Returns ``(new_params, decision)`` where ``decision`` is:
      - ``None`` — present the rewritten options to the user (tiers 0–4),
      - an option-id string — the proxy auto-responds without asking (tier 5 block,
        or a tier-0 auto-approve if the caller opts into non-interactive mode).

    The tool call's ``kind``, affected ``locations``, and ``rawInput.command`` drive
    classification. Unknown shapes fall back to the conservative ``other`` kind.
    """
    policy = policy or DEFAULT_POLICY
    sensitive_paths = sensitive_paths or []
    tool = params.get("toolCall", params.get("tool_call", {}))
    kind = tool.get("kind", "other")
    path = _first_location(tool)
    command = _command_of(tool)

    tier = classify(kind, path, command, sensitive_paths, policy)
    sensitive = bool(path) and _matches_any(path, sensitive_paths)
    spec = options_for(tier, kind=kind, sensitive=sensitive, policy=policy)

    new_params = dict(params)
    new_params["options"] = [_option(o) for o in spec["options"]]
    new_params["_governance"] = {
        "tier": tier, "posture": spec["posture"], "default": spec["default"],
        "kind": kind, "path": path, "sensitive": sensitive,
    }
    # Surface the governance consequence in the human-readable title.
    hint = _companion_hint(path, sensitive, spec)
    if hint:
        new_params["_governance"]["titleHint"] = hint

    if spec.get("block_at_seam"):
        return new_params, "reject_always"   # Tier 5: never reaches the user
    return new_params, None


def _first_location(tool):
    locs = tool.get("locations") or []
    if locs and isinstance(locs[0], dict):
        return locs[0].get("path", "")
    return tool.get("path", "") or ""


def _command_of(tool):
    raw = tool.get("rawInput") or tool.get("raw_input") or {}
    if isinstance(raw, dict):
        return raw.get("command", "") or raw.get("cmd", "") or ""
    return ""


def _option(option_id):
    kind = "allow" if option_id.startswith("allow") else "reject"
    name = {
        "allow_once": "Allow once", "allow_always": "Always allow",
        "reject_once": "Reject once", "reject_always": "Always reject",
    }.get(option_id, option_id)
    return {"optionId": option_id, "name": name, "kind": f"{kind}_{option_id.split('_')[1]}"}


def _companion_hint(path, sensitive, spec):
    if spec["posture"] == "block":
        return "Tier 5 (remote/production) — blocked at the ACP seam; route to human authorization."
    if spec.get("requires_human_authorization"):
        return "Tier 4 (environment-altering) — requires out-of-band human authorization before Allow."
    if sensitive:
        return f"Sensitive path ({path}) — allow_always withheld; review each change."
    return ""


def load_policy(path):
    """Load a consumer policy override from ``.acp/policy.yaml`` (or .json).

    Merges shallow overrides onto DEFAULT_POLICY. Uses PyYAML if available for a
    ``.yaml`` file; otherwise expects JSON. Missing file → DEFAULT_POLICY unchanged.
    """
    import json
    import os

    if not path or not os.path.exists(path):
        return DEFAULT_POLICY
    with open(path) as f:
        text = f.read()
    data = None
    if path.endswith((".yaml", ".yml")):
        try:
            import yaml  # optional; reference tool only
            data = yaml.safe_load(text)
        except ImportError:
            raise SystemExit(
                "reference-proxy: .yaml override needs PyYAML (`pip install pyyaml`), "
                "or supply the override as JSON."
            )
    else:
        data = json.loads(text)
    merged = {k: (dict(v) if isinstance(v, dict) else list(v) if isinstance(v, list) else v)
              for k, v in DEFAULT_POLICY.items()}
    for key, val in (data.get("overrides", data) if isinstance(data, dict) else {}).items():
        if key in merged and isinstance(merged[key], dict) and isinstance(val, dict):
            merged[key].update(val)
        else:
            merged[key] = val
    return merged
