<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Environment Inventory

**Owner:** @platform-team
**Last updated:** 2024-03-01

This inventory documents every environment where the platform or governed projects are deployed
or operated. Update it when a new environment is provisioned, decommissioned, or when access
controls change.

---

| Environment | Purpose | URL / Access | Owner | Data classification | Deploy mechanism |
| ----------- | ------- | ------------ | ----- | ------------------- | ---------------- |
| local | Individual developer workstation — run validators and tests | n/a | Individual developer | Development only; no production data | Manual (`bash platform/validators/...`) |
| CI (GitHub Actions) | Automated validator runs on every PR and push to main | GitHub Actions runner (ubuntu-latest) | @platform-team | No persistent data; ephemeral runners | GitHub Actions (`harness.yml`) |
| GitBook (docs) | Published platform documentation site | See project repo for URL | @platform-team | Public documentation only | Auto-publish on merge to main via GitBook integration |
| NPM / GitHub Package Registry | (Future) Published platform package if registry distribution is adopted | n/a | @platform-team | No sensitive data | CI release workflow (not yet active) |

---

## Access and Credentials

| Environment | Who has access | Auth mechanism | Secrets location |
| ----------- | -------------- | -------------- | ---------------- |
| local | All developers | Filesystem permissions | Developer's local environment |
| CI (GitHub Actions) | GitHub Actions bot; repo admins | GitHub OIDC / repository secrets | GitHub Actions Secrets (repo level) |
| GitBook | @platform-team admins | GitBook account (SSO recommended) | GitBook organization settings |

---

## Notes

- No customer data or PII is processed or stored in any environment — the platform governs
  documentation and CI; it does not handle application runtime data.
- The CI environment uses ephemeral runners; no state persists between runs.
- Any new environment added to this project must be logged here before its first use and must
  have a designated owner before going live.
