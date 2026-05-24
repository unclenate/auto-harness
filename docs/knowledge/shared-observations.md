# auto-harness — Shared Observations

**Structure:** Structured Template (see README.md § Observation Structure; locked by ADR-0002)
**Write Policy:** heartbeat-only (see README.md § Write Policy; adjustable)
**Last Updated:** 2026-05-24 *(brownfield onboarding catalog-gap observation — YouBase batch)*

Append-only structured observations from project participants (agents
and humans). Read this file on each heartbeat. Observations accumulate
here until distillation.

---

## Observations

### Brownfield onboarding is the harness's highest-leverage catalog-gap discovery mechanism

- **Context:** The first non-trivial *external* brownfield consumer to be
  put through the `harness-onboarding` skill (YouBase — a 2016-era Node +
  CoffeeScript cryptographic identity store, abandoned by its original
  company, ~600 LoC across 13 `.coffee` files, fork held by the
  auto-harness maintainer) produced a clean 5-section assessment but
  immediately surfaced *three* structural catalog gaps in a single pass:
  no stack module fit (the catalog has `node-typescript` and `python`
  only — neither matches plain Node-JavaScript or CoffeeScript); no
  data module fit (the catalog has relational/document/object-store —
  none matches LevelDB-class embedded key-value); no domain module fit
  (the catalog's `domains/web3` is Ethereum-specific — does not cover
  Bitcoin-style HD-wallet identity, DID/SSI primitives, or personal
  data stores). All three holes were caught by the skill's "Evidence
  only" + Conservative-module-selection rules behaving correctly —
  refusing to claim coverage that doesn't exist — which is exactly
  the right behavior, but it told the consumer "we don't have a
  category for you" three times in one assessment.
- **Observation:** Brownfield consumers exercise dimensions of the
  catalog that the self-dogfood cannot. Auto-harness's self-dogfood is
  a Ruby + Bash + Markdown project that never activates any stack,
  data, or domain module — so the self-dogfood validates the kernel
  + management + agents catalog but says *nothing* about whether the
  stacks/data/domains catalog covers reality. The first real external
  consumer immediately produced three concrete catalog additions
  (filed as OPP-0008, OPP-0009, OPP-0010) that no amount of
  self-dogfood could have surfaced.
- **Implication:** Brownfield-onboarding-as-discovery is structurally
  load-bearing for catalog completeness. Three near-term consequences:
  (1) the harness should treat every brownfield onboarding pass as a
  potential catalog-gap discovery event, not only as a consumer-
  service event; (2) the `harness-onboarding` skill's output (the
  Section 5 Risks and Open Questions block) already names catalog
  gaps explicitly — that surface should be promoted into a recurring
  *intake* for new OPPs rather than living only in the consumer's
  assessment document; (3) the dimensions the self-dogfood does not
  exercise (stacks, data, domains, architectures) deserve targeted
  *synthetic-brownfield* test passes — run the skill against several
  hypothetical-but-realistic consumer shapes (a Rust HTTP service, a
  Go monorepo, a Python ML pipeline, a Swift mobile app, an Electron
  app) and harvest the catalog gaps before real consumers hit them.
- **Confidence:** medium-high — the pattern is supported by one strong
  instance (YouBase produced three independent catalog hits in one
  pass) and one supporting analog (`bdits/municipal-brain` produced
  the canonical-position OPP and five sibling observations from its
  reconciliation handoff — also a not-self-dogfood discovery event).
  Generalization to "every brownfield pass yields ≥1 catalog gap"
  is untested but the underlying mechanism (consumer exercises catalog
  dimensions the maintainer doesn't) is structurally sound.
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-24

### Knowledge-capture module itself is an observation-worthy design

- **Context:** Designing the `management/knowledge-capture` module
  dogfooded in auto-harness itself. The choice of write policy,
  observation structure, and cadences was deliberately made adjustable
  at the project level (rather than hardcoded by the harness).
- **Observation:** Moving configuration out of the manifest schema and
  into the project's own `docs/knowledge/README.md` produced a cleaner
  design than extending the manifest. The policy lives where the data
  lives; git history is the durable configuration trail; no schema
  extension was needed.
- **Implication:** Future harness features that need per-project
  configuration should consider this pattern (config-in-artifact)
  before extending `harness.manifest.yaml`. Not every tunable belongs
  in the manifest.
- **Confidence:** medium — the pattern works for knowledge-capture but
  generalization to other cases is untested
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-04-16

### Two harness genres exist in the AI-coding ecosystem; auto-harness is unambiguously the governance-harness genre

- **Context:** Reviewing adenhq/hive (YC-backed multi-agent runtime harness) to determine whether auto-harness should integrate with, absorb, or remain separate from it. Hive is a runtime-harness (DAG execution, state recovery, MCP tools, dashboard for agents doing business work). auto-harness is a governance-harness (trust tiers, lifecycle gates, PRD/ADR templates governing AI-assisted human coding work).
- **Observation:** The word "harness" is doing double duty in this space: runtime-harness (Hive, LangGraph, CrewAI) is not the same as governance-harness (auto-harness). Both genres exist; both call themselves "harness." Hive's "evolve graph on failure" loop is exactly the kind of self-modifying agent behavior that benefits from human-approval gates and audit trails — the governance primitives auto-harness already encodes (trust tiers, lifecycle stages, companion rules, validators).
- **Implication:** auto-harness should not absorb Hive (different layer, scope bloat, license/cadence coupling) and should not integrate tightly (couples to one runtime's product direction). The latent product opportunity is to define an exportable governance contract — a consumable schema, skill, or protocol that any runtime harness (Hive, LangGraph, CrewAI, custom) can adopt to gate state transitions and self-modifications on human approval, with audit trails compatible with auto-harness's lifecycle artifacts. This keeps auto-harness composable with the runtime ecosystem rather than betting on one runtime. Filed as OPP-0001.
- **Confidence:** medium — the genre distinction is high-confidence; the "exportable contract" opportunity is medium-confidence and warrants validation by reading Hive's actual state-machine and self-modification entry points before committing.
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-12

### Companion-rule precision is best enforced by file boundaries, not regex sophistication

- **Context:** Issue #28 surfaced a class of companion-rule false-positive: the
  `management/opportunity-capture` README rule fired on any
  `docs/opportunities/README.md` edit, even pure organizational
  (cluster-heading / `OPP-NNNN` line-item) changes. Three upstream
  resolutions were considered: (a) section-aware triggers (heading-scoped
  regex inside the file), (b) `acceptedAlternative` field for project-local
  ratifying ADRs, (c) file split — move the candidate index to a sibling
  `docs/opportunities/candidates.md` and scope the rule to README only.
- **Observation:** Option (c) won by aligning the file boundary with the
  change-class boundary the rule wanted. The other options either added
  regex complexity that generalizes nowhere (a) or codified perpetual
  exemption as a first-class governance primitive (b). After the split, no
  validator-engine change was needed — the regex layer continued to work
  as designed because the artifact it gated now only contains the change
  class it cares about.
- **Implication:** When a companion rule needs more precision, prefer
  reshaping artifacts so file boundaries match change-class boundaries
  over teaching the validator about substructure. The companion-rule
  machinery's value is the simplicity of regex-over-paths; preserving that
  simplicity scales better than per-rule renderer-aware diff parsing. If a
  regex can't separate two change classes within one file, that's a signal
  the artifact is doing too much, not that the validator needs more brains.
- **Confidence:** medium — one decision, but the rejected alternatives
  were both seriously considered and the file-split rationale generalizes
  to similar precision problems
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-20

### Consumer-driven feedback has displaced the scheduled-review cadence as the active quality mechanism

- **Context:** Two consumer-filed issues in three days followed an identical
  shape: #24 (stale validator CLI signatures in `harness-governance` skill,
  surfaced in `bdits/municipal-brain` after PRs #15/#22 changed validator
  surface) and #28 (companion-rule false-positive on README index edits,
  also surfaced in `bdits/municipal-brain`). Both issues were filed with
  precise reproduction steps, a local workaround already in place, and 2–3
  proposed upstream resolutions with explicit tradeoffs. Both were
  merged within hours. Meanwhile, the scheduled-review cadence declared
  in `docs/knowledge/distilled-learnings.md` (set 2026-04-16, target
  2026-04-30) never fired — five weeks past, no team review held; the
  honest staleness sits in the file as governance debt.
- **Observation:** The dogfooding loop — consumer hits friction → files
  issue with proposed fix → upstream tightens module + docs within hours —
  is producing higher-signal learning than the scheduled-review pattern
  the knowledge-capture module assumes. Consumer-discovered issues are
  about *live friction* with real user models; scheduled-review distillation
  is about *latent drift*. For a solo-maintained framework with active
  consumers, the consumer loop appears to be the dominant quality engine.
- **Implication:** Two possible directions worth weighing: (a) retire the
  scheduled-review cadence in favor of an event-driven distillation
  pattern (e.g., distill after every consumer-issue closure once a
  threshold of N is reached); (b) keep the cadence but hold the review
  even when the docket feels thin — the discipline of distilling is more
  valuable than the size of any particular batch. Either is a deliberate
  choice; the current state (declared cadence quietly going untriggered)
  is the worst option because it makes the docs lie about how this
  project actually learns.
- **Confidence:** medium — two consumer-issue data points fit the
  pattern, but generalization to N>1 consumers is untested. The cadence-
  vs-event-driven choice is genuinely open.
- **Severity:** process
- **Contributed by:** @unclenate via Claude Code, 2026-05-20

### Companion-rule machinery was already most of the gap-closer for distillation

- **Context:** Designing PRD-0004's v1 mechanism for cycle-end
  distillation triggers. OPP-0004 enumerated three candidate shapes
  (passive validator, active agent-tool hook, hybrid). When sketching
  the passive piece, mapped its pseudocode against the existing
  `validate-companions.sh` machinery to see what new validator code
  would be needed.
- **Observation:** No new validator code was needed. The companion-rule
  machinery — framed in module docs as enforcing "audit trail on
  destination edits" — cleanly handles "distillation trail on source
  triggers" by reversing trigger/satisfier semantics inside the existing
  regex-over-paths model. The harness's existing primitives were more
  powerful than the docs claimed they were. Three of OPP-0004's three
  design shapes turned out to be expressible in current primitives;
  what was missing was a *missing artifact* (a rule entry, a workflow
  doc, a hook config), not *missing machinery*.
- **Implication:** When designing a new harness capability, audit the
  existing primitives first by writing the new contract in pseudocode
  and trying to map it to existing fields. The harness's primitives
  (modules, validators, companion rules, hooks, skills, workflows) are
  highly composable but their reach is undersold in current docs.
  Building new machinery should be the last resort, not the first move.
  This argues for periodic "what can the existing primitives already do
  that we haven't tried?" passes alongside the gap-discovery work.
- **Confidence:** high — verified during the PRD-0004 draft by writing
  the rule in pseudocode and seeing it map directly to existing
  `companionRules` fields with no engine change
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-22

### Maintainer "I thought that was already happening" is the highest-signal gap-discovery pattern

- **Context:** Conversation immediately post-PR-#30 merge (the docs pass
  capturing two observations + operating-principles § 7). The maintainer
  flagged distillation triggers as a gap with: *"I was assuming that my
  harness projects were doing this already and it's a core function."*
  That single statement promoted what would have been a low-priority
  backlog item to OPP-filed-and-PRD-drafted-the-same-day priority.
- **Observation:** *Assumed-features-as-gaps* are qualitatively
  different from the other gap classes this project has produced (audit-
  discovered drift, missing-tests, refactoring opportunities,
  consumer-issue-filed friction). They represent the gap between (a)
  the project's mental model of itself and (b) what the project actually
  does. They are nearly invisible until pointed at because both reader
  and writer assume the feature exists. When discovered, they are
  usually load-bearing precisely because the assumption that they exist
  has been actively relied on — by the maintainer in design decisions,
  and downstream by any consumer reading the same docs.
- **Implication:** Treat *"I thought X was already working"* as P0
  signal in this project. The assumption itself is the evidence: if a
  load-bearing function is assumed-to-exist by its own maintainer,
  downstream consumers will silently rely on it too. Gap-mining
  technique: periodically scan recent conversation logs and module
  README prose for phrasings like *"the harness ensures..."*, *"agents
  read X on each heartbeat..."*, *"distillation happens at..."*, and
  audit whether the named mechanism actually exists as machinery vs.
  documentation-as-aspiration. (The "heartbeat with Knowledge
  Contribution step" prose was a textbook case before PRD-0004
  formalized it.)
- **Confidence:** medium — one strong data point in this session;
  pattern needs more instances to confirm generalization, but the
  signal-quality argument is structural and the cost of treating
  false-positives as P0 is small relative to the cost of missing real
  load-bearing assumptions.
- **Severity:** process
- **Contributed by:** @unclenate via Claude Code, 2026-05-22

### Distillation triggers can land without bootstrap exception when the introducing PR carries genuine learning

- **Context:** PRD-0004 § Risks anticipated that the implementation PR
  landing the new cycle-end distillation companion rule on
  `management/knowledge-capture` would need the
  `overrides.disabledValidations` escape hatch for one merge — since the
  new rule's trigger set includes `^platform/profiles/.+/module\.yaml$`,
  and the PR landing the rule itself modifies a module.yaml. The plan
  was: disable for one merge, enforce thereafter.
- **Observation:** The escape hatch was not needed. The PR landing the
  rule naturally included multiple genuine distillations — the
  pre-merge manual-distillation pass on PR #32 carried two architectural
  /process observations, the workflow doc itself surfaced
  heartbeat-prose-formalization as a captured decision, and the
  implementation produced this entry as its own meta-observation about
  self-stabilization. The PR satisfied its own new rule by construction
  rather than by exception. The pattern: when a new companion rule is
  itself substantial enough to warrant distillation, the
  trigger-rule-firing-on-itself problem resolves without exception
  machinery.
- **Implication:** Bootstrap-exception machinery (`overrides.
  disabledValidations`) is a safety net for *routine* rule introductions
  (e.g., adding a triggerPath to an existing rule, tightening a regex)
  — not the default mode. Valuable governance machinery is structurally
  harder to bootstrap *because* it's valuable: the rule's own
  introduction is itself the kind of work the rule wants distilled, so
  the satisfier is naturally available. Treat the override as the rare
  case; expect new rules with genuine architectural weight to satisfy
  themselves.
- **Confidence:** medium — one instance; pattern needs more
  rule-introduction cycles to confirm. But the logic chain (valuable
  rule → real architectural learning → naturally available distillation
  in the same diff) is structurally sound and worth treating as a
  default assumption.
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-22 (implementation pass)

### Paired-mechanism implementation is a free correctness check on the governance side of the pair

- **Context:** Implementing PRD-0004 FR-006/FR-007 — the Claude
  Code Stop-hook adapter (`distillation-prompt.sh`) intended to remind
  agents in-session of cycle-end distillation. The hook's trigger-detection
  logic was written to mirror the companion rule's `triggerPaths` regex,
  so the in-session reminder and the PR-boundary floor would fire on the
  same change classes. To do this faithfully, the hook script ran the
  rule's exact pattern against `git diff --name-only main...HEAD` and
  inspected the matched paths.
- **Observation:** Writing the second mirror of the pattern immediately
  surfaced a scope bug in the first. The companion rule shipped in PR
  #33 with `^platform/profiles/.+/module\.yaml$` — which covered only
  modules under `platform/profiles/` and silently missed the 8
  agent-pack modules under `platform/agents/*` and the kernel module at
  `platform/core/kernel/base/module.yaml`. The bug was invisible while
  the rule existed alone; it became obvious the moment a *second* piece
  of machinery was written to exercise the same pattern and the author
  had to enumerate which modules the hook should fire on. Fix was a
  one-character broadening to `^platform/.+/module\.yaml$`, applied in
  four places (rule, hook regex + comment, workflow doc table, skill
  table).
- **Implication:** Paired mechanisms (validator + hook, lint + fixer,
  schema + migration) are not just convenience or DRY artifacts — the
  act of writing the second mirror is a structural correctness check on
  the first. When designing governance machinery, consider building the
  in-session adapter early *even if* the validator could ship alone,
  precisely because the adapter forces a different code path through
  the same predicate. The bug class this catches — silently-narrow
  triggers — is exactly the failure mode regex-over-paths is most prone
  to (passes its own tests because they were written against the same
  narrow assumption). A sibling pattern to property-based testing,
  applied to governance regex.
- **Confidence:** medium — one strong data point in this session, but
  the discovery dynamic (forced enumeration during adapter
  implementation surfaces narrow patterns) is structurally sound and
  generalizes to any pair where the second member must independently
  re-derive what the first matches.
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-22 (hook adapter pass)

### Harness primitives that don't compose toward the consumer-side surface are silent governance gaps

- **Context:** Diagnosing the maintainer-flagged template-header
  inheritance problem (filed as OPP-0005). Auto-harness has two
  pre-existing primitives that *together* would close the gap entirely:
  `platform/bootstrap/add-license-headers.sh` (inserts SPDX/copyright
  headers, idempotent) and `platform/validators/validate-placeholders.sh`
  (fails CI on unfilled `[[…]]` patterns). The header script is
  scoped to auto-harness's own tree; the validator already enforces
  token-fill discipline on consumer projects.
- **Observation:** Neither primitive was composed with the templates
  or with the consumer's bootstrap flow, so a real governance gap (61
  template files shipping with wrong attribution; consumers inheriting
  UncleNate's headers into their own ADRs/PRDs) persists despite the
  capability to close it existing in the repo. The harness's existing
  primitives are individually correct but unconnected at the
  consumer-side boundary. This is a different shape from "missing
  machinery" — it's *available machinery that nobody pointed at each
  other*. The OPP-0004 lesson ("audit existing primitives before
  building new") applies in reverse here: existing primitives can also
  fail by not being *composed*, not only by not being *reached for*.
- **Implication:** When scanning for governance gaps in this project,
  ask both questions: "is there machinery for this?" *and* "is the
  machinery composed with the consumer-side surface where the gap shows
  up?" The second question is easier to miss because reading the
  validator code and reading the template code in isolation each look
  fine. The bug lives in the *negative space between them*. Suggests
  a periodic audit pass: enumerate primitives × consumer-touchpoints
  and check each cell for composition. The same pattern almost
  certainly recurs elsewhere — e.g., do the agent-pack adapters compose
  with the kernel's trust-tier prompts on consumer projects, or is each
  side individually correct in isolation? Worth a follow-up audit.
- **Confidence:** medium — one instance in this diagnosis, but the
  *shape* (primitive A + primitive B both exist; consumer-side surface
  C needs A∘B; nothing composes them) is structural and likely to
  recur. The discovery technique (look for capabilities-that-exist-but-
  don't-meet) generalizes beyond headers.
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-22 (OPP-0005 filing)

### PRD drafts surface questions the originating OPP successfully elided — the OPP→PRD pipeline is a discipline, not a redundancy

- **Context:** Drafting PRD-0005 (consumer header hygiene) immediately
  after OPP-0005 was filed. OPP-0005 enumerated four design options
  (A/B/C/D), expressed initial bias toward A+B, and listed six open
  questions for the PRD pass — appearing thorough.
- **Observation:** Writing the PRD forced commitments on questions the
  OPP had successfully elided. The OPP asked "should SPDX be tokenized
  too?" without answering. The OPP asked "config file vs. per-prompt?"
  without answering. The OPP framed module placement as a multiple-
  choice question. Each only resolved when the PRD had to specify
  concrete machinery — at which point the answer was forced by the
  shape of what was being specified. Tokenizing SPDX *only became
  obvious* once we wrote out the example header block and saw that
  leaving SPDX literal means consumers default to MIT/Apache when their
  license intent might differ. Config-file-vs-prompt *only became
  obvious* when we wrote the bootstrap flow and saw that per-prompt
  forces re-asking on every template-copy. These weren't decisions the
  OPP could have made cheaply; they required the PRD's design pressure.
- **Implication:** The OPP→PRD pipeline isn't a paperwork chain — each
  document type applies a different kind of design pressure. OPPs ask
  "is this a real gap and what's the design space?" PRDs ask "what
  specific machinery resolves the gap?" Questions that look settled
  at OPP-time turn out to be open at PRD-time, and the gap-resolution
  *requires* both passes. This is consistent with the PRD-0004
  observation that *"writing the second mirror of a regex pattern forces
  re-derivation that catches silent narrowness in the first"* — but
  generalized from validator pairs to document pairs. Sibling pattern:
  paired *documents* are a free correctness check the same way paired
  *mechanisms* are. Suggests resisting the temptation to skip the PRD
  for "obvious" cases — the document's job is precisely to surface
  what's not obvious.
- **Confidence:** medium — one instance in this session (PRD-0005), but
  pattern is consistent with PRD-0004's experience (PRD took positions
  on all six OPP-0004 open questions, several of which only had
  defensible answers once the implementation surface was specified).
  Two consistent data points in two cycles.
- **Severity:** process
- **Contributed by:** @unclenate via Claude Code, 2026-05-22 (PRD-0005 draft pass)

### Header-token classes split cleanly along project-wide vs. per-record axis

- **Context:** Shipping PRD-0005 v1 (consumer header hygiene). The
  initial scope assumed all `[[…]]` tokens in templates were
  symmetric — fill once and you're done. The bootstrap helper design
  forced a question: should `set-consumer-headers.sh` fill *every*
  uppercase token it finds, or only a subset?
- **Observation:** Two distinct token classes emerged, splitting along
  a clean axis: *project-wide* tokens (`YEAR`, `OWNER_NAME`,
  `OWNER_EMAIL`, `SPDX_LICENSE`, `PROJECT_NAME` — using the bracketed
  `[[…]]` form in templates) appear in every template's SPDX/copyright
  header block and have the same answer for every artifact in the
  project; *per-record* tokens (`OWNER`, `OPP_TITLE`, `ADR_TITLE`,
  `RISK_DESCRIPTION`, and others) appear in template bodies and have a
  *different* answer for each instance.
  Filling per-record tokens at bootstrap time would be actively wrong
  (every ADR would name the same owner; every risk would have the same
  description). The bootstrap helper's scope must respect the axis: fill
  exactly the project-wide set and leave everything else for the
  per-artifact author. The `validate-placeholders` regex (`[A-Z0-9_]+`)
  treats both classes identically, so the distinction has to be enforced
  by the *substituter*, not the *validator*.
- **Implication:** When introducing a token-based system across multiple
  artifact types, two questions matter from day one: (1) what's the
  axis along which tokens divide? (2) which tool fills which class?
  Both answers need to live in the documentation alongside the token
  list, otherwise consumers will reach for the bootstrap helper and
  expect it to fill everything. Captured in `platform/templates/README.md`
  as the "two classes of token" callout. Generalizes: any future
  tokenized surface (e.g., agent-pack metadata, MCP server-spec
  templates) should declare its token classes up front and name which
  tool owns each class.
- **Confidence:** medium — one design instance (PRD-0005 v1), but the
  pattern (token sets need a class taxonomy or the substituter
  misbehaves) is structurally sound and likely recurs anywhere
  templates carry both universal and per-instance fields.
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-22 (PRD-0005 implementation pass)

### Each new artifact asserting a catalog count is a new place that fact can drift

- **Context:** Building the documentation visualization pass — six
  Mermaid diagrams in `docs/architecture/diagrams.md` plus front/back
  SVG covers. The diagrams cite `35 modules · 7 validators · 7 skills ·
  56 templates · 14 workflows`; the back-cover SVG cites the same
  numbers; the diagram's "Modules" node has `35 total in-tree` baked
  into its label; `platform/reference/how-to-read.md` already cited the
  numbers in prose AND in an ASCII-art authority-stack illustration.
- **Observation:** Before this PR, the catalog counts lived in
  *exactly one* mostly-correct place (`how-to-read.md` line 10) plus a
  drifted copy two pages down (the same file's ASCII art said `55
  templates · 13 workflows` while the prose said `55 / not-mentioned`,
  and the actual counts were 56 / 14). After this PR, the counts also
  live in (a) the back cover SVG, (b) the diagram-1 module-count
  annotation, and (c) the diagrams.md "Editing These Diagrams"
  guidance. We *added three new copies* of facts that drift.
  Visualizations are powerful precisely because they re-state the same
  data in a more digestible form — but the re-statement is replication,
  and replication has a maintenance cost. The documented count
  recipe at the top of `how-to-read.md` (HTML comment with `find …
  | wc -l` invocations) saved us once today; nothing similar exists for
  the back-cover counts or the diagram annotations.
- **Implication:** When introducing a new artifact that asserts a fact
  asserted elsewhere, *write down where the canonical copy is and how
  to recompute it*. Better, encode the recipe inline so any future
  reader can verify. Even better, build CI assertion that the counts
  match (e.g., a `validate-catalog-counts.sh` validator that diffs
  documented claims against `find | wc -l`). Until such a validator
  exists, the human discipline is: when bumping a count anywhere,
  grep for the old value across the repo and bump every occurrence in
  the same PR. Treat catalog claims like API contracts — each call
  site is a coupling that must be maintained. Worth elevating to
  operating-principles if the drift recurs in a future audit.
- **Confidence:** medium — the drift dynamic is structurally sound
  (replication → drift) but the specific recommendation (count
  validator) hasn't been built, so its effectiveness is speculative.
  The discipline part (grep on bump) is high-confidence and immediately
  actionable.
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-22 (visualization + QA pass)

### Governance machinery that asserts against state-including-itself creates a free first-run self-test

- **Context:** Shipping `validate-catalog-counts.sh`. Adding the
  validator script bumps the `validators` canonical count from 7 to
  8. The validator's first run reads its own filesystem state (which
  now includes itself), computes the new canonical count (8), and
  compares to documented claims (which still say 7 across four call
  sites until this PR updates them). The validator catches the drift
  it just caused. Identical structural dynamic to PRD-0004's Stop-hook
  catching the companion rule's regex-scope bug (PR #34) and to
  PRD-0005's templates dogfooding `validate-placeholders.sh` against
  the harness's own tree (PR #38).
- **Observation:** When a new piece of governance machinery is
  introduced and the machinery happens to assert against state that
  *includes the machinery itself*, the act of introducing it produces
  a free first-run self-test — because the machinery, before any docs
  are updated, is checking documented claims that haven't caught up to
  reality. This is a distinct dynamic from "paired mechanisms catch
  each other's bugs" (PR #34's observation): there, two separate
  artifacts cross-validated each other on introduction. Here, *one*
  artifact validates a system-including-itself. Three instances now
  (hook + rule, validator + templates, validator + own count) suggest
  this is a reliable structural property: machinery whose contract
  references repo-wide facts is self-stabilizing because the
  introducing diff necessarily exercises the new contract.
- **Implication:** When designing governance primitives, prefer the
  shape *"validator/check that asserts against entire-repo state"*
  over *"validator that asserts against a fixed-scoped subset that
  excludes itself."* The former gets a first-run self-test for free;
  the latter needs separate test infrastructure to verify it works.
  Applied dimensions: count assertions across all docs (catalog
  validator), regex coverage over all paths (placeholder validator),
  doc-reference resolution across all markdown (doc-references
  validator). Generalizes to: any check whose scope is *"the whole
  repo"* will, by construction, be exercised by its own introducing PR.
- **Confidence:** medium → high — three independent data points across
  three different mechanism types (hook adapter, template tokenization,
  validator-asserting-its-own-count) in this session alone. Pattern is
  structurally sound and the cost of the design choice is essentially
  zero (just *not* artificially scoping the check away from the new
  artifact's neighborhood).
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-23 (catalog-counts validator)

### Doctrine in prose without enforcement in code is a recurring harness gap pattern

- **Context:** Detailed quality + capability audit (this session,
  2026-05-23). Two parallel exploration agents enumerated documentation
  gaps and missing capabilities. Synthesizing the findings revealed a
  shape that recurs across multiple distinct gaps.
- **Observation:** The harness has shipped strong machinery for some of
  its claims — companion rules turning trigger paths into CI gates,
  catalog-counts validator turning prose claims into asserted facts,
  cycle-end distillation hook turning aspirational "heartbeat" prose
  into actionable triggers — but a parallel set of *equally
  load-bearing claims* remains pure documentation. The audit named at
  least four:
  - **Trust tier model** (kernel/base/trust-model.md) — six tiers of
    agent autonomy with explicit auth-required-or-not rules. PR template
    has manual checkboxes. Zero machine-checked enforcement; no module
    schema field declares tier; no validator catches escalation.
  - **Versioning** — CHANGELOG.md is "Unreleased" forever; no git tags
    exist; maintenance docs reference hypothetical `v0.2.0`. Consumers
    pin to commit hashes, defeating semver entirely.
  - **Knowledge curation** — distillation *triggers* are machinery (PR
    #34), but *promotion to distilled-learnings* and curation-vs-
    accretion of operating-principles remain workflow prose only. No
    sample project demonstrates the end-to-end curation cycle.
  - **Consumer module operations** — adding / removing / changing
    modules in an active manifest is governed by zero machinery; the
    only operational doc is "pulling upstream changes."

  The shape across all four: the harness has *named* the discipline but
  not *built* the contract. Where the harness has built the contract,
  drift is structurally bounded; where it hasn't, drift accumulates as
  honor-code violation.
- **Implication:** When auditing the harness for completeness, the
  highest-yield prompt is *"name a discipline this project claims; is
  there machinery that asserts the claim?"* The audit produced four
  Wave-3 candidates this way (versioning, trust-tier enforcement,
  knowledge curation, module operations) — each one is the same gap
  shape applied to a different surface. Worth elevating the technique to
  operating-principles as a recurring audit discipline if a future audit
  produces additional candidates. For shipping decisions, the pattern
  argues for prioritizing machinery-of-claim over additional prose
  documentation when both are options for closing a gap; prose is
  cheaper to produce but the gap stays open.
- **Confidence:** medium — four data points in one audit, but the
  *shape* (claim made, machinery absent) generalizes cleanly. The
  technique is structurally sound; effectiveness depends on whether the
  enumeration of "claims the harness makes" is comprehensive enough.
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-23 (audit synthesis)

### Inference-with-declaration-override is the right shape for opt-in governance enforcement

- **Context:** Drafting PRD-0006 (trust-tier enforcement). OPP-0006
  enumerated five design options (A: optional schema only; B:
  required schema + migration; C: inferred with override; D:
  companion-rule level; E: hybrid of A + sensitivePaths inference).
  The PRD-design pressure forced commitment to one.
- **Observation:** When mechanizing existing-but-unenforced governance
  doctrine, the *opt-in additive schema + inference fallback* pattern
  (Option E) wins consistently over the alternatives. The reasoning
  chain:
  - Required schema breaks every existing module — high-friction
    migration cost for marginal additional safety
  - Optional schema alone leaves legacy modules permanently outside
    enforcement — silent coverage gap that grows over time
  - Inference alone is opaque (users don't know why their module
    flagged as high-tier) — surprising and brittle
  - Inference-with-declaration-override gives all parties the right
    affordance: legacy modules covered by inference; new modules can
    declare; declaration always wins when present (no surprise); the
    inference rules are public contract (no opacity)

  The general shape: *opt-in machinery for the migration path,
  inference for the legacy coverage, declaration-wins for the
  ergonomic surface*. This pattern recurred in PR #41
  (validate-catalog-counts) where the inference was implicit recipes
  and the declaration was the documented numeric claim, and in PR #38
  (consumer header hygiene) where the declaration was the
  `.harness-headers.yaml` config and the inference was *which tokens to
  fill* (header-only, not per-record).
- **Implication:** When mechanizing the remaining doctrine-without-
  enforcement gaps identified by the 2026-05-23 audit (knowledge
  curation workflow, consumer module operations, release versioning),
  apply the same shape: inference-with-declaration-override. For
  knowledge curation specifically: infer promotion candidates from
  observation severity + repeat-count patterns; allow explicit
  curator declarations to override. For consumer module operations:
  infer required follow-up artifacts from module dependencies;
  allow explicit overrides for cases where the inference is wrong.
  The pattern generalizes; the audit's findings can be addressed
  with a coherent design vocabulary rather than ad-hoc solutions per
  gap.
- **Confidence:** medium — three instances now (catalog-counts,
  header hygiene, this PRD's bias toward Option E). The pattern is
  structurally sound but the trust-tier implementation hasn't shipped
  yet — Option E's effectiveness for *this* gap remains
  hypothetical until v0.6.0 lands.
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-23 (OPP-0006 + PRD-0006 drafting)

### Validator opt-out has no staleness pressure

- **Context:** `bdits/municipal-brain`'s `harness.manifest.yaml` carried
  `disabledValidations: [required-artifacts]` and `requiredArtifacts: []`
  set 2026-05-13 "for the discovery phase." That opt-out persisted
  silently for 9+ days across multiple workflow cycles (firm-name sweep,
  intake docx pipeline, Phase 0 build-readiness skeletons, OS partnership
  v2.0 rework, intake re-pre-fill passes). The project moved through
  Phase 0 build-readiness without any harness mechanism nudging that
  the opt-out had outlived its rationale. Only an explicit
  human-driven materials-alignment review (MB-REV-002 § 4) caught it.
  See `bdits/municipal-brain` at commit `ff953c1`:
  `docs/reviews/2026-05-22-materials-alignment-review.md`, the
  pre-repair `harness.manifest.yaml`, and the repair commit `ff953c1`.
- **Observation:** Validator opt-out (`overrides.disabledValidations`,
  empty `requiredArtifacts`) has no built-in staleness pressure. The
  harness honors the override correctly but provides no signal when
  the override has outlived its original rationale. The override is
  bound to *the original reason* (e.g., "discovery phase"), not to the
  project's *current state*. As the project matures, the opt-out
  becomes silent drift; nothing surfaces it. The failure class is
  recoverable but only by an out-of-band human audit — which is exactly
  the kind of work the harness exists to make unnecessary.
- **Implication:** Treat validator opt-outs as time-bound: require a
  short rationale (or a citation to the canonical-position section, per
  OPP-0007) at the time the override is set, and emit a low-priority
  warning on every validator run that names the override age and
  rationale. Stronger version: a companion rule that fires when an
  override has persisted N days beyond the project's last maturity
  flip, asking for an explicit reconfirmation or revocation. Even
  stronger: tie the override's basis to the canonical-position artifact
  so it auto-invalidates when that artifact materially changes. The
  goal is to make "set-and-forget overrides" structurally hard to do.
- **Confidence:** high — the failure played end-to-end in a real
  consumer project; the mechanism gap is structural and unambiguous,
  and the same opt-out shape is available to every harness consumer
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-22 (municipal-brain reconciliation handoff)

### Opportunity-capture has no backlog-reconciliation trigger when the canonical direction changes

- **Context:** `bdits/municipal-brain` filed OPP-0001 through OPP-0024
  between 2026-05-13 and 2026-05-18. The canonical direction then
  changed substantially via the BDITS-000 ratification on 2026-05-22.
  After ratification, OPP-0020 was manually flagged superseded; OPPs
  0001..0018 (the bulk of the backlog) remained at `proposed` status
  with their original framing intact, but most of them no longer
  reference live concepts — the v4 platform thesis, the cycle-time
  wedge, and the Microsoft-first stack they presumed are all archived.
  The harness fired no rule on this state; the backlog drift sits as
  silent inconsistency. See `bdits/municipal-brain` at commit
  `ff953c1`: `docs/opportunities/OPP-00{01..18}-*.md` (framing predates
  BDITS-000) vs. `docs/BDITS-000-canonical-position.md` (the new
  canonical reference).
- **Observation:** The opportunity-capture module ships a per-record
  floor rule (audit-trail entry on each OPP edit) and a same-commit
  PRD promotion contract for accepted candidates, but has no mechanism
  that fires when a *global* canonical direction changes. Each OPP is
  treated as independent; the backlog has no concept of "the basis on
  which we filed these candidates has shifted." After a canonical
  reset, the backlog increasingly disagrees with itself, requiring a
  separate manual audit pass to triage which candidates remain viable,
  which are superseded, and which need re-framing.
- **Implication:** Opportunity-capture should carry a
  "canonical-direction-change → backlog re-audit" discipline. Most
  cleanly composes with OPP-0007 (canonical-position artifact): when
  the canonical-position artifact is materially revised, a companion
  rule fires demanding either a re-audit log entry in the change-log
  (lightweight satisfier — *"the backlog was walked; N candidates
  reconfirmed, M superseded, K re-framed"*) or, more strictly, an
  explicit status review on every existing OPP. The re-audit itself
  could be a checklist artifact (similar to the proposed review /
  reconciliation type — Observation C below). Without this, the
  backlog asymptotically becomes a museum of retired thinking.
- **Confidence:** high — 24 OPPs of which roughly 18 are now framing-
  stale; the failure is quantitative and the mechanism gap is structural
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-22 (municipal-brain reconciliation handoff)

### No formal review / reconciliation artifact type — and the ad-hoc one proved high-value

- **Context:** The `bdits/municipal-brain` reconciliation produced four
  review artifacts in four days (MB-REV-001 plan-vs-call-record
  reconciliation; MB-REV-002 planning improvement review, four-lens;
  MB-REV-003 project alignment audit, four-lens; MB-REV-004 materials
  alignment review). They landed in an ad-hoc `docs/reviews/` folder
  with no harness template, no naming convention beyond a date-prefix,
  topic slug, and an `MB-REV-NNN` ID, and no companion rules.
  Despite the ad-hoc structure, MB-REV-001/002/003 directly drove the
  BDITS-000 canonical position ratification, and MB-REV-004 produced
  the four remediation actions (M-1..M-4) that closed out the materials
  drift. They were the highest-value documents produced in the
  reconciliation window after BDITS-000 itself. See `bdits/municipal-
  brain` at commit `ff953c1`:
  `docs/reviews/2026-05-22-project-alignment-audit.md` (one example).
- **Observation:** The harness has ADR / PRD / OPP / change-log /
  knowledge — five durable artifact types — but no formal *review*
  artifact. ADRs document decisions; reviews document the *audit that
  produces* a decision. They are different artifact classes: an ADR
  commits to a course of action; a review surfaces gaps, scores
  artifacts against criteria, and proposes remediations. Without a
  formal review type, projects either (a) skip the audit step and let
  drift accumulate (the failure mode `bdits/municipal-brain` hit
  *before* MB-REV-001..004), or (b) invent the artifact ad-hoc (the
  failure mode it hit *after* — the reviews work but their place in
  the lifecycle is unowned).
- **Implication:** Formalize a review artifact type, likely as an
  addition to `management/project-standard` or as a new lightweight
  overlay (`management/review-cadence`?). Template needs: ID convention
  (per-project prefix similar to `MB-REV-NNN`), lens / dimension
  structure (the four-lens shape proved valuable), verdict-per-
  artifact table, remediation actions with `M-NNN` identifiers, and a
  Companion field linking to the canonical-position artifact
  (OPP-0007). Cadence may be event-driven (file when drift suspected)
  and/or scheduled. The natural pair: the canonical-position artifact
  is revised *by* a review proposing the revision; the two artifact
  types compose into a coherent strategic-direction lifecycle.
  `program-template/governance-cadence.md` (if it exists) may be the
  scheduling home for the cadence side.
- **Confidence:** high — four reviews in four days produced load-
  bearing outputs; the gap in the harness's artifact catalog is
  structural and reproducible across long-running projects
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-22 (municipal-brain reconciliation handoff)

### Discovery-intake treats the intake as one-shot; canonical-direction-changed → intake-stale path is missing

- **Context:** `bdits/municipal-brain`'s intake questionnaire was
  pre-filled three times in nine days. The 2026-05-13 first pre-fill
  was against the v4 stack + OPP-0001..0018. The 2026-05-21 second
  pre-fill wove in OPP-0019..0024 (filed since the first pre-fill). The
  2026-05-22 third pre-fill was a full re-pre-fill required because the
  second pass still carried v4 framing that the canonical position
  (BDITS-000) had retired. Three pre-fill passes; the first two were
  architecturally trapped because when the canonical direction
  changed, the existing pre-fill became stale silently and the only
  way to recover was to re-do the work. See `bdits/municipal-brain` at
  commit `ff953c1`: `docs/discovery/intake-questionnaire.md` (current
  third-pass state) + the three corresponding 2026-05-22 / 2026-05-21
  / 2026-05-13 change-log entries documenting each pass.
- **Observation:** The `discovery-intake` module treats the intake-
  questionnaire as a one-shot artifact: pre-filled, OPEN markers
  resolved, downstream artifacts produced. There is no harness-level
  model of *"the canonical direction changed → this intake's framing
  is now stale."* The intake does not declare *which canonical
  position it was filled against*; there is no companion rule that
  fires when the canonical position changes and the intake hasn't been
  re-pre-filled since. Each pre-fill pass is a one-shot human-triggered
  event with no harness continuity.
- **Implication:** Tie the intake to the canonical-position artifact
  (OPP-0007). Concretely: add a required header field to the intake
  template — *"Filled against: `<canonical-position-artifact-path>`
  @commit `<SHA>`"* — captured at pre-fill time. Add a companion rule:
  when the canonical-position artifact's content (not just metadata)
  changes after the intake's recorded SHA, the intake's Status header
  should flip to `stale-canonical-direction-changed` (or similar),
  surfacing the need to re-pre-fill. This composes with the review
  artifact type (Observation C): a review can propose a canonical-
  position revision, which automatically flags the intake stale,
  which triggers re-pre-fill — all visible to the harness instead of
  requiring out-of-band human triggers.
- **Confidence:** high — three pre-fill passes in nine days is a
  quantitative measure of the gap; the mechanism gap is structural and
  identical for every long-running planning project
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-05-22 (municipal-brain reconciliation handoff)

### Three positive patterns from a heavy-load reconciliation worth promoting to harness conventions

- **Context:** The `bdits/municipal-brain` reconciliation ran roughly
  11 commits in 4 days across two repos, multiple Cowork ↔ Claude Code
  handoffs, and a four-lens audit. Three patterns held up under load
  and are worth promoting from project-local habit to harness
  convention, before they fade. See `bdits/municipal-brain` at commit
  `ff953c1`: `docs/project/change-log.md` (entire 2026-05-22 cluster),
  `docs/archive/ARCHIVE-INDEX.md`, and the post-reconciliation manifest
  state.
- **Observation:** Three patterns:
  1. **The change-log as commit-grouping spec.** The Cowork → Claude
     Code session handoff used "one commit per change-log entry" as
     the literal commit-boundary instruction. The change-log isn't
     just a record — it became an active coordination contract
     between authors and committers, with each entry's
     `What changed` directly becoming the commit's body. This worked
     cleanly across 6 dependency-ordered commits.
  2. **Companion-rules discipline held under heavy load and caught
     real misses.** The kernel/base rule fired on a new `scripts/`
     addition demanding a change-log entry; the opportunity-capture
     README rule had previously caught cluster-update edits that
     warranted ratification — both were *real* governance signals,
     not noise. The discipline never had to be bypassed across the
     entire reconciliation.
  3. **Salvage-before-archive + ARCHIVE-INDEX.** Before archiving the
     pre-v4 planning iterations, valuable content was extracted into
     the live corpus (MB-RES-CC-005 absorbed the v2 traceability
     matrix; the OS working-session-invitation template absorbed the
     v3.1 outreach memo). An `ARCHIVE-INDEX.md` records what each
     archived document was and what superseded it. Both decisions —
     salvage-before-archive *and* maintain an index — proved high-
     value during and after the reconciliation: nothing was lost; the
     archive remained navigable.
- **Implication:** Promote the three patterns to harness conventions:
  1. The change-log format already exists in `project-standard`. Add
     an explicit note (in `platform/profiles/management/project-
     standard/README.md` or a new `platform/workflow/change-log-as-
     commit-spec.md`) that entries should be commit-grouping-ready,
     and codify the "one entry = one logical commit" pattern as the
     supported handoff format for multi-session work.
  2. Companion-rules discipline is structurally encoded already; the
     observation is positive — preserve the regex-over-paths
     simplicity (per the file-boundary-as-precision discipline of
     ADR-0012) and resist adding sophistication that would make
     compliance harder. This is a "do not regress" observation, not
     a new feature.
  3. Add an `archive-discipline.md` workflow doc (or extend
     `docs/operating-principles.md`): when retiring artifacts,
     salvage valuable content into the live corpus first; then move;
     then maintain `ARCHIVE-INDEX.md` in any archive directory.
     Optionally promote `docs/archive/ARCHIVE-INDEX.md` to a
     recognized optional artifact for `kernel/base` or
     `project-standard`. The index is the natural place for the
     supersession chain a future reader needs to reconstruct project
     history without spelunking git log.
- **Confidence:** high for patterns 1 and 3 (observed under load with
  load-bearing outcomes); medium for the broader generalization to
  other projects, but the patterns are structurally sound and worth
  the cheap experiment of promoting them
- **Severity:** process
- **Contributed by:** @unclenate via Claude Code, 2026-05-22 (municipal-brain reconciliation handoff)

### Anchor-OPP-and-satellite-observations is a stronger filing shape than disconnected OPPs

- **Context:** Drafting PRD-0007 (canonical-position artifact)
  surfaced that OPP-0007 was originally filed not in isolation but
  as the *anchor* for four sibling observations (A, B, C, D in
  `shared-observations.md` 2026-05-22, plus a process-pattern
  observation E). Each sibling's proposed resolution explicitly
  depends on OPP-0007's canonical-position primitive existing first.
  This structure made PRD-0007's scoping materially easier than
  prior PRDs: the OPP's design space was framed by *which siblings
  to bundle into v1 vs. defer*, not by *what to even propose*.
- **Observation:** Filing observations as a *constellation around an
  anchor OPP* — the anchor proposes the central primitive; each
  satellite observation names a dependent gap that the primitive
  unlocks — produces better PRD scoping than filing each gap as an
  independent OPP. Three structural advantages:
  - **Composition discipline at PRD-time.** The PRD must explicitly
    decide which satellites bundle into v1 vs. defer. Forced
    composition decisions surface the right v1 scope (PRD-0007:
    bundle Observation C's review-artifact because ratification
    depends on it; bundle Observation E's patterns as cheap
    operating-principle additions; defer A, B, D — each has its
    own substantive scope and prerequisite).
  - **Backlog coherence.** Independent OPPs that turn out to be
    related get filed without the relationship being explicit; the
    backlog reads as parallel gaps. Anchor-satellite makes the
    dependency tree legible.
  - **Deferred follow-ups inherit context.** When Observations A,
    B, D become their own OPPs (post-PRD-0007 acceptance), they
    cite OPP-0007 as prerequisite and carry the prior framing.
- **Implication:** When filing observations from a heavy
  reconciliation pass (or any work surfacing multiple related
  gaps), explicitly identify the anchor gap and file it as an OPP
  with satellite observations naming the dependents. Resist filing
  each gap as its own OPP — that loses the structural relationship
  that makes the PRD pass tractable. Worth elevating to
  operating-principles if a second instance confirms the shape
  (PRD-0004's distillation-triggers work had some of this shape —
  heartbeat-formalization + cycle-end + audit-trail rules — but
  wasn't filed as a constellation; could have been).
- **Confidence:** medium — one strong instance (this PRD-0007
  drafting pass) but structural argument is sound. The technique
  requires filing-time discipline (recognize the anchor; name the
  satellites) that may not be available when observations are
  written rapid-fire. PRD-0007's case worked because the
  maintainer authored the OPP + five observations together.
- **Severity:** process
- **Contributed by:** @unclenate via Claude Code, 2026-05-24 (PRD-0007 drafting pass)
