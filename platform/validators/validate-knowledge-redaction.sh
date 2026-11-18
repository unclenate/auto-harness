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
#   Cloud-identifier class (2026-11, OPP-0048 lineage). The name denylist
#   above guards a corpus of KNOWN names. Evidence harvested from a live
#   cloud account leaks through a different channel: an account id or an
#   ARN carries the customer's identity and resource names without ever
#   naming the consumer. OPP-0072's account test is the forcing case —
#   its observations are written into OPP / PRD records, and the record
#   itself notes that a denied call's error text carried a queue name.
#   A name denylist cannot cover this: there is no name to list in
#   advance. So this class is PATTERN-based, not corpus-based, and it is
#   the asymmetric one — a consumer codename has legitimate uses in
#   doctrine (hence WARN), while a real account id or customer ARN has
#   none (hence BLOCK). Documentation placeholders are allow-listed by
#   value so example policies and AWS-owned ARNs still write freely.
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
#      consumer-name patterns AND the cloud-identifier pattern class.
#      Lines matching any pattern in `.knowledge-redaction-ignore`
#      (project-root-scoped) are exempt.
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
#   Cloud-identifier patterns (always BLOCK; no --block needed):
#     - a bare 12-digit run (AWS account id), not part of a longer
#       digit run
#     - an ARN in any AWS partition (`arn:aws…:`)
#   Scanned on the two watched files AND the broadened design corpus
#   (ADR / OPP / PRD / diagrams / roadmap), because harvested cloud
#   evidence lands in opportunity and requirement records.
#
#   Allow-listed as documentation placeholders (never a hit):
#     - AWS's documented example account ids (123456789012, the
#       repeated-quad family, all-zeros)
#     - an AWS-owned ARN account field (`arn:aws:iam::aws:policy/…`)
#     - a template token in the matched text (`<…>`, `${…}`, `[[…]]`,
#       `PLACEHOLDER`, `ACCOUNT_ID`, `AWS::AccountId`, `example`)
#
#   `.knowledge-redaction-ignore` format: one regex per line; lines
#   starting with `#` are comments. A new line matching any ignore
#   pattern is exempted from scanning — this is the escape hatch for a
#   cloud-identifier hit a human has judged safe.
#
# Exit codes:
#   0  no hits, OR only name-class hits surfaced as warnings (default
#      WARN posture)
#   1  any cloud-identifier hit, OR name-class hits AND `--block`
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

Cloud-identifier patterns (always BLOCK, with or without --block):
  12-digit AWS account ids, and ARNs in any AWS partition. Scanned on
  the watched files AND the design corpus (ADR / OPP / PRD / diagrams /
  roadmap). AWS's example account ids, AWS-owned policy ARNs, and
  template tokens (<…>, ${…}, [[…]], PLACEHOLDER, ACCOUNT_ID,
  AWS::AccountId, example) are allow-listed as documentation.

Exemptions:
  Add line-regex patterns to `.knowledge-redaction-ignore` in the
  project root. One regex per line; `#` comments allowed.

Default posture is WARN for the NAME classes — the validator surfaces
hits but does not fail the PR. Reviewers eyeball the warnings. Use
--block once the corpus of legitimate citations stabilizes (per
OPP-0036 v2 path). The cloud-identifier class is BLOCK unconditionally:
a real account id or customer ARN has no legitimate doctrine use, and
placeholders are allow-listed by value.

Exit codes:
  0  no hits, OR only name-class hits (default WARN)
  1  any cloud-identifier hit, OR name-class hits with --block
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

# Reject an over-broad exemption pattern BEFORE any git work — a broken
# off-switch should fail regardless of diff state (the other ignore-file
# validators guard unconditionally too). Uses the same grep -E engine the
# patterns are applied with, against a corpus of innocuous-content lines
# (mirrors HarnessRegistry.EXEMPTION_CANARIES): a pattern matching ANY of them
# would swallow real content and is too broad to be a safe exemption. Corrected
# model (scanner-hardening, 2026-11): the prior "matches EVERY disjoint
# single-char canary" test waved through char-class blinders ([A-Za-z], \w, a
# bare space) that match all real lines yet fail a digit/punct canary. The
# pattern-level dual of #212's file-level off-switch governance.
_exemption_overbroad() {
  local pat="$1" c
  for c in 'the quarterly review covered three agenda items' \
           'Release 7 shipped on schedule with no blockers' \
           'notes/example-report.txt' \
           'summary: ready = yes'; do
    if printf '%s' "${c}" | grep -qE -- "${pat}"; then
      return 0
    fi
  done
  return 1
}
if [[ -f ".knowledge-redaction-ignore" ]]; then
  while IFS= read -r _ig_line || [[ -n "$_ig_line" ]]; do
    [[ -z "$_ig_line" ]] && continue
    [[ "$_ig_line" =~ ^[[:space:]]*# ]] && continue
    if _exemption_overbroad "$_ig_line"; then
      echo "✗ .knowledge-redaction-ignore: over-broad exemption pattern '${_ig_line}' matches ordinary content — it would exempt real added lines and defeat the redaction scan. Narrow it to the specific line(s) you mean." >&2
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

# ----------------------------------------------------------------------
# Cloud-identifier class (pattern-based, BLOCK posture).
#
# Unlike the two name classes above, this one cannot be a corpus: the
# leak channel is an identifier minted by a cloud provider, so there is
# no name to list in advance. A 12-digit account id or a customer ARN
# identifies the account and names its resources without ever naming the
# consumer, which is exactly the gap the name denylist leaves open for
# evidence harvested from a live account (OPP-0072).
#
# Anchored, not bare: the account-id pattern requires a non-digit (or
# string edge) on both sides, so a 13+-digit run — a millisecond epoch,
# a long numeric id — is NOT a hit. An unanchored `[0-9]{12}` would
# match inside any longer number and make the class unusable (the
# OPP-0071 anchoring lesson, applied at the token level).
# ----------------------------------------------------------------------
CLOUD_ID_PATTERNS=(
  "(^|[^0-9])[0-9]{12}([^0-9]|$)"             # bare AWS account id
  # A WHOLE ARN: partition, service, region, account, resource. The shape
  # is required, not just the recognizable `arn:aws:` prefix, because the
  # prefix alone carries no account id and no resource name — it is
  # structurally incapable of leaking, and it appears in prose that
  # *discusses* ARNs (this file's own doctrine, for one). Demanding the
  # trailing fields keeps the class pointed at identifiers rather than
  # at vocabulary.
  "arn:aws[a-zA-Z0-9-]*:[a-z0-9-]+:[a-z0-9-]*:[a-zA-Z0-9-]*:[^[:space:]]+"
)

# Documented example account ids. AWS's own docs use 123456789012 and the
# repeated-quad family; these are published placeholders, not anyone's
# account, so a design doc may write them freely.
CLOUD_PLACEHOLDER_ACCOUNTS=(
  "123456789012"
  "000000000000"
  "111122223333"
  "222233334444"
  "333344445555"
  "444455556666"
  "555566667777"
  "666677778888"
  "777788889999"
  "888899990000"
  "999900001111"
)

# Template tokens that mark a matched identifier as a form, not a value.
# Deliberately NOT including bare `example`: a real bucket or queue can
# carry that word, so allow-listing it would launder
# `arn:aws:s3:::example-corp-prod-data`. A doc-shaped ARN writes an
# explicit marker instead — `arn:aws:s3:::<bucket-name>`. Fail closed;
# the author reaches for the template form, not the scanner for a
# heuristic (the OPP-0072 lesson that a provider's own "safe" label
# cannot be the admission rule, applied to our own scanner).
CLOUD_PLACEHOLDER_TOKENS=(
  "<"
  ">"
  '${'
  "[["
  "PLACEHOLDER"
  "ACCOUNT_ID"
  "AWS::AccountId"
)

# Returns 0 if the MATCHED TOKEN is a documentation placeholder rather
# than a live identifier; 1 otherwise. Operates on the matched token, not
# the whole line, so one placeholder elsewhere on a line cannot launder a
# real identifier beside it.
_cloud_token_is_placeholder() {
  local token="$1" acct tok
  for acct in "${CLOUD_PLACEHOLDER_ACCOUNTS[@]}"; do
    case "$token" in *"$acct"*) return 0 ;; esac
  done
  for tok in "${CLOUD_PLACEHOLDER_TOKENS[@]}"; do
    case "$token" in *"$tok"*) return 0 ;; esac
  done
  # An AWS-owned ARN account field: arn:aws:iam::aws:policy/ReadOnlyAccess.
  # AWS-managed policies are public identifiers, not customer data.
  case "$token" in *":aws:policy/"*|*"::aws:"*) return 0 ;; esac
  return 1
}

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
cloud_hits=0
total_files_scanned=0

scan_added_lines() {
  local file="$1" label="$2"
  shift 2
  local -a patterns=("$@")
  [[ -f "$file" ]] || return 0

  # Get the unified diff for this file vs base. --unified=0 minimizes
  # context (we only want added lines). git might return non-zero
  # exit when no diff exists or the file is unchanged — that's fine.
  local diff_output current_line hdr_minus diff_line content pattern short matched _hit_token
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
        if [[ "$label" == "cloud-identifier" ]]; then
          # Per-TOKEN evaluation: extract each match, drop documented
          # placeholders, and count only live-looking identifiers. The
          # name classes stay per-line (below) — a name has no token to
          # normalize, but an identifier does.
          if ! line_exempted "$content"; then
            _hit_token=""
            for pattern in "${patterns[@]}"; do
              while IFS= read -r matched; do
                [[ -z "$matched" ]] && continue
                # Skip placeholders and keep looking — a documented
                # example beside a real identifier must not shield it.
                if _cloud_token_is_placeholder "$matched"; then
                  continue
                fi
                _hit_token="$matched"
                break
              done < <(printf '%s\n' "$content" | grep -oE -- "$pattern" 2>/dev/null || true)
              [[ -n "$_hit_token" ]] && break
            done
            # One hit per line: the account-id pattern also matches inside
            # an ARN, so counting every pattern would double-report a
            # single identifier and make the total meaningless.
            if [[ -n "$_hit_token" ]]; then
              short="$(printf '%s' "$content" | cut -c1-120)"
              echo "✗ $file:$current_line: $label match '$(printf '%s' "$_hit_token" | tr -d '[:space:]')' in new line: $short" >&2
              cloud_hits=$((cloud_hits + 1))
            fi
          fi
          current_line=$((current_line + 1))
          continue
        fi
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
  scan_added_lines "$file" "cloud-identifier" "${CLOUD_ID_PATTERNS[@]}"
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
  # Cloud identifiers are scanned here too — harvested account evidence
  # lands in OPP / PRD records, not only in the knowledge files.
  scan_added_lines "$file" "cloud-identifier" "${CLOUD_ID_PATTERNS[@]}"
done

# ----------------------------------------------------------------------
# Result
# ----------------------------------------------------------------------

# Cloud-identifier hits fail regardless of --block. A consumer codename
# can be legitimate doctrine; a live account id or customer ARN cannot,
# and every documented placeholder form is already allow-listed. The
# escape hatch for a judged-safe hit is .knowledge-redaction-ignore.
if [[ "$cloud_hits" -gt 0 ]]; then
  echo "" >&2
  echo "✗ Knowledge-redaction validation failed: $cloud_hits cloud-identifier hit(s) in new lines." >&2
  echo "  An AWS account id or ARN in a durable record identifies the account and names its resources." >&2
  echo "  Replace it with a documented placeholder (123456789012, <account-id>), or exempt the line via" >&2
  echo "  .knowledge-redaction-ignore if a human has judged this identifier safe to publish." >&2
  if [[ "$total_hits" -gt 0 ]]; then
    echo "  ($total_hits name-class hit(s) also surfaced above.)" >&2
  fi
  exit 1
fi

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
