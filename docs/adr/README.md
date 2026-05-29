<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# auto-harness — Architecture Decision Records

> **Contributor / maintainer surface.** This directory contains Architecture
> Decision Records (`ADR-NNNN-*.md`) — internal governance artifacts authored
> by harness contributors to capture *why* a structural choice was made and
> what alternatives were rejected. ADRs are not entry-point reading for
> first-time users of auto-harness.
>
> **New here?** Start with the [repository README](../../README.md) for the
> value proposition and adoption paths, or the
> [governance catalog](../README.md) for the curated ADR / PRD / OPP index.

**Owner:** @unclenate | **Last Updated:** 2026-05-28

---

## What ADRs Are

An Architecture Decision Record captures a single durable structural choice
the project has made. It names the decision, the context that forced it, the
alternatives considered, and the rationale for the path taken. ADRs are
immutable once accepted — when a decision is later overturned, a new ADR
records the supersession; the original remains in place as historical record.

ADRs in this directory govern the *harness platform itself* — the modular
governance framework — not any consumer project that uses the harness.

## Authoring an ADR

- Template: [`platform/templates/adr.md`](../../platform/templates/adr.md)
- Next number: see the catalog at [`../README.md`](../README.md) and pick the
  next sequential `ADR-NNNN`
- Catalog entry: list-completeness enforces a row in
  [`../README.md`](../README.md) — add it in the same commit as the ADR file
- Companion-rule: ADRs touching `platform/profiles/**/module.yaml`,
  `HARNESS.md`, or `operating-principles.md` may also require change-log
  entries; see the relevant module's `companionRules`

## Status Flow

| Status | Meaning |
|--------|---------|
| `Proposed` | Drafted; not yet ratified — open to substantive critique |
| `Accepted` | Ratified; in force; companion-rule enforcement applies |
| `Superseded` | Replaced by a newer ADR; links the supersedor in its body |

ADRs do not have a `Declined` status — declined proposals leave no on-disk
record (the conversation log is the record). If a proposal has substance
worth preserving for future reasoning, file it as an OPP first.

## References

- Operating principles that ADRs satisfy: [`../operating-principles.md`](../operating-principles.md)
- Governance catalog (full ADR / PRD / OPP index): [`../README.md`](../README.md)
- Companion OPP capture: [`../opportunities/README.md`](../opportunities/README.md)
- Companion PRD capture: [`../requirements/README.md`](../requirements/README.md)
