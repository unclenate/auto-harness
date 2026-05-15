<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Risk Register

**Owner:** @platform-team
**Last reviewed:** 2024-03-01

Risks that could affect delivery, operations, or adoption of the harness platform. Review
monthly and before each release. Move active incidents to `docs/ops/incidents/`.

---

## Open Risks

| ID | Area | Risk | Likelihood | Impact | Mitigation | Owner | Status |
| -- | ---- | ---- | ---------- | ------ | ---------- | ----- | ------ |
| R-001 | Third-party | Agent Skills standard changes incompatibly, breaking SKILL.md frontmatter across all four skills | Low | High | Monitor Anthropic and community changelogs; pin format-version in frontmatter; skills are plain Markdown and trivially updatable | @platform-team | Monitoring |
| R-002 | Delivery | Ruby version on CI runner diverges from documented minimum (3.0+), causing test failures | Med | Med | Pin Ruby version in `ruby/setup-ruby` action; include Ruby version in dependency log | @platform-team | Mitigated |
| R-003 | Adoption | Teams adopt the harness but do not enable `validate-companions.sh` in CI, defeating the companion rule enforcement model | Med | High | Document as required step in ci-integration.md; add to harness-governance skill discipline rules; review during onboarding | @platform-team | Open |
| R-004 | Security | A governed project's AI agent acts on a Tier 4 or Tier 5 action without human review because AGENTS.md trust tiers were not read at session start | Low | High | harness-governance skill enforces session-start reads; trust model is a compiled fragment; reviewers check AGENTS.md during onboarding | @platform-team | Monitoring |

---

## Closed Risks

| ID | Area | Risk | Resolution | Closed date |
| -- | ---- | ---- | ---------- | ----------- |
| R-005 | Delivery | ripgrep not available on macOS system Ruby, causing placeholder tests to fail silently | Added `RG_AVAILABLE` guard in integration tests; tests skip gracefully when `rg` not installed; CI installs ripgrep explicitly | 2024-02-10 |
