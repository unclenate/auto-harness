<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# [[PROJECT_NAME]] — Distilled Learnings (Dormant)

**Status:** Dormant template — kept for compatibility with consumer
projects that scaffolded knowledge surfaces before
[ADR-0014](../../../docs/adr/ADR-0014-sunset-distilled-learnings.md) (2026-05-25)
and [PRD-0011](../../../docs/requirements/PRD-0011-distilled-learnings-disposition.md)
sunset this file as a `requiredArtifact` of `management/knowledge-capture`.

If you are scaffolding a new consumer project today, you do **not** need
this file. The `management/knowledge-capture` module v1.2.0+ no longer
declares it as required. The curated longitudinal destination is
`docs/operating-principles.md` — patterns crystallize there when they
appear across multiple observations in `shared-observations.md`.

If you are an existing consumer with `distilled-learnings.md` content,
you have three options:

1. **Keep it as-is.** The file is no longer required but is also not
   prohibited. If your team has been actively curating into it, the
   sunset does not delete your content.
2. **Migrate to operating-principles.** Promote each existing
   distilled-learning into a section of `docs/operating-principles.md`,
   then convert `distilled-learnings.md` into a dormancy pointer
   matching the upstream pattern at
   [`docs/knowledge/distilled-learnings.md`](../../../docs/knowledge/distilled-learnings.md).
3. **Maintain a fork-local extension.** If your team genuinely needs a
   separate curated-synthesis surface distinct from operating-principles,
   keep the file and document the local exception in your project's
   change log.

For the rationale, the alternatives weighed, and the explicit revisit
triggers that would justify reintroducing this file as a required
artifact, see
[ADR-0014](../../../docs/adr/ADR-0014-sunset-distilled-learnings.md).
