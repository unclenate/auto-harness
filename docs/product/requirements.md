<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Requirements

**Project:** Development Harness Framework (`docs/product/problem-statement.md`)
**Growth stage:** Alpha
**Owner:** @unclenate
**Last updated:** 2026-04-07

Priority tiers:

- **Must** — required for this version to deliver value
- **Should** — high value but can ship without
- **Later** — acknowledged and deferred

---

## User Stories

| ID | As a... | I want to... | So that... | Priority |
|----|---------|-------------|------------|----------|
| US-001 | Developer using AI assistants | Declare which governance modules are active for my project | Validators enforce the right rules without manual configuration | Must |
| US-002 | Developer | Have templates for every required artifact | I can bootstrap a governed project in minutes, not hours | Must |
| US-003 | Team lead | Onboard an existing codebase progressively | I don't have to create all artifacts before getting any governance value | Must |
| US-004 | Developer | Record architectural decisions as ADRs | Future contributors understand why the system is built this way | Must |
| US-005 | Developer | Record product decisions as PRDs | The rationale behind feature choices survives context switches and team changes | Must |
| US-006 | Developer | Run validators locally and in CI | Governance drift is caught before merge, not after | Must |
| US-007 | Developer | Use any AI coding tool with the same governance | Switching tools doesn't mean losing governance | Should |
| US-008 | Developer | Install agent skills that provide domain expertise | Agents have both governance context and API accuracy | Should |

---

## Functional Requirements

| ID | Requirement | Acceptance Criteria | Priority | Notes |
|----|-------------|---------------------|----------|-------|
| FR-001 | Modular manifest system | Projects declare active modules in YAML; validator resolves dependency graph | Must | Done |
| FR-002 | 6 core validators | manifest, module-graph, required-artifacts, placeholders, agent-pack, companions all pass | Must | Done |
| FR-003 | Automated test suite | Unit and integration tests cover all validator logic; 0 failures, 0 skips | Must | Done (51 tests) |
| FR-004 | Template coverage | Every required artifact declared by any module has a corresponding template | Must | Done (35 templates) |
| FR-005 | PRD record type | Numbered product decision records with CI companion rule integration | Must | Done |
| FR-006 | ADR record type | Numbered architectural decision records with CI companion rule integration | Must | Done |
| FR-007 | Brownfield onboarding | Progressive compliance path for existing codebases | Must | Done |
| FR-008 | Agent Skills integration | Skills in standard SKILL.md format discoverable by compliant clients | Should | Done (4 skills) |
| FR-009 | Self-governance | Harness governs itself using its own module system and artifacts | Should | In progress |
| FR-010 | Custom module creation guide | Documentation for creating new modules beyond the built-in set | Later | |

---

## Out of Scope for This Version

| Feature | Reason deferred | When to revisit |
|---------|----------------|-----------------|
| Runtime enforcement of trust tiers | Shell scripts can't enforce tool permissions; governance is advisory | When agent tooling APIs support permission gating |
| Automated CODEOWNERS generation | Useful but not core governance; manual CODEOWNERS works | After v1 |
| GUI or web dashboard | The harness is a developer tool; CLI and file-based is appropriate | If adoption requires it |
| Multi-repo governance | Single-repo governance must be solid first | After proven in 5+ consumer projects |

---

## Quality Expectations

| Area | Expectation | Notes |
|------|-------------|-------|
| Performance | Validators complete in < 5s on a typical project | Ruby + shell; no compilation step |
| Reliability | All validators idempotent; safe to run repeatedly | No side effects |
| Security | No secrets in templates or examples | Platform repo contains no runtime code |
| Compatibility | Works on macOS and Linux; requires Ruby, Bash, ripgrep | Documented in validator README |

---

## Success Metrics

| Metric | Target | Measurement method |
|--------|--------|-------------------|
| Template coverage | 100% of required artifacts | Automated: compare module.yaml requiredArtifacts vs templates/ |
| Test pass rate | 100%, 0 skips | CI: `ruby -I ... test/*.rb` |
| Self-governance gap | 0 disabled validations | Manual: review harness.manifest.yaml overrides |
| Documentation parity | Every module has README matching module.yaml | Gap analysis process |

---

## Requirements Change Log

| Date | Change | Reason | Owner |
|------|--------|--------|-------|
| 2026-04-07 | Added FR-005 (PRD record type) | PRDs were lost in monolith-to-modular decomposition; restored as first-class records | @unclenate |
| 2026-04-07 | Added FR-009 (self-governance) | Harness should eat its own dog food | @unclenate |
