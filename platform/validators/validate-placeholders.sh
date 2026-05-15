#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
set -euo pipefail

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
  echo "rg is required for placeholder validation." >&2
  exit 1
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
  echo "✗ Placeholder validation failed to run cleanly." >&2
  exit ${STATUS}
fi

echo "✗ Unresolved placeholders found:"
echo "${FINDINGS}"
exit 1
