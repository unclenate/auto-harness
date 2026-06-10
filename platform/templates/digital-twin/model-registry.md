---
# Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
# SPDX-License-Identifier: [[SPDX_LICENSE]]
---

# Model Registry — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required at maturity L3 (Digital twin prototype) and above. Document every model
used by this twin. Declare its type and whether LLM assistance is permitted.

## Model entries

| Field | Value |
|---|---|
| id | [[MODEL_ID]] |
| name | [[MODEL_NAME]] |
| owner | [[MODEL_OWNER]] |
| responsibility | [[WHAT_IT_COMPUTES]] |
| inputs | [[INPUT_DATASETS_OR_SIGNALS]] |
| outputs | [[OUTPUT_SIGNALS_OR_ARTIFACTS]] |
| source-of-truth | [[REPO_PATH_OR_URI]] |
| type | [[deterministic_or_probabilistic_or_LLM-assisted]] |
| validation method | [[VALIDATION_METHOD]] |
| known limitations | [[LIMITATIONS]] |
| failure modes | [[FAILURE_MODES]] |
| human-review triggers | [[TRIGGER_CONDITIONS]] |
| lastReviewed | YYYY-MM-DD |

> **A model without a registry is not governable.** LLMs may assist; they are
> not source-of-truth for simulation outputs unless explicitly modeled,
> evaluated, and reviewed. Add one block per model.
