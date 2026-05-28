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
