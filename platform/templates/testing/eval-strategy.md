<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Eval Strategy — [[PROJECT_NAME]]

> Template for `docs/testing/eval-strategy.md` (required artifact of
> `management/eval-gated-testing`). The eval contract for this project. Fill
> every `[[…]]` token.

**Owner:** [[OWNER]] | **Last Updated:** [[DATE]] | **Runner:** [[EVAL_RUNNER]]

---

## What We Evaluate

The units under evaluation (skills, prompts, agents, end-to-end flows) and
why evals — not coverage — are the primary gate for them. [[EVAL_SCOPE]]

## Runner & CI Gate

The eval runner ([[EVAL_RUNNER]] — e.g. Microsoft Waza, GAIA, UK-AISI
Inspect, bespoke), how it is invoked, and where it gates (PR / merge /
scheduled). [[RUNNER_AND_CI]]

## Graders

Each grader, what it asserts, and why it is meaningful (not trivially
passable). [[GRADERS]]

| Grader | Asserts | Pass condition |
|--------|---------|----------------|
| [[GRADER_NAME]] | [[GRADER_ASSERTION]] | [[GRADER_PASS]] |

## Thresholds

The pass thresholds that gate merge (e.g. `task_completion ≥ 0.8`). Changes
here are quality commitments — they require a change-log entry, ADR, or PRD.
[[THRESHOLDS]]

## Task Taxonomy

Coverage across task classes. Every evaluated unit should have at least a
`basic-usage` and a `should-not-trigger` case.

| Class | Purpose | Present? |
|-------|---------|----------|
| `basic-usage` | Expected behavior on common input | [[BASIC_COVERAGE]] |
| `edge-case` | Boundary / partial / ambiguous input | [[EDGE_COVERAGE]] |
| `should-not-trigger` | Anti-trigger: must decline or stay silent | [[ANTI_COVERAGE]] |
| [[DOMAIN_OVERRIDE_CLASS]] | Domain safety gate that must fire | [[OVERRIDE_COVERAGE]] |

## Fixtures: Synthetic Only

How fixtures are kept synthetic — no real user data, PHI, credentials, or
production records under version control. State the redaction/synthesis
process. [[FIXTURE_POLICY]]

## Flake Policy

How non-determinism is handled so a green gate is reliable (pass-rate over N
runs, temperature pinning, retries). [[FLAKE_POLICY]]
