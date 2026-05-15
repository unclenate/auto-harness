<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Kernel Doctrine

The kernel defines rules that are durable across stacks, domains, and delivery models.

## Principles

- Ownership is explicit.
- Review is a knowledge-distribution mechanism, not a rubber stamp.
- Documentation is part of the change, not follow-up work.
- Secrets never belong in tracked artifacts.
- Migrations, releases, and incident response are operational events.
- AI acceleration increases the need for controls, not the license to skip them.

## Boundaries

The kernel does not define:

- language or framework commands
- path assumptions for application code
- vendor-specific service layouts
- environment topology beyond the requirement to document and govern it

Those belong in overlays.
