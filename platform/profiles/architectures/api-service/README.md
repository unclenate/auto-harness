<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Architecture Overlay: API Service

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay governs service-boundary documentation and request-handling surfaces for
API-first systems — backends consumed by other services, mobile clients, or third parties.
It does not assume REST, GraphQL, or any specific framework.

---

## What This Overlay Governs

**Required artifact:** `docs/architecture/overview.md`
The architecture overview must describe the service boundary: what the API exposes, who the
consumers are, how authentication works, and where rate limiting or validation happens.

**Sensitive paths:** `api/`, `src/api/`, `src/handlers/`, `src/services/`, `cmd/`
Changes to API handlers or service code trigger a companion rule requiring an architecture
overview update or an ADR. External-facing contract changes must be recorded.

---

## Core Rule: Contracts Are Explicit

> API contracts — endpoints, request shapes, response shapes, error codes — are external
> commitments. Changes to them must be recorded as decisions, not treated as internal
> refactors. A consumer breaking change without an ADR is a governance failure.

Review gate: *"Human review is required for externally visible API contract changes."*

---

## How This Overlay Composes

| Pair with | When |
|-----------|------|
| `stacks/node-typescript` | Node.js API (Express, Fastify, Hono, etc.) |
| `stacks/python` | Python API (FastAPI, Flask, Django REST) |
| `data/relational-sql` | Postgres as the primary data store |
| `data/document-store` | Document store for flexible schemas |
| `architectures/event-driven` | Service emits or consumes events in addition to HTTP |

**Can coexist with `web-app`** if the same codebase serves both a UI and an API surface.

---

## Architecture Overview Expectations

The required `docs/architecture/overview.md` should answer:

- What does this service expose? (endpoints, event streams, RPC)
- Who are the consumers? (internal services, mobile clients, third parties)
- How is authentication enforced at the boundary?
- What does the service own vs. delegate to another service?
- What are the SLA or reliability expectations for external consumers?

Use the template at `platform/templates/architecture-overview.md`.

---

## Agent Behavior

Agents may propose new endpoints, refactor handlers, and modify service logic. Any change that
alters the external API contract — adds, removes, or changes endpoint behavior — must be
flagged for human review and accompanied by an ADR or architecture overview update.

---

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- Related module: [`architectures/web-app`](../web-app/README.md)
