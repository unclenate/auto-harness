#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-knowledge-redaction.sh — Scan new lines added to durable
# knowledge surfaces (`docs/knowledge/shared-observations.md` and
# `docs/operating-principles.md`) against a denylist of consumer-name
# patterns. Default posture: WARN (exit 0 with surfaced hits on stderr).
# Optional `--block` flag escalates hits to a hard fail (exit 1).
#
# Why this exists:
#   Auto-harness ships durable doctrine that absorbs lessons learned
#   from specific consumer projects (Tula, OpenEMR, YouBase, municipal-
#   brain, etc.). The cycle-end distillation rule (PRD-0004) routes
#   distillation-worthy work into upstream-tracked knowledge files,
#   where consumer-specific evidence becomes load-bearing for framework
#   doctrine. Safety-security-sweep §8 found 50+ consumer mentions in
#   `shared-observations.md` and called out the upstream-propagation
#   pathway as built-in by design. §9 names four pathways — including
#   "any PR-author can land observations without CODEOWNERS guard" —
#   and recommends a warn-then-redact discipline.
#
#   This validator implements the warn-half of that discipline: surface
#   consumer-name hits in NEW LINES added to the two knowledge files,
#   so reviewers see them before merge. The CODEOWNERS half (Wave 5.5
#   companion change) routes review of `docs/knowledge/` through the
#   maintainer. Together they convert §8 + §9 upstream-leakage from
#   "structurally built-in" to "machine-surfaced + maintainer-gated."
#
#   Roadmap citation: ADR-0017 (Safety Hardening Roadmap) Wave 5.5.
#   Closes safety-security-sweep §8 cross-pollination findings and §9
#   reverse-direction propagation pathways 1–4 per OPP-0036.
#
# Usage:
#   validate-knowledge-redaction.sh [<project-root>] [<base-branch>]
#   validate-knowledge-redaction.sh --block [<project-root>] [<base-branch>]
#
# Behavior:
#   1. Compute `git diff` between HEAD and the base branch (default:
#      `main`) for the two watched files.
#   2. Extract only NEW lines (added in the PR; lines beginning with
#      `+` in the unified diff, excluding the `+++` header).
#   3. For each new line, scan against the built-in denylist of
#      consumer-name patterns. Lines matching any pattern in
#      `.knowledge-redaction-ignore` (project-root-scoped) are exempt.
#   4. Surface hits to stderr with file path + line number + matched
#      pattern + the offending line excerpt.
#   5. Default: exit 0 even on hits (WARN posture). With `--block`:
#      exit 1 on any hit (post-corpus-stabilization posture per
#      OPP-0036 v2).
#
#   Watched files (v1 scope):
#     - docs/knowledge/shared-observations.md
#     - docs/operating-principles.md
#
#   Denylist (v1 seed; extend via patches as new consumer corpus
#   stabilizes):
#     - Tula
#     - OpenEMR
#     - YouBase
#     - municipal-brain
#     - toast-mcp
#
#   `.knowledge-redaction-ignore` format: one regex per line; lines
#   starting with `#` are comments. A new line matching any ignore
#   pattern is exempted from scanning.
#
# Exit codes:
#   0  no hits, OR hits surfaced as warnings (default WARN posture)
#   1  hits found AND `--block` was passed
#   2  usage error (missing git, bad project-root, etc.)

set -euo pipefail

# ----------------------------------------------------------------------
# Help
# ----------------------------------------------------------------------

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-knowledge-redaction.sh — Surface consumer-name hits in new
knowledge-file lines.

Usage:
  validate-knowledge-redaction.sh [--block] [<project-root>] [<base-branch>]

Arguments:
  --block       Escalate hits to exit 1 (default: warn only, exit 0).
  project-root  Path to the project root (default: current working dir).
  base-branch   Git ref to diff against (default: main).

Watched files:
  docs/knowledge/shared-observations.md
  docs/operating-principles.md

Built-in denylist (v1 seed):
  Tula, OpenEMR, YouBase, municipal-brain, toast-mcp

Exemptions:
  Add line-regex patterns to `.knowledge-redaction-ignore` in the
  project root. One regex per line; `#` comments allowed.

Default posture is WARN — the validator surfaces hits but does not
fail the PR. Reviewers eyeball the warnings. Use --block once the
corpus of legitimate citations stabilizes (per OPP-0036 v2 path).

Exit codes:
  0  no hits, OR hits surfaced as warnings (default)
  1  hits found AND --block was set
  2  usage error
USAGE
    exit 0
    ;;
esac

# ----------------------------------------------------------------------
# Arg parsing
# ----------------------------------------------------------------------

BLOCK=0
if [[ "${1:-}" == "--block" ]]; then
  BLOCK=1
  shift
fi

PROJECT_ROOT="${1:-$(pwd)}"
BASE_BRANCH="${2:-main}"

if [[ ! -d "$PROJECT_ROOT" ]]; then
  echo "✗ Project root not a directory: $PROJECT_ROOT" >&2
  exit 2
fi

if ! command -v git >/dev/null 2>&1; then
  echo "✗ git not available in PATH (required for diff-based scan)" >&2
  exit 2
fi

cd "$PROJECT_ROOT"

# Reject an over-broad exemption pattern (".", ".*", "^", …) BEFORE any git
# work — a broken off-switch should fail regardless of diff state (the other
# ignore-file validators guard unconditionally too). Uses the same grep -E
# engine the patterns are applied with, against five disjoint canary strings
# (mirrors HarnessRegistry.EXEMPTION_CANARIES): a pattern matching all five is a
# catch-all that would exempt everything. The pattern-level dual of #212's
# file-level off-switch governance.
_exemption_overbroad() {
  local pat="$1" c
  for c in 'z' 'Q' '7' '-' 'the quick brown fox'; do
    printf '%s' "${c}" | grep -qE -- "${pat}" || return 1
  done
  return 0
}
if [[ -f ".knowledge-redaction-ignore" ]]; then
  while IFS= read -r _ig_line || [[ -n "$_ig_line" ]]; do
    [[ -z "$_ig_line" ]] && continue
    [[ "$_ig_line" =~ ^[[:space:]]*# ]] && continue
    if _exemption_overbroad "$_ig_line"; then
      echo "✗ .knowledge-redaction-ignore: over-broad exemption pattern '${_ig_line}' matches every canary string — it would exempt all added lines and defeat the redaction scan. Narrow it to the specific line(s) you mean." >&2
      exit 2
    fi
  done < ".knowledge-redaction-ignore"
fi

# Verify we're in a git repo.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "✗ Not inside a git working tree: $PROJECT_ROOT" >&2
  exit 2
fi

# Verify base ref exists (it might not in a shallow CI checkout).
if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
  # In CI on the base ref itself, there's no diff to scan — exit clean.
  echo "ℹ Base branch $BASE_BRANCH not present locally; skipping diff-based scan."
  exit 0
fi

# ----------------------------------------------------------------------
# Watched files + denylist
# ----------------------------------------------------------------------

WATCHED_FILES=(
  "docs/knowledge/shared-observations.md"
  "docs/operating-principles.md"
)

# Built-in denylist: extended regex (passed to grep -E).
DENYLIST=(
  "Tula"
  "OpenEMR"
  "YouBase"
  "municipal-brain"
  "toast-mcp"
)

# Sensitive-class subset for the BROADENED design-corpus scan (below). These are
# private org / repo / project identifiers that must never appear in the tracked
# tree at all. It deliberately EXCLUDES the public roadmap codenames
# (Tula / OpenEMR / YouBase), which legitimately appear across OPPs / PRDs / the
# roadmap as design context — scanning the design corpus for those would flag
# hundreds of legitimate references. Gitignored names (loaded below) are all
# private and are added to this set too.
SENSITIVE_DENYLIST=(
  "bdits/"          # private org repo-path prefix (e.g. bdits/<repo>)
  "municipal-brain"
  "toast-mcp"
)

# Local gitignored denylist (OPP-0048 mechanism 2): additional consumer/project
# names loaded from `.knowledge-redaction-denylist` if present. This keeps the
# sensitive names OUT of the public tree (the file is gitignored) while still
# giving a local pre-commit safety net. One extended-regex pattern per line;
# blank lines and `#` comments are skipped. CI on a fresh clone will not have the
# file (by design — the names must not be committed); this is a local guard.
LOCAL_DENYLIST_FILE=".knowledge-redaction-denylist"
if [[ -f "$LOCAL_DENYLIST_FILE" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    DENYLIST+=("$line")
    SENSITIVE_DENYLIST+=("$line")
  done < "$LOCAL_DENYLIST_FILE"
fi

# ----------------------------------------------------------------------
# Load exemption patterns from .knowledge-redaction-ignore (if present)
# ----------------------------------------------------------------------

IGNORE_FILE=".knowledge-redaction-ignore"
IGNORE_PATTERNS=()
if [[ -f "$IGNORE_FILE" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip blank lines + comment lines
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    IGNORE_PATTERNS+=("$line")
  done < "$IGNORE_FILE"
fi

# Returns 0 if line matches any exemption pattern; 1 otherwise.
line_exempted() {
  local line="$1"
  local pat
  for pat in "${IGNORE_PATTERNS[@]+"${IGNORE_PATTERNS[@]}"}"; do
    if echo "$line" | grep -qE -- "$pat"; then
      return 0
    fi
  done
  return 1
}

# ----------------------------------------------------------------------
# Scan added lines against a pattern set (WARN; honors line_exempted).
# Appends to the global total_hits. Shared by the strict watched-file scan
# (full denylist, incl. codenames) and the broadened design-corpus scan
# (sensitive-class tokens only).
# ----------------------------------------------------------------------

total_hits=0
total_files_scanned=0

scan_added_lines() {
  local file="$1" label="$2"
  shift 2
  local -a patterns=("$@")
  [[ -f "$file" ]] || return 0

  # Get the unified diff for this file vs base. --unified=0 minimizes
  # context (we only want added lines). git might return non-zero
  # exit when no diff exists or the file is unchanged — that's fine.
  local diff_output current_line hdr_minus diff_line content pattern short
  diff_output="$(git diff --unified=0 "$BASE_BRANCH"...HEAD -- "$file" 2>/dev/null || true)"
  [[ -z "$diff_output" ]] && return 0

  # Track the current new-file line number while walking the diff.
  # Hunk headers look like: @@ -OLD_START,OLD_LEN +NEW_START,NEW_LEN @@
  current_line=0
  hdr_minus=0
  while IFS= read -r diff_line; do
    # File-header pair detection BEFORE the case: a "+++ " line is the new-file header ONLY when it
    # immediately follows the "--- " old-file header. Otherwise a diff line beginning "+++" is an
    # ADDED CONTENT line whose text starts with "++" (the single "+" diff marker + "++…") and MUST be
    # scanned — the previous broad `+++*` glob skipped exactly this, letting a confidential name on a
    # line starting with "++" bypass the denylist.
    if [[ "$diff_line" == "--- "* ]]; then hdr_minus=1; continue; fi
    if [[ "$diff_line" == "+++ "* && "$hdr_minus" -eq 1 ]]; then hdr_minus=0; continue; fi
    hdr_minus=0
    case "$diff_line" in
      @@*)
        # Parse the hunk header to extract the starting new-line number.
        if [[ "$diff_line" =~ \+([0-9]+) ]]; then
          current_line="${BASH_REMATCH[1]}"
        fi
        continue
        ;;
      +*)
        # An added line. Strip the leading `+`.
        content="${diff_line:1}"
        for pattern in "${patterns[@]}"; do
          if echo "$content" | grep -qE -- "$pattern"; then
            if line_exempted "$content"; then
              :   # Exempted.
            else
              short="$(printf '%s' "$content" | cut -c1-120)"
              echo "⚠ $file:$current_line: $label '$pattern' in new line: $short" >&2
              total_hits=$((total_hits + 1))
            fi
            break
          fi
        done
        current_line=$((current_line + 1))
        ;;
      -*)
        # Removed line — doesn't advance new-file line counter.
        continue
        ;;
      *)
        # Context line (only present with --unified > 0; we used --unified=0
        # so this shouldn't happen, but be safe).
        current_line=$((current_line + 1))
        ;;
    esac
  done <<< "$diff_output"
}

# Strict scan: the two knowledge-distillation surfaces against the FULL denylist
# (codenames included — a distilled lesson should never name a consumer even by
# a public codename).
for file in "${WATCHED_FILES[@]}"; do
  [[ -f "$file" ]] || continue
  total_files_scanned=$((total_files_scanned + 1))
  scan_added_lines "$file" "consumer-name" "${DENYLIST[@]}"
done

# Broadened scan (WARN): the design / publication corpus against the
# SENSITIVE-class tokens only. Catches a FUTURE re-introduction of a private
# org / repo / project identifier (`bdits/`-style paths, municipal-brain,
# toast-mcp, gitignored names) into an ADR / OPP / PRD / diagram / roadmap. It
# deliberately does NOT scan for the public roadmap codenames, which
# legitimately appear here. Diff-based, so the existing corpus is never
# re-flagged; WARN, so a hit surfaces for review without failing CI.
BROADENED_FILES=()
while IFS= read -r _bf; do
  [[ -n "$_bf" ]] && BROADENED_FILES+=("$_bf")
done < <(git ls-files 'docs/adr/*.md' 'docs/opportunities/*.md' 'docs/requirements/*.md' \
                      'docs/architecture/diagrams.md' 'docs/roadmap.md' 2>/dev/null)

for file in "${BROADENED_FILES[@]:-}"; do
  [[ -n "$file" ]] || continue
  scan_added_lines "$file" "sensitive-name" "${SENSITIVE_DENYLIST[@]}"
done

# ----------------------------------------------------------------------
# Result
# ----------------------------------------------------------------------

if [[ "$total_hits" -gt 0 ]]; then
  echo "" >&2
  if [[ "$BLOCK" -eq 1 ]]; then
    echo "✗ Knowledge-redaction validation failed: $total_hits redaction hit(s) in new lines (--block enabled)." >&2
    echo "  Either rephrase to anonymize, exempt via .knowledge-redaction-ignore, or remove --block." >&2
    exit 1
  else
    echo "ℹ Knowledge-redaction surfaced $total_hits redaction hit(s) in new lines (WARN posture; not failing CI)." >&2
    echo "  Reviewers should verify each hit is intentional doctrine, not unredacted leakage." >&2
    echo "  Pass --block to escalate to hard fail." >&2
    # WARN posture — exit 0 even with hits.
    exit 0
  fi
fi

if [[ "$total_files_scanned" -eq 0 ]]; then
  echo "✓ Knowledge-redaction validation passed (no watched files present in this project)."
else
  echo "✓ Knowledge-redaction validation passed (no redaction hits in new lines across $total_files_scanned watched file(s) + the broadened design corpus)."
fi
exit 0
