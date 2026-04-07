# Troubleshooting Validator Errors

This document maps every known validator failure mode to its cause and fix.

---

## How to Read Validator Output

All validators print a single result line:

```
✓ [description]         # exit 0 — passed
✗ [description]         # exit 1 — failed
  - [specific error]    # one line per issue
```

Validators exit 0 on pass, 1 on failure. A disabled validator prints:

```
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
  maturity: prototype    # prototype | mvp | production
  criticality: low       # low | medium | high | critical
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

```
# Error:
Missing module definition for management:discovery-intake at /path/to/platform/profiles/management/discovery-intake/module.yaml

# Fix: check available modules
ls platform/profiles/management/

# If the module genuinely doesn't exist, remove it from the manifest
# If it's a typo, correct the spelling
```

---

**`X depends on missing module Y`**
Module `X` declares `dependsOn: [Y]` but module `Y` is not in the manifest.

```
# Error:
program-lite depends on missing module project-standard

# Fix: add the dependency to the manifest
modules:
  management:
    - project-standard   # add this
    - program-lite
```

Common dependencies to remember:
- `program-lite` → requires `project-standard`
- `claude-code` agent → requires `base` agent
- `supabase` domain → requires `relational-postgres`
- `media-pipeline` domain → requires `object-storage`

---

**`X conflicts with active module Y`**
Two mutually exclusive modules are both declared.

```
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

```
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

```
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

### `✗ Companion validation failed`

**`module-id: [rule description]`**
A file matching a companion rule's `triggerPaths` was changed in this PR, but none of the
files in `requiredAny` were also changed.

```
# Error example:
  - product-lite: Requirements changes during development must be reflected in project change-log or a new ADR
    required change matching ^docs/project/change-log\.md$
    required change matching ^docs/adr/ADR-

# Fix: include one of the required companion files in your PR
# Option A: update docs/project/change-log.md
# Option B: add a new docs/adr/ADR-XXXX-description.md
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

## validate-placeholders.sh

### `✗ Placeholder validation failed`

**`[[PLACEHOLDER_NAME]] found in docs/product/requirements.md:5`**
A template token was not replaced when the file was filled in.

```
# Fix: open the file and replace the token with real content
# The error includes the file path and line number
```

Common placeholder patterns:
- `[[OWNER]]` → replace with a GitHub handle or team name
- `[[DATE]]` / `YYYY-MM-DD` → replace with the actual date
- `[[PROJECT_NAME]]` → replace with the project name
- `[[PERSONA_NAME]]` → replace with a real persona name

If you want to intentionally leave a placeholder (not recommended), add the file to
`.harnessignore` (if supported) or disable the `placeholders` validation in the manifest.

---

## validate-agent-pack.sh

### `✗ Agent pack validation failed`

**`missing AGENTS.md`**
The cross-agent contract file doesn't exist at the project root.

```
# Fix: create AGENTS.md
# Reference: platform/examples/sample-projects/node-web-saas-postgres/AGENTS.md
# Or use the agents/base compiled fragments as a starting point
```

---

**`missing .claude/settings.json`** (when claude-code agent is active)
The Claude Code configuration file doesn't exist.

```
# Fix: create .claude/settings.json
# Reference: platform/examples/sample-projects/node-web-saas-postgres/.claude/settings.json
# Or start from the agents/claude-code compiled fragments
```

---

## General Troubleshooting

### Validator exits with a Ruby error

```
/path/to/harness_registry.rb:X: syntax error...
```

This is a bug in the platform library, not your project. Report it with the full stack trace.

---

### "Permission denied" running a validator

```
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
bash development-harness/platform/validators/validate-manifest.sh harness.manifest.yaml

# Risky — only works if your CWD is exactly right
bash validate-manifest.sh harness.manifest.yaml
```

---

### Running all validators at once

There's no `validate-all.sh` script. Run each validator explicitly in order:

```bash
PLATFORM=development-harness/platform
bash $PLATFORM/validators/validate-manifest.sh harness.manifest.yaml
bash $PLATFORM/validators/validate-module-graph.sh harness.manifest.yaml
bash $PLATFORM/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash $PLATFORM/validators/validate-placeholders.sh harness.manifest.yaml .
bash $PLATFORM/validators/validate-agent-pack.sh harness.manifest.yaml .
# Companion validator requires a base branch — skip locally unless comparing branches
```

---

## Reference

| Resource | Path |
|----------|------|
| Bootstrap quickstart | `platform/workflow/bootstrap-quickstart.md` |
| CI integration guide | `platform/workflow/ci-integration.md` |
| Validator source | `platform/validators/` |
| Registry library | `platform/validators/lib/harness_registry.rb` |
| Validator tests | `platform/validators/test/test_harness_registry.rb` |
