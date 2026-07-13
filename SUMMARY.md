<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# auto-harness

> **New here? Start with the [README](README.md).** It has the value
> proposition, the hero graphic, and the adoption paths. This page is
> the GitBook table of contents — useful once you know what you're
> looking for.

## Start Here

* [Introduction](README.md)
* [Platform Overview](platform/README.md)
* [Roadmap](docs/roadmap.md) — released versions, planned versions, and what's coming toward v1.0
* [How to Use This Documentation](platform/reference/how-to-read.md)
* [Prerequisites](platform/reference/prerequisites.md) — per-platform toolchain (macOS / Linux / Windows-WSL)
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
* [Session Shape and Review-Trigger Taxonomy](platform/workflow/session-shape.md) — the session-boundary checkpoints, the six trigger-classes, and the audit of declared-but-unfired reviews
* [Modify Composition Mid-Project](platform/workflow/modify-composition-mid-project.md) — add / change / remove modules in an active manifest
* [Incident Response](platform/workflow/incident-response.md) — operational workflow for production incidents and postmortems
* [Agentic Interface Integration](platform/workflow/agentic-interface-integration.md) — operator workflow for in-product agent surfaces
* [MCP Server Build](platform/workflow/mcp-server-build.md) — operator workflow for projects that ship an MCP server
* [Multi-Agent Tool Coordination](platform/workflow/multi-agent-tool-coordination.md)
* [Work-Package Worktree Runbook](platform/workflow/work-package-worktree-runbook.md) — idempotent isolated-worktree setup for dispatching parallel multi-agent work-packages (`management/work-package`)

## Maintenance & Operations

How to keep the harness itself healthy after adoption — upgrades, version pinning, drift recovery, governance audits.

* [Maintenance & Operations Guide](platform/workflow/maintenance-operations.md) — upgrade flow, pinning, rollback, drift detection, copy-to-submodule migration, lifecycle transitions, periodic audits
* [Consumer Upgrade Runbook](platform/workflow/consumer-upgrade-runbook.md) — single-page checklist to bump a consuming repo to a newer version, plus the `upgrade.sh` helper script
* [Recover a Misplaced Consumer](platform/workflow/recover-misplaced-consumer.md) — runbook for extracting a consumer mistakenly created inside the platform repo
* [Release and Versioning](platform/workflow/release-and-versioning.md) — policy and process for releasing auto-harness itself
* [Validator Error Solver (Troubleshooting)](platform/workflow/troubleshooting.md)

## Contributing & Extension

Authoring new modules, validators, skills, templates, and agent packs.

* [Operating Principles](docs/operating-principles.md) — the harness platform's own doctrine (§§ 1–12): ownership, review discipline, self-governance, split-design-from-implementation, classify-claims-before-enforcing, privacy-by-default, and authoring deep governance verticals from the shared skeleton
* [Extending the Harness](platform/workflow/extending-the-harness.md) — module / validator / skill / template / agent-pack author guide
* [Authoring a Deep Governance Vertical](platform/workflow/deep-governance-vertical-authoring.md) — the step-by-step playbook for building the next domain/overlay from the six-ingredient skeleton (operating-principles § 12)
* [Threat Model](docs/threat-model.md) — what auto-harness protects against; what it doesn't; mitigations in place
* [Upstream Harvesting](platform/workflow/upstream-harvesting.md) — scrub, tokenize, validate, and integrate custom modules back to the core

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
* [Stigmergy](docs/architecture/stigmergy.md) — decentralized, environmental feedback loops and agent coordination
* [Module Types](platform/core/registry/module-types.md) — families, field reference, compiled fragments vs skills
* [Prerequisites](platform/reference/prerequisites.md) — per-platform toolchain (macOS / Linux / Windows-WSL)
* [Glossary](platform/reference/glossary.md) — shared terminology
* [Topic Index](platform/reference/index.md) — cross-reference by concept

## Module Library

### Stacks

Language, runtime, and framework adaptations.

* [Node / TypeScript](platform/profiles/stacks/node-typescript/README.md)
* [Node / JavaScript](platform/profiles/stacks/node-javascript/README.md) — plain JavaScript (no TypeScript)
* [CoffeeScript](platform/profiles/stacks/coffeescript/README.md) — legacy CoffeeScript projects
* [Python](platform/profiles/stacks/python/README.md)

### Architectures

Interaction and deployment patterns.

* [Web App](platform/profiles/architectures/web-app/README.md)
* [API Service](platform/profiles/architectures/api-service/README.md)
* [Event Driven](platform/profiles/architectures/event-driven/README.md)
* [Agentic UI](platform/profiles/architectures/agentic-ui/README.md) — conversational-primary or MCP-host-shell products where the agent surface is the dominant topology
* [MCP Server](platform/profiles/architectures/mcp-server/README.md) — projects that ship their own MCP server (npm/pip package, hosted endpoint, internal service)
* [Agent Skill Pack](platform/profiles/architectures/agent-skill-pack/README.md) — products whose unit of delivery is an authored, eval-gated skill pack loaded by an agent runtime (OpenClaw / ClawHub, Claude Code, Cursor)
* [Agent Observability](platform/profiles/architectures/agent-observability/README.md) — opt-in overlay declaring the project's OpenTelemetry multi-agent trace contract (spans/attributes/exporters) for foundry/observability-backend consumption; v1 declarative (PRD-0014)
* [AI Foundry Target](platform/profiles/architectures/ai-foundry-target/README.md) — opt-in overlay declaring which enterprise AI foundries (Microsoft/Azure AI Foundry, NVIDIA, Palantir AIP, AWS Bedrock AgentCore, Google Vertex Agent Engine, custom) a project targets and the portable foundry-agnostic evidence for each; v1 declarative (PRD-0028)
* [Intelligent Model Routing](platform/profiles/architectures/intelligent-model-routing/README.md) — opt-in overlay declaring a project's task→model routing table (routing criteria, free-form provider list, foundry-routing seams); v1 declarative (PRD-0029)
* [Agent Defense-in-Depth](platform/profiles/architectures/agent-defense-in-depth/README.md) — opt-in overlay declaring how a project realizes Microsoft's four autonomous-agent patterns (scope-containment, least-permissions, human-in-the-loop, agent identity) + an operator-owned append-only action log; v1 declarative (PRD-0030)

### Data

Storage and state-management overlays.

* [Relational SQL](platform/profiles/data/relational-sql/README.md)
* [Document Store](platform/profiles/data/document-store/README.md)
* [Object Storage](platform/profiles/data/object-storage/README.md)
* [Embedded Key-Value](platform/profiles/data/embedded-key-value/README.md) — server-side LevelDB / LMDB / SQLite-as-KV / Bun-KV / Deno-KV
* [Browser Storage](platform/profiles/data/browser-storage/README.md) — IndexedDB / localStorage / OPFS

### Delivery

Lifecycle and operational posture overlays.

* [Prototype](platform/profiles/delivery/prototype/README.md)
* [Production SaaS](platform/profiles/delivery/production-saas/README.md)
* [Internal Platform](platform/profiles/delivery/internal-platform/README.md)
* [Self-Hosted OSS](platform/profiles/delivery/self-hosted-oss/README.md) — published OSS shipped as a self-hosted deployment the user operates (between prototype and production-saas)
* [Managed Fleet](platform/profiles/delivery/managed-fleet/README.md) — teams that operate configuration managing a live host fleet (between internal-platform and production-saas)

### Management

Product, project, and program governance overlays.

* [Discovery Intake](platform/profiles/management/discovery-intake/README.md)
* [Interview-Driven](platform/profiles/management/interview-driven/README.md)
* [Product Lite](platform/profiles/management/product-lite/README.md)
* [Project Standard](platform/profiles/management/project-standard/README.md)
* [Program Lite](platform/profiles/management/program-lite/README.md)
* [Testing Standard](platform/profiles/management/testing-standard/README.md)
* [Eval-Gated Testing](platform/profiles/management/eval-gated-testing/README.md) — quality gated on binary-graded evals rather than coverage (sibling to Testing Standard)
* [Knowledge Capture](platform/profiles/management/knowledge-capture/README.md)
* [Opportunity Capture](platform/profiles/management/opportunity-capture/README.md)
* [Privacy by Design](platform/profiles/management/privacy-by-design/README.md) — default-on privacy-by-design overlay; Cavoukian's 7 principles + a consumer-declared legal regime
* [Security Static Analysis](platform/profiles/management/security-static-analysis/README.md) — opt-in SAST coverage posture for agent-generated code (Wave 5.4; PRD-0016)
* [Digital Twin / Scenario Runtime](platform/profiles/management/digital-twin/README.md) — default-off overlay for scenario-driven twins; maturity-gated twin-profile + dual-spine standards anchor (interoperability + Gemini Principles)
* [Work Package](platform/profiles/management/work-package/README.md) — default-off overlay for parallel multi-agent delivery; a per-task lane (allowedFiles / readOnlyFiles / prMode) checked against the dispatched agent's actual diff by `validate-lane-integrity.sh`
* [Canonical Position](platform/profiles/management/canonical-position/README.md) — opt-in strategic north-star overlay; a single ratified `docs/canonical-position.md` every strategy-shaped artifact must cite, revised only via a paired review-artifact ratification trail (PRD-0007 / OPP-0007)

### Domains

Vendor, ecosystem, or specialist overlays.

* [Agentic Interfaces](platform/profiles/domains/agentic-interfaces/README.md) — in-product copilot panels, generative-UI surfaces, conversational-primary products
* [Supabase](platform/profiles/domains/supabase/README.md)
* [Media Pipeline](platform/profiles/domains/media-pipeline/README.md)
* [Web3](platform/profiles/domains/web3/README.md) — Ethereum-specific smart-contract concerns
* [Cryptographic Identity](platform/profiles/domains/cryptographic-identity/README.md) — BIP32/BIP39 wallets, DID/SSI, key custody (non-Ethereum)
* [Healthcare FHIR](platform/profiles/domains/healthcare-fhir/README.md) — FHIR data layer; jurisdiction-neutral core (healthcare deep-domain family)
* [Healthcare SMART on FHIR](platform/profiles/domains/healthcare-smart-on-fhir/README.md) — app launch + scopes; provider/patient roles (pairs with Healthcare FHIR)
* [AEC ISO 19650 IM](platform/profiles/domains/aec-iso19650-im/README.md) — ISO 19650 information-management substrate; CDE, containers, actor model (AEC deep-domain family)
* [AEC openBIM Exchange](platform/profiles/domains/aec-openbim-exchange/README.md) — IFC/IDS exchange + producer/receiver/reviewer roles (pairs with AEC ISO 19650 IM)
* [AEC ISO 19650-5 Security](platform/profiles/domains/aec-iso19650-5-security/README.md) — security-minded sensitivity + security-management plan (composes with privacy-by-design)
* [Geospatial Foundation](platform/profiles/domains/geospatial-foundation/README.md) — spatial-reference substrate; CRS, datum, epoch, units + per-dataset provenance (geospatial deep-domain family)
* [Geospatial Exchange](platform/profiles/domains/geospatial-exchange/README.md) — OGC formats/services exchange + publisher/consumer roles + CRS-on-the-wire policy (pairs with Geospatial Foundation)
* [Geospatial BIM↔GIS Georeference](platform/profiles/domains/geospatial-bim-georeference/README.md) — IfcMapConversion georeferencing bridge (first cross-family dependency; bridges to AEC openBIM Exchange)
* [GitBook](platform/profiles/domains/gitbook/README.md)

### Agents

AI-tool packs and operating adapters.

* [Base](platform/agents/base/README.md)
* [Claude Code](platform/agents/claude-code/README.md)
* [Codex CLI](platform/agents/codex-cli/README.md)
* [Copilot CLI](platform/agents/copilot-cli/README.md)
* [Cursor](platform/agents/cursor/README.md)
* [Gemini CLI](platform/agents/gemini-cli/README.md)
* [Generic LLM](platform/agents/generic-llm/README.md)
* [OpenClaw](platform/agents/openclaw/README.md)

## Validator Reference

The twenty-five validator scripts and their shared Ruby library. CI wiring and troubleshooting live in the workflow sections above.

* [Validators Overview](platform/validators/README.md)
* [validate-manifest.sh](platform/validators/validate-manifest.sh)
* [validate-module-graph.sh](platform/validators/validate-module-graph.sh)
* [validate-required-artifacts.sh](platform/validators/validate-required-artifacts.sh)
* [validate-placeholders.sh](platform/validators/validate-placeholders.sh)
* [validate-agent-pack.sh](platform/validators/validate-agent-pack.sh)
* [validate-companions.sh](platform/validators/validate-companions.sh)
* [validate-doc-references.sh](platform/validators/validate-doc-references.sh)
* [validate-catalog-counts.sh](platform/validators/validate-catalog-counts.sh)
* [validate-list-completeness.sh](platform/validators/validate-list-completeness.sh)
* [validate-trust-tier.sh](platform/validators/validate-trust-tier.sh)
* [validate-sensitive-paths.sh](platform/validators/validate-sensitive-paths.sh)
* [validate-skill-content.sh](platform/validators/validate-skill-content.sh)
* [validate-knowledge-redaction.sh](platform/validators/validate-knowledge-redaction.sh)
* [validate-observation-hygiene.sh](platform/validators/validate-observation-hygiene.sh)
* [validate-sast-coverage.sh](platform/validators/validate-sast-coverage.sh)
* [validate-trace-contract.sh](platform/validators/validate-trace-contract.sh)
* [validate-foundry-target.sh](platform/validators/validate-foundry-target.sh)
* [validate-model-routing.sh](platform/validators/validate-model-routing.sh)
* [validate-agent-defense-in-depth.sh](platform/validators/validate-agent-defense-in-depth.sh)
* [validate-privacy-by-design.sh](platform/validators/validate-privacy-by-design.sh)
* [validate-twin-profile.sh](platform/validators/validate-twin-profile.sh)
* [validate-scenario-manifest.sh](platform/validators/validate-scenario-manifest.sh)
* [validate-lane-integrity.sh](platform/validators/validate-lane-integrity.sh)
* [validate-publication-boundary.sh](platform/validators/validate-publication-boundary.sh)
* [validate-module-stability.sh](platform/validators/validate-module-stability.sh)
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
* [harness-digital-twin](platform/skills/harness-digital-twin/SKILL.md)

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
* [MCP Server (TypeScript, OSS)](platform/compositions/mcp-server-typescript-oss.yaml) — OSS-released MCP server with `delivery/self-hosted-oss` + project-standard + knowledge-capture
* [Healthcare FHIR App](platform/compositions/healthcare-fhir-app.yaml) — FHIR + SMART-on-FHIR application; healthcare data layer + app-launch/scope overlay
* [AEC BIM Project](platform/compositions/aec-bim-project.yaml) — ISO 19650 / openBIM delivery; information-management substrate + openBIM exchange + ISO 19650-5 security
* [Digital Twin Prototype](platform/compositions/digital-twin-prototype.yaml) — scenario-driven digital-twin overlay with privacy-by-design on a built stack
* [Geospatial BIM Twin](platform/compositions/geospatial-bim-twin.yaml) — BIM + GIS twin of a place; spatial-reference substrate + OGC exchange + BIM↔GIS georeferencing

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
* [Eval Strategy](platform/templates/testing/eval-strategy.md)

### Skills

* [Skill Authoring Conventions](platform/templates/skills/authoring-conventions.md)

### Deployment

* [Self-Hosting Guide](platform/templates/deployment/self-hosting-guide.md)

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

### Healthcare

* [Jurisdiction Profile](platform/templates/healthcare/jurisdiction-profile.md)
* [FHIR Resource Map](platform/templates/healthcare/fhir-resource-map.md)
* [SMART Scope Map](platform/templates/healthcare/smart-scope-map.md)

### AEC

* [Jurisdiction Profile](platform/templates/aec/jurisdiction-profile.md)
* [Information Management Plan](platform/templates/aec/information-management-plan.md)
* [Exchange Requirements](platform/templates/aec/exchange-requirements.md)
* [Security Management Plan](platform/templates/aec/security-management-plan.md)
* [Sensitivity Assessment](platform/templates/aec/sensitivity-assessment.md)

### Geospatial

* [Spatial Reference Profile](platform/templates/geospatial/spatial-reference-profile.md)
* [Exchange Profile](platform/templates/geospatial/exchange-profile.md)
* [Dataset Inventory](platform/templates/geospatial/dataset-inventory.md)
* [Georeference Map](platform/templates/geospatial/georeference-map.md)

### Digital Twin

* [Overview](platform/templates/digital-twin/overview.md)
* [Twin Profile](platform/templates/digital-twin/twin-profile.md)
* [Model Registry](platform/templates/digital-twin/model-registry.md)
* [Agent Registry](platform/templates/digital-twin/agent-registry.md)
* [Scenario Manifest Spec](platform/templates/digital-twin/scenario-manifest-spec.md)
* [Run-Log Spec](platform/templates/digital-twin/run-log-spec.md)
* [Data Provenance](platform/templates/digital-twin/data-provenance.md)
* [Uncertainty Policy](platform/templates/digital-twin/uncertainty-policy.md)
* [Publication Policy](platform/templates/digital-twin/publication-policy.md)
* [Security Boundaries](platform/templates/digital-twin/security-boundaries.md)

### Privacy

* [Privacy Profile](platform/templates/privacy/privacy-profile.md)
* [Data Inventory](platform/templates/privacy/data-inventory.md)
* [Privacy Impact Assessment](platform/templates/privacy/privacy-impact-assessment.md)

### Security

* [SAST Coverage Declaration](platform/templates/security/sast-coverage.md)

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
* [ADR-0013: Documentation Information Architecture](docs/adr/ADR-0013-documentation-information-architecture.md) — *Phases 3–4 superseded by ADR-0016*
* [ADR-0014: Sunset distilled-learnings.md](docs/adr/ADR-0014-sunset-distilled-learnings.md)
* [ADR-0015: Add delivery/managed-fleet Posture](docs/adr/ADR-0015-managed-fleet-delivery-posture.md)
* [ADR-0016: Documentation IA — Phase 3–4 Target Structure](docs/adr/ADR-0016-documentation-ia-phase-3-4-target-structure.md)
* [ADR-0017: Safety Hardening Roadmap](docs/adr/ADR-0017-safety-hardening-roadmap.md)
* [ADR-0018: Privacy by Default Posture](docs/adr/ADR-0018-privacy-by-default-posture.md)
* [ADR-0019: Adopt Digital Twin / Scenario Runtime as a Management Overlay](docs/adr/ADR-0019-digital-twin-scenario-runtime-overlay.md)

### Product Requirements Documents (this project)

Specifications for substantive new capabilities, paired with their originating opportunity records.

* [PRD-0001: Restore PRD Support](docs/requirements/PRD-0001-restore-prd-support.md)
* [PRD-0002: Extend PRD Template Execution Sections](docs/requirements/PRD-0002-extend-prd-template-execution-sections.md)
* [PRD-0003: Opportunity Capture Module](docs/requirements/PRD-0003-opportunity-capture-module.md)
* [PRD-0004: Distillation Triggers](docs/requirements/PRD-0004-distillation-triggers.md)
* [PRD-0005: Consumer Header Hygiene](docs/requirements/PRD-0005-consumer-header-hygiene.md)
* [PRD-0006: Trust-Tier Enforcement](docs/requirements/PRD-0006-trust-tier-enforcement.md)
* [PRD-0007: Canonical-Position Artifact](docs/requirements/PRD-0007-canonical-position-artifact.md)
* [PRD-0008: Agent Skill-Pack Architecture](docs/requirements/PRD-0008-agent-skill-pack-architecture.md)
* [PRD-0009: Eval-Gated Testing Module](docs/requirements/PRD-0009-eval-gated-testing-module.md)
* [PRD-0010: Self-Hosted OSS Delivery](docs/requirements/PRD-0010-self-hosted-oss-delivery.md)
* [PRD-0011: Sunset distilled-learnings.md](docs/requirements/PRD-0011-distilled-learnings-disposition.md)
* [PRD-0012: validate-doc-references Consumer-Aware Scan](docs/requirements/PRD-0012-doc-references-consumer-aware.md)
* [PRD-0013: Session-Cycle Orchestration and Review-Trigger Taxonomy](docs/requirements/PRD-0013-session-cycle-orchestration.md)
* [PRD-0014: Agent Observability with OpenTelemetry Semantic Conventions](docs/requirements/PRD-0014-agent-observability.md)
* [PRD-0015: Skill Content Safety Validator](docs/requirements/PRD-0015-validate-skill-content.md) — `validate-skill-content.sh` design contract (Wave 5.2; closes red-team V1/V2/V4-partial/V6)
* [PRD-0016: Security Static Analysis Module](docs/requirements/PRD-0016-security-static-analysis-module.md) — `management/security-static-analysis` design contract (Wave 5.4; opt-in posture for SAST coverage)
* [PRD-0017: Healthcare FHIR + SMART on FHIR Wedge](docs/requirements/PRD-0017-healthcare-fhir-smart-wedge.md)
* [PRD-0018: Privacy by Design Module](docs/requirements/PRD-0018-privacy-by-design.md)
* [PRD-0019: AEC ISO 19650 + openBIM Wedge](docs/requirements/PRD-0019-aec-iso19650-openbim-wedge.md)
* [PRD-0020: Bootstrap Hardening — Guards + Dependency Preflight](docs/requirements/PRD-0020-bootstrap-hardening-guards-and-preflight.md)
* [PRD-0021: Greenfield Onboarding Conservatism](docs/requirements/PRD-0021-greenfield-onboarding-conservatism.md)
* [PRD-0022: Cybersecurity OSINT / Maltego Wedge](docs/requirements/PRD-0022-cybersec-osint-maltego-wedge.md)
* [PRD-0023: Digital Twin / Scenario Runtime Governance Overlay](docs/requirements/PRD-0023-digital-twin-scenario-runtime-overlay.md)
* [PRD-0024: Geospatial / GIS Wedge (CRS Foundation + OGC Exchange + BIM↔GIS Georeferencing)](docs/requirements/PRD-0024-geospatial-gis-wedge.md)
* [PRD-0025: Work-Package Lane Contract](docs/requirements/PRD-0025-work-package-lane-contract.md)
* [PRD-0026: Publication-Boundary Marker](docs/requirements/PRD-0026-publication-boundary-marker.md)
* [PRD-0027: Module Stability Tiers](docs/requirements/PRD-0027-module-stability-tiers.md)
* [PRD-0028: Enterprise AI Foundry Target Awareness](docs/requirements/PRD-0028-ai-foundry-target.md)
* [PRD-0029: Intelligent Model Routing](docs/requirements/PRD-0029-intelligent-model-routing.md)
* [PRD-0030: Agent Defense-in-Depth (Four Patterns)](docs/requirements/PRD-0030-agent-defense-in-depth.md)
* [PRD-0031: Trace-Contract Content Validator](docs/requirements/PRD-0031-validate-trace-contract.md)
* [PRD-0032: Frontier-Agent Cluster Content Validators (Phases 2–4)](docs/requirements/PRD-0032-cluster-content-validators.md)

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
* [OPP-0011: Stack Module for PHP (with skill + two validators)](docs/opportunities/OPP-0011-stack-module-php.md)
* [OPP-0012: Generalize `data/relational-postgres` → `data/relational-sql` (engine sub-field)](docs/opportunities/OPP-0012-data-module-relational-sql-engine-generalization.md)
* [OPP-0013: Healthcare Domain Family (decomposed `domains/healthcare-*`)](docs/opportunities/OPP-0013-domain-family-healthcare-decomposed.md)
* [OPP-0014: Polyglot Companion-Services Pattern (`domains/polyglot-services`)](docs/opportunities/OPP-0014-polyglot-companion-services.md)
* [OPP-0015: Regulated-Compliance Module + External Test-Kit Pattern](docs/opportunities/OPP-0015-regulated-compliance-test-kits.md)
* [OPP-0016: Specialist Healthcare-Review Skill Family](docs/opportunities/OPP-0016-specialist-healthcare-review-skills.md)
* [OPP-0017: Legacy-Coexistence Template Family (+ PHI tripwire validator)](docs/opportunities/OPP-0017-legacy-coexistence-template-family.md)
* [OPP-0018: Authored Eval-Gated Agent Skill-Pack (Tula)](docs/opportunities/OPP-0018-architecture-eval-gated-skill-pack.md)
* [OPP-0019: Binary-Eval Testing Posture (Tula)](docs/opportunities/OPP-0019-eval-gated-testing-posture.md)
* [OPP-0020: Evaluation & Safety Tooling in Toolchain (Tula)](docs/opportunities/OPP-0020-evaluation-tooling-in-harness-toolchain.md)
* [OPP-0021: Delivery — Self-Hosted OSS (Tula)](docs/opportunities/OPP-0021-delivery-self-hosted-oss.md)
* [OPP-0022: Patient-Facing Health-Agent Safety (Tula)](docs/opportunities/OPP-0022-patient-facing-health-agent-safety.md)
* [OPP-0023: `validate-doc-references` Consumer-Aware Scan](docs/opportunities/OPP-0023-doc-references-consumer-scan.md)
* [OPP-0025: Consumer-Side Integration Smoke Test](docs/opportunities/OPP-0025-consumer-integration-smoke-test.md)
* [OPP-0026: `distilled-learnings.md` Disposition](docs/opportunities/OPP-0026-distilled-learnings-disposition.md)
* [OPP-0027: Frontier-Agent Posture (Cluster Anchor)](docs/opportunities/OPP-0027-frontier-agent-posture.md)
* [OPP-0028: Enterprise AI Foundry Target Awareness](docs/opportunities/OPP-0028-ai-foundry-target.md)
* [OPP-0029: Agent Observability with OpenTelemetry Semantic Conventions](docs/opportunities/OPP-0029-agent-observability.md)
* [OPP-0030: Intelligent Model Routing](docs/opportunities/OPP-0030-intelligent-model-routing.md)
* [OPP-0031: Agent Defense-in-Depth (Microsoft's Four Patterns)](docs/opportunities/OPP-0031-agent-defense-in-depth.md)
* [OPP-0032: Session-Cycle Orchestration and Review-Trigger Taxonomy](docs/opportunities/OPP-0032-session-cycle-orchestration.md)
* [OPP-0033: Content-Safety Validator](docs/opportunities/OPP-0033-validate-skill-content.md) — `validate-skill-content.sh` (Wave 5.2; closes red-team V1/V2/V4/V6)
* [OPP-0034: Sensitive-Paths Overlap Validator](docs/opportunities/OPP-0034-validate-sensitive-paths.md) — `validate-sensitive-paths.sh` (Wave 5.3; closes Asserted-only claim 12)
* [OPP-0035: Security Static Analysis Module](docs/opportunities/OPP-0035-security-static-analysis.md) — `management/security-static-analysis`, child of OPP-0020 (Wave 5.4; closes underhanded-code blind spot)
* [OPP-0036: Knowledge-Redaction Validator + CODEOWNERS](docs/opportunities/OPP-0036-validate-knowledge-redaction.md) — `validate-knowledge-redaction.sh` (Wave 5.5; closes cross-pollination + reverse-leakage pathways)
* [OPP-0037: Classify-Before-Enforcing as Operating Principle](docs/opportunities/OPP-0037-classify-before-enforcing-as-operating-principle.md) — Doctrine codification; promoted the four-instance meta-pattern to operating-principles §10 (design-only OPP + half-day implementation pattern)
* [OPP-0038: Adopter Artifact Attribution Boundary](docs/opportunities/OPP-0038-adopter-artifact-attribution-boundary.md) — Signing governance artifacts in a host project without asserting affiliation/ownership (design deferred)
* [OPP-0039: AEC Domain Family (decomposed `domains/aec-*`)](docs/opportunities/OPP-0039-domain-family-aec-decomposed.md) — Second built deep-domain vertical; 3-module ISO 19650 + openBIM wedge promoted via PRD-0019 (partial promotion), 3 sub-modules deferred
* [OPP-0040: Cross-Platform Install Prerequisites](docs/opportunities/OPP-0040-cross-platform-install-prerequisites.md) — Surface + preflight install deps at first contact (accepted; PRD-0020)
* [OPP-0041: Onboarding Containment Safety](docs/opportunities/OPP-0041-onboarding-containment-safety.md) — Refuse bootstrapping a consumer inside the platform / nested in another repo (accepted; PRD-0020)
* [OPP-0042: Greenfield Onboarding Conservatism](docs/opportunities/OPP-0042-greenfield-onboarding-conservatism.md) — Route contextless greenfield to discovery, not a guessed enforced manifest (accepted; PRD-0021)
* [OPP-0043: Cybersecurity Domain Family (decomposed `domains/cybersec-*`)](docs/opportunities/OPP-0043-domain-family-cybersecurity-decomposed.md) — Third built deep-domain vertical; OSINT + engagement-charter wedge promoted via PRD-0022
* [OPP-0044: Digital Twin / Scenario Runtime Governance Overlay](docs/opportunities/OPP-0044-digital-twin-scenario-runtime.md) — Cross-cutting management overlay (ADR-0019); twin-profile maturity ladder + scenario epistemic-discipline, promoted via PRD-0023
* [OPP-0045: Geospatial / GIS Domain Family (decomposed `domains/geospatial-*`)](docs/opportunities/OPP-0045-domain-family-geospatial-decomposed.md) — Fourth built deep-domain vertical; CRS foundation + OGC exchange + BIM↔GIS georeferencing wedge promoted via PRD-0024
* [OPP-0046: Parallel Multi-Agent Work-Package Lane Contract](docs/opportunities/OPP-0046-parallel-multi-agent-work-package-lane-contract.md) — Lintable lane contract for concurrent multi-agent worktrees; lane (scope) wedge promoted via PRD-0025 (accepted — partial promotion)
* [OPP-0047: Delivery-Cost & Unit-Economics Governance](docs/opportunities/OPP-0047-delivery-cost-unit-economics-governance.md) — Token/cost attribution per delivery unit for build-vs-buy decisions; folded into PRD-0025 as a deferred v2 phase (proposed)
* [OPP-0048: Redaction-Scope & Publication-Boundary Hardening](docs/opportunities/OPP-0048-redaction-scope-and-publication-boundary-hardening.md) — Always-on do-not-publish marker gate; promoted via PRD-0026 (accepted)
* [OPP-0049: Deep Governance Vertical: Authoring-Pattern Harvest](docs/opportunities/OPP-0049-deep-governance-vertical-harvest.md) — Harvests the six-times-proven deep-domain authoring skeleton into operating-principle § 12 + a playbook (accepted)
* [OPP-0050: Module Stability Tiers & Parity Normalization](docs/opportunities/OPP-0050-module-stability-tiers-parity.md) — Per-module `stability` readiness signal; promoted via PRD-0027 (accepted)
* [OPP-0051: Frontier-Agent Cluster v2 Enforcement: Artifact-Content Validators](docs/opportunities/OPP-0051-frontier-agent-cluster-v2-enforcement.md) — The four content validators enforcing the cluster's declarative artifacts; promoted via PRD-0031 + PRD-0032 (accepted)
