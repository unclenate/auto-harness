---
# Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
# SPDX-License-Identifier: [[SPDX_LICENSE]]
---

# Run Log Spec — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required at maturity L4 (Operational twin) and above. The run log is append-only
JSONL. Each event line carries the minimum fields below.

## Minimum event fields

| Field | Description |
|---|---|
| schemaVersion | Log schema version (integer) |
| eventId | Unique event identifier (UUID) |
| timestamp | ISO 8601 UTC |
| scenarioId | Scenario identifier (matches manifest `scenario.id`) |
| runId | Run identifier (unique per execution) |
| actor | System, agent, or human that emitted the event |
| eventType | e.g. run.started / run.completed / dataset.loaded / output.generated |
| source | Component or service that produced the event |
| payload | Event-type-specific data (object) |
| inputRefs | Array of dataset/model/agent IDs consumed |
| outputRefs | Array of output artifact IDs produced |
| validationStatus | passed / warned / failed / skipped |
| correlationId | Trace ID for cross-event correlation |

## Storage and access

- **Path:** `[[RUN_LOG_PATH]]` (e.g. `logs/runs/`)
- **Format:** Append-only JSONL; one event per line; no in-place edits.
- **Retention:** [[RETENTION_POLICY]]

> **A simulation without a run log is not auditable.** Prototypes use
> append-only JSONL; operational twins may need event sourcing with replay.
