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

# Rollback Checklist

<!-- Use this checklist when a release must be reversed. -->
<!-- See platform/templates/release-checklist.md §3 for the release close step that triggers this. -->

**Release being rolled back:** [[RELEASE_VERSION]]
**Rollback owner:** @platform-team
**Rollback initiated:** YYYY-MM-DD HH:MM UTC
**Reason for rollback:** [[BRIEF_REASON]]

---

## 1. Before Rolling Back

- [ ] Rollback owner identified and has access to deploy pipeline
- [ ] Target version (the version being restored) confirmed: [[TARGET_VERSION]]
- [ ] Target version confirmed stable in version history
- [ ] Stakeholders notified that a rollback is in progress

---

## 2. Rollback Execution

- [ ] Rollback initiated via approved pipeline (not manual override)
- [ ] Rollback log captured
- [ ] Health checks green within expected timeframe after rollback

---

## 3. Post-Rollback Verification

- [ ] All validators pass against the restored version
- [ ] Published documentation reflects the rolled-back state
- [ ] No new errors introduced by the rollback itself
- [ ] Rollback owner confirms system is stable

---

## 4. Incident Record

- [ ] Incident opened in `docs/ops/incidents/` (or issue tracker) for the failed release
- [ ] Root cause of the rollback documented
- [ ] Follow-up action items assigned with owners
- [ ] Post-release review scheduled within 48 hours

**Rollback outcome:** [ ] Successful — system restored  [ ] Partial — further action needed

**Notes:**
