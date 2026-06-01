<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Domain Overlay: Media Pipeline

**Depends on:** `kernel/base`, `data/object-storage`.
**Conflicts with:** None.

This overlay activates governance for systems where media assets are ingested, transformed,
or derived — including computer vision (CV) pipelines, photogrammetry workflows, video/audio
processing, and any system where the output is a derived artifact computed from raw media input.

It extends `data/object-storage` with the assumption that media and derived artifacts live
in blob storage, and adds governance for operational replayability and traceability.

---

## When to Activate This Overlay

Use `domains/media-pipeline` when:

- The system ingests raw media (images, video, audio, point clouds, LiDAR) and produces
  derived outputs (thumbnails, transcripts, 3D models, labels, embeddings)
- Pipeline jobs are expensive to recompute and replayability is a product requirement
- Derived artifacts must be traceable back to their source inputs and processing parameters
- Workflows include stages that can fail mid-pipeline, leaving partial outputs

Do not activate this overlay for simple file upload and download. Object storage alone
(`data/object-storage`) is sufficient for those cases.

---

## What This Overlay Governs

The dependency on `data/object-storage` reflects that derived artifacts and source media
are assumed to live in object storage. The object storage module's governance on access
policy and naming conventions applies here.

**Sensitive paths:** `media/`, `pipelines/`, `transforms/`, `photogrammetry/`

Changes to these paths trigger a companion rule requiring one of:

- An update to `docs/architecture/overview.md`
- An update to `docs/ops/runbook-index.md`

This enforces the principle that pipeline topology and processing behavior are documented
before they run in production, not after incidents expose gaps.

---

## Derived Artifacts and Replayability

The core governance concern for media pipelines is: *if a derived artifact is wrong or
missing, can it be reproduced exactly?*

Document the following in `docs/architecture/overview.md` or a dedicated runbook:

- Input sources: where raw media originates (upload, external feed, crawler)
- Processing parameters: model version, resolution, quality settings, algorithm config
- Output contract: format, naming convention, storage path structure
- Replay procedure: how to reprocess a batch if the output is corrupted or outdated
- Idempotency: whether reprocessing a job produces identical output (required for auditable systems)

An agent may draft pipeline code and transformation logic. But a pipeline that cannot be
replayed is an ops liability. The review gate exists to catch deployments that lack runbook coverage.

---

## Runbook Index

The optional artifact `docs/ops/runbook-index.md` is the entry point for operational procedures.
For media pipelines, it should cover at minimum:

- How to trigger a reprocess job for a specific batch or date range
- How to identify and recover from partial pipeline failures
- Storage cost implications of reprocessing (object storage writes are not free)
- How to promote pipeline config changes through staging → production

There is no platform template for `runbook-index.md` — the structure varies too much by
system. Start with a simple list of runbooks and link each one.

---

## Review Gate

Human review is required when:

- Workflow changes affect expensive recomputation — a misconfigured pipeline can run for
  hours and generate significant storage and compute costs before the error is detected
- Media handling is irreversible — some transforms (e.g., lossy compression, deletion of
  source after processing) cannot be undone; these require explicit human sign-off
- Model or algorithm version changes affect output quality — downstream consumers of derived
  artifacts may depend on output stability

---

## Companion Rule Context

When `media/`, `pipelines/`, `transforms/`, or `photogrammetry/` paths change, the companion
rule requires an update to architecture or runbook docs. This is not bureaucracy — it is the
minimum traceability needed to answer "what changed and why did this batch produce different
output?" after a production incident.

---

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- Required dep: [`data/object-storage`](../../data/object-storage/README.md)
