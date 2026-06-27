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

## 2026-06-27 — doc-watch — DRIFT FOUND + FIXED (governance-machinery wave #135–#148; GitBook front-door stale)

**Window:** 2026-06-22 → 2026-06-27 (since last watch). ~14 PRs (#135–#148). This
was a heavy development run, and — unlike every prior "ALL CLEAR" entry — the watch
found **real drift in the non-validator-enforced prose surfaces** and fixed it in
the same pass. Three parallel agents audited the GitBook docs (TOC completeness /
front-door freshness / render-hygiene + cadence); findings were verified against
disk before acting (two agents disagreed on the SUMMARY validator section; the
disk was authoritative).

**What landed in the window:** OPP-0049 §12 harvest (playbook); OPP-0048 →
`validate-publication-boundary.sh` (#139); OPP-0050 → `validate-module-stability.sh`
with a 57-module backfill (#145); canonical-position implemented (#142);
agent-observability implemented (#147); PRD-0028 ai-foundry-target designed (#148).
Validators 18 → 20;
two new modules; operating-principle § 10 gained a module-stability bullet.

**Drift found (validator-blind prose) — all fixed in this PR:**

- `SUMMARY.md` validator section read "**eighteen** validator scripts" and listed
  only **17** — missing `validate-lane-integrity`, `validate-publication-boundary`,
  `validate-module-stability`. (Not in the catalog-counts assertion table, so it
  drifted silently.) → corrected to twenty + the three added.
- `docs/roadmap.md` was **severely stale** (Updated 2026-05-25): it listed
  canonical-position (shipped #142) and trust-tier (shipped Wave 5.1) as "PRD
  Proposed; ready to pick up," and treated the entire post-v0.5.0 governance +
  deep-domain wave as "Planned." → status lines corrected, a **Shipped since v0.5.0**
  record added; release-version re-tagging explicitly flagged as a maintainer task.
- Two nav gaps in the TOC: the canonical `docs/operating-principles.md` (the
  platform's own §§ 1–12 doctrine) and `platform/workflow/work-package-worktree-runbook.md`
  were not reachable from `SUMMARY.md`. → both added.

**Verified clean (no action):** `validate-doc-references.sh` → 0 (no GitBook-fragile
links); `docs/README.md` indexes current through PRD-0028 / OPP-0050 / ADR-0019;
`docs/architecture/diagrams.md` captions current; the three dated `QUALITY-AUDIT-*`
pages correctly excluded from the TOC (historical snapshots); catalog counts in
`how-to-read.md` correct.

**Live counts:** profiles 49 · modules-all 58 · agents 8 · validators 20 · skills 8 ·
compositions 15 · arch diagrams 16 · templates 94 · ADRs 19 · PRDs 28 · OPPs 50
(through OPP-0050).

**Escalation assessment:** This window **crossed the re-audit threshold** (2 new
modules + 2 new validators + new doctrine surface) — hence the 3-agent audit was run.
The lesson for the cadence: validator-enforced surfaces (index rows, numeric counts)
stayed green throughout, but the *enumerated-prose* surfaces (the SUMMARY validator
list, the roadmap narrative) drifted because they sit in no assertion table — exactly
the class the periodic doc-watch exists to catch. Going forward, a doc-watch after a
≥ 2-validator wave should explicitly re-read the SUMMARY validator list and the
roadmap against reality.

---

## 2026-06-22 — Weekly doc-watch (Monday) — ALL CLEAR (new work-package module + PRD-0025 + 4 OPPs, zero drift)

**Window:** 2026-06-15 14:28 → 2026-06-22 (since last watch commit `22daf24`).
Branch `feat/op-principle-12-deep-governance`. Working tree dirty (one
untracked file `docs/superpowers/specs/2026-06-09-digital-twin-seed-brief.md`;
analysis was read-only). 11 doc-relevant commits in window (#125–#134).

**What landed:**

- New module **`management/work-package`** (#132 / PRD-0025) — parallel
  multi-agent work-package lane contract. Ships `module.yaml` + sibling
  `README.md` + `platform/templates/work-package/lane.md` template subdir +
  validator fixtures + `work-package-worktree-runbook.md`.
- **PRD-0013** session-cycle orchestration implemented (#133) — adds
  `session-shape.md` workflow + review-trigger taxonomy.
- **Operating-principle § 12** (#134) — deep-governance-vertical authoring
  pattern; OPP-0049 harvest filed.
- New design-only OPPs: **0046, 0047, 0048, 0049**. GitBook front-door /
  SUMMARY TOC resynced (#129); OPP/PRD index↔source status drift reconciled
  twice (#127, #131).

**Live counts:** profiles 47 · agents 8 · validators 18 · skills 8 ·
compositions 15 · arch diagrams 16 · templates 95 · ADRs 19 · PRDs 25 · OPPs 48.

**Drift checks — all green:**

- `validate-catalog-counts.sh` → ✓ 26/26 assertions match.
- `validate-doc-references.sh` → ✓ all link targets resolve.
- `validate-list-completeness.sh` → ✓ 249/249 assertions match.
- Index completeness: new entities (OPP-0046–0049, PRD-0025, work-package
  module, work-package template subdir) all indexed in `docs/README.md`,
  `SUMMARY.md`, and `platform/templates/README.md`. Module has sibling README.
- `markdownlint-cli2` → ✓ 0 errors across 404 files.

**Escalation assessment:** Structural growth was real (1 new module, 1 new
implemented PRD lane, op-principle §12, 4 new OPPs) but does NOT cross the
re-audit threshold: only 1 new module (<3), no new architecture family, 1
genuinely-new PRD this window, and zero drift in zero places. The Wave 1
list-completeness validator continues to catch index drift at CI time — every
new entity this week landed with its canonical index row already present. No
full multi-agent re-audit recommended.

---

## 2026-06-15 — Weekly doc-watch — ALL CLEAR (full deep-domain expansion + consumer tooling, zero drift)

**Window:** 2026-06-09 → 2026-06-15. Branch `main`. Doc-relevant merges: the
digital-twin overlay (#111–#113), privacy + sensitive-paths fixes (#114–#116),
the greenfield clone-ordering fix (#118), the agent-catalog interoperability pass
(`95a9a09`), the geospatial / GIS vertical (#119–#120), and the consumer upgrade
runbook + `upgrade.sh` (#123). Working tree carries one untracked, intentionally
parked spec (`docs/superpowers/specs/2026-06-09-digital-twin-seed-brief.md` —
markdownlint-ignored, do-not-publish).

**Large structural change this window** (well past the re-audit threshold):

- **Second cross-cutting overlay shipped:** `management/digital-twin`
  (OPP-0044 / ADR-0019 / PRD-0023) — module + 10 templates + 2 Half-enforced WARN
  validators (`validate-twin-profile`, `validate-scenario-manifest`) + the
  `harness-digital-twin` skill + diagram #14.
- **Fourth deep-domain vertical shipped:** `domains/geospatial-*`
  (OPP-0045 / PRD-0024) — `geospatial-foundation` + `geospatial-exchange` +
  `geospatial-bim-georeference` (the catalog's first cross-family dependency) +
  4 templates + diagram #15 + the first 4-way `geospatial-bim-twin` composition.
- **Third deep-domain vertical (design-only):** cybersec OSINT wedge
  (OPP-0043 / PRD-0022, #110).
- **Consumer tooling:** the consolidated `consumer-upgrade-runbook.md` +
  `platform/bootstrap/upgrade.sh` (#123).
- **Net catalog:** 46 profile modules / 55 total / 17 validators / 8 skills /
  88 templates / 15 diagrams / 14 compositions / 20 workflows.

**Drift checks — all green despite the growth:**

- `validate-catalog-counts.sh`: ✓ 26/26 assertions.
- `validate-doc-references.sh`: ✓ all link targets resolve.
- `validate-list-completeness.sh`: ✓ 236/236 (every ADR / PRD / OPP / module /
  template-subdir / composition index complete — no missing rows).
- `validate-companions.sh` / `validate-knowledge-redaction.sh` (PR-diff mode):
  ✓ on every merge this window.
- markdownlint-cli2 (`**/*.md`): ✓ 0 errors.
- Narrative counts verified live: `how-to-read.md:10` "46 modules, 88 templates,
  17 validators, 8 skills, 20 workflows" — all match; a stale-integer scan across
  README / HARNESS / SUMMARY / diagrams found none.
- All new modules carry a sibling `README.md` citing their OPP / PRD origin.

**Non-validator coherence checks (this window's specific risk surfaces):**

- **Upgrade-doc cluster (new this week).** The upgrade sequence now spans four
  workflow docs. Verified **bidirectional** linkage: the three sources
  (`submodule-integration`, `release-and-versioning`, `maintenance-operations`)
  all point to the new `consumer-upgrade-runbook.md`, and the runbook links back
  to all three. No contradiction — tag-pinning is the recommended production path
  in the runbook + release-and-versioning, with `--remote` branch-tracking
  correctly scoped to experimental adoption; the runbook's pinning table
  disambiguates. **Coherent.**
- **Geospatial family narrative.** Three module READMEs present, each citing
  OPP-0045 / PRD-0024; diagram #15 prose places the family correctly (healthcare
  #12 → AEC #13 → geospatial, fourth). Spot-checked **clean**.

**Verdict: All clear** on drift — the list-completeness + catalog-counts gates
again held the line through a very large window (a full cross-cutting overlay, a
full domain vertical, and a tooling addition) with not one hand-maintained index
falling out of sync.

**Standing recommendation (carried from 2026-06-08):** accumulated structural
growth — now four deep-domain verticals + two cross-cutting overlays — continues
to outpace the last full content audit (2026-05-25/27). A full multi-agent
re-audit remains advisable, not to fix drift (there is none) but to give the
newer surfaces (digital-twin, geospatial, the consumer-upgrade cluster) a first
content + IA review at audit depth.

**Forward-looking:** open issues #121 (machine-readable WP lane contracts)
and #122 (inter-agent variance in parallel execution) propose a new governance
surface for parallel multi-agent work-packages; if accepted they add
docs/validators that future doc-watch windows should track.

## 2026-06-08 — Weekly doc-watch (Monday) — ALL CLEAR (large structural growth, zero drift)

**Window:** 2026-05-28 → 2026-06-08. Branch `main`, 23 commits, working tree
has 2 untracked AEC superpowers files (`docs/superpowers/plans/` +
`specs/`, both markdownlint-ignored). Doc-relevant commits: all 23.

**Large structural change this week** (meets re-audit threshold on all three
counts — 3+ modules, new domain family, multiple new PRDs):

- **+6 profile modules** (42 total): `domains/aec-iso19650-im`,
  `domains/aec-iso19650-5-security`, `domains/aec-openbim-exchange`,
  `domains/healthcare-fhir`, `domains/healthcare-smart-on-fhir`,
  `management/privacy-by-design`.
- **2 new deep-domain verticals** — healthcare wedge (PRD-0017) and AEC /
  ISO 19650 + openBIM wedge (PRD-0019).
- **+4 PRDs** (19 total): PRD-0016 SAST module, PRD-0017 healthcare,
  PRD-0018 privacy-by-design, PRD-0019 AEC.
- **+4 validators** since the 2026-05-25 audit (15 total):
  `validate-sast-coverage.sh`, `validate-skill-content.sh`,
  `validate-knowledge-redaction.sh`, `validate-sensitive-paths.sh`.
- New OPPs (OPP-0035/0037/0038/0039 + OPP-0013 promotion; 38 total),
  ADR-0018, and template families (AEC ×5, healthcare ×3, privacy ×3,
  security ×1).

**Drift checks — all green despite the growth:**

- `validate-catalog-counts.sh`: ✓ 24/24 assertions.
- `validate-doc-references.sh`: ✓ all link targets resolve.
- `validate-list-completeness.sh`: ✓ 200/200 (ADR/PRD/OPP/composition/
  template-subdir/module indexes all complete — no missing rows).
- markdownlint-cli2 (`**/*.md`, repo `.markdownlint-cli2.jsonc`): ✓ 0 errors
  across 361 linted files.
- Narrative counts verified live: `how-to-read.md:10` "42 modules, 74
  templates, 15 validators, 7 skills, 18 workflows" — all match;
  `diagrams.md:359` "15 validators" — matches. No stale integers found in
  README/HARNESS/SUMMARY/platform-README/glossary.
- All 6 new modules have sibling `README.md`.

**No drift in any location.** The Wave 1 list-completeness validator did
exactly its job: the catalog grew by 6 modules + 2 domain families and not
one hand-maintained index fell out of sync — the historical catalog-drift
failure mode did not recur.

**Re-verify of 2026-05-25 Refresh #1 open High findings — newly resolved:**

- H-a (trust-model.md was a 26-line stub) → now 215 lines. **Resolved.**
- H-b (`PLATFORM=path/to` placeholder in bootstrap-quickstart) → placeholder
  gone. **Resolved.**
- H-c / H-d / M-f / M-h / M-j (index + count drift) → structurally enforced
  by list-completeness (200✓) + catalog-counts (24✓). **Resolved.**
- M-b (module-README inconsistency) → Wave 4.2 standardization (#87). **Resolved.**
- L-a (governance banners) → Wave 4.5 added adr/ + requirements/; opportunities
  still deferred. **Partial.**

**Verdict: All clear** on drift. Because the window brought large structural
change (6 modules, 2 new domain families, 4 PRDs) since the last full audit
(2026-05-25, two weeks old), a **full multi-agent re-audit is recommended** —
not to fix drift (there is none) but to give the two new deep-domain verticals
and the four new safety/privacy modules a first-pass content + IA review at
audit depth.

---

## 2026-05-28 — Wave 4.5 governance-doc banners (partial — opportunities deferred)

**Partially closes Refresh #1 L-a.** Two of three governance-record
directories (`docs/adr/`, `docs/requirements/`) gained newly authored
`README.md` files opening with a contributor-surface banner directing
first-time users to the repository README. Banner shape matches the
existing `> **New here?**` convention in `HARNESS.md` / `docs/README.md`.

`docs/opportunities/README.md` banner was deferred — the
`management/opportunity-capture` companion-rule treats any edit to that
file as a structural-policy change requiring a paired ADR. A
visitor-orientation banner is neither structural nor candidates.md-eligible,
which is an over-broad-rule signal the maintainer needs to resolve
(banner-carve-out ADR, regex tightening, or both). Captured as a
rule-design-tension follow-up in the change-log.

**Roadmap §7 progress:** 4 fully closed (4.3 / 4.4 / 4.8 / 4.10) + 4.5
partial. Remaining: opp-side 4.5 follow-up, plus 4.1 / 4.2 / 4.6 (larger
items) and 4.7 / 4.9 / 4.11 (need Refresh #1 source text).

---

## 2026-05-28 — Wave 4 content polish batch 1 (4.4 + 4.8 + 4.10)

**First active-mode work after Wave 5 sprint closure.** Three roadmap §7 sub-PRs
bundled as a single companion-rule cycle.

**What landed:**

- 4.4 `bootstrap-quickstart` *Bootstrap Complete* criteria — extended from 4
  validators to all 14, matching the `AGENTS.md` Build-and-Test run-order.
- 4.8 Agent-pack Status lines — four stable packs (`base`, `claude-code`,
  `generic-llm`, `openclaw`) now carry explicit `Status: stable as of v0.5.0`
  declarations parallel to the four R&D packs.
- 4.10 `link-skills.sh --help` no longer prints the SPDX header; pattern-based
  filter (not line-position) so future SPDX changes don't reintroduce the issue.

**Roadmap §7 progress:** 3 of 11 sub-PRs closed (4.3 was complete pre-sprint;
this PR closes 4.4 + 4.8 + 4.10).

**Deferred (need Refresh #1 finding-text or are larger):** 4.1 / 4.2 / 4.5 / 4.6
/ 4.7 / 4.9 / 4.11. Refresh #1 source doc not in tree — items 4.7 / 4.9 / 4.11
will need either source recovery or independent reasoning before the next batch.

---

## 2026-05-28 — Wave 5.4 implementation shipped (`management/security-static-analysis`)

**Wave 5.4 — `management/security-static-analysis` module +
`validate-sast-coverage.sh`.** Shipped the 14th validator and the
first new module of the Wave 5 sprint. Module is opt-in: the harness
itself does not activate it; the validator's no-op-pass path is what
the harness's CI exercises. When a consumer activates the module,
the validator asserts `docs/security/sast-coverage.md` is well-formed
(recommended-set tool / scanPaths / severityThreshold).

**Wave 5 sprint complete.** Six Asserted-only safety items closed
across Waves 5.1–5.5: claims 10/11 (Wave 5.1), 12 (Wave 5.3),
§8+§9 (Wave 5.5), §3 V1/V2/V4-partial/V6 (Wave 5.2), §11
half-enforced (Wave 5.4). Remaining items: §3 V3 + V5 (genuine
residual gaps; out-of-genre); claims 13/15/18 (by-design
honor-code).

**First Half-enforced classification shipped end-to-end.** PRD-0016
§10 C-SAST-S1 was the first explicit Half-enforced PRD claim
(PR #83); the Wave 5.4 implementation makes good on the
classification by shipping a contract validator that the harness
controls and a tool-runner contract that the consumer CI controls.
Neither half alone is sufficient.

**Fourth consecutive predict-clean Wave.** A new variant of
predict-clean surfaced: the harness's CI exercises the validator's
opt-in-gating no-op-pass path, not a dogfood scan. The validator's
substantive work only fires when a consumer manifest activates the
module. Distinct mechanism shape from Waves 5.3 / 5.5 / 5.2 — added
to `feedback-validator-absorption-mechanisms` as a fourth variant.

**Catalog count bumps:** validators 13 → 14 (8 documented sites);
profile modules 35 → 36; templates 62 → 63 (new `templates/security/`
subdir); `harness-onboarding/SKILL.md` Management catalog and
`discovery-to-composition.md` Step 6 rubric both gained rows.

**Roadmap delta:** Wave 5 closes. The 2026-05-27 audit roadmap's
remaining open lanes are Wave 3 (visual program — 8 sub-PRs) and
Wave 4 (content polish — 11 sub-PRs). Both are parallel-safe; both
benefit from the patterns established by Waves 1 + 2 + 5.

---

## 2026-05-28 — Wave 5.4 PRD-0016 shipped (design-only)

**Wave 5.4 — PRD-0016 Security Static Analysis Module (design pass).**
Filed PRD-0016 as the design pass for OPP-0035 — the
`management/security-static-analysis` opt-in overlay. Design-only PR
per operating principle §9; the implementing PR (Wave 5.4 impl) ships
the module scaffolding + required-artifact template +
`validate-sast-coverage.sh` + standard catalog propagation.

**Second PRD authored under §10.** §10 Claim Classification block
included per the PR #81 precedent — and PRD-0016 is the first PRD to
ship an explicitly **Half-enforced** claim categorization (C-SAST-S1:
opt-in module + consumer-CI cooperation for end-to-end enforcement).
The §10 vocabulary lets the PRD declare partial coverage honestly
rather than overclaim or silently elide it.

**OPP-0035 status flipped `proposed` → `exploring`** in the same
commit per OPP-0037 / §10 precedent. The OPP gains an explicit
"Promotion candidate" line citing PRD-0016.

**Predict-clean absorption mechanism stated** at design pass — fourth
predict-clean Wave in a row (Wave 5.3 strict BLOCK, Wave 5.5 WARN,
Wave 5.2 strict BLOCK, Wave 5.4 stated). The harness's own CI run is
the validator's module-inactive path (no active
`management/security-static-analysis` overlay equals no-op pass).

**Test-seam pattern adopted at design time** per
`feedback-validator-test-seam-pattern` (Should-Have FR-S03). First
PRD to adopt the test-seam pattern proactively at design pass time
rather than discovering it during implementation. Confirms the
memory's "watch the next PRD for proactive adoption" hypothesis.

**Roadmap delta:** Wave 5.4 design pass closes; the implementing PR
is next. Sixth Asserted-only safety item (sweep §11) gains a Half-
enforced closure path after Wave 5.4 impl ships. Remaining genuine
residual gaps after the sprint: §3 V3 (supply-chain) + §3 V5
(consumer-runtime tampering). Three other remaining items (claim 13,
15, 18) are out-of-genre or by-design honor-code.

---

## 2026-05-28 — Wave 5.2 shipped (validate-skill-content.sh)

**Wave 5.2 — PRD-0015 Skill Content Safety Validator.** Shipped the
13th validator (`validate-skill-content.sh`) per PRD-0015 spec.
Closes safety-security-sweep §3 red-team vectors V1/V2/V4-partial/V6.

**BLOCK posture from PR 1.** Predict-clean absorption mechanism per
PRD-0015 FR-003. **51 sources scanned, zero hits on first run** —
the prediction held verbatim. Third predict-clean validator in a row
(Wave 5.3, Wave 5.5 via WARN posture, Wave 5.2 via strict BLOCK).
Convergence trajectory: Wave 1 → 6 fix-ups, Wave 5.1 → 4, Wave 5.3
→ 0, Wave 5.5 → 0, Wave 5.2 impl → 0.

**Implementation Reconciliation: --scan-file mode addition.** The
implementation added a small `--scan-file <path>` test-seam mode
that wasn't in PRD-0015's Must-Have FRs. Per the new shared-
observations entry `[[test-seams-are-not-section-10-deviations]]`,
test seams are additive ergonomic features, not contract changes —
the §10 Claim Classification block in PRD-0015 still holds verbatim,
and the seven Must-Have FRs all hold. Future structural-enforcer
PRDs should consider adding `--scan-file` as a Must-Have FR up
front; the pattern is now thrice-evidenced.

**Drift checks now in force:** any new module added to the active
catalog must declare authored-prose fields that pass the v1 denylist
scan, or add a justified `.skill-content-ignore` entry. The next
Wave 5 candidate is **Wave 5.4** (`management/security-static-analysis`
module per OPP-0035 / ADR-0017) — largest remaining safety item;
likely 1–2 weeks and needs PRD pass.

**Wave 5 status:** 5.1 ✅ (PR #76), 5.3 ✅ (PR #77), 5.5 ✅ (PR #78),
5.2 ✅ (PR #82 — this PR's implementation), 5.4 pending. Five of
seven Asserted-only safety items now closed (claims 10/11 via 5.1;
claim 12 via 5.3; §8+§9 via 5.5; V1/V2/V4-partial/V6 via 5.2).

---

## 2026-05-28 — Wave 5.2 PRD filed (PRD-0015, design-only)

**PRD-0015 — Skill Content Safety Validator.** Filed to specify the
v1 design contract for `validate-skill-content.sh` (the Wave 5.2
validator under ADR-0017). Promotes OPP-0033 from `proposed` →
`exploring`.

**First PRD authored under §10.** PRD-0015's body includes a dedicated
`## §10 Claim Classification` block naming each load-bearing claim
being converted (C-V1, C-V2, C-V4, C-V6) plus claims explicitly NOT
converted plus Half-enforced fallback. This is the design-time
analog of §10's prior audit-time applications — first instance.

**Drift checks now in force:** the implementing PR for PRD-0015
must (a) ship the validator + adversarial-corpus fixtures + exemption
file format per FRs, (b) bump catalog count 12 → 13 at the 7
documented sites, (c) wire into all standard surfaces (CI, AGENTS.md
run-order, harness-governance SKILL.md, validators/README.md, root
README), (d) confirm the predict-clean absorption mechanism holds
(harness's own authored prose passes the v1 denylist scan from PR 1),
(e) include an "Implementation Reconciliation" section per the
Wave 5.1 precedent for any §10 classification deviations.

**Follow-up named:** update `platform/templates/product/prd.md` to
add an optional `## §10 Claim Classification` section so future
structural-enforcer PRDs inherit the discipline.

---

## 2026-05-28 — §10 shipped (operating-principles promotion)

**§10 "Classify Claims Before Enforcing Them" added to
`docs/operating-principles.md`.** Implements OPP-0037 — promotes the
[[claim-vs-enforcement-classification]] meta-pattern from
shared-observations to durable doctrine. Four cited instances
mirror §9's "First applied" structure.

**OPP-0037 status flipped `proposed` → `exploring` in same commit
per OPP's Risk 6 bias.** Disposition + Promotion populated.

**Drift checks now in force:** ADRs, PRDs, OPPs, and new
operating-principle entries authored after this point should
explicitly classify their load-bearing claims (Enforced /
Half-enforced / Asserted-only) during design. Wave 5.2 and 5.4 PRDs
should cite §10 explicitly and use its vocabulary. Refresh-3 (or
the next periodic doctrine audit) should run the §10 classification
across the framework's current claim surface and refresh the
Asserted-only follow-up queue.

**No new validator.** §10 is honor-code doctrine; the classification
is a reading-and-cataloguing discipline that fires during audit /
PRD-drafting work, not at CI time. No `validate-classification.sh`
shipped or planned — mechanizing the classification would surface
the §9 bundling anti-pattern the framework already warns against.

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
