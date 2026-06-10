---
# Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
# SPDX-License-Identifier: [[SPDX_LICENSE]]
maturity: [[MATURITY_LEVEL]]
conformance:
  - standard: [[STANDARD_ID]]
    status: [[published_or_emerging]]
governingPrinciples: [[GEMINI_PRINCIPLES_APPLIED]]
---

# Twin Profile — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required artifact for the `management/digital-twin` overlay. Declares this twin's
maturity, the interoperability/thread standards it conforms to (and at what
status), and the Gemini Principles governing its outputs.

## Maturity declaration

**Declared level:** [[MATURITY_LEVEL]]  *(digital-model | digital-shadow | digital-twin-prototype | operational-twin | control-loop)*

**Evidence for this level:** [[MATURITY_EVIDENCE]]

> **Bias guardrail.** Do not claim a level your evidence does not support. An
> operational twin requires live synchronization, run logs, and operational
> governance; a control-loop twin additionally requires safety controls and a
> second review.

## Standards conformance

| Standard | Targets | Status (published / emerging) |
|----------|---------|-------------------------------|
| [[STANDARD_ID]] | [[WHAT_IT_COVERS]] | [[published_or_emerging]] |

> Cite published standards as normative; cite emerging standards (e.g.
> ISO 23247-5 digital thread, ISO/IEC 30188) as emerging — never as ratified.

## Governing principles (Gemini)

State which principles govern this twin's publication and trust posture:
Purpose (public good, value creation, insight); Trust (security, openness,
quality); Function (federation, curation, evolution).

**Applied:** [[GEMINI_PRINCIPLES_APPLIED]]

## World / scenario / run state

Confirm the project separates **canonical world state** (best-known reality),
**scenario state** (a branch with changed assumptions), and **run state** (one
execution's trace). Do not mutate canonical world state to test a scenario —
branch it, run against the branch, and log the run.
