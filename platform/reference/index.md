<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Topic Index

A curated cross-reference for concepts that span multiple pages. Use this when you know
the topic but not which page covers it.

---

## Trust and Access Control

- Trust tier definitions — [Trust Model](../core/kernel/base/trust-model.md)
- When human review is required — [Enforcement Model](../core/kernel/base/enforcement-model.md)
- Sensitive path patterns — each module's `module.yaml` > `sensitivePaths`
- Agent self-elevation prohibition — [Trust Model](../core/kernel/base/trust-model.md) and [Doctrine](../core/kernel/base/doctrine.md)

## Companion Rules

- What companion rules are — [Glossary](glossary.md#companion-rule)
- How they are declared — [Module Types](../core/registry/module-types.md) > `companionRules` field
- How they are enforced — [validate-companions.sh](../validators/validate-companions.sh)
- Troubleshooting failures — [Troubleshooting](../workflow/troubleshooting.md) > Companion rule errors
- PRD and ADR as companion artifacts — [Canonical Records](../core/kernel/base/canonical-records.md)

## Disabled Validations

- How to disable a validator — [Validators Overview](../validators/README.md) > Disabled validations
- Brownfield progressive re-enablement — [Brownfield Onboarding](../workflow/brownfield-onboarding.md)
- Manifest `overrides.disabledValidations` — [Module Types](../core/registry/module-types.md)

## Artifacts and Templates

- Required vs optional artifacts — [Glossary](glossary.md#required-artifact)
- Canonical vs derivative records — [Canonical Records](../core/kernel/base/canonical-records.md)
- Template placeholder convention — [Templates Reference](../templates/README.md)
- Template naming convention — [Templates Reference](../templates/README.md) > Template Naming Convention
- ADR and PRD as numbered records — [Glossary](glossary.md#adr-architecture-decision-record)

## Modules and Composition

- Module families — [Module Types](../core/registry/module-types.md)
- Starter compositions — [Compositions](../compositions/README.md)
- Module field reference — [Module Types](../core/registry/module-types.md) > Module Field Reference
- Compiled fragments vs skills — [Module Types](../core/registry/module-types.md) > compiledFragments vs. recommendedSkills
- Dependency and conflict resolution — [validate-module-graph.sh](../validators/validate-module-graph.sh)

## Validators and CI

- Validator overview — [Validators](../validators/README.md)
- CI workflow setup — [CI Integration](../workflow/ci-integration.md)
- Every error message explained — [Troubleshooting](../workflow/troubleshooting.md)
- Test suite and fixtures — [Validators](../validators/README.md) > Test Suite

## Agent Integration

- Skills standard — [Skills and Agents](../workflow/skills-and-agents.md)
- Agent packs (base, claude-code, generic-llm) — [Agents](#) in the Module Library
- Compiled fragments vs skills — [Glossary](glossary.md#compiled-fragment)
- Harness-native skills — [Skills](#) in the table of contents

## Workflows

- New project bootstrap — [Bootstrap Quickstart](../workflow/bootstrap-quickstart.md)
- Web3 bootstrap — [Web3 Bootstrap Quickstart](../workflow/bootstrap-web3-quickstart.md)
- Idea to manifest — [Discovery to Composition](../workflow/discovery-to-composition.md)
- Existing codebase — [Brownfield Onboarding](../workflow/brownfield-onboarding.md)
- Troubleshooting validators — [Troubleshooting](../workflow/troubleshooting.md)
