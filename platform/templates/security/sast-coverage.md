---
tool: semgrep
scanPaths:
  - ^src/
  - ^lib/
severityThreshold: high
---

<!--
Copyright {{YEAR}} {{AUTHOR}} <{{AUTHOR_EMAIL}}>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of {{PROJECT_NAME}} — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# SAST Coverage Declaration

This document is the consumer's SAST contract. It declares which static
analysis tool is configured for this repository, which paths the tool
scans, and what severity threshold gates CI.

The frontmatter above is parsed by `validate-sast-coverage.sh` (part of
the `management/security-static-analysis` overlay module). The validator
asserts:

1. `tool:` names a value from the recommended set (`semgrep`, `codeql`,
   `bandit`, `gosec`, `eslint-plugin-security`, `snyk-code`).
2. `scanPaths:` has at least one entry.
3. `severityThreshold:` is non-empty.

Update the values above to match this project's SAST configuration.

## Tool selection rationale

Document **why** this tool was chosen for this project's stack. The
reviewGate on this artifact rejects an unrationalized tool selection
— reviewers should be able to read this section and understand the
tradeoffs the team made (e.g., "CodeQL for GitHub-hosted polyglot
project — accepts the GH-Code-Scanning UI tradeoff over Semgrep's
broader rule library"). Include license posture (OSS vs commercial)
where the tradeoff matters.

## Scan paths

The `scanPaths:` frontmatter list above must cover the project's
primary source root. Describe each path here in prose:

- `^src/` — the project's primary source directory; agent-generated
  code lands here.
- `^lib/` — shared library code consumed by the application surface.
- (add more rows as the project's source root grows)

When source paths change (broaden the scope or add a new top-level
directory), update the `scanPaths:` frontmatter and add a row here
explaining the change. The companion rule on this artifact ensures
the change has an aligned change-log / ADR / PRD entry.

## Severity threshold

The `severityThreshold:` frontmatter declares the severity at which
SAST findings fail the consumer's CI. Document the policy here:

- **Above threshold (current: `high`)** — CI fails the build; finding
  must be remediated, suppressed with documented rationale, or have its
  severity successfully challenged.
- **At threshold (current: `medium`)** — CI warns but does not fail;
  reviewers triage; finding may merge with an inline suppression
  comment + change-log entry.
- **Below threshold (current: `low`)** — CI logs; no merge gate.

When lowering the threshold (e.g., `high` → `critical`), the companion
rule requires a change-log entry, ADR, or PRD documenting the rationale.
Reviewers verify the change is intentional. Agents may not lower the
threshold without human approval.

## Finding-triage policy

Document the workflow for findings:

- **Where findings are tracked** (e.g., GitHub Security tab, Jira
  project, internal triage doc).
- **Who triages** (e.g., security review group, project maintainer,
  on-call rotation).
- **Suppression discipline** (when an inline suppression is acceptable,
  what the comment must include, how suppressions are reviewed
  periodically).
- **Baseline policy** (e.g., findings present at activation are
  recorded as the baseline; new findings above threshold post-baseline
  fail CI even if pre-existing findings exist).

## Cross-references

- `management/security-static-analysis` module
  ([README](../../profiles/management/security-static-analysis/README.md))
- PRD-0016 — Security Static Analysis Module design contract
- The CI workflow file (`.github/workflows/*.yml` or equivalent) that
  invokes the declared tool — link to it here for reviewer convenience.
