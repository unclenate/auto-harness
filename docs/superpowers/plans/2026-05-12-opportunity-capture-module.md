<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Opportunity Capture Module — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the `management/opportunity-capture` module to the harness, with templates, validators wired via existing infrastructure, dogfood adoption in auto-harness's own manifest, and a project-level policy file at `docs/opportunities/README.md`.

**Architecture:** New opt-in module parallel to `management/knowledge-capture`, declared in `harness.manifest.yaml`. Module governs a new top-level surface (`docs/opportunities/`) holding one structured-record file per candidate. Two companion rules (audit-trail floor + README→ADR) wired through the existing `validate-companions` validator with `humanReview` text covering the four substantive checks. No new validator code.

**Tech Stack:** Markdown + YAML only. Validators are bash. Reference modules: `platform/profiles/management/knowledge-capture/` (structural analog), `docs/knowledge/README.md` (auto-harness's prior adoption analog), `docs/adr/ADR-0002-knowledge-capture-structured-observations.md` (the locking-ADR precedent).

**Companion specs:**

- [PRD-0003](../../requirements/PRD-0003-opportunity-capture-module.md) — module spec, all 15 functional requirements
- [ADR-0004](../../adr/ADR-0004-opportunity-capture-record-structure.md) — locked record-structure choice

---

## File Structure (created/modified across the plan)

**Created:**

- `platform/profiles/management/opportunity-capture/module.yaml` — module manifest
- `platform/profiles/management/opportunity-capture/README.md` — module documentation (compiled fragment)
- `platform/templates/opportunity/README.md` — project-level policy template
- `platform/templates/opportunity/opp-template.md` — per-candidate record template
- `docs/opportunities/README.md` — auto-harness's adopted policy file

**Modified:**

- `harness.manifest.yaml` — adds `opportunity-capture` to `modules.management`
- `platform/templates/README.md` — documents new placeholder tokens
- `docs/project/change-log.md` — records the change

---

## Task 1: Create the module manifest

**Files:**

- Create: `platform/profiles/management/opportunity-capture/module.yaml`

- [ ] **Step 1: Create `platform/profiles/management/opportunity-capture/module.yaml` with the following content**

```yaml
id: opportunity-capture
type: management
version: 1.0.0
summary: "Forward-looking opportunity capture module. Provides docs/opportunities/ as a per-project surface for pre-PRD candidate records — one structured file per candidate (OPP-NNNN-slug.md) with explicit status, evidence-linkage to shared-observations.md, and a binding promotion contract (status=accepted requires a PRD in the same commit)."
dependsOn:
  - kernel/base
  - project-standard
conflictsWith: []
requiredArtifacts:
  - docs/opportunities/README.md
optionalArtifacts: []
sensitivePaths:
  - description: "Opportunity capture policies — the foundational record-structure choice (locked by ADR), Write Policy, status definitions, and companion-rule references"
    patterns:
      - "^docs/opportunities/README\\.md$"
companionRules:
  - description: "Edits to any opportunity record (OPP-NNNN-slug.md) require an audit-trail entry in the day's daily memory log or the project change-log. Floor rule for all candidate edits. humanReview verifies the substantive checks the regex layer cannot enforce: (a) status changes from `proposed` accompanied by a populated Disposition field with rationale, (b) status flipping to `accepted` accompanied by a PRD created or referenced in the same commit, (c) status flipping to `declined` or `superseded` accompanied by substantive rationale (not just a status-line edit)."
    triggerPaths:
      - "^docs/opportunities/OPP-"
    requiredAny:
      - "^memory/\\d{4}-\\d{2}-\\d{2}\\.md$"
      - "^docs/project/change-log\\.md$"
    humanReview: "Reviewers verify (a) appropriate Disposition rationale when status changed from proposed, (b) `accepted` status accompanied by a PRD created/referenced in the same commit, (c) `declined`/`superseded` status accompanied by substantive rationale rather than just a status-line edit."
  - description: "Changes to the project-level opportunity-capture policy (docs/opportunities/README.md) require an ADR. This is the governance floor for any structural change to how candidates are captured."
    triggerPaths:
      - "^docs/opportunities/README\\.md$"
    requiredAny:
      - "^docs/adr/ADR-"
    humanReview: "Reviewers verify the ADR explicitly addresses the structural change (not merely a tangential README update)."
validators:
  - validate-required-artifacts
  - validate-companions
reviewGates:
  - "The foundational record-structure choice is a one-way decision in practice. Reviewers treat ADRs changing it with extra scrutiny."
  - "Accepted candidates must spawn a real PRD in the same commit. An 'accepted' status without a PRD is a contract violation — block or fix in review."
  - "The Origin / Evidence field is the gap-closer between forward-looking ideas and backward-looking observations. A `thesis-only` marker without a stated reason undermines the entire module's purpose; reviewers push back."
agentAdapters:
  - platform/agents/base
compiledFragments:
  - platform/profiles/management/opportunity-capture/README.md
```

- [ ] **Step 2: Verify the module file structure is valid by inspection**

Run: `cat platform/profiles/management/opportunity-capture/module.yaml | head -20`
Expected: First 20 lines render cleanly; `id:`, `type:`, `version:`, `summary:` all present.

- [ ] **Step 3: Confirm validate-manifest still passes (no manifest changes yet)**

Run: `bash platform/validators/validate-manifest.sh harness.manifest.yaml`
Expected: Exit 0. The module file exists but isn't activated, so the manifest's current state is unchanged from a validator perspective.

---

## Task 2: Create the module README (compiled fragment)

**Files:**

- Create: `platform/profiles/management/opportunity-capture/README.md`

- [ ] **Step 1: Create `platform/profiles/management/opportunity-capture/README.md` with the following content**

```markdown
# Management Overlay: Opportunity Capture

This overlay adds a durable, reviewable, project-level surface for forward-looking
candidate records to any project that adopts it. Pre-PRD candidates — product
opportunities, strategic theses, "things we might pursue" — accumulate as
one-file-per-candidate records with explicit status, evidence-linkage to the
observation surface, and a binding promotion contract: accepting a candidate
requires spawning a real PRD in the same commit.

---

## What This Overlay Requires

One file in `docs/opportunities/`:

**`docs/opportunities/README.md`** — The project's opportunity-capture policies.
Declares the foundational Record Structure choice (locked by ADR), the adjustable
Write Policy, the status definitions and what each transition requires, and a
reference to the companion rules that enforce the audit-trail floor and the
PRD-spawning contract.

Per-candidate records (`OPP-NNNN-slug.md`) accumulate in the same directory as
contributors capture and explore opportunities.

---

## How This Overlay Fits With Other Modules

| Module | Relationship |
|--------|--------------|
| `core/kernel/base` | Required dependency — trust tier model applies to opportunity edits |
| `management/project-standard` | Required dependency — revision tracker is the audit trail when used |
| `management/knowledge-capture` | Soft dependency — the Origin / Evidence field links forward-looking candidates to backward-looking observations when grounded; both modules can be adopted independently |
| `management/product-lite` (PRDs) | Soft dependency — accepted candidates spawn PRDs; the PRD module governs the downstream artifact |
| All agent packs | Agents read the opportunity README on heartbeats to know how to contribute candidates and apply the Write Policy |

---

## Companion Rules

Two companion rules enforce the governance floor; `humanReview` text covers four
substantive checks the regex layer cannot enforce:

1. **Any edit to an OPP record** requires an audit-trail entry in the day's
   daily memory log or the project change-log. This is the floor.
   `humanReview` covers: (a) Disposition rationale when status changed from
   `proposed`, (b) PRD spawned in the same commit when status flipped to
   `accepted`, (c) substantive rationale (not a one-line status edit) for
   `declined` or `superseded` transitions.

2. **Changes to `docs/opportunities/README.md`** (the project's policy file)
   require an ADR. This is the foundational governance floor — changing the
   record structure silently would invalidate every past candidate's
   interpretation.

---

## Review Gates

Human review ensures the overlay's intent is preserved:

- The Record Structure choice is effectively one-way. Reviewers treat any ADR
  proposing a structural change with extra scrutiny — including verification
  that past candidates can be interpreted under the new structure or that a
  migration plan exists.
- Accepted candidates must spawn a PRD in the same commit. An `accepted`
  status without a PRD is a contract violation — block or fix in review.
- The Origin / Evidence field is the gap-closer. A `thesis-only` marker
  without a stated reason undermines the module's purpose; reviewers push back.

---

## Agent Behavior

Agents in opportunity-capture-enabled projects:

1. Read `docs/opportunities/README.md` on each heartbeat to pick up current
   policies (Write Policy, status definitions, escalation patterns).
2. Contribute candidates per the Write Policy. Under `heartbeat-only` (the
   recommended default), candidates are filed only during the Knowledge
   Contribution step of the agent's heartbeat, after dreaming has distilled
   their daily logs. This keeps signal high.
3. When filing a candidate, link the Origin / Evidence field to specific
   observations in `docs/knowledge/shared-observations.md` when grounded, or
   mark `thesis-only` with a stated reason when un-grounded.
4. Do not autonomously flip status to `accepted` — this is a human decision
   that binds a PRD commitment. Agents may draft Disposition rationale and
   stage a PRD for human review, but the status transition is human.

The `harness-onboarding` skill identifies whether a project should adopt
opportunity-capture during onboarding. It's an optional module — projects
add it when forward-looking idea durability is a real concern (e.g.,
projects with multiple contributors filing candidates over weeks/months,
or projects where ideas regularly get lost between sessions).

---

## When to Adopt This Module

Good fit for projects that:

- Capture product opportunities or strategic directions mid-session that
  warrant durable per-record memory beyond conversation history
- Have a real promotion path from idea → PRD → delivery and want the
  intermediate state to be a first-class artifact, not a backlog item
- Benefit from explicit evidence linkage between forward-looking ideas and
  the observations that grounded them

Less necessary for:

- Single-session throwaway work
- Projects with no PRD discipline (the promotion contract has no anchor)
- Contexts where idea durability is already handled by an external tool
  (Linear, Notion, etc.) and dual-capture would be noise

---

## References

- Module definition: `platform/profiles/management/opportunity-capture/module.yaml`
- Templates: `platform/templates/opportunity/`
- Locking ADR (auto-harness adoption): `docs/adr/ADR-0004-opportunity-capture-record-structure.md`
- Spec: `docs/requirements/PRD-0003-opportunity-capture-module.md`
- Related modules: `management/knowledge-capture/README.md` (the observation surface),
  `management/product-lite/README.md` (the PRD surface that accepted candidates spawn)
```

- [ ] **Step 2: Verify the README renders correctly**

Run: `wc -l platform/profiles/management/opportunity-capture/README.md`
Expected: Output reports a non-trivial line count (>100 lines).

---

## Task 3: Create the per-candidate template

**Files:**

- Create: `platform/templates/opportunity/opp-template.md`

- [ ] **Step 1: Create `platform/templates/opportunity/opp-template.md` with the following content**

```markdown
# OPP-NNNN — [[OPP_TITLE]]

**Status:** proposed
**Owner:** [[OPP_OWNER]]
**Created:** YYYY-MM-DD
**Last Updated:** YYYY-MM-DD
**Confidence:** [[OPP_CONFIDENCE]]

---

## Thesis

[[OPP_THESIS]]

## Origin / Evidence

[[OPP_ORIGIN_EVIDENCE]]

<!--
Cite the grounding for this candidate. Options:
- Observations: link to specific entries in docs/knowledge/shared-observations.md
- External signals: links, quotes, market evidence
- thesis-only: explicit marker with stated reason if there is no backward-looking
  evidence yet — and why pursuing anyway is defensible
-->

## Why Now

[[OPP_WHY_NOW]]

<!-- Timing signal. Use "n/a" if there is no timing signal beyond general interest. -->

## Risks / Open Questions

[[OPP_RISKS_OPEN_QUESTIONS]]

<!-- What would have to be true. What could kill it. What we don't yet know. -->

## Disposition

<!--
Empty while Status: proposed. Populated when status flips to exploring,
accepted, declined, or superseded. Captures rationale and any pointer
(e.g., to the spawned PRD or the superseding OPP).
-->

## Promotion

<!--
Empty until accepted. Then a link to PRD-NNNN. Format:
- See `docs/requirements/PRD-NNNN-slug.md`
-->
```

- [ ] **Step 2: Verify the template has the right placeholder tokens**

Run: `rg -o '\[\[[A-Z0-9_]+\]\]' platform/templates/opportunity/opp-template.md | sort -u`
Expected: Output lists `[[OPP_CONFIDENCE]]`, `[[OPP_ORIGIN_EVIDENCE]]`, `[[OPP_OWNER]]`, `[[OPP_RISKS_OPEN_QUESTIONS]]`, `[[OPP_THESIS]]`, `[[OPP_TITLE]]`, `[[OPP_WHY_NOW]]`.

---

## Task 4: Create the project-level policy template

**Files:**

- Create: `platform/templates/opportunity/README.md`

- [ ] **Step 1: Create `platform/templates/opportunity/README.md` with the following content**

```markdown
# [[PROJECT_NAME]] — Opportunity Capture

**Version:** 1.0 | **Owner:** [[OWNER]] | **Last Updated:** YYYY-MM-DD

This directory is the project's durable, reviewable surface for forward-looking
candidate records — pre-PRD opportunities filed by participants (human and agent).

One policy file plus one record per candidate:

- `README.md` — policies and structure for this project's opportunity capture (this file)
- `OPP-NNNN-slug.md` — one structured record per candidate

Agents read this README on each heartbeat to know how to behave when filing
candidates. Humans update this README to tune the Write Policy as the project
evolves.

---

## Record Structure (FOUNDATIONAL)

**Choice:** Structured Record
**Locked:** YYYY-MM-DD via [[LOCKING_ADR]]

Per-candidate records (`OPP-NNNN-slug.md`) MUST follow this structure. Changes
to this choice require an ADR because the structure shapes companion-rule
enforcement, reviewer verification, and the promotion contract.

Each record includes:

- **Metadata block:** `Status` (proposed | exploring | accepted | declined | superseded), `Owner`, `Created`, `Last Updated`, `Confidence` (low | medium | high)
- **Thesis:** One to three sentences — what the opportunity is, in plain language
- **Origin / Evidence:** Links to observations (docs/knowledge/shared-observations.md), external signals, or an explicit `thesis-only` marker with stated reason
- **Why Now:** Timing signal or `n/a`
- **Risks / Open Questions:** What would have to be true; what could kill it
- **Disposition:** Empty while proposed; populated on status change with rationale
- **Promotion:** Empty until accepted; then a link to the spawned PRD-NNNN

See the locking ADR for the rationale and rejected alternatives. The
per-candidate template is at `platform/templates/opportunity/opp-template.md`.

---

## Write Policy (ADJUSTABLE)

**Current mode:** [[WRITE_POLICY]]
**Last changed:** YYYY-MM-DD (initial)
**Rationale:** [[WRITE_POLICY_RATIONALE]]

Options available:

- **autonomous** — Any agent may file a new candidate at any time during normal
  work or heartbeats. Fastest capture; highest noise risk.
- **heartbeat-only** — Agents may only file candidates during the Knowledge
  Contribution step of their heartbeat, after dreaming has distilled their
  daily logs. Paced and reflective. Recommended default.
- **draft-to-promote** — Agents stage candidates in their own daily memory;
  a human reviewer promotes them to `docs/opportunities/`. Highest quality;
  requires active curation.

Change this value when the signal-to-noise ratio warrants it. Note the change
and its rationale in the metadata above.

---

## Status Definitions and Transition Requirements

| Status | What it means | Required when transitioning into this state |
|--------|--------------|-----|
| `proposed` | Newly captured candidate; no active investigation | Audit-trail entry on file creation (companion rule floor) |
| `exploring` | Owner is actively investigating or weighing it | Disposition field populated with current thinking |
| `accepted` | Decision to pursue; PRD has been or will be created in the same commit | **PRD file created/referenced in same commit**; Promotion field populated; Disposition captures rationale for acceptance |
| `declined` | Decision not to pursue | Substantive rationale in Disposition (not a one-line "no") |
| `superseded` | Merged into / replaced by another candidate | Pointer to superseding OPP-NNNN in Disposition |

The companion rule layer enforces audit-trail presence on any OPP edit. The
`humanReview` text on the companion rule covers what the regex cannot — that
the rationale is substantive, that `accepted` is accompanied by a real PRD,
that `declined`/`superseded` aren't drive-by status flips.

---

## References

- Module definition: `platform/profiles/management/opportunity-capture/module.yaml`
- Foundational choice: [[LOCKING_ADR]]
- Per-candidate template: `platform/templates/opportunity/opp-template.md`
- Related modules: `management/knowledge-capture` (observations the Origin /
  Evidence field links to), `management/product-lite` (the PRD module that
  accepted candidates spawn)

---

**Document Owner:** [[OWNER]]
```

- [ ] **Step 2: Verify placeholder tokens are all declared**

Run: `rg -o '\[\[[A-Z0-9_]+\]\]' platform/templates/opportunity/README.md | sort -u`
Expected: Output lists `[[LOCKING_ADR]]`, `[[OWNER]]`, `[[PROJECT_NAME]]`, `[[WRITE_POLICY]]`, `[[WRITE_POLICY_RATIONALE]]`.

---

## Task 5: Document new placeholders in templates reference

**Files:**

- Modify: `platform/templates/README.md`

- [ ] **Step 1: Identify which placeholders are new (not already in `platform/templates/README.md`)**

Run: `rg -o '\[\[[A-Z0-9_]+\]\]' platform/templates/opportunity/ | sort -u`
Expected: A combined list of all OPP placeholders.

Run: `rg -c '\[\[OPP_' platform/templates/README.md`
Expected: 0 (no OPP_* tokens documented yet).

Run: `rg -c '\[\[WRITE_POLICY\]\]' platform/templates/README.md`
Expected: Either 0 (token not yet documented) or 1+ (already there from prior templates).

- [ ] **Step 2: Append new placeholder rows to `platform/templates/README.md`**

Open `platform/templates/README.md` and find the "Common Placeholder Reference" table. Append the following rows to that table (immediately before the next markdown section):

```markdown
| `[[OPP_TITLE]]` | Opportunity template | Title of the candidate (e.g., `Exportable governance contract for runtime harnesses`) |
| `[[OPP_OWNER]]` | Opportunity template | GitHub handle accountable for moving the candidate through its lifecycle |
| `[[OPP_CONFIDENCE]]` | Opportunity template | `low`, `medium`, or `high` |
| `[[OPP_THESIS]]` | Opportunity template | One to three sentences: what the opportunity is, in plain language |
| `[[OPP_ORIGIN_EVIDENCE]]` | Opportunity template | Links to observations, external signals, or a `thesis-only` marker with stated reason |
| `[[OPP_WHY_NOW]]` | Opportunity template | Timing signal or `n/a` |
| `[[OPP_RISKS_OPEN_QUESTIONS]]` | Opportunity template | What would have to be true; what could kill it |
| `[[LOCKING_ADR]]` | Knowledge & opportunity README templates | The ADR that locks the foundational structural choice (e.g., `docs/adr/ADR-0004-opportunity-capture-record-structure.md`) |
| `[[WRITE_POLICY]]` | Knowledge & opportunity README templates | Current write-policy mode: `autonomous`, `heartbeat-only`, or `draft-to-promote` |
| `[[WRITE_POLICY_RATIONALE]]` | Knowledge & opportunity README templates | One-paragraph rationale for the current write-policy choice |
```

Note: `[[LOCKING_ADR]]`, `[[WRITE_POLICY]]`, and `[[WRITE_POLICY_RATIONALE]]` may already be in use by `platform/templates/knowledge/README.md` without being documented in this reference. Adding them now backfills that gap.

- [ ] **Step 3: Confirm no `[[...]]` tokens introduced in templates are missing from the reference**

Run:

```bash
rg -o '\[\[[A-Z0-9_]+\]\]' platform/templates/opportunity/ | sort -u | while read tok; do
  grep -q "$tok" platform/templates/README.md || echo "MISSING: $tok"
done
```

Expected: No "MISSING:" output.

---

## Task 6: Activate the module (red state) and observe required-artifacts failure

**Files:**

- Modify: `harness.manifest.yaml`

- [ ] **Step 1: Add `opportunity-capture` to `modules.management` in `harness.manifest.yaml`**

Current state (read first to confirm):

```yaml
modules:
  core:
    - kernel/base
  delivery:
    - internal-platform
  management:
    - project-standard
    - product-lite
    - knowledge-capture
  agents:
    - base
    - generic-llm
    - openclaw
```

Add `opportunity-capture` to the `management` list. Result:

```yaml
modules:
  core:
    - kernel/base
  delivery:
    - internal-platform
  management:
    - project-standard
    - product-lite
    - knowledge-capture
    - opportunity-capture
  agents:
    - base
    - generic-llm
    - openclaw
```

- [ ] **Step 2: Run validate-manifest — should PASS**

Run: `bash platform/validators/validate-manifest.sh harness.manifest.yaml`
Expected: Exit 0. The module is declared and its `module.yaml` exists.

- [ ] **Step 3: Run validate-module-graph — should PASS**

Run: `bash platform/validators/validate-module-graph.sh harness.manifest.yaml`
Expected: Exit 0. Dependencies (`kernel/base`, `project-standard`) are present in the manifest.

- [ ] **Step 4: Run validate-required-artifacts — should FAIL**

Run: `bash platform/validators/validate-required-artifacts.sh harness.manifest.yaml .`
Expected: Non-zero exit. Error message identifies `docs/opportunities/README.md` as a missing required artifact. This is the "red" state — it confirms the manifest is wired and the validator can see the requirement.

If the validator does NOT fail on a missing `docs/opportunities/README.md`, stop and investigate: either the module.yaml's `requiredArtifacts` declaration is wrong, or the manifest didn't pick up the module activation.

---

## Task 7: Populate the adopted policy file (green state)

**Files:**

- Create: `docs/opportunities/README.md`

- [ ] **Step 1: Create `docs/opportunities/README.md` with auto-harness's specifics**

The file is the template at `platform/templates/opportunity/README.md` with placeholders filled. Use this content directly:

```markdown
# auto-harness — Opportunity Capture

**Version:** 1.0 | **Owner:** @unclenate | **Last Updated:** 2026-05-12

This directory is the auto-harness project's durable, reviewable surface for
forward-looking candidate records — pre-PRD opportunities filed by participants
(human and agent).

One policy file plus one record per candidate:

- `README.md` — policies and structure for this project's opportunity capture (this file)
- `OPP-NNNN-slug.md` — one structured record per candidate

Agents read this README on each heartbeat to know how to behave when filing
candidates. Humans update this README to tune the Write Policy as the project
evolves.

---

## Record Structure (FOUNDATIONAL)

**Choice:** Structured Record
**Locked:** 2026-05-12 via ADR-0004

Per-candidate records (`OPP-NNNN-slug.md`) MUST follow this structure. Changes
to this choice require an ADR because the structure shapes companion-rule
enforcement, reviewer verification, and the promotion contract.

Each record includes:

- **Metadata block:** `Status` (proposed | exploring | accepted | declined | superseded), `Owner`, `Created`, `Last Updated`, `Confidence` (low | medium | high)
- **Thesis:** One to three sentences — what the opportunity is, in plain language
- **Origin / Evidence:** Links to observations (docs/knowledge/shared-observations.md), external signals, or an explicit `thesis-only` marker with stated reason
- **Why Now:** Timing signal or `n/a`
- **Risks / Open Questions:** What would have to be true; what could kill it
- **Disposition:** Empty while proposed; populated on status change with rationale
- **Promotion:** Empty until accepted; then a link to the spawned PRD-NNNN

See ADR-0004 for the rationale and rejected alternatives. The per-candidate
template is at `platform/templates/opportunity/opp-template.md`.

---

## Write Policy (ADJUSTABLE)

**Current mode:** heartbeat-only
**Last changed:** 2026-05-12 (initial)
**Rationale:** We're early. Signal over volume. Heartbeat-only plays nicely
with token-exhaustion concerns — if the heartbeat fails, no rogue candidates
get filed. Also enforces reflection: agents file candidates only after
dreaming has distilled their daily logs, so entries reflect considered
judgment rather than in-the-moment reactions. Matches the policy choice made
for knowledge-capture (see docs/knowledge/README.md § Write Policy).

Options available:

- **autonomous** — any agent files a candidate anytime (fast capture, noise risk)
- **heartbeat-only** — agents file only during Knowledge Contribution step after dreaming (current)
- **draft-to-promote** — agents stage in memory, humans promote to docs/opportunities/ (highest quality, slowest)

Adjust this value when signal-to-noise conditions warrant it. Log the change
and its rationale.

---

## Status Definitions and Transition Requirements

| Status | What it means | Required when transitioning into this state |
|--------|--------------|-----|
| `proposed` | Newly captured candidate; no active investigation | Audit-trail entry on file creation (companion rule floor) |
| `exploring` | Owner is actively investigating or weighing it | Disposition field populated with current thinking |
| `accepted` | Decision to pursue; PRD has been or will be created in the same commit | **PRD file created/referenced in same commit**; Promotion field populated; Disposition captures rationale for acceptance |
| `declined` | Decision not to pursue | Substantive rationale in Disposition (not a one-line "no") |
| `superseded` | Merged into / replaced by another candidate | Pointer to superseding OPP-NNNN in Disposition |

The companion rule layer enforces audit-trail presence on any OPP edit. The
`humanReview` text on the companion rule covers what the regex cannot — that
the rationale is substantive, that `accepted` is accompanied by a real PRD,
that `declined`/`superseded` aren't drive-by status flips.

---

## References

- Module definition: `platform/profiles/management/opportunity-capture/module.yaml`
- Foundational choice: `docs/adr/ADR-0004-opportunity-capture-record-structure.md`
- Per-candidate template: `platform/templates/opportunity/opp-template.md`
- Spec: `docs/requirements/PRD-0003-opportunity-capture-module.md`
- Related modules: `management/knowledge-capture` (observations the Origin /
  Evidence field links to), `management/product-lite` (the PRD module that
  accepted candidates spawn)

---

**Document Owner:** @unclenate
```

- [ ] **Step 2: Run validate-required-artifacts — should now PASS**

Run: `bash platform/validators/validate-required-artifacts.sh harness.manifest.yaml .`
Expected: Exit 0. The required artifact is now present.

- [ ] **Step 3: Run validate-placeholders — should PASS**

Run: `bash platform/validators/validate-placeholders.sh harness.manifest.yaml .`
Expected: Exit 0. No `[[PLACEHOLDER_NAME]]` tokens remain in the new files. (Templates are excluded from this check by validator design; only adopted artifacts under `docs/` are scanned.)

If validate-placeholders fails: search for any `[[...]]` tokens still in `docs/opportunities/README.md` — those should all have been filled in Step 1. Templates under `platform/templates/opportunity/` are expected to retain their placeholders and should be excluded by the validator.

---

## Task 8: Record the change in the project change-log

**Files:**

- Modify: `docs/project/change-log.md`

- [ ] **Step 1: Add a new row to the `## Log` table in `docs/project/change-log.md`**

Insert the following row directly under the table header (above the existing 2026-05-09 row), preserving the existing row format:

```markdown
| 2026-05-12 | Scope | Added `management/opportunity-capture` module: new opt-in surface (`docs/opportunities/`) for pre-PRD candidate records with status (proposed | exploring | accepted | declined | superseded), evidence linkage to `docs/knowledge/shared-observations.md`, and a binding promotion contract (status=accepted requires PRD in same commit). Two companion rules wired via existing validators; no new validator code. auto-harness adopts the module in its own manifest. | A session-level analysis surfaced the gap between forward-looking ideas and backward-looking observations: the harness had no native surface for pre-PRD candidates, so product-shaped insights died in conversation history. Closes the gap at the explicit evidence link rather than by merging surfaces. | @unclenate | PRD-0003, ADR-0004 |
```

- [ ] **Step 2: Verify the change-log row reads correctly**

Run: `head -15 docs/project/change-log.md`
Expected: The new 2026-05-12 row appears as the topmost data row in the log table, with PRD-0003 and ADR-0004 referenced in the ADR/PRD column.

---

## Task 9: Run the full validator chain and confirm green

**Files:** (no edits — validator run only)

- [ ] **Step 1: Run the full validator chain in order**

```bash
PLATFORM=platform
bash $PLATFORM/validators/validate-manifest.sh harness.manifest.yaml
bash $PLATFORM/validators/validate-module-graph.sh harness.manifest.yaml
bash $PLATFORM/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash $PLATFORM/validators/validate-companions.sh harness.manifest.yaml .
bash $PLATFORM/validators/validate-placeholders.sh harness.manifest.yaml .
```

Expected: All five exit 0.

- [ ] **Step 2: If validate-companions fails, diagnose**

The most likely failure is that the change-log row in Task 8 didn't land in the right place, or the row format isn't recognized as a "trigger satisfied" by the validator. Check:

- Is the file `docs/project/change-log.md` modified in the working tree? (`git status`)
- Does the new row contain the date `2026-05-12`?
- Are the companion rule patterns in `module.yaml` correctly anchored (`^memory/...` or `^docs/project/change-log\.md$`)?

The companion-rule trigger for this commit is the creation of `docs/opportunities/README.md` (which matches the sensitive-path pattern). The required companion is either a memory file dated today OR a change-log edit. The change-log edit in Task 8 satisfies the rule.

- [ ] **Step 3: Confirm git status reflects the expected file changes**

Run: `git status --short`
Expected output (order may vary):

```text
 M docs/project/change-log.md
 M harness.manifest.yaml
 M platform/templates/README.md
?? docs/opportunities/
?? platform/profiles/management/opportunity-capture/
?? platform/templates/opportunity/
```

---

## Task 10: Commit

**Files:** (no edits — git commit only)

- [ ] **Step 1: Stage exactly the files involved in this change**

```bash
git add docs/opportunities/ \
        docs/project/change-log.md \
        docs/requirements/PRD-0003-opportunity-capture-module.md \
        docs/adr/ADR-0004-opportunity-capture-record-structure.md \
        harness.manifest.yaml \
        platform/profiles/management/opportunity-capture/ \
        platform/templates/opportunity/ \
        platform/templates/README.md \
        docs/superpowers/plans/2026-05-12-opportunity-capture-module.md \
        .placeholder-ignore
```

Note: The PRD and ADR files were created in the prior session; they're staged here so they land alongside the module adoption that depends on them.

- [ ] **Step 2: Verify the staged set is correct**

Run: `git diff --cached --stat`
Expected: Shows all the files listed in Step 1, no unrelated paths.

- [ ] **Step 3: Commit with conventional-commits message referencing both governance records**

```bash
git commit -m "$(cat <<'EOF'
feat(management): add opportunity-capture module for forward-looking candidate records

New opt-in module parallel to knowledge-capture. Adds docs/opportunities/ as
a per-project surface for pre-PRD candidate records — one structured file
per candidate with explicit status (proposed | exploring | accepted |
declined | superseded), evidence linkage to docs/knowledge/shared-observations.md,
and a binding promotion contract: accepting a candidate requires spawning a
PRD in the same commit.

Two companion rules wired through the existing validate-companions validator
with humanReview text covering the four substantive checks; no new validator
code.

auto-harness adopts the module in its own manifest (dogfooding). ADR-0004
locks the foundational record-structure choice, parallel to ADR-0002 for
knowledge-capture's observation structure.

Spec: PRD-0003
Lock: ADR-0004

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

- [ ] **Step 4: Confirm the commit landed**

Run: `git log --oneline -3`
Expected: Top line shows the new commit; the message references PRD-0003 and ADR-0004.

- [ ] **Step 5: Re-run the validator chain post-commit as a final smoke check**

Run the same five validators from Task 9 Step 1. All should still exit 0.

---

## Task 11 (optional, follow-up): Draft OPP-0001 — the Hive analysis

**This task is the original user ask "draft the idea" that triggered this whole design. It is optional within this plan — the module is fully functional without OPP-0001 — but it serves as the canonical first use that validates the module shape end-to-end.**

**Prerequisite:** This task should be a separate commit AFTER Task 10 lands, not bundled with it. Reason: the module commit demonstrates the surface exists; OPP-0001 demonstrates the surface is *used*. Two distinct concerns.

**Files:**

- Create: `docs/knowledge/shared-observations.md` (append a new observation, do not overwrite existing)
- Create: `docs/opportunities/OPP-0001-exportable-governance-contract-for-runtime-harnesses.md`

- [ ] **Step 1: Append the backward-looking observation to `docs/knowledge/shared-observations.md`**

Append (do NOT overwrite) the following structured observation to the bottom of the file, under the existing `## Observations` section:

```markdown
### Two harness genres exist in the AI-coding ecosystem; auto-harness is unambiguously the governance-harness genre

- **Context:** Reviewing adenhq/hive (YC-backed multi-agent runtime harness) to determine whether auto-harness should integrate with, absorb, or remain separate from it. Hive is a runtime-harness (DAG execution, state recovery, MCP tools, dashboard for agents doing business work). auto-harness is a governance-harness (trust tiers, lifecycle gates, PRD/ADR templates governing AI-assisted human coding work).
- **Observation:** The word "harness" is doing double duty in this space: runtime-harness (Hive, LangGraph, CrewAI) ≠ governance-harness (auto-harness). Both genres exist; both call themselves "harness." Hive's "evolve graph on failure" loop is exactly the kind of self-modifying agent behavior that benefits from human-approval gates and audit trails — the governance primitives auto-harness already encodes (trust tiers, lifecycle stages, companion rules, validators).
- **Implication:** auto-harness should not absorb Hive (different layer, scope bloat, license/cadence coupling) and should not integrate tightly (couples to one runtime's product direction). The latent product opportunity is to define an exportable governance contract — a consumable schema/skill/protocol that any runtime harness (Hive, LangGraph, CrewAI, custom) can adopt to gate state transitions and self-modifications on human approval, with audit trails compatible with auto-harness's lifecycle artifacts. This keeps auto-harness composable with the runtime ecosystem rather than betting on one runtime.
- **Confidence:** medium — the genre distinction is high-confidence; the "exportable contract" opportunity is medium-confidence and warrants validation by reading Hive's actual state-machine and self-modification entry points before committing.
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-12
```

- [ ] **Step 2: Create the forward-looking candidate file**

Create `docs/opportunities/OPP-0001-exportable-governance-contract-for-runtime-harnesses.md` with the following content:

```markdown
# OPP-0001 — Exportable Governance Contract for Runtime Harnesses

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-12
**Last Updated:** 2026-05-12
**Confidence:** medium

---

## Thesis

Define an exportable governance contract — a consumable schema, skill, or protocol — that any AI-agent runtime harness (Hive, LangGraph, CrewAI, custom) can adopt to gate state transitions and self-modifications on human approval, with audit trails compatible with auto-harness's lifecycle artifacts. The contract is auto-harness-flavored governance, decoupled from auto-harness's specific module surface, so the runtime ecosystem can compose with it rather than choosing between integrating tightly or building parallel governance.

## Origin / Evidence

- **Observation:** `docs/knowledge/shared-observations.md` — "Two harness genres exist in the AI-coding ecosystem; auto-harness is unambiguously the governance-harness genre" (architectural severity, 2026-05-12)
- **External signal:** adenhq/hive README and architecture description (Y Combinator-backed multi-agent runtime harness; "evolve graph on failure" is a self-modifying agent behavior that explicitly lacks human-approval gating in the current product surface)
- **Internal precedent:** auto-harness already encodes trust tiers, lifecycle stages, companion rules, and validators. Those primitives are repo-internal; nothing currently makes them consumable by an external runtime.

## Why Now

The runtime-harness category is consolidating around production AI workloads (Hive, LangGraph, CrewAI all currently scaling). They are all introducing self-modification behaviors (graph evolution, self-healing, autonomous task generation) without standard governance contracts. Defining the contract now lets auto-harness occupy the governance-layer position before runtime harnesses build proprietary equivalents or before "governance" becomes a feature of each runtime rather than a portable contract.

## Risks / Open Questions

- Is the contract substantial enough to be valuable, or thin enough that runtime harnesses just inline equivalent checks? Validation requires reading Hive's actual state-machine and self-modification entry points before committing to the contract shape.
- Does the contract need to be enforceable (cryptographic, MCP-shaped tool gating) or is it sufficient for it to be declarative (a YAML/JSON schema that runtime harnesses voluntarily comply with)? Two very different scopes.
- Adoption is the gating question. Even if the contract is well-designed, a contract no runtime harness adopts is dead. Initial validation should test with one runtime harness (likely Hive given its observability and self-modification behaviors) before generalizing.
- Auto-harness's existing module/manifest/validator surface is markdown-and-YAML-heavy. A "consumable contract" for runtime harnesses likely needs a different shape (programmatic API, MCP tools, protocol spec) than auto-harness currently produces. Building the contract may require expanding auto-harness's technical surface area, with its own scope tradeoffs.

## Disposition

<!-- Empty: status is proposed -->

## Promotion

<!-- Empty: not yet accepted -->
```

- [ ] **Step 3: Run the validator chain — should PASS**

```bash
PLATFORM=platform
bash $PLATFORM/validators/validate-manifest.sh harness.manifest.yaml
bash $PLATFORM/validators/validate-module-graph.sh harness.manifest.yaml
bash $PLATFORM/validators/validate-required-artifacts.sh harness.manifest.yaml .
bash $PLATFORM/validators/validate-companions.sh harness.manifest.yaml .
bash $PLATFORM/validators/validate-placeholders.sh harness.manifest.yaml .
```

Expected: All five exit 0. The companion rule for OPP edits requires an audit-trail entry; the change is exercising the companion-rule layer for the first time and may surface that we also need to add a `memory/2026-05-12.md` daily-memory entry. If `validate-companions` fails for that reason, create a stub `memory/2026-05-12.md` referencing OPP-0001 and the shared-observation entry, then re-run.

- [ ] **Step 4: Commit OPP-0001 separately from the module commit**

```bash
git add docs/knowledge/shared-observations.md \
        docs/opportunities/OPP-0001-exportable-governance-contract-for-runtime-harnesses.md \
        memory/2026-05-12.md  # only if Step 3 required creating it
git commit -m "$(cat <<'EOF'
feat(opportunities): file OPP-0001 — exportable governance contract for runtime harnesses

First candidate filed under the new opportunity-capture module. Closes the
gap between forward-looking idea and backward-looking observation: the
candidate's Origin / Evidence field cites a structured observation in
shared-observations.md from the same session.

Status: proposed. Confidence: medium. Next step is owner-driven exploration
(read Hive's state-machine and self-modification entry points to validate
whether the contract shape is substantial enough to pursue).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Self-Review (run after writing the plan; results documented below)

**Spec coverage check:** Walked each PRD-0003 functional requirement; all 15 map to tasks in this plan. FR-001 → Task 1. FR-002, FR-003, FR-004, FR-005, FR-006 → all in Task 1 (`module.yaml` declares them). FR-007 → Task 3. FR-008 → Task 4. FR-009 → Task 6. FR-010 → Task 7. FR-011 → already-written in the spec phase (`docs/adr/ADR-0004-opportunity-capture-record-structure.md`); referenced in Task 10's git-add list. FR-012 → Task 8. FR-013 → Task 5. FR-014 → Task 9 (validator chain). FR-015 (Should Have, demonstrate shape) → Task 11.

**Placeholder scan:** No "TBD", "TODO", "fill in details", "similar to Task N" in the plan body. Code blocks are complete content, not stubs.

**Type consistency check:** Status enum (`proposed | exploring | accepted | declined | superseded`) is identical across `module.yaml`, the per-candidate template, the policy README template, and the auto-harness adopted README. Field names (`Status`, `Owner`, `Created`, `Last Updated`, `Confidence`, `Thesis`, `Origin / Evidence`, `Why Now`, `Risks / Open Questions`, `Disposition`, `Promotion`) match exactly between the per-candidate template (Task 3) and the policy README's structure declaration (Task 4 and Task 7).

**One spec-vs-plan deviation noted:** PRD-0003 FR-011 specifies ADR-0004 creation. The ADR was already created in the spec-writing phase (this session) and is on disk uncommitted. The plan does not re-create it; it stages it in Task 10's git-add list. If the plan is executed in a fresh session where ADR-0004 doesn't exist, the executor must first read the spec phase output or re-create the ADR per its written content. (Mitigation: the ADR file is committed alongside the module in Task 10, so once Task 10 lands, this deviation no longer matters.)
