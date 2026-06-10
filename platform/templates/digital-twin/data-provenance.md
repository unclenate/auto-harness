---
# Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
# SPDX-License-Identifier: [[SPDX_LICENSE]]
---

# Data Provenance — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required at maturity L2 (Digital shadow) and above. Document every dataset used
by this twin so runs are reproducible.

## Dataset registry

| Field | Value |
|---|---|
| id | [[DATASET_ID]] |
| name | [[DATASET_NAME]] |
| source | [[SOURCE_URL_OR_SYSTEM]] |
| owner | [[DATASET_OWNER]] |
| license | [[LICENSE]] |
| version | [[VERSION]] |
| asOf | YYYY-MM-DD |
| freshness | [[FRESHNESS_CADENCE]] |
| transform | [[TRANSFORM_DESCRIPTION_OR_NONE]] |
| confidence | [[high_or_medium_or_low]] |
| pathOrUri | [[PATH_OR_URI]] |

> **An unversioned dataset is not reproducible.** Every dataset entry must
> carry a version and an asOf date. Add one row per dataset; duplicate the
> table block as needed.
