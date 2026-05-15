<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Data Overlay: Object Storage

This overlay is for systems that store blobs, media files, derived artifacts, or large binary
objects — S3, GCS, Azure Blob, Supabase Storage, R2. Object storage has distinct governance
concerns from structured data: retention, access control, lifecycle rules, and cost.

---

## What This Overlay Governs

**Optional artifacts:** `docs/architecture/overview.md`, `docs/ops/runbook-index.md`
The architecture overview should describe bucket layout, access patterns, and what data lives
where. Runbooks are recommended once the system reaches production with real user data.

**Sensitive paths:** `storage/`, `buckets/`, `lifecycle/`
Changes to bucket configuration or lifecycle rules trigger a companion rule requiring an
architecture overview or ops documentation update.

---

## Core Governance Concerns

**Retention and deletion:** Object storage makes it easy to accumulate data indefinitely.
Retention policies and lifecycle rules must be intentional and documented — not defaults.
Deleting the wrong object or bucket is irreversible.

**Access control:** Public vs. private buckets, pre-signed URL expiry, and IAM policies
all have security implications. Access control changes require human review.

**Cost:** Large object stores accumulate egress and storage costs silently. The architecture
overview should note expected data volumes and retention windows.

Review gate: *"Human review is required when retention or lifecycle policies change."*

---

## How This Overlay Composes

| Pair with | When |
|-----------|------|
| `domains/media-pipeline` | Object storage holds input media and derived artifacts |
| `architectures/api-service` | API handles upload and download signed URL generation |
| `architectures/event-driven` | Object creation events trigger downstream processing |
| `data/relational-postgres` | Metadata in Postgres, blobs in object storage |

---

## Agent Behavior

Agents may propose bucket layout changes, presigned URL logic, and upload/download handlers.
Changes to retention policies, lifecycle rules, bucket permissions, or public access settings
require human review and an architecture overview or ops documentation update in the same PR.
