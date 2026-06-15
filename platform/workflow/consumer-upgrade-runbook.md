<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Consumer Upgrade Runbook

How a project that consumes auto-harness (as a git submodule) bumps to a newer
version, safely and repeatably. This is the single consolidated checklist; the
underlying policy and detail live in
[`release-and-versioning.md`](release-and-versioning.md) and
[`maintenance-operations.md`](maintenance-operations.md).

> Paths below use `<mount>` for your submodule mount (default `.harness`).
> Run every command from your **consumer project root**, on a **feature branch**,
> so your CI gates the bump before it reaches your `main`.

---

## TL;DR — use the helper script

```bash
# 1. See where you are and what's available (mutates nothing):
bash <mount>/platform/bootstrap/upgrade.sh

# 2. Move to a version and preview what it requires:
bash <mount>/platform/bootstrap/upgrade.sh --to v0.X.Y   # or --latest

# 3. Review, satisfy any new required artifacts, run validators, then commit
#    (the script prints these exact steps; it never commits for you).
```

The script automates the safe, deterministic steps — fetch tags, show the
current pin vs. available versions, check out the target tag, and preview what
the bump requires — and then **stops**. It deliberately never commits the bump,
never runs `install.sh --force`, and never creates artifacts for you: those need
your judgment after reading the diff and the CHANGELOG.

**Script exit codes:** `0` clean, no missing artifacts · `1` action required
(new required artifacts, or the dry-run reports files to write) · `2` usage
error / precondition not met.

---

## The manual sequence (what the script automates)

Do this by hand when you want full control, or in CI.

1. **Read the CHANGELOG first.** Pre-1.0, this is mandatory every upgrade —
   breaking changes can ride inside a MINOR bump and are called out under
   `### Breaking Changes`.

   ```bash
   git -C <mount> fetch --tags
   git -C <mount> log <current-tag>..v0.X.Y
   ```

2. **Move the submodule to the target tag.**

   ```bash
   cd <mount>
   git fetch --tags
   git checkout v0.X.Y
   cd -
   ```

3. **Preview what the upgrade requires — before committing.** A new release may
   add a *required artifact* an existing module now declares. Surface it with a
   dry-run install plus the required-artifacts validator:

   ```bash
   bash <mount>/platform/bootstrap/install.sh --dry-run
   bash <mount>/platform/validators/validate-required-artifacts.sh harness.manifest.yaml .
   ```

4. **Apply any scaffolding the preview flagged.** If the dry-run reports file
   work, run it for real (`--force` only to regenerate harness-managed files),
   then create any new required artifacts:

   ```bash
   bash <mount>/platform/bootstrap/install.sh
   ```

5. **Run your full validator chain** and confirm it is green.

6. **Commit the bump (+ any new artifacts).**

   ```bash
   git add <mount> <any-new-artifacts>
   git commit -m "chore: upgrade auto-harness to v0.X.Y"
   ```

> **Why steps 3–4 exist.** Most upstream content — skills, compositions,
> templates — is referenced through symlinks into `platform/`, so it goes live
> the instant the submodule SHA changes (no re-bootstrap). The one thing that
> bites silently is a module newly declaring a doc/template as `required`:
> nothing breaks until `validate-required-artifacts.sh` fails in CI. The dry-run
> is a "what will this demand of me" preview that turns a surprise CI-red into a
> planned step.

---

## Pinning strategy

| Strategy | Use when | How |
|----------|----------|-----|
| **Tag pinning** (`v0.5.1`) — recommended | Production consumers; intentional upgrades | Check out a tag (the script's default target model) |
| **Branch pinning** (`main`) | Experimental adoption or harness contributors only | `git submodule update --remote <mount>` |
| **Commit-hash pinning** | Consuming pre-release work between tags | Check out a specific SHA |

The latest tag is shown by the helper script (and by
`git -C <mount> tag --list 'v*' --sort=-v:refname | head -1`).

---

## Gotchas

- **`--remote` fights a tag pin.** If you're holding a specific tag/commit
  (release freeze, regulated period), do **not** run
  `git submodule update --remote` — it follows the `submodule.<name>.branch` key
  (or the remote default) and silently moves you off the pin. To hold a pin,
  rely on plain `git submodule update`; to follow a release line, point the
  branch key at an upstream `release/*` branch (tags don't work with `--remote`).
- **Set `HARNESS_SUBMODULE_ROOT` in CI** so generated workflow snippets resolve
  regardless of mount path (see
  [`submodule-integration.md`](submodule-integration.md) § The
  `HARNESS_SUBMODULE_ROOT` contract).

---

## Rollback

If a bump breaks you, return to the previous pin and re-commit:

```bash
git -C <mount> checkout <previous-tag>
git add <mount> && git commit -m "chore: roll back auto-harness to <previous-tag>"
```

Before rolling back, capture *why* — open an upstream bug report
([`bug_report.yml`](../../.github/ISSUE_TEMPLATE/bug_report.yml)) so the next
adopter doesn't hit the same wall. If the rollback proves durable, pin
explicitly per the pinning table above.

---

## See also

- [`release-and-versioning.md`](release-and-versioning.md) — versioning policy,
  what counts as MAJOR/MINOR/PATCH, the consumer-side upgrade flow, pinning.
- [`maintenance-operations.md`](maintenance-operations.md) — the detailed
  maintenance guide (upgrade, new-artifact detection, rollback, drift, lifecycle).
- [`submodule-integration.md`](submodule-integration.md) — first-time
  integration and the mount-path contract.
- [`CHANGELOG.md`](../../CHANGELOG.md) — the human-readable release history.
