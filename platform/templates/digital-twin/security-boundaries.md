---
# Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
# SPDX-License-Identifier: [[SPDX_LICENSE]]
---

# Security Boundaries — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required at maturity L5 (Closed-loop / control twin); recommended at L4.
Maps to the Gemini Security principle.

## Public / private boundary

| Surface | Classification | Access control |
|---|---|---|
| [[SURFACE_NAME]] | [[public_or_private_or_restricted]] | [[ACCESS_CONTROL_MECHANISM]] |

## Sensitive infrastructure and geospatial handling

- **Sensitive infrastructure data:** [[WHAT_IS_SENSITIVE_AND_WHY]]
- **Geospatial data classification:** [[CLASSIFICATION_LEVEL]]
- **Handling requirements:** [[HANDLING_REQUIREMENTS]]

## Access control

- **Authentication:** [[AUTH_MECHANISM]]
- **Authorization model:** [[AUTHZ_MODEL]]
- **Privileged access:** [[PRIVILEGED_ACCESS_POLICY]]

## Data egress

- **Permitted egress destinations:** [[DESTINATIONS]]
- **Egress approval process:** [[APPROVAL_PROCESS]]
- **Audit logging:** [[AUDIT_LOG_LOCATION]]

## Secrets

- **Secrets management:** [[SECRETS_MANAGER_OR_METHOD]]
- **Rotation policy:** [[ROTATION_POLICY]]
- **Exposure response:** [[INCIDENT_RESPONSE_LINK_OR_SUMMARY]]
