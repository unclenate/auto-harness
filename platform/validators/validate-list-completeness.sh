#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-list-completeness.sh — Assert every governance / catalog entity on
# disk has a corresponding row in its canonical index file.
#
# Why this exists:
#   Hand-maintained lists drift: a new ADR is filed but the docs/README.md ADR
#   table is not updated; a new composition lands but its row in
#   compositions/README.md is forgotten. Each occurrence is the same defect
#   class — "an entity exists on disk but no list-of-entities surface knows
#   about it" — and the audit of 2026-05-27 (refresh #2) recorded the class
#   reproducing within 48 hours of a sibling fix.
#
#   This validator closes that defect class by asserting, for each entity
#   directory, that every member is referenced by the right index surface.
#   When a new ADR is filed without a README row, CI fails immediately with a
#   concrete "missing row for ADR-NNNN" message — turning honor-code list
#   maintenance into code-checked list maintenance.
#
#   Roadmap citation: documentation-audit-2026-05-27/execution-roadmap.md §4
#   ("Wave 1 — The unblock"). Closes refresh-2.md finding M-j and prevents
#   the recurring N1-class drift.
#
# Usage:
#   validate-list-completeness.sh [<project-root>]
#
# Behavior:
#   For each check (see CHECKS below), the validator discovers a set of
#   entities on disk and asserts each entity is referenced in its canonical
#   index file(s). When an index file is absent (e.g., a consumer project has
#   no docs/adr/ tree), the corresponding entity discovery yields zero
#   matches and the check is a no-op — naturally consumer-safe.
#
# Checks:
#   1. ADRs            docs/adr/ADR-NNNN-*.md           → docs/README.md
#                                                        + SUMMARY.md (nav)
#   2. PRDs            docs/requirements/PRD-NNNN-*.md  → docs/README.md
#                                                        + SUMMARY.md (nav)
#   3. OPPs            docs/opportunities/OPP-NNNN-*.md → docs/README.md
#                                                        + docs/opportunities/candidates.md
#                                                        + SUMMARY.md (nav)
#   4. Compositions    platform/compositions/*.yaml     → platform/compositions/README.md
#                                                        + README.md (root)
#   5. Template dirs   platform/templates/<subdir>/     → platform/templates/README.md
#   6. Profile modules platform/profiles/**/module.yaml → SUMMARY.md
#   7. Agent modules   platform/agents/*/module.yaml    → SUMMARY.md
#
# ADR/PRD/OPP → SUMMARY.md nav is anchored on the record's link-target PATH
# (docs/<dir>/<filename>), NOT the bare record id: SUMMARY module descriptions
# cite records in prose (e.g. "(PRD-0014)"), so a bare-id grep would match a
# prose mention and pass with the nav row deleted. The relative path appears
# only in the nav row's link target — one occurrence per record. Per OPP-0055.
#
# Exit codes:
#   0  every discovered entity is referenced in its canonical index file(s)
#   1  one or more entities are unreferenced (drift detected)
#   2  usage error (bad project-root, etc.)

set -euo pipefail

# ----------------------------------------------------------------------
# Help
# ----------------------------------------------------------------------

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-list-completeness.sh — Assert every catalog entity has its index row.

Usage:
  validate-list-completeness.sh [<project-root>]

Arguments:
  project-root  Path to scan (optional; default: current working directory).
                Must be the auto-harness repo or a checkout with the same
                docs/ + platform/ + SUMMARY.md layout. When run against a
                consumer project that omits a given entity directory (e.g.,
                no docs/adr/), the corresponding check is a no-op.

Behavior:
  For each of seven checks (ADRs, PRDs, OPPs, compositions, template
  subdirectories, profile modules, agent modules), discovers the on-disk entity set and
  asserts each entity is referenced in its canonical index file(s).

  Index file definitions:
    ADRs   → docs/README.md + SUMMARY.md (nav)
    PRDs   → docs/README.md + SUMMARY.md (nav)
    OPPs   → docs/README.md + docs/opportunities/candidates.md + SUMMARY.md (nav)
    Compositions → platform/compositions/README.md + README.md
    Templates    → platform/templates/README.md
    Profile modules → SUMMARY.md
    Agent modules   → SUMMARY.md

  The ADR/PRD/OPP → SUMMARY.md nav assertion is anchored on the record's
  link-target path (docs/<dir>/<filename>), which appears only in the nav
  row — never on the bare record id, which SUMMARY descriptions also cite in
  prose (a bare-id grep would pass with the nav row deleted). Per OPP-0055.

Exit codes:
  0  every entity has its canonical index row
  1  one or more entities are unreferenced (drift)
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
# Assert helper
# ----------------------------------------------------------------------

violations=0
checks_run=0

# assert_contains FILE TOKEN HUMAN_ID LABEL
#   Greps FILE for the fixed-string TOKEN. On miss, increments `violations`
#   and prints a structured stderr line. When FILE itself does not exist,
#   prints a single index-missing error per call site.
assert_contains() {
  local file="$1" token="$2" human_id="$3" label="$4"
  if [[ ! -f "$file" ]]; then
    echo "✗ $label: index file missing: $file" >&2
    violations=$((violations + 1))
    return
  fi
  if ! grep -qF -- "$token" "$file"; then
    echo "✗ $file: missing $label row for $human_id" >&2
    violations=$((violations + 1))
  fi
}

# ----------------------------------------------------------------------
# Check 1 — ADRs → docs/README.md
# ----------------------------------------------------------------------

if [[ -d docs/adr ]]; then
  for adr in docs/adr/ADR-*.md; do
    [[ -e "$adr" ]] || continue
    base="$(basename "$adr" .md)"
    # Token: "ADR-NNNN" prefix (first 8 chars of the basename). Robust because
    # the README table either links to the file (link target contains the
    # token) or names the ADR by number — either form satisfies.
    id="${base:0:8}"
    checks_run=$((checks_run + 1))
    assert_contains "docs/README.md" "$id" "$id" "ADR"
    # SUMMARY nav row — anchored on the link-target path (unique to the nav row).
    checks_run=$((checks_run + 1))
    assert_contains "SUMMARY.md" "$adr" "$id" "ADR nav"
  done
fi

# ----------------------------------------------------------------------
# Check 2 — PRDs → docs/README.md
# ----------------------------------------------------------------------

if [[ -d docs/requirements ]]; then
  for prd in docs/requirements/PRD-*.md; do
    [[ -e "$prd" ]] || continue
    base="$(basename "$prd" .md)"
    id="${base:0:8}"
    checks_run=$((checks_run + 1))
    assert_contains "docs/README.md" "$id" "$id" "PRD"
    # SUMMARY nav row — anchored on the link-target path (unique to the nav row).
    checks_run=$((checks_run + 1))
    assert_contains "SUMMARY.md" "$prd" "$id" "PRD nav"
  done
fi

# ----------------------------------------------------------------------
# Check 3 — OPPs → docs/README.md + docs/opportunities/candidates.md
# ----------------------------------------------------------------------

if [[ -d docs/opportunities ]]; then
  for opp in docs/opportunities/OPP-*.md; do
    [[ -e "$opp" ]] || continue
    base="$(basename "$opp" .md)"
    id="${base:0:8}"
    checks_run=$((checks_run + 1))
    assert_contains "docs/README.md" "$id" "$id" "OPP table"
    # candidates.md may reference the OPP in a cluster row OR a "retired"
    # footnote — either form contains the OPP-NNNN token, so a fixed-string
    # grep satisfies both shapes.
    checks_run=$((checks_run + 1))
    assert_contains "docs/opportunities/candidates.md" "$id" "$id" "OPP candidates"
    # SUMMARY nav row — anchored on the link-target path (unique to the nav row).
    checks_run=$((checks_run + 1))
    assert_contains "SUMMARY.md" "$opp" "$id" "OPP nav"
  done
fi

# ----------------------------------------------------------------------
# Check 4 — Compositions → compositions/README.md + root README.md
# ----------------------------------------------------------------------

if [[ -d platform/compositions ]]; then
  for comp in platform/compositions/*.yaml; do
    [[ -e "$comp" ]] || continue
    name="$(basename "$comp")"
    checks_run=$((checks_run + 1))
    assert_contains "platform/compositions/README.md" "$name" "$name" "composition (compositions/README)"
    checks_run=$((checks_run + 1))
    assert_contains "README.md" "$name" "$name" "composition (root README)"
  done
fi

# ----------------------------------------------------------------------
# Check 5 — Template subdirectories → platform/templates/README.md
# ----------------------------------------------------------------------

if [[ -d platform/templates ]]; then
  for sub in platform/templates/*/; do
    [[ -d "$sub" ]] || continue
    # Token: "templates/<subdir>/" — matches the path form used in the
    # directory-map tables (e.g., `templates/discovery/intake-questionnaire.md`).
    name="$(basename "$sub")"
    token="templates/$name/"
    checks_run=$((checks_run + 1))
    assert_contains "platform/templates/README.md" "$token" "$name/" "template subdirectory"
  done
fi

# ----------------------------------------------------------------------
# Check 6 — Profile modules → SUMMARY.md
# ----------------------------------------------------------------------

if [[ -d platform/profiles ]]; then
  while IFS= read -r mod; do
    # Strip leading "platform/" + trailing "/module.yaml" to get
    # "profiles/<family>/<slug>/" — the fragment that appears in
    # SUMMARY.md's module-library link targets.
    rel="${mod#platform/}"
    dir="${rel%/module.yaml}/"
    family_slug="$dir"
    checks_run=$((checks_run + 1))
    assert_contains "SUMMARY.md" "$family_slug" "$family_slug" "profile module"
  done < <(find platform/profiles -name module.yaml | sort)
fi

# ----------------------------------------------------------------------
# Check 7 — Agent modules → SUMMARY.md
# ----------------------------------------------------------------------

if [[ -d platform/agents ]]; then
  while IFS= read -r mod; do
    rel="${mod#platform/}"
    dir="${rel%/module.yaml}/"
    checks_run=$((checks_run + 1))
    assert_contains "SUMMARY.md" "$dir" "$dir" "agent module"
  done < <(find platform/agents -mindepth 2 -maxdepth 2 -name module.yaml | sort)
fi

# ----------------------------------------------------------------------
# Result
# ----------------------------------------------------------------------

if [[ "$violations" -gt 0 ]]; then
  echo "" >&2
  echo "✗ List-completeness drift detected: $violations of $checks_run assertions failed." >&2
  echo "  Add the missing index row(s) — see the failed assertions above." >&2
  exit 1
fi

echo "✓ All $checks_run list-completeness assertions match canonical entities."
exit 0
