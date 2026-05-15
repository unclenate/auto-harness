#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
# link-skills.sh — create relative symlinks from consumer skill dirs into the
# auto-harness submodule.
#
# Usage:
#   link-skills.sh [options] <skill-name>...
#
# Options:
#   --project-root PATH   Default: current working directory.
#   --mount-path PATH     Submodule mount relative to project root. Default: .harness
#   --targets LIST        Comma-separated target skill dirs. Default:
#                         .agents/skills,.claude/skills
#   --force               Replace symlinks pointing elsewhere. Never replaces
#                         real directories (those are always CONFLICTs).
#   --help, -h            Show this help and exit.
#
# Exit codes:
#   0 = every requested link is OK, CREATED, or REPLACED
#   1 = one or more CONFLICTs that prevent linking
#   2 = usage error (bad flag, unknown skill, missing submodule, etc.)
#
# The symlinks created are *relative*: a link at
#   <project-root>/.claude/skills/harness-governance
# resolves to
#   <project-root>/.harness/platform/skills/harness-governance
# via the relative path "../../.harness/platform/skills/harness-governance".
# Relative links survive repo moves that absolute links would not.

set -euo pipefail

PROJECT_ROOT="$(pwd)"
MOUNT_PATH=".harness"
TARGETS=".agents/skills,.claude/skills"
FORCE=false
SKILL_NAMES=()

die() { echo "error: $*" >&2; exit 2; }

print_usage() {
  # Extract the leading comment block as help text.
  sed -n '2,/^$/{s/^# \{0,1\}//;p;}' "$0" | sed '/^!/d'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-root) PROJECT_ROOT="$2"; shift 2 ;;
    --mount-path)   MOUNT_PATH="$2"; shift 2 ;;
    --targets)      TARGETS="$2"; shift 2 ;;
    --force)        FORCE=true; shift ;;
    --help|-h)      print_usage; exit 0 ;;
    --*)            die "unknown flag: $1" ;;
    *)              SKILL_NAMES+=("$1"); shift ;;
  esac
done

[[ ${#SKILL_NAMES[@]} -gt 0 ]] || die "no skill names provided (use --help for usage)"
[[ "$MOUNT_PATH" != /* ]] || die "--mount-path must be relative, got: $MOUNT_PATH"
[[ -d "$PROJECT_ROOT" ]] || die "--project-root not a directory: $PROJECT_ROOT"

cd "$PROJECT_ROOT"

HARNESS_SKILLS_DIR="${MOUNT_PATH}/platform/skills"
[[ -d "$HARNESS_SKILLS_DIR" ]] \
  || die "harness skills dir not found at '$HARNESS_SKILLS_DIR' (is the submodule initialized? try: git submodule update --init)"

for name in "${SKILL_NAMES[@]}"; do
  [[ -d "${HARNESS_SKILLS_DIR}/${name}" ]] \
    || die "unknown skill '$name' (looked in ${HARNESS_SKILLS_DIR}/)"
done

# count_segments <path> — number of path components after stripping trailing /
count_segments() {
  local p="${1%/}"
  [[ -z "$p" ]] && { echo 0; return; }
  # count '/' and add 1
  local slashes
  slashes=$(tr -cd '/' <<< "$p" | wc -c)
  echo $((slashes + 1))
}

ok_count=0
created_count=0
replaced_count=0
conflict_count=0

IFS=',' read -r -a TARGET_DIRS <<< "$TARGETS"

for raw_tgt in "${TARGET_DIRS[@]}"; do
  tgt_dir="${raw_tgt%/}"
  [[ -z "$tgt_dir" ]] && { echo "warning: skipping empty target-dir entry" >&2; continue; }

  mkdir -p "$tgt_dir"

  segments=$(count_segments "$tgt_dir")
  up_path=""
  for ((i=0; i<segments; i++)); do up_path+="../"; done

  for name in "${SKILL_NAMES[@]}"; do
    link_path="${tgt_dir}/${name}"
    expected_target="${up_path}${MOUNT_PATH}/platform/skills/${name}"

    if [[ -L "$link_path" ]]; then
      actual_target=$(readlink "$link_path")
      if [[ "$actual_target" == "$expected_target" ]]; then
        echo "[OK] ${link_path}"
        ok_count=$((ok_count + 1))
      elif $FORCE; then
        rm "$link_path"
        ln -s "$expected_target" "$link_path"
        echo "[REPLACED] ${link_path} (was → ${actual_target})"
        replaced_count=$((replaced_count + 1))
      else
        echo "[CONFLICT] ${link_path} points to ${actual_target} (use --force to replace)"
        conflict_count=$((conflict_count + 1))
      fi
    elif [[ -d "$link_path" ]]; then
      # A real directory is user-authored content; never delete, even with --force.
      echo "[CONFLICT] ${link_path} is a directory, not a symlink; refusing to clobber (even with --force)"
      conflict_count=$((conflict_count + 1))
    elif [[ -e "$link_path" ]]; then
      echo "[CONFLICT] ${link_path} exists and is neither symlink nor directory; refusing to modify"
      conflict_count=$((conflict_count + 1))
    else
      ln -s "$expected_target" "$link_path"
      echo "[CREATED] ${link_path} → ${expected_target}"
      created_count=$((created_count + 1))
    fi
  done
done

echo ""
echo "Summary: ${ok_count} OK, ${created_count} CREATED, ${replaced_count} REPLACED, ${conflict_count} CONFLICTS"

[[ $conflict_count -eq 0 ]] || exit 1
exit 0
