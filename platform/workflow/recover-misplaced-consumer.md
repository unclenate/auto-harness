<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Runbook — Recovering a consumer mistakenly created inside the platform repo

This runbook recovers from a specific, high-consequence onboarding mistake: a
**consumer project was instantiated as a subdirectory inside the auto-harness
platform repo itself** (instead of in its own repository), so the consumer's
files become changes to *auto-harness* and risk being committed — or pushed —
into the platform repo.

> **Prevent it instead.** The durable fix is the instantiation-boundary guard
> tracked in
> [OPP-0041 — Onboarding Containment Safety](../../docs/opportunities/OPP-0041-onboarding-containment-safety.md).
> This runbook is the cure for an instance that already happened; the guard is
> the vaccine. The guard now ships in `install.sh` (PRD-0020) — use this runbook
> to recover an instance created **before** the guard landed, through an
> `--inside-platform` / `--allow-nested` override, or by hand with no harness
> tooling at all (which no guard can intercept).

The correct end state is always the same: **the consumer is its own git
repository, located outside the platform's working tree, with auto-harness
mounted beneath it as a submodule** — never a subdirectory of the platform.

---

## Symptoms — how to recognize the mistake

Any one of these, for a consumer directory `<consumer-dir>/` sitting inside an
auto-harness checkout:

- `git status` in the auto-harness repo shows the consumer's files
  (`<consumer-dir>/AGENTS.md`, `<consumer-dir>/docs/…`,
  `<consumer-dir>/harness.manifest.yaml`) as changes **to auto-harness**.
- A routine "commit this" / `git add .` would stage the consumer's files into
  the platform repo (this is usually the moment a human notices).
- The bootstrap left commits like `chore: add auto-harness as submodule` /
  `feat: wire auto-harness via submodule` **in the platform repo's history**.
- `<consumer-dir>/.harness` is a submodule gitlink pointing at auto-harness's
  *own* commit — the platform mounted inside itself.

---

## Step 0 — Diagnose (read-only, do this first)

Run these from the auto-harness repo root. They tell you the blast radius and,
critically, **whether the bad commits are already pushed** — which decides the
whole strategy.

```bash
# Set these once. CONSUMER_DIR is the entangled directory's path RELATIVE TO the
# auto-harness repo root (e.g. unclenate.com, or apps/my-site). Treated as a
# literal path everywhere below — never as a regex.
CONSUMER_DIR="path/to/consumer-dir"
CONSUMER_NAME="$(basename "$CONSUMER_DIR")"
BR="$(git branch --show-current)"

# Is the consumer a plain subdir (no git root of its own)?
test -e "$CONSUMER_DIR/.git" && echo "has its own .git" || echo "plain subdir — entangled"

# Which consumer files are tracked by the PLATFORM repo?
git ls-files -- "$CONSUMER_DIR/"

# Which commits introduced them, and are they on the remote yet? (current branch)
git log --oneline -- "$CONSUMER_DIR/"
git log --oneline "origin/$BR..$BR" -- "$CONSUMER_DIR/" 2>/dev/null \
  || echo "(no upstream for $BR, or no commits on it touch $CONSUMER_DIR)"

# Submodule / .gitmodules entanglement (fixed-string match — paths aren't regexes)
git config -f .gitmodules --get-regexp '^submodule\.' | grep -F "$CONSUMER_DIR" \
  || echo "(no .gitmodules entry)"
git submodule status | grep -F "$CONSUMER_DIR" || true
```

Decide which case you are in:

| | Bad commits **not** on any remote | Bad commits **already pushed** |
|---|---|---|
| Strategy | **Case A** — drop them from history (clean) | **Case B** — remove them forward (never rewrite shared history) |
| Risk | Local only; fully recoverable via reflog | A rewrite would break every other clone |

---

## Step 1 — Preserve the consumer's authored content

Before removing anything, copy the consumer's *real* work (its manifest and any
`docs/` it authored) somewhere outside both repos so nothing is lost:

```bash
RESCUE_DIR="$HOME/harness-rescue/$CONSUMER_NAME"   # deterministic, outside both repos
mkdir -p "$RESCUE_DIR"
cp -R "$CONSUMER_DIR/." "$RESCUE_DIR/"
echo "rescued to: $RESCUE_DIR"
```

The submodule checkout under `$CONSUMER_DIR/.harness` is just a copy of
auto-harness — you do **not** need to preserve it (you'll skip it in Step 2).

---

## Step 2 — Stand the consumer up as its own repository

In its correct location (a sibling directory, *not* inside the platform tree):

```bash
mkdir -p ~/projects/"$CONSUMER_NAME" && cd ~/projects/"$CONSUMER_NAME"
git init
# restore the authored content you rescued (manifest, docs/), NOT the old .harness
cp -R "$RESCUE_DIR/docs" .                      2>/dev/null || true
cp "$RESCUE_DIR/harness.manifest.yaml" .        2>/dev/null || true
git add . && git commit -m "chore: initial import (recovered from platform repo)"
```

You will re-bootstrap the harness here in Step 6.

---

## Step 3 — Remove the scaffold from the platform repo

### Case A — bad commits are not pushed (preferred)

If the consumer scaffold is the only thing in the unpushed commits, reset the
branch back to the remote and the commits (and their tracked files) disappear:

```bash
# from the auto-harness repo, ON the branch that holds the bad commits.
# Reset to THIS branch's upstream (not a hardcoded origin/main) — only safe when
# the scaffold commits are the ONLY unpushed commits on this branch:
git reset --hard "@{u}"              # @{u} = the current branch's tracking branch
```

If the bad commits are interleaved with work you want to keep, use an
interactive-free targeted rebase instead — drop only the scaffold commits:

```bash
git rebase --onto <commit-before-scaffold> <last-scaffold-commit> <branch>
```

### Case B — bad commits are already pushed

Do **not** rewrite shared history. Remove the scaffold going forward with an
explicit commit:

```bash
git rm -r --cached "$CONSUMER_DIR"
git submodule deinit -f "$CONSUMER_DIR/.harness" 2>/dev/null || true
git config -f .gitmodules --remove-section "submodule.$CONSUMER_DIR/.harness" 2>/dev/null || true
git add .gitmodules 2>/dev/null || true
git commit -m "chore: remove consumer scaffold mistakenly committed into the platform repo"
```

---

## Step 4 — Clean filesystem and submodule leftovers

A `reset`/`rm` does not delete the on-disk submodule checkout or its internal
git data. Remove them:

```bash
rm -rf "$CONSUMER_DIR"                    # the entangled subdir (content already rescued)
rm -rf ".git/modules/$CONSUMER_DIR"      # internal submodule data
```

---

## Step 5 — Rebase any dependent local branches

If you cut feature branches *after* the scaffold landed (Case A), they still
carry it in their ancestry. Lift each onto the cleaned base so it does not
reintroduce the scaffold on merge:

```bash
git rebase --onto origin/main <last-scaffold-commit> <feature-branch>
```

---

## Step 6 — Verify no vestige remains, then re-bootstrap correctly

```bash
# In the platform repo — every check should come back empty/clean:
git log --all --oneline -- "$CONSUMER_DIR"   # (empty = no commit anywhere touches it)
git status --short                            # (clean)
test -e "$CONSUMER_DIR" && echo "STILL ON DISK" || echo "gone"

# In the consumer repo — bootstrap the harness the RIGHT way (its own repo):
cd ~/projects/"$CONSUMER_NAME"
git submodule add -b main https://github.com/unclenate/auto-harness .harness
bash .harness/platform/bootstrap/install.sh
```

See [submodule-integration.md](submodule-integration.md) for the full,
correct adoption flow and [maintenance-operations.md](maintenance-operations.md)
for ongoing upkeep.

---

## See also

- [OPP-0041 — Onboarding Containment Safety](../../docs/opportunities/OPP-0041-onboarding-containment-safety.md) — the prevention this runbook is the cure for
- [submodule-integration.md](submodule-integration.md) — the correct consumer adoption flow
- [maintenance-operations.md](maintenance-operations.md) — drift detection and recovery after adoption
- [ADR-0003 — Submodule Integration](../../docs/adr/ADR-0003-submodule-integration.md) — why consumers mount auto-harness as a submodule
