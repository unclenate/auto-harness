<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Rollback Checklist — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Rollback authority: [[ROLLBACK_AUTHORITY]]
> Last updated: YYYY-MM-DD
> Last exercised: YYYY-MM-DD

A rollback checklist that has never been exercised is not a rollback plan. Test this
checklist before you need it.

---

## Pre-Conditions

Before starting a rollback, confirm:

- [ ] The decision to rollback has been authorized by [[ROLLBACK_AUTHORITY]]
- [ ] The issue triggering rollback has been identified or categorized
- [ ] The target rollback version has been identified: `[[ROLLBACK_TARGET_VERSION]]`
- [ ] Affected users or stakeholders have been notified (if applicable)

---

## Rollback Steps

### 1. Halt Forward Deployment

- [ ] Cancel any in-progress deployments
- [ ] Disable auto-deploy or merge queue if active

### 2. Revert Application

- [ ] Deploy previous known-good version: `[[ROLLBACK_DEPLOY_COMMAND]]`
- [ ] Verify deployment completed successfully
- [ ] Confirm health checks pass on all instances

### 3. Database Considerations

- [ ] Determine if the release included migrations
- [ ] If migrations are backward-compatible: no database rollback needed
- [ ] If migrations are NOT backward-compatible: execute rollback migration `[[MIGRATION_ROLLBACK_COMMAND]]`
- [ ] Verify data integrity after migration rollback

### 4. External Dependencies

- [ ] Verify third-party integrations still function with the rolled-back version
- [ ] Check webhook configurations are compatible
- [ ] Confirm API contract compatibility with consumers

### 5. Verification

- [ ] Application is responding on all endpoints
- [ ] Error rates have returned to baseline
- [ ] Key user flows are functional (manual or automated smoke test)
- [ ] Monitoring dashboards confirm recovery: [[MONITORING_URL]]

---

## Post-Rollback

- [ ] Record the incident in `docs/incidents/` using the incident template
- [ ] Update the risk register if a new risk was discovered
- [ ] Schedule a post-incident review within [[POST_INCIDENT_REVIEW_SLA]]
- [ ] Document what went wrong and the fix plan before re-attempting the release

---

## Rollback Contacts

| Role | Person | Contact |
|------|--------|---------|
| Rollback authority | [[ROLLBACK_AUTHORITY]] | [[ROLLBACK_CONTACT]] |
| On-call engineer | [[ONCALL_ENGINEER]] | [[ONCALL_CONTACT]] |
| Escalation | [[ESCALATION_CONTACT]] | [[ESCALATION_METHOD]] |

---

## Notes

- This checklist must be reviewed and updated with every release that changes the
  deployment topology, adds migrations, or alters external integrations.
- Exercise this checklist in staging at least once per quarter.
