#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <nate@bdits.io>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# add-license-headers.sh
# ----------------------
# Inserts SPDX/copyright headers into tracked auto-harness source files,
# idempotently. Re-running is safe — files that already carry a
# `SPDX-License-Identifier:` line are skipped.
#
# Usage:
#   bash platform/bootstrap/add-license-headers.sh           # dry-run (default)
#   bash platform/bootstrap/add-license-headers.sh --apply   # actually write changes
#
# Per-extension header formats:
#   *.sh                3 lines, # comment, inserted after shebang
#   *.rb                3 lines, # comment, top of file
#   *.yml / *.yaml      2 lines, # comment, top of file
#   *.md                4-line HTML comment block, top of file
#                       (files starting with YAML frontmatter `---` are skipped)
#
# Skipped paths:
#   .git/, .remember/, legacy/, node_modules/, .DS_Store
#   platform/validators/test/fixtures/  (deliberately malformed test data)
#
# Exit codes:
#   0  Success (no changes needed in dry-run; changes applied in --apply)
#   1  Unexpected error

set -euo pipefail

YEAR=2026
AUTHOR='Nate DiNiro <nate@bdits.io>'
SPDX='MIT OR Apache-2.0'
PROJECT_NAME='auto-harness'

APPLY=0
if [[ "${1:-}" == "--apply" ]]; then
  APPLY=1
fi

# Locate repo root so the script is callable from anywhere.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

count_total=0
count_skipped_existing=0
count_skipped_frontmatter=0
count_skipped_excluded=0
count_would_change=0

# Path-based exclusions.
#
# Curated team records (knowledge captures, opportunity records, observations)
# are governance artifacts whose edits are gated by companion rules. Bulk
# header insertion would falsely trigger those rules. The dual license still
# applies via LICENSE-MIT / LICENSE-APACHE at the repository root; per-file
# indicia on those files is helpful but not legally required.
is_excluded() {
  local path="$1"
  case "$path" in
    .git/*|.remember/*|legacy/*|node_modules/*) return 0 ;;
    platform/validators/test/fixtures/*) return 0 ;;
    docs/knowledge/distilled-learnings.md) return 0 ;;
    docs/knowledge/shared-observations.md) return 0 ;;
    docs/opportunities/OPP-*.md) return 0 ;;
    *.DS_Store) return 0 ;;
  esac
  return 1
}

# Detect an existing SPDX-License-Identifier in the first 10 lines.
has_spdx_header() {
  head -n 10 "$1" 2>/dev/null | grep -q 'SPDX-License-Identifier:'
}

# Detect Markdown YAML frontmatter (first non-empty line is `---`).
starts_with_frontmatter() {
  local first
  first="$(awk 'NF{print; exit}' "$1" 2>/dev/null || true)"
  [[ "$first" == '---' ]]
}

apply_shell_header() {
  local file="$1"
  local tmp
  tmp="$(mktemp)"
  if head -n 1 "$file" | grep -q '^#!'; then
    head -n 1 "$file" > "$tmp"
    {
      printf '# Copyright %s %s\n' "$YEAR" "$AUTHOR"
      printf '# SPDX-License-Identifier: %s\n' "$SPDX"
      printf '# Part of %s — see LICENSE-MIT and LICENSE-APACHE at repository root.\n' "$PROJECT_NAME"
    } >> "$tmp"
    tail -n +2 "$file" >> "$tmp"
  else
    {
      printf '# Copyright %s %s\n' "$YEAR" "$AUTHOR"
      printf '# SPDX-License-Identifier: %s\n' "$SPDX"
      printf '# Part of %s — see LICENSE-MIT and LICENSE-APACHE at repository root.\n' "$PROJECT_NAME"
    } > "$tmp"
    cat "$file" >> "$tmp"
  fi
  mv "$tmp" "$file"
}

apply_yaml_header() {
  local file="$1"
  local tmp
  tmp="$(mktemp)"
  {
    printf '# Copyright %s %s\n' "$YEAR" "$AUTHOR"
    printf '# SPDX-License-Identifier: %s\n' "$SPDX"
  } > "$tmp"
  cat "$file" >> "$tmp"
  mv "$tmp" "$file"
}

apply_markdown_header() {
  local file="$1"
  local tmp
  tmp="$(mktemp)"
  {
    printf '<!--\n'
    printf 'Copyright %s %s\n' "$YEAR" "$AUTHOR"
    printf 'SPDX-License-Identifier: %s\n' "$SPDX"
    printf 'Part of %s — see LICENSE-MIT and LICENSE-APACHE at repository root.\n' "$PROJECT_NAME"
    printf -- '-->\n\n'
  } > "$tmp"
  cat "$file" >> "$tmp"
  mv "$tmp" "$file"
}

process_file() {
  local file="$1"
  count_total=$((count_total + 1))

  if is_excluded "$file"; then
    count_skipped_excluded=$((count_skipped_excluded + 1))
    return 0
  fi

  if has_spdx_header "$file"; then
    count_skipped_existing=$((count_skipped_existing + 1))
    return 0
  fi

  case "$file" in
    *.sh)
      count_would_change=$((count_would_change + 1))
      [[ "$APPLY" == "1" ]] && apply_shell_header "$file"
      echo "  [shell]    $file"
      ;;
    *.rb)
      count_would_change=$((count_would_change + 1))
      [[ "$APPLY" == "1" ]] && apply_shell_header "$file"
      echo "  [ruby]     $file"
      ;;
    *.yml|*.yaml)
      count_would_change=$((count_would_change + 1))
      [[ "$APPLY" == "1" ]] && apply_yaml_header "$file"
      echo "  [yaml]     $file"
      ;;
    *.md)
      if starts_with_frontmatter "$file"; then
        count_skipped_frontmatter=$((count_skipped_frontmatter + 1))
        return 0
      fi
      count_would_change=$((count_would_change + 1))
      [[ "$APPLY" == "1" ]] && apply_markdown_header "$file"
      echo "  [markdown] $file"
      ;;
  esac
}

echo "auto-harness license-header inserter"
echo "  mode: $([ "$APPLY" == "1" ] && echo APPLY || echo DRY-RUN)"
echo "  repo: $REPO_ROOT"
echo

while IFS= read -r -d '' file; do
  process_file "$file"
done < <(
  git ls-files -z -- \
    '*.sh' '*.rb' '*.yml' '*.yaml' '*.md' \
    2>/dev/null || true
)

echo
echo "Summary:"
echo "  Total files considered:      $count_total"
echo "  Already had SPDX header:     $count_skipped_existing"
echo "  Skipped (frontmatter):       $count_skipped_frontmatter"
echo "  Skipped (excluded path):     $count_skipped_excluded"
echo "  Files $([ "$APPLY" == "1" ] && echo CHANGED || echo 'that WOULD CHANGE'): $count_would_change"

if [[ "$APPLY" == "0" && "$count_would_change" -gt 0 ]]; then
  echo
  echo "Run with --apply to write the headers."
fi
