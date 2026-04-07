# Templates Reference

All harness templates use `[[PLACEHOLDER_NAME]]` tokens to mark fields that must be
filled before a file is production-ready. The `validate-placeholders.sh` validator
will fail if any `[[...]]` token remains in a tracked file.

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

---

## Template Directory Map

| Template | Required By Module | Path |
| -------- | ------------------ | ---- |
| Intake questionnaire | `management/discovery-intake` | `templates/discovery/intake-questionnaire.md` |
| MVP scope | `management/discovery-intake` | `templates/discovery/mvp-scope.md` |
| Starting assets | `management/discovery-intake` (optional) | `templates/discovery/starting-assets.md` |
| Problem statement | `management/product-lite` | `templates/product/problem-statement.md` |
| Personas | `management/product-lite` (optional) | `templates/product/personas.md` |
| Requirements | `management/product-lite` | `templates/product/requirements.md` |
| Release intent | `delivery/production-saas` | `templates/product/release-intent.md` |
| Scope plan | `management/project-standard` | `templates/project/scope-plan.md` |
| Milestones | `management/project-standard` | `templates/project/milestones.md` |
| Change log | `management/project-standard` | `templates/project/change-log.md` |
| Dependency log | `management/project-standard` | `templates/project/dependency-log.md` |
| Workstream map | `management/program-lite` | `templates/program/workstream-map.md` |
| Stakeholder report | `management/program-lite` | `templates/program/stakeholder-report.md` |
| Governance cadence | `management/program-lite` | `templates/program/governance-cadence.md` |
| Architecture overview | All production modules | `templates/architecture-overview.md` |
| ADR | All modules with arch decisions | `templates/adr.md` |
| Release checklist | `delivery/production-saas` | `templates/release-checklist.md` |
| Risk register | `delivery/production-saas` | `templates/risk-register.md` |
| Web3 risk register | `domains/web3` | `templates/web3/risk-register-web3.md` |
| Incident response | `delivery/production-saas` | `templates/incident.md` |
| Ownership map | `delivery/production-saas` | `templates/ownership-map.md` |
| Runbook index | `delivery/production-saas` | `templates/ops/runbook-index.md` |
| Runbook (individual) | Populated from runbook index | `templates/ops/runbook-template.md` |
| Chain config | `domains/web3` | `templates/web3/chain-config.md` |
| Contract registry | `domains/web3` (optional) | `templates/web3/contract-registry.md` |
| Token strategy | `domains/web3` (optional) | `templates/web3/token-strategy.md` |
| Web3 ADR | `domains/web3` | `templates/web3/adr-web3.md` |
| Web3 intake supplement | `domains/web3` | `templates/web3/web3-intake-supplement.md` |

---

## Reference

| Resource | Path |
| -------- | ---- |
| Placeholder validator | `platform/validators/validate-placeholders.sh` |
| Bootstrap quickstart | `platform/workflow/bootstrap-quickstart.md` |
| Discovery workflow | `platform/workflow/discovery-to-composition.md` |
| SUMMARY.md | `platform/SUMMARY.md` |
