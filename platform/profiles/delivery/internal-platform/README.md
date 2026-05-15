<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Delivery Overlay: Internal Platform

This overlay is for shared systems — internal tooling, shared services, developer platforms,
data pipelines — where downstream team coordination matters more than external product launch
ceremony. The consumers are engineers, not end users.

---

## What This Overlay Requires

**`docs/project/dependency-log.md`**
A record of teams and systems that depend on this platform. Internal platforms fail silently
when consumers don't know about breaking changes. The dependency log is what makes change
communication possible.

**`docs/project/milestones.md`**
A schedule of planned milestones visible to downstream consumers. Internal platforms that
ship without notice create coordination failures across multiple teams.

---

## How This Differs from `production-saas`

Internal platforms serve a known set of consumers rather than an unbounded user base. The
governance focus shifts from launch ceremony (release checklists, rollback drills) toward
consumer visibility and dependency coordination.

The tradeoff: fewer required ops artifacts, but stricter expectation that consumers are
informed of changes before they happen.

Review gate: *"Shared platform changes require explicit owner visibility even when user impact is indirect."*

---

## When to Use This Instead of `prototype`

Use `internal-platform` when:
- Other teams or systems depend on this codebase
- A breaking change here breaks something elsewhere
- There is a named owner accountable for the platform's behavior

Use `prototype` when:
- No other team depends on the output yet
- The system is purely experimental with no downstream consumers

---

## How This Overlay Composes

Internal platform commonly pairs with `architectures/api-service` (shared backend service)
or `architectures/event-driven` (shared event bus or message broker). Data modules and stack
modules compose normally.

---

## Agent Behavior

Agents operating on an internal platform must be aware that changes have downstream impact
beyond the immediate codebase. Breaking changes to shared interfaces or contracts require
dependency-log review and consumer notification before deployment.
