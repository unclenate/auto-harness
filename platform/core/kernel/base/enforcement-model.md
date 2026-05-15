<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Enforcement Model

The modular harness keeps five categories distinct:

## Doctrine

Human-readable operating rules that define intent and constraints.

## Template

Reusable artifact skeletons with expected structure.

## Generated Or Instantiated Artifact

Project-facing files required by active modules.

## Validator

Executable checks that can verify presence, consistency, or path-based policy.

## Review Gate

Human checkpoints that validate semantics, quality, and risk beyond machine checks.

## Runtime Or Operational Control

Tool permissions, CODEOWNERS, CI jobs, deployment gates, hooks, or secret-management controls.

These should never be collapsed into one catch-all policy file.
