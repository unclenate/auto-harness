<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# HARNESS.md

This sample project uses the modular harness manifest at `harness.manifest.yaml` to govern
a SaaS web-app that ships an **in-product agentic interface** — a CopilotKit-style copilot
sidebar plus a small generative-UI surface.

The hypothetical product is "Lattice" — an analytics SaaS for small teams that lets users
ask questions in natural language, get charts rendered in-product, and trigger common
actions (export, share, schedule) via an agent rather than menu hunting.

Source modules:

- `kernel/base`
- `node-typescript`
- `web-app`
- `agentic-interfaces`
- `prototype`
- `interview-driven`
- `base`

The agent surface is governed by `domains/agentic-interfaces`. The canonical artifacts are:

- `docs/agentic-interface/design.md` — flavor, runtime, action surface, renderer contract, HITL checkpoints
- `docs/agentic-interface/risk-register.md` — agentic-UI-specific risks

See [`platform/profiles/domains/agentic-interfaces/README.md`](../../../profiles/domains/agentic-interfaces/README.md)
for the overlay's three-flavor map, companion rules, and review gates.

The product follows the `interview-driven` management overlay — monolithic PRD + plan +
spec-prompt — because the team is small enough that splitting docs would slow them down.
