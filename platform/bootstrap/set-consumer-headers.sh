#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# set-consumer-headers.sh — Fill consumer-project header tokens in
# template-derived files.
#
# Specifies and implements PRD-0005 FR-002. Consumer projects that
# scaffold artifacts by copying files from `platform/templates/**`
# inherit files whose headers carry `[[YEAR]] [[OWNER_NAME]]
# <[[OWNER_EMAIL]]>` and `SPDX-License-Identifier: [[SPDX_LICENSE]]`
# tokens. This helper prompts (or reads from `.harness-headers.yaml`
# / flags) for the consumer's chosen values, writes the project-local
# config, and substitutes tokens across files in the project tree.
#
# Token set this script fills (and only these):
#   [[YEAR]]            -> e.g. 2026
#   [[OWNER_NAME]]      -> e.g. Jane Smith
#   [[OWNER_EMAIL]]     -> e.g. jane@example.com
#   [[SPDX_LICENSE]]    -> e.g. MIT or "MIT OR Apache-2.0"
#   [[PROJECT_NAME]]    -> e.g. my-project (or "" to skip)
#
# Other `[[…]]` tokens (e.g. `[[OWNER]]`, `[[OPP_TITLE]]`) are
# *deliberately* not filled here — those are per-record fields that
# the consumer fills when scaffolding a specific artifact.
#
# Usage:
#   set-consumer-headers.sh                # interactive; writes config + substitutes
#   set-consumer-headers.sh --dry-run      # report changes without writing
#   set-consumer-headers.sh --non-interactive --owner-name=... --owner-email=...
#   set-consumer-headers.sh --config=.harness-headers.yaml --files=docs/adr/ADR-0001.md
#
# Exit codes:
#   0  success
#   1  user-error (invalid email, missing required value in non-interactive mode)
#   2  usage-error (missing dependency, malformed config, unknown flag)

set -euo pipefail

# ----------------------------------------------------------------------
# Defaults + constants
# ----------------------------------------------------------------------

CONFIG_FILE=".harness-headers.yaml"

# Combined regex for ripgrep scanning (matches any of the 5 supported tokens
# this script fills: YEAR, OWNER_NAME, OWNER_EMAIL, SPDX_LICENSE, PROJECT_NAME).
SCAN_REGEX='\[\[(YEAR|OWNER_NAME|OWNER_EMAIL|SPDX_LICENSE|PROJECT_NAME)\]\]'

OWNER_NAME=""
OWNER_EMAIL=""
YEAR=""
SPDX_LICENSE=""
PROJECT_NAME=""
INTERACTIVE=auto
DRY_RUN=0
FILES_ARG=""
SCAN_ROOT="."

# ----------------------------------------------------------------------
# Help
# ----------------------------------------------------------------------

show_help() {
  cat <<'USAGE'
set-consumer-headers.sh — Fill template-header tokens for a consumer project.

Usage:
  set-consumer-headers.sh [flags]

Default behavior (no flags):
  1. Loads existing `.harness-headers.yaml` if present (offered as prompt defaults).
  2. Prompts interactively for OWNER_NAME, OWNER_EMAIL, YEAR, SPDX_LICENSE, PROJECT_NAME.
  3. Writes/updates `.harness-headers.yaml` with the chosen values.
  4. Scans the project tree for tracked files containing any of the five
     supported tokens and substitutes the chosen values in place.

Flags:
  --owner-name=NAME            Set owner name (skips prompt for this field)
  --owner-email=EMAIL          Set owner email (skips prompt for this field)
  --year=YYYY                  Set year (default: current year)
  --spdx-license=ID            Set SPDX license identifier (e.g. "MIT")
  --project-name=NAME          Set project name; pass "" to skip the field
  --config=PATH                Use a different config file path
  --files=p1,p2,...            Only operate on these files (default: scan tree)
  --scan=DIR                   Scope the tree scan to DIR (default: ".")
  --non-interactive            Fail if any required value is missing instead of prompting
  --dry-run                    Report changes without writing files or config
  -h, --help                   Show this help

Token set substituted (and only these):
  [[YEAR]]          [[OWNER_NAME]]   [[OWNER_EMAIL]]
  [[SPDX_LICENSE]]  [[PROJECT_NAME]]

Other tokens (e.g. [[OWNER]], [[OPP_TITLE]]) are left unfilled — those
are per-artifact fields filled when scaffolding individual records.

Examples:
  # First-time consumer onboarding (interactive)
  bash platform/bootstrap/set-consumer-headers.sh

  # CI / scripted (no prompts, all values from flags)
  bash platform/bootstrap/set-consumer-headers.sh \
    --non-interactive \
    --owner-name="Jane Smith" --owner-email="jane@example.com" \
    --spdx-license="MIT" --project-name="my-project"

  # Re-run after editing the config file
  bash platform/bootstrap/set-consumer-headers.sh --non-interactive

  # Apply to specific files only
  bash platform/bootstrap/set-consumer-headers.sh --files=docs/adr/ADR-0001-foo.md

Exit codes:
  0  success
  1  user-error (invalid email format, missing required value in --non-interactive)
  2  usage-error (missing dependency, malformed config, unknown flag)

Spec: docs/requirements/PRD-0005-consumer-header-hygiene.md
USAGE
}

# ----------------------------------------------------------------------
# Arg parsing
# ----------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) show_help; exit 0 ;;
    --owner-name=*) OWNER_NAME="${1#*=}" ;;
    --owner-email=*) OWNER_EMAIL="${1#*=}" ;;
    --year=*) YEAR="${1#*=}" ;;
    --spdx-license=*) SPDX_LICENSE="${1#*=}" ;;
    --project-name=*) PROJECT_NAME="${1#*=}" ;;
    --config=*) CONFIG_FILE="${1#*=}" ;;
    --files=*) FILES_ARG="${1#*=}" ;;
    --scan=*) SCAN_ROOT="${1#*=}" ;;
    --non-interactive) INTERACTIVE=0 ;;
    --interactive) INTERACTIVE=1 ;;
    --dry-run) DRY_RUN=1 ;;
    *) echo "✗ Unknown flag: $1" >&2; echo "Run with --help for usage." >&2; exit 2 ;;
  esac
  shift
done

# ----------------------------------------------------------------------
# Dependency check
# ----------------------------------------------------------------------

if ! command -v rg >/dev/null 2>&1; then
  echo "✗ rg (ripgrep) is required. Install ripgrep and re-run." >&2
  exit 2
fi

# ----------------------------------------------------------------------
# Resolve interactivity mode
# ----------------------------------------------------------------------

if [[ "$INTERACTIVE" == "auto" ]]; then
  if [[ -t 0 && -t 1 ]]; then INTERACTIVE=1; else INTERACTIVE=0; fi
fi

# ----------------------------------------------------------------------
# Config-file load (offers prompt defaults)
# ----------------------------------------------------------------------

read_config_field() {
  # Read a top-level scalar field from a flat YAML config file.
  # Format expected: `key: "value"` or `key: value` (no nested structures).
  local file="$1" key="$2"
  if [[ ! -f "$file" ]]; then return; fi
  awk -v k="$key" '
    BEGIN { FS = ":" }
    /^[[:space:]]*#/ { next }
    $1 == k {
      $1 = ""
      sub(/^:[[:space:]]*/, "")
      sub(/^[[:space:]]+/, "")
      sub(/[[:space:]]+$/, "")
      gsub(/^"|"$/, "")
      print
      exit
    }
  ' "$file"
}

if [[ -f "$CONFIG_FILE" ]]; then
  [[ -z "$OWNER_NAME"  ]] && OWNER_NAME="$(read_config_field "$CONFIG_FILE" owner_name)"
  [[ -z "$OWNER_EMAIL" ]] && OWNER_EMAIL="$(read_config_field "$CONFIG_FILE" owner_email)"
  [[ -z "$YEAR"        ]] && YEAR="$(read_config_field "$CONFIG_FILE" year)"
  [[ -z "$SPDX_LICENSE" ]] && SPDX_LICENSE="$(read_config_field "$CONFIG_FILE" spdx_license)"
  [[ -z "$PROJECT_NAME" ]] && PROJECT_NAME="$(read_config_field "$CONFIG_FILE" project_name)"
fi

# Year default = current calendar year.
if [[ -z "$YEAR" ]]; then YEAR="$(date +%Y)"; fi

# ----------------------------------------------------------------------
# Interactive prompts
# ----------------------------------------------------------------------

prompt_for() {
  # prompt_for VAR_NAME "Question text" "default-value"
  local var_name="$1" question="$2" default="$3" answer=""
  if [[ -n "$default" ]]; then
    read -r -p "$question [$default]: " answer </dev/tty || true
    [[ -z "$answer" ]] && answer="$default"
  else
    read -r -p "$question: " answer </dev/tty || true
  fi
  printf -v "$var_name" '%s' "$answer"
}

if [[ "$INTERACTIVE" == 1 ]]; then
  echo "Setting consumer-project headers. Press Enter to keep the [default] shown for each prompt."
  echo ""
  prompt_for OWNER_NAME    "Owner name (person or organization)"             "$OWNER_NAME"
  prompt_for OWNER_EMAIL   "Owner email"                                     "$OWNER_EMAIL"
  prompt_for YEAR          "Copyright year"                                  "$YEAR"
  prompt_for SPDX_LICENSE  "SPDX license identifier (e.g. MIT, Apache-2.0)"  "${SPDX_LICENSE:-MIT}"
  prompt_for PROJECT_NAME  "Project name (or leave empty)"                   "$PROJECT_NAME"
  echo ""
fi

# ----------------------------------------------------------------------
# Validate required values
# ----------------------------------------------------------------------

missing=()
[[ -z "$OWNER_NAME"   ]] && missing+=("OWNER_NAME")
[[ -z "$OWNER_EMAIL"  ]] && missing+=("OWNER_EMAIL")
[[ -z "$YEAR"         ]] && missing+=("YEAR")
[[ -z "$SPDX_LICENSE" ]] && missing+=("SPDX_LICENSE")
# PROJECT_NAME is optional (consumer may omit the project-reference line).

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "✗ Missing required values: ${missing[*]}" >&2
  if [[ "$INTERACTIVE" == 0 ]]; then
    echo "  Re-run interactively or pass via flags (e.g. --owner-name=\"Jane Smith\")." >&2
  fi
  exit 1
fi

# Basic email-shape sanity check (not a spec-grade validator — just catches obvious typos).
if [[ ! "$OWNER_EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
  echo "✗ '$OWNER_EMAIL' does not look like a valid email address." >&2
  exit 1
fi

# ----------------------------------------------------------------------
# Write config file
# ----------------------------------------------------------------------

write_config() {
  local config_path="$1"
  cat > "$config_path" <<EOF
# .harness-headers.yaml
# Generated by platform/bootstrap/set-consumer-headers.sh
# Edit values and re-run the script with --non-interactive to re-apply.
owner_name: "${OWNER_NAME}"
owner_email: "${OWNER_EMAIL}"
year: ${YEAR}
spdx_license: "${SPDX_LICENSE}"
project_name: "${PROJECT_NAME}"
EOF
}

if [[ "$DRY_RUN" == 1 ]]; then
  echo "[dry-run] Would write config: $CONFIG_FILE"
else
  write_config "$CONFIG_FILE"
  echo "✓ Wrote config: $CONFIG_FILE"
fi

# ----------------------------------------------------------------------
# Find candidate files
# ----------------------------------------------------------------------

declare -a CANDIDATES=()
if [[ -n "$FILES_ARG" ]]; then
  IFS=',' read -r -a CANDIDATES <<< "$FILES_ARG"
else
  # Files in scan root containing any of the 5 supported tokens.
  if mapfile_out="$(rg -l --regexp "$SCAN_REGEX" "$SCAN_ROOT" 2>/dev/null)"; then
    while IFS= read -r line; do
      [[ -n "$line" ]] && CANDIDATES+=("$line")
    done <<< "$mapfile_out"
  fi
fi

if [[ ${#CANDIDATES[@]} -eq 0 ]]; then
  echo "ℹ No files contain the supported tokens. Nothing to substitute."
  exit 0
fi

# ----------------------------------------------------------------------
# Substitution
# ----------------------------------------------------------------------

# Escape a value for use in sed s|...|<here>|g (delimiter is pipe).
escape_replacement() {
  # Escape backslash, pipe, ampersand for sed RHS.
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/|/\\|/g' -e 's/&/\\&/g'
}

ESC_OWNER_NAME="$(escape_replacement "$OWNER_NAME")"
ESC_OWNER_EMAIL="$(escape_replacement "$OWNER_EMAIL")"
ESC_YEAR="$(escape_replacement "$YEAR")"
ESC_SPDX="$(escape_replacement "$SPDX_LICENSE")"
ESC_PROJECT="$(escape_replacement "$PROJECT_NAME")"

substitute_in_file() {
  local f="$1"
  if [[ "$DRY_RUN" == 1 ]]; then
    # Report which tokens would be replaced.
    local found
    found="$(grep -oE "$SCAN_REGEX" "$f" 2>/dev/null | sort -u | tr '\n' ' ')"
    echo "[dry-run] Would substitute in: $f  ($found)"
    return
  fi

  # Portable in-place edit: use sed -i with a backup suffix that works on
  # both BSD (macOS) and GNU sed. Delete the backup after success.
  sed -i.bak \
    -e "s|\\[\\[OWNER_NAME\\]\\]|${ESC_OWNER_NAME}|g" \
    -e "s|\\[\\[OWNER_EMAIL\\]\\]|${ESC_OWNER_EMAIL}|g" \
    -e "s|\\[\\[YEAR\\]\\]|${ESC_YEAR}|g" \
    -e "s|\\[\\[SPDX_LICENSE\\]\\]|${ESC_SPDX}|g" \
    -e "s|\\[\\[PROJECT_NAME\\]\\]|${ESC_PROJECT}|g" \
    "$f"
  rm -f "$f.bak"
}

changed=0
for f in "${CANDIDATES[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "⚠ Skipping (not a file): $f" >&2
    continue
  fi
  substitute_in_file "$f"
  changed=$((changed + 1))
done

if [[ "$DRY_RUN" == 1 ]]; then
  echo ""
  echo "[dry-run] $changed file(s) would be modified."
else
  echo "✓ Substituted in $changed file(s)."
fi

exit 0
