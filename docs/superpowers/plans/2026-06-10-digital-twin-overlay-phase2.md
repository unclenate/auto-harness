# Digital Twin / Scenario Runtime Overlay — Phase 2 (implementation) Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax. This plan is HYBRID: copy-exact literal content for docs/config/templates; TDD (fixtures → test → implement) for the two validators.

**Goal:** Build the `management/digital-twin` overlay specified by PRD-0023 — module + 10 templates + two Half-enforced module-gated WARN validators (with fixtures/tests) + the `harness-digital-twin` skill + a sample composition + discoverability + catalog-count propagation — as a single PR that keeps the harness's own validator suite green (the overlay is catalog-only, not activated on this repo).

**Architecture:** A management overlay mirroring `management/privacy-by-design` exactly (module shape, validator posture, ship-as-catalog). Default-off (no manifest entry). The two validators are module-gated (no-op when the overlay is inactive) with a `--scan-file` seam for fixture tests, mirroring `validate-privacy-by-design.sh`. The maturity-gated artifact model lives in the templates + README guidance (depth-by-maturity is Asserted-only in v1; the validators enforce profile + manifest *presence/shape* only).

**Tech Stack:** YAML module contracts; Markdown templates/docs; Bash 3.2 validators; Ruby (system) for validator logic + Minitest integration tests; `markdownlint-cli2`; `gh` CLI.

---

## Governing facts (verified against `origin/main`, 2026-06-10)

- **Implements PRD-0023** (merged, #111). Creates NO new numbered OPP/ADR/PRD — so no candidates token, no README OPP/PRD/ADR index rows. Creating `module.yaml` fires the **PRD-0004 distillation rule** → satisfied by the FR-S01 observation in `shared-observations.md` (Task 9); the audit-trail floor → `change-log.md` (Task 9).
- **Current counts → Phase-2 targets:** modules_profiles **42→43**; modules_all **51→52**; validators **15→17**; skills **7→8**; templates **74→84** (+10). Diagrams **stays 13** (see deferral).
- **DEFERRED to a maintainer follow-up (do NOT do in this PR):** the Cybersecurity-style **family diagram (PRD-0023 FR-007)** and the consequent **HARNESS.md diagram-count bump**. Rationale: HARNESS.md is a governance entrypoint; editing its `— thirteen Mermaid diagrams` line triggers the CLAUDE.md companion-rule reflex (ADR or operating-principles update in the same commit), disproportionate for a count bump (established pattern: maintainer one-liner). By NOT adding a diagram, all diagram-count sites stay 13 and **HARNESS.md is not touched at all**. Note this explicitly in the PR body as a known follow-up.
- **Catalog-only:** do NOT add `management/digital-twin` to `harness.manifest.yaml` (mirrors privacy / security-static-analysis). The module is NOT added to HARNESS.md "Active Modules" (that section is repo-active modules only). So **HARNESS.md is untouched**.
- **Module-gating:** both validators must no-op (exit 0) when no `digital-twin` module is active, so the harness's own CI stays green. Mirror the gating in `validate-privacy-by-design.sh` (checks `active_modules.any? { |m| m["id"] == "digital-twin" }`).
- **Attribution:** SPDX dual-license headers, `UncleNate@gmail.com`. Templates use `[[TOKEN]]` placeholders + SPDX-in-frontmatter. Do not modify `LICENSE-APACHE` URLs.
- **markdownlint hazards:** no line starting with `+ ` (MD004); table column consistency (MD056); no trailing blank lines (MD012); template SPDX headers go INSIDE the YAML frontmatter at line 1 (the `---` fence first), per the privacy-template pattern.
- **Branch/merge:** feature branch `digital-twin-overlay-phase2`; push; PR; **no merge** (Tier 3).
- **RE-VERIFY at execution:** counts and the count-site assertion table (`platform/validators/validate-catalog-counts.sh` ASSERTIONS) — a parallel PR may have shifted them.

## Count-site map (every place the changed counts are asserted — from the ASSERTIONS table)

Update ONLY these for modules(42→43 / 51→52), templates(74→84), validators(15→17), skills(7→8). **Do NOT touch diagram counts or HARNESS.md.**

| File | Tokens to change |
|---|---|
| `platform/reference/how-to-read.md` | prose: `42 modules`→43, `74 templates`→84, `15 validators`→17, `7 skills`→8; ASCII art: `(42 modules)`→43? *(verify which count-key — modules_profiles)*, `(15 scripts)`→17, `(74 files)`→84 |
| `docs/architecture/diagrams.md` (diagram 1 labels only) | `(51 total in-tree)`→52, `>15 scripts`→17, `>74 scaffolding files`→84 |
| `docs/_assets/cover-back.svg` | `>51 modules<`→52, `>15 validators<`→17, `>7 skills<`→8, `>74 templates<`→84 |
| `README.md` | `Validator chain** — fifteen`→seventeen, `Fifteen validators`→Seventeen, `provides seven skills`→eight, mermaid `Validators</b><br/>15 scripts`→17 |
| `platform/workflow/skills-and-agents.md` | `provides seven skills`→eight |

> Run `bash platform/validators/validate-catalog-counts.sh .` after edits; it names any missed site with file/line/expected/actual. Fix forward until exit 0.

## File map

| File | Action |
|---|---|
| `platform/profiles/management/digital-twin/module.yaml` | Create |
| `platform/profiles/management/digital-twin/README.md` | Create |
| `platform/templates/digital-twin/{twin-profile,overview,scenario-manifest-spec,data-provenance,model-registry,agent-registry,run-log-spec,uncertainty-policy,publication-policy,security-boundaries}.md` | Create (10) |
| `platform/validators/validate-twin-profile.sh` | Create |
| `platform/validators/validate-scenario-manifest.sh` | Create |
| `platform/validators/test/fixtures/digital-twin/*` | Create (fixtures) |
| `platform/validators/test/test_validators_integration.rb` | Modify (2 test classes) |
| `platform/skills/harness-digital-twin/SKILL.md` | Create |
| `platform/compositions/digital-twin-prototype.yaml` | Create |
| `platform/compositions/README.md` | Modify (1 row) |
| `SUMMARY.md`, `README.md`, `platform/skills/harness-onboarding/SKILL.md`, `platform/workflow/discovery-to-composition.md` | Modify (discoverability) |
| `platform/reference/how-to-read.md`, `docs/architecture/diagrams.md`, `docs/_assets/cover-back.svg`, `platform/workflow/skills-and-agents.md` | Modify (count propagation) |
| `docs/knowledge/shared-observations.md`, `docs/project/change-log.md` | Modify (distillation + audit-trail) |

---

### Task 1: Create the module (`module.yaml` + README)

**Files:** Create `platform/profiles/management/digital-twin/module.yaml` and `.../README.md`

- [ ] **Step 1: Write `module.yaml` verbatim**

```yaml
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
id: digital-twin
type: management
version: 1.0.0
summary: Digital Twin / Scenario Runtime overlay — governs projects that model real-world systems, run scenarios, and publish decision-support. A maturity-gated twin-profile forcing artifact, a dual-spine standards anchor (interoperability/digital-thread + the Gemini Principles), and a WARN+validate floor for scenario/provenance changes. Default-off, opt-in.
dependsOn:
  - kernel/base
conflictsWith: []
requiredArtifacts:
  - docs/twin/twin-profile.md
optionalArtifacts:
  - docs/twin/scenario-manifest-spec.md
  - docs/twin/data-provenance.md
  - docs/twin/model-registry.md
  - docs/twin/agent-registry.md
  - docs/twin/run-log-spec.md
  - docs/twin/uncertainty-policy.md
  - docs/twin/publication-policy.md
  - docs/twin/security-boundaries.md
sensitivePaths:
  - description: Scenario, model, agent, dataset, run-state, and public-scenario surfaces for a digital twin
    patterns:
      - ^scenarios/
      - ^models/
      - ^agents/
      - ^datasets/
      - ^data/
      - ^simulation/
      - ^public/scenarios/
      - ^docs/twin/
companionRules:
  - description: Scenario/model/agent/dataset/run-state changes require a twin artifact update or an ADR
    triggerPaths:
      - ^scenarios/
      - ^models/
      - ^agents/
      - ^datasets/
      - ^simulation/
    requiredAny:
      - ^docs/twin/.*\.md$
      - ^docs/adr/ADR-
    humanReview: Reviewers confirm the scenario/model/provenance change is captured and the declared maturity level still holds.
  - description: twin-profile maturity or conformance changes require a change-log entry or ADR
    triggerPaths:
      - ^docs/twin/twin-profile\.md$
    requiredAny:
      - ^docs/project/change-log\.md$
      - ^docs/adr/ADR-
    humanReview: Reviewers confirm a maturity-level or standards-conformance change is intentional and evidence-backed.
validators:
  - validate-twin-profile
  - validate-scenario-manifest
  - validate-companions
reviewGates:
  - Human review required before publishing any public scenario or decision-support output, and for any regulatory, financial, civic, safety, healthcare, or operational output.
  - Second review required for production / control-loop integrations; security review for sensitive infrastructure or geospatial data; privacy review for personal, health, behavioral, or civic-participation data.
  - ADR required for material changes to model semantics, scenario semantics, or public-facing methodology.
agentAdapters:
  - platform/agents/base
compiledFragments:
  - platform/profiles/management/digital-twin/README.md
recommendedSkills:
  - harness-digital-twin   # twin maturity, world/scenario/run state, provenance (source: platform/skills/)
  - harness-governance     # trust tiers and companion rules
```

- [ ] **Step 2: Write `README.md` verbatim** (mirrors the privacy README structure)

```markdown
<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Management Overlay: Digital Twin / Scenario Runtime

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay governs projects that **model real-world systems, run scenarios,
and publish decision-support** — a default-off, opt-in cross-cutting concern
that layers on whatever the project is (civic, real-estate / built-environment,
AI-datacenter, healthcare, geospatial). It is the second discipline overlay
after `privacy-by-design`, and it makes "build a planning model that can be
transformed into an operational twin" a governed conformance question.

## What This Overlay Requires

- **Required:** `docs/twin/twin-profile.md` — the forcing artifact. Declares the
  **maturity level** (digital model → shadow → prototype → operational →
  control-loop), the **standards conformance** the twin targets and at what
  *status* (published vs emerging), and the **governing principles** (the Gemini
  Principles). Template at `platform/templates/digital-twin/`.
- **Optional (required by maturity level):** scenario-manifest-spec,
  data-provenance, model-registry, agent-registry, run-log-spec,
  uncertainty-policy, publication-policy, security-boundaries — see the maturity
  ladder in `overview.md`. A digital *model* needs only the profile; an
  *operational* twin needs run-log + publication + review gates.

## Maturity ladder (declare your level; do not overclaim)

| Level | Adds (required) |
|---|---|
| 1 Digital model | twin-profile only |
| 2 Digital shadow | + data-provenance |
| 3 Digital twin prototype | + scenario-manifest-spec + model-registry + agent-registry + uncertainty-policy |
| 4 Operational twin | + run-log-spec + publication-policy + review gates |
| 5 Closed-loop / control twin | + security-boundaries + safety / second-review gates |

> **Bias guardrail — default-deny overclaiming.** You may not claim a maturity
> level your evidence does not support (no "operational twin" without live
> synchronization, run logs, and operational governance), cite an emerging
> standard as ratified, or publish a high-impact output without its review gate.

## Dual-spine standards anchor

- **Interoperability / digital thread:** ISO 23247 (incl. the emerging Part 5
  digital-thread), ISO/IEC 30173 (terminology), Asset Administration Shell
  (IEC 63278), DTDL, W3C WoT, ISO 10303 STEP/AP242, QIF (ISO 23952). Cite
  published as normative, emerging as emerging.
- **Governance values:** the Gemini Principles (CDBB, 2018) — Purpose
  (public good, value creation, insight), Trust (security, openness, quality),
  Function (federation, curation, evolution). "Federation" requires the standard
  connected environment the interoperability spine provides.

## Composition

Composes with `management/privacy-by-design` (personal/civic data) and with
subject-matter domains. The lead built-environment stack is
`domains/aec-iso19650-im` × `management/digital-twin` × `management/privacy-by-design`
(see `platform/compositions/digital-twin-prototype.yaml`).

## Sensitive Paths and Companion Rules

Registers scenario/model/agent/dataset/run-state/public-scenario patterns; changes
touching them require a twin-artifact update or an ADR. twin-profile maturity or
conformance changes require a change-log entry or ADR. Reviewers confirm the
declared maturity still holds.

## When to activate

Activate for projects that model real-world systems or run scenarios for
decision support. Not needed for projects that merely visualize data (a dashboard
is not a twin) or do no scenario modeling.
```

- [ ] **Step 3: Verify** — `bash platform/validators/validate-module-graph.sh harness.manifest.yaml` exits 0 (the `digital-twin` module parses and its `kernel/base` dep resolves). No commit yet.

---

### Task 2: Create the 10 templates

**Files:** Create the ten files under `platform/templates/digital-twin/`.

> All templates: SPDX header inside YAML frontmatter at line 1 (mirror `platform/templates/privacy/privacy-profile.md`), `[[TOKEN]]` placeholders, `YYYY-MM-DD` for dates. Keep skeletons tight; the consumer fills them.

- [ ] **Step 1: Write `twin-profile.md` verbatim** (the forcing artifact — the validator checks this)

```markdown
---
# Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
# SPDX-License-Identifier: [[SPDX_LICENSE]]
maturity: [[MATURITY_LEVEL]]
conformance:
  - standard: [[STANDARD_ID]]
    status: [[published_or_emerging]]
governingPrinciples: [[GEMINI_PRINCIPLES_APPLIED]]
---

# Twin Profile — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required artifact for the `management/digital-twin` overlay. Declares this twin's
maturity, the interoperability/thread standards it conforms to (and at what
status), and the Gemini Principles governing its outputs.

## Maturity declaration

**Declared level:** [[MATURITY_LEVEL]]  *(digital-model | digital-shadow | digital-twin-prototype | operational-twin | control-loop)*

**Evidence for this level:** [[MATURITY_EVIDENCE]]

> **Bias guardrail.** Do not claim a level your evidence does not support. An
> operational twin requires live synchronization, run logs, and operational
> governance; a control-loop twin additionally requires safety controls and a
> second review.

## Standards conformance

| Standard | Targets | Status (published / emerging) |
|----------|---------|-------------------------------|
| [[STANDARD_ID]] | [[WHAT_IT_COVERS]] | [[published_or_emerging]] |

> Cite published standards as normative; cite emerging standards (e.g.
> ISO 23247-5 digital thread, ISO/IEC 30188) as emerging — never as ratified.

## Governing principles (Gemini)

State which principles govern this twin's publication and trust posture:
Purpose (public good, value creation, insight); Trust (security, openness,
quality); Function (federation, curation, evolution).

**Applied:** [[GEMINI_PRINCIPLES_APPLIED]]

## World / scenario / run state

Confirm the project separates **canonical world state** (best-known reality),
**scenario state** (a branch with changed assumptions), and **run state** (one
execution's trace). Do not mutate canonical world state to test a scenario —
branch it, run against the branch, and log the run.
```

- [ ] **Step 2: Write `overview.md` verbatim** (the maturity ladder + the world/scenario/run doctrine)

```markdown
---
# Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
# SPDX-License-Identifier: [[SPDX_LICENSE]]
---

# Digital Twin Overview & Maturity Ladder — [[PROJECT_NAME]]

Classify the project honestly. The ladder discourages overclaiming.

1. **Digital model** — static representation of assets/places/systems.
2. **Digital shadow** — model updated from real/periodic data; not interactive.
3. **Digital twin prototype** — scenario-capable, explainable; not closed-loop.
4. **Operational twin** — live/synchronized, governed, auditable; used for decisions.
5. **Closed-loop / control twin** — can influence real-world systems; highest controls.

Required-artifact depth scales with the declared level (see `twin-profile.md`).

## Three states you must distinguish

- **Canonical world state** — the best-known current representation of reality.
- **Scenario state** — a branch/fork of world state with changed assumptions.
- **Run state** — the execution trace and outputs of one simulation/evaluation.

> Do not mutate canonical world state to test a scenario. Branch it, run against
> the branch, and log the run.

## Anti-patterns this overlay guards against

A dashboard masquerading as a twin · LLM-generated truth · unversioned datasets ·
unreproducible runs · hidden assumptions · fake precision · public/private leakage ·
no model registry · no run log · no uncertainty statement · no review gate before
public or high-impact outputs.
```

- [ ] **Step 3: Write `scenario-manifest-spec.md` verbatim** (the validator checks a manifest against this shape)

```markdown
---
# Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
# SPDX-License-Identifier: [[SPDX_LICENSE]]
---

# Scenario Manifest Spec — [[PROJECT_NAME]]

A scenario manifest makes a run reproducible. `validate-scenario-manifest.sh`
checks that a manifest YAML carries the required sections below.

## Required top-level sections

- `scenario:` — id, title, owner, purpose, maturity, status, created, updated
- `boundary:` — geography/system, included, excluded
- `baseline:` — worldStateVersion, source, asOf, limitations
- `datasets:` — each with **id, source, version, asOf, confidence** (required), plus name, owner, license, transform, pathOrUri
- `assumptions:` — each with **confidence** and **sensitivity** (required), plus statement, rationale, source
- `models:` / `agents:` — id, name, owner, inputs, outputs, validation; agents declare `llmAllowed:`
- `outputs:` — each with audience, `publicationAllowed:`, `reviewRequired:`; if `publicationAllowed: true`, a `publication.approvalStatus` must be present
- `uncertainty:` — method, confidenceScale, sensitivityMethod, requiredDisclosure
- `provenance:` — **required**: gitCommit, runId, generatedAt, generatedBy, inputHash, outputHash
- `review:` / `publication:` — reviewers, gates, status; audience, redaction, approvalStatus

## Minimal skeleton

```yaml
schemaVersion: 1
scenario: { id: [[ID]], title: [[TITLE]], owner: [[OWNER]], maturity: [[LEVEL]], status: draft }
baseline: { worldStateVersion: [[VER]], source: [[SRC]], asOf: YYYY-MM-DD }
datasets: [ { id: d1, source: [[SRC]], version: [[VER]], asOf: YYYY-MM-DD, confidence: medium } ]
assumptions: [ { id: a1, statement: [[TEXT]], confidence: low, sensitivity: high } ]
outputs: [ { id: o1, audience: internal, publicationAllowed: false, reviewRequired: true } ]
uncertainty: { method: [[METHOD]], confidenceScale: [[SCALE]], requiredDisclosure: true }
provenance: { gitCommit: [[SHA]], runId: [[RUN]], generatedAt: [[TS]], generatedBy: [[WHO]], inputHash: [[H]], outputHash: [[H]] }
```
```

- [ ] **Step 4: Write the remaining seven templates** — each a tight tokenized skeleton with SPDX-in-frontmatter, a title `# <Name> — [[PROJECT_NAME]]`, and the bullet fields below. Create one file each:

  - `data-provenance.md` — for each dataset: id, name, source, owner, license, version, asOf, freshness, transform, confidence, pathOrUri. Guidance: "An unversioned dataset is not reproducible."
  - `model-registry.md` — for each model: id, name, owner, responsibility, inputs, outputs, source-of-truth, type (deterministic/probabilistic/LLM-assisted), validation method, known limitations, failure modes, human-review triggers, lastReviewed. Guidance: "A model without a registry is not governable. LLMs may assist; they are not source-of-truth for simulation outputs unless explicitly modeled, evaluated, and reviewed."
  - `agent-registry.md` — for each agent: id, name, responsibility, mode, inputs, outputs, validation, **llmAllowed**, human-review triggers, lastReviewed.
  - `run-log-spec.md` — append-only JSONL; minimum event fields: schemaVersion, eventId, timestamp, scenarioId, runId, actor, eventType, source, payload, inputRefs, outputRefs, validationStatus, correlationId. Guidance: "A simulation without a run log is not auditable. Prototypes use append-only JSONL; operational twins may need event sourcing + replay."
  - `uncertainty-policy.md` — disclose: high-sensitivity assumptions, low-confidence inputs, known model limitations, excluded variables, confidence scale, likely ranges (not fake precision), when human review is required, when an output cannot be published. Guidance: prefer "likely range X–Y; primary sensitivity Z; confidence medium" over single-point predictions.
  - `publication-policy.md` — audiences: public / restricted / internal / confidential. Require review before publishing: financial projections, regulatory interpretations, operational recommendations, healthcare/safety outputs, sensitive infrastructure/geospatial data, PII/behavioral data, civic-participation data, and any LLM-generated public explanation of model outputs. Maps to Gemini Trust + Purpose.
  - `security-boundaries.md` — public/private boundary, sensitive infrastructure & geospatial handling, access control, data egress, secrets. Required at maturity L5; recommended at L4. Maps to Gemini Security.

- [ ] **Step 5: Verify** — `bash platform/validators/validate-placeholders.sh .` exits 0 (the `[[TOKEN]]` and `YYYY-MM-DD` placeholders are template-legal); `find platform/templates/digital-twin -name '*.md' | wc -l` = 10.

---

### Task 3: `validate-twin-profile.sh` (TDD; mirror `validate-privacy-by-design.sh`)

**Files:** Create `platform/validators/validate-twin-profile.sh`; create fixtures under `platform/validators/test/fixtures/digital-twin/`; add a test class to `platform/validators/test/test_validators_integration.rb`.

- [ ] **Step 1: Write the fixtures** (mirror the privacy fixtures' style):
  - `clean-profile.md` — frontmatter with `maturity: digital-twin-prototype`, one `conformance` entry with `status: published`, `governingPrinciples` non-empty → expect exit 0.
  - `unfilled-profile.md` — empty `maturity:` / no conformance → expect exit 1.
  - `emerging-as-published.md` — a conformance entry citing `ISO 23247-5` with `status: published` (it is emerging) → expect exit 1 (overclaim guard).

- [ ] **Step 2: Write the failing test class** in `test_validators_integration.rb` (mirror `TestValidatePrivacyByDesign`):

```ruby
class TestValidateTwinProfile < Minitest::Test
  TWIN_FIXTURES_DIR = File.join(PLATFORM_DIR, "validators", "test", "fixtures", "digital-twin")
  FIXTURE_EXPECTATIONS = {
    "clean-profile.md"        => 0,
    "unfilled-profile.md"     => 1,
    "emerging-as-published.md"=> 1,
  }.freeze

  def test_runs_clean_against_harness_repo
    # module inactive → exit 0 (catalog-only; digital-twin not in harness.manifest.yaml)
    _o, _e, code = run_validator("validate-twin-profile.sh", "harness.manifest.yaml", ".")
    assert_equal 0, code
  end

  def test_every_fixture_has_expected_exit_in_scan_file_mode
    FIXTURE_EXPECTATIONS.each do |name, expected|
      _o, _e, code = run_validator("validate-twin-profile.sh", "--scan-file", File.join(TWIN_FIXTURES_DIR, name))
      assert_equal expected, code, "fixture #{name}"
    end
  end
end
```

- [ ] **Step 3: Run the test, verify it fails** — `ruby platform/validators/test/test_validators_integration.rb -n /TwinProfile/` → FAIL (script not found).

- [ ] **Step 4: Implement `validate-twin-profile.sh`** mirroring `validate-privacy-by-design.sh`'s structure: `--help`; `--scan-file <path>` mode (parse frontmatter; FAIL if `maturity` empty/missing, if no `conformance` entry, if `governingPrinciples` empty, or if a conformance entry marks a known-emerging standard — `ISO 23247-5`, `ISO 23247-6`, `ISO/IEC 30188` — as `status: published`); main mode (resolve manifest via `HarnessRegistry`, module-gate on `m["id"] == "digital-twin"` → exit 0 if inactive; else assert `docs/twin/twin-profile.md` exists and passes the `--scan-file` checks; WARN posture: advisory hits exit 0 unless `--block`). Bash 3.2 compatible. SPDX header.

- [ ] **Step 5: Run the test, verify it passes** — `ruby platform/validators/test/test_validators_integration.rb -n /TwinProfile/` → PASS. Also `shellcheck platform/validators/validate-twin-profile.sh` clean.

---

### Task 4: `validate-scenario-manifest.sh` (TDD; mirror Task 3)

**Files:** Create `platform/validators/validate-scenario-manifest.sh`; fixtures under `.../fixtures/digital-twin/`; test class in `test_validators_integration.rb`.

- [ ] **Step 1: Fixtures:**
  - `clean-manifest.yaml` — all required sections present (datasets w/ source+version+asOf+confidence; assumptions w/ confidence+sensitivity; provenance complete; an output with `publicationAllowed: false`) → expect 0.
  - `missing-provenance.yaml` — omit `provenance:` → expect 1.
  - `dataset-missing-version.yaml` — a dataset lacks `version`/`asOf`/`confidence` → expect 1.
  - `published-without-approval.yaml` — an output `publicationAllowed: true` with no `publication.approvalStatus` → expect 1.

- [ ] **Step 2: Write the failing test class** `TestValidateScenarioManifest` (same shape as Task 3 Step 2, with the four fixtures + a module-inactive clean run).

- [ ] **Step 3: Run, verify fail.**

- [ ] **Step 4: Implement `validate-scenario-manifest.sh`** — `--scan-file <manifest.yaml>` mode: FAIL if any required top-level section missing (`scenario`, `datasets`, `assumptions`, `outputs`, `uncertainty`, `provenance`), if a dataset lacks source/version/asOf/confidence, if an assumption lacks confidence/sensitivity, if provenance is missing, or if an output marked `publicationAllowed: true` lacks a publication approval. Main mode: module-gated (exit 0 if `digital-twin` inactive); WARN posture. Mirror the privacy validator's Ruby-heredoc YAML parsing. SPDX header; Bash 3.2; shellcheck clean.

- [ ] **Step 5: Run, verify pass; shellcheck clean.**

---

### Task 5: `harness-digital-twin` skill

**Files:** Create `platform/skills/harness-digital-twin/SKILL.md`

- [ ] **Step 1: Write `SKILL.md` verbatim** (mirror the `harness-onboarding` frontmatter shape)

```markdown
---
name: harness-digital-twin
description: "Use for tasks involving digital twins, simulation, scenarios, world state, run logs, model/agent registries, data provenance, geospatial/city/infrastructure models, AI-datacenter or operational twins, or scenario manifests. Enforces maturity honesty, world/scenario/run separation, provenance, uncertainty disclosure, and publication boundaries for projects governed by the management/digital-twin overlay."
license: Apache-2.0
compatibility: For any Agent Skills-compatible client. The target project should activate management/digital-twin and carry docs/twin/twin-profile.md.
metadata:
  harness-module: management/digital-twin
  format-version: "1.1"
---

> For human developers: this skill guides agents working on scenario-driven /
> digital-twin projects. It does not run simulations; it governs them.

---

## Role and Goal

Govern a digital-twin / scenario-runtime project so it is reproducible,
honest about maturity, and safe to publish. Do not let visualization substitute
for simulation; do not treat LLM output as simulation source-of-truth.

## Always do, in order

1. **Classify maturity** (model → shadow → prototype → operational → control-loop)
   and record it in `docs/twin/twin-profile.md`. Do not overclaim.
2. **Separate world / scenario / run state.** Never mutate canonical world state
   to test a scenario — branch it, run against the branch, log the run.
3. **Require source-data provenance** (version, asOf, confidence) — an unversioned
   dataset is not reproducible.
4. **Require a scenario manifest** carrying datasets, assumptions (confidence +
   sensitivity), models/agents, outputs, uncertainty, and provenance.
5. **Require a model/agent registry** — declare deterministic/probabilistic/
   LLM-assisted and whether LLM is allowed; LLMs are not source-of-truth.
6. **Require a run log** (append-only JSONL minimum).
7. **Require uncertainty disclosure** — prefer "likely range X–Y; sensitivity Z;
   confidence medium" over single-point predictions.
8. **Require a publication boundary + review gate** before any public or
   high-impact output (Gemini Trust + Purpose).

## Standards

Conform to the interoperability/digital-thread spine (ISO 23247, ISO/IEC 30173,
Asset Administration Shell, DTDL, W3C WoT, ISO 10303 STEP/AP242, QIF) and the
Gemini Principles. Cite published standards as normative, emerging as emerging.
```

- [ ] **Step 2: Verify** — `bash platform/validators/validate-skill-content.sh harness.manifest.yaml .` exits 0; `ls platform/skills/harness-digital-twin/` shows `SKILL.md`.

---

### Task 6: Sample composition

**Files:** Create `platform/compositions/digital-twin-prototype.yaml`; modify `platform/compositions/README.md`.

- [ ] **Step 1: Write the composition verbatim**

```yaml
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
# Starter composition for a scenario-driven digital-twin prototype. Activates the
# digital-twin overlay with privacy-by-design (civic/personal data) on a built-
# environment substrate (ISO 19650 IM) — the municipal / real-estate planning-twin
# stack. The catalog's second domain x cross-cutting x cross-cutting composition.
# References:
#   - platform/profiles/management/digital-twin/README.md
#   - platform/profiles/management/privacy-by-design/README.md
#   - platform/profiles/domains/aec-iso19650-im/README.md
#   - docs/requirements/PRD-0023-digital-twin-scenario-runtime-overlay.md
schemaVersion: 1
project:
  id: example-digital-twin-prototype
  name: Example Digital Twin Prototype
  maturity: prototype
  criticality: medium
modules:
  core:
    - kernel/base
  domains:
    - aec-iso19650-im
  management:
    - digital-twin
    - privacy-by-design
overrides:
  requiredArtifacts: []
  disabledValidations: []
```

- [ ] **Step 2: Add the README row** to `platform/compositions/README.md` — find the `aec-bim-project.yaml` row and insert after it:

```markdown
| [digital-twin-prototype.yaml](digital-twin-prototype.yaml) | digital-twin + privacy-by-design + ISO 19650 IM | Scenario-driven digital-twin / decision-support project (municipal, real-estate, datacenter, civic) |
```

- [ ] **Step 3: Verify** — `grep -c digital-twin-prototype platform/compositions/README.md` ≥ 1.

---

### Task 7: Discoverability propagation

**Files:** Modify `SUMMARY.md`, `README.md` (Module System table), `platform/skills/harness-onboarding/SKILL.md`, `platform/workflow/discovery-to-composition.md`.

- [ ] **Step 1: `SUMMARY.md`** — find the `* [Security Static Analysis](...)` line in the `### Management` section; insert after it:

```markdown
* [Digital Twin / Scenario Runtime](platform/profiles/management/digital-twin/README.md) — default-off overlay for scenario-driven twins; maturity-gated twin-profile + dual-spine standards anchor (interoperability + Gemini Principles)
```

- [ ] **Step 2: `README.md` Module System table** — in the **Management** row's backtick list, append `, `digital-twin`` before the cell's closing ` |`.

- [ ] **Step 3: `harness-onboarding/SKILL.md`** — find the `| `management/privacy-by-design` | ...` row; insert after it:

```markdown
| `management/digital-twin` | Project models real-world systems, runs scenarios, or publishes decision-support (municipal/real-estate/datacenter/civic twins) |
```

- [ ] **Step 4: `discovery-to-composition.md`** — find the `management/privacy-by-design` selection row; insert after it:

```markdown
| Models a real-world system / runs scenarios / publishes decision-support? | `management/digital-twin` (default-off; declare maturity in `docs/twin/twin-profile.md`) |
```

- [ ] **Step 5: Verify** — `grep -rl 'management/digital-twin\|digital-twin/README' SUMMARY.md README.md platform/skills/harness-onboarding/SKILL.md platform/workflow/discovery-to-composition.md` lists all four.

---

### Task 8: Catalog-count propagation (NOT diagrams, NOT HARNESS.md)

**Files:** `platform/reference/how-to-read.md`, `docs/architecture/diagrams.md` (diagram-1 labels only), `docs/_assets/cover-back.svg`, `README.md`, `platform/workflow/skills-and-agents.md`.

- [ ] **Step 1: Apply the count edits** per the "Count-site map" table above: modules_profiles 42→43, modules_all 51→52, validators 15→17, templates 74→84, skills 7→8. Use the exact regex tokens from `validate-catalog-counts.sh`'s ASSERTIONS array (re-read it first; it is the source of truth). **Do not change any diagram count (stays 13). Do not edit HARNESS.md.**

- [ ] **Step 2: Verify** — `bash platform/validators/validate-catalog-counts.sh .` exits 0. If it reports drift, it names the exact file/line/expected/actual — fix that site and re-run until green.

---

### Task 9: Distillation observation (PRD-0004 satisfier) + change-log

**Files:** Modify `docs/knowledge/shared-observations.md`, `docs/project/change-log.md`.

- [ ] **Step 1: shared-observations** — creating `module.yaml` fires the PRD-0004 distillation rule. Bump the Last-Updated line (preserve the running `Prior:` chain; prepend a 2026-06-10 Phase-2 note) and append an observation: the Phase-2 implementation evidence — that the maturity-gated overlay shipped catalog-only/predict-clean, the two module-gated WARN validators no-op on the harness's own CI, and the dual-spine anchor is now concrete in templates. Close with the standard "satisfies the PRD-0004 distillation rule fired by the new `platform/profiles/management/digital-twin/module.yaml`."

- [ ] **Step 2: change-log** — insert (newest-first, after the `---`) a `## 2026-06-10 — management/digital-twin overlay implemented (PRD-0023 Phase 2)` entry summarizing: module + 10 templates + 2 Half-enforced validators + skill + composition + discoverability + count propagation; diagram (FR-007) + HARNESS.md bump deferred to a maintainer follow-up; catalog-only.

- [ ] **Step 3: Verify** — `grep -n 'digital-twin' docs/project/change-log.md` shows the new entry near top.

---

### Task 10: Validate, run tests, commit, push, PR (no merge)

- [ ] **Step 1: Run the validator test suite** — `ruby platform/validators/test/test_validators_integration.rb` → all pass (incl. the two new test classes). `ruby platform/validators/test/test_harness_registry.rb` → pass.
- [ ] **Step 2: shellcheck** the two new validators → clean. **markdownlint** — `npx markdownlint-cli2` → 0 errors (watch MD004 `+`-line-start in the new templates/README/observation; MD056 in the README/template tables).
- [ ] **Step 3: Full validator suite** (all 17 now, incl. diff-mode vs `main`) — run the 15 from the Phase-1 plan's list **plus** `validate-twin-profile.sh harness.manifest.yaml .` and `validate-scenario-manifest.sh harness.manifest.yaml .`. All exit 0; the two new ones no-op (module inactive). `validate-catalog-counts.sh` and `validate-list-completeness.sh` green.
- [ ] **Step 4: Branch, stage, commit**

```bash
git checkout -b digital-twin-overlay-phase2
git add platform/profiles/management/digital-twin/ platform/templates/digital-twin/ \
        platform/validators/validate-twin-profile.sh platform/validators/validate-scenario-manifest.sh \
        platform/validators/test/ platform/skills/harness-digital-twin/ \
        platform/compositions/digital-twin-prototype.yaml platform/compositions/README.md \
        SUMMARY.md README.md platform/skills/harness-onboarding/SKILL.md \
        platform/workflow/discovery-to-composition.md platform/reference/how-to-read.md \
        docs/architecture/diagrams.md docs/_assets/cover-back.svg platform/workflow/skills-and-agents.md \
        docs/knowledge/shared-observations.md docs/project/change-log.md \
        docs/superpowers/plans/2026-06-10-digital-twin-overlay-phase2.md
git status --short   # confirm NO harness.manifest.yaml, NO HARNESS.md, NO docs/architecture diagram added
```

Commit message: `[digital-twin overlay] PRD-0023 Phase 2 — management/digital-twin module + templates + validators + skill + composition` with the Co-Authored-By trailer. **Do NOT stage** `docs/product/Digital-Twin-Seed.txt` or `docs/doc-watch-log.md`.

- [ ] **Step 5: Re-run the full suite + tests on the committed branch** (diff-mode vs `main`). Green → push + `gh pr create` (body: summary; note diagram FR-007 + HARNESS.md bump deferred to maintainer; catalog-only/predict-clean; full suite + tests green). **Stop — do not merge.**

---

## Self-Review

- **PRD-0023 coverage:** FR-001 module (T1) ✓; FR-002 ten templates (T2) ✓; FR-003 twin-profile validator (T3) ✓; FR-004 scenario-manifest validator (T4) ✓; FR-005 skill (T5) ✓; FR-006 composition (T6) ✓; **FR-007 diagram — DEFERRED to maintainer (documented)**; FR-008 discoverability (T7) ✓; FR-009 counts + full suite (T8/T10) ✓; FR-S01 distillation (T9) ✓.
- **Phase/scope:** catalog-only (no manifest edit); HARNESS.md untouched (module not repo-active; diagram deferred); validators module-gated (predict-clean). ✓
- **Placeholder scan:** templates use `[[TOKEN]]`/`YYYY-MM-DD` (placeholder-legal); validators TDD-spec'd against the privacy mirror (not literal 475-line bytes — they are CODE, built test-first). ✓
- **Count consistency:** modules 42→43/51→52, validators 15→17, skills 7→8, templates 74→84, diagrams unchanged-13 — consistent across the count-site map; `validate-catalog-counts.sh` is the gate. ✓
- **Number/name consistency:** `digital-twin` / `twin-profile.md` / `validate-twin-profile.sh` / `validate-scenario-manifest.sh` / `harness-digital-twin` / `digital-twin-prototype.yaml` spelled identically across tasks. ✓
