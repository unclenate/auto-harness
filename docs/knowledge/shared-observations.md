# auto-harness — Shared Observations

**Structure:** Structured Template (see README.md § Observation Structure; locked by ADR-0002)
**Write Policy:** heartbeat-only (see README.md § Write Policy; adjustable)
**Last Updated:** 2026-05-22 *(hook adapter pass)*

Append-only structured observations from project participants (agents
and humans). Read this file on each heartbeat. Observations accumulate
here until distillation.

---

## Observations

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
