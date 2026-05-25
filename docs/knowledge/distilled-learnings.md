<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# auto-harness — Distilled Learnings (Dormant)

**Status:** Dormant since 2026-05-25 ([ADR-0014](../adr/ADR-0014-sunset-distilled-learnings.md), [PRD-0011](../requirements/PRD-0011-distilled-learnings-disposition.md))

This file is retained as a historical pointer. The curated longitudinal
synthesis function it was originally created for is now served by
[`docs/operating-principles.md`](../operating-principles.md), which has
absorbed the role in practice (see operating-principles § 7 and § 8 as
concrete examples of cross-observation synthesis). Two destinations
whose change-classes collapsed into one are now one destination —
consistent with operating-principle § 7.

The `management/knowledge-capture` module no longer requires this file.
The cycle-end distillation trigger rule's satisfier set shrank from
three destinations to two
([`shared-observations.md`](shared-observations.md) and
[`operating-principles.md`](../operating-principles.md)). See
[ADR-0014](../adr/ADR-0014-sunset-distilled-learnings.md) for the
decision rationale, the alternatives weighed, and the explicit revisit
triggers under which this dormancy could be reversed.

For the originating evidence and the failure-mode analysis, see the
paired observations in
[`shared-observations.md`](shared-observations.md) (2026-05-25,
*"Declared knowledge surfaces without an inbound-flow trigger silently
die"* and *"Sunsetting a declared-but-unused mechanism must rule out
replicating the failure mode at the surviving destination"*).
