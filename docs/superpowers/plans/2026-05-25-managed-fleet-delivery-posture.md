# `delivery/managed-fleet` Posture — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a fifth auto-harness delivery posture, `delivery/managed-fleet`, for teams that operate configuration managing a live host fleet, and adopt it in the `the-IaC-fleet-repo` consumer.

**Architecture:** A new `module.yaml` profile + compiled README, three `docs/ops/` templates, and same-commit catalog propagation across 5 docs (README, SUMMARY, discovery-to-composition, harness-onboarding SKILL, templates/README). Recorded via ADR-0015 + change-log. The consumer (`the-IaC-fleet-repo`) then flips its manifest and creates the three artifacts. Validation is by the existing shell validators — there is no unit-test framework; "tests" are validator runs with expected pass/fail.

**Tech Stack:** YAML profiles, Markdown templates/docs, Bash validators (`validate-module-graph.sh`, `validate-required-artifacts.sh`, `validate-companions.sh`, `validate-catalog-counts.sh`, `validate-placeholders.sh`), Ruby 3.0+.

**Working location:** auto-harness repo, mounted at `.harness/`, on branch `feature/managed-fleet-delivery` (already created; spec committed as `6707f53`). Paths below are relative to the auto-harness repo root (`.harness/`) **except Task 7**, which operates in the `the-IaC-fleet-repo` parent repo. The consumer reads the submodule working tree directly, so adoption is testable before the auto-harness branch merges.

**Spec:** `docs/superpowers/specs/2026-05-25-managed-fleet-delivery-posture-design.md`

---

### Task 1: Create the `managed-fleet` module profile

**Files:**
- Create: `platform/profiles/delivery/managed-fleet/module.yaml`

- [ ] **Step 1: Write the module.yaml**

Create `platform/profiles/delivery/managed-fleet/module.yaml`:

```yaml
# Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
# SPDX-License-Identifier: MIT OR Apache-2.0
id: managed-fleet
type: delivery
version: 1.0.0
summary: >
  Delivery posture for a team that OPERATES configuration managing a live fleet
  of hosts (or hosting estate) — real production blast radius, but no external
  app or distributable of its own. Sits between internal-platform (too lean: no
  operational artifacts) and production-saas (assumes a served product whose
  release/rollback you own, not host config you apply). Carry exactly one
  delivery posture; see README for the single-posture expectation.
dependsOn:
  - kernel/base
conflictsWith:
  - prototype
requiredArtifacts:
  - docs/ops/fleet-inventory.md
  - docs/ops/change-control.md
  - docs/ops/config-rollback.md
optionalArtifacts:
  - docs/architecture/overview.md
  - docs/security/risk-register.md
sensitivePaths:
  - description: Fleet topology — which hosts exist and what role each plays
    patterns:
      - '^inventory/.*/hosts\.ya?ml$'
      - '^inventory/.*/hosts\.ini$'
      - '^host_vars/'
companionRules:
  - description: >
      Fleet-topology changes (adding/removing hosts, changing a host's role)
      must update the fleet inventory or be recorded in change-control — the
      live fleet's shape is changing, not just a role's internals.
    triggerPaths:
      - '^inventory/.*/hosts\.ya?ml$'
      - '^inventory/.*/hosts\.ini$'
      - '^host_vars/'
    requiredAny:
      - '^docs/ops/fleet-inventory\.md$'
      - '^docs/ops/change-control\.md$'
      - '^docs/adr/ADR-'
    humanReview: >
      Reviewers verify the topology change is reflected in the fleet record and
      has a stated maintenance window and rollback path.
validators:
  - validate-required-artifacts
  - validate-companions
reviewGates:
  - A change to the live fleet's topology requires a named maintenance window and a stated rollback path.
  - Applying configuration to production hosts is a human-directed action; agents may prepare changes (dry-run, diff) but must not apply them.
  - A managed-fleet project handling real or client data (criticality >= medium) is strongly expected to carry docs/security/risk-register.md even though it is optional here.
agentAdapters:
  - platform/agents/base
compiledFragments:
  - platform/profiles/delivery/managed-fleet/README.md
```

- [ ] **Step 2: Verify the module parses and graphs cleanly**

Run from a scratch manifest to prove the module loads. Create a throwaway test manifest:

```bash
cat > /tmp/mf-test.manifest.yaml <<'EOF'
schemaVersion: 1
project: { id: mf-test, name: MF Test, maturity: production, criticality: medium }
modules:
  core: [kernel/base]
  delivery: [managed-fleet]
  agents: [base]
overrides: { requiredArtifacts: [], disabledValidations: [required-artifacts] }
EOF
bash platform/validators/validate-manifest.sh /tmp/mf-test.manifest.yaml
bash platform/validators/validate-module-graph.sh /tmp/mf-test.manifest.yaml
```

Expected: both print `✓` and exit 0.

- [ ] **Step 3: Verify the conflict rule works (negative test)**

```bash
cat > /tmp/mf-conflict.manifest.yaml <<'EOF'
schemaVersion: 1
project: { id: mf-c, name: MF C, maturity: prototype, criticality: low }
modules:
  core: [kernel/base]
  delivery: [prototype, managed-fleet]
  agents: [base]
overrides: { requiredArtifacts: [], disabledValidations: [required-artifacts] }
EOF
bash platform/validators/validate-module-graph.sh /tmp/mf-conflict.manifest.yaml; echo "exit=$?"
```

Expected: FAIL (non-zero exit) reporting a conflict between `prototype` and `managed-fleet`. Then clean up: `rm /tmp/mf-test.manifest.yaml /tmp/mf-conflict.manifest.yaml`.

- [ ] **Step 4: Commit**

```bash
git add platform/profiles/delivery/managed-fleet/module.yaml
git commit -m "feat(delivery): add managed-fleet module profile"
```

---

### Task 2: Write the module README (compiled fragment)

**Files:**
- Create: `platform/profiles/delivery/managed-fleet/README.md`

- [ ] **Step 1: Write the README**

Create `platform/profiles/delivery/managed-fleet/README.md` (mirrors the structure of `platform/profiles/delivery/internal-platform/README.md`):

```markdown
<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Delivery Overlay: Managed Fleet

This overlay is for teams that **operate** configuration managing a live fleet of hosts —
infrastructure-as-code repos, configuration-management estates, hosting platforms. The
team applies config to hosts it runs; it does not ship an app or a distributable to
external users. The blast radius is real production, but the unit of change is host
configuration, not a released product.

---

## What This Overlay Requires

**`docs/ops/fleet-inventory.md`**
The authoritative record of which hosts are in the fleet, what role each plays, and which
inventory source is canonical. Without it, "what's in production" lives only in inventory
files and tribal knowledge.

**`docs/ops/change-control.md`**
How configuration reaches live hosts: approval, maintenance windows, and the
dry-run-before-apply gate. A fleet posture without change-control is just a prototype with
more hosts.

**`docs/ops/config-rollback.md`**
The codify-before-modify discipline and the restore path: snapshot known-good config before
changing it, and the exact steps to restore it. Rollback for a config-managed fleet is
restoring config state, not redeploying a version.

---

## How This Differs from the Other Postures

- **vs `internal-platform`** — internal-platform requires only dependency/milestone tracking
  and mandates no operational artifacts. A managed fleet has live production blast radius, so
  it forces change-control and a rollback path.
- **vs `production-saas`** — production-saas's artifacts describe releasing *your software*
  (environment inventory, release/rollback of a deployed product). managed-fleet's artifacts
  describe *applying config to hosts you operate*. Use production-saas when you ship a served
  product; use managed-fleet when you operate the hosts.
- **vs `prototype`** — hard conflict. A live fleet cannot also be throwaway with no real users.

Review gate: *"A change to the live fleet's topology requires a named maintenance window and
a stated rollback path."*

---

## Single-Posture Expectation

Like `internal-platform` and `self-hosted-oss`, managed-fleet declares only a hard conflict
with `prototype`. A project should still carry exactly one delivery posture. A project that
ALSO serves a hosted product models that as a separate manifest with `delivery/production-saas`
rather than stacking postures.

---

## How This Overlay Composes

Managed-fleet pairs naturally with a configuration-management stack and `management/project-standard`
(scope, milestones, change tracking). When the fleet coordinates many downstream client projects,
add `management/program-lite`.

---

## Agent Behavior

Applying configuration to production hosts is a human-directed action. Agents may prepare
changes — dry-run (`--check`), diff, staged `--limit` rollout plans — but must not apply to
live hosts. Topology changes require a fleet-inventory or change-control update in the same
change.
```

- [ ] **Step 2: Verify no unfilled placeholders**

Run: `bash platform/validators/validate-placeholders.sh platform/profiles/delivery/managed-fleet/`
Expected: PASS / exit 0 (the README has no `[[...]]` placeholders — it is a compiled fragment, not a template).

- [ ] **Step 3: Commit**

```bash
git add platform/profiles/delivery/managed-fleet/README.md
git commit -m "docs(delivery): add managed-fleet overlay README"
```

---

### Task 3: Create the three `docs/ops/` templates

**Files:**
- Create: `platform/templates/ops/fleet-inventory.md`
- Create: `platform/templates/ops/change-control.md`
- Create: `platform/templates/ops/config-rollback.md`

- [ ] **Step 1: Write `templates/ops/fleet-inventory.md`**

```markdown
<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Fleet Inventory — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Authoritative inventory source: [[AUTHORITATIVE_INVENTORY]]
> Last updated: YYYY-MM-DD

The canonical record of hosts this project manages. If a host runs in production and is not
in this table, that is a gap to close — not an exception to tolerate.

---

## Authoritative Source

The single source of truth for fleet membership is `[[AUTHORITATIVE_INVENTORY]]`. This
document is the human-readable projection of it. When they disagree, the inventory wins and
this document is updated.

---

## Hosts

| Host | Role | Environment | OS | Purpose | Inventory entry |
| ---- | ---- | ----------- | -- | ------- | --------------- |
| [[HOST_NAME]] | [[HOST_ROLE]] | production | [[HOST_OS]] | [[HOST_PURPOSE]] | `[[INVENTORY_PATH]]` |

---

## Roles

Define each role's responsibility and which configuration (roles/playbooks) applies to it.

| Role | Responsibility | Applied configuration |
| ---- | -------------- | --------------------- |
| [[ROLE_NAME]] | [[ROLE_RESPONSIBILITY]] | [[ROLE_CONFIG]] |

---

## Topology Change Procedure

Adding, removing, or re-roling a host is a fleet-topology change. It requires:

1. An update to this table and the authoritative inventory in the same change.
2. A maintenance window and rollback path recorded in `docs/ops/change-control.md`.
```

- [ ] **Step 2: Write `templates/ops/change-control.md`**

```markdown
<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Change Control — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Change authority: [[CHANGE_AUTHORITY]]
> Last updated: YYYY-MM-DD

How configuration reaches live hosts. Applying config to production is a human-directed
action; this document defines the gate it passes through.

---

## The Apply Gate

No configuration reaches a live host without passing, in order:

- [ ] Dry run: `[[DRY_RUN_COMMAND]]` (e.g. `ansible-playbook ... --check`) reviewed by a human
- [ ] Staged rollout: applied to a single canary host first (`[[CANARY_LIMIT_COMMAND]]`)
- [ ] Verification on the canary before fleet-wide apply
- [ ] Fleet-wide apply authorized by [[CHANGE_AUTHORITY]]

---

## Maintenance Windows

| Environment | Allowed window | Notification |
| ----------- | -------------- | ------------ |
| production | [[MAINTENANCE_WINDOW]] | [[NOTIFICATION_TARGET]] |

---

## Change Record

| Date | Change | Hosts affected | Dry-run reviewed by | Applied by | Rollback ref |
| ---- | ------ | -------------- | ------------------- | ---------- | ------------ |
| YYYY-MM-DD | [[CHANGE_SUMMARY]] | [[HOSTS]] | [[REVIEWER]] | [[APPLIER]] | `docs/ops/config-rollback.md` |
```

- [ ] **Step 3: Write `templates/ops/config-rollback.md`**

```markdown
<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Configuration Rollback — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Rollback authority: [[ROLLBACK_AUTHORITY]]
> Last updated: YYYY-MM-DD
> Last exercised: YYYY-MM-DD

For a config-managed fleet, rollback means restoring known-good configuration state — not
redeploying a product version. A rollback path that has never been exercised is not a
rollback plan.

---

## Codify Before Modify

Before changing hand-tuned or production config, capture the current known-good state into
version control:

- [ ] Snapshot current config: `[[SNAPSHOT_COMMAND]]` (e.g. an extract-configs run)
- [ ] Commit the snapshot or store it at: `[[SNAPSHOT_LOCATION]]`
- [ ] Confirm the snapshot is complete before applying any change

---

## Restore Procedure

- [ ] Identify the last known-good snapshot: `[[KNOWN_GOOD_REF]]`
- [ ] Halt any in-progress apply across the fleet
- [ ] Restore config to affected hosts: `[[RESTORE_COMMAND]]`
- [ ] Reload affected services via handlers (not ad-hoc restarts)
- [ ] Verify service health on each restored host: `[[HEALTH_CHECK_COMMAND]]`

---

## Verification

- [ ] Affected hosts serve correctly post-restore
- [ ] The fleet inventory and change-control record reflect the rollback
```

- [ ] **Step 4: Verify templates carry placeholders (sanity check)**

Run: `grep -l '\[\[' platform/templates/ops/fleet-inventory.md platform/templates/ops/change-control.md platform/templates/ops/config-rollback.md`
Expected: all three paths printed (each contains `[[...]]` placeholders, matching the template convention).

- [ ] **Step 5: Commit**

```bash
git add platform/templates/ops/fleet-inventory.md platform/templates/ops/change-control.md platform/templates/ops/config-rollback.md
git commit -m "feat(templates): add managed-fleet ops templates (fleet-inventory, change-control, config-rollback)"
```

---

### Task 4: Catalog propagation (5 docs) + fix internal-platform drift

**Files:**
- Modify: `README.md` (Module System table, delivery row)
- Modify: `SUMMARY.md` (Delivery section)
- Modify: `platform/workflow/discovery-to-composition.md` (delivery decision rubric)
- Modify: `platform/skills/harness-onboarding/SKILL.md` (delivery table + required-artifacts lines)
- Modify: `platform/templates/README.md` (Architecture and Operations table)

> NOTE: `HARNESS.md` Active Modules is intentionally NOT modified — it lists modules
> auto-harness *activates in its own manifest*, and auto-harness does not adopt
> managed-fleet. This is a deliberate deviation from the generic catalog-propagation
> reflex; ADR-0015 (Task 5) records it.

- [ ] **Step 1: README.md — extend the delivery row**

In `README.md`, find the Module System table row (currently):

```
| **Delivery** | Lifecycle posture | `prototype`, `production-saas`, `internal-platform` |
```

Replace with (adds `managed-fleet` AND `self-hosted-oss`, the latter being pre-existing drift this row was missing):

```
| **Delivery** | Lifecycle posture | `prototype`, `production-saas`, `internal-platform`, `self-hosted-oss`, `managed-fleet` |
```

- [ ] **Step 2: SUMMARY.md — add the Delivery bullet**

In `SUMMARY.md`, in the `### Delivery` list, after the `Self-Hosted OSS` bullet, add:

```
* [Managed Fleet](platform/profiles/delivery/managed-fleet/README.md) — teams that operate configuration managing a live host fleet (between internal-platform and production-saas)
```

- [ ] **Step 3: discovery-to-composition.md — add the rubric row**

In `platform/workflow/discovery-to-composition.md`, in the delivery decision table (the rows around `delivery/self-hosted-oss`), after:

```
| Published OSS the user self-hosts (not a hosted service)? (§7.4) | `delivery/self-hosted-oss` |
```

add:

```
| Operates a live fleet / hosting estate (config applied to hosts you run)? (§7.4) | `delivery/managed-fleet` |
```

- [ ] **Step 4: SKILL.md — add managed-fleet to the delivery table**

In `platform/skills/harness-onboarding/SKILL.md`, in the `### delivery (pick exactly one)` table, after the `self-hosted-oss` row, add:

```
| `delivery/managed-fleet` | Team operates configuration managing a live host fleet / hosting estate; production blast radius but no external app/distributable | `delivery/prototype` |
```

- [ ] **Step 5: SKILL.md — add managed-fleet required-artifacts line**

In the same file, after the `self-hosted-oss` required-artifact line (line ~453), add:

```
Required artifacts for `delivery/managed-fleet`: `docs/ops/fleet-inventory.md`, `docs/ops/change-control.md`, `docs/ops/config-rollback.md` (risk register optional; expected at criticality ≥ medium).
```

- [ ] **Step 6: SKILL.md — fix the internal-platform drift**

In the same file, find (line ~455):

```
No required artifacts for `delivery/prototype` or `delivery/internal-platform`.
```

Replace with:

```
No required artifacts for `delivery/prototype`. Required artifacts for `delivery/internal-platform`: `docs/project/dependency-log.md`, `docs/project/milestones.md`.
```

- [ ] **Step 7: templates/README.md — register the three ops templates**

In `platform/templates/README.md`, in the `### Architecture and Operations` table, after the `Fallback matrix` row, add three rows:

```
| Fleet inventory | `delivery/managed-fleet` | `templates/ops/fleet-inventory.md` |
| Change control | `delivery/managed-fleet` | `templates/ops/change-control.md` |
| Config rollback | `delivery/managed-fleet` | `templates/ops/config-rollback.md` |
```

- [ ] **Step 8: Run the catalog-counts validator and fix any drift it reports**

Run: `bash platform/validators/validate-catalog-counts.sh .`
Expected: it MAY report drift on documented module/template counts (e.g. "N modules" or "N templates" assertions) because we added one module and three templates. For EACH reported `file:line expected X actual Y`, open that file/line and update the asserted number to the actual. Re-run until exit 0.

- [ ] **Step 9: Commit**

```bash
git add README.md SUMMARY.md platform/workflow/discovery-to-composition.md platform/skills/harness-onboarding/SKILL.md platform/templates/README.md
git commit -m "docs(catalog): propagate managed-fleet across catalog; fix internal-platform required-artifacts drift"
```

---

### Task 5: Record the decision (ADR-0015 + change-log)

**Files:**
- Create: `docs/adr/ADR-0015-managed-fleet-delivery-posture.md`
- Modify: `docs/project/change-log.md` (prepend a new dated row)

- [ ] **Step 1: Write ADR-0015**

Create `docs/adr/ADR-0015-managed-fleet-delivery-posture.md`:

```markdown
<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# ADR-0015: Add `delivery/managed-fleet` Posture

**Status:** Accepted
**Date:** 2026-05-25
**Author:** @unclenate
**Reviewers:** @unclenate
**Context sources:**

- `docs/superpowers/specs/2026-05-25-managed-fleet-delivery-posture-design.md` — the design
- Brownfield onboarding of `an IaC fleet repo` (an Ansible IaC fleet repo) surfaced the gap

## Context

The four existing delivery postures all assume the project ships an app or a
distributable. Onboarding `the-IaC-fleet-repo` — an Ansible repo that operates a
live 8-host fleet but ships no product of its own — had no good fit:

- `prototype` waives operational burden a live fleet cannot waive.
- `production-saas`'s required artifacts describe releasing *software* (environment
  inventory, release/rollback of a deployed product), not *applying config to hosts*.
- `internal-platform` is closest but mandates no operational artifacts (only
  dependency-log + milestones).
- `self-hosted-oss` is for a distributable a downstream user operates; here the team
  operates the fleet.

## Decision

Add `delivery/managed-fleet`: a production-grade posture oriented to config applied to a
fleet, requiring `docs/ops/fleet-inventory.md`, `docs/ops/change-control.md`, and
`docs/ops/config-rollback.md`. It hard-conflicts with `prototype` only; the single-posture
expectation is documented (matching `internal-platform`/`self-hosted-oss`). Its companion
rule fires on fleet-topology changes (inventory host files, `host_vars/`) rather than every
role edit, to stay low-noise in an active IaC repo. A risk register is optional but expected
at criticality ≥ medium.

## Consequences

- `HARNESS.md` Active Modules is NOT updated: it lists modules auto-harness activates in its
  own manifest, and auto-harness does not adopt managed-fleet. This is a deliberate deviation
  from the generic "propagate new module to all catalog docs" reflex — managed-fleet is a
  catalog addition, not a self-adoption.
- The catalog-counts validator's documented module/template counts are updated in the same change.
- The propagation pass also corrects pre-existing drift: the `harness-onboarding` SKILL.md
  claimed `internal-platform` has no required artifacts (it requires two), and README.md's
  delivery row omitted `self-hosted-oss`.
- Follow-up (not in this change): extend `validate-catalog-counts.sh` (or a new check) to diff
  SKILL.md prose required-artifact claims against `module.yaml`, so this drift class is caught
  structurally. Logged as a G2/maintenance item.
```

- [ ] **Step 2: Prepend the change-log row**

In `docs/project/change-log.md`, add a new row at the TOP of the entries table (above the `2026-05-17` row), matching the existing `| date | category | description | rationale | author | refs |` format:

```
| 2026-05-25 | Scope | Added `delivery/managed-fleet` posture: a fifth delivery overlay for teams that operate configuration managing a live host fleet (production blast radius, no external app/distributable). Requires `docs/ops/{fleet-inventory,change-control,config-rollback}.md`; conflicts only with `prototype`; companion rule fires on fleet-topology changes (inventory host files, `host_vars/`). Ships three `templates/ops/` templates and the overlay README. Propagated across README.md, SUMMARY.md, discovery-to-composition.md, harness-onboarding SKILL.md, and templates/README.md. NOT added to HARNESS.md Active Modules (auto-harness does not self-adopt it). Same pass fixes pre-existing drift: SKILL.md internal-platform required-artifacts and README.md missing self-hosted-oss in the delivery row. | Brownfield onboarding of `an IaC fleet repo` surfaced a posture gap: an IaC fleet repo fits none of prototype/production-saas/internal-platform/self-hosted-oss. managed-fleet names the shape and governs its operational risks (uncontrolled apply to live hosts, undocumented topology, no rollback path). R&D pass on `feature/managed-fleet-delivery` for maintainer review before merge. | @unclenate | ADR-0015 |
```

- [ ] **Step 3: Verify the companion rule for governance entrypoints is satisfied**

The kernel companion reflex requires module-catalog edits to ship with a change-log entry or ADR in the same commit. We have both. Verify the change-log row is well-formed:

Run: `head -20 docs/project/change-log.md | grep -c "2026-05-25 | Scope | Added .delivery/managed-fleet"`
Expected: `1`.

- [ ] **Step 4: Commit**

```bash
git add docs/adr/ADR-0015-managed-fleet-delivery-posture.md docs/project/change-log.md
git commit -m "docs(adr): ADR-0015 record managed-fleet posture + change-log entry"
```

---

### Task 6: Validate the complete auto-harness change

**Files:** none (validation only)

- [ ] **Step 1: Run the full auto-harness validator suite against its own manifest**

```bash
bash platform/validators/validate-manifest.sh harness.manifest.yaml
bash platform/validators/validate-module-graph.sh harness.manifest.yaml
bash platform/validators/validate-catalog-counts.sh .
bash platform/validators/validate-placeholders.sh platform/profiles/delivery/managed-fleet/
```

Expected: all exit 0. (auto-harness's own manifest still uses `internal-platform`; adding a catalog module must not change its self-validation. `validate-placeholders` on the profile dir confirms the README has no stray placeholders; templates legitimately contain `[[...]]` and live under `platform/templates/`, which the placeholder validator excludes/handles as templates.)

- [ ] **Step 2: Confirm the module graph for a managed-fleet consumer**

```bash
cat > /tmp/mf-consumer.manifest.yaml <<'EOF'
schemaVersion: 1
project: { id: mf, name: MF, maturity: production, criticality: medium }
modules:
  core: [kernel/base]
  delivery: [managed-fleet]
  management: [project-standard]
  agents: [base, claude-code]
overrides: { requiredArtifacts: [], disabledValidations: [required-artifacts] }
EOF
bash platform/validators/validate-module-graph.sh /tmp/mf-consumer.manifest.yaml; echo "exit=$?"
rm /tmp/mf-consumer.manifest.yaml
```

Expected: `✓` and exit 0.

- [ ] **Step 3: No commit** (validation only). If any validator failed, return to the relevant task, fix, and re-run before proceeding.

---

### Task 7: Adopt `managed-fleet` in `the-IaC-fleet-repo` (consumer)

> **Location change:** this task runs in the `the-IaC-fleet-repo` parent repo
> (`<local-fleet-repo-checkout>`), NOT the submodule. The
> consumer reads the submodule working tree, which is on `feature/managed-fleet-delivery`,
> so the new module is already visible.

**Files:**
- Modify: `harness.manifest.yaml` (delivery posture)
- Create: `docs/ops/fleet-inventory.md`
- Create: `docs/ops/change-control.md`
- Create: `docs/ops/config-rollback.md`

- [ ] **Step 1: Flip the delivery posture**

In `harness.manifest.yaml`, change:

```yaml
  delivery:
    - internal-platform           # Internal ops tooling, no external user-facing surface of its own
```

to:

```yaml
  delivery:
    - managed-fleet               # Operates a live host fleet; production blast radius, no external product
```

- [ ] **Step 2: Verify manifest + graph still pass**

```bash
cd <local-fleet-repo-checkout>
bash .harness/platform/validators/validate-manifest.sh harness.manifest.yaml
bash .harness/platform/validators/validate-module-graph.sh harness.manifest.yaml
```

Expected: both `✓`, exit 0.

- [ ] **Step 3: Create the three artifacts from templates, seeded from existing docs**

Fill the three templates with real content (placeholders replaced):

- `docs/ops/fleet-inventory.md` — seed the host table from the README "Production Fleet Overview" (the production host fleet with roles); authoritative source = `inventory/production/hosts.yml`.
- `docs/ops/change-control.md` — seed the apply gate from `docs/operations/deployment-checklist.md`; dry-run command `ansible-playbook -i inventory/production/hosts.yml playbooks/site.yml --check`; canary `--check --limit <canary-host>`.
- `docs/ops/config-rollback.md` — seed the snapshot/restore steps from `docs/operations/config-extraction.md` and `scripts/extract-configs.sh`.

Replace ALL `[[...]]` placeholders with real values (owner: Nate DiNiro, nate@bdits.io; YEAR 2026; SPDX `MIT OR Apache-2.0`).

- [ ] **Step 4: Verify required artifacts now resolve and no placeholders remain**

Temporarily test required-artifacts by pointing the validator at the manifest with the override still in place (it will report "disabled"), then prove the files exist and are placeholder-free:

```bash
cd <local-fleet-repo-checkout>
ls docs/ops/fleet-inventory.md docs/ops/change-control.md docs/ops/config-rollback.md
bash .harness/platform/validators/validate-placeholders.sh .
```

Expected: all three files listed; placeholder scan exits 0 (no `[[...]]` left).

- [ ] **Step 5: Re-enable required-artifacts for the delivery scope**

In `harness.manifest.yaml`, the `disabledValidations: [required-artifacts]` override is still needed (project-standard/testing-standard artifacts remain ungated per the onboarding plan). Leave the override but update the trailing comment to record that the delivery (managed-fleet) artifacts now EXIST. Do NOT remove `required-artifacts` globally yet — that happens when project-standard/testing-standard gaps close in the onboarding progression.

- [ ] **Step 6: Commit (parent repo)**

```bash
cd <local-fleet-repo-checkout>
git add harness.manifest.yaml docs/ops/fleet-inventory.md docs/ops/change-control.md docs/ops/config-rollback.md
git commit -m "harness: adopt delivery/managed-fleet; add fleet ops artifacts"
```

> The parent repo's `.harness` gitlink still points at the pre-branch submodule SHA. Bumping it to the `feature/managed-fleet-delivery` (or merged) SHA is a separate, explicit step taken when the auto-harness branch is reviewed/merged — out of scope for this plan.

---

## Self-Review

**Spec coverage:**
- Module definition (artifacts, conflict, companion, reviewGates) → Task 1 ✓
- Overlay README → Task 2 ✓
- Three templates → Task 3 ✓
- Catalog propagation (5 docs) + internal-platform drift fix → Task 4 ✓
- ADR + change-log → Task 5 ✓
- Validation (incl. negative conflict test, companion intent) → Tasks 1, 6 ✓
- the-IaC-fleet-repo adoption → Task 7 ✓
- Spec's "HARNESS.md not updated" deviation → captured in Task 4 note + ADR (Task 5) ✓
- Spec's catalog-counts-extension follow-up → recorded as out-of-scope in ADR ✓

**Placeholder scan:** No "TBD/TODO/implement later". Template `[[...]]` tokens are intentional (template convention), and Task 7 Step 3 explicitly requires replacing them.

**Type/name consistency:** Artifact paths are identical across spec, module.yaml, README, templates, SKILL line, ADR, and consumer adoption (`docs/ops/fleet-inventory.md`, `docs/ops/change-control.md`, `docs/ops/config-rollback.md`). Module id `managed-fleet` consistent throughout. Branch name `feature/managed-fleet-delivery` consistent.

**Scope:** G1 only. F1–F4 and G2 explicitly deferred.
```
