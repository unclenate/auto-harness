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
- **Bash 4+** — standard on Linux; macOS ships Bash 3 but the scripts are compatible

---

## Validator Scripts

Run from the repository root. Each script exits 0 on pass, 1 on failure with a specific
error message.

| Script | Arguments | What It Checks |
| ------ | --------- | -------------- |
| `validate-manifest.sh` | `<manifest>` | Schema version, required project fields, valid module categories, overrides structure |
| `validate-module-graph.sh` | `<manifest>` | Module existence on disk, dependency chains satisfied, conflict detection, category/type match |
| `validate-required-artifacts.sh` | `<manifest> <project-root>` | Every `requiredArtifact` declared by active modules exists on disk |
| `validate-placeholders.sh` | `<project-root>` | No unfilled `[[PLACEHOLDER]]` or `YYYY-MM-DD` tokens in project files; respects `.placeholder-ignore` exclusions (requires ripgrep) |
| `validate-agent-pack.sh` | `<manifest> <project-root>` | Agent modules declare adapters and compiled fragments; all referenced files must exist |
| `validate-companions.sh` | `<manifest> <project-root> <base-branch>` | PR diff satisfies all active companion rules (requires git context) |

### Recommended run order

```bash
bash platform/validators/validate-manifest.sh harness.manifest.yaml
bash platform/validators/validate-module-graph.sh harness.manifest.yaml
bash platform/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash platform/validators/validate-placeholders.sh .
bash platform/validators/validate-agent-pack.sh harness.manifest.yaml .
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
| `load_manifest(path)` | Parse a YAML manifest |
| `active_refs(manifest)` | Return `[category, ref]` pairs for all declared modules |
| `active_modules(platform_root, manifest)` | Load and return `module.yaml` data for every active module |
| `required_artifacts(modules, manifest)` | Aggregate and deduplicate required artifacts across modules + overrides |
| `resolve_module_path(platform_root, category, ref)` | Map a module reference to its `module.yaml` path on disk |
| `disabled_validation?(manifest, name)` | Check if a validation is in the disabled list |
| `patterns_match?(patterns, path)` | Test a file path against an array of regex patterns (used by companion rules) |
| `changed_files(project_root, base_branch)` | Get the list of changed files via `git diff` against a base branch |

---

## Test Suite

Two test files using Ruby Minitest (stdlib, no gem install required).

### Unit tests

**`test/test_harness_registry.rb`** — 48 tests covering `HarnessRegistry` methods:

- `patterns_match?` — single/multiple patterns, anchors, nil/empty, special characters
- `disabled_validation?` — present, absent, missing key, multiple entries
- `required_artifacts` — aggregation, deduplication, manifest overrides, nil handling
- Companion rule logic — inline simulation of the trigger/required-any loop from
  `validate-companions.sh` with controlled `changed_files` arrays

```bash
ruby -I platform/validators/lib platform/validators/test/test_harness_registry.rb
```

### Integration tests

**`test/test_validators_integration.rb`** — 29 tests that shell out to the actual
validator scripts against fixture projects:

- `validate-manifest.sh` — valid pass, bad schema fail, missing file abort
- `validate-module-graph.sh` — valid pass, bad dependency fail, conflict fail
- `validate-required-artifacts.sh` — valid pass, missing artifact fail, disabled override
- `validate-placeholders.sh` — clean pass, unfilled `[[TOKEN]]` fail, `YYYY-MM-DD` fail (skipped without ripgrep)
- `validate-agent-pack.sh` — agents pass, missing AGENTS.md fail, no-agent vacuous pass

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
