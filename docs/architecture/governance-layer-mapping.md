<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Governance-Layer Mapping: Auto-Harness Primitives → G1–G6 (OPP-0001 exploration)

**Purpose.** The exportable-governance-contract idea (OPP-0001, `exploring`) has a concrete, dated
framing: the interoperability protocols (A2A, MCP, IBM's Agent Communication Protocol) standardize the
*coordination mechanism* but, per Kang & Diponegoro ("Governance Gaps in Agent Interoperability
Protocols," arXiv 2606.31498, Jun 2026), **cannot express governance semantics** — voting, dissent,
human escalation, and designed audit are absent from every one. Governance is a missing **Layer 4**
above coordination. Auto-harness already *is* a Layer-4 implementation. This document maps the harness's
shipped primitives onto the paper's six-dimension taxonomy, so the mapping can seed a **candidate
governance extension** (most plausibly an A2A extension, per the paper) that is vendor-neutral by
construction — it sits above A2A (Google/LF lineage) and MCP (Anthropic lineage) alike.

**Acronym collision (mandatory disambiguation).** The paper's **"ACP" = IBM's Agent *Communication*
Protocol** (FIPA-ACL heritage; now folded into A2A). Auto-harness's **`agents/acp` = the Agent *Client*
Protocol** (editor↔agent, `request_permission`). Different protocols, same three letters. Any citation
of this paper alongside our ACP bridge must say so, or a reader concludes our bridge scored 2/12.

**Governing principle (the one caveat that shapes everything below).** The paper's model is *collective
peer decision-making* among agents; auto-harness is **principal-gated** — a human owner is the authority,
agents act within declared trust tiers. So we adopt G1–G6 as a **checklist of what the contract must be
able to express and record**, never as a mandate that agents *decide* by quorum. G3 (voting) in
particular does not transfer as a decision rule: we want its **recording** half (each reviewer's position
and rationale, tallied for a human) and never its **deciding** half. We cherry-pick primitives that serve
principal-gated governance; chasing 12/12 would be letting an external taxonomy drive the design.

## Verified scorecard (control-loop contract v1, PRD-0039; evidence on disk)

| Dim | Verdict | Primitive on disk (evidence) | Minimal additive delta |
|---|---|---|---|
| **G1 Membership** | Absent (contract) / Partial (harness) | Contract carries **addressing only**: `from`, `to` (`control-loop-contract.md:26-27`) — an endpoint for one exchange, no join/leave/roster. Harness-wide: active agent-packs in the manifest; OPP-0046 lane scope (`allowedFiles`) governs *what* not *who*. | A governed `participants` roster (or `join`/`leave`) the orchestrator validates `from`/`to` against. **Open: likely overlaps existing manifest + lane machinery — verify before minting a new primitive.** |
| **G2 Deliberation** | Partial | `verdict.decision ∈ {approve,reject,revise}` + `rationale`; `block.reason` (`control-loop-contract.md:48,50`) — stated reasons, but single-shot, no challenge round. | A threaded counter/challenge round reusing the correlation `id` before a terminal verdict. |
| **G3 Voting** | Absent (contract) / Partial-unshipped | No tally/quorum. Vehicle = OPP-0052's decorrelated-provider verdict tally + `validate-coordination-verdicts.sh` (proposed, unshipped). | A same-`id` verdict tally — **recording only**, tallied for a human, never binding (principal-gated). Adopt `sealed_until_all_cast` (blind verdicts) for decorrelation. |
| **G4 Dissent** | Absent | A `reject`/`revise` is a transient bus message; the `.acked`/`.sent` trail is **gitignored ephemeral** runtime (`adapter-contract.md:47-50`). | Persist each `reject`/`revise` + `rationale` as a committed artifact (OPP-0052 `verdict-<taskId>-<provider>.json`); reference it from the superseding decision. |
| **G5 Human escalation** | **Supported** (strongest) | `tier_ceiling` caps-never-grants; **Tier 4/5 human-gated regardless of any peer message** (`control-loop-contract.md:81-93`); `block` → human escalation never silently dropped (`:59-67`); kernel six-tier model (`AGENTS.md:106-107`); ACP seam enforcement (`tier-policy.yaml:107,109-116`). | None. |
| **G6 Audit/replay** | Partial | Correlation `id` + ISO-8601 `ts` for ordering/audit; `sync` redaction; `.acked`/`.sent` durable-move logs (`adapter-contract.md:38-48`) — but no hash chain, no signatures, ordering rests on wall-clock `ts`. | `prev_hash` (keyless SHA-256 chain) on the audit record — **this is OPP-0057 / PRD-0040**, designed there as the shared keystone. |

**Coverage:** ~5/12 for the contract alone, ~7/12 harness-wide — already above every protocol the paper scores (≤2/12), because the harness *is* the layer they describe. **G4 and G6 are the next contract revision's requirements** (both live at the ephemeral-vs-durable / trust-vs-verify boundary that makes review and post-hoc audit load-bearing — kernel doctrine's own concern).

**Substrate nuance (from the verification):** the contract's `from`/`to` (G1) and `id` (G3/G6) are
*addressing/correlation* primitives a reader could mistake for membership/tally support. They are neither
— but they are the substrate on which each minimal delta is small and **additive**, not structural.

## The exportable extension (OPP-0001 disposition)

The mapping above is the payload of a candidate governance layer: **control-loop message envelope +
trust-tier escalation model + (with OPP-0057's `prev_hash`) tamper-evident audit + (with OPP-0052)
dissent/tally recording**, expressed as an overlay any coordination protocol can carry. The paper puts a
clock on it — governance primitives will be standardized "particularly via A2A's extension mechanism"
within 6–12 months, and "no one has done so" yet. Recommended, cheap, expiring-option disposition:

1. Flip **OPP-0001 `proposed → exploring`** with a disposition note citing this paper (+ the ACP
   disambiguation).
2. First deliverable = **this mapping**, published as the governance-extension proposal seed.
3. Register interest with the A2A extensions process; watch, do not rush a half-formed standards proposal.

Temper the urgency: the window is the paper's estimate. The mapping doc is clarifying **regardless** of
whether standardization is pursued — it names exactly what the harness would contribute and what it
would keep proprietary (the trust-tier policy) vs. propose as neutral (the envelope + escalation +
audit shapes).
