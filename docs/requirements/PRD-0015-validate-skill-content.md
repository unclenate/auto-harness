<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0015: Skill Content Safety Validator — Surfacing Prompt-Injection and Tier-Bypass Patterns

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-05-28 | **Review Cycle:** On-change

**Status:** Proposed
**Date:** 2026-05-28 (filed)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Related OPP: [OPP-0033](../opportunities/OPP-0033-validate-skill-content.md) — `proposed`; this PRD is its promotion candidate. Will flip to `exploring` in the same commit that ships this PRD.
- Related ADR: [ADR-0017](../adr/ADR-0017-safety-hardening-roadmap.md) — Wave 5.2 of the Safety Hardening Roadmap. PRD-0015 is the design pass that ADR-0017 §16 priority 2 anchors.
- Related PRDs:
  - [PRD-0006](PRD-0006-trust-tier-enforcement.md) — Trust-tier enforcement (Wave 5.1). PRD-0015 enforces the *wording integrity* of tier prose; PRD-0006 enforces tier *declarations*. They compose.
  - [PRD-0004](PRD-0004-distillation-triggers.md) — Knowledge-capture cycle-end rule. PRD-0015 is itself a knowledge-capture trigger.
- Related operating principles:
  - [§ 5 Self-Governance](../operating-principles.md#5-self-governance) — the harness must enforce on its own surface what it claims for consumers.
  - [§ 9 Split Design from Implementation](../operating-principles.md#9-split-design-from-implementation) — this PRD ships the design contract; the implementing PR ships `validate-skill-content.sh` + the adversarial corpus.
  - [§ 10 Classify Claims Before Enforcing Them](../operating-principles.md#10-classify-claims-before-enforcing-them) — this PRD names each Asserted-only claim being converted to Enforced (see §10 Claim Classification block below).
- Related observations:
  - `docs/knowledge/shared-observations.md` — *"Claim-vs-enforcement classification is a generalizable framework-audit mechanism"* (2026-05-27) — the principle that frames this PRD's claim accounting.
- Other:
  - `documentation-audit-2026-05-27/safety-security-sweep.md` § 3 (red-team attack branches V1/V2/V4/V6), § 4 (Prompt Injection Testing), § 7 (doc-code-alignment).

## Overview

The framework's authored prose — `module.yaml` description-class
fields, `SKILL.md` bodies, agent-pack READMEs, `compiledFragments`
markdown — is loaded into downstream AI agent contexts at session
start. This makes the framework's *prose* an attack surface. The
current defense is human review (CODEOWNERS plus maintainer
scrutiny). That is necessary but not structurally sufficient against
a contributor or maintainer mistake; a deny-list validator closes
the gap at the structural layer.

This PRD specifies the v1 enforcement machinery as a single
coordinated validator:

1. **`validate-skill-content.sh`** — Bash + Ruby content scanner that
   reads a curated **denylist of prompt-injection and tier-bypass
   patterns** and asserts none appear in the v1-scoped fields of
   each active module's authored prose. Per-line surfacing with file:
   line + matched pattern + the offending excerpt. 3-state exit (0
   pass / 1 violation / 2 usage error) per established convention.
2. **`.skill-content-ignore` exemption file** — line-regex format
   mirroring `.doc-reference-ignore` / `.placeholder-ignore` /
   `.knowledge-redaction-ignore`. Exempted lines bypass the scan.
   Pedagogical contexts (the `harness-mcp` skill discussing MCP
   security patterns, this PRD itself citing the seed denylist) use
   it.
3. **Adversarial-corpus seed fixture** at
   `platform/validators/test/fixtures/adversarial/` — a growable
   directory of known injection strings, tier-bypass phrasings, and
   role-prompt headers. Each fixture is a single-line file. The
   validator test suite asserts the validator flags every fixture
   when scanned. Future additions are append-only: new attack
   patterns get a new fixture; the validator's denylist is updated
   in the same PR; the test asserts the new pattern is caught.
4. **Default posture: BLOCK** (not warn). Unlike
   `validate-knowledge-redaction.sh` (which uses WARN posture because
   50+ historical consumer citations exist), the framework's authored
   prose surface has zero known historical violations. v1 ships as a
   hard-fail validator from PR 1. Absorption mechanism per
   `feedback-validator-absorption-mechanisms`: **predict-clean** —
   the OPP's Risk section predicts the harness's own authored prose
   does not contain the seed denylist patterns; the implementing PR
   confirms or refutes the prediction.

v1 is **PR-boundary enforcement** only. Runtime classification of
compiledFragments as "treat as untrusted input" is a separate v2+
defense per safety-security-sweep §4 — out of scope here.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- Ship `platform/validators/validate-skill-content.sh` — Bash 3.2
  compatible, shellcheck-clean at warning severity, 3-state exit,
  per established validator conventions.
- Define the v1 seed denylist (~10 high-confidence patterns) directly
  in the validator script's body, with a comment block citing
  safety-security-sweep §3 Recommendation 2 as the source of each
  pattern.
- Define the v1 scanned-fields set (per file type) explicitly: which
  `module.yaml` fields, which markdown sections of `SKILL.md`, which
  paths under `compiledFragments`. The set must be enumerable from
  the validator's `--help` output.
- Ship `.skill-content-ignore` format spec (line-regex per
  established pattern) and seed exemptions for known-pedagogical
  contexts.
- Ship `platform/validators/test/fixtures/adversarial/` seed
  directory with one fixture per v1 denylist pattern (~10 files);
  the test suite asserts the validator flags each.
- Wire the new validator into `kernel/base` module.yaml validators
  list, `.github/workflows/harness.yml`, consumer CI templates,
  `AGENTS.md` recommended-run-order, `harness-governance/SKILL.md`
  validator chain + signature notes, `validators/README.md` script
  table, root `README.md` validators table + mermaid box.
- Update `validate-catalog-counts.sh` ASSERTIONS for the validator
  count bump (12 → 13) at the documented sites.
- Declare the new validator's `sensitivePaths` overlap so
  `validate-sensitive-paths.sh` keeps passing (this is a §10
  meta-application: the new validator itself is an authored surface
  whose declarations get validated by sibling validators).
- One paired distillation observation capturing the design pressure
  of mechanizing the *prose-as-attack-surface* claim — anticipated:
  the implementation pass will surface design questions about
  ignore-file scope and false-positive tolerance that the PRD pass
  may elide.

**Non-Goals** — outcomes explicitly out of scope. Be specific; vague
non-goals allow scope to creep back in:

- **Runtime content classification.** Marking compiledFragments as
  "untrusted input" at session-start time requires AI-client-specific
  hooks (Claude Code, Cursor, Copilot, Codex, Gemini). v1 is
  PR-boundary only. Runtime classification is a v2+ orthogonal
  defense.
- **Tier-vocabulary lockfile.** Sweep §3 Recommendation 3 proposes a
  separate lockfile listing exact tier wording. v1 of this validator
  uses denylist patterns to catch some tier-bypass phrasings (V4),
  but does not freeze the canonical tier vocabulary in a separate
  file. If v1 proves insufficient against V4 specifically, file a
  follow-up OPP.
- **Unicode normalization / zero-width character stripping at write
  time.** v1 *detects* zero-width and bidi-mark characters; it does
  not auto-strip or auto-normalize source files. Auto-fix is a v2+
  risk surface (a write-side validator could itself become an
  injection vector).
- **Scanning consumer project content beyond active modules' authored
  prose.** v1 scans only the harness's own active-module surface
  (the dogfood pass). Consumer projects that adopt the harness will
  scan their own active-module surface — same recipe, different
  base path. Out-of-scope here.

> Distinction from `Functional Requirements > Out of Scope`: Non-Goals
> are *outcomes* ("we are not solving runtime classification"); FR
> Out-of-Scope is *features* ("we are not building auto-strip").

## §10 Claim Classification

Per the freshly codified [§10 operating principle](../operating-principles.md#10-classify-claims-before-enforcing-them),
this PRD names each load-bearing claim being converted from
Asserted-only to Enforced:

| Claim ID | Claim | Current state | After v1 | Source |
|----------|-------|---------------|----------|--------|
| C-V1 | Authored `module.yaml` description-class fields do not contain prompt-injection patterns | Asserted-only | Enforced | Sweep §3 vector V1 |
| C-V2 | `SKILL.md` bodies and compiledFragment markdown do not contain prompt-injection patterns | Asserted-only | Enforced | Sweep §3 vector V2 |
| C-V4 | Authored prose does not contain tier-bypass phrasings (the seed denylist subset) | Asserted-only | Enforced (partial — see Non-Goals re: tier-vocabulary lockfile) | Sweep §3 vector V4 |
| C-V6 | `humanReview` text in `module.yaml` is not diluted by prompt-injection patterns | Asserted-only | Enforced | Sweep §3 vector V6 |

**Claims explicitly NOT converted by v1** (remain Asserted-only after
this PRD ships):

- Sweep §3 V3 (supply-chain — npm/pip/PyPI compromise injecting into
  shared deps): out-of-genre; SAST work per OPP-0035 / Wave 5.4.
- Sweep §3 V5 (consumer-local agent-pack tampering at runtime):
  consumer-runtime concern, not harness-side.
- Sweep §3 V7-V10: addressed by other validators or out-of-scope.
- Sweep §4 runtime context classification: explicit Non-Goal above.

**Half-enforced after v1** (partial coverage):

- C-V4 partial: v1 denylist catches *some* tier-bypass phrasings
  (e.g., "always operates at Tier", "supersedes harness-governance"
  per sweep §3 Rec 2). Comprehensive tier-vocabulary lockfile (which
  would convert C-V4 fully to Enforced) is deferred per Non-Goals.

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Harness maintainer | The repo's primary owner | Confidence that authored prose can't carry prompt-injection or tier-bypass payloads past CI. |
| Harness contributor | Outside contributor filing PR that modifies authored prose | Clear validator output explaining what's flagged and why; an exemption path for legitimate pedagogical mentions. |
| Downstream consumer adopting auto-harness | Project applying the harness | The same validator runs against their active-module surface, giving them the same defense by default. |
| Security reviewer | External audit, red-team exercise | A documented denylist + adversarial-corpus fixture set they can stress-test against. |

## User Stories

- As a **harness maintainer**, I want the CI pipeline to fail when a
  PR introduces a known prompt-injection pattern into any active
  module's authored prose, so that I don't have to manually grep
  every diff for injection-string lookalikes.
- As a **harness contributor**, I want the validator's output to
  cite the matched pattern + file:line + recommended fix (rephrase
  / add to exemption file with justification), so that the failure
  is actionable without reading the validator source.
- As a **downstream consumer**, I want `validate-skill-content.sh`
  to run against my own active-module surface (not the harness's),
  so that my consumer-project gets the same defense by default
  with no extra setup.
- As a **security reviewer**, I want to drop a new adversarial
  fixture into `platform/validators/test/fixtures/adversarial/`,
  add the matching denylist pattern, and have the test suite
  confirm both ends close, so that the validator's coverage is
  empirically demonstrated and the corpus is append-only.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | The validator scans authored prose in active modules per the v1 scanned-fields set | Active-module enumeration via `HarnessRegistry.active_modules` (same library Wave 5.1 + 5.3 use). For each active module: (a) `module.yaml` fields `description`, `summary`, `humanReview`, `reviewGates`, `companionRules[].humanReview`; (b) every `SKILL.md` body referenced by the module's skills list; (c) every markdown file referenced by `compiledFragments`. | Per-field/per-line surfacing required. Bash + Ruby pattern same as Wave 5.1. |
| FR-002 | The v1 denylist matches the seed patterns specified below | Validator's `--help` enumerates the seed denylist. Each pattern's source is cited via inline comment in the validator script (sweep §3 Rec 2 line reference). | Seed list (~10 patterns) is the minimum bar; future PRs append. |
| FR-003 | Default posture is BLOCK (exit 1 on any hit unless exempted) | `validate-skill-content.sh` returns exit 1 when an active module's scanned field contains a denylist match not exempted by `.skill-content-ignore`. Exit 0 when clean. Exit 2 on usage error (missing project root, bad args). | No `--warn` flag at v1; unlike `validate-knowledge-redaction.sh` the absorption mechanism here is predict-clean. |
| FR-004 | `.skill-content-ignore` exemption file format is line-regex, one per line, `#` comments | Lines beginning with `#` are comments. Blank lines ignored. Each non-comment line is a regex tested against the matched line's content; if any regex matches, the hit is exempted. Format mirrors `.doc-reference-ignore` / `.placeholder-ignore` / `.knowledge-redaction-ignore`. | The exemption file is project-root scoped. |
| FR-005 | Adversarial fixture suite at `platform/validators/test/fixtures/adversarial/` covers every v1 denylist pattern | Each denylist pattern has at least one corresponding fixture file. The validator test suite (`platform/validators/test/test_validate_skill_content.rb`) iterates fixtures, scans each with `validate-skill-content.sh`, and asserts exit 1. The test fails if a pattern lacks fixture coverage. | Append-only discipline: future denylist additions ship with their fixture(s) in the same PR. |
| FR-006 | Validator wired into harness CI, consumer CI templates, AGENTS.md run-order, harness-governance SKILL.md, validators/README.md, root README.md tables and mermaid box | `validate-skill-content.sh` appears in the same documentation surfaces every prior validator was wired into. `validate-catalog-counts.sh` ASSERTIONS validator-count entries bump 12 → 13 at the 7 documented sites. | Standard Wave-style propagation. |
| FR-007 | The validator's own authored prose (its `--help`, its inline comment block citing the denylist patterns, the adversarial-corpus README) does not itself trigger the validator | `.skill-content-ignore` includes exemptions for the validator script itself + its test fixtures + the adversarial-corpus README. The dogfood pass passes. | Meta-§10 application: the validator's *own* declarations get scanned by sibling validators. |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-S01 | Validator output includes a suggested-fix hint per matched pattern | When a hit fires, stderr includes a "→ rephrase to avoid pattern" or "→ if pedagogical, add to `.skill-content-ignore`" hint. | Improves contributor friction. Not blocking for v1. |
| FR-S02 | Performance: scan completes in < 1s on the harness's own active-module set | Measured during implementation; if exceeded, add per-file content caching. Document scan time in change-log. | Per OPP-0033 Risk 4. |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| Auto-strip / auto-normalize zero-width and bidi characters | Write-side validators are themselves risk surface — an auto-fixer could become an injection vector | After v1 ships and the read-only detection mechanism is stable; only if detection-only proves insufficient |
| Tier-vocabulary lockfile (sweep §3 Rec 3) | v1's denylist catches *some* tier-bypass phrasings; a full lockfile is a separate design decision and a parallel-but-related closure for V4 | If v1's coverage proves insufficient against V4, file follow-up OPP |
| Scanning consumer-project content from harness CI | Consumer projects scan their own surface using the same validator; that's the recipe-reuse story not a separate feature | When consumer projects file feedback indicating per-consumer harness-CI cross-scanning is wanted |
| Runtime classification of compiledFragments | Requires AI-client-specific hooks; orthogonal defense | When session-cycle orchestration (PRD-0013) has agent-hook primitives |

## Implementation Deferral

Per operating principle § 9, a PRD whose natural scope would bundle
design work with the machinery that enforces it should ship the design
at v1 and defer the enforcement to a follow-up OPP/PRD pair. This PRD
is the design pass; the implementing PR adds the validator + fixtures.

| Deferred implementation | Deferred to | Why deferred |
|-------------------------|-------------|--------------|
| Tier-vocabulary lockfile (full coverage of C-V4) | Follow-up OPP iff v1 deny-list proves insufficient | Sweep §3 Rec 3 is a parallel-but-related design; deciding now would over-commit to a specific approach before v1 surfaces real-world V4 patterns |
| Runtime compiledFragment classification | v2 (post agent-hook primitives) | Requires AI-client-specific hooks |
| Auto-strip / auto-normalize | v2+ (post v1 detection stability) | Write-side validators are risk surfaces; v1 establishes detection baseline first |
| Adversarial-corpus expansion beyond v1 seed | Ongoing — new fixtures added as new attack patterns surface | The corpus is by-design append-only; v1 establishes the seed + the append discipline |

What v1 *does* commit to (the contract that must hold before any
follow-up is built):

- A working denylist scanner with 3-state exit, `--help`, and
  `.skill-content-ignore` exemption support.
- The seed denylist enumerated below in FR-002 / Technical Constraints.
- The seed adversarial-corpus fixture set.
- Full propagation to the documented harness surfaces (CI, AGENTS.md,
  SKILL.md, etc.).
- Validator-count bump 12 → 13 at 7 documented sites.
- BLOCK posture from PR 1 (predict-clean absorption mechanism).

## Technical Constraints

- **Bash 3.2 compatibility** — macOS default. Test on `bash --version`
  ≤ 3.2.
- **Shellcheck clean at warning severity** — `shellcheck -S warning`.
- **3-state exit contract** — 0 pass / 1 violation / 2 usage error.
- **Ruby for content scanning** — same pattern as `validate-trust-tier.sh`
  and `validate-sensitive-paths.sh`. Inline ruby via `ruby -e`.
- **No new runtime dependencies** — only Bash + system Ruby (already
  in CI environment per established pattern).
- **v1 seed denylist patterns** (per sweep §3 Rec 2, codified here so
  the PRD is the canonical source):
  1. `ignore previous instructions` (case-insensitive)
  2. `treat as Tier [0-5]` (case-insensitive) — V4 partial
  3. `always operates? at Tier` (case-insensitive) — V4 partial
  4. `skip (?:the )?validator` (case-insensitive)
  5. `supersedes? harness-governance` (case-insensitive)
  6. `^[[:space:]]*System:[[:space:]]` (role-prompt header)
  7. `^[[:space:]]*User:[[:space:]]` (role-prompt header)
  8. `^[[:space:]]*Assistant:[[:space:]]` (role-prompt header)
  9. Zero-width characters: U+200B, U+200C, U+200D, U+FEFF
  10. Unicode bidirectional override marks: U+202A–U+202E, U+2066–U+2069
- **Performance budget** — < 1s scan on harness's own active-module
  set. Measured during implementation per FR-S02.

## CI/CD Gates

| Gate | Required? | Notes |
|------|-----------|-------|
| Lint passes (markdownlint, shellcheck) | Yes | This PRD's body passes markdownlint; the implementing validator passes shellcheck |
| Test coverage threshold | Yes (functional) | Every v1 denylist pattern has at least one adversarial fixture; test suite asserts each is flagged |
| Required tests added | Yes | `platform/validators/test/test_validate_skill_content.rb` |
| Validator chain passes | Yes | The new validator joins the chain; chain itself stays green |
| Companion-rule check passes | Yes | `validate-companions.sh` passes; the new validator's `sensitivePaths` (if any) overlap an active trigger |
| Change-log updated | Yes | This PR + the implementing PR each get an entry |

## Success Metrics

| KPI | Target | How measured |
|-----|--------|-------------|
| Dogfood pass rate at PR 1 | 100% — harness's own authored prose passes v1 deny-list scan | Implementing PR's CI run |
| Adversarial-fixture coverage | 100% — every denylist pattern has ≥ 1 fixture, every fixture is flagged | Implementing PR's test suite |
| Validator scan time on harness tree | < 1s | Measured + logged in change-log |
| False-positive rate post-merge | 0 false positives in first 30 days post-merge | Tracked via maintainer triage; if > 0, add to `.skill-content-ignore` or refine denylist regex |

## Dependencies

- `platform/validators/lib/harness_registry.rb` — module enumeration (same library Wave 5.1 + 5.3 use).
- Bash 3.2 + system Ruby (already in CI environment).
- No new gems, no new package manifests.

## Open Questions

- [ ] **Should the validator scan `README.md` files in `platform/agents/*/`?** OPP-0033 scope mentions "agent-pack READMEs" — but the v1 FR-001 scanned-fields set names `module.yaml` + `SKILL.md` + `compiledFragments` only. **Bias: defer agent-pack READMEs to v2.** Rationale: their content surface is broader and harder to scope cleanly; v1 prioritizes the highest-leverage surface (compiled-into-context fragments). If a contributor surfaces an agent-pack-README V1 instance, file follow-up.
- [ ] **Should `compiledFragments` scanning follow per-fragment `format` (e.g., raw vs templated)?** Bias: no — scan all referenced fragments uniformly at v1. The format-aware distinction (per sweep §4) is a v2 runtime defense concern, not a v1 static scan concern.
- [ ] **Should exempted lines still be reported as "exempted" in verbose mode?** Bias: yes — `--verbose` flag lists exemptions with the regex that matched, so the exemption-file maintenance discipline (no unbounded growth) can be reviewed. Default output stays terse.

These open questions are *implementation-level*, not *design-level*.
The PRD commits to the FR-001 scanned-fields set, the FR-002 denylist
seed, the FR-003 BLOCK posture, and the FR-004 exemption format. The
implementing PR may resolve the above via stated Bias positions; if
the implementation surfaces design-level questions that the PRD
elides (per the [Wave 5.1 mechanizing-doctrine
observation](../knowledge/shared-observations.md#mechanizing-doctrine-surfaces-prd-internal-inconsistencies-that-the-design-pass-elided--third-claim-vs-enforcement-classification-instance-empirical-not-transcribed)),
record them in the implementing PR's "Implementation Reconciliation"
section per the Wave 5.1 precedent.
