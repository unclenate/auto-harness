<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# [[PROJECT_NAME]] — Opportunity Candidates Index

**Owner:** [[OWNER]] | **Last Updated:** YYYY-MM-DD

Organizational index of opportunity candidates filed in this directory. The
canonical record for each candidate is its own `OPP-NNNN-slug.md` file —
this index exists only to group, cluster, or annotate them for human readers.

> **Scope of this file.** This file is *organizational*, not *structural*.
> Editing this file does **not** require an ADR — the companion-rule floor on
> `README.md` applies only to policy changes. Add, rename, or remove cluster
> headings freely as your candidate set evolves. The audit-trail floor on
> individual `OPP-NNNN-*.md` files still applies.

---

## How to use this file

- Group candidates under cluster headings that reflect how your team
  reasons about them (theme, milestone, sponsor, status, etc.). Pick a
  grouping that helps reviewers, not one that constrains contributors.
- Each entry is a single line: `- [OPP-NNNN](OPP-NNNN-slug.md) — one-line thesis`.
- Avoid restating policy here. If you find yourself writing about *how*
  candidates should be captured, that belongs in `README.md` (and the
  edit will require an ADR).
- Sort clusters by salience to readers, not by candidate number.

---

## Index of Current Candidates

Replace this section with your project's clusters. Example shape:

```markdown
### Cluster heading 1

- [OPP-NNNN](OPP-NNNN-slug.md) — short thesis line

### Cluster heading 2

- [OPP-NNNN](OPP-NNNN-slug.md) — short thesis line
```

---

## References

- Policy: `README.md` (this directory)
- Per-candidate template: `platform/templates/opportunity/opp-template.md`
- Module definition: `platform/profiles/management/opportunity-capture/module.yaml`
