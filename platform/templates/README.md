<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Templates Reference

All harness templates use `[[PLACEHOLDER_NAME]]` tokens to mark fields that must be
filled before a file is production-ready. The `validate-placeholders.sh` validator
will fail if any `[[...]]` token remains in a tracked file.

> **Two classes of token.** *Header tokens* (`[[YEAR]]`, `[[OWNER_NAME]]`,
> `[[OWNER_EMAIL]]`, `[[SPDX_LICENSE]]`, `[[PROJECT_NAME]]`) appear in
> every template's SPDX/copyright header block — they are project-wide
> and filled *once* via
> [`platform/bootstrap/set-consumer-headers.sh`](../bootstrap/set-consumer-headers.sh).
> *Per-record tokens* (e.g. `[[OWNER]]`, `[[OPP_TITLE]]`, `[[ADR_TITLE]]`)
> appear in template bodies — filled per-artifact when the consumer scaffolds
> a specific ADR / OPP / observation. The bootstrap helper deliberately
> does *not* touch per-record tokens.

---

## Placeholder Convention

Placeholders follow the format: `[[UPPER_SNAKE_CASE]]`

Fill every placeholder with real content before committing the file to a shared branch.
Date placeholders (`YYYY-MM-DD`) are also treated as unfilled by the placeholder validator.

---

## Common Placeholder Reference

| Placeholder | Used In | What to Fill |
| ----------- | ------- | ------------ |
| `[[PROJECT_NAME]]` | Most templates | The project's display name |
| `[[PROJECT_ID]]` | Manifest, scope plan | Kebab-case unique identifier (e.g., `my-app`) |
| `[[OWNER]]` | Most templates | GitHub handle or team name (e.g., `@alice` or `@platform-team`) |
| `[[BACKUP]]` | Ownership map | Secondary owner handle |
| `[[TECH_LEAD]]` | Architecture, scope plan | Technical lead handle |
| `[[DELIVERY_LEAD]]` | Program templates | Delivery lead handle |
| `[[PROGRAM_MANAGER]]` | Program templates | Program manager handle |
| `[[EXECUTIVE_SPONSOR]]` | Governance cadence | Executive sponsor handle |
| `[[SECURITY_OWNER]]` | Risk register, ownership map | Security lead handle |
| `[[RISK_OWNER]]` | Risk register | Primary owner of the risk register |
| `[[DECISION_SUMMARY]]` | Change log, governance cadence | One-sentence decision description |
| `[[WHAT_CHANGED]]` | Change log | What changed (scope, plan, or technical direction) |
| `[[WHY]]` | Change log, ADR | Rationale for the change |
| `[[MILESTONE_1]]` | Milestones, scope plan | Milestone name (e.g., `Alpha`, `Beta`, `Launch`) |
| `[[ACCEPTANCE_CRITERIA]]` | Milestones | Concrete, verifiable done condition |
| `[[EXIT_CRITERIA]]` | Scope plan, milestones | What must be true to complete this phase |
| `[[WORKSTREAM_1]]` | Workstream map | Workstream name |
| `[[DEPENDENCY_1]]` | Dependency log | External dependency name |
| `[[BLOCKER_DESCRIPTION]]` | Workstream map | What is blocking the workstream |
| `[[RISK_1]]` | Risk register | One-line risk description |
| `[[MITIGATION]]` | Risk register | Control or plan to reduce the risk |
| `[[AREA]]` | Risk register | Risk category (Security, Data, Infra, Delivery, etc.) |
| `[[OPERATION_NAME]]` | Runbook template | Name of the operation (e.g., `Database Failover`) |
| `[[TRIGGER_CONDITION]]` | Runbook template | When to use this runbook |
| `[[DURATION]]` | Runbook template | Expected time to complete (e.g., `15 minutes`) |
| `[[TIER]]` | Runbook template | Harness trust tier required (1–5) |
| `[[ESCALATION_CONTACT]]` | Runbook template | Who to contact if operation fails |
| `[[CHAIN_NAMES]]` | Web3 risk register | Chains in scope (e.g., `Ethereum mainnet, Base`) |
| `[[RISK_SIGNAL]]` | Web3 risk register | The signal being tracked (e.g., `address_sanctions_hit`) |
| `[[AUDIT_THRESHOLD]]` | Web3 risk register | Contract value above which audit is required |
| `[[STALENESS_LIMIT]]` | Web3 risk register | Maximum age for oracle data (in seconds) |
| `[[PROGRAM_NAME]]` | Stakeholder report | Program display name |
| `[[TWO_TO_THREE_SENTENCE_SUMMARY]]` | Stakeholder report | Current status summary |
| `[[CADENCE_NAME]]` | Governance cadence | Name of the recurring meeting or review |
| `[[PERSONA_NAME]]` | Personas template | Persona name (e.g., `Alex — Power User`) |
| `[[IN_SCOPE_ITEM_1]]` | Scope plan | Specific deliverable in scope |
| `[[OUT_OF_SCOPE_ITEM_1]]` | Scope plan | Specific item explicitly not in scope |
| `[[UNIT_LINE_PCT]]` | Coverage thresholds | Minimum unit test line coverage (e.g., `80`) |
| `[[UNIT_BRANCH_PCT]]` | Coverage thresholds | Minimum unit test branch coverage (e.g., `75`) |
| `[[UNIT_FUNCTION_PCT]]` | Coverage thresholds | Minimum unit test function coverage (e.g., `80`) |
| `[[UNIT_CMD]]` | Test strategy, test plan | Command to run unit tests |
| `[[INTEGRATION_CMD]]` | Test strategy, test plan | Command to run integration tests |
| `[[E2E_CMD]]` | Test strategy, test plan | Command to run E2E tests |
| `[[FLAKY_TRIAGE_SLA]]` | Test strategy | Time to triage a flaky test (e.g., `48 hours`) |
| `[[MILESTONE_OR_RELEASE_NAME]]` | Test plan | Name of the release or milestone being tested |
| `[[SEED_COMMAND]]` | Test plan | Command to seed the test database |
| `[[RESTORATION_DEADLINE]]` | Coverage thresholds | Deadline for restoring a lowered threshold |
| `[[PRD_TITLE]]` | PRD template | Short title for the product decision |
| `[[PRD_OVERVIEW]]` | PRD template | 2-3 sentence summary of the decision and the problem it solves |
| `[[USER_ACTION]]` | PRD template | Action in user story (e.g., `manage my subscription`) |
| `[[USER_VALUE]]` | PRD template | Value in user story (e.g., `I can control my billing`) |
| `[[TECHNICAL_CONSTRAINT]]` | PRD template | Technical constraint on the feature |
| `[[METRIC]]` | PRD template | Name of the KPI |
| `[[TARGET]]` | PRD template | Success metric target value |
| `[[METHOD]]` | PRD template | How the success metric is measured |
| `[[OPEN_QUESTION]]` | PRD template | Question to resolve before or during implementation |
| `[[RELATED_DOCUMENT]]` | PRD template | Link to related ADR, PRD, design doc, or external reference |
| `[[RELATED_ADR]]` | PRD template | ADR numbers this PRD depends on or extends |
| `[[REVIEW_CYCLE]]` | PRD template, standards docs | Review cadence (e.g., `Quarterly`, `Semi-annually`, `Annually`) |
| `[[REQUIREMENT]]` | PRD template | Specific functional requirement description |
| `[[GOAL_1]]` | PRD template (Goals & Non-Goals) | Outcome the PRD commits to delivering |
| `[[NON_GOAL_1]]` | PRD template (Goals & Non-Goals) | Outcome explicitly out of scope, with reason |
| `[[STACK_LANGUAGE]]` | PRD template (Tech Stack) | Decided language / runtime |
| `[[STACK_FRAMEWORK]]` | PRD template (Tech Stack) | Decided framework |
| `[[STACK_DATA_STORE]]` | PRD template (Tech Stack) | Decided data store |
| `[[STACK_HOSTING]]` | PRD template (Tech Stack) | Decided hosting / deploy target |
| `[[STACK_AUTH]]` | PRD template (Tech Stack) | Decided auth provider or strategy |
| `[[STACK_OTHER]]` | PRD template (Tech Stack) | Other infra (queue, cache, observability, etc.) |
| `[[API_METHOD]]` | PRD template (API & Data) | HTTP method |
| `[[API_PATH]]` | PRD template (API & Data) | Endpoint path |
| `[[API_AUTH]]` | PRD template (API & Data) | Auth requirement for the endpoint |
| `[[API_REQUEST]]` | PRD template (API & Data) | Request body shape |
| `[[API_RESPONSE]]` | PRD template (API & Data) | Response body shape |
| `[[DATA_ENTITY]]` | PRD template (API & Data) | Primary data entity name |
| `[[DATA_SCHEMA_LINK]]` | PRD template (API & Data) | Link to authoritative schema (OpenAPI, Prisma, SQL, Pydantic) |
| `[[VIEW_NAME]]` | PRD template (UI/UX) | Major view name |
| `[[VIEW_LAYOUT_DESCRIPTION]]` | PRD template (UI/UX) | One-paragraph layout description |
| `[[UI_EMPTY_STATE]]` | PRD template (UI/UX) | Empty-state behavior |
| `[[UI_LOADING_STATE]]` | PRD template (UI/UX) | Loading-state behavior |
| `[[UI_ERROR_STATE]]` | PRD template (UI/UX) | Error-state behavior |
| `[[UI_SUCCESS_STATE]]` | PRD template (UI/UX) | Success / completion-state behavior |
| `[[UI_WCAG_TARGET]]` | PRD template (UI/UX) | Accessibility target (e.g., `WCAG 2.1 AA`) |
| `[[UI_BREAKPOINTS]]` | PRD template (UI/UX) | Breakpoints / device support |
| `[[GATE_LINT]]` | PRD template (CI/CD Gates) | Yes/No — lint required |
| `[[GATE_TYPECHECK]]` | PRD template (CI/CD Gates) | Yes/No — type-check required |
| `[[GATE_COVERAGE]]` | PRD template (CI/CD Gates) | Coverage threshold (e.g., `≥80%`) |
| `[[GATE_TESTS]]` | PRD template (CI/CD Gates) | Yes/No — required tests added |
| `[[GATE_VALIDATORS]]` | PRD template (CI/CD Gates) | Yes/No — validator chain passes |
| `[[GATE_COMPANIONS]]` | PRD template (CI/CD Gates) | Yes/No — companion-rule check passes |
| `[[GATE_CHANGELOG]]` | PRD template (CI/CD Gates) | Yes/No — change log updated |
| `[[FINDING_DESCRIPTION]]` | Revision tracker | One-line description of the finding |
| `[[AFFECTED_DOCS]]` | Revision tracker | Documents affected by the finding |
| `[[OBSERVATION_STRUCTURE]]` | Knowledge README | Foundational choice: `Structured Template`, `Freeform prose`, or `Severity-prefixed findings` |
| `[[LOCKING_ADR]]` | Knowledge & opportunity README templates | The ADR number that locks the foundational structural choice (e.g., `ADR-0015` for observation structure, `ADR-0004` for opportunity record structure) |
| `[[WRITE_POLICY]]` | Knowledge & opportunity README templates, distilled learnings | Current write policy: `autonomous`, `heartbeat-only`, or `draft-to-promote` |
| `[[WRITE_POLICY_RATIONALE]]` | Knowledge & opportunity README templates | Why the project is in the current write policy mode |
| `[[DRAFT_CADENCE]]` | Knowledge README | How often agents draft distilled learnings (e.g., `weekly`) |
| `[[REVIEW_CADENCE]]` | Knowledge README | How often the team reviews drafts (e.g., `biweekly`) |
| `[[FIRST_OBSERVATION_TITLE]]` | Shared observations | Title of the seed observation (in the initial template) |
| `[[CONTEXT]]` | Shared observations | What situation prompted the observation |
| `[[OBSERVATION]]` | Shared observations | What was noticed, specific and factual |
| `[[IMPLICATION]]` | Shared observations | What this observation suggests for the project or harness |
| `[[CONFIDENCE]]` | Shared observations | `low`, `medium`, or `high` |
| `[[SEVERITY]]` | Shared observations | `informational`, `governance-relevant`, `architectural`, or `risk-bearing` |
| `[[CONTRIBUTOR]]` | Shared observations | Agent name or `@handle` |
| `[[OBSERVATION_COUNT]]` | Distilled learnings | Count of observations since last review |
| `[[REVIEWER]]` | Review log | Name/handle of the reviewer (e.g., `@unclenate`) |
| `[[REVIEW_SUBJECT]]` | Review log | What was reviewed (e.g., `ADR-0007`, `docs/product/requirements.md §3`) |
| `[[REVIEW_CONTEXT]]` | Review log | Why the review happened (e.g., `Tier 3 commit gate`, `ADR status change`) |
| `[[REVIEW_NOTES]]` | Review log | Additional context or follow-up actions |
| `[[KPI_DEFINITION]]` | KPI dictionary | One-sentence definition of what the KPI measures |
| `[[KPI_FORMULA]]` | KPI dictionary | Explicit, reproducible calculation formula |
| `[[KPI_DATA_SOURCE]]` | KPI dictionary | Where the raw data comes from |
| `[[KPI_FREQUENCY]]` | KPI dictionary | Reporting cadence (e.g., `Monthly`, `On-change`) |
| `[[KPI_APPLICABILITY]]` | KPI dictionary | Which projects, tiers, or domains track this KPI |
| `[[KPI_BASELINE_PROTOCOL]]` | KPI dictionary | How the initial baseline is established |
| `[[COMPONENT_NAME]]` | Fallback matrix | Name of the failed component (e.g., `Supabase`, `Ollama`) |
| `[[IMPACT]]` | Fallback matrix | What breaks when the component fails |
| `[[FALLBACK]]` | Fallback matrix | What replaces the normal capability |
| `[[TRIGGER]]` | Fallback matrix | Condition that signals it's time to switch |
| `[[P0_DESCRIPTION]]` | Fallback matrix | Revenue-critical / safety-critical functions |
| `[[P1_DESCRIPTION]]` | Fallback matrix | Core business operation functions |
| `[[P2_DESCRIPTION]]` | Fallback matrix | Delivery pipeline functions |
| `[[P3_DESCRIPTION]]` | Fallback matrix | Convenience / non-blocking functions |
| `[[FUNCTION_NAME]]` | Fallback matrix | Name of the automated function being covered |
| `[[NORMAL_MODE]]` | Fallback matrix | How the function operates when everything works |
| `[[DEGRADED_MODE]]` | Fallback matrix | Reduced-capability operation mode |
| `[[MANUAL_FALLBACK]]` | Fallback matrix | Human-executed alternative when automation is unavailable |
| `[[SWITCH_TRIGGER]]` | Fallback matrix | Condition that causes a mode change |
| `[[EXIT_CRITERIA]]` | Fallback matrix | When to return to normal mode |
| `[[FALLBACK_TYPE]]` | Fallback matrix | Which fallback mode was exercised (degraded or manual) |
| `[[NOTES]]` | Fallback matrix | Issues found during a fallback exercise |
| `[[OPP_TITLE]]` | Opportunity template | Title of the candidate (e.g., `Exportable governance contract for runtime harnesses`) |
| `[[OPP_OWNER]]` | Opportunity template | GitHub handle accountable for moving the candidate through its lifecycle |
| `[[OPP_CONFIDENCE]]` | Opportunity template | `low`, `medium`, or `high` |
| `[[OPP_THESIS]]` | Opportunity template | One to three sentences: what the opportunity is, in plain language |
| `[[OPP_ORIGIN_EVIDENCE]]` | Opportunity template | Links to observations, external signals, or a `thesis-only` marker with stated reason |
| `[[OPP_WHY_NOW]]` | Opportunity template | Timing signal or `n/a` |
| `[[OPP_RISKS_OPEN_QUESTIONS]]` | Opportunity template | What would have to be true; what could kill it |

---

## Template Naming Convention

Template file names do not always match their artifact destination paths. The convention
is to flatten the directory when a template is the only file for its category:

| Template path | Artifact destination |
|--------------|---------------------|
| `templates/architecture-overview.md` | `docs/architecture/overview.md` |
| `templates/risk-register.md` | `docs/security/risk-register.md` |
| `templates/ownership-map.md` | `docs/ops/ownership-map.md` |
| `templates/operating-principles.md` | `docs/operating-principles.md` |
| `templates/tools.md` | `TOOLS.md` (project root) |

Numbered record types use the template as a starting point but are stored
with their own naming convention:

| Template path | Artifact destination |
|--------------|---------------------|
| `templates/adr.md` | `docs/adr/ADR-NNNN-slug.md` |
| `templates/product/prd.md` | `docs/requirements/PRD-NNNN-slug.md` |

Templates that share a category directory keep the subdirectory structure intact
(e.g., `templates/ops/`, `templates/testing/`, `templates/web3/`).

---

## Template Directory Map

Jump to: [Discovery](#discovery) | [Product](#product) | [Project](#project) |
[Program](#program) | [Testing](#testing) | [Governance](#governance) |
[Architecture and Operations](#architecture-and-operations) | [Database](#database) |
[Web3](#web3-templates) | [Healthcare](#healthcare-templates) |
[Privacy](#privacy-templates)

> [!NOTE]
> Templates for the Cybersecurity domain family (OPP-0043 / PRD-0022) are deferred to Phase 2.

### Discovery

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Intake questionnaire | `management/discovery-intake` | `templates/discovery/intake-questionnaire.md` |
| MVP scope | `management/discovery-intake` | `templates/discovery/mvp-scope.md` |
| Starting assets | `management/discovery-intake` (optional) | `templates/discovery/starting-assets.md` |

### Product

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Problem statement | `management/product-lite` | `templates/product/problem-statement.md` |
| Personas | `management/product-lite` (optional) | `templates/product/personas.md` |
| Requirements | `management/product-lite` | `templates/product/requirements.md` |
| Release intent | `management/product-lite` | `templates/product/release-intent.md` |
| PRD | `management/product-lite` | `templates/product/prd.md` |

### Project

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Scope plan | `management/project-standard` | `templates/project/scope-plan.md` |
| Milestones | `management/project-standard` | `templates/project/milestones.md` |
| Change log | `management/project-standard` | `templates/project/change-log.md` |
| Dependency log | `management/project-standard` | `templates/project/dependency-log.md` |
| Revision tracker | `management/project-standard` | `templates/project/revision-tracker.md` |
| Review log | `management/project-standard` (optional) | `templates/project/review-log.md` |

### Knowledge

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Knowledge README | `management/knowledge-capture` | `templates/knowledge/README.md` |
| Shared observations | `management/knowledge-capture` | `templates/knowledge/shared-observations.md` |
| Distilled learnings *(dormant — see ADR-0014)* | — *(no longer required by `management/knowledge-capture` v1.2.0+; template retained as a dormancy pointer for existing consumers)* | `templates/knowledge/distilled-learnings.md` |

### Opportunity

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Opportunity README | `management/opportunity-capture` | `templates/opportunity/README.md` |
| Opportunity record (`OPP-NNNN-slug.md`) | `management/opportunity-capture` | `templates/opportunity/opp-template.md` |

### Program

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Workstream map | `management/program-lite` | `templates/program/workstream-map.md` |
| Stakeholder report | `management/program-lite` | `templates/program/stakeholder-report.md` |
| Governance cadence | `management/program-lite` | `templates/program/governance-cadence.md` |

### Testing

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Test strategy | `management/testing-standard` | `templates/testing/test-strategy.md` |
| Coverage thresholds | `management/testing-standard` | `templates/testing/coverage-thresholds.md` |
| Test plan | `management/testing-standard` (optional) | `templates/testing/test-plan.md` |
| Eval strategy | `management/eval-gated-testing` | `templates/testing/eval-strategy.md` |

### Skills

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Skill authoring conventions | `architectures/agent-skill-pack` (optional) | `templates/skills/authoring-conventions.md` |

### Deployment

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Self-hosting guide | `delivery/self-hosted-oss` | `templates/deployment/self-hosting-guide.md` |

### Governance

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Operating principles | `core/kernel/base` | `templates/operating-principles.md` |
| Tools registry (TOOLS.md) | `agents/openclaw` | `templates/tools.md` |
| Project SUMMARY.md (GitBook TOC) | `domains/gitbook` | `templates/docs/SUMMARY.md` |
| do-not-publish marker | `core/kernel/base` | `templates/governance/do-not-publish-marker.md` |

### Standards

Single-source-of-truth documents that other artifacts reference instead of
duplicating inline. Absorbed from governance patterns observed in adsclaw.

| Template | Optional/Required | Module | Path |
| -------- | ----------------- | ------ | ---- |
| KPI dictionary | Optional | `management/product-lite` | `templates/standards/kpi-dictionary.md` |

### Security

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| SAST coverage declaration | `management/security-static-analysis` | `templates/security/sast-coverage.md` |
| Agent defense-in-depth | `architectures/agent-defense-in-depth` | `templates/security/agent-defense-in-depth.md` |
| Append-only action log | `architectures/agent-defense-in-depth` | `templates/security/append-only-action-log.md` |

### Canonical Position

The ratified strategic north-star and its ratification trail. Part of the
`management/canonical-position` overlay (PRD-0007 / OPP-0007).

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Canonical position (north-star) | `management/canonical-position` | `templates/canonical-position/canonical-position.md` |
| Review-artifact (ratification trail) | `management/canonical-position` | `templates/canonical-position/review.md` |

### Architecture and Operations

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Architecture overview | All production modules | `templates/architecture-overview.md` |
| ADR | All modules with arch decisions | `templates/adr.md` |
| Release checklist | `delivery/production-saas` | `templates/release-checklist.md` |
| Risk register | `delivery/production-saas` | `templates/risk-register.md` |
| Incident response | `delivery/production-saas` | `templates/incident.md` |
| Ownership map | `delivery/production-saas` | `templates/ownership-map.md` |
| Runbook index | `delivery/production-saas` | `templates/ops/runbook-index.md` |
| Environment inventory | `delivery/production-saas` | `templates/ops/environment-inventory.md` |
| Rollback checklist | `delivery/production-saas` | `templates/ops/rollback-checklist.md` |
| Runbook (individual) | Populated from runbook index | `templates/ops/runbook-template.md` |
| Fallback matrix | `delivery/production-saas` (optional) | `templates/ops/fallback-matrix.md` |
| Fleet inventory | `delivery/managed-fleet` | `templates/ops/fleet-inventory.md` |
| Change control | `delivery/managed-fleet` | `templates/ops/change-control.md` |
| Config rollback | `delivery/managed-fleet` | `templates/ops/config-rollback.md` |

### Observability

The OpenTelemetry multi-agent trace contract and exporter posture for projects where
agent activity is a first-class observable surface (`architectures/agent-observability`,
PRD-0014 / OPP-0029).

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Trace contract | `architectures/agent-observability` | `templates/observability/trace-contract.md` |
| Trace exporters | `architectures/agent-observability` | `templates/observability/exporters.md` |

### Foundry Target

The enterprise-AI-foundry target declaration — which foundries a project commits to
landing in and the portable, foundry-agnostic evidence for each — for projects with
the `architectures/ai-foundry-target` overlay (PRD-0028 / OPP-0028).

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Foundry targets | `architectures/ai-foundry-target` | `templates/architecture/foundry-targets.md` |

### Model Routing

The task→model routing table — which models a project routes which tasks to, and why —
for projects with the `architectures/intelligent-model-routing` overlay
(PRD-0029 / OPP-0030).

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Model routing | `architectures/intelligent-model-routing` | `templates/architecture/model-routing.md` |

### Database

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Migration readiness | `data/relational-postgres` | `templates/database/migration-readiness.md` |

### Web3 Templates

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Web3 risk register | `domains/web3` | `templates/web3/risk-register-web3.md` |
| Chain config | `domains/web3` | `templates/web3/chain-config.md` |
| Contract registry | `domains/web3` (optional) | `templates/web3/contract-registry.md` |
| Token strategy | `domains/web3` (optional) | `templates/web3/token-strategy.md` |
| Web3 ADR | `domains/web3` | `templates/web3/adr-web3.md` |
| Web3 intake supplement | `domains/web3` | `templates/web3/web3-intake-supplement.md` |

### Healthcare Templates

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| FHIR resource map | `domains/healthcare-fhir` | `templates/healthcare/fhir-resource-map.md` |
| Jurisdiction profile | `domains/healthcare-fhir` | `templates/healthcare/jurisdiction-profile.md` |
| SMART scope map | `domains/healthcare-smart-on-fhir` | `templates/healthcare/smart-scope-map.md` |

### Privacy Templates

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Privacy profile (bias-guardrail + regime declaration) | `management/privacy-by-design` | `templates/privacy/privacy-profile.md` |
| Data inventory | `management/privacy-by-design` | `templates/privacy/data-inventory.md` |
| Privacy impact assessment (DPIA / PIA) | `management/privacy-by-design` | `templates/privacy/privacy-impact-assessment.md` |

### Digital Twin

Templates for projects that model real-world systems, run scenarios, and publish
decision-support. Copy the files you need into the project's `docs/twin/` tree.

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Twin profile (forcing artifact) | `management/digital-twin` | `templates/digital-twin/twin-profile.md` |
| Overview and maturity ladder | `management/digital-twin` | `templates/digital-twin/overview.md` |
| Scenario manifest spec | `management/digital-twin` | `templates/digital-twin/scenario-manifest-spec.md` |
| Data provenance | `management/digital-twin` | `templates/digital-twin/data-provenance.md` |
| Model registry | `management/digital-twin` | `templates/digital-twin/model-registry.md` |
| Agent registry | `management/digital-twin` | `templates/digital-twin/agent-registry.md` |
| Run log spec | `management/digital-twin` | `templates/digital-twin/run-log-spec.md` |
| Uncertainty policy | `management/digital-twin` | `templates/digital-twin/uncertainty-policy.md` |
| Publication policy | `management/digital-twin` | `templates/digital-twin/publication-policy.md` |
| Security boundaries | `management/digital-twin` | `templates/digital-twin/security-boundaries.md` |

### Work Package

Template for one parallel multi-agent work-package. Copy into the project's
`docs/work-package/` tree; fill the prose and the fenced lane block.

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Work-package lane (forcing artifact) | `management/work-package` | `templates/work-package/lane.md` |

### AEC

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Information Management Plan | `domains/aec-iso19650-im` | `templates/aec/information-management-plan.md` |
| Jurisdiction Profile | `domains/aec-iso19650-im` | `templates/aec/jurisdiction-profile.md` |
| Exchange Requirements | `domains/aec-openbim-exchange` | `templates/aec/exchange-requirements.md` |
| Sensitivity Assessment | `domains/aec-iso19650-5-security` | `templates/aec/sensitivity-assessment.md` |
| Security Management Plan | `domains/aec-iso19650-5-security` | `templates/aec/security-management-plan.md` |

### Geospatial

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Spatial Reference Profile | `domains/geospatial-foundation` | `templates/geospatial/spatial-reference-profile.md` |
| Dataset Inventory | `domains/geospatial-foundation` | `templates/geospatial/dataset-inventory.md` |
| Exchange Profile | `domains/geospatial-exchange` | `templates/geospatial/exchange-profile.md` |
| Georeference Map | `domains/geospatial-bim-georeference` | `templates/geospatial/georeference-map.md` |

### Agentic Interface

Templates for projects shipping an in-product copilot / generative-UI / conversational-primary
surface. Copy the files you need into the project's `docs/agentic-interface/` tree.

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Agentic interface README | `domains/agentic-interfaces` | `templates/agentic-interface/README.md` |
| Interface design | `domains/agentic-interfaces` | `templates/agentic-interface/design.md` |
| Prompt + tool registry | `domains/agentic-interfaces` | `templates/agentic-interface/prompt-tool-registry.md` |
| Renderer contract | `domains/agentic-interfaces` | `templates/agentic-interface/renderer-contract.md` |
| Interface risk register | `domains/agentic-interfaces` | `templates/agentic-interface/risk-register.md` |

### MCP

Templates for projects that ship a Model Context Protocol server. Written against the
**MCP 2025-06-18 spec revision**; pin the revision your server targets in `server-spec.md`.

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| MCP template family README | `architectures/mcp-server` | `templates/mcp/README.md` |
| MCP server spec | `architectures/mcp-server` | `templates/mcp/server-spec.md` |
| Capability schema | `architectures/mcp-server` | `templates/mcp/capability-schema.md` |
| Tool registry | `architectures/mcp-server` | `templates/mcp/tool-registry.md` |
| Transport and auth | `architectures/mcp-server` | `templates/mcp/transport-and-auth.md` |
| Prompt-injection test plan | `architectures/mcp-server` | `templates/mcp/prompt-injection-test-plan.md` |
| MCP risk register | `architectures/mcp-server` | `templates/mcp/risk-register.md` |

### CI

Ready-to-copy CI configurations that run the auto-harness validator chain on
consumer projects. Pick the file matching your CI provider; both fill in via
`bash .harness/platform/bootstrap/set-consumer-headers.sh`.

| Template | Provider | Path |
| -------- | -------- | ---- |
| GitHub Actions workflow | GitHub Actions | `templates/ci/github-actions.yml` |
| GitLab CI pipeline | GitLab CI | `templates/ci/gitlab-ci.yml` |
| CI template family README | — | `templates/ci/README.md` |

---

## Reference

| Resource | Path |
| -------- | ---- |
| Placeholder validator | `platform/validators/validate-placeholders.sh` |
| Bootstrap quickstart | `platform/workflow/bootstrap-quickstart.md` |
| Discovery workflow | `platform/workflow/discovery-to-composition.md` |
| SUMMARY.md | `SUMMARY.md` (repository root) |
