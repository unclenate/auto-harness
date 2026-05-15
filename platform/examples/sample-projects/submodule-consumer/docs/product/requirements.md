<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Requirements

**Growth stage:** MVP / Early Access
**Intake source:** `docs/discovery/intake-questionnaire.md`
**MVP scope:** `docs/discovery/mvp-scope.md`
**Owner:** @owner
**Last updated:** YYYY-MM-DD

---

## Priority Tiers

| Tier | Meaning |
|------|---------|
| Must | Required for this version to deliver value. In MVP scope. |
| Should | High value but can ship without. Target v1+. |
| Later | Acknowledged and explicitly deferred. |

---

## User Stories

| ID | Persona | Story | Priority |
|----|---------|-------|----------|
| US-001 | Developer | As a developer, I want governance checks to run automatically in CI so that I don't have to remember to run them manually. | Must |
| US-002 | Team lead | As a team lead, I want required artifacts enforced at PR time so that documentation stays current as the codebase changes. | Must |
| US-003 | Developer | As a developer, I want clear error messages from validators so that I know exactly what artifact or rule is missing. | Must |
| US-004 | New team member | As a new team member, I want a single front-door document so that I can understand project governance without asking the team. | Should |

---

## Functional Requirements

| ID | Requirement | Acceptance Criteria | Priority | Notes |
|----|-------------|---------------------|----------|-------|
| FR-001 | Validator scripts check required artifact presence | `validate-required-artifacts.sh` passes when all declared artifacts exist; fails with named path when one is missing | Must | |
| FR-002 | Companion rule enforcement in CI | `validate-companions.sh` detects when a sensitive path changes without the required companion file being touched | Must | Powered by `harness_registry.rb` |
| FR-003 | Module graph resolves dependencies and detects conflicts | `validate-module-graph.sh` passes for valid compositions; fails with named module on conflict or missing dep | Must | |
| FR-004 | Manifest schema validation rejects malformed YAML | `validate-manifest.sh` returns non-zero and explains the error for any failing manifest | Must | |
| FR-005 | Validators surface human review gates | Output includes review gate text for modules with defined `reviewGates` | Should | |
| FR-006 | CI workflow runs all validators on PR | GitHub Actions workflow executes all four validators; blocks merge on any failure | Must | |

---

## Out of Scope

| Feature | Why deferred | When to revisit |
|---------|-------------|-----------------|
| Web UI for manifest editing | CLI is sufficient for developers; UI adds surface area with no near-term return | v2 if adoption widens to non-developer users |
| Auto-generation of missing artifacts | Risk of masking real gaps; canonical artifacts should be human-written | Later — possibly as scaffold helper with explicit opt-in |
| Programmatic API for registry | No consumer identified yet | Revisit when a second integration point emerges |
| Notification integrations (Slack, email) | Out of scope for local dev tooling | Revisit if CI output proves insufficient for async teams |

---

## Quality Expectations

| Dimension | Expectation |
|-----------|------------|
| Performance | All validators complete under 5 seconds on a standard laptop for a 50-module graph |
| Reliability | No false negatives — a passing run means manifest and artifacts are valid |
| Security | No secrets in validator output; validators operate read-only |
| Ruby version | Compatible with Ruby 3.0+ |

---

## Success Metrics

| Metric | Target | How measured |
|--------|--------|-------------|
| Validator adoption | All new platform projects include CI workflow | Review new manifests at initialization |
| False positive rate | Zero across all sample projects | Run validators in CI against sample projects |
| Time to green | Developer initializes valid manifest within 30 min of reading front-door doc | Usability check at each major release |

---

## Requirements Change Log

| Date | Change | Reason | Decided by |
|------|--------|--------|-----------|
| | | | |
