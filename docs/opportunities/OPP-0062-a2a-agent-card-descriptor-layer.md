<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0062 — A2A Agent-Card descriptor layer + `tier_ceiling` extension for the agent-coordination bus

**Status:** proposed
**Owner:** @unclenate · **Created/Updated:** 2026-09-02
**Confidence:** high (the descriptor-layer alignment is sound and low-risk); medium (the exact extension
shape is a review choice, and the external-spec facts below are from a secondary-source research pass and
must be confirmed against the primaries before this advances)
**Parent:** PRD-0039 / OPP-0060 (`management/agent-coordination`)

## Thesis

PRD-0039 shipped the inter-agent bus with a bespoke 7-message control schema and **ad-hoc, prose per-agent
descriptors** — who each participant is, what it can do, how it is reached, what it is permitted. The
industry has since consolidated on **A2A** (an agent-interoperability standard now under the Linux
Foundation) for exactly that **descriptor layer**: A2A's *Agent Card* is a static JSON document of identity,
`skills[]`, `capabilities`, and `securitySchemes`. This OPP proposes aligning the bus's descriptor layer to
the A2A Agent Card **without changing the transport or the control schema**, for two structural reasons:

1. **A2A cannot be the transport here.** A2A binds to network transports (HTTP / JSON-RPC / gRPC) and — per
   the research pass below — has **no local/stdio/file binding**. The bus governs a *local, heterogeneous*
   fleet (stdio CLIs, an IDE agent with no headless server), which A2A cannot carry. The file inbox/outbox
   transport stays; A2A is adopted only for the *descriptor* layer.
2. **`tier_ceiling` has no standard equivalent.** A Layer-4 governance-gap analysis (Kang & Diponegoro,
   arXiv 2606.31498 — already held independently in [[project_protocol_layer_governance]]) finds that no
   agent protocol (A2A / MCP / the former ACP) expresses a permission ceiling or trust tier. So
   `tier_ceiling` is modelled as an Agent Card **extension**, not force-fit onto a standard field.

This makes the bus's descriptor layer *legible to the ecosystem* (an A2A-aware tool can read a participant's
identity/skills) while keeping the two things A2A does not provide — a local transport and a governance
ceiling — as declared, clearly-labelled non-standard additions.

## Design (descriptor layer only — no wire change)

- **Adopt the A2A Agent Card as the per-agent descriptor**: `name`, `description`, `provider`, `version`,
  `capabilities`, `securitySchemes`, and `skills[]`. This is the standardized form of what the parked
  local-CLI agent-pack gestured at informally.
- **Declare `tier_ceiling` as a named Agent Card extension** — e.g. `{ maxTier, capsNeverGrants: true }`.
  The runtime is unchanged: the effective tier a recipient may act at remains
  `min(dispatch.tier_ceiling, card.maxTier)`, and Tier 4/5 stays human-gated. `card.maxTier` is the agent's
  own policy ceiling — a cap, never a grant.
- **Declare the local file bus as a NON-standard transport interface** in the card (A2A has no field for a
  file transport). A future network participant can add a standard HTTP interface alongside it.
- **Annotate the 7 message types to the A2A task-state vocabulary** for legibility, with **no change to the
  bus wire format**: `dispatch`→submitted, `ack`→working, `progress`→a status update, `done`→completed (with
  an artifact), `block`→input-required / auth-required, `verdict`→a terminal state carrying a data part.
  `sync` (the out-of-band heartbeat/broadcast) has **no A2A equivalent** and stays bespoke.

## Trust & safety (preserved, not weakened)

`tier_ceiling` still **caps and never grants** (the card's `maxTier` is the agent's ceiling); Tier 4/5
remains human-gated regardless of any card or peer message; bus messages remain **untrusted data**, and an
Agent Card is a *descriptor*, not an instruction channel. If cards ever cross a trust boundary, A2A provides
signed Agent Cards (a JWS/JCS scheme, per the research pass) as an available hardening — not required for the
in-repo local fleet where the filesystem's own access control is the trust anchor.

## Provenance & independent-verification note

**Field-reported 2026-09-02** by a coordinator session in a live multi-agent consumer deployment, with a
secondary-source research pass behind the external-standard findings; **independently re-derived here** and
credited generically. The design (descriptor-alignment-without-transport-change; `tier_ceiling` as an
extension; `sync` stays bespoke) is corroborated by the harness's own protocol-landscape analysis. The
**external-spec claims** — that A2A absorbed the former ACP (2025-08-29) and archived AGNTCY, that A2A has no
local binding, and the exact Agent Card field set — are **carried as reported and MUST be confirmed against
the primary sources** (the a2a-protocol.org specification, the Linux Foundation merger announcement, and the
arXiv analysis) before this OPP advances to `accepted`. The **A2A v1.0 release date is deliberately not cited
normatively** — secondary sources conflict (March vs April 2026); pin it to the official changelog first.

## Open questions

1. **Scope of participation** — align all bus participants to Agent Cards now, or native + local-CLI
   adapters first?
2. **Extension shape** — an ad-hoc `x-tier-ceiling` field vs a formally registered A2A extension URI.
3. **Lifecycle-alignment depth** — annotate the message types to A2A task states (documentation only) vs a
   deeper structural alignment of the full task lifecycle.
4. **Primary-source confirmation** (see the provenance note) — resolve before ratification, especially the
   A2A v1.0 date and the no-local-binding claim.

## Neighbors

- **PRD-0039 / OPP-0060** (parent) — this refines the descriptor layer of the shipped bus; no transport or
  control-schema change.
- The parked local-CLI agent-pack — this OPP is its standards-aligned form.
- **OPP-0052** (verdict/observation ledger) — a `verdict` / `done` data part could feed the ledger.
- [[project_protocol_layer_governance]] — the A2A / MCP / governance-Layer-4 landscape this sits in;
  reframes agent-coordination as governance-*binding* onto A2A rather than reinventing it.

## Disposition

Design-only, `proposed`. Advancing to `accepted` requires the primary-source confirmations above and a
decision on the four open questions. Implementation (Agent Card schema + the `tier_ceiling` extension +
the descriptor validation) would be a subsequent PRD or a scoped OPP → implementation pass, reconciled
against the current bus schema and the `validate-agent-bus.sh` conformance linter (OPP-0061).
