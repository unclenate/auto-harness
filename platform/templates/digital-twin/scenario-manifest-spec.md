---
# Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
# SPDX-License-Identifier: [[SPDX_LICENSE]]
---

# Scenario Manifest Spec — [[PROJECT_NAME]]

A scenario manifest makes a run reproducible. `validate-scenario-manifest.sh`
checks that a manifest YAML carries the required sections below.

## Enforced top-level sections (CI checked)

- `scenario:` — id, title, owner, purpose, maturity, status, created, updated
- `datasets:` — each with **id, source, version, asOf, confidence** (required), plus name, owner, license, transform, pathOrUri
- `assumptions:` — each with **confidence** and **sensitivity** (required), plus statement, rationale, source
- `outputs:` — each with audience, `publicationAllowed:`, `reviewRequired:`; if `publicationAllowed: true`, a `publication.approvalStatus` must be present
- `uncertainty:` — method, confidenceScale, sensitivityMethod, requiredDisclosure
- `provenance:` — **required**: gitCommit, runId, generatedAt, generatedBy, inputHash, outputHash

## Recommended top-level sections (process/human reviewed)

- `boundary:` — geography/system, included, excluded
- `baseline:` — worldStateVersion, source, asOf, limitations
- `models:` / `agents:` — id, name, owner, inputs, outputs, validation; agents declare `llmAllowed:`
- `review:` / `publication:` — reviewers, gates, status; audience, redaction, approvalStatus

## Minimal skeleton

```yaml
schemaVersion: 1
scenario: { id: [[ID]], title: [[TITLE]], owner: [[OWNER]], maturity: [[LEVEL]], status: draft }
baseline: { worldStateVersion: [[VER]], source: [[SRC]], asOf: YYYY-MM-DD }
datasets: [ { id: d1, source: [[SRC]], version: [[VER]], asOf: YYYY-MM-DD, confidence: medium } ]
assumptions: [ { id: a1, statement: [[TEXT]], confidence: low, sensitivity: high } ]
outputs: [ { id: o1, audience: internal, publicationAllowed: false, reviewRequired: true } ]
uncertainty: { method: [[METHOD]], confidenceScale: [[SCALE]], requiredDisclosure: true }
provenance: { gitCommit: [[SHA]], runId: [[RUN]], generatedAt: [[TS]], generatedBy: [[WHO]], inputHash: [[H]], outputHash: [[H]] }
```
