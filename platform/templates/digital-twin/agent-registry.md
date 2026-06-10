---
# Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
# SPDX-License-Identifier: [[SPDX_LICENSE]]
---

# Agent Registry — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required at maturity L3 (Digital twin prototype) and above. Document every agent
that participates in scenario execution or data collection for this twin.

## Agent entries

| Field | Value |
|---|---|
| id | [[AGENT_ID]] |
| name | [[AGENT_NAME]] |
| responsibility | [[WHAT_IT_DOES]] |
| mode | [[autonomous_or_human-in-loop_or_batch]] |
| inputs | [[INPUT_SIGNALS_OR_DATASETS]] |
| outputs | [[OUTPUT_SIGNALS_OR_ARTIFACTS]] |
| validation | [[VALIDATION_METHOD]] |
| llmAllowed | [[true_or_false]] |
| human-review triggers | [[TRIGGER_CONDITIONS]] |
| lastReviewed | YYYY-MM-DD |

> Declare `llmAllowed` explicitly for every agent. If `true`, document the LLM
> role, its known limitations, and the review gate before any output is acted on.
> Add one block per agent.
