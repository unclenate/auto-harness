<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0017: Safety Hardening Roadmap

**Status:** Accepted
**Date:** 2026-05-27
**Author:** @unclenate
**Reviewers:** @unclenate
**Context sources:**

- `documentation-audit-2026-05-27/safety-security-sweep.md` — the originating audit: eight named safety dimensions, ~70 findings consolidated to ~30 distinct items, plus the cross-cutting structural-cause framing
- `documentation-audit-2026-05-27/refresh-2.md` — the open-findings ledger that named M-j (list-completeness) as the single highest-leverage outstanding item; Wave 1 closed M-j (PR #72)
- `documentation-audit-2026-05-27/execution-roadmap.md` § 5 (this ADR's sequencing) and § 8 (Wave 5 — Safety hardening — the multi-PR implementation track this ADR shelters)

## Context

The 2026-05-27 safety sweep enumerated 19 load-bearing claims the framework
makes about agent behavior and governance contract integrity, classified
each as **Enforced**, **Half-enforced**, or **Asserted-only**. The result:

| Status | Count | Examples |
|---|---|---|
| **Enforced** | 9 | required artifacts, manifest structure, module-graph dependencies, companion rules, forbidden patterns, catalog counts (numeric only), doc references, agent-pack structure |
| **Half-enforced** | 3 | disabled-validations override; entrypoint distinct-jobs; qualitative catalog propagation |
| **Asserted-only** | 7 | no-self-elevation; tier-ceiling-fixed; sensitive-paths; kernel-doctrine override; second-human "Harness Ready"; design-vs-implementation split; module text in stripped contexts |

**Six of the seven Asserted-only items are about agent behavior or
governance contract integrity** — exactly the surface that matters most
for the framework's stated mission. The trust-model document itself names
this gap candidly. The sweep's framing, stated plainly:

> The framework's enforcement surface is structural-only. Validators
> check that files exist, that paths match regexes, and that integers
> in documentation match canonical recipes. They do not check that
> lists are complete, that wording preserves a tier declaration, that
> a claim made in prose has a code anchor, or that consumer-specific
> content has been redacted before being absorbed into framework
> doctrine.

This is the same cross-cutting insight refresh-2 surfaced (the M-j
list-completeness drift) and ia-restructure-proposal surfaced (the
documentation IA can't teach what enforcement claims aren't true). The
three audit deliverables argue the same architectural move in three
voices:

- **Refresh #2:** ship list-completeness validation *(done — Wave 1)*
- **IA proposal:** restructure the nav to stop teaching the catalog
  and start teaching the journey *(ADR-0016 + Wave 6)*
- **Safety sweep:** ship content-safety validation, trust-tier
  enforcement, sensitive-path enforcement, and the redaction validator
  *(this ADR + Wave 5)*

All three are flavors of the same move: **turning honor-code into
code-code.** ADR-0017 is the safety-roadmap expression of that move.

The sweep's § 16 ("If you do only five things") names the priority order
this ADR adopts. Two of the five are already in-flight or shipped
(list-completeness via Wave 1; PRD-0006 trust-tier already drafted);
this ADR formalizes the priority order for the remaining three and
files OPPs for the four new validator surfaces (content-safety,
sensitive-paths, security-static-analysis, knowledge-redaction).

## Decision

Adopt the safety hardening priority order from safety-security-sweep §16
as the framework's safety roadmap. Each priority maps to one already-
existing artifact or one OPP filed alongside this ADR, with explicit
sequencing for Wave 5 implementation per execution-roadmap § 8.

### The five priorities

| # | Priority | Closes claim(s) from sweep §2 | Implementation artifact |
|---|---|---|---|
| 1 | **List-completeness validation** *(done — Wave 1)* | claim 19 (qualitative catalog propagation — partial) | `validate-list-completeness.sh` shipped in [PR #72](https://github.com/unclenate/auto-harness/pull/72); see [ADR-0016 Implementation Deferral](ADR-0016-documentation-ia-phase-3-4-target-structure.md) for the SUMMARY.md coverage extension deferred to Wave 6 |
| 2 | **Trust-tier enforcement (PRD-0006)** | claims 10–11 (no self-elevation; tier-ceiling fixed) | Already drafted as [PRD-0006](../requirements/PRD-0006-trust-tier-enforcement.md); already exists as [OPP-0006](../opportunities/OPP-0006-trust-tier-enforcement.md) — Wave 5.1 ships implementation |
| 3 | **Content-safety scanner (`validate-skill-content.sh`)** | red-team attack vectors V1, V2, V4, V6 from sweep §3 | **NEW** [OPP-0033](../opportunities/OPP-0033-validate-skill-content.md) — Wave 5.2 |
| 4 | **Sensitive-paths overlap validator (`validate-sensitive-paths.sh`)** | claim 12 (sensitive paths trigger elevated review) | **NEW** [OPP-0034](../opportunities/OPP-0034-validate-sensitive-paths.md) — Wave 5.3 |
| 5 | **Security static analysis module (`management/security-static-analysis`)** | sweep §11 (underhanded code in agent output — the largest mission-relative gap) | **NEW** [OPP-0035](../opportunities/OPP-0035-security-static-analysis.md) — Wave 5.4. Anchored as a child OPP under [OPP-0020](../opportunities/OPP-0020-evaluation-tooling-in-harness-toolchain.md) (eval/safety tooling) per execution-roadmap §8 |

Plus one additional priority surfaced by the sweep §8 cross-pollination
findings and §9 reverse-direction propagation pathways, not in the §16
top-five but explicitly recommended as part of the same hardening track:

| # | Priority | Closes claim(s) | Implementation artifact |
|---|---|---|---|
| 6 | **Knowledge-redaction validator + CODEOWNERS on `docs/knowledge/`** | sweep §8 (cross-pollination) + §9 (upstream-propagation pathways 1–4) | **NEW** [OPP-0036](../opportunities/OPP-0036-validate-knowledge-redaction.md) — Wave 5.5 |

### Wave 5 sequencing

Per execution-roadmap § 8, the five Wave 5 sub-items execute in this
order to amortize risk and pattern-establishment cost:

```text
5.1 — PRD-0006 trust-tier enforcement       (already drafted; lowest implementation risk)
   ↓
5.3 — validate-sensitive-paths.sh           (half-day; small surface)
   ↓
5.5 — validate-knowledge-redaction.sh       (small; pairs with CODEOWNERS)
   ↓
5.2 — validate-skill-content.sh             (needs adversarial corpus; pattern follows from 5.3/5.5)
   ↓
5.4 — management/security-static-analysis   (largest; benefits from prior pattern establishment)
```

### Architectural commitments

- **Validators only — no doctrine rewrites.** This roadmap converts
  honor-code claims to code-checked claims; it does not change what
  the claims *are*. Trust-tier doctrine, sensitive-paths intent,
  knowledge-redaction principles, and SAST-coverage expectations are
  already documented; this ADR commits to enforcing them.
- **OPPs adopt the §9 design-then-enforce pattern.** Each new OPP
  ships its design at v1 (the validator's contract and scope); its
  per-rule enforcement extensions can defer to a v2 OPP if scope
  bloats. Same discipline ADR-0016 uses; same pattern PRDs 0011/
  0013/0014 established.
- **No new sensitive-paths added to `kernel/base/module.yaml`.**
  The new validators read the existing `sensitivePaths` declarations
  on consumer module.yaml files (validate-sensitive-paths) or scan
  authored content under existing governance paths (validate-skill-
  content, validate-knowledge-redaction). The kernel's sensitive-
  path set does not expand.
- **`management/security-static-analysis` is opt-in.** The SAST
  module overlays new artifact requirements and a validator only
  when a project's manifest activates it. Existing consumers are
  unaffected; new adopters get the option. Same opt-in shape as
  `management/eval-gated-testing` (OPP-0019 / PRD-0009).
- **`docs/knowledge/` CODEOWNERS rule is additive.** The rule routes
  reviews of `shared-observations.md` and `operating-principles.md`
  through the maintainer; it does not change who can edit. Same
  shape as the existing CODEOWNERS coverage on `platform/profiles/`.

## Implementation Deferral

Per operating principle § 9 ("Split Design from Implementation"), this
ADR ships the *priority order + OPP queue* at v1 and defers the per-OPP
PRDs, validators, and module construction to Wave 5 PRs. A deferred
implementation that is not written down is indistinguishable from a
forgotten one; each is enumerated below.

| Deferred implementation | Deferred to | Why deferred |
|---|---|---|
| Promote OPP-0006 → PRD-0006 implementation (`module.yaml` `tier` / `defaultTier` field + `validate-trust-tier.sh`) | **Wave 5.1** | PRD already drafted; implementation is bounded but distinct from this ADR's priority-setting scope |
| Implement OPP-0033 → PRD + `validate-skill-content.sh` + adversarial-corpus fixtures | **Wave 5.2** | Needs the adversarial corpus to be useful; OPP captures the design contract |
| Implement OPP-0034 → PRD + `validate-sensitive-paths.sh` (assert every declared `sensitivePaths` pattern is overlapped by at least one `companionRules.triggerPaths` regex) | **Wave 5.3** | Half-day work; OPP captures scope |
| Implement OPP-0035 → PRD + `management/security-static-analysis` module + `validate-sast-coverage.sh` | **Wave 5.4** | Largest single item in Wave 5 (1–2 weeks); benefits from patterns established by 5.1/5.3/5.5 first |
| Implement OPP-0036 → PRD + `validate-knowledge-redaction.sh` + `docs/knowledge/` CODEOWNERS rule | **Wave 5.5** | Small scope; pairs with the §8/§9 cross-pollination / reverse-leakage findings |

What v1 *does* commit to (the contract that must hold before any
enforcement is built): the priority order above, the Wave 5 sequencing,
the architectural commitments, and the four new OPPs filed alongside
this ADR. The per-OPP PRDs and validator code are not.

## Consequences

**Positive:**

- Six of seven Asserted-only claims from sweep §2 gain a named closure
  path. The seventh (claim 18 — "module text reads cleanly in stripped
  contexts") is documented as by-design honor-code; this ADR does not
  re-scope it.
- Five of the ten red-team attack vectors from sweep §3 (V1, V2, V4,
  V6 via OPP-0033; V12 via OPP-0034) gain structural defenses.
- The §11 underhanded-code blind spot — *the largest mission-relative
  gap in the sweep* — gains a named module (OPP-0035) anchored under
  the maintainer's existing OPP-0020 work, avoiding a duplicate parallel
  track.
- The §8 cross-pollination risk and §9 upstream-propagation pathways
  gain a single named OPP (OPP-0036) rather than per-incident remediation.
- One ADR covers a multi-PR multi-week safety hardening track cleanly,
  mirroring ADR-0013's role for documentation Phases 0–2 and ADR-0016's
  role for Wave 6 IA migration. The kernel governance-entrypoint
  companion rule is satisfied by citation to this ADR from each
  subsequent Wave 5 PR.

**Negative / costs:**

- Wave 5 is estimated at 2–3 weeks of multi-PR work (per execution-
  roadmap § 8). Until Wave 5 lands, the Asserted-only cluster remains
  honor-code. Wave 1 (list-completeness) closed one item structurally;
  Wave 5 closes the remaining six.
- Filing four new OPPs in one PR is unusual for the project. Each is
  scoped at the design-contract level (per the §9 pattern); deeper
  PRD work happens per-OPP during Wave 5. Risk: a future maintainer
  finds the OPPs underspecified and re-litigates the scope. Mitigation:
  the safety sweep is the cited substantive case; the OPPs themselves
  are intentionally pointer-shaped.
- `management/security-static-analysis` (Wave 5.4) is the largest
  single piece of work in this roadmap (1–2 weeks). It is sequenced
  last specifically because the patterns established by 5.1/5.3/5.5
  reduce its design risk. If 5.4 stalls, 5.1–5.3+5.5 still deliver
  five of the six priority closures.

**Risk:**

- If Wave 5 stalls before completion, the Asserted-only cluster
  remains partially closed. Mitigation: the priority order above is
  graceful — each priority is independently valuable; stopping at any
  point still delivers a measurable safety-profile improvement.
- The §3 red-team attack vectors V7, V8, V9, V10 (long-tail and lower-
  severity) are *not* closed by this roadmap. They are documented in
  the sweep and acknowledged in OPP-0031 (defense-in-depth); their
  remediation is a future Wave's work.

## Alternatives considered

**Bundle OPPs into one mega-OPP.** Reject filing four OPPs; ship one
"safety-hardening OPP" that lists the four validators internally.
Rejected: each validator has a distinct scope, distinct test surface,
and distinct PRD path. Bundling would defer the OPP-promotion decision
to Wave 5 PRs, increasing per-PR friction. The §9 design-vs-implementation
pattern argues for shipping the design at the right grain — one OPP per
distinct enforcement surface is the right grain.

**Defer the safety roadmap until Wave 6 (IA migration) completes.**
Rejected: Wave 6 is estimated at 3–4 weeks. The Asserted-only safety
gaps have been open since the project's inception; further delay does
not improve them. ADR-0016 (Wave 2a) and this ADR (Wave 2b) are
parallel-safe per execution-roadmap § 5; both can proceed without
blocking each other.

**Skip the priority-order ADR; let Wave 5 PRs each cite the safety
sweep directly.** Rejected: this reproduces the per-PR change-log
friction the project's ADR-shelter pattern was designed to prevent
(ADR-0013 for documentation Phases 0–2; ADR-0016 for Wave 6). The
roadmap §5 explicitly recommends this ADR as the multi-PR shelter
for the same reason.

**Implement the four new validators inline in this PR.** Rejected:
violates the per-PR contract of "one PR per roadmap item" (per the
session-execution protocol) and would conflate the priority-setting
decision with five distinct implementation surfaces. Wave 5's
sequencing (5.1 → 5.3 → 5.5 → 5.2 → 5.4) is explicitly designed for
incremental landing.

## References

- [Safety & Security Sweep](../../documentation-audit-2026-05-27/safety-security-sweep.md) — the originating audit
- [Refresh #2](../../documentation-audit-2026-05-27/refresh-2.md) — the open-findings ledger
- [Execution Roadmap](../../documentation-audit-2026-05-27/execution-roadmap.md) § 5 (this ADR's sequencing) and § 8 (Wave 5 implementation plan)
- [ADR-0016: Documentation IA Phase 3–4 Target Structure](ADR-0016-documentation-ia-phase-3-4-target-structure.md) — parallel-safe sibling decision (Wave 2a)
- [OPP-0006: Trust-Tier Enforcement](../opportunities/OPP-0006-trust-tier-enforcement.md) and [PRD-0006](../requirements/PRD-0006-trust-tier-enforcement.md) — already-drafted artifact for Wave 5.1
- [OPP-0020: Evaluation & Safety Tooling in Toolchain](../opportunities/OPP-0020-evaluation-tooling-in-harness-toolchain.md) — anchor for OPP-0035 (Wave 5.4)
- [OPP-0033](../opportunities/OPP-0033-validate-skill-content.md) · [OPP-0034](../opportunities/OPP-0034-validate-sensitive-paths.md) · [OPP-0035](../opportunities/OPP-0035-security-static-analysis.md) · [OPP-0036](../opportunities/OPP-0036-validate-knowledge-redaction.md) — the four new OPPs filed alongside this ADR
- [Operating principle § 9 — Split Design from Implementation](../operating-principles.md) — the deferral pattern this ADR uses (second ADR-level application; first was ADR-0016)
