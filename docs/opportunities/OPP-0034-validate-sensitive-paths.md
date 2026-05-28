<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0034 — Sensitive-Paths Overlap Validator (`validate-sensitive-paths.sh`)

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-27
**Last Updated:** 2026-05-27
**Confidence:** high

---

## Thesis

Ship `validate-sensitive-paths.sh` — a structural validator that asserts
every `sensitivePaths` pattern declared in any active `module.yaml` is
overlapped by at least one `companionRules.triggerPaths` regex on some
active module.

The `sensitivePaths` field is currently **documentary metadata read by
zero validators** (per safety-security-sweep § 2 claim 12: *"Asserted-
only — sensitivePaths field is read by zero validators — purely
documentary metadata"*). The README sells `sensitivePaths` as a security
feature; the code never reads the field. This OPP closes that doc-code
alignment gap by enforcing the structural invariant that gives
`sensitivePaths` its semantic meaning: a path declared sensitive MUST be
under elevated review via at least one companion rule.

The validator is ~30 lines of Ruby (per safety-security-sweep §6
Recommendation 1: "Add a validator that asserts `conflictsWith` symmetry
— if A conflicts with B, B's `module.yaml` must list A. Roughly 30 lines
of Ruby" — same shape applies here). Small surface, high-leverage close.

**Closes safety-security-sweep §2 claim 12 (Asserted-only → Enforced).**

Anchored under [ADR-0017](../adr/ADR-0017-safety-hardening-roadmap.md)
Wave 5.3. Smallest of the four new validators in the safety hardening
roadmap (half-day work).

## Origin / Evidence

- **safety-security-sweep.md § 2** explicitly classifies claim 12 as
  Asserted-only with the diagnosis: *"`sensitivePaths` field is read by
  zero validators — purely documentary metadata."* Recommendation 3 of
  §2 specifies the validator: *"a validator that asserts every declared
  `sensitivePaths` pattern has at least one companion rule whose
  `triggerPaths` overlaps it — turning claim 12 from documentary metadata
  into machine-checked structural metadata."*
- **safety-security-sweep.md § 7** documentation-code alignment finding:
  *"The README sells `sensitivePaths` as a security feature; the code
  never reads the field."* This is one of four No-code-anchor claims
  (#4 in the table) that the sweep flags as high-severity. This OPP is
  the specific closure for claim #4.
- **Existing kernel sensitivePaths declarations** (in
  `platform/core/kernel/base/module.yaml`): "Governance entrypoints"
  (`^HARNESS\.md$`, `^AGENTS\.md$`, `^CLAUDE\.md$`, `^\.github/CODEOWNERS$`)
  and "Governance automation" (`^\.github/workflows/`, `^scripts/`). All
  six patterns ARE overlapped by the kernel's own companion rule
  `triggerPaths`. So the kernel itself passes the proposed check today
  — the validator's value is preventing future drift, not catching
  current drift.
- **Recipe pattern existing in `validate-module-graph.sh`** which already
  iterates per-active-module `module.yaml` data via `HarnessRegistry`.
  The new validator extends the same `active_modules(...)` traversal
  with two additional projections: collect-all-sensitive-paths and
  collect-all-trigger-paths; assert overlap via regex compatibility.

## Why Now

- **The claim-vs-enforcement table in safety-security-sweep §2 is the
  current source of truth on the Asserted-only cluster.** Claim 12 is
  the lowest-hanging fruit on that table: small surface, well-scoped,
  no PRD-level design choices remaining.
- **Wave 1's `validate-list-completeness.sh` established the recipe for
  structural-invariant validators** (PR #72): discover entities via
  HarnessRegistry, iterate, assert per-entity property, fail with
  structured stderr. The same recipe applies here directly.
- **Future module additions will declare sensitivePaths.** Without this
  validator, every new module's declared sensitive paths can drift away
  from companion-rule coverage. Land the validator now and the next
  module that declares a new sensitive path has its rule-coverage
  enforced at PR time.

## Risks / Open Questions

1. **Regex overlap is non-trivial.** Two patterns "overlap" when there
   exists at least one string they both match. Strict overlap-checking
   is undecidable in general; this OPP should adopt a practical
   approximation: require the `sensitivePath` pattern to be either
   (a) literally listed as one of the companion-rule `triggerPaths`,
   (b) a substring of a `triggerPaths` regex, or (c) a regex subset by
   conservative anchor/character-class matching. The audit's framing —
   *"at least one companion rule whose triggerPaths overlaps it"* — is
   pragmatic; v1 should implement the pragmatic check and document the
   approximation.
2. **Cross-module overlap is allowed.** A module's `sensitivePaths` need
   not be covered by its OWN companion rule — coverage by any active
   module's companion rule suffices. v1 should explicitly support this.
3. **The kernel's existing declarations all pass.** v1 should ship with
   the harness's own tree as the dogfood test (mirror Wave 1's
   `test_runs_clean_against_harness_repo`). No fixing commit is needed
   (unlike Wave 1, which surfaced 6 pre-existing drift items).
4. **Consumer-side behavior.** Consumer projects that mount auto-harness
   as a submodule and add their own `sensitivePaths` should also gain
   coverage assertions. v1 should operate over the active-module set as
   declared in the consumer's manifest, not the harness's own — same
   shape as the existing validators.
5. **Companion to PRD-0006 trust-tier enforcement.** PRD-0006 closes
   claims 10–11 (no self-elevation, tier-ceiling-fixed); this OPP closes
   claim 12 (sensitive-paths). Together they convert three of the seven
   Asserted-only items to Enforced. They are orthogonal scopes; no
   integration work needed between Wave 5.1 and Wave 5.3.
