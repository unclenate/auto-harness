<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# How to Use This Documentation

This page helps you find the right starting point based on what you are trying to do.
The harness documentation is large — 52 modules, 98 templates, 25 validators, 8 skills, 24 workflows —
but most readers need only a narrow slice at any given time.

<!--
Catalog counts above are verified by:
  modules:    find platform/profiles -name module.yaml | wc -l      (excludes core/agents; profile families only)
  templates:  find platform/templates -type f -name '*.md' ! -name 'README.md' | wc -l
  validators: ls platform/validators/validate-*.sh | wc -l
  skills:     ls -d platform/skills/*/ | wc -l
If you grow the catalog, re-run these and update both this paragraph and the
diagram in "Authority Stack" below.
-->

---

## Reader Paths by Intent

### "I want to adopt the harness for my project"

1. **[Submodule Integration](../workflow/submodule-integration.md)** — the recommended consumption pattern; mount auto-harness as a git submodule for automatic upstream updates
2. [Bootstrap Quickstart](../workflow/bootstrap-quickstart.md) — alternative copy-based flow when submodules aren't viable
3. [Starter Compositions](../compositions/README.md) — pick a manifest template
4. [Validators Overview](../validators/README.md) — understand the enforcement chain
5. [CI Integration](../workflow/ci-integration.md) — wire validators into your pipeline
6. [Troubleshooting](../workflow/troubleshooting.md) — when validators fail

Already have a codebase? Start with
[Brownfield Onboarding](../workflow/brownfield-onboarding.md) instead.

### "I want to understand the constraints and principles"

1. [Kernel Base](../core/kernel/base/README.md) — the governance foundation
2. [Doctrine](../core/kernel/base/doctrine.md) — the design principles
3. [Trust Model](../core/kernel/base/trust-model.md) — the six escalation tiers
4. [Enforcement Model](../core/kernel/base/enforcement-model.md) — how rules become gates
5. [Canonical Records](../core/kernel/base/canonical-records.md) — what is authoritative

### "I want to choose the right modules"

1. [Module Types](../core/registry/module-types.md) — the eight families and their purpose
2. Browse by family in the [Module Library](../../SUMMARY.md#module-library) section of the table of contents
3. Each module's `README.md` explains when to activate it and what it requires
4. [Discovery to Composition](../workflow/discovery-to-composition.md) — a guided process
   for going from an idea to a composed manifest

**Management-overlay posture note:** `privacy-by-design` is default-on for data-handling
projects; `security-static-analysis` is opt-in SAST; `testing-standard` and
`eval-gated-testing` are compatible sibling quality-gates.

### "I'm building a regulated or domain-specialist product"

1. Start with the relevant domain module — [`domains/healthcare-fhir`](../profiles/domains/healthcare-fhir/README.md)
   or [`domains/healthcare-smart-on-fhir`](../profiles/domains/healthcare-smart-on-fhir/README.md)
2. Review [`platform/compositions/healthcare-fhir-app.yaml`](../compositions/healthcare-fhir-app.yaml)
   as a concrete composition example
3. Activate the [`management/privacy-by-design`](../profiles/management/privacy-by-design/README.md)
   overlay (default-on for data-handling projects; covers Cavoukian's 7 principles and
   consumer-declared legal regime)

### "I want to integrate AI agents"

1. [Skills and Agents](../workflow/skills-and-agents.md) — the integration model
2. [Multi-Agent Tool Coordination](../workflow/multi-agent-tool-coordination.md) — per-tool context files, skill paths, approval modes, and known conflict surfaces
3. [Agent Base](../agents/base/README.md) — the foundational cross-agent pack
4. [Agents](../../SUMMARY.md#agents) — tool-specific packs for Claude Code, Codex CLI, Copilot CLI, Cursor, Gemini CLI, Generic LLM, and OpenClaw
5. [Harness-Native Skills](../../SUMMARY.md#harness-native-skills) — governance, testing, web3, onboarding skills
6. [Glossary: Compiled Fragment vs Skill](glossary.md#compiled-fragment) — understand the
   difference between always-on context and on-demand guidance

### "I want to contribute to the harness itself"

1. This page and the [Glossary](glossary.md) — shared terminology
2. [Kernel Base](../core/kernel/base/README.md) — what the kernel provides and protects
3. [Module Types](../core/registry/module-types.md) — how modules are classified
4. [Templates Reference](../templates/README.md) — placeholder conventions
5. [Validators Overview](../validators/README.md) — the test suite and fixture projects

---

## Authority Stack

Not all documentation carries equal weight. When sources conflict, higher tiers take
precedence.

```text
                    ┌─────────────────────┐
                    │   kernel/base        │  Normative: doctrine, trust model,
                    │   doctrine.md        │  lifecycle controls, canonical records.
                    │   trust-model.md     │  These define correct behavior.
                    └─────────┬───────────┘
                              │
                    ┌─────────▼───────────┐
                    │   module.yaml tree   │  Contractual: each module's machine-
                    │   (52 modules)       │  readable governance declaration.
                    │                      │  Validators enforce these.
                    └─────────┬───────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
    ┌─────────▼─────┐ ┌──────▼──────┐ ┌──────▼──────┐
    │  validators   │ │  templates  │ │  workflows  │
    │  (25 scripts)  │ │  (98 files) │ │ (24 guides) │
    │               │ │             │ │             │
    │  Operational: │ │  Generative:│ │  Procedural:│
    │  enforce the  │ │  produce    │ │  how to use │
    │  contract at  │ │  project    │ │  the system │
    │  CI time      │ │  artifacts  │ │  end to end │
    └───────────────┘ └─────────────┘ └─────────────┘
```

**In plain terms:**

- **Kernel doctrine** is normative for behavior — if you're unsure what's allowed, the
  doctrine and trust model are the final word.
- **module.yaml** is the contract — validators read these files to determine what must
  exist, what triggers review, and what companion artifacts are required.
- **Validators** are operational — they enforce the contract. The
  [Troubleshooting](../workflow/troubleshooting.md) guide is the operational reference
  for validator errors.
- **Templates** are generative — they produce project artifacts from skeletons. They
  implement the contract but are not the contract itself.
- **Workflows** are procedural — they explain how to use the system. They describe the
  contract but do not define it.

---

## What Is Not Documentation

The `platform/validators/test/fixtures/` directory contains fixture projects used by the
test suite. These are **test data, not documentation**. They contain intentionally broken
manifests, missing artifacts, and other conditions that exercise validator error paths.
Do not treat fixture content as canonical or exemplary.

For real examples of harnessed projects, see [Examples](../examples/README.md).
