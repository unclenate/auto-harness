# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
"""build_argv — map (cli, task, effective_tier) to the headless invocation argv for a
supported local CLI (Codex / Copilot / Grok). Pure construction: argv is meant for
subprocess.run(argv, shell=False), so `task` is always a single, un-shell-interpreted
element. Flags verified against each CLI's --help on 2026-08-31 (auto-harness 75f1ed8).
The effective_tier is the runner's already-capped tier. This builder is a defense-in-depth
SECOND gate: it refuses to construct any Tier 4/5 or sandbox-bypass command.

SECURITY — the `task` is UNTRUSTED and must never be parsed as a FLAG. The tier ceiling caps
the tier NUMBER; nothing upstream inspects the task STRING, so a leading-dash task like
`--dangerously-bypass-approvals-and-sandbox` would, if appended as a bare positional, be read
by the CLI as an option and re-open the sandbox BENEATH the tier gate. Every builder therefore
binds the task so it can never separate into its own token: codex places it after a `--`
end-of-options separator; grok and copilot pass it as a single `=`-joined value."""

SUPPORTED_CLIS = ("codex", "copilot", "grok")
HUMAN_GATE_TIER = 4
# Some CLIs cannot honor a read-only cap: copilot's non-interactive mode FORCES broad tool
# permission (--allow-all-tools), so there is no true read-only headless copilot. Rather than
# silently run it over-permissioned at Tier 0/1 (a caps-never-grants violation), refuse the
# dispatch below its minimum tier — enforced in code here, not merely documented.
CLI_MIN_TIER = {"copilot": 2}

def build_argv(cli, task, effective_tier, cwd=None, model=None):
    if cli not in SUPPORTED_CLIS:
        raise ValueError("unsupported CLI: %r (supported: %s)"
                         % (cli, ", ".join(SUPPORTED_CLIS)))
    tier = int(effective_tier)
    if tier >= HUMAN_GATE_TIER:
        raise ValueError("tier %d is human-gated; build_argv refuses to construct it" % tier)
    min_tier = CLI_MIN_TIER.get(cli, 0)
    if tier < min_tier:
        raise ValueError("%s cannot honor a tier-%d cap (headless mode forces broad tool "
                         "permission); minimum tier is %d" % (cli, tier, min_tier))
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
        argv += ["--", task]   # end-of-options: the untrusted task can never be parsed as a flag
        return argv

    if cli == "grok":
        # --single=<task>: single-turn, prints to stdout, exits. The `=`-joined value is one
        # token, so a leading-dash task binds to --single instead of separating into a flag.
        argv = ["grok", "--single=%s" % task]
        if not read_only:
            argv.append("--always-approve")  # auto-approve tool use only above read-only
        return argv

    # copilot: tier >= CLI_MIN_TIER["copilot"] guaranteed above. Non-interactive mode requires
    # broad tool permission (--allow-all-tools) — legitimate at tier >= 2, refused read-only.
    # --prompt=<task>: `=`-joined single token, so a leading-dash task cannot become a flag.
    argv = ["copilot", "--prompt=%s" % task, "--allow-all-tools"]
    if cwd:
        argv += ["--add-dir", cwd]
    return argv
