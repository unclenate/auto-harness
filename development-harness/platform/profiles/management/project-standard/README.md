# Management Overlay: Project Standard

This overlay defines the minimum delivery-planning record for teams that need real coordination
without heavyweight program governance. It is the baseline for any project with more than one
contributor or more than a few weeks of active development.

---

## What This Overlay Requires

**`docs/project/scope-plan.md`**
What is being built in this release cycle, what is explicitly deferred, and what the phased
delivery sequence looks like. The scope plan is the shared contract between engineering and
any stakeholders on what is in and out.

**`docs/project/dependency-log.md`**
External dependencies — other teams, third-party services, API contracts — that could block
or constrain delivery. A dependency that isn't tracked is a dependency that will surprise you.

**`docs/project/milestones.md`**
Concrete delivery checkpoints with success criteria. Not a timeline — a set of observable
states that confirm the project is on track.

**`docs/project/change-log.md`**
A running record of decisions that changed scope, requirements, or approach. Answers "why
did we end up here?" when someone asks six months later. Updated whenever a scope, requirement,
or architectural decision changes.

---

## How This Overlay Fits Into the Management Stack

`project-standard` is the coordination layer. It pairs with the product layer:

| Module | Responsibility |
|--------|---------------|
| `discovery-intake` | Problem framing and intake — before engineering starts |
| `product-lite` | Product requirements, personas, release intent |
| `project-standard` | Delivery planning, milestones, scope, dependencies |
| `program-lite` | Multi-team coordination — activate only when needed |

All three management modules can coexist and complement each other. `project-standard`
depends only on `kernel/base` and has no conflicts.

---

## Review Gate

Human review must confirm owners and milestone realism. Validators check file presence.
Reviewers check that:
- Scope is specific enough to use as a delivery contract
- Milestones have observable success criteria, not just dates
- The dependency log names real dependencies, not aspirational ones
- The change log is current — stale change logs are useless change logs

---

## Agent Behavior

Agents may update the scope plan, milestones, and dependency log as part of planning work.
The change log must be updated by a human or explicitly directed agent whenever scope,
requirements, or architectural decisions change — not left as a post-hoc summary.
