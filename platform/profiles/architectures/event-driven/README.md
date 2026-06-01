<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Architecture Overlay: Event Driven

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay is for asynchronous systems — message queues, pub/sub, event streams, background
workers — where contract drift, replay behavior, and operational traceability require explicit
governance. It does not assume Kafka, SQS, RabbitMQ, or any specific broker.

---

## What This Overlay Governs

**Required artifact:** `docs/architecture/overview.md`
The architecture overview must describe the event topology: what events are emitted, what
consumes them, ordering guarantees, and what happens when a consumer fails.

**Optional artifact:** `docs/ops/runbook-index.md`
Event-driven systems have operational failure modes (poison messages, consumer lag, replay
requirements) that warrant runbooks. Recommended once the system reaches production.

**Sensitive paths:** `events/`, `src/events/`, `src/consumers/`, `src/publishers/`
Changes to event contracts or async handlers trigger a companion rule requiring an architecture
overview update or an ADR.

---

## Core Rules

> Event contracts are as binding as API contracts. A producer changing an event schema without
> notifying consumers is a breaking change even if no HTTP contract changed. Schema drift in
> event-driven systems is silent and hard to detect after the fact.

> Replay and ordering behavior must be explicit. If consumers assume at-most-once or
> at-least-once delivery, that assumption must be documented. Changing delivery semantics is
> an architectural decision requiring an ADR.

Review gate: *"Human review is required for changes that affect delivery guarantees or replay behavior."*

---

## How This Overlay Composes

| Pair with | When |
|-----------|------|
| `architectures/api-service` | Service exposes both HTTP and event interfaces |
| `data/relational-postgres` | Event processing writes to relational state |
| `data/object-storage` | Events trigger artifact generation stored in object storage |
| `domains/media-pipeline` | Events drive media processing workflows |

---

## Architecture Overview Expectations

The required `docs/architecture/overview.md` should answer:

- What events does this system produce? What are the schemas?
- What systems consume each event? Are consumers internal or external?
- What are the delivery semantics? (at-least-once, at-most-once, exactly-once)
- How does the system handle duplicate messages (idempotency)?
- What is the retry and dead-letter strategy?
- What does replay look like operationally?

---

## Agent Behavior

Agents may modify consumer logic, add new event types, and refactor publishers. Any change
that alters an event schema, changes delivery semantics, or modifies retry/dead-letter behavior
must be accompanied by an architecture overview update or an ADR and flagged for human review.

---

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
