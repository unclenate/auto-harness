# Development Harness Platform

## Getting Started

* [Introduction](README.md)
* [Bootstrap Quickstart](workflow/bootstrap-quickstart.md)
* [Web3 Bootstrap Quickstart](workflow/bootstrap-web3-quickstart.md)
* [Discovery to Composition](workflow/discovery-to-composition.md)
* [Skills and Agents](workflow/skills-and-agents.md)

## Core Governance

* [Doctrine](core/kernel/base/doctrine.md)
* [Trust Model](core/kernel/base/trust-model.md)
* [Lifecycle Controls](core/kernel/base/lifecycle-controls.md)
* [Enforcement Model](core/kernel/base/enforcement-model.md)
* [Audit Model](core/kernel/base/audit-model.md)
* [Operational Readiness](core/kernel/base/ops-readiness.md)
* [Canonical Records](core/kernel/base/canonical-records.md)

## Module Reference

* [Module Types](core/registry/module-types.md)

### Stacks

Language, runtime, and framework adaptations.

* [Node / TypeScript](profiles/stacks/node-typescript/README.md)
* [Python](profiles/stacks/python/README.md)

### Architectures

Interaction and deployment patterns.

* [Web App](profiles/architectures/web-app/README.md)
* [API Service](profiles/architectures/api-service/README.md)
* [Event Driven](profiles/architectures/event-driven/README.md)

### Data

Storage and state-management overlays.

* [Relational Postgres](profiles/data/relational-postgres/README.md)
* [Document Store](profiles/data/document-store/README.md)
* [Object Storage](profiles/data/object-storage/README.md)

### Delivery

Lifecycle and operational posture overlays.

* [Prototype](profiles/delivery/prototype/README.md)
* [Production SaaS](profiles/delivery/production-saas/README.md)
* [Internal Platform](profiles/delivery/internal-platform/README.md)

### Management

Product, project, and program governance overlays.

* [Discovery Intake](profiles/management/discovery-intake/README.md)
* [Product Lite](profiles/management/product-lite/README.md)
* [Project Standard](profiles/management/project-standard/README.md)
* [Program Lite](profiles/management/program-lite/README.md)

### Domains

Vendor, ecosystem, or specialist overlays.

* [Supabase](profiles/domains/supabase/README.md)
* [Media Pipeline](profiles/domains/media-pipeline/README.md)
* [Web3](profiles/domains/web3/README.md)
* [GitBook](profiles/domains/gitbook/README.md)

### Agents

AI-tool packs and operating adapters.

* [Base](agents/base/README.md)
* [Claude Code](agents/claude-code/README.md)
* [Generic LLM](agents/generic-llm/README.md)

## Harness-Native Skills

Skills in Agent Skills format, discoverable by Claude Code, VS Code Copilot, Cursor, and
other compliant clients. Install to `.agents/skills/` or `.claude/skills/`.

* [harness-governance](skills/harness-governance/SKILL.md)
* [harness-web3](skills/harness-web3/SKILL.md)

## Starter Compositions

Pre-built manifests for common project types. Copy the closest match to
`harness.manifest.yaml` and adjust.

* [New Product Discovery](compositions/new-product-discovery.yaml) — discovery phase, no stack chosen
* [Node Web SaaS + Postgres](compositions/node-web-saas-postgres.yaml) — Node/TS + PostgreSQL web app
* [Python API Service + Postgres](compositions/python-api-service-postgres.yaml) — Python API backend
* [Research Pipeline (Python + Object Storage)](compositions/research-pipeline-python-object-storage.yaml) — data / ML pipeline
* [Web3 Risk Analytics](compositions/web3-risk-analytics.yaml) — blockchain-integrated Python platform

## Templates

### Discovery

* [Intake Questionnaire](templates/discovery/intake-questionnaire.md)
* [MVP Scope](templates/discovery/mvp-scope.md)
* [Starting Assets](templates/discovery/starting-assets.md)

### Product

* [Problem Statement](templates/product/problem-statement.md)
* [Personas](templates/product/personas.md)
* [Requirements](templates/product/requirements.md)
* [Release Intent](templates/product/release-intent.md)

### Project

* [Scope Plan](templates/project/scope-plan.md)
* [Milestones](templates/project/milestones.md)
* [Change Log](templates/project/change-log.md)
* [Dependency Log](templates/project/dependency-log.md)

### Program

* [Workstream Map](templates/program/workstream-map.md)
* [Stakeholder Report](templates/program/stakeholder-report.md)
* [Governance Cadence](templates/program/governance-cadence.md)

### Architecture and Operations

* [Architecture Overview](templates/architecture-overview.md)
* [ADR](templates/adr.md)
* [Release Checklist](templates/release-checklist.md)
* [Risk Register](templates/risk-register.md)
* [Incident Response](templates/incident.md)
* [Ownership Map](templates/ownership-map.md)
* [Runbook Index](templates/ops/runbook-index.md)
* [Runbook Template](templates/ops/runbook-template.md)

### Web3

* [Chain Configuration](templates/web3/chain-config.md)
* [Contract Registry](templates/web3/contract-registry.md)
* [Token Strategy](templates/web3/token-strategy.md)
* [Risk Register — Web3](templates/web3/risk-register-web3.md)
* [ADR — Web3 Variant](templates/web3/adr-web3.md)
* [Web3 Intake Supplement](templates/web3/web3-intake-supplement.md)

### Documentation

* [Project SUMMARY.md](templates/docs/SUMMARY.md)
* [Templates Reference](templates/README.md)

## Validators and CI

* [CI Integration](workflow/ci-integration.md)
* [Troubleshooting](workflow/troubleshooting.md)

## Examples

### Node Web SaaS Postgres

* [Discovery: Intake Questionnaire](examples/sample-projects/node-web-saas-postgres/docs/discovery/intake-questionnaire.md)
* [Discovery: MVP Scope](examples/sample-projects/node-web-saas-postgres/docs/discovery/mvp-scope.md)
* [Product: Problem Statement](examples/sample-projects/node-web-saas-postgres/docs/product/problem-statement.md)
* [Product: Personas](examples/sample-projects/node-web-saas-postgres/docs/product/personas.md)
* [Product: Requirements](examples/sample-projects/node-web-saas-postgres/docs/product/requirements.md)
* [Product: Release Intent](examples/sample-projects/node-web-saas-postgres/docs/product/release-intent.md)
* [Architecture Overview](examples/sample-projects/node-web-saas-postgres/docs/architecture/overview.md)
* [Database: Migration Readiness](examples/sample-projects/node-web-saas-postgres/docs/database/migration-readiness.md)
* [Security: Risk Register](examples/sample-projects/node-web-saas-postgres/docs/security/risk-register.md)
* [Ops: Environment Inventory](examples/sample-projects/node-web-saas-postgres/docs/ops/environment-inventory.md)
* [Ops: Release Checklist](examples/sample-projects/node-web-saas-postgres/docs/ops/release-checklist.md)
* [Ops: Rollback Checklist](examples/sample-projects/node-web-saas-postgres/docs/ops/rollback-checklist.md)
* [Project: Scope Plan](examples/sample-projects/node-web-saas-postgres/docs/project/scope-plan.md)
* [Project: Milestones](examples/sample-projects/node-web-saas-postgres/docs/project/milestones.md)
* [Project: Change Log](examples/sample-projects/node-web-saas-postgres/docs/project/change-log.md)
* [Project: Dependency Log](examples/sample-projects/node-web-saas-postgres/docs/project/dependency-log.md)
* [Operating Principles](examples/sample-projects/node-web-saas-postgres/docs/operating-principles.md)
