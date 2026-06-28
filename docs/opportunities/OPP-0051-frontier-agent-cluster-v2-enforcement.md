<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0051 — Frontier-Agent Cluster v2 Enforcement: Artifact-Content Validators

**Status:** exploring
**Owner:** @unclenate
**Created:** 2026-06-28
**Last Updated:** 2026-06-28 *(promoted `proposed` → `exploring`: [PRD-0031](../requirements/PRD-0031-validate-trace-contract.md) drafted + accepted, ratifying the **first concrete deliverable** — the artifact-content half, anchored on `validate-trace-contract.sh` (module-gated/predict-clean, mirrors `validate-sast-coverage`; asserts the trace contract pins a semconv version + declares a conventional span + states its content-capture posture; presence + shape only). The code-cross-reference half + companion rule stay deferred. OPP-0051 flips `accepted` at that validator's implementation-merge; the foundry-target / model-routing / defense-in-depth content validators are follow-on phases reusing the shape-assertion skeleton.)*
**Confidence:** medium

---

## Thesis

The four frontier-agent-cluster satellites (anchor [OPP-0027](OPP-0027-frontier-agent-posture.md))
all shipped **declarative v1**: each requires its artifact to **exist**
(`validate-required-artifacts`) but never checks the artifact's **content**.

- `architectures/agent-observability` (PRD-0014) — `trace-contract.md` / `exporters.md`
- `architectures/ai-foundry-target` (PRD-0028) — `foundry-targets.md`
- `architectures/intelligent-model-routing` (PRD-0029) — `model-routing.md`
- `architectures/agent-defense-in-depth` (PRD-0030) — `agent-defense-in-depth.md`

Every one of those PRDs deferred "enforcement" to a v2 OPP, and every one's § 10 table
classified its central claim **Half-enforced** precisely because *content* (the truth and
shape of the declaration) is not yet checked. This OPP opens that v2 thread.

**The crucial scoping insight** (the reason v1 deferred, and what is buildable now):
there are *two* kinds of v2 enforcement, and only one is well-formed today.

1. **Artifact-content / shape conformance** — assert the declared artifact is *internally
   well-formed* (e.g. `trace-contract.md` pins an explicit OpenTelemetry semconv version,
   declares at least one span in the conventional `operation → span` shape, and flags
   content attributes as opt-in). This needs **no consumer code** and is **fixture-testable
   today**, exactly like `validate-sast-coverage.sh` validates the `sast-coverage.md`
   frontmatter. **This OPP proposes building this half.**
2. **Code-cross-reference** — assert the declaration *matches the running code* (the
   emitted spans match the contract; the permission model matches the action code). This
   needs a consumer's code and a **fixed code path** to anchor a companion rule's
   `triggerPaths` on — which a declarative architecture overlay does not have. **This half
   stays deferred** (the original v1 deferral reasoning holds for it).

So v2-via-this-OPP = the **artifact-content validator family**, module-gated and
predict-clean (the harness does not activate these modules, so each validator no-ops on
the harness's own CI — value accrues to consumers, the same posture as
`validate-sast-coverage` / `validate-privacy-by-design` / `validate-twin-profile`).

**Anchor first on the trace-contract validator.** Trace conformance is the strongest
cross-foundry anchor: `ai-foundry-target`'s top portable-evidence axis is OTel trace
conformance, `intelligent-model-routing`'s model-selection spans live in the trace
contract, and `agent-defense-in-depth`'s identity-binding is the runtime half of the same
spans. A `validate-trace-contract.sh` that asserts the contract's shape is the
highest-leverage single step and proves out a shape-assertion skeleton the other three
content validators reuse.

## Origin / Evidence

- **Every cluster PRD names this as the v2 follow-up.** PRD-0014, 0028, 0029, and 0030
  each state, in their Non-Goals, a deferred companion rule + content validator, and each
  § 10 table leaves the content claim Half-enforced. This OPP is the harvest of those four
  identical deferrals.
- **The shape-validator precedent is shipped and proven.** `validate-sast-coverage.sh`
  (PRD-0016) validates the `sast-coverage.md` artifact's frontmatter (tool from a
  recommended set, non-empty scan paths, severity threshold) — opt-in, predict-clean,
  `--scan-file` fixture mode. A trace-contract content validator is the same shape applied
  to a different artifact: assert the load-bearing invariants, fixture-test via
  `--scan-file`, no-op when the module is inactive.
- **The deferral was about well-formedness, not value** (see `shared-observations.md`,
  2026-06-27: "an OPP's proposed enforcement mechanism is a hypothesis the PRD ratifies
  against shipped precedent and well-formedness"). The content half clears the
  well-formedness bar today; the code-cross-reference half does not. This OPP draws that
  line explicitly rather than re-deferring everything.

## Why Now

- **The cluster just completed.** All four declarative contracts exist on `main` and are
  stable; the artifacts they govern have settled templates. Content validators can pin
  against a fixed target.
- **It closes the § 10 gap the cluster opened.** Each satellite advertises a
  Half-enforced central claim; the artifact-content validators convert the
  artifact-shape portion of each from "asserted" toward "enforced" without waiting on
  consumer code.
- **One skeleton, four payoffs.** Building the trace-contract validator establishes a
  reusable shape-assertion harness (parse the artifact, assert N invariants, 3-state exit,
  `--scan-file` fixture mode) that the foundry-target / model-routing / defense-in-depth
  validators slot into — amortized cost.

## Risks / Open Questions

1. **One validator for all four artifacts, or one per artifact?** Bias: **one per
   artifact** — each has a distinct shape (trace spans vs. foundry enum vs. routing table
   vs. four-pattern sections) — but factor a shared shape-assertion skeleton. Start with
   `validate-trace-contract.sh`; generalize the skeleton as the second lands.
2. **Module-gated or always-on?** Bias: **module-gated (predict-clean)** — these are
   opt-in capability overlays like sast-coverage / privacy / twin; an always-on content
   check would wrongly fire on every repo that never adopts the overlay.
3. **A companion rule too?** Bias: **no** in this OPP — the companion rule ("a code change
   introducing a new span shape must update `trace-contract.md`") is the *code-cross-reference*
   half and still needs a fixed consumer code path. It stays deferred; v2-this-OPP is the
   artifact-content validator only.
4. **One OPP for all four, or phase / separate OPPs?** Bias: **this OPP anchors the
   pattern and ships the trace-contract validator**; the foundry-target / model-routing /
   defense-in-depth content validators are follow-on phases (or their own OPPs) once the
   skeleton proves out — don't pre-commit four validators before the first proves the shape.
5. **Over-fitting risk.** A content validator could over-constrain a template consumers
   legitimately vary. Bias: assert **only the load-bearing invariants** (a version pin
   *exists*; at least one span declared in `operation → span` form; a content-attrs-opt-in
   note present) — presence and shape, never exhaustive correctness — mirroring
   `validate-module-stability`'s "presence + enum only, never the human judgment."
6. **Is this premature given no in-repo consumer?** Honest answer: the validators are
   predict-clean, so they cost the harness nothing and accrue value to consumers — the
   same bet `validate-sast-coverage` already makes. The line this OPP draws (ship the
   fixture-testable content half, defer the code-cross-reference half) is what keeps it
   from being speculative: it builds only what is well-formed without a consumer.

## Disposition

<!--
Empty while Status: proposed. Satellite of the OPP-0027 cluster; harvests the four
v2-enforcement deferrals from PRD-0014 / 0028 / 0029 / 0030.
-->

## Promotion

<!--
Empty until accepted. Anchor: OPP-0027. First concrete deliverable: validate-trace-contract.sh
(artifact-content / shape conformance, module-gated on architectures/agent-observability).
-->
