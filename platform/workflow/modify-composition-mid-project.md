<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Modifying Composition Mid-Project

## Adding, Changing, or Removing Modules in an Active Manifest

[`bootstrap-quickstart.md`](bootstrap-quickstart.md) and
[`brownfield-onboarding.md`](brownfield-onboarding.md) cover *initial*
composition. [`maintenance-operations.md`](maintenance-operations.md)
covers *keeping the harness current*. This document covers the
in-between case: **a consumer project with an active manifest that
needs to change which modules are active.**

> **Visual:** the [Consumer Adoption Flow diagram](../../docs/architecture/diagrams.md#6-consumer-adoption-flow)
> shows the end-to-end initial adoption. This workflow is what
> happens *after* "Ready" when the consumer's needs evolve.

---

## When You Need This

Common triggers for re-composing:

- The project scope has grown (e.g., adding web3 functionality —
  needs the web3 domain module + skill)
- The project is maturing (moving from `delivery/prototype` to
  `delivery/production-saas`)
- A subsystem is being sunset (removing modules that govern code that
  no longer exists)
- A new module became available upstream (auto-harness shipped a
  capability you now want — e.g., `management/knowledge-capture` for
  institutional learning)
- An audit revealed an active module isn't being used (clean removal
  vs. dead policy)

The harness's modular composition is designed to be opt-in
*incrementally* — including incremental subtraction. This workflow
makes the operational mechanics explicit.

---

## Three Operations

### A. Adding a Module

1. **Confirm the module is appropriate.** Read its README in
   `platform/profiles/<family>/<module>/README.md`. Check
   `dependsOn` and `conflictsWith`.

2. **Update `harness.manifest.yaml`.** Add the module name under the
   correct family list. Bump the manifest revision marker if you
   maintain one.

3. **Resolve dependencies.** Run `validate-module-graph.sh`. It
   surfaces any unmet `dependsOn` or active `conflictsWith` —
   resolve before continuing.

4. **Scaffold required artifacts.** Run
   `validate-required-artifacts.sh`. For each missing artifact:
   - Copy the matching template from `platform/templates/`
   - Fill placeholders (the new template-derived files will have
     tokenized headers; run
     [`set-consumer-headers.sh`](../bootstrap/set-consumer-headers.sh)
     to fill the header tokens project-wide using your existing
     `.harness-headers.yaml` config)
   - Fill per-record tokens (`[[OWNER]]`, `[[ADR_TITLE]]`, etc.)
     manually per artifact

5. **Wire companion rules.** Each module's `companionRules`
   automatically apply once the manifest activates the module. No
   manual config; `validate-companions.sh` reads from the live manifest.

6. **Run the full validator chain.** All 8 validators should exit 0.

7. **Open a PR.** The new companion rules will fire against the diff;
   if your scaffolded artifacts satisfy them by construction, CI passes.

8. **Update catalog claims.** If your project documents its active
   module count anywhere (uncommon for consumers; common for the
   harness itself), update those claims.

### B. Removing a Module

1. **Inventory what depends on it.** Run
   `validate-module-graph.sh` *after* hypothetically removing the
   module — it will surface broken `dependsOn` chains. If other
   active modules depend on this one, you can't cleanly remove it
   without removing them too.

2. **Inventory what artifacts it required.** Read the module's
   `module.yaml` `requiredArtifacts:` list. Decide for each: does the
   project still need this artifact for other reasons, or can it be
   deleted?

3. **Inventory what companion rules fire on its artifacts.** Other
   active modules may have rules that trigger on paths the removed
   module produced. Removing the module without removing those paths
   leaves dead rules.

4. **Update `harness.manifest.yaml`.** Delete the module name from
   its family list.

5. **Delete unused required artifacts.** Per step 2, anything that's
   strictly orphaned by the removal.

6. **Run the full validator chain.** Special attention to
   `validate-required-artifacts.sh` (should find nothing missing
   *because* the requirements list shrank) and
   `validate-companions.sh` (should find no broken trigger sets).

7. **Update catalog claims** as in step 8 of "Adding a Module."

### C. Changing Manifests (Composition Shift)

The most common case: a `prototype` project graduates to
`production-saas`. Or `interview-driven` discovery completes and the
project shifts to `discovery-intake`. The mechanics are
*remove old, add new* in a single PR.

1. **Identify the swap.** What module(s) are leaving and what's
   replacing them?

2. **Compare required-artifact sets.** Run
   `validate-required-artifacts.sh` against the *current* manifest
   to see what's required now. Mentally compare to the new
   composition's requirements (cross-reference both modules'
   `module.yaml`).

3. **Identify net-new requirements.** Artifacts the new module requires
   but the old one didn't. Scaffold these first.

4. **Identify net-removed requirements.** Artifacts the old module
   required but the new one doesn't. Decide per-file whether to keep
   (project still benefits) or delete (orphaned).

5. **Single-commit swap.** Edit the manifest's module list (remove old,
   add new) plus scaffold/delete artifacts as identified.

6. **Run the full validator chain.**

7. **Companion rules will shift** — the old module's rules stop
   firing; the new module's rules start firing. Verify this matches
   your intent before opening the PR.

---

## Sunset: Removing auto-harness Adoption Entirely

Rare but worth documenting. If a project decides to stop using
auto-harness:

1. **Remove the submodule (or copied platform/).**
   `git submodule deinit -f .harness && git rm -f .harness`

2. **Delete harness-managed entrypoints.** `HARNESS.md`,
   `harness.manifest.yaml`, `.harness-headers.yaml`. Edit `AGENTS.md`
   to remove the harness-managed section (the marker comments make
   the boundary obvious).

3. **Decide on artifacts.** Most harness-required artifacts
   (`docs/adr/`, `docs/requirements/`, `docs/operating-principles.md`,
   etc.) are genuinely useful project artifacts — keep them.
   `harness.manifest.yaml` and `HARNESS.md` are harness-specific —
   remove.

4. **Remove CI workflow steps.** Delete the validator invocations
   from `.github/workflows/`.

5. **Remove skill symlinks.** `rm -rf .agents/skills/ .claude/skills/`
   (or the specific symlinks you created — `link-skills.sh` tracked
   what it installed).

6. **Audit for orphaned references.** `grep -rE
   "harness|HARNESS" .` will surface any lingering references in
   docs that need updating.

The harness's "observation-first" bootstrap discipline (never
overwriting foreign files) means sunset is symmetric: you can leave
auto-harness as cleanly as you adopted it.

---

## Common Pitfalls

| Pitfall | What happens | Fix |
|---------|--------------|-----|
| Add module but forget to scaffold required artifacts | `validate-required-artifacts.sh` fails | Run validator; copy templates; fill tokens |
| Remove module but keep artifacts that other modules require | `validate-required-artifacts.sh` may still pass (if other modules require the same artifacts) — silent | Cross-check what's truly orphaned vs. shared |
| Remove module but the manifest still lists it under `dependsOn` of another module | `validate-module-graph.sh` fails | Resolve dependency before removing |
| Forget to run `set-consumer-headers.sh` after scaffolding | `validate-placeholders.sh` fails on the new template-derived files | Run the helper; templates fill from `.harness-headers.yaml` |
| Composition shift breaks companion rules silently | A trigger path is no longer being triggered because the path no longer exists | Read the new module's rules; verify intent matches reality |

---

## Self-Audit: What's My Current Composition?

A quick triage when picking up an unfamiliar consumer project:

```bash
# What modules are active?
grep -E "^\s+-\s" harness.manifest.yaml

# What required artifacts exist?
bash .harness/platform/validators/validate-required-artifacts.sh \
  harness.manifest.yaml .

# What companion rules are active?
# (No standalone tool; read each active module's module.yaml)
for mod in $(grep -E "^\s+-\s" harness.manifest.yaml | tr -d ' -'); do
  echo "=== $mod ==="
  cat .harness/platform/profiles/*/$mod/module.yaml 2>/dev/null | \
    grep -A 50 "^companionRules:"
done
```

(A proper composition-introspection tool is a future-work item.)

---

## References

- [`bootstrap-quickstart.md`](bootstrap-quickstart.md) — initial adoption
- [`brownfield-onboarding.md`](brownfield-onboarding.md) — existing-project adoption
- [`maintenance-operations.md`](maintenance-operations.md) — pulling upstream changes
- [`platform/core/kernel/base/`](../core/kernel/base/README.md) — kernel + schema
- [Component Composition diagram](../../docs/architecture/diagrams.md#1-component-composition)
- [Consumer Adoption Flow diagram](../../docs/architecture/diagrams.md#6-consumer-adoption-flow)
