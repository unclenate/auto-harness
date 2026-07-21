#!/usr/bin/env bash
# shellcheck disable=SC2034
# (COUNT_* vars below are read via indirect expansion `${!varname}` in
# canonical_count(); the static analyzer cannot trace that pattern.)
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-catalog-counts.sh — Assert documented catalog counts match
# repository reality.
#
# Why this exists:
#   Documentation that asserts "N modules / N validators / N templates /
#   etc." accumulates more call sites as the project grows (entry-point
#   prose, ASCII-art diagrams, Mermaid diagrams, back cover SVG, etc.).
#   Each call site is a drift opportunity. This validator computes the
#   canonical counts via inline recipes and compares them to every
#   documented assertion site in the assertion table below.
#
#   Captured in `docs/knowledge/shared-observations.md` (2026-05-22):
#   "Each new artifact asserting a catalog count is a new place that
#   fact can drift." This validator closes that drift class
#   structurally.
#
# Usage:
#   validate-catalog-counts.sh [<project-root>]
#
# Behavior:
#   Runs recipes in <project-root> to compute canonical counts. Iterates
#   the ASSERTIONS table below and checks each documented claim against
#   the corresponding canonical count. Reports drift with file/line/
#   expected/actual and exits 1.
#
#   To add a new assertion site: append a row to ASSERTIONS.
#   To add a new count: add a recipe to compute_counts() and a new
#   count-key the assertions can reference.
#
# Exit codes:
#   0  all documented claims match canonical counts
#   1  one or more documented claims drift from canonical
#   2  usage error (missing dependency, bad project-root, etc.)

set -euo pipefail

# ----------------------------------------------------------------------
# Help
# ----------------------------------------------------------------------

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-catalog-counts.sh — Assert documented catalog counts match reality.

Usage:
  validate-catalog-counts.sh [<project-root>]

Arguments:
  project-root  Path to scan (optional; default: current working directory).
                Must be the auto-harness repo or a checkout with the same
                platform/, docs/, and SUMMARY.md structure.

Behavior:
  Computes canonical counts via inline recipes (e.g., `find platform/profiles
  -name module.yaml | wc -l`) and checks every documented assertion site
  (entry-point prose, diagrams.md, cover SVGs, etc.) against the canonical
  values. Each row in the internal ASSERTIONS table is one (file, regex,
  count-key) triple.

  When a count or a new assertion site is added, edit this file directly.

Exit codes:
  0  all documented claims match canonical counts
  1  one or more documented claims drift from canonical
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
# Canonical recipes
# ----------------------------------------------------------------------

# Compute each canonical count by running the documented recipe. Keep
# these in sync with the recipe comment at the top of
# platform/reference/how-to-read.md (the comment is the
# human-readable expression of the same logic).
#
# Stored as separate variables (`COUNT_<key>`) rather than an
# associative array so this script remains compatible with Bash 3.2
# (the version macOS ships by default; the validators CI job uses the
# system bash, not the Homebrew bash 4+ that bootstrap tests install).
COUNT_modules_profiles=$(find platform/profiles -name module.yaml 2>/dev/null | wc -l | tr -d ' ')
COUNT_modules_all=$(find platform -name module.yaml 2>/dev/null | wc -l | tr -d ' ')
COUNT_validators=$(find platform/validators -maxdepth 1 -name 'validate-*.sh' 2>/dev/null | wc -l | tr -d ' ')
COUNT_skills=$(find platform/skills -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
COUNT_templates=$(find platform/templates -type f -name '*.md' ! -name 'README.md' 2>/dev/null | wc -l | tr -d ' ')
COUNT_workflows=$(find platform/workflow -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
COUNT_diagrams=$(grep -cE '^## [0-9]+\.' docs/architecture/diagrams.md 2>/dev/null || echo 0)
# Derived: the validator test suite generates 3 --help/-h contract tests per
# validator script (see TestValidatorHelpFlag). Gating this keeps the prose
# "N dynamically generated" count honest as the validator set grows.
COUNT_help_tests=$((3 * COUNT_validators))

# Lookup a canonical count by key, using indirect variable expansion.
# Returns the empty string for unknown keys (caller treats as
# internal-error).
canonical_count() {
  local varname="COUNT_$1"
  printf '%s' "${!varname-}"
}

# ----------------------------------------------------------------------
# Assertion table
# ----------------------------------------------------------------------

# Format: "file|regex-with-one-capture-group|count-key"
#
# - file: path relative to PROJECT_ROOT
# - regex: extended regex with ONE capture group matching the asserted
#   number. First match in the file wins.
# - count-key: which COUNT[] entry the captured number must equal
#
# To add a new assertion site, append a row here. To add a new count
# entirely, add it to the recipes block above first.
ASSERTIONS=(
  # platform/reference/how-to-read.md — prose line
  "platform/reference/how-to-read.md|harness documentation is large — ([0-9]+) modules|modules_profiles"
  "platform/reference/how-to-read.md|, ([0-9]+) templates,|templates"
  "platform/reference/how-to-read.md|, ([0-9]+) validators,|validators"
  "platform/reference/how-to-read.md|, ([0-9]+) skills,|skills"
  "platform/reference/how-to-read.md|, ([0-9]+) workflows|workflows"

  # platform/reference/how-to-read.md — authority-stack ASCII art
  "platform/reference/how-to-read.md|\(([0-9]+) modules\)|modules_profiles"
  "platform/reference/how-to-read.md|\(([0-9]+) scripts\)|validators"
  "platform/reference/how-to-read.md|\(([0-9]+) files\)|templates"
  "platform/reference/how-to-read.md|\(([0-9]+) guides\)|workflows"

  # docs/architecture/diagrams.md — diagram 1 (component composition) labels
  "docs/architecture/diagrams.md|\(([0-9]+) total in-tree\)|modules_all"
  "docs/architecture/diagrams.md|>([0-9]+) scripts|validators"
  "docs/architecture/diagrams.md|>([0-9]+) scaffolding files|templates"
  "docs/architecture/diagrams.md|>([0-9]+) guides:|workflows"

  # docs/architecture/diagrams.md — onboarding-flow Mermaid node label. The
  # count lives inside a Mermaid node string, a blind spot that drifted twice
  # (doc-watch 2026-07-13 → 2026-07-19, unnoticed to off-by-2); gating it here.
  "docs/architecture/diagrams.md|\(([0-9]+) validators\)|validators"

  # platform/validators/README.md — test-suite prose (help-test count is
  # 3 × validators; the per-validator basis is the validator count). Both are
  # count mirrors the run-order propagation missed on the 25→26 bump.
  "platform/validators/README.md|hard-coded tests \+ ([0-9]+) dynamically|help_tests"
  "platform/validators/README.md|per validator × ([0-9]+) validators|validators"

  # docs/_assets/cover-back.svg — back cover catalog list
  "docs/_assets/cover-back.svg|>([0-9]+) modules<|modules_all"
  "docs/_assets/cover-back.svg|>([0-9]+) validators<|validators"
  "docs/_assets/cover-back.svg|>([0-9]+) skills<|skills"
  "docs/_assets/cover-back.svg|>([0-9]+) templates<|templates"
  "docs/_assets/cover-back.svg|>([0-9]+) workflows<|workflows"
  "docs/_assets/cover-back.svg|>([0-9]+) diagrams<|diagrams"

  # README.md — prose count claims (word-form caught via normalize_count)
  "README.md|Validator chain\*\* — ([a-z-]+) shell scripts|validators"
  "README.md|^([A-Z][a-z-]+) validators, each targeting|validators"
  "README.md|The harness provides ([a-z]+) skills|skills"
  "README.md|architecture diagrams \(([a-z]+) in total|diagrams"

  # HARNESS.md — diagram count prose (recurring drift site; word-form)
  "HARNESS.md|— ([a-z]+) Mermaid diagrams|diagrams"
  # README.md — mermaid Enforcement (CI) box (numeric form)
  "README.md|Validators</b><br/>([0-9]+) scripts|validators"

  # platform/workflow/skills-and-agents.md — skills count
  "platform/workflow/skills-and-agents.md|The harness provides ([a-z]+) skills|skills"
)

# ----------------------------------------------------------------------
# Assertion check
# ----------------------------------------------------------------------

# extract_first_capture FILE REGEX
#   Reads FILE line-by-line; returns the first capture group of the
#   first matching line. Empty string if no match.
extract_first_capture() {
  local file="$1" regex="$2"
  if [[ ! -f "$file" ]]; then
    return
  fi
  while IFS= read -r line; do
    if [[ "$line" =~ $regex ]]; then
      printf '%s' "${BASH_REMATCH[1]}"
      return
    fi
  done < "$file"
}

# normalize_count VALUE
#   Convert a small English number word (one, two, …, twenty) to its
#   numeric form. Pass-through for already-numeric input. Returns the
#   value unchanged if it doesn't match a known word — the caller's
#   compare step will then surface the mismatch.
normalize_count() {
  case "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" in
    one) echo 1 ;;
    two) echo 2 ;;
    three) echo 3 ;;
    four) echo 4 ;;
    five) echo 5 ;;
    six) echo 6 ;;
    seven) echo 7 ;;
    eight) echo 8 ;;
    nine) echo 9 ;;
    ten) echo 10 ;;
    eleven) echo 11 ;;
    twelve) echo 12 ;;
    thirteen) echo 13 ;;
    fourteen) echo 14 ;;
    fifteen) echo 15 ;;
    sixteen) echo 16 ;;
    seventeen) echo 17 ;;
    eighteen) echo 18 ;;
    nineteen) echo 19 ;;
    twenty) echo 20 ;;
    twenty-one) echo 21 ;;
    twenty-two) echo 22 ;;
    twenty-three) echo 23 ;;
    twenty-four) echo 24 ;;
    twenty-five) echo 25 ;;
    twenty-six) echo 26 ;;
    twenty-seven) echo 27 ;;
    twenty-eight) echo 28 ;;
    twenty-nine) echo 29 ;;
    thirty) echo 30 ;;
    *) echo "$1" ;;
  esac
}

violations=0
total=${#ASSERTIONS[@]}

for entry in "${ASSERTIONS[@]}"; do
  IFS='|' read -r file regex key <<< "$entry"

  expected="$(canonical_count "$key")"
  if [[ -z "$expected" ]]; then
    echo "✗ Internal error: assertion references unknown count-key '$key' for $file" >&2
    violations=$((violations + 1))
    continue
  fi

  actual_raw="$(extract_first_capture "$file" "$regex" || true)"

  if [[ -z "$actual_raw" ]]; then
    echo "✗ $file: regex '$regex' did not match (count-key: $key, canonical: $expected)" >&2
    violations=$((violations + 1))
    continue
  fi

  actual="$(normalize_count "$actual_raw")"

  if [[ "$actual" != "$expected" ]]; then
    if [[ "$actual_raw" != "$actual" ]]; then
      echo "✗ $file: claims '$actual_raw' ($actual) but canonical $key is $expected (regex: $regex)" >&2
    else
      echo "✗ $file: claims $actual but canonical $key is $expected (regex: $regex)" >&2
    fi
    violations=$((violations + 1))
  fi
done

# ----------------------------------------------------------------------
# Result
# ----------------------------------------------------------------------

if [[ "$violations" -gt 0 ]]; then
  echo "" >&2
  echo "✗ Catalog count drift detected: $violations of $total assertions failed." >&2
  echo "  Update the documented claim(s) above OR explain why canonical is wrong." >&2
  exit 1
fi

echo "✓ All $total catalog-count assertions match canonical recipes."
exit 0
