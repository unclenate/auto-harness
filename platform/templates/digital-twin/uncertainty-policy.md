---
# Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
# SPDX-License-Identifier: [[SPDX_LICENSE]]
---

# Uncertainty Policy — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required at maturity L3 (Digital twin prototype) and above. Every output must
disclose uncertainty before it is shared or published.

## Required disclosures

- **High-sensitivity assumptions:** [[LIST_HIGH_SENSITIVITY_ASSUMPTIONS]]
- **Low-confidence inputs:** [[LIST_LOW_CONFIDENCE_INPUTS]]
- **Known model limitations:** [[LIST_MODEL_LIMITATIONS]]
- **Excluded variables:** [[LIST_EXCLUDED_VARIABLES]]
- **Confidence scale:** [[SCALE_DEFINITION]] (e.g. high/medium/low with criteria)
- **Likely ranges:** [[RANGE_METHOD]] — prefer "likely range X–Y; primary sensitivity Z; confidence medium" over single-point predictions
- **When human review is required:** [[REVIEW_TRIGGERS]]
- **When an output cannot be published:** [[PUBLICATION_BLOCK_CONDITIONS]]

> Prefer ranges with named sensitivities over point estimates. Fake precision
> is a governed anti-pattern for this overlay.
