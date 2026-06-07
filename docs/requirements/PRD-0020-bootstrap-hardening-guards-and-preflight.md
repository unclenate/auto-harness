<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD-0020: Bootstrap Hardening — Instantiation-Boundary Guards + Dependency Preflight

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-06-06 | **Review Cycle:** On-change

**Status:** Accepted *(v1 shipped in the same PR — design and implementation together)*
**Date:** 2026-06-06
**Author:** @unclenate
**Reviewers:** @unclenate

## Cross-references

- Originating OPPs: [OPP-0041 — Onboarding Containment Safety](../opportunities/OPP-0041-onboarding-containment-safety.md), [OPP-0040 — Cross-Platform Install Prerequisites](../opportunities/OPP-0040-cross-platform-install-prerequisites.md)
- Recovery runbook: [`platform/workflow/recover-misplaced-consumer.md`](../../platform/workflow/recover-misplaced-consumer.md)
- Related ADR: [ADR-0003 — Submodule Integration](../adr/ADR-0003-submodule-integration.md)
- Architecture context: `docs/architecture/overview.md`

## Overview

`platform/bootstrap/install.sh` is the consumer entry point. Two real incidents
motivate hardening it at the moment of instantiation, before it writes anything:

1. **Wrong location (OPP-0041).** A consumer was bootstrapped *inside* the
   auto-harness platform repo, becoming a subdirectory committed into the
   platform's own history — caught only when a routine commit nearly pushed a
   private site into the public platform repo. Every validator had passed; the
   harness validates file *content* but never *where* the consumer is created.

2. **Missing/old toolchain (OPP-0040).** Hard dependencies (Bash 4+, Ruby 3.0+,
   ripgrep, git) were surfaced only mid-run, asymmetrically, and the docs were
   internally inconsistent about ripgrep. The dogfood machine itself ran Ruby
   2.6.10 with no `rg` on PATH — reproducing the consumer problem exactly.

This PRD adds, in `install.sh` and the `harness-onboarding` skill: (a) two
hard-fail **instantiation-boundary guards** (inside-platform, nested-repo) with
narrow escape hatches, and (b) an up-front **dependency preflight** with an
opt-in auto-installer for the deps that can be fixed safely.

## Goals & Non-Goals

**Goals**

- Refuse, by default, to bootstrap a consumer inside the platform repo or nested
  inside any other git repo — detected locally and unambiguously, before any write.
- Check every runtime dependency up front and report all gaps together with
  per-platform install commands; fail rather than complete against a broken toolchain.
- Offer opt-in auto-install for the deps that can be fixed safely, without making
  an environment-altering action the default.
- Apply the guards in both onboarding entry paths (`install.sh` and the skill).

**Non-Goals**

- **Auto-installing Ruby** — *(excluded: a system Ruby commonly shadows a
  package-manager Ruby, so a scripted fix is unreliable; we direct users to a
  version manager instead.)*
- **Protecting against fully manual mis-creation** (hand-authoring files with no
  harness tooling at all) — *(excluded: there is no instantiation moment to hook;
  out of reach by construction.)*
- **The greenfield over-assertion guard (OPP-0042)** — *(excluded: separate,
  softer "route-to-discovery" posture; remains `proposed`.)*

## §10 Claim Classification

| Claim | Classification |
|-------|----------------|
| A consumer cannot be bootstrapped inside the platform repo without `--inside-platform` | **Enforced** (hard-fail in `install.sh`; tested) |
| A consumer cannot be bootstrapped nested in another git repo without `--allow-nested` | **Enforced** (hard-fail in `install.sh`; tested) |
| Missing/old Bash/Ruby/ripgrep/git block completion with an actionable report | **Enforced** (hard-fail preflight; tested) |
| The skill refuses the same two locations | **Half-enforced** (instruction in SKILL.md; agent-followed, not mechanically gated) |
| Fully-manual mis-creation is prevented | **Asserted-only** (out of scope; documented as a Non-Goal) |

## Target Audience

| Persona | Who they are | What they need from this |
|---------|-------------|--------------------------|
| Adopter | A developer running `install.sh` to add the harness | To be stopped before a wrong-location or broken-toolchain bootstrap, with a clear remedy |
| Onboarding agent | Claude/other agent running the `harness-onboarding` skill | The same precondition check as a first step, so it never scaffolds in the wrong place |

## User Stories

- As an adopter, I want bootstrap to refuse when I'm in the wrong directory, so that I never commit a private project into the platform repo.
- As an adopter on a fresh machine, I want all missing dependencies reported at once with copy-paste install commands, so that I'm not debugging the toolchain mid-run.

## Functional Requirements

### Must Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-001 | Inside-platform guard | When `PROJECT_ROOT`'s enclosing git toplevel contains `platform/core/kernel/base/doctrine.md` and a `harness.manifest.yaml` whose `id` is `development-harness-framework`, `install.sh` exits 2 with a remedy, before any write. `--inside-platform` overrides. | Fingerprint unique to auto-harness's own repo. |
| FR-002 | Nested-repo guard | When `PROJECT_ROOT` is below (not equal to) an enclosing git toplevel that is *not* the platform, `install.sh` exits 2 with a remedy. `--allow-nested` overrides (monorepo subproject). | Skipped when `PROJECT_ROOT` is not in a git repo. |
| FR-003 | Dependency preflight | Before any write, check git, Ruby ≥ 3.0, ripgrep (Bash 4+ already enforced). If any missing, print all gaps together with per-platform install commands and exit 2. | Replaces the asymmetric, discover-it-late behavior. |
| FR-004 | Opt-in installer | `--install-deps` auto-installs the safe deps (git, ripgrep) via the detected package manager (brew/apt-get/dnf/pacman), re-checks, and only then proceeds or fails. Ruby is never auto-installed. | Environment-altering / Tier 4 — off by default. |
| FR-005 | Preflight bypass for CI/tests | `HARNESS_SKIP_DEPCHECK=1` skips only the dependency preflight, never the location guards. | Documented as test/CI/advanced-only. |
| FR-006 | Skill precondition | `harness-onboarding` SKILL.md adds, as a first step, the same inside-platform / nested-repo refusal with a pointer to the recovery runbook. | Closes the skill entry path. |
| FR-007 | Recovery runbook | `platform/workflow/recover-misplaced-consumer.md` documents extracting a mis-created consumer (unpushed vs pushed cases), indexed in SUMMARY and cross-linked from submodule-integration. | The cure paired with the prevention. |
| FR-008 | Tests | Bootstrap suite covers: inside-platform refusal + escape, nested refusal + escape, preflight missing-dep report, `--install-deps` no-package-manager path. Existing tests stay green via the bypass. | `platform/bootstrap/test/test_install.rb`. |

### Should Have

| ID | Requirement | Acceptance Criteria | Notes |
|----|-------------|---------------------|-------|
| FR-009 | Docs | `platform/bootstrap/README.md` documents the new flags, the preflight, the guards, the bypass env var, and the exit semantics. | Keeps the bootstrap reference current. |

### Out of Scope

| Feature | Reason excluded | When to revisit |
|---------|----------------|-----------------|
| Greenfield over-assertion guard | Separate posture (OPP-0042) | When OPP-0042 is promoted |
| Auto-installing/managing Ruby versions | Unreliable from a script (system Ruby shadows) | If a robust version-manager hook emerges |

## Technical Constraints

- Bash 4+ (consistent with `install.sh`'s existing requirement); shellcheck-clean.
- Guards must run before any filesystem write and must not fire when `PROJECT_ROOT`
  is not inside a git repo (a not-yet-init'd consumer dir trips neither guard).

## Success Metrics

| Metric | Target | Source |
|--------|--------|--------|
| Guard behaviors covered by tests | 4/4 (2 guards × refuse + escape) | `test_install.rb` |
| Existing bootstrap tests still green | 100% | CI |
| Real toolchain gap caught up front | Yes (verified: Ruby 2.6.10 + missing rg on the dogfood machine) | Manual run |

## Dependencies

- `git` (for the guard's `rev-parse --show-toplevel`), present wherever submodule
  adoption is possible.

## Open Questions

- Should the nested-repo guard also warn (not fail) for a `PROJECT_ROOT` that *is*
  a git root but whose parent is also a repo (sibling-nesting)? Deferred; current
  scope keys on enclosing-toplevel ≠ project-root.

## Acceptance Criteria for OPP-0040 + OPP-0041 → `accepted`

Both OPPs flip to `accepted` in this PR, with this PRD referenced in their
Promotion fields, when FR-001–FR-008 ship and the bootstrap suite is green.
FR-009 (docs) ships in the same PR.
