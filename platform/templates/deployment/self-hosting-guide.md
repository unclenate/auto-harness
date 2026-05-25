<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Self-Hosting Guide — [[PROJECT_NAME]]

> Template for `docs/deployment/self-hosting-guide.md` (required artifact of
> `delivery/self-hosted-oss`). This is the operator's contract — the person
> running this software on their own infrastructure. Fill every `[[…]]` token.

**Owner:** [[OWNER]] | **Last Updated:** [[DATE]] | **Applies to version:** [[VERSION]]

---

## Who Operates This

State plainly that the **user is the operator**: there is no hosted service;
the person who deploys this is responsible for its operation. [[OPERATOR_MODEL]]

## Minimum Viable Deployment

The smallest real deployment: host requirements, runtime/dependencies,
install steps, and a first-run check. [[MVD]]

## Data Locations the Operator Owns

Every place this software writes data the operator is responsible for
(persistence, caches, secrets, backups) and what lives where. [[DATA_LOCATIONS]]

## Security Posture the Operator Inherits

What the project secures **by default** and what the operator **must secure
themselves** (network exposure, credentials, transport, allowlists). Be
honest about residual risk; cross-link `docs/security/risk-register.md` if
present. [[SECURITY_POSTURE]]

## Upgrade & Versioning

How the operator moves between versions safely, and where breaking changes
are announced. [[UPGRADE_PROCESS]]

## Backup & Recovery

What the operator must back up and how to restore. [[BACKUP_RECOVERY]]

## Costs

The operating costs the self-hoster bears (compute, storage, any external
API usage). [[COSTS]]
