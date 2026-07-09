<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0027 — Frontier-Agent Posture (Management Overlay; Cluster Anchor)

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-05-25
**Last Updated:** 2026-06-30 *(flipped `proposed` → `accepted`: the posture cluster is fully realized through its four satellites — all shipped + accepted as `architectures/*` modules with v2 artifact-content enforcement (OPP-0051). Per the OPP's own Open Question 1 (incremental adoption over a forced umbrella), the standalone `management/frontier-agent-posture` overlay was deliberately NOT built — the satellites compose without it and are adopted à la carte. See Disposition.)*
**Confidence:** medium-high

---

## Thesis

The Tula 2026-05-25 second-pass profiling revealed that the harness's
agent-related catalog covers *who the agent is* (`agents/claude-code`,
`agents/openclaw`, etc.) and *what the agent ships as* (`architectures/
agent-skill-pack` per OPP-0018) — but does **not** capture *what
enterprise-AI-platform infrastructure the agent is built to
participate in from day one*. Tula calls this "Frontier AI agent"
posture and explicitly contrasts it with "hobby chatbot wearing a
[domain] costume":

> "Most patient-facing AI projects start as a chatbot demo and then
> spend nine to eighteen months retrofitting evaluations, audit
> logging, identity, model governance, and HIPAA controls before a
> hospital will let them anywhere near a real patient. Tula inverts
> that order. The evaluation harness, the audit-friendly trace shape,
> the scope-contained skill model, the sender-allowlist transport
> gate, and the provider-agnostic routing layer are built in from
> skill #1."

That posture decomposes into a small set of mutually-reinforcing
patterns Tula adopts wholesale: enterprise AI Foundry targeting,
OpenTelemetry-shaped observability with multi-agent semantic
conventions, intelligent model routing across providers and
deployment contexts, and Microsoft's four defense-in-depth patterns
for autonomous AI agents. None of those are currently first-class
modules or required-artifact patterns in auto-harness's catalog.

Add **`management/frontier-agent-posture`** — a management overlay
that declares a project commits to enterprise-AI-platform standards
from skill #1 rather than retrofitting them later. The overlay
itself is lightweight (a few required artifacts naming the posture
commitments); the substantive machinery lives in the four satellite
modules this OPP anchors:

- [OPP-0028](OPP-0028-ai-foundry-target.md) — AI Foundry target
  awareness (`architectures/ai-foundry-target`)
- [OPP-0029](OPP-0029-agent-observability.md) — Agent observability +
  OTel multi-agent semantic conventions (`architectures/agent-observability`)
- [OPP-0030](OPP-0030-intelligent-model-routing.md) — Intelligent
  model routing (`architectures/intelligent-model-routing`)
- [OPP-0031](OPP-0031-agent-defense-in-depth.md) — Agent
  defense-in-depth (`architectures/agent-defense-in-depth`)

This is the second clear instance of the **anchor-satellite filing
pattern** named in `shared-observations.md` (OPP-0007 was the first):
one umbrella OPP captures the posture, four satellites carry the
substantive design pressure of each component, the OPP-0007 PRD
pattern of "v1 bundles tightly-coupled satellites, defers loosely-
coupled ones" applies cleanly here.

## Origin / Evidence

- **Consumer project: Tula** (`github.com/unclenate/tula`). Second-pass
  profiling of the [Tula README](https://github.com/unclenate/tula/blob/main/README.md)
  on 2026-05-25, after the catalog had digested the first-pass
  filings (OPP-0018..0022 + augmentations to OPP-0013/0016). The
  README's *"Tula Is a Frontier AI Agent"* section names the posture
  explicitly and decomposes it into the six capability rows now
  mapped to the satellite OPPs.
- **Microsoft Foundry agent patterns as the source of the design
  vocabulary.** Tula cites [Microsoft's May 2026 *Defense in depth
  for autonomous AI agents*](https://www.microsoft.com/en-us/security/blog/2026/05/14/defense-in-depth-autonomous-ai-agents/)
  blog, [Foundry agent evaluators](https://learn.microsoft.com/en-us/azure/foundry/concepts/evaluation-evaluators/agent-evaluators),
  [Foundry Observability GA](https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/generally-available-evaluations-monitoring-and-tracing-in-microsoft-foundry/4502760),
  and [multi-agent OpenTelemetry semantic conventions](https://learn.microsoft.com/en-us/azure/foundry/observability/concepts/trace-agent-concept).
  This is a published, externally-defined set of patterns — not
  Tula-specific framing — so the satellite OPPs target a stable
  reference set rather than a vendor-internal shape.
- **The pattern generalizes beyond healthcare.** Tula's domain is
  patient-agent infrastructure, but the four satellite OPPs (foundry
  targeting, observability, routing, defense-in-depth) are all
  domain-agnostic. Any consumer building an agent-native product for
  a regulated or enterprise environment hits the same posture
  pressure.
- **Auto-harness's first-pass Tula filings missed this entire
  cluster.** OPP-0018 (skill-pack architecture), OPP-0019
  (eval-gated testing), OPP-0021 (self-hosted-OSS delivery),
  OPP-0022 (patient-facing safety) cover the *product shape* and
  *healthcare-specific safety*. The *enterprise-AI-platform layer*
  is orthogonal — Tula is foundry-agnostic, OTel-shaped,
  multi-provider, and defense-in-depth-from-day-one independent of
  the patient-agent domain. The second-pass profiling caught the gap
  the first pass didn't see because the first pass wasn't looking for
  it (paired observation captured under "Brownfield catalog gaps
  surface in layers").
- **Existing catalog overlap is genuine but partial.** The four
  agent packs (claude-code, openclaw, generic-llm, etc.) cover *which
  agent runtime* the project uses. `management/eval-gated-testing`
  (OPP-0019) covers the eval-as-test posture. `domains/agentic-
  interfaces` (OPP-0002) covers user-facing copilot surfaces.
  `management/frontier-agent-posture` is none of those — it is the
  *project-level commitment* that the agent ships with
  enterprise-platform machinery from skill #1.

## Why Now

Three converging signals:

1. **Tula is the first consumer to surface this gap in the
   catalog.** Field evidence beats audit evidence (per the
   prioritization examination's bias). The Tula second-pass dropped
   in a single session; the gap is real and unambiguous.
2. **The reference vocabulary is recent and consolidating.** Microsoft
   Foundry's defense-in-depth blog is dated May 2026; the multi-agent
   OTel semantic conventions are GA; the Foundry agent evaluators
   pattern is published. The window where adopting these as catalog
   primitives carries low risk is now — the patterns are stable
   enough to name without locking the catalog into a moving target.
3. **The agent-native delivery cluster (OPP-0018..0021) just
   shipped at v0.5.2.** Adding the platform-layer cluster on top is
   the natural next move — the catalog is positioned to attract
   exactly the consumer class that needs this (frontier-agent-shaped
   products with regulatory pressure), and the missing surface area
   is the limiting factor.

## Risks / Open Questions

1. **Is `frontier-agent-posture` an overlay or a posture-shaped sub-
   category of `project-standard`?** Initial bias: overlay (sibling
   to `eval-gated-testing` and `knowledge-capture`), depending on
   `project-standard`. Avoids forcing the four satellite modules on
   projects that don't want all four; allows incremental adoption.
   PRD-pass should weigh.
2. **What does the umbrella overlay's `requiredArtifacts` look
   like?** Candidate set: a single `docs/architecture/frontier-
   agent-posture.md` artifact that explicitly declares which of the
   four satellite postures the project adopts and what evidence
   substantiates each. Lightweight; the heavy lifting lives in the
   satellite modules' required artifacts.
3. **Should the umbrella require all four satellites?** Bias: no.
   The umbrella declares the posture *commitment*; consumers compose
   the satellite modules they need. A project might adopt observability
   plus defense-in-depth but not (yet) foundry-targeting if no
   enterprise foundry is in scope.
4. **Are there candidate consumer projects beyond Tula that exercise
   this cluster?** Yes — any RealActivity-portfolio agent-native
   product (Aria, the commercial extension), any healthcare AI
   project targeting Microsoft Foundry, any agent-native research
   project subject to UK-AISI Inspect or AI-Act review. None
   currently onboarded to the harness; the pattern is forward-looking
   but specifically anticipated.
5. **Does this conflict with existing `management/eval-gated-testing`
   (OPP-0019)?** No. `eval-gated-testing` is the testing posture;
   `frontier-agent-posture` is the umbrella declaration that this
   posture (and others) are adopted as a coherent set from day one.
   They compose; they don't conflict.
6. **What about non-enterprise agent products?** Bias: don't force
   the posture on them. The overlay is opt-in by design — a
   prototype or experimental agent doesn't need it.
7. **How does this interact with the trust-tier model (OPP-0006)?**
   Frontier-agent posture is a *capability commitment*, not a
   *trust-tier promotion*. A project can adopt frontier-agent
   posture at any tier; the posture says what the agent *will do*,
   the trust tier says what it's *allowed to do*. PRD-pass should
   explicitly note this separation.

## Disposition

**Accepted 2026-06-30 — realized incrementally through the four satellites, not as a
standalone umbrella overlay.** The posture this OPP named ("the agent ships with
enterprise-platform machinery from skill #1") is now a built reality across the catalog:

- `architectures/agent-observability` (OPP-0029 / PRD-0014) — the OTel multi-agent trace contract.
- `architectures/ai-foundry-target` (OPP-0028 / PRD-0028) — the enterprise-foundry target declaration.
- `architectures/intelligent-model-routing` (OPP-0030 / PRD-0029) — the task→model routing table.
- `architectures/agent-defense-in-depth` (OPP-0031 / PRD-0030) — Microsoft's four defense-in-depth patterns.
- v2 artifact-content enforcement for all four (OPP-0051 / PRD-0031 + PRD-0032) — four `validate-*.sh` content validators.

**The `management/frontier-agent-posture` umbrella overlay was deliberately not built.**
Open Question 1 weighed an overlay-that-bundles-the-four against incremental adoption and
biased toward the latter ("avoids forcing the four satellite modules on projects that don't
want all four; allows incremental adoption") — and that is what shipped. The satellites
compose without a bundling parent; a consumer activates exactly the ones it commits to. An
umbrella overlay would add a forcing dependency with no capability the à-la-carte satellites
don't already provide, so it was dropped rather than built. If a future consumer surfaces a
genuine need to adopt all four as one unit, that is a fresh, narrowly-scoped OPP (an overlay
that `dependsOn` the four), not residual work on this one.

## Promotion

Realized through satellites, not a single PRD: [OPP-0028](OPP-0028-ai-foundry-target.md),
[OPP-0029](OPP-0029-agent-observability.md), [OPP-0030](OPP-0030-intelligent-model-routing.md),
[OPP-0031](OPP-0031-agent-defense-in-depth.md), and the v2-enforcement
[OPP-0051](OPP-0051-frontier-agent-cluster-v2-enforcement.md) — all `accepted`.
