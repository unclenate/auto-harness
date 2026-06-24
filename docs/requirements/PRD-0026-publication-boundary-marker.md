<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0026: Publication-Boundary Marker — `validate-publication-boundary.sh`

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-24 | **Review Cycle:** On-change

**Status:** Accepted *(design-only per § 9; the implementing PR ships the validator + wiring)*
**Date:** 2026-06-24 (filed + accepted)
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Promoting OPP: [OPP-0048](../opportunities/OPP-0048-redaction-scope-and-publication-boundary-hardening.md) — `proposed`; this PRD ratifies its **thin wedge** (mechanism 1, the file-level `do-not-publish` blocking check) and flips OPP-0048 → `accepted` in the same commit. OPP-0048 mechanism 2 (the configurable content-denylist scan-scope extension) is explicitly **staged to a phase-2 follow-up**.
- Parent OPP: [OPP-0036](../opportunities/OPP-0036-validate-knowledge-redaction.md) — `validate-knowledge-redaction.sh`, the content-denylist primitive this hardens. This PRD's validator is its file-publication-intent sibling: where OPP-0036 matches *content* against a name denylist, this matches *publication intent* against `git ls-files`.
- Related ADR: [ADR-0017](../adr/ADR-0017-safety-hardening-roadmap.md) — Safety Hardening Roadmap; this extends the §8/§9 leakage-pathway closures with a publish-time gate.
- Sibling validator precedent: [`validate-knowledge-redaction.sh`](../../platform/validators/validate-knowledge-redaction.sh) (PRD-0036/OPP-0036) — diff/tree scan + exemption-file convention + WARN/BLOCK posture lever; and [`validate-placeholders.sh`](../../platform/validators/validate-placeholders.sh) — the *always-on, kernel-level, non-module-gated* safety-validator shape this PRD follows (it is **not** a predict-clean opt-in module validator).
- Related operating principles:
  - [§ 5 Self-Governance](../operating-principles.md#5-self-governance) — the harness is a public repo that must not leak the private material it parks; this mechanizes the boundary instead of asserting it.
  - [§ 9 Split Design from Implementation](../operating-principles.md#9-split-design-from-implementation) — this PRD ships the design contract; the implementing PR ships the validator + propagation.
  - [§ 10 Classify Claims Before Enforcing Them](../operating-principles.md#10-classify-claims-before-enforcing-them) — see the §10 block below; this converts an Asserted-only convention to Enforced.
- Related observations:
  - `docs/knowledge/shared-observations.md` — *"redaction primitive needs a file-level `do-not-publish` blocking marker (which requires no name corpus)"* (2026-06-17, OPP-0048 filing) — the design this PRD ratifies.
- Multi-agent workspace context: `project-codex-multiagent` — Claude, Codex, and Gemini commit under one git identity here, so a per-file convention does not scale with agent count; a machine check does.

## Overview

auto-harness is a **public** repository that, in normal operation, parks
**untracked private design material** under `docs/superpowers/specs/` — most
concretely a 716-line Digital-Twin seed brief naming several private/client
projects, held untracked by maintainer decision. That decision is enforced
**today only by agent memory and manual `git add` discipline**. The directory is
excluded from `.placeholder-ignore` *and* the markdownlint ignore globs, and the
redaction scanner does not look there, so a single `git add -A` from any of the
three agents sharing this repo's git identity would publish it **tripping zero CI
guardrails** — irreversibly, against a public, indexed, mirror-able remote.

This PRD specifies a v1 **always-on, kernel-level safety validator** —
`validate-publication-boundary.sh` — that asserts **no git-tracked file declares
a `do-not-publish` marker**. The marker is an intent declaration that travels
*with* the artifact; the steady state (marker present in an *untracked* file) is
invisible to `git ls-files` and passes cleanly. The instant a marked file is
staged or committed, the validator exits 1 (BLOCK). The check needs **no name
corpus** — it protects the whole file by declared intent, and generalizes to any
artifact (specs, briefs, exports), including non-markdown files.

**Why a per-file marker and not a directory glob.** A blanket
`docs/superpowers/specs/**` "never-track" glob is wrong: that directory holds
**ten already-tracked, legitimately-published** design specs (healthcare, AEC,
privacy, cybersec, digital-twin, geospatial, …) alongside the **one** untracked
unpublishable brief. A directory rule false-positives on all ten. Publication
intent is a per-file property; the marker model matches that reality.

v1 is the **file-publication-intent** mechanism only. Extending OPP-0036's
*content* scanner to a wider, configurable scan scope with a gitignored name
denylist (OPP-0048 mechanism 2) is **staged to a phase-2 follow-up** — its
denylist source-of-truth question is the genuinely hard part and is not on the
critical path to closing the live leak.

## Goals & Non-Goals

**Goals** — outcomes this PRD commits to delivering:

- Ship `platform/validators/validate-publication-boundary.sh` — Bash 3.2
  compatible, shellcheck-clean at warning severity, 3-state exit (0 pass / 1
  violation / 2 usage). It enumerates git-tracked files and fails if any declares
  the `do-not-publish` marker, listing every offending path on stderr.
- Define the marker precisely enough that a doc *discussing* it does not self-trip
  (see FR-002), with a `.publication-boundary-ignore` exemption file (regex
  patterns, one per line) for the unavoidable self-references (this PRD, the
  validator, the template, OPP-0048).
- Ship `platform/templates/governance/do-not-publish-marker.md` — a tiny template
  showing the two accepted marker forms (YAML frontmatter key and HTML-comment
  sentinel) plus a copy-paste line, so an author marking a parked file has a
  canonical reference.
- Wire the validator as an **always-on kernel check**: `kernel/base` module.yaml
  validators list, `.github/workflows/harness.yml`, `AGENTS.md` recommended
  run-order, `harness-governance/SKILL.md` validator chain + signature note,
  `platform/validators/README.md` script table, root `README.md` validators table
  and mermaid box, and the `validate-catalog-counts.sh` validator-count bump
  (18 → 19) at every documented site.
- Provide a **pre-commit hook** recipe (documented in the consumer upgrade path
  and the validator's `--help`) so the block fires *before* the push — the CI gate
  is the backstop; the pre-commit hook is the actual prevention.
- Apply the marker to the live forcing case: the implementing PR (or a paired
  local step) adds the HTML-comment marker to the untracked seed brief so the gate
  is protective from day one. The brief **stays untracked** — the marker edit is
  never committed.
- One paired distillation observation capturing the design pressure (a publish-time
  gate is a "must-NOT-be-tracked" assertion — the inverse of `requiredArtifacts`).

**Non-Goals** — outcomes explicitly out of scope:

- **Content/name redaction.** Matching client names in *content* is OPP-0036's
  job (and OPP-0048 mechanism 2, staged). v1 matches *publication intent*, not
  names. The two are complementary layers, not substitutes.
- **Preventing an `--no-verify` bypass or a force-add of an unmarked file.** A
  file with no marker is invisible to this check; the marker is an author-asserted
  intent, not a content classifier. v1 does not attempt to *infer* sensitivity.
- **Scrubbing git history.** v1 prevents the *first* publish of a marked file; it
  does not detect or remediate material already committed in history.
- **A module-gated / predict-clean posture.** This is a safety floor for *every*
  harnessed project, like `validate-placeholders`. It is always-on, not opt-in
  behind a module. Consumers who must disable it use the documented
  `disabledValidations` escape hatch.
- **The configurable content-denylist scan-scope extension (OPP-0048 mechanism 2).**
  Staged to a phase-2 follow-up; its gitignored-denylist source-of-truth design is
  the hard part and is not required to close the live leak.

## §10 Claim Classification

Per the [§10 operating principle](../operating-principles.md#10-classify-claims-before-enforcing-them):

| Claim ID | Claim | Current state | After v1 | Source |
|----------|-------|---------------|----------|--------|
| C-PUB-S1 | A file the maintainer has marked `do-not-publish` is never committed to the public tree | Asserted-only (agent memory + manual `git add` discipline) | **Enforced** (always-on; a tracked marked file fails CI / pre-commit) | OPP-0048 Thesis |
| C-PUB-S2 | The publish-time gate needs no corpus of private names to function | Asserted-only | **Enforced** — the marker is intent-based; the check is `marker ∧ git ls-files` | OPP-0048 mechanism 1 |
| C-PUB-S3 | The gate distinguishes the parked unpublishable file from co-located published specs | Asserted-only (human judgement) | **Enforced** — per-file marker, not a directory rule (10 tracked specs coexist with 1 marked brief) | this PRD Overview |

**Claims explicitly NOT converted by v1** (remain Asserted-only):

- **Content with private names but no marker is caught.** v1 is intent-based; an
  unmarked sensitive file is invisible. Name-content catching is OPP-0036 / OPP-0048
  mechanism 2 (staged).
- **A determined `--no-verify` + direct-push bypass is prevented.** The pre-commit
  hook is skippable by design; CI is the backstop, but CI on a public remote
  already runs *after* the push. This is the same after-the-fact limitation
  OPP-0036 documents; the marker shrinks the window, it does not seal it.
- **History already containing sensitive material is remediated.** Out of scope.

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Harness maintainer | The repo's primary owner | A machine gate that makes "leave this brief untracked" survive a fat-fingered `git add -A`, instead of depending on memory. |
| Multi-agent workspace | Claude / Codex / Gemini under one identity | A check that does not depend on every agent remembering a per-file rule the others never saw. |
| Consumer-project maintainer | A team adopting auto-harness with a multi-agent workflow | An always-on, opt-out-able publish-time gate they inherit for their own parked material. |
| Security reviewer | External audit / red-team | A first-class, mechanized publication boundary backing the framework's "public repo, private working material" claim. |

## User Stories

- As the **maintainer**, I want a parked brief marked `do-not-publish` to fail CI
  the moment it is staged, so an accidental `git add -A` cannot publish client
  names to a public remote.
- As an **agent in a shared-identity workspace**, I want the publication boundary
  enforced by a check rather than by convention, so I cannot violate a rule I was
  never told about.
- As a **consumer maintainer**, I want the gate always-on with a documented
  `disabledValidations` escape hatch, so I get the protection by default but can
  opt out with an auditable declaration.
- As an **author marking a parked file**, I want a canonical template showing the
  exact marker syntax, so I don't guess at frontmatter vs comment form.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | `validate-publication-boundary.sh` ships and enumerates git-tracked files | Bash 3.2 compatible, shellcheck-clean at warning severity, 3-state exit. Enumerates `git ls-files`; for each, tests for the marker; exits 1 listing every offending tracked path; exits 0 when none. Exit 2 on usage error (not a git tree, missing dependency). | Always-on; no manifest/module gating. |
| FR-002 | The marker is matched precisely enough to avoid self-trip | The marker is a line matching `^(<!--\s*)?do-not-publish:\s*true\b` — i.e. a YAML frontmatter key **or** an HTML-comment sentinel at line start. A prose mention like "the `do-not-publish: true` marker" mid-sentence does **not** match (not at line start). | Two accepted forms cover frontmatter-bearing and content-bearing files. |
| FR-003 | A `.publication-boundary-ignore` exemption file is honored | One regex per line; tracked paths matching any pattern are exempt from the scan. Seeded with the unavoidable self-references: this PRD, the validator script, the marker template, OPP-0048. Comments (`#`) and blank lines ignored. | Same convention as `.knowledge-redaction-ignore` / `.skill-content-ignore`. |
| FR-004 | Marker template ships | `platform/templates/governance/do-not-publish-marker.md` with tokenized header, both marker forms, and a copy-paste line. | Canonical author reference. |
| FR-005 | Validator wired as an always-on kernel check + count bump | Added to `kernel/base` validators list, `.github/workflows/harness.yml`, `AGENTS.md` run-order, `harness-governance/SKILL.md` chain + signature note, `validators/README.md`, root `README.md` table + mermaid box. `validate-catalog-counts.sh` validator count 18 → 19 at every documented site. | Standard validator propagation; NOT a new module, so no module-count bump. |
| FR-006 | Pre-commit hook recipe documented | The validator's `--help` and the consumer upgrade runbook show a pre-commit hook invocation. The hook is the prevention; CI is the backstop. | No hook is force-installed; it is documented + opt-in. |
| FR-007 | The live forcing case is protected | The implementing PR adds the HTML-comment marker to the untracked seed brief (a local, uncommitted edit) and demonstrates the validator fails when the brief is `git add`-ed in a throwaway check, passes when untracked. The brief remains untracked. | Proof the gate is protective, without ever committing the brief. |
| FR-008 | Integration tests | `platform/validators/test/test_validators_integration.rb` gains `validate-publication-boundary.sh` to `VALIDATOR_SCRIPTS` (help-coverage) + a `TestValidatePublicationBoundary` class: (a) clean tree passes, (b) a tracked fixture bearing the marker fails, (c) an ignore-file exemption is honored, (d) a mid-sentence prose mention does not trip. | Fixture-based; `--scan-file`/explicit-path seam if needed for a no-git fixture. |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-S01 | A `--staged` mode scans only `git diff --cached --name-only` | For fast pre-commit use, an optional flag restricts the scan to staged files. Default scans all tracked files. | Pre-commit ergonomics. |
| FR-S02 | Per-offender remediation hint | On failure, stderr prints `→ this file declares do-not-publish; git rm --cached <path> and keep it untracked, or remove the marker if publication is intended.` | Actionable output. |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| Content/name denylist scan over `docs/superpowers/specs/**` | OPP-0048 mechanism 2; needs a gitignored denylist source-of-truth design | Phase-2 follow-up PRD under OPP-0048 |
| Inferring sensitivity of unmarked files | v1 is intent-based, not a classifier | If unmarked leaks prove a real pattern |
| Git-history scrubbing of already-committed material | v1 gates the first publish only | Separate incident-response runbook |
| Force-install of the pre-commit hook | Consumers own their hook config | Document, don't mandate |

## Implementation Deferral

Per § 9 this PRD is the design pass; the implementing PR adds the validator,
template, ignore-file, wiring, count bump, tests, and the marker on the live
brief.

| Deferred implementation | Deferred to | Why |
|-------------------------|-------------|-----|
| Configurable content-denylist scan-scope (OPP-0048 mechanism 2) | Phase-2 follow-up PRD under OPP-0048 | Denylist source-of-truth (gitignored-local vs baseline) is the hard design; not on the critical path to closing the live leak |
| `--staged` pre-commit fast path (FR-S01) | Implementing PR (Should-Have) | Ergonomic, not required for the CI backstop |

## Technical Constraints

- **Bash 3.2 compatible**, **shellcheck clean at warning severity**, **3-state exit**.
- **Tracked-file enumeration via `git ls-files`** — the steady state (marker in an
  untracked file) is intentionally invisible; the check fires only on tracked files.
- **No new runtime dependencies** — Bash + git; system Ruby only if a fixture seam needs it.
- **Self-trip avoidance** — the line-start marker regex (FR-002) plus the
  `.publication-boundary-ignore` file (FR-003) keep the validator, this PRD, the
  template, and OPP-0048 from matching themselves.
- **Always-on** — wired into `kernel/base`, not gated behind a module; the
  `disabledValidations` escape hatch is the documented opt-out (precedent:
  `validate-sensitive-paths`).
- **Outside-git-tree behavior** — when run where `git ls-files` is empty or git is
  absent, exit 0 with an informational message (mirrors `validate-knowledge-redaction`
  shallow-checkout handling), so non-git dogfood contexts do not false-fail.

## CI/CD Gates

| Gate | Required? | Notes |
|------|-----------|-------|
| Lint (markdownlint, shellcheck) | Yes | PRD body passes markdownlint; the validator passes shellcheck |
| Required tests added | Yes | `TestValidatePublicationBoundary` + `VALIDATOR_SCRIPTS` entry |
| Validator chain passes | Yes | The new validator joins the chain and stays green on the harness (the seed brief is untracked) |
| Catalog counts | Yes | 18 → 19 validator count reconciled at every documented site |
| Change-log updated | Yes | This PR + the implementing PR each get an entry |

## Success Metrics

| KPI | Target | How measured |
|-----|--------|-------------|
| Dogfood pass at PR 1 | 100% — harness CI passes (seed brief untracked → no tracked marker) | Implementing PR CI |
| Forcing-case proof | Validator fails when the seed brief is staged, passes when untracked | FR-007 demonstration |
| Self-trip rate | 0 — no doc discussing the marker trips the check | Implementing PR CI |
| False-positive rate | 0 in first 30 days (no legitimately-tracked file wrongly flagged) | Maintainer triage |

## Dependencies

- `git` (already required by the harness CI environment).
- `.publication-boundary-ignore` convention (new, mirrors existing ignore files).
- No new gems, no new package manifests, no new modules.

## Open Questions

- [ ] **Frontmatter key vs HTML-comment sentinel as the *recommended* form?**
  **Bias: HTML-comment sentinel** (`<!-- do-not-publish: true -->`) for the
  general case — it is valid anywhere in a markdown file (frontmatter must be line
  1 and collides with the existing license-header comment), renders invisibly, and
  works for content-bearing files. The frontmatter key stays accepted for files
  that already carry frontmatter. The implementing PR finalizes the template
  wording.
- [ ] **Should the always-on check also cover untracked-but-staged files in the
  `--staged` path?** **Bias: yes** — staged is the pre-commit decision point;
  a staged marked file is exactly the violation to catch before the push.
- [ ] **Ship the marker on the seed brief as part of the impl PR, or as a separate
  local-only step?** **Bias: a local, uncommitted step** demonstrated in the PR
  description — the brief must never be tracked, so its marker edit must never be
  in a commit. FR-007 captures the demonstration without committing the file.

These are implementation-level. The PRD commits to the FR-001 validator contract,
the FR-002 marker grammar, the FR-003 exemption convention, the FR-004 template,
the FR-005 always-on wiring + count bump, and the FR-008 tests. The implementing
PR may resolve the above via the stated Bias positions.

## Acceptance Criteria for OPP-0048 → `accepted`

1. This PRD `Accepted`.
2. FR-001…FR-008 merged.
3. Full validator chain green on the PR (harness's own run passes — seed brief untracked).
4. The forcing-case demonstration (FR-007) shown: staged → fail, untracked → pass.
5. OPP-0048 mechanism 2 carried forward as a named phase-2 follow-up (not silently dropped).

## Versioning Implications

Validator-count bump (18 → 19) lands within the next v0.x batch. No module ships,
so no module-count change. The marker convention is additive and backward
compatible.
