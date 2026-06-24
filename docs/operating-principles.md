<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Operating Principles — Development Harness Framework

> Owner: @unclenate
> Last updated: 2026-06-11 *(§ 3 gained the enumeration-surfaces-drift bullet — member lists for validators/skills drift independently of the totals they sum to: a count validator guarding "17" does not guard that the validator *table* lists 17 rows, which is how the `management/digital-twin` overlay (#112) bumped the asserted 17/8 counts yet left a dozen enumeration tables reading 15/7; corrected here by propagating the DT validators/skill to every catalog surface while keeping run-chain surfaces matched to `harness.yml`. Prior: § 3 gained a bullet 2026-06-10 — a new counted surface couples its entrypoint count in the same change (architecture-diagram worked example, the `management/digital-twin` family diagram, #14); § 3 gained the register-prose-counts bullet 2026-06-07 during the QA pass that fixed the HARNESS.md/README.md "twelve→thirteen" diagram-count drift; § 10 "Classify Claims Before Enforcing Them" added 2026-05-28 from the four-instance [[claim-vs-enforcement-classification]] observation chain (OPP-0037); § 9 "Split Design from Implementation" added 2026-05-26; the curated longitudinal destination role established 2026-05-25 per ADR-0014)*

These principles govern how the harness platform itself is built and evolved.
They are derived from the kernel doctrine and adapted to this project's context.

This file is the project's **curated longitudinal destination** for durable
how-this-project-works truths synthesized from accumulating observations in
[`docs/knowledge/shared-observations.md`](knowledge/shared-observations.md).
Promotion from observations to principles happens when patterns crystallize —
when the same pattern appears across multiple observations or when a single
observation has clearly universal scope. Promotion is not on a fixed cadence;
it is driven by accumulated evidence (see ADR-0014 for the rationale and
[PRD-0011](requirements/PRD-0011-distilled-learnings-disposition.md) for the
design that consolidated this role here).

---

## 1. Ownership

Every module, validator, template, and workflow document has a named owner.

- Primary owner: @unclenate
- The harness is currently a solo project. As contributors join, ownership will be
  distributed per module family.

---

## 2. Review Discipline

Review is a knowledge-distribution mechanism, not a rubber stamp.

- All governance changes (HARNESS.md, AGENTS.md, module.yaml companion rules,
  validator logic) require deliberate review
- AI agent output is reviewed to the same standard as human output
- Gap analyses from multiple AI tools are cross-verified before acting
- **Companion-rule satisfiers scale with change weight.** Substantive decisions
  (new authentication model, new CI surface, new ownership boundary) require an
  ADR / PRD / operating-principles update. Routine maintenance (Dependabot
  version bumps, CODEOWNERS line additions, minor workflow ergonomics) may
  satisfy the kernel rule via a `docs/project/change-log.md` or
  `docs/project/dependency-log.md` entry that names the change and the
  reviewer. See [ADR-0010](adr/ADR-0010-cheap-satisfiers-for-routine-governance.md)
  for the rationale and the kernel rule definition.

---

## 3. Documentation as Part of the Change

Documentation is not follow-up work. A change is not complete until its documentation is current.

- New modules require README.md and module.yaml in the same commit
- Template changes require templates/README.md directory map update
- Workflow changes require SUMMARY.md and cross-reference updates
- Active-module catalog changes propagate to HARNESS.md, SUMMARY.md, README.md (directory tree), `platform/skills/harness-onboarding/SKILL.md` (module catalog), and `platform/workflow/discovery-to-composition.md` (decision rubric) in the same pass
- Repo-root governance entrypoints (`README.md`, `HARNESS.md`, `AGENTS.md`, `CLAUDE.md`, `TOOLS.md`) each carry a distinct job statement; when one is edited to change scope, the others' job statements and the SUMMARY.md "Entry Points by Audience" block are reviewed in the same pass
- **Module-text reads in stripped contexts.** `module.yaml` `description`, `humanReview`, and similar prose fields appear in validator output, CI logs, and onboarding docs without their surrounding file context. Use fully-qualified repo-relative paths (`docs/opportunities/README.md`) in rule text, not bare basenames (`README.md`) — the YAML reads unambiguous to the author but the CI log line does not. Catch in review; this is not validator-enforceable.
- **Cycle-end distillation is the trigger-side counterpart to destination-side audit trails.** Existing companion rules require an audit trail when a *destination* (`shared-observations.md`, `distilled-learnings.md`, etc.) is touched. The cycle-end distillation rule (PRD-0004; landed in `management/knowledge-capture` v1.1.0) is the inverse: when *distillation-worthy work* is in a PR diff (new ADR, new OPP, OPP `proposed` flip, new module manifest, catalog change), at least one knowledge destination must be touched in the same diff. Two rules, two satisfiers, one coherent PR. See [`platform/workflow/cycle-end-distillation.md`](../platform/workflow/cycle-end-distillation.md) for the satisfier decision tree.
- **A prose count claim that is not in the `validate-catalog-counts.sh` assertion table will drift.** Every place that states a catalog size in prose — "thirteen diagrams", "fifteen validators", "seven skills" — is a drift site. The validator only protects the (file, regex) pairs registered in its assertion table; counts stated anywhere else read as covered but are not. When you add a numeric/word-form catalog claim to a tracked file, register it in the assertion table in the same change (word-form is normalized, so register the natural English too). The HARNESS.md and README.md *diagram* counts went stale to "twelve" while the canonical count, the cover SVG, and `diagrams.md` itself all read thirteen — precisely because those two prose sites were unguarded. This is the count-drift instance of § 10 (*classify before enforcing*): a claim is only enforced where a check actually reads it.
- **A new counted surface couples its entrypoint count in the same change.** Adding an architecture diagram (a `## N.` section in `docs/architecture/diagrams.md`) increments the canonical diagram count, and `validate-catalog-counts.sh` asserts that count against the `HARNESS.md` and `README.md` prose — so the entrypoint bump is *coupled*, not optional follow-up: omit it and CI fails rather than drifting silently. This holds even when the motivating capability is a catalog-only, default-off overlay that never enters this repo's own manifest (e.g. the `management/digital-twin` family diagram, #14): the overlay is invisible to the active-module list, but its diagram still moves the entrypoint count. This is the *enforced* counterpart to the register-prose-counts bullet above — the assertion table is precisely what converts a drift-prone prose count into a same-change requirement, and what now prevents a recurrence of the earlier twelve→thirteen HARNESS.md drift.
- **Enumeration surfaces drift independently of the counts they total.** `validate-catalog-counts.sh` guards numeric *totals*, and `validate-list-completeness.sh` guards that ADRs / PRDs / OPPs / compositions / template subdirectories / profile modules / agent modules are each indexed — but the *member lists* for validators and skills (the `README.md` / `SUMMARY.md` / `platform/validators/README.md` tables, the `harness-governance` run-chain, the skills tables) are guarded by neither. Adding a validator or skill must add its row to every enumerating surface in the same pass, not just bump the total: when the `management/digital-twin` overlay shipped (#112) it correctly raised the asserted validator/skill counts to 17/8 yet left a dozen enumeration tables reading 15/7, because none of those files sit in the overlay's companion `triggerPaths`. The bump-the-number bullets above are necessary but not sufficient — the rows are a separate, unguarded surface. Distinguish *catalog* surfaces (enumerate what exists → list all 17 validators) from *run-chain* surfaces (enumerate what CI actually executes → match `.github/workflows/harness.yml`, which omits the two module-gated Digital Twin validators by design); the two are corrected to different memberships, not the same number.

---

## 4. Secrets and Credentials

Secrets never belong in tracked artifacts.

- This platform repo contains no runtime secrets — it is a governance framework,
  not an application
- Consumer projects using the harness must follow the kernel's secrets doctrine

---

## 5. Self-Governance

The harness governs itself using its own module system.

- `harness.manifest.yaml` declares active modules
- Validators run against this repo's own artifacts
- Disabled validations are documented and justified — not silently skipped
- The gap between declared governance and practiced governance should be zero

---

## 6. AI-Assisted Development

AI acceleration increases the need for controls, not the license to skip them.

- Multiple AI tools are used for gap analysis (Claude Code, Cursor, Copilot, Codex)
- Cross-tool findings are verified against disk before acting
- Agents operate within the trust tier model defined in AGENTS.md
- Every significant product decision gets a PRD; every architectural decision gets an ADR
- Agent-local context folders (`.claude/`, `.codex/`, `.cursor/`, `.github/`, and
  similar) are projection surfaces, not durable sources of governance truth. Fresh
  harness installs may create or seed those surfaces with shims, symlinks, or
  managed blocks that point back to `HARNESS.md`, `AGENTS.md`, and
  `platform/skills/`; brownfield installs must detect existing tool-local content
  and preserve it unless the human explicitly opts into an additive managed update.

---

## 7. Align File Boundaries with Change-Class Boundaries

When a companion rule needs to distinguish two classes of edit (structural vs.
organizational; binding vs. routine; policy vs. derived view), reshape the
artifact so each class lives in its own file rather than teaching the regex
layer about substructure.

- The companion-rule machinery's value is the simplicity of regex-over-paths.
  File shape determines the regex's precision; if a regex can't separate two
  change classes within one file, the artifact is doing too much.
- Prefer file splits over section-aware triggers, per-rule renderer parsers,
  or perpetual-exemption mechanisms — those add complexity that generalizes
  nowhere or codifies governance escape hatches as first-class primitives.
- First applied in [ADR-0012](adr/ADR-0012-opportunity-capture-index-split.md):
  the `management/opportunity-capture` README rule was firing on pure
  organizational edits; the fix was splitting the candidate index into a
  sibling `candidates.md` so the ADR-gated file holds only policy. No
  validator-engine change was needed.
- When evaluating a new companion rule, ask: *does the file this rule
  guards contain exactly one change class?* If not, split it before
  writing the rule.

---

## 8. Prefer Text Representations

When a new harness artifact can be expressed as text (YAML, Markdown,
Mermaid, SVG, plain bash) or as binary / proprietary format (PNG, JPG,
Figma file, Word doc, GUI-tool project file), choose text. The default
is overwhelming: every binary asset introduced is a maintenance and
governance debt the harness pays continuously.

- **Versionable** — text diffs are reviewable; binary diffs are opaque.
  A reviewer can see exactly what changed in a Mermaid diagram or SVG
  cover; a reviewer cannot meaningfully review a PNG diff.
- **Toolchain-free** — text artifacts edit in any editor on any
  platform. Binary artifacts couple the project to specific tooling
  (Figma seats, Photoshop licenses, Sketch on macOS-only) and to
  specific people who have that tooling.
- **CI-friendly** — validators can read, parse, and assert against
  text. They cannot meaningfully inspect a binary. Companion rules,
  placeholder validators, and link checkers all assume text input.
- **Diffable in PR review** — the same property that makes text
  reviewable in commits makes it reviewable in PR comments, where
  reviewers can quote specific lines.
- **Future-proof** — text representations survive tool deprecation.
  A 2026 Figma project may not open in 2036; a Mermaid block in a
  Markdown file will.

**Applied in the harness:**

| Surface | Text choice | Rejected alternative |
|---------|-------------|----------------------|
| Module contracts | `module.yaml` | GUI module-builder UI |
| Validators | Bash + Ruby scripts | Compiled binary tool |
| Architecture diagrams | Mermaid in Markdown | Static PNG / Figma export |
| Book covers | SVG (text-based) | PNG / JPG / InDesign |
| Skill definitions | Markdown SKILL.md | Compiled skill bundle |
| ADRs / PRDs / OPPs | Markdown | Confluence / Notion pages |
| Documentation diagrams | Mermaid blocks | Diagram-tool exports |
| Configuration | `.harness-headers.yaml`, etc. | TUI / config UI |

**When to break the rule:**

- **Photography or illustration** that genuinely requires raster (logos
  with photographic elements, screenshots of real product UIs, charts
  with thousands of data points). Even then, store the *source* of the
  artifact (Lightroom catalog, raw photo, screenshot recipe) alongside
  the rendered binary so the regeneration path is documented.
- **Render targets** for downstream tools that don't accept text (some
  print services need PNG / TIFF; some browsers can't render SVG
  filters). Generate from text source on demand rather than committing
  the binary. See `docs/_assets/README.md` for the rsvg-convert recipe
  that produces PNG covers from the SVG sources.
- **Tool-specific binary that must round-trip** (e.g., a `.psd` whose
  layers carry information the rendered PNG flattens away). Document
  the round-trip dependency explicitly so the rule's exception is
  legible.

**When introducing a new artifact, ask:** *can this be expressed as
text without losing essential meaning?* If yes, do so even if the text
representation is slightly less polished than the binary alternative;
the maintenance + governance gains compound across the project's
lifetime. If no, document the exception and the regeneration path
alongside the artifact.

- Derived from accumulated evidence in
  `docs/knowledge/shared-observations.md`: YAML manifests + bash
  validators + Markdown SKILL files + Mermaid diagrams + SVG covers
  each introduced under their own design pressure; the *pattern across
  all of them* is what this principle codifies. See specifically the
  observation *"Each new artifact asserting a catalog count is a new
  place that fact can drift"* (2026-05-22) which articulated the
  downstream cost of replicating facts across new artifacts —
  manageable when those artifacts are text (greppable, diffable, CI-
  assertable), much less so when they are binary.

**Markdown table caveat — never put a raw `|` inside backticks inside a
table cell.** Markdown is a preferred text representation, but its table
syntax has a sharp edge that costs review cycles: a literal `|` inside an
inline code span within a table cell is parsed by the renderer as a column
delimiter. It silently breaks the table (extra columns — `markdownlint`
MD056) and cascades into spurious "spaces inside code span" warnings
(MD038). When a table cell must show pipe-containing content — enum unions
like `a / b / c`, shell pipelines — use one of:

- **slashes:** `a / b / c`
- **prose:** "a, b, or c"
- **escaped pipes:** `a \| b \| c`

This bit the auto-harness change-log twice in one session (the
OPP-0011..0017 batch, 2026-05-24): an `engine` enum code span listing four
SQL engines inside a table row reported nine columns where six were
expected. The fix was slashes. The caveat is a corollary of this section,
not an exception to it — Markdown remains the right choice; the table
sub-syntax just has a trap worth naming so future authors don't re-pay the
review cycles.

---

## 9. Split Design from Implementation

When a PRD's natural scope would bundle *design work* (deciding what the
system should do and why) with *implementation work* (writing the rule,
regex, validator, or module that enforces it), prefer shipping the design at
v1 and deferring the implementation to a follow-up OPP/PRD pair.

- **Design and implementation are different change classes**, and operating
  principle § 7 (*Align File Boundaries with Change-Class Boundaries*) is the
  load-bearing argument: the design work of deciding "which review wants which
  trigger primitive" or "what contract should this module declare" is reviewed
  on different terms than the implementation work of writing a rule's regex,
  satisfier set, and `humanReview` text. Bundling them lets the lighter half
  ride on the heavier half's review and starves each of its own design
  pressure.
- **v1 ships the contract; a follow-up ships the enforcement.** The v1 PRD
  establishes *what should happen and why*; follow-up PRDs ship *how each
  component does its part*. This lets the v1 contract be validated against
  real consumer adoption before enforcement machinery locks it in — a contract
  that no consumer exercises is cheaper to revise than one already wrapped in
  companion rules and validators.
- **The cost is one extra PR per implementation; the benefit is that each
  implementation gets full design-pressure review on its own terms.** When the
  cheap move is "ship taxonomy plus four new rules in one PR," the disciplined
  move is usually to ship the taxonomy and defer the rules — unless the rules
  are trivial and the taxonomy is meaningless without them.
- **Record the deferral explicitly.** A deferred implementation that is not
  written down is indistinguishable from a forgotten one. State in the v1 PRD's
  Non-Goals or a dedicated *Implementation Deferral* section which
  implementations are deferred, to what follow-up, and why (see the PRD
  template's *Implementation Deferral* section).

**First applied** across three instances in one session (2026-05-26),
documented in `docs/knowledge/shared-observations.md`:

- **[PRD-0011](requirements/PRD-0011-distilled-learnings-disposition.md)** —
  the distilled-learnings sunset explicitly rejected Option B (adding a
  synthetic forcing trigger to operating-principles) to preserve the
  evidence-driven promotion cadence. Design without new enforcement.
- **[PRD-0013](requirements/PRD-0013-session-cycle-orchestration.md)** — the
  session-cycle taxonomy ships the workflow doc and defers the per-rule
  companion-rule machinery to per-rule OPP→PRD cycles.
- **[PRD-0014](requirements/PRD-0014-agent-observability.md)** — the agent-
  observability module ships the trace-contract *contract* and templates and
  defers the trace-contract-update companion rule to a v2 OPP/PRD pair.

**When drafting a PRD, ask:** *does this PRD's natural scope bundle "what
should happen" with "the machinery that enforces it"?* If yes, ship the design
and defer the enforcement — unless the enforcement is trivial or the design is
inert without it. Name every deferral so it is a record, not a gap.

## 10. Classify Claims Before Enforcing Them

Every load-bearing claim the framework makes about its own behavior or
governance-contract integrity is either **Enforced** (a validator catches
violations), **Half-enforced** (partially structurally checked), or
**Asserted-only** (claimed in prose, not checked anywhere in code). Run the
classification *before* deciding what to enforce next; the output of the
classification IS the next-phase roadmap.

- **The Asserted-only cluster is the safety debt.** Honor-code prose can
  carry inconsistency, contradiction, or silent drift indefinitely because
  no code ever checks it. Enumerating which load-bearing claims fall in
  the Asserted-only bucket makes the safety debt visible — and visible
  debt can be sequenced, scoped, and paid down. Hidden debt accumulates.
- **The Half-enforced cluster is the upgrade-path candidate set.**
  Partial enforcement is often where the highest-leverage validator
  improvements live: the structural surface is already understood, the
  contract already half-codified, and converting Half-enforced to
  Enforced is usually smaller scope than converting Asserted-only to
  Enforced. Treat Half-enforced as a triage queue, not as an acceptable
  end state.
- **The Enforced cluster is what the framework can currently defend.**
  This is the load-bearing claim a maintainer can make to a consumer
  without footnoting "trust us." Knowing exactly which claims sit in
  this bucket calibrates marketing prose, ADR confidence levels, and
  consumer-onboarding expectations.
- **The classification is itself the audit work** — enumerate canonical
  surfaces (doctrine files, README marketing claims, kernel rules,
  operating-principles, module declarations), tag each claim, and the
  classification output drives the next batch of structural-enforcement
  work. Re-evaluate on-change (any ADR touching doctrine; any new
  operating-principle entry; any new module added to the active catalog)
  and at a quarterly cap if no on-change trigger has fired.
- **The mechanism is reusable.** Any framework that exists to enforce
  something — governance harnesses, policy engines, contract checkers,
  compliance scaffolding — can run the same classification procedure
  against its own claims. Auto-harness ships the governance contract;
  consumer projects can apply this principle to their own honor-code
  surfaces.

**First applied** across four instances in the 2026-05-27 / 28 audit
sprint, documented in `docs/knowledge/shared-observations.md`:

- **Refresh-2 list-completeness audit** — narrow-scope precursor: the
  audit enumerated canonical-surface lists (ADRs, PRDs, OPPs,
  compositions, template-subdirs, profile-modules) and classified each
  catalog as Asserted (humans maintain) vs Enforced (a validator
  checks). Result: the Wave 1 validator (`validate-list-completeness.sh`)
  converted six Asserted-only catalogs into Enforced ones in one PR.
- **Wave 2b safety-security-sweep § 2** — framework-wide articulation:
  the sweep enumerated 19 load-bearing claims and classified each as
  Enforced (9), Half-enforced (3), or Asserted-only (7). The seven
  Asserted-only claims (claims 10–13, 15, 16) mapped directly to
  Wave 5's priority order in [ADR-0017](adr/ADR-0017-safety-hardening-roadmap.md)
  — the classification's output IS the roadmap.
- **Wave 5.1 mechanizing-doctrine discovery** — implementation-driven
  confirmation: the [PRD-0006](requirements/PRD-0006-trust-tier-enforcement.md)
  implementation surfaced PRD-internal inconsistencies that the design
  pass had elided (FR-002 + FR-003 + FR-005 cannot simultaneously hold
  for the kernel module). Mechanization is the first time prior
  Asserted-only contradictions are forced to resolve.
- **Wave 5.5 posture-design reflection** — discovery via design choice:
  authoring the WARN-posture validator
  ([OPP-0036](opportunities/OPP-0036-validate-knowledge-redaction.md))
  surfaced that *which* absorption mechanism (fix-on-impl / predict-clean
  / warn-defer) the implementing PR uses is downstream of how the claim
  was classified. The classification choice IS a design decision, not
  an implementation detail.

[OPP-0037](opportunities/OPP-0037-classify-before-enforcing-as-operating-principle.md)
is the design contract under which this section was promoted. The OPP
documents the four instances above, the §9 three-instance bar that
gated promotion, and the workflow shape (design-only OPP per § 9 +
half-day implementation per the project's no-PRD-for-half-day-OPP
pattern).

**When drafting an ADR, PRD, OPP, or new operating-principle entry,
ask:** *which load-bearing claims am I making, and what's each claim's
enforcement state?* Tag each as Enforced, Half-enforced, or
Asserted-only. The Asserted-only set is your follow-up OPP queue; the
Half-enforced set is your validator upgrade-path queue; the Enforced
set is what you can defend without footnote. Run this classification
during design — not after — so the audit work IS the design work.

## 11. Privacy by Design, by Default

The harness is built around **privacy by design** and ships it **on by default** to consumer
projects. The content spine is Cavoukian's seven Foundational Principles of Privacy by Design
(proactive not reactive; privacy as the default setting; privacy embedded into design; full
functionality / positive-sum; end-to-end security; visibility and transparency; respect for
user privacy). These are jurisdiction-neutral — the universal floor. The applicable *legal
regime* (GDPR, CCPA/CPRA, LGPD, PIPEDA, PIPL, …) is a consumer-declared choice made at
initialization, never assumed.

**Default-on, opt-out.** Every bootstrapped project activates `management/privacy-by-design`.
A project with genuinely no personal or sensitive data may opt out — but opt-out is explicit
and recorded (a `none`-regime exemption in `docs/privacy/privacy-profile.md`), never silent. If
data-handling later appears despite an exemption, the validator warns and prompts re-choosing
a regime.

**Layered enforcement.** The validator *warns* on privacy-risk patterns (advisory); companion
rules *enforce* that privacy artifacts update when data-handling paths change; review gates
*prevent* risky merges via required human sign-off. Privacy *outcomes* remain human-judged
(Asserted-only per §10); artifact presence and the data-handling companion rule are Enforced; risk-pattern detection is
Half-enforced.

This principle is the first cross-vertical reuse of the **deep governance vertical**
authoring skeleton codified in [§ 12](#12-author-deep-governance-verticals-from-the-shared-skeleton):
the same machinery that keeps `domains/healthcare-*` from assuming a jurisdiction keeps
privacy from assuming a legal regime. Privacy is one of the two cross-cutting *overlays*
(with `management/digital-twin`) that proved the skeleton generalizes off subject-matter
domains.

## 12. Author Deep Governance Verticals from the Shared Skeleton

A **deep governance vertical** is a focused, standards-anchored governance
capability layered onto the kernel — whether it governs a *subject-matter
domain* (healthcare, AEC, cybersecurity, geospatial) or a *cross-cutting
discipline* (privacy, digital twins). The harness has built five of them on **one
shared skeleton**, with a sixth (cybersec) designed against the same skeleton and
pending build. Author the next one *from* that skeleton — do not re-derive it —
and codify any extension back into this principle.

**The skeleton — six ingredients every deep governance vertical carries:**

- **Jurisdiction-neutral core.** The universal floor assumes no jurisdiction,
  legal regime, or standard *version*. The applicable specific is
  consumer-declared at initialization, never assumed (FHIR-neutral healthcare;
  ISO-19650-neutral AEC; Cavoukian's 7 as the neutral privacy floor).
- **One forcing artifact.** A single required file turns the vertical into a
  governed conformance question; it declares the consumer's specific choices and
  is what the validator reads (`jurisdiction-profile.md`, `twin-profile.md`,
  `spatial-reference-profile.md`, `privacy-profile.md`, the engagement-charter).
- **A default-deny bias guardrail.** You may not claim a maturity, conformance,
  or coverage your evidence does not support; emerging standards are cited as
  emerging, not ratified. Overclaiming is the failure mode the guardrail blocks.
- **Single-concern decomposition.** A family splits into focused sub-modules,
  each governing one seam, composed by `dependsOn` (`aec-{im, openbim, security}`;
  `geospatial-{foundation, exchange, georeference}`).
- **One of three composition shapes.** **Intra-family** (sub-modules depend
  within the family), **domain × cross-cutting overlay** (a domain composes with
  privacy or digital-twin), or **cross-family bridge** (a module depends across
  two families — `geospatial-bim-georeference` × `aec-openbim-exchange`).
- **A predict-clean, module-gated validator.** The vertical's machine enforcement
  no-ops when the module is inactive, so the harness's own CI is a clean pass and
  consumer CI honors it (the § 10 Half-enforced posture).

**Where domains and overlays diverge — the one documented difference.** A
cross-cutting *overlay* carries a **dual-spine** standards anchor: a technical /
interoperability spine *and* a governance-values spine (digital-twin =
interoperability standards + the Gemini Principles; privacy = data-protection
regimes + Cavoukian's 7). A subject-matter *domain* carries a single spine.
Everything else in the skeleton is identical across the two.

**The inclusion test — what is *not* a deep governance vertical.** A module is a
deep governance vertical only if it has a **neutral core + a forcing artifact + a
standards anchor**. Thin management overlays that lack these are not — and the
skeleton must not be over-applied to them. `management/work-package` is the
canonical negative case: it reuses only the predict-clean-validator ingredient
(a lane validator) and has no neutral core, forcing artifact, or standards
anchor, so it is a thin overlay, not a deep vertical.

**Proven across six applications of the skeleton** — five carried through to built
modules, comfortably clearing the § 9 three-instance bar: three subject-matter
domain families — `domains/healthcare-*`
([PRD-0017](requirements/PRD-0017-healthcare-fhir-smart-wedge.md)),
`domains/aec-*` ([PRD-0019](requirements/PRD-0019-aec-iso19650-openbim-wedge.md)),
`domains/geospatial-*` ([PRD-0024](requirements/PRD-0024-geospatial-gis-wedge.md)) —
and two cross-cutting overlays — `management/privacy-by-design`
([§ 11](#11-privacy-by-design-by-default)) and `management/digital-twin`
([PRD-0023](requirements/PRD-0023-digital-twin-scenario-runtime-overlay.md)). A
sixth — `domains/cybersec-*`
([PRD-0022](requirements/PRD-0022-cybersec-osint-maltego-wedge.md), designed; module
pending) — was authored *against* the skeleton at design time, evidence the
skeleton generalizes before a line of the module exists. The geospatial bridge
contributed the cross-family composition shape; the two overlays contributed the
dual-spine divergence.

[OPP-0049](opportunities/OPP-0049-deep-governance-vertical-harvest.md) is the
design contract under which this section was promoted. The skeleton was built
concrete-first (one vertical at a time) and harvested only after five built
instances (plus a sixth designed) — the same harvest-after-evidence discipline
§ 9 and § 10 followed. The OPP's Phase 3 ships the step-by-step authoring playbook
([`platform/workflow/deep-governance-vertical-authoring.md`](../platform/workflow/deep-governance-vertical-authoring.md));
this section is the doctrine the playbook implements.

**When proposing a new domain or cross-cutting overlay, ask:** *does it pass the
inclusion test (neutral core + forcing artifact + standards anchor)?* If yes,
author it from the six-ingredient skeleton, pick one of the three composition
shapes, and add the second spine if it is an overlay. If no, it is a thinner
module — build it as such, and do not borrow the vertical scaffold it does not
need. Either way, if the vertical needs a *seventh* ingredient or a *fourth*
composition shape, that extends this principle — record it here.
