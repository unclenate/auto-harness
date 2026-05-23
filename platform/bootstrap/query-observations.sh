#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# query-observations.sh — grep-based query helper for the knowledge
# destinations.
#
# Closes the "knowledge management is write-only" gap identified in
# the 2026-05-23 audit and operating-principle-§-8-paired observation.
# The `shared-observations.md` file accretes over a project's lifetime;
# without a query tool, finding "all observations about X" or "all
# architectural-severity observations" requires manual grep + visual
# parsing.
#
# This is the v1 — pure bash + ripgrep. A richer indexing tool may
# come later if a project's observation file grows past O(100) entries.
#
# Usage:
#   query-observations.sh [--severity=LEVEL] [--topic=KEYWORD]
#                         [--since=YYYY-MM-DD] [--list-only]
#                         [<path-to-shared-observations.md>]
#
# Exit codes:
#   0  query completed (zero or more results displayed)
#   1  no observations matched (when at least one filter is supplied)
#   2  usage error (missing file, bad arg, ripgrep not installed)

set -euo pipefail

# ----------------------------------------------------------------------
# Help
# ----------------------------------------------------------------------

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
query-observations.sh — Filter and surface observations from shared-observations.md.

Usage:
  query-observations.sh [flags] [<path>]

Default behavior (no flags):
  List every observation's heading + severity + contributor (compact).
  Default <path> is docs/knowledge/shared-observations.md relative to cwd.

Flags:
  --severity=LEVEL   Filter to observations tagged with this severity
                     (architectural / process / informational / security)
  --topic=KEYWORD    Filter to observations whose heading or body mentions
                     KEYWORD (case-insensitive substring match)
  --since=YYYY-MM-DD Filter to observations contributed on or after this date
                     (matches the "Contributed by: ... YYYY-MM-DD" footer)
  --list-only        Show only headings + metadata (no body); default
  --full             Show full observation body for each match
  -h, --help         Show this help

Examples:
  # Every architectural observation, headings only
  bash query-observations.sh --severity=architectural

  # Everything about distillation
  bash query-observations.sh --topic=distillation --full

  # Observations from the last week, listed compactly
  bash query-observations.sh --since=2026-05-17

  # Combine filters
  bash query-observations.sh --severity=process --since=2026-05-20

Spec source: 2026-05-23 audit follow-up (Wave 3-B small bundle).
USAGE
    exit 0
    ;;
esac

# ----------------------------------------------------------------------
# Defaults + arg parsing
# ----------------------------------------------------------------------

FILE="docs/knowledge/shared-observations.md"
SEVERITY=""
TOPIC=""
SINCE=""
SHOW_FULL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --severity=*) SEVERITY="${1#*=}" ;;
    --topic=*) TOPIC="${1#*=}" ;;
    --since=*) SINCE="${1#*=}" ;;
    --list-only) SHOW_FULL=0 ;;
    --full) SHOW_FULL=1 ;;
    -h|--help) exec "$0" --help ;;
    --) shift; break ;;
    -*) echo "✗ Unknown flag: $1" >&2; exit 2 ;;
    *) FILE="$1" ;;
  esac
  shift
done

# ----------------------------------------------------------------------
# Sanity checks
# ----------------------------------------------------------------------

if [[ ! -f "$FILE" ]]; then
  echo "✗ Observations file not found: $FILE" >&2
  echo "  Pass a path explicitly: query-observations.sh /path/to/shared-observations.md" >&2
  exit 2
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "✗ rg (ripgrep) is required. Install ripgrep and re-run." >&2
  exit 2
fi

# ----------------------------------------------------------------------
# Parse observations
# ----------------------------------------------------------------------
#
# Each observation in shared-observations.md is a block beginning with
# `### <heading>` and ending at the next `### ` (or EOF). Inside the
# block, fields appear as `- **Field:** value`. We parse heading +
# severity + contributor-date for filtering.
#
# Storage: parallel arrays (Bash 3.2 compatible).

HEADINGS=()
SEVERITIES=()
DATES=()
CONTRIBUTORS=()
BODIES=()  # body text including the heading line

current_body=""
current_heading=""
current_severity=""
current_date=""
current_contributor=""

flush_current() {
  if [[ -n "$current_heading" ]]; then
    HEADINGS+=("$current_heading")
    SEVERITIES+=("$current_severity")
    DATES+=("$current_date")
    CONTRIBUTORS+=("$current_contributor")
    BODIES+=("$current_body")
  fi
}

while IFS= read -r line; do
  if [[ "$line" =~ ^###[[:space:]]+(.+)$ ]]; then
    flush_current
    current_heading="${BASH_REMATCH[1]}"
    current_severity=""
    current_date=""
    current_contributor=""
    current_body="$line"
  elif [[ -n "$current_heading" ]]; then
    current_body+=$'\n'"$line"
    if [[ "$line" =~ \*\*Severity:\*\*[[:space:]]+([a-z]+) ]]; then
      current_severity="${BASH_REMATCH[1]}"
    fi
    if [[ "$line" =~ \*\*Contributed[[:space:]]by:\*\*[[:space:]]+(.+)[[:space:]]([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
      current_contributor="${BASH_REMATCH[1]}"
      current_date="${BASH_REMATCH[2]}"
    fi
  fi
done < "$FILE"
flush_current

# ----------------------------------------------------------------------
# Apply filters
# ----------------------------------------------------------------------

matches=0
filter_count=0
[[ -n "$SEVERITY" ]] && filter_count=$((filter_count + 1))
[[ -n "$TOPIC" ]] && filter_count=$((filter_count + 1))
[[ -n "$SINCE" ]] && filter_count=$((filter_count + 1))

# Lowercase helper for topic filter (Bash 3.2 compatible).
to_lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }
TOPIC_LC="$(to_lower "$TOPIC")"

for i in "${!HEADINGS[@]}"; do
  heading="${HEADINGS[$i]}"
  severity="${SEVERITIES[$i]}"
  date="${DATES[$i]}"
  body="${BODIES[$i]}"

  # Severity filter
  if [[ -n "$SEVERITY" && "$severity" != "$SEVERITY" ]]; then
    continue
  fi

  # Date filter
  if [[ -n "$SINCE" ]]; then
    if [[ -z "$date" ]] || [[ "$date" < "$SINCE" ]]; then
      continue
    fi
  fi

  # Topic filter (case-insensitive substring match in body)
  if [[ -n "$TOPIC" ]]; then
    body_lc="$(to_lower "$body")"
    if [[ "$body_lc" != *"$TOPIC_LC"* ]]; then
      continue
    fi
  fi

  matches=$((matches + 1))

  if [[ "$SHOW_FULL" == 1 ]]; then
    echo "$body"
    echo ""
    echo "---"
    echo ""
  else
    printf '%-12s  %-10s  %s\n' "${date:-?}" "${severity:-?}" "$heading"
  fi
done

# ----------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------

if [[ "$matches" -eq 0 ]]; then
  if [[ "$filter_count" -gt 0 ]]; then
    echo "" >&2
    echo "No observations matched the filter set." >&2
    exit 1
  fi
fi

if [[ "$SHOW_FULL" == 0 ]]; then
  echo ""
  echo "($matches observation(s); --full for body text)"
fi
exit 0
