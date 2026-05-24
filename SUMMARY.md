<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Development Harness

## Start Here

* [Introduction](README.md)
* [Platform Overview](platform/README.md)
* [How to Use This Documentation](platform/reference/how-to-read.md)
* [Glossary](platform/reference/glossary.md)
* [Topic Index](platform/reference/index.md)

### Entry Points by Audience

These five files share the repository root. Each has a distinct job — pick the one that matches your role first, then read the others as needed.

* [README.md](README.md) — Repo and GitBook front door. Best first read for humans.
* [HARNESS.md](HARNESS.md) — Project-level governance entrypoint. Best first read when you want to know which modules are active and where the governance contract lives.
* [AGENTS.md](AGENTS.md) — Cross-agent operating manual. Best first read for any AI tooling (Cursor, Copilot, Codex, OpenClaw, Gemini CLI). First-session workflow lives here.
* [CLAUDE.md](CLAUDE.md) — Claude Code load order. Thin shim that points Claude Code at the canonical files above in the right sequence.
* [TOOLS.md](TOOLS.md) — Environment-specific tool registry. Loaded on demand by agents that use MCP developer tools (Linear, Slack, etc.).

## Adoption Workflows

How to start using the harness on a project. Walk through one of these once per project.

* [Submodule Integration](platform/workflow/submodule-integration.md) — recommended consumption pattern
* [Bootstrap Quickstart](platform/workflow/bootstrap-quickstart.md) — greenfield, stack known
* [Web3 Bootstrap Quickstart](platform/workflow/bootstrap-web3-quickstart.md) — Web3-specific bootstrap
* [Discovery to Composition](platform/workflow/discovery-to-composition.md) — idea → manifest
* [Brownfield Onboarding](platform/workflow/brownfield-onboarding.md) — existing codebase

## Day-to-Day Workflows

How to use the harness during normal development on a project that has already adopted it.

* [Skills and Agents](platform/workflow/skills-and-agents.md)
* [CI Integration](platform/workflow/ci-integration.md)
* [Standards Pattern](platform/workflow/standards-pattern.md)
* [Cycle-End Distillation](platform/workflow/cycle-end-distillation.md) — when and where to capture institutional learning
* [Modify Composition Mid-Project](platform/workflow/modify-composition-mid-project.md) — add / change / remove modules in an active manifest
* [Incident Response](platform/workflow/incident-response.md) — operational workflow for production incidents and postmortems
* [Agentic Interface Integration](platform/workflow/agentic-interface-integration.md) — operator workflow for in-product agent surfaces
* [MCP Server Build](platform/workflow/mcp-server-build.md) — operator workflow for projects that ship an MCP server
* [Multi-Agent Tool Coordination](platform/workflow/multi-agent-tool-coordination.md)

## Maintenance & Operations

How to keep the harness itself healthy after adoption — upgrades, version pinning, drift recovery, governance audits.

* [Maintenance & Operations Guide](platform/workflow/maintenance-operations.md) — upgrade flow, pinning, rollback, drift detection, copy-to-submodule migration, lifecycle transitions, periodic audits
* [Release and Versioning](platform/workflow/release-and-versioning.md) — policy and process for releasing auto-harness itself
* [Validator Error Solver (Troubleshooting)](platform/workflow/troubleshooting.md)

## Contributing & Extension

Authoring new modules, validators, skills, templates, and agent packs.

* [Extending the Harness](platform/workflow/extending-the-harness.md) — module / validator / skill / template / agent-pack author guide
* [Threat Model](docs/threat-model.md) — what auto-harness protects against; what it doesn't; mitigations in place

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

* [Architecture Diagrams](docs/architecture/diagrams.md) — composition, trust tier flow, companion rule firing, OPP/PRD/ADR lifecycle, distillation triggers, consumer adoption
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
* [Agentic UI](platform/profiles/architectures/agentic-ui/README.md) — conversational-primary or MCP-host-shell products where the agent surface is the dominant topology
* [MCP Server](platform/profiles/architectures/mcp-server/README.md) — projects that ship their own MCP server (npm/pip package, hosted endpoint, internal service)

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
* [Interview-Driven](platform/profiles/management/interview-driven/README.md)
* [Product Lite](platform/profiles/management/product-lite/README.md)
* [Project Standard](platform/profiles/management/project-standard/README.md)
* [Program Lite](platform/profiles/management/program-lite/README.md)
* [Testing Standard](platform/profiles/management/testing-standard/README.md)
* [Knowledge Capture](platform/profiles/management/knowledge-capture/README.md)
* [Opportunity Capture](platform/profiles/management/opportunity-capture/README.md)

### Domains

Vendor, ecosystem, or specialist overlays.

* [Agentic Interfaces](platform/profiles/domains/agentic-interfaces/README.md) — in-product copilot panels, generative-UI surfaces, conversational-primary products
* [Supabase](platform/profiles/domains/supabase/README.md)
* [Media Pipeline](platform/profiles/domains/media-pipeline/README.md)
* [Web3](platform/profiles/domains/web3/README.md)
* [GitBook](platform/profiles/domains/gitbook/README.md)

### Agents

AI-tool packs and operating adapters.

* [Base](platform/agents/base/README.md)
* [Claude Code](platform/agents/claude-code/README.md)
* [Generic LLM](platform/agents/generic-llm/README.md)
* [OpenClaw](platform/agents/openclaw/README.md)

## Validator Reference

The eight validator scripts and their shared Ruby library. CI wiring and troubleshooting live in the workflow sections above.

* [Validators Overview](platform/validators/README.md)
* [validate-manifest.sh](platform/validators/validate-manifest.sh)
* [validate-module-graph.sh](platform/validators/validate-module-graph.sh)
* [validate-required-artifacts.sh](platform/validators/validate-required-artifacts.sh)
* [validate-placeholders.sh](platform/validators/validate-placeholders.sh)
* [validate-agent-pack.sh](platform/validators/validate-agent-pack.sh)
* [validate-companions.sh](platform/validators/validate-companions.sh)
* [validate-doc-references.sh](platform/validators/validate-doc-references.sh)
* [validate-catalog-counts.sh](platform/validators/validate-catalog-counts.sh)
* [Shared Library: harness\_registry.rb](platform/validators/lib/harness_registry.rb)

### Test Suite

* [Unit Tests: HarnessRegistry](platform/validators/test/test_harness_registry.rb)
* [Integration Tests: Validators](platform/validators/test/test_validators_integration.rb)

### Bootstrap Tools

* [Bootstrap Overview](platform/bootstrap/README.md)
* [install.sh — consumer onboarding](platform/bootstrap/install.sh)
* [link-skills.sh — skill symlink creator](platform/bootstrap/link-skills.sh)
* [set-consumer-headers.sh — fill template-header tokens](platform/bootstrap/set-consumer-headers.sh)
* [query-observations.sh — filter shared-observations by severity/topic/date](platform/bootstrap/query-observations.sh)
* [add-license-headers.sh — maintainer-only header insertion](platform/bootstrap/add-license-headers.sh)

### CI Templates (for consumer projects)

* [CI Templates Overview](platform/templates/ci/README.md)
* [GitHub Actions](platform/templates/ci/github-actions.yml)
* [GitLab CI](platform/templates/ci/gitlab-ci.yml)

## Harness-Native Skills

Skills in Agent Skills format, discoverable by Claude Code, VS Code Copilot, Cursor, and
other compliant clients. Install to `.agents/skills/` or `.claude/skills/`.

* [harness-governance](platform/skills/harness-governance/SKILL.md)
* [harness-web3](platform/skills/harness-web3/SKILL.md)
* [harness-testing](platform/skills/harness-testing/SKILL.md)
* [harness-onboarding](platform/skills/harness-onboarding/SKILL.md)
* [harness-tools](platform/skills/harness-tools/SKILL.md)
* [harness-agentic-interfaces](platform/skills/harness-agentic-interfaces/SKILL.md)
* [harness-mcp](platform/skills/harness-mcp/SKILL.md)

## Compositions and Examples

### Starter Compositions

Pre-built manifests for common project types. Copy the closest match to
`harness.manifest.yaml` and adjust.

* [Compositions Overview](platform/compositions/README.md)
* [Brownfield Lite](platform/compositions/brownfield-lite.yaml)
* [Interview-Driven Discovery](platform/compositions/interview-driven-discovery.yaml)
* [New Product Discovery](platform/compositions/new-product-discovery.yaml)
* [Node Web SaaS + Postgres](platform/compositions/node-web-saas-postgres.yaml)
* [Python API Service + Postgres](platform/compositions/python-api-service-postgres.yaml)
* [Research Pipeline (Python + Object Storage)](platform/compositions/research-pipeline-python-object-storage.yaml)
* [Web3 Risk Analytics](platform/compositions/web3-risk-analytics.yaml)
* [Agentic UI SaaS](platform/compositions/agentic-ui-saas.yaml) — Node/TS SaaS shipping an in-product copilot or generative UI
* [MCP Server (TypeScript)](platform/compositions/mcp-server-typescript.yaml) — projects that produce their own MCP server

### Examples

* [Examples Overview](platform/examples/README.md)

#### Composed Entrypoints

Sample HARNESS.md, AGENTS.md, and CLAUDE.md demonstrating how a project's agent adapter
files reference the harness governance contract.

* [HARNESS.md](platform/examples/composed-entrypoints/HARNESS.md)
* [AGENTS.md](platform/examples/composed-entrypoints/AGENTS.md)
* [CLAUDE.md](platform/examples/composed-entrypoints/CLAUDE.md)

#### Interview-Driven Hackathon — Sample Project

A minimal sample project using the `interview-driven` overlay with a monolithic PRD, a
decision-complete plan, and an AI-facing interview/spec prompt.

* [HARNESS.md](platform/examples/sample-projects/interview-driven-hackathon/HARNESS.md)
* [AGENTS.md](platform/examples/sample-projects/interview-driven-hackathon/AGENTS.md)
* [CLAUDE.md](platform/examples/sample-projects/interview-driven-hackathon/CLAUDE.md)
* [PRD (monolithic)](platform/examples/sample-projects/interview-driven-hackathon/docs/PRD.md)
* [Full Plan (decision-complete)](platform/examples/sample-projects/interview-driven-hackathon/docs/full-plan.md)
* [Interview / Spec Prompt](platform/examples/sample-projects/interview-driven-hackathon/docs/prd-interview-spec-prompt.md)
* [Operating Principles](platform/examples/sample-projects/interview-driven-hackathon/docs/operating-principles.md)

#### Agentic UI Starter — Sample Project

A SaaS web-app that ships an in-product agentic interface (copilot sidebar + small generative-UI surface). Demonstrates the `domains/agentic-interfaces` overlay.

* [HARNESS.md](platform/examples/sample-projects/agentic-ui-starter/HARNESS.md)
* [AGENTS.md](platform/examples/sample-projects/agentic-ui-starter/AGENTS.md)
* [CLAUDE.md](platform/examples/sample-projects/agentic-ui-starter/CLAUDE.md)
* [PRD](platform/examples/sample-projects/agentic-ui-starter/docs/PRD.md)
* [Full Plan](platform/examples/sample-projects/agentic-ui-starter/docs/full-plan.md)
* [Interview / Spec Prompt](platform/examples/sample-projects/agentic-ui-starter/docs/prd-interview-spec-prompt.md)
* [Agentic Interface — Design](platform/examples/sample-projects/agentic-ui-starter/docs/agentic-interface/design.md)
* [Agentic Interface — Risk Register](platform/examples/sample-projects/agentic-ui-starter/docs/agentic-interface/risk-register.md)
* [Architecture Overview](platform/examples/sample-projects/agentic-ui-starter/docs/architecture/overview.md)
* [Operating Principles](platform/examples/sample-projects/agentic-ui-starter/docs/operating-principles.md)

#### MCP Server Starter — Sample Project

A reference MCP-server-producing project (TypeScript) demonstrating the `architectures/mcp-server` overlay with a small tool surface that spans Tier 0, 2, and 3.

* [HARNESS.md](platform/examples/sample-projects/mcp-server-starter/HARNESS.md)
* [AGENTS.md](platform/examples/sample-projects/mcp-server-starter/AGENTS.md)
* [CLAUDE.md](platform/examples/sample-projects/mcp-server-starter/CLAUDE.md)
* [PRD](platform/examples/sample-projects/mcp-server-starter/docs/PRD.md)
* [Full Plan](platform/examples/sample-projects/mcp-server-starter/docs/full-plan.md)
* [MCP — Server Spec](platform/examples/sample-projects/mcp-server-starter/docs/mcp/server-spec.md)
* [MCP — Tool Registry](platform/examples/sample-projects/mcp-server-starter/docs/mcp/tool-registry.md)
* [MCP — Risk Register](platform/examples/sample-projects/mcp-server-starter/docs/mcp/risk-register.md)
* [MCP — Transport and Auth](platform/examples/sample-projects/mcp-server-starter/docs/mcp/transport-and-auth.md)
* [MCP — Capability Schema](platform/examples/sample-projects/mcp-server-starter/docs/mcp/capability-schema.md)
* [MCP — Prompt-Injection Test Plan](platform/examples/sample-projects/mcp-server-starter/docs/mcp/prompt-injection-test-plan.md)
* [Operating Principles](platform/examples/sample-projects/mcp-server-starter/docs/operating-principles.md)

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
* [Revision Tracker](platform/templates/project/revision-tracker.md)
* [Review Log](platform/templates/project/review-log.md)

### Knowledge

* [Knowledge README](platform/templates/knowledge/README.md)
* [Shared Observations](platform/templates/knowledge/shared-observations.md)
* [Distilled Learnings](platform/templates/knowledge/distilled-learnings.md)

### Opportunity

* [Opportunity README](platform/templates/opportunity/README.md)
* [Opportunity Record (OPP-NNNN)](platform/templates/opportunity/opp-template.md)

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
* [Tools Registry (TOOLS.md)](platform/templates/tools.md)

### Standards

* [KPI Dictionary](platform/templates/standards/kpi-dictionary.md)

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
* [Fallback Matrix](platform/templates/ops/fallback-matrix.md)

### Database

* [Migration Readiness](platform/templates/database/migration-readiness.md)

### Web3

* [Chain Configuration](platform/templates/web3/chain-config.md)
* [Contract Registry](platform/templates/web3/contract-registry.md)
* [Token Strategy](platform/templates/web3/token-strategy.md)
* [Risk Register — Web3](platform/templates/web3/risk-register-web3.md)
* [ADR — Web3 Variant](platform/templates/web3/adr-web3.md)
* [Web3 Intake Supplement](platform/templates/web3/web3-intake-supplement.md)

### Agentic Interface

* [Agentic Interface README](platform/templates/agentic-interface/README.md)
* [Design](platform/templates/agentic-interface/design.md)
* [Risk Register](platform/templates/agentic-interface/risk-register.md)
* [Prompt / Tool Registry](platform/templates/agentic-interface/prompt-tool-registry.md)
* [Renderer Contract](platform/templates/agentic-interface/renderer-contract.md)

### MCP

* [MCP README](platform/templates/mcp/README.md)
* [Server Spec](platform/templates/mcp/server-spec.md)
* [Tool Registry](platform/templates/mcp/tool-registry.md)
* [Risk Register](platform/templates/mcp/risk-register.md)
* [Capability Schema](platform/templates/mcp/capability-schema.md)
* [Prompt-Injection Test Plan](platform/templates/mcp/prompt-injection-test-plan.md)
* [Transport and Auth](platform/templates/mcp/transport-and-auth.md)

### Documentation

* [Project GitBook Stub (SUMMARY.md)](platform/templates/docs/SUMMARY.md)
* [Templates Reference](platform/templates/README.md)

## Project Governance & Community

Open-source-cut metadata: license, contribution flow, community standards, and the project's own decision records.

* [Contributing Guide](CONTRIBUTING.md)
* [Code of Conduct](CODE_OF_CONDUCT.md)
* [Security Policy](SECURITY.md)
* [License — MIT](https://github.com/unclenate/auto-harness/blob/main/LICENSE-MIT)
* [License — Apache 2.0](https://github.com/unclenate/auto-harness/blob/main/LICENSE-APACHE)
* [NOTICE](https://github.com/unclenate/auto-harness/blob/main/NOTICE)
* [Authors and Maintainers](https://github.com/unclenate/auto-harness/blob/main/AUTHORS)
* [Self-Governance Entrypoint (HARNESS.md)](HARNESS.md)
* [Cross-Agent Operating Manual (AGENTS.md)](AGENTS.md)
* [Claude Code Load Order (CLAUDE.md)](CLAUDE.md)
* [Tools Registry (TOOLS.md)](TOOLS.md)

### Architecture Decision Records (this project)

* [ADR-0001: Modular Governance](docs/adr/ADR-0001-modular-governance.md)
* [ADR-0002: Knowledge Capture — Structured Observations](docs/adr/ADR-0002-knowledge-capture-structured-observations.md)
* [ADR-0003: Submodule Integration](docs/adr/ADR-0003-submodule-integration.md)
* [ADR-0004: Opportunity Capture — Record Structure](docs/adr/ADR-0004-opportunity-capture-record-structure.md)
* [ADR-0005: Open-Source Cut](docs/adr/ADR-0005-open-source-cut.md)
* [ADR-0006: Interview-Driven Management](docs/adr/ADR-0006-interview-driven-management.md)
* [ADR-0007: Agentic Interface Awareness](docs/adr/ADR-0007-agentic-interface-awareness.md)
* [ADR-0008: MCP Awareness](docs/adr/ADR-0008-mcp-awareness.md)
* [ADR-0009: CI Hardening](docs/adr/ADR-0009-ci-hardening.md)
* [ADR-0010: Cheap Satisfiers for Routine Governance](docs/adr/ADR-0010-cheap-satisfiers-for-routine-governance.md)
* [ADR-0011: Markdownlint Policy](docs/adr/ADR-0011-markdownlint-policy.md)
* [ADR-0012: Opportunity Capture — Index Split](docs/adr/ADR-0012-opportunity-capture-index-split.md)

### Product Requirements Documents (this project)

Specifications for substantive new capabilities, paired with their originating opportunity records.

* [PRD-0001: Restore PRD Support](docs/requirements/PRD-0001-restore-prd-support.md)
* [PRD-0002: Extend PRD Template Execution Sections](docs/requirements/PRD-0002-extend-prd-template-execution-sections.md)
* [PRD-0003: Opportunity Capture Module](docs/requirements/PRD-0003-opportunity-capture-module.md)
* [PRD-0004: Distillation Triggers](docs/requirements/PRD-0004-distillation-triggers.md)
* [PRD-0005: Consumer Header Hygiene](docs/requirements/PRD-0005-consumer-header-hygiene.md)
* [PRD-0006: Trust-Tier Enforcement](docs/requirements/PRD-0006-trust-tier-enforcement.md)
* [PRD-0007: Canonical-Position Artifact](docs/requirements/PRD-0007-canonical-position-artifact.md)

### Opportunity Records (this project)

Forward-looking pre-PRD candidates managed by the `opportunity-capture` module.

* [Opportunity Records — Policy README](docs/opportunities/README.md)
* [Opportunity Candidates Index](docs/opportunities/candidates.md)
* [OPP-0001: Exportable Governance Contract for Runtime Harnesses](docs/opportunities/OPP-0001-exportable-governance-contract-for-runtime-harnesses.md)
* [OPP-0002: Agentic Interface Awareness](docs/opportunities/OPP-0002-agentic-interface-awareness.md)
* [OPP-0003: MCP Producer and Exportable Governance via MCP](docs/opportunities/OPP-0003-mcp-producer-and-exportable-governance-via-mcp.md)
* [OPP-0004: Distillation Triggers](docs/opportunities/OPP-0004-distillation-triggers.md)
* [OPP-0005: Consumer Header Hygiene](docs/opportunities/OPP-0005-consumer-header-hygiene.md)
* [OPP-0006: Trust-Tier Enforcement](docs/opportunities/OPP-0006-trust-tier-enforcement.md)
* [OPP-0007: Canonical-Position Artifact as Harness Primitive](docs/opportunities/OPP-0007-canonical-position-artifact.md)
* [OPP-0008: Stack Module for Plain Node-JavaScript (and Legacy CoffeeScript)](docs/opportunities/OPP-0008-stack-module-node-javascript-and-coffeescript.md)
* [OPP-0009: Data Module for Embedded Key-Value Stores (LevelDB-class)](docs/opportunities/OPP-0009-data-module-embedded-key-value.md)
* [OPP-0010: Domain Module for Cryptographic Identity (Non-Ethereum HD Wallets)](docs/opportunities/OPP-0010-domain-module-cryptographic-identity.md)
