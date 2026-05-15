<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Architecture Overview

**Owner:** @platform-team
**Last updated:** 2024-03-01
**ADRs:** `docs/adr/` (architectural decisions are recorded here)

---

## System Summary

The development harness platform is a file-based governance system distributed as a directory
subtree (`platform/`) included in each governed project. It has no server-side
runtime — governance is enforced by shell scripts run locally and in CI.

The platform consists of three main layers:

1. **Registry layer** — Ruby library (`harness_registry.rb`) that parses manifests and resolves
   the module graph; shared across all validators
2. **Validator layer** — Six shell scripts that enforce specific governance contracts; each
   script calls the registry and exits 0 (pass) or 1 (fail) with structured output
3. **Profile layer** — Module definitions (`module.yaml`) and compiled fragments (Markdown)
   that declare what each module requires and injects into governed projects

---

## Major Components

| Component | Responsibility | Location | Owner |
| --------- | -------------- | -------- | ----- |
| `harness_registry.rb` | Parse `harness.manifest.yaml`; resolve module graph; surface requiredArtifacts and companionRules | `platform/validators/lib/` | @platform-team |
| Validator scripts (6) | Enforce manifest schema, module graph, required artifacts, companion rules, placeholders, agent pack | `platform/validators/` | @platform-team |
| Module profiles | Declare per-module governance: requiredArtifacts, companionRules, validators, reviewGates | `platform/profiles/` | @platform-team |
| Compiled governance fragments | Doctrine, trust model, lifecycle controls — injected into governed projects as Markdown | `platform/core/kernel/base/` | @platform-team |
| Agent Skills | Structured prompts (SKILL.md) for AI coding assistants; loaded by Claude Code, Cursor, Windsurf | `platform/skills/` | @platform-team |
| Templates | Artifact skeletons with `[[PLACEHOLDER]]` tokens; one per required artifact type | `platform/templates/` | @platform-team |
| Compositions | Pre-built `harness.manifest.yaml` starters for common project types | `platform/compositions/` | @platform-team |
| Workflow guides | Human-readable onboarding and operational paths | `platform/workflow/` | @platform-team |
| Test suite | Ruby Minitest unit + integration tests for registry logic and validator scripts | `platform/validators/test/` | @platform-team |

---

## Data Flow: Governance Enforcement

```text
Developer commits to PR
        │
        ▼
GitHub Actions runs harness.yml
        │
        ├── validate-manifest.sh ──────────────┐
        │       └── reads harness.manifest.yaml │
        │                                       │
        ├── validate-module-graph.sh ───────────┤  harness_registry.rb
        │       └── resolves module graph       │  (shared Ruby lib)
        │                                       │
        ├── validate-required-artifacts.sh ─────┤
        │       └── checks file existence        │
        │                                       │
        ├── validate-companions.sh ─────────────┤
        │       └── git diff vs. base branch    │
        │                                       │
        ├── validate-placeholders.sh ───────────┘
        │       └── ripgrep scan for [[...]] tokens
        │
        └── validate-agent-pack.sh
                └── checks AGENTS.md, .claude/settings.json
        │
        ▼
All exit 0 → PR may merge
Any exit 1 → PR blocked with structured error output
```

---

## Key Constraints

- **No runtime server.** The platform is entirely static files + shell scripts. Governance is
  pull-based (validators run when invoked), not push-based (no webhook server).
- **Ruby stdlib only.** The registry library requires no gems. Ruby 3.0+ is sufficient.
- **Manifest-driven.** All governance behavior derives from `harness.manifest.yaml`. No hidden
  configuration files or environment variables affect validator behavior.
- **Additive module composition.** Modules combine without overwriting each other. A governed
  project's effective governance is the union of all active module rules.
