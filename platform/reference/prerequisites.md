<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Prerequisites

Before bootstrapping auto-harness into a project, your machine needs a small
toolchain. **This page is the single canonical list** — other docs link here
rather than restating it.

You do not have to memorize it: `install.sh` runs a **dependency preflight**
([PRD-0020](../../docs/requirements/PRD-0020-bootstrap-hardening-guards-and-preflight.md))
that checks all of these up front and fails with a per-platform message naming
every gap at once. The opt-in `--install-deps` flag auto-installs the ones that
can be fixed safely. So the fastest path is often: run `install.sh`, read what it
asks for, install that, re-run.

## The matrix

| Dependency | Minimum | Why it's needed | `--install-deps` can install it? |
|------------|---------|-----------------|----------------------------------|
| **Bash** | 4.0+ | `install.sh` uses associative arrays (`declare -A`); macOS ships 3.2 | **No** — install before running the script |
| **Git** | 2.0+, `core.symlinks=true` | Mount the submodule; relative skill symlinks | **Yes** |
| **Ruby** | 3.0+ | `install.sh`'s manifest merge + the validators | **No** — use a version manager (see macOS note) |
| **ripgrep** (`rg`) | any recent | `validate-placeholders.sh` and other validators | **Yes** |

## Per-platform

### macOS

- **Bash**: the system `/bin/bash` is **3.2** (frozen for GPL-v3 licensing reasons).
  `brew install bash`, then invoke the script through the newer one:
  `/opt/homebrew/bin/bash …` (Apple Silicon) or `/usr/local/bin/bash …` (Intel).
- **Ruby**: the system `/usr/bin/ruby` is **2.6** and **shadows a Homebrew Ruby on
  `PATH`**. This is why `--install-deps` does *not* auto-install Ruby — installing
  it rarely changes what your shell resolves. Use a version manager (rbenv / asdf),
  or ensure the Homebrew Ruby precedes `/usr/bin` on `PATH`.
- **Everything at once**: `brew install bash ruby ripgrep git`
- `core.symlinks` defaults to `true`.

### Linux

- **Bash 4+** is standard.
- Install the rest via your package manager:
  - Debian / Ubuntu: `sudo apt-get install -y git ruby ripgrep`
  - Fedora / RHEL: `sudo dnf install -y git ruby ripgrep`
  - Arch: `sudo pacman -S git ruby ripgrep`
- **Heads-up**: some still-supported LTS distros ship **Ruby < 3.0** and don't
  carry **ripgrep** in the base install. Check `ruby -v`; if it's below 3.0, use a
  version manager (rbenv / asdf) or your distro's `ruby3.x` package.
- `core.symlinks` defaults to `true`.

### Windows

- **Use WSL2** (e.g. Ubuntu) and follow the Linux instructions above. The bootstrap
  relies on Bash 4+ associative arrays and POSIX symlinks, so WSL2 is the supported
  path.
- Native Git Bash / PowerShell is **not** a supported target. If you must, you need
  Bash 4+, Ruby 3+, and ripgrep available, and must enable symlinks:
  `git config --global core.symlinks true` (Windows defaults to `false`).

## Verifying and installing

```bash
# install.sh preflights everything and reports all gaps at once:
bash .harness/platform/bootstrap/install.sh

# auto-install the safe deps (git + ripgrep) via your package manager — never Ruby:
bash .harness/platform/bootstrap/install.sh --install-deps

# skip the preflight (CI images / advanced users managing the toolchain out-of-band):
HARNESS_SKIP_DEPCHECK=1 bash .harness/platform/bootstrap/install.sh
```

## See also

- [`submodule-integration.md`](../workflow/submodule-integration.md) — the full consumer adoption flow
- [`platform/bootstrap/README.md`](../bootstrap/README.md) — `install.sh` reference (flags, guards, preflight)
- [ADR-0003 — Submodule Integration](../../docs/adr/ADR-0003-submodule-integration.md) — why Ruby and a submodule mount are required
