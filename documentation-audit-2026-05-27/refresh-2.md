# auto-harness — Documentation Audit, Refresh #2

**Prepared:** 2026-05-27
**Repo state:** `main` @ `1e1791f`, post-v0.5.2 (21 commits since refresh #1)
**Companion deliverables:** `ia-restructure-proposal.md`, `safety-security-sweep.md` (same folder)
**Method:** seven-agent verification pass + fact-check against the repo
**Status:** Audit and plan only — no repository files were modified

---

## 1. Executive summary

Two days. Twenty-one commits. Major chunks of the refresh #1 roadmap shipped:

- **Phase 0.5 hotfix bundle** (PR #60) closed the urgent CI-blocker (U1, MD033) and the catalog-drift items (H-c PRD table, H-d validator-count drift, M-f templates README).
- **Phase 2 of ADR-0013** (PR #68) closed the centerpiece concept-clarity findings — `trust-model.md` expanded **26 → 163 lines** with full rationale, `doctrine.md` / `audit-model.md` / `enforcement-model.md` / `lifecycle-controls.md` all earned the explanatory paragraphs they were missing, `module-types.md` now opens with a Core Concepts block, and the glossary closed the five named gaps (*install.sh*, *Lite Manifest*, *Bootstrap Complete*, *Harness Ready*, *Overlay*).
- A new module landed (`delivery/managed-fleet` via ADR-0015), 4 PRDs (0011 sunset distilled-learnings, 0012 doc-references consumer-aware, 0013 session-cycle orchestration, 0014 agent observability + OTel), 9 OPPs (notably the Tula second-pass cluster on agent safety: 0027 frontier-agent posture, 0029 observability, 0030 model routing, 0031 defense-in-depth), a new operating principle (§9 Split Design from Implementation, codifying the design-first / enforcement-deferred pattern already used in PRDs 0011/0013/0014), and a new "superpowers" workflow directory pattern (`docs/superpowers/{plans,specs}/`).

**Of refresh #1's 25 open findings: 11 Resolved, 1 Partially Resolved, 13 still Open.** Phases 0, 0.5, 1, and 2 of ADR-0013 are done. Phases 3 (visual program + validator hardening) and 4 (navigation polish + module-README standardization + examples refresh) are the bulk of the remaining documentation work.

But the audit cycle exists for the same reason it always has, and it earned its keep again: **three new drift findings emerged in 48 hours.** The most pointed one is the structural lesson refresh #1 already named — `docs/README.md`'s PRD table was fixed two days ago, and within the same week ADR-0015 landed without being added to that file's ADR table. The defect class is reproducing in sibling tables on a 48-hour cadence. The lesson is unchanged and now empirically stronger: **finding M-j (list-completeness drift is an unguarded class) is the single highest-leverage item left on the board.** Hand-corrected indexes will drift again. A list-completeness validator stops the cycle. Everything else in the plan is content; this one is structure.

Two other framings to surface alongside this refresh: the **IA restructure proposal** (companion doc) takes the welcome-the-newcomer thesis from a top-of-README problem to a top-of-GitBook problem — the rendered nav has grown to 15 top-level sections, ~290 visible leaves, and a max depth of 4, and it teaches the wrong order. The **safety & security sweep** (companion doc) covers the eight dimensions you named and surfaces the systemic gap: enforcement is structural-only (files, paths, regex). The two highest-impact unaddressed items in the safety sweep — adding **list-completeness validation** and shipping **PRD-0006 trust-tier enforcement** — are the same architectural move pointed at different symptoms.

---

## 2. What changed in the last 48 hours

| Artifact | What it is | Why it matters |
|---|---|---|
| **`platform/profiles/delivery/managed-fleet/`** | New 5th delivery posture for teams operating live host fleets (Ansible / Terraform / Puppet IaC). Sits between `internal-platform` and `production-saas`. | Fills a real catalog gap (live-host operations) surfaced by `fortify-ansible/ansible-internal` brownfield onboarding. Brings 3 new templates: fleet-inventory, change-control, config-rollback. |
| **ADR-0014** Sunset `distilled-learnings.md` | Removes the curated longitudinal destination; consolidates into `operating-principles.md`. Companion to PRD-0011. | *Reduces* surface area — one fewer destination, one fewer companion rule, one fewer required artifact. Net-positive for cross-pollination risk (see safety sweep §8). |
| **ADR-0015** Add `delivery/managed-fleet` posture | Companion to the new module. Explicitly carves an exception to operating-principle §3 ("catalog changes propagate"): HARNESS.md Active Modules is *not* updated because auto-harness itself doesn't activate `managed-fleet`. | Documents a deliberate gap in the propagation reflex (see new drift finding N2). |
| **PRD-0011** Sunset distilled-learnings | Curated knowledge moves to `operating-principles.md`. Rejects synthetic forcing triggers. | First applied use of §9 (design-first / enforcement-deferred pattern). |
| **PRD-0012** validate-doc-references consumer-aware | Validator now hard-fails for submodule consumers (was silent no-op). | Closes a real consumer-experience gap. **One of the few resolved "doc-claims-stronger-than-code" alignment findings** (see safety sweep §7). |
| **PRD-0013** Session-Cycle Orchestration taxonomy | Names the orchestration concepts; defers per-rule machinery. | Second §9 application — taxonomy shipped, companions deferred. |
| **PRD-0014** Agent Observability with OTel | Trace contract for agent-instrumented consumers. Cites Microsoft+Cisco Outshift's *agent-trace-concept*. | Third §9 application. Lays groundwork for safety telemetry (see safety sweep §9). |
| **9 new OPPs (0023, 0025–0032)** | doc-references consumer-aware (0023), consumer integration smoke test (0025), distilled-learnings disposition (0026), **frontier-agent posture (0027)**, AI Foundry target awareness (0028), **agent observability (0029)**, intelligent model routing (0030), **agent defense-in-depth (0031)**, session-cycle orchestration (0032). | The bolded three are explicit agent-safety scoping — the project has formally entered the safety-program territory the sweep addresses. |
| **Operating principle §9 — Split Design from Implementation** | Codifies that PRDs ship the contract at v1 and defer enforcement machinery to follow-up OPP/PRD pairs, with explicit "Implementation Deferral" sections. | Important governance evolution. The cost: enforcement debt accumulates structurally (see safety sweep §6 / V7 attack vector). |
| **`docs/superpowers/{plans,specs}/`** | New design-spec → implementation-plan companion pattern, dated `YYYY-MM-DD-slug`. | Markdownlint excluded (PR #71); placeholder-scan excluded. A new pattern the validator suite explicitly carves out — worth tracking. |

---

## 3. Refresh #1 finding status — full ledger

| ID | Restatement | Status | Evidence |
|---|---|---|---|
| **U1** `<strong>` markdownlint CI-blocker | **Resolved** | `README.md:86` — `<strong>` dropped (chose tag removal over allow-list extension). Markdownlint passes |
| **H-a** trust-model.md a 26-line spec | **Resolved** | 163 lines, full rationale, "Why six?", enforcement floor — Phase 2 of ADR-0013 |
| **H-b** `$PLATFORM` / `$PLATFORM_ROOT` | **Resolved** | `bootstrap-quickstart.md` uses `$PLATFORM_ROOT` exclusively (8x); `troubleshooting.md` 8x `$PLATFORM_ROOT`, zero bare `$PLATFORM` |
| **H-c** PRD table missing 0008-0010 | **Resolved** | `docs/README.md:69-82` lists PRDs 0001-0014 (14 rows match disk) |
| **H-d** "7 validators" stale references | **Resolved** in live catalog files | All 8 cited drift files cleaned. Remaining hits are historical (CHANGELOG, prior audits, shared-observations describing past) — appropriate to leave |
| **H-e** examples/README documents 1 of 5 | **Open** | Still only `node-web-saas-postgres` listed |
| **H-f** diagrams #4–#11 not embedded in concept docs | **Open** | Zero `mermaid` blocks across `platform/core/`, `platform/reference/`, `platform/workflow/`, `platform/agents/` |
| **M-a** "what is a module" missing | **Resolved** | `module-types.md:17` Core Concepts block (Module, Manifest, Composition, Kernel, Overlay) |
| **M-b** module-README inconsistency | **Partially Resolved** | New modules + managed-fleet use uniform "X Overlay: Name" heading; "Depends on / Conflicts with" callout still missing in most module READMEs |
| **M-c** glossary gaps | **Resolved** | All 5 gaps closed (install.sh, Lite Manifest, Bootstrap Complete, Harness Ready, Overlay) |
| **M-d** doctrine bare-bullet docs | **Resolved** | doctrine.md 104 lines, audit-model 109, enforcement-model 152, lifecycle-controls 160 — all earned rationale paragraphs in Phase 2 |
| **M-e** validators README contributor-pitched | **Open** | Structure unchanged |
| **M-f** templates README stale | **Resolved** | Lists all v0.5.2 templates + managed-fleet ops templates; new Skills + Deployment sections added |
| **M-g** README before/after duplicated, ~633 lines | **Open** | Still 632 lines; job-mixing unresolved |
| **M-h** compositions/README.md table 7 of 9 | **Open** | Still missing `agentic-ui-saas.yaml` and `mcp-server-typescript.yaml` |
| **M-i** bootstrap-quickstart runs 5 of 8 validators | **Open** | "Bootstrap Complete" criteria still 4 validators |
| **M-j** list-completeness unguarded | **Open — single highest-leverage** | `validate-catalog-counts.sh` (264 lines) and `validate-doc-references.sh` (195 lines, gained consumer-awareness via PRD-0012) — neither asserts list completeness |
| **L-a..L-h** governance banners, TOOLS stubs, agent-pack status, change-log cell, SUMMARY stub, link-skills SPDX, AGENTS step 2, fixture exec bit | **All Open** | None touched |

**Tally: 11 Resolved · 1 Partially Resolved · 13 Open.**

---

## 4. New drift findings (the 48-hour delta caught its own pattern)

### N1 — `docs/README.md` ADR table is missing ADR-0015

Severity: **High** · provenance: NEW

`docs/README.md:45-58` ADR table stops at ADR-0014 (the sunset-distilled-learnings record). ADR-0015 (managed-fleet posture) was created the same day (2026-05-25, commit `3ee3d15`) and the docs/README.md table was last touched on 2026-05-25 as well. **Within the same week that PR #56 fixed the PRD table to close H-c, the sibling ADR table reproduced the identical defect for ADR-0015.**

This is the structural lesson made empirical: hand-corrected lists drift again within a single sprint as soon as the maintainer's attention rotates. The fix is not to fix N1 by hand (that fixes the symptom for ~48 hours); the fix is M-j (a list-completeness validator that fails CI when an ADR file exists without a table row).

### N2 — HARNESS.md silence on `managed-fleet` (deliberate per ADR-0015)

Severity: **Low** · provenance: NEW (informational)

`HARNESS.md` Active Modules table does not list `delivery/managed-fleet`. ADR-0015 explicitly explains this: auto-harness itself doesn't activate `managed-fleet` (it's a delivery posture for a different kind of project), so the Active Modules table — which is auto-harness's own self-governance manifest — correctly does not include it. The ADR calls this "a deliberate deviation from the generic propagation reflex" cited in operating-principle §3.

This is fine. But it weakens §3's "always propagate" framing without an explicit rewording. Recommendation: in a future operating-principles edit, restate §3 as "propagate when the module is self-activated; otherwise label as catalog-only" — turning ADR-0015's carve-out into a rule rather than a one-off.

### N3 — OPP numbering gap at 0024 (no record explains the skip)

Severity: **Low** · provenance: NEW (informational)

Disk has OPPs 0001-0023 and 0025-0032 (31 records). `docs/README.md` OPP table correctly reflects what exists on disk. But no record explains why 0024 was skipped — was it reserved? Was it created and rejected pre-merge? Reads ambiguously to a contributor.

Recommendation: a one-line entry in `docs/opportunities/candidates.md` ("OPP-0024 reserved — see [reason]" or "OPP-0024 retired — see commit [hash]") would close the question without ceremony.

### N4 — M-j has now empirically demonstrated its own value (not a new finding; a meta-observation)

The list-completeness drift class has now demonstrated reproduction within 48 hours of its prior occurrence. Refresh #1 named this. This refresh confirms it as a *predictable* recurring class. **Treat this as the strongest evidence in the project's audit history that the structural fix is overdue.**

---

## 5. Drift class diagnosis

The refresh #1 thesis sharpened in the safety sweep companion doc as the cross-cutting insight: **enforcement is structural-only.** Validators check that files exist, that paths match regexes, that integers in the docs match the recipes. They do not check that lists are complete, that wording preserves a tier, or that a claim made in prose has a code anchor. Every drift finding in this refresh — N1 (ADR-0015 absent from a list), N3 (OPP-0024 unexplained), the carry-over M-b (module heading style), M-h (compositions table) — is the same class. They land in indexes the validator does not watch.

The fix has a name: **list-completeness assertions.** Concretely:

```
For every ADR file in docs/adr/, assert a row in docs/README.md ADR table.
For every PRD file in docs/requirements/, assert a row in docs/README.md PRD table.
For every OPP file in docs/opportunities/, assert a row in docs/README.md OPP table
    AND a row in docs/opportunities/candidates.md (or a "retired" footnote).
For every composition YAML in platform/compositions/, assert a row in
    platform/compositions/README.md AND in README.md root table.
For every template subdirectory in platform/templates/, assert a section in
    platform/templates/README.md directory map.
For every module.yaml under platform/profiles/, assert a row in the
    family-appropriate catalog page.
```

This is a ~150-line bash/Ruby validator that follows the existing `validate-catalog-counts.sh` recipe pattern. It is *the* unblocking item — until it ships, every documentation refresh after this one will re-flag a sibling instance of the same defect.

---

## 6. Updated roadmap

| Phase | Scope | Status | Notes |
|---|---|---|---|
| 0 | Truth & wiring | ✅ Done | PR #60 hotfix bundle |
| 0.5 | The MD033 CI-blocker hotfix and the find-and-replace items | ✅ Done | Same PR #60 |
| 1 | The 60-second front door (README rebuild) | ✅ Done | PR #56 / #58 |
| 2 | Mental-model clarity (vocab, trust-model, doctrine rationale, glossary) | ✅ Done | PR #68 |
| **3** | **The visual program + validator hardening** | **In progress — start of Phase 3 is the priority slot** | Three sub-items: (a) embed diagrams #4–#11 in concept docs (H-f); (b) the M-j list-completeness validator extension; (c) add the new visuals proposed in the IA companion doc |
| 4 | Navigation polish + module-README standardization + examples refresh | Pending | H-e, M-b (worsened — 8 new modules added 2 more heading patterns), M-h, M-i, L-a banners |
| **IA Restructure** | New work surfaced this round | Standalone proposal in companion doc | Not part of ADR-0013's original 5 phases; recommend a sibling ADR-0016 |
| **Safety hardening** | New work surfaced this round | Standalone sweep in companion doc | Includes OPP-0020 (eval/safety tooling) prioritization, list-completeness validator (overlaps M-j), trust-tier enforcement (PRD-0006), content-safety validator |

---

## 7. If you do only three things this week

1. **Ship the list-completeness validator.** Closes M-j and prevents N1's recurrence (and the next N1, and the one after). Roughly a half-day of work. Single highest-leverage item in this entire audit cycle.
2. **Fix N1 the right way.** Add ADR-0015 to `docs/README.md` *and* land the validator in the same PR, so the fix is structurally durable. Don't fix it by hand alone.
3. **Decide on ADR-0013 succession.** The IA restructure proposal (companion doc) recommends superseding Phases 3–4 of ADR-0013 with a sibling ADR-0016 carrying the target-tree decision. Either accept that proposal or explicitly rule it out — the longer the IA work runs against an outdated ADR shape, the more friction it accumulates.

The full open-finding ledger from §3 is the longer to-do list; these three are what the refresh #2 audit specifically argues should land before any further catalog growth.

---

## 8. Companion deliverables

This refresh is one of three modular outputs from the 2026-05-27 audit pass:

- **IA Restructure Proposal** (`ia-restructure-proposal.md`) — the target-tree design for adoption and didactic effect, with three new Mermaid diagrams.
- **Safety & Security Sweep** (`safety-security-sweep.md`) — eight safety dimensions organized around the Core Safety and Targeted Safety framings, plus repo/CI hardening, equity, and recommended future analyses.

The three deliverables share one cross-cutting recommendation: **structural enforcement is the missing layer.** The list-completeness validator (this refresh), the target-tree IA migration (the IA proposal), and the content-safety / trust-tier enforcement validators (the safety sweep) are three different concrete shapes for the same architectural move — turning honor-code into code-code.

---

*Refresh #2 prepared 2026-05-27. No repository files were modified.*
