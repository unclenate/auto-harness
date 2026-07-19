#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-status-parity.sh — Assert every OPP record's canonical Status
# agrees with the status token in each of its derived index surfaces.
#
# Why this exists:
#   An OPP record's `**Status:**` field is the source of truth for that
#   opportunity's lifecycle state, but the same state is mirrored into two
#   derived surfaces that no validator reconciles:
#     1. docs/opportunities/candidates.md — the leading token of each entry's
#        `*(…)*` annotation.
#     2. docs/README.md — the status column of the opportunities index table.
#   `validate-list-completeness.sh` asserts every OPP has an index *row*
#   (presence) but never that the row's *status* agrees with the record. The
#   result is silent drift, arbitrarily long-lived, and worst exactly where
#   work moves fastest — the same failure `validate-catalog-counts.sh` closes
#   for *counts*, applied here to *status*.
#
#   This is the third always-on structural reconciler (recompute a derived
#   claim from its source and diff), sitting between catalog-counts (row
#   counts) and list-completeness (row presence): it checks row *status*.
#   Per PRD-0036 / OPP-0054.
#
# Usage:
#   validate-status-parity.sh [<project-root>]
#
# Behavior:
#   For each docs/opportunities/OPP-NNNN-*.md record, extracts the leading
#   canonical Status token, then for each derived surface locates the record's
#   entry — anchored on the exact OPP-id + filename, never a prose mention —
#   and asserts the surface's leading status token equals the record's. A
#   surface entry with no status token normalizes to an implicit `proposed`
#   (so an `accepted` record with an un-annotated entry fails, while a
#   genuinely-`proposed` record with no annotation passes). Presence of the
#   entry itself is validate-list-completeness's job; a surface that has no
#   entry for a record is skipped here (no status to compare).
#
# Design (per PRD-0036, § 10 forks resolved):
#   - Missing-annotation policy: implicit `proposed` (option c).
#   - Enforcement posture: BLOCK (exit 1 on any drift), matching the two
#     same-species always-on reconcilers; WARN is reserved for the fuzzy
#     denylist check (validate-knowledge-redaction.sh).
#   - Surfaces are declared in the SURFACES loop below; adding a third status
#     mirror later means adding a branch there, not re-coding the comparison.
#   - Leading-token equality only — never whether the chosen status is the
#     semantically correct disposition (the validate-module-stability boundary).
#
# The project-root positional is the test seam: fixture tests build a mini
# project root (docs/opportunities/ records + candidates.md + docs/README.md)
# and point the validator at it. A single-file `--scan-file` is intentionally
# not offered — the check is inherently cross-file (record ↔ surface), so a
# lone surface file carries no source of truth to diff against.
#
# Exit codes:
#   0  every derived surface's status token agrees with its record
#   1  one or more surfaces drift from their record's Status (or an
#      unrecognized status token on a record)
#   2  usage error (bad project-root, etc.)

set -euo pipefail

# ----------------------------------------------------------------------
# Help
# ----------------------------------------------------------------------

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-status-parity.sh — Assert each OPP's Status matches its index surfaces.

Usage:
  validate-status-parity.sh [<project-root>]

Arguments:
  project-root  Path to scan (optional; default: current working directory).
                Must be the auto-harness repo or a checkout with the same
                docs/opportunities/ + docs/README.md layout. When run against
                a consumer project with no docs/opportunities/ tree, the check
                is a vacuous no-op (zero records → exit 0).

Behavior:
  For each docs/opportunities/OPP-NNNN-*.md record, extracts the leading
  canonical Status token and compares it against the status token in each
  derived surface:
    - docs/opportunities/candidates.md  (the `*(token …)*` annotation)
    - docs/README.md                    (the opportunities-table status column)
  Entries are matched on the exact OPP-id + filename anchor (never a prose
  mention). A matched entry with no status token normalizes to an implicit
  `proposed`. Only leading-token equality is checked — never whether the
  chosen status is semantically correct.

  Recognized status tokens: proposed, exploring, accepted, rejected,
  superseded, deferred (extended append-only when a future ADR adds a
  lifecycle state).

Posture: BLOCK — any drift exits 1.

Exit codes:
  0  every derived surface's status agrees with its record
  1  drift detected (or an unrecognized status token on a record)
  2  usage error
USAGE
    exit 0
    ;;
esac

PROJECT_ROOT="${1:-$(pwd)}"

if [[ ! -d "$PROJECT_ROOT" ]]; then
  echo "✗ Project root not a directory: $PROJECT_ROOT" >&2
  exit 2
fi

cd "$PROJECT_ROOT"

# ----------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------

# leading_token STRING — echo the lowercased first alphabetic run of STRING,
# or the empty string if it contains none. Normalizes richer surface labels
# ("accepted (partial promotion)", "proposed 2026-07-16") to their canonical
# leading token.
leading_token() {
  local s="$1"
  if [[ "$s" =~ ([A-Za-z]+) ]]; then
    printf '%s' "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]'
  fi
}

# is_recognized TOKEN — 0 if TOKEN is a known lifecycle/terminal status.
is_recognized() {
  case "$1" in
    proposed|exploring|accepted|rejected|superseded|deferred) return 0 ;;
    *) return 1 ;;
  esac
}

# record_status FILE — echo the leading token of the record's `**Status:**`
# line (empty if the file has no such line).
record_status() {
  local file="$1" l
  while IFS= read -r l; do
    if [[ "$l" =~ ^\*\*Status:\*\*[[:space:]]*(.*)$ ]]; then
      leading_token "${BASH_REMATCH[1]}"
      return 0
    fi
  done < "$file"
}

# candidates_status FILE FILENAME — for the candidates.md list-item whose link
# target is exactly FILENAME, echo the leading token of the first `*(…)*`
# annotation in that entry's block, or `proposed` when the entry has none.
# Returns 1 (no output) when no list-item entry targets FILENAME (presence is
# list-completeness's job).
#
# The annotation is NOT always on the link line: long bullets wrap, so the
# `*(accepted …)*` token frequently sits on the following (indented) line. The
# entry block runs from the link line to the next list item, blank line, or
# heading; we scan the whole block for the first annotation.
candidates_status() {
  local file="$1" filename="$2" l in_entry=0
  [[ -f "$file" ]] || return 1
  while IFS= read -r l; do
    if [[ $in_entry -eq 1 ]]; then
      # A new list item, a blank line, or a heading ends the entry block.
      if [[ "$l" =~ ^-[[:space:]] ]] || [[ -z "${l//[[:space:]]/}" ]] || [[ "$l" =~ ^# ]]; then
        printf 'proposed'
        return 0
      fi
      if [[ "$l" =~ \*\(([A-Za-z]+) ]]; then
        leading_token "${BASH_REMATCH[1]}"
        return 0
      fi
      continue
    fi
    # Anchor: a Markdown list item "- [OPP-NNNN](target)". Compare the captured
    # target to FILENAME by string equality so a prose mention never matches.
    if [[ "$l" =~ ^-[[:space:]]+\[OPP-[0-9]{4}\]\(([^\)]+)\) ]]; then
      if [[ "${BASH_REMATCH[1]}" == "$filename" ]]; then
        # Annotation on the link line itself?
        if [[ "$l" =~ \*\(([A-Za-z]+) ]]; then
          leading_token "${BASH_REMATCH[1]}"
          return 0
        fi
        in_entry=1   # scan the block's continuation lines for the annotation
      fi
    fi
  done < "$file"
  # Entry was the file's last bullet with no annotation before EOF.
  if [[ $in_entry -eq 1 ]]; then
    printf 'proposed'
    return 0
  fi
  return 1
}

# readme_status FILE FILENAME — for the docs/README.md opportunities-table row
# whose link target is exactly `opportunities/FILENAME`, echo the status
# column's leading token (implicit `proposed` when the cell is empty). Returns
# 1 when no table row targets FILENAME.
readme_status() {
  local file="$1" filename="$2" l tok
  [[ -f "$file" ]] || return 1
  while IFS= read -r l; do
    # Anchor: a table cell link "[NNNN](opportunities/target)" — the 4-digit
    # link text (no OPP- prefix) is unique to the index table, not prose.
    if [[ "$l" =~ \[[0-9]{4}\]\(opportunities/([^\)]+)\) ]]; then
      if [[ "${BASH_REMATCH[1]}" == "$filename" ]]; then
        # Status = the last pipe-delimited cell on the row.
        if [[ "$l" =~ \|([^\|]*)\|[[:space:]]*$ ]]; then
          tok="$(leading_token "${BASH_REMATCH[1]}")"
          if [[ -n "$tok" ]]; then printf '%s' "$tok"; else printf 'proposed'; fi
        else
          printf 'proposed'
        fi
        return 0
      fi
    fi
  done < "$file"
  return 1
}

# ----------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------

violations=0
checks=0
records=0

if [[ -d docs/opportunities ]]; then
  for opp in docs/opportunities/OPP-*.md; do
    [[ -e "$opp" ]] || continue
    filename="$(basename "$opp")"
    id="${filename:0:8}"   # OPP-NNNN
    records=$((records + 1))

    rec="$(record_status "$opp")"
    if ! is_recognized "$rec"; then
      echo "✗ $id: unrecognized (or missing) record Status token '${rec:-<none>}'" >&2
      violations=$((violations + 1))
      continue
    fi

    # Surface 1 — candidates.md annotation
    if cand="$(candidates_status docs/opportunities/candidates.md "$filename")"; then
      checks=$((checks + 1))
      if [[ "$cand" != "$rec" ]]; then
        echo "✗ candidates.md: $id annotation reads '$cand' but record Status is '$rec'" >&2
        violations=$((violations + 1))
      fi
    fi

    # Surface 2 — docs/README.md status column
    if rd="$(readme_status docs/README.md "$filename")"; then
      checks=$((checks + 1))
      if [[ "$rd" != "$rec" ]]; then
        echo "✗ docs/README.md: $id status column reads '$rd' but record Status is '$rec'" >&2
        violations=$((violations + 1))
      fi
    fi
  done
fi

# ----------------------------------------------------------------------
# Result
# ----------------------------------------------------------------------

if [[ "$violations" -gt 0 ]]; then
  echo "" >&2
  echo "✗ Status-parity drift detected: $violations mismatch(es) across $records OPP record(s)." >&2
  echo "  Align each derived surface's status token with the record's **Status:**," >&2
  echo "  or correct the record. A missing annotation normalizes to 'proposed'." >&2
  exit 1
fi

echo "✓ status-parity: $records OPP record(s) × their index surfaces reconciled ($checks checks), 0 drift."
exit 0
