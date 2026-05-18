<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# `legacy/` — Archived Historical Files

Nothing in this directory is canonical. It is preserved as a snapshot of the pre-modular state of the project so future readers can understand where the harness's design choices came from. Closes quality-audit finding L1-12.

## Contents

| File | What it was | Why it's still here |
|---|---|---|
| `v1-monolith-prompt.txt` | The original single-file prompt that produced the first auto-harness instance — before the modular kernel/templates/validators split. | Documents what the harness replaced and the design problems that motivated breaking the monolith apart. ADR-0001 cites it as the "before" state. |
| `Docs.pdf` | An early printed snapshot of the harness's documentation surface, predating the GitBook publish path. | Reference for the documentation-architecture evolution; the current published surface is everything under `docs/` plus `SUMMARY.md`. |
| `project-specific/` | One-off files that belonged to a specific consumer project the harness was extracted from. | Provenance — if someone needs to trace why a specific module decision was made, this directory holds the original context. |

## Why these files aren't deleted

The harness's modular kernel + module library is one possible answer to the question "how do you give an AI-assisted project durable governance without a 200-page operating manual?" Keeping the pre-modular monolith visible makes the "before / after" diff legible — the size, the duplication, the lack of validation — and ADR-0001 references this directory as evidence for the modular-governance decision.

## What to read for current state instead

| What you want | Go here |
|---|---|
| The current modular kernel | [`platform/core/kernel/base/`](../platform/core/kernel/base/README.md) |
| The current module library | [`platform/profiles/`](../platform/profiles/) (browse on GitHub) |
| The current published documentation | [`SUMMARY.md`](../SUMMARY.md) |
| The decision that broke the monolith apart | [`docs/adr/ADR-0001-modular-governance.md`](../docs/adr/ADR-0001-modular-governance.md) |
