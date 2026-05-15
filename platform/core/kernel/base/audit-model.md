<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Audit Model

Auditability comes from explicit records and predictable control points.

## Required Audit Surfaces

- manifest declaring active modules
- module metadata declaring validators and review gates
- project-facing canonical records
- CI or local validation results
- version control history and review discussions

## Non-Goals

- command logs are helpful but not canonical
- generated summaries do not replace approvals
- validator success does not certify production readiness on its own
