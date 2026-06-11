# Issue #88 — sensitive-paths composition coverage + disable lever — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `validate-sensitive-paths` pass on every shipped composition, honor the `disabledValidations` escape hatch, and gate the class in CI.

**Architecture:** Affirm one meaning for `sensitivePaths` (companion-backed elevated-review surfaces) and resolve every uncovered pattern by self-coverage — fold each orphan into its own module's `companionRules.triggerPaths` (the PR #114 precedent). Add the `disabled_validation?` early-return to the validator (Bug B). Run the validator over `platform/compositions/*.yaml` in CI + an integration test (prevention).

**Tech Stack:** Bash validators, Ruby (HarnessRegistry lib + Minitest integration tests), YAML module manifests, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-06-10-sensitive-paths-coverage-and-disable-design.md`

**Branch:** `fix-88-sensitive-paths` (already created; the spec is committed there as `a74b144`).

**Sequencing:** Task 1 (Bug B) → Tasks 2–8 (module self-coverage, parallelizable) → Task 9 (composition gate green) → Task 10 (satisfiers) → Tasks 11–12 (prevention) → Task 13 (verify + PR).

---

## Task 1: Bug B — validator honors `disabledValidations`

**Files:**
- Modify: `platform/validators/validate-sensitive-paths.sh` (insert after line 147, before `active_modules =`)
- Test: `platform/validators/test/test_validators_integration.rb` (add a method to `class TestValidateSensitivePaths`)

- [ ] **Step 1: Write the failing test.** In `test_validators_integration.rb`, inside `class TestValidateSensitivePaths` (after `test_runs_clean_against_harness_repo`), add:

```ruby
  def test_disabled_validation_exits_zero
    # A manifest that disables sensitive-paths must exit 0 with the override
    # message, even though the early-return fires before module enumeration.
    Dir.mktmpdir do |tmpdir|
      manifest_path = File.join(tmpdir, "harness.manifest.yaml")
      File.write(manifest_path, <<~YAML)
        schemaVersion: 1
        project:
          id: test-disabled-sp
          name: Test Disabled Sensitive Paths
          maturity: prototype
          criticality: low
        modules:
          core:
            - kernel/base
          management:
            - product-lite
        overrides:
          disabledValidations:
            - sensitive-paths
      YAML

      out, err, code = run_validator("validate-sensitive-paths.sh", manifest_path, HARNESS_ROOT)
      assert_equal 0, code, "Disabled sensitive-paths validation should exit 0. stderr: #{err}"
      assert_match(/disabled/i, out)
    end
  end
```

- [ ] **Step 2: Run the test to verify it fails.**

Run: `ruby -I platform/validators/lib platform/validators/test/test_validators_integration.rb -n /TestValidateSensitivePaths/ 2>&1 | tail -8`
Expected: FAIL — `test_disabled_validation_exits_zero` (validator still enumerates modules and exits 0 only because product-lite/kernel happen to pass, or asserts `/disabled/i` not found → failure on the `assert_match`).

- [ ] **Step 3: Add the early-return.** In `platform/validators/validate-sensitive-paths.sh`, between the manifest-load `end` (line 147) and `active_modules = ...` (line 149), insert:

```ruby
end

if HarnessRegistry.disabled_validation?(manifest, "sensitive-paths")
  puts "✓ Sensitive-paths validation disabled by manifest override"
  exit 0
end

active_modules = HarnessRegistry.active_modules(platform_root, manifest)
```

(The blank line + `if` block go after the existing `end`; `active_modules =` is the existing line 149 — keep it.)

- [ ] **Step 4: Run the test to verify it passes.**

Run: `ruby -I platform/validators/lib platform/validators/test/test_validators_integration.rb -n /TestValidateSensitivePaths/ 2>&1 | tail -6`
Expected: PASS (all `TestValidateSensitivePaths` tests, including the new one).

- [ ] **Step 5: Shellcheck the validator.**

Run: `shellcheck platform/validators/validate-sensitive-paths.sh && echo OK`
Expected: `OK` (no findings).

- [ ] **Step 6: Commit.**

```bash
git add platform/validators/validate-sensitive-paths.sh platform/validators/test/test_validators_integration.rb
git commit -m "fix(validate-sensitive-paths): honor overrides.disabledValidations (Bug B, #88)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Tasks 2–8: Bug A — module self-coverage

Each task adds the uncovered `sensitivePaths` pattern(s) to that module's own
`companionRules.triggerPaths`. These are independent (different files) and may run in
parallel. After each edit, the per-module verification confirms the offending pattern is
now covered. **Match the exact indentation of the surrounding list items (4 spaces +
`- `).** Do NOT commit per-module; a single Bug-A commit lands in Task 9.

### Task 2: `digital-twin`

**Files:** Modify `platform/profiles/management/digital-twin/module.yaml`

- [ ] **Step 1.** In the first companion rule (`description: Scenario/model/agent/dataset/run-state changes...`), the `triggerPaths:` list currently ends with `- ^simulation/`. Add two entries so the list reads:

```yaml
    triggerPaths:
      - ^scenarios/
      - ^models/
      - ^agents/
      - ^datasets/
      - ^simulation/
      - ^data/
      - ^public/scenarios/
```

- [ ] **Step 2: Verify.** Run: `bash platform/validators/validate-sensitive-paths.sh platform/compositions/digital-twin-prototype.yaml 2>&1 | tail -2`
Expected: `✓ All N sensitive-path patterns are companion-rule covered.`

### Task 3: `node-typescript`

**Files:** Modify `platform/profiles/stacks/node-typescript/module.yaml`

- [ ] **Step 1.** In the `description: Major dependency or runtime changes...` rule, the `triggerPaths:` list ends with `- ^\.nvmrc$`. Add `- ^tsconfig\.` so it reads:

```yaml
    triggerPaths:
      - ^package\.json$
      - ^package-lock\.json$
      - ^pnpm-lock\.yaml$
      - ^yarn\.lock$
      - ^\.nvmrc$
      - ^tsconfig\.
```

- [ ] **Step 2: Verify.** Run: `bash platform/validators/validate-sensitive-paths.sh platform/compositions/mcp-server-typescript.yaml 2>&1 | tail -2`
Expected: `✓ All N sensitive-path patterns are companion-rule covered.`

### Task 4: `testing-standard`

**Files:** Modify `platform/profiles/management/testing-standard/module.yaml`

- [ ] **Step 1.** The two existing companion rules trigger only on `coverage-thresholds.md` and `test-strategy.md`. Add a THIRD companion rule covering the test/build config files. After the second rule (`description: Test strategy changes...`) block, append a new list item at the same indentation:

```yaml
  - description: Test or build configuration changes affect the quality gates — require a change-log entry, ADR, or PRD
    triggerPaths:
      - ^jest\.config
      - ^vitest\.config
      - ^pytest\.ini$
      - ^pyproject\.toml$
      - ^setup\.cfg$
    requiredAny:
      - ^docs/project/change-log\.md$
      - ^docs/adr/ADR-
      - ^docs/requirements/PRD-
```

- [ ] **Step 2: Verify.** Run: `bash platform/validators/validate-sensitive-paths.sh platform/compositions/python-api-service-postgres.yaml 2>&1 | tail -2`
Expected: `✓ All N sensitive-path patterns are companion-rule covered.`

### Task 5: `web3`

**Files:** Modify `platform/profiles/domains/web3/module.yaml`

- [ ] **Step 1.** In the third companion rule (`description: Scoring or signal rule changes require an ADR...`), the `triggerPaths:` list currently ends with `- ^src/signals/`. Add `- ^src/agents/` so it reads:

```yaml
    triggerPaths:
      - scoring_rules
      - signal_weights
      - ^src/scoring/
      - ^src/signals/
      - ^src/agents/
```

- [ ] **Step 2: Verify.** Run: `bash platform/validators/validate-sensitive-paths.sh platform/compositions/web3-risk-analytics.yaml 2>&1 | tail -2`
Expected: `✓ All N sensitive-path patterns are companion-rule covered.`

### Task 6: `self-hosted-oss` (enforce release-intent, remove `^CHANGELOG`)

**Files:** Modify `platform/profiles/delivery/self-hosted-oss/module.yaml`

- [ ] **Step 1a — remove `^CHANGELOG` from sensitivePaths.** In the second `sensitivePaths` block (`description: Release/versioning surface...`), delete the `- ^CHANGELOG` line so the block reads:

```yaml
  - description: Release/versioning surface for the distributable artifact
    patterns:
      - ^docs/product/release-intent\.md$
```

(Per spec maintainer-decision 1: the changelog is itself the audit record; requiring a companion to edit it is backwards.)

- [ ] **Step 1b — enforce `release-intent.md`.** Add a SECOND companion rule (after the existing install/deploy rule) covering the release surface:

```yaml
  - description: Release-intent changes require a self-hosting-guide update, change-log entry, or ADR — the release surface is what every downstream operator consumes
    triggerPaths:
      - ^docs/product/release-intent\.md$
    requiredAny:
      - ^docs/deployment/self-hosting-guide\.md$
      - ^docs/project/change-log\.md$
      - ^docs/adr/ADR-
```

- [ ] **Step 2: Verify.** Run: `bash platform/validators/validate-sensitive-paths.sh platform/compositions/mcp-server-typescript-oss.yaml 2>&1 | tail -2`
Expected: `✓ All N sensitive-path patterns are companion-rule covered.`

### Task 7: `healthcare-fhir`

**Files:** Modify `platform/profiles/domains/healthcare-fhir/module.yaml`

- [ ] **Step 1.** In the second companion rule (`description: PHI-schema-touching changes require a risk-register update`), the `triggerPaths:` list currently reads `- ^src/FHIR/` and `- ^fhir/`. Add the four PHI content markers so it reads:

```yaml
    triggerPaths:
      - ^src/FHIR/
      - ^fhir/
      - patient
      - observation
      - bundle
      - phi
```

(Per spec maintainer-decision 2: enforce as-is; narrowing `bundle` is a separate follow-up.)

- [ ] **Step 2: Verify.** Run: `bash platform/validators/validate-sensitive-paths.sh platform/compositions/healthcare-fhir-app.yaml 2>&1 | tail -3`
Expected: the `healthcare-fhir` lines disappear from the uncovered list (smart-on-fhir lines remain until Task 8).

### Task 8: `healthcare-smart-on-fhir`

**Files:** Modify `platform/profiles/domains/healthcare-smart-on-fhir/module.yaml`

- [ ] **Step 1.** In the second companion rule (`description: SMART implementation and auth-surface changes...`), the `triggerPaths:` list currently reads `- ^src/FHIR/SMART/` and `- ^auth/`. Add the three auth markers so it reads:

```yaml
    triggerPaths:
      - ^src/FHIR/SMART/
      - ^auth/
      - launch
      - token
      - oauth
```

- [ ] **Step 2: Verify.** Run: `bash platform/validators/validate-sensitive-paths.sh platform/compositions/healthcare-fhir-app.yaml 2>&1 | tail -2`
Expected: `✓ All N sensitive-path patterns are companion-rule covered.`

---

## Task 9: Bug A — all compositions green + commit

**Files:** none (verification + commit of Tasks 2–8)

- [ ] **Step 1: Verify every shipped composition passes.**

Run:
```bash
fail=0; for c in platform/compositions/*.yaml; do
  bash platform/validators/validate-sensitive-paths.sh "$c" >/dev/null 2>&1 || { echo "RED: $c"; fail=1; }
done; [ $fail -eq 0 ] && echo "ALL COMPOSITIONS GREEN"
```
Expected: `ALL COMPOSITIONS GREEN`

- [ ] **Step 2: Confirm the harness's own suite still passes (no self-coverage regression).**

Run: `bash platform/validators/validate-sensitive-paths.sh 2>&1 | tail -1`
Expected: `✓ All 11 sensitive-path patterns are companion-rule covered.`

- [ ] **Step 3: Commit the module edits.**

```bash
git add platform/profiles/management/digital-twin/module.yaml \
        platform/profiles/stacks/node-typescript/module.yaml \
        platform/profiles/management/testing-standard/module.yaml \
        platform/profiles/domains/web3/module.yaml \
        platform/profiles/delivery/self-hosted-oss/module.yaml \
        platform/profiles/domains/healthcare-fhir/module.yaml \
        platform/profiles/domains/healthcare-smart-on-fhir/module.yaml
git commit -m "fix(modules): self-cover all sensitivePaths via companion triggerPaths (Bug A, #88)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 10: distillation + audit-trail satisfiers (paired companion rules)

The seven `module.yaml` edits are PRD-0004 distillation triggers; the shared-observations
touch then triggers the audit-trail rule. (See PR #114 — the same cascade.)

**Files:**
- Modify: `docs/knowledge/shared-observations.md` (append observation + bump `Last Updated` Prior chain)
- Modify: `docs/project/change-log.md` (new dated entry at top, after the `---`)

- [ ] **Step 1: Append the distillation observation** at the end of `docs/knowledge/shared-observations.md`:

```markdown

### A catalog-wide `sensitivePaths` audit generalizes the PR #114 self-coverage fix — every module must enforce its own declared sensitive surface

- **Context:** Issue #88. `validate-sensitive-paths` (OPP-0034/ADR-0017) requires every active `sensitivePath` to overlap an active companion `triggerPath`. Eight of 13 shipped compositions failed across seven modules (digital-twin, node-typescript, testing-standard, web3, self-hosted-oss, healthcare-fhir, healthcare-smart-on-fhir) — each declared sensitive paths it never enforced. This is the catalog-wide form of the single-module gap PR #114 fixed for privacy-by-design.
- **Observation:** `sensitivePaths` was being used for two superficially-similar purposes — path-prefix markers (`^tsconfig\.`, `^data/`) that genuinely warrant companion-backed review, and unanchored content-keyword markers (`patient`, `oauth`) that read as "flag files mentioning this term." The overlap invariant is coherent only for the former. The fix that preserves the validator's doctrine without a schema or validator change is **self-coverage**: fold each orphan into its own module's companion rule. The content-keyword cases resolve the same way because the modules that declared them (healthcare, SMART-on-FHIR) are opt-in domains whose purpose IS heightened PHI/auth governance — so "touching a PHI/auth surface requires a risk-register/ADR" is the intended contract, not over-enforcement. One genuinely-miscategorized marker (`^CHANGELOG`) was removed rather than enforced (the changelog is itself the audit record).
- **Implication:** When auditing a cross-cutting structural validator, the failure set is a map of where a declared-but-unenforced policy accreted. Resolve by making the declaring unit self-sufficient (declare-layer ⊆ enforce-layer within the module), not by relaxing the validator — relaxation reopens the gap the validator exists to close. Gate the class by running the validator over the project's own example compositions in CI, so the examples can't silently re-accrete the gap.
- **Confidence:** medium-high. Seven modules across four module types (stack, management, domain, delivery) resolved by one mechanism; the validator's dogfood run and the per-composition run are the evidence.
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-10 (satisfies the PRD-0004 distillation rule fired by the seven modified `platform/profiles/**/module.yaml`; substantive connection — generalizes the PR #114 single-module self-coverage observation into a catalog-wide audit principle and the "gate-examples-in-CI" prevention, rather than restating the issue)
```

- [ ] **Step 2: Bump the `Last Updated` line** at the top of `docs/knowledge/shared-observations.md`. Find the segment `*(privacy-by-design self-coverage fix:` and replace with a new note that demotes the existing one into the `Prior:` chain:

```
*(Issue #88 sensitivePaths catalog audit: folded every uncovered sensitivePath across seven modules into its own companion triggerPaths (self-coverage, generalizing PR #114), added the disabledValidations escape hatch to validate-sensitive-paths.sh, and gated the class by running the validator over shipped compositions in CI; appended the catalog-wide self-coverage observation. Satisfies the PRD-0004 distillation rule fired by the seven modified module.yaml files. Prior: 2026-06-10 privacy-by-design self-coverage fix:
```

(Leave everything from `added \`^auth/\`` onward unchanged — this only injects the new note ahead of the prior one.)

- [ ] **Step 3: Add the change-log entry.** In `docs/project/change-log.md`, immediately after the first `---` (before the most recent `## 2026-06-10` heading), insert:

```markdown

## 2026-06-10 — sensitive-paths: composition coverage + disable lever (Issue #88)

`validate-sensitive-paths` required every active `sensitivePath` to overlap a companion
`triggerPath`, but eight of 13 shipped compositions failed across seven modules that
declared sensitive paths they never enforced. Resolved by **self-coverage** — each orphan
folded into its own module's companion rule (generalizing PR #114): `digital-twin`
(`^data/`, `^public/scenarios/`), `node-typescript` (`^tsconfig\.`), `testing-standard`
(jest/vitest/pytest/pyproject/setup config), `web3` (`^src/agents/`), `self-hosted-oss`
(`release-intent.md`; `^CHANGELOG` removed as miscategorized), `healthcare-fhir`
(patient/observation/bundle/phi → risk-register), `healthcare-smart-on-fhir`
(launch/token/oauth → risk-register).

Also fixed **Bug B**: `validate-sensitive-paths.sh` now honors
`overrides.disabledValidations: [sensitive-paths]` (the documented consumer escape hatch),
matching the three sibling validators. **Prevention:** CI + an integration test now run the
validator over every `platform/compositions/*.yaml`. No change to the overlap algorithm or
the validator's doctrine.
```

- [ ] **Step 4: Markdownlint the touched docs.**

Run: `markdownlint-cli2 docs/knowledge/shared-observations.md docs/project/change-log.md 2>&1 | tail -2`
Expected: `Summary: 0 error(s)`

- [ ] **Step 5: Commit.**

```bash
git add docs/knowledge/shared-observations.md docs/project/change-log.md
git commit -m "docs(distillation+changelog): Issue #88 catalog-wide self-coverage audit (PRD-0004)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 11: Prevention — composition integration test + Bug-B regression already in Task 1

**Files:** Modify `platform/validators/test/test_validators_integration.rb` (add to `class TestValidateSensitivePaths`)

- [ ] **Step 1: Write the composition-sweep test.** Inside `class TestValidateSensitivePaths`, add:

```ruby
  def test_all_shipped_compositions_are_covered
    # Every shipped composition must pass sensitive-paths — the project's own
    # examples gate the "declared-but-unenforced sensitivePath" class (Issue #88).
    compositions = Dir.glob(File.join(HARNESS_ROOT, "platform", "compositions", "*.yaml"))
    refute_empty compositions, "expected shipped compositions to exist"
    failures = compositions.reject do |c|
      _out, _err, code = run_validator("validate-sensitive-paths.sh", c, HARNESS_ROOT)
      code.zero?
    end
    assert_empty failures.map { |f| File.basename(f) },
                 "these shipped compositions have uncovered sensitivePaths"
  end
```

- [ ] **Step 2: Run it to verify it passes** (Tasks 2–8 already made compositions green).

Run: `ruby -I platform/validators/lib platform/validators/test/test_validators_integration.rb -n /TestValidateSensitivePaths/ 2>&1 | tail -6`
Expected: PASS (all methods, including `test_all_shipped_compositions_are_covered`).

- [ ] **Step 3: Commit.**

```bash
git add platform/validators/test/test_validators_integration.rb
git commit -m "test(sensitive-paths): gate all shipped compositions (prevention, #88)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 12: Prevention — CI step over compositions

**Files:** Modify `.github/workflows/harness.yml` (Validators job)

- [ ] **Step 1: Locate the Validators job's last validator step.** Run: `grep -n "Validate sensitive paths\|Validate companion rules\|run: bash platform/validators/validate-sensitive-paths" .github/workflows/harness.yml`
Find the existing "Validate sensitive paths" step.

- [ ] **Step 2: Add a step** immediately after the existing "Validate sensitive paths" step, matching the surrounding YAML indentation:

```yaml
      - name: Validate sensitive paths over shipped compositions
        run: |
          fail=0
          for c in platform/compositions/*.yaml; do
            if ! bash platform/validators/validate-sensitive-paths.sh "$c" >/dev/null 2>&1; then
              echo "✗ uncovered sensitivePaths in $c"; fail=1
            fi
          done
          if [ "$fail" -ne 0 ]; then echo "Some shipped compositions have uncovered sensitivePaths"; exit 1; fi
          echo "✓ All shipped compositions pass sensitive-paths"
```

- [ ] **Step 3: Lint the workflow (if actionlint available; else skip).**

Run: `command -v actionlint >/dev/null && actionlint .github/workflows/harness.yml || echo "actionlint not installed — skipping (CI will validate)"`
Expected: no errors, or the skip message.

- [ ] **Step 4: Commit.**

```bash
git add .github/workflows/harness.yml
git commit -m "ci(validators): run sensitive-paths over shipped compositions (prevention, #88)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Task 13: Full verification + PR

**Files:** none

- [ ] **Step 1: Run the full validator integration suite.**

Run: `ruby platform/validators/test/test_validators_integration.rb 2>&1 | tail -3`
Expected: `... 0 failures, 0 errors, 0 skips` (run count ≥ 148, two new tests added).

- [ ] **Step 2: Run the diff-mode companion + knowledge-redaction validators** (Task 10 touched a distillation trigger + a knowledge destination):

```bash
bash platform/validators/validate-companions.sh harness.manifest.yaml . main; echo "companions rc=$?"
bash platform/validators/validate-knowledge-redaction.sh . main; echo "redaction rc=$?"
```
Expected: both `✓` and `rc=0`.

- [ ] **Step 3: Run catalog-counts + shellcheck + markdownlint.**

```bash
bash platform/validators/validate-catalog-counts.sh 2>&1 | tail -1
shellcheck platform/validators/validate-sensitive-paths.sh && echo "shellcheck OK"
markdownlint-cli2 docs/knowledge/shared-observations.md docs/project/change-log.md 2>&1 | tail -1
```
Expected: counts ✓, shellcheck OK, markdownlint `0 error(s)`.

- [ ] **Step 4: Push + open PR.**

```bash
git push -u origin fix-88-sensitive-paths
gh pr create --base main --head fix-88-sensitive-paths \
  --title "fix(sensitive-paths): composition coverage + disable lever (Issue #88)" \
  --body "Closes #88. Self-coverage across 7 modules + Bug B escape hatch + CI gate over compositions. See docs/superpowers/specs/2026-06-10-sensitive-paths-coverage-and-disable-design.md.

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
```

- [ ] **Step 5: Holistic review** — dispatch a fresh subagent over `git diff main...HEAD` for cross-doc consistency (count/enforcement-semantics drift, prose accuracy, the two maintainer-decision items applied as specified). Fix any findings forward.

- [ ] **Step 6: Confirm CI green** (10/10) before declaring done. Do NOT merge (Tier 3 — await explicit direction).

---

## Self-Review (completed by plan author)

- **Spec coverage:** Bug A (Tasks 2–9) ✓; Bug B (Task 1) ✓; Prevention CI (Task 12) + test (Task 11) ✓; distillation/audit-trail cascade (Task 10) ✓; both maintainer-decisions applied (Task 6 removes `^CHANGELOG`; Task 7 enforces `bundle` as-is) ✓; acceptance criteria mapped to Tasks 9/1/12/13. 
- **Placeholder scan:** every edit shows exact YAML/code; no TBD/TODO. `N` in expected validator output is the live pattern count (intentionally not hard-coded — it varies per composition and isn't asserted).
- **Type/name consistency:** disable key `"sensitive-paths"` matches the documented override + sibling convention; test method names unique within `TestValidateSensitivePaths`; module/file paths verified against the repo.
