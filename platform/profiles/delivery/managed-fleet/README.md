<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Delivery Overlay: Managed Fleet

**Depends on:** `kernel/base`.
**Conflicts with:** `prototype`.

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

---

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- ADR: [`ADR-0015 — Managed-Fleet Delivery Posture`](../../../../docs/adr/ADR-0015-managed-fleet-delivery-posture.md)
