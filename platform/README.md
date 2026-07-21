<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Platform Overview

The `platform/` directory is the source of truth for the Development Harness framework.
Everything that defines the governance contract — modules, validators, templates, skills,
workflows — lives here.

**Version:** Alpha, pre-1.0 — matches [HARNESS.md](../HARNESS.md) `Maturity: Platform (Alpha)` and [SECURITY.md](../SECURITY.md) "alpha maturity"

> **Recent docs additions:** a [glossary](reference/glossary.md) of shared terminology, a
> [how-to-read guide](reference/how-to-read.md) with reader paths by intent and an
> authority stack, a [topic index](reference/index.md), restructured GitBook navigation
> with semantic grouping, folder-level READMEs for
> [compositions](compositions/README.md) and [examples](examples/README.md), and
> `.gitbookignore` exclusion of test fixtures.

For the full introduction to the harness — what it does, trust tiers, module system,
companion rules, templates, and getting started — see the
[top-level README](../README.md).

---

## Directory Structure

```text
platform/
├── core/           # Kernel doctrine, trust model, lifecycle controls, schemas
├── profiles/       # Stack, architecture, data, delivery, management, domain overlays
├── agents/         # AI-tool operating packs: acp, base, claude-code, codex-cli, copilot-cli, cursor, gemini-cli, generic-llm, openclaw
├── skills/         # Agent Skills: harness-governance, harness-testing, harness-web3, harness-onboarding, harness-tools, harness-agentic-interfaces, harness-mcp, harness-digital-twin
├── templates/      # Artifact skeletons — see templates/README.md for placeholder reference
├── validators/     # Validator scripts, shared Ruby library, test suite, fixtures
├── compositions/   # Starter manifests for common project types
├── examples/       # Sample project with all artifacts filled in
├── reference/      # Glossary, how-to-read guide, topic index
└── workflow/       # Guides: bootstrap, discovery, brownfield, CI, troubleshooting
```

---

## Quick Start

| Starting point | Guide |
| -------------- | ----- |
| Raw idea, no stack chosen | [Discovery to Composition](workflow/discovery-to-composition.md) |
| Know your stack, ready to build | [Bootstrap Quickstart](workflow/bootstrap-quickstart.md) |
| Web3 project | [Web3 Bootstrap Quickstart](workflow/bootstrap-web3-quickstart.md) |
| Existing codebase, not built with the harness | [Brownfield Onboarding](workflow/brownfield-onboarding.md) |

**Intake questionnaire:** [templates/discovery/intake-questionnaire.md](templates/discovery/intake-questionnaire.md)
— an 8-section instrument usable with clients, stakeholders, or as a self-interview.

**Starter compositions:** [compositions/](compositions/README.md) — copy the closest match to
`harness.manifest.yaml` and adjust.

---

## Key Reference Pages

- [Glossary](reference/glossary.md) — shared terminology for the harness
- [How to Use This Documentation](reference/how-to-read.md) — reader paths by intent, authority stack
- [Topic Index](reference/index.md) — find any concept across the docs
- [Module Types](core/registry/module-types.md) — the eight families and field reference
- [Templates Reference](templates/README.md) — all templates, placeholder convention, naming rules

---

## Operating Model

Each module (`module.yaml`) declares its own governance contract:

- identity, type, version, dependencies, conflicts
- required and optional artifacts
- sensitive path patterns and companion artifact rules
- validator IDs and human review gates
- agent adapter paths and compiled fragments
- recommended skills (Agent Skills format + OpenClaw/ClawHub)

Projects compose modules through `harness.manifest.yaml`. The validator chain enforces
the contract at development time and in CI.
