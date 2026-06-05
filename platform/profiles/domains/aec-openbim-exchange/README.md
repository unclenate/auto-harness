<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Domain Overlay: AEC openBIM Exchange

**Depends on:** `kernel/base`, `domains/aec-iso19650-im`.
**Conflicts with:** None.

This overlay governs **openBIM model exchange** — the IDS-style exchange
requirements (which IFC entities, classifications, and properties must be present),
the **pinned IFC version** (an enforced field, given IFC4 / IFC4.3 tool-support
fragmentation), and the **producer / receiver / reviewer role axis** (ISO 19650-4
exchange roles). It is the AEC analog of `domains/healthcare-smart-on-fhir`: the
access/interop layer where the trust-role axis lives. `aec-iso19650-im`'s CDE
permissions *reference* the roles declared here.

## When To Activate

Activate when a project exchanges federated BIM models via openBIM formats
(IFC/BCF) under an information-delivery contract. Requires `aec-iso19650-im` (the
CDE/container substrate the exchange flows through).

## What This Overlay Requires

| Artifact | Purpose |
|----------|---------|
| `docs/aec/exchange-requirements.md` | IDS-style required entities/properties, the pinned IFC version, and the producer / receiver / reviewer role axis |

The template lives in `platform/templates/aec/`.

## Sensitive Paths and Companion Rules

Sensitive paths cover IFC, BCF, and federated-exchange surfaces (`ifc/`,
`exchange/`, and paths containing `bcf`, `federation`). Two companion rules:

- `exchange-requirements.md` changes (including the IFC-version pin or an exchange
  grant) require an ADR or change-log entry.
- IFC/exchange-surface changes require a risk-register update or an ADR.

## Review Gate

Human review is required to change the pinned IFC version or widen an exchange
grant — both alter what model information crosses an organizational boundary.

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Built on: [`domains/aec-iso19650-im`](../aec-iso19650-im/README.md)
- Templates: `platform/templates/aec/`
- Origin: [`OPP-0039`](../../../../docs/opportunities/OPP-0039-domain-family-aec-decomposed.md), [`PRD-0019`](../../../../docs/requirements/PRD-0019-aec-iso19650-openbim-wedge.md)
