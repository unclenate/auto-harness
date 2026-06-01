<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Domain Overlay: Supabase

**Depends on:** `kernel/base`, `data/relational-postgres`.
**Conflicts with:** None.

This overlay activates Supabase-specific governance when Supabase is the hosted backend layer —
providing auth, database, storage, and edge functions as a managed service. It extends
`data/relational-postgres` with the assumptions that come with a hosted Supabase project: a
managed Postgres instance, built-in auth primitives, and a hosted API surface.

---

## What This Overlay Governs

**Sensitive paths:** `supabase/`, `src/auth/`, `src/middleware/`, and any file containing
`session`, `jwt`, or `token` in its path.

Changes to these paths trigger a companion rule requiring one of:

- An update to `docs/security/risk-register.md`
- A new or updated ADR
- An update to `docs/architecture/overview.md`

This enforces the principle that auth, policy, and hosted-boundary changes are tracked decisions,
not silent implementation details.

The dependency on `data/relational-postgres` means this overlay inherits all migration
discipline and schema governance from that module. Supabase provides the hosting layer;
the database governance rules still apply.

---

## Row-Level Security (RLS)

RLS is the primary access control mechanism in Supabase. Key governance expectations:

- RLS must be enabled on all tables that hold user or multi-tenant data.
- Policy changes are auth changes — they trigger the companion rule.
- An agent may draft RLS policy SQL, but human review is required before applying it.
  Misconfigured RLS is a data exposure event, not a schema mistake.
- RLS changes to production environments are Tier 4 actions. The `apply` command must be
  human-directed.

Common pattern to document in `docs/security/risk-register.md`:

- Which tables have RLS enabled
- Policy approach (user-scoped, org-scoped, public read, etc.)
- Any tables explicitly excluded from RLS and why

---

## Auth Boundaries

Supabase Auth handles user identity, session management, and JWT issuance. Governance expectations:

- Auth provider configuration (`supabase/config.toml`, OAuth provider setup) is a sensitive
  path change. Document provider decisions in an ADR.
- JWT secrets and service role keys must not appear in source files. These are Tier 5 operations
  (production credential access) requiring human management.
- Middleware that validates JWTs (`src/middleware/`) is subject to the companion rule.
  Changes here touch every protected route.
- Magic link and OAuth redirect URLs must match deployed origins. Mismatched redirects are
  a common auth failure mode at environment promotion time.

---

## Migrations

This overlay inherits full migration discipline from `data/relational-postgres`:

- Migrations live in `supabase/migrations/` — tracked in version control.
- Agents may write migration files but must not apply them to any shared or production environment.
  `supabase db push` against production is a Tier 4 action.
- Use `supabase db diff` to generate migrations from schema changes; review the output before
  committing.
- The `supabase/seed.sql` file, if present, is a data mutation. Treat it as a migration artifact.

---

## Hosted Service Integration

The Supabase project URL and anon key are public-facing but scope-limited. The service role key
is not. Document the boundary clearly in `docs/architecture/overview.md`:

- Which client surfaces use the anon key
- Which server surfaces use the service role key
- How environment variables are managed per deployment tier
- Whether Supabase Edge Functions are used and what they own

---

## Recommended Skills

Install `supabase-postgres-best-practices` in your AI tool before writing RLS policies,
migration files, or auth configuration. This skill provides current Supabase API patterns,
RLS policy syntax, and common gotchas that training data may not reflect accurately.

See `platform/workflow/skills-and-agents.md` for installation guidance.

---

## Review Gate

Human review is required for:

- Any auth provider configuration change
- Any RLS policy addition, modification, or removal
- Any change to JWT validation logic in middleware
- Any service role key usage pattern change

These are not stylistic decisions — they determine who can access what data.

---

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- Required dep: [`data/relational-postgres`](../../data/relational-postgres/README.md)
- ADR: [`ADR-0003 — Submodule Integration`](../../../../docs/adr/ADR-0003-submodule-integration.md)
