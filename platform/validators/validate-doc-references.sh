#!/usr/bin/env bash
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
#
# validate-doc-references.sh — renderer-aware Markdown link validator (v2).
#
# v1 only caught `platform/...`-shaped path strings inside platform/*.md.
# v2 catches the bug class that surfaced in PR #18 and PR #20:
#
#   1. Relative-path link targets — `[X](../foo.md)`, `[X](../adr/ADR-0001.md)`
#      — the idiomatic way to cross-link sibling-dir docs.
#   2. Bare extensionless targets — `[X](LICENSE-MIT)`, `[X](NOTICE)` — these
#      render correctly on GitHub.com but GitBook treats them as directories
#      and 404s on `<target>/README.md`.
#   3. Trailing-slash directory targets — `[X](path/to/dir/)` — same renderer
#      issue.
#   4. Inline backtick code-spans containing `[X](broken.md)` — pedagogical
#      strings, not real links; v1 (and v2 fenced-block skip) didn't cover
#      this.
#
# Scope:
#   - Inputs: every *.md file under <project-root> EXCEPT files under
#     legacy/, .git/, .claude/, node_modules/, .worktrees/,
#     platform/validators/test/fixtures/, platform/templates/docs/
#     (rationale: see DEFAULT_SCAN_EXCLUDE_PREFIXES in harness_registry.rb)
#   - Match: `[text](target)` where target is not external (http/https/mailto/
#     tel/#anchor/<...>/{{template}})
#   - Also preserved from v1: bare `platform/...` path strings (so the dogfood
#     guarantee against the harness's own tree is unchanged)
#   - Skip: matches inside fenced code blocks (``` ... ```) or inline backtick
#     code spans (`...`)
#   - Ignore: paths matching any regex in <project-root>/.doc-reference-ignore
#
# Output:
#   - Each violation is reported as:
#       <md-file>:<line>: <target> — <reason>
#     where <reason> is one of:
#       broken                            (resolved path does not exist)
#       directory target may not render…  (trailing slash or resolves to dir)
#       bare extensionless target…        (renderer-fragile per GitBook spec)
#
# Exit codes:
#   0 — no broken or renderer-fragile references
#   1 — at least one violation
#   2 — usage error (no project root, etc.)
set -euo pipefail

case "${1:-}" in
  -h|--help)
    cat <<'USAGE'
validate-doc-references.sh — Assert every markdown link resolves on disk and renders safely.

Usage:
  validate-doc-references.sh [<project-root>]

Arguments:
  project-root  Path to the consumer project root (optional; default: current working directory)

Behavior:
  Scans every *.md under <project-root> for markdown links `[text](target)`
  with a relative target. Each target is resolved against the markdown file's
  directory and checked for:
    1. on-disk existence (no broken links)
    2. renderer safety (no trailing-slash / bare-extensionless targets —
       these break on GitBook even when they resolve on GitHub.com)
  Skips fenced code blocks and inline backtick code spans. Honors regex
  patterns in <project-root>/.doc-reference-ignore (one per line; # for
  comments). The legacy v1 `platform/...` bare-path extractor is preserved
  so the dogfood guarantee carries over.

Example:
  bash platform/validators/validate-doc-references.sh .

Exit codes:
  0  validation passed
  1  validation failed (one or more broken or renderer-fragile links)
  2  usage error (<project-root> does not exist)
USAGE
    exit 0
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${1:-$(pwd)}"

if [[ ! -d "${PROJECT_ROOT}" ]]; then
  echo "✗ ${PROJECT_ROOT} does not exist — nothing to scan." >&2
  exit 2
fi

if [[ ! -d "${PROJECT_ROOT}/platform" ]]; then
  echo "✗ ${PROJECT_ROOT}/platform does not exist — nothing to scan." >&2
  exit 2
fi

ruby -I"${SCRIPT_DIR}/lib" - "${PROJECT_ROOT}" <<'RUBY'
require "harness_registry"

project_root     = File.expand_path(ARGV[0])
ignore_file      = File.join(project_root, ".doc-reference-ignore")
ignore_patterns  = HarnessRegistry.load_doc_reference_ignore(ignore_file)

failures = []

# ---------------------------------------------------------------------------
# Pass 1 (v1, preserved): bare `platform/...` references under platform/*.md.
# This is the dogfood guarantee against the harness's own platform/ tree and
# is what the existing test suite asserts. We keep it untouched so the v2
# scope expansion is purely additive.
# ---------------------------------------------------------------------------
platform_dir = File.join(project_root, "platform")
v1_md_files  = Dir.glob(File.join(platform_dir, "**", "*.md")).reject do |path|
  rel = path.sub(/\A#{Regexp.escape(project_root)}\/?/, "")
  HarnessRegistry::DEFAULT_SCAN_EXCLUDE_PREFIXES.any? { |prefix| rel.start_with?(prefix) }
end

v1_md_files.sort.each do |md_path|
  refs = HarnessRegistry.extract_doc_references(File.read(md_path))
  refs.each do |ref|
    next if HarnessRegistry.doc_reference_ignored?(ref[:path], ignore_patterns)
    next if HarnessRegistry.doc_reference_resolves?(ref[:path], project_root)

    rel_md = md_path.sub(/\A#{Regexp.escape(project_root)}\/?/, "")
    failures << {
      file:   rel_md,
      line:   ref[:line],
      target: ref[:path],
      reason: "broken (platform/ reference does not resolve)"
    }
  end
end

# ---------------------------------------------------------------------------
# Pass 2 (v2): all markdown links across project_root.
# ---------------------------------------------------------------------------
v2_md_files = HarnessRegistry.markdown_files_to_scan(project_root)

v2_md_files.each do |md_path|
  md_dir = File.dirname(md_path)
  links  = HarnessRegistry.extract_markdown_links(File.read(md_path))

  links.each do |link|
    target   = link[:target]
    resolved = HarnessRegistry.resolve_relative_link(target, md_dir, project_root)

    # Ignore-list keys off the resolved project-relative path. When the
    # resolver returns nil (target escapes root or is external) we still
    # allow ignoring by the raw target string for forward compatibility.
    next if resolved && HarnessRegistry.doc_reference_ignored?(resolved, ignore_patterns)
    next if HarnessRegistry.doc_reference_ignored?(target, ignore_patterns)

    classification = HarnessRegistry.link_target_classify(target, resolved, project_root)
    next if classification == :ok

    reason =
      case classification
      when :missing
        "broken (resolved path does not exist on disk)"
      when :directory_target
        "directory target may not render in GitBook; point at <canonical>.md inside the directory"
      when :extensionless
        "bare extensionless target may not render in GitBook; use an absolute GitHub URL or add an extension"
      else
        "unknown classification: #{classification}"
      end

    rel_md = md_path.sub(/\A#{Regexp.escape(project_root)}\/?/, "")
    failures << {
      file:   rel_md,
      line:   link[:line],
      target: target,
      reason: reason
    }
  end
end

# De-duplicate: pass-1 and pass-2 can both flag the same `[X](platform/foo.md)`
# inside a platform/*.md file. Key by (file, line, target).
failures.uniq! { |f| [f[:file], f[:line], f[:target]] }

if failures.empty?
  puts "✓ All markdown link targets resolve on disk and render safely."
  exit 0
end

warn "✗ Broken or renderer-fragile doc references found:"
failures.each do |f|
  warn "  - #{f[:file]}:#{f[:line]}: #{f[:target]} — #{f[:reason]}"
end
exit 1
RUBY
