#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# upgrade.sh — guided, safe upgrade of the auto-harness submodule in a consumer
# repo. It automates the deterministic, non-destructive steps of the documented
# upgrade sequence (fetch tags, show the current pin vs. available versions,
# optionally check out a target tag, and preview what the bump requires) and then
# STOPS, handing back the steps that need operator judgment.
#
# It NEVER commits the submodule bump, NEVER runs install.sh --force, and NEVER
# creates required artifacts for you. Those are deliberate decisions you make
# after reviewing the diff and the CHANGELOG. See the full runbook:
#   platform/workflow/consumer-upgrade-runbook.md
#
# Usage (run from your consumer project root):
#   bash <mount-path>/platform/bootstrap/upgrade.sh [options]
#
# Options:
#   --to TAG            Check out this auto-harness tag in the submodule (e.g. v0.5.1).
#   --latest            Check out the newest tag available from the remote.
#   --mount-path PATH   Submodule mount relative to project root. Default:
#                       auto-detected from this script's location, falling back
#                       to ".harness".
#   --project-root PATH Project root. Default: current working directory.
#   --help, -h          Show this help and exit.
#
# Without --to/--latest the script runs in PREVIEW mode: it mutates nothing and
# only reports the current pin, available newer versions, and whether your tree
# currently satisfies its required artifacts. To see what a specific upgrade
# requires, run with --to <tag> (the checkout is safely revertible:
# `git -C <mount-path> checkout <previous-tag>`).
#
# Exit codes:
#   0 = completed cleanly; no missing required artifacts detected.
#   1 = completed, but action is required before committing (new required
#       artifacts are missing, or the dry-run reports files to write).
#   2 = usage error or precondition not met (not a git repo, submodule missing,
#       dirty submodule working tree, unknown tag).

set -euo pipefail

PROJECT_ROOT="$(pwd)"
MOUNT_PATH=""
TARGET_TAG=""
USE_LATEST=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

err()  { printf 'ERROR: %s\n' "$*" >&2; }
info() { printf '%s\n' "$*"; }
step() { printf '\n=== %s ===\n' "$*"; }

# Preview what the harness's current HEAD requires of the consumer tree: a
# dry-run install (files it would write) and the required-artifacts check.
# Returns 1 if required artifacts are missing, 0 otherwise.
preview_required_artifacts() {
  local prc=0
  step "Dry-run install (scaffolding the harness would write)"
  bash "$MOUNT_ABS/platform/bootstrap/install.sh" --dry-run --project-root "$PROJECT_ROOT" || true
  step "Required-artifact check against your tree"
  if bash "$MOUNT_ABS/platform/validators/validate-required-artifacts.sh" harness.manifest.yaml "$PROJECT_ROOT"; then
    info "  ✓ all required artifacts present."
  else
    prc=1
    info ""
    info "  ⚠ required artifacts are missing for the current configuration (listed above)."
  fi
  return "$prc"
}

show_usage() {
  sed -n '18,37p' "${BASH_SOURCE[0]}" | sed 's/^#\{0,1\} \{0,1\}//'
}

# --- parse args -------------------------------------------------------------
while [ "$#" -gt 0 ]; do
  case "$1" in
    --to)           TARGET_TAG="${2:-}"; shift 2 || { err "--to requires a TAG"; exit 2; } ;;
    --latest)       USE_LATEST=1; shift ;;
    --mount-path)   MOUNT_PATH="${2:-}"; shift 2 || { err "--mount-path requires a PATH"; exit 2; } ;;
    --project-root) PROJECT_ROOT="${2:-}"; shift 2 || { err "--project-root requires a PATH"; exit 2; } ;;
    -h|--help)      show_usage; exit 0 ;;
    *)              err "unknown option: $1"; show_usage; exit 2 ;;
  esac
done

if [ -n "$TARGET_TAG" ] && [ "$USE_LATEST" -eq 1 ]; then
  err "use either --to <tag> or --latest, not both"; exit 2
fi

# --- resolve paths ----------------------------------------------------------
if ! PROJECT_ROOT="$(cd "$PROJECT_ROOT" 2>/dev/null && pwd)"; then
  err "project root not found"; exit 2
fi

if [ -n "$MOUNT_PATH" ]; then
  if ! MOUNT_ABS="$(cd "$PROJECT_ROOT/$MOUNT_PATH" 2>/dev/null && pwd)"; then
    err "mount path not found under project root: $MOUNT_PATH"; exit 2
  fi
else
  # Script lives at <mount>/platform/bootstrap/upgrade.sh → mount root is two up.
  MOUNT_ABS="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

# Mount must be under the project root to compute a relative path for git.
case "$MOUNT_ABS" in
  "$PROJECT_ROOT"/*) MOUNT_REL="${MOUNT_ABS#"$PROJECT_ROOT"/}" ;;
  *) err "submodule mount ($MOUNT_ABS) is not under project root ($PROJECT_ROOT); pass --mount-path"; exit 2 ;;
esac

# --- preconditions ----------------------------------------------------------
if ! git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  err "project root is not a git repository: $PROJECT_ROOT"; exit 2
fi
if ! git -C "$MOUNT_ABS" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  err "no git submodule at mount path: $MOUNT_REL (did you run 'git submodule update --init'?)"; exit 2
fi

info "auto-harness upgrade helper"
info "  project root : $PROJECT_ROOT"
info "  submodule    : $MOUNT_REL"

# --- current pin ------------------------------------------------------------
CURRENT_SHA="$(git -C "$MOUNT_ABS" rev-parse --short HEAD)"
CURRENT_DESC="$(git -C "$MOUNT_ABS" describe --tags --always 2>/dev/null || printf '%s' "$CURRENT_SHA")"
info "  current pin  : $CURRENT_DESC ($CURRENT_SHA)"

step "Fetching upstream tags"
if ! git -C "$MOUNT_ABS" fetch --tags --quiet; then
  err "could not fetch tags from the submodule remote"; exit 2
fi

LATEST_TAG="$(git -C "$MOUNT_ABS" tag --list 'v*' --sort=-v:refname | head -1)"
step "Available versions (newest first)"
git -C "$MOUNT_ABS" tag --list 'v*' --sort=-v:refname | head -8 | sed 's/^/  /'
info ""
info "  CHANGELOG: $MOUNT_REL/CHANGELOG.md  (pre-1.0: read it every upgrade — breaking changes can ride a MINOR bump)"

# --- resolve target ---------------------------------------------------------
if [ "$USE_LATEST" -eq 1 ]; then
  TARGET_TAG="$LATEST_TAG"
  [ -n "$TARGET_TAG" ] || { err "no tags found on the remote"; exit 2; }
fi

if [ -z "$TARGET_TAG" ]; then
  # PREVIEW MODE — no mutation.
  step "Preview mode (no changes made)"
  info "Current pin's required-artifact status:"
  rc=0; preview_required_artifacts || rc=$?
  step "Next"
  info "  To upgrade, re-run with a target, e.g.:"
  info "    bash $MOUNT_REL/platform/bootstrap/upgrade.sh --latest      # newest tag ($LATEST_TAG)"
  info "    bash $MOUNT_REL/platform/bootstrap/upgrade.sh --to v0.X.Y   # a specific tag"
  exit "$rc"
fi

# Validate the requested tag exists.
if ! git -C "$MOUNT_ABS" rev-parse --verify --quiet "refs/tags/$TARGET_TAG" >/dev/null; then
  err "tag not found in submodule: $TARGET_TAG (run with no target to list available tags)"; exit 2
fi

if [ "$TARGET_TAG" = "$CURRENT_DESC" ]; then
  info ""
  info "Already on $TARGET_TAG — nothing to do."
  exit 0
fi

# Refuse to clobber local changes inside the submodule.
if ! git -C "$MOUNT_ABS" diff --quiet || ! git -C "$MOUNT_ABS" diff --cached --quiet; then
  err "the submodule working tree has uncommitted changes; resolve them before upgrading"; exit 2
fi

step "Checking out $TARGET_TAG in the submodule"
if ! git -C "$MOUNT_ABS" checkout --quiet "$TARGET_TAG"; then
  err "failed to check out $TARGET_TAG"; exit 2
fi
info "  submodule moved: $CURRENT_DESC → $TARGET_TAG"

# --- preview what the new version requires ----------------------------------
rc=0
preview_required_artifacts || rc=$?

# --- hand back the operator steps -------------------------------------------
step "Done — remaining steps are yours to review and commit"
cat <<EOF
  1. Review the version bump and the CHANGELOG:
       git -C "$PROJECT_ROOT" diff -- "$MOUNT_REL"
       sed -n '/## \[/,/## \[/p' "$MOUNT_REL/CHANGELOG.md"   # the new section
  2. If the dry-run above reported files to write, run the bootstrap
     (add --force only to regenerate harness-managed files you want refreshed):
       bash "$MOUNT_REL/platform/bootstrap/install.sh"
  3. Create any new required artifacts the check flagged.
  4. Run your validator chain and confirm it is green.
  5. Commit the bump:
       git -C "$PROJECT_ROOT" add "$MOUNT_REL"
       git -C "$PROJECT_ROOT" commit -m "chore: upgrade auto-harness to $TARGET_TAG"

  To roll back instead:
       git -C "$MOUNT_ABS" checkout "$CURRENT_DESC"
EOF

exit "$rc"
