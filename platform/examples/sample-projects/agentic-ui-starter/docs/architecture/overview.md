<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Architecture Overview — Lattice

Required by `architectures/web-app`. Augmented with an agentic-UI topology section because
`domains/agentic-interfaces` is also active.

## Web-App Topology (required by architectures/web-app)

| Question | Answer |
|----------|--------|
| Entry point for browser requests | Vercel edge → Next.js app router (Node runtime) |
| What runs at edge vs origin | Static assets at edge; all API routes and the CopilotKit runtime at origin (Node) |
| Authentication before requests reach app code | NextAuth session middleware on every API route; cookie-based session, server-validated |
| Where user input is validated | Server-side at the route boundary; Zod schemas; agent tool input also validated at the runtime layer |
| Trust boundary | Browser is untrusted. All validation, authorization, and trust decisions run server-side. The agent runtime, system prompt, and tool definitions are server-side only |

## Agentic-UI Topology (because domains/agentic-interfaces is active)

| Question | Answer |
|----------|--------|
| Where does the agent loop execute? | Server-side, in the Next.js route handler at `/api/copilot/runtime` |
| Trust boundary the agent crosses to call a tool | Same authentication as the user — every tool call runs against the user's authenticated session, with the user's RLS posture applied |
| Renderer contract | Controlled flavor; closed catalog of 11 React components in `src/copilot/components/`; CopilotKit `useCopilotAction` registrations form the runtime tool allowlist |
| Renderer threat model | Catalog drift and hallucinated affordances mitigated by runtime allowlist check at render time. No Open-ended surface in v1 |
| Audit posture | Every tool invocation logged to `tool_invocations` table; 90-day retention; thread + turn IDs preserved |
| Model/runtime upgrade posture | Canary 5% / 25% / 100%; rollback documented; golden-set of 30 interactions run in CI for every PR touching `src/copilot/` or `copilotkit.config.ts` |
| Conversation state ownership | Postgres `conversation_threads` and `conversation_turns`; client holds only the in-flight thread for display |

## Data Topology

- Postgres (primary): users, analytics data, `conversation_threads`, `conversation_turns`, `tool_invocations`
- Pinecone (secondary): vector store for retrieval over user-uploaded analytics docs

## Trust Summary

The non-negotiables for this product:

- Validation, authorization, and trust decisions live on the server (architectures/web-app rule)
- The agent runtime executes server-side; the browser never sees the system prompt or tool definitions (architectures/web-app + domains/agentic-interfaces, reinforced)
- Tier-3 tools require structured confirmation at the runtime layer (domains/agentic-interfaces rule)
- Renderer broadening (new component, new rendering mechanism) is a Tier-4 change with an ADR or design-doc update (domains/agentic-interfaces rule)
- Model and framework version pinned; upgrades go through a PR with the golden set run (domains/agentic-interfaces rule)

## See Also

- `docs/agentic-interface/design.md` — full agent-surface design
- `docs/agentic-interface/risk-register.md` — agentic-UI risk register
- `platform/profiles/architectures/web-app/README.md`
- `platform/profiles/domains/agentic-interfaces/README.md`
