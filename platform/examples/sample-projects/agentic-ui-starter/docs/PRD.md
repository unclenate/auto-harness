<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# PRD — Lattice (Agentic-UI Starter Sample)

**Problem.** Small-team analytics users spend most of their time menu-hunting and re-running
slightly-different versions of the same query. A natural-language copilot that can render
charts and trigger common product actions (export, share, schedule) inside the existing
Lattice web-app would compress that work into one conversation.

**In scope (MVP).**

- CopilotKit-flavored copilot sidebar embedded in the existing Lattice web-app
- Natural-language Q&A over the user's analytics data, with charts rendered in the chat thread
- Three Tier-3 actions invokable by the copilot with structured confirmation: `send-share-email`, `export-to-third-party-storage`, `schedule-recurring-report`
- Vector-store retrieval over user-uploaded analytics docs (PDF, MD)
- Per-thread conversation history persisted in Postgres
- Per-thread tool-call audit log

**Out of scope (explicit).**

- Voice input
- Mobile-native rendering (the copilot is web-only in v1)
- A2UI / cross-client rendering (revisit when there is a second client)
- Open-ended generative UI (no raw-HTML rendering surface in v1)
- Tier 4+ tools (no in-product configuration changes, no deploys triggered by the agent)
- Multi-agent orchestration (single agent loop, no sub-agents)

**Success metric.** A user who has never seen the copilot before completes one of the three
Tier-3 actions end-to-end in a single conversation, with the structured `Confirm` step being
the only friction.

**Open questions.** None at PRD time. Raise as ADRs if they emerge during implementation.
