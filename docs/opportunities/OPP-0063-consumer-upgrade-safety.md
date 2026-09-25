<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0063 — Consumer-upgrade safety: compat affordances for breaking changes and layout-agnostic validators

**Status:** proposed
**Owner:** @unclenate · **Created/Updated:** 2026-09-16
**Confidence:** high (F1–F4 re-derived against the real validators on disk; F2 is an unambiguous
breaking-change defect); medium (the exact fix shape for each finding is a review choice)
**Parent:** OPP-0025 (consumer integration smoke-test) · relates PRD-0033 (relational-sql rename),
OPP-0023 / PRD-0012 (consumer-aware doc-references)

## Thesis

Upgrading four consumer repositories from pins in the `v0.5.1-66 … v0.6.0-6` range to current `main`
(`v0.6.0-46`, `b89c7fe`) surfaced four consumer-facing breaks plus one process gap. They share **one root
cause: the harness assumes its own dogfooded layout (repo-root `platform/`, repo-root `SUMMARY.md`,
`docs/` at root) is the consumer's, and at least one breaking change (a module rename) shipped with no
consumer-compat affordance.** A maintainer's green validator chain does **not** predict a consumer's,
because activation sets and doc layouts differ per consumer — so each of the four repos broke differently,
and two were already CI-red on `main` unnoticed.

This is the same triage lesson as the 2026-09 adversarial audit ([[project_adversarial_audit_2026_09]]):
some of these are the *deliberate* governance-harness posture (a documented affordance the consumer did not
use), and one (F2) is a genuine defect. Each finding below is labelled accordingly. The unifying fix is a
**consumer-compat contract**: breaking catalog changes ship a one-release deprecation affordance, and the
always-on structural validators tolerate a declared non-root layout instead of assuming the harness's own.

## Findings (each re-derived against the real validators on disk, 2026-09-16)

### F2 — module rename shipped as a hard cutover, no alias *(DEFECT — the load-bearing finding)*

The `data/relational-postgres` → `data/relational-sql` rename (PRD-0033) deleted the old module id with no
alias. Confirmed on disk: only `platform/profiles/data/relational-sql/` exists; zero `relational-postgres`
references remain in the platform tree. A consumer that **actively selects** the old id in its
`harness.manifest.yaml` crashes 9 of 14 validators with `Missing module definition for
data:relational-postgres` on the first run at the new pin. A maintainer's own pre-flight stays green if the
maintainer only *mentions* the module in a comment rather than activating it — so the break is invisible
upstream. This violates the harness's own breaking-change discipline (a rename is a breaking change and owes
a compat affordance).
**Proposed fix:** ship a **one-release deprecation alias** (old id → new id, resolved with a WARN) and a
**BREAKING note** in `change-log.md` at rename time; optionally scan known-consumer manifests when renaming
a shipped module.

### F1 — `validate-list-completeness` hard-codes a repo-root `SUMMARY.md` *(GAP)*

After `cd "$PROJECT_ROOT"`, the ADR/PRD/OPP nav assertions reference a bare `"SUMMARY.md"` — i.e. root-level
only, with no `docs/SUMMARY.md` fallback and no `.gitbook.yaml` awareness. A consumer that publishes GitBook
from `docs/` (`.gitbook.yaml` `root: ./docs/`) keeps its TOC at `docs/SUMMARY.md`, which the validator never
reads → it fails despite a complete nav, forcing the consumer to add a second root-level validator-facing
`SUMMARY.md`.
**Proposed fix:** honor `.gitbook.yaml` `root:` when present, **or** accept either `SUMMARY.md` or
`docs/SUMMARY.md`, **or** make the SUMMARY-nav arm opt-in for a declared non-root GitBook root.

### F3 — `validate-catalog-counts` misreads a submodule-mount consumer as count-drift *(UX DEFECT + affordance gap)*

`validate-catalog-counts.sh` does `PROJECT_ROOT="${1:-$(pwd)}"; cd "$PROJECT_ROOT"` then runs
`find platform/profiles …` relative to that root, with no detection of where `platform/` actually lives. A
submodule consumer mounts the platform under `.harness/`, so `validate-catalog-counts.sh .` finds nothing and
the mismatch reads as **count-drift** rather than a wrong-root error. Pointing the validator at `.harness` is
the existing affordance (as documented for `validate-doc-references`), but catalog-counts neither auto-detects
nor errors clearly.
**Proposed fix:** auto-detect the directory containing `platform/` (walk up / check `.harness/`), **or** exit
`2` with an explicit "no `platform/` under `<root>` — pass your submodule mount" message instead of silently
computing zero.

### F4 — `validate-placeholders` date arm false-positives on legitimate date-format docs *(PRECISION GAP)*

The pattern `\[\[[A-Z0-9_]+\]\]|YYYY-MM-DD` matches the literal token `YYYY-MM-DD` **anywhere**, including
inside code spans and string examples (a JSDoc `…HH:MM` line, a JSON `"generated": "YYYY-MM-DD…"` example). A
consumer sat blocking-red for two months on a stable documentation line. `.placeholder-ignore` is the
*documented intended remedy* — so this is partly posture — but the date arm's imprecision makes the default
experience a false alarm.
**Proposed fix:** narrow the date arm (skip matches inside code spans / fenced blocks / quoted strings, or
require an accompanying placeholder marker), **and/or** document in the validator `--help` that
`.placeholder-ignore` is the intended remedy for legitimate date-format documentation.

### F5 — a consumer upgrade-preflight runbook exists but does not cover these break classes *(PROCESS — augment, not build)*

`platform/workflow/consumer-upgrade-runbook.md` (and `platform/bootstrap/upgrade.sh`) already exist — so this
is not a new-runbook request. The gap is that the runbook does not warn about the specific break classes this
upgrade surfaced: module-rename cutovers, new always-on index surfaces (a validator added since the pin), and
path-assumption failures on non-root layouts. It also does not state the core discipline plainly: **run the
FULL chain your CI invokes, from the paths your CI uses; a green chain in the harness or in another consumer
is not a substitute.**
**Proposed fix:** augment the existing runbook with a break-class checklist and that discipline statement.

## Scope & disposition

Design-only, `proposed`. F2 is the priority (a live breaking-change defect); F1/F3/F4 are validator hardening
that make the always-on structural checks layout-agnostic; F5 is a doc augmentation. A reasonable split is a
short **F2-first** implementation pass (alias + BREAKING note) followed by an F1/F3/F4 validator-hardening
PR and the F5 runbook edit — or a single bundled hardening PR if scoped together. Advancing to `accepted`
requires a decision on the four open questions below. No transport, trust-tier, or control-schema change is
implied.

## Open questions

1. **F2 alias mechanism** — a manifest-resolution alias table (old id → new id) resolved with a WARN, vs a
   thin shim `module.yaml` at the old path that `extends` the new one; and how long the alias lives (one
   minor? until the next major?).
2. **F1 layout detection** — honor `.gitbook.yaml root:` (couples the validator to a GitBook file) vs accept
   either `SUMMARY.md` location unconditionally vs an opt-in manifest flag for a non-root docs root.
3. **F3 auto-detect vs explicit-error** — is walking up to find `platform/` too magical (prefer a loud exit
   2), or is auto-detection the right consumer ergonomics?
4. **F4 default posture** — narrow the regex (risk: a real unresolved `YYYY-MM-DD` template token inside a
   code fence slips through) vs leave the pattern and rely on documented `.placeholder-ignore`.

## Provenance & independent-verification note

**Field-reported 2026-09-16** by a coordinator session upgrading four live consumer repositories, relayed
via a peer session and **independently re-derived here against the real validators** before filing (per
[[feedback_peer_handoff_verification]]): F1, F2, F3, and F4 were each confirmed by reading the named
validator on disk; F5's runbook was found to **already exist**, correcting the report's implication that a
runbook must be built. Credited generically. The peer's public-safe draft was not used as a source — the
findings here are re-derived from the validators themselves. No private consumer names, hostnames, or
identifiers are carried into this record.

## Neighbors

- **OPP-0025** (consumer integration smoke-test) — the CI mechanism that *should* catch this class; F5's
  runbook is the manual companion for the upgrade path this OPP is about.
- **PRD-0033** (relational-postgres → relational-sql rename) — the origin of F2; this OPP proposes the compat
  affordance that rename omitted.
- **OPP-0023 / PRD-0012** (consumer-aware `validate-doc-references`) — the precedent affordance F3 asks
  catalog-counts to match (scan whichever root you're given; point at the submodule mount).
- [[project_adversarial_audit_2026_09]] — the defect-vs-deliberate-posture triage doctrine applied here.
