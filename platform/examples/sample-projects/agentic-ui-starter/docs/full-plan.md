<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Full Plan — Lattice Copilot

**Decision-complete plan.** Scope, milestones, dependencies, and trade-offs in one file —
upgrade to `product-lite + project-standard` if the team grows past three contributors.

## Scope (= PRD MVP)

See `docs/PRD.md`. This plan does not redefine scope; it sequences it.

## Milestones

| # | Milestone | Exit criteria |
| - | --------- | ------------- |
| M1 | Runtime + readable state | CopilotKit runtime route handler shipped; `useCopilotReadable` exposes the user's currently-open chart. No tools yet. |
| M2 | Q&A over visible state | Agent can answer questions about the open chart. No tool invocation. |
| M3 | First Tier-3 tool with confirmation | `send-share-email` shipped with structured `Confirm` UI; HITL conformance test green. |
| M4 | Remaining Tier-3 tools | `export-to-third-party-storage`, `schedule-recurring-report` shipped with structured `Confirm`. |
| M5 | Retrieval + injection defense | Vector-store retrieval shipped with `<untrusted_source>` framing; risk register AI-001 reviewed before merge. |
| M6 | Golden set + canary | 30-interaction golden set in CI; model + framework canary rollout configured. |

## Dependencies

- Postgres for `conversation_threads`, `conversation_turns`, `tool_invocations`
- Pinecone for vector store (alternative: pgvector — defer decision until M5)
- CopilotKit v1.57.x pinned in package.json
- Claude Sonnet 4.7 primary; GPT-5 mini fallback (cost-sensitive paths only)

## Trade-offs

- **Vector store over user-uploaded docs is the highest-risk surface.** v1 ships without a payload-scanner. Tracked as AI-001 (Open) in the risk register. Mitigation relies on framing + tool allowlist + structured confirm. Add scanner in v2.
- **No A2UI in v1.** Choosing CopilotKit + Controlled flavor for tighter integration with existing React components. Re-evaluate when a second client (mobile, IDE plugin) is on the roadmap.
- **Single model loop.** No multi-agent orchestration. Keeps the trust model small; revisit if the action surface grows past ~15 tools.

## Out of Scope (mirrors PRD)

Authentication is reused from the existing Lattice app — not new work.
Multi-tenant isolation is reused from the existing Lattice RLS posture — see AI-100 in risk register.

## Open Questions

None at plan time.
