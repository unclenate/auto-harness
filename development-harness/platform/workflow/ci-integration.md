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
        run: |
          bash $PLATFORM_ROOT/validators/validate-companions.sh \
            $MANIFEST $PROJECT_ROOT ${{ github.base_ref }}

      - name: Validate placeholders
        run: bash $PLATFORM_ROOT/validators/validate-placeholders.sh $MANIFEST $PROJECT_ROOT

      - name: Validate agent pack
        run: bash $PLATFORM_ROOT/validators/validate-agent-pack.sh $MANIFEST $PROJECT_ROOT
```

---

## Setting PLATFORM_ROOT

The `PLATFORM_ROOT` variable must point to the `platform/` directory. How you set it depends on
how the platform is included in your project:

**Option A — Platform lives inside the project repo (monorepo or subtree):**

```yaml
env:
  PLATFORM_ROOT: ${{ github.workspace }}/development-harness/platform
```

**Option B — Platform is a git submodule:**

```yaml
- name: Checkout (with submodules)
  uses: actions/checkout@v4
  with:
    submodules: recursive
    fetch-depth: 0

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

If a validator is not appropriate for a project's current stage (e.g., `required-artifacts`
during early discovery), disable it in `harness.manifest.yaml`:

```yaml
overrides:
  disabledValidations:
    - required-artifacts
    - companions
```

The validator script exits 0 cleanly when disabled. Remove the override when the project matures.

See `platform/compositions/new-product-discovery.yaml` for an example discovery-phase manifest
that disables `required-artifacts`.

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
      - run: bash development-harness/platform/validators/validate-manifest.sh harness.manifest.yaml
      - run: bash development-harness/platform/validators/validate-module-graph.sh harness.manifest.yaml
      - run: bash development-harness/platform/validators/validate-required-artifacts.sh harness.manifest.yaml .
      - name: Companion rules (PRs only)
        if: github.event_name == 'pull_request'
        run: |
          bash development-harness/platform/validators/validate-companions.sh \
            harness.manifest.yaml . ${{ github.base_ref }}
      - run: bash development-harness/platform/validators/validate-placeholders.sh harness.manifest.yaml .
      - run: bash development-harness/platform/validators/validate-agent-pack.sh harness.manifest.yaml .

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

## Reference

| Resource | Path |
|----------|------|
| Validator scripts | `platform/validators/` |
| Ruby registry library | `platform/validators/lib/harness_registry.rb` |
| Validator test suite | `platform/validators/test/test_harness_registry.rb` |
| Starter discovery manifest | `platform/compositions/new-product-discovery.yaml` |
| Troubleshooting validator errors | `platform/workflow/troubleshooting.md` |
