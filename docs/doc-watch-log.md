<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Documentation Watch Log

Tracks the cadence of audit-roadmap waves shipped against the 2026-05-27
documentation audit (`documentation-audit-2026-05-27/`). Each entry records
which wave closed, what it shipped, and what remains.

The weekly doc-watch (Monday 7am PT, when scheduled) reads this file to know
where the project is in the roadmap and which drift checks should now be in
force.

---

## 2026-05-28 — OPP-0037 filed (design-only)

**OPP-0037 — Classify-Before-Enforcing as Operating Principle.** Filed
to promote the [[claim-vs-enforcement-classification]] meta-pattern to
a new §10 operating principle. Four documented instances exceed the §9
three-instance bar by one.

**Design-only per §9.** The OPP captures the design contract; the
implementation (the §10 edit in `docs/operating-principles.md`) ships
in a follow-up PR. First exercise of §9 against a doctrine
*promotion*, not a new doctrine surface.

**Drift checks now in force:** the §10 promotion implementation PR
should land before Wave 5.2 or 5.4 begin, so those PRDs can cite §10
explicitly and use its classify-before-enforcing vocabulary. If
Wave 5.2/5.4 ship before §10 lands, expect re-articulation drift in
their distillation observations (the meta-pattern will be cited under
its observation slug instead of its principle number).

---

## 2026-05-28 — Wave 5.5 closed

**Wave 5.5 — OPP-0036 Knowledge-Redaction + CODEOWNERS.** Shipped the
12th validator (`validate-knowledge-redaction.sh`) plus CODEOWNERS
entries for `/docs/knowledge/` and `/docs/operating-principles.md`.
Closes safety-security-sweep §8 cross-pollination + §9 upstream-
propagation pathways (the four reverse-direction propagation paths
the cycle-end-distillation rule creates by design).

**WARN posture** is the v1 default — surfaces consumer-name hits in
new diff lines without failing CI. Reviewers eyeball in CI logs.
`--block` flag escalates to hard fail (v2 posture). The design
intentionally defers the corpus-stabilization decision: once
"legitimate citations" are well-understood, flip to default-block.

**Two consecutive waves shipped without a fixing commit.** Wave 5.3
established the no-fixing-commit precedent through OPP-0034 risk
prediction; Wave 5.5 extends it through WARN-posture design that
sidesteps existing-state break. Different mechanism, same outcome.
The convergence-signal trajectory now reads 6 → 4 → 0 → 0 fix-up
items per wave.

**Mid-sprint pattern crystallizing.** The `feedback-opp-to-
implementation-no-prd` workflow established in Wave 5.3 and repeated
in Wave 5.5 is now a documented project pattern: half-day-scoped OPPs
ship directly under the OPP design contract; PRD pass is skipped with
explicit rationale in the change-log.

**4 of 7 Asserted-only items now closed.** Wave 5.1 closed claims
10+11; Wave 5.3 closed claim 12; Wave 5.5 closes the §8+§9
cross-pollination cluster (adjacent to claim 13 but distinct). Three
remain in the original cluster: claim 13 (kernel-doctrine override),
15 (second-human Harness Ready), 16 (design-vs-implementation
split — has its own §9 codification path), 18 (module text in stripped
contexts — by-design honor-code).

**Next wave per ADR-0017 Wave 5 sequencing (5.1 → 5.3 → 5.5 → 5.2 →
5.4):** Wave 5.2 — `validate-skill-content.sh` (OPP-0033). Needs
adversarial-corpus test fixtures per OPP-0033 description. Larger
scope than 5.3/5.5 — likely 1–2 day implementation requiring PRD pass.
After 5.2: Wave 5.4 (SAST module, largest remaining Wave 5 item, 1–2
weeks).

Alternatively: pivot to Wave 3 / Wave 4 / Wave 6.1 for parallel-safe
work.

---

## 2026-05-28 — Wave 5.3 closed

**Wave 5.3 — OPP-0034 Sensitive-Paths Coverage.** Shipped the 11th
validator (`validate-sensitive-paths.sh`). Closes safety-security-sweep
§2 claim 12 (Asserted-only → Enforced). The framework's
`sensitivePaths` field — previously documentary metadata read by zero
validators — is now structurally enforced: every declared pattern must
be overlapped by at least one companion-rule `triggerPaths` regex on
some active module.

**No fixing commit needed** (first Wave 5 implementation to ship without
one). OPP-0034 Risk 3 predicted the harness's own state would pass on
first run; the prediction held. All 11 active sensitive-path patterns
are covered. This is its own signal that the framework's structural
enforcement is converging — the gap-naming work of Wave 1 + 2a + 2b +
5.1 created the conditions for Wave 5.3 to be a pure
asserted-to-enforced conversion without remediation work.

Drive-by alignment: Wave 5.1's `validate-trust-tier.sh` was missing
from the root README validators table. Added in this PR alongside the
new `validate-sensitive-paths.sh` row.

**Two of seven Asserted-only items now closed** — claims 10 + 11
(Wave 5.1) + claim 12 (Wave 5.3). Five remain: 13 (kernel-doctrine
override), 15 (second-human Harness Ready), 16 (design-vs-implementation
split), 18 (module text in stripped contexts; by-design honor-code).
Of those, claim 16 has its own §9 codification path (the Wave 2a + 2b +
5.1 distillation observations already document promotion candidacy).

**Next wave per ADR-0017 Wave 5 sequencing (5.1 → 5.3 → 5.5 → 5.2 →
5.4):** Wave 5.5 — `validate-knowledge-redaction.sh` + CODEOWNERS on
`docs/knowledge/` (OPP-0036). Small scope; pairs with the §8/§9 cross-
pollination + reverse-leakage findings. Then 5.2 (content-safety
scanner; needs adversarial corpus) and 5.4 (SAST module; 1–2 weeks,
largest remaining Wave 5 item).

Alternatively: pivot to Wave 3 / Wave 4 / Wave 6.1 for parallel-safe
work.

---

## 2026-05-27 — Wave 5.1 closed

**Wave 5.1 — PRD-0006 Trust-Tier Enforcement.** Implemented per
PRD-0006 and ADR-0017. Closes safety-security-sweep §2 Asserted-only claims 10–11
(no self-elevation; tier-ceiling fixed) — the framework's centerpiece
safety contract now converts honor-code to PR-boundary code-check.

**What shipped:** 10th validator (`validate-trust-tier.sh`); additive
`tier` + `maxTier` schema fields on `module.yaml`; explicit tier
declarations on all 9 active modules (dogfood); CI wiring (harness +
consumer templates); `harness-governance` SKILL.md updates;
trust-model.md "Partial Machine Enforcement (v1)" section rewrite;
threat-model A5 mitigation update.

**Implementation reconciliation:** PRD-0006 FR-003 (strict
"declared >= inferred") conflicted with FR-005 ("kernel/base — Tier 0")
because kernel's `sensitivePaths` infer tier 5 per the FR-002 table.
Maintainer direction (in-session AskUserQuestion): adopt strict
interpretation, reinterpret FR-005's "Tier 0" as describing the
doctrine surface while declared tier reflects the governance surface.
Cascading deviations from FR-005: kernel declared 5 + rationale;
agents bumped maxTier 3/4 → 5; criticality check relaxed for
`maturity: platform` projects. All captured as a substantive
distillation observation building on the Wave 2a + 2b observation
chain (third [[claim-vs-enforcement-classification]] instance —
empirical, not transcribed — fitting the §9 three-instance
generalizability bar).

**Next wave per roadmap §8 (Wave 5 sequencing per ADR-0017):**
Wave 5.3 — `validate-sensitive-paths.sh` (OPP-0034, half-day work,
smallest of the remaining Wave 5 items). Then 5.5 (knowledge-redaction),
5.2 (content-safety), 5.4 (SAST module).

Alternatively: Wave 3 / Wave 4 / Wave 6.1 are all parallel-safe with
Wave 5 progression.

---

## 2026-05-27 — Wave 2b closed

**Wave 2b — ADR-0017 (Safety Hardening Roadmap) + 4 new OPPs.** Authored
the safety-roadmap decision record adopting the five-priority order from
`safety-security-sweep.md` §16. Filed 4 new OPPs (0033 content-safety,
0034 sensitive-paths overlap, 0035 SAST module, 0036 knowledge-redaction)
as the §16 "OPP queue." Sequenced Wave 5 implementation 5.1 → 5.3 → 5.5
→ 5.2 → 5.4 for amortized risk per ADR-0017's architectural commitments.

Second ADR-level application of operating principle §9 (Split Design
from Implementation), following ADR-0016. The pattern is now codified
across two ADRs in one sprint: the multi-PR ADR records the design
contract (priority order + OPP queue), individual Wave-5/6 PRs ship the
enforcement.

Catalog propagation per Wave 1 validator: ADR-0017 row + 4 OPP rows in
`docs/README.md` (enforced); 4 entries in `candidates.md` under new
"Safety hardening" cluster (validator-enforced). Manual SUMMARY.md
drift close (continuing the Wave 2a interim pattern until Wave 6's
validator extension): ADR-0017 + 4 OPPs added to SUMMARY.md ADR + OPP
sections.

**Together Wave 2a + Wave 2b unblock the multi-PR Waves 5 and 6.**
Both ADRs are now in place as companion-rule shelter. Wave 5 (safety
hardening, 2–3 weeks, cited under ADR-0017) and Wave 6 (IA migration,
3–4 weeks, cited under ADR-0016) are parallel-safe and can proceed
independently.

**Next wave per roadmap §6:** Wave 3 (visual program) or Wave 4 (content
polish) — both parallel-safe with Wave 0 (which still has CI-config
items gated on direct human action). Both are smaller, multi-sub-PR
content tracks. Alternatively, begin Wave 5.1 (PRD-0006 trust-tier
enforcement, already drafted) as the first Wave 5 implementation PR.

---

## 2026-05-27 — Wave 2a closed

**Wave 2a — ADR-0016 (Documentation IA Phase 3–4 Target Structure).** Authored
the structural-IA decision record: adopt the 9-section target tree from
`ia-restructure-proposal.md`, supersede Phases 3–4 of ADR-0013, give Wave 6
the multi-PR companion-rule shelter ADR-0013 gave Phases 0–2. Uses operating
principle § 9 (Split Design from Implementation) — design at v1, five
implementation items explicitly deferred to Wave 6.

Drift handled in passing: PR #73 surfaced that `SUMMARY.md` is a canonical
list-completeness surface for ADRs (and the other entity types), but the
Wave 1 validator only checks `SUMMARY.md` for modules. ADR-0015 was missing.
Per the maintainer decision documented in `feedback_maintainer_parallel_prs.md`
memory, the validator extension itself is deferred to Wave 6 (which reshapes
`SUMMARY.md`'s structure wholesale); ADR-0015 + ADR-0016 manually added to
`SUMMARY.md` ADR section in this PR. Wave 1 validator continues to enforce
the `docs/README.md` ADR row automatically (caught + satisfied).

**Next wave per roadmap §5:** Wave 2b — ADR-0017 (Safety Hardening Roadmap).
Parallel-safe with this Wave 2a; the two ADRs do not block each other.
Together they unlock the multi-PR Waves 5 (safety hardening, cited under
ADR-0017) and 6 (IA migration, cited under ADR-0016).

---

## 2026-05-27 — Wave 1 closed

**Wave 1 — The unblock.** Shipped `validate-list-completeness.sh` (six checks
covering ADRs, PRDs, OPPs, compositions, template subdirectories, and profile
modules). Wired into CI validators job; bumped validator count 8→9 across all
asserted documentation sites; added `VALIDATOR_SCRIPTS` --help coverage for the
new script. Land-green fixing commit repaired three pre-existing index gaps
the validator surfaced on first run:

- ADR-0015 row added to `docs/README.md` (closes refresh-2 N1)
- 2 composition rows (`agentic-ui-saas.yaml`, `mcp-server-typescript.yaml`)
  added to `platform/compositions/README.md` (closes refresh-2 M-h)
- 3 template-subdir sections (`agentic-interface`, `ci`, `mcp`) added to
  `platform/templates/README.md` directory map (drift class caught for the
  first time — these subdirectories were never indexed; M-f's targeted scan
  did not enumerate by directory)

Closes refresh-2 finding M-j. The cross-cutting structural-enforcement gap
is now closed: future ADRs/PRDs/OPPs/compositions/templates/modules cannot
land on disk without their canonical index row, because CI will block.

**Next wave per roadmap §5:** Wave 2a (ADR-0016 — Documentation IA Phase 3-4
Target Structure) and Wave 2b (ADR-0017 — Safety Hardening Roadmap),
parallel-safe. Wave 1 is the prerequisite that gates Waves 5 and 6 (which
both cite the Wave 2 ADRs).
