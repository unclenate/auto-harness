<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Lifecycle Controls

The kernel distinguishes *baseline harness states* from *project-specific
overlays*. Two lifecycle stages are normative across every harnessed
project — **Bootstrap Complete** and **Harness Ready**. Each is a defined
state with explicit criteria; the project moves between them along
specific paths.

These stages exist because *partial-adoption fragility* is a known failure
mode: a project that runs `install.sh`, gets some artifacts in place, and
then stalls before adding the rest produces a half-governed state where
some validators pass and others are silently disabled. The lifecycle
stages name the *two stable points* in the adoption arc, so a project
knows which one it's at and what it needs to reach the next.

## Bootstrap Complete

Bootstrap is complete when the harness is **mechanically wired** to the
project:

- The active manifest validates (`validate-manifest.sh` exits 0).
- All selected modules resolve without dependency or conflict errors
  (`validate-module-graph.sh` exits 0).
- Placeholder scanning passes (`validate-placeholders.sh` exits 0 — no
  unfilled `[[TOKEN]]` or `YYYY-MM-DD` tokens remain).
- Required compatibility entrypoints exist (`HARNESS.md`, `AGENTS.md`,
  `CLAUDE.md`, the agent-pack-specific files).
- Required artifact templates have been instantiated *or explicitly
  waived* via `overrides.disabledValidations` (the lite-manifest
  pattern).

What Bootstrap Complete *does not* mean: the project is fully governed.
A lite manifest with `required-artifacts` disabled is Bootstrap
Complete — but it has deferred the substantive artifacts the harness
exists to require. Bootstrap Complete is the *threshold of mechanical
wiring*, not the threshold of governance maturity.

The first PR on a newly-installed harness should reach Bootstrap
Complete on green CI. The criteria above are exactly what the
`bootstrap-quickstart.md` walkthrough produces.

## Harness Ready

Harness Ready is the **next stable state** after Bootstrap Complete. A
project is Harness Ready when it is *fully governed*, not merely
mechanically wired:

- All Bootstrap Complete criteria hold.
- **Ownership and review gates are active.** The `module.yaml` `reviewGates`
  for each active module fire on the appropriate PR shapes; named
  reviewers are configured (typically via CODEOWNERS or the
  equivalent on non-GitHub forges).
- **The validator set is wired into CI** (or an equivalent local gate).
  Validators that run only on the bootstrapping developer's machine
  don't actually enforce anything for the team; CI is what makes the
  contract durable.
- **Operational readiness artifacts** required by active delivery modules
  exist. A project with `delivery/production-saas` active needs the
  full risk register, release checklist, and incident-response
  artifacts the delivery module requires; a `delivery/prototype` project
  needs much less. The bar is set by the *active delivery module*, not
  by the project's stage of development.
- **At least one human reviewer besides the bootstrapper** has reviewed
  the harness. This rule exists because the bootstrapper has a known
  blind spot: they wrote the manifest, they chose the modules, they
  approved the trade-offs. A second human acting as the first external
  reviewer catches the assumptions the bootstrapper baked in without
  noticing.

Harness Ready is where the project *can rely on the governance contract*.
Pre-Harness-Ready, the contract is in motion; post-Harness-Ready, the
team can trust that the discipline the harness encodes is actually
producing the audit-trail floor the doctrine demands.

## Lifecycle Transitions

The path from no-harness to Harness Ready has known transitions:

```text
No harness
    │
    │  bash .harness/platform/bootstrap/install.sh
    ▼
Bootstrapping (intermediate; not a stable state)
    │
    │  validators green; templates instantiated or waived
    ▼
Bootstrap Complete  ◄── stable; some projects pause here
    │
    │  required artifacts backfilled; CI wired; second reviewer onboarded
    ▼
Harness Ready  ◄── stable; the target state for adopting projects
    │
    │  (optional) delivery-overlay stricter readiness
    ▼
Production-Saas-Ready / Internal-Platform-Ready / etc.
```

Movement *backward* is possible but should be deliberate. Disabling
validators via `overrides.disabledValidations` regresses a project
from Harness Ready toward Bootstrap Complete; the override should be
documented in the change log, and the criterion to re-enable should
be named. Silent regressions — disabling a validator without recording
why — are a governance-relevant failure mode.

## Delivery Overlays May Add Stricter Readiness States

Beyond Harness Ready, delivery overlays can declare *production-shaped*
readiness criteria. `delivery/production-saas` requires risk-register
completeness, threat-model coverage, deployment-runbook artifacts,
and incident-response readiness that `delivery/prototype` does not. A
project adopting `delivery/production-saas` doesn't reach
*Production-SaaS-Ready* until those additional criteria are
satisfied — Harness Ready is necessary but not sufficient.

These stricter readiness states are *not* part of the kernel; they are
declared per delivery overlay. The kernel only normalizes the two
universal stages (Bootstrap Complete, Harness Ready). Delivery-specific
stages are the overlay's concern.

## Why These Two Stages and Not More

The kernel could define more stages — *Discovery Complete*,
*Module Selected*, *First Artifact Live*, *Validator Wired*, *CI Green*,
and so on. It deliberately doesn't, for the same reason the trust
model has six tiers and not twelve: *only the transitions where the
governance contract changes hands* warrant naming.

- Bootstrap Complete: the *mechanical* contract is satisfied (validators
  green; entrypoints exist).
- Harness Ready: the *substantive* contract is satisfied (review gates
  active; CI enforces; second reviewer onboarded).

Between them, the project is *mid-transition*; before Bootstrap
Complete, the project is *pre-harness*; after Harness Ready, additional
delivery-specific stages can layer on. Two stages is the smallest set
that captures the two transitions where *what the harness guarantees*
changes meaningfully. More stages would either repeat the same
information at finer granularity (without adding decision-relevant
distinctions) or encode delivery-specific concerns that belong in
overlays.

## Related

- [Doctrine](doctrine.md) — the principles these stages operationalize
- [Audit Model](audit-model.md) — what counts as evidence that a stage
  has been reached
- [Bootstrap Quickstart](../../../workflow/bootstrap-quickstart.md) —
  the walkthrough that takes a project to Bootstrap Complete
- [Submodule Integration](../../../workflow/submodule-integration.md) —
  the recommended adoption path
- Glossary: [Bootstrap Complete](../../../reference/glossary.md#bootstrap-complete),
  [Harness Ready](../../../reference/glossary.md#harness-ready),
  [Lite Manifest](../../../reference/glossary.md#lite-manifest)
