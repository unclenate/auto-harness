<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Work-Package Worktree Runbook

How a dispatcher sets up an **isolated git worktree** for one parallel
multi-agent work-package, idempotently and without corrupting the shared
checkout. This is the operational companion to the
[`management/work-package`](../profiles/management/work-package/README.md) lane
contract: the lane says *where* an agent may write; this runbook says *how* to
give it an isolated place to write.

> This runbook closes the cross-LLM worktree-init variance recorded in issues
> #121 / #122, where different agents set up worktrees inconsistently and broke
> each other's checkouts.

## The normalized command

Create one worktree per work-package, branch-and-path in a single step:

```bash
git worktree add -b <branch> <path> <base>
# e.g.
git worktree add -b feat/widget-export ../wt-widget-export main
```

- `<branch>` — the lane's `branch` field. Created fresh off `<base>`.
- `<path>` — a **sibling** directory outside the main checkout (e.g. `../wt-*`),
  never a subdirectory of the repo.
- `<base>` — the lane's `base` field (usually `main`).

## The two rules

1. **Never mutate the shared checkout's branch state.** Do not `git checkout`,
   `git switch`, `git reset`, or `git branch -f` in the primary working tree to
   set up a work-package. The primary tree stays on its branch; every
   work-package gets its own worktree. A dispatcher running N agents touches the
   primary tree zero times for branch setup.

2. **Be idempotent — re-attach, don't re-create.** If the worktree already
   exists (a retried dispatch, a resumed session), attach to it rather than
   failing or clobbering:

   ```bash
   if git worktree list --porcelain | grep -q "branch refs/heads/<branch>"; then
     cd "$(git worktree list --porcelain | awk -v b="refs/heads/<branch>" '
       $1=="worktree"{p=$2} $1=="branch"&&$2==b{print p}')"
   else
     git worktree add -b <branch> <path> <base>
   fi
   ```

## Sibling-worktree validator fallback

A sibling worktree created with `git worktree add` does **not** get the
submodule populated — `.harness/` (or the platform mount) is empty in the new
worktree. Run validators from the **main checkout's** `platform/` instead:

```bash
# From inside the sibling worktree, point at the primary checkout's validators:
MAIN_CHECKOUT="$(git worktree list --porcelain | awk '/^worktree /{print $2; exit}')"
bash "$MAIN_CHECKOUT/platform/validators/validate-lane-integrity.sh" \
  harness.manifest.yaml . "$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null || echo main)"
```

The primary checkout is always the first entry in `git worktree list`. This
keeps the full validator chain available to every work-package without
re-initializing the submodule in each worktree.

## Teardown

When the work-package's PR is merged (or abandoned), remove the worktree and
prune:

```bash
git worktree remove <path>
git worktree prune
```

Removing a worktree does not delete its branch; delete the branch separately
once the PR is merged (`git branch -d <branch>` or via the squash-merge's
`--delete-branch`).
