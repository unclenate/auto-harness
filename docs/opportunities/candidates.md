<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# auto-harness — Opportunity Candidates Index

**Owner:** @unclenate | **Last Updated:** 2026-07-15 *(status reconciliation: 10 entries whose annotation had drifted from their record's canonical `Status` — OPP-0012 / 0025 / 0027 / 0028 / 0029 / 0030 / 0031 / 0032 / 0051 / 0053 — realigned to `accepted`. Prior: 2026-06-10 added Digital Twin / Scenario Runtime cluster: OPP-0044)*

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

This cluster captures a deeper concern: the harness has accumulated
powerful enforcement machinery (companion rules, distillation
triggers, Stop-event hooks, validator chains, audit-trail rules) but
**no defined "optimal session shape" with review checkpoints that
systematically fire them.** A session might add ten shared-observations,
ship a PRD, and merge — but never run the curation review that
operating-principles benefits from, never check whether second-pass
brownfield framing would surface new gaps, never audit the
back-pressure between observation accumulation and synthesis. The
automations exist; the *cadence that consumes their output* is
underspecified.

- [OPP-0032](OPP-0032-session-cycle-orchestration.md) *(accepted 2026-06-19;
  filed 2026-05-25; PRD-0013, drafted same-day; promoted from
  candidate-stub after a second concrete instance accumulated)* — Define a taxonomy of session-boundary
  review checkpoints and name which automation fires at each. Two
  confirmed instances motivated the promotion: the distilled-learnings
  dormancy resolved by OPP-0026/ADR-0014/PRD-0011 (a declared
  "dedicated review session" that no automation fired in 40 days);
  the Tula two-pass discovery captured in OPP-0027..0031 plus its
  paired observation (a declared "orthogonal-framing second pass"
  that no automation scheduled — only happened because the maintainer
  re-read the README). v1 scope-bias: workflow-doc only (a new
  `platform/workflow/session-shape.md` peer to
  `cycle-end-distillation.md`) covering the full taxonomy plus the
  audit of currently-declared-but-unfired reviews; per-rule
  PRD passes for any new companion rules the taxonomy recommends.
  Anchored on the maintainer's framing: *"there's an as yet
  undefined optimal set of process steps for a session, and we are
  missing reviews that could be triggering these powerful
  automations we've designed."*

- **Design-artifact staleness — finalize-before-accept reconciliation**
  *(candidate stub, 1 instance, 2026-06-26)* — A drafted-but-unaccepted
  design artifact (a `Proposed` PRD, an `exploring` OPP) accumulates
  **silent drift** while it waits: catalog/validator counts go stale, ADR
  and diagram numbers it *reserved* get reassigned to other work,
  operating-principle section numbers it targets get taken, and version
  plans ship out from under it. **No validator catches this** — PRDs/OPPs
  sit on no count or `validate-list-completeness` surface — so a
  rubber-stamp acceptance carries every stale claim into the
  implementation PR as a spec a builder follows faithfully (and wrongly).
  This is a **declared-but-unfired review** in the
  [OPP-0032](OPP-0032-session-cycle-orchestration.md) taxonomy: the
  "finalize-before-accept" reconciliation wants a **PR-boundary** trigger
  (fires when a PRD diff flips `Proposed → Accepted`) and/or a
  **time-boundary** staleness cadence over long-`Proposed`/`exploring`
  artifacts. It is also the third member of the staleness-pressure family
  anchored by [OPP-0007](OPP-0007-canonical-position-artifact.md) (siblings
  A: validator-opt-out staleness; D: intake-canonical-SHA staleness) —
  here the *design artifact itself* is the thing with no staleness pressure.
  **One documented instance:** PRD-0007's 2026-06-26 finalization (drift
  across validator count `8→19`, catalog counts, a reassigned
  "Diagram 10"/"ADR-0013", an obsolete v0.6.0/v0.7.0 plan, and an FR
  targeting a now-taken `§ 9`). **Promotion criterion:** a second
  documented stale-design-artifact reconciliation → file the OPP (the
  candidate-stub-with-promotion-criterion discipline OPP-0032 itself used).
  A possible v1 mechanism: a `validate-companions` rule that, when a PRD's
  status line flips to `Accepted` in a diff, requires a "reconciled-against-
  main" finalization note — cheaper than a general freshness validator.

### Consumer onboarding & project hygiene

- [OPP-0040](OPP-0040-cross-platform-install-prerequisites.md) *(accepted
  2026-06-06; PRD-0020 — preflight + opt-in installer shipped)* — Surface and preflight the install path's real prerequisites
  (**Bash 4+, Ruby 3.0+, ripgrep, Git `core.symlinks=true`**) at first contact.
  Today they are documented only in reference sections an adopter reaches *after*
  the quickstart, and `install.sh` preflights them asymmetrically: Bash is
  hard-checked up front, a missing Ruby surfaces only as a late post-validator
  follow-up, and ripgrep / git-symlinks aren't preflighted at all. Surfaced by
  operator-reported macOS friction (Bash 3.2 + Ruby hit mid-install, not at first
  contact); grounded further by an internal doc inconsistency — `README.md` cites
  `submodule-integration.md#prerequisites` for the ripgrep requirement, but that
  section never lists ripgrep. Initial bias: a consolidated cross-platform
  prerequisites matrix (macOS / Linux / Windows-WSL) plus an `install.sh`
  up-front `--preflight`/doctor pass emitting one actionable report. Cross-platform
  (Windows/Linux) coverage is currently thin beyond the well-documented macOS edge.

Onboarding-safety pair surfaced by a single 2026-06-05 incident: a contextless
greenfield consumer (`unclenate.com`, "a portfolio site") was bootstrapped *inside*
the auto-harness platform working tree, committing the consumer's scaffold into the
platform's own history and mounting the platform into itself — caught by a human
when a routine commit was about to push a personal site up into the platform repo
(vestige since fully removed). OPP-0041 is the *general* guardrail (containment
safety); OPP-0042 is the *greenfield-specific* guardrail (don't over-assert from a
one-liner). They mirror the maintainer's own framing — "onboarding in general, and
complete greenfield projects specifically."

- [OPP-0041](OPP-0041-onboarding-containment-safety.md) *(accepted 2026-06-06; PRD-0020 — both guards shipped in install.sh + skill)* —
  Bootstrap/onboarding must **detect and refuse** instantiating a consumer *inside*
  the auto-harness platform repo (or any unrelated git repo), so a consumer is
  never scaffolded as a subdirectory of — or committed into — the platform.
  Detection is local and unambiguous (enclosing repo root owns `platform/core/kernel/`
  plus a `project.id: development-harness-framework` manifest). Silent today; passed
  every validator; caught only by a human. Initial bias: hard-fail preflight in
  `install.sh` (composes with OPP-0040) + the onboarding skill's first step, an
  `--inside-platform` escape hatch for `platform/examples/`, plus an
  extract-a-mis-created-consumer recovery runbook (the procedure this incident
  produced). Confidence: high.

- [OPP-0042](OPP-0042-greenfield-onboarding-conservatism.md) *(accepted 2026-06-07; PRD-0021 — greenfield mode added to the onboarding skill)* —
  Contextless greenfield should **route to discovery** (`new-product-discovery` /
  `interview-driven-discovery`), not a guessed enforcement-on composition. From "a portfolio
  site for me" the flow asserted `node-typescript` + `web-app` as active modules,
  authored a full `docs/` tree, and re-enabled `required-artifacts` — before any
  code existed, while its own comments admitted it was inferring intent
  ("enforcement deferred until package.json exists"). The "conservative module
  selection" rule is brownfield-shaped (evidence = files present); greenfield needs
  the inverse default. Initial bias: assert no stack/architecture module without a
  concrete evidence artifact; keep `required-artifacts` disabled through discovery;
  consider a structured `intent:` vs `modules:` split. Routing/defaults, not new
  machinery. Confidence: medium.

- [OPP-0038](OPP-0038-adopter-artifact-attribution-boundary.md) *(proposed
  2026-06-02; design deferred — to be informed by ongoing adoption practice)* —
  Define how a brownfield adopter should **sign** governance artifacts they
  author in a host project they don't own — retaining authorship without
  asserting affiliation, ownership, or rights over the host's identity, code, or
  trademarks. Origin: a fork-held consumer's intake artifacts were stamped
  `Owner: @adopter (HostOrg)`, falsely badging the adopter with the original
  owner's company; caught by a human, not a validator. The adopter-artifact vs.
  host-IP boundary is computable from `git` first-authorship, suggesting a
  possible `validate-attribution` check + manifest `hostOwner`/`adopter`
  declarations. Generalizes to any adopter-≠-owner context (contractors,
  internal platform teams, upstream contributors).

- [OPP-0006](OPP-0006-trust-tier-enforcement.md) *(accepted 2026-05-23;
  PRD-0006 v1 fully shipped — validate-trust-tier.sh + optional tier schema + dogfood declarations)* — Make the kernel-doctrine
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

- [OPP-0023](OPP-0023-doc-references-consumer-scan.md) *(accepted 2026-05-25; PRD-0012; v0.5.3)* —
  `validate-doc-references.sh` hard-fails (exit 2) for **submodule consumers**:
  it requires a `<root>/platform/` tree and never reaches its general
  markdown-link-resolution pass on consumer docs. The consumer CI template
  includes a doc-references step while `ci-integration.md`'s minimal workflow
  omits it — they disagree, so following the template reds a consumer's CI.
  Surfaced by the Tula onboarding (recorded in its `ADR-0002`). Initial bias:
  make the validator scan consumer `*.md` when no `platform/` exists (skip the
  platform-specific pass), and align the template + guide.

- [OPP-0025](OPP-0025-consumer-integration-smoke-test.md) *(accepted 2026-06-28;
  filed 2026-05-25 as OPP-0023 in working tree, renumbered after PR #59
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
- [OPP-0012](OPP-0012-data-module-relational-sql-engine-generalization.md) *(accepted 2026-07-09; filed 2026-05-24; PRD-0033)*
  — Generalize `data/relational-postgres` → `data/relational-sql` with
  `engine: postgres | mysql | mariadb | sqlite` sub-field. 95% of
  required artifacts are engine-independent; the rename keeps the
  catalog compact and unblocks MySQL/MariaDB/SQLite consumers.
- [OPP-0013](OPP-0013-domain-family-healthcare-decomposed.md) *(accepted 2026-06-01; PRD-0017; partial promotion — fhir + smart-on-fhir)*
  — Decomposed `domains/healthcare-*` family (12 sub-modules) +
  `templates/healthcare/` (8 templates) + `harness-healthcare` skill +
  `healthcare-full-ehr.yaml` convenience composition. Healthcare is
  the largest plausible regulated-domain expansion; per-concern
  granularity avoids forcing consumers into bundled artifact debt.
- [OPP-0039](OPP-0039-domain-family-aec-decomposed.md) *(accepted 2026-06-04; PRD-0019; partial promotion — iso19650-im + openbim-exchange + iso19650-5-security)*
  — Decomposed `domains/aec-*` family (6 sub-modules; 3 promoted to a v1
  wedge, 3 deferred) + `templates/aec/` + `aec-bim-project.yaml`
  convenience composition. The designated second built deep-domain
  vertical (sibling of OPP-0013); standards-anchored (ISO 19650 / openBIM
  / ISO 19650-5) rather than brownfield-derived. Grounds the deep-domain
  framework harvest with a compound forcing artifact and a domain ×
  cross-cutting composition.
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

- **[OPP-0027](OPP-0027-frontier-agent-posture.md)** *(accepted 2026-06-30;
  filed 2026-05-25; anchor)* — `management/frontier-agent-posture` overlay
  declaring a project commits to enterprise-AI-platform standards
  from skill #1: foundry-targeting, OTel-shaped observability,
  intelligent model routing, defense-in-depth-for-autonomous-agents.
  Lightweight umbrella; substantive machinery lives in the four
  satellites below. Second instance of the anchor-satellite filing
  pattern after OPP-0007.
- **[OPP-0028](OPP-0028-ai-foundry-target.md)** *(accepted 2026-06-27; filed
  2026-05-25; satellite of OPP-0027)* — `architectures/ai-foundry-target` —
  enumerated `foundries:` field naming which enterprise AI foundries
  (Microsoft / Azure AI Foundry, NVIDIA AI Foundry, Palantir Foundry /
  AIP, AWS Bedrock Agents, Google Vertex Agents, IBM watsonx
  Orchestrate) the project commits to landing in. New
  `architectures/`-family deployment-target dimension distinct from
  `delivery/` and `agents/`.
- **[OPP-0029](OPP-0029-agent-observability.md)** *(accepted 2026-06-27;
  filed 2026-05-26; PRD-0014, drafted same-day; satellite of OPP-0027)* — `architectures/agent-observability`
  — OpenTelemetry-shaped multi-agent semantic conventions (Microsoft +
  Cisco Outshift). Required artifacts: `docs/observability/trace-contract.md`,
  plus `docs/observability/exporters.md`. Companion rule: action-code
  changes require trace-contract updates if a new span shape is
  introduced. Composes with OPP-0028 (foundries consume the shape)
  and OPP-0030 (model-selection spans).
- **[OPP-0030](OPP-0030-intelligent-model-routing.md)** *(accepted 2026-06-28;
  filed 2026-05-25; satellite of OPP-0027)* — `architectures/intelligent-model-routing`
  — deployment-context-aware multi-provider routing as a first-class
  architectural primitive. Required artifact: `docs/architecture/model-routing.md`
  with the routing table, decision criteria, providers, and
  foundry-routing seams. Healthcare-specific routing (MedGemma 4B/27B,
  MedASR, MedImageInsight, CXRReportGen) named in the suggested-providers
  list but not required.
- **[OPP-0031](OPP-0031-agent-defense-in-depth.md)** *(accepted 2026-06-28;
  filed 2026-05-25; satellite of OPP-0027)* — `architectures/agent-defense-in-depth`
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

### Safety hardening — closing structural-only enforcement gaps (2026-05-27)

Filed alongside [ADR-0017](../adr/ADR-0017-safety-hardening-roadmap.md)
(Safety Hardening Roadmap). Each OPP closes one Asserted-only claim or
attack-vector cluster from `documentation-audit-2026-05-27/
safety-security-sweep.md`. Sequenced for Wave 5 of the execution
roadmap (5.1 → 5.3 → 5.5 → 5.2 → 5.4 per ADR-0017's amortized-risk
ordering). All four OPPs use the §9 design-then-enforce pattern: ship
the contract at v1; defer per-rule extensions to v2 if scope bloats.

- [OPP-0033](OPP-0033-validate-skill-content.md) *(accepted 2026-05-28;
  PRD-0015; Wave 5.2 shipped)* — Content-safety validator
  (`validate-skill-content.sh`) scanning SKILL.md and `module.yaml`
  text fields against a deny-list of prompt-injection and tier-bypass
  patterns. Closes red-team attack vectors V1, V2, V4, V6 from
  safety-security-sweep §3. Wave 5.2.
- [OPP-0034](OPP-0034-validate-sensitive-paths.md) *(accepted 2026-05-27;
  Wave 5.3 shipped)* — Sensitive-paths overlap validator (`validate-
  sensitive-paths.sh`) asserting every declared `sensitivePaths`
  pattern is overlapped by at least one `companionRules.triggerPaths`
  regex. Closes safety-security-sweep §2 claim 12 (Asserted-only →
  Enforced). Smallest of the four (half-day). Wave 5.3.
- [OPP-0035](OPP-0035-security-static-analysis.md) *(accepted
  2026-05-28; promoted via PRD-0016; Wave 5.4 shipped)* — Security static analysis module
  (`management/security-static-analysis`) overlaying per-stack SAST
  configs + `validate-sast-coverage.sh`. Addresses safety-security-
  sweep §11 — *the largest mission-relative gap in the entire safety
  sweep* (the harness governs AI code generation but has zero
  machinery inspecting agent-generated code). Filed explicitly as a
  child OPP under [OPP-0020](OPP-0020-evaluation-tooling-in-harness-toolchain.md).
  Wave 5.4.
- [OPP-0036](OPP-0036-validate-knowledge-redaction.md) *(accepted 2026-05-27;
  Wave 5.5 shipped)* — Knowledge-redaction validator
  (`validate-knowledge-redaction.sh`) + CODEOWNERS rule on
  `docs/knowledge/` and `docs/operating-principles.md`. Closes
  safety-security-sweep §8 cross-pollination findings and §9 reverse-
  direction prompt-leakage pathways 1–4. Wave 5.5.
- [OPP-0048](OPP-0048-redaction-scope-and-publication-boundary-hardening.md)
  *(accepted 2026-06-24; PRD-0026 ratifies mechanism 1 — the always-on
  `do-not-publish` blocking validator; mechanism 2 staged as a phase-2 follow-up)* —
  **Redaction-scope & publication-boundary
  hardening.** Follow-up to OPP-0036: its scanner covers only the two
  knowledge files against a hardcoded denylist, while a public repo parks
  **untracked** private design material under `docs/superpowers/specs/`
  (excluded from placeholder + markdownlint) with zero publish-time gate.
  Proposes (1) a file-level `do-not-publish` frontmatter marker + a
  **blocking** validator that fails if a marked file becomes tracked (needs
  no name list), and (2) a configurable, wider-scope extension of the
  content scanner. Forcing case: the parked Digital Twin seed brief, guarded
  today only by agent memory and manual `git add` discipline.

### Doctrine codification — operating-principle promotions (2026-05-28)

Promotions of meta-patterns from `docs/knowledge/shared-observations.md`
into `docs/operating-principles.md`, gated by the §9 three-instance
generalizability bar (the bar §9 itself was promoted under). Each entry
ships the design contract as an OPP; the implementation (the
`operating-principles.md` section edit) follows in a separate PR per
the §9 split-design-from-implementation discipline.

- [OPP-0037](OPP-0037-classify-before-enforcing-as-operating-principle.md)
  *(accepted 2026-05-28; promoted directly to §10)* — Promote claim-vs-enforcement classification
  to a new §10 operating principle. Four documented instances
  (refresh-2 audit, Wave 2b safety sweep, Wave 5.1 mechanizing-doctrine,
  Wave 5.5 posture-design) exceed the §9 three-instance bar by one.
  Design-only OPP; implementation PR adds the §10 section.
- [OPP-0049](OPP-0049-deep-governance-vertical-harvest.md)
  *(accepted 2026-06-21; Phase 2 promoted to §12)* — Harvest the
  deep-governance-vertical authoring skeleton (neutral-core + forcing-artifact +
  bias-guardrail + decomposition + composition-shape + predict-clean validator)
  into a §12 operating principle and an authoring playbook. Six proven instances
  (healthcare, AEC, cybersec, geospatial + the privacy & digital-twin overlays)
  double the §9 three-instance bar. Phase 2 (§12 doctrine) shipped; Phase 3 (the
  playbook) and Phase 4 (meta-template) remain.

### Cybersecurity deep-domain vertical — OSINT / Maltego (2026-06-05)

The third built deep-domain vertical after healthcare (OPP-0013) and AEC
(OPP-0039). Standards/tool-anchored (MITRE ATT&CK + PTES, anchored on the
real operator tool Maltego) rather than brownfield-derived. Adds a single
family-wide forcing artifact (`engagement-charter.md`, shared across unbuilt
siblings) and a tool-entry (dogfooded) / catalog-module (predict-clean) split.

- [OPP-0043](OPP-0043-domain-family-cybersecurity-decomposed.md) *(accepted 2026-06-05; PRD-0022; partial promotion — cybersec-osint)*
  — Decomposed `domains/cybersec-*` family (`cybersec-osint` built as a v1
  wedge; `cybersec-red` + `cybersec-blue` deferred; Purple is a documented
  red × blue composition, never a module) + `templates/cybersec/` +
  `cybersec-osint-engagement.yaml` composition + a Half-enforced
  `engagement-charter` WARN validator + the dogfooded Maltego tool entry.
  Disambiguated from `management/security-static-analysis` (SAST) and
  `aec-iso19650-5-security` (built-asset sensitivity). Composes with
  `management/privacy-by-design` — the catalog's second domain × cross-cutting
  composition.

### Digital Twin / Scenario Runtime overlay (2026-06-10)

A reusable cross-cutting governance overlay for projects that model real-world
systems, run scenarios, and publish decision-support outputs. The second
discipline overlay (after privacy-by-design) built on the deep-domain
primitives; dual-spine standards anchor (interoperability/digital-thread +
the Gemini Principles); a maturity-gated forcing artifact.

- [OPP-0044](OPP-0044-digital-twin-scenario-runtime.md) *(accepted 2026-06-10; ADR-0019; PRD-0023)*
  — `management/digital-twin` (default-off opt-in) + `templates/digital-twin/` +
  `digital-twin-prototype.yaml` composition + two Half-enforced WARN validators
  (`validate-twin-profile`, `validate-scenario-manifest`) + the `harness-digital-twin`
  skill. Composes with `management/privacy-by-design` and `domains/aec-iso19650-im`
  (the municipal / real-estate planning-twin stack).

### Geospatial / GIS domain family (2026-06-12)

The fourth deep-domain vertical: GIS / mapping / BIM↔GIS governance. A
jurisdiction-neutral CRS substrate, an OGC exchange layer with a
publisher/consumer role axis, and the first cross-family bridge module
(geospatial × AEC). The CRS forcing artifact is the purest instance of the
jurisdiction-profile primitive — geodetically *and* temporally bound.

- [OPP-0045](OPP-0045-domain-family-geospatial-decomposed.md) *(accepted 2026-06-12; PRD-0024; Phase 2 shipped)*
  — decomposed `domains/geospatial-*`: a `geospatial-foundation` +
  `geospatial-exchange` + `geospatial-bim-georeference` wedge,
  `templates/geospatial/`, the `geospatial-bim-twin.yaml` 4-way composition, and
  four deferred family members. First cross-family dependency
  (`geospatial-bim-georeference → aec-openbim-exchange`) and first temporal
  forcing-artifact axis. Composes with `management/digital-twin` and
  `management/privacy-by-design` for geospatial sensitivity (compose-don't-build).

### Parallel multi-agent execution — work-package lane contract (2026-06-15)

Governing concurrent multi-agent work (Claude + Codex + Gemini in isolated git
worktrees): a machine-checkable work-package lane contract, a normalized worktree
runbook, and the shared-observations ledger as an explicit cross-agent memory bus.
The multi-agent analog of the module declare-then-enforce contract.

- [OPP-0046](OPP-0046-parallel-multi-agent-work-package-lane-contract.md) *(accepted — partial promotion 2026-06-15; PRD-0025 promotes the lane wedge as `management/work-package`; triaged from issues #121 + #122)*
  — decomposed: a WP lane schema (`allowedFiles` / `requiredChecks` /
  `forbiddenCommands` / `prMode`) + a lane-vs-diff lint validator + a conflict
  protocol + an idempotent worktree runbook (wedge candidates); cross-agent
  memory-bus auto-load, interface-first contract-stub, and project-specific rules
  deferred. Harvest the schema from real PlanAtlas / `central-city-web` lane specs.

### Delivery-cost & unit-economics governance (2026-06-15)

Token cost of agentic *delivery* (what it costs to build a unit of code) as
governance evidence for build-vs-buy decisions — a new economics axis beside
quality/safety. Govern the contract (a delivery-cost record + budget + a
cite-the-evidence rule), not the extraction; composes with the OPP-0046 lane
(lane = scope, cost record = economics).

- [OPP-0047](OPP-0047-delivery-cost-unit-economics-governance.md) *(proposed 2026-06-15; pairs with a research brief)*
  — decomposed: a delivery-cost record schema + a `tokenBudget` on the WP lane +
  a `build-vs-buy-decision.md` artifact that must cite cost evidence (wedge
  candidates); the cost-attribution convention, baselines, scope→spend predictor,
  and dispatch-cost optimization deferred (mostly research). Landscape confirms the
  gap: OTel standardizes token counts not cost, and no tool attributes cost to a
  unit of delivery.

### Canonical direction & strategic alignment

- [OPP-0007](OPP-0007-canonical-position-artifact.md) *(accepted + SHIPPED
  2026-06-26 — `management/canonical-position` module + templates + citation/
  ratification rules live on main; PRD-0007 finalized & accepted)* —
  Introduced the canonical-position artifact as a first-class harness
  primitive. Every other strategy / product / GTM / partnership artifact
  cites it and cannot contradict it. Anchored four sibling observations
  (validator opt-out staleness; opportunity-capture backlog re-audit on
  canonical change; formal review/reconciliation artifact type;
  intake-vs-canonical-direction staleness) — now follow-up OPPs, joined by
  Observation E (reconciliation-load patterns → a future § 13). Identified
  as the highest-leverage single gap in the harness's artifact catalog by
  the four-lens project alignment audit (MB-REV-003) of `bdits/municipal-brain`.

- [OPP-0050](OPP-0050-module-stability-tiers-parity.md) *(accepted
  2026-06-26; PRD-0027 ratifies the v1 wedge — `stability` field + always-on
  `validate-module-stability.sh` + 57-module backfill)* — **Module stability
  tiers & parity normalization.** The
  catalog has uniform structural metadata (6 fields in 57/57 modules) and
  anti-sprawl gates (§ 12 inclusion test), but **no module-readiness
  signal** — `stability`/`maturity` is in 0/57. Add a per-module
  `stability: {experimental | beta | stable}` field (distinct from trust
  tier = *risk* and § 10 = *per-claim enforcement*), backfill it across all
  57 modules against a rubric, surface it in onboarding + an honest
  stack-parity note (`stacks/` is 3/4 JS-family), and assert presence +
  enum with a light validator. Extends § 10 honesty from *claims* to
  *modules*; makes the platform's blanket "alpha" granular. The distilled,
  field-verified signal from a 2026-06-26 external review that was otherwise
  ~70% already-built. Deferred: behavior-gating on stability, a module
  deprecation/lifecycle policy, stack build-out.

- [OPP-0051](OPP-0051-frontier-agent-cluster-v2-enforcement.md) *(accepted
  2026-06-28)* — **Frontier-Agent Cluster v2 Enforcement: Artifact-Content
  Validators.** The four cluster satellites (observability / foundry-target /
  model-routing / defense-in-depth) shipped declarative-v1 — they require
  their artifact to *exist* but never check its *content*, leaving every § 10
  central claim Half-enforced. Open the deferred v2 thread by drawing the line
  between the two enforcement halves: **artifact-content / shape conformance**
  (assert the declared artifact is internally well-formed — e.g.
  `trace-contract.md` pins a semconv version + declares a span in the
  conventional shape) is fixture-testable today, like `validate-sast-coverage`;
  **code-cross-reference** (the declaration matches the running code) still
  needs a fixed consumer code path and stays deferred. Ship the content half,
  anchored on `validate-trace-contract.sh` (the cross-foundry conformance
  anchor), module-gated / predict-clean; the other three content validators
  reuse its shape-assertion skeleton as follow-on phases. Asserts load-bearing
  invariants only (presence + shape), never exhaustive correctness, mirroring
  `validate-module-stability`. Harvests the identical v2 deferral from PRD-0014
  / 0028 / 0029 / 0030.

- [OPP-0052](OPP-0052-federated-review-lane-contract.md) *(proposed
  2026-07-09)* — **Federated Review-Lane Contract (verdict schema + coordination
  substrate).** OPP-0046 / PRD-0025 mechanized the scope-lane (who writes what);
  the complementary **review-lane** (who reviews whom, in what artifact, how
  verdicts are tallied) has no machine-checkable substrate. Ship a
  `platform/templates/coordination/` scaffold + a provider-neutral verdict schema
  `{ taskId, reviewer, verdict, severity, findings[], timestamp }` +
  `validate-coordination-verdicts.sh`, so cross-provider reviewers (Claude / Codex
  / Copilot / Antigravity) emit the same artifact and an adjudicating core tallies
  them mechanically. The enforcement half of a two-layer inter-agent contract whose
  design authority-of-record lives in a consumer supervisor's ADR. Field-proven
  before authored: two Enforced rules (canonical shared `taskId`; mandatory
  decorrelated-provider coverage) each fix a specific defect observed in a real
  federated-review cycle (verdict label-swap; core-only adjudication). Sibling half
  of OPP-0046; declare-then-enforce retargeted from scope to review.

- [OPP-0053](OPP-0053-observation-ledger-hygiene.md) *(accepted 2026-07-12;
  filed 2026-07-10; PRD-0034 + PRD-0035; delivered end-to-end
  2026-07-15)* — **Observation-Ledger Hygiene Gate (structured-agent-ledger
  validator + ambient auto-capture).** `management/knowledge-capture` enforces that a
  shared observation *exists* and is *connected* (audit-trail + distillation
  pointers) but never checks its *shape*. ADR-0002 locks six fields with two enums,
  yet the schema has drifted for want of a validator: of 105 live observations,
  **62 (59%) carry an off-enum `Severity`**, the most-severe canonical level
  `risk-bearing` is used **0×**, and ~20% omit `Confidence` or `Contributed by`.
  Shipped (1) `validate-observation-hygiene.sh` — a diff-based BLOCK linter checking
  each added observation against ADR-0002 (six fields, both enums, ISO date),
  grandfathering history (PRD-0034, Layer 1); (2) an ambient auto-capture Stop-hook
  that scaffolds a schema-shaped inert stub when a session touched a
  distillation-trigger path but not the ledger (PRD-0035, Layer 2). **Sibling of OPP-0052**: the same *structured-agent-ledger gate*
  species retargeted from the verdict ledger to the knowledge ledger — reconciled at
  the convention layer (named in `stigmergy.md`, separate module homes) rather than
  shared code, since a Markdown field-parser and a JSON schema-validator barely
  overlap. The one load-bearing PRD-time (§ 10) decision — `Severity`
  enforce-as-locked vs. amend-ADR-0002 — resolved as **enforce-as-locked**, because
  `Severity` drives ADR-0002's escalation table, so off-enum drift silently defeats
  escalation. Validator count 24 → 25.

- [OPP-0054](OPP-0054-status-parity-validator.md) *(exploring 2026-07-18; PRD-0036)* —
  **Status-Parity Validator (OPP record status vs. derived index surfaces).** An
  OPP record's `Status` field is the source of truth, but the same state is
  mirrored into ≥ 2 *derived* surfaces no validator reconciles: the
  `candidates.md` annotation token and the `docs/README.md` status column.
  `validate-list-completeness.sh` checks every OPP has an index *row* (presence)
  but never that the row's *status* agrees with the record → silent drift. Ship an
  always-on `validate-status-parity.sh` that recomputes each derived surface's
  status token from the record and diffs — the same species as
  `validate-catalog-counts.sh` (recompute-a-derived-claim) applied to status
  instead of counts, and the completion of `validate-list-completeness.sh` (row
  status, not just row presence). **Field-proven this session at my own expense:**
  #174 missed a status flip → forced the #177 closeout; #177 reconciled 10
  `candidates.md` annotations by hand yet silently left `docs/README.md`'s OPP-0012
  row at `proposed` (fixed in this same PR). Root cause is structural — ADR-0012
  exempts `candidates.md` from the companion-rule floor as *organizational*, which
  is why nothing reconciles it. Two load-bearing § 10 forks (missing-annotation
  policy; BLOCK vs. WARN) → short-PRD promotion recommended. Sibling of OPP-0053
  (shape-parity on the observation ledger); this is status-parity on the
  opportunity index.

---

## References

- Policy: `README.md` (this directory)
- Per-candidate template: `platform/templates/opportunity/opp-template.md`
- Module definition: `platform/profiles/management/opportunity-capture/module.yaml`
- Split rationale: `docs/adr/ADR-0012-opportunity-capture-index-split.md`
