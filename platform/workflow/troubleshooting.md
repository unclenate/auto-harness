<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Troubleshooting Validator Errors

This document maps every known validator failure mode to its cause and fix.

---

## How to Read Validator Output

All validators print a single result line:

```text
✓ [description]         # exit 0 — passed
✗ [description]         # exit 1 — failed
  - [specific error]    # one line per issue
```

Validators exit 0 on pass, 1 on failure. A disabled validator prints:

```text
✓ [name] validation disabled by manifest override
```

and exits 0.

---

## validate-manifest.sh

### `✗ Manifest structure validation failed`

**`missing required field: schemaVersion`**
The manifest file doesn't have a `schemaVersion` key at the top level.

```yaml
# Fix: add this as the first line
schemaVersion: 1
```

---

**`schemaVersion must be 1, got: X`**
The schema version is present but not the integer `1`.

```yaml
# Fix: ensure it is the integer 1, not a string
schemaVersion: 1   # correct
schemaVersion: "1" # wrong
```

---

**`missing required project field: id` / `name` / `maturity` / `criticality`**
The `project:` block is incomplete.

```yaml
# Fix: all four fields are required
project:
  id: my-project
  name: My Project
  maturity: prototype    # prototype | mvp | production | research | platform (any string accepted)
  criticality: low       # low | medium | high | critical | platform | research | internal (schema-enforced enum)
```

---

**`unknown module group: X`**
A key under `modules:` is not a recognized category.

Allowed categories: `core`, `stacks`, `architectures`, `data`, `delivery`, `management`,
`domains`, `agents`.

```yaml
# Wrong
modules:
  tools:
    - my-tool

# Fix: use the correct category, or omit the group entirely
modules:
  agents:
    - my-tool
```

---

## validate-module-graph.sh

### `✗ Module graph validation failed`

**`Missing module definition for category:ref at path`**
A module is declared in the manifest but no `module.yaml` file exists at the expected path.

Common causes:

- Typo in the module name (case-sensitive, kebab-case)
- Module doesn't exist in this platform version
- Platform root is pointed at the wrong directory

```bash
# Error:
# Missing module definition for management:discovery-intake at /path/to/platform/profiles/management/discovery-intake/module.yaml

# Fix: check available modules
ls platform/profiles/management/

# If the module genuinely doesn't exist, remove it from the manifest
# If it's a typo, correct the spelling
```

---

**`X depends on missing module Y`**
Module `X` declares `dependsOn: [Y]` but module `Y` is not in the manifest.

```bash
# Error:
# program-lite depends on missing module project-standard

# Fix: add the dependency to the manifest
modules:
  management:
    - project-standard   # add this
    - program-lite
```

Common dependencies to remember:

- `program-lite` → requires `project-standard`
- `claude-code` agent → requires `base` agent
- `supabase` domain → requires `relational-sql`
- `media-pipeline` domain → requires `object-storage`

---

**`X conflicts with active module Y`**
Two mutually exclusive modules are both declared.

```text
# Error:
prototype conflicts with active module production-saas

# Fix: choose one — remove the other from the manifest
# For a prototype: keep prototype, remove production-saas
# For a production deployment: keep production-saas, remove prototype
```

Known conflicts:

- `prototype` ↔ `production-saas`
- `node-typescript` ↔ `python`

---

**`X resolved from category but declares type Y`**
A module's `type:` field doesn't match the category it was placed in.

```text
# Error:
my-module resolved from stacks but declares type management

# Fix: either move the module.yaml to the correct profiles/ subdirectory,
# or fix the type: field in module.yaml to match the category
```

---

## validate-required-artifacts.sh

### `✗ Required artifact validation failed`

**`missing docs/product/requirements.md`** (or any other path)
The file declared as a required artifact doesn't exist at that path in the project root.

```bash
# Fix: create the file using the template
cp platform/templates/product/requirements.md docs/product/requirements.md
# Then fill in the [[PLACEHOLDER_NAME]] fields
```

If the file legitimately doesn't exist yet (e.g., during discovery phase), disable the
validation in the manifest:

```yaml
overrides:
  disabledValidations:
    - required-artifacts
```

Remove this override once the artifacts are created.

---

**Validation passes but files are empty stubs**
`validate-required-artifacts.sh` checks file existence only, not content. Empty files pass.
The `validate-placeholders.sh` validator will catch unfilled template tokens. Human review
gates in each module's `reviewGates` field are the backstop for content quality.

---

## validate-companions.sh

### How Companion Rules Work

Companion rules enforce a paper trail for changes that affect governance-sensitive areas.
A companion rule says: "when file A changes, file B must also change in the same PR."

**Example:** When `docs/product/requirements.md` changes, either `docs/project/change-log.md`
or a new `docs/adr/ADR-XXXX-*.md` must also be in the PR. This ensures that requirements
changes don't happen silently — they require either a changelog entry (lightweight) or an
ADR (for architectural impact).

**How it's checked:** `validate-companions.sh` runs `git diff --name-only <base-branch>...HEAD`
to get all files changed in the PR. For each changed file that matches a `triggerPaths`
pattern in any active module, it checks whether at least one file matching `requiredAny`
is also in the diff.

**The rule fires per-PR, not per-commit.** A companion file touched in a previous commit on
the same branch satisfies the rule. A companion file touched in a separate PR does not.

**Common companion rules in the default modules:**

| Module | Trigger | Required companion |
| ------ | ------- | ------------------ |
| `product-lite` | `docs/product/requirements.md` | change-log, ADR, or PRD |
| `discovery-intake` | `docs/discovery/mvp-scope.md` | change-log, ADR, or PRD |
| `project-standard` | `docs/project/scope-plan.md` | change-log |
| `relational-sql` | `migrations/` | `docs/database/migration-readiness.md` |
| `domains/web3` | `contracts/`, `src/wallet/` | risk register or ADR |
| `domains/web3` | `src/scoring/` | ADR |
| `domains/web3` | `chain_config` | ADR |
| `claude-code` agent | `CLAUDE.md`, `.claude/` | `AGENTS.md`, ADR, or PRD |

For the full list, read each active module's `module.yaml` `companionRules` section.

---

### `✗ Companion validation failed`

**`module-id: [rule description]`**
A file matching a companion rule's `triggerPaths` was changed in this PR, but none of the
files in `requiredAny` were also changed.

```text
# Error example:
  - product-lite: Requirements changes during development must be reflected in project change-log, a new ADR, or a new PRD
    required change matching ^docs/project/change-log\.md$
    required change matching ^docs/adr/ADR-
    required change matching ^docs/requirements/PRD-

# Fix: include one of the required companion files in your PR
# Option A: update docs/project/change-log.md
# Option B: add a new docs/adr/ADR-XXXX-description.md
# Option C: add a new docs/requirements/PRD-XXXX-description.md
```

Companion rules exist because governance changes need a paper trail. The rule is not satisfied
by touching the file in a previous commit — it must be in this PR's diff.

---

**Companion validation shows "No changed files detected"**
The validator found no files changed relative to the base branch. This happens when:

- Running against a clean branch with no commits ahead of main
- The base branch argument is wrong

```bash
# Check what files are actually changed
git diff --name-only origin/main...HEAD

# If running locally, pass the correct base branch
bash platform/validators/validate-companions.sh harness.manifest.yaml . main
```

---

**Companion validation triggered unexpectedly**
A file you changed is matching a trigger pattern you didn't expect. The trigger patterns are
defined in each module's `companionRules` in its `module.yaml`.

```bash
# Find which module's rule is triggering
grep -r "triggerPaths" platform/profiles/management/ platform/profiles/stacks/
```

If the trigger is legitimate but you want to suppress it for this PR, you cannot — the rules
are enforced. Add the required companion file or document the rationale in a new ADR.

---

## validate-doc-references.sh

### How Doc-Reference Validation Works

The validator scans every `*.md` file under `<project-root>/platform/` and extracts every
string matching `platform/[A-Za-z0-9_./\-]+\.(md|yaml|yml|sh|rb|json|txt)`. For each
extracted reference, the file must exist on disk relative to the project root. Matches
inside fenced code blocks (```` ``` ... ``` ````) are skipped — they're assumed to be
illustrative.

The validator catches the most common documentation-drift class: a `README.md` (or
template, or workflow doc) points at a file that has since been renamed, moved, or
deleted. The pre-validator workflow caught these only at PR-review time; the validator
catches them in CI.

---

### `✗ Broken doc references found:`

**`platform/foo/example.md:42: platform/workflow/missing-guide.md`**

The file `platform/foo/example.md`, on line 42, references `platform/workflow/missing-guide.md`,
which does not exist on disk.

**Fix:** open the source file and either correct the reference (it was probably renamed)
or remove the stale reference if the target no longer exists.

```bash
# Find what the file used to be called
git log --diff-filter=D --name-only --pretty=format: -- '*missing-guide*'

# Or just look at what's currently in that directory
ls platform/workflow/
```

If the reference is intentionally pointing at a file that does not yet exist (rare —
prefer to leave the reference out until the file lands), add a regex to
`.doc-reference-ignore` at the project root:

```text
# .doc-reference-ignore — one regex per line, # for comments
^platform/workflow/intentional-future-doc\.md$
```

Use sparingly. The validator's value is exactly its noisiness about drift.

---

### `✗ <project-root>/platform does not exist — nothing to scan.`

The validator was pointed at a directory that has no `platform/` subdirectory. This is
either a misconfiguration (wrong working directory) or you're running it against a
consumer project that has not yet adopted the harness via submodule.

```bash
# Fix: run from the repo root
bash platform/validators/validate-doc-references.sh .
```

If the consumer project mounts the platform via submodule (`.harness/platform/...`),
make the validator point at the project root (the directory above `.harness`); the
validator scans `<project-root>/platform/` directly — submodule consumers without a
top-level `platform/` directory should skip this validator or symlink as appropriate.

---

### Reference inside a fenced code block is flagged anyway

The validator is fence-aware (it tracks ``` toggling line-by-line). If a reference inside
a code block is being flagged, the most likely cause is a fence that the validator can't
recognize:

- Indented code blocks (4-space-indented) are NOT recognized as fences. Convert to
  fenced (```` ``` ````) to get the skip behavior.
- A fence on the same line as text (rare) won't toggle. Put the ` ``` ` on its own line.

---

## validate-companions.sh — forbiddenPatterns hard fails

### `✗ Companion validation failed (forbidden paths):`

**`ERROR: forbidden path src/AGENTS.override.md matched pattern (^|/)AGENTS\.override\.md$ (rule: <description>)`**

The PR diff contains a file whose path matches a `forbiddenPatterns` regex on one of the
active modules' companion rules. Forbidden patterns are hard fails — they cannot be
satisfied by adding a companion file the way `requiredAny` rules can. The check runs
*before* the `requiredAny` check, so an offending file flanked by a documentary
`AGENTS.md` / ADR / PRD edit still fails.

**Fix:** remove the offending file from the PR.

```bash
# Identify the file the validator is complaining about, then drop it
git rm src/AGENTS.override.md
# Or, if it's only staged:
git restore --staged src/AGENTS.override.md
rm src/AGENTS.override.md
```

If you believe the forbidden pattern is wrong for your project (e.g., your team has a
defensible reason to commit `AGENTS.override.md` and accepts the risks Codex's loader
behavior implies), do not edit the rule on the platform module — instead, file an issue
to discuss with the platform maintainers. The rule is shared governance, not per-project
configuration.

**Why this is hard-enforced:** Codex CLI reads `AGENTS.override.md` before `AGENTS.md` at
every level of its file walk and lets the override win silently. Committing the file at
any depth lets the override silently rewrite the project's governance contract for every
Codex user descending into that subtree — a Tier 4+ configuration change that should
never enter the repo accidentally.

---

## validate-placeholders.sh

### `✗ Placeholder validation failed`

**`[[PLACEHOLDER_NAME]] found in docs/product/requirements.md:5`**
A template token was not replaced when the file was filled in.

```bash
# Fix: open the file and replace the token with real content
# The error includes the file path and line number
```

Common placeholder patterns:

- `[[OWNER]]` → replace with a GitHub handle or team name
- `[[DATE]]` / `YYYY-MM-DD` → replace with the actual date
- `[[PROJECT_NAME]]` → replace with the project name
- `[[PERSONA_NAME]]` → replace with a real persona name

If you want to intentionally exclude a file or directory from placeholder checking, add the
path pattern to `.placeholder-ignore` at the project root (one glob pattern per line).

---

## testing-standard Module Errors

### `✗ Required artifact validation failed: missing docs/testing/test-strategy.md`

The `testing-standard` management module requires this file.

```bash
mkdir -p docs/testing
cp platform/templates/testing/test-strategy.md docs/testing/test-strategy.md
```

Open the file and fill in:

- Which pyramid layers are active (unit, integration, E2E)
- Which test framework is in use
- What is enforced in CI vs. deferred to manual review

---

### `✗ Required artifact validation failed: missing docs/testing/coverage-thresholds.md`

```bash
cp platform/templates/testing/coverage-thresholds.md docs/testing/coverage-thresholds.md
```

Fill in the threshold percentages, then wire them into the framework config (Jest
`coverageThreshold`, pytest `--cov-fail-under`) so CI enforces them. The document alone
is not enforcement — the framework config is.

---

### Coverage threshold companion rule fires unexpectedly

```text
testing-standard: Coverage threshold changes require a change-log entry, ADR, or PRD
```

This fires when `docs/testing/coverage-thresholds.md` is modified without a companion
`docs/project/change-log.md`, `docs/adr/ADR-*.md`, or `docs/requirements/PRD-*.md` in
the same PR.

Thresholds are architectural commitments. Changing them requires a documented rationale.

```bash
# Fix: add one of these to your PR
# Option A: update the change log
echo "Changed unit coverage threshold from 80% to 75% — reason: ..." >> docs/project/change-log.md

# Option B: create an ADR
cp platform/templates/adr.md docs/adr/ADR-XXXX-coverage-threshold-change.md

# Option C: create a PRD (if the threshold change is driven by a product decision)
cp platform/templates/product/prd.md docs/requirements/PRD-XXXX-coverage-adjustment.md
```

---

### Prototype delivery + testing-standard: when to disable enforcement

If `delivery/prototype` is active alongside `testing-standard`, the harness won't prevent
you from having lower or zero thresholds. But validators will still check for the
existence of `docs/testing/test-strategy.md` and `docs/testing/coverage-thresholds.md`.

For pure prototype projects that genuinely don't need testing governance, omit
`testing-standard` from the manifest entirely. Don't activate it and then disable all
its validators — that creates governance debt without benefit.

---

## validate-agent-pack.sh

### `✗ Agent pack validation failed`

**`missing AGENTS.md`**
The cross-agent contract file doesn't exist at the project root.

```bash
# Fix: create AGENTS.md
# Reference: platform/examples/sample-projects/node-web-saas-postgres/AGENTS.md
# Or use the agents/base compiled fragments as a starting point
```

---

**`missing .claude/settings.json`** (when claude-code agent is active)
The Claude Code configuration file doesn't exist.

```bash
# Fix: create .claude/settings.json
# Reference: platform/examples/sample-projects/node-web-saas-postgres/.claude/settings.json
# Or start from the agents/claude-code compiled fragments
```

---

## General Troubleshooting

### Validator exits with a Ruby error

```text
/path/to/harness_registry.rb:X: syntax error...
```

This is a bug in the platform library, not your project. Report it with the full stack trace.

---

### "Permission denied" running a validator

```text
bash: platform/validators/validate-manifest.sh: Permission denied
```

```bash
# Fix: ensure the scripts are executable
chmod +x platform/validators/*.sh
```

---

### Validator can't find the platform root

Validators derive the platform root from their own script location (`$SCRIPT_DIR/../..`).
This assumes the script is at `platform/validators/validate-*.sh`. If you've moved or
symlinked the scripts, the relative path resolution will break.

Always run validators from the repository root using the full path to the script:

```bash
# Good
bash platform/validators/validate-manifest.sh harness.manifest.yaml

# Risky — only works if your CWD is exactly right
bash validate-manifest.sh harness.manifest.yaml
```

---

### Running all validators at once

There's no `validate-all.sh` script. Run each validator explicitly in order. Set
`$PLATFORM_ROOT` first per the definitions in
[`bootstrap-quickstart.md` Step 2](bootstrap-quickstart.md) (typically
`"$PWD/.harness/platform"` for submodule consumers or `"$PWD/platform"` for in-tree
checkouts):

```bash
bash $PLATFORM_ROOT/validators/validate-manifest.sh harness.manifest.yaml
bash $PLATFORM_ROOT/validators/validate-module-graph.sh harness.manifest.yaml
bash $PLATFORM_ROOT/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash $PLATFORM_ROOT/validators/validate-placeholders.sh .
bash $PLATFORM_ROOT/validators/validate-agent-pack.sh harness.manifest.yaml .
bash $PLATFORM_ROOT/validators/validate-doc-references.sh .
bash $PLATFORM_ROOT/validators/validate-catalog-counts.sh .
# Companion validator requires a base branch — skip locally unless comparing branches
```

---

## Reference

| Resource | Path |
| -------- | ---- |
| Bootstrap quickstart | `platform/workflow/bootstrap-quickstart.md` |
| CI integration guide | `platform/workflow/ci-integration.md` |
| Validator source | `platform/validators/` |
| Registry library | `platform/validators/lib/harness_registry.rb` |
| Validator tests | `platform/validators/test/test_harness_registry.rb` |
