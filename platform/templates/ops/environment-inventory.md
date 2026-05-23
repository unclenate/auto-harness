<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Environment Inventory — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

This document records every environment in the system, what runs where, how credentials
are managed, and who has access. Without this, incident response starts with archaeology.

---

## Environments

### Local Development

| Property | Value |
|----------|-------|
| Purpose | Individual developer workflow |
| URL / Access | `localhost` |
| Data | Seeded / synthetic |
| Credentials | Local `.env` (not committed) |
| Who has access | Individual developer |

### Staging

| Property | Value |
|----------|-------|
| Purpose | Pre-production validation |
| URL / Access | [[STAGING_URL]] |
| Data | [[STAGING_DATA_DESCRIPTION]] |
| Credentials | [[STAGING_CREDENTIAL_METHOD]] |
| Who has access | [[STAGING_ACCESS_LIST]] |
| Deployed via | [[STAGING_DEPLOY_METHOD]] |

### Production

| Property | Value |
|----------|-------|
| Purpose | Live user-facing environment |
| URL / Access | [[PRODUCTION_URL]] |
| Data | Real user data |
| Credentials | [[PRODUCTION_CREDENTIAL_METHOD]] |
| Who has access | [[PRODUCTION_ACCESS_LIST]] |
| Deployed via | [[PRODUCTION_DEPLOY_METHOD]] |

---

## Credential Management

| Credential type | Storage method | Rotation schedule | Owner |
|----------------|---------------|-------------------|-------|
| Database | [[DB_CREDENTIAL_METHOD]] | [[DB_ROTATION]] | [[DB_CREDENTIAL_OWNER]] |
| API keys (third-party) | [[API_CREDENTIAL_METHOD]] | [[API_ROTATION]] | [[API_CREDENTIAL_OWNER]] |
| Deployment secrets | [[DEPLOY_CREDENTIAL_METHOD]] | [[DEPLOY_ROTATION]] | [[DEPLOY_CREDENTIAL_OWNER]] |

---

## Environment Parity

| Dimension | Local | Staging | Production |
|-----------|-------|---------|------------|
| Database engine | [[LOCAL_DB]] | [[STAGING_DB]] | [[PROD_DB]] |
| Runtime version | [[LOCAL_RUNTIME]] | [[STAGING_RUNTIME]] | [[PROD_RUNTIME]] |
| Feature flags | All enabled | Matches production | Production config |
| External services | Mocked / sandboxed | Sandbox accounts | Live accounts |

---

## Notes

- Add or remove environment rows as needed. Some projects have additional environments
  (QA, canary, preview per-PR).
- This file is a companion rule target — changes to deployment automation require this
  file to be updated in the same PR.
