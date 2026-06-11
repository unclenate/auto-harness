<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Architecture Overview

This document is the harness-required architecture-overview artifact
for projects that activate any module with that requirement (most
delivery and architecture overlays). It captures the *project's*
architectural shape — what it ships, how the pieces fit, and how the
runtime topology composes.

> **This file is a project-level artifact, not a harness-level
> reference.** For the auto-harness *framework's* own architecture,
> see [`docs/architecture/diagrams.md`](diagrams.md) (visual
> reference) and [`docs/operating-principles.md`](../operating-principles.md)
> (durable how-this-project-works truths).

## What belongs here

Auto-harness ships this file as a stub so consumer projects have a
canonical place to put their architecture overview when they activate
a module that requires it. The expected sections vary by project
shape, but the common spine is:

1. **System context** — what the system does, who uses it, what it
   integrates with at the outermost boundary
2. **Component decomposition** — the major internal pieces and how
   they communicate
3. **Data flows** — request paths, event sequences, batch processes
4. **External integrations** — APIs consumed, APIs published, third-
   party services, infrastructure dependencies
5. **Topology / deployment shape** — runtime processes, services,
   regions, scaling characteristics
6. **Architectural constraints** — non-functional requirements,
   regulatory constraints, performance budgets

## auto-harness's own architecture

Auto-harness *itself* (the framework) is a documentation + validator +
template surface; it has no runtime. Its architecture is the
governance contract:

- **`platform/`** is the framework's source of truth — modules,
  validators, templates, skills, agent packs, workflows, examples.
- **`docs/`** is the project's self-governance — ADRs, PRDs, OPPs,
  observations, the canonical roadmap.
- **CI** (in `.github/workflows/harness.yml`) runs the validator suite
  on every PR against `main`.

See [`docs/architecture/diagrams.md`](diagrams.md) Diagram 1
(Component Composition) for the visual reference of how these layers
relate.

## When this file is required

Several modules list `docs/architecture/overview.md` as a required or
recommended artifact. A non-exhaustive list:

- `delivery/production-saas`, `delivery/internal-platform`
- `architectures/web-app`, `architectures/api-service`,
  `architectures/event-driven`, `architectures/agentic-ui`,
  `architectures/mcp-server`
- `domains/agentic-interfaces`, `domains/supabase`,
  `domains/media-pipeline`, `domains/web3`,
  `domains/cryptographic-identity`
- `stacks/node-typescript`, `stacks/python`,
  `stacks/node-javascript`, `stacks/coffeescript`

Run `bash platform/validators/validate-required-artifacts.sh
harness.manifest.yaml .` to confirm whether your active manifest
requires it.

## How auto-harness itself fills this

The auto-harness repository activates `delivery/internal-platform` and
several management modules; per its manifest, this overview file is
required. The content above describes the harness's own architecture
in summary; for the full picture see `platform/README.md` and the
component-composition diagram.
