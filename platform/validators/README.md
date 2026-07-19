<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Validators

Shell scripts and a shared Ruby library that enforce the harness governance contract.
Run locally during development and in CI on every pull request.

---

## Requirements

- **Ruby 3.0+** — all validators use inline Ruby for YAML parsing and logic
- **ripgrep (`rg`)** — required by `validate-placeholders.sh` only; other validators work without it
- **Bash** — the twenty-five `validate-*.sh` scripts delegate to Ruby and work with Bash 3.2 (macOS default) and 4+. The bootstrap scripts (`install.sh`, `link-skills.sh`, `add-license-headers.sh`) require Bash 4+ (use `declare -A` and other 4+ features); macOS users must `brew install bash` for those.

---

## Validator Scripts

Run from the repository root. Every script honors a uniform `--help` / `-h` flag
and a uniform three-state exit-code contract (see [Exit-code contract](#exit-code-contract)
below).

| Script | Arguments | What It Checks |
| ------ | --------- | -------------- |
| `validate-manifest.sh` | `<manifest>` | Schema version, required project fields, valid module categories, overrides structure |
| `validate-module-graph.sh` | `<manifest>` | Module existence on disk, dependency chains satisfied, conflict detection, category/type match |
| `validate-required-artifacts.sh` | `<manifest> <project-root>` | Every `requiredArtifact` declared by active modules exists on disk |
| `validate-placeholders.sh` | `<project-root>` | No unfilled `[[PLACEHOLDER]]` or `YYYY-MM-DD` tokens in project files; respects `.placeholder-ignore` exclusions (requires ripgrep) |
| `validate-agent-pack.sh` | `<manifest> <project-root>` | Agent modules declare adapters and compiled fragments; all referenced files must exist |
| `validate-companions.sh` | `<manifest> <project-root> <base-branch>` | PR diff satisfies all active companion rules — including `forbiddenPatterns` hard fails (requires git context) |
| `validate-doc-references.sh` | `<project-root>` | **v2 (renderer-aware):** every markdown link `[text](target)` with a relative target resolves on disk *and* renders safely (no trailing-slash / bare-extensionless GitBook breakage). Skips fenced blocks *and* inline backtick code spans. Preserves v1's `platform/...` bare-path extractor as a second pass. Respects `.doc-reference-ignore` |
| `validate-catalog-counts.sh` | `[<project-root>]` | Documented catalog-count claims (e.g., "8 validators", "35 modules") match canonical recipe-computed values across every asserted call site (entry-point prose, ASCII art, Mermaid diagrams, back-cover SVG) — closes the count-drift class |
| `validate-list-completeness.sh` | `[<project-root>]` | For every ADR / PRD / OPP / composition / template subdirectory / profile module / agent module on disk, asserts the matching row exists in its canonical index file (docs/README.md, candidates.md, compositions/README.md, templates/README.md, SUMMARY.md) — closes the list-completeness drift class |
| `validate-status-parity.sh` | `[<project-root>]` | Always-on: for every `docs/opportunities/OPP-NNNN-*.md` record, asserts its canonical `Status` token equals the status token in each derived surface — the `candidates.md` `*(…)*` annotation and the `docs/README.md` opportunities-table status column. Entries are anchored on the exact OPP-id + filename (never a prose mention); a matched entry with no status token normalizes to implicit `proposed`. Leading-token equality only. The row-*status* sibling of `validate-catalog-counts.sh` (counts) and `validate-list-completeness.sh` (presence) — closes the status-drift class. PRD-0036 / OPP-0054 |
| `validate-trust-tier.sh` | `[<manifest>] [<project-root>]` | For each active module, validates the optional `tier.declared` field (range 0–5; rationale required for ≥3); computes the inferred tier from `sensitivePaths` regex patterns against representative production-shape sample paths (highest match wins); asserts declared ≥ inferred. For agent modules, validates `maxTier` and asserts it ≥ the max active non-agent tier. Cross-cutting: declared tier 5 requires `project.criticality` ∈ {high, critical}, unless `project.maturity == platform`. PRD-0006 / ADR-0017 Wave 5.1 |
| `validate-sensitive-paths.sh` | `[<manifest>] [<project-root>]` | Across all active modules, asserts every `sensitivePaths` regex pattern is overlapped by at least one `companionRules.triggerPaths` regex on some active module. Uses a pragmatic 3-tier overlap check (literal equality, trigger contains sensitive as substring, or sensitive contains trigger as substring). Cross-module overlap is allowed. Closes the doc-code-alignment gap where `sensitivePaths` was sold-as-policy but never-checked-in-code (safety-security-sweep §2 claim 12 → Enforced). OPP-0034 / ADR-0017 Wave 5.3 |
| `validate-skill-content.sh` | `[--verbose] [<manifest>] [<project-root>]` (or `--scan-file <path>`) | Across active modules, scans authored prose (`module.yaml` description / summary / reviewGates / companionRules.humanReview + SKILL.md bodies via `recommendedSkills` + `compiledFragments` markdown) against a built-in denylist of prompt-injection patterns (e.g., "ignore previous instructions"), tier-bypass phrasings (e.g., "always operates at Tier"), role-prompt headers (`^System:`/`^User:`/`^Assistant:`), zero-width characters, and Unicode bidi marks. Lines matching `.skill-content-ignore` regex patterns are exempted. **Default posture: BLOCK** — hard-fails on any unexempted hit (predict-clean absorption per PRD-0015 FR-003). `--scan-file <path>` provides direct content scanning for ad-hoc fixture checks. Closes safety-security-sweep §3 red-team vectors V1, V2, V4 (partial), V6. PRD-0015 / OPP-0033 / ADR-0017 Wave 5.2 |
| `validate-knowledge-redaction.sh` | `[--block] [<project-root>] [<base-branch>]` | Diff-based scan of new lines added to `docs/knowledge/shared-observations.md` and `docs/operating-principles.md` against a built-in denylist of consumer-name patterns (Tula, OpenEMR, YouBase, municipal-brain, toast-mcp). Lines matching `.knowledge-redaction-ignore` patterns are exempted. **Default posture: WARN** — surfaces hits on stderr but exits 0 (reviewers eyeball in CI logs). `--block` escalates hits to exit 1 (v2 posture per OPP-0036). Closes safety-security-sweep §8 (cross-pollination) + §9 (upstream-propagation pathways). OPP-0036 / ADR-0017 Wave 5.5 |
| `validate-observation-hygiene.sh` | `[<manifest>] [<project-root>] [<base-branch>]` (or `--scan-file <path>`) | Diff-based ADR-0002 shape linter for `docs/knowledge/shared-observations.md`. Module-gated on `management/knowledge-capture` (inactive → exit 0 skip; the harness activates it, so its own CI runs **live/dogfood**, not predict-clean). Lints each observation whose `###` heading was **added** vs. the base branch: six fields present (`Context` / `Observation` / `Implication` / `Confidence` / `Severity` / `Contributed by`), `Confidence` ∈ `{low, medium, high}`, `Severity` ∈ `{informational, governance-relevant, architectural, risk-bearing}` (**enforce-as-locked** per PRD-0034 §10 — off-enum values fail), `Contributed by` name + ISO date. **Grandfathers history** — only diff-added records are linted; outside a git tree / base absent → exit 0. Presence + enum membership only, never semantic quality. The knowledge-ledger instance of the *structured-agent-ledger gate* (stigmergy.md §4); `--scan-file` lints every record for fixtures. PRD-0034 / OPP-0053; schema ADR-0002 |
| `validate-sast-coverage.sh` | `[<manifest>] [<project-root>]` (or `--scan-file <path>`) | Opt-in validator for the `management/security-static-analysis` overlay. When the module is not active, exits 0 with a "module inactive" message — the harness itself does not activate the module, so its own CI run is a no-op pass (predict-clean absorption per PRD-0016 FR-003). When the module is active, reads `docs/security/sast-coverage.md`, parses YAML frontmatter, and asserts `tool:` is from the recommended set (`semgrep` / `codeql` / `bandit` / `gosec` / `eslint-plugin-security` / `snyk-code`), `scanPaths:` is a non-empty list, `severityThreshold:` is a non-empty string. `--scan-file <path>` provides direct content scanning for fixture tests and ad-hoc validation. Half-enforces safety-security-sweep §11 (the largest mission-relative gap in the sweep) — the harness validates the contract; consumer CI honors it for end-to-end enforcement. PRD-0016 / OPP-0035 / ADR-0017 Wave 5.4 |
| `validate-trace-contract.sh` | `[<manifest>] [<project-root>]` (or `--scan-file <path>`) | Opt-in validator for the OpenTelemetry multi-agent trace contract. Activates when **any active module requires `docs/observability/trace-contract.md`** (`architectures/agent-observability`, which owns it, or `architectures/ai-foundry-target`, which reuses it via the deferred-dependency model); when none does, exits 0 with a "skipping" message (predict-clean — the harness activates neither). When active, parses the artifact's YAML frontmatter and asserts `semconv_version:` is a non-empty pin, `spans:` declares at least one conventional GenAI operation (`chat` / `invoke_agent` / `execute_tool` / `create_agent` / `embeddings` / `invoke_workflow`), and `content_capture:` is one of `{opt-in, none}`. Presence + shape only — the artifact-content half of the frontier-agent cluster's v2 enforcement; the code-cross-reference half (declared spans match emitted telemetry) stays deferred. `--scan-file <path>` for fixture tests. PRD-0031 / OPP-0051 / OPP-0027 |
| `validate-foundry-target.sh` | `[<manifest>] [<project-root>]` (or `--scan-file <path>`) | Opt-in content validator (OPP-0051 phase 2). Activates when any active module requires `docs/architecture/foundry-targets.md` (`architectures/ai-foundry-target`); predict-clean otherwise. Asserts the `foundries:` frontmatter is a non-empty list, each entry an `id` from the enum (`azure-ai-foundry` / `nvidia-ai-foundry` / `palantir-aip` / `aws-bedrock-agentcore` / `google-vertex-agent-engine` / `custom`) with a `status` of `{live, roadmap}`. Presence + shape only. `--scan-file` for fixtures. PRD-0032 / OPP-0051 |
| `validate-model-routing.sh` | `[<manifest>] [<project-root>]` (or `--scan-file <path>`) | Opt-in content validator (OPP-0051 phase 3). Activates when any active module requires `docs/architecture/model-routing.md` (`architectures/intelligent-model-routing`); predict-clean otherwise. Asserts the `routes:` frontmatter is a non-empty list, each entry a non-empty `task` + `model`. Providers are free-form — no provider-enum check. Presence + shape only. `--scan-file` for fixtures. PRD-0032 / OPP-0051 |
| `validate-agent-defense-in-depth.sh` | `[<manifest>] [<project-root>]` (or `--scan-file <path>`) | Opt-in content validator (OPP-0051 phase 4). Activates when any active module requires `docs/security/agent-defense-in-depth.md` (`architectures/agent-defense-in-depth`); predict-clean otherwise. Asserts the `patterns:` frontmatter names all four (`scope-containment`, `least-permissions`, `human-in-the-loop`, `agent-identity`). Presence + shape only. `--scan-file` for fixtures. PRD-0032 / OPP-0051 |
| `validate-privacy-by-design.sh` | `[--block] [<manifest>] [<project-root>]` (or `--scan-file <path>`) | Opt-in validator for the `management/privacy-by-design` overlay. When the module is not active, exits 0 (module-gated no-op). When active, validates the privacy-profile presence/consistency (FAIL layer) and WARN-surfaces privacy-risk patterns; `--block` escalates WARN hits to a non-zero exit. PRD-0018 / §11 |
| `validate-twin-profile.sh` | `[--block] [<manifest>] [<project-root>]` (or `--scan-file <path>`) | Opt-in validator for the `management/digital-twin` overlay. When the module is not active, exits 0. When active, parses `docs/twin/twin-profile.md` frontmatter and asserts `maturity` / `conformance` / `governingPrinciples` are populated and no emerging standard (ISO 23247-5/-6, ISO/IEC 30188) is marked `published`. Advisory WARN (exit 0); `--block` escalates. PRD-0023 / ADR-0019 |
| `validate-scenario-manifest.sh` | `[--block] [<manifest>] [<project-root>]` (or `--scan-file <path>`) | Opt-in validator for the `management/digital-twin` overlay. When the module is not active, exits 0. When active, scans scenario manifests for the required epistemic-discipline sections (`scenario` / `datasets` / `assumptions` / `outputs` / `uncertainty` / `provenance`), per-dataset `source`+`version`+`asOf`+`confidence`, per-assumption `sensitivity`, and publication-approval gating. Advisory WARN (exit 0); `--block` escalates. PRD-0023 / ADR-0019 |
| `validate-lane-integrity.sh` | `[<manifest>] [<project-root>] [<base-branch>]` (or `--scan-file <lane-spec> [<changed-path>...]`) | Opt-in validator for the `management/work-package` overlay. When the module is not active, exits 0 (predict-clean). When active, parses the fenced `lane` block in `docs/work-package/lane.md`, asserts the schema is well-formed (`branch` / `base` / `prMode` / non-empty `allowedFiles`), then diffs the branch against `base` and fails if any changed file is outside `allowedFiles` or touches `readOnlyFiles`. PRD-0025 |
| `validate-publication-boundary.sh` | `[<project-root>]`, `--staged [<project-root>]`, or `--scan-file <path>...` | **Always-on** (not module-gated). Fails (exit 1) if any git-tracked file declares a `do-not-publish` marker (frontmatter key or `<!-- do-not-publish: true -->` sentinel, matched only at line start). A marker in an *untracked* file is invisible to `git ls-files` and passes — the intended steady state. Path regexes in `.publication-boundary-ignore` exempt files that discuss the marker. `--staged` scans staged files (pre-commit); `--scan-file` is a no-git test seam. Outside a git tree exits 0. PRD-0026 / OPP-0048 |
| `validate-module-stability.sh` | `[<project-root>]` or `--scan-file <module.yaml>` | **Always-on** structural check (not module-gated). Asserts every `module.yaml` under `platform/` declares `stability:` ∈ `{experimental, beta, stable}` — presence + enum only, never the correctness of the judgment. A third axis, independent of trust tier (*risk*) and § 10 (*per-claim enforcement*): how proven the module is. Rubric is authoring guidance in `extending-the-harness.md` + `--help`. PRD-0027 / OPP-0050 |

### `--help` / `-h`

Every validator accepts `--help` or `-h` as the first argument and prints a usage
block (purpose, arguments, an example, the exit-code contract) before exiting 0
without invoking Ruby. The same convention is followed by
[`platform/bootstrap/install.sh`](../bootstrap/install.sh),
[`platform/bootstrap/link-skills.sh`](../bootstrap/link-skills.sh), and
[`platform/bootstrap/add-license-headers.sh`](../bootstrap/add-license-headers.sh).

```bash
bash platform/validators/validate-manifest.sh --help
bash platform/validators/validate-companions.sh -h
```

### Exit-code contract

Every validator follows the same three-state contract — the same convention the
bootstrap scripts adopted in PR #12:

| Code | Meaning | When it applies |
| ---- | ------- | --------------- |
| `0` | **Pass** | Validation passed, or the validator was disabled via `overrides.disabledValidations`, or `--help` was requested. |
| `1` | **Violation** | The script ran fully and found a real governance issue (missing artifact, broken module graph, forbidden-path hit, etc.). |
| `2` | **Usage error** | The script could not run at all: missing/unreadable/malformed manifest, missing module definition on disk, missing dependency (e.g., `rg` not installed), missing `platform/` directory. |

Malformed manifests produce a typed `✗ <message>` line on stderr followed by
exit 2 — never a raw Ruby `NoMethodError` or `Psych::SyntaxError` stack trace.

### Recommended run order

```bash
bash platform/validators/validate-manifest.sh harness.manifest.yaml
bash platform/validators/validate-module-graph.sh harness.manifest.yaml
bash platform/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash platform/validators/validate-placeholders.sh .
bash platform/validators/validate-agent-pack.sh harness.manifest.yaml .
bash platform/validators/validate-doc-references.sh .
bash platform/validators/validate-catalog-counts.sh .
bash platform/validators/validate-list-completeness.sh .
bash platform/validators/validate-status-parity.sh .
bash platform/validators/validate-trust-tier.sh harness.manifest.yaml .
bash platform/validators/validate-sensitive-paths.sh harness.manifest.yaml .
bash platform/validators/validate-skill-content.sh harness.manifest.yaml .
bash platform/validators/validate-knowledge-redaction.sh . main
bash platform/validators/validate-observation-hygiene.sh harness.manifest.yaml . main
bash platform/validators/validate-sast-coverage.sh harness.manifest.yaml .
bash platform/validators/validate-trace-contract.sh harness.manifest.yaml .
bash platform/validators/validate-foundry-target.sh harness.manifest.yaml .
bash platform/validators/validate-model-routing.sh harness.manifest.yaml .
bash platform/validators/validate-agent-defense-in-depth.sh harness.manifest.yaml .
bash platform/validators/validate-publication-boundary.sh .
bash platform/validators/validate-module-stability.sh .
# Companion rules — only meaningful when comparing branches:
bash platform/validators/validate-companions.sh harness.manifest.yaml . main
```

### Disabled validations

Any validator can be skipped by adding its name to `overrides.disabledValidations` in the
manifest. The `validate-required-artifacts.sh` script checks for `required-artifacts`;
`validate-agent-pack.sh` checks for `agent-pack`. This is how brownfield projects start
with enforcement off and progressively re-enable it.

---

## Shared Library

**`lib/harness_registry.rb`** — Ruby module used by validators and tests. Key methods:

| Method | Purpose |
| ------ | ------- |
| `load_manifest(path)` | Parse + shape-check a YAML manifest. Returns the parsed Hash, or raises `HarnessRegistry::ManifestShapeError` on missing/unreadable/malformed input or a non-mapping top level. Validators rescue this and exit 2. |
| `active_refs(manifest)` | Return `[category, ref]` pairs for all declared modules |
| `active_modules(platform_root, manifest)` | Load and return `module.yaml` data for every active module |
| `required_artifacts(modules, manifest)` | Aggregate and deduplicate required artifacts across modules + overrides |
| `resolve_module_path(platform_root, category, ref)` | Map a module reference to its `module.yaml` path on disk |
| `disabled_validation?(manifest, name)` | Check if a validation is in the disabled list |
| `patterns_match?(patterns, path)` | Test a file path against an array of regex patterns (used by companion rules) |
| `changed_files(project_root, base_branch)` | Get the list of changed files via `git diff` against a base branch |
| `first_forbidden_match(patterns, path)` | Returns `[pattern, path]` for the first forbidden-pattern match, or `nil`. Used by `validate-companions.sh` to enforce hard-fail `forbiddenPatterns` on companion rules |
| `extract_doc_references(markdown)` | **v1:** Extracts every `platform/...` path reference from a Markdown string, skipping fenced code blocks. Returns `[{path:, line:}, ...]` |
| `doc_reference_resolves?(path, project_root)` | True iff the referenced path exists on disk under the project root |
| `doc_reference_ignored?(path, patterns)` | True iff `path` matches any regex pattern in the `.doc-reference-ignore` list |
| `load_doc_reference_ignore(path)` | Read a `.doc-reference-ignore` file (one regex per line; `#` comments allowed); returns `[]` when missing |
| `extract_markdown_links(markdown)` | **v2:** Extracts every `[text](target)` link, skipping fenced blocks, inline backtick code spans, and external schemes (`http(s)://`, `mailto:`, `tel:`, `#anchor`, `<autolink>`, `{{template}}`). Returns `[{target:, line:}, ...]` |
| `strip_inline_code_spans(line)` | **v2:** Replace inline backtick `...` runs with same-length space-padding so column offsets stay monotonic. Prevents false-positive flagging of pedagogical link syntax shown as inline code |
| `link_target_external?(target)` | **v2:** True if the target is an external scheme, anchor, autolink, template placeholder, or empty — i.e. must never be checked on disk |
| `strip_link_anchor(target)` | **v2:** Strip `#anchor` and `?query` from a link target; what remains is the on-disk path candidate |
| `resolve_relative_link(target, md_file_dir, project_root)` | **v2:** Resolve a relative link target against the markdown file's directory; returns the project-root-relative path or `nil` if the target escapes the project root |
| `link_target_classify(target, resolved_rel_path, project_root)` | **v2:** Classify a link as `:ok`, `:missing` (broken), `:directory_target` (renderer-fragile trailing slash or resolves to directory), or `:extensionless` (renderer-fragile bare basename like `LICENSE-MIT`) |
| `link_target_renderer_safe?(target, resolved_rel_path, project_root)` | **v2:** Convenience boolean — true iff `link_target_classify` returns `:ok` |
| `markdown_files_to_scan(project_root, extra_exclude_prefixes=[])` | **v2:** Enumerate every `*.md` under project_root, honoring `DEFAULT_SCAN_EXCLUDE_PREFIXES` (`legacy/`, `.git/`, `.claude/`, `node_modules/`, `.worktrees/`, `platform/validators/test/fixtures/`, `platform/templates/docs/`) plus any caller-supplied extras |

---

## Test Suite

Two test files using Ruby Minitest (stdlib, no gem install required).

### Unit tests

**`test/test_harness_registry.rb`** — unit tests covering `HarnessRegistry` methods:

- `patterns_match?` — single/multiple patterns, anchors, nil/empty, special characters
- `disabled_validation?` — present, absent, missing key, multiple entries
- `required_artifacts` — aggregation, deduplication, manifest overrides, nil handling
- Companion rule logic — inline simulation of the trigger/required-any loop from
  `validate-companions.sh` with controlled `changed_files` arrays
- `first_forbidden_match` — match precedence and edge cases for forbidden patterns
- Companion rule logic with `forbiddenPatterns` — inline simulation proving
  forbidden-first ordering wins over `requiredAny` satisfaction
- `extract_doc_references` — fence-aware extraction, multiple extensions, multi-match lines (v1)
- `doc_reference_resolves?`, `doc_reference_ignored?`, `load_doc_reference_ignore` —
  positive and negative paths plus comment / blank-line handling
- **v2 renderer-aware helpers** — `strip_inline_code_spans` (column-preserving
  inline-code stripping), `link_target_external?` (every external scheme + anchor +
  autolink + template placeholder), `strip_link_anchor` (anchor/query stripping),
  `resolve_relative_link` (same-dir, parent-dir, project-root-escape rejection,
  anchor stripping), `link_target_classify` / `link_target_renderer_safe?`
  (`:ok` / `:missing` / `:directory_target` / `:extensionless`),
  `extract_markdown_links` (multi-link, with-title, fenced + inline-code skip,
  external-target skip), `markdown_files_to_scan` (default + extra prefix
  exclusions, dot-prefixed directory skip)
- `load_manifest` typed-error shape checking — missing/empty/nil path, empty
  document, non-mapping top level (string / array), malformed YAML; every
  failure path raises `HarnessRegistry::ManifestShapeError` with a
  human-readable message (no raw `NoMethodError` / `Psych::SyntaxError` leaks)

```bash
ruby -I platform/validators/lib platform/validators/test/test_harness_registry.rb
```

### Integration tests

**`test/test_validators_integration.rb`** — hard-coded tests + 72 dynamically
generated `--help` / `-h` coverage tests (3 per validator × 25 validators) that
shell out to the actual validator scripts against fixture projects:

- `validate-manifest.sh` — valid pass, bad schema fail, missing file → exit 2
- `validate-module-graph.sh` — valid pass, bad dependency fail, conflict fail
- `validate-required-artifacts.sh` — valid pass, missing artifact fail, disabled override
- `validate-placeholders.sh` — clean pass, unfilled `[[TOKEN]]` fail, `YYYY-MM-DD` fail (skipped without ripgrep)
- `validate-agent-pack.sh` — agents pass, missing AGENTS.md fail, no-agent vacuous pass
- `validate-doc-references.sh` — valid pass, broken bare-path fail (file + line in stderr),
  fenced-block skip, ignore-file exempt, missing-platform → exit 2, dogfood pass
  against the harness's own repo. **v2 cases:** broken relative-path link
  (`../bar/does-not-exist.md`) flagged; inline backtick link syntax skipped;
  bare extensionless target (`LICENSE-MIT`) flagged with GitBook rationale;
  trailing-slash directory target flagged; external (`https://`, `mailto:`,
  `tel:`, `#anchor`, `<autolink>`, `{{template}}`) skipped; `.doc-reference-ignore`
  matching the resolved project-rooted path exempts the link
- `validate-companions.sh` `forbiddenPatterns` — no-hit pass, hit fail with
  `forbidden path X matched pattern Y` message, hit-plus-satisfied-requiredAny still
  fails (forbidden wins; skipped without git)
- `validate-publication-boundary.sh` — `--scan-file` clean pass, HTML-comment +
  frontmatter marker fail, mid-sentence mention no-trip, missing-arg → exit 2;
  git-tracked marker fail + `.publication-boundary-ignore` exemption pass (skipped
  without git); outside-git-tree pass
- `validate-module-stability.sh` — `--scan-file` valid-tier pass, missing-field
  fail, out-of-enum fail, missing-arg → exit 2; enumerate-mode all-valid pass
- `validate-observation-hygiene.sh` — `--scan-file` well-formed pass, missing-field
  fail, off-enum Confidence fail, off-enum Severity fail, Confidence-misfiled-into-
  Severity fail (with hint), no-ISO-date fail, missing-arg → exit 2; module-inactive
  skip; hermetic git-fixture grandfather pass + new-off-enum-observation fail
- `validate-trace-contract.sh` — `--scan-file` well-formed pass, missing-version
  fail, empty-spans fail, no-conventional-operation fail, bad-content_capture fail,
  missing-arg → exit 2; inactive-modules skip (predict-clean)
- `validate-foundry-target.sh` — `--scan-file` well-formed pass, empty-foundries
  fail, bad-id fail, bad-status fail, missing-arg → exit 2; inactive-modules skip
- `validate-model-routing.sh` — `--scan-file` well-formed pass, empty-routes fail,
  missing-model fail, missing-arg → exit 2; inactive-modules skip
- `validate-agent-defense-in-depth.sh` — `--scan-file` all-four pass, missing-one-pattern
  fail, missing-field fail, missing-arg → exit 2; inactive-modules skip
- Uniform `--help` / `-h` — every validator exits 0 with a "Usage:" + "Exit codes:"
  block on `--help` and `-h`, and works from any cwd without invoking Ruby
- Typed usage-error exit codes — empty manifest, malformed YAML, missing manifest
  file, and non-mapping top-level YAML all exit 2 with a clean `✗ <message>`
  line on stderr and zero raw Ruby `NoMethodError` / `Psych::SyntaxError` leakage

```bash
ruby -I platform/validators/lib platform/validators/test/test_validators_integration.rb
```

---

## Test Fixtures

> **Not documentation.** Fixture projects are test data — they contain intentionally
> broken manifests, missing artifacts, and other conditions that exercise validator error
> paths. Do not treat fixture content as canonical or exemplary. For real examples of
> harnessed projects, see [`examples/`](../examples/README.md).

Fixture projects in `test/fixtures/projects/` provide controlled test inputs:

| Fixture | Purpose |
| ------- | ------- |
| `valid-prototype/` | Minimal valid project (kernel/base + discovery-intake + product-lite + project-standard + prototype + base agent) with all required artifacts |
| `valid-testing-standard/` | Valid project with testing-standard module and testing artifacts (test-strategy.md, coverage-thresholds.md) |
| `valid-submodule-mount/` | Submodule-style consumer layout used to exercise mounted-platform validation paths |
| `broken-bad-schema/` | Invalid manifest — wrong schema version, missing fields, unknown module groups |
| `broken-bad-dependency/` | Manifest declaring a module that depends on a missing module |
| `broken-conflict/` | Manifest declaring two conflicting modules |
| `broken-missing-artifact/` | Valid manifest but missing required artifact files on disk |
| `valid-doc-references/` | Minimal `platform/` tree with valid markdown link + bare-path + inline-code references all resolving |
| `broken-doc-references/` | Tree where one bare `platform/...` reference points at a missing file under `platform/` (v1 scope) |
| `doc-references-in-fence/` | Tree with a broken reference inside a fenced code block — validator must skip it |
| `doc-references-ignored/` | Tree with a broken reference exempted by the fixture-local `.doc-reference-ignore` |
| `v2-broken-relative-link/` | **v2:** sibling-dir `[X](../bar/does-not-exist.md)` — broken relative path that v1 missed entirely |
| `v2-inline-code-link/` | **v2:** pedagogical `` `[X](broken.md)` `` inside inline backticks — must NOT be flagged |
| `v2-bare-extensionless/` | **v2:** `[X](../../LICENSE-MIT)` — file exists on disk but GitBook 404s on extensionless basenames |
| `v2-trailing-slash/` | **v2:** `[X](inner/)` — trailing-slash directory target trips GitBook's `<target>/README.md` lookup |
| `v2-external-skipped/` | **v2:** every external scheme (`https://`, `mailto:`, `tel:`, `#anchor`, `<autolink>`, `{{template}}`) — all must be skipped |
| `v2-ignored-by-file/` | **v2:** broken relative link exempted by the fixture-local `.doc-reference-ignore` matching the resolved project-rooted path |

Additional fixtures in `test/fixtures/`:

| Fixture | Purpose |
| ------- | ------- |
| `manifest_basic.yaml` | Minimal manifest for unit test loading |
| `module_with_companion.yaml` | Module declaring companion rules for unit test pattern matching |

---

## CI Integration

See [`workflow/ci-integration.md`](../workflow/ci-integration.md) for the complete GitHub
Actions workflow including validator steps and the test suite job.

---

## Troubleshooting

See [`workflow/troubleshooting.md`](../workflow/troubleshooting.md) for every validator
error message, its cause, and the fix.

---

## Known v2 exclusions to triage

The v2 scope expansion of `validate-doc-references.sh` surfaced renderer-fragile
links that v1 did not catch. Rather than block the v2 wire-in on the long-tail
cleanup, each finding was seeded into [`/.doc-reference-ignore`](../../.doc-reference-ignore)
with a one-line comment naming the source file and the recommended follow-up.

The triage queue:

| Source | Class | Recommendation |
| ------ | ----- | -------------- |
| `CHANGELOG.md:179` — `[\`docs/adr/\`](docs/adr/)` | `directory_target` (trailing-slash) | Either change the link to point at a representative ADR (e.g., `docs/adr/ADR-0010-cheap-satisfiers-for-routine-governance.md`) or author `docs/adr/README.md` as a canonical landing page for the ADR series, then remove the `^docs/adr$` entry from `.doc-reference-ignore`. |

When a triage entry is resolved, delete the corresponding line from
`.doc-reference-ignore` and run the full validator chain to confirm CI stays
green. The validator's value is its noisiness about drift — every ignore-file
entry is technical debt against that value.
