# Milestones

**Owner:** @platform-team
**Last updated:** 2024-01-15

Milestones track the major delivery gates for the harness platform. Each milestone has explicit
completion criteria — a milestone is not "done" unless every criterion is verifiable.

---

| Milestone | Target Date | Owner | Status | Completion Criteria |
| --------- | ----------- | ----- | ------ | ------------------- |
| Core validators green | 2024-01-20 | @platform-team | Complete | All six validators exit 0 against the sample project; unit + integration test suite passes |
| Module profile library complete | 2024-02-01 | @platform-team | Complete | All profiles have substantive README, module.yaml with correct requiredArtifacts/companionRules |
| Template library complete | 2024-02-10 | @platform-team | Complete | All templates have guidance prose, [[PLACEHOLDER]] tokens, and match the quality bar in templates/README.md |
| Skills published (Agent Skills format) | 2024-02-15 | @platform-team | Complete | harness-governance, harness-testing, harness-web3, harness-onboarding pass frontmatter validation; body covers stated use cases |
| CI integration guide verified | 2024-02-20 | @platform-team | Complete | validate-placeholders.sh runs correctly in CI with ripgrep; GitHub Actions workflow template passes against sample project |
| Brownfield onboarding capability | 2024-03-01 | @platform-team | Complete | harness-onboarding skill produces valid lite manifest; brownfield-lite.yaml passes validators; workflow guide complete |
| Alpha release — team distribution | 2024-03-15 | @platform-team | In Progress | All validators passing, no critical stubs, test suite green, brownfield onboarding path usable |
| First governed project onboarded | 2024-04-01 | @platform-team | Planned | An external project has a valid manifest, passing validators, and CI integration active |
| v1.0 — documentation and governance stable | 2024-05-01 | @platform-team | Planned | Schema version frozen at 1; all breaking changes require version bump; full-team onboarding guide published |

---

## Milestone Health

Status values:

- **Complete** — all criteria verified and signed off
- **In Progress** — actively being worked on
- **Planned** — scheduled but not yet started
- **Blocked** — cannot proceed; blocker noted in change log
- **Deferred** — milestone moved out of current cycle
