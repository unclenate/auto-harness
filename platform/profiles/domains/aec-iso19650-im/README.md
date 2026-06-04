<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Domain Overlay: AEC ISO 19650 Information Management

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay governs an **ISO 19650 information-management substrate** — the Common
Data Environment (CDE), the information containers moving through it and their
status codes (S0 WIP → shared → published → S7 archived), the actor model
(appointing party / lead appointed party / appointed party), and the
status-transition policy (who may promote a container). It is the foundation of the
AEC domain family; `domains/aec-openbim-exchange` and
`domains/aec-iso19650-5-security` build on it.

The overlay's core is **jurisdiction-agnostic**. ISO 19650 is an international
standard; the National Annexes, the Authority Having Jurisdiction (AHJ) + code
edition, and the classification system are jurisdictional. This overlay makes none
the default — it forces the consumer to declare theirs in a required artifact.

## When To Activate

Activate when a project delivers built-environment information under ISO 19650 — a
CDE with information containers, a BIM Execution Plan (BEP), or a Master Information
Delivery Plan (MIDP). Pairs with `domains/aec-openbim-exchange` (model exchange) and
`domains/aec-iso19650-5-security` (security-minded handling).

## What This Overlay Requires

| Artifact | Purpose |
|----------|---------|
| `docs/aec/information-management-plan.md` | CDE structure, container status codes, the actor model, and the status-transition policy |
| `docs/aec/jurisdiction-profile.md` | The compound forcing artifact — declares National Annex × AHJ + code edition × classification system; carries the bias guardrail |

Templates for both live in `platform/templates/aec/`.

## Sensitive Paths and Companion Rules

Sensitive paths cover CDE, information-container, and model surfaces (`cde/`,
`containers/`, and paths containing `models`, `bep`, `midp`). Two companion rules:

- CDE-structure or container status-transition changes require an
  `information-management-plan.md` update or an ADR.
- `jurisdiction-profile.md` changes require a change-log entry or an ADR.

## Review Gate

Human review is required to promote a container to **Published** or **As-Built**
(a published container is contractually binding) or to change a declared
jurisdiction profile.

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- Built on by: [`domains/aec-openbim-exchange`](../aec-openbim-exchange/README.md), [`domains/aec-iso19650-5-security`](../aec-iso19650-5-security/README.md)
- Templates: `platform/templates/aec/`
- Origin: [`OPP-0039`](../../../../docs/opportunities/OPP-0039-domain-family-aec-decomposed.md), [`PRD-0019`](../../../../docs/requirements/PRD-0019-aec-iso19650-openbim-wedge.md)
