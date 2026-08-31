# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
"""build_argv — map (cli, task, effective_tier) to the headless invocation argv for a
supported local CLI (Codex / Copilot / Grok). Pure construction: argv is meant for
subprocess.run(argv, shell=False), so `task` is always a single, un-shell-interpreted
element. Flags verified against each CLI's --help on 2026-08-31 (auto-harness 75f1ed8).
The effective_tier is the runner's already-capped tier. This builder is a defense-in-depth
SECOND gate: it refuses to construct any Tier 4/5 or sandbox-bypass command."""

SUPPORTED_CLIS = ("codex", "copilot", "grok")
HUMAN_GATE_TIER = 4

def build_argv(cli, task, effective_tier, cwd=None, model=None):
    if cli not in SUPPORTED_CLIS:
        raise ValueError("unsupported CLI: %r (supported: %s)"
                         % (cli, ", ".join(SUPPORTED_CLIS)))
    tier = int(effective_tier)
    if tier >= HUMAN_GATE_TIER:
        raise ValueError("tier %d is human-gated; build_argv refuses to construct it" % tier)
    read_only = tier <= 1  # T0 read-only / T1 local-analysis -> no writes, no tool auto-approve

    if cli == "codex":
        # codex maps trust tier onto its own sandbox policy almost 1:1 (cleanest of the three).
        mode = "read-only" if read_only else "workspace-write"
        # --skip-git-repo-check: a headless runner may spawn codex in a non-git workdir, which
        # codex exec otherwise refuses ("not inside a trusted directory"). Verified live 2026-08-31.
        argv = ["codex", "exec", "-s", mode, "--skip-git-repo-check"]
        if model:
            argv += ["-c", "model=%s" % model]   # per-call override; leaves global config untouched
        if not read_only and cwd:
            argv += ["-C", cwd]
        argv.append(task)
        return argv

    if cli == "grok":
        argv = ["grok", "-p", task]          # -p/--single: single-turn, prints to stdout, exits
        if not read_only:
            argv.append("--always-approve")  # auto-approve tool use only above read-only
        return argv

    # copilot: non-interactive mode REQUIRES broad tool permission (--allow-all-tools) — no true
    # read-only headless tier. A copilot runner should declare a low local_tier + run in a scoped cwd.
    argv = ["copilot", "-p", task, "--allow-all-tools"]
    if not read_only and cwd:
        argv += ["--add-dir", cwd]
    return argv
