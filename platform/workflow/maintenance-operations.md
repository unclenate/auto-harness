<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Maintenance & Operations

## Keeping the Harness Healthy After You Adopt It

This guide is for **operators** — anyone running a project that has already adopted auto-harness and now needs to keep the harness itself current, recover from drift, manage versions, or perform periodic governance checks.

If you are setting up the harness for the first time, you want the adoption guides instead:

- [Submodule integration](submodule-integration.md) — the recommended adoption mode
- [Bootstrap quickstart](bootstrap-quickstart.md) — greenfield, stack known
- [Brownfield onboarding](brownfield-onboarding.md) — existing codebase being brought under governance

Maintenance starts where adoption ends.

---

## Keeping Your Harness Current

### Pulling Upstream Improvements (Submodule Mode)

If you adopted the harness via the recommended git-submodule pattern, every upstream improvement — new skill, fixed validator, refined composition — is one command away:

```bash
git submodule update --remote .harness
```

Substitute your mount path if you used something other than `.harness`.

Review the change before committing:

```bash
git diff HEAD -- .harness
```

This shows the new submodule commit SHA. If the upstream change touched only skills, compositions, or templates you reference via symlink, the change is already live in your repo — no re-bootstrap step is required, because your consumer references `platform/` content through symlinks.

If the upstream change introduced a new required artifact or modified `install.sh` behavior, surface it with a dry-run:

```bash
bash .harness/platform/bootstrap/install.sh --dry-run
```

The dry-run summary tells you whether any new files would be created or existing files updated. If it reports work to do, run without `--dry-run` (and add `--force` if you want to regenerate harness-style files that already exist).

Commit:

```bash
git add .harness
git commit -m "chore: update auto-harness submodule"
```

### Pulling Upstream Improvements (Copy Mode — Legacy)

The copy-based adoption flow (`cp -r platform/...` from a snapshot) is the original pattern and is now superseded by submodule integration. Copy-mode consumers stay on the platform version they originally copied; upstream improvements do not flow in automatically.

To pull upstream improvements in copy mode, you must re-copy manually:

```bash
# In a sibling directory, fetch the latest auto-harness
git clone https://github.com/unclenate/auto-harness ../auto-harness-upstream
cd ../auto-harness-upstream && git pull

# Back in your project, refresh the copies you originally took
cd your-project
rm -rf platform/skills/harness-governance .agents/skills/harness-governance
cp -r ../auto-harness-upstream/platform/skills/harness-governance .agents/skills/

# Repeat for every skill, composition, and template you originally copied
```

There is no tool that detects which copied files have changed upstream — you must remember what you copied and re-copy each piece. This is the structural disadvantage of copy mode and the main reason submodule integration is recommended.

If you maintain a copy-mode project long-term, see [Migrating from Copy Mode to Submodule](#migrating-from-copy-mode-to-submodule) below.

### Detecting New Required Artifacts After an Upgrade

When upstream adds a new required artifact (for example, a new template that an existing module now declares as `required`), the `validate-required-artifacts.sh` validator will start failing. Surface this proactively with a dry-run install before committing the submodule bump:

```bash
bash .harness/platform/bootstrap/install.sh --dry-run
```

The dry-run output enumerates anything `install.sh` would create. Cross-reference against your existing files to see what is genuinely new.

You can also re-run the validators directly:

```bash
bash .harness/platform/validators/validate-required-artifacts.sh harness.manifest.yaml .
```

Either approach surfaces gaps before they break CI.

---

## Version Management

### Pinning to a Specific Harness Version

Submodules track a specific commit, not a moving branch reference. By default, `git submodule update --remote` follows whatever branch the submodule was added on (usually `main`). If you want stability — for example, during a release freeze or a regulated period — you can pin to a specific commit or tag.

**Pinning to a tag** (recommended when an upstream version has been tagged):

```bash
cd .harness
git fetch --tags
git checkout v0.2.0    # whatever tag you want
cd ..
git add .harness
git commit -m "chore: pin auto-harness to v0.2.0"
```

**Pinning to a specific commit** (when no tag exists):

```bash
cd .harness
git checkout 3193270   # a specific commit SHA
cd ..
git add .harness
git commit -m "chore: pin auto-harness to commit 3193270"
```

After pinning, `git submodule update --remote` will keep following the configured branch (and would move you off the pinned commit). To prevent that, change the tracking branch in `.gitmodules`:

```ini
[submodule ".harness"]
    path = .harness
    url = https://github.com/unclenate/auto-harness
    branch = v0.2.0       ; or leave unset and only use explicit checkouts
```

Then run `git submodule sync` so the change takes effect.

Document the pin in your `docs/project/change-log.md` so future maintainers understand why your harness version is held back from `main`.

### Rolling Back After a Breaking Upstream Change

If you pull a new submodule version and discover it breaks your validators, your CI, or your bootstrap, roll back to the previous commit:

```bash
cd .harness
git log --oneline -10                # find the previous SHA you were on
git checkout <previous-sha>
cd ..
git add .harness
git commit -m "revert: roll back auto-harness submodule to <previous-sha>"
```

Before deciding to roll back, capture *why* — open an issue against auto-harness using the [bug report template](../../.github/ISSUE_TEMPLATE/bug_report.yml). Rollback resolves your immediate problem; the upstream issue prevents the next adopter from hitting the same wall.

If a rollback proves to be more than temporary, follow the pinning guidance above to make it explicit and durable.

---

## Validator Lifecycle After Adoption

### Running Validators Locally on an Ongoing Basis

Validators are not just a bootstrap-time check — they are the day-to-day mechanism that keeps governance current. Run the full chain before every significant commit:

```bash
bash platform/validators/validate-manifest.sh harness.manifest.yaml
bash platform/validators/validate-module-graph.sh harness.manifest.yaml
bash platform/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash platform/validators/validate-placeholders.sh .
bash platform/validators/validate-agent-pack.sh harness.manifest.yaml .
bash platform/validators/validate-companions.sh harness.manifest.yaml . main
```

When a validator fails, the [troubleshooting guide](troubleshooting.md) maps each error message to a cause and a fix. Treat it as a reference manual — operators look things up in it, not as a one-time bootstrap reading.

### Re-enabling Validators Disabled During Adoption

Brownfield onboarding intentionally disables some validators at adoption time so the team can backfill artifacts gradually without blocking active development. The most common disabled validator is `required-artifacts`:

```yaml
overrides:
  disabledValidations:
    - required-artifacts
```

The validator script exits 0 cleanly when disabled, but the team carries an implicit debt: every disabled validator is a piece of governance not being enforced.

The reverse path — *re-enabling* validators as artifacts are created — is the maintenance discipline that pays the debt back:

| Phase | Focus | Validator state |
| ----- | ----- | --------------- |
| **Phase 1** (initial adoption) | Kernel artifacts: `HARNESS.md`, `AGENTS.md`, `docs/operating-principles.md` | `required-artifacts` disabled |
| **Phase 2** (week 1–2) | Architecture overview, product problem statement and requirements | Re-enable `required-artifacts` selectively as modules are ready |
| **Phase 3** (week 2–4) | Ops docs (if `delivery/production-saas` is active): environment inventory, release checklist, risk register | All validators enabled locally |
| **Phase 4** (ongoing) | CI wired; `harness-governance` skill installed; all validators green in CI | **Harness Ready** |

To re-enable a validator after creating the relevant artifacts:

1. Create or fill the missing artifacts (using templates from `platform/templates/`).
2. Remove the validator entry from `disabledValidations` in `harness.manifest.yaml`.
3. Run the validator locally to confirm green before committing.
4. Commit the manifest change and the new artifacts in the same PR.

This applies equally to brownfield projects ramping up and to long-running projects that disabled a validator during a sprint and forgot to re-enable it. Treat `disabledValidations` as visible technical debt — review it at every quarterly governance audit (see below).

### When Validators Themselves Change Upstream

Validator scripts in `platform/validators/` evolve over time. When upstream changes the logic of a validator — fixing a false-negative, tightening a rule, adding a new schema check — your project may suddenly see a failure on a check that was previously green.

When this happens:

1. Read the validator's recent commit history: `git log --oneline -20 platform/validators/validate-<name>.sh` (run inside the submodule).
2. Cross-reference the failure message against the [troubleshooting guide](troubleshooting.md). If a new error code appeared, it will be documented there.
3. Decide whether the new behavior is a bug fix (fix your artifacts) or a tightening (decide whether to comply, override, or pin to the previous version).

Validator changes that *tighten* rules should be paired with an upstream ADR — read it before acting. If you cannot find an ADR explaining a tightened rule, open an issue: the upstream contract is that validator changes are themselves documented changes.

---

## Drift & Recovery

### Detecting Drift in Copy-Mode Projects

Copy-mode projects accumulate drift the longer they run. Skills, validators, and templates that were copied at adoption time slowly fall behind upstream. There is no automated detector for this — copy mode trades drift detection for simplicity.

To audit a copy-mode project against upstream:

```bash
# Fetch the current upstream into a sibling directory
git clone https://github.com/unclenate/auto-harness ../auto-harness-upstream

# Diff your copied files against upstream
diff -r .agents/skills/harness-governance ../auto-harness-upstream/platform/skills/harness-governance
diff -r .claude/skills/harness-governance ../auto-harness-upstream/platform/skills/harness-governance

# Repeat for every skill, composition, template you originally copied
```

Schedule this audit on a calendar cadence — quarterly is reasonable. The drift detection effort is itself a strong signal that copy mode is the wrong long-term shape; see [Migrating from Copy Mode to Submodule](#migrating-from-copy-mode-to-submodule) below for the migration path.

### Migrating from Copy Mode to Submodule

If your project currently uses copy-mode adoption and you want to switch to the recommended submodule pattern, the migration is mostly removal followed by re-bootstrapping:

```bash
# 1. Remove the copied artifacts (harness-managed, not foreign files)
rm -rf .agents/skills/harness-governance .agents/skills/harness-onboarding
rm -rf .claude/skills/harness-governance .claude/skills/harness-onboarding
# Repeat for every harness-managed skill you previously copied.
# Do NOT remove .agents/skills/ or .claude/skills/ as a whole if you have
# foreign skills (from other platforms) installed there.

# 2. Add the submodule
git submodule add https://github.com/unclenate/auto-harness .harness
git commit -m "chore: add auto-harness as submodule"

# 3. Run the bootstrap — it will recreate the symlinks pointing into the submodule
bash .harness/platform/bootstrap/install.sh --dry-run    # preview
bash .harness/platform/bootstrap/install.sh

# 4. Run the validator chain to confirm parity with your prior state
bash .harness/platform/validators/validate-manifest.sh harness.manifest.yaml
bash .harness/platform/validators/validate-module-graph.sh harness.manifest.yaml
bash .harness/platform/validators/validate-required-artifacts.sh harness.manifest.yaml .

# 5. Commit
git add .agents/ .claude/
git commit -m "chore: switch from copy-mode to submodule for auto-harness"
```

If your previous copy-mode artifacts had been hand-modified, those modifications are now lost. Capture them as a separate commit on `main` before starting the migration so they can be re-applied (or, better, upstreamed via PR against auto-harness so future versions include them).

### Symlink Re-initialization After Submodule Operations

Some operations — submodule re-initialization, deep clones on platforms with different symlink defaults, switching branches that have different submodule states — can leave the `.agents/skills/<name>` or `.claude/skills/<name>` symlinks broken.

To check:

```bash
ls -la .agents/skills/
```

A broken symlink shows up as `lrwxr-xr-x` pointing to a non-existent path. To fix, re-run `link-skills.sh`:

```bash
bash .harness/platform/bootstrap/link-skills.sh
```

`link-skills.sh` is the bash-only component of the bootstrap and does not require Ruby. It re-creates the symlinks idempotently.

**On Windows**, symlinks are disabled in git by default. If your symlinks aren't following at all, enable them globally and re-initialize the submodule:

```bash
git config --global core.symlinks true
git submodule update --force --recursive
```

This is a one-time configuration. After enabling, all future clones and updates honor symlinks correctly.

### Recovering from "harness skills dir not found"

`link-skills.sh` reports this if `.harness/platform/skills/` does not exist on disk. The submodule is registered in `.gitmodules` but has not been initialized:

```bash
git submodule update --init --recursive
```

This populates the submodule directory. After it completes, re-run `link-skills.sh` to recreate the symlinks.

---

## Lifecycle Transitions

### Prototype → MVP → Production

A project's harness composition evolves with its maturity. The kernel doctrine permits — and expects — modules to swap as the project's lifecycle stage advances.

| From | To | What changes |
| ---- | -- | ------------ |
| `delivery/prototype` | `delivery/production-saas` | Swap module; new required artifacts appear (environment inventory, release checklist, risk register, rollback checklist, runbook index) |
| `management/discovery-intake` active | Promote to `management/product-lite` and `management/project-standard` | Discovery artifacts archive; product and project artifacts become canonical |
| `management/product-lite` | `management/product-lite` + introduction of PRDs | No module change; behavioral change — significant requirements changes now require a PRD |

To make the transition cleanly:

1. **Update `harness.manifest.yaml`** — change the module declaration.
2. **Run `bash platform/validators/validate-required-artifacts.sh harness.manifest.yaml .`** — the validator will list every new required artifact the swap introduced.
3. **Create the missing artifacts** from `platform/templates/`. Fill in `[[PLACEHOLDER_NAME]]` tokens.
4. **If `required-artifacts` was disabled** during earlier phases, re-enable it now.
5. **Update `HARNESS.md`** to reflect the new lifecycle stage. The harness-governance skill's companion rule requires an ADR or `docs/operating-principles.md` update when `HARNESS.md` changes — fold the lifecycle-stage transition into one of those.
6. **Log the transition in `docs/project/change-log.md`** with a brief rationale.

A lifecycle transition is itself a governance event. Do it deliberately and document it.

### Periodic Governance Audits

Governance erodes silently. Validators may be disabled "temporarily" and forgotten. Skills may have been installed at adoption but never updated. Companion rules may be silently violated through misuse of `--no-verify` commits or branch-protection bypasses.

Run a governance audit on a calendar cadence — quarterly is a reasonable default for active projects.

**Audit checklist:**

| Check | How |
| ----- | --- |
| Are any validators in `disabledValidations` no longer needed? | `cat harness.manifest.yaml \| yq '.overrides.disabledValidations'` and review each |
| Are all skills current? | `git submodule status .harness` (submodule mode) or diff against upstream (copy mode) |
| Is the trust tier in `HARNESS.md` still appropriate? | Review against actual practice — are agents operating at the declared tier? |
| Are companion rules being honored? | Spot-check recent PRs: changes to sensitive paths should have paired artifact updates |
| Are required artifacts genuinely current? | Open each one in `requiredArtifacts` and confirm it reflects current state, not the state at adoption |
| Are there orphaned templates? | Files containing `[[PLACEHOLDER_NAME]]` that escaped the placeholder validator |
| Is CI running the full validator chain? | `cat .github/workflows/harness.yml` (or your CI's equivalent) and confirm every validator is wired |

Record the audit outcome as an entry in `docs/project/change-log.md` (type: Governance) with the date and any actions taken. Treat this as another companion-rule artifact: visible, traceable, audit-able.

---

## Reference

| Topic | Path |
| ----- | ---- |
| Submodule adoption (first-time setup) | [submodule-integration.md](submodule-integration.md) |
| Bootstrap quickstart (greenfield, copy-mode) | [bootstrap-quickstart.md](bootstrap-quickstart.md) |
| Brownfield onboarding (existing codebase) | [brownfield-onboarding.md](brownfield-onboarding.md) |
| CI integration (validator wiring) | [ci-integration.md](ci-integration.md) |
| Validator error solver | [troubleshooting.md](troubleshooting.md) |
| Trust tier model | `platform/core/kernel/base/trust-model.md` |
| Kernel doctrine | `platform/core/kernel/base/doctrine.md` |
| Submodule integration ADR | `docs/adr/ADR-0003-submodule-integration.md` |
| Open-source cut decision | `docs/adr/ADR-0005-open-source-cut.md` |
