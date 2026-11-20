<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0062 — A2A Agent-Card descriptor layer + `tier_ceiling` extension for the agent-coordination bus

**Status:** deferred
**Owner:** @unclenate · **Created:** 2026-09-02 · **Updated:** 2026-11-19
**Confidence:** high (the descriptor-layer alignment is sound and low-risk); medium (the exact extension
shape is a review choice, and the external-spec facts below are from a secondary-source research pass and
must be confirmed against the primaries before this advances). **Deferred 2026-11-19:** a review found the 2026-09-30 confirmation below partly wrong and the premise not on disk; see the Disposition and the hold review at the end of this record
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
extension; `sync` stays bespoke) is corroborated by the harness's own protocol-landscape analysis. The **external-spec claims were confirmed against primary sources 2026-09-30** (the
[a2a-protocol.org](https://a2a-protocol.org/latest/specification/) `latest` specification + the Linux
Foundation A2A launch announcement):

- **A2A is network-transport only** — JSON-RPC (spec §9), gRPC (§10), HTTP+JSON/REST (§11), with **no
  local / stdio / file binding**. ✅ Confirms the file inbox/outbox transport stays (A2A cannot carry the
  local heterogeneous fleet).
- **Agent Card fields** — `name`, `description`, `url`, `provider`, `version`, `capabilities`, `skills`,
  `securitySchemes`, `security`, and **`extensions`**. ✅ The `extensions` field directly supports modelling
  `tier_ceiling` as a named Agent Card extension (open question 2).
- **Signed Agent Cards** exist — spec §8.4 "Agent Card Signing" (JWS). ✅
- **A2A v1.0.0 is the current released version** (spec header: "Latest Released Version 1.0.0"). ✅ This
  resolves the earlier March-vs-April-2026 date ambiguity — v1.0.0 is *released*, so cite the version, not a
  contested date.
- **REFUTED:** A2A did **not** "archive AGNTCY." AGNTCY is a *separate, active* Linux Foundation project
  (Directory / Identity / SLIM Messaging / Observability) that is *integrating* A2A support — a complementary
  interoperability layer above A2A, not something A2A absorbed. The earlier note was a secondary-source error;
  corrected here.
- **ACP → A2A consolidation** (IBM's Agent Communication Protocol, 2025-08-29, under LF AI & Data) is strongly
  corroborated across consistent secondary sources; it is the "former ACP" this design targets — distinct from
  the Agent *Client* Protocol naming collision (see [[project_protocol_layer_governance]]).

**Design impact: none.** Every confirmation upholds the design (file-bus-stays, `tier_ceiling`-as-extension,
`sync`-stays-bespoke), and the confirmed `extensions` field strengthens the extension approach; the AGNTCY
line was a provenance correction only. This closes the primary-source precondition for advancing to
`accepted` (that disposition remains the maintainer's call).

## Open questions

1. **Scope of participation** — align all bus participants to Agent Cards now, or native + local-CLI
   adapters first?
2. **Extension shape** — an ad-hoc `x-tier-ceiling` field vs a formally registered A2A extension URI.
3. **Lifecycle-alignment depth** — annotate the message types to A2A task states (documentation only) vs a
   deeper structural alignment of the full task lifecycle.
4. **Primary-source confirmation** — ✅ **RESOLVED 2026-09-30** (see the provenance note): A2A v1.0.0 is
   released, the no-local-binding claim is confirmed against the spec, the Agent Card `extensions` field is
   confirmed, and the AGNTCY claim was corrected. Open questions 1–3 remain design choices for the acceptance
   / PRD pass.

## Neighbors

- **PRD-0039 / OPP-0060** (parent) — this refines the descriptor layer of the shipped bus; no transport or
  control-schema change.
- The parked local-CLI agent-pack — this OPP is its standards-aligned form.
- **OPP-0052** (verdict/observation ledger) — a `verdict` / `done` data part could feed the ledger.
- [[project_protocol_layer_governance]] — the A2A / MCP / governance-Layer-4 landscape this sits in;
  reframes agent-coordination as governance-*binding* onto A2A rather than reinventing it.

## Disposition

**Deferred by the maintainer, 2026-11-19**, on the hold review at the end of this record. As filed: design-only; advancing to `accepted` requires the primary-source confirmations above and a
decision on the four open questions. Implementation (Agent Card schema + the `tier_ceiling` extension +
the descriptor validation) would be a subsequent PRD or a scoped OPP → implementation pass, reconciled
against the current bus schema and the `validate-agent-bus.sh` conformance linter (OPP-0061).

## Hold review (2026-11-19)

A review before the acceptance decision checked this record against the repo and against A2A's primary sources (the `a2aproject/A2A` repository, read 2026-11-19). The body above is left as filed; these findings are against it.

- **There are no bus descriptors to align.** The thesis says PRD-0039 shipped ad-hoc prose per-agent descriptors. The two coordination contracts and the module contain none. What exists is an adapter `capabilities` operation and a tier argument on the reference runner. An Agent Card would be a new artifact, not an alignment.
- **The field list is the older card shape.** In the current schema there is no top-level `url` (it is per entry in `supportedInterfaces`), `security` is `securityRequirements`, and `extensions` is a field of `capabilities`, not of the card. `supportedInterfaces` is required, so a card for a local agent with no A2A endpoint is either invalid or declares a binding the bus does not implement.
- **An ad-hoc extension field is not a spec mechanism.** Extensions are entries with a URI and parameters and may not add fields to core structures, which rules out one of the two shapes in open question 2.
- **"No field for a file transport" is wrong as worded.** The binding identifier is an open string and the spec defines custom bindings, though a custom binding must implement the core operations. Two upstream proposals for a stdio binding are open, so the local-transport question is unsettled.
- **The released version is 1.0.1**, not 1.0.0.
- **The citation for "no protocol expresses a tier ceiling" does not support it.** The cited paper's text does not contain the words tier or ceiling. The point itself appears to hold on a reading of the card schema, which has no such field.
- **A card ceiling would duplicate an existing one.** Each agent's ceiling already lives in its `module.yaml` (`maxTier`, ADR-0020); the record does not say how the two would be reconciled.
- **No consumer reads cards**, and this repo does not activate agent-coordination.

Revisit when a stdio binding is accepted upstream or a consumer needs to publish cards. The record should be corrected against the then-current spec before it is reconsidered.
