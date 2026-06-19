#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-lane-integrity.sh — Check a dispatched agent's actual changes against
# the work-package lane it declared, for projects activating the
# management/work-package overlay.
#
# Why this exists:
#   The management/work-package module gives a parallel multi-agent dispatcher a
#   machine-readable lane contract on a work-package spec: which files an agent
#   may write (allowedFiles), which it must not touch (readOnlyFiles), which
#   checks must pass, and the PR mode. This validator is the enforcement half:
#   it parses the lane spec and asserts a branch's changed files stay within the
#   declared lane. It is the multi-agent re-targeting of the module
#   declare-then-enforce contract (sensitivePaths + companionRules +
#   validate-companions): declare a boundary, then mechanically check work
#   against it, leaving judgment to review.
#
#   Roadmap citation: PRD-0025 (design contract); Phase 2 implementing PR.
#
# Usage:
#   validate-lane-integrity.sh [<manifest>] [<project-root>] [<base-branch>]
#   validate-lane-integrity.sh --scan-file <lane-spec> [<changed-path>...]
#
# Behavior:
#   Main mode (manifest-driven, module-gated):
#     1. Parse the manifest, enumerate active modules.
#     2. If management/work-package is NOT active: exit 0 with a
#        "module inactive" message (predict-clean — the harness's own CI does
#        not activate the module, so this validator is a no-op there).
#     3. If active: read docs/work-package/lane.md, parse the fenced ```yaml
#        lane block, assert the schema is well-formed, then compute the set of
#        files changed on the current branch vs <base-branch> and assert:
#          - every changed file matches at least one allowedFiles glob
#          - no changed file matches a readOnlyFiles glob
#        When no diff against base is available (clean tree / shallow checkout /
#        non-git), the schema check still runs and the diff check is skipped.
#
#   --scan-file mode (no manifest, no git):
#     Treat the given file as a lane spec. Always run the schema check. If one
#     or more changed-path arguments are supplied, also run the lane-vs-diff
#     check against that explicit set (used for fixture-firing tests, and the
#     same checker main mode feeds its git diff into).
#
# Exit codes:
#   0  validation passed (or module inactive)
#   1  validation failed (missing artifact, malformed lane schema, or a changed
#      file outside allowedFiles / touching readOnlyFiles)
#   2  usage error

set -euo pipefail

# ----------------------------------------------------------------------
# Help
# ----------------------------------------------------------------------

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-lane-integrity.sh — Check a dispatched agent's actual changes against
the work-package lane it declared (management/work-package overlay).

Usage:
  validate-lane-integrity.sh [<manifest>] [<project-root>] [<base-branch>]
  validate-lane-integrity.sh --scan-file <lane-spec> [<changed-path>...]

Arguments:
  manifest      Path to harness.manifest.yaml (default: ./harness.manifest.yaml)
  project-root  Path to the project root (default: dirname of manifest)
  base-branch   Branch/ref to diff the current branch against (default: main)
  --scan-file   Direct-content-test mode: validate an arbitrary lane-spec file's
                schema, and (if changed paths are given) the lane-vs-diff check
                against that explicit path set. Bypasses module gating and git.

Behavior (main mode):
  1. Parse the manifest, enumerate active modules.
  2. If management/work-package is NOT active: exit 0 ("module inactive")
     — predict-clean; the harness's own CI does not activate the module.
  3. If active: read docs/work-package/lane.md, parse the fenced ```yaml lane
     block, assert the schema is well-formed (branch, base, prMode in
     {draft,ready}, non-empty allowedFiles, list-typed readOnlyFiles /
     requiredChecks / forbiddenCommands), then diff the current branch vs
     <base-branch> and assert every changed file is inside allowedFiles and no
     changed file touches readOnlyFiles. The diff check is skipped when no diff
     is available (clean tree / shallow checkout / non-git).

Behavior (--scan-file mode):
  Runs the schema check always; runs the lane-vs-diff check when changed-path
  arguments are supplied. Useful for fixture-firing tests.

Exit codes:
  0  validation passed (or module inactive)
  1  validation failed
  2  usage error
USAGE
    exit 0
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# ----------------------------------------------------------------------
# Shared Ruby checker — emitted to both modes. Reads a lane-spec path and an
# optional list of changed paths from ARGV; prints diagnostics; exits 0/1.
# ----------------------------------------------------------------------
read -r -d '' LANE_CHECK_RUBY <<'RUBY_CHECK' || true
require "yaml"

PRMODES = ["draft", "ready"].freeze

# Convert a gitignore-ish glob to a Ruby fnmatch invocation. A trailing "/"
# means "this directory and everything under it".
def lane_match?(path, glob)
  g = glob.to_s.strip
  return false if g.empty?
  if g.end_with?("/")
    return path == g.chomp("/") || path.start_with?(g)
  end
  flags = File::FNM_PATHNAME | File::FNM_EXTGLOB
  File.fnmatch?(g, path, flags) ||
    # allow a bare "dir" pattern to also cover "dir/anything"
    File.fnmatch?("#{g}/**", path, flags)
end

def parse_lane(spec_path)
  raw = File.read(spec_path)
  # Prefer a fenced ```yaml ... ``` block; fall back to whole-file YAML.
  block = raw[/```ya?ml\s*\n(.*?)\n```/m, 1]
  text  = block || raw
  begin
    data = YAML.safe_load(text)
  rescue Psych::SyntaxError => e
    return [nil, "YAML parse error in lane block: #{e.message}"]
  end
  return [nil, "lane block is not a mapping"] unless data.is_a?(Hash)
  # The lane may be nested under a top-level "lane:" key or be the mapping itself.
  lane = data["lane"].is_a?(Hash) ? data["lane"] : data
  [lane, nil]
end

def check_schema(lane, label)
  errs = []
  %w[branch base].each do |f|
    v = lane[f]
    errs << "missing or empty required field '#{f}:' (string)" if v.nil? || v.to_s.strip.empty?
  end
  pm = lane["prMode"].to_s.strip
  errs << "field 'prMode:' must be one of #{PRMODES.join('|')} (got #{pm.inspect})" unless PRMODES.include?(pm)
  allowed = lane["allowedFiles"]
  if !allowed.is_a?(Array) || allowed.empty?
    errs << "field 'allowedFiles:' must be a non-empty list of globs"
  end
  %w[readOnlyFiles requiredChecks forbiddenCommands].each do |f|
    v = lane[f]
    next if v.nil? # optional; treated as empty
    errs << "field '#{f}:' must be a list (got #{v.class.name})" unless v.is_a?(Array)
  end
  errs
end

spec_path = ARGV[0]
changed   = ARGV[1..] || []

lane, perr = parse_lane(spec_path)
if perr
  warn "✗ #{spec_path}: #{perr}"
  exit 1
end

schema_errs = check_schema(lane, spec_path)
unless schema_errs.empty?
  warn "✗ #{spec_path}: malformed lane schema:"
  schema_errs.each { |e| warn "  → #{e}" }
  exit 1
end

allowed   = Array(lane["allowedFiles"])
read_only = Array(lane["readOnlyFiles"])

if changed.empty?
  puts "✓ Lane schema valid (#{spec_path}: branch=#{lane['branch']}, prMode=#{lane['prMode']}, #{allowed.size} allowed glob(s))"
  exit 0
end

out_of_lane = []
readonly_hits = []
changed.each do |path|
  path = path.strip
  next if path.empty?
  readonly_hits << path if read_only.any? { |g| lane_match?(path, g) }
  out_of_lane   << path unless allowed.any? { |g| lane_match?(path, g) }
end

if out_of_lane.empty? && readonly_hits.empty?
  puts "✓ Lane integrity passed (#{changed.size} changed file(s) within lane #{lane['branch']})"
  exit 0
end

warn "✗ #{spec_path}: lane integrity violation:"
unless out_of_lane.empty?
  warn "  changed files outside allowedFiles:"
  out_of_lane.uniq.each { |p| warn "    → #{p}" }
end
unless readonly_hits.empty?
  warn "  changed files touching readOnlyFiles:"
  readonly_hits.uniq.each { |p| warn "    → #{p}" }
end
warn "  → if an acceptance criterion or named symbol requires a file outside the"
warn "    lane, STOP and report — do not silently widen or narrow allowedFiles."
exit 1
RUBY_CHECK

# ----------------------------------------------------------------------
# --scan-file mode — direct content test, no active-module enumeration, no git
# ----------------------------------------------------------------------

if [[ "${1:-}" == "--scan-file" ]]; then
  shift
  TARGET_FILE="${1:-}"
  if [[ -z "$TARGET_FILE" ]]; then
    echo "✗ --scan-file requires a lane-spec path argument" >&2
    exit 2
  fi
  if [[ ! -f "$TARGET_FILE" ]]; then
    echo "✗ File not found: $TARGET_FILE" >&2
    exit 2
  fi
  ruby -e "$LANE_CHECK_RUBY" "$@" || exit $?
  exit 0
fi

# ----------------------------------------------------------------------
# Main mode — manifest-driven active-module gating
# ----------------------------------------------------------------------

MANIFEST="${1:-harness.manifest.yaml}"
PROJECT_ROOT="${2:-}"
BASE_BRANCH="${3:-main}"

if [[ ! -f "$MANIFEST" ]]; then
  echo "✗ Manifest not found: $MANIFEST" >&2
  exit 2
fi

if [[ -z "$PROJECT_ROOT" ]]; then
  PROJECT_ROOT="$(cd "$(dirname "$MANIFEST")" && pwd)"
fi

if [[ ! -d "$PROJECT_ROOT" ]]; then
  echo "✗ Project root not a directory: $PROJECT_ROOT" >&2
  exit 2
fi

HARNESS_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PLATFORM_ROOT="${HARNESS_ROOT}/platform"

# Active-module gate (predict-clean): exit 0 if work-package is not active.
ACTIVE="$(ruby -I "$LIB_DIR" -r harness_registry -e '
begin
  manifest = HarnessRegistry.load_manifest(ARGV[0])
  mods = HarnessRegistry.active_modules(ARGV[1], manifest)
  puts(mods.any? { |m| m["id"] == "work-package" } ? "yes" : "no")
rescue => e
  warn "usage error: #{e.message}"
  exit 2
end
' "$MANIFEST" "$PLATFORM_ROOT")" || exit $?

if [[ "$ACTIVE" != "yes" ]]; then
  echo "✓ Lane-integrity validation skipped (management/work-package not active)"
  exit 0
fi

LANE_REL="docs/work-package/lane.md"
LANE_PATH="$PROJECT_ROOT/$LANE_REL"
if [[ ! -f "$LANE_PATH" ]]; then
  echo "✗ Required artifact missing: $LANE_REL" >&2
  echo "  → the management/work-package module is active but its lane spec is not present" >&2
  echo "  → see platform/templates/work-package/lane.md for the template" >&2
  exit 1
fi

# Compute the changed-file set vs the base branch, if a diff is available.
CHANGED=()
if git -C "$PROJECT_ROOT" rev-parse --git-dir >/dev/null 2>&1 \
   && git -C "$PROJECT_ROOT" rev-parse --verify --quiet "$BASE_BRANCH" >/dev/null 2>&1; then
  while IFS= read -r f; do
    [[ -n "$f" ]] && CHANGED+=("$f")
  done < <(git -C "$PROJECT_ROOT" diff --name-only "$BASE_BRANCH"...HEAD 2>/dev/null || true)
else
  echo "ℹ No diff against '$BASE_BRANCH' available — running lane schema check only." >&2
fi

ruby -e "$LANE_CHECK_RUBY" "$LANE_PATH" "${CHANGED[@]+"${CHANGED[@]}"}" || exit $?
exit 0
