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
- **Bash** — the seven `validate-*.sh` scripts delegate to Ruby and work with Bash 3.2 (macOS default) and 4+. The bootstrap scripts (`install.sh`, `link-skills.sh`, `add-license-headers.sh`) require Bash 4+ (use `declare -A` and other 4+ features); macOS users must `brew install bash` for those.

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
| `validate-doc-references.sh` | `<project-root>` | Every `platform/...` path reference inside Markdown files under `platform/` resolves on disk; skips fenced code blocks; respects `.doc-reference-ignore` |

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
| `extract_doc_references(markdown)` | Extracts every `platform/...` path reference from a Markdown string, skipping fenced code blocks. Returns `[{path:, line:}, ...]` |
| `doc_reference_resolves?(path, project_root)` | True iff the referenced path exists on disk under the project root |
| `doc_reference_ignored?(path, patterns)` | True iff `path` matches any regex pattern in the `.doc-reference-ignore` list |
| `load_doc_reference_ignore(path)` | Read a `.doc-reference-ignore` file (one regex per line; `#` comments allowed); returns `[]` when missing |

---

## Test Suite

Two test files using Ruby Minitest (stdlib, no gem install required).

### Unit tests

**`test/test_harness_registry.rb`** — 96 tests covering `HarnessRegistry` methods:

- `patterns_match?` — single/multiple patterns, anchors, nil/empty, special characters
- `disabled_validation?` — present, absent, missing key, multiple entries
- `required_artifacts` — aggregation, deduplication, manifest overrides, nil handling
- Companion rule logic — inline simulation of the trigger/required-any loop from
  `validate-companions.sh` with controlled `changed_files` arrays
- `first_forbidden_match` — match precedence and edge cases for forbidden patterns
- Companion rule logic with `forbiddenPatterns` — inline simulation proving
  forbidden-first ordering wins over `requiredAny` satisfaction
- `extract_doc_references` — fence-aware extraction, multiple extensions, multi-match lines
- `doc_reference_resolves?`, `doc_reference_ignored?`, `load_doc_reference_ignore` —
  positive and negative paths plus comment / blank-line handling
- `load_manifest` typed-error shape checking — missing/empty/nil path, empty
  document, non-mapping top level (string / array), malformed YAML; every
  failure path raises `HarnessRegistry::ManifestShapeError` with a
  human-readable message (no raw `NoMethodError` / `Psych::SyntaxError` leaks)

```bash
ruby -I platform/validators/lib platform/validators/test/test_harness_registry.rb
```

### Integration tests

**`test/test_validators_integration.rb`** — 43 hard-coded tests + 21 dynamically
generated `--help` / `-h` coverage tests (3 per validator × 7 validators) that
shell out to the actual validator scripts against fixture projects:

- `validate-manifest.sh` — valid pass, bad schema fail, missing file → exit 2
- `validate-module-graph.sh` — valid pass, bad dependency fail, conflict fail
- `validate-required-artifacts.sh` — valid pass, missing artifact fail, disabled override
- `validate-placeholders.sh` — clean pass, unfilled `[[TOKEN]]` fail, `YYYY-MM-DD` fail (skipped without ripgrep)
- `validate-agent-pack.sh` — agents pass, missing AGENTS.md fail, no-agent vacuous pass
- `validate-doc-references.sh` — valid pass, broken-ref fail (file + line in stderr),
  fenced-block skip, ignore-file exempt, missing-platform → exit 2, dogfood pass
  against the harness's own repo
- `validate-companions.sh` `forbiddenPatterns` — no-hit pass, hit fail with
  `forbidden path X matched pattern Y` message, hit-plus-satisfied-requiredAny still
  fails (forbidden wins; skipped without git)
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
| `broken-doc-references/` | Tree where one Markdown link points at a missing file under `platform/` |
| `doc-references-in-fence/` | Tree with a broken reference inside a fenced code block — validator must skip it |
| `doc-references-ignored/` | Tree with a broken reference exempted by the fixture-local `.doc-reference-ignore` |

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
