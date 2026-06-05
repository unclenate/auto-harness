<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Domain Overlay: AEC ISO 19650-5 Security

**Depends on:** `kernel/base`, `domains/aec-iso19650-im`.
**Composes with:** `management/privacy-by-design`.
**Conflicts with:** None.

This overlay governs **security-minded information handling** per BS EN ISO
19650-5:2020 — a sensitivity assessment (identify and classify sensitive
information) and a security-management plan (redaction, RBAC, secure federation,
monitoring/audit). Sensitivity drivers include critical infrastructure, building
occupants, and embedded security systems: a built-asset model can reveal how to
attack a building or utility.

## When To Activate

Activate when a project handles sensitive built-asset information — critical
infrastructure, defence/government estates, or any asset whose model would aid an
attacker. Requires `aec-iso19650-im` (the substrate it secures).

## Security × Privacy — the composition boundary

This overlay governs **built-asset / infrastructure sensitivity** (the model
reveals how to attack a building). `management/privacy-by-design` (shipped) governs
**personal-data privacy** (occupant PII). They are complementary, not overlapping:

- A real AEC project with occupant data activates **both**.
- The `sensitivity-assessment.md` references the `privacy-profile.md`'s declared
  legal regime so the two artifacts cross-reference rather than duplicate.
- Asset-sensitivity classification is this module's concern; personal-data lawful
  basis and the regime declaration remain privacy-by-design's concern.

The sample composition `platform/compositions/aec-bim-project.yaml` activates both.

## What This Overlay Requires

| Artifact | Purpose |
|----------|---------|
| `docs/aec/sensitivity-assessment.md` | Identify and classify sensitive information; reference the privacy-profile regime for occupant data |
| `docs/aec/security-management-plan.md` | Redaction, RBAC, secure-federation, and monitoring/audit policy |

Templates for both live in `platform/templates/aec/`.

## Sensitive Paths and Companion Rules

Sensitive paths cover security-classified, redaction, and secure-federation
surfaces (paths containing `sensitive`, `classified`, `redaction`, and `security/`).
Two companion rules: artifact changes require an ADR or change-log entry;
classified/redaction surface changes require a risk-register update or an ADR.

## Review Gate

Human review is required to declassify information, broaden access to a sensitive
container, or change the redaction policy.

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Built on: [`domains/aec-iso19650-im`](../aec-iso19650-im/README.md)
- Composes with: [`management/privacy-by-design`](../../management/privacy-by-design/README.md)
- Templates: `platform/templates/aec/`
- Origin: [`OPP-0039`](../../../../docs/opportunities/OPP-0039-domain-family-aec-decomposed.md), [`PRD-0019`](../../../../docs/requirements/PRD-0019-aec-iso19650-openbim-wedge.md)
