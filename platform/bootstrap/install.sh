#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
# shellcheck disable=SC2034
# SC2034: NON_INTERACTIVE flag is documented in usage, parsed in the case
# block, but currently a no-op (install.sh has no prompts). Reserved for
# future use; remove the disable when a prompt path consults the variable.
# install.sh — bootstrap a consumer repo after adding auto-harness as a git
# submodule. Brownfield-safe: never clobbers pre-existing files from other AI
# platforms (Cursor, Windsurf, Copilot, Codex, OpenClaw, Hermes, …) and
# conservatively merges harness-managed files that already exist.
#
# Usage:
#   bash <mount-path>/platform/bootstrap/install.sh [options]
#
# Options:
#   --mount-path PATH       Submodule mount relative to project root. Default:
#                           auto-detected from script location relative to
#                           --project-root, falling back to ".harness".
#   --project-root PATH     Default: current working directory.
#   --composition NAME      Name of the starter composition (without .yaml).
#                           Default: brownfield-lite.
#   --skills LIST           Comma-separated skill names to link. Default:
#                           harness-governance,harness-onboarding.
#   --dry-run               Report what would happen without writing anything.
#   --force                 Overwrite harness-managed files that exist with a
#                           harness signature. Never overwrites foreign or
#                           platform-artifact files.
#   --inside-platform       Escape hatch for the containment guard: allow
#                           bootstrapping inside the auto-harness platform repo
#                           (only for authoring in-tree examples). Off by default.
#   --allow-nested          Escape hatch for the nesting guard: allow
#                           bootstrapping a consumer nested inside another git
#                           repo (intentional monorepo subproject). Off by default.
#   --install-deps          Opt-in: auto-install missing dependencies that can be
#                           fixed safely (git, ripgrep) via the detected package
#                           manager. Ruby is never auto-installed (use a version
#                           manager). Off by default; without it, missing deps
#                           hard-fail with instructions. Environment-altering.
#   --non-interactive       Never prompt; fail fast if a confirmation would
#                           otherwise be required. (Currently unused; reserved.)
#   --help, -h              Show this help and exit.
#
# Exit codes:
#   0 = bootstrap completed cleanly OR all reported conflicts are
#       informational (e.g., consumer-authored file left untouched).
#       Nothing for the user to act on.
#   1 = completed with one or more *blocking* conflicts that require
#       the user to take action before re-running.
#   2 = usage error (bad flag, missing composition, invalid paths)
#
# Conflict classification:
#   - Informational: the script intentionally left a foreign / consumer-
#     authored file alone (CLAUDE.md without harness markers, etc.). A
#     follow-up suggestion is emitted under MANUAL FOLLOW-UP. No action
#     is required to use the harness.
#   - Blocking: the script could not produce a coherent state (manifest
#     present but unparseable, link-skills target collision, permission
#     denied, etc.). The user MUST act before re-running.
#
# See: platform/workflow/submodule-integration.md for the full narrative.
# See: docs/adr/ADR-0003-submodule-integration.md for design rationale.

set -euo pipefail

# ---------------------------------------------------------------------------
# Bash version preflight. This script uses associative arrays (`declare -A`)
# at line ~129, which require Bash 4+. macOS ships Bash 3.2 due to GPL-v3
# licensing, so the default `/bin/bash` will fail with a cryptic
# `declare: -A: invalid option` — bail early with a helpful message instead.
# Uses only Bash 3-compatible syntax so the check itself doesn't trigger
# the very error it's trying to explain.
# ---------------------------------------------------------------------------
if [ "${BASH_VERSINFO[0]:-0}" -lt 4 ]; then
  echo "error: install.sh requires Bash 4+ (you have Bash ${BASH_VERSION:-unknown})." >&2
  echo "" >&2
  echo "macOS ships Bash 3.2 due to GPL-v3 licensing. To get a newer one:" >&2
  echo "  brew install bash" >&2
  echo "" >&2
  echo "Then re-run this script through the newer bash:" >&2
  echo "  /opt/homebrew/bin/bash $0 $*    # Apple Silicon" >&2
  echo "  /usr/local/bin/bash $0 $*       # Intel Mac" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Script root (the auto-harness submodule mount). SCRIPT_DIR/../.. → the mount
# point, regardless of where the submodule lives in the consumer repo.
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PLATFORM_ROOT="${HARNESS_ROOT}/platform"

# Defaults (overridable via flags)
PROJECT_ROOT="$(pwd)"
COMPOSITION="brownfield-lite"
# management/privacy-by-design is default-active in brownfield-lite (and all other
# starter compositions). Every bootstrapped project gets privacy governance. Opt out
# by declaring `regime: none` with a documented `exemption:` in
# docs/privacy/privacy-profile.md — the overlay stays active in exempt mode; it is
# not removed from the manifest.
# See: platform/profiles/management/privacy-by-design/module.yaml
SKILLS="harness-governance,harness-onboarding"
DRY_RUN=false
FORCE=false
# NON_INTERACTIVE is reserved for future use. The flag is documented in the
# usage block above and parsed in the case-branch below, but install.sh
# currently has no prompts, so the boolean is a no-op. Kept so consumers can
# pass --non-interactive without breaking; remove (or actually read) when a
# prompt path is added that consults it. shellcheck SC2034 is suppressed
# inline on the case-branch where the assignment fires.
NON_INTERACTIVE=false
# Instantiation-boundary guards (OPP-0041). Both default OFF (guards active);
# each flag is a narrow, explicit escape hatch for a rare intentional case.
INSIDE_PLATFORM=false   # allow bootstrapping inside the auto-harness platform repo
ALLOW_NESTED=false      # allow bootstrapping nested inside another git repo (monorepo)
INSTALL_DEPS=false      # opt-in auto-install of missing deps (git/ripgrep) via package manager
MOUNT_PATH=""  # auto-detected after PROJECT_ROOT is known

die()   { echo "error: $*" >&2; exit 2; }
note()  { echo "$@"; }

print_usage() {
  sed -n '2,/^$/{s/^# \{0,1\}//;p;}' "$0" | sed '/^!/d'
}

# ---------------------------------------------------------------------------
# Flag parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mount-path)       MOUNT_PATH="$2"; shift 2 ;;
    --project-root)     PROJECT_ROOT="$2"; shift 2 ;;
    --composition)      COMPOSITION="$2"; shift 2 ;;
    --skills)           SKILLS="$2"; shift 2 ;;
    --dry-run)          DRY_RUN=true; shift ;;
    --force)            FORCE=true; shift ;;
    --inside-platform)  INSIDE_PLATFORM=true; shift ;;
    --allow-nested)     ALLOW_NESTED=true; shift ;;
    --install-deps)     INSTALL_DEPS=true; shift ;;
    --non-interactive)  NON_INTERACTIVE=true; shift ;;
    --help|-h)          print_usage; exit 0 ;;
    *)                  die "unknown argument: $1 (use --help)" ;;
  esac
done

[[ -d "$PROJECT_ROOT" ]] || die "--project-root not a directory: $PROJECT_ROOT"
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"

# ---------------------------------------------------------------------------
# Dependency preflight (OPP-0040). Check ALL runtime dependencies up front and
# report any that are missing together, with per-platform install hints —
# rather than discovering each at the point it is first used (Ruby at the
# manifest merge, ripgrep at the placeholder validator, …). Bash 4+ is already
# enforced at the top of this script. Hard-fail if anything is missing so
# initialization never completes against a broken toolchain.
#
# HARNESS_SKIP_DEPCHECK=1 skips ONLY this dependency preflight (not the location
# guards below). It exists for the test harness, for CI images that provision
# the toolchain themselves, and for advanced users managing deps out-of-band.
# ---------------------------------------------------------------------------
if [[ -z "${HARNESS_SKIP_DEPCHECK:-}" ]]; then

# Populate MISSING_TOKENS with canonical dep ids (git|ruby|ripgrep). Re-runnable
# so we can re-check after an --install-deps attempt.
MISSING_TOKENS=()
detect_missing_deps() {
  MISSING_TOKENS=()
  command -v git >/dev/null 2>&1 || MISSING_TOKENS+=("git")
  if command -v ruby >/dev/null 2>&1; then
    ruby -e 'exit((RUBY_VERSION.split(".").map(&:to_i) <=> [3,0,0]) >= 0 ? 0 : 1)' 2>/dev/null \
      || MISSING_TOKENS+=("ruby")
  else
    MISSING_TOKENS+=("ruby")
  fi
  command -v rg >/dev/null 2>&1 || MISSING_TOKENS+=("ripgrep")
}
dep_desc() {
  case "$1" in
    git)     echo "git — required to mount and update the auto-harness submodule" ;;
    ripgrep) echo "ripgrep (rg) — required by validate-placeholders.sh and other validators" ;;
    ruby)
      if command -v ruby >/dev/null 2>&1; then
        echo "ruby >= 3.0 (found $(ruby -e 'print RUBY_VERSION' 2>/dev/null)) — required by install.sh's manifest merge and the validators"
      else
        echo "ruby >= 3.0 — required by install.sh's manifest merge and the validators"
      fi ;;
  esac
}

detect_missing_deps

# Opt-in auto-install (Tier 4 / environment-altering). Only git and ripgrep are
# auto-installed; Ruby is deliberately excluded because a system Ruby commonly
# shadows a package-manager Ruby, making a scripted fix unreliable.
if [[ ${#MISSING_TOKENS[@]} -gt 0 ]] && $INSTALL_DEPS; then
  PM_INSTALL=""
  if   command -v brew    >/dev/null 2>&1; then PM_INSTALL="brew install"
  elif command -v apt-get >/dev/null 2>&1; then PM_INSTALL="sudo apt-get install -y"
  elif command -v dnf     >/dev/null 2>&1; then PM_INSTALL="sudo dnf install -y"
  elif command -v pacman  >/dev/null 2>&1; then PM_INSTALL="sudo pacman -S --noconfirm"
  fi
  if [[ -z "$PM_INSTALL" ]]; then
    echo "--install-deps: no supported package manager (brew/apt-get/dnf/pacman) found; skipping auto-install." >&2
  else
    PKGS=()
    for tok in "${MISSING_TOKENS[@]}"; do
      case "$tok" in
        git)     PKGS+=("git") ;;
        ripgrep) PKGS+=("ripgrep") ;;
        ruby)    echo "--install-deps: not auto-installing Ruby (a system Ruby often shadows a package-manager Ruby); use a version manager — see note below." >&2 ;;
      esac
    done
    if [[ ${#PKGS[@]} -gt 0 ]]; then
      echo "--install-deps: installing via: $PM_INSTALL ${PKGS[*]}" >&2
      # shellcheck disable=SC2086
      $PM_INSTALL "${PKGS[@]}" >&2 || echo "--install-deps: install command failed; see output above." >&2
    fi
    detect_missing_deps
  fi
fi

if [[ ${#MISSING_TOKENS[@]} -gt 0 ]]; then
  {
    echo "error: missing required dependencies — bootstrap cannot complete:"
    echo ""
    for tok in "${MISSING_TOKENS[@]}"; do echo "  - $(dep_desc "$tok")"; done
    echo ""
    case "$(uname -s)" in
      Darwin) echo "Install on macOS (Homebrew):   brew install git ruby ripgrep bash" ;;
      Linux)
        echo "Install on Debian/Ubuntu:       sudo apt-get install -y git ruby ripgrep"
        echo "Install on Fedora/RHEL:         sudo dnf install -y git ruby ripgrep"
        echo "Install on Arch:                sudo pacman -S git ruby ripgrep" ;;
      *)      echo "Install git, ruby (>=3.0), and ripgrep via your platform's package manager." ;;
    esac
    echo ""
    echo "Note: some distributions ship Ruby < 3.0 — use a version manager (rbenv/asdf)"
    echo "or your distro's ruby3.x package to get a current Ruby."
    echo ""
    echo "Tip: re-run with --install-deps to auto-install git/ripgrep via your package"
    echo "manager (Ruby still needs a version manager). Re-run once deps are present."
  } >&2
  exit 2
fi
fi  # end HARNESS_SKIP_DEPCHECK guard

# ---------------------------------------------------------------------------
# Instantiation-boundary guards (OPP-0041). A consumer MUST be its own git
# repository — never the auto-harness platform repo itself, and never nested
# inside another repo's working tree (its files would be committed into, and
# possibly pushed to, the wrong repository). Detect both BEFORE writing
# anything and hard-fail with a remedy. Each guard has a narrow escape hatch
# for the rare intentional case. The check runs only when PROJECT_ROOT is
# inside a git repo; a not-yet-init'd consumer dir trips neither guard.
# See: platform/workflow/recover-misplaced-consumer.md (recovery runbook).
# ---------------------------------------------------------------------------
ENCLOSING_TOPLEVEL=""
if command -v git >/dev/null 2>&1; then
  ENCLOSING_TOPLEVEL="$(git -C "$PROJECT_ROOT" rev-parse --show-toplevel 2>/dev/null || true)"
fi

if [[ -n "$ENCLOSING_TOPLEVEL" ]]; then
  # Guard A — inside the auto-harness platform repo itself. Highest-consequence
  # case (a private consumer's files committed/pushed into the platform repo).
  # The fingerprint — kernel doctrine path + the self-repo manifest id — is
  # unique to auto-harness's own repository, so false positives are negligible.
  if [[ -f "$ENCLOSING_TOPLEVEL/platform/core/kernel/base/doctrine.md" ]] \
     && grep -Eq '^[[:space:]]*id:[[:space:]]*development-harness-framework[[:space:]]*$' \
            "$ENCLOSING_TOPLEVEL/harness.manifest.yaml" 2>/dev/null; then
    if ! $INSIDE_PLATFORM; then
      {
        echo "error: refusing to bootstrap a consumer inside the auto-harness platform repo."
        echo ""
        echo "  Platform repo detected at: $ENCLOSING_TOPLEVEL"
        echo "  Target consumer root:      $PROJECT_ROOT"
        echo ""
        echo "A consumer must be its OWN git repository, with auto-harness mounted"
        echo "beneath it as a submodule — never a subdirectory of the platform."
        echo ""
        echo "Fix — from a directory OUTSIDE the platform repo:"
        echo "  cd ~/projects/my-app && git init"
        echo "  git submodule add -b main <auto-harness-url> .harness"
        echo "  bash .harness/platform/bootstrap/install.sh"
        echo ""
        echo "Authoring an intentional in-tree example? Re-run with --inside-platform."
        echo "Already created files in the platform tree? Recover with:"
        echo "  ${HARNESS_ROOT}/platform/workflow/recover-misplaced-consumer.md"
      } >&2
      exit 2
    fi
  # Guard B — nested under some OTHER git repo. The consumer's files would be
  # tracked by the enclosing repo rather than a repo of its own. The common
  # legitimate case is a monorepo subproject, hence an explicit escape hatch
  # rather than a silent proceed.
  elif [[ "$ENCLOSING_TOPLEVEL" != "$PROJECT_ROOT" ]]; then
    if ! $ALLOW_NESTED; then
      {
        echo "error: refusing to bootstrap a consumer nested inside another git repository."
        echo ""
        echo "  Enclosing git repo:   $ENCLOSING_TOPLEVEL"
        echo "  Target consumer root: $PROJECT_ROOT"
        echo ""
        echo "The consumer's files would be tracked by the enclosing repo, not by a"
        echo "repository of their own. A consumer should be its own git root."
        echo ""
        echo "Fix: run from the intended repository root (where .git lives), or create"
        echo "a fresh repo for the consumer outside '$ENCLOSING_TOPLEVEL'."
        echo ""
        echo "Intentional monorepo subproject? Re-run with --allow-nested."
      } >&2
      exit 2
    fi
  fi
fi

# Auto-detect MOUNT_PATH if not provided
if [[ -z "$MOUNT_PATH" ]]; then
  # relative path from project root to harness root
  if command -v realpath >/dev/null 2>&1; then
    MOUNT_PATH="$(realpath --relative-to="$PROJECT_ROOT" "$HARNESS_ROOT" 2>/dev/null || echo ".harness")"
  else
    MOUNT_PATH=".harness"
  fi
  # guard: if detection landed outside the project (e.g., sibling checkout),
  # fall back to .harness for the documented default.
  case "$MOUNT_PATH" in
    ..*|/*) MOUNT_PATH=".harness" ;;
  esac
fi

[[ "$MOUNT_PATH" != /* ]] || die "--mount-path must be relative, got: $MOUNT_PATH"

COMPOSITION_FILE="${PLATFORM_ROOT}/compositions/${COMPOSITION}.yaml"
[[ -f "$COMPOSITION_FILE" ]] \
  || die "composition not found: $COMPOSITION_FILE (available: $(ls "${PLATFORM_ROOT}/compositions" | sed 's/\.yaml$//' | tr '\n' ' '))"

# ---------------------------------------------------------------------------
# Platform signature catalog. Each line: PLATFORM_NAME:SIGNATURE_PATH.
# PLATFORM_ARTIFACT files (those actually present as files, not the catalog
# itself) are never modified by this script.
# ---------------------------------------------------------------------------
PLATFORM_SIGNATURES=(
  "cursor:.cursorrules"
  "cursor:.cursor"
  "windsurf:.windsurfrules"
  "windsurf:.windsurf"
  "github-copilot:.github/copilot-instructions.md"
  "github-copilot:.github/copilot"
  "ms-copilot:.vscode/copilot.json"
  "ms-copilot:.copilot"
  "openai-codex:codex.yaml"
  "openai-codex:.codex"
  "openclaw:TOOLS.md"
  "openclaw:SOUL.md"
  "openclaw:IDENTITY.md"
  "openclaw:HEARTBEAT.md"
  "openclaw:BOOT.md"
  "openclaw:USER.md"
  "hermes:hermes.yaml"
  "hermes:.hermes"
)

# Detect platforms present; collect unique platform names + their observed paths.
declare -A OBSERVED_PATHS   # platform -> " path1 path2 ..."
PLATFORMS_OBSERVED=()

cd "$PROJECT_ROOT"
for entry in "${PLATFORM_SIGNATURES[@]}"; do
  platform="${entry%%:*}"
  sig_path="${entry#*:}"
  if [[ -e "$sig_path" ]]; then
    if [[ -z "${OBSERVED_PATHS[$platform]+x}" ]]; then
      PLATFORMS_OBSERVED+=("$platform")
      OBSERVED_PATHS[$platform]=""
    fi
    OBSERVED_PATHS[$platform]+=" $sig_path"
  fi
done

# ---------------------------------------------------------------------------
# Summary accumulators
#
# CONFLICTS holds every reported conflict line (informational + blocking)
# because users still want to see informational entries — they explain why
# the harness skipped a file. BLOCKING_CONFLICTS is the exit-code signal:
# only call sites where the user MUST act before re-running increment it.
# See the "Exit codes" header for the classification rule.
# ---------------------------------------------------------------------------
CREATED=()
SKIPPED=()
CONFLICTS=()
FOLLOWUPS=()
BLOCKING_CONFLICTS=0

write_file() {
  local path="$1" content="$2"
  if $DRY_RUN; then
    CREATED+=("[DRY-RUN] $path")
    return
  fi
  mkdir -p "$(dirname "$path")"
  printf '%s' "$content" > "$path"
  CREATED+=("$path")
}

replace_file() {
  local path="$1" content="$2"
  if $DRY_RUN; then
    CREATED+=("[DRY-RUN replace] $path")
    return
  fi
  printf '%s' "$content" > "$path"
  CREATED+=("$path (replaced)")
}

# ---------------------------------------------------------------------------
# merge_manifest_identity: preserve the consumer's project identity across a
# --force re-bootstrap.
#
# Reads project.id / project.name / project.maturity / project.criticality from
# the existing manifest at $1 (an existing on-disk file), then substitutes
# them into the generated manifest content passed on stdin. Emits the merged
# manifest on stdout.
#
# Identity fields are *descriptive* — they identify the consumer's project,
# not its governance. --force is meant to replace the governance (modules,
# overrides) the composition declares, not silently clobber the consumer's
# project identity with the composition's example placeholders (e.g.,
# `id: example-interview-driven`).
#
# Field-by-field: each identity field is preserved only if the existing
# manifest declares it AND the generated content also has a slot for it.
# If the existing manifest is missing a `project:` block (e.g., it's corrupt
# or stub), no substitution happens and the generated content is returned
# verbatim — same as a fresh install.
#
# Implementation note: uses awk for portability (no Ruby/yq dependency).
# Assumes the conventional two-space YAML indentation under `project:`. All
# in-tree composition files use two-space indent (validated by the harness
# itself). Only the *first* occurrence of each `  <field>:` line under the
# `project:` block is rewritten — composition manifests have exactly one
# per file by convention.
# ---------------------------------------------------------------------------
merge_manifest_identity() {
  local existing="$1"
  local existing_id existing_name existing_maturity existing_criticality

  # Extract identity from existing manifest. We only consider lines inside the
  # top-level `project:` block (two-space indented `  id:`, etc.). Missing
  # fields yield an empty string and are skipped during substitution.
  extract_field() {
    local field="$1"
    awk -v f="$field" '
      /^project:[[:space:]]*$/ { in_project = 1; next }
      /^[^[:space:]]/         { in_project = 0 }
      in_project && $0 ~ "^  " f ":" {
        sub("^  " f ":[[:space:]]*", "")
        sub("[[:space:]]*#.*$", "")
        sub("[[:space:]]+$", "")
        print
        exit
      }
    ' "$existing"
  }

  existing_id="$(extract_field id)"
  existing_name="$(extract_field name)"
  existing_maturity="$(extract_field maturity)"
  existing_criticality="$(extract_field criticality)"

  # If the existing manifest had no `project:` block at all, every field came
  # back empty — fall through to composition defaults (just pass stdin).
  if [[ -z "$existing_id" && -z "$existing_name" \
        && -z "$existing_maturity" && -z "$existing_criticality" ]]; then
    cat
    return
  fi

  awk \
    -v new_id="$existing_id" \
    -v new_name="$existing_name" \
    -v new_maturity="$existing_maturity" \
    -v new_criticality="$existing_criticality" '
    BEGIN { in_project = 0; did_id = 0; did_name = 0; did_maturity = 0; did_criticality = 0 }
    /^project:[[:space:]]*$/ { in_project = 1; print; next }
    /^[^[:space:]]/          { in_project = 0 }
    {
      if (in_project && new_id != "" && !did_id && $0 ~ /^  id:/) {
        print "  id: " new_id; did_id = 1; next
      }
      if (in_project && new_name != "" && !did_name && $0 ~ /^  name:/) {
        print "  name: " new_name; did_name = 1; next
      }
      if (in_project && new_maturity != "" && !did_maturity && $0 ~ /^  maturity:/) {
        print "  maturity: " new_maturity; did_maturity = 1; next
      }
      if (in_project && new_criticality != "" && !did_criticality && $0 ~ /^  criticality:/) {
        print "  criticality: " new_criticality; did_criticality = 1; next
      }
      print
    }
  '
}

# ---------------------------------------------------------------------------
# Target 1: harness.manifest.yaml
# ---------------------------------------------------------------------------
handle_manifest() {
  local target="${PROJECT_ROOT}/harness.manifest.yaml"
  if [[ ! -e "$target" ]]; then
    local content
    content="$(cat "$COMPOSITION_FILE")"
    write_file "$target" "$content"
    return
  fi

  # Signature: valid manifest has `schemaVersion: 1` near the top
  if head -n 5 "$target" | grep -q '^schemaVersion: 1'; then
    if $FORCE; then
      # Preserve consumer's project identity across the --force regeneration.
      # Governance (modules, overrides) comes from the composition; identity
      # (id/name/maturity/criticality) is sourced from the existing manifest.
      local content
      content="$(merge_manifest_identity "$target" < "$COMPOSITION_FILE")"
      replace_file "$target" "$content"
    else
      SKIPPED+=("harness.manifest.yaml (harness-style, use --force to replace)")
    fi
  else
    # Blocking: a file at harness.manifest.yaml that we can't recognize means
    # validators will fail and the harness will not function. The user must
    # decide (delete + re-run, or merge manually) before re-running.
    CONFLICTS+=("harness.manifest.yaml exists but lacks harness signature (schemaVersion: 1); leaving untouched")
    BLOCKING_CONFLICTS=$((BLOCKING_CONFLICTS + 1))
    FOLLOWUPS+=("Review harness.manifest.yaml; run 'cp ${COMPOSITION_FILE} harness.manifest.yaml.new' and merge manually")
  fi
}

# ---------------------------------------------------------------------------
# Target 2: HARNESS.md
# ---------------------------------------------------------------------------
HARNESS_MD_TEMPLATE="# HARNESS.md

This project uses the modular harness manifest at \`harness.manifest.yaml\`.
Auto-harness is mounted at \`${MOUNT_PATH}/\` as a git submodule.

- Governance: \`${MOUNT_PATH}/platform/workflow/submodule-integration.md\`
- Validators: \`${MOUNT_PATH}/platform/validators/\`
- Skills (symlinked): \`.agents/skills/\` and \`.claude/skills/\`

Update the submodule to pull in upstream improvements:

\`\`\`
git submodule update --remote ${MOUNT_PATH}
\`\`\`
"

handle_harness_md() {
  local target="${PROJECT_ROOT}/HARNESS.md"
  if [[ ! -e "$target" ]]; then
    write_file "$target" "$HARNESS_MD_TEMPLATE"
    return
  fi

  if grep -q 'harness.manifest.yaml' "$target" 2>/dev/null; then
    if $FORCE; then
      replace_file "$target" "$HARNESS_MD_TEMPLATE"
    else
      SKIPPED+=("HARNESS.md (harness-style, use --force to replace)")
    fi
  else
    # Blocking: HARNESS.md is the load-order anchor for every harness-aware
    # agent. If a file exists at that path that doesn't reference
    # harness.manifest.yaml, agents can't follow the contract. User must act.
    CONFLICTS+=("HARNESS.md exists but lacks harness signature; leaving untouched")
    BLOCKING_CONFLICTS=$((BLOCKING_CONFLICTS + 1))
    FOLLOWUPS+=("Review HARNESS.md; harness content lives in ${MOUNT_PATH}/platform/workflow/")
  fi
}

# ---------------------------------------------------------------------------
# Target 3: CLAUDE.md
# ---------------------------------------------------------------------------
CLAUDE_MD_TEMPLATE="# CLAUDE.md

Claude Code must read:

1. \`HARNESS.md\`
2. \`AGENTS.md\`
3. this file
4. active stack and delivery overlays declared in \`harness.manifest.yaml\`

Harness skills are available under \`.claude/skills/\` (symlinked into \`${MOUNT_PATH}/platform/skills/\`).
"

handle_claude_md() {
  local target="${PROJECT_ROOT}/CLAUDE.md"
  if [[ ! -e "$target" ]]; then
    write_file "$target" "$CLAUDE_MD_TEMPLATE"
    return
  fi

  if grep -q 'HARNESS.md' "$target" 2>/dev/null && grep -q 'harness.manifest.yaml' "$target" 2>/dev/null; then
    if $FORCE; then
      replace_file "$target" "$CLAUDE_MD_TEMPLATE"
    else
      SKIPPED+=("CLAUDE.md (harness-style, use --force to replace)")
    fi
  else
    # Informational (not blocking). CLAUDE.md is consumer-authored content;
    # the harness only suggests an additive 'reads HARNESS.md, AGENTS.md'
    # block. Nothing is broken if the user ignores the suggestion. Reported
    # in CONFLICTS for visibility but does NOT increment BLOCKING_CONFLICTS.
    CONFLICTS+=("CLAUDE.md exists and appears consumer-authored; leaving untouched")
    FOLLOWUPS+=("Consider adding a 'reads HARNESS.md, AGENTS.md' block to your CLAUDE.md")
  fi
}

# ---------------------------------------------------------------------------
# Target 4: AGENTS.md (always merged via marker block, never replaced wholesale)
# ---------------------------------------------------------------------------
AGENTS_MARKER_START="<!-- harness-managed-section -->"
AGENTS_MARKER_END="<!-- /harness-managed-section -->"

build_agents_managed_block() {
  cat <<EOF
${AGENTS_MARKER_START}

<!-- This section is maintained by ${MOUNT_PATH}/platform/bootstrap/install.sh.
     Edits between the markers will be overwritten on re-bootstrap.
     See docs/adr/ADR-0003-submodule-integration.md for rationale. -->

## Harness governance

This repo adopts auto-harness for governance, mounted at \`${MOUNT_PATH}/\`.

- Active manifest: \`harness.manifest.yaml\`
- Governance rules: derived from active modules declared in the manifest
- Validators: \`${MOUNT_PATH}/platform/validators/*.sh\` (require Ruby 3.0+)
- Skills available: \`.agents/skills/\` (cross-client) and \`.claude/skills/\` (Claude Code)

Cross-agent operating rules come from the kernel trust model and active agent
packs declared in \`harness.manifest.yaml\`.

### Keeping the harness up to date

Periodically run \`git submodule update --remote ${MOUNT_PATH}\` to pick up harness
improvements (new modules, validator fixes, new compositions). Review the
diff and commit. See \`${MOUNT_PATH}/platform/workflow/maintenance-operations.md\`
for the full upgrade workflow.

${AGENTS_MARKER_END}
EOF
}

AGENTS_FULL_TEMPLATE_HEAD="# AGENTS.md

Cross-agent operating rules for this project. This file is read by Claude Code,
Cursor, Windsurf, GitHub Copilot, OpenAI Codex, and any other agent that
respects the AGENTS.md cross-client convention.

"

handle_agents_md() {
  local target="${PROJECT_ROOT}/AGENTS.md"
  local managed_block
  managed_block="$(build_agents_managed_block)"

  if [[ ! -e "$target" ]]; then
    write_file "$target" "${AGENTS_FULL_TEMPLATE_HEAD}${managed_block}"$'\n'
    return
  fi

  # File exists. Check for existing marker.
  if grep -qF "$AGENTS_MARKER_START" "$target" && grep -qF "$AGENTS_MARKER_END" "$target"; then
    # Replace content between markers
    if $DRY_RUN; then
      CREATED+=("[DRY-RUN update markers] AGENTS.md")
      return
    fi
    local tmp block_tmp
    tmp="$(mktemp)"
    block_tmp="$(mktemp)"
    # BSD awk (macOS default) rejects multi-line strings passed via `-v`
    # ("newline in string"), so write the managed block to a temp file and
    # have awk read it on demand inside the BEGIN/replacement block. Same
    # behavior on gawk; survives portability.
    printf '%s' "$managed_block" > "$block_tmp"
    awk -v start="$AGENTS_MARKER_START" -v end="$AGENTS_MARKER_END" -v blockfile="$block_tmp" '
      BEGIN {
        in_managed = 0
        block = ""
        while ((getline line < blockfile) > 0) {
          if (block == "") block = line
          else             block = block "\n" line
        }
        close(blockfile)
      }
      $0 == start { print block; in_managed = 1; next }
      $0 == end   { in_managed = 0; next }
      !in_managed { print }
    ' "$target" > "$tmp"
    mv "$tmp" "$target"
    rm -f "$block_tmp"
    CREATED+=("AGENTS.md (managed section updated)")
  else
    # Append managed block, preserving all existing content.
    if $DRY_RUN; then
      CREATED+=("[DRY-RUN append] AGENTS.md + managed block")
      return
    fi
    printf '\n\n%s\n' "$managed_block" >> "$target"
    CREATED+=("AGENTS.md (managed block appended; existing content preserved)")
  fi
}

# ---------------------------------------------------------------------------
# Skill linking (delegates to link-skills.sh)
# ---------------------------------------------------------------------------
link_skills() {
  local link_sh="${SCRIPT_DIR}/link-skills.sh"
  [[ -x "$link_sh" ]] || die "link-skills.sh not found or not executable: $link_sh"

  local skill_args
  IFS=',' read -r -a skill_args <<< "$SKILLS"

  local link_out link_code=0
  local force_flag=""
  $FORCE && force_flag="--force"

  if $DRY_RUN; then
    CREATED+=("[DRY-RUN] symlinks for skills: ${SKILLS}")
    return
  fi

  # Temporarily disable `set -e` so link-skills.sh's exit 1 (conflicts) doesn't abort us.
  set +e
  link_out="$(bash "$link_sh" --project-root "$PROJECT_ROOT" --mount-path "$MOUNT_PATH" $force_flag "${skill_args[@]}" 2>&1)"
  link_code=$?
  set -e

  # Parse link-skills output and fold into our summary. link-skills CONFLICTs
  # (e.g., a directory present where the symlink would go) are blocking —
  # the skill won't be available until the user resolves the collision.
  while IFS= read -r line; do
    case "$line" in
      "[OK] "*)       SKIPPED+=("${line#[OK] }") ;;
      "[CREATED] "*)  CREATED+=("${line#[CREATED] }") ;;
      "[REPLACED] "*) CREATED+=("${line#[REPLACED] }") ;;
      "[CONFLICT] "*)
        CONFLICTS+=("${line#[CONFLICT] }")
        BLOCKING_CONFLICTS=$((BLOCKING_CONFLICTS + 1))
        ;;
      Summary:*|"")   ;; # drop
      *)              FOLLOWUPS+=("link-skills: $line") ;;
    esac
  done <<< "$link_out"

  if [[ $link_code -ne 0 ]] && [[ ${#CONFLICTS[@]} -eq 0 ]]; then
    FOLLOWUPS+=("link-skills.sh exited $link_code but reported no parseable conflicts")
  fi
}

# ---------------------------------------------------------------------------
# CI snippet (emitted to stdout; NOT written — too easy to clobber existing CI)
# ---------------------------------------------------------------------------
emit_ci_snippet() {
  cat <<EOF

# ---------------------------------------------------------------------------
# Suggested CI workflow (NOT installed automatically — review and add manually):
#
#   .github/workflows/harness.yml
#
# ---------------------------------------------------------------------------
# name: Harness validation
# on: [pull_request, push]
# jobs:
#   validate:
#     runs-on: ubuntu-latest
#     env:
#       HARNESS_SUBMODULE_ROOT: \${{ github.workspace }}/${MOUNT_PATH}
#     steps:
#       - uses: actions/checkout@v4
#         with:
#           submodules: recursive
#           fetch-depth: 0
#       - uses: ruby/setup-ruby@v1
#         with:
#           ruby-version: "3.3"
#       - name: Validate manifest
#         run: bash \$HARNESS_SUBMODULE_ROOT/platform/validators/validate-manifest.sh harness.manifest.yaml
#       - name: Validate module graph
#         run: bash \$HARNESS_SUBMODULE_ROOT/platform/validators/validate-module-graph.sh harness.manifest.yaml
# ---------------------------------------------------------------------------

EOF
}

# ---------------------------------------------------------------------------
# Validator smoke test
# ---------------------------------------------------------------------------
smoke_test_validators() {
  $DRY_RUN && return

  local manifest="${PROJECT_ROOT}/harness.manifest.yaml"
  [[ -f "$manifest" ]] || return  # nothing to validate

  if ! command -v ruby >/dev/null 2>&1; then
    FOLLOWUPS+=("Install Ruby 3.0+ to run validators locally: apt install ruby (or use ruby/setup-ruby in CI)")
    return
  fi

  set +e
  local m_out m_code g_out g_code
  m_out="$(bash "${PLATFORM_ROOT}/validators/validate-manifest.sh" "$manifest" 2>&1)"
  m_code=$?
  g_out="$(bash "${PLATFORM_ROOT}/validators/validate-module-graph.sh" "$manifest" 2>&1)"
  g_code=$?
  set -e

  if [[ $m_code -ne 0 ]]; then
    FOLLOWUPS+=("validate-manifest.sh exited $m_code: $(echo "$m_out" | tail -3 | tr '\n' ' ')")
  fi
  if [[ $g_code -ne 0 ]]; then
    FOLLOWUPS+=("validate-module-graph.sh exited $g_code: $(echo "$g_out" | tail -3 | tr '\n' ' ')")
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
note "auto-harness bootstrap"
note "  harness root:      $HARNESS_ROOT"
note "  project root:      $PROJECT_ROOT"
note "  mount path:        $MOUNT_PATH"
note "  composition:       $COMPOSITION ($COMPOSITION_FILE)"
note "  skills to link:    $SKILLS"
$DRY_RUN && note "  mode:              DRY-RUN (no files will be written)"
$FORCE && note "  force:             ENABLED (harness-style files may be overwritten)"
note ""

handle_manifest
handle_harness_md
handle_claude_md
handle_agents_md
link_skills
smoke_test_validators
emit_ci_snippet

# ---------------------------------------------------------------------------
# Summary (5 blocks)
# ---------------------------------------------------------------------------
print_block() {
  local label="$1"; shift
  local -a items=("$@")
  note "${label}:"
  if [[ ${#items[@]} -eq 0 ]]; then
    note "  (none)"
  else
    local item
    for item in "${items[@]}"; do note "  - $item"; done
  fi
  note ""
}

note "------------------------------------------------------------------"
note "Bootstrap summary"
note "------------------------------------------------------------------"
print_block "CREATED"            "${CREATED[@]+"${CREATED[@]}"}"
print_block "SKIPPED (existing)" "${SKIPPED[@]+"${SKIPPED[@]}"}"
print_block "CONFLICTS"          "${CONFLICTS[@]+"${CONFLICTS[@]}"}"

# Platforms observed: format "platform (path1, path2)"
PLATFORM_LINES=()
for p in "${PLATFORMS_OBSERVED[@]+"${PLATFORMS_OBSERVED[@]}"}"; do
  paths="${OBSERVED_PATHS[$p]}"
  # trim leading space + comma-join
  paths="${paths# }"
  paths="${paths// /, }"
  PLATFORM_LINES+=("$p ($paths)")
done
print_block "PLATFORMS OBSERVED (never modified by bootstrap)" "${PLATFORM_LINES[@]+"${PLATFORM_LINES[@]}"}"

# Always-present follow-up
FOLLOWUPS+=("For deeper brownfield gap analysis, run the harness-onboarding skill against this repo.")
print_block "MANUAL FOLLOW-UP" "${FOLLOWUPS[@]+"${FOLLOWUPS[@]}"}"

note "------------------------------------------------------------------"

# Three-state exit. See header "Exit codes" section.
#   - blocking > 0 → exit 1 (user must act)
#   - blocking == 0 with informational entries → exit 0 with explanatory note
#   - blocking == 0 with no entries → exit 0 with clean note
if [[ $BLOCKING_CONFLICTS -gt 0 ]]; then
  note "Completed with ${BLOCKING_CONFLICTS} blocking conflict(s). Resolve them and re-run."
  exit 1
fi

if [[ ${#CONFLICTS[@]} -gt 0 ]]; then
  note "Completed. ${#CONFLICTS[@]} item(s) in CONFLICTS are informational — no action required. See MANUAL FOLLOW-UP for suggestions."
  exit 0
fi

note "Completed successfully."
exit 0
