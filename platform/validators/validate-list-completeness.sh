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
#   8. Module catalog  platform/profiles/**/module.yaml → platform/skills/harness-onboarding/SKILL.md
#   9. Discovery matrix platform/profiles/**/module.yaml → platform/workflow/discovery-to-composition.md
#  10. README table    platform/profiles/**/module.yaml → README.md Module System table (leaf)
#  11. Active modules   harness.manifest.yaml modules:   → HARNESS.md Active Modules (active⇒listed)
#  12. Active modules   HARNESS.md Active Modules table  → harness.manifest.yaml (listed⇒active)
#
# ADR/PRD/OPP → SUMMARY.md nav is anchored on the record's link-target PATH
# (docs/<dir>/<filename>), NOT the bare record id: SUMMARY module descriptions
# cite records in prose (e.g. "(PRD-0014)"), so a bare-id grep would match a
# prose mention and pass with the nav row deleted. The relative path appears
# only in the nav row's link target — one occurrence per record. Per OPP-0055.
#
# Checks 8–12 (OPP-0067 / 0068 / 0069) reconcile the module-catalog mirror the
# CLAUDE.md propagation reflex names across five surfaces. Each anchors on the
# token UNIQUE TO THE ENUMERATION (never a whole-file substring — OPP-0055 /
# OPP-0071): a prose sentence or an in-row cross-reference ("composes with
# `slug`") must not stand in for the capability-bearing catalog row.
#   8–9 (OPP-0067, hardened by OPP-0071): the "<category>/<name>" slug must
#   appear as the first backtick-bounded token of a table CELL — preceded by a
#   cell boundary `|` or a `+` multi-module separator — in the onboarding
#   catalog (which forbids selecting an unlisted module) and the
#   discovery→composition matrix (the two surfaces PR #232 hand-fixed an
#   8-module lag in). Cell-anchored, not row-leading, because the discovery
#   rubric lists modules in the answer column (sometimes `+`-joined).
#   10 (OPP-0068): the README Module System table lists modules by LEAF name in
#   category rows — backtick-bounded leaf anchor, leaves disk-verified unique,
#   scoped to the family-row block, skipped if that block is absent.
#   11–12 (OPP-0068 / 0069, hardened by OPP-0071): HARNESS.md Active Modules is
#   manifest-RELATIVE (a subset), reconciled as a BIDIRECTIONAL set-equality
#   over ONE extracted set — the module-column cells of the Active Modules
#   table (field 3 under -F'|', backtick-filtered). Check 11 asserts every
#   manifest-active module is a table cell (active⇒listed) by EXACT value
#   match — so `base` no longer masks via `kernel/base` or a path mention;
#   check 12 asserts every table cell is manifest-active (listed⇒active,
#   catching a stale row for a deactivated module). If no module-column cell
#   parses (a differently-shaped consumer HARNESS.md), 11–12 skip rather than
#   false-fail. Checks 8–10 are platform-only (consumer no-op); checks 11–12
#   run for consumers too (they have a manifest + a HARNESS.md).
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
  For each of twelve checks (ADRs, PRDs, OPPs, compositions, template
  subdirectories, profile modules, agent modules, module catalog, discovery
  matrix, README table, and HARNESS.md active-module parity in both
  directions), discovers the entity set and asserts each entity is referenced
  in its canonical index file(s).

  Index file definitions:
    ADRs   → docs/README.md + SUMMARY.md (nav)
    PRDs   → docs/README.md + SUMMARY.md (nav)
    OPPs   → docs/README.md + docs/opportunities/candidates.md + SUMMARY.md (nav)
    Compositions → platform/compositions/README.md + README.md
    Templates    → platform/templates/README.md
    Profile modules → SUMMARY.md
    Agent modules   → SUMMARY.md
    Module catalog  → platform/skills/harness-onboarding/SKILL.md (slug)
    Discovery matrix → platform/workflow/discovery-to-composition.md (slug)
    README table    → README.md Module System table (leaf, table-scoped)
    Active modules  → HARNESS.md ⇄ manifest (bidirectional set-equality)

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
bt='`'   # a literal backtick, for grep -E patterns (avoids backtick-in-"" command substitution)

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

# assert_cell_listed FILE SLUG LABEL
#   Passes when SLUG appears as the first backtick-bounded token of a table
#   cell — preceded by a cell boundary `|` or a `+` multi-module separator,
#   then optional whitespace, then `` `SLUG` ``. This anchors on the
#   ENUMERATION (a structured table listing), never a prose sentence or an
#   in-cell cross-reference ("composes with `SLUG`"), closing the
#   OPP-0055 / OPP-0071 prose-masking false-negative that an unanchored
#   whole-file grep (assert_contains) allows: the capability-bearing catalog
#   row must be present, not merely the slug somewhere in the file. SLUG is a
#   `<category>/<name>` path (only `[a-z0-9-/]`, no regex metacharacters), so
#   it is injected into the ERE pattern verbatim. Used by checks 8 and 9.
assert_cell_listed() {
  local file="$1" slug="$2" label="$3"
  if [[ ! -f "$file" ]]; then
    echo "✗ $label: index file missing: $file" >&2
    violations=$((violations + 1))
    return
  fi
  if ! grep -qE "(\||\+)[[:space:]]*${bt}${slug}${bt}" "$file"; then
    echo "✗ $file: missing $label row for $slug (slug must be a table-cell listing, not a prose mention)" >&2
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
# Check 8 — Profile modules → harness-onboarding catalog (OPP-0067)
# ----------------------------------------------------------------------
# The onboarding skill's module catalog forbids an onboarding agent from
# selecting a module not listed in it, so a missing row makes a shipped
# module unselectable (capability-suppressing, not cosmetic). Anchor on the
# "<category>/<name>" slug as the first backtick-bounded cell of a catalog
# table ROW (every module is listed as a row-leading cell), not a whole-file
# substring — so a prose mention or an in-row cross-reference
# ("composes with `slug`") can't mask a deleted catalog row (OPP-0071).
# Platform-only file → guarded on existence (consumer no-op).
onboarding_catalog="platform/skills/harness-onboarding/SKILL.md"
if [[ -d platform/profiles && -f "$onboarding_catalog" ]]; then
  while IFS= read -r mod; do
    rel="${mod#platform/}"            # profiles/<category>/<name>/module.yaml
    slug="${rel#profiles/}"           # <category>/<name>/module.yaml
    slug="${slug%/module.yaml}"       # <category>/<name>
    checks_run=$((checks_run + 1))
    assert_cell_listed "$onboarding_catalog" "$slug" "module catalog"
  done < <(find platform/profiles -name module.yaml | sort)
fi

# ----------------------------------------------------------------------
# Check 9 — Profile modules → discovery→composition matrix (OPP-0067)
# ----------------------------------------------------------------------
# Same cell-listing anchor as check 8: the discovery rubric lists each module
# as a backtick-bounded token in the "pick this" answer column (first in the
# cell, or after a `+` multi-module separator). Anchoring on the cell boundary
# rejects an in-cell cross-reference ("(composes with `slug`)") that an
# unanchored grep would accept (OPP-0071).
discovery_matrix="platform/workflow/discovery-to-composition.md"
if [[ -d platform/profiles && -f "$discovery_matrix" ]]; then
  while IFS= read -r mod; do
    rel="${mod#platform/}"
    slug="${rel#profiles/}"
    slug="${slug%/module.yaml}"
    checks_run=$((checks_run + 1))
    assert_cell_listed "$discovery_matrix" "$slug" "discovery matrix"
  done < <(find platform/profiles -name module.yaml | sort)
fi

# ----------------------------------------------------------------------
# Check 10 — Profile modules → README Module System table (OPP-0068)
# ----------------------------------------------------------------------
# The README table lists modules by LEAF name inside category-grouped rows
# (`| **Family** | purpose | `leaf`, `leaf`, ... |`). Anchor on the
# backtick-bounded leaf (leaf names are unique across the 54 profile modules,
# and the backticks prevent substring/prose false-matches). The search is
# scoped to the family-row block, not the whole README; if that block is
# absent (a copy-mode consumer whose README has a different shape), the check
# degrades to a skip rather than false-failing every module — consistent with
# the "absent index → no-op" contract.
if [[ -d platform/profiles && -f README.md ]]; then
  module_table_block="$(grep -E '^\| \*\*(Core|Stacks|Architectures|Data|Delivery|Management|Domains|Agents)\*\*' README.md || true)"
  if [[ -n "$module_table_block" ]]; then
    while IFS= read -r mod; do
      rel="${mod#platform/}"
      slug="${rel#profiles/}"; slug="${slug%/module.yaml}"   # <category>/<name>
      leaf="${slug##*/}"
      checks_run=$((checks_run + 1))
      if ! grep -qF -- "\`$leaf\`" <<<"$module_table_block"; then
        echo "✗ README.md: missing Module System table entry for $slug (leaf \`$leaf\`)" >&2
        violations=$((violations + 1))
      fi
    done < <(find platform/profiles -name module.yaml | sort)
  fi
fi

# ----------------------------------------------------------------------
# Check 11 — Manifest-active modules → HARNESS.md Active Modules (OPP-0068)
# ----------------------------------------------------------------------
# Manifest-relative parity (the inverse of checks 8-10): every module declared
# active in harness.manifest.yaml's `modules:` block must be reflected in
# HARNESS.md's active-module source-of-truth doc. Unlike the platform-only
# catalog checks, this runs for consumers too (they have a manifest + a
# HARNESS.md). Dependency-free manifest extraction (the `modules:` block is a
# flat `family: [- name]` structure). Guarded on the `## Active Modules`
# section being present (skip if absent → consumer-safe).
manifest_file="harness.manifest.yaml"
if [[ -f "$manifest_file" && -f HARNESS.md ]] && grep -qE '^#+[[:space:]]+Active Modules' HARNESS.md; then
  # Active set, extracted once from the flat `modules:` block.
  manifest_active="$(awk '
      /^modules:/            { inblk=1; next }
      inblk && /^[A-Za-z]/   { inblk=0 }
      inblk && /^[[:space:]]*-[[:space:]]/ {
          sub(/^[[:space:]]*-[[:space:]]*/, "");
          sub(/[[:space:]]*#.*$/, "");
          sub(/[[:space:]]+$/, "");
          print
      }
    ' "$manifest_file" | sort -u)"

  # Modules LISTED in the HARNESS.md Active Modules table — extracted ONCE from
  # the module COLUMN (field 3 under `-F'|'`, since the leading pipe makes
  # field 1 empty), filtered to rows whose module column contains a backtick,
  # which skips the header and separator rows and ignores the purpose column's
  # incidental backticks (e.g. `docs/knowledge/`). The section runs from the
  # `Active Modules` heading to the next heading or horizontal rule. Shared by
  # checks 11 and 12 so the pair is a set-equality over ONE extracted set.
  harness_listed="$(awk '
      /^#+[[:space:]]+Active Modules/                       { inblk=1; next }
      inblk && (/^#+[[:space:]]/ || /^---[[:space:]]*$/)    { inblk=0 }
      inblk && /^\|/                                        { print }
    ' HARNESS.md | awk -F'|' '$3 ~ /`/ { col=$3; gsub(/[` ]/, "", col); print col }' | sort -u)"

  # Consumer-safety / shape-robustness: if the Active Modules section exists but
  # no module-column cell was extracted (a consumer whose HARNESS.md uses a
  # different table shape), degrade to a skip rather than false-failing every
  # active module — consistent with check 10's absent-block skip. The harness's
  # own HARNESS.md parses, so its CI runs both directions live.
  if [[ -n "$harness_listed" ]]; then
    # Check 11 (forward, active ⇒ listed): every manifest-active module is a row
    # in the HARNESS.md table — EXACT whole-value match against the extracted
    # module column, never a substring of the whole doc. This closes the
    # OPP-0071 mask where `base` matched inside `kernel/base` or a
    # `platform/core/kernel/base/` path mention (unanchored assert_contains).
    while IFS= read -r active_mod; do
      [[ -n "$active_mod" ]] || continue
      checks_run=$((checks_run + 1))
      if ! grep -qxF -- "$active_mod" <<<"$harness_listed"; then
        echo "✗ HARNESS.md: active module \`$active_mod\` (in $manifest_file) is not listed in the Active Modules table (active ⇒ listed)" >&2
        violations=$((violations + 1))
      fi
    done <<<"$manifest_active"

    # Check 12 (reverse, listed ⇒ active, OPP-0069): every module LISTED in the
    # HARNESS.md Active Modules table must be active in the manifest — the other
    # half of the set-equality, so a module deactivated in the manifest but left
    # in the doc can't silently overstate active governance.
    while IFS= read -r listed_mod; do
      [[ -n "$listed_mod" ]] || continue
      checks_run=$((checks_run + 1))
      if ! grep -qxF -- "$listed_mod" <<<"$manifest_active"; then
        echo "✗ HARNESS.md: Active Modules lists \`$listed_mod\` but it is not active in $manifest_file (stale row / listed ⇒ active)" >&2
        violations=$((violations + 1))
      fi
    done <<<"$harness_listed"
  fi
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
