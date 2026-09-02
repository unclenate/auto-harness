<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
-->

# Design Spec — `delivery/managed-fleet` posture

> Status: proposed (awaiting maintainer review)
> Author: @unclenate
> Date: 2026-05-25
> Sub-project: **G1** of the the fleet operator multi-stack hosting program (see "Program context")

---

## Program context (why this exists)

the fleet operator is evolving `the-IaC-fleet-repo` from a WordPress-fleet Ansible repo into
a **multi-stack hosting orchestrator**: WordPress today, static/headless React/Next.js
next, via a Bastion "Build Foundry" that compiles client apps and syncs static assets
to hardened edge hosts. The full program decomposes into six sub-projects:

| ID | Layer | Sub-project | Depends on |
| -- | ----- | ----------- | ---------- |
| **G1** | governance | `delivery/managed-fleet` posture *(this spec)* | — |
| F1 | feature | Client site model (client ID, stack type, target host, docroot) | — |
| F2 | feature | Build Foundry role (Node toolchain on Bastion, isolated builds) | F1 |
| F3 | feature | Static-host role (hardened static serving, atomic releases) | F1 |
| F4 | feature | Deploy pipeline (`deploy-static.yml` → Foundry build → rsync atomic sync) | F1–F3 |
| G2 | governance | Stack/architecture absorptions (`stacks/ansible`, polyglot node, static-edge, staged-rollout testing, lint-baseline) | F2–F4 |

Build order: **G1 → F1 → F2 → F3 → F4 → G2**. G1 leads because every other piece is
built under a delivery posture, and `the-IaC-fleet-repo` needs a fleet-shaped posture for
its own harness conformance *regardless* of which client stacks are added. Each
sub-project gets its own spec → plan → implementation cycle. **This spec covers G1 only.**

---

## Goal

Add a fifth delivery posture to auto-harness for a team that **operates** configuration
managing a live fleet of hosts (or hosting estate) — real production blast radius, but
no external app or distributable of its own.

### The gap it closes

The four existing postures all assume the project ships an app or a distributable:

- `prototype` — no real users; waives operational burden. Wrong: a managed fleet has real production impact.
- `production-saas` — assumes a served product whose **release and rollback you own**. Its required artifacts (`environment-inventory`, `release-checklist`, `rollback-checklist`, `risk-register`) are product-shaped: they describe deploying *your software*, not *applying config to hosts you operate*.
- `internal-platform` — closest, but too lean: it requires only `dependency-log.md` + `milestones.md` and mandates no operational artifacts. A live fleet needs change-control and a rollback path.
- `self-hosted-oss` — for a distributable the downstream user operates; here the **team** operates the fleet, not a downstream user.

`managed-fleet` sits between `internal-platform` and `production-saas`: production-grade
operational discipline, but oriented to *config applied to a fleet* rather than *a product
served to users*.

### Non-goals (YAGNI)

- Not `management/program-lite` (coordinating many client projects) — separate module, added later if/when client sites become distinct harness projects.
- Not stack overlays, a static-edge architecture, or testing-model changes — those are G2, and only after F2–F4 produce real patterns to absorb.
- Not a replacement for `production-saas`. A project that ALSO serves a hosted product models that as a separate manifest, per the single-posture expectation.

---

## Design

### Module — `platform/profiles/delivery/managed-fleet/module.yaml`

```yaml
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
  - prototype            # a live fleet cannot also be "no real users / throwaway"
requiredArtifacts:
  - docs/ops/fleet-inventory.md
  - docs/ops/change-control.md
  - docs/ops/config-rollback.md
optionalArtifacts:
  - docs/architecture/overview.md
  - docs/security/risk-register.md   # expected at criticality >= medium (see reviewGates)
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

**Design rationale for the choices made during brainstorming:**

- **Required artifacts = "Operational" set (3).** Fleet inventory (what's in the fleet + authoritative source), change-control (how config reaches live hosts), config-rollback (codify-before-modify as the rollback path). Captures live-blast-radius reality without overreaching into product-shaped docs.
- **Companion trigger = topology changes only.** In an active Ansible repo, `roles/**` changes constantly; a rule firing on every role edit gets disabled. Scoping to inventory host files + `host_vars/` captures the genuinely risky "what's in the fleet" changes and survives daily use — mirroring how `production-saas` scopes its rule to deploy automation, not all app code.
- **`conflictsWith: [prototype]`.** Semantic exclusivity: a live fleet cannot also be throwaway/no-real-users. No hard conflict with the other postures (they declare none either); the single-posture expectation is stated in the README, consistent with `internal-platform`/`self-hosted-oss`.
- **`risk-register` optional but expected at criticality ≥ medium.** Same stance as `self-hosted-oss` — a fleet with client data carries real residual risk, but a low-criticality internal fleet shouldn't be forced into it.

### New templates (`platform/templates/ops/`)

| Template | Purpose | Seed in the-IaC-fleet-repo |
| -------- | ------- | ------------------------ |
| `fleet-inventory.md` | Host → role → OS → purpose → authoritative-source table | README.md "Production Fleet Overview" table |
| `change-control.md` | Maintenance windows, who approves, the dry-run-before-apply gate, staged rollout (`--check --limit` then expand) | `docs/operations/deployment-checklist.md` |
| `config-rollback.md` | Codify-before-modify via `extract-configs`, config-snapshot → restore steps | `docs/operations/config-extraction.md` |

Templates use the harness placeholder convention (`[[OWNER]]`, `[[PROJECT_NAME]]`, etc.)
and must pass `validate-placeholders.sh` once filled.

### Propagation (same commit — kernel companion-rule reflex)

`.harness/CLAUDE.md` requires any new module to propagate to the catalog in one pass.
For `managed-fleet` that means editing, in the same commit:

1. `HARNESS.md` — Active Modules table (auto-harness's own manifest does not activate it, but the catalog table lists it).
2. `SUMMARY.md` — Module Library section.
3. `README.md` — Module System table.
4. `platform/skills/harness-onboarding/SKILL.md` — the delivery table (add the row; **also fix the `internal-platform` row**, which currently claims "no required artifacts" but the module requires `dependency-log.md` + `milestones.md`).
5. `platform/workflow/discovery-to-composition.md` — delivery decision rubric.
6. `platform/templates/README.md` — register the three new `ops/` templates.
7. `docs/project/change-log.md` — a `Scope` entry, and **ADR-0015** documenting the new posture and the gap it closes.

### the-IaC-fleet-repo adoption (the consumer side)

After the posture exists upstream and the submodule is updated:

1. `harness.manifest.yaml`: `delivery: [internal-platform]` → `delivery: [managed-fleet]`.
2. Create the three `docs/ops/` artifacts from templates, seeded from the existing docs noted above (near-EQUIVALENT content already exists).
3. Re-run `validate-required-artifacts.sh` and `validate-companions.sh`; once green, remove `required-artifacts` from `disabledValidations` for the delivery scope.

---

## Testing / validation

- `validate-manifest.sh` and `validate-module-graph.sh` must pass with `managed-fleet` present (graph: depends on `kernel/base`, conflicts with `prototype`).
- `validate-catalog-counts.sh` must still pass after propagation (this is the validator that *should* — but currently does not — catch the SKILL.md/module.yaml drift; a follow-up to extend it is logged as a G2/maintenance item, not part of G1).
- A negative test: a manifest declaring both `prototype` and `managed-fleet` must fail `validate-module-graph.sh`.
- A companion test: a diff touching `inventory/production/hosts.yml` with no `docs/ops/fleet-inventory.md` or `docs/ops/change-control.md` change must fail `validate-companions.sh`.

---

## Risks & open items

- **Companion-rule false negatives.** `validate-companions` matches changed paths; it cannot distinguish a *new* host_vars file (real topology change) from an edit to an existing one. Matching any `host_vars/` change is an intentional over-trigger (safe direction — asks for a record when in doubt).
- **Catalog drift.** Propagation is manual across 6 files; the `internal-platform` drift this spec fixes is evidence the process is fallible. Extending `validate-catalog-counts.sh` to diff the SKILL.md prose tables against `module.yaml` is filed as a separate maintenance item.
- **Submodule workflow.** This is an auto-harness change consumed by the-IaC-fleet-repo via the `.harness` submodule. Implementation happens on a feature branch in the auto-harness repo (per the `feature/agentic-interfaces-rnd` convention); the-IaC-fleet-repo adoption is a separate commit after `git submodule update`.

---

## Out of scope for G1

F1–F4 (the Build Foundry pipeline) and G2 (stack/architecture absorptions). Those are
separate specs in this directory, brainstormed after G1 lands.
