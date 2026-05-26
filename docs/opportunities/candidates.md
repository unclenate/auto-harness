<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# auto-harness — Opportunity Candidates Index

**Owner:** @unclenate | **Last Updated:** 2026-05-24 *(added Tula cluster: OPP-0018..0022 + OPP-0013/0016 augmentation)*

Organizational index of opportunity candidates filed in this directory. The
canonical record for each candidate is its own `OPP-NNNN-slug.md` file —
this index exists only to group, cluster, or annotate them for human readers.

> **Scope of this file.** This file is *organizational*, not *structural*.
> Editing this file does **not** require an ADR — the companion-rule floor on
> `README.md` applies only to policy changes. Add, rename, or remove cluster
> headings freely as the candidate set evolves. The audit-trail floor on
> individual `OPP-NNNN-*.md` files still applies. See ADR-0012 for the
> structural-vs-organizational split rationale.

---

## Index of Current Candidates

### Exportable governance & ecosystem interop

- [OPP-0001](OPP-0001-exportable-governance-contract-for-runtime-harnesses.md) —
  Define an exportable governance contract any AI-agent runtime harness (Hive,
  LangGraph, CrewAI) can adopt to gate state transitions on human approval,
  with audit trails compatible with auto-harness's lifecycle artifacts.
- [OPP-0003](OPP-0003-mcp-producer-and-exportable-governance-via-mcp.md) —
  Teach auto-harness to govern three MCP modes (consumer, producer, and
  exportable-governance-via-MCP) as first-class shapes, making the governance
  contract from OPP-0001 reachable through the protocol layer.

### In-product agent surfaces

- [OPP-0002](OPP-0002-agentic-interface-awareness.md) — Teach the auto-harness
  to recognize agentic interfaces (CopilotKit-style copilots, A2UI generative
  UI, conversational-primary products) as a governable shape, so consumer
  projects ship modern AI surfaces without inventing their own
  prompt-injection / action-approval / agent-attribution governance.

### Knowledge distillation & self-improvement loop

- [OPP-0004](OPP-0004-distillation-triggers.md) *(accepted 2026-05-22;
  PRD-0004 v1 fully shipped — passive companion rule + workflow doc +
  Claude Code Stop-hook adapter)* — Close the cycle-end distillation
  gap: the harness provides destinations (observations, learnings,
  operating-principles) but no triggers to reliably cause distillation
  to happen during or after work cycles. v1 ships both the PR-boundary
  floor (companion rule) and the in-session reminder (hook adapter).
  Same-day proposed → exploring → accepted trajectory driven by
  maintainer priority signal.

- [OPP-0026](OPP-0026-distilled-learnings-disposition.md) *(accepted
  2026-05-25; PRD-0011 + ADR-0014 + 13 FRs shipped same-day; filed as
  OPP-0024 in working tree, renumbered after PR #59 took the OPP-0023
  slot)* — Decided the disposition of
  `distilled-learnings.md`:
  sunset, revive with a forcing trigger, or clarify as dormant.
  Investigation revealed the file has had zero content entries in 40
  days since the knowledge-capture module was added; the audit's M8
  finding flagged it as stale-cosmetic, but the gap is structural —
  `operating-principles.md` has *de facto* absorbed the curated-knowledge
  charter (§§ 7 and 8 added this session) while distilled-learnings has
  no forcing trigger to receive cross-observation synthesis. Initial
  bias toward sunset (consolidate curation in operating-principles), but
  PRD-pass should weigh the alternatives. Paired with a shared-observation
  framing the gap as the intra-repo sibling of OPP-0025's cross-repo
  silent-declaration pattern.

### Session-cycle orchestration & review-trigger taxonomy

This cluster captures a deeper concern surfaced by the OPP-0026
investigation: the harness has accumulated powerful automations
(companion rules, distillation triggers, Stop-event hooks, validator
chains, audit-trail rules) but **no defined "optimal session shape"
with review checkpoints that systematically fire them.** A session
might add ten shared-observations, ship a PRD, and merge — but never
run the curation review that distilled-learnings was designed to
receive, never check whether operating-principles needs a new section,
never audit the back-pressure between observation accumulation and
synthesis. The automations exist; the *cadence that consumes their
output* is underspecified. This is the trigger-side counterpart to the
audit-driven pattern the project has already named ("audits surface
what continuous discipline missed").

- **Candidate (not yet an OPP — awaiting second instance):**
  *Session-cycle orchestration / review-trigger taxonomy.* Frame the
  ideal session shape end-to-end — from session start (load skills,
  observe state) through work (companion rules, hooks, validators)
  through session close (cycle-end distillation, observation review,
  promotion-candidate scan, curation back-pressure check). Identify
  which automations are *already firing* at which checkpoints and
  which are *declared but unfired*. Produce a taxonomy of review
  triggers (PR-boundary, session-boundary, time-boundary,
  count-boundary, audit-boundary) and assign each declared review to
  exactly one trigger class. Likely outputs: an additions to
  `cycle-end-distillation.md` covering the full session arc (not just
  cycle end); a possible new workflow doc `session-shape.md`; possibly
  new companion rules for currently-unfired reviews; possibly
  retirement of declared reviews that have no defensible trigger
  (Option A of OPP-0026 is one instance of this). Promoted from
  candidate-stub to OPP when a second concrete instance of
  "declared review without a trigger" surfaces independently —
  same evidence-pattern that lifted brownfield-onboarding-as-discovery
  from observation to OPP cluster. **Origin:** maintainer framing
  during the OPP-0026 investigation, 2026-05-25:
  *"It may warrant further investigation because it seems that there's
  an as yet undefined optimal set of process steps for a session, and
  we are missing reviews that could be triggering these powerful
  automations we've designed."*

### Consumer onboarding & project hygiene

- [OPP-0006](OPP-0006-trust-tier-enforcement.md) *(exploring;
  PRD-0006 in flight, drafted 2026-05-23)* — Make the kernel-doctrine
  trust tier model machine-checkable. Six tiers are referenced
  everywhere (every agent pack, PR template, operating-principles)
  but zero machinery enforces them. The harness's most-cited safety
  guarantee runs on honor code. Initial bias: optional `tier` schema
  field on `module.yaml`, production-shape `sensitivePaths` inference,
  new `validate-trust-tier.sh` validator, and dogfood declarations on
  auto-harness's own modules. Closes the highest-priority gap from the
  2026-05-23 audit; named explicitly in the
  "doctrine-without-enforcement" architectural observation.

- [OPP-0005](OPP-0005-consumer-header-hygiene.md) *(accepted 2026-05-22;
  PRD-0005 v1 fully shipped — templates tokenized + bootstrap helper +
  sample-project markers + attribution drift fixed)* — Stop template
  SPDX/copyright headers from
  propagating to consumer files. 61 template files + every
  sample-project file currently ship with literal
  `Copyright 2026 Nate DiNiro <UncleNate@gmail.com>` headers, so
  consumers who scaffold their own ADR/PRD/observation from templates
  end up with files attributed to UncleNate under MIT/Apache regardless
  of their own license intent. Initial bias: tokenize template headers
  so the existing `validate-placeholders.sh` machinery gates new files,
  plus a small bootstrap helper that fills tokens project-wide. Real
  legal correctness issue, not cosmetic.

- [OPP-0023](OPP-0023-doc-references-consumer-scan.md) *(proposed 2026-05-25)* —
  `validate-doc-references.sh` hard-fails (exit 2) for **submodule consumers**:
  it requires a `<root>/platform/` tree and never reaches its general
  markdown-link-resolution pass on consumer docs. The consumer CI template
  includes a doc-references step while `ci-integration.md`'s minimal workflow
  omits it — they disagree, so following the template reds a consumer's CI.
  Surfaced by the Tula onboarding (recorded in its `ADR-0002`). Initial bias:
  make the validator scan consumer `*.md` when no `platform/` exists (skip the
  platform-specific pass), and align the template + guide.

- [OPP-0025](OPP-0025-consumer-integration-smoke-test.md) *(proposed
  2026-05-25; filed as OPP-0023 in working tree, renumbered after PR #59
  took the OPP-0023 slot for a separate Tula-surfaced finding)* — Add a
  consumer-side integration smoke test as a
  first-class harness primitive: a tiny CI workflow template + a recipe
  documented in `submodule-integration.md` § 6 (added in the same
  hotfix bundle as this OPP). Closes two silent-failure modes the
  harness's own CI cannot see by construction: (a) clones without
  `--recurse-submodules` leave `.harness/` empty with no error; (b) the
  pinned submodule SHA can become unreachable (force-push, branch
  deletion, auth-gated remote) and `git submodule update --init` fails
  with confusing errors. Complementary to PR #58's `-b main`
  improvement — explicit branch tracking clarifies intent; the smoke
  test provides the missing mechanical check. Framed in
  shared-observations as the cross-repo instance of the "declaration
  without enforcement" pattern; anchor for the M-j list-completeness
  validator candidate (intra-repo sibling).

### Brownfield catalog coverage

Catalog gaps surfaced by three independent external brownfield onboardings on
2026-05-24: YouBase (Node + CoffeeScript cryptographic identity store; OPP-0008,
0009, 0010), OpenEMR (25-year-old PHP healthcare EHR; OPP-0011..0017), and Tula
(OpenClaw personal-health-agent skill pack; OPP-0018..0022 + augmentation of
OPP-0013/0016). Each gap is a category the `harness-onboarding` skill correctly
refused to claim under the Conservative-module-selection rule because no catalog
module fits. Filed as coherent batches so the brownfield-discovery pattern is
visible as a class rather than scattered. YouBase and OpenEMR converged on
**stack/data catalog breadth** (different language angles within 24 hours); Tula
surfaced a distinct class — **delivery-topology breadth for agent-native
products** (the unit of product is an eval-gated skill pack on a runtime, not an
app or a service). Both signals are captured in shared-observations.md.

#### From YouBase (cryptographic-identity / personal-data-store)

- [OPP-0008](OPP-0008-stack-module-node-javascript-and-coffeescript.md) *(accepted 2026-05-25; v1 modules shipped)* —
  Add a stack module for plain Node-JavaScript (and a sibling for legacy
  CoffeeScript). Catalog currently has `stacks/node-typescript` and
  `stacks/python` only; a Node-not-TypeScript brownfield consumer leaves
  `stacks/*` empty even when the stack is unambiguous. Initial bias:
  sibling modules `stacks/node-javascript` + `stacks/coffeescript`, both
  zero-required-artifact like the existing pair. Closes the smallest of
  the three gaps.

- [OPP-0009](OPP-0009-data-module-embedded-key-value.md) *(accepted 2026-05-25; v1 modules shipped)* —
  Add a data module for embedded key-value stores (LevelDB / LMDB / RocksDB
  / SQLite-as-KV) plus a sibling `data/browser-storage` for IndexedDB /
  localStorage / OPFS. Catalog currently has relational-postgres, document-
  store, and object-storage only; YouBase's full LevelDB stack (five deps,
  four of them already npm-deprecated and migrating upstream to
  `abstract-level`) has nowhere to land. Initial bias: split server-embedded
  from browser-embedded; zero required artifacts in v1.

- [OPP-0010](OPP-0010-domain-module-cryptographic-identity.md) *(accepted 2026-05-25; v1 module shipped)* —
  Add a domain module for cryptographic identity (BIP39 mnemonics, BIP32 HD
  derivation, secp256k1 ECDSA, DID/SSI primitives), orthogonal to
  `domains/web3` (which is Ethereum-specific). Five governance concerns
  enumerated (encryption-mode invariants, crypto-library audit cadence,
  mnemonic backup policy, purpose-code registration discipline,
  signature-scheme migration). Initial bias: ship narrow as
  `domains/cryptographic-identity`; defer the broader "personal data store"
  product framing to a future OPP if multiple PDS consumers exercise the
  catalog.

#### From OpenEMR (PHP healthcare EHR)

*Originally drafted as OPP-0008..0014; renumbered to OPP-0011..0017 to avoid
collision with the YouBase batch, which was filed earlier the same day. Cross-
references back to OPP-0008/0009/0010 record the convergence.*

- [OPP-0011](OPP-0011-stack-module-php.md) *(proposed 2026-05-24)* — PHP stack
  support: `stacks/php` module + `harness-php` skill +
  `validate-php-strict-types.sh` + `validate-conventional-commits.sh`.
  Closes the gap that forced OpenEMR's manifest to omit stacks entirely;
  convergent with OPP-0008 (Node-JS-without-TS) from the YouBase
  onboarding.
- [OPP-0012](OPP-0012-data-module-relational-sql-engine-generalization.md) *(proposed 2026-05-24)*
  — Generalize `data/relational-postgres` → `data/relational-sql` with
  `engine: postgres | mysql | mariadb | sqlite` sub-field. 95% of
  required artifacts are engine-independent; the rename keeps the
  catalog compact and unblocks MySQL/MariaDB/SQLite consumers.
- [OPP-0013](OPP-0013-domain-family-healthcare-decomposed.md) *(proposed 2026-05-24)*
  — Decomposed `domains/healthcare-*` family (12 sub-modules) +
  `templates/healthcare/` (8 templates) + `harness-healthcare` skill +
  `healthcare-full-ehr.yaml` convenience composition. Healthcare is
  the largest plausible regulated-domain expansion; per-concern
  granularity avoids forcing consumers into bundled artifact debt.
- [OPP-0014](OPP-0014-polyglot-companion-services.md) *(proposed 2026-05-24)* —
  `domains/polyglot-services` module for companion-service pattern
  (one language per service surface). Triggered by ccdaservice
  Node.js companion in OpenEMR; recurs widely (Rails+Node,
  Django+Lua, Go+Python).
- [OPP-0015](OPP-0015-regulated-compliance-test-kits.md) *(proposed 2026-05-24)*
  — `domains/regulated-compliance` module + compliance templates +
  `regulated-saas.yaml` composition. External compliance test-kit
  pattern (Inferno ONC G10, PCI scanners, SOC2 evidence harnesses);
  generalizes beyond healthcare.
- [OPP-0016](OPP-0016-specialist-healthcare-review-skills.md) *(proposed 2026-05-24)*
  — Specialist healthcare review skill family: `harness-fhir`,
  `harness-hl7v2`, `harness-onc-certification`, `harness-phi-audit`,
  `harness-encryption-review`, `harness-rbac-review`. Refinement
  layer on top of the broad `harness-healthcare` skill from
  OPP-0013; incremental ship.
- [OPP-0017](OPP-0017-legacy-coexistence-template-family.md) *(proposed 2026-05-24)*
  — Legacy-coexistence template family + PHI tripwire validator.
  Templates for upgrade-vault history, dual-data-layer migration,
  template-engine migration, OAuth2/SMART scopes, ACL/RBAC, sub-app
  portal auth. Pattern absorbed from a 25-year-old project's lived
  coexistence experience.

#### From Tula (OpenClaw personal-health-agent skill pack)

*Distinct gap class from the YouBase/OpenEMR stack-breadth batch:
**delivery-topology breadth for agent-native products**. The catalog's
conventional layers (node-typescript, web-app, product-lite, dev-agent
packs) described Tula fine; the miss is concentrated in how an agent-native
product is built, gated, and shipped — plus the patient-side of healthcare,
which OpenEMR's operator-side family did not see.*

- [OPP-0018](OPP-0018-architecture-eval-gated-skill-pack.md) *(accepted 2026-05-25; PRD-0008; v0.5.2)* —
  Authored, eval-gated **agent skill-pack** as a delivery topology
  (`architectures/agent-skill-pack` + thin `domains/openclaw`). The unit of
  product is a conventioned skill collection deployed to an agent runtime —
  neither an app, a service, an in-product copilot, nor an MCP server.
  Lineage: `jmandel/health-skillz` (SMART co-creator publishing agent skills).
- [OPP-0019](OPP-0019-eval-gated-testing-posture.md) *(accepted 2026-05-25; PRD-0009; v0.5.2)* —
  **Binary-eval quality gate** as a testing posture (consumer-facing).
  `testing-standard` is percentage-coverage shaped; this adds grader
  thresholds, an eval task taxonomy (basic/edge/should-not-trigger/override),
  and synthetic-fixture discipline. Bias: a `mode: eval-gate` variant.
- [OPP-0020](OPP-0020-evaluation-tooling-in-harness-toolchain.md) *(proposed 2026-05-24)* —
  **Evaluation & safety tooling as harness toolchain components** (Waza /
  GAIA / UK-AISI Inspect). Inbound complement to OPP-0001: auto-harness adds
  a *behavioral* gate alongside its structural validators. Maintainer-signaled
  direction (Waza as component, not just awareness).
- [OPP-0021](OPP-0021-delivery-self-hosted-oss.md) *(accepted 2026-05-25; PRD-0010; v0.5.2)* —
  **`delivery/self-hosted-oss`** posture for published OSS that ships as a
  single-user self-hosted reference deployment — between `prototype` (undersells)
  and `production-saas` (oversells with hosted-ops artifacts).
- [OPP-0022](OPP-0022-patient-facing-health-agent-safety.md) *(proposed 2026-05-24)* —
  **Patient-facing health-agent safety** (triage gating, draft-never-send,
  non-diagnostic stance, PHI workspace boundary, indirect-injection-via-ingestion).
  Patient-side counterpart to OPP-0013's operator-side family. Carries the
  **US-healthcare-bias guardrail**: both healthcare evidence points are American;
  international second-evidence (EHDS, Near/Far East) required before freezing.
- *Augmentation (not new OPPs):* [OPP-0013](OPP-0013-domain-family-healthcare-decomposed.md)
  and [OPP-0016](OPP-0016-specialist-healthcare-review-skills.md) gain Tula as a
  role-distinct second healthcare consumer (patient-authorized SMART client vs
  OpenEMR's server/provider-launch), plus the US-bias guardrail.

#### From Tula second-pass — enterprise-AI-platform layering (2026-05-25)

Second-pass profiling of the Tula README against a different framing
question ("what enterprise-AI-platform infrastructure does this commit
to?") surfaced a cluster of gaps the first pass missed. Filed as an
anchor + four satellites following the OPP-0007 anchor-satellite
pattern; three existing OPPs gained substantive augmentations. The
paired observation *"Brownfield catalog gaps surface in layers — the
first profile pass catches product-shape gaps; a second pass catches
platform-layer gaps"* in `shared-observations.md` (2026-05-25)
generalizes the two-pass discipline.

- **[OPP-0027](OPP-0027-frontier-agent-posture.md)** *(proposed
  2026-05-25; anchor)* — `management/frontier-agent-posture` overlay
  declaring a project commits to enterprise-AI-platform standards
  from skill #1: foundry-targeting, OTel-shaped observability,
  intelligent model routing, defense-in-depth-for-autonomous-agents.
  Lightweight umbrella; substantive machinery lives in the four
  satellites below. Second instance of the anchor-satellite filing
  pattern after OPP-0007.
- **[OPP-0028](OPP-0028-ai-foundry-target.md)** *(proposed 2026-05-25;
  satellite of OPP-0027)* — `architectures/ai-foundry-target` —
  enumerated `foundries:` field naming which enterprise AI foundries
  (Microsoft / Azure AI Foundry, NVIDIA AI Foundry, Palantir Foundry /
  AIP, AWS Bedrock Agents, Google Vertex Agents, IBM watsonx
  Orchestrate) the project commits to landing in. New
  `architectures/`-family deployment-target dimension distinct from
  `delivery/` and `agents/`.
- **[OPP-0029](OPP-0029-agent-observability.md)** *(proposed
  2026-05-25; satellite of OPP-0027)* — `architectures/agent-observability`
  — OpenTelemetry-shaped multi-agent semantic conventions (Microsoft +
  Cisco Outshift). Required artifacts: `docs/observability/trace-contract.md`,
  plus `docs/observability/exporters.md`. Companion rule: action-code
  changes require trace-contract updates if a new span shape is
  introduced. Composes with OPP-0028 (foundries consume the shape)
  and OPP-0030 (model-selection spans).
- **[OPP-0030](OPP-0030-intelligent-model-routing.md)** *(proposed
  2026-05-25; satellite of OPP-0027)* — `architectures/intelligent-model-routing`
  — deployment-context-aware multi-provider routing as a first-class
  architectural primitive. Required artifact: `docs/architecture/model-routing.md`
  with the routing table, decision criteria, providers, and
  foundry-routing seams. Healthcare-specific routing (MedGemma 4B/27B,
  MedASR, MedImageInsight, CXRReportGen) named in the suggested-providers
  list but not required.
- **[OPP-0031](OPP-0031-agent-defense-in-depth.md)** *(proposed
  2026-05-25; satellite of OPP-0027)* — `architectures/agent-defense-in-depth`
  — Microsoft's four mutually-reinforcing patterns: agents-as-microservices,
  least-permissions, deterministic human-in-the-loop, agent-identity.
  Required artifacts: `docs/security/agent-defense-in-depth.md` +
  `docs/security/append-only-action-log.md`. Generalizes OPP-0022's
  healthcare-specific safety to the umbrella four-pattern model.
- *Augmentations (not new OPPs):*
  [OPP-0015](OPP-0015-regulated-compliance-test-kits.md) gains
  *(B1)* BAA-tier LLM gateway governance and *(B2)* EU AI Act
  compliance test-kit integration (Microsoft Purview, Credo AI, Saidot)
  as two named sub-shapes of the external-test-kit pattern.
  [OPP-0019](OPP-0019-eval-gated-testing-posture.md) gains the
  *three-stage eval lifecycle* dimension (dev → CI → production-traffic);
  v1's CI-stage coverage is the floor, with production-traffic stage
  a v2 OPP candidate. [OPP-0021](OPP-0021-delivery-self-hosted-oss.md)
  gains an optional `OPEN_CORE.md` template for self-hosted-OSS
  projects with a proprietary commercial extension (Tula/Aria split
  as the reference instance).

### Canonical direction & strategic alignment

- [OPP-0007](OPP-0007-canonical-position-artifact.md) *(exploring;
  PRD-0007 in flight, drafted 2026-05-24; renumbered from OPP-0006
  after the trust-tier-enforcement OPP took that slot)* —
  Introduce a canonical-position artifact as a first-class harness
  primitive. Every other strategy / product / GTM / partnership artifact
  cites it and cannot contradict it. Anchors four sibling observations
  filed in the same session (validator opt-out staleness;
  opportunity-capture backlog re-audit on canonical change; formal
  review/reconciliation artifact type; intake-vs-canonical-direction
  staleness). Identified as the highest-leverage single gap in the
  harness's artifact catalog by the four-lens project alignment audit
  (MB-REV-003) of `bdits/municipal-brain`.

---

## References

- Policy: `README.md` (this directory)
- Per-candidate template: `platform/templates/opportunity/opp-template.md`
- Module definition: `platform/profiles/management/opportunity-capture/module.yaml`
- Split rationale: `docs/adr/ADR-0012-opportunity-capture-index-split.md`
