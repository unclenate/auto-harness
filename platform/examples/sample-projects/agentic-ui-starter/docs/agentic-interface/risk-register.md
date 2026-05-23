<!--
NOTE: This is an auto-harness sample-project file (reference implementation).
If you copy this file into your own project, replace the SPDX/copyright
header below with your own — running
`bash platform/bootstrap/set-consumer-headers.sh` from your project root
after the copy will do this for you.
-->

<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Agentic Interface Risk Register — Lattice Copilot

<!-- Required by the `domains/agentic-interfaces` module. -->

**Owner:** @lattice-team
**Last reviewed:** 2026-05-17
**Review cadence:** with every prompt-tool-registry change, every model/runtime upgrade, monthly minimum.

---

## Open Risks

| ID | Risk | Likelihood | Impact | Mitigation | Owner | Status |
| -- | ---- | ---------- | ------ | ---------- | ----- | ------ |
| AI-001 | Prompt injection via vector-store retrieval over user-uploaded analytics docs. A document containing instructions could redirect the agent's behavior or attempt to call Tier-3 tools. | High | High | `<untrusted_source>` framing of all retrieval results; runtime tool allowlist (deny by default); structured `Confirm` UI for all Tier-3 tools. Payload-scanner not yet shipped — accepted residual risk for v1. | @lattice-team | Open |
| AI-002 | Hallucinated UI affordances — the agent could try to render a Confirm button for a tool not in the allowlist. | Med | Med | Render-time check inside every action component verifies the underlying tool is in the runtime allowlist; failure renders a disabled state with an error notice. | @lattice-team | Mitigated |
| AI-003 | Action-approval bypass — a Tier-3 tool could be invoked without the structured `Confirm` step. | Low | High | Confirmation enforced at the runtime layer via CopilotKit `handler` returning `confirm: true`; integration test `tests/copilot/confirm-required.test.ts` covers each Tier-3 tool. | @lattice-team | Mitigated |
| AI-004 | Generative-UI XSS — N/A in v1 (no Open-ended surface). | Low | Low | Closed catalog; markdown rendered with strict tag allowlist. | @lattice-team | Mitigated |
| AI-005 | Agent-controlled navigation to attacker-controlled URLs (in a shared share-email or in a generated report). | Med | Med | Link allowlist on share-email body — only known-safe origins for embedded links; warning UI for any unrecognized origin in agent output. | @lattice-team | Monitoring |
| AI-006 | Attribution drift — agent cites a vector-store result that does not say what the agent claims it says. | High | Med | Citations validated against retrieval results before render; "I don't know" is a first-class output. Manual review of golden-set runs catches drift before merge. | @lattice-team | Open |
| AI-007 | Model-update regression — Claude Sonnet 4.7 → 4.8 changes tool-call patterns and breaks the golden set. | High | Med | Canary rollout (5% / 25% / 100%); rollback path documented; golden-set run in CI on every model-version PR. | @lattice-team | Mitigated |
| AI-008 | System-prompt leakage via debug logging accidentally enabled in production. | Low | High | Server-side runtime; debug logs scrubbed before any client emission; production builds strip debug paths at build time. | @lattice-team | Mitigated |
| AI-009 | Persistent conversation as data exfil channel — accumulated retrieval results in a long thread could be summarized and exported. | Med | Med | Per-turn context scoping (tool results not carried unless needed); export tool requires structured confirmation showing the export scope. | @lattice-team | Monitoring |
| AI-010 | Tool-call rate as DoS / cost surface — agent loops on a tool. | Med | Med | Per-thread tool-call budget (20 calls/thread); circuit breaker on 3 repeated identical calls; cost alerting at the org level. | @lattice-team | Mitigated |
| AI-011 | Sycophancy / over-confirmation — agent confirms a destructive action because conversational context made it look helpful. | Med | Med | Destructive actions require the structured `Confirm` UI showing actual payload, not conversational paraphrase. | @lattice-team | Mitigated |
| AI-012 | CopilotKit major-version bump silently changes runtime behavior. | Med | Med | Version pinned in package.json; release-note review for every bump; canary rollout. | @lattice-team | Mitigated |

---

## Product-Specific Risks

| ID | Risk | Likelihood | Impact | Mitigation | Owner | Status |
| -- | ---- | ---------- | ------ | ---------- | ----- | ------ |
| AI-100 | Agent answers a question about analytics data the user does not have permission to see (RLS bypass via the agent's tool calls). | Low | High | All tool calls execute against the user's authenticated session — same RLS as the rest of the product; tested via `tests/copilot/rls-isolation.test.ts`. | @lattice-team | Mitigated |
| AI-101 | Share-email recipient is autofilled from agent inference of "the team" rather than an explicit user-provided list. | Med | Med | `send-share-email` requires explicit recipient input from the user via the structured Confirm UI; agent cannot pre-populate from any source other than user input. | @lattice-team | Mitigated |

---

## Closed Risks

(none yet)

---

## Reference

| Resource | Path |
| -------- | ---- |
| Module README | `platform/profiles/domains/agentic-interfaces/README.md` |
| Design doc | `docs/agentic-interface/design.md` |
| Trust model | `platform/core/kernel/base/trust-model.md` |
