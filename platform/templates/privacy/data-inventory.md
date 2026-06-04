<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Data Inventory — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Companion artifact for `management/privacy-by-design`. Enumerate every category
of personal or sensitive data the project collects, processes, or stores. Keep
one row per category. Delete this instruction block when the inventory is filled.

## Personal Data Categories

| Category | Source | Purpose | Storage | Retention | Destruction | Lawful basis |
| -------- | ------ | ------- | ------- | --------- | ----------- | ------------ |
| [[DATA_CATEGORY]] | [[SOURCE]] | [[PURPOSE]] | [[STORAGE_LOCATION]] | [[RETENTION_PERIOD]] | [[DESTRUCTION_METHOD]] | [[LAWFUL_BASIS]] |

### Column Definitions

- **Category** — Human-readable label for the data type (e.g., "Email address",
  "IP address", "Health record", "Payment card number").
- **Source** — Where the data originates (e.g., "User registration form",
  "Third-party analytics SDK", "Server access log").
- **Purpose** — Why the data is collected (e.g., "Account authentication",
  "Usage analytics", "Fraud detection").
- **Storage** — Where the data lives at rest (e.g., "Postgres users table",
  "S3 bucket `logs-raw`", "Redis session cache").
- **Retention** — How long the data is kept (e.g., "Until account deletion",
  "90 days", "7 years for tax records").
- **Destruction** — How data is destroyed after retention expires (e.g.,
  "Automated deletion job", "Encrypted-key destruction", "Secure wipe").
- **Lawful basis** — Legal justification for processing (GDPR Art. 6 / CCPA
  equivalent): Consent / Contract / Legal obligation / Vital interests /
  Public task / Legitimate interests / N/A (non-GDPR regime — note applicable
  basis).

## Cross-Reference

- Privacy profile: `docs/privacy/privacy-profile.md` (declared regime)
- Privacy impact assessment: `docs/privacy/privacy-impact-assessment.md`
