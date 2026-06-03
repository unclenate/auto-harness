<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Domain Overlay: Healthcare SMART on FHIR

**Depends on:** `kernel/base`, `healthcare-fhir`.
**Conflicts with:** None.

This overlay governs **SMART on FHIR** — the OAuth-based app-launch and scope layer that
lets an application access FHIR data. It sits on top of `domains/healthcare-fhir` (SMART is
an authorization layer over a FHIR server).

SMART serves **two trust roles**, modeled here as a documented axis in one artifact rather
than as duplicate modules:

- **Provider-launch** — an EHR launches the app and supplies context (`launch/patient`,
  provider-scoped grants). The provider operates the system.
- **Patient-access** — a patient authorizes an app to read their *own* records
  (`patient/*.read`). The patient is the resource owner; the trust model differs in kind.

---

## What This Overlay Requires

| Artifact | Purpose |
|----------|---------|
| `docs/healthcare/smart-scope-map.md` | Declares scopes per role (provider-launch section + patient-access section) and a trust-model note stating who owns the resource in each role |

Template: `platform/templates/healthcare/smart-scope-map.md`.

---

## Sensitive Paths and Companion Rules

Sensitive paths cover SMART launch, OAuth scope, and token handling (`src/FHIR/SMART/`,
`auth/`, and paths containing `scope`, `launch`, `token`, `oauth`). Companion rules:

- Scope-map changes require an ADR or change-log entry.
- Changes under the SMART implementation and auth surfaces (`src/FHIR/SMART/`, `auth/`)
  require a risk-register update or ADR — these implement the scope, launch, and token
  handling that governs the patient-access trust boundary, where the patient is the
  resource owner (a higher bar than a documentation-only scope-map edit).

---

## Review Gate

Human review is required for scope grants, launch-context changes, and any edit to the
provider-launch vs patient-access scope boundary. Granting an app a broader scope is an
authorization change, not a configuration tweak.

---

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- Required dependency: [`domains/healthcare-fhir`](../healthcare-fhir/README.md)
- Templates: `platform/templates/healthcare/`
- Origin: [`OPP-0013`](../../../../docs/opportunities/OPP-0013-domain-family-healthcare-decomposed.md), [`PRD-0017`](../../../../docs/requirements/PRD-0017-healthcare-fhir-smart-wedge.md)
- Patient-agent safety (separate, future): [`OPP-0022`](../../../../docs/opportunities/OPP-0022-patient-facing-health-agent-safety.md)
