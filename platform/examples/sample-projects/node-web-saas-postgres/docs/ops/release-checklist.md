<!--
NOTE: This is an auto-harness sample-project file (reference implementation).
If you copy this file into your own project, replace the SPDX/copyright
header below with your own — running
`bash platform/bootstrap/set-consumer-headers.sh` from your project root
after the copy will do this for you.
-->

<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Release Checklist

<!-- Complete this checklist before every release of the harness platform. -->
<!-- See platform/templates/release-checklist.md for the canonical template. -->

**Release version:** [[RELEASE_VERSION]]
**Release owner:** @platform-team
**Second approver:** [[SECOND_APPROVER]]
**Release window:** YYYY-MM-DD

---

## 1. Readiness

### Governance

- [ ] All seven validators pass against this project's manifest and sample project
- [ ] Companion validation passes for this release's PRs
- [ ] No High/High risks open in `docs/security/risk-register.md` without mitigation

### Quality

- [ ] Unit tests pass: `ruby -I platform/validators/lib platform/validators/test/test_harness_registry.rb`
- [ ] Integration tests pass: `ruby -I platform/validators/lib platform/validators/test/test_validators_integration.rb`
- [ ] No markdown lint warnings in new documentation (check IDE diagnostics)
- [ ] No unfilled `[[PLACEHOLDER]]` tokens in platform templates (run `validate-placeholders.sh`)

### Documentation

- [ ] `docs/project/change-log.md` updated with changes in this release
- [ ] `docs/project/milestones.md` reflects current milestone status
- [ ] New modules or skills have substantive README / SKILL.md (not stubs)
- [ ] SUMMARY.md updated to reflect any new files added

### Operations

- [ ] Release owner and rollback authority identified and briefed
- [ ] `docs/project/dependency-log.md` is current; no dependencies flagged At Risk or Deprecated

### Human approvals

- [ ] Second approver has reviewed and signed off on Readiness section

---

## 2. Deployment

- [ ] Release tag created in version control (`git tag v[[RELEASE_VERSION]]`)
- [ ] GitBook documentation synced and published
- [ ] Any distribution package published (if applicable)
- [ ] Team notified via agreed communication channel

---

## 3. Verification

- [ ] Published documentation accessible and renders correctly
- [ ] Validators confirmed runnable from a clean clone (no hidden dependencies)
- [ ] No incidents or error reports from release channel

**Release outcome:** [ ] Successful  [ ] Successful with issues  [ ] Rolled back

**Notes:**
