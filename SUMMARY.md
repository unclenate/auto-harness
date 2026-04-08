# Development Harness

## Start Here

* [Introduction](README.md)
* [Platform Overview](platform/README.md)
* [How to Use This Documentation](platform/reference/how-to-read.md)
* [Glossary](platform/reference/glossary.md)
* [Topic Index](platform/reference/index.md)

## Workflows

Step-by-step guides for adopting and operating the harness.

* [Bootstrap Quickstart](platform/workflow/bootstrap-quickstart.md)
* [Web3 Bootstrap Quickstart](platform/workflow/bootstrap-web3-quickstart.md)
* [Discovery to Composition](platform/workflow/discovery-to-composition.md)
* [Brownfield Onboarding](platform/workflow/brownfield-onboarding.md)
* [Skills and Agents](platform/workflow/skills-and-agents.md)

## Kernel — Governance Foundation

The universal rules that apply to every harnessed project, regardless of modules.

* [Kernel Base](platform/core/kernel/base/README.md)
* [Doctrine](platform/core/kernel/base/doctrine.md)
* [Trust Model](platform/core/kernel/base/trust-model.md)
* [Lifecycle Controls](platform/core/kernel/base/lifecycle-controls.md)
* [Enforcement Model](platform/core/kernel/base/enforcement-model.md)
* [Audit Model](platform/core/kernel/base/audit-model.md)
* [Operational Readiness](platform/core/kernel/base/ops-readiness.md)
* [Canonical Records](platform/core/kernel/base/canonical-records.md)

## Concepts and Reference

* [Module Types](platform/core/registry/module-types.md) — families, field reference, compiled fragments vs skills
* [Glossary](platform/reference/glossary.md) — shared terminology
* [Topic Index](platform/reference/index.md) — cross-reference by concept

## Module Library

### Stacks

Language, runtime, and framework adaptations.

* [Node / TypeScript](platform/profiles/stacks/node-typescript/README.md)
* [Python](platform/profiles/stacks/python/README.md)

### Architectures

Interaction and deployment patterns.

* [Web App](platform/profiles/architectures/web-app/README.md)
* [API Service](platform/profiles/architectures/api-service/README.md)
* [Event Driven](platform/profiles/architectures/event-driven/README.md)

### Data

Storage and state-management overlays.

* [Relational Postgres](platform/profiles/data/relational-postgres/README.md)
* [Document Store](platform/profiles/data/document-store/README.md)
* [Object Storage](platform/profiles/data/object-storage/README.md)

### Delivery

Lifecycle and operational posture overlays.

* [Prototype](platform/profiles/delivery/prototype/README.md)
* [Production SaaS](platform/profiles/delivery/production-saas/README.md)
* [Internal Platform](platform/profiles/delivery/internal-platform/README.md)

### Management

Product, project, and program governance overlays.

* [Discovery Intake](platform/profiles/management/discovery-intake/README.md)
* [Product Lite](platform/profiles/management/product-lite/README.md)
* [Project Standard](platform/profiles/management/project-standard/README.md)
* [Program Lite](platform/profiles/management/program-lite/README.md)
* [Testing Standard](platform/profiles/management/testing-standard/README.md)

### Domains

Vendor, ecosystem, or specialist overlays.

* [Supabase](platform/profiles/domains/supabase/README.md)
* [Media Pipeline](platform/profiles/domains/media-pipeline/README.md)
* [Web3](platform/profiles/domains/web3/README.md)
* [GitBook](platform/profiles/domains/gitbook/README.md)

### Agents

AI-tool packs and operating adapters.

* [Base](platform/agents/base/README.md)
* [Claude Code](platform/agents/claude-code/README.md)
* [Generic LLM](platform/agents/generic-llm/README.md)

## Operating the Harness

### Validators and CI

* [Validators Overview](platform/validators/README.md)
* [validate-manifest.sh](platform/validators/validate-manifest.sh)
* [validate-module-graph.sh](platform/validators/validate-module-graph.sh)
* [validate-required-artifacts.sh](platform/validators/validate-required-artifacts.sh)
* [validate-placeholders.sh](platform/validators/validate-placeholders.sh)
* [validate-agent-pack.sh](platform/validators/validate-agent-pack.sh)
* [validate-companions.sh](platform/validators/validate-companions.sh)
* [Shared Library: harness\_registry.rb](platform/validators/lib/harness_registry.rb)
* [CI Integration](platform/workflow/ci-integration.md)
* [Troubleshooting](platform/workflow/troubleshooting.md)

### Test Suite

* [Unit Tests: HarnessRegistry](platform/validators/test/test_harness_registry.rb)
* [Integration Tests: Validators](platform/validators/test/test_validators_integration.rb)

## Harness-Native Skills

Skills in Agent Skills format, discoverable by Claude Code, VS Code Copilot, Cursor, and
other compliant clients. Install to `.agents/skills/` or `.claude/skills/`.

* [harness-governance](platform/skills/harness-governance/SKILL.md)
* [harness-web3](platform/skills/harness-web3/SKILL.md)
* [harness-testing](platform/skills/harness-testing/SKILL.md)
* [harness-onboarding](platform/skills/harness-onboarding/SKILL.md)

## Compositions and Examples

### Starter Compositions

Pre-built manifests for common project types. Copy the closest match to
`harness.manifest.yaml` and adjust.

* [Compositions Overview](platform/compositions/README.md)
* [Brownfield Lite](platform/compositions/brownfield-lite.yaml)
* [New Product Discovery](platform/compositions/new-product-discovery.yaml)
* [Node Web SaaS + Postgres](platform/compositions/node-web-saas-postgres.yaml)
* [Python API Service + Postgres](platform/compositions/python-api-service-postgres.yaml)
* [Research Pipeline (Python + Object Storage)](platform/compositions/research-pipeline-python-object-storage.yaml)
* [Web3 Risk Analytics](platform/compositions/web3-risk-analytics.yaml)

### Examples

* [Examples Overview](platform/examples/README.md)

#### Composed Entrypoints

Sample HARNESS.md, AGENTS.md, and CLAUDE.md demonstrating how a project's agent adapter
files reference the harness governance contract.

* [HARNESS.md](platform/examples/composed-entrypoints/HARNESS.md)
* [AGENTS.md](platform/examples/composed-entrypoints/AGENTS.md)
* [CLAUDE.md](platform/examples/composed-entrypoints/CLAUDE.md)

#### Node Web SaaS Postgres — Sample Project

A complete sample project with all governance artifacts filled in.

* [HARNESS.md](platform/examples/sample-projects/node-web-saas-postgres/HARNESS.md)
* [AGENTS.md](platform/examples/sample-projects/node-web-saas-postgres/AGENTS.md)
* [CLAUDE.md](platform/examples/sample-projects/node-web-saas-postgres/CLAUDE.md)
* [Discovery: Intake Questionnaire](platform/examples/sample-projects/node-web-saas-postgres/docs/discovery/intake-questionnaire.md)
* [Discovery: MVP Scope](platform/examples/sample-projects/node-web-saas-postgres/docs/discovery/mvp-scope.md)
* [Product: Problem Statement](platform/examples/sample-projects/node-web-saas-postgres/docs/product/problem-statement.md)
* [Product: Personas](platform/examples/sample-projects/node-web-saas-postgres/docs/product/personas.md)
* [Product: Requirements](platform/examples/sample-projects/node-web-saas-postgres/docs/product/requirements.md)
* [Product: Release Intent](platform/examples/sample-projects/node-web-saas-postgres/docs/product/release-intent.md)
* [Architecture Overview](platform/examples/sample-projects/node-web-saas-postgres/docs/architecture/overview.md)
* [Database: Migration Readiness](platform/examples/sample-projects/node-web-saas-postgres/docs/database/migration-readiness.md)
* [Security: Risk Register](platform/examples/sample-projects/node-web-saas-postgres/docs/security/risk-register.md)
* [Ops: Environment Inventory](platform/examples/sample-projects/node-web-saas-postgres/docs/ops/environment-inventory.md)
* [Ops: Release Checklist](platform/examples/sample-projects/node-web-saas-postgres/docs/ops/release-checklist.md)
* [Ops: Rollback Checklist](platform/examples/sample-projects/node-web-saas-postgres/docs/ops/rollback-checklist.md)
* [Project: Scope Plan](platform/examples/sample-projects/node-web-saas-postgres/docs/project/scope-plan.md)
* [Project: Milestones](platform/examples/sample-projects/node-web-saas-postgres/docs/project/milestones.md)
* [Project: Change Log](platform/examples/sample-projects/node-web-saas-postgres/docs/project/change-log.md)
* [Project: Dependency Log](platform/examples/sample-projects/node-web-saas-postgres/docs/project/dependency-log.md)
* [Operating Principles](platform/examples/sample-projects/node-web-saas-postgres/docs/operating-principles.md)

## Templates

### Discovery

* [Intake Questionnaire](platform/templates/discovery/intake-questionnaire.md)
* [MVP Scope](platform/templates/discovery/mvp-scope.md)
* [Starting Assets](platform/templates/discovery/starting-assets.md)

### Product

* [Problem Statement](platform/templates/product/problem-statement.md)
* [Personas](platform/templates/product/personas.md)
* [Requirements](platform/templates/product/requirements.md)
* [Release Intent](platform/templates/product/release-intent.md)
* [PRD](platform/templates/product/prd.md)

### Project

* [Scope Plan](platform/templates/project/scope-plan.md)
* [Milestones](platform/templates/project/milestones.md)
* [Change Log](platform/templates/project/change-log.md)
* [Dependency Log](platform/templates/project/dependency-log.md)

### Program

* [Workstream Map](platform/templates/program/workstream-map.md)
* [Stakeholder Report](platform/templates/program/stakeholder-report.md)
* [Governance Cadence](platform/templates/program/governance-cadence.md)

### Testing

* [Test Strategy](platform/templates/testing/test-strategy.md)
* [Coverage Thresholds](platform/templates/testing/coverage-thresholds.md)
* [Test Plan](platform/templates/testing/test-plan.md)

### Governance

* [Operating Principles](platform/templates/operating-principles.md)

### Architecture and Operations

* [Architecture Overview](platform/templates/architecture-overview.md)
* [ADR](platform/templates/adr.md)
* [Release Checklist](platform/templates/release-checklist.md)
* [Environment Inventory](platform/templates/ops/environment-inventory.md)
* [Rollback Checklist](platform/templates/ops/rollback-checklist.md)
* [Risk Register](platform/templates/risk-register.md)
* [Incident Response](platform/templates/incident.md)
* [Ownership Map](platform/templates/ownership-map.md)
* [Runbook Index](platform/templates/ops/runbook-index.md)
* [Runbook Template](platform/templates/ops/runbook-template.md)

### Database

* [Migration Readiness](platform/templates/database/migration-readiness.md)

### Web3

* [Chain Configuration](platform/templates/web3/chain-config.md)
* [Contract Registry](platform/templates/web3/contract-registry.md)
* [Token Strategy](platform/templates/web3/token-strategy.md)
* [Risk Register — Web3](platform/templates/web3/risk-register-web3.md)
* [ADR — Web3 Variant](platform/templates/web3/adr-web3.md)
* [Web3 Intake Supplement](platform/templates/web3/web3-intake-supplement.md)

### Documentation

* [Project GitBook Stub (SUMMARY.md)](platform/templates/docs/SUMMARY.md)
* [Templates Reference](platform/templates/README.md)
