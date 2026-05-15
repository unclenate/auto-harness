<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Data Overlay: Document Store

This overlay is for document databases — MongoDB, Firestore, DynamoDB, Couchbase — where
schema flexibility is by design but schema drift still requires governance. The absence of
enforced schemas makes the discipline more important, not less.

---

## What This Overlay Governs

**Optional artifact:** `docs/architecture/overview.md`
The architecture overview should describe document shape expectations, indexing strategy,
and how the application handles documents that don't match the expected shape.

**Sensitive paths:** `schemas/`, `indexes/`, `mongodb/`
Changes to document schemas or index configuration trigger a companion rule requiring an
architecture overview update or an ADR.

---

## Core Rule: Flexibility Is Not the Same as Freedom

> Document stores allow schema changes without a migration file. This makes it easy for
> shape assumptions to drift silently between the application and stored data. Just because
> a schema change doesn't require a migration doesn't mean it's consequence-free.

> Every intentional change to document shape should be recorded. Unrecorded shape changes
> are how compatibility bugs appear in production weeks after a deployment.

Review gate: *"Human review is required when loose schema changes create compatibility risk."*

---

## Schema Governance Without Migrations

Without migration files to trigger governance, the companion rule applies to explicit schema
definition files (`schemas/`). Teams should maintain explicit schema definitions even when
the database doesn't enforce them — they serve as the authoritative record of expected shape
and generate the companion rule trigger.

If the project does not have a `schemas/` directory, architecture overview updates or ADRs
become the primary record of intentional shape changes.

---

## How This Overlay Composes

| Pair with | When |
|-----------|------|
| `architectures/api-service` | API backend with document storage |
| `architectures/event-driven` | Event-sourced or CQRS patterns with document read models |
| `domains/media-pipeline` | Metadata storage for derived media artifacts |

---

## Agent Behavior

Agents may propose document shape changes and index modifications. Any change that alters
the expected document shape — adds, removes, or renames fields that application code reads —
must be accompanied by an architecture overview update or an ADR and flagged for human review.
