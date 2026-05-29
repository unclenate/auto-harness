<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0016: Security Static Analysis Module — `management/security-static-analysis`

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-05-28 | **Review Cycle:** On-change

**Status:** Accepted *(v1 module + validator shipped; release marker v0.6.0)*
**Date:** 2026-05-28 (filed) | 2026-05-28 (accepted on Wave 5.4 implementation merge)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Related OPP: [OPP-0035](../opportunities/OPP-0035-security-static-analysis.md) — `proposed`; this PRD is its promotion candidate. Will flip to `exploring` in the same commit that ships this PRD.
- Parent OPP: [OPP-0020](../opportunities/OPP-0020-evaluation-tooling-in-harness-toolchain.md) — Evaluation & Safety Tooling in Harness Toolchain (Tula). OPP-0035 is filed explicitly as a child under OPP-0020 per execution-roadmap §8.
- Related ADR: [ADR-0017](../adr/ADR-0017-safety-hardening-roadmap.md) — Wave 5.4 of the Safety Hardening Roadmap. ADR-0017 §16 priority 5 anchors this PRD; line 150 names "PRD + `management/security-static-analysis` module + `validate-sast-coverage.sh`" as the Wave 5.4 deferred implementation.
- Sibling module precedent: [`management/eval-gated-testing`](../../platform/profiles/management/eval-gated-testing/module.yaml) ([PRD-0009](PRD-0009-eval-gated-testing-module.md)) — the opt-in management overlay pattern this PRD follows: required artifact, companion rule, review gates, opt-in for consumers that aren't ready.
- Related PRDs:
  - [PRD-0015](PRD-0015-validate-skill-content.md) — Wave 5.2 content-safety validator. Same sprint, same §10-bearing-PRD shape, immediate precedent.
  - [PRD-0006](PRD-0006-trust-tier-enforcement.md) — Wave 5.1 validator pattern; declared-content-validates-against-known-set shape this PRD's validator mirrors.
- Related operating principles:
  - [§ 5 Self-Governance](../operating-principles.md#5-self-governance) — the harness recommends SAST coverage for consumer projects; this PRD lets consumers structurally adopt the recommendation rather than only see it asserted.
  - [§ 9 Split Design from Implementation](../operating-principles.md#9-split-design-from-implementation) — this PRD ships the design contract; the implementing PR ships the module scaffolding + validator + propagation.
  - [§ 10 Classify Claims Before Enforcing Them](../operating-principles.md#10-classify-claims-before-enforcing-them) — this PRD names each Asserted-only claim being converted (see §10 Claim Classification block below).
- Related observations:
  - `docs/knowledge/shared-observations.md` — *"Mechanizing-doctrine surfaces PRD-internal inconsistencies the design pass elided"* (2026-05-27) — anticipated to apply here: the implementation may surface specific scope-budget cuts the PRD elides.
- Other:
  - `documentation-audit-2026-05-27/safety-security-sweep.md` § 11 (Underhanded-Code Risk in Governed Software — *the largest mission-relative gap in the entire safety sweep*), § 16 priority 4 (the priority anchor).

## Overview

The framework governs AI agents that generate code, but there is
**zero machinery in the harness that inspects agent-generated code in
the consumer project** for security smells. Safety-security-sweep §11
documents this as *"the largest mission-relative gap in the entire
safety sweep."* The harness ships governance scaffolding around an AI
agent's *changes*, but no structural check on whether the *code
produced* contains underhanded patterns — off-by-one bugs, TOCTOU
races, integer truncation, sign-flip in security predicates.

This PRD specifies a v1 **opt-in management overlay** module —
`management/security-static-analysis` — that lets consumers structurally
adopt SAST coverage as a quality gate, with the same opt-in shape as
`management/eval-gated-testing`. v1 ships:

1. **`platform/profiles/management/security-static-analysis/{module.yaml,README.md}`** —
   the module declaration: required artifact, sensitive-paths,
   companion rules, review gates, agent adapters.
2. **`docs/security/sast-coverage.md`** required artifact (template
   provided at `platform/templates/security/sast-coverage.md`) — the
   consumer's SAST contract: which tool is configured, which paths it
   scans, what severity threshold gates CI, how findings are triaged.
3. **`validate-sast-coverage.sh`** — Bash + Ruby validator that, when
   the module is active in the consumer's manifest, asserts the
   `sast-coverage.md` artifact is well-formed: declares a tool from
   the recommended-set, declares scan paths, declares a severity
   threshold. 3-state exit per established convention.
4. **Companion rule:** changes under guarded source paths (consumer
   declares; v1 default `src/`, `lib/`, `app/`) require an updated
   SAST report attached or an updated `sast-coverage.md` entry —
   reusing `validate-companions.sh` machinery.
5. **Tool ecosystem documented:** v1 README lists 2-3 SAST tools per
   common stack (Semgrep, CodeQL, Bandit, gosec, ESLint security
   plugins, Snyk Code) with explicit "pick one" guidance per
   OPP-0035 Risk 1.
6. **Default posture: predict-clean** — the harness itself does not
   activate the module. The validator scans only when a consumer's
   manifest activates the module. Per
   `feedback-validator-absorption-mechanisms`: predict-clean — the
   harness's CI runs the validator as a no-op pass (no active
   `management/security-static-analysis` overlay, nothing to scan).

v1 is **opt-in posture enforcement** only. Actually invoking SAST
tools from the harness toolchain (Semgrep/CodeQL/Bandit/gosec
adapters) is the parent OPP-0020 territory — out of scope here.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- Ship `platform/profiles/management/security-static-analysis/module.yaml`
  declaring `type: management`, `dependsOn: [kernel/base]`,
  `conflictsWith: []`, `requiredArtifacts:
  [docs/security/sast-coverage.md]`, sensitive-paths covering the
  artifact + common SAST-config locations, a companion rule for
  guarded source paths, review gates per the section below.
- Ship `platform/profiles/management/security-static-analysis/README.md`
  enumerating the recommended SAST tools per stack with "pick one"
  guidance.
- Ship `platform/templates/security/sast-coverage.md` (tokenized
  header per established header-hygiene; sections for declared tool,
  scan paths, severity threshold, finding-triage policy).
- Ship `platform/validators/validate-sast-coverage.sh` — Bash 3.2
  compatible, shellcheck-clean at warning severity, 3-state exit.
  When the consumer's manifest activates the module, the validator
  reads `docs/security/sast-coverage.md` and asserts: (a) declares a
  tool name from the recommended-set, (b) declares at least one
  `scanPaths:` entry, (c) declares a `severityThreshold:` value.
  When the module is *not* active, validator exits 0 with a "module
  inactive, skipping" message.
- Define the recommended-set inline in the validator with a comment
  block citing the module README. Initial set per OPP-0035 Risk 1:
  `semgrep`, `codeql`, `bandit`, `gosec`, `eslint-plugin-security`,
  `snyk-code`. Append-only; new tools added with PRs.
- Wire the new validator into `kernel/base` module.yaml validators
  list, `.github/workflows/harness.yml`, consumer CI templates,
  `AGENTS.md` recommended-run-order, `harness-governance/SKILL.md`
  validator chain + signature notes, `validators/README.md` script
  table, root `README.md` validators table + mermaid box.
- Update `validate-catalog-counts.sh` ASSERTIONS for validator-count
  bump (13 → 14) at the 7 documented sites; module-count bump (9 → 10
  for active-modules-reachable; profiles module count bumps the
  separate `modules_profiles` recipe).
- Propagate module to catalog surfaces: `SUMMARY.md` Module Library
  (Management); `harness-onboarding/SKILL.md` management catalog;
  `discovery-to-composition.md` Step 6 rubric row.
- One paired distillation observation in
  `docs/knowledge/shared-observations.md` capturing the design
  pressure of the *first new opt-in module of the sprint* (prior
  Waves all added validators against existing modules; Wave 5.4 adds
  a new module). Anticipated: the implementation pass will surface
  design questions about how `validate-sast-coverage.sh` detects
  "module is active" without re-implementing manifest parsing.

**Non-Goals** — outcomes explicitly out of scope. Be specific; vague
non-goals allow scope to creep back in:

- **Running SAST tools from the harness toolchain.** Invoking
  Semgrep/CodeQL/Bandit/gosec from the harness CLI is OPP-0020 (the
  parent OPP) territory. v1 is consumer-posture only: the consumer
  configures the tool in their own CI; the harness validates the
  consumer's *declaration* of which tool + paths + thresholds are in
  use.
- **Inspecting SAST finding *content*.** v1 does not parse SAST
  reports for finding-severity, line locations, or rule IDs. The
  consumer's CI gates on the threshold; the harness validates the
  *contract* exists, not the *report* contents. Report-content
  inspection is a v2+ orthogonal defense.
- **Secrets scanning.** Per OPP-0035 Risk 4: secrets is GitHub
  repo-level (already enabled per L3-04 from PR #74's audit-folder
  followup) and is structurally different from SAST. This module
  focuses on SAST findings.
- **Agent self-review reviewGate.** Sweep §11 Recommendation 2 names
  an "Agent Self-Review" reviewGate on `agents/base/module.yaml`.
  Per OPP-0035 Risk 5: distinct surface; file separate OPP under
  OPP-0031 (defense-in-depth) if pursued. Not part of this PRD.
- **Tier-vocabulary or tool-version lockfile.** v1's recommended-set
  is a soft recommendation surface, not a frozen lockfile. Pinning
  exact tool versions is a v2+ design decision.
- **Mandating a specific SAST tool.** v1 lists multiple tools per
  stack; consumer activates the tool matching their CI investment.
  Avoid the failure mode of "module recommends N tools and consumer
  picks none."

> Distinction from `Functional Requirements > Out of Scope`: Non-Goals
> are *outcomes* ("we are not solving runtime classification"); FR
> Out-of-Scope is *features* ("we are not building auto-strip").

## §10 Claim Classification

Per the [§10 operating principle](../operating-principles.md#10-classify-claims-before-enforcing-them),
this PRD names each load-bearing claim being converted from
Asserted-only to Enforced or Half-enforced:

| Claim ID | Claim | Current state | After v1 | Source |
|----------|-------|---------------|----------|--------|
| C-SAST-S1 | The harness has machinery for consumers to structurally adopt SAST coverage as a quality gate | Asserted-only | Half-enforced — opt-in module exists; consumer must activate it AND run SAST tools in their CI for *actual* enforcement | Sweep §11 |
| C-SAST-S2 | When a consumer's `sast-coverage.md` declares a SAST tool, the tool is named from a documented recommended-set | Asserted-only | Enforced (when module active) | Sweep §11 Rec 1 |
| C-SAST-S3 | When a consumer's `sast-coverage.md` is present, it declares which paths are scanned | Asserted-only | Enforced (when module active) | Sweep §11 Rec 1 + OPP-0035 Q2 |
| C-SAST-S4 | When a consumer's `sast-coverage.md` is present, it declares a severity threshold that gates CI | Asserted-only | Enforced (when module active) | OPP-0035 Q2 |

**Claims explicitly NOT converted by v1** (remain Asserted-only after
this PRD ships):

- **SAST tools are actually configured in consumer CI and run on
  every PR.** v1 validates the *declaration* in `sast-coverage.md`
  but cannot verify the consumer's CI workflow file actually wires
  the declared tool. Out of scope: cross-validating
  `sast-coverage.md` against `.github/workflows/*.yml` content is a
  v2 concern.
- **SAST findings above threshold actually fail CI.** v1 validates
  the consumer *declared* a threshold; it does not verify the
  threshold is wired to a CI failure gate. Same v2 cross-validation
  scope.
- **The recommended-set tools are themselves not vulnerable.** v1
  does not pin tool versions or scan tool-vendor advisories.
- **Sweep §11 underhanded code is structurally prevented.** v1
  enables consumers to opt into SAST coverage as a posture; it does
  not prevent the underhanded-code-output failure mode at the
  framework layer. That requires either (a) actual SAST tool runs
  (consumer responsibility) or (b) runtime agent-output filtering
  (a separate, much harder problem).

**Half-enforced after v1** (deliberate partial coverage):

- C-SAST-S1 is Half-enforced because the harness provides the
  *opt-in scaffolding*, but enforcement of the *actual SAST run*
  happens in consumer CI. This is the same shape as
  `management/eval-gated-testing` (the harness validates the
  eval-strategy.md exists and is well-formed; running the evals is
  consumer CI). Documented as half-enforced rather than fully
  enforced because the harness alone cannot guarantee the consumer's
  CI honors what `sast-coverage.md` declares.

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Harness maintainer | The repo's primary owner | A real, mechanized closure path for the largest mission-relative gap in the safety sweep (§11). |
| Consumer-project maintainer | A team adopting auto-harness for an AI agent project | A documented, opt-in path to add SAST coverage as a quality gate; clear tool-selection guidance per stack; the harness validating the contract exists without micromanaging the tool choice. |
| Harness contributor | Outside contributor PR-modifying the SAST module | A clear module spec mirroring `management/eval-gated-testing` so the precedent is unsurprising. |
| Security reviewer | External audit, red-team exercise | A documented module that names SAST as a first-class concern of the framework, with a structural validator backing the declaration. |

## User Stories

- As a **consumer-project maintainer**, I want to activate
  `management/security-static-analysis` in my manifest and have the
  harness validate that my `docs/security/sast-coverage.md` is
  well-formed (names a recommended tool, lists scan paths, declares
  a severity threshold), so that the contract is reviewable and
  agent contributors can't silently weaken the SAST posture.
- As a **consumer-project maintainer**, I want clear "pick one"
  guidance on SAST tool selection per stack, so that activating the
  module does not require independent research on Semgrep vs CodeQL
  vs Bandit selection criteria.
- As a **harness maintainer**, I want
  `validate-sast-coverage.sh` to be a no-op pass on the harness
  itself (since the harness does not activate the module), so that
  Wave 5.4 ships without harness-side fixing churn.
- As a **harness contributor**, I want the new module to follow the
  same shape as `management/eval-gated-testing` (sibling precedent)
  so the catalog stays internally consistent and no new module
  archetype is invented for SAST specifically.
- As a **security reviewer**, I want the harness's catalog to name
  SAST coverage as a structurally adoptable concern of any consumer
  project, so the framework's overall safety posture is auditable.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | Module scaffolding ships at `platform/profiles/management/security-static-analysis/` | `module.yaml` and `README.md` present; `module.yaml` declares `type: management`, `dependsOn: [kernel/base]`, `conflictsWith: []`, `requiredArtifacts: [docs/security/sast-coverage.md]`, sensitive-paths, companion rules, review gates, `agentAdapters: [platform/agents/base]`, `recommendedSkills` including `harness-governance`. | Sibling shape to `management/eval-gated-testing`. |
| FR-002 | Required artifact template ships at `platform/templates/security/sast-coverage.md` | Tokenized header per `feedback-attribution` (`UncleNate@gmail.com`) + SPDX dual-license. Sections: declared tool, scan paths, severity threshold, finding-triage policy. | Template-generation parity with `eval-strategy.md`. |
| FR-003 | `validate-sast-coverage.sh` validator ships at `platform/validators/validate-sast-coverage.sh` | Bash 3.2 compatible, shellcheck-clean at warning severity, 3-state exit (0 pass / 1 violation / 2 usage). When `management/security-static-analysis` is not active in the manifest: exit 0 with a "module inactive, skipping" message on stderr. When active: read `docs/security/sast-coverage.md`; assert it declares a `tool:` named from the recommended-set, at least one `scanPaths:` entry, and a `severityThreshold:` value; per-field surfacing on failure. | Active-module detection via `HarnessRegistry.active_modules` (same library Wave 5.1 + 5.3 + 5.2 use). |
| FR-004 | The recommended-set is declared as a Ruby constant in the validator | Inline Ruby constant `RECOMMENDED_TOOLS = %w[semgrep codeql bandit gosec eslint-plugin-security snyk-code].freeze`. Comment cites `platform/profiles/management/security-static-analysis/README.md` as the source-of-truth document. Validator's `--help` enumerates the set. | Append-only: new tools added in PRs that also update the README. |
| FR-005 | Sensitive paths declared on the module cover the artifact + common SAST-config locations | `^docs/security/sast-coverage\.md$`, `\.semgrep\.yml$`, `\.codeql\.yml$`, `\.bandit$`, `\.gosec\.yml$`, `\.eslintrc.*$` (security-rule-affecting only — companion rule scopes). | `validate-sensitive-paths.sh` keeps passing because the new sensitivePaths overlap an active trigger-paths set. |
| FR-006 | Companion rule binds guarded-source-path changes to a SAST evidence trail | `triggerPaths` default to `^src/`, `^lib/`, `^app/`. `requiredAny`: updated `docs/security/sast-coverage.md` (consumer narrating the scope shift) OR a SAST report attachment under `docs/security/sast-reports/`. `humanReview` text instructs reviewers to verify the SAST report covers the changed paths and the severity gate held. | Reuses `validate-companions.sh`; no new companion-validator code. |
| FR-007 | Review gates declared on the module | Three gates: (a) the artifact names a tool from the recommended-set with a stated rationale for the choice; (b) the declared scan paths cover the project's primary source root; (c) the severity threshold is documented and reviewers verify it is not silently lowered. | Mirror shape of `management/eval-gated-testing` review-gate set. |
| FR-008 | Validator wired into harness CI, consumer CI templates, AGENTS.md run-order, harness-governance SKILL.md, validators/README.md, root README.md tables and mermaid box | `validate-sast-coverage.sh` appears in the same documentation surfaces every prior validator was wired into. `validate-catalog-counts.sh` ASSERTIONS validator-count entries bump 13 → 14 at the 7 documented sites. Module catalog count bumps where applicable. | Standard Wave-style propagation. |
| FR-009 | The new module is reachable from the `harness-onboarding` skill catalog | `platform/skills/harness-onboarding/SKILL.md` Management catalog gains a row for the new module; `platform/workflow/discovery-to-composition.md` Step 6 rubric gains a corresponding row. | Discovery-to-composition completeness. |
| FR-010 | The validator's own authored prose (its `--help`, its inline comment block) does not trigger `validate-skill-content.sh` | Adversarial-pattern absence verified by the dogfood run of the Wave 5.2 validator on the new file. | Meta-§10 application: the new validator's own surface gets scanned by sibling validators. |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-S01 | Validator output includes a per-stack tool recommendation hint when an unrecognized tool is declared | When `sast-coverage.md` declares a `tool:` not in the recommended-set, stderr lists the recommended-set with a "→ pick one of the following, or file a PR to add yours" hint. | Improves contributor friction. Not blocking for v1. |
| FR-S02 | Performance: scan completes in < 1s on the harness's own (module-inactive) run, and < 2s on a consumer activation | Measured during implementation. Inactive run is no-op so should be near-instant. | Per OPP-0035 sequencing concern. |
| FR-S03 | `--scan-file <path>` test-seam mode per `feedback-validator-test-seam-pattern` | Direct-content-test mode bypasses active-module gating and validates an arbitrary `sast-coverage.md`-shaped file. Enables fixture-firing tests. | Adopt the test-seam pattern proactively per the thrice-evidenced precedent. |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| Running SAST tools from the harness CLI | OPP-0020 (parent OPP) is the named home for harness-toolchain eval/safety tool invocation | When OPP-0020 reaches PRD pass and includes SAST adapters |
| Inspecting SAST report content (finding severity / rule IDs / line numbers) | v1 validates the contract exists; the consumer's CI gates on report content | v2 if a consumer surfaces a specific cross-validation need (e.g., "report claims threshold pass but PR shipped a critical finding") |
| Cross-validating `sast-coverage.md` against the consumer's CI workflow file content | Workflow-file parsing is YAML-shaped per-CI-vendor and scope-explodes the validator | v2 if the rate of consumers declaring a tool in `sast-coverage.md` but not wiring it in CI proves non-trivial |
| Tool-version pinning / vendor-advisory scanning of the recommended-set | v1 treats the recommended-set as a soft recommendation surface | v2 if a recommended tool ships a known-CVE release |
| Agent self-review reviewGate on `agents/base/module.yaml` | Distinct surface per OPP-0035 Risk 5; file separately under OPP-0031 if pursued | After v1 lands and the SAST-coverage posture is stable |
| Secrets-scanning artifact alignment | GitHub-repo-level concern per OPP-0035 Risk 4 | Out-of-scope for this module's lifetime |

## Implementation Deferral

Per operating principle § 9, a PRD whose natural scope would bundle
design work with the machinery that enforces it should ship the
design at v1 and defer the enforcement to a follow-up. This PRD is
the design pass; the implementing PR adds the module + template +
validator + propagation.

| Deferred implementation | Deferred to | Why deferred |
|-------------------------|-------------|--------------|
| Runtime SAST tool invocation from harness toolchain | OPP-0020 PRD pass | The parent OPP names this as its scope; v1 of this PRD ships consumer-posture only |
| Cross-validation of `sast-coverage.md` against CI workflow file content | v2 follow-up OPP iff consumer feedback surfaces the divergence as a non-trivial failure mode | YAML-per-CI-vendor scope-explodes the validator |
| SAST-report content inspection (severity / rule-id / line-number assertions) | v2 follow-up | Out-of-scope per OPP-0035 Q2 Bias: artifact-and-CI-do-enforcement, not validator-inspects-report-content |
| Agent self-review reviewGate | Separate OPP under OPP-0031 (defense-in-depth) iff pursued | Distinct surface per OPP-0035 Risk 5 |
| Tool-version pinning / vendor-advisory tracking | v2 follow-up iff a recommended tool ships a known-CVE release | Soft-recommendation surface in v1 |

What v1 *does* commit to (the contract that must hold before any
follow-up is built):

- The module scaffolding (`module.yaml`, `README.md`) as specified
  in FR-001.
- The required-artifact template (`sast-coverage.md`) as specified
  in FR-002.
- The validator (`validate-sast-coverage.sh`) with the 3-state exit
  contract, the recommended-set check, the `scanPaths:` check, and
  the `severityThreshold:` check as specified in FR-003–FR-004.
- The sensitive-paths, companion rule, and review gates as specified
  in FR-005–FR-007.
- Full propagation to the documented harness surfaces per FR-008–FR-009.
- The `--scan-file` test-seam mode per FR-S03 (Should Have but
  recommended for proactive test-seam adoption).
- Predict-clean absorption mechanism: the harness's own CI run is
  no-op pass; the validator only does substantive work when a
  consumer activates the module.

## Technical Constraints

- **Bash 3.2 compatibility** — macOS default. Test on `bash --version`
  ≤ 3.2.
- **Shellcheck clean at warning severity** — `shellcheck -S warning`.
- **3-state exit contract** — 0 pass / 1 violation / 2 usage error.
- **Ruby for content scanning** — same pattern as `validate-trust-tier.sh`,
  `validate-sensitive-paths.sh`, `validate-skill-content.sh`. Inline
  Ruby via `ruby -e`.
- **No new runtime dependencies** — only Bash + system Ruby (already
  in CI environment per established pattern).
- **YAML parsing for `sast-coverage.md` frontmatter** — the artifact
  has a YAML frontmatter block declaring `tool:`, `scanPaths:`,
  `severityThreshold:`. The validator parses the frontmatter via the
  same Ruby `YAML.safe_load` approach used by `harness_registry.rb`.
- **v1 recommended-set** (codified here so the PRD is the canonical
  source):
  1. `semgrep` (polyglot, OSS, CI-friendly)
  2. `codeql` (GitHub-native, deep semantic analysis)
  3. `bandit` (Python-specific)
  4. `gosec` (Go-specific)
  5. `eslint-plugin-security` (JavaScript/TypeScript)
  6. `snyk-code` (commercial, polyglot)
- **Active-module detection** — `HarnessRegistry.active_modules`
  returns the activated module set from the manifest; the validator
  checks for `management/security-static-analysis` membership before
  doing artifact-content work.
- **Performance budget** — < 1s scan on the harness's own
  (module-inactive) run; < 2s on a consumer activation.

## CI/CD Gates

| Gate | Required? | Notes |
|------|-----------|-------|
| Lint passes (markdownlint, shellcheck) | Yes | This PRD's body passes markdownlint; the implementing validator passes shellcheck |
| Test coverage threshold | Yes (functional) | Fixture-based tests via `--scan-file` mode covering: (a) module-inactive no-op pass, (b) well-formed artifact pass, (c) missing tool: hit, (d) tool not in recommended-set hit, (e) missing scanPaths: hit, (f) missing severityThreshold: hit |
| Required tests added | Yes | `platform/validators/test/test_validators_integration.rb` gains a `TestValidateSastCoverage` class |
| Validator chain passes | Yes | The new validator joins the chain; chain itself stays green |
| Companion-rule check passes | Yes | `validate-companions.sh` passes; the new module's `sensitivePaths` overlap an active trigger |
| Change-log updated | Yes | This PR + the implementing PR each get an entry |

## Success Metrics

| KPI | Target | How measured |
|-----|--------|-------------|
| Dogfood pass rate at PR 1 | 100% — harness's own CI run passes (module-inactive no-op path) | Implementing PR's CI run |
| Fixture coverage | 100% — each Must-Have FR-003 assertion has ≥ 1 fixture, each fixture exercises the expected exit | Implementing PR's test suite |
| Validator scan time | < 1s harness; < 2s consumer | Measured + logged in change-log |
| Module catalog reachability | The new module is reachable from `harness-onboarding/SKILL.md` Management catalog and `discovery-to-composition.md` Step 6 rubric | Spot-check post-merge |
| Recommended-set adoption | 0 false-positives in first 30 days (no legitimate consumer using a tool the validator wrongly rejects) | Tracked via maintainer triage; if > 0, append to recommended-set or refine the regex |

## Dependencies

- `platform/validators/lib/harness_registry.rb` — module enumeration
  (same library Wave 5.1 + 5.2 + 5.3 use).
- `platform/profiles/management/eval-gated-testing/` — sibling-module
  precedent for opt-in management overlay shape.
- Bash 3.2 + system Ruby (already in CI environment).
- No new gems, no new package manifests.

## Open Questions

- [ ] **Should the validator also check that the consumer's CI
  workflow file (`.github/workflows/*.yml`) actually invokes the
  declared tool?** **Bias: no — out of scope for v1** per Non-Goals.
  The cross-validation is YAML-per-CI-vendor and scope-explodes the
  validator. v1 validates the *declaration*; the consumer's CI
  honors it. Revisit if consumer feedback surfaces the divergence
  as a non-trivial failure mode.
- [ ] **Should `sast-coverage.md` use YAML frontmatter or a code-block
  syntax for the declared `tool:` / `scanPaths:` / `severityThreshold:`?**
  **Bias: YAML frontmatter** for consistency with other tokenized
  templates (`eval-strategy.md` template uses a similar pattern).
  The implementing PR finalizes this with the template.
- [ ] **Should the recommended-set entry for `snyk-code` (commercial)
  be excluded?** **Bias: no** — list it explicitly so consumers
  using Snyk Code are not surprised by a hit, but mark it
  "commercial" in the README's per-stack guidance so consumers
  preferring OSS see the OSS-only alternatives. v1 README enumerates
  license per tool.
- [ ] **Should the companion rule's default `triggerPaths` include
  `cmd/`, `internal/`, `pkg/` for Go projects?** **Bias: no — keep
  v1 default tight (`src/`, `lib/`, `app/`)**; consumers customize
  by overriding the module's companion rule in their own
  `module.yaml` extension or via per-project trigger-path
  declarations. Broadening to language-specific defaults is a v2
  decision once consumer-project diversity surfaces concrete
  patterns.

These open questions are *implementation-level*, not *design-level*.
The PRD commits to the FR-001 module scaffolding, the FR-002 template
shape, the FR-003 validator contract, the FR-004 recommended-set
seed, the FR-005 sensitive-paths set, the FR-006 companion rule, and
the FR-007 review gates. The implementing PR may resolve the above
via stated Bias positions; if the implementation surfaces design-level
questions the PRD elides, record them in the implementing PR's
"Implementation Reconciliation" section per the Wave 5.1 / 5.2
precedent.

## Acceptance Criteria for OPP-0035 → `accepted`

1. This PRD `Accepted`.
2. FR-001…FR-010 merged.
3. Full validator chain green on the PR.
4. Module reachable from the `harness-onboarding` skill catalog and
   named as a sibling to `management/eval-gated-testing` in the
   `discovery-to-composition` Step 6 rubric.
5. The harness's own CI run exercises the validator's
   module-inactive path (no false fixings on the dogfood pass).

## Versioning Implications

Module ships at `1.0.0`. Validator-count and module-count bumps land
within the v0.6.x batch. Release marker: **v0.6.0** if Wave 5.4 closes
out the sprint's safety hardening track, otherwise **v0.5.4**.
