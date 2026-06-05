<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Domain Overlay: Healthcare FHIR

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay governs a **FHIR data layer** — the HL7 FHIR resources a system exposes, its
API surface, and the PHI those resources carry. It is the foundation of the healthcare
domain family; `domains/healthcare-smart-on-fhir` builds on it for app launch and scopes.

The overlay's core is **jurisdiction-agnostic**. FHIR is an international standard; the
profiles layered on top (US Core, the International Patient Summary, UK/AU profiles) are
jurisdictional. This overlay makes no jurisdiction the default — it forces the consumer to
declare theirs in a required artifact.

---

## What This Overlay Requires

| Artifact | Purpose |
|----------|---------|
| `docs/healthcare/fhir-resource-map.md` | Which FHIR resources and version the system implements, and which profiles apply |
| `docs/healthcare/jurisdiction-profile.md` | The forcing artifact — declares region(s) and applicable profiles; carries the bias guardrail |

Optional: `docs/healthcare/bulk-export-readiness.md` (FHIR Bulk Data / `$export`).

Templates for all three live in `platform/templates/healthcare/`.

---

## Sensitive Paths and Companion Rules

Sensitive paths cover FHIR implementation and PHI-touching code (`fhir/`, `src/FHIR/`, and
paths containing `patient`, `observation`, `bundle`, `phi`). Two companion rules apply:

- Changes to `fhir-resource-map.md` or `jurisdiction-profile.md` require an ADR or a
  change-log entry.
- PHI-schema-touching changes under `src/FHIR/` or `fhir/` require a risk-register update.

---

## Review Gate

Human review is required for any change that widens PHI exposure or changes a declared
jurisdiction profile. These are not stylistic decisions — they determine what protected
health information leaves the system and under which legal regime.

---

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- Built on by: [`domains/healthcare-smart-on-fhir`](../healthcare-smart-on-fhir/README.md)
- Templates: `platform/templates/healthcare/`
- Origin: [`OPP-0013`](../../../../docs/opportunities/OPP-0013-domain-family-healthcare-decomposed.md), [`PRD-0017`](../../../../docs/requirements/PRD-0017-healthcare-fhir-smart-wedge.md)
