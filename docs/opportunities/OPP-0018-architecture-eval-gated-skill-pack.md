<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0018 — Authored, Eval-Gated Agent Skill-Pack as a Delivery Topology

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-05-24
**Last Updated:** 2026-05-25 *(accepted; PRD-0008 drafted + module scaffolded; v0.5.2 batch)*
**Confidence:** high

---

## Thesis

The harness has no module for the shape where the **unit of product is an
authored agent skill pack** — a collection of conventioned skills
(`SKILL.md` + progressive-disclosure references + deterministic scripts)
authored to a spec, gated by evals, and deployed to an agent runtime
(OpenClaw / ClawHub / agentskills.io). This is a distinct delivery
topology, neither an application binary, a hosted service, an in-product
copilot, nor an MCP server.

Add a module — initial bias: **`architectures/agent-skill-pack`** plus a
thin **`domains/openclaw`** ecosystem overlay — that governs the
skill-pack production model: skill-scoping discipline (one skill, one
job), least-permission workspace-cache boundaries, the
reference-don't-embed personal-data rule, the SKILL.md spec contract, and
deploy-after-eval-gate. The eval-gate half pairs with OPP-0019 (the
testing posture) and OPP-0020 (eval tooling in the harness toolchain).

## Origin / Evidence

- **Consumer project: Tula (`github.com/unclenate/tula` fork).** Brownfield
  onboarding 2026-05-24; gap analysis at `docs/knowledge/harness-coverage-gap-analysis.md`
  §TG1. Six live skills (`skills/{health-records,med-pdf,epic-note,myhealth-pulse,memory-diff,request-amendment}/`),
  a mature authoring standard at `skills/AGENTS.md` (frontmatter spec,
  body-section order, reference-don't-embed personal data, token
  discipline, deploy-after-validation), and `scripts/deploy-skills.sh`
  deploying to `~/.openclaw/workspace/skills/`.
- **External signal — the pattern comes from the standard's own authors.**
  Tula's `skills/health-records` derives from
  [`jmandel/health-skillz`](https://github.com/jmandel/health-skillz) —
  Josh Mandel ([`jmandel`](https://github.com/jmandel)), co-creator of
  SMART on FHIR. The author of a foundational health-data standard is
  publishing **agent skills** as the delivery vehicle. This is not a
  one-off: authored skill packs are an emerging distribution shape across
  the agent ecosystem (ClawHub, agentskills.io, Claude Code / Cursor skill
  directories).
- **Eval tooling as part of the product contract.**
  [`microsoft/waza`](https://github.com/microsoft/waza) runs as a spec gate
  on Tula's skills in CI (`.waza.yaml`, `.github/workflows/eval-status.yml`);
  a skill that fails the gate does not ship. The eval suite is authored
  *alongside* the skill (`evals/<skill>/`), making "skill + its eval" the
  atomic shippable unit.
- **Why no existing module fits.** `agents/openclaw` governs the runtime
  *workspace files* (`TOOLS.md`, `SOUL.md`), not the *authoring/shipping*
  of a skill collection. `architectures/agentic-ui` and
  `domains/agentic-interfaces` govern in-product agent UIs. `architectures/mcp-server`
  governs an MCP server's exposed tool surface. OPP-0001 exports governance
  *to* a runtime; this OPP governs a payload authored *for* a runtime —
  the opposite direction.

## Why Now

- **The skill-pack distribution shape is consolidating across the
  ecosystem** (ClawHub, agentskills.io, Claude/Cursor skill dirs) at the
  same moment the harness's own recommended-skills lists assume it exists
  (every agent pack's `recommendedSkills` block points at ClawHub slugs)
  but the catalog has no governance for *producing* one.
- **Tula is the first consumer to exercise it**, and it exercises it
  maturely (a written authoring standard, a deploy script, an eval gate),
  so the module can be designed against a real, considered instance rather
  than a sketch.
- **Composes cleanly with OPP-0019/0020.** The skill-pack topology and the
  eval-gate posture are two halves of the same production model; designing
  them together avoids a later seam.

## Risks / Open Questions

- **Family placement is unresolved.** Is "authored eval-gated skill pack"
  an `architecture/` (it is a topology decision about where capability
  lives and how it is loaded), a `domain/` (it is tied to the
  OpenClaw/ClawHub/agentskills.io ecosystem), or a `delivery/` overlay (it
  is about how the artifact ships)? Initial bias: an `architectures/`
  module for the topology + a thin `domains/openclaw` overlay for
  ecosystem-specific conventions, so non-OpenClaw skill ecosystems (Claude
  Code skills, Cursor rules) can reuse the architecture without inheriting
  OpenClaw specifics. PRD must take a position.
- **Overlap with `agents/openclaw`.** That pack governs workspace files;
  this module governs authored skills. The boundary (a deployed skill
  becomes a workspace file at runtime) needs a clean statement so the two
  do not double-govern `~/.openclaw/workspace/skills/`.
- **Required-artifact restraint.** A first version should be near-zero
  required-artifact (like the stack modules), leaning on companion rules
  ("a new skill requires a matching eval") rather than mandating heavy
  authoring docs every consumer must write. Over-specifying here recreates
  the bundling debt OPP-0013 warns about.
- **Single evidence point.** One consumer (Tula). The jmandel/health-skillz
  lineage is a strong external signal, but a second independent skill-pack
  consumer (ideally non-health, e.g. a developer-tooling skill pack) should
  be sought before freezing the module shape.

## Disposition

**Accepted 2026-05-25.** Promoted to a v1 module in the v0.5.2 "agent-native
delivery" batch alongside OPP-0019 and OPP-0021. Rationale: the skill-pack
delivery topology is the load-bearing gap from the Tula onboarding (§TG1) and
is reinforced by the `jmandel/health-skillz` lineage; the module is
vendor-neutral and near-zero-required-artifact, so adoption cost is low. The
`domains/openclaw` half of the OPP's bias was **deferred** — `agents/openclaw`
already governs OpenClaw workspace files, so a second OpenClaw surface would
double-govern. See PRD-0008 for resolved design questions.

## Promotion

- See [`docs/requirements/PRD-0008-agent-skill-pack-architecture.md`](../requirements/PRD-0008-agent-skill-pack-architecture.md)
- Module: `platform/profiles/architectures/agent-skill-pack/`

## Related

- Gap analysis source: consumer project (`tula`) at
  `docs/knowledge/harness-coverage-gap-analysis.md` §TG1
- Pairs with: [OPP-0019](OPP-0019-eval-gated-testing-posture.md) (the eval
  gate as a testing posture), [OPP-0020](OPP-0020-evaluation-tooling-in-harness-toolchain.md)
  (eval tooling as a harness toolchain component)
- Adjacent (opposite direction): [OPP-0001](OPP-0001-exportable-governance-contract-for-runtime-harnesses.md)
  (exports governance *to* runtimes), [OPP-0002](OPP-0002-agentic-interface-awareness.md)
  (in-product agentic UIs)
- Existing partial coverage: `platform/agents/openclaw/module.yaml`
