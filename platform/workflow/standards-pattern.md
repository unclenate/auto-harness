<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# The Standards Pattern

## Single Source of Truth Artifacts in `docs/standards/`

Some governance artifacts are referenced by many other documents — KPI
definitions, SLA commitments, attribution rules, taxonomy definitions.
When these are defined inline in the documents that use them, they drift.
By the third document, the same metric has three slightly different
formulas.

The standards pattern solves this by putting each such artifact in
`docs/standards/` as a single source of truth. Other documents reference
the standards file by name; they don't redefine its content.

---

## When to Use the Standards Pattern

Adopt a standards artifact when:

- A definition, formula, or rule is referenced in multiple documents
- Drift between references would cause real problems (inconsistent
  reporting, broken SLAs, audit failures)
- The definition has a clear owner who can approve changes
- Changes to the definition are relatively rare

Skip the standards pattern when:

- Only one document uses the definition
- The definition is project-ephemeral (lives and dies with a single
  initiative)
- Domain-specific jargon unlikely to spread beyond a single team

---

## The Discipline

Any document in `docs/standards/` follows four rules:

1. **Define once, reference everywhere.** Other documents reference the
   standard by name — they don't restate it.
2. **Changes require review.** Modifying a standard is a breaking change
   for everything downstream. Treat updates like an API change: log the
   change, notify referencing documents, update them if necessary.
3. **New entries require justification.** Before adding to a standard,
   confirm it can't be expressed as a variant of an existing entry.
4. **Retired entries stay documented.** Don't delete retired entries —
   mark them `Status: Retired` with the date and replacement (if any).

---

## Standard Artifact Format

Every standards file has:

- A versioned header (`Version`, `Owner`, `Last Updated`, `Review Cycle`)
  — the same convention used across other harness-governed documents
- A single-source-of-truth statement at the top naming what this file is
  the authority for
- Entry format documentation that tells readers how to read and extend
  the file
- Usage rules explicit in the file (not only in the template README)
- A cross-references section linking to documents that use this standard

See `platform/templates/standards/kpi-dictionary.md` for the canonical
example.

---

## Examples

Common standards artifacts projects adopt as they mature:

| Standard | What it defines | Typical consumers |
|----------|-----------------|-------------------|
| `kpi-dictionary.md` | Metric definitions, formulas, data sources | PRDs, dashboards, stakeholder reports |
| `sla-definitions.md` | Service-level objectives and commitments | Ops runbooks, customer contracts, on-call |
| `attribution-model.md` | How outcomes are attributed to inputs | Reporting, revenue tracking, marketing docs |
| `taxonomy.md` | Shared vocabulary, entity naming conventions | Any document with domain terminology |
| `style-guide.md` | Writing conventions, formatting rules | All documentation |

Not every project needs all of these. Adopt a standard when the drift
risk becomes real.

---

## Relationship to Modules

The standards pattern is cross-cutting — individual standards attach to
whichever module makes sense:

| Standard | Most natural module |
|----------|---------------------|
| KPI dictionary | `management/product-lite` |
| SLA definitions | `delivery/production-saas` |
| Attribution model | `management/product-lite` or `delivery/production-saas` |
| Taxonomy | `core/kernel/base` or a domain module |

Standards are generally **optional artifacts**, adopted when a project
is mature enough for drift to matter. See the KPI dictionary's entry in
`management/product-lite/README.md` for the reference pattern.

---

## Pattern Origin

This pattern was absorbed into auto-harness from observed practice in
the adsclaw project, which used `docs/standards/` (KPI Dictionary, SLA
Definitions, Attribution Model) to prevent drift across a growing body
of engine plans and operational documents. The convention and discipline
both predate auto-harness; this file codifies them for other projects.

---

## References

- KPI Dictionary template: `platform/templates/standards/kpi-dictionary.md`
- Templates reference: `platform/templates/README.md` § Standards
- Cross-reference pattern (for linking from consumer documents):
  `platform/templates/product/prd.md` § Cross-references
