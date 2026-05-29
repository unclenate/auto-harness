<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# auto-harness — Product Requirements Documents

> **Contributor / maintainer surface.** This directory contains Product
> Requirements Documents (`PRD-NNNN-*.md`) — internal governance artifacts
> authored by harness contributors to specify *what* a feature does, how it
> behaves, and how its completion is verified. PRDs are not entry-point
> reading for first-time users of auto-harness.
>
> **New here?** Start with the [repository README](../../README.md) for the
> value proposition and adoption paths, or the
> [governance catalog](../README.md) for the curated PRD / ADR / OPP index.

**Owner:** @unclenate | **Last Updated:** 2026-05-28

---

## What PRDs Are

A Product Requirements Document captures the design contract for a single
harness feature or module — the functional requirements (Must-Have /
Should-Have), the open questions, the success criteria, and the verification
plan. PRDs are the bridge between an accepted opportunity ([OPP](../opportunities/README.md))
and a shipping implementation.

Under [operating principles § 9](../operating-principles.md) (Split Design
from Implementation), most PRDs ship as a design-only PR first; the
implementation PR follows in a separate cycle. Under
[§ 10](../operating-principles.md) (Classify Claims Before Enforcing Them),
PRDs that introduce structural-enforcement validators include a
*Claim Classification* block that tags each claim as Enforced,
Half-enforced, or Asserted-only.

PRDs in this directory govern the *harness platform itself* — the modular
governance framework — not any consumer project that uses the harness.

## Authoring a PRD

- Template: [`platform/templates/product/prd.md`](../../platform/templates/product/prd.md)
- Next number: see the catalog at [`../README.md`](../README.md) and pick the
  next sequential `PRD-NNNN`
- Catalog entry: list-completeness enforces a row in
  [`../README.md`](../README.md) — add it in the same commit as the PRD file
- OPP linkage: every accepted PRD references at least one originating OPP in
  its body (the "Origin" field); see
  [`../opportunities/README.md`](../opportunities/README.md) for that side of
  the contract

## Status Flow

| Status | Meaning |
|--------|---------|
| `Proposed` | Drafted; design contract under review — open to substantive critique |
| `Accepted` | Ratified; implementation work authorized; no further design churn without an ADR |
| `Implemented` | Implementation PR shipped; PRD remains as the durable design record |
| `Superseded` | Replaced by a newer PRD; links the supersedor in its body |

PRDs do not have a `Declined` status. A rejected PRD is unwound by deleting
the file (it has no on-disk historical claim, unlike an ADR). The originating
OPP captures the rejection rationale in its Disposition field.

## References

- Operating principles that PRDs satisfy: [`../operating-principles.md`](../operating-principles.md)
- Governance catalog (full PRD / ADR / OPP index): [`../README.md`](../README.md)
- Companion ADR capture: [`./README.md` siblings, the ADR set](../adr/README.md)
- Companion OPP capture: [`../opportunities/README.md`](../opportunities/README.md)
