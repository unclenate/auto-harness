<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Architecture Overlay: Web App

This overlay covers browser-facing systems — UI surfaces, request boundaries, and client/server
trust separation. It does not assume React, Next.js, or any specific hosting vendor. Framework
and hosting choices belong in stack or domain modules.

---

## What This Overlay Governs

**Required artifact:** `docs/architecture/overview.md`
The architecture overview must describe the system topology: where the browser boundary is,
what runs at the edge vs. origin, and how requests are authenticated before they reach
application logic.

**Sensitive paths:** `app/`, `src/ui/`, `src/components/`, `src/pages/`, `public/`
Changes to browser-facing code trigger a companion rule requiring an architecture overview
update or an ADR. This ensures that trust boundary shifts in the UI are recorded, not silent.

---

## Core Rule: Trust Belongs on the Server

The non-negotiable governance principle for web applications:

> Validation, authorization, and trust decisions must live on the server. Browser code is
> user-controlled and cannot be trusted. Any change that moves a trust decision into browser
> code requires human review.

This is enforced by the review gate:
*"Human review is required for changes that move validation or trust decisions into browser code."*

---

## How This Overlay Composes

| Pair with | When |
|-----------|------|
| `stacks/node-typescript` | Node.js/TypeScript web application |
| `stacks/python` | Python web application (Django, FastAPI + HTMX, etc.) |
| `domains/supabase` | Supabase as the backend for auth, data, and storage |
| `data/relational-postgres` | Postgres as the primary database |

**Does not conflict with any other module.** Multiple architecture overlays can coexist if the
system has both web-facing and API-facing surfaces — add both `web-app` and `api-service`.

---

## Architecture Overview Expectations

The required `docs/architecture/overview.md` should answer:

- What is the entry point for browser requests? (CDN edge, load balancer, server)
- What runs at the edge vs. origin?
- How is authentication handled before requests reach application code?
- Where does user input get validated?
- What does the trust boundary between browser and server look like?

Use the template at `platform/templates/architecture-overview.md`.

---

## Agent Behavior

Agents operating under this overlay must treat any change that moves trust logic toward the
browser as a human review trigger. Agents may propose UI changes, but changes that affect
authentication flow, session handling, or permission checks require explicit human sign-off
before applying.
