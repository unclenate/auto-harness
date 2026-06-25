#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
set -euo pipefail

# validate-publication-boundary.sh — Per PRD-0026 / OPP-0048.
# Always-on, kernel-level publication-boundary gate: fail if any git-TRACKED
# file declares a do-not-publish marker. The marker is an author-asserted
# intent that travels with the artifact; a marker in an UNTRACKED file is
# invisible to `git ls-files` (the intended steady state) and passes cleanly.
# This is the inverse of a required-artifact check: a must-NOT-be-tracked
# assertion. It needs no corpus of private names.

# Marker grammar (line-start only, so a mid-sentence prose mention does not
# trip): a YAML frontmatter key OR an HTML-comment sentinel.
#   do-not-publish: true
#   <!-- do-not-publish: true -->
MARKER_ERE='^(<!--[[:space:]]*)?do-not-publish:[[:space:]]*true([[:space:]]|$)'

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-publication-boundary.sh — Block do-not-publish-marked files from the tracked tree.

Usage:
  validate-publication-boundary.sh [<project-root>]
  validate-publication-boundary.sh --staged [<project-root>]
  validate-publication-boundary.sh --scan-file <path> [<path>...]

Modes:
  (default)      Scan every git-TRACKED file under <project-root> (default: cwd).
  --staged       Scan only staged files (git diff --cached) — for a pre-commit hook.
  --scan-file    Scan the given explicit paths directly, without git — a test seam.

Marker (line-start; a mid-sentence mention does NOT match):
  do-not-publish: true              (YAML frontmatter key)
  <!-- do-not-publish: true -->     (HTML-comment sentinel)

Exemptions (default/--staged modes only):
  Path regexes in <project-root>/.publication-boundary-ignore (one per line; # comments)
  exempt files that legitimately DISCUSS the marker (this validator, the template, the PRD).

Pre-commit hook (the actual prevention; CI is the backstop):
  bash platform/validators/validate-publication-boundary.sh --staged . || exit 1

Exit codes:
  0  pass (no tracked file declares the marker, or outside a git tree)
  1  violation (a tracked/staged/given file declares the marker)
  2  usage error (missing argument)
USAGE
    exit 0
    ;;
esac

# --- marker check over an explicit list of files (the pure checker) ----------
# Echoes "path:lineno:line" for every marker hit; returns 0 when clean (no
# marker), 1 when a violation (at least one marker) is found.
scan_paths() {
  local clean=0 file hit
  for file in "$@"; do
    [[ -f "${file}" ]] || continue
    if hit=$(grep -nEI "${MARKER_ERE}" -- "${file}" 2>/dev/null); then
      while IFS= read -r line; do
        echo "${file}:${line}"
      done <<< "${hit}"
      clean=1
    fi
  done
  return ${clean}
}

# --- mode: --scan-file (no git; test seam) -----------------------------------
if [[ "${1:-}" == "--scan-file" ]]; then
  shift
  if [[ $# -eq 0 ]]; then
    echo "✗ --scan-file requires at least one path." >&2
    exit 2
  fi
  set +e
  HITS=$(scan_paths "$@")
  STATUS=$?
  set -e
  if [[ ${STATUS} -eq 0 ]]; then
    echo "✓ No do-not-publish marker in the scanned file(s)."
    exit 0
  fi
  echo "✗ do-not-publish marker found in scanned file(s):"
  echo "${HITS}"
  exit 1
fi

# --- mode: default / --staged (git tree) -------------------------------------
STAGED=0
if [[ "${1:-}" == "--staged" ]]; then
  STAGED=1
  shift
fi
PROJECT_ROOT="${1:-$(pwd)}"
cd "${PROJECT_ROOT}"

# Outside a git tree → nothing to gate; pass with an informational message
# (mirrors validate-knowledge-redaction's shallow-checkout handling).
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "✓ Publication-boundary validation skipped (not inside a git work tree)."
  exit 0
fi

# Load path-regex exemptions
IGNORE_FILE="${PROJECT_ROOT}/.publication-boundary-ignore"
IGNORES=()
if [[ -f "${IGNORE_FILE}" ]]; then
  while IFS= read -r line; do
    [[ -z "${line}" || "${line}" == \#* ]] && continue
    IGNORES+=("${line}")
  done < "${IGNORE_FILE}"
fi

is_ignored() {
  local path="$1" pat
  for pat in "${IGNORES[@]:-}"; do
    [[ -z "${pat}" ]] && continue
    if printf '%s\n' "${path}" | grep -qE "${pat}"; then
      return 0
    fi
  done
  return 1
}

# Enumerate candidate files
# Bash 3.2 (macOS default) has no `mapfile`/`readarray`; use a portable read loop.
CANDIDATES=()
if [[ ${STAGED} -eq 1 ]]; then
  SCOPE="staged"
  while IFS= read -r _f; do CANDIDATES+=("${_f}"); done \
    < <(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)
else
  SCOPE="tracked"
  while IFS= read -r _f; do CANDIDATES+=("${_f}"); done \
    < <(git ls-files 2>/dev/null || true)
fi

if [[ ${#CANDIDATES[@]} -eq 0 ]]; then
  echo "✓ Publication-boundary validation passed (no ${SCOPE} files to scan)."
  exit 0
fi

FILES=()
for f in "${CANDIDATES[@]}"; do
  [[ -z "${f}" ]] && continue
  if is_ignored "${f}"; then continue; fi
  FILES+=("${f}")
done

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "✓ Publication-boundary validation passed (all ${SCOPE} files exempted)."
  exit 0
fi

set +e
HITS=$(scan_paths "${FILES[@]}")
STATUS=$?
set -e

if [[ ${STATUS} -eq 0 ]]; then
  echo "✓ Publication-boundary validation passed (${#FILES[@]} ${SCOPE} file(s); no do-not-publish marker)."
  exit 0
fi

echo "✗ A do-not-publish-marked file is ${SCOPE} in git — it must never be published:" >&2
echo "${HITS}" >&2
echo "→ git rm --cached <path> and keep it untracked, or remove the marker if publication is intended." >&2
exit 1
