<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0021 — `delivery/self-hosted-oss` Posture

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-05-24
**Last Updated:** 2026-05-25 *(accepted; PRD-0010 drafted + module scaffolded; v0.5.2 batch)*
**Confidence:** medium-high

---

## Thesis

The `delivery/` family has three postures — `prototype`, `production-saas`,
`internal-platform` — and none fits a **published open-source tool that
ships as a single-user, self-hosted reference deployment**. This is a
common and growing shape (self-hosted apps, CLI tools, agent runtimes,
homelab software), and the catalog forces it into a posture that
misrepresents it:

- `prototype` *undersells* — the software is live, may handle data that
  matters, and often ships a security model and a release cadence.
- `production-saas` *oversells* — it mandates hosted-infrastructure ops
  artifacts (environment inventory, release/rollback for a hosted service)
  that do not exist when every user self-hosts.
- `internal-platform` is for internal-only tooling with no external surface.

Add **`delivery/self-hosted-oss`**: required artifacts oriented to a
*distributable the user runs*, not a *service the team operates* — a
self-host deployment guide, a security model the operator inherits, and a
distributable versioning/release-intent — and explicitly **no**
hosted-infra ops artifacts.

## Origin / Evidence

- **Consumer project: Tula (`github.com/unclenate/tula` fork).** Brownfield
  onboarding 2026-05-24; gap analysis §TG3. Tula is Apache-2.0 OSS plus a
  single-user self-hosted reference deployment. It already carries the
  artifacts this posture would require: `docs/deployment-guide.md`,
  `docs/security-model.md`, `docs/cost-guide.md`,
  `docs/health-skillz-vm-hosting.md`, and operator scripts
  (`scripts/install-health-skillz-vm.sh`, `health-skillz-vm-preflight.sh`,
  `agent-backup.sh`, `deploy-skills.sh`). `OPEN_CORE.md` scopes the
  open/self-hosted product against a separate commercial hosted offering
  (Aria) — a textbook open-core/self-hosted split.
- **The mismatch has a concrete cost.** The one production artifact that
  genuinely applies to Tula regardless of posture —
  `docs/security/risk-register.md`, given it handles PHI — is today gated
  behind a `production-saas` framing that otherwise does not fit. A
  self-hosted-oss posture can require the risk register without dragging in
  hosted-ops artifacts.
- **The pattern generalizes well beyond Tula.** Self-hosted OSS is a large
  category: Nextcloud, Gitea, Home Assistant, Immich, countless agent
  runtimes and CLIs. All share "the user is the operator," version-pinned
  releases, an inherited security posture, and no team-operated production
  environment.
- **Internal precedent for per-posture granularity.** The `delivery/`
  family already encodes mutually-exclusive postures with distinct
  artifact contracts; this is one more posture on the same axis.

## Why Now

- **Agent-native products skew self-hosted.** OPP-0018's skill-pack
  consumers frequently ship as self-hosted runtimes (Tula on a VM is the
  exemplar). As the harness courts that audience, a delivery posture that
  fits them is load-bearing.
- **Avoids a dishonest manifest at intake.** Without this posture,
  brownfield onboarding of any self-hosted OSS project must choose a
  misrepresenting delivery module on day one — exactly the
  conservative-selection tension the onboarding skill is designed to avoid.

## Risks / Open Questions

- **Conflict declaration.** Should it `conflictsWith` `production-saas`
  (like `prototype` does), or can a project be both (an OSS tool that *also*
  offers a hosted edition)? Tula's own Tula/Aria split suggests "self-hosted
  OSS" and "hosted SaaS" can be two *manifests* for two products rather than
  two postures on one. Bias: `conflictsWith: production-saas` within a
  single manifest; cross-product is a separate manifest.
- **Maturity-vs-delivery confusion.** "Self-hosted OSS" is a *delivery*
  shape, orthogonal to `maturity` (an OSS tool can be prototype-grade or
  rock-solid). The module must not encode a maturity assumption.
- **Required-artifact restraint.** Resist mandating a heavy ops set; the
  point of the posture is that the operator-burden artifacts are *fewer and
  different*, not absent. Likely: self-host guide (required), security model
  (required), release/versioning intent (required), risk register (required
  if criticality ≥ medium).
- **Overlap with regulated-compliance.** A self-hosted OSS project in a
  regulated space (Tula handles PHI) may also want OPP-0015's
  regulated-compliance module. The two should compose; this posture is
  delivery-shape, that one is governance-shape.

## Disposition

**Accepted 2026-05-25.** Promoted to a v1 delivery posture
(`delivery/self-hosted-oss`) in the v0.5.2 batch. v1 uses `conflictsWith: []`
(matching the `internal-platform` precedent) and documents the single-posture
expectation in the README rather than editing `prototype`/`production-saas`
for symmetric conflicts; a graph-level "exactly one delivery posture" check is
the cleaner long-term home for mutual exclusivity (future work). Required
artifacts kept minimal (self-hosting guide only; risk register optional,
review-gated by criticality). See PRD-0010 for resolved design questions.

## Promotion

- See [`docs/requirements/PRD-0010-self-hosted-oss-delivery.md`](../requirements/PRD-0010-self-hosted-oss-delivery.md)
- Module: `platform/profiles/delivery/self-hosted-oss/`

## Related

- Gap analysis source: consumer project (`tula`) at
  `docs/knowledge/harness-coverage-gap-analysis.md` §TG3
- Composes with: [OPP-0015](OPP-0015-regulated-compliance-test-kits.md)
  (regulated self-hosted OSS), [OPP-0018](OPP-0018-architecture-eval-gated-skill-pack.md)
  (skill-pack runtimes ship self-hosted)
- Existing family: `platform/profiles/delivery/{prototype,production-saas,internal-platform}/`
