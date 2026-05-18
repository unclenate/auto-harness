#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
set -euo pipefail

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-placeholders.sh — Scan a project for unresolved [[PLACEHOLDER]] / YYYY-MM-DD tokens.

Usage:
  validate-placeholders.sh [<project-root>]

Arguments:
  project-root  Path to the consumer project root (optional; default: current working directory)

Behavior:
  Scans every tracked file under <project-root> using ripgrep, honoring path patterns
  in <project-root>/.placeholder-ignore (one glob per line; # for comments).

Example:
  bash platform/validators/validate-placeholders.sh .

Exit codes:
  0  validation passed (no unresolved placeholders found)
  1  validation failed (one or more unresolved placeholders present)
  2  usage error (ripgrep not installed, ripgrep failed unexpectedly)
USAGE
    exit 0
    ;;
esac

PROJECT_ROOT="${1:-$(pwd)}"
IGNORE_FILE="${PROJECT_ROOT}/.placeholder-ignore"
PLACEHOLDER_PATTERN='\[\[[A-Z0-9_]+\]\]|YYYY-MM-DD'

cd "${PROJECT_ROOT}"

EXCLUDES=()
if [[ -f "${IGNORE_FILE}" ]]; then
  while IFS= read -r line; do
    [[ -z "${line}" || "${line}" == \#* ]] && continue
    EXCLUDES+=(--glob "!${line}")
  done < "${IGNORE_FILE}"
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "✗ rg (ripgrep) is required for placeholder validation. Install ripgrep and re-run." >&2
  exit 2
fi

set +e
if [[ ${#EXCLUDES[@]} -gt 0 ]]; then
  FINDINGS=$(rg -n "${PLACEHOLDER_PATTERN}" . "${EXCLUDES[@]}" 2>/dev/null)
else
  FINDINGS=$(rg -n "${PLACEHOLDER_PATTERN}" . 2>/dev/null)
fi
STATUS=$?
set -e

if [[ ${STATUS} -eq 1 ]]; then
  echo "✓ No unresolved placeholders found."
  exit 0
fi

if [[ ${STATUS} -ne 0 ]]; then
  echo "✗ Placeholder validation failed to run cleanly (rg exit ${STATUS})." >&2
  exit 2
fi

echo "✗ Unresolved placeholders found:"
echo "${FINDINGS}"
exit 1
