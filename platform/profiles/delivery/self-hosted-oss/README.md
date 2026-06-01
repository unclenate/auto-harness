<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Delivery Overlay: Self-Hosted OSS

**Depends on:** `kernel/base`.
**Conflicts with:** None.

## What this module adds

This overlay is the delivery posture for **published open-source software
that ships as a self-hosted deployment the end user operates**. It fills the
gap between `delivery/prototype` and `delivery/production-saas`:

- `delivery/prototype` *undersells* it — the software is live, may handle
  real data, ships a security model, and has a release cadence. It is past
  "experiment."
- `delivery/production-saas` *oversells* it — that posture mandates
  hosted-infrastructure ops artifacts (environment inventory, release and
  rollback checklists for a hosted service) that do not exist when **every
  user self-hosts**.

The defining shift: **the operator is the user, not the team**. Artifacts are
oriented to a *distributable the user runs* — a self-hosting guide, an
inherited security posture, a release/versioning intent — not a *service the
team operates*.

## When to activate

Activate `delivery/self-hosted-oss` when:

- The project is published open source AND is run by end users on their own
  infrastructure (a VM, a homelab, a container they manage).
- There is no hosted multi-tenant service you operate; each user gets their
  own deployment.
- The project is more than a throwaway prototype (it has a security posture,
  a release cadence, real operators downstream).

Common shapes: self-hosted apps (Nextcloud-class), agent runtimes and CLIs,
homelab software, and reference deployments of an open-core product.

## What it requires

- **Required:** `docs/deployment/self-hosting-guide.md` — the operator's
  contract: minimum viable deployment, data locations the operator owns, and
  the security posture they inherit. Template at
  `platform/templates/deployment/self-hosting-guide.md`.
- **Optional but strongly expected for data-handling deployments:**
  `docs/security/risk-register.md` (reuses the `risk-register.md` template) —
  required by review gate when criticality ≥ medium.
- **Optional:** `docs/product/release-intent.md` (distributable versioning
  intent), `docs/ops/runbook-index.md`.
- **Companion rule:** changes to install/deploy automation require an update
  to the self-hosting guide or the release intent.

## Single-posture expectation

Like `delivery/internal-platform`, this module declares no hard
`conflictsWith`, but a project should carry **exactly one** delivery posture.
A project that *also* offers a hosted edition should model that edition as a
**separate manifest** using `delivery/production-saas` — not by stacking two
postures in one manifest. (This mirrors the open-core split where the
self-hosted OSS product and the hosted SaaS product are distinct
repositories/manifests.)

## What it does not do

- It does not waive security or supply-chain rules. Unlike `prototype`, this
  is published software with downstream operators; secret-handling and
  dependency hygiene are in force.
- It does not require hosted-ops artifacts. If you operate a hosted service,
  you want `delivery/production-saas`, not this.
- It does not encode a maturity level. "Self-hosted OSS" is a *delivery*
  shape orthogonal to `maturity` — an OSS tool can be prototype-grade or
  rock-solid; set `maturity` independently.

---

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- Spec: [`docs/requirements/PRD-0010-self-hosted-oss-delivery.md`](../../../../docs/requirements/PRD-0010-self-hosted-oss-delivery.md)
