<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Privacy by Design Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make privacy-by-design a default-on/opt-out cross-cutting concern — an operating principle, an ADR, a default-active `management/privacy-by-design` overlay, a warn+validate validator, privacy templates, and init-time guided education — anchored on Cavoukian's 7 principles with a consumer-declared legal regime.

**Architecture:** Governance docs (operating-principle §11 + ADR-0018 + PRD-0018) define the posture; a management overlay + a module-gated, WARN-posture validator enforce the floor and surface implications; `install.sh`'s generated manifest + discovery Step 6 make it default-active; a `privacy-profile.md` template carries the 7-principle education + regime choice + bias guardrail + `none`-exemption.

**Tech Stack:** YAML modules, bash validators (`validate-*.sh`) + Ruby validator lib, markdown governance docs, the three CI workflow files.

**Source spec:** `docs/superpowers/specs/2026-06-03-privacy-by-design-design.md`

---

## Conventions every task must follow

- **Attribution:** harness-authored files (module.yaml, README, ADR, PRD, validator) use `Nate DiNiro <UncleNate@gmail.com>`; **template files** under `platform/templates/**` ship tokenized headers (`Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>`).
- **Placeholder exemption:** files under `platform/**` are exempt from `validate-placeholders.sh`; files under `docs/` are NOT — use the real date `2026-06-03`, never a bare `YYYY-MM-DD` or unfilled `[[TOKEN]]`.
- **Validator runs:** stash the planning folder and capture each exit code IMMEDIATELY (never read `$?` after the restore `mv`, never pipe the validator — both mask failures):
  ```
  mv documentation-audit-2026-05-27 /tmp/au-stash 2>/dev/null
  fail=0
  for v in manifest module-graph required-artifacts placeholders agent-pack companions \
           doc-references catalog-counts list-completeness trust-tier sensitive-paths \
           knowledge-redaction skill-content sast-coverage privacy-by-design; do
    "platform/validators/validate-$v.sh" >/dev/null 2>&1; rc=$?
    [ "$rc" -eq 0 ] && echo "$v OK" || { echo "$v FAIL($rc)"; fail=1; }
  done
  mv /tmp/au-stash documentation-audit-2026-05-27 2>/dev/null
  [ "$fail" -eq 0 ] && echo "ALL GREEN" || { echo "RED"; exit 1; }
  ```
  (Add `privacy-by-design` to the loop only after Task 5 creates the validator.)
- **Distillation rule (PRD-0004):** ADR and module.yaml edits fire the cycle-end distillation rule — each phase must touch `docs/knowledge/shared-observations.md` OR `docs/operating-principles.md`. Phase 1 satisfies it via the §11 operating-principle edit; Phase 2 must add a `shared-observations.md` entry.
- **Git:** branch off `main`. Explicit `git add <paths>`, never `git add -A` (planning folder + the untracked construction brief in `docs/superpowers/specs/` must not be staged).
- **markdownlint:** stash planning folder; watch MD004 (no soft-wrapped line starting with `+ `).

## Catalog-count impact (every assertion site — Phase 2)

Adding 1 validator, 1 module, 3 templates shifts: **validators 14→15, modules_profiles 38→39, modules_all 47→48, templates 66→69.** Sites (from `validate-catalog-counts.sh` ASSERTIONS):
- `platform/reference/how-to-read.md` line ~10: `38 modules, 66 templates, 14 validators` → `39 modules, 69 templates, 15 validators`.
- `docs/_assets/cover-back.svg`: `>47 modules<`→`>48`, `>66 templates<`→`>69`, `>14 validators<`→`>15`.
- `docs/architecture/diagrams.md`: `(47 total in-tree)`→`48`, `66 scaffolding files`→`69`, `14 ... scripts`→`15`.
- `README.md` **word forms** (the trap): `Validator chain** — fourteen shell scripts` → `fifteen`; `Fourteen validators, each targeting` → `Fifteen`; `Validators</b><br/>14 scripts` → `15`.

---

# PHASE 1 — Governance (design-only PR)

Branch: `privacy-by-design-phase1`. Produces ADR-0018 + PRD-0018 + operating-principle §11. No module/validator yet.

### Task 1: Operating Principle §11

**Files:**
- Modify: `docs/operating-principles.md` (append `## 11. Privacy by Design, by Default` after §10)

- [ ] **Step 1: Read §10 for house style** — `sed -n '273,330p' docs/operating-principles.md` (match heading depth, prose voice, any "Enforcement"/"Rationale" sub-structure §10 uses).

- [ ] **Step 2: Append §11.** After the end of §10, add:

```markdown

## 11. Privacy by Design, by Default

The harness is built around **privacy by design** and ships it **on by default** to consumer
projects. The content spine is Cavoukian's seven Foundational Principles of Privacy by Design
(proactive not reactive; privacy as the default setting; privacy embedded into design; full
functionality / positive-sum; end-to-end security; visibility and transparency; respect for
user privacy). These are jurisdiction-neutral — the universal floor. The applicable *legal
regime* (GDPR, CCPA/CPRA, LGPD, PIPEDA, PIPL, …) is a consumer-declared choice made at
initialization, never assumed.

**Default-on, opt-out.** Every bootstrapped project activates `management/privacy-by-design`.
A project with genuinely no personal or sensitive data may opt out — but opt-out is explicit
and recorded (a one-line exemption in `docs/privacy/privacy-profile.md`), never silent. If
data-handling later appears despite an exemption, the validator warns and prompts re-choosing
a regime.

**Layered enforcement.** The validator *warns* on privacy-risk patterns (advisory); companion
rules *enforce* that privacy artifacts update when data-handling paths change; review gates
*prevent* risky merges via required human sign-off. Privacy *outcomes* remain human-judged
(Asserted-only per §10); artifact presence is Enforced; risk-pattern detection is
Half-enforced.

This principle is the first cross-vertical reuse of the deep-domain jurisdiction-neutral-core
+ forcing-artifact + bias-guardrail pattern: the same machinery that keeps `domains/healthcare-*`
from assuming a jurisdiction keeps privacy from assuming a legal regime.
```

- [ ] **Step 3: Run the validator suite** (Phase-1 loop, WITHOUT `privacy-by-design`) → all green. Editing `operating-principles.md` satisfies the PRD-0004 distillation rule for this PR.

- [ ] **Step 4: markdownlint** `docs/operating-principles.md` (folder stashed) → 0 errors.

- [ ] **Step 5: Commit**
  ```
  git add docs/operating-principles.md
  git commit -m "[Privacy by Design] operating-principle §11 — privacy by design, by default"
  ```

### Task 2: ADR-0018 (privacy-by-default posture)

**Files:**
- Create: `docs/adr/ADR-0018-privacy-by-default-posture.md`
- Modify: `docs/README.md` (ADR catalog row)

- [ ] **Step 1: Read the ADR template + a recent ADR** — `sed -n '1,40p' platform/templates/adr.md` and `sed -n '1,50p' docs/adr/ADR-0017-safety-hardening-roadmap.md` for the exact status/section shape.

- [ ] **Step 2: Write the ADR** at `docs/adr/ADR-0018-privacy-by-default-posture.md` following that structure. Required content: SPDX header (Nate DiNiro); `# ADR-0018 — Privacy-by-Default Posture`; Status `Accepted`; Context (privacy is a cross-cutting concern; the harness should help consumers implement PbD, not just permit it); **Decision** (default-on/opt-out, anchored on Cavoukian's 7 with a consumer-declared regime; active-but-exempt opt-out); **Alternatives considered and rejected** — (a) *opt-in overlay only* (rejected: "by default" requires activation by default, not consumer initiative); (b) *kernel-mandatory* (rejected: imposes privacy ceremony on genuinely data-free projects — libraries, pure compute); **Consequences** (a default manifest now includes the overlay; a `none` exemption path exists; the validator is module-gated so the harness's own CI stays green while dogfood is deferred). Real date `2026-06-03`, no `[[TOKEN]]`.

- [ ] **Step 3: Add the list-completeness ADR row.** In `docs/README.md` find the ADR table (search `ADR-0017`), copy that row's exact column schema, add an `ADR-0018` row.

- [ ] **Step 4:** `platform/validators/validate-list-completeness.sh` → exit 0 (fix the row shape if it flags ADR-0018).

- [ ] **Step 5: Run the validator suite** (Phase-1 loop) → all green. (The ADR fires the distillation rule; the §11 edit from Task 1 already satisfies it in this PR.)

- [ ] **Step 6: markdownlint** the ADR + `docs/README.md` (folder stashed) → 0 errors.

- [ ] **Step 7: Commit**
  ```
  git add docs/adr/ADR-0018-privacy-by-default-posture.md docs/README.md
  git commit -m "[Privacy by Design] ADR-0018 — privacy-by-default posture"
  ```

### Task 3: PRD-0018 (design contract)

**Files:**
- Create: `docs/requirements/PRD-0018-privacy-by-design.md`
- Modify: `docs/README.md` (PRD catalog row)

- [ ] **Step 1: Read a recent PRD** — `sed -n '1,60p' docs/requirements/PRD-0017-healthcare-fhir-smart-wedge.md` for the section order + §10 block + standalone Verification section.

- [ ] **Step 2: Write PRD-0018** following PRD-0017's structure. Required content: SPDX header; `# PRD-0018 — Privacy-by-Design Module`; Status `Proposed`; Owner @unclenate; Last Updated `2026-06-01`→use `2026-06-03`; Origin cites ADR-0018; design-context cites the spec path. Must-Haves: **M1** `management/privacy-by-design` module (dependsOn kernel/base; required artifact `docs/privacy/privacy-profile.md`; optional `data-inventory.md`, `privacy-impact-assessment.md`; the two companion rules; review gates). **M2** `validate-privacy-by-design.sh` — module-gated (exit 0 when inactive), VALIDATE layer (profile presence + consistency), WARN layer (privacy-risk patterns, exit 0), `--scan-file` seam. **M3** `platform/templates/privacy/` (3 templates incl. the bias-guardrail `privacy-profile.md` with the 7-principle explainer + regime choice + `none` exemption). **M4** default-active mechanism (install.sh generated manifest includes the module; discovery Step 6 lists it default-on; bootstrap-quickstart adds privacy-profile to Bootstrap-Complete) + init-flow education (onboarding skill, intake-questionnaire). **M5** CI wiring (3 workflows) + catalog-count propagation. **§10 Claim Classification** table: profile presence = Enforced (validate-privacy-by-design + validate-required-artifacts); data-handling change pairs privacy doc = Enforced (validate-companions); risk-pattern detection = Half-enforced; privacy outcomes = Asserted-only. **Standalone Verification section.** Open questions: dogfood/manifest (default ship-as-catalog, dogfood-deferred); exact sensitivePaths/WARN regex; optional `harness-privacy` skill.

- [ ] **Step 3: Add the list-completeness PRD row** in `docs/README.md` (copy the PRD-0017 row schema).

- [ ] **Step 4:** `validate-list-completeness.sh` → exit 0.

- [ ] **Step 5: Run the validator suite** → all green.

- [ ] **Step 6: markdownlint** the PRD + `docs/README.md` → 0 errors.

- [ ] **Step 7: Commit**
  ```
  git add docs/requirements/PRD-0018-privacy-by-design.md docs/README.md
  git commit -m "[Privacy by Design] PRD-0018 — privacy-by-design module (design-only)"
  ```

- [ ] **Step 8: Push + open the Phase 1 design-only PR; confirm CI green; resolve Copilot.** Phase 2 is gated on this merging (Phase 2 module README + validator cross-reference ADR-0018 / PRD-0018).

---

# PHASE 2 — Implementation (modules PR)

Branch: `privacy-by-design-phase2` off `main` after Phase 1 merges. Per-commit reality (healthcare lesson): a module/validator/template commit makes `catalog-counts` red until its count bump lands in the same logical change — group accordingly; each task ends fully green.

### Task 4: The overlay module (`management/privacy-by-design`)

**Files:**
- Create: `platform/profiles/management/privacy-by-design/module.yaml`
- Create: `platform/profiles/management/privacy-by-design/README.md`
- Modify: `SUMMARY.md`; the module-count sites (how-to-read 38→39, cover-back, diagrams 47→48)

- [ ] **Step 1: Read** `platform/profiles/management/security-static-analysis/module.yaml` to match the management-module schema exactly.

- [ ] **Step 2: Write `module.yaml`:**
```yaml
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
id: privacy-by-design
type: management
version: 1.0.0
summary: Privacy-by-design overlay — Cavoukian's 7 principles as a jurisdiction-neutral spine, a consumer-declared legal regime, and a warn+validate floor for data-handling changes. Default-active, opt-out via a documented exemption.
dependsOn:
  - kernel/base
conflictsWith: []
requiredArtifacts:
  - docs/privacy/privacy-profile.md
optionalArtifacts:
  - docs/privacy/data-inventory.md
  - docs/privacy/privacy-impact-assessment.md
sensitivePaths:
  - description: Personal-data handling, consent, telemetry, and third-party data egress surfaces
    patterns:
      - pii
      - personal
      - ^src/.*user
      - consent
      - analytics
      - telemetry
      - tracking
      - ^auth/
companionRules:
  - description: Data-handling sensitive-path changes require a privacy-profile or data-inventory update or an ADR
    triggerPaths:
      - pii
      - personal
      - consent
      - analytics
      - telemetry
    requiredAny:
      - ^docs/privacy/privacy-profile\.md$
      - ^docs/privacy/data-inventory\.md$
      - ^docs/adr/ADR-
    humanReview: Reviewers confirm the privacy implications of the change are captured and the declared regime still holds.
  - description: privacy-profile regime or exemption changes require a change-log entry or ADR
    triggerPaths:
      - ^docs/privacy/privacy-profile\.md$
    requiredAny:
      - ^docs/project/change-log\.md$
      - ^docs/adr/ADR-
    humanReview: Reviewers confirm a regime or exemption change is intentional.
validators:
  - validate-privacy-by-design
  - validate-companions
reviewGates:
  - Human review is required for broadening data collection, adding third-party data egress, weakening a declared privacy default, changing legal regime, or logging PII-shaped data.
agentAdapters:
  - platform/agents/base
compiledFragments:
  - platform/profiles/management/privacy-by-design/README.md
recommendedSkills:
  - harness-governance   # trust tiers and companion rules (source: platform/skills/)
```

- [ ] **Step 3: Write `README.md`** in the Wave 4.2 standardized shape: SPDX `<!-- -->` header; `# Management Overlay: Privacy by Design`; blank; `**Depends on:** \`kernel/base\`.` / `**Conflicts with:** None.`; blank; intro (default-on cross-cutting concern; Cavoukian spine + declared regime); `## What This Overlay Requires` (privacy-profile required; data-inventory/PIA optional); `## Sensitive Paths and Companion Rules`; `## Review Gate`; `## See Also` (module.yaml; Active modules table `../../../../HARNESS.md`; Templates `\`platform/templates/privacy/\``; Origin `ADR-0018` + `PRD-0018` with `../../../../docs/...` links). No trailing-slash markdown links (verify `grep -nE '\]\([^)]*/\)'` empty).

- [ ] **Step 4: SUMMARY.md** — under `### Management` add `* [Privacy by Design](platform/profiles/management/privacy-by-design/README.md) — default-on privacy-by-design overlay; Cavoukian's 7 principles + declared legal regime`.

- [ ] **Step 5: Module-count bump 38→39 / 47→48** at how-to-read.md, cover-back.svg, diagrams.md (see "Catalog-count impact"). `validate-catalog-counts.sh` + `validate-list-completeness.sh` → exit 0.

- [ ] **Step 6: Run suite** (still WITHOUT privacy-by-design in the loop — validator not created yet) → green. **Commit** module.yaml + README + SUMMARY + count sites.

### Task 5: The validator (`validate-privacy-by-design.sh`) + fixtures + tests

**Files:**
- Create: `platform/validators/validate-privacy-by-design.sh` (executable)
- Create: `platform/validators/test/fixtures/privacy/*` (a clean profile, a `none`-exemption profile, a contradiction profile, a risk-pattern sample)
- Create/modify: the validator test file alongside the existing validator tests
- Modify: validator-count sites (14→15, incl. README word forms)

- [ ] **Step 1: Read both analogs** — `validate-sast-coverage.sh` (module-gating + `--scan-file`) and `validate-knowledge-redaction.sh` (WARN posture, `--block`). The new validator combines them.

- [ ] **Step 2: Write the validator** following those patterns. Behavior contract (document in the header comment, exit codes, usage):
  - Args: `[<manifest>] [<project-root>]` (gated mode) and `--scan-file <path>` (test seam, bypasses gating).
  - Gated mode: parse manifest active modules. If `management/privacy-by-design` NOT active → print "module inactive" and `exit 0` (this keeps auto-harness CI green; dogfood deferred).
  - If active: **VALIDATE** — `docs/privacy/privacy-profile.md` must exist and declare either a regime or `regime: none` + a non-empty exemption line; consistency — if `docs/privacy/data-inventory.md` lists personal data while the profile is `regime: none` → `exit 1`; if sensitive-data paths exist but profile is `none` with no data-inventory → WARN. **WARN** — scan changed/repo text for risk patterns (new `analytics`/`telemetry` SDK refs, third-party egress, PII-shaped logging, data fields with no nearby `consent`) and surface on stderr; WARN posture exits 0 (mirror knowledge-redaction; offer `--block` to escalate).
  - `--scan-file <path>`: run only the profile-consistency checks against the given file; used by the fixture tests.
  - Exit codes: 0 = inactive OR active-and-clean (incl. WARN hits); 1 = active-and-VALIDATE-failure; 2 = usage error.

- [ ] **Step 3: `chmod +x`** the validator. Create fixtures: `clean-profile.md` (regime declared), `none-exempt.md` (`regime: none` + exemption), `contradiction.md` (`regime: none` + a data-inventory listing PII — must fail), `risk-sample.md` (telemetry-without-consent — must WARN).

- [ ] **Step 4: Write the tests** matching the existing validator test harness (find how `validate-sast-coverage` is tested under `platform/validators/test/`; mirror it). Assert: inactive→0; `--scan-file clean-profile.md`→0; `--scan-file contradiction.md`→1; risk-sample surfaces a WARN but exits 0. Run the tests → all pass.

- [ ] **Step 5: Validator-count bump 14→15** at how-to-read.md, cover-back.svg, diagrams.md, AND the **README word forms** (`fourteen`→`fifteen`, `Fourteen`→`Fifteen`, `14 scripts`→`15`). `validate-catalog-counts.sh` → exit 0.

- [ ] **Step 6: Dogfood check** — run `validate-privacy-by-design.sh harness.manifest.yaml .` → exit 0 with "module inactive" (auto-harness does not activate it; ship-as-catalog per the spec). Then run the FULL suite WITH `privacy-by-design` added to the loop → all 15 green. **Commit** validator + fixtures + tests + count sites.

### Task 6: Templates (`platform/templates/privacy/`)

**Files:**
- Create: `platform/templates/privacy/privacy-profile.md`, `data-inventory.md`, `privacy-impact-assessment.md`
- Modify: `platform/templates/README.md` (new "Privacy Templates" section + TOC); template-count 66→69 sites

- [ ] **Step 1: Write `privacy-profile.md`** (tokenized header). Four blocks: (1) a plain-language explainer of Cavoukian's 7 principles; (2) a **regime-choice block** — a table with rows for GDPR / CCPA-CPRA / LGPD / PIPEDA / PIPL / multiple / `decide-later` / `none` and a "selected:" field; (3) the **bias guardrail** blockquote (verbatim): `> **Bias guardrail.** No legal regime is the default. Declare yours below. Do not assume GDPR, US (CCPA/CPRA), or any single regime applies — privacy law is jurisdictional and the principles (Cavoukian's 7) are the universal floor, not any one country's statute.`; (4) a `none`-exemption block (`If you selected none: one-line reason this project handles no personal/sensitive data`). Keep `>` lines contiguous (MD028).

- [ ] **Step 2: Write `data-inventory.md`** (tokenized) — table of personal-data categories, source, purpose, storage, retention, destruction; lawful-basis column.

- [ ] **Step 3: Write `privacy-impact-assessment.md`** (tokenized) — DPIA-style: processing description, necessity/proportionality, risks to data subjects, mitigations, residual risk sign-off.

- [ ] **Step 4: Register in `platform/templates/README.md`** — add `[Privacy](#privacy-templates)` to the TOC and a `## Privacy Templates` table (3 rows, module `management/privacy-by-design`) matching the existing column schema. `validate-list-completeness.sh` → exit 0.

- [ ] **Step 5: Template-count bump 66→69** at how-to-read.md, cover-back.svg, diagrams.md. `validate-catalog-counts.sh` → exit 0.

- [ ] **Step 6:** `validate-placeholders.sh` → 0 (platform/** exempt). Run full suite → 15 green. markdownlint the templates + templates README → 0. **Commit.**

### Task 7: Default-active mechanism + init-flow education

**Files:**
- Modify: `platform/bootstrap/install.sh` (generated-manifest default module set) + `platform/bootstrap/test/test_install.rb`
- Modify: `platform/workflow/discovery-to-composition.md` (Step 6), `platform/templates/discovery/intake-questionnaire.md`, `platform/workflow/bootstrap-quickstart.md`, `platform/skills/harness-onboarding/SKILL.md`

- [ ] **Step 1: install.sh** — find the generated-manifest content in `handle_manifest()` (`grep -n 'schemaVersion\|modules:\|management:' platform/bootstrap/install.sh`). Add `management/privacy-by-design` to the default `modules.management:` list the generator emits. Update `platform/bootstrap/test/test_install.rb` assertions that check the generated manifest's module set. Run `ruby platform/bootstrap/test/test_install.rb` → all pass.

- [ ] **Step 2: discovery Step 6** — add a row to the decision matrix: `| Handles any personal or sensitive data? (default: yes) | \`management/privacy-by-design\` (default-on; opt out only with a documented exemption) |`.

- [ ] **Step 3: intake-questionnaire.md** — add a "Privacy" section: does the project handle personal/sensitive data; which legal regime(s); if none, why.

- [ ] **Step 4: bootstrap-quickstart.md** — in the Bootstrap-Complete list add `validate-privacy-by-design.sh exits 0` and note `docs/privacy/privacy-profile.md` present (or a documented `none` exemption).

- [ ] **Step 5: harness-onboarding/SKILL.md** — add a privacy step to the onboarding flow: teach the 7 principles, walk the regime choice (or warned `none`), record in `privacy-profile.md`; add `management/privacy-by-design` to the management catalog list with correct required artifacts (`docs/privacy/privacy-profile.md`). `validate-skill-content.sh` → 0.

- [ ] **Step 6:** Run full suite → 15 green. markdownlint changed files → 0. **Commit.**

### Task 8: CI wiring (3 workflows)

**Files:**
- Modify: `.github/workflows/harness.yml`, `platform/templates/ci/github-actions.yml`, `platform/templates/ci/gitlab-ci.yml`

- [ ] **Step 1:** In `.github/workflows/harness.yml`, after the `validate-sast-coverage.sh` step (line ~87), add a step: `run: bash platform/validators/validate-privacy-by-design.sh harness.manifest.yaml .` (gated → exit 0 for auto-harness). Mirror the addition into the two `platform/templates/ci/*` templates following their existing per-validator step pattern.

- [ ] **Step 2:** Run full suite → 15 green. markdownlint (yml not linted; skip). **Commit.**

### Task 9: Distillation observation + final gate

**Files:**
- Modify: `docs/knowledge/shared-observations.md` (+ Last Updated header), `docs/project/change-log.md`

- [ ] **Step 1: shared-observations entry** — Phase 2 adds a module.yaml (distillation trigger). Append a substantive observation: *"privacy-by-design is the first cross-vertical reuse of the deep-domain jurisdiction-neutral-core + forcing-artifact + bias-guardrail primitives — applied to a cross-cutting concern rather than a domain — evidence the primitives generalize ahead of the framework harvest."* Bump the Last Updated header. (Non-cargo-cult: it names a generalization the earlier observations set up.)

- [ ] **Step 2: change-log entry** — one entry covering the full PR: module + validator + 3 templates + init-flow + default-active (install.sh) + CI + counts (39/48/69/15). Audit-trail for the shared-observations + module edits.

- [ ] **Step 3: FULL 15-validator suite** (independent, correct exit capture) → all green. markdownlint all changed markdown → 0.

- [ ] **Step 4: Push + open the Phase 2 PR; confirm CI green; resolve Copilot.** Do not merge without explicit direction.

---

## Self-review checklist (run after writing, before execution)

- [ ] Spec coverage: §11 (Task 1), ADR posture + rejected alternatives (Task 2), PRD + §10 (Task 3), overlay M1 (Task 4), validator M2 (Task 5), templates M3 (Task 6), default-active + init-flow M4 (Task 7), CI M5 (Task 8). Bias guardrail = Task 6 Step 1. Dogfood-deferred = Task 5 Step 6.
- [ ] Placeholder scan: ADR/PRD/change-log/shared-observations use `2026-06-03`; template `[[TOKEN]]`s are platform-exempt.
- [ ] Name consistency: module id `privacy-by-design`; artifact `docs/privacy/privacy-profile.md`; validator `validate-privacy-by-design.sh`; ADR-0018 / PRD-0018 used identically across tasks.
- [ ] Count math: validators 14→15 (incl. README word forms), modules 38→39 / 47→48, templates 66→69 — consistent in Tasks 4/5/6.
