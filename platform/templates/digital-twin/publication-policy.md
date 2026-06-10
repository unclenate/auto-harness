---
# Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
# SPDX-License-Identifier: [[SPDX_LICENSE]]
---

# Publication Policy — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required at maturity L4 (Operational twin) and above. Governs what may be
published, to whom, and under what review conditions. Maps to Gemini
Trust and Purpose.

## Audience tiers

| Tier | Description |
|---|---|
| public | Externally visible; highest review bar |
| restricted | Named stakeholders or regulated recipients |
| internal | Project team and governance only |
| confidential | Restricted by legal, safety, or security obligation |

## Review required before publication

The following output types always require human review before publication:

- Financial projections or economic-impact estimates
- Regulatory interpretations or compliance statements
- Operational recommendations affecting real-world systems
- Healthcare or safety outputs
- Sensitive infrastructure or geospatial data
- PII, behavioral, or civic-participation data
- LLM-generated public explanations of model outputs

## Approval fields (per output)

| Field | Value |
|---|---|
| outputId | [[OUTPUT_ID]] |
| audience | [[AUDIENCE_TIER]] |
| reviewedBy | [[REVIEWER_NAME]] |
| approvalStatus | [[approved_or_pending_or_blocked]] |
| approvalDate | YYYY-MM-DD |
| redactionNotes | [[REDACTION_NOTES_OR_NONE]] |
