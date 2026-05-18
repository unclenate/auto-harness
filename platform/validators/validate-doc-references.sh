#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-doc-references.sh — scan every Markdown file under <project-root>/platform/
# for references to platform/... paths and assert that each referenced path resolves on
# disk relative to <project-root>. Catches the documentation-drift bugs that the audit
# pass surfaced (a link points at a file that has since moved or been renamed).
#
# Scope:
#   - Inputs: every *.md file under <project-root>/platform/ (recursive)
#   - Match: regex `platform/[A-Za-z0-9_./\-]+\.(md|yaml|yml|sh|rb|json|txt)`
#   - Skip: matches that occur inside fenced code blocks (``` ... ```)
#   - Ignore: paths matching any pattern in <project-root>/.doc-reference-ignore
#
# Exit codes:
#   0 — no broken references
#   1 — at least one reference does not resolve on disk
#   2 — usage error (no platform/ dir to scan, etc.)
set -euo pipefail

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-doc-references.sh — Assert every `platform/...` doc reference resolves on disk.

Usage:
  validate-doc-references.sh [<project-root>]

Arguments:
  project-root  Path to the consumer project root (optional; default: current working directory)

Behavior:
  Scans every *.md under <project-root>/platform/ for `platform/...` references,
  skipping fenced code blocks. Honors regex patterns in
  <project-root>/.doc-reference-ignore (one per line; # for comments).

Example:
  bash platform/validators/validate-doc-references.sh .

Exit codes:
  0  validation passed (every reference resolves)
  1  validation failed (one or more references do not resolve on disk)
  2  usage error (<project-root>/platform/ does not exist)
USAGE
    exit 0
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${1:-$(pwd)}"

if [[ ! -d "${PROJECT_ROOT}/platform" ]]; then
  echo "✗ ${PROJECT_ROOT}/platform does not exist — nothing to scan." >&2
  exit 2
fi

ruby -I"${SCRIPT_DIR}/lib" - "${PROJECT_ROOT}" <<'RUBY'
require "harness_registry"

project_root = ARGV[0]
platform_dir = File.join(project_root, "platform")
ignore_file  = File.join(project_root, ".doc-reference-ignore")

ignore_patterns = HarnessRegistry.load_doc_reference_ignore(ignore_file)
md_files = Dir.glob(File.join(platform_dir, "**", "*.md")).reject do |path|
  # Fixture projects under the validator test tree are intentionally self-contained:
  # they reference paths relative to their own fixture root, not the outer repo.
  # Scanning them at the outer-repo level would surface false positives.
  rel = path.sub(/\A#{Regexp.escape(project_root)}\/?/, "")
  rel.start_with?("platform/validators/test/fixtures/")
end

failures = []

md_files.sort.each do |md_path|
  refs = HarnessRegistry.extract_doc_references(File.read(md_path))
  refs.each do |ref|
    next if HarnessRegistry.doc_reference_ignored?(ref[:path], ignore_patterns)
    next if HarnessRegistry.doc_reference_resolves?(ref[:path], project_root)

    rel_md = md_path.sub(/\A#{Regexp.escape(project_root)}\/?/, "")
    failures << {
      file: rel_md,
      line: ref[:line],
      path: ref[:path]
    }
  end
end

if failures.empty?
  puts "✓ All platform/ doc references resolve on disk."
  exit 0
end

warn "✗ Broken doc references found:"
failures.each do |f|
  warn "  - #{f[:file]}:#{f[:line]}: #{f[:path]}"
end
exit 1
RUBY
