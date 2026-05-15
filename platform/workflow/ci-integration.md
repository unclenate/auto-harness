<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# CI Integration Guide
## Wiring Harness Validators to GitHub Actions

This guide shows how to run the platform validators in CI so that manifest and governance checks
happen automatically on every pull request.

---

## What the Validators Check

| Validator | What it checks | When it runs |
|-----------|---------------|--------------|
| `validate-manifest.sh` | Schema, project fields, module group names | Every PR and push |
| `validate-module-graph.sh` | Dependencies, conflicts, module type correctness | Every PR and push |
| `validate-required-artifacts.sh` | Required files exist at declared paths | Every PR and push |
| `validate-companions.sh` | Sensitive path changes have required companion updates | PR only (needs git diff) |
| `validate-placeholders.sh` | No unfilled `[[PLACEHOLDER_NAME]]` tokens remain | Every PR and push |
| `validate-agent-pack.sh` | Agent entrypoints (AGENTS.md, CLAUDE.md, settings) present | Every PR and push |

All validators require Ruby 3.0+. `validate-placeholders.sh` additionally requires `ripgrep` (`rg`).

---

## Minimal Working Workflow

Create `.github/workflows/harness.yml` in your project repository:

```yaml
name: Harness Checks

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

env:
  PLATFORM_ROOT: ${{ github.workspace }}/path/to/platform
  MANIFEST: ${{ github.workspace }}/harness.manifest.yaml
  PROJECT_ROOT: ${{ github.workspace }}

jobs:
  harness:
    name: Harness Validators
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"

      - name: Install ripgrep
        run: sudo apt-get install -y ripgrep

      - name: Validate manifest structure
        run: bash $PLATFORM_ROOT/validators/validate-manifest.sh $MANIFEST

      - name: Validate module graph
        run: bash $PLATFORM_ROOT/validators/validate-module-graph.sh $MANIFEST

      - name: Validate required artifacts
        run: bash $PLATFORM_ROOT/validators/validate-required-artifacts.sh $MANIFEST $PROJECT_ROOT

      - name: Validate companion rules
        if: github.event_name == 'pull_request'
        env:
          BASE_REF: ${{ github.base_ref }}
        run: |
          bash $PLATFORM_ROOT/validators/validate-companions.sh \
            $MANIFEST $PROJECT_ROOT "$BASE_REF"

      - name: Validate placeholders
        run: bash $PLATFORM_ROOT/validators/validate-placeholders.sh $PROJECT_ROOT

      - name: Validate agent pack
        run: bash $PLATFORM_ROOT/validators/validate-agent-pack.sh $MANIFEST $PROJECT_ROOT
```

---

## Setting PLATFORM_ROOT

The `PLATFORM_ROOT` variable must point to the `platform/` directory. How you set it depends on
how auto-harness is included in your project:

**Option A — Submodule (recommended).** Mount auto-harness as a git submodule at a path of your
choosing (`.harness` by default). Set `HARNESS_SUBMODULE_ROOT` to the mount path and derive
`PLATFORM_ROOT` from it. Upstream improvements flow in via `git submodule update --remote`. See
[submodule-integration.md](submodule-integration.md) for the full setup flow.

```yaml
- name: Checkout (with submodules)
  uses: actions/checkout@v4
  with:
    submodules: recursive
    fetch-depth: 0

env:
  HARNESS_SUBMODULE_ROOT: ${{ github.workspace }}/.harness
  PLATFORM_ROOT: ${{ github.workspace }}/.harness/platform
```

For a non-default mount path (e.g., `vendor/auto-harness`), substitute consistently in both variables.

**Option B — Platform lives inside the project repo (monorepo or subtree):**

```yaml
env:
  PLATFORM_ROOT: ${{ github.workspace }}/platform
```

**Option C — Platform is checked out separately (separate repo):**

```yaml
- name: Checkout platform
  uses: actions/checkout@v4
  with:
    repository: your-org/development-harness
    path: harness

env:
  PLATFORM_ROOT: ${{ github.workspace }}/harness/platform
```

---

## Companion Validator Details

`validate-companions.sh` requires a git diff against a base branch to determine which files
changed. It takes three arguments:

```bash
bash validate-companions.sh <manifest> <project-root> <base-branch>
```

In GitHub Actions, `github.base_ref` is the target branch of the pull request. This is only
set for PR events — that's why the companion step has `if: github.event_name == 'pull_request'`.

On direct pushes to `main`, companion validation is skipped (no base branch to diff against).
This is intentional: companion checks enforce PR hygiene, not post-merge state.

---

## Disabling Validators Per-Manifest

Disabling validators during early discovery or brownfield adoption — and the discipline of re-enabling them as artifacts are created — is covered in **[Maintenance & Operations](maintenance-operations.md#re-enabling-validators-disabled-during-adoption)**. The short form: add the validator id to `overrides.disabledValidations` in `harness.manifest.yaml`; remove the entry once the relevant artifacts exist. See `platform/compositions/new-product-discovery.yaml` for a discovery-phase example that disables `required-artifacts`.

---

## Ruby Dependency

All validators except `validate-placeholders.sh` call the Ruby library at
`platform/validators/lib/harness_registry.rb`. No gems are required — it uses only Ruby stdlib
(`yaml`). Ruby 3.0+ is sufficient.

The `ruby/setup-ruby` action handles installation. If your runner already has Ruby (most
`ubuntu-latest` images do), you can omit the setup step, but pinning the version is recommended
for reproducibility.

---

## Ripgrep Dependency

`validate-placeholders.sh` uses `rg` (ripgrep) for fast pattern scanning. On `ubuntu-latest`:

```yaml
- name: Install ripgrep
  run: sudo apt-get install -y ripgrep
```

On `macos-latest`, ripgrep is pre-installed.

---

## Full Example: Node/TypeScript SaaS Project

For a project using the `node-web-saas-postgres` composition, a complete workflow combining
harness checks with stack checks looks like this:

```yaml
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  harness:
    name: Harness Validators
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
      - run: sudo apt-get install -y ripgrep
      - run: bash platform/validators/validate-manifest.sh harness.manifest.yaml
      - run: bash platform/validators/validate-module-graph.sh harness.manifest.yaml
      - run: bash platform/validators/validate-required-artifacts.sh harness.manifest.yaml .
      - name: Companion rules (PRs only)
        if: github.event_name == 'pull_request'
        env:
          BASE_REF: ${{ github.base_ref }}
        run: |
          bash platform/validators/validate-companions.sh \
            harness.manifest.yaml . "$BASE_REF"
      - run: bash platform/validators/validate-placeholders.sh .
      - run: bash platform/validators/validate-agent-pack.sh harness.manifest.yaml .

  stack:
    name: Stack Checks
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version-file: .nvmrc
          cache: npm
      - run: npm ci
      - run: npm run typecheck
      - run: npm run lint
      - run: npm run test
```

Keep harness and stack jobs separate so a governance failure and a test failure are independently
visible in the PR status checks.

---

## Wiring testing-standard Coverage Enforcement

When `management/testing-standard` is active, the thresholds declared in
`docs/testing/coverage-thresholds.md` must be enforced by the test runner in CI — the
document alone is not enforcement. The harness validators check that the file exists and
that any changes to it have a companion change-log entry or ADR. The test runner enforces
the numbers.

### Node / TypeScript (Jest or Vitest)

Add `coverageThreshold` to your Jest config to fail CI when coverage drops below the
declared values:

```javascript
// jest.config.js (or jest.config.ts)
module.exports = {
  coverageThreshold: {
    global: {
      lines: 80,
      branches: 75,
      functions: 80,
      statements: 80,
    },
  },
};
```

Run with coverage in the CI stack job:

```yaml
  stack:
    name: Stack Checks
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version-file: .nvmrc
          cache: npm
      - run: npm ci
      - run: npm run typecheck
      - run: npm run lint
      - run: npm test -- --coverage       # fails if thresholds not met
```

Vitest uses the same `thresholds` key under `coverage` in `vitest.config.ts`:

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    coverage: {
      thresholds: { lines: 80, branches: 75, functions: 80, statements: 80 },
    },
  },
});
```

### Python (pytest + pytest-cov)

Add `--cov-fail-under` to fail CI when coverage drops below the declared value:

```yaml
  stack:
    name: Stack Checks
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install -r requirements.txt
      - run: pytest --cov=src --cov-fail-under=80   # fails if threshold not met
```

Or declare the threshold in `pyproject.toml` to keep it out of the workflow file:

```toml
# pyproject.toml
[tool.pytest.ini_options]
addopts = "--cov=src --cov-fail-under=80"
```

### Keeping thresholds in sync

`docs/testing/coverage-thresholds.md` is the human-readable declaration. The framework
config (`jest.config.js`, `pyproject.toml`) is the enforcement. When you change one, change
the other in the same PR. The `testing-standard` companion rule will fire if you modify
`coverage-thresholds.md` without a change-log entry or ADR — but it will not catch the
reverse (changing the framework config without updating the doc). Keep them in sync manually.

---

## Harness Self-Tests in CI

If you are developing the platform itself (or vendoring it and want regression coverage),
add a job to run the harness test suite:

```yaml
  harness-tests:
    name: Harness Self-Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
      - name: Install ripgrep
        run: sudo apt-get install -y ripgrep

      - name: Unit tests (registry logic)
        run: |
          ruby -I platform/validators/lib \
               platform/validators/test/test_harness_registry.rb

      - name: Integration tests (validator scripts)
        run: |
          ruby -I platform/validators/lib \
               platform/validators/test/test_validators_integration.rb
```

The integration tests shell out to the actual validator scripts against fixture projects in
`platform/validators/test/fixtures/projects/`. They verify that each validator exits 0 on
valid input and exits 1 with the correct error message on each known-bad fixture.

The placeholder tests require ripgrep — they are automatically skipped if `rg` is not
available, and will run in CI where it is installed.

---

## Reference

| Resource | Path |
| -------- | ---- |
| Validator scripts | `platform/validators/` |
| Ruby registry library | `platform/validators/lib/harness_registry.rb` |
| Unit test suite | `platform/validators/test/test_harness_registry.rb` |
| Integration test suite | `platform/validators/test/test_validators_integration.rb` |
| Test fixtures | `platform/validators/test/fixtures/projects/` |
| Starter discovery manifest | `platform/compositions/new-product-discovery.yaml` |
| Troubleshooting validator errors | `platform/workflow/troubleshooting.md` |
