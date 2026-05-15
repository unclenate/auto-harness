<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Operational Readiness

Operational readiness is modular.

The kernel requires projects to explicitly decide and document:

- who owns a release decision
- who owns rollback authority
- how incidents are recorded
- where risks are tracked
- which environments or runtime states exist

Delivery overlays decide how much rigor is mandatory. A prototype should not inherit production SaaS ceremony by default, and a production SaaS project must not be allowed to skip it.
