<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Implementation Log: Auto-Harness Submodule Integration

This log records the step-by-step journey of implementing the submodule-integration work scoped by [ADR-0003](../adr/ADR-0003-submodule-integration.md). It is **not** a summary written after the fact; it is a running log updated as each step is completed, capturing surprises, deviations from the plan, decisions made in-flight, and context that would otherwise be lost.

The plan being executed is preserved at `~/.claude/plans/so-i-was-just-scalable-fountain.md` in the implementing environment. The 11-step build sequence below maps to the plan's build sequence section.

---

## Entry format

Each step gets a section. Each section contains:

- **What was done** — one-paragraph summary
- **Surprises / deviations** — anything that departed from the plan; blank if nothing notable
- **Decisions made in-flight** — new decisions not covered by the plan or ADR
- **Follow-ups queued** — items discovered mid-step that need later attention

---

## Step 1 — ADR-0003 written

**Date:** 2026-04-20

**What was done:** Authored [`docs/adr/ADR-0003-submodule-integration.md`](../adr/ADR-0003-submodule-integration.md), modeled on the style of ADR-0002. Captured the four-part decision (pluggable mount path, symlinked skills, brownfield-safe bootstrap, multi-platform coexistence), along with Context, Consequences (Positive/Negative/Watch), and five Alternatives Considered (copy-in, subtree, sibling checkout, package-manager distribution, skill-only bootstrap).

**Surprises / deviations:** None at this step. The existing ADR-0002 gave a strong template to mirror.

**Decisions made in-flight:**

- Used ADR number 0003 (next available after 0001 and 0002).
- Included "Watch" subsection under Consequences to flag leading indicators that would invalidate parts of the decision — matches ADR-0002's pattern and is worth keeping.

**Follow-ups queued:**

- Consumer-facing docs rewritten in Step 8 should reference ADR-0003 as the authoritative decision record.

**Post-review expansion (2026-04-20):** User reviewed the ADR and asked that the Alternatives Considered section capture the essence of *all* choices, not just the 5 initially drafted. Added two more:

- **Monorepo** (fold consumers into auto-harness) — rejected on independent-cadence, licensing, access-control, and substrate-identity grounds.
- **Vendored copy with automated sync bot** — rejected as high-complexity reinvention of what `git submodule update --remote` already does in one command; introduces a drift window that submodules avoid entirely.

ADR now has 7 alternatives. The record is more complete for future maintainers who may revisit the decision.

**Step 10 pulled forward (2026-04-20):** Per user request to "update as we go so as not to lose details," the `docs/project/change-log.md` entry for this work was appended now rather than at Step 10. Entry cites ADR-0003 and is marked "Implementation in progress" so future readers know the row dates the *decision*, not the *completion*. The Step 10 todo is adjusted accordingly — it will become "finalize change-log entry (strike 'in progress' marker)" once verification passes.

---

## Step 2 — Fixtures and samples

**Date:** 2026-04-20

**What was done:** Three fixture/sample directory trees created in parallel by dispatched agents:

- **`platform/validators/test/fixtures/projects/valid-submodule-mount/`** — Mirror of `valid-prototype/` with a relative symlink `.harness → ../../../../../..` pointing to the repo root. Models a consumer repo that has mounted auto-harness as a git submodule at `.harness/`. All governance files (`docs/**`, `harness.manifest.yaml`, `HARNESS.md`, `AGENTS.md`) are byte-identical copies of the reference fixture.
- **`platform/examples/sample-projects/submodule-consumer/`** — Mirror of `node-web-saas-postgres/` structured as if `.harness/` were submoduled. `harness.manifest.yaml` is byte-identical to the reference (verified with `cmp` and `diff`), proving manifests are topology-agnostic. `AGENTS.md` includes the `<!-- harness-managed-section -->` marker block so readers can see the bootstrap's merge boundary. `.claude/skills/harness-governance` and `.agents/skills/harness-governance` are relative symlinks that are intentionally dangling (the demo's `.harness/` is a pointer, not a real submodule).
- **`platform/bootstrap/test/fixtures/consumer-repos/coexist-{cursor,copilot,multi,openclaw}/`** — Four fixtures with realistic seeded content from other AI platforms. 14 files, ~69 lines total. `coexist-multi/AGENTS.md` deliberately omits the harness-managed-section marker so the bootstrap's safe-merge logic gets tested on "virgin" AGENTS.md in a future step.

**Surprises / deviations:**

- **Symlink depth corrected.** The plan brief to the first agent suggested 5 `..` segments for the `.harness` symlink; empirical verification showed 6 was correct (fixture lives 6 levels deep under repo root: `platform/validators/test/fixtures/projects/valid-submodule-mount/`). Agent caught this and flagged it. Final symlink target: `../../../../../..` (6 segments). Lesson for future fixture work: always verify symlink depth with `realpath` rather than trusting mental arithmetic.
- **Ruby unavailable in this dev environment.** `command -v ruby` returns nothing; `apt-cache show ruby` confirms it's available as Ubuntu package `ruby 1:3.2~ubuntu1` but not installed. Auto-harness validators use Ruby heredocs (see [platform/validators/validate-manifest.sh:9](../../platform/validators/validate-manifest.sh)), so the Step 2a smoke tests and the Step 6 TestSubmoduleMount integration test cannot be run to green locally. They will run correctly in a ruby-equipped environment (CI via `actions/setup-ruby`, or local after `sudo apt install ruby`). Implementation continues; verification scenarios 1, 2, 3, 4, and 7 from the plan that invoke validators will need to be deferred to a ruby-available session. Not a design blocker.
- **Correction (2026-04-20, post-user-review):** I initially framed Ruby as a "dev environment" concern, implying it was only needed by maintainers of auto-harness. That framing was wrong. Every validator shell script (`validate-*.sh`) is a bash wrapper around a Ruby heredoc — `grep -n '^ruby ' platform/validators/*.sh` shows 5 matches, one per validator. So **Ruby is a consumer CI dependency**, not a maintainer-only concern. The existing [ci-integration.md](../../platform/workflow/ci-integration.md) already prescribes `ruby/setup-ruby@v1` in every example workflow (lines 54-56, 208-210, 347-349), confirming the requirement has been consumer-facing since the validators were written. ADR-0003's "Consequences > Negative" block has been updated to make this explicit at the decision-record level. Only [link-skills.sh](../../platform/bootstrap/link-skills.sh) is pure bash; `install.sh` will also require Ruby for manifest-merge logic. Future-architecture note: rewriting validators as first-class `.rb` files (no heredoc) with optional `.sh` wrappers would make the dependency graph more honest, but that refactor is outside this plan's scope — logging it here so a future maintainer spots the option.
- **Valid-prototype fixture files are zero-byte.** The existing `valid-prototype/` fixture uses empty files as placeholders — they exist to satisfy `requiredArtifacts` existence checks, not to contain governance content. The new `valid-submodule-mount/` mirrors that pattern. No path-reference edits were needed inside files.

**Decisions made in-flight:**

- **Sample README marks dangling symlinks as "by design."** The `.claude/skills/harness-governance` and `.agents/skills/harness-governance` symlinks in `submodule-consumer/` point into a `.harness/` that isn't populated (no real submodule in the demo). Rather than work around this, the sample's top-level `README.md` calls it out explicitly: readers see "this is what the link would be in a real consumer; the target is absent in this demo" and learn the pattern without being confused by broken links.
- **AGENTS.md in the sample carries the marker block pre-populated.** Even though the sample is a demonstration (no bootstrap run occurred), showing the `<!-- harness-managed-section -->` marker pattern in the sample itself teaches consumers what to expect from their own AGENTS.md after running `install.sh`. Makes the merge boundary legible.

**Follow-ups queued:**

- Step 6 (TestSubmoduleMount) needs a note in its test harness that it will skip if ruby is unavailable, or that the project's CI is responsible for running it.
- Step 4 (install.sh) must handle the dangling-symlink case for `submodule-consumer/` if it's ever used as an `install.sh` fixture — right now it's a *sample* (illustrative), not a test fixture, but if that changes the rule needs to be "symlink with missing target is `[OK]` not `[CONFLICT]` because the submodule may not be checked out yet."
- When writing the verification section of `submodule-integration.md` (Step 7), cite that fixture-creation required empirical symlink-depth verification — good cautionary tale for consumers setting up their own `.harness/` mounts.

---

---

## Step 3 — link-skills.sh + tests

**Date:** 2026-04-20

**What was done:**

- **`platform/bootstrap/link-skills.sh`** — portable-bash script implementing the symlink contract from ADR-0003. CLI: `[--project-root] [--mount-path] [--targets] [--force] <skill-name>...`. Creates relative symlinks from consumer-side skill directories (default `.agents/skills/` and `.claude/skills/`) into `$MOUNT_PATH/platform/skills/<name>`. Four terminal states per (target, name) pair: `[OK]` (existing correct symlink), `[CREATED]` (fresh), `[REPLACED]` (with --force on a misdirected symlink), `[CONFLICT]` (misdirected symlink without --force, or a real directory at the target — even --force refuses to delete a real directory, because it may be user-authored).
- Exit codes: `0` all clean, `1` conflicts, `2` usage error (unknown skill, missing submodule, bad flag, absolute mount path).
- Manual smoke-test covered all 7 behavioral scenarios end-to-end against a scratch tmpdir with a `.harness` symlink to the real repo — results matched spec exactly. Relative symlink target verified as `../../.harness/platform/skills/harness-governance` (for 2-segment target dirs like `.claude/skills`); different mount paths like `vendor/auto-harness` produce `../../vendor/auto-harness/platform/skills/<name>`.
- **`platform/bootstrap/test/test_link_skills.rb`** — minitest suite matching the [test_validators_integration.rb](../../platform/validators/test/test_validators_integration.rb) idiom. Covers fresh install (both targets + custom mount + single-target), idempotency, three conflict scenarios (misdirected-without-force, misdirected-with-force-replaces, real-directory-never-replaced), four error scenarios (unknown skill, missing submodule, absolute mount path, missing skill args), bad flags, and help-text rendering. Each test class uses `Dir.mktmpdir` for isolation; no state leaks between tests.

**Surprises / deviations:**

- **Segment counting in pure bash required care.** `awk -F'/' NF` gives a count but is sensitive to trailing slashes (`".agents/skills/"` reports 3 instead of 2). Resolved by normalizing with `${p%/}` parameter expansion before counting slashes via `tr -cd '/' | wc -c`. The `count_segments` helper in the script encapsulates this — worth a second look when auditing the script.
- **`realpath --relative-to` rejected for portability.** The cleaner option for computing the relative symlink target would have been `realpath --relative-to="$(dirname "$link_path")" "${HARNESS_SKILLS_DIR}/${name}"`, but that flag is GNU-coreutils-specific (available since v8.23, 2014). macOS users would need to `brew install coreutils` to get it. Opted for the manual `up_path` construction to preserve out-of-the-box portability.
- **`--force` semantics deliberately asymmetric.** `--force` replaces *misdirected symlinks* but refuses to replace *real directories*. This asymmetry is intentional: a misdirected symlink is a broken or stale reference and always safe to remove; a real directory at the symlink's path is user-authored content with unknown value, and destroying it silently is never acceptable. The test `test_real_directory_never_replaced_even_with_force` is the regression gate for this policy.
- **Minitest suite requires ruby that isn't installed locally.** Same constraint noted in Step 2. Tests will run clean in CI or after `sudo apt install ruby`. Not a design blocker.

**Decisions made in-flight:**

- **Portable bash over modern GNU features.** The script sticks to POSIX-ish constructs plus bash `[[ ]]` and arrays — nothing from recent GNU coreutils. Rationale: consumer CI may run on alpine or minimal containers where coreutils features vary. The `tr | wc` pattern is ugly but universal.
- **Targets default to both `.agents/skills` and `.claude/skills`.** Consumers can override with `--targets .claude/skills` (Claude-only) or `--targets .agents/skills` (cross-client-only) if they don't want the parallel tree. Tested explicitly via `test_single_target_via_flag`.

**Follow-ups queued:**

- Step 4 (install.sh) will invoke this script — needs to pass through `--project-root`, `--mount-path`, `--force` flags consistently. Resolved skill list comes from the active composition's `recommendedSkills` field (parsed in install.sh, forwarded as positional args).
- Step 7 (submodule-integration.md) should show a link-skills.sh example with a `--targets .claude/skills` customization to teach the asymmetric-client case.
- If bootstrap test runs eventually catch a case where link-skills.sh's `mkdir -p "$tgt_dir"` creates a directory that the consumer didn't want created (e.g., consumer uses only `.claude/skills/` but ends up with an empty `.agents/skills/` dir), consider making directory creation contingent on successful link creation rather than unconditional. Low-priority; flagged here so a future reviewer spots it.

---

---

## Step 4 — install.sh + tests

**Date:** 2026-04-20 (started) / 2026-04-21 (tests run)

**What was done:**

- **`platform/bootstrap/install.sh`** — ~300-line bash bootstrap that mounts the five algorithmic phases of ADR-0003 into one executable. Flags: `--mount-path`, `--project-root`, `--composition`, `--skills`, `--dry-run`, `--force`, `--non-interactive`, `--help`. Auto-detects mount path relative to script location via `realpath --relative-to` with a `.harness` fallback for portability. Defaults to composition `brownfield-lite` and skills `harness-governance,harness-onboarding` if not specified.
- **Signature-file catalog** hardcoded as a single bash array (~18 entries spanning Cursor, Windsurf, GitHub Copilot, MS Copilot, OpenAI Codex, OpenClaw, Hermes). Each observed signature gets recorded in a `PLATFORMS OBSERVED:` summary block alongside the file paths that triggered detection. **None of these files are ever written by the bootstrap.**
- **Harness-managed targets** handled with per-file classification:
  - `harness.manifest.yaml` — `ABSENT` → copy composition; `HARNESS_STYLE` (has `schemaVersion: 1`) → skip unless `--force`; `FOREIGN` → `[CONFLICT]`, leave alone.
  - `HARNESS.md` — same pattern, signature is "harness.manifest.yaml" mentioned in content.
  - `CLAUDE.md` — same pattern, signature is both "HARNESS.md" and "harness.manifest.yaml" present.
  - `AGENTS.md` — **special-cased**. Always merged via `<!-- harness-managed-section --> ... <!-- /harness-managed-section -->` markers. Existing content outside the markers is preserved verbatim. If the marker is absent, append; if present, replace content between markers via `awk`. Custom AGENTS.md content is never overwritten.
- **Skills symlinking** delegates to `link-skills.sh` and parses its output lines back into the unified 5-block summary. `[OK]` maps to SKIPPED, `[CREATED]`/`[REPLACED]` to CREATED, `[CONFLICT]` to CONFLICTS.
- **CI snippet** emitted to stdout (NOT written). Commented block suggesting `.github/workflows/harness.yml` with `HARNESS_SUBMODULE_ROOT` parameterization, `ruby/setup-ruby@v1`, `submodules: recursive`. Consumer copy-pastes into their repo manually; install.sh refuses to touch `.github/workflows/` because existing CI from other platforms could be present.
- **Validator smoke test** — runs `validate-manifest.sh` and `validate-module-graph.sh` against the final state. Ruby availability is detected; if missing, a `MANUAL FOLLOW-UP:` line directs the user to `apt install ruby` or `ruby/setup-ruby`. Does not fail the bootstrap; validator failures surface as follow-ups so consumers can iterate.
- **5-block summary** at end: CREATED / SKIPPED / CONFLICTS / PLATFORMS OBSERVED / MANUAL FOLLOW-UP. Always present, even when empty (prints `(none)`). Final exit code: 0 if no conflicts, 1 if any conflicts, 2 on usage errors.
- **`platform/bootstrap/test/test_install.rb`** — 16-test minitest suite exercising greenfield scaffolding, idempotency, `--force` replace, brownfield conflict preservation (foreign CLAUDE.md, foreign manifest), coexistence (cursor alone, multi-platform, openclaw, AGENTS.md merge preserving custom content), dry-run (zero writes), CLI validation (unknown flag, absolute mount path, missing composition), and CI snippet format assertions.

**Test results:** 16 runs, 99 assertions, 0 failures, 0 errors, 0 skips (after `apt install ruby 3.2.3`).

**Surprises / deviations:**

- **`realpath --relative-to` IS used** in install.sh for mount-path auto-detection — deliberate deviation from the link-skills.sh portability stance. Rationale: link-skills.sh is the hot path invoked on every skill sync (may run on more constrained environments); install.sh is a one-time bootstrap that runs under a controlled ruby/bash setup anyway. If `realpath` fails (missing or non-GNU), the script falls back to `.harness` as the default mount and logs nothing — user can override with `--mount-path`. Documented this fallback chain so future maintainers know why behaviors differ.
- **AGENTS.md re-merge on idempotent re-run is not strictly a no-op.** When install.sh runs twice with no intervening edits, the managed section gets rewritten with byte-identical content, but the summary reports "AGENTS.md (managed section updated)" rather than an `[OK]` equivalent. Decided to ship as-is: cleaner output at the cost of adding a "was the new content different from what's there?" check would complicate the awk-based merge without user-visible benefit. Follow-up noted below.
- **Pre-existing test suite has 2 unrelated failures.** Running `ruby -I platform/validators/lib platform/validators/test/test_validators_integration.rb` reports 2 failures against `valid-prototype` fixture — missing `docs/project/revision-tracker.md`. This is a pre-existing state (the fixture was not updated when `revision-tracker.md` became a required artifact) and is NOT caused by this work. Explicitly out of scope per plan's "Files deliberately NOT modified" list. Flagged here so a future maintainer spots the drift.

**Decisions made in-flight:**

- **CI snippet emits to stdout, not a file.** The plan called for this but I reconfirmed it after seeing how easy it would be to clobber a consumer's existing `.github/workflows/` directory. Consumer has to consciously copy the snippet into their workflow — that friction is protective, not hostile.
- **`--skills` default is static, not derived from composition modules.** Plan's original spec said "derived from the active composition's active modules' recommendedSkills fields" but that would require parsing the module graph in bash (no Ruby escape hatch in this code path). Opted for a static default of `harness-governance,harness-onboarding` — these apply regardless of composition. Consumers with richer compositions pass `--skills ...` explicitly. Follow-up: parse recommendedSkills when composition-aware defaults become valuable.
- **Validator smoke test folds failures into `MANUAL FOLLOW-UP:`, not `CONFLICTS:`.** Rationale: a validator failure on the *just-generated* manifest usually indicates a composition bug or a missing required-artifact that the consumer will address as the next step; it's not a "bootstrap failed" state but a "you have work to do next" state. Exit code stays 0 as long as file operations succeeded.

**Follow-ups queued:**

- AGENTS.md merge idempotency: add a "was content different?" gate to avoid the "updated" label on no-op re-runs. Low-priority cosmetic improvement.
- Composition-aware skill defaults: parse module.yaml `recommendedSkills` to auto-populate `--skills` when not specified. Would require reading the composition and traversing the module graph — use Ruby heredoc like validators do. Nice-to-have.
- Consider a `--check` mode that implies `--dry-run` but ALSO exits 1 if CREATED would be non-empty — useful as a CI gate to verify consumers keep their bootstrap current.
- Future-architecture: validators as first-class `.rb` files rather than bash+heredoc wrappers (also noted in Step 2 log). Would make Ruby dependency more honest at the surface.

---

---

## Step 5 — platform/bootstrap/README.md

**Date:** 2026-04-21

**What was done:** Wrote [platform/bootstrap/README.md](../../platform/bootstrap/README.md) as the module-level entry point for the new directory. Quick-reference tables (fresh install / brownfield / re-run / additional skills), exit-code matrix, five-block summary explainer, platform signature catalog, requirements, test commands, and cross-references to ADR-0003 / `submodule-integration.md` / `ci-integration.md` / `brownfield-onboarding.md`.

**Surprises / deviations:** None — pure documentation authored from the material already in the scripts and ADR.

**Decisions made in-flight:** Included the signature catalog inline in the README (rather than linking elsewhere) because it's the single most-asked question from consumers ("what files will this touch?"). Duplication risk accepted.

---

## Step 6 — TestSubmoduleMount integration test

**Date:** 2026-04-21

**What was done:** Added `TestSubmoduleMount` class to [platform/validators/test/test_validators_integration.rb](../../platform/validators/test/test_validators_integration.rb) covering four assertions:

1. `.harness` symlink in the fixture resolves to the auto-harness repo root.
2. `validate-manifest.sh` invoked through `<fixture>/.harness/platform/validators/validate-manifest.sh` exits 0.
3. `validate-module-graph.sh` invoked through the mount path exits 0.
4. Top-level vs mount-path invocations produce byte-identical stdout and exit codes.

**Test results:** 4 runs, 10 assertions, 0 failures, 0 errors, 0 skips.

**This is the critical proof** that validators are already submodule-safe without any code changes — the entire feature is consumer-side ergonomics plus docs.

**Surprises / deviations:**

- **First implementation had a path calculation bug.** I computed `File.expand_path("../../..", PLATFORM_DIR)` expecting to reach the auto-harness repo root, but PLATFORM_DIR is already `<repo>/platform/`, so 3 `..` overshoots to `/home/unclenate`. Correct form is `File.expand_path("..", PLATFORM_DIR)`. Caught on first test run; fixed in the same commit.
- **Deliberately limited to manifest + module-graph validators.** Per ADR-0003 the proof obligation is "validators work through submodule paths," and validators share the `SCRIPT_DIR/../..` idiom. Running two representative validators end-to-end through the mount is sufficient evidence; exhaustively running all five would bloat the test class for diminishing returns. `validate-required-artifacts.sh` was deliberately excluded because the fixture (copied from `valid-prototype`) is missing `docs/project/revision-tracker.md` due to the pre-existing fixture drift flagged in Step 4.

**Follow-ups queued:**

- When (if) the pre-existing `valid-prototype` fixture is updated to include `revision-tracker.md`, mirror the change into `valid-submodule-mount` and extend `TestSubmoduleMount` to also run the required-artifacts and companions validators through the mount.

---

## Step 7 — platform/workflow/submodule-integration.md

**Date:** 2026-04-21

**What was done:** Wrote [platform/workflow/submodule-integration.md](../../platform/workflow/submodule-integration.md) as the canonical guide. Covers: why submodule mode, prerequisites (Ruby 3.0+ called out prominently), 5-step quick start (submodule add → bootstrap → verify → commit → wire CI), the `HARNESS_SUBMODULE_ROOT` contract, upgrade flow, brownfield integration with the signature catalog, AGENTS.md special-case explanation, troubleshooting (missing submodule, Windows symlinks, conflicts, missing revision-tracker, ruby not found), and the relationship between `install.sh` and the `harness-onboarding` skill ("install.sh first, then the skill").

**Decisions made in-flight:** Surfaced the "install.sh first, then the skill" ordering prominently — the plan implied it but didn't state it as a headline. Consumers asking "which one do I run?" need a one-liner answer; burying it would push them into the wrong order.

---

## Step 8 — Consumer-facing doc rewrites

**Date:** 2026-04-21

**What was done:**

- **[ci-integration.md](../../platform/workflow/ci-integration.md)** — fixed the Option B bug (`PLATFORM_ROOT` was set to `${{ github.workspace }}/platform` despite claiming submodule mode). Reordered to put **Submodule (recommended)** first. New snippet uses both `HARNESS_SUBMODULE_ROOT` and `PLATFORM_ROOT` with consistent paths. Noted that non-default mount paths substitute consistently across both vars.
- **[bootstrap-quickstart.md](../../platform/workflow/bootstrap-quickstart.md)** — inserted a "Step 0 — Choose your integration mode" fork at the top directing submodule consumers to `install.sh` with a single bash command. Existing Steps 1–6 remain untouched as the non-submodule (monorepo/subtree) path.
- **[brownfield-onboarding.md](../../platform/workflow/brownfield-onboarding.md)** — inserted "Step 1.5 — Add auto-harness as submodule; run install.sh" in the Workflow at a Glance ASCII diagram and added a post-diagram paragraph explaining what Step 1.5 produces (harness-managed files, marker-block AGENTS.md merge, symlinked skills) and how Steps 2–7 refine that output.
- **[SKILL.md](../../platform/skills/harness-onboarding/SKILL.md)** — parameterized the validator runbook (lines ~302–322). The hardcoded `PLATFORM=path/to/platform` became `HARNESS_SUBMODULE_ROOT="${HARNESS_SUBMODULE_ROOT:-.harness}"` with `PLATFORM="$HARNESS_SUBMODULE_ROOT/platform"`. Left the monorepo/subtree alternative as a comment so non-submodule consumers know how to override.
- **[README.md](../../README.md)** — added an "Integrating into your repo" section between "Getting Started" and "Design Principles" presenting the submodule flow as the recommended pattern with three cross-references (submodule-integration.md, ADR-0003, bootstrap README). Preserved the existing Getting Started block (which shows self-dogfood / platform-at-root patterns) — keeps both modes legible.

**Surprises / deviations:** None — straightforward doc edits aligned with the plan.

---

## Step 9 — SUMMARY.md and HARNESS.md updates

**Date:** 2026-04-21

**What was done:**

- **[SUMMARY.md](../../SUMMARY.md)** — added `* [Submodule Integration](platform/workflow/submodule-integration.md)` as the first entry under the "Workflows" section. Leads the workflow list so GitBook readers find the recommended path first.
- **[HARNESS.md](../../HARNESS.md)** — appended a "Consuming auto-harness in other projects" section at the end with a one-paragraph summary and pointers to the workflow guide and ADR-0003. Kept the existing self-governance content intact (auto-harness still describes itself; the new section describes how others consume it).

---

## Step 10 — Finalize change-log.md

**Date:** 2026-04-21

**What was done:** Updated the preliminary change-log entry to drop the "Implementation in progress" marker and list the shipped artifacts (install.sh + link-skills.sh + submodule-integration.md + TestSubmoduleMount + all doc rewrites). Date advanced to 2026-04-21 to reflect the actual completion date.

---

## Step 11 — Shipped

**Date:** 2026-04-21

**Final verification:**

- **New bootstrap test suites (100% green):** `test_link_skills.rb` — 13 runs, 56 assertions; `test_install.rb` — 16 runs, 99 assertions; `TestSubmoduleMount` — 4 runs, 10 assertions. **Total: 33 runs, 165 assertions, 0 failures, 0 errors, 0 skips.**
- **Self-dogfood validators:** `validate-manifest.sh` and `validate-module-graph.sh` both PASS against auto-harness's own `harness.manifest.yaml`. Nothing in this work regressed the repo's self-governance.
- **Pre-existing test failures noted but out of scope:** The full `test_validators_integration.rb` suite shows 2 failures and 4 skips (24 runs, 60 assertions total). All 2 failures are against the `valid-prototype` fixture's missing `docs/project/revision-tracker.md` — pre-existing drift that predates this work. The 4 skips are conditional on test setup unrelated to submodule integration.
- **All deliverables present:** ADR-0003, implementation log, 2 bash tools + their minitest suites + bootstrap README, submodule-integration.md, submodule-consumer sample, valid-submodule-mount fixture, 4 coexist-* fixtures, doc edits across 5 existing files, SUMMARY.md and HARNESS.md updates, change-log entry.

**Verification scenarios run (per ADR-0003 / plan):**

1. Greenfield simulation — ✓ (install.sh test_empty_repo_gets_full_scaffold + manual tmpdir test)
2. Brownfield with foreign CLAUDE.md — ✓ (test_foreign_claude_md_is_preserved)
3. Dry-run — ✓ (test_dry_run_writes_nothing)
4. Re-run idempotency — ✓ (test_rerun_skips_harness_style_files)
5. Upstream update propagation — architecturally guaranteed via symlinks; `submodule-integration.md` documents the `git submodule update --remote` flow
6. Submodule mount path variation — ✓ (test_custom_mount_path)
7. Self-dogfood green — ✓ (manifest + module-graph validators against auto-harness's own manifest)
8. Multi-platform coexistence — ✓ (test_cursor_detected_and_file_untouched, test_multi_platform_all_untouched_and_reported, test_agents_md_custom_content_preserved_on_merge, test_openclaw_files_detected_and_untouched)
9. Documentation deliverables present — ✓ (all 10 tracked files exist; 5 existing docs updated; cross-references verified)

**Known follow-ups carried forward** (from prior step logs):

- AGENTS.md re-merge idempotency cosmetic (reports "updated" on byte-identical re-writes).
- Composition-aware `--skills` defaults via module-graph traversal (currently static default).
- Validator refactor — `.rb` first-class files instead of bash+heredoc wrappers (future architecture; out of scope here).
- Pre-existing `valid-prototype` fixture drift re: `docs/project/revision-tracker.md` — flagged separately; not a submodule-integration concern.

**Status: Shipped.**

---

## Step 8 — Consumer-facing doc rewrites (not yet started)

<!-- populated when the step is executed -->

---

## Step 9 — SUMMARY.md and HARNESS.md updates (not yet started)

<!-- populated when the step is executed -->

---

## Step 10 — change-log.md entry (not yet started)

<!-- populated when the step is executed -->

---

## Step 11 — Shipped (not yet started)

<!-- final entry when all verification scenarios pass -->
