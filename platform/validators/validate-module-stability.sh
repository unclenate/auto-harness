#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
set -euo pipefail

# validate-module-stability.sh — Per PRD-0027 / OPP-0050.
# Always-on, structural catalog check (like validate-list-completeness, NOT a
# predict-clean module-gated validator): every module.yaml must declare a
# `stability:` field from a fixed three-value enum. Asserts PRESENCE + ENUM
# membership only — never the correctness of the human judgment (honesty is an
# authoring act, as § 10 classification is). Stability is a third axis,
# independent of trust tier (risk) and § 10 (per-claim enforcement): how proven
# the module itself is.
#
# Rubric (authoring guidance — see platform/workflow/extending-the-harness.md):
#   stable       — shipped + machine enforcement + foundational (kernel) or >=1
#                  real consumer/dogfood instance
#   beta         — shipped + complete, but thin enforcement or no consumer yet
#   experimental — scaffold / speculative / niche; not battle-tested

STABILITY_ENUM="experimental beta stable"

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-module-stability.sh — Assert every module declares a valid stability tier.

Usage:
  validate-module-stability.sh [<project-root>]
  validate-module-stability.sh --scan-file <module.yaml>

Modes:
  (default)    Enumerate every module.yaml under <project-root>/platform and assert
               each declares `stability:` from the enum below.
  --scan-file  Validate a single module.yaml without enumeration (a test seam).

Field:
  stability: <experimental | beta | stable>

Rubric (authoring guidance, not machine-enforced — the validator checks presence
+ enum membership only):
  stable        shipped + enforced + foundational or >=1 real consumer/dogfood
  beta          shipped + complete, thin enforcement or no consumer instance yet
  experimental  scaffold / speculative / niche

Exit codes:
  0  pass (every module declares a valid stability)
  1  violation (a module omits stability or declares an out-of-enum value)
  2  usage error (missing argument, no modules found)
USAGE
    exit 0
    ;;
esac

# Extract + validate the stability value of one module.yaml.
# Echoes "<path>: <reason>" on a problem; returns 0 clean, 1 problem.
check_module() {
  local file="$1" line val
  line=$(grep -E '^stability:[[:space:]]' "${file}" 2>/dev/null | head -1 || true)
  if [[ -z "${line}" ]]; then
    echo "${file}: missing 'stability:' field"
    return 1
  fi
  val=$(printf '%s\n' "${line}" | sed -E 's/^stability:[[:space:]]*//; s/[[:space:]]*(#.*)?$//; s/["'"'"']//g')
  case " ${STABILITY_ENUM} " in
    *" ${val} "*) return 0 ;;
    *) echo "${file}: invalid stability '${val}' (expected one of: ${STABILITY_ENUM})"; return 1 ;;
  esac
}

# --- mode: --scan-file (single file; test seam) ------------------------------
if [[ "${1:-}" == "--scan-file" ]]; then
  shift
  if [[ $# -eq 0 || ! -f "${1:-}" ]]; then
    echo "✗ --scan-file requires a readable module.yaml path." >&2
    exit 2
  fi
  set +e
  problem=$(check_module "$1")
  status=$?
  set -e
  if [[ ${status} -eq 0 ]]; then
    echo "✓ ${1}: valid stability."
    exit 0
  fi
  echo "✗ ${problem}" >&2
  exit 1
fi

# --- mode: default (enumerate the catalog) -----------------------------------
PROJECT_ROOT="${1:-$(pwd)}"
if [[ ! -d "${PROJECT_ROOT}/platform" ]]; then
  echo "✗ No platform/ directory under '${PROJECT_ROOT}'." >&2
  exit 2
fi

MODULES=()
while IFS= read -r f; do MODULES+=("${f}"); done \
  < <(find "${PROJECT_ROOT}/platform" -name module.yaml 2>/dev/null | sort)

if [[ ${#MODULES[@]} -eq 0 ]]; then
  echo "✗ No module.yaml files found under '${PROJECT_ROOT}/platform'." >&2
  exit 2
fi

PROBLEMS=()
for m in "${MODULES[@]}"; do
  set +e
  p=$(check_module "${m}")
  s=$?
  set -e
  [[ ${s} -ne 0 ]] && PROBLEMS+=("${p}")
done

if [[ ${#PROBLEMS[@]} -eq 0 ]]; then
  echo "✓ All ${#MODULES[@]} modules declare a valid stability tier."
  exit 0
fi

echo "✗ Module-stability violations (${#PROBLEMS[@]} of ${#MODULES[@]} modules):" >&2
for p in "${PROBLEMS[@]}"; do echo "  ${p}" >&2; done
echo "→ add 'stability: <experimental|beta|stable>' (see the rubric in --help)." >&2
exit 1
