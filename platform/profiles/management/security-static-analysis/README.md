<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Management Overlay: Security Static Analysis

## What this module adds

This overlay governs projects that adopt **SAST coverage as a structural
quality gate on agent-generated code**. It turns the SAST discipline into
a reviewable contract:

- **A SAST coverage declaration** (`docs/security/sast-coverage.md`)
  naming the tool, the scan paths, the severity threshold, and the
  finding-triage policy.
- **A guarded-source-path companion rule** — changes under `src/`,
  `lib/`, `app/` require either an attached SAST report or an updated
  coverage declaration.
- **A tool-change companion rule** — changes to the coverage
  declaration or tool-configuration files require a change-log entry,
  ADR, or PRD.
- **Review gates** that reject silently lowered thresholds and
  declarations that omit the primary source root.

The harness validates the contract exists and is well-formed; the
consumer's CI runs the SAST tool and gates on findings. This module's
posture is **half-enforced** per PRD-0016 §10 C-SAST-S1: the harness
provides the opt-in scaffolding, but end-to-end enforcement requires
the consumer's CI honoring the declared threshold.

## When to activate

Activate `management/security-static-analysis` when:

- Your project ships software (not only documents) and agent-generated
  code lands in the shipped surface.
- You can configure a SAST tool in your CI and gate merge on findings
  above a declared severity threshold.
- You want a single canonical artifact reviewers can read to understand
  which paths are scanned, by what tool, at what threshold.

Pair it with `management/eval-gated-testing` when the project also
gates on binary-graded evaluation of agent output — eval gates govern
behavioral quality, SAST coverage governs code-output quality. The two
are complementary, not substitutes.

## What it requires

- **Required:** `docs/security/sast-coverage.md` — the SAST contract.
  Template at `platform/templates/security/sast-coverage.md`.
- **Optional:** `docs/security/sast-reports/` directory — attached
  SAST run outputs that the companion rule's `requiredAny` accepts.

## The recommended-set this module expects

The coverage declaration must name a tool from this set (the validator
fails on an unrecognized tool name, prompting the consumer to either
adopt a recommended tool or file a PR adding theirs):

| Tool | Stack focus | License | Notes |
|------|-------------|---------|-------|
| `semgrep` | Polyglot (50+ languages) | OSS (LGPL/MIT) + commercial tier | CI-friendly; large community rule library; v1 default for polyglot projects |
| `codeql` | GitHub-native, deep semantic | OSS for OSS use; commercial for private | Best signal-quality for GH-hosted projects; integrates with GH Code Scanning |
| `bandit` | Python | OSS (Apache-2.0) | Python AST-based; lightweight; idiomatic for Python-only projects |
| `gosec` | Go | OSS (Apache-2.0) | Go AST-based; idiomatic for Go-only projects |
| `eslint-plugin-security` | JavaScript / TypeScript | OSS (Apache-2.0) | Plugs into existing ESLint pipeline; idiomatic for JS-shaped projects |
| `snyk-code` | Polyglot (commercial) | Commercial | Strong rule set; commercial license — pick OSS alternatives if license posture matters |

**Pick-one guidance** (avoid the failure mode of "module recommends 6
tools and consumer picks none"):

- **Polyglot project on GitHub** → `codeql` (best signal-quality + GH
  integration) or `semgrep` (broader rule library + non-GH-friendly).
- **Python-only project** → `bandit` (smaller surface) or `semgrep`
  (if a polyglot rule library is desirable).
- **Go-only project** → `gosec`.
- **JavaScript / TypeScript project** → `eslint-plugin-security` if
  ESLint is already in use; `semgrep` otherwise.
- **Mixed-license-permissive project** → start with the OSS options;
  `snyk-code` adds value when the team can justify the commercial
  spend.

The list is append-only — new tools can be added via PR alongside an
update to the validator's `RECOMMENDED_TOOLS` constant. Filing a
"recommend tool X" PR is the path for tools not yet enumerated.

## What the validator checks

`validate-sast-coverage.sh` runs as part of the harness validator
chain. When this module is **not** active in the manifest, the
validator exits 0 with a "module inactive — skipping" message; the
harness itself does not activate it, so the harness's own CI run
is a no-op pass (predict-clean absorption mechanism per PRD-0016
FR-003).

When this module **is** active, the validator reads
`docs/security/sast-coverage.md` and asserts:

1. The artifact exists.
2. It parses as YAML frontmatter (between `---` fences at the top).
3. The frontmatter declares a `tool:` key with a value from the
   recommended set (case-sensitive).
4. The frontmatter declares at least one `scanPaths:` entry (list of
   path globs / regex strings).
5. The frontmatter declares a `severityThreshold:` key with a
   non-empty value (e.g., `medium`, `high`, `critical`).

Per-field surfacing on failure: the validator names the missing or
malformed field and points at the artifact line. Exit semantics:
0 pass, 1 violation, 2 usage error.

## What it does not do

- It does not invoke SAST tools. Running Semgrep / CodeQL / Bandit /
  gosec / ESLint / Snyk Code from the harness toolchain is parent
  [OPP-0020](../../../../docs/opportunities/OPP-0020-evaluation-tooling-in-harness-toolchain.md)
  territory. The consumer configures the tool in their CI; the harness
  validates the *declaration* of which tool, paths, and threshold are
  in use.
- It does not inspect SAST report content. v1 does not parse reports
  for finding-severity, rule IDs, or line numbers. The consumer's CI
  gates on threshold; the harness validates the contract exists.
- It does not handle secrets scanning. Secrets is GitHub-repo-level
  (already enabled via repo settings) and structurally different
  from SAST.
- It does not pin tool versions. The recommended-set is a soft
  surface; tool-version pinning and vendor-advisory tracking are
  v2 concerns.
- It does not cross-validate `sast-coverage.md` against the consumer's
  CI workflow file content. YAML-per-CI-vendor scope-explodes the
  validator and is deferred to v2 if consumer feedback surfaces the
  divergence as a non-trivial failure mode.

## Cross-references

- [PRD-0016](../../../../docs/requirements/PRD-0016-security-static-analysis-module.md) — design contract.
- [OPP-0035](../../../../docs/opportunities/OPP-0035-security-static-analysis.md) — origin and evidence.
- [OPP-0020](../../../../docs/opportunities/OPP-0020-evaluation-tooling-in-harness-toolchain.md) — parent OPP (harness-side eval/safety tool invocation).
- [ADR-0017](../../../../docs/adr/ADR-0017-safety-hardening-roadmap.md) — Safety Hardening Roadmap (Wave 5.4).
- `safety-security-sweep.md` §11 — *the largest mission-relative gap in the entire safety sweep*; this module is the named closure path.
