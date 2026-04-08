# Release Intent

**Release:** Alpha
**Growth stage:** Alpha / Internal platform
**Owner:** @unclenate
**Last updated:** 2026-04-07

---

## Target Outcome

The harness framework is usable by the creator and early adopters to govern AI-assisted
software projects. A developer can bootstrap a new project or onboard an existing codebase
with a complete governance contract — validators, templates, companion rules, and decision
records — in under 30 minutes.

---

## Feature Maturity

**This release:** Alpha / Internal platform — the framework is functional and self-governing,
but the audience is the creator and close collaborators. External polish, packaging, and
documentation for unknown users is not yet a priority.

---

## Scope of This Release

- 24 modules across 8 families with full module.yaml contracts and READMEs
- 6 validators with 51 automated tests
- 35 templates covering all required artifacts
- ADR and PRD record types with companion rule CI integration
- 4 Agent Skills in standard format
- 6 starter compositions
- Brownfield onboarding workflow
- Self-governance via own manifest and artifacts

---

## What Is Not in This Release

- Custom module creation guide (documented patterns exist; no formal guide)
- Runtime trust tier enforcement (advisory only)
- Multi-repo governance support
- Packaging or distribution (no npm/gem/pip package; copy-based adoption)

---

## Success Signals

| Signal | How measured | Target |
|--------|-------------|--------|
| All validators pass on self | Run validators against repo root | 0 failures |
| All tests pass | Run test suite | 51 pass, 0 skip |
| Self-governance complete | No disabled validations in manifest | 0 overrides |
| First consumer project onboarded | Apply harness to a real project | 1 project |
