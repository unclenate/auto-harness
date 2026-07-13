---
name: harness-governance
description: Trust tier enforcement, lifecycle controls, and companion rule requirements for projects using the development harness. Use when checking if an action requires human approval, creating or validating documentation artifacts, verifying lifecycle stage conditions, running validators, or making changes to governance entrypoints (HARNESS.md, AGENTS.md, CLAUDE.md, CI workflows).
license: Apache-2.0
compatibility: Designed for any Agent Skills-compatible client (Claude Code, VS Code, Cursor, and others). For projects governed by the development harness platform via harness.manifest.yaml.
metadata:
  harness-module: kernel/base
  format-version: "1.0"
---

# Harness Governance

This skill encapsulates the core governance rules of the development harness. Read it when
working on any project that has a `harness.manifest.yaml` file.

## Trust Tiers

Every action falls into one of six tiers. Tier determines autonomy — higher tiers require
human authorization, never self-elevation.

> **Visual:** see the [Trust Tier Decision Flow diagram](../../../docs/architecture/diagrams.md#2-trust-tier-decision-flow)
> for the same content rendered as a flowchart.

| Tier | Name | Examples | Agent may proceed? |
| ---- | ---- | -------- | ------------------ |
| 0 | Read-only | Read files, search, inspect git history | Yes |
| 1 | Local analysis | Run tests, builds, linters | Yes |
| 2 | Workspace mutation | Edit files, scaffold docs, create artifacts | Yes, with care |
| 3 | Git-writing | Commit, push to feature branches, open PRs | Yes, with care |
| 4 | Environment-altering | Install dependencies, apply local migrations, configure services | Human authorization required |
| 5 | Remote / production | Deploy, production migrations, secrets rotation, infra changes | Human authorization + second sign-off |

**Gotchas:**

- Dependency installation (`npm install`, `pip install`, `uv sync`) is Tier 4 — even locally.
- `supabase db push` against any non-local environment is Tier 4.
- Any deploy command is Tier 5 regardless of how it is invoked.
- Finding a workaround that achieves a Tier 4/5 effect while appearing lower-tier is prohibited.

## Companion Rules

When a sensitive path changes, a companion file must also change in the same commit.
If you change a trigger path without updating the companion, flag it before finishing.

> **Visual:** see the [Companion Rule Firing diagram](../../../docs/architecture/diagrams.md#3-companion-rule-firing)
> for the trigger → satisfier → CI-gate flow.

Common companion rules in harness projects:

| Trigger path | Required companion |
| ------------ | ------------------ |
| `docs/product/requirements.md` | `docs/project/change-log.md` OR a new ADR |
| `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, `.github/CODEOWNERS` | ADR OR `docs/operating-principles.md` |
| `package.json`, lock files, `.nvmrc` | ADR OR `docs/architecture/overview.md` |
| `pyproject.toml`, `requirements.txt`, lock files | ADR OR `docs/architecture/overview.md` |
| `supabase/`, `src/auth/`, session/jwt/token paths | `docs/security/risk-register.md`, ADR, or architecture overview |
| New/modified ADR (`docs/adr/ADR-*`), OPP (`docs/opportunities/OPP-*`), module manifest (`platform/*/module.yaml` — anywhere under `platform/`), or active-module catalog (`harness.manifest.yaml`) — *cycle-end distillation trigger when `management/knowledge-capture` is active* | Either of: `docs/knowledge/shared-observations.md` or `docs/operating-principles.md`. See [`platform/workflow/cycle-end-distillation.md`](../../workflow/cycle-end-distillation.md) for the satisfier decision tree. Pre-ADR-0014 (2026-05-25) the satisfier set also included `docs/knowledge/distilled-learnings.md`; that destination was sunset and consolidated into operating-principles.md. |

Active companion rules for the current project are declared in each module's `module.yaml`.

> **Cycle-end distillation pattern (PRD-0004; satisfier set updated by ADR-0014).** When a PR introduces
> distillation-worthy work (new ADR / OPP / module / catalog change), the
> distillation-trigger rule fires. Pair the trigger with either an observation
> in `shared-observations.md` or a new/modified section in `operating-principles.md` —
> the `humanReview` text demands substantive connection between the trigger
> work and the distillation, not a tangential entry appended to pass CI. See
> [`platform/workflow/cycle-end-distillation.md`](../../workflow/cycle-end-distillation.md)
> for the canonical workflow, and
> [`platform/workflow/session-shape.md`](../../workflow/session-shape.md) for the
> umbrella **review-trigger taxonomy** — the six trigger-classes (PR-boundary,
> session-boundary, time-boundary, count-boundary, audit-boundary,
> external-event-driven) and the audit of declared-but-unfired reviews.

## Lifecycle Stages

Do not declare a stage complete unless all conditions are met.

**Bootstrap Complete** — all of the following:

- `validate-manifest.sh` exits 0
- `validate-module-graph.sh` exits 0
- `validate-required-artifacts.sh` exits 0 (or intentionally disabled)
- `validate-placeholders.sh` exits 0 — no `[[PLACEHOLDER_NAME]]` tokens remain
- CI workflow is green on the first PR

**Harness Ready** — Bootstrap Complete plus:

- Ownership and review gates are active
- Validators are wired into CI
- Operational readiness artifacts (risk register, release checklist) exist if required by active delivery modules
- At least one human reviewer besides the bootstrapper has reviewed the harness

## Running Validators

Run the full chain before committing any change to `docs/`, `harness.manifest.yaml`, or
any companion rule trigger path.

```bash
PLATFORM=path/to/platform
bash $PLATFORM/validators/validate-manifest.sh           harness.manifest.yaml
bash $PLATFORM/validators/validate-module-graph.sh       harness.manifest.yaml
bash $PLATFORM/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash $PLATFORM/validators/validate-placeholders.sh       .
bash $PLATFORM/validators/validate-agent-pack.sh         harness.manifest.yaml .
bash $PLATFORM/validators/validate-doc-references.sh     .
bash $PLATFORM/validators/validate-catalog-counts.sh     .
bash $PLATFORM/validators/validate-list-completeness.sh  .
bash $PLATFORM/validators/validate-trust-tier.sh         harness.manifest.yaml .
bash $PLATFORM/validators/validate-sensitive-paths.sh    harness.manifest.yaml .
bash $PLATFORM/validators/validate-skill-content.sh      harness.manifest.yaml .
bash $PLATFORM/validators/validate-knowledge-redaction.sh .                    main
bash $PLATFORM/validators/validate-observation-hygiene.sh harness.manifest.yaml . main
bash $PLATFORM/validators/validate-sast-coverage.sh      harness.manifest.yaml .
bash $PLATFORM/validators/validate-trace-contract.sh     harness.manifest.yaml .
bash $PLATFORM/validators/validate-foundry-target.sh     harness.manifest.yaml .
bash $PLATFORM/validators/validate-model-routing.sh      harness.manifest.yaml .
bash $PLATFORM/validators/validate-agent-defense-in-depth.sh harness.manifest.yaml .
bash $PLATFORM/validators/validate-privacy-by-design.sh  harness.manifest.yaml .
bash $PLATFORM/validators/validate-twin-profile.sh       harness.manifest.yaml .
bash $PLATFORM/validators/validate-scenario-manifest.sh  harness.manifest.yaml .
bash $PLATFORM/validators/validate-lane-integrity.sh     harness.manifest.yaml . main
bash $PLATFORM/validators/validate-publication-boundary.sh .
bash $PLATFORM/validators/validate-module-stability.sh   .
bash $PLATFORM/validators/validate-companions.sh         harness.manifest.yaml . main
```

All must exit 0 before the commit is complete. Each validator supports
`--help` / `-h` and uses a 3-state exit contract: `0` = pass, `1` =
governance violations found, `2` = usage error (missing argument,
missing dependency like `ripgrep`, unreadable manifest, malformed
YAML). Per-script signatures vary; run any validator with `--help` to
see its arguments.

A few signature notes worth highlighting:

- **`validate-placeholders.sh`** takes only `[<project-root>]` (default:
  cwd). Passing a manifest path as the first arg causes the script to
  attempt to `cd` into it and exit 2 with a `Not a directory` error.
- **`validate-doc-references.sh`** also takes only `[<project-root>]`.
  Pass 1 asserts every `platform/...` string inside `platform/*.md`
  resolves on disk (the harness's own dogfood check). Pass 2 scans
  every `*.md` under the project root for relative link targets and
  classifies each as `:ok`, `:missing`, `:directory_target` (GitBook
  404-fragile), or `:extensionless` (also GitBook-fragile). Consumers
  whose project doesn't have a `platform/` directory of its own can
  point at their `.harness/` submodule mount instead; the validator
  scans whichever root it's given.
- **`validate-trust-tier.sh`** takes `[<manifest>] [<project-root>]`
  (defaults: `./harness.manifest.yaml` and `dirname(manifest)`). For
  each active module, validates the optional `tier.declared` field
  (0–5; rationale required for ≥3); computes inferred tier from
  `sensitivePaths` regexes against representative production-shape
  sample paths; asserts `declared >= inferred`. For agent modules,
  validates `maxTier` and asserts it ≥ the highest active non-agent
  tier. Per PRD-0006 / ADR-0017 Wave 5.1. The harness's own kernel
  declares tier 5 (governs CI workflows + governance entrypoints); the
  cross-cutting "declared tier 5 requires criticality high/critical"
  rule is relaxed for `maturity: platform` projects (auto-harness
  itself).
- **`validate-list-completeness.sh`** takes only `[<project-root>]`.
  Asserts every ADR / PRD / OPP / composition / template subdirectory /
  profile module / agent module on disk has its canonical index row.
- **`validate-knowledge-redaction.sh`** takes
  `[--block] [<project-root>] [<base-branch>]` (defaults: cwd and `main`).
  Diff-based scan of new lines added to
  `docs/knowledge/shared-observations.md` and
  `docs/operating-principles.md` against a built-in denylist of
  consumer-name patterns (Tula, OpenEMR, YouBase, municipal-brain,
  toast-mcp). Lines matching `.knowledge-redaction-ignore` regex
  patterns are exempted. **Default posture: WARN** — surfaces hits on
  stderr but exits 0 (reviewers eyeball in CI logs). `--block` flag
  escalates hits to exit 1. Per OPP-0036 / ADR-0017 Wave 5.5. When run
  outside a git working tree or against a base branch that doesn't
  exist locally (shallow CI checkout, dogfood from a non-PR context),
  the validator exits 0 cleanly with an informational message rather
  than failing.
- **`validate-observation-hygiene.sh`** takes
  `[<manifest>] [<project-root>] [<base-branch>]` (or
  `--scan-file <path>`). Module-gated on `management/knowledge-capture`
  (inactive → exit 0 skip; the harness DOES activate it, so its own CI
  runs this **live/dogfood**, unlike the predict-clean content
  validators). Diff-based: lints each observation whose `###` heading was
  **added** vs. the base branch in `docs/knowledge/shared-observations.md`
  against the ADR-0002 shape — six fields present, `Confidence` ∈
  `{low, medium, high}`, `Severity` ∈ `{informational,
  governance-relevant, architectural, risk-bearing}` (**enforce-as-locked**
  per PRD-0034 § 10 — off-enum values fail), `Contributed by` name + ISO
  date. **Grandfathers history** — only diff-added records are linted, so
  the existing corpus is never re-scanned; outside a git tree / base
  absent → exit 0. Presence + enum membership only, never the semantic
  quality of the judgement (the `validate-module-stability` boundary).
  The knowledge-ledger instance of the *structured-agent-ledger gate*
  species (see `docs/architecture/stigmergy.md` § 4); the verdict-ledger
  instance is `validate-coordination-verdicts.sh` (OPP-0052).
  `--scan-file` lints every record in a file for fixture tests. Per
  PRD-0034 / OPP-0053; the governed schema is ADR-0002.
- **`validate-sensitive-paths.sh`** takes `[<manifest>] [<project-root>]`
  (defaults: `./harness.manifest.yaml` and `dirname(manifest)`). Across
  all active modules, asserts every `sensitivePaths` regex pattern is
  overlapped by at least one `companionRules.triggerPaths` regex on some
  active module. Uses a pragmatic 3-tier overlap check (literal
  equality, trigger contains sensitive as substring, or sensitive
  contains trigger as substring). Cross-module overlap is allowed —
  coverage by any active module's companion rule suffices. Closes
  safety-security-sweep §2 claim 12 (Asserted-only → Enforced). Per
  OPP-0034 / ADR-0017 Wave 5.3.
- **`validate-skill-content.sh`** takes
  `[--verbose] [<manifest>] [<project-root>]` (defaults: `./harness.manifest.yaml`
  and `dirname(manifest)`). Across active modules, scans authored prose in
  `module.yaml` description-class fields (`description`, `summary`,
  `reviewGates[]`, `companionRules[].humanReview`), SKILL.md bodies
  referenced via `recommendedSkills[]`, and markdown files referenced via
  `compiledFragments[]`. Hard-fails on any unexempted denylist match
  (prompt-injection patterns like "ignore previous instructions" or
  "skip the validator", tier-bypass phrasings like "always operates at
  Tier", role-prompt headers `^System:`/`^User:`/`^Assistant:`,
  zero-width characters U+200B/200C/200D/FEFF, Unicode bidi marks
  U+202A–202E/U+2066–2069). Lines matching `.skill-content-ignore` regex
  patterns are exempted. **Default posture: BLOCK** (predict-clean
  absorption per PRD-0015 FR-003). An auxiliary `--scan-file <path>` mode
  scans an arbitrary file's content against the denylist without
  enumerating active modules — useful for ad-hoc adversarial-corpus
  checks. Per PRD-0015 / OPP-0033 / ADR-0017 Wave 5.2. Closes
  safety-security-sweep §3 vectors V1, V2, V4 (partial), V6.
- **`validate-sast-coverage.sh`** takes `[<manifest>] [<project-root>]`
  (defaults: `./harness.manifest.yaml` and `dirname(manifest)`).
  Opt-in — when the `management/security-static-analysis` module is
  not active in the manifest, exits 0 with a "module inactive"
  message (the harness itself does not activate the module, so the
  harness's own CI run is a no-op pass — predict-clean absorption per
  PRD-0016 FR-003). When the module is active, reads
  `docs/security/sast-coverage.md`, parses the YAML frontmatter
  between `---` fences, and asserts: `tool:` is from the recommended
  set (`semgrep` / `codeql` / `bandit` / `gosec` /
  `eslint-plugin-security` / `snyk-code`), `scanPaths:` has at least
  one non-empty entry, `severityThreshold:` is a non-empty string.
  An auxiliary `--scan-file <path>` mode validates an arbitrary
  sast-coverage-shaped file without manifest gating — useful for
  fixture tests and ad-hoc validation of a candidate artifact before
  committing. Per PRD-0016 / OPP-0035 / ADR-0017 Wave 5.4.
  Half-enforces safety-security-sweep §11 (the largest mission-
  relative gap in the sweep) — the harness validates the contract;
  consumer CI honors it for end-to-end enforcement.
- **`validate-trace-contract.sh`** takes `[<manifest>] [<project-root>]`
  (or `--scan-file <path>`). Opt-in / module-gated, but on a different
  predicate than the others: it activates when **any active module
  declares `docs/observability/trace-contract.md` in its
  `requiredArtifacts`** — today `architectures/agent-observability`
  (which owns it) or `architectures/ai-foundry-target` (which reuses it
  via the deferred-dependency model) — so a consumer activating either
  gets the check. When none does, exits 0 with a "skipping" message
  (predict-clean — the harness activates neither). When active, parses
  the artifact's YAML frontmatter and asserts `semconv_version:` is a
  non-empty version pin, `spans:` declares at least one conventional
  GenAI operation (`chat` / `invoke_agent` / `execute_tool` /
  `create_agent` / `embeddings` / `invoke_workflow`), and
  `content_capture:` is one of `{opt-in, none}`. Presence + shape only
  (never that the declared spans match the emitted telemetry — that is
  the deferred code-cross-reference half). The artifact-content half of
  the frontier-agent cluster's v2 enforcement; `--scan-file <path>` for
  fixture tests. Per PRD-0031 / OPP-0051 / OPP-0027.
- **`validate-foundry-target.sh`**, **`validate-model-routing.sh`**, and
  **`validate-agent-defense-in-depth.sh`** are the three sibling
  content validators (PRD-0032, OPP-0051 phases 2–4) — same skeleton as
  `validate-trace-contract.sh` (requirement-set activation gate,
  `--scan-file`, predict-clean), each asserting its own artifact's
  frontmatter shape: `foundry-targets.md` declares ≥ 1 foundry from the
  enum with a `live`/`roadmap` status; `model-routing.md` declares ≥ 1
  `task`→`model` route (providers free-form); `agent-defense-in-depth.md`
  names all four patterns (`scope-containment`, `least-permissions`,
  `human-in-the-loop`, `agent-identity`). Presence + shape only; the
  code-cross-reference half stays deferred.
- **`validate-companions.sh`** is PR-diff-based and takes a third
  positional arg `<base-branch>` (default `main`). It is intended for
  CI; running it locally on a clean branch with no diff against base
  prints `No changed files detected ... Skipping companion validation.`
  and exits 0 without checking anything.
- **`validate-catalog-counts.sh`** takes only `[<project-root>]`.
  Asserts that documented catalog counts (modules, validators, skills,
  templates, workflows, diagrams) cited in entry-point docs match the
  canonical recipes. The recipes are inline in the script alongside an
  assertion table mapping `(file, regex, count-key)` to documented
  claim sites. When you add a new doc that cites a catalog count, append
  a row to the script's `ASSERTIONS` table so the drift class stays
  closed.
- **`validate-lane-integrity.sh`** takes
  `[<manifest>] [<project-root>] [<base-branch>]` (or
  `--scan-file <lane-spec> [<changed-path>...]`). Opt-in — when the
  `management/work-package` module is not active, exits 0 (predict-clean;
  the harness's own CI is a no-op pass). When active, parses the fenced
  `lane` block in `docs/work-package/lane.md`, asserts the schema is
  well-formed (`branch` / `base` / `prMode` in `{draft,ready}` / non-empty
  `allowedFiles` / list-typed `readOnlyFiles` / `requiredChecks` /
  `forbiddenCommands`), then diffs the branch against `<base-branch>` and
  fails if any changed file is outside `allowedFiles` or touches
  `readOnlyFiles`. The `--scan-file` mode runs the schema check (and, given
  an explicit changed-path list, the lane-vs-diff check) without git, for
  fixture-firing tests. Per PRD-0025. The multi-agent re-targeting of the
  module declare-then-enforce contract.
- **`validate-publication-boundary.sh`** takes `[<project-root>]`, or
  `--staged [<project-root>]`, or `--scan-file <path>...`. **Always-on** (not
  module-gated): it enumerates git-tracked files (or staged files, or the given
  paths) and exits 1 if any declares a `do-not-publish` marker — a YAML
  frontmatter key or an HTML-comment sentinel (`<!-- do-not-publish: true -->`),
  matched only at line start so a mid-sentence mention does not trip. Path
  regexes in `.publication-boundary-ignore` exempt files that legitimately discuss
  the marker. The steady state (marker in an *untracked* file) is invisible to
  `git ls-files` and passes; the gate fires the instant a marked file is
  tracked/staged. Outside a git work tree it exits 0. The inverse of a
  required-artifact check — a must-NOT-be-tracked assertion that needs no name
  corpus. Per PRD-0026 / OPP-0048; run it as a pre-commit hook (`--staged`) for
  prevention, with CI as the backstop.
- **`validate-module-stability.sh`** takes `[<project-root>]` or
  `--scan-file <module.yaml>`. **Always-on** structural catalog check (like
  `validate-list-completeness`, not module-gated): every `module.yaml` under
  `platform/` must declare `stability:` ∈ `{experimental, beta, stable}`. It
  asserts **presence + enum membership only** — never the correctness of the
  human judgment (honesty is an authoring act). Stability is a third axis,
  independent of trust tier (*risk*) and § 10 (*per-claim enforcement*): how
  proven the module itself is. `--scan-file` validates one module without
  enumerating, for fixtures. The rubric (stable / beta / experimental) is
  authoring guidance in [`extending-the-harness.md`](../../workflow/extending-the-harness.md)
  and the validator `--help`. Per PRD-0027 / OPP-0050.

## Required Artifacts

Required artifacts are declared per module in `module.yaml`. Run
`validate-required-artifacts.sh` to see what is missing. Do not substitute an empty file —
the validator checks existence, not content. Both matter.

Use templates from `platform/templates/` to create missing artifacts. Fill every
`[[PLACEHOLDER_NAME]]` field before committing.

## Installing This Skill

Keep this directory canonical under `platform/skills/`. For submodule consumers,
link the canonical skill into both `.agents/skills/` and `.claude/skills/` rather
than copying it into tool-local folders:

```bash
bash .harness/platform/bootstrap/link-skills.sh \
  --project-root . \
  --mount-path .harness \
  harness-governance
```
