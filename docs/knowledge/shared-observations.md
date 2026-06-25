# auto-harness — Shared Observations

**Structure:** Structured Template (see README.md § Observation Structure; locked by ADR-0002)
**Write Policy:** heartbeat-only (see README.md § Write Policy; adjustable)
**Last Updated:** 2026-06-24 *(PRD-0026 (publication-boundary marker, OPP-0048 wedge): backlog triage (3 independent ranking passes over 19 open OPPs) converged on OPP-0048 as highest risk×readiness; filed PRD-0026 ratifying mechanism 1 — an always-on kernel-level `validate-publication-boundary.sh` that fails CI/pre-commit if any GIT-TRACKED file declares a `do-not-publish` marker (no name corpus needed; invisible while the file stays untracked); flipped OPP-0048 proposed→accepted; staged mechanism 2 (configurable content-denylist scan-scope) as a named phase-2 follow-up. Appended the observation that a publish-time gate is the INVERSE of `requiredArtifacts` (a must-NOT-be-tracked assertion), and that on-disk reality disproved the simpler directory-glob design — `docs/superpowers/specs/` holds TEN already-tracked published specs beside the ONE untracked unpublishable brief, so publication intent is a per-FILE property, not a per-directory one. Satisfies the PRD-0004 distillation rule fired by the modified OPP-0048. Prior: 2026-06-24 OPP-0049 Phase 3 (deep-governance-vertical authoring playbook): shipped `platform/workflow/deep-governance-vertical-authoring.md` — the step-by-step playbook §12 references (Step 0 inclusion-test gate, six build steps one-per-ingredient, a worked-examples matrix, the composition-shape + dual-spine decisions, a catalog-wide propagation checklist, a definition of done); flipped OPP-0049 Phase 3 → done; propagated the workflow count 22→23 across four prose sites + the SUMMARY row. The same pass corrected operating-principle §12's "built six" to the accurate **five built + one designed (cybersec, PRD-0022)** — authoring an accurate playbook surfaced that cybersec is designed-not-built on disk (no `domains/cybersec-*` module, no `validate-engagement-charter.sh`), a non-validator PROSE drift the catalog-count and list-completeness validators cannot see because cybersec was never counted as a module. Satisfies the PRD-0004 distillation rule fired by the modified OPP-0049. Prior: 2026-06-20 OPP-0049 (deep-governance-vertical authoring-pattern harvest): filed the design-only OPP that harvests the six-times-proven authoring skeleton (jurisdiction-neutral core + forcing artifact + default-deny bias guardrail + single-concern decomposition + one of three composition shapes + predict-clean module-gated validator) into a §12 operating principle (Phase 2) and an authoring playbook (Phase 3); meta-template deferred (Phase 4). Appended the observation that the skeleton generalizes across BOTH subject-matter domain families and cross-cutting discipline overlays — the inclusion test is neutral-core + forcing-artifact + standards-anchor, which is exactly what separates a deep governance vertical (healthcare/AEC/cybersec/geospatial/privacy/digital-twin) from a thin management overlay (work-package, the negative case, reuses only the predict-clean validator); overlays additionally carry a dual-spine anchor (interoperability standard + values framework) where domains carry one. Satisfies the PRD-0004 distillation rule fired by the new OPP-0049. Prior: 2026-06-19 PRD-0013 IMPLEMENTATION (session-shape workflow doc, origin OPP-0032): shipped `platform/workflow/session-shape.md` — the session-boundary checkpoint taxonomy + the six-class trigger taxonomy + the audit of declared-but-unfired reviews; flipped OPP-0032 → accepted and PRD-0013 → Accepted; appended the observation that all five currently-FIRED declared reviews are PR-boundary (companion rules) while every declared-but-UNFIRED review wants one of the other five trigger-classes the harness has on paper but never built. Satisfies the PRD-0004 distillation rule fired by the modified OPP-0032. Prior: 2026-06-19 PRD-0025 IMPLEMENTATION (Phase 2): shipped the `management/work-package` module + `validate-lane-integrity.sh` (validator chain 17→18) + lane template + idempotent worktree runbook + sample composition + diagram #16, catalog-only / predict-clean (the harness does not activate the module, so the new validator no-ops on the harness's own CI); appended the observation that a diff-checking validator stays cheaply fixture-testable by separating the diff-SOURCE (git, in main mode) from the diff-CHECKER (a pure function over an explicit changed-path list) — `--scan-file <spec> [path...]` exercises the exact lane-vs-diff logic CI runs without standing up a live branch. Satisfies the PRD-0004 distillation rule fired by the new `platform/profiles/management/work-package/module.yaml`. Prior: 2026-06-17 OPP-0048 (redaction-scope & publication-boundary hardening): filed the OPP-0036 follow-up after the 2026-06-17 GitBook / documentation pass re-confirmed a live gap — a public repo parks **untracked** private design material under `docs/superpowers/specs/` (excluded from both the placeholder validator and markdownlint) with zero publish-time gate, guarded today only by agent memory and manual `git add` discipline; appended the observation that the redaction primitive needs a file-level `do-not-publish` **blocking** marker (which requires no name corpus) plus a configurable wider-scope content scan, because per-file git-add discipline does not scale across a shared-identity multi-agent workspace. Satisfies the PRD-0004 distillation rule fired by the new OPP-0048. Prior: 2026-06-15 PRD-0025 promotes OPP-0046's lane wedge as `management/work-package` (design-only); flipped OPP-0046 → accepted (partial promotion) in the same PR; appended the observation that two tightly-coupled OPPs promote best as one module with staged phases — combine the home, sequence the depth — not two modules or two PRDs. Satisfies the PRD-0004 distillation rule fired by the modified OPP-0046. Prior: 2026-06-15 OPP backlog hygiene reconciliation: flipped six OPPs (0006/0033/0034/0036/0037/0045) + PRD-0006/0015 from proposed/exploring to accepted to match shipped reality; appended the observation that OPP/PRD status is un-validated prose that drifts after every implementation wave, the flip belongs in the implementing-PR checklist, and this is the live evidence for a backlog-review cadence (OPP-0032). Satisfies the PRD-0004 distillation rule fired by the six modified OPP files. Prior: 2026-06-15 OPP-0047 (delivery-cost & unit-economics governance): appended the observation that delivery cost is a new governance axis (economics) attaching to the same work-package unit OPP-0046 defines — lane = scope contract, cost record = economic contract — and follows the govern-the-contract-not-the-extraction boundary. Satisfies the PRD-0004 distillation rule fired by the new OPP-0047. Prior: 2026-06-15 OPP-0046 triage (#121 + #122 → parallel multi-agent work-package lane contract): appended the observation that the WP lane is the multi-agent analog of the module declare-then-enforce contract, and that shared-observations.md is already an emergent cross-agent memory bus. Satisfies the PRD-0004 distillation rule fired by the new OPP-0046. Prior: 2026-06-14 Geospatial / GIS wedge IMPLEMENTATION (Phase 2, PRD-0024): shipped three modules + four templates + diagram #15 + the 4-way geospatial-bim-twin composition catalog-only / predict-clean; appended the observation that the first cross-family dependsOn resolved with zero validator changes (a bridge module is a pure composition of existing primitives). Satisfies the PRD-0004 distillation rule fired by the three new module manifests. Prior: 2026-06-13 Geospatial / GIS deep-domain wedge design (OPP-0045 + PRD-0024): appended the observation that a deep-domain vertical can govern a seam between two domains via a cross-family module dependency — generalizing the harness composition model into a three-shape taxonomy (intra-family / domain×overlay / cross-family bridge) — and that the CRS forcing artifact adds a temporal axis to the jurisdiction-profile primitive. Satisfies the PRD-0004 distillation rule fired by the new OPP-0045. Prior: 2026-06-10 Issue #88 sensitivePaths catalog audit: folded every uncovered sensitivePath across seven modules into its own companion triggerPaths (self-coverage, generalizing PR #114), added the disabledValidations escape hatch to validate-sensitive-paths.sh, and gated the class by running the validator over shipped compositions in CI; appended the catalog-wide self-coverage observation. Satisfies the PRD-0004 distillation rule fired by the seven modified module.yaml files. Prior: 2026-06-10 privacy-by-design self-coverage fix: added `^auth/`, `^src/.*user`, and `tracking` to the module's own `companionRules.triggerPaths` so its WARN-layer `sensitivePaths` are self-enforced at the VALIDATE layer rather than relying on another active module to cross-cover them (which `validate-sensitive-paths` overlap-checking silently permitted); appended the observation naming the ambient-cross-coverage masking failure mode and the self-coverage principle. Satisfies the PRD-0004 distillation rule fired by the modified `platform/profiles/management/privacy-by-design/module.yaml`. Prior: 2026-06-10 Digital Twin overlay Phase 2: PRD-0023 implementation — module + 10 templates + 2 Half-enforced WARN validators + skill + composition + discoverability + count propagation shipped catalog-only/predict-clean; the two module-gated validators no-op on the harness's own CI; the dual-spine anchor is now concrete in templates. Prior: 2026-06-10 Digital Twin overlay Phase 1: OPP-0044 + ADR-0019 + PRD-0023 design contract; appended the observation that the deep-domain primitives generalize to a SECOND cross-cutting discipline overlay (after privacy-by-design), and that a twin-governance overlay needs a dual-spine anchor — interoperability/digital-thread standards plus a governance-values framework — to make planning→operational transformation a governed conformance question. Satisfies the PRD-0004 distillation rule fired by the new `docs/opportunities/OPP-0044-digital-twin-scenario-runtime.md` and `docs/adr/ADR-0019-digital-twin-scenario-runtime-overlay.md`. Prior: 2026-06-09 cybersec wedge (OPP-0043 + PRD-0022); 2026-06-07 greenfield conservatism (PRD-0021); 2026-06-06 bootstrap hardening (PRD-0020); 2026-06-05 onboarding safety + install prerequisites; 2026-06-04 AEC wedge Phase 2; the OPP-0038 attribution-boundary observation; and consumer-adoption observations from the fork-held-consumer pin-bump session.)*

Append-only structured observations from project participants (agents
and humans). Read this file on each heartbeat. Observations accumulate
here until distillation.

---

## Observations

### A publish-time gate is the inverse of a required artifact — and publication intent is a per-file property, not a per-directory one

- **Context:** OPP-0048's thin wedge (PRD-0026) needed a machine check that the
  parked, untracked Digital-Twin seed brief under `docs/superpowers/specs/` can
  never be accidentally committed to this public repo. The intuitive first design
  was a directory "never-track" glob (`docs/superpowers/specs/**`).
- **Observation:** That design is wrong on contact with disk. `git ls-files
  docs/superpowers/specs/` returns **ten already-tracked, legitimately-published**
  design specs (healthcare, AEC, privacy, cybersec, digital-twin, geospatial, …)
  sharing the directory with the **one** untracked unpublishable brief. A directory
  rule false-positives on all ten. Publication intent is therefore a **per-file**
  property, and the correct primitive is a per-file `do-not-publish` marker matched
  against `git ls-files` — which also needs no corpus of private names (the OPP's
  stated goal) and stays invisible while the file is untracked (its steady state).
- **Implication:** The check is the **inverse of `requiredArtifacts`** — a
  "must-NOT-exist-in-the-tracked-tree" assertion rather than a "must-exist" one,
  and it belongs as an **always-on kernel safety validator** (like
  `validate-placeholders`), not a predict-clean module-gated overlay: a leak gate
  that only fires when a module is active would miss the very repos that never
  activate it. The same shape generalizes — declare an intent on the artifact,
  enforce it by tree membership.
- **Severity:** Medium — the live risk it closes is high (irreversible public leak
  in a shared-identity multi-agent workspace), but the wedge is small.
- **Contributed-by:** Claude (OPP-0048 / PRD-0026 session, 2026-06-24)

### Authoring an accurate playbook is itself an audit — it surfaced merged-doctrine prose drift no validator can see

- **Context:** OPP-0049 Phase 3 ships the deep-governance-vertical authoring
  playbook, whose value depends on a *worked-examples matrix* citing each
  vertical's real on-disk artifacts (module dirs, forcing-artifact paths,
  validators). Building that matrix from disk — not from the PRD index — forced a
  per-vertical existence check.
- **Observation:** The check found that operating-principle § 12 (merged one
  cycle earlier in #135) claimed the harness had **"built six"** verticals and
  listed `domains/cybersec-*` among "four subject-matter domain families." But
  cybersec is **designed, not built**: PRD-0022 is `Proposed`, and there is no
  `domains/cybersec-*` module, no templates, and no `validate-engagement-charter.sh`
  anywhere on disk. The honest count is **five built + one designed**. Every
  validator passed throughout — `validate-catalog-counts` and
  `validate-list-completeness` are self-consistent precisely *because* cybersec
  was never counted as a module; the overstatement lived only in narrative prose,
  which no regex guards.
- **Implication:** A "worked example must cite a real artifact" constraint is a
  cheap, high-yield audit of the doctrine it elaborates — write the elaboration
  *from disk* and divergences from the abstract claim fall out. This is the
  non-validator cross-doc-consistency class (Copilot + holistic review catch it;
  validators do not); fold the correction into the same PR that surfaced it so
  doctrine and elaboration ship consistent. The fix preserved § 12's argument
  (five built still clears the § 9 three-instance bar) and *strengthened* it: a
  vertical designed cleanly against the skeleton before any module exists is
  evidence the skeleton generalizes at design time.
- **Severity:** Medium — corrected in-PR; the lesson (elaborate from disk to
  audit the abstraction) is the durable takeaway.
- **Contributed-by:** Claude (OPP-0049 Phase 3 session, 2026-06-24)

### The deep-governance-vertical skeleton is one pattern across domains and overlays; the inclusion test is what separates it from a thin overlay

- **Context:** Filing OPP-0049 required deciding what the "deep-domain pattern"
  actually *is* after six built instances — four subject-matter domain families
  (healthcare, AEC, cybersec, geospatial) and two cross-cutting discipline
  overlays (privacy, digital-twin). The naïve framing ("how to build a domain
  vertical") under-claims: `operating-principles.md` § 11 already calls privacy
  "the first cross-vertical reuse of the deep-domain pattern," so the pattern had
  visibly jumped off domains two overlays ago.
- **Observation:** The six instances share one skeleton — jurisdiction-neutral
  core, a single forcing artifact, a default-deny bias guardrail, decomposition
  into single-concern sub-modules, one of three composition shapes, and a
  predict-clean module-gated validator. Domains and overlays differ in exactly
  one documented place: overlays carry a **dual-spine** standards anchor (an
  interoperability/technical spine *and* a governance-values spine), where domains
  carry one. The skeleton is therefore best named for the superclass — a **deep
  governance vertical** — not for domains alone. Crucially, the pattern has a
  sharp **inclusion test**: neutral-core + forcing-artifact + standards-anchor.
  The work-package lane (`management/work-package`) is the negative case — it has
  none of those and reuses only the predict-clean-validator ingredient, so it is a
  thin management overlay, not a deep vertical.
- **Implication:** A codified pattern needs its boundary as much as its body. The
  §12 doctrine this OPP promotes must state the inclusion test so the skeleton is
  not over-applied to every new module; the negative case (work-package) is the
  cheapest way to teach the boundary. This also reframes the harvest target: the
  playbook is "how to author a deep governance vertical (domain or overlay)," and
  the one branch in it is single- vs dual-spine. Naming the superclass now avoids
  a future overlay author failing to find a domains-only playbook.
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-06-20

### The harness built one of six trigger-classes; every dormant review wants one of the other five

- **Context:** PRD-0013 (origin OPP-0032) shipped `session-shape.md`, whose FR-004
  audit catalogs every *declared review process* in the codebase and classifies
  each as fired (some automation triggers it) or unfired (declared in prose,
  nothing fires it). The audit was exhaustive — grep across module READMEs,
  workflow docs, skills, and operating-principles.
- **Observation:** The fired and unfired sets split cleanly by **trigger-class**.
  All five currently-fired declared reviews (cycle-end distillation + four
  audit-trail/ADR rules) are **PR-boundary** — they hang off a companion rule
  checked by `validate-companions` on a PR diff. PR-boundary is the *only* one of
  the six trigger-classes the harness has actually built. Every declared-but-
  unfired review — the operating-principles promotion scan, the second-pass
  brownfield onboarding, the knowledge-tree back-pressure audit, the periodic §10
  doctrine audit — wants one of the **other five** classes (session-, time-,
  count-, audit-, or external-event-boundary), which exist only on paper. A review
  is not dormant because the harness "lacks primitives" in the abstract; it is
  dormant because the *specific* trigger-class it needs was never implemented.
- **Implication:** The follow-up work the taxonomy points at is not "write more
  companion rules" — companion rules are the one solved class. It is to build the
  missing trigger-class primitives (a session-end hook, a scheduled-CI cadence, a
  count-threshold check) and hang the dormant reviews off them. The cheapest wins
  are the reviews that can borrow the session-boundary or audit-boundary class via
  an agent-skill prompt (no new infra), which is why the advisory sequencing in
  `session-shape.md` front-loads the onboarding-prompt and promotion-scan reviews.
  This also explains *why* the `distilled-learnings` surface died (ADR-0014): it
  depended on a time-boundary cadence that was never built, and the harness had no
  time-boundary class to hang it on.
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-06-19

### A diff-checking validator stays fixture-testable by splitting the diff-source from the diff-checker

- **Context:** `validate-lane-integrity.sh` (PRD-0025, `management/work-package`)
  enforces that a dispatched agent's changed files stay within its declared
  lane (`allowedFiles` / `readOnlyFiles`). The natural implementation reads the
  branch diff via `git diff --name-only <base>...HEAD` — which sounds like it
  requires standing up a live branch with real commits to test, making fixtures
  expensive and the out-of-lane path under-covered.
- **Observation:** The validator avoids that by separating the **diff-source**
  from the **diff-checker**. The checker is a pure function over `(lane spec,
  explicit changed-path list)`; main mode's only extra job is to *produce* that
  list from git. The `--scan-file <spec> [changed-path...]` seam feeds the list
  directly, so cheap fixtures exercise the identical lane-vs-diff logic CI runs
  — in-lane → pass, out-of-lane → fail, readOnly-touched → fail — with no git
  repository at all. This generalizes the established validator test-seam
  pattern (a `--scan-file` mode that bypasses manifest enumeration) to a
  *stateful* validator whose state is a git diff: make the stateful input an
  explicit argument, and the same code path serves both the real run and the
  fixture.
- **Implication:** Any future validator that checks a project against a
  computed-from-environment input (a diff, a dependency tree, a build manifest)
  should take that input as an explicit argument in a test mode, not read it
  only from the live environment. The environment read becomes a thin adapter
  over a pure, fixture-testable core. The lane validator is also the first
  *Enforced* (not WARN) module-gated validator whose enforcement is a function
  of the diff rather than the presence/shape of a single artifact.
- **Severity:** architectural
- **Contributed by:** @unclenate via Claude Code, 2026-06-19

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
  data, or domain module — so the self-dogfood validates the kernel +
  management + agents catalog but says *nothing* about whether the
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

### Two consumer projects converged on the stack-catalog breadth gap within 24 hours

- **Context:** OpenEMR brownfield onboarding session 2026-05-24
  produced a gap analysis at the consumer's
  `docs/knowledge/harness-coverage-gap-analysis.md`. § G1 identifies
  no `stacks/php` module as a blocker for substantive canonization
  work. Independently, PR #49 (merged 2026-05-24, from a YouBase
  brownfield onboarding by the maintainer) authored OPP-0008
  identifying no `stacks/node-javascript` module as the same blocker.
- **Observation:** Two independent consumer projects, two different
  languages (PHP and Node-JS-without-TS), hit the *same structural
  pattern* within the same 24-hour window: the harness-onboarding
  skill's "Evidence only" rule correctly refuses to activate
  `stacks/node-typescript` for non-TS Node projects (or `python` for
  non-Python projects), leaving the proposed composition's `stacks/*`
  section empty. The composition still validates, but a significant
  fact about the consumer (it has a primary stack) is unrepresented.
- **Implication:** The harness's stack catalog breadth — not its
  catalog mechanics — is the load-bearing brownfield-onboarding
  issue. Two consumer onboardings hitting the same gap from
  different language angles is strong signal that *every*
  brownfield onboarding outside the two pre-built stacks will hit
  it. OPP-0008 (Node-JS, YouBase) and OPP-0011 (PHP, OpenEMR)
  together justify a coordinated "fix the stack catalog breadth"
  PRD pass rather than two parallel ones. Filing convergent OPPs
  with explicit cross-reference is the constellation-filing
  technique from the municipal-brain handoff (see prior
  observation), applied across consumer projects rather than within
  one.
- **Confidence:** high — two independent instances with identical
  structural shape
- **Severity:** architectural
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-24 (OpenEMR canonization)

### Module sizing's hidden axis is consumer-audience granularity

- **Context:** OpenEMR canonization 2026-05-24. Initial gap-analysis
  draft proposed a single `domains/healthcare-ehr` module to cover
  OpenEMR's healthcare surface. Deeper subsystem inspection
  re-shaped the proposal into a decomposed 12-sub-module family
  (`domains/healthcare-fhir`, `-hl7v2`, `-smart-on-fhir`, `-ccda`,
  `-eprescribing`, `-cdr`, `-cqm`, `-phi-encryption`, `-audit-log`,
  `-direct-messaging`, `-ehi-export`, `-patient-portal`) plus an
  optional convenience composition for projects that implement the
  full stack.
- **Observation:** The coarseness gap surfaced as soon as the
  hypothetical downstream consumer was named: a project building a
  FHIR-only client does not need ePrescribing artifacts; a project
  building HL7 v2 integration does not need patient portal
  artifacts. A single `healthcare-ehr` module would have forced
  every consumer to inherit *every* other consumer's required-
  artifact debt. The granularity decision is not "how big a unit
  governs cleanly?" — it is "what subset of artifacts does a
  typical consumer actually need activated?" The latter forces
  per-concern decomposition; the former tolerates bundling.
- **Implication:** The harness's module sizing principle should
  explicitly account for consumer-audience granularity as the
  primary axis. Bundling artifacts a typical consumer does not
  need is module-debt that downstream projects pay forever; the
  cost is invisible at module-design time and compounds with each
  consumer onboard. Worth elevating to operating-principles if a
  second instance confirms (the OPP-0013 healthcare-family
  decomposition is one instance; a similar decomposition pressure
  may surface on the in-flight OPP-0010 cryptographic-identity
  domain from YouBase, which faces analogous "is this one module
  or a family?" tension).
- **Confidence:** medium-high — strong single instance with a
  clear structural argument; a second instance would lift to high
- **Severity:** architectural
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-24 (OpenEMR canonization)

### Second instance confirms: brownfield-as-catalog-gap-discovery; standardizing the gap-analysis output is the next move

- **Context:** Observation at top of this file (*"Brownfield
  onboarding is the harness's highest-leverage catalog-gap discovery
  mechanism"*, YouBase, 2026-05-24) named the pattern from one strong
  instance with confidence medium-high. The OpenEMR canonization
  pass earlier the same day is the second instance: a clean
  brownfield onboarding that surfaced 20 catalog gaps in a single
  pass (gap analysis at the consumer's
  `docs/knowledge/harness-coverage-gap-analysis.md`; OPPs 0011–0017
  filed against it the same day).
- **Observation:** Both consumer onboardings — YouBase and OpenEMR,
  filed within the same UTC day — produced gap analyses *as
  byproducts of the onboarding work*. The agent could not complete
  the assessment task without surfacing the gaps, because the
  catalog's "Evidence only" + Conservative-module-selection rules
  forced explicit "no module fits" declarations every time the
  consumer's reality exceeded catalog coverage. The shape of the
  output (Section 5 Risks and Open Questions; numbered gap items;
  direct mapping from gap → potential OPP) is repeatable across
  both sessions. The cost to the harness is near-zero — the
  onboarding session was going to run anyway; the gap analysis
  came along for free.
- **Implication:** Confirms the YouBase observation's confidence
  toward "high" — two independent instances with identical
  productive yield is the bar that distinguishes pattern from
  anecdote. The YouBase observation's named near-term consequence
  #2 (promote the Section 5 surface into a recurring OPP intake)
  becomes the actionable next step. The OpenEMR session's gap
  analysis was sized for direct upstream extraction precisely
  because the agent treated it as that recurring intake even
  before the skill formalizes it. The `harness-onboarding` skill
  should ship that surface as a *standard* output artifact
  alongside the lite manifest and the assessment — the OpenEMR
  session is structural evidence for what that artifact looks
  like (`harness-coverage-gap-analysis.md` is the proof-of-concept).
- **Confidence:** high (lifted from YouBase's medium-high after this
  second instance)
- **Severity:** governance-relevant
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-24 (OpenEMR canonization)

### Third brownfield instance surfaces a *second* gap class: delivery-topology breadth for agent-native products

- **Context:** YouBase and OpenEMR (both 2026-05-24) converged on
  **stack/data catalog breadth** — a Node-not-TypeScript stack, a PHP
  stack, embedded key-value, relational-SQL generalization. The third
  external brownfield pass the same day — Tula (`github.com/unclenate/tula`
  fork), an OpenClaw personal-health-agent skill pack — is plain
  Node/TypeScript, which the catalog already handles. Yet it produced five
  new OPPs (0018..0022) plus an augmentation of the OpenEMR healthcare
  family. The gaps were not about *language* or *storage*; they were about
  how the product is **built, gated, and shipped**: the unit of product is
  an authored, eval-gated skill pack deployed to an agent runtime
  (OPP-0018), gated by binary LLM evals rather than percentage coverage
  (OPP-0019), shipped as single-user self-hosted OSS (OPP-0021). The
  catalog's conventional layers (node-typescript, web-app, product-lite,
  the dev-agent packs) described Tula's *surface* perfectly; the miss was
  concentrated entirely in its *delivery topology*.
- **Observation:** Catalog-gap discovery has (at least) two distinct axes,
  and they are surfaced by different consumer kinds. *Legacy / polyglot*
  brownfields (YouBase, OpenEMR) exercise **stack/data breadth**.
  *Agent-native* products (Tula) exercise **delivery-topology breadth** —
  the catalog has rich coverage of apps and services but thin coverage of
  the agent-native production model (authored skill pack, eval gate,
  self-hosted runtime). A corollary surfaced in the same session: the
  harness's enforcement surface is entirely *structural* (markdown/YAML/Bash
  validators) and has no *behavioral* gate — it cannot check whether an
  agent skill does what it claims or does so safely. The maintainer named
  the inbound move directly: make evaluation/safety tooling (Waza, the GAIA
  benchmark, the UK AI Safety Institute's Inspect) *components* of the
  harness toolchain, not merely things it is aware of (OPP-0020), as the
  inbound complement to OPP-0001's outbound governance export.
- **Implication:** (1) The next catalog-breadth investment after the
  YouBase/OpenEMR stack work is **agent-native delivery**, not more language
  stacks — and the harness's own `recommendedSkills` blocks already assume a
  skill-pack ecosystem the catalog does not yet govern producing. (2) The
  `harness-onboarding` skill's module catalog should grow an
  `architectures/agent-skill-pack` family once OPP-0018 is shaped, since
  agent-native consumers will recur. (3) Behavioral gating (OPP-0020) is the
  harness's most-cited absent capability and is now evidence-backed by a
  working consumer CI (`.waza.yaml` + eval-status workflow) — it is a
  generalize-the-wiring problem, not a greenfield one. (4) Synthetic-
  brownfield test passes (proposed in the YouBase observation) should add an
  *agent-native* shape (a skill pack, an MCP server, a self-hosted agent
  runtime) to the language/framework shapes already suggested, so this axis
  is exercised before the next real consumer hits it.
- **Confidence:** medium-high — one strong instance for the *agent-native*
  axis (Tula), but the axis is reinforced by the harness's own dependence on
  a skill ecosystem it does not govern, and by an explicit maintainer
  priority signal on the behavioral-gating corollary.
- **Severity:** architectural
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-24 (Tula onboarding)

### Healthcare catalog evidence is US-centric — guard against baking US health-system assumptions into module shapes

- **Context:** The harness's healthcare coverage (OPP-0013 family, OPP-0015
  regulated-compliance, OPP-0016 specialist skills, and now OPP-0022
  patient-agent safety) is grounded in exactly two consumers, both American:
  OpenEMR (ONC certification, HITECH, HIPAA, US Core, Inferno G10) and Tula
  (Epic MyChart, HIPAA §164.526 amendment law, US Core, US patient-access /
  Cures Act framing). The maintainer flagged this directly during the Tula
  pass: there is a real risk of baking the cultural and economic assumptions
  of the **US** health system — its payer model, its certification regime,
  its consent and amendment law, MyChart as the canonical patient portal,
  US Core as the canonical profile — into module shapes as if they were
  universal, and an intent to seek healthcare consumers from Europe, the
  Near East, and the Far East to correct it.
- **Observation:** The bias is structural, not incidental. FHIR *core* is an
  international HL7 standard, but the artifacts a US-grounded onboarding
  naturally reaches for (US Core profiles, ONC G10 conformance, HIPAA
  citations, MyChart UX assumptions) are US-realm-specific. A healthcare
  module family frozen on US-only evidence would encode US regulatory and
  economic structure into its required artifacts, forcing every
  international consumer to either misrepresent their context or carry
  irrelevant US artifact debt — the same "forced bundling" failure mode
  OPP-0013's module-sizing observation already names, but along a
  *jurisdictional* axis rather than a capability axis.
- **Implication:** (1) Healthcare module artifacts must be designed around
  *concepts* that hold cross-jurisdiction (red-flag triage, draft-not-send,
  patient-as-resource-owner, audit/breakglass, encryption-at-rest), with
  realm-specific law carried as *fill-in references* (HIPAA, GDPR/EHDS
  rectification rights, etc.), never hard-coded. (2) The non-diagnostic
  stance must not encode a single jurisdiction's medical-device or liability
  framing. (3) `harness-onc-certification`-style skills are inherently
  US-specific and should be named as such, with international analogues
  (EU EHDS conformance, national certification regimes) as distinct skills,
  not the same one renamed. (4) **Required before freezing any healthcare
  artifact:** at least one non-US healthcare second-evidence consumer
  (OpenMRS is a strong LMIC-deployed candidate; EHDS-aligned EU software is
  another). This gate is recorded as a Risk in OPP-0013, OPP-0016, and
  OPP-0022.
- **Confidence:** high — the bias is directly observable in the evidence set
  (two US consumers, zero non-US) and was independently flagged by the
  maintainer.
- **Severity:** architectural
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-24 (Tula onboarding)

### Bundling truth-fixes with catalog growth produces a higher-confidence shipping unit

- **Context:** The 2026-05-25 "this-week bundle" PR (Phase 0 factual
  fixes from the documentation audit + YouBase v0.5.1 catalog patch +
  ADR-0013 governance umbrella + docs/README.md ADR/PRD/OPP index)
  bundled four independently-shippable pieces of work into one PR.
  The bundling came out of a prioritization examination that
  recommended each piece separately; combining them was pragmatic
  ("they're all cheap and orthogonal").
- **Observation:** Bundling truth-repair (validator count drift,
  diagram count drift, ADR-0004 stale status, dangling
  `docs/architecture/overview.md`, `$PLATFORM` standardization) with
  catalog growth (5 new modules from OPP-0008/0009/0010) produces a
  higher-confidence shipping unit than either piece in isolation. The
  truth-repair changes harden documentation trust *for the same
  reviewers who will then assess the new modules*; the catalog growth
  gives the truth-repair PR substantive content that justifies the
  review effort. Either piece alone is a "small patch" (truth-repair
  is mechanical; catalog growth is module-copy). Together they're a
  coherent v0.5.1 unit with internal logic — *the newcomer experience
  (Phase 0 fixes) and the active-consumer experience (new modules) are
  both served by the same PR*. This is distinct from cargo-cult
  bundling (combining unrelated work for review economy); here the
  bundling rationale is structural — Phase 0's count fixes touch the
  documentation that the new modules' READMEs cross-reference, and
  ADR-0013 is the governance umbrella under which both halves sit.
- **Implication:** When prioritization analyses surface independent
  pieces of work that share a *governance umbrella* (here: ADR-0013's
  Phase 0 + the catalog-growth opportunity acceptance), look for
  bundling that preserves substantive coherence rather than just
  review economy. The signal that bundling is right: each piece's
  change-log entry would naturally cite the other pieces. The signal
  that bundling is wrong: the pieces' rationale paragraphs read as
  independent — that's two PRs masquerading as one. Worth testing
  against the next multi-piece prioritization decision to see if the
  shape recurs.
- **Confidence:** medium — one instance where the bundling felt
  coherent. Structurally sound but bundling decisions are easy to
  rationalize after the fact. Watch for whether the next examination
  surfaces similar bundling opportunities or whether this was a
  one-off.
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-25 (this-week bundle PR)

### A guardrail filed in one pass correctly partitioned the very next pass's build scope

- **Context:** The Tula onboarding filed five OPPs and a US-healthcare-bias
  guardrail (#53, 2026-05-24). The immediately-following pass (2026-05-25)
  fleshed three of those OPPs into shipped v1 modules (the v0.5.2 agent-native
  delivery batch: `architectures/agent-skill-pack`,
  `management/eval-gated-testing`, `delivery/self-hosted-oss` via
  PRD-0008/0009/0010). The decision of *which* OPPs to build was made by the
  guardrail the previous pass had just filed: the bias guardrail says
  "international second-evidence required before freezing any healthcare
  artifact," so the three healthcare/safety-adjacent items (OPP-0022
  patient-agent safety, OPP-0020 eval/safety tooling, and the OPP-0013
  healthcare-fhir/smart sub-modules) were held, and only the three
  bias-unblocked agent-native items shipped.
- **Observation:** The guardrail was not a passive note — it actively
  constrained the next build step, and building the deferred items would have
  *violated the guardrail on the first move after filing it*. The
  agent-native delivery OPPs carried no equivalent constraint, so they were
  the correct things to build first. The brownfield-discovery → OPP → PRD →
  shipped-module loop closed in under 48 hours for the unblocked subset, while
  the bias-gated subset waits on evidence the harness does not yet have.
- **Implication:** (1) Guardrail-style risks recorded in OPPs are
  load-bearing for sequencing, not just for the eventual PRD — a "freeze-later"
  marker should be read as "do-not-build-yet" by the next pass. (2) A single
  brownfield consumer can both *expand* the catalog (three new modules) and
  *block* part of it (three deferred), and that asymmetry is healthy: it
  prevents the catalog from ossifying around one jurisdiction's evidence while
  still capturing the vendor-neutral gaps immediately. (3) The agent-native
  delivery family (skill-pack topology + eval-gate posture + self-hosted-oss)
  is now activatable, so the next agent-native brownfield consumer — and
  Tula's own second-pass intake — profiles against real modules rather than
  "no module fits."
- **Confidence:** high — directly observed across the #53 → v0.5.2 sequence in
  this session.
- **Severity:** governance-relevant
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-25 (Tula OPP fleshing / v0.5.2 batch)

### Documentation reorder costs almost nothing and unblocks the audience the docs were already serving

- **Context:** Phase 1 of ADR-0013's documentation IA work — the
  README rebuild. The 2026-05-24 audit's headline finding was
  "The hook exists. It is just buried under the navigation." Phase 1
  exercises that diagnosis literally: rewrite zero prose, surface the
  existing hook, embed the existing diagram, and demote the existing
  5-way fork.
- **Observation:** The README rebuild was almost entirely *reorder*,
  not *rewrite*. Every piece of substance — the value framing, the
  "Who This Is For," the "What It Does," the adoption paths — already
  existed and was already good. The only new content was the H1
  wordmark fix (`Development Harness` → `auto-harness`), the hero SVG
  reference (the file already existed in `_assets/proposed-visuals/`
  from PR #56), and the Mermaid Diagram 1 embed in "How It Works"
  (the diagram already existed at `diagrams.md` § 1). Net new prose:
  roughly two sentences. Net structural change: top section reordered,
  TOC collapsed under `<details>`, and the 5-way fork demoted from
  above the value to below it. The high-impact change is the *visual
  order* of what readers encounter first, not what's actually written.
- **Implication:** When an audit identifies a "buried value" or "hook
  too deep" pattern, suspect the fix is reorder, not rewrite. The
  tell: the audit's recommendations name *which content to promote*
  rather than *what new content to write*. This was the shape of
  ADR-0013's Phase 1, and the Phase 1 PR did virtually zero new
  authorship — just rearrangement. The discipline this argues for is:
  before drafting new prose to fix a comprehension gap, *audit
  whether the comprehension content already exists somewhere*; if it
  does, the cheaper fix is to surface it. Worth elevating to
  operating-principles after the rest of ADR-0013's phases land — if
  Phases 2-4 also turn out to be mostly reorder/surface work, the
  pattern is robust enough to codify.
- **Confidence:** medium-high — one strong instance (this Phase 1
  PR). The "reorder, not rewrite" diagnosis matched the audit's
  framing and the actual implementation experience. Phases 2-4 of
  ADR-0013 will surface whether this generalizes.
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-25 (Phase 1 README rebuild)

### A validator that hard-requires the harness's own repo layout is a consumer-onboarding stumbling block

- **Context:** Wiring the harness validator chain into CI for the first
  submodule consumer (Tula, 2026-05-25) surfaced that
  `validate-doc-references.sh` exits `2` ("`<root>/platform` does not exist")
  for any consumer whose platform lives at `.harness/platform/` rather than
  `./platform/`. The consumer CI template includes the step; the
  `ci-integration.md` minimal workflow omits it. Filed as OPP-0023.
- **Observation:** This is the *inverse* of the brownfield-catalog-breadth
  pattern. Catalog gaps surface when a consumer's *reality exceeds the
  catalog*; this is a *tooling* gap — a validator written for the harness's own
  dogfood (which always has `platform/`) silently bakes in that layout and so
  fails for the recommended submodule consumption mode. The template-vs-guide
  disagreement is the visible symptom; the root cause is that the dogfood never
  exercises the no-`platform/` path. It is the same class as the YouBase
  observation that the self-dogfood "says nothing about the dimensions it
  doesn't exercise" — here the unexercised dimension is the *consumer runner
  environment*, not the catalog.
- **Implication:** (1) Every validator in the consumer chain should be run, in
  a self-test, against a no-`platform/` consumer fixture — the dogfood's own
  `platform/` masks layout assumptions. (2) The consumer CI template and the
  `ci-integration.md` minimal workflow are two assertions of the same validator
  set and should be kept in sync by construction; they drifted. (3) "Nothing to
  scan" should be a clean exit `0` across the chain — a consumer with no
  matching files is a valid state, not misuse.
- **Confidence:** high — directly observed (one validator confirmed failing,
  one template/guide mismatch confirmed) during the Tula CI wiring.
- **Severity:** governance-relevant
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-25 (Tula CI wiring)

### Cross-repo declarations have the same silent-drift failure mode as intra-repo doctrine-without-enforcement, and the harness's own CI cannot see them

- **Context:** A fresh `repo → harness → Website Design plan` initialization
  session by the maintainer surfaced an integration-time observation: `.harness/`
  is a gitlink (submodule), not a copy; cloning the consumer repo without
  `--recurse-submodules` leaves the directory empty, and the pinned SHA must
  remain reachable in the upstream remote. Both are silent failures at the
  first-developer's machine — no error during clone, no error during commit;
  the failure only manifests when a second developer joins, when CI clones
  fresh, or when a contributor lands and the validators can't find their own
  scripts. The auto-harness CI itself cannot see this failure mode by
  construction: the harness *is* the upstream the consumer pins to, so it has
  no consumer-side execution path to test.
- **Observation:** This is the *cross-repo* version of a pattern the project
  has already named in this file: *"doctrine in prose without enforcement in
  code is a recurring harness gap."* The intra-repo version is a documented
  catalog count that no validator asserts; the cross-repo version is a
  documented integration step (submodule SHA pin, dependency reference,
  manifest-cited external module) that no consumer-side check asserts. Both
  share the same shape — a declaration with no mechanical check against its
  referent — and both share the same failure dynamic: the declaration is
  written when the referent is correct, then drifts silently as the referent
  changes. PR #58 (in flight as of 2026-05-25) addresses one slice of this by
  recording an explicit tracking branch (`-b main` on `git submodule add`),
  which clarifies *intent* but does not provide a *check*: the SHA at that
  branch can still be force-pushed away, the branch can be deleted, and the
  remote can become auth-gated. Three observed-or-plausible instances of the
  same class so far: (a) catalog-count drift in unwatched files — the M-j
  finding from the 2026-05-25 audit refresh, surfaced as a list-completeness
  validation gap; (b) submodule SHA-unreachability — the trigger for this
  observation; (c) the broader space of cross-repo references the harness
  hasn't catalogued yet — manifest-cited module URLs in lite-mode consumers,
  reference URLs in module READMEs, external skill registries cited in
  `harness-tools`. The unifying lesson: **every cross-repo declaration the
  harness records on a consumer's behalf needs either a mechanical consumer-side
  smoke test or a hand-discipline workaround documented prominently; the
  harness should prefer the former because the failure mode is silent.**
- **Implication:** Two concrete moves follow. First (filed as
  [OPP-0025](../opportunities/OPP-0025-consumer-integration-smoke-test.md)):
  the consumer-side integration smoke test — a tiny CI template + a recipe
  documented in `submodule-integration.md` — closes the most common instance
  (submodule SHA reachability). Second (the M-j list-completeness OPP
  candidate, not yet filed): extending `validate-catalog-counts.sh` to assert
  index completeness closes the intra-repo version. The two compose naturally
  as anchor + satellite — same root cause, two different surface
  manifestations, one durable design conclusion: when the harness declares
  something on a consumer's behalf, ship the validator alongside the
  declaration or accept that the declaration will rot.
- **Confidence:** medium-high — one direct instance (this observation's
  trigger) plus the structural argument paralleling the already-confirmed
  intra-repo pattern (catalog-count drift). A second instance in the
  cross-repo space — e.g., a manifest-cited module URL that 404'd, or a
  skill-registry pointer that broke — would lift to high.
- **Severity:** architectural
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-25 (initialization-session
  insight relayed by maintainer, paired with OPP-0025 filing)

### Declared knowledge surfaces without an inbound-flow trigger silently die; operating-principles ate distilled-learnings' lunch

- **Context:** Investigating *"when does the process trigger to generate
  distilled learnings happen? distilled-learnings.md seems way behind and it
  doesn't seem to be triggered by anything? Does it get read by anything?"*
  raised by the maintainer mid-bundle on 2026-05-25. The investigation traced
  the distillation flow end-to-end against the v1.1.0 `knowledge-capture`
  module: PRD-0004's cycle-end trigger rule fires on ADR/OPP/module.yaml/
  manifest changes (fresh and well-fed); shared-observations.md is the
  default destination and grew to ~1,218 lines as expected;
  operating-principles.md acquired §§ 7 and 8 this session via curation;
  *distilled-learnings.md has been a 64-line shell since 2026-04-16, the day
  the knowledge-capture module was first added — zero content entries in 40
  days.* This was already flagged in the 2026-05-24 documentation audit
  (finding M8: "review cadence ~7 months stale") but treated as a status-drift
  cosmetic. The investigation revealed the gap is structural, not cosmetic.
- **Observation:** This is the *intra-repo* sibling of the cross-repo
  silent-declaration pattern recorded one entry above — same shape, different
  surface. The `knowledge-capture` module *declares* three knowledge
  destinations (shared-observations, operating-principles, distilled-learnings)
  as `requiredArtifacts`, and the cycle-end rule accepts any of the three as
  satisfiers. Two have inbound flow: shared-observations is the default
  destination and absorbs the bulk of cycle-end traffic; operating-principles
  receives promotions when patterns crystallize. **distilled-learnings has no
  inbound-flow trigger by design** — the workflow doc explicitly tells
  authors *not* to write to it opportunistically (*"Promote observations to
  learnings during dedicated review, not opportunistically"*) and instead
  reserves it for "dedicated review sessions." Nothing schedules those review
  sessions. The audit-trail rule on distilled-learnings.md fires only if it
  is edited, but nothing edits it. operating-principles.md has *de facto*
  absorbed distilled-learnings' charter: §§ 7 and 8 are exactly the
  cross-observation synthesis distilled-learnings was supposed to host.
  Three instances of the same class are now visible: (a) the consumer-side
  smoke test (one entry up, filed as OPP-0025); (b) catalog-count list-
  completeness (M-j from the audit refresh, candidate OPP); (c) this — a
  declared knowledge destination with no production path. The unifying lesson
  extends the cross-repo one: **every declared surface — file, validator,
  index, workflow — needs an inbound-flow trigger or an explicit dormancy
  label. Declared-without-trigger is the slow-failure mode that survives
  long enough to mislead future readers about what the project actually
  practices.**
- **Implication:** The narrow move (filed as [OPP-0026](
  ../opportunities/OPP-0026-distilled-learnings-disposition.md)) is to
  decide distilled-learnings.md's disposition — sunset (drop it from
  `requiredArtifacts` + cycle-end satisfier list; consolidate curation in
  operating-principles), revive (add a time-or-count-based trigger that
  forces a curation session), or clarify (label it dormant pending an
  established curation cadence). The broader move is the *deeper* concern
  this surfaces, captured as a candidate in `candidates.md`: **the harness
  has powerful automations (companion rules, distillation triggers,
  Stop-event hooks) but no defined "optimal session shape" with review
  checkpoints that systematically fire them.** A session might add ten
  shared-observations, ship a PRD, and merge — but never run the curation
  review that distilled-learnings was designed to receive, never check
  whether operating-principles needs a new section, never audit the
  back-pressure between observation accumulation and synthesis. The
  automations exist; the *cadence that consumes their output* is
  underspecified. This is bigger than distilled-learnings.md alone and
  warrants its own examination — it is the trigger-side counterpart to
  the audit-driven pattern the project has already named ("audits surface
  what continuous discipline missed"). The candidate-stub in
  candidates.md preserves the framing until a second instance accumulates.
- **Confidence:** high on the narrow distilled-learnings claim (40 days of
  zero inbound flow; audit-confirmed staleness); medium on the broader
  session-cycle claim (one strong articulation by the maintainer this
  session; the structural argument is sound but lacks a second concrete
  instance of "review we wish had fired but didn't").
- **Severity:** architectural
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-25 (investigation
  triggered by maintainer mid-bundle; paired with OPP-0026 and session-cycle
  candidate stub)

### Sunsetting a declared-but-unused mechanism must rule out replicating the failure mode at the surviving destination

- **Context:** Drafting PRD-0011 (sunset `distilled-learnings.md`,
  promotion of OPP-0026 → exploring, 2026-05-25). The Option-A
  disposition was straightforward on its evidence — 40 days of zero
  inbound flow, `operating-principles.md` had absorbed the charter,
  operating-principle § 7 explicitly argues against keeping two
  destinations whose change-classes have collapsed. The non-obvious
  part of the PRD was the rejection of Option B (revive with a
  forcing trigger). The reason was not "forcing triggers are bad" —
  PRD-0004 demonstrably ships a successful forcing trigger (the
  cycle-end-distillation rule). The reason was that a forcing trigger
  added *now* against operating-principles.md would either fire on
  the same change-class operating-principles already serves (creating
  a routing problem) or fire on a synthetic schedule the team would
  resent or game — which is the *exact failure mode the PRD is
  removing from distilled-learnings*.
- **Observation:** When sunsetting a declared-but-unused mechanism,
  the v1 must rule out replicating that mechanism's failure mode at
  the surviving destination — or the sunset will recur there. The
  failure mode that kills a declared destination is *declared triggers
  nobody adopts*: distilled-learnings died because its "dedicated
  review sessions" trigger had no forcing pressure upstream. The naive
  Option-B response is to add upstream pressure to operating-principles
  ("quarterly review", "every N observations triggers a check") — but
  that pressure would be just as synthetic as the one that failed at
  distilled-learnings, and operating-principles' current "promote when
  the pattern crystallizes" cadence is healthy *because the promotion
  is driven by real evidence accumulating in shared-observations.md*,
  not by clock or count. The structural insight: the failure of
  declared-without-trigger is not solved by adding *any* trigger — it
  is solved by ensuring the trigger that exists is *driven by
  accumulating evidence in another tracked surface*, not by clock or
  count. This generalizes: every sunset PRD should explicitly enumerate
  the failure mode that killed the original mechanism, and check that
  the surviving destination's mechanism is structurally protected from
  the same mode.
- **Implication:** Add this as an explicit check item to the OPP→PRD
  promotion workflow: *"If this PRD sunsets a declared mechanism, the
  Rejected Alternatives section must enumerate the failure mode that
  killed the original and show why the surviving destination is
  structurally immune."* This is not yet operating-principle-grade
  (one instance), but lift to that surface if a second sunset PRD
  exercises the same discipline successfully. Possible candidate for
  a future operating-principles § 9 if so. There is also a meta-point
  worth noting: this observation exists because the cycle-end
  distillation rule fired on the PR that drafted PRD-0011 and *forced*
  the distillation to be written before merge — exactly the rule's
  designed PR-boundary behavior. The PR author had initially claimed
  the rule was not triggered (the OPP edit was framed as a status flip,
  not new substantive work); CI rejected that framing and required a
  real distillation entry. The rule worked: it caught the over-narrow
  "this is just a status flip" framing and forced the distillation a
  reader would benefit from.
- **Confidence:** medium-high — one direct instance with explicit
  reasoning (PRD-0011's Option B rejection rationale), structurally
  sound argument. Second instance would lift to high.
- **Severity:** architectural
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-25 (PRD-0011 drafting; satisfies the cycle-end distillation rule that fired on the OPP-0026 status flip and the PRD-0011 file creation, which CI caught — the rule's PR-boundary enforcement working as designed)

### The distilled-learnings sunset shipped — the sunset-PRD discipline carried through to implementation

- **Context:** PRD-0011 implementation, 2026-05-25. The PRD specified 13
  must-have FRs covering the module.yaml edits, the dormancy stub, the
  workflow-doc updates, ADR-0014, and the destination-side claim in
  operating-principles.md. The previously-recorded observation
  *"Sunsetting a declared-but-unused mechanism must rule out replicating
  the failure mode at the surviving destination"* (2026-05-25, one entry
  up) had named the discipline; the implementation was the test of
  whether that discipline would actually carry through under execution
  pressure, where the cheap move would have been to bolt a quarterly-
  review trigger onto operating-principles to "preserve cadence."
- **Observation:** The discipline held. Operating-principles.md gained
  an explicit claim of the curated-longitudinal-knowledge role
  (paragraph two of the file's header), but no synthetic trigger — no
  time-based companion rule, no count-based threshold, no audit cadence
  attached. The cycle-end distillation rule continues to fire on the
  same ADR/OPP/module.yaml/manifest trigger set; the satisfier set
  shrank from three destinations to two; the rule's *behavior* is
  unchanged, only the satisfier surface area is smaller. The discipline
  named in the prior observation — *"the failure of declared-without-
  trigger is solved by ensuring the trigger that exists is driven by
  accumulating evidence in another tracked surface, not by clock or
  count"* — was exercised concretely: operating-principles is now
  explicitly named as the curated destination *and* its promotion
  cadence is evidence-driven by accumulation in shared-observations,
  not by a synthetic clock. The OPP-0026 acceptance criterion *"PR
  includes a paired observation confirming the sunset happened"* is
  satisfied by this entry; the rule worked end-to-end on the
  implementation PR exactly as it worked on the design PR (#61).
- **Implication:** Two observations now connect (declared-without-flow +
  sunset-discipline) and operate as a tested pair: the first names the
  failure mode, the second names the discipline that prevents
  recurrence, and the implementation exercised both. If a third sunset
  PRD lands in the future with the same discipline visible in its
  rejected-alternatives section, that's the lift to high-confidence
  evidence and the candidate for operating-principles § 9. Until then,
  the pair stands as observed-twice, applied-once. The implementation
  also confirmed by absence: no consumer projects required migration
  steps; the module-version bump (1.1.0 → 1.2.0) is a softening of the
  contract, never a tightening, exactly as PRD-0011 specified.
- **Confidence:** high — direct, observed end-to-end execution of the
  discipline with concrete evidence (operating-principles' explicit
  destination claim was added; a synthetic trigger was *not* added; the
  satisfier set shrank exactly as designed).
- **Severity:** governance-relevant
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-25 (PRD-0011 implementation; satisfies the cycle-end distillation rule fired by the implementation PR's ADR-0014 + module.yaml + OPP-0026 acceptance edits; also satisfies the PRD-0011 acceptance criterion requiring a paired observation confirming the sunset)

### Brownfield catalog gaps surface in layers — the first profile pass catches product-shape gaps; a second pass catches platform-layer gaps

- **Context:** Tula second-pass profiling against the
  [Tula README](https://github.com/unclenate/tula/blob/main/README.md)
  on 2026-05-25, after the catalog had digested the first-pass
  filings (OPP-0018..0022 + augmentations to OPP-0013/0016). The
  first pass produced five OPPs covering *product shape* — eval-gated
  skill-pack architecture, binary-eval testing posture, self-hosted-
  OSS delivery, evaluation tooling in toolchain, patient-facing
  health-agent safety — and the operator-vs-patient-side
  augmentation of the healthcare family. The second pass produced
  five *new* OPPs (the OPP-0027 anchor + four satellites OPP-0028..0031)
  covering *enterprise-AI-platform layering* — foundry targeting,
  agent observability, intelligent model routing, defense-in-depth
  for autonomous agents — plus three augmentations (OPP-0015 with
  BAA-LLM-gateway and AI Act, OPP-0019 with three-stage eval
  lifecycle, OPP-0021 with optional `OPEN_CORE.md`). The two passes
  surfaced *disjoint* gap sets — the first pass did not see the
  second-pass cluster because the first pass was answering "what
  product shape is this?", not "what enterprise-AI-platform
  infrastructure does this commit to?"
- **Observation:** Brownfield catalog-gap discovery is *layered*,
  not flat. A single onboarding pass surfaces the gap class the pass
  is *looking for*; gap classes orthogonal to that framing remain
  invisible until a deliberate second pass against a different
  framing question. The first Tula pass framing was "what's the
  product shape and what safety constraints apply?" — that framing
  caught the delivery-topology gap (OPP-0021) and the healthcare-
  safety gap (OPP-0022) but did not catch the foundry-target gap
  (OPP-0028) or the observability gap (OPP-0029) because those
  weren't in the first frame. The second pass framing was "what
  enterprise-AI-platform infrastructure is this project built to
  participate in?" — that framing caught the cluster the first pass
  missed. This generalizes: each onboarding pass should declare its
  *framing question* explicitly; subsequent passes against the same
  project should pick a *different* framing question to surface
  orthogonal gaps. The discipline: don't assume one pass exhausts a
  brownfield project's catalog-implications; budget multiple passes
  with deliberately-different framings.
- **Implication:** Two operational moves follow. (1) `harness-
  onboarding` SKILL should explicitly prompt for the *framing
  question* the pass is answering, capture it in the gap analysis,
  and recommend at least one orthogonal-framing second pass for
  non-trivial consumers — especially agent-native ones, which span
  product-shape, regulated-AI-deployment, and enterprise-AI-platform
  dimensions simultaneously. (2) Future brownfield onboardings
  should be scheduled as *two-pass* by default: first pass on
  product/delivery/safety shapes, second pass on platform/observability/
  routing/defense-in-depth shapes. The first pass produces fast
  catalog growth (zero-required-artifact OPPs); the second pass
  produces deeper architecture-aware modules. PRD-pass for any
  future onboarding-skill enhancement should explicitly bake in the
  two-pass cadence. This is also a strong second instance for the
  *session-cycle orchestration candidate* in
  `docs/opportunities/candidates.md` — the missing review there is
  *"second-pass onboarding against a different framing question"*.
- **Confidence:** medium-high — one strong instance (this Tula
  second-pass directly produced five new OPPs and three substantial
  augmentations the first pass missed). The structural argument is
  sound, but a second instance against a different consumer project
  would lift to high. The pattern's specific prediction: any
  brownfield agent-native project will surface enterprise-AI-platform-
  layer gaps on a second pass that the first pass misses.
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-25 (Tula second-pass profiling against the project README, after the catalog had digested OPP-0018..0022; paired with OPP-0027 anchor and satellites OPP-0028..0031, plus augmentations to OPP-0015, OPP-0019, OPP-0021)

### The candidate-stub-to-OPP promotion gate worked end-to-end on first firing

- **Context:** OPP-0032 filing, 2026-05-25. The session-cycle
  orchestration candidate had been held as a stub in `candidates.md`
  with an explicit promotion-criterion declared in the stub itself:
  *"Promoted from candidate-stub to OPP when a second concrete instance
  of 'declared review without a trigger' surfaces independently — same
  evidence-pattern that lifted brownfield-onboarding-as-discovery from
  observation to OPP cluster."* Two instances accumulated within hours
  of one another in the same session (distilled-learnings dormancy via
  OPP-0026; Tula two-pass discovery via OPP-0027..0031 and the
  layered-brownfield observation). The promotion gate fired exactly as
  declared.
- **Observation:** This is the first observed instance of the
  *candidate-stub-with-explicit-promotion-criterion* pattern firing
  end-to-end in this project. The discipline pattern is: (1) when a
  concern surfaces but the evidence is single-instance, capture it as
  a *candidate-stub* in `candidates.md` (the organizational index, no
  full OPP file); (2) declare an *explicit promotion criterion* in
  the stub itself (e.g., "promoted when a second concrete instance
  surfaces independently"); (3) when the criterion fires, *promote*
  the stub to a full OPP file with the accumulated evidence cited.
  The discipline avoids the two failure modes that plague candidate
  capture: *premature OPP filing* (one instance gets a full OPP, then
  no second instance ever validates the concern) and *forgotten
  insights* (single-instance concerns never recorded, lost to
  session memory). The promotion-criterion is the load-bearing part —
  without it, a candidate-stub is just an undated note; with it, the
  stub becomes a self-firing record that activates when its own
  evidence-bar clears. The pattern is structurally similar to the
  *cycle-end-distillation rule fires on triggers, requires satisfiers*
  pattern, but at a slower cadence — candidate-stubs gate on
  *cross-session evidence accumulation*, while cycle-end rules gate
  on *per-PR trigger paths*.
- **Implication:** The candidate-stub-with-explicit-promotion-criterion
  pattern is worth elevating as a documented technique in
  `platform/templates/opportunity/candidates.md` (the template, not the
  in-tree index). A new section in the template could codify: *"For
  insights single-instance enough to record but not yet substantial
  enough to file as a full OPP, capture as a candidate-stub with an
  explicit promotion criterion. Suggested criteria: 'second concrete
  instance surfaces independently' (cross-session evidence), 'audit
  surfaces the same gap class' (audit-driven evidence), 'consumer
  project hits this' (field evidence)."* This is a possible
  operating-principles candidate after a second observed
  promotion-gate firing — same gate-promotion discipline applied to
  operating-principles itself.
  - **Update 2026-05-26:** Documented as a technique in the
    discipline-codification PR — but in the opportunity **README
    template** (`platform/templates/opportunity/README.md`), not the
    candidates.md template this implication originally named. The
    correction: the technique is *how-to-capture* guidance (policy),
    and the candidates.md charter (ADR-0012, operating-principle § 7)
    reserves that file for *organizational* index content while policy
    lives in `README.md`. The stub itself is an index line (lives in
    candidates.md); the *technique* documenting it is policy (lives in
    the README). Operating-principle promotion remains correctly gated
    on a **second** promotion-gate firing — it was *not* promoted now,
    preserving the very candidate-stub discipline it describes.
- **Confidence:** medium — one direct instance of the promotion-gate
  firing correctly, with concrete evidence (the OPP-0032 file now
  exists with the two cited instances). Second instance would lift to
  high; the candidate-stub pattern's *staying power* across sessions
  is the unobserved-yet dimension.
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-25 (OPP-0032 filing; satisfies the cycle-end distillation rule fired by the OPP-0032 file creation, with substantive connection — the observation is *about the promotion-gate that produced the OPP*, not cargo-cult padding)

### A validator's self-tests inherit the dogfood's structural assumptions — test the consumer layout explicitly

- **Context:** Implementing OPP-0023 (PRD-0012) to make `validate-doc-references`
  consumer-aware. The fix was a **single guard removal** — the Ruby was already
  consumer-safe (Pass 1 no-ops via an empty `platform/**/*.md` glob; Pass 2
  scans the project root regardless). The only reason submodule consumers failed
  was the `<root>/platform`-must-exist bash guard, and the only reason the test
  suite never caught it was that every existing doc-references fixture — and the
  dogfood — *has* a `platform/` tree. The pre-existing `test_missing_platform_dir_aborts`
  actively asserted the buggy contract (missing `platform/` → exit 2).
- **Observation:** A validator's self-tests inherit the dogfood's structural
  assumptions. `validate-doc-references` had thorough tests, but every one ran
  against a `platform/`-bearing fixture, so the consumer layout (no top-level
  `platform/`) was untested and the guard's over-strictness was invisible — the
  behavior was "correct" against the only shape the tests exercised. This is the
  *test-fixture* analog of the catalog observation that "the self-dogfood says
  nothing about the dimensions it doesn't exercise": here the unexercised
  dimension is the **consumer's directory layout**, and a test even encoded the
  wrong behavior as correct.
- **Implication:** (1) Every validator in the *consumer* chain should carry a
  consumer-shaped self-test fixture (no `platform/`), not only harness-shaped
  ones; PRD-0012 adds `consumer-no-platform-{valid,broken}`. (2) Audit the other
  consumer-chain validators for the same dogfood-only-fixture blind spot. (3)
  Pairs with OPP-0025 (consumer-side integration smoke test) — the same
  "test the consumer layout, not just the dogfood" theme at two levels: unit
  fixture (here) and fresh-clone (OPP-0025). (4) A test that encodes current
  behavior can lock in a bug; when a fix changes a contract, expect to *replace*
  a test, and treat "why did this test assert that?" as a smell worth chasing.
- **Confidence:** high — directly observed; the one-line fix plus the
  bug-asserting test it replaced are the evidence.
- **Severity:** governance-relevant
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-25 (OPP-0023 / PRD-0012 implementation)

### Deferring rule implementations from the taxonomy PRD preserves the per-rule OPP→PRD discipline

- **Context:** PRD-0013 drafting, 2026-05-25. The natural shape of a
  "session-cycle orchestration and review-trigger taxonomy" PRD is to
  *include implementations of the new rules the taxonomy names*. The
  audit section identifies multiple declared-but-unfired reviews
  (operating-principles promotion-candidate scan, second-pass
  brownfield onboarding, knowledge-tree back-pressure audit,
  candidate-stub-with-promotion-criterion gate, etc.); each could be
  drafted as a new companion rule in the same PRD. The cheap move is
  to ship "taxonomy + four new rules" in one PR.
- **Observation:** PRD-0013 explicitly rejects the cheap move. Each
  new companion rule warrants its own OPP→PRD cycle because the *design
  work* of deciding "which review wants which trigger primitive" is a
  different change class than the *implementation work* of writing a
  rule's regex, satisfier set, and humanReview text. Operating-principle
  § 7 (*Align File Boundaries with Change-Class Boundaries*) is the
  load-bearing argument. The session has now exercised this discipline
  twice in one window: PRD-0011 explicitly rejected Option B (add a
  forcing trigger to operating-principles) to preserve the
  evidence-driven cadence; PRD-0013 explicitly defers per-rule
  machinery to preserve the OPP→PRD-per-rule cadence. Different domains,
  same discipline. The pattern: **when a PRD's natural scope would
  bundle design work with implementation work, split it.** v1 ships
  *what the system should do and why* (design); follow-up PRDs ship
  *how each component does its part* (implementation). The cost is one
  extra PR per implementation; the benefit is each implementation gets
  full design-pressure review on its own terms.
- **Implication:** The pattern *PRD-with-deferred-implementations* is
  now observed twice (PRD-0011 sunset rejecting Option B; PRD-0013
  taxonomy deferring per-rule machinery). A third instance in a future
  session would lift this to high-confidence evidence and make it a
  strong candidate for operating-principles § 9 — possibly co-located
  with the candidate-stub-with-promotion-criterion technique under a
  unifying heading like *"Split design from implementation; bundle by
  change-class, not by topical adjacency."* The PRD template
  (`platform/templates/product/prd.md`) could eventually surface this
  explicitly with a "Implementation Deferral" section that prompts the
  author to enumerate which implementations are deferred and why —
  defer that template change until the third instance accumulates.
  - **Update 2026-05-26:** The third instance arrived (PRD-0014) and
    both the § 9 promotion and the PRD-template "Implementation
    Deferral" section landed the same day. The § 9 heading shipped as
    *"Split Design from Implementation"* (not co-located with the
    candidate-stub technique — that pattern is at one firing and got
    lighter-weight template documentation instead). See the
    third-instance observation below for the landing detail.
- **Confidence:** medium-high — two direct instances in one session
  with explicit reasoning in each PRD's Non-Goals section. Third
  instance from a future session would be the lift to high.
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-25 (PRD-0013 drafting; satisfies the cycle-end distillation rule fired by the OPP-0032 status flip and the PRD-0013 file creation; substantive connection — the observation captures the *design discipline that produced the PRD's scope shape*, not a tangential note)

### Doctrine documents expanded with rationale prose — *why six*, *why this boundary*, *why these stages* — without changing any rule

- **Context:** Phase 2 of ADR-0013 implementation, 2026-05-25. The
  documentation audit (M-d) had flagged the kernel doctrine docs
  (`doctrine.md`, `audit-model.md`, `enforcement-model.md`,
  `lifecycle-controls.md`) and the trust-model spec (H-a) as bare bullet
  lists — *rules without rationale*. The Phase 2 PR expanded each from
  ~25 lines to a substantive doc covering not just *what the rule is*
  but *why it exists*, *what failure mode it prevents*, and *what
  alternative was rejected*. Critically: **no rule was changed.** The
  trust-model still has six tiers; the doctrine still names the same
  six principles; the enforcement model still distinguishes the same
  five categories. The expansion was *purely additive* — the original
  rules sit at the top of each section, with the rationale below.
- **Observation:** Adding rationale prose to load-bearing kernel docs
  is a substantively different change class than changing the rules
  themselves. The audit findings M-d and H-a are *audience-fit* concerns
  ("readers can't tell why this rule matters") rather than
  *correctness* concerns ("this rule is wrong"). Recognizing the
  distinction lets Phase 2 land as a single coherent PR (six files,
  ~700 net new lines of prose, zero rule changes) without triggering
  any of the heavier governance machinery that would fire if rules
  *were* changing (no ADR for a rule change; no companion-rule update;
  no module.yaml edit). This is the **documentation-as-audience-fit-work**
  pattern: when the audit identifies an audience-fit gap, the fix is
  expansion-without-modification, and the change class is *narrative
  documentation*, not *governance contract change*. The trust-model
  document is a particularly clean instance: 26 lines of spec became
  ~150 lines of spec + rationale + enforcement-today honesty, all
  while preserving the six-tier table and the kernel rules verbatim.
- **Implication:** This is a generalizable technique for the remaining
  ADR-0013 phases (3 and 4) and for any future audit-driven doc work:
  *if the finding is audience-fit, the fix is rationale-expansion-without-
  rule-change*; *if the finding is correctness, the fix is a rule
  change with the heavier machinery that demands*. The distinction is
  worth surfacing in the audit template itself — adding a "Finding
  class: audience-fit / correctness / drift" line to each finding would
  let future audits be explicit about which change-mode they're
  pointing at. The session has now exercised this discipline three
  times: Phase 1 (README rebuild — reorder, not rewrite, per the prior
  "Documentation reorder costs almost nothing" observation), and
  Phase 2 (this work — rationale, not rule change). The reorder /
  rationale-add / rule-change taxonomy is the audit-finding-class
  taxonomy worth codifying.
- **Confidence:** medium-high — three instances this session
  (README rebuild = reorder; Phase 2 doctrine = rationale; the OPP-0026
  / PRD-0011 disposition = rule change with full ADR machinery). The
  three-way split is sound and the technique has worked at scale (the
  largest doctrine doc expanded was lifecycle-controls.md, from 30
  lines to ~130, in one coherent pass).
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-25 (Phase 2 of ADR-0013 — vocabulary + trust-model + doctrine rationale; satisfies the cycle-end distillation rule fired by the touched modules and ADR-referencing changes)

### Third instance of deferred-implementations discipline confirms the pattern is generalizable

- **Context:** PRD-0014 (Agent Observability with OpenTelemetry Semantic
  Conventions) drafting, 2026-05-26. The PRD explicitly defers the
  trace-contract-update companion rule to a v2 follow-up OPP/PRD pair,
  citing PRD-0013's paired observation as the discipline-source: *"v1
  establishes the contract; v2 enforces it."* This is the **third
  observed instance** of the deferred-implementations pattern this
  session.
- **Observation:** The pattern *PRD-with-deferred-implementations* has
  now fired three times: (1) PRD-0011 sunset rejecting Option B (no
  synthetic trigger added to operating-principles); (2) PRD-0013
  taxonomy deferring per-rule machinery; (3) PRD-0014 deferring the
  trace-contract-update companion rule to v2. Three instances in one
  session is the established bar for lifting from medium-high to high
  confidence and from observation to operating-principle candidate.
  The pattern as a candidate § 9 for `docs/operating-principles.md`:
  *"Split design from implementation. When a PRD's natural scope
  would bundle design work (deciding what should happen) with
  implementation work (writing the rule that enforces it), prefer
  shipping the design at v1 and deferring the implementation to a
  follow-up OPP/PRD pair. The cost is one extra PR per implementation;
  the benefit is each implementation gets full design-pressure review
  on its own terms — and the v1 contract is validated against real
  consumer adoption before machinery locks it in."*
- **Implication:** Two concrete next moves: (1) **promote to
  operating-principles § 9** in a dedicated PR (the discipline-
  codification PR named in the deferred-implementations observation
  itself); the PR is small (one section addition) and the discipline
  is now well-supported with three instances. (2) **update the PRD
  template** (`platform/templates/product/prd.md`) with an
  "Implementation Deferral" section that prompts the author to
  enumerate which implementations are deferred and why — also
  deferred from PRD-0013 (which suggested the template change but
  deferred to the third instance). The third instance is here; both
  moves are now ripe. Filing both as follow-up OPPs (likely the same
  OPP given the topical adjacency, with the operating-principle
  promotion as the v1 deliverable and the template change as v2)
  is the natural next discipline-codification work.
  - **Update 2026-05-26:** Both moves landed in a single
    discipline-codification PR (not filed as a follow-up OPP — the
    work was small, self-contained, and directly supported by the
    three documented instances, so it shipped as a direct codification
    of an already-evidenced discipline). `docs/operating-principles.md`
    § 9 *Split Design from Implementation* now codifies the discipline
    with all three instances cited; `platform/templates/product/prd.md`
    gained an *Implementation Deferral* section. The candidate-stub
    technique (one firing) was documented as guidance in the
    opportunity README *template* rather than promoted to an
    operating-principle — see that observation's own update note.
- **Confidence:** high — three direct instances in one session with
  explicit citation chain (PRD-0011 → PRD-0013 → PRD-0014). The
  pattern's generalizability is proven across three distinct domains
  (sunset disposition; taxonomy doc; new module declaration). The
  candidate-stub-with-promotion-criterion technique (named in a
  separate observation) is the second pattern this session has now
  observed firing three times across three different topical
  domains; both are operating-principle candidates worth promoting
  in the same follow-up PR.
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-26 (PRD-0014 drafting; satisfies the cycle-end distillation rule fired by the OPP-0029 status flip and the PRD-0014 file creation; substantive connection — the observation captures the third firing of the *deferred-implementations* discipline this PR exercises, lifting it to operating-principle candidate)

### Structural enforcement is itself layered — shipping a structural enforcer requires a canonical-surface audit

- **Context:** Wave 1 of the 2026-05-27 audit roadmap shipped
  `validate-list-completeness.sh` (PR #72, merged 2026-05-27 21:06
  US/Pacific), closing the "list-completeness drift" defect class
  refresh-2 §4 named as the single highest-leverage outstanding item.
  The validator's six checks were scoped against the contract spelled
  out in execution-roadmap §4 — which named `docs/README.md`,
  `candidates.md`, `compositions/README.md`, root `README.md`,
  `templates/README.md`, and (for modules only) `SUMMARY.md` as the
  canonical index surfaces. Within ~30 minutes of merge, maintainer
  PR #73 added `mcp-server-typescript-oss` composition and explicitly
  cited the new validator in its body — but added a `SUMMARY.md` row
  for the composition that the validator did not check for. The
  maintainer was *manually compensating* for a coverage gap I had not
  realized existed. Tracing the gap: `SUMMARY.md` has dedicated
  canonical sections for *all six* entity types the validator covers
  (ADRs, PRDs, OPPs, compositions, template subdirectories, modules)
  — not just modules. And `SUMMARY.md`'s ADR section was already
  missing ADR-0015 at that point, reproducing the exact defect Wave 1
  was supposed to close, in a sibling surface, within 24 hours of
  Wave 1's land. Refresh-2's "48-hour reproduction cadence" empirically
  demonstrated *again*, now against the structural fix itself.
- **Observation:** The original "structural enforcement is the missing
  layer" thesis (refresh-2 + safety sweep + IA proposal cross-cutting
  insight) is correct but incomplete. When you ship a structural
  enforcer, the next-order question is: *which canonical surfaces does
  this enforcer cover, and are there any canonical surfaces it doesn't?*
  Uncovered canonical surfaces become the next drift opportunity, with
  the same recurrence cadence as before — except now harder to notice,
  because the closed defect class creates a false sense of completion.
  The validator scoping I shipped followed the audit's contract literally;
  it did not audit whether the contract enumerated all canonical surfaces
  that exist in practice. PR #73 surfaced that gap in hours, not weeks,
  via maintainer parallel work — which is itself part of the discipline.
- **Implication:** Three concrete near-term moves; each generalizable
  beyond this one validator. **First**, when shipping a structural
  enforcer in future, the design step needs an explicit "canonical
  surface inventory" — enumerate every index surface for the entity
  class on disk, then audit the validator's check table against that
  inventory. The roadmap contract is a *minimum* surface set, not the
  complete one. **Second**, the §9 *Split Design from Implementation*
  pattern is the right response when a canonical-surface gap is
  discovered after design ship: ADR-0016 records the validator-extension
  decision and defers the implementation to Wave 6 (which reshapes
  `SUMMARY.md` wholesale). The pattern proves general beyond PRDs —
  ADR-0016 is the first ADR-level use of §9. **Third**, treat
  maintainer parallel-PR work as a structural canary for validator
  scope. If the maintainer is manually adding rows the validator
  doesn't check, the validator's contract is incomplete; this is more
  reliable signal than waiting for a future audit cycle to surface
  the gap.
- **Confidence:** medium-high — one strong instance (Wave 1 →
  PR #73 → ADR-0016) with explicit empirical drift (ADR-0015 missing
  from `SUMMARY.md`) and a clean architectural framing that generalizes
  to "every future structural enforcer." Second instance pending —
  Wave 6's IA migration will produce the validator extension; if the
  extension surfaces *another* uncovered canonical surface, the pattern
  is confirmed as recurring. The Wave 1 → Wave 2a cycle alone is one
  data point; promotion to operating-principle candidate would benefit
  from the Wave 6 follow-through to count as the §9-style "three
  instances" generalization.
- **Severity:** architectural
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-27 (ADR-0016 drafting; satisfies the cycle-end distillation rule fired by the ADR-0016 file creation + ADR-0013 status update; substantive connection — the observation captures the architectural learning that *prompted* ADR-0016's §9 deferral entry for the validator extension, rather than an unrelated observation appended to satisfy the rule)

### Claim-vs-enforcement classification is a generalizable framework-audit mechanism — the classification *is* the next-phase roadmap

- **Context:** Wave 2b of the 2026-05-27 audit roadmap (this PR)
  shipped ADR-0017 (Safety Hardening Roadmap) plus four OPPs (0033
  content-safety, 0034 sensitive-paths, 0035 SAST module, 0036
  knowledge-redaction) anchoring the framework's safety-debt pay-down
  schedule. Authoring the ADR forced a close reading of the safety
  sweep's Part-I §2 ("Formal Verification — Claim-vs-Enforcement
  Map"), which enumerated **19 load-bearing claims the framework
  makes about agent behavior or governance contract integrity** and
  classified each as **Enforced**, **Half-enforced**, or
  **Asserted-only**. Result: 9 Enforced, 3 Half-enforced, 7
  Asserted-only — with six of seven Asserted-only items being exactly
  the surface that matters most (claims 10–13, 15, 16:
  no-self-elevation, tier-ceiling-fixed, sensitive-paths,
  kernel-doctrine override, second-human-Harness-Ready,
  design-vs-implementation split). The sweep's recommendation
  structure flowed directly from the table — each Asserted-only item
  mapped to a specific closure path (a PRD, an OPP, or a §16-priority
  validator). ADR-0017 transcribed that table's structure into
  Wave 5's priority order without re-deriving it.
- **Observation:** The claim-vs-enforcement classification is a
  **generalizable framework-audit mechanism**, not a one-time
  analytical frame specific to auto-harness's 2026-05-27 audit. Any
  framework that exists to enforce something — governance harnesses,
  policy engines, contract checkers, compliance scaffolding — can run
  the same procedure: enumerate load-bearing claims (from doctrine,
  README marketing, operating-principles, public docs), classify each
  as Enforced (a validator catches it), Half-enforced (partially
  structurally checked), or Asserted-only (claimed in prose, not
  checked anywhere in code). **The output of that classification IS
  the next-phase roadmap.** The Asserted-only cluster is the safety
  debt. The Half-enforced cluster is the upgrade-path candidate set.
  The Enforced cluster is what the framework can currently defend.
  This is the **second flavor** of the structural-only-enforcement
  observation chain. The Wave 2a observation
  [[structural-enforcement-is-layered]] named that *within a single
  validator's scope, canonical surfaces can be uncovered* (Wave 1's
  validator covered six surfaces but missed `SUMMARY.md` for 5 of 6
  entity types). This Wave 2b observation names that *across the
  framework's overall enforcement surface, claims can be uncovered*
  (the seven Asserted-only items). Two flavors of the same meta-
  pattern at different scales — both with the same remedy: enumerate
  canonical surfaces, convert Asserted to Enforced via targeted
  validators, accept that the enumeration is itself the enforcement
  work.
- **Implication:** Three concrete moves; each generalizable beyond
  this PR. **First**, run the claim-vs-enforcement classification as
  a periodic re-evaluation — safety-security-sweep §13 #3 names this
  as "Doctrine-vs-enforcement re-evaluation — on-change, capped at
  quarterly," triggered by any ADR touching doctrine. The
  classification IS the audit; running it routinely catches new
  Asserted-only claims as they accumulate (every new
  ADR/PRD/operating-principle is a potential new claim).
  **Second**, adopt the documentation convention safety-security-
  sweep §7 Recommendation 2 names: "any guardrail claim that is
  honor-code carries an inline marker like `(asserted; not
  machine-enforced — see PRD-NNNN)` until enforcement lands." This
  makes the gap visible at the point of claim, not buried in an
  audit. The marker is itself forward-citation discipline — every
  honor-code claim names its closure OPP/PRD. **Third**, generalize
  beyond this framework: the audit mechanism is reusable by any
  consumer building their own enforcement layer. Auto-harness ships
  the governance contract; consumers can use the same audit shape
  against their own enforcement surfaces. This is the
  auto-harness-as-meta-framework story made operational.
- **Confidence:** medium-high. One strong instance (the safety
  sweep's table directly generated Wave 5's priority order,
  demonstrating actionability) plus prior partial instances (refresh-
  2's list-completeness audit was a claim-vs-enforcement
  classification at narrower scope; the catalog-counts validator was
  authored from exactly this kind of audit observation; the Wave 2a
  observation [[structural-enforcement-is-layered]] is the within-
  validator flavor). Three or more instances total across the
  project's history fits the §9 "three-instance generalizability"
  bar. **Promotion candidate to operating principle** — provisional
  working title: *"Classify-before-enforcing: every load-bearing
  claim is Enforced, Half-enforced, or Asserted-only; ship the
  classification before shipping the validators; the classification
  is the next-phase roadmap."* Recommend filing as a follow-up OPP
  when a fourth instance surfaces, per the §9 codification pattern
  (the deferred-implementations operating-principle promotion
  required three instances + a fourth instance witness in PRD-0014).
- **Severity:** architectural
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-27 (ADR-0017 drafting + 4 new OPPs; satisfies the cycle-end distillation rule fired by the ADR-0017 file creation + 4 new OPP creations; substantive connection — the observation captures the audit-mechanism learning that *grounds* ADR-0017's entire priority-setting frame; the prior Wave 2a observation [[structural-enforcement-is-layered]] is the explicit antecedent this observation builds on)

### Mechanizing doctrine surfaces PRD-internal inconsistencies that the design pass elided — third [[claim-vs-enforcement-classification]] instance (empirical, not transcribed)

- **Context:** Wave 5.1 (PRD-0006 implementation) shipped
  `validate-trust-tier.sh` — the 10th validator, closing the framework's
  centerpiece safety claims (no self-elevation; tier-ceiling fixed) per
  ADR-0017. The implementation pass surfaced an inconsistency between
  two FRs of the same PRD that the design pass had not anticipated.
  PRD-0006 FR-003 specifies strict "declared >= inferred" enforcement.
  PRD-0006 FR-002 specifies an inference table where `^.github/workflows/`
  → tier 4 and `^platform/core/kernel/` → tier 5. PRD-0006 FR-005
  specifies dogfood declarations including "kernel/base — Tier 0 (read-
  only doctrine)." The kernel's `sensitivePaths` declare `^.github/
  workflows/` (and `^scripts/`), which under the FR-002 inference table
  yield inferred tier 5. Under FR-003's strict rule, declared 0 < inferred
  5 fails. The PRD is internally inconsistent for the kernel module.
  The implementation pass surfaced two further cascading inconsistencies:
  if kernel declared tier 5 to satisfy strict, then per FR-003 step 2
  (agent-pack maxTier ≥ active floor) every active agent must have
  maxTier ≥ 5 — but FR-005 specified agents at maxTier 3/4. And the
  cross-cutting "tier 5 requires criticality high/critical" check from
  FR-003 step 3 fails on the harness's own manifest (criticality medium,
  maturity platform). The PRD's FR-005 declarations form a self-
  consistent set under a *permissive* reading of FR-003 ("inference is
  advisory floor; under-declaration warns"); under the *strict* reading
  the cascade requires three deviations (kernel = 5, agents maxTier
  bumped to 5, criticality check relaxed for maturity = platform). The
  maintainer chose strict via in-session AskUserQuestion, accepting the
  cascade.
- **Observation:** Mechanizing doctrine — converting an Asserted-only
  claim to an Enforced one — **surfaces PRD-internal inconsistencies
  that the design pass elided.** PRD-0006 was drafted carefully: 7 FRs,
  acceptance criteria, risk section, open questions resolved. The design
  pass nevertheless missed that FR-002 + FR-003 + FR-005 cannot
  simultaneously hold for the kernel module under either strict or
  permissive reading of FR-003 without modification. The inconsistency
  only becomes visible during implementation — when the validator
  actually runs against the harness's own state and produces violations.
  Honor-code prose can carry inconsistency indefinitely because no code
  ever checks it; mechanization is the first time the inconsistency is
  forced to resolve. **This is the third empirical confirmation of the
  [[claim-vs-enforcement-classification]] meta-pattern** — but unlike
  the prior two instances (refresh-2's list-completeness audit, the
  safety sweep's claim-vs-enforcement table), this one wasn't an audit
  *transcribing* an Asserted-only state; it was an *implementation*
  forcing resolution of an Asserted-only contradiction. Two flavors of
  the same meta-pattern: audit-driven discovery (the sweep) vs
  implementation-driven discovery (this PR). Both are valid; the
  implementation-driven mode is sharper because the contradiction is no
  longer optional to resolve.
- **Implication:** Three concrete moves; one already actionable, two
  prospective. **First**, the §9 "Split Design from Implementation"
  operating principle should be amended (or its companion practice
  noted): the implementation pass IS itself an audit pass for the
  preceding design. Each implementation PR should include an
  "Implementation Reconciliation" section in the change-log entry
  enumerating any deviations from the PRD it implements, with rationale.
  Wave 5.1's change-log entry establishes the format. **Second**, the
  [[claim-vs-enforcement-classification]] observation now has three
  documented instances: refresh-2 (audit), Wave 2b safety sweep (audit),
  Wave 5.1 (implementation-driven). The pattern is ripe for
  operating-principle promotion per the §9 three-instance bar. Filing a
  new OPP for "Classify-before-enforcing as an operating principle" is
  the natural next codification step. **Third**, every future PRD that
  ships before its implementation (which is most PRDs, per the
  §9 design-then-implementation pattern) should explicitly note in its
  Open Questions section: "Inconsistencies between FRs may surface
  during mechanization — the implementing PR carries the resolution
  authority." This is a small documentation discipline change that
  pre-clears the friction the Wave 5.1 reconciliation exercised.
- **Confidence:** high. Three confirmed instances of
  [[claim-vs-enforcement-classification]] now exist (two audit-driven,
  one implementation-driven). The implementation-driven mode is the
  most rigorous instance — it forced actual code-checked resolution,
  not just an analytical classification. Promotion to operating
  principle is justified by the §9 three-instance bar. The provisional
  title from the Wave 2b observation ("Classify-before-enforcing: every
  load-bearing claim is Enforced, Half-enforced, or Asserted-only; ship
  the classification before shipping the validators; the classification
  is the next-phase roadmap") stands; promotion via follow-up OPP is
  warranted.
- **Severity:** architectural
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-27 (Wave 5.1 PRD-0006 implementation; satisfies the cycle-end distillation rule fired by the validate-trust-tier.sh creation + 8 module.yaml edits + kernel.base sensitive-paths edit; substantive connection — the observation captures the *implementation-driven* discovery of the PRD-internal inconsistency that the Wave 5.1 reconciliation resolved, and which prior audit-driven [[claim-vs-enforcement-classification]] instances did not reach; the prior [[claim-vs-enforcement-classification]] observation from Wave 2b is the explicit antecedent — this is its third instance and the most rigorous confirmation)

### Successive structural-enforcement waves produce diminishing fix-up size — convergence signal

- **Context:** Wave 5.3 (this PR) shipped `validate-sensitive-paths.sh`
  — the 11th validator, closing safety-security-sweep §2 claim 12
  (sensitivePaths Asserted-only → Enforced) per OPP-0034 and ADR-0017.
  OPP-0034 Risk 3 explicitly predicted: *"The kernel's existing
  declarations all pass. v1 should ship with the harness's own tree as
  the dogfood test ... No fixing commit is needed (unlike Wave 1, which
  surfaced 6 pre-existing drift items)."* The prediction held. All 11
  active sensitive-path patterns are covered by some active module's
  companion-rule triggerPaths on first run. Wave 5.3 is the **first
  Wave 5 implementation that ships without a fixing commit.** Tracing
  the trajectory across the sprint: Wave 1 (list-completeness) surfaced
  6 fixing items (ADR-0015 missing plus 2 compositions plus 3 templates);
  Wave 5.1 (trust-tier) surfaced 4 cascading PRD-internal
  inconsistencies (kernel tier 5 reinterpretation, agent maxTier 3/4→5,
  criticality check relaxation, declared-vs-inferred semantic
  ambiguity); Wave 5.3 (sensitive-paths) surfaced 0 drift items.
- **Observation:** Successive structural-enforcement waves on the same
  framework produce **diminishing fix-up size** — a convergence signal.
  When a framework's first structural validator lands (Wave 1), it
  surfaces N drift items (the accumulated gap-set). When subsequent
  validators land against a framework that has already absorbed earlier
  validators' enforcement (Waves 5.1, 5.3), they surface fewer pre-
  existing drift items — because the prior validators have either
  already caught the drift (catalog rows) or set the discipline
  conditions that prevent its accumulation (claim-vs-enforcement
  audit-driven backfill). This is the **inverse** of the standard
  "complexity grows with feature count" intuition: when the features
  ARE enforcement layers, additional features REDUCE the rough-edge
  surface area, because each layer constrains the design space of the
  next. The trajectory is empirically observable across the sprint:
  6 → 4 → 0 fix-up-items per wave, with the §9 distillation chain
  (Wave 2a → 2b → 5.1 → 5.3 observations) tracking the pattern's
  generalization.
- **Implication:** Three concrete moves; two prospective. **First**,
  the pattern is a **diagnostic for framework enforcement maturity**.
  Run the [[claim-vs-enforcement-classification]] mechanism (per the
  earlier observation from this chain) periodically; track the
  Asserted-only count over time as an objective enforcement-maturity
  metric. A framework whose Asserted-only count is *decreasing* is
  converging; one whose count is *stable or growing* is accumulating
  enforcement debt faster than it is paying it down. This metric is
  trivially computable and surfaces strategic state. **Second**, the
  pattern suggests **sequencing matters** — the order in which
  structural validators land affects total fix-up cost. Wave 1 came
  first by design (the unblock); had Wave 5.1 or Wave 5.3 come first,
  they would likely have surfaced larger fix-up sets because the
  supporting enforcement layer (list-completeness) would not yet
  exist to constrain new ADR/PRD/OPP additions. The roadmap's Wave-1-
  first sequencing was inadvertently right for reasons beyond the
  "single highest-leverage item" framing — it was also the *first
  enforcement layer*, which makes every subsequent layer cheaper.
  **Third**, this is the **second confirmation that the §9 design-
  then-implementation pattern converges**: design (the OPP) makes a
  prediction; implementation tests the prediction; outcome refines
  the framework's self-model. Wave 5.1 disconfirmed FR-005's literal
  reading (PRD-internal inconsistency); Wave 5.3 confirmed OPP-0034
  Risk 3 (no fix-up needed). Both outcomes are valuable; neither
  would have been visible without the implementation pass.
- **Confidence:** medium. The trajectory is one sprint long (6 → 4 →
  0 across three waves). The pattern's generalizability would
  strengthen with Wave 5.5 (knowledge-redaction; small scope) and
  Wave 5.4 (SAST module; large scope) as additional data points. If
  Wave 5.5 also lands with ≤1 fix-up items and Wave 5.4 lands with
  ≤2 (despite its larger surface area), the convergence claim is
  well supported. Open question: at what point does fix-up cost
  stabilize rather than continue to decrease? Hypothesis: at the
  point where the Asserted-only set is approximately closed, fix-up
  cost approaches the *new-feature-friction* baseline (small,
  constant) rather than the *enforcement-debt* mode (larger,
  decreasing).
- **Severity:** architectural
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-28 (Wave 5.3 OPP-0034 implementation; satisfies the cycle-end distillation rule fired by the kernel/base/module.yaml validators-list edit; substantive connection — the observation captures the *convergence-signal* trajectory across the Wave 1 → 5.1 → 5.3 sequence which the prior [[claim-vs-enforcement-classification]] observations did not yet have enough data to articulate; the Wave 5.1 [[mechanizing-doctrine-surfaces-inconsistencies]] observation is the explicit antecedent — together the two observations form a complementary pair: implementation-driven discovery in 5.1 and prediction-confirmation in 5.3, both flavors of the §9 design-then-test pattern)

### Posture design is a third enforcement-absorption mechanism — fix-on-impl vs predict-clean vs warn-defer

- **Context:** Wave 5.5 (this PR) shipped
  `validate-knowledge-redaction.sh` — the 12th validator, closing
  safety-security-sweep §8 cross-pollination + §9 upstream-propagation
  pathways per OPP-0036 and ADR-0017. Unlike Waves 1 and 5.1 (which
  fixed pre-existing drift) and Wave 5.3 (which had no pre-existing
  drift to fix), Wave 5.5 ships against a knowledge surface with
  **50+ pre-existing consumer-name citations** in
  `shared-observations.md` alone. Naively, the validator would flag
  all 50+ on first run, breaking the framework's own state. But
  OPP-0036's design anticipated this: WARN posture (default exit 0;
  hits surface on stderr; `--block` flag for v2) lets the discipline
  absorb gradually without breaking existing state. The validator's
  diff-based scan (new-lines-only) means historical citations are
  invisible until they are re-touched. CI passes; reviewers eyeball
  warnings; the corpus stabilizes over time; eventually `--block`
  flips to default.
- **Observation:** Structural enforcement that lands against a
  framework with **pre-existing state has three design-time options**
  for handling the absorption tension. Each is a distinct mechanism;
  picking the right one depends on the cost of fixing existing state
  vs the cost of letting accumulation continue. **Mechanism 1: fix-on-
  implementation.** Wave 1 (list-completeness) and Wave 5.1 (trust-
  tier) both required fixing items as part of the implementing PR.
  Cost: time to find + fix; risk of scope creep. Benefit: clean state
  on day one. **Mechanism 2: predict-clean.** Wave 5.3 (sensitive-
  paths) shipped against state predicted (by OPP-0034 Risk 3) to be
  already-coherent; the prediction held. Cost: requires accurate
  upstream prediction. Benefit: zero fix-up; cleanest possible
  implementation. **Mechanism 3: posture-defer-via-warn.** Wave 5.5
  (knowledge-redaction) ships warning-only by default; existing state
  is technically out-of-policy but doesn't break; corpus stabilizes
  over time; a future v2 PR flips to default-block once "legitimate
  citations" are well-understood. Cost: enforcement debt persists
  longer; requires v2 follow-up commitment. Benefit: absorbs
  discipline without breaking existing state; reviewer-friendly
  during transition. The choice between mechanisms is **a first-class
  design decision** for any structural-enforcement OPP, not an
  implementation detail. OPP authors should explicitly call out which
  mechanism the implementation will use, with rationale.
- **Implication:** Three concrete moves; two prospective. **First**,
  the **[[claim-vs-enforcement-classification]] meta-pattern now has
  four documented instances** (refresh-2 audit, Wave 2b safety sweep,
  Wave 5.1 implementation-driven discovery, Wave 5.5 posture-design
  reflection). **The §9 three-instance bar is now exceeded;
  promotion to operating principle is overdue.** Recommend filing a
  new OPP (working title: "Classify-before-enforcing as operating
  principle") with the four instances cited and the provisional
  principle wording from the Wave 2b observation. This is the
  fourth-instance witness PRD-0014 needed for §9's own promotion —
  the pattern is empirically generalizable. **Second**, the **three
  absorption mechanisms** named above (fix-on-impl, predict-clean,
  warn-defer) are themselves a contribution to the OPP-authoring
  template. Future structural-enforcement OPPs should include an
  "Absorption mechanism" field naming which of the three the v1
  implementation will use, with rationale. Add to the OPP template
  in `platform/templates/opportunity/opp-template.md` as a follow-up.
  **Third**, the **warn-then-block evolution path** (Wave 5.5's v1 →
  v2) is itself a reusable discipline: any enforcement layer can
  ship in warn posture, gather field data on legitimate
  exceptions / corpus shape, then flip to block once the exception
  set stabilizes. This is a *runtime-design analog* of the §9
  design-vs-implementation pattern. Could be codified as a §9
  satellite.
- **Confidence:** medium-high. Four instances of the meta-pattern;
  three distinct absorption mechanisms observed; one sprint's worth
  of trajectory data. The promotion-to-operating-principle move is
  overdue (the §9 three-instance bar has been exceeded for at least
  one full session). The "three absorption mechanisms" framing is
  novel — it generalizes the convergence-signal observation by
  adding a third category (posture-defer) that the prior observation
  hadn't yet articulated. Open question: are there *other* absorption
  mechanisms beyond the three named? Hypothesis: yes — at least
  "incremental scope reduction" (validator covers a subset of the
  full surface in v1; expands per-release) is a fourth mechanism
  observed in `validate-doc-references.sh` v1→v2 evolution. Worth
  watching for additional instances during Waves 5.2 and 5.4.
- **Severity:** architectural
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-28 (Wave 5.5 OPP-0036 implementation; satisfies the cycle-end distillation rule fired by the kernel/base/module.yaml validators-list edit; substantive connection — the observation captures the *posture-design-as-third-mechanism* insight that emerged from authoring the WARN-posture validator, which the prior [[successive-enforcement-waves-diminishing-fix-up-size]] observation didn't yet have data to articulate; together with the Wave 5.1 and 5.3 observations this completes a three-mechanism framing for the enforcement-absorption tension; meanwhile the [[claim-vs-enforcement-classification]] meta-pattern's fourth-instance count makes operating-principle promotion overdue per §9 three-instance bar)

### Promotion OPPs are the §9 codification path's empirical resolution — filing OPP-0037 ratifies the §9 three-instance bar as load-bearing project discipline, not transcribed lore

- **Context:** OPP-0037 was filed against `docs/opportunities/` on
  2026-05-28 to promote the [[claim-vs-enforcement-classification]]
  meta-pattern to a new §10 operating principle. The OPP cites four
  documented instances (refresh-2 audit, Wave 2b safety sweep, Wave
  5.1 mechanizing-doctrine, Wave 5.5 posture-design) — exceeding the
  §9 three-instance bar by one. The OPP itself ships **design-only**
  per §9: the contract (which mechanism, which sections, which
  cadence claim) lives in the OPP; the implementation (the actual
  `operating-principles.md` edit adding §10) ships in a follow-up PR.
  This is the first time the §9 codification path has been exercised
  for a *promotion* (not a new doctrine surface) — and the first time
  §9 has been applied to its own codification cousin.
- **Observation:** **The §9 three-instance bar is now load-bearing
  project discipline, not transcribed lore.** §9 was itself codified
  after three instances (PRD-0011, PRD-0013, PRD-0014). When the
  next promotion candidate ([[claim-vs-enforcement-classification]])
  surfaced its third instance during Wave 5.1, the
  three-instance-bar rule fired — but the project deliberately waited
  for a fourth instance (Wave 5.5) before promoting. The wait was a
  signal: the bar isn't just *minimum* three instances, it's "three
  instances PLUS a beat to verify the pattern hasn't decayed." OPP-0037
  filed at the fourth-instance count, not the third, is the
  empirical confirmation that the discipline is being practiced as
  written, not just cited as written. **The §9 codification path is
  now self-validating** — its own three-instance bar generated the
  cadence that gated its first downstream codification.
- **Implication:** Three concrete moves; one already actionable, two
  prospective. **First**, OPP-0037's design-only posture (per §9)
  combined with `feedback-opp-to-implementation-no-prd`'s
  half-day-direct-implementation pattern (per Wave 5.3 + 5.5)
  produces a clean shape: OPP captures the design contract; the
  follow-up PR adds the operating-principles section + updates the
  TOC + the change-log entry; no PRD intermediate. This is the
  codification-via-promotion workflow shape for future operating-
  principle promotions; document it once in the implementing PR's
  change-log entry rather than re-deriving for each future
  promotion. **Second**, future distillation observations that cite a
  meta-pattern at *three* documented instances should mention that
  promotion is *eligible*, not *overdue* — and at *four* documented
  instances should mention that promotion is *overdue*. The Wave 5.1
  observation used "ripe"; the Wave 5.5 observation used "overdue";
  this calibration is now empirical. The OPP-template's "Why Now"
  field could carry a "promotion eligibility at instance N" rubric
  for §9-style codification OPPs specifically. **Third**, the
  operating-principles §10 edit (in the follow-up PR) should include
  a *"First applied"* paragraph mirroring §9's structure — citing
  the four documented instances by name, just as §9 cites
  PRD-0011/0013/0014. This makes the principle self-witnessing in
  the same shape §9 already established.
- **Confidence:** medium-high. One strong instance (this OPP filing,
  with the four-instance evidence already documented). The
  generalizability claim (that this shape codifies the
  operating-principle promotion workflow) rests on §9's own precedent
  — one prior codification, with the present OPP being the second.
  Two instances of "operating-principle codification via promotion
  OPP" don't yet meet the three-instance bar for *that* meta-
  meta-pattern, but the structural shape is consistent enough that
  documenting it as the working shape is justified. Open question:
  will the next operating-principle codification candidate (whatever
  it is) reuse the same shape, or will the shape pressure-test under
  a different content? Worth watching during the OPP-0037
  implementation PR and the next promotion cycle.
- **Severity:** architectural
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-28 (OPP-0037 filing; satisfies the cycle-end distillation rule fired by the OPP-0037 creation in `docs/opportunities/`; substantive connection — the observation captures the *promotion-workflow shape* that emerges from combining §9's design-only-OPP discipline with the half-day-direct-implementation pattern, neither of which prior observations addressed in combination; the Wave 5.5 [[posture-design-as-third-mechanism]] observation is the explicit antecedent — its closing implication recommended filing this promotion OPP; this observation is that filing's documented self-witness)

### §10 PRD Claim Classification block is a load-bearing PRD structural addition — PRD-0015 demonstrates the discipline at design-pass time, not just at audit-pass time

- **Context:** PRD-0015 (Skill Content Safety Validator) was filed on
  2026-05-28 to specify Wave 5.2 of ADR-0017 (the
  `validate-skill-content.sh` validator). It is the FIRST PRD
  authored after §10 ("Classify Claims Before Enforcing Them") was
  codified to operating-principles. The PRD's body includes a
  **dedicated `## §10 Claim Classification` block** between Non-Goals
  and Target Audience, naming each load-bearing claim being converted
  from Asserted-only to Enforced (C-V1, C-V2, C-V4, C-V6) plus the
  claims explicitly NOT converted (V3, V5, V7–V10) plus the
  Half-enforced fall-back (C-V4 partial).
- **Observation:** §10's classification mechanism, originally framed
  as an *audit-time* discipline (Wave 2b safety sweep enumerated 19
  claims and triaged them; the framework's Wave 5 roadmap was the
  output), generalizes cleanly to *design-time*: every new structural
  enforcer's PRD can include a §10 Claim Classification block that
  forces the PRD author to enumerate exactly which Asserted-only
  claims this enforcer converts, which it leaves unconverted, and
  which it half-converts. **The classification block IS the PRD's
  contract with the safety-debt ledger.** A PRD that doesn't enumerate
  its claim-conversions allows scope creep: the implementing PR can
  silently expand or contract what was supposedly "specified" without
  visible deviation. The §10 block makes that contract explicit and
  reviewable.
- **Implication:** Three concrete moves; one already actionable. **First**,
  the **PRD template at `platform/templates/product/prd.md` should
  gain an optional `## §10 Claim Classification` section** with
  guidance: "When this PRD ships a structural enforcer (validator,
  schema rule, lint check), enumerate each load-bearing claim being
  converted from Asserted-only to Enforced. Use the three-bucket
  framing per §10. Claims explicitly NOT converted are themselves
  load-bearing — name them so the next PRD knows what's still
  Asserted-only." Filed as follow-up; not in PRD-0015's same-PR
  scope. **Second**, **future PRD reviews should check** that the
  §10 block's claim list matches the PRD's FRs — every claim
  converted should map to at least one FR, every FR should map back
  to at least one claim. This is a self-consistency invariant the
  reviewer can mechanically check. **Third**, the
  Implementation Reconciliation pattern from Wave 5.1 should explicitly
  flag *§10 classification deviations* — if the implementing PR finds
  it converted a claim the PRD didn't name (or failed to convert one
  the PRD claimed), that's a §10 reconciliation, not a routine
  reconciliation. Promote that distinction in the implementing PR's
  change-log.
- **Confidence:** medium. One strong instance (PRD-0015's §10 block
  is concrete, traceable to four named claims, and forced explicit
  Non-Goal enumeration that the OPP-0033 evidence section did not).
  Generalizability to all structural-enforcer PRDs rests on §10's own
  generalizability — already validated across four instances of the
  meta-pattern. But the *design-time* application (vs §10's prior
  audit-time applications) is novel; needs at least one more PRD to
  confirm the block doesn't degenerate into a perfunctory checklist
  field. Watch the next Wave 5.4 PRD (or whatever PRD comes next) for
  whether the §10 block stays substantive or becomes ceremonial.
  Open question: should the §10 block also appear in ADRs that
  decide enforcement-roadmap priority order (like ADR-0017 itself)?
  ADR-0017 implicitly classifies via its Wave order; making it
  explicit via a §10 block might be redundant or might add reviewer
  signal — unclear.
- **Severity:** architectural
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-28 (PRD-0015 filing + OPP-0033 status flip; satisfies the cycle-end distillation rule fired by both the PRD creation in `docs/requirements/` and the OPP edit in `docs/opportunities/`; substantive connection — the observation captures the *design-time application* of §10 that PRD-0015 demonstrates; the prior [[claim-vs-enforcement-classification]] meta-pattern observations all addressed audit-time applications; PRD-0015's §10 block is the first instance of design-time application, completing the principle's generalization from audit to design)

### Test-seam API additions are a class of implementation-time additions that should NOT count as §10 design-vs-implementation deviations — they don't change which claims are enforced, only how enforcement can be tested

- **Context:** Wave 5.2 implementation (`validate-skill-content.sh`)
  was authored from PRD-0015's seven Must-Have FRs. During
  implementation, the FR-005 acceptance criterion ("the test suite
  iterates fixtures, scans each with `validate-skill-content.sh`, and
  asserts exit 1") collided with a known architectural constraint:
  the validator computes `PLATFORM_ROOT` from its own script location,
  making synthetic-module fixture tests require a platform-root-
  override that's out of v1 scope (the same constraint Wave 5.1 and
  Wave 5.3 hit). The implementation pass resolved this by adding a
  small `--scan-file <path>` mode to the validator — a direct content
  scanner that bypasses the active-module gating. The PRD did not
  anticipate this surface; the implementation added it.
- **Observation:** The `--scan-file` addition is **not** a §10
  design-vs-implementation deviation in the Wave 5.1 sense (where
  PRD-0006's FR-002/003/005 had latent contradictions that
  mechanization forced to resolve). It is a **test seam** — an
  additive ergonomic feature that doesn't change which load-bearing
  claims the validator enforces. The §10 Claim Classification block
  in PRD-0015 still holds verbatim (C-V1 / C-V2 / C-V4 partial / C-V6
  all converted to Enforced; Half-enforced fallback for C-V4
  unchanged; Out-of-scope set unchanged). The seven Must-Have FRs all
  hold. Only the implementation surface gained a small additional
  command-line mode that simplifies fixture testing and ad-hoc
  adversarial-corpus exercise. **Test seams are a recognized
  programming-discipline category, not a contract change.** Naming
  this distinction up front prevents future "did the implementation
  deviate from the PRD?" reviews from flagging additive ergonomics as
  drift.
- **Implication:** Three concrete moves; one already actionable.
  **First**, the Implementation Reconciliation pattern from Wave 5.1
  should explicitly carve out a **"Test seams and ergonomic additions
  are not deviations"** clause. Implementing PRs may add such
  features without triggering a §10 reconciliation; the change-log
  entry should still name the addition for audit purposes (which this
  PR does), but the addition does not count against PRD-implementation
  congruence. **Second**, future PRDs for structural enforcers should
  consider adding a `--scan-file` (or equivalent direct-content-test)
  mode as a Must-Have FR up front, since (a) every prior wave hit the
  same platform-root constraint, and (b) the test seam is small and
  useful. The pattern is now thrice-evidenced (trust-tier, sensitive-
  paths, skill-content all had the constraint; skill-content is the
  first to solve it with a direct mode). **Third**, the predict-clean
  absorption mechanism (per `feedback-validator-absorption-mechanisms`)
  is now thrice-confirmed across distinct posture choices: Wave 5.3
  (predict-clean strict via OPP-0034), Wave 5.5 (predict-clean via
  WARN-posture-as-graceful-coverage per OPP-0036), Wave 5.2
  (predict-clean strict via BLOCK-posture per PRD-0015). 51 sources
  scanned with zero hits on first run = the prediction held.
- **Confidence:** medium-high. One strong instance (this PR's
  `--scan-file` addition is concrete and traceable). The
  generalizability rests on the same constraint having surfaced
  three times — the platform-root-fixed validator pattern is now
  well-evidenced, and a test seam is the natural resolution. The
  Implementation Reconciliation carve-out is a small documentation
  discipline change; needs at least one more PR's worth of evidence
  before promotion to operating-principle status. Open question: is
  there a *category* of design-time additions that, like test seams,
  are additive-and-ergonomic-only and don't count as §10 deviations?
  Hypothesis: yes — at least `--verbose`/`--quiet` mode additions and
  `--help`-text expansions also fit this category. Watch the next
  Wave 5 implementation PR for additional instances.
- **Severity:** programming-discipline
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-28 (Wave 5.2 implementation; satisfies the cycle-end distillation rule fired by the kernel/base/module.yaml validators-list edit; substantive connection — the observation names a new programming-discipline distinction (test seams as additive non-deviations) that the prior [[§10-prd-claim-classification-block]] observation did not address; together they form a pair: the prior observation formalizes the design-time classification surface, this observation carves out what additions don't disturb that surface)

### Half-enforced is a load-bearing third state of the §10 vocabulary — PRD-0016 ships the first explicit Half-enforced claim, not as an Asserted-only-with-handwave

- **Observation:** PRD-0016 (Wave 5.4 design pass for `management/security-static-analysis`) is the **first PRD to explicitly classify a load-bearing claim as Half-enforced** in its §10 Claim Classification block. C-SAST-S1 ("the harness has machinery for consumers to structurally adopt SAST coverage as a quality gate") is Asserted-only today and becomes Half-enforced after v1 — because the harness provides the opt-in scaffolding, but **enforcement of the actual SAST tool run happens in consumer CI**, which the harness alone cannot guarantee. PRD-0015 (the first PRD authored under §10) shipped only Enforced and Asserted-only classifications. PRD-0016 ships an explicit Half-enforced one, exercising the third leg of the §10 vocabulary for the first time at design pass time.
- **Why it matters:** §10 codified three states (Enforced / Half-enforced / Asserted-only) but the Half-enforced state had only been demonstrated in the operating-principle prose, not in concrete PRD-time application. PRD-0016 demonstrates that the Half-enforced category is not a hedge or a transitional state on the way to Enforced — it is sometimes the **honestly-correct end state** for a load-bearing claim. Opt-in posture modules categorically cannot be fully Enforced by the framework alone; they require consumer-CI cooperation. Without the Half-enforced vocabulary, a PRD author would either (a) overclaim by labeling C-SAST-S1 as Enforced and silently relying on consumer goodwill, or (b) underclaim by labeling it Asserted-only and obscuring the real machinery being added. Half-enforced names the actual epistemic state.
- **Implications:** future PRDs introducing **opt-in management overlay** modules (the eval-gated-testing precedent, this PRD, and any future opt-in posture module) should expect Half-enforced classifications. The §10 PRD template addition recommended in [[§10-prd-claim-classification-block]] should explicitly note that Half-enforced is appropriate for opt-in surfaces where the framework cannot guarantee consumer-side enforcement. Reviewers should not push back on Half-enforced classifications as "incomplete" — they may be the most honest available state.
- **Confidence:** medium-high. One concrete instance (this PRD). Generalizability rests on the structural argument: any opt-in posture surface that depends on consumer-CI cooperation is categorically un-fully-Enforceable by the framework alone, and that pattern recurs across all `management/*` overlay modules. Two prior management overlays exist (`testing-standard`, `eval-gated-testing`) but predate §10 and were never §10-classified; if either were retroactively classified now, both would also yield Half-enforced claims, which would corroborate the pattern.
- **Severity:** programming-discipline
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-28 (Wave 5.4 PRD-0016 design pass; satisfies the cycle-end distillation rule fired by the PRD-0016 addition + the OPP-0035 status-flip edit per PRD-0004; substantive connection — exercises the third leg of the §10 vocabulary that prior [[§10-prd-claim-classification-block]] formalized but that PRD-0015 itself did not exemplify, demonstrating that the Half-enforced category is a load-bearing distinct state, not a hedge)

### Opt-in-module-activation gating is a fourth variant of the predict-clean absorption mechanism — distinct from dogfood-predict-clean

- **Observation:** Wave 5.4 (`validate-sast-coverage.sh` per PRD-0016) introduces a **fourth structural variant** of the predict-clean absorption mechanism documented in [[posture-design-as-third-mechanism]] and [[feedback-validator-absorption-mechanisms]]. Prior predict-clean instances (Wave 5.3 `validate-sensitive-paths.sh`, Wave 5.5 `validate-knowledge-redaction.sh`, Wave 5.2 `validate-skill-content.sh`) all worked by **scanning the harness's own active-module surface and predicting zero hits** — the "predict-clean dogfood scan" shape. Wave 5.4's mechanism is different: the validator's substantive work is **gated on whether the consumer's manifest activates `management/security-static-analysis`**. The harness does not activate the module; the validator's no-op-pass path is what the harness's CI exercises. There is **no dogfood scan** because there is no harness-side artifact to scan. The harness CI is clean by structural gating, not by scan-and-predict.
- **Why it matters:** The taxonomy in [[feedback-validator-absorption-mechanisms]] documented three mechanism families (fix-on-impl, predict-clean, warn-defer-via-posture) and the prior observation [[posture-design-as-third-mechanism]] called out posture as a separate design axis. Wave 5.4 surfaces that **within predict-clean itself there are at least two distinct mechanisms**: (a) **dogfood-predict-clean** — the harness has the active surface, the validator scans it, the prediction is "zero hits" (Waves 5.2/5.3/5.5 shape); (b) **gated-predict-clean** — the harness does NOT have the active surface, the validator detects module-inactivity and short-circuits to exit 0 (Wave 5.4 shape). Both reach "harness CI is clean from day one" but via structurally different machinery. The distinction matters because: (i) gated-predict-clean validators have no historical-state risk at all — there cannot be pre-existing violations because there is no surface to violate; (ii) they don't need an exemption file (`.skill-content-ignore` etc.) because there are no exemptions to grant; (iii) they ship with a categorically simpler test surface (the dogfood test asserts only the inactive-path exit message, not a content scan); (iv) the validator's `--scan-file` test-seam carries the actual content-validation contract, not the manifest path.
- **Implications:** Future opt-in management overlays should expect gated-predict-clean as the default mechanism. The recommendation pattern for module-yaml-bearing PRDs is now: **(1) name the absorption mechanism (likely gated-predict-clean for opt-in overlays); (2) name the §10 disposition (likely Half-enforced for opt-in surfaces per [[half-enforced-is-a-load-bearing-third-state-of-the-section-10-vocabulary]]); (3) adopt `--scan-file` test-seam from day one because the dogfood test alone is structurally insufficient — the substantive content-validation contract lives in test-seam mode**. The three observations form a cluster covering the design contract surface for opt-in posture modules.
- **Confidence:** medium. One concrete instance (Wave 5.4) but a strong structural argument that the pattern recurs. Two prior management overlays exist (`testing-standard`, `eval-gated-testing`) that, if retroactively classified, would both fit the gated-predict-clean shape because they too rely on `validate-required-artifacts` + `validate-companions` and contribute no harness-side content. The `management/eval-gated-testing` PRD-0009 didn't ship a custom validator; Wave 5.4 demonstrates the mechanism even when a custom validator *is* present. The distinction is robust to validator presence/absence.
- **Severity:** programming-discipline
- **Contributed by:** Claude Code (claude-opus-4-7), 2026-05-28 (Wave 5.4 implementation; satisfies the cycle-end distillation rule fired by the kernel `validators:` list edit + the OPP-0035 status flip + the new module.yaml addition per PRD-0004; substantive connection — refines the predict-clean mechanism taxonomy from [[posture-design-as-third-mechanism]] by surfacing a fourth variant; together with [[half-enforced-is-a-load-bearing-third-state-of-the-section-10-vocabulary]] and [[§10-prd-claim-classification-block]] this forms a three-observation cluster covering the design-contract surface for opt-in posture modules)

### Promoting the cross-consumer sub-modules first is the highest-value wedge when partially accepting a multi-sub-module domain OPP

- **Context:** OPP-0013 decomposed healthcare into twelve `domains/healthcare-*` sub-modules, derived subsystem-by-subsystem from OpenEMR (a provider/server-side EHR). A second consumer — Tula, a patient-authorized client — exercised only two of those twelve (`healthcare-fhir` and `healthcare-smart-on-fhir`), and from a *different trust role* (patient-access, `patient/*.read`, patient-as-resource-owner) than OpenEMR's provider-launch role. When OPP-0013 was partially accepted (2026-06-01, PRD-0017), the promoted wedge was exactly those two cross-consumer sub-modules — not the largest subset, not the most "foundational" EHR subset.
- **Observation:** When a multi-sub-module domain OPP is *partially* accepted, the highest-value wedge is the subset exercised by **multiple consumers across distinct roles**, not the biggest or the most upstream subset. The cross-consumer slice is precisely where the generalizable framework questions concentrate — jurisdiction-neutrality (FHIR is international; US Core / IPS / UK / AU are profiles on top) and trust-role modeling (one technology, two trust roles, modeled as a documented axis rather than duplicate modules). Building that slice first ships value to the most consumers AND pressure-tests the reusable pattern on real divergent usage before it is generalized.
- **Implication:** Deep-domain families (healthcare now; finance, logistics, manufacturing, security later) should be promoted wedge-first along the cross-consumer axis. Two reusable primitives surfaced from this wedge and are the first harvest candidates: (1) the **jurisdiction-profile forcing artifact** (a required doc that makes the consumer declare region/profile, with a bias guardrail so no jurisdiction — including the author's own — is the default); (2) **trust-role-as-documented-axis** (model multiple roles of one technology inside one module's required artifact, not as sibling modules). These should be harvested into an operating-principle only after the wedge proves them across a second vertical, per the concrete-first sequencing this initiative adopted.
- **Confidence:** low-medium. One concrete instance (OPP-0013 → PRD-0017). The structural argument generalizes: any deep regulated vertical decomposes into many technology-bounded sub-modules, but only a few are exercised by multiple consumer roles, and those few are where cross-cutting framework decisions must be validated. Corroboration awaits the second vertical (finance or logistics) instantiating the same wedge-first pattern.
- **Severity:** architecture
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-01 (healthcare wedge Phase 1; satisfies the cycle-end distillation rule fired by the OPP-0013 status-flip edit per PRD-0004; substantive connection — captures the discovery technique behind the OPP-0013 partial-promotion decision: promote the cross-consumer / role-spanning subset first, and names the two reusable primitives the wedge surfaces, rather than restating the OPP's content)

### Off-enum status values pass the validator suite but fail documented-vocabulary consistency — normalize to the enum, carry nuance in prose

- **Context:** OPP-0013 was first recorded (PR #90) with `**Status:** partially-accepted` to express that only two of its twelve proposed sub-modules were promoted. All 14 validators passed — **no validator enforces the OPP status enum** (`proposed | exploring | accepted | declined | superseded`, documented in `docs/opportunities/README.md`). The off-enum value was caught only by Copilot's PR review, after merge.
- **Observation:** The validator suite enforces structural and companion rules but **not controlled-vocabulary membership** for metadata fields like `Status`. An invented status value therefore sails through CI green while silently breaking the state-machine vocabulary that humans and any future tooling depend on. The enum lives in the ADR-gated opportunity-capture README; extending it is a governance decision, not an authoring convenience.
- **Implication:** When a record's real state is not cleanly one enum value (e.g., a multi-sub-module OPP only partly promoted), use the nearest documented enum value — here `accepted`, which also satisfies the promotion contract via the referenced PRD-0017 — and express the nuance ("partial promotion: two of twelve sub-modules; the remainder stay proposed within this OPP") in the **Disposition prose**. PRD-0007 already sanctions "partially accepted" as Disposition vocabulary, distinct from the Status enum. Minting a new status value requires an ADR to extend the enum. A lightweight status-enum-membership check would close the gap that let this reach post-merge review.
- **Confidence:** medium. One instance, but the underlying gap (no enum enforcement) is directly verifiable and general to every controlled-vocabulary metadata field in the harness.
- **Severity:** programming-discipline
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-02 (Copilot review remediation on PR #90; satisfies the PRD-0004 distillation rule fired by the OPP-0013 re-edit; substantive connection — generalizes the specific Copilot finding into a reusable lesson about the validator-vs-vocabulary gap, names the within-enum-plus-prose resolution and the ADR path for a genuine enum extension, and pairs with the preceding cross-consumer-wedge observation from the same initiative)

### The adopter-artifact / host-IP attribution boundary is computable from git first-authorship

- **Context:** During a brownfield second-pass onboarding of a fork-held external consumer (a fork held by the harness maintainer, instrumented to explore whether the resulting governance would interest the upstream owner), the intake-authored governance artifacts had been stamped `Owner: @adopter (HostOrg)` — badging the adopter with the *host project's* company identity. HostOrg is the original owner and trademark holder, not the adopter. No validator caught it; the human maintainer did.
- **Observation:** The boundary between "artifacts the adopter created" (theirs to author) and "the host project's original IP" (never to re-attribute) is not a judgment call — it is directly computable from `git log --diff-filter=A` (first-add authorship). In the incident the partition fell *exactly* on first-authorship: every mis-stamped file was first-added by the adopter at intake; every file carrying legitimate host-org references (the original README / OPEN_CORE / TRADEMARK / articles, which state the owner's actual trademark rights correctly) was first-added by the original maintainer.
- **Implication:** Because the boundary is computable, the attribution discipline is a candidate for *tooling*, not merely guidance — a `validate-attribution`-style check could flag adopter-authored files that assert the host org's identity or trademarks, given manifest-declared host-owner / adopter identities. More broadly, brownfield adopters are very often *not* the host project's legal owner (forks, outside contractors, internal platform teams), so "how does an adopter sign artifacts without asserting rights" is a recurring, harness-general question. Filed as OPP-0038 (design deferred pending more adoptions).
- **Confidence:** medium-high on computability (directly verified in one incident; `git` first-authorship is deterministic). Medium on the eventual convention's generalizability — which is why the OPP defers design.
- **Severity:** governance-relevant
- **Contributed by:** @unclenate via Claude Code, 2026-06-02 (consumer-adoption distillation; satisfies the PRD-0004 distillation rule fired by adding [[OPP-0038]]; substantive connection — this observation is the de-identified evidence OPP-0038 cites, and names the computable-from-git-first-authorship mechanism that makes the OPP's proposed `validate-attribution` check feasible)

### Jurisdiction-neutral-core is the correct default design for international-standard domain overlays — not a regional default with a carve-out

- **Context:** `domains/healthcare-fhir` (PRD-0017, Tasks 3–4) governs HL7 FHIR, which is an international standard. When designing the overlay, the question arose: should the module default to US Core (the author's jurisdiction) and treat other profiles as opt-in deviations? Or should it start jurisdiction-agnostic and *force* the consumer to declare theirs via a required artifact?
- **Observation:** The jurisdiction-neutral-core design is categorically correct for any overlay governing an international standard. Defaulting to the author's jurisdiction embeds a regional assumption into a cross-regional standard — every non-US consumer inherits a mismatch silently. The neutral design instead surfaces the jurisdiction question as a *required* consumer decision (a forcing artifact: `docs/healthcare/jurisdiction-profile.md`), ensuring the bias is never invisible. The same logic applies symmetrically to any future overlay for an international standard (DICOM, HL7v2, SNOMED CT, ICD-10, ISO 27001 controls, etc.).
- **Implication:** When authoring overlays for international standards, the default template should be: (1) jurisdiction-neutral core; (2) required `jurisdiction-profile.md` artifact with a bias guardrail in the template; (3) `sensitivePaths` tuned to the standard's PHI/PII surface, not to any jurisdiction's additional requirements. Jurisdiction-specific profiles (US Core, IPS, UK Core, AU Base) belong in optional artifacts or consumer-side extensions, not in the base overlay. Reviewers should push back on domain overlays for international standards that bake in a regional default without an ADR justifying the narrowing.
- **Confidence:** medium. One concrete instance (`healthcare-fhir`). The structural argument extends to any overlay for a published international standard; HL7 FHIR is a clear exemplar because the gap between the standard and its regional profiles is well-documented and the bias risk is high (HIPAA is not GDPR is not UK DSP Toolkit).
- **Severity:** architecture
- **Contributed by:** Claude Code (claude-sonnet-4-6), 2026-06-02 (healthcare wedge Tasks 3–4; satisfies the PRD-0004 distillation rule fired by the new platform/profiles/domains/healthcare-fhir/module.yaml addition; substantive connection — captures the jurisdiction-design decision that distinguishes this overlay from a naive US-Core default, and generalizes it to future international-standard overlays)

### A submodule pin bump silently widens the gap between the harness's recommended CI template and the consumer's adopted validator chain

- **Context:** A fork-held external consumer (a Node/TypeScript agent-skill-pack project) carries the harness as a `.harness` git submodule and wires a fixed list of validator invocations into its own `.github/workflows/`. During a routine pin bump (advancing the submodule pointer by ~28 upstream commits), the upstream range had added six new validators and extended the recommended CI template (`platform/templates/ci/github-actions.yml`) with five new steps (trust-tier, sensitive-paths, skill-content, knowledge-redaction, sast-coverage). The consumer's workflow was unchanged by the bump — it kept invoking only the original six-validator chain.
- **Observation:** A pin bump moves the *trusted commit* but never moves the *invocation list*. After the bump the consumer runs the new harness **code** against its old **call set**, so it silently consumes none of the newly-recommended gates. The drift is invisible at bump time: every validator the consumer *does* call still passes, CI is green, and nothing signals that the recommended template has moved ahead. The bump is correctly classified as routine — a bare gitlink change trips no companion rule and is exactly the "version bump" the distillation trigger set deliberately excludes — yet "routine" masks a real and growing capability gap.
- **Implication:** There is an unclosed drift class between "what the harness recommends" (the CI template) and "what a consumer enforces" (its workflow), and pin bumps *widen* it monotonically. Candidate harness responses: (a) an onboarding/runbook step that diffs the consumer's workflow against `platform/templates/ci/github-actions.yml` after any pin bump and reports newly-recommended-but-unadopted steps; (b) a `validate-ci-currency`-style advisory validator (WARN posture) that a consumer can opt into; (c) a CHANGELOG/release-note convention upstream that flags "new consumer-CI step recommended" so bumps carry an adoption signal. This is design-shaped, not yet specced — an OPP candidate, not a built thing.
- **Confidence:** medium-high. One concrete instance, but the mechanism is structural: any submodule-consuming project pins a commit and hard-codes its own invocation list, so the two surfaces can only be kept in sync by an explicit reconciliation step that does not exist today. The gap is guaranteed to recur on every bump that adds validators.
- **Severity:** governance-relevant
- **Contributed by:** @unclenate via Claude Code, 2026-06-01 (consumer-adoption distillation, not harness-self work; surfaced while bumping an external consumer's `.harness` pin. Logged as an observation rather than forced into the consumer's own docs because the insight is about the *harness's* recommend-vs-adopt seam, not the consumer — and per the cycle-end-distillation anti-pattern guidance, the consumer-side bump was routine and did not itself warrant a consumer observation)

### Forked consumers hit a wrong-base default when opening adoption PRs with `gh pr create`

- **Context:** The same fork-held consumer opens governance PRs (intake, CI wiring, pin bumps) against its own `main`. `gh pr create` with no explicit repo flags repeatedly failed with `GraphQL: No commits between main and <branch>` / `Head sha can't be blank`, despite `git ls-remote` confirming the branch and `main` differed by exactly one real commit.
- **Observation:** Because the consumer repo is a GitHub *fork*, `gh` defaults the PR base to the **upstream parent** repository and compares the parent's `main` against the head branch — a comparison with no shared commits — producing a misleading "no commits between" error that reads like a local-state problem but is actually a base-targeting problem. The fix is to pin both sides explicitly: `gh pr create --repo <owner>/<fork> --base main --head <owner>:<branch>`.
- **Implication:** Brownfield consumers are very often *forks* (the maintainer explores governance on a fork before proposing it upstream — the recurring pattern across the fork-held consumers in this catalog). The harness-onboarding guidance should carry an explicit note: when the consumer repo is a fork, PR-creation tooling needs explicit base/head repo qualification, or contributors will burn time diagnosing a phantom "empty diff." Cheap to document, high-friction to rediscover.
- **Confidence:** high. Reproduced deterministically; root cause is well-understood `gh` fork-default behavior, not project-specific.
- **Severity:** informational
- **Contributed by:** @unclenate via Claude Code, 2026-06-01 (consumer-adoption distillation; tooling-friction note relevant to any fork-held brownfield consumer onboarding the harness)

### The deep-domain primitives (neutral-core + forcing-artifact + bias-guardrail) generalize beyond domains to cross-cutting concerns — privacy-by-design is the first reuse

- **Context:** The deep-industry-domain framework (healthcare wedge) produced three reusable primitives: a **jurisdiction-neutral core**, a **forcing artifact** (`jurisdiction-profile.md` — the consumer must declare their jurisdiction), and a **bias guardrail** (no jurisdiction is the default). `management/privacy-by-design` (Phase 2) reuses all three for a **cross-cutting concern, not a vertical domain**: Cavoukian's 7 principles are the jurisdiction-neutral spine; `privacy-profile.md` is the forcing artifact (the consumer declares their legal regime — GDPR / CCPA / LGPD / …); the bias guardrail is "no legal regime is the default."
- **Observation:** The structural pattern — **a universal/neutral floor + a consumer-declared variant + a guardrail against assuming a default variant** — is not domain-specific. It recurs whenever a concern has an international/neutral core and jurisdictional/contextual variance. Three instances now share it: healthcare (FHIR + jurisdictional profiles), privacy (principles + legal regimes), and — per the construction research brief — AEC (ISO 19650 + national annexes). Privacy is the first instance that is a *cross-cutting management overlay* rather than a `domains/*` vertical, which is the evidence that the primitives are a **general governance pattern**, not a domain convenience.
- **Implication:** When the deep-domain framework is harvested into an operating-principle, scope it as a **general primitive** ("neutral-core + forcing-artifact + bias-guardrail for any concern with a neutral core and contextual variance"), not a domains-only one. The harvest case now rests on 1 built domain (healthcare) + 1 cross-cutting reuse (privacy); the construction vertical will be the confirming 2nd domain. The privacy module also reuses the established opt-in-management-overlay mechanics (module-gated WARN-posture validator, dogfood-deferred so the harness's own CI stays green) — see [[feedback-validator-absorption-mechanisms]].
- **Confidence:** medium. Two implemented instances sharing the structural pattern (healthcare domain + privacy cross-cutting), plus a third designed (construction). The cross-cutting reuse is the load-bearing new evidence.
- **Severity:** architecture
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-03 (privacy-by-design Phase 2 module addition; satisfies the PRD-0004 distillation rule fired by `platform/profiles/management/privacy-by-design/module.yaml`; substantive connection — names the cross-vertical reuse the module embodies and its consequence for scoping the eventual framework harvest as a general governance primitive rather than a domains-only one)

### A deep-domain vertical can be grounded in a standard + research brief alone — the evidence pattern shifts from "observed subsystem boundaries" to "standard-defined concern boundaries"

- **Context:** OPP-0039 designates AEC/construction as the second built deep-domain vertical and promotes a three-module ISO 19650 + openBIM wedge (PRD-0019). Unlike healthcare (OPP-0013), which was grounded in two real consumer codebases — OpenEMR (provider role) and Tula (patient role), each sub-module anchored to an observed code path — AEC has **no brownfield consumer codebase** in hand. The wedge boundary was instead lifted from the structure of the standards themselves (a committed research brief on ISO 19650 parts 1–6, openBIM IFC/BCF/IDS, and ISO 19650-5).
- **Observation:** A deep-domain OPP does not require a consumer codebase to be well-grounded. When a domain is governed by mature, well-partitioned international standards, the standard's own concern boundaries supply the decomposition evidence: ISO 19650 *information management* (CDE/containers/actors), openBIM *exchange* (IFC/IDS/roles), and ISO 19650-5 *security* are distinct, standard-defined concerns that map one-to-one onto modules — exactly as OpenEMR's `src/FHIR/`, `src/FHIR/SMART/`, and `src/Encryption/` did, but derived from the spec rather than the repo. The evidence pattern shifts from "observed subsystem boundaries in a codebase" to "concern boundaries defined by the standard," and the bias risk shifts correspondingly (for AEC, over-documentation of the UK BS EN + Uniclass path rather than US-healthcare assumptions).
- **Implication:** For standards-rich domains where no single consumer codebase exercises the whole surface (AEC, but also likely finance/ISO 20022, logistics/GS1, manufacturing/ISA-95), ground the OPP in the standard's partition and flag the absence of a consumer codebase explicitly as a Risk (refine sensitive-path regexes against a real repo when one onboards). Reviewers should accept standard-derived decomposition as first-class evidence, not a weaker substitute for code-path grounding — but should require the standard-partition rationale to be as concrete as a code-path anchor would be.
- **Confidence:** medium. One instance (AEC/OPP-0039), but it contrasts cleanly with the code-grounded healthcare precedent and the partition logic generalizes to any standard-partitioned domain.
- **Severity:** architecture
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-04 (AEC wedge Phase 1; satisfies the PRD-0004 distillation rule fired by the new `docs/opportunities/OPP-0039-domain-family-aec-decomposed.md`; substantive connection — captures the standard-vs-codebase grounding distinction behind OPP-0039's decomposition and generalizes it to the next standards-rich verticals, rather than restating the OPP's content)

### The AEC wedge is the second domain instance of the deep-domain primitives — it adds a compound forcing artifact and the catalog's first domain × cross-cutting composition

- **Context:** The AEC wedge implementation (PRD-0019, Phase 2) shipped three `domains/aec-*` modules (`aec-iso19650-im` + `aec-openbim-exchange` + `aec-iso19650-5-security`), five `platform/templates/aec/` artifacts, and the `aec-bim-project.yaml` composition. It is the second *built* domain instance of the deep-domain primitives (neutral-core + forcing-artifact + bias-guardrail + trust-role) after healthcare, and the first to compose a domain family with a cross-cutting concern.
- **Observation:** AEC surfaces two enrichments a single domain (healthcare) could not. First, a **compound** forcing artifact: the `jurisdiction-profile.md` is `{National Annex} × {AHJ + code edition} × {classification}` — three axes — versus healthcare's single jurisdiction axis, demonstrating the forcing-artifact primitive scales from one axis to N without changing the bias-guardrail mechanism (default-deny the over-documented path; force an explicit declaration). Second, the catalog's first **domain × cross-cutting composition**: `aec-iso19650-5-security` composes with `management/privacy-by-design` — built-asset sensitivity versus occupant personal-data privacy — documented (in the security README and the `sensitivity-assessment.md` template's reference to the privacy regime) so the two concerns neither overlap nor leave a gap.
- **Implication:** With two shipped domains (healthcare, AEC) plus the privacy cross-cutting, the deep-domain primitives now have three independent reuse instances — the evidence bar the design spec set for promoting them to an operating-principle in the harvest pass. The compound forcing artifact and the documented domain × cross-cutting composition boundary are the two patterns the harvest should generalize beyond their AEC-specific wording; future standards-rich verticals with multi-axis jurisdictions or asset-versus-personal-data tension can copy them directly.
- **Confidence:** medium. Two domain instances plus one cross-cutting instance; the compound-artifact and composition-boundary patterns are concrete and copyable, but their generality is asserted against analog verticals not yet built.
- **Severity:** architecture
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-04 (AEC wedge Phase 2; satisfies the PRD-0004 distillation rule fired by the three new `platform/profiles/domains/aec-*/module.yaml` additions; substantive connection — names the two enrichments the second built domain surfaces over the first, advancing the harvest evidence captured by the preceding standard-vs-codebase observation rather than restating it)

### A declared prerequisite that lives only in reference docs and is preflighted asymmetrically is, in effect, undeclared at the moment it matters

- **Context:** An operator adopting the harness on macOS hit two hard install prerequisites (Bash 3.2 → 4+, and Ruby) only *mid-install*, not at first contact. Investigating, the prerequisites (Bash 4+, Ruby 3.0+, ripgrep, Git `core.symlinks=true`) turned out to be documented — but only in three reference sections an adopter reaches *after* the quickstart, never in the README "Getting Started" flow or at the top of the install path. `install.sh` hard-preflights Bash (clean exit) but surfaces a missing Ruby only as a *late* post-validator follow-up and never preflights ripgrep or git-symlinks at all. And the docs disagree with themselves: the README declares ripgrep a runtime requirement and cross-references it to `submodule-integration.md#prerequisites`, a section that does not list ripgrep.
- **Observation:** A requirement that is technically documented but (a) not surfaced at the point of first contact, (b) preflighted asymmetrically (some deps hard-checked up front, others discovered late or never), and (c) inconsistently cross-referenced is, from the adopter's perspective, *undeclared at the moment it matters*. The failure is platform-independent in shape — the macOS Bash edge is the well-covered case, but the same "discover it when you trip over it" pattern almost certainly applies to the thinner Windows/Linux paths (LTS distros shipping Ruby < 3.0, no ripgrep in base, no WSL stance). This is the install-time instance of the catalog's recurring "declaration without first-contact surfacing / without enforcement" motif.
- **Implication:** Prerequisites should be (1) consolidated into a single cross-platform matrix surfaced at first contact (not only in reference sections), and (2) preflighted *symmetrically and up front* — one `install.sh --preflight`/doctor pass that checks Bash version, Ruby presence *and* version, ripgrep, and git-symlinks, emitting a single actionable report rather than failing piecemeal. Filed as OPP-0040. The internal doc inconsistency (README → a section that omits ripgrep) means this is a correctness defect, not only ergonomics, and a `validate-doc-references`-style check on cross-referenced requirement lists could close the drift class. Composes with the instantiation-boundary preconditions in the onboarding-safety observation (containment + greenfield evidence-gate).
- **Confidence:** high for the specific finding (reproduced by an operator; the doc inconsistency and the asymmetric preflight are concrete and verifiable). Medium for the cross-platform generalization (the macOS case is evidenced; Windows/Linux is inferred from the same doc/preflight structure, not yet operator-confirmed).
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-05 (satisfies the PRD-0004 distillation rule fired by the new `docs/opportunities/OPP-0040-cross-platform-install-prerequisites.md`; substantive connection — generalizes OPP-0040's evidence into the "documented-but-not-at-first-contact = undeclared" pattern rather than restating the record)

### Onboarding validates a consumer's file *content* but never its *location / repository identity* — the highest-consequence install failures are silent and location-dependent

- **Context:** A contextless greenfield consumer (`unclenate.com`, described to the agent only as "a portfolio site for me") was bootstrapped while the working directory was *inside the auto-harness platform repo itself*. The flow produced a valid-looking result that was wrong in two independent ways at once. (1) **Containment:** the consumer became a plain subdirectory with no `.git` of its own, its scaffold was committed into auto-harness's *own* history (two `install.sh`-stock commits), `.gitmodules` gained a `unclenate.com/.harness` entry, and that gitlink pointed at auto-harness's own HEAD — the platform mounted inside itself. (2) **Greenfield over-assertion:** from a one-line description the manifest asserted `node-typescript` + `web-app` as active modules, authored a full `docs/` tree, and re-enabled `required-artifacts` — before any code existed, while its own comments admitted it was inferring ("enforcement deferred until package.json exists"). Every validator passed. The conflation surfaced only when a routine "commit this" was about to push the operator's private website up into the public platform repo; a human caught it.
- **Observation:** The harness's enforcement surface checks the *content and structure* of files a consumer produces (placeholders, required artifacts, companion rules, doc references) but has no check on the two *preconditions* that make onboarding safe: **(a) where am I being run** — is the consumer its own git root, distinct from and not contained by the platform repo? — and **(b) how much do I actually know** — is there evidence (code, `package.json`, an affirmed framework) to justify asserting a stack/architecture module and turning enforcement on, or is this an inference from a sentence? The "conservative module selection" rule that should have caught (b) is *brownfield-shaped*: its notion of evidence is "files present in the repo," which is empty for greenfield, so it fails open rather than routing to discovery. Both failures are silent (content validators pass), location/context-dependent (the same commands are correct one directory up, or with a `package.json` present), and were caught only by an attentive human at a high-consequence moment.
- **Implication:** Onboarding needs a class of guard distinct from the post-hoc content validators — **preconditions checked at the instantiation boundary, before anything is written**: a containment/identity check (refuse to scaffold a consumer inside the platform repo or any unrelated git repo; detection is local and unambiguous — the enclosing root owns `platform/core/kernel/` + a `project.id: development-harness-framework` manifest) and an evidence-gate that makes contextless greenfield *default to discovery* (`new-product-discovery` / `interview-driven`) rather than a guessed enforcement-on composition, keeping intent-only modules out of the active set and `required-artifacts` disabled until evidence lands. This is the same "declaration/inference without enforcement, surfaced only by a human" motif the catalog keeps hitting (cf. OPP-0025 silent submodule failures; OPP-0040 late-surfaced prerequisites; OPP-0038 attribution badging) — but applied to the *act of instantiation* rather than to artifacts after the fact. Filed as OPP-0041 (containment safety, general) and OPP-0042 (greenfield conservatism, specific); both compose with OPP-0040's proposed up-front preflight.
- **Confidence:** high for the containment failure (reproduced; detection signal is concrete and local; consequence is a private-into-public exposure, not cosmetic). Medium for the generalization that *every* contextless greenfield over-asserts — one strong instance, but the brownfield-shaped-evidence mechanism behind it is structural, not incidental.
- **Severity:** architectural
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-05 (satisfies the PRD-0004 distillation rule fired by the two new OPPs `docs/opportunities/OPP-0041-onboarding-containment-safety.md` and `OPP-0042-greenfield-onboarding-conservatism.md`; substantive connection — generalizes the two OPPs into one learning, that onboarding lacks instantiation-boundary preconditions distinct from its content validators, rather than restating either record)

### Friction-vs-safety is mostly a false tradeoff for boundary guards — the cost lives in happy-path checks and environment-altering actions, not in preconditions that fire only on the mistake path

- **Context:** Implementing PRD-0020 (OPP-0040 + OPP-0041 bootstrap hardening), the maintainer framed the work as "balance friction against safety and security — we don't want adoption friction." Three new safety behaviors were added to `install.sh`: two instantiation-boundary guards (refuse to bootstrap inside the platform repo / nested in another git repo) and a dependency preflight, plus an opt-in dependency auto-installer.
- **Observation:** The three behaviors do not carry equal friction, and the difference is structural. (1) **Boundary guards fire only on the mistake path** — a real adopter is never inside the platform repo and rarely nested, so a hard-fail-by-default guard with a narrow escape hatch (`--inside-platform` / `--allow-nested`) costs the happy path *nothing*; the friction lands only on the rare intentional case, which is exactly where a deliberate flag belongs. (2) **A preflight that fires on every run** has real but small friction, minimized by reporting all gaps at once with copy-paste fixes rather than failing piecemeal. (3) **Environment-altering actions (auto-installing system packages) are the genuine tradeoff** — Tier 4 by the kernel's own model, with real hazards (sudo, wrong package manager, CI, and the fact that a system Ruby shadows a package-manager Ruby so the "fix" is unreliable) — so they must be opt-in, never the silent default. The reflexive "any new check adds adoption friction" intuition conflates these three classes.
- **Implication:** When hardening onboarding (or any entry point), classify each proposed safeguard before choosing its default: **boundary precondition → hard-fail by default + explicit escape hatch** (near-zero happy-path cost); **happy-path check → keep, but consolidate and make output actionable**; **environment-altering action → opt-in, never default, and decline the parts that can't be done reliably** (here: guide to a version manager for Ruby rather than auto-installing it). This classification is the concrete tool for "balance friction vs safety" — friction is not a single dial. The dogfood machine reproduced the consumer problem (Ruby 2.6.10, no `rg`), confirming the preflight earns its keep.
- **Confidence:** medium-high. One implementation, but the three-class distinction is concrete, was applied per-behavior in PRD-0020, and generalizes to any guard-vs-check-vs-action decision.
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-06 (satisfies the PRD-0004 distillation rule fired by the OPP-0040/OPP-0041 `accepted` status flips and PRD-0020; substantive connection — extracts the friction-classification principle the implementation embodies, advancing the preceding instantiation-boundary observation rather than restating it)

### An evidence-based rule needs an evidence model that fits the lifecycle stage — "conservative selection" was brownfield-shaped and so failed open on greenfield

- **Context:** Implementing PRD-0021 (OPP-0042). The `harness-onboarding` skill already had strong-sounding guardrails — "Evidence only," "UNKNOWN when uncertain," "Conservative module selection (omit when ambiguous)." Yet from a one-line greenfield prompt ("a portfolio site for me") it asserted `node-typescript` + `web-app` as active modules and re-enabled `required-artifacts`. The guardrails did not fire.
- **Observation:** The rules were sound but their *evidence model* was implicitly brownfield: "evidence" meant "files present in the repo." On a greenfield repo there are no files, so "omit when evidence is ambiguous" had nothing to act on — and the only available signal, the operator's verbal description of intent, got silently promoted to evidence. A conservative rule keyed on the wrong evidence model doesn't just weaken; it **fails open** in the lifecycle stage it wasn't shaped for. The fix is not a stricter rule but a stage-aware one: name greenfield as a distinct mode, declare that a description is *intent, not evidence*, and invert the default (assert almost nothing until code lands). This rhymes with the OPP-0040 "documented-but-not-at-first-contact = undeclared" finding — both are cases where a control was technically present but mis-scoped to the situation it needed to cover.
- **Implication:** When a governance rule depends on "evidence," state explicitly *what counts as evidence and at which lifecycle stage*. Audit existing evidence-based rules for stages they silently don't cover (greenfield, pre-code, doc-only, archived). A rule that is correct for the common stage but fails open elsewhere is more dangerous than a visibly absent rule, because it reads as covered. Prefer asking 2–3 scoping questions over inferring from a description when evidence is structurally unavailable.
- **Confidence:** medium-high. One concrete instance (the greenfield over-assertion), but the failure mode (evidence-based rule + wrong evidence model = fails open) is general and already has a sibling (OPP-0040).
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-07 (satisfies the PRD-0004 distillation rule fired by the OPP-0042 `accepted` status flip and PRD-0021; substantive connection — generalizes why the skill's existing conservative-selection rule failed on greenfield into a reusable "evidence model must fit the lifecycle stage" principle, rather than restating the OPP)

### A deep-domain vertical can be anchored on a real operator tool — producing a single family-wide forcing artifact and a tool-entry / catalog-module dogfood split

- **Context:** OPP-0043 designates Cybersecurity as the third built deep-domain vertical and promotes a single-module OSINT wedge (`domains/cybersec-osint`, PRD-0022). Healthcare (OPP-0013) was grounded in two consumer codebases; AEC (OPP-0039) in a standard + research brief. Cybersecurity is grounded differently again — in a standard-shaped discipline (MITRE ATT&CK + PTES) **anchored on a real tool the maintainer operates** (Maltego, which has an MCP server and a skill).
- **Observation:** A real operator tool can be the concrete anchor for a deep-domain vertical, and doing so surfaces two patterns the first two domains could not. First, a **single family-wide forcing artifact**: `engagement-charter.md` (PTES pre-engagement — authorization, scope/RoE, lawful basis, dual-use posture, intelligence handling) is shared across `cybersec-osint` and the not-yet-built `cybersec-red`/`cybersec-blue` siblings, versus healthcare/AEC where each module carried its own artifact — the forcing-artifact primitive scales from per-module to per-family without changing the bias-guardrail mechanism (here, default-deny un-authorized activity / scope creep). Second, a **tool-entry / catalog-module dogfood split**: the Maltego `TOOLS.md` entry is dogfooded (live usage, with a default-deny stop-condition), while the `cybersec-osint` module stays catalog-only (predict-clean) — the tool half is real, the module half is composable-but-unactivated.
- **Implication:** With healthcare and AEC already meeting the harvest precondition, Cybersecurity adds two generalizable patterns for the eventual operating-principle: (1) a forcing artifact can be scoped per-family (not just per-module) when sibling modules share an authorization/scope spine, and (2) a vertical anchored on an operator tool naturally splits into a dogfooded tool surface plus a catalog module, which keeps the harness's own CI predict-clean while still exercising the tool in practice. Future tool-anchored verticals (e.g., other investigation/observability platforms) can copy both. The harvest remains a separate, maintainer-gated cycle. See [[project-deep-industry-domains]] and [[project-maltego-osint]].
- **Confidence:** medium. One instance (Cybersecurity/OPP-0043), but it contrasts cleanly with both prior grounding patterns (code-grounded healthcare, standard-grounded AEC) and the family-wide-artifact + dogfood-split patterns are concrete and copyable.
- **Severity:** architecture
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-05 (Cybersecurity wedge Phase 1; satisfies the PRD-0004 distillation rule fired by the new `docs/opportunities/OPP-0043-domain-family-cybersecurity-decomposed.md`; substantive connection — names the tool-anchored grounding pattern and the per-family forcing artifact the third domain surfaces over the first two, advancing the harvest evidence rather than restating the OPP)

### A twin-governance overlay generalizes the deep-domain primitives to a second cross-cutting discipline, and needs a dual-spine (interoperability + values) anchor to govern model→operational transformation

- **Context:** OPP-0044 / ADR-0019 / PRD-0023 establish `management/digital-twin` as a default-off cross-cutting overlay for projects that model real-world systems and run scenarios. It follows `privacy-by-design` as the second *discipline* overlay (not an industry vertical) built on the neutral-core + forcing-artifact + bias-guardrail primitives proven in healthcare, AEC, and cybersec.
- **Observation:** Two patterns surface that the industry verticals could not. First, the primitives generalize to a **second cross-cutting concern**: the forcing artifact (`twin-profile.md`) makes the consumer declare a maturity level the way `privacy-profile` declares a regime, and the bias guardrail (default-deny overclaiming) mirrors the no-US-default guardrail — evidence that the deep-domain primitives are not domain-specific. Second, a credible twin overlay needs a **dual-spine anchor**: an interoperability / digital-thread spine (ISO 23247, ISO 10303 STEP/AP242, QIF, Asset Administration Shell, DTDL, W3C WoT) that makes a planning model *transformable* into an operational twin, AND a governance-values spine (the Gemini Principles) that governs publication and trust — and the two interlock (Gemini "Federation" requires the standard connected environment the interoperability spine provides). The placement question also exposed a latent **epistemic-discipline** category (governing the model↔reality gap) shared with `eval-gated-testing`, staged in ADR-0019 rather than minted (concrete-first).
- **Implication:** The harvest now has a second cross-cutting data point: the operating-principle generalization should read "neutral-core + forcing-artifact + bias-guardrail works for industry domains (×3) AND discipline overlays (×2)." Future tool/standards-anchored overlays can copy the dual-spine pattern (a technical-conformance spine + a values spine that interlock). The epistemic-discipline category is a deferred taxonomy-harvest triggered by a third instance. See [[project-deep-industry-domains]] and [[project-digital-twin-overlay]].
- **Confidence:** medium. One overlay instance (digital-twin), but it contrasts cleanly with the privacy overlay and the three industry verticals, and the dual-spine + maturity-gated patterns are concrete and copyable.
- **Severity:** architecture
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-10 (Digital Twin overlay Phase 1; satisfies the PRD-0004 distillation rule fired by the new OPP-0044 and ADR-0019; substantive connection — names the second-cross-cutting-overlay generalization and the dual-spine anchor the digital-twin overlay surfaces over the prior four, advancing the harvest evidence rather than restating the OPP)

### A maturity-gated management overlay can ship catalog-only/predict-clean with module-gated WARN validators, and the dual-spine anchor is now concrete in templates

- **Context:** PRD-0023 Phase 2 implements the `management/digital-twin` overlay — module, 10 templates, two Half-enforced WARN validators (`validate-twin-profile.sh`, `validate-scenario-manifest.sh`), skill, sample composition, discoverability, and count propagation — as a single catalog-only PR on the harness itself.
- **Observation:** Three Phase-2 patterns confirm and extend the Phase-1 design. First, the **catalog-only/predict-clean ship path** works: the overlay is not in `harness.manifest.yaml`, so the two new validators are module-gated and no-op on the harness's own CI — the same predict-clean posture used by `privacy-by-design` and `security-static-analysis`. Second, the **dual-spine anchor is now concrete in templates**: `twin-profile.md` requires the consumer to list interoperability standards (ISO 23247, ISO/IEC 30173, Asset Administration Shell, DTDL, W3C WoT, ISO 10303 STEP/AP242, QIF) at a declared status (published vs emerging), and to state which Gemini Principles apply — the dual-spine is not an abstraction but a structured declaration consumers fill in. Third, the **maturity-gated artifact model** is enforced at the template + validator layer (the validator checks profile presence and conformance; depth-by-maturity is Asserted-only in v1, governed by the bias-guardrail in `overview.md`), matching the PRD-0023 §10 claim classification.
- **Implication:** Future discipline overlays can follow the same three-phase pattern: design (OPP + ADR + PRD), catalog-only implementation (module + templates + validators + skill, no manifest entry, predict-clean), activation (opt-in by consumers). The predict-clean gate keeps the harness's own CI green while making the overlay immediately composable. The dual-spine pattern (technical-conformance spine + values spine) is now reproducible: other overlays that govern model↔reality gaps, publication trust, or federated data can adopt the same template structure.
- **Confidence:** medium-high. One complete implementation cycle (design + catalog-only impl), but the predict-clean + module-gated WARN posture is directly evidenced by CI passing with both new validators installed, and the dual-spine concreteness is evidenced by the 10 templates on disk.
- **Severity:** architecture
- **Contributed by:** Claude Code (claude-sonnet-4-6), 2026-06-10 (Digital Twin overlay Phase 2; satisfies the PRD-0004 distillation rule fired by the new `platform/profiles/management/digital-twin/module.yaml`; substantive connection — captures the catalog-only/predict-clean ship path, the dual-spine concreteness, and the maturity-gated validator posture as reproducible patterns for future discipline overlays, advancing the Phase-1 observation rather than restating it)

### A module's WARN sensitivePaths must be self-covered by its own VALIDATE triggerPaths, not by another active module's ambient cross-coverage

- **Context:** `privacy-by-design` declared `^auth/`, `^src/.*user`, and `tracking` in `sensitivePaths` (the advisory WARN layer) but omitted them from its own `companionRules.triggerPaths` (the enforced VALIDATE layer). `validate-sensitive-paths.sh` (OPP-0034 / ADR-0017, Wave 5.3) asserts every sensitivePath is overlapped by *some active module's* triggerPath — so the module passed only when another co-active module happened to cross-cover those paths, and a project activating `privacy-by-design` in isolation failed the validator with exit 1 on all three patterns.
- **Observation:** A module that declares a sensitive path but does not enforce it in its own companion rule has a **silent cross-module dependency**: its correctness depends on the ambient set of co-active modules, not on itself. Because the overlap validator is satisfied by *any* covering triggerPath, the gap is masked whenever a sibling module (a node/auth/data module) incidentally covers the same path — and only surfaces for the single-module consumer. This is the module-level analogue of the count-drift class: a guarantee that *reads* as present (the path is listed under sensitivePaths) but is only *enforced* where some other check happens to reach it. The dogfood manifest, with many modules co-active, is exactly the configuration that hides it. The fix co-locates declaration and enforcement — a module that owns a concern enforces its own sensitivePaths through its own triggerPaths, so it is self-sufficient regardless of what else is active (sibling `healthcare-smart-on-fhir` already self-enforces `^auth/`).
- **Implication:** When a module declares `sensitivePaths`, audit that each pattern is overlapped by *that same module's* `companionRules.triggerPaths`, not merely by some other active module — treat overlap-by-another-module as a latent failure (green in the multi-module dogfood, red for the isolated consumer). A regression fixture asserting `privacy-by-design` is self-covered when activated alone would prevent re-divergence of this class. This generalizes to any "declared in layer A, enforced in layer B" split: the two layers must be internally consistent within the unit that owns them, never made whole by ambient context.
- **Confidence:** medium. One instance (privacy-by-design), but the failure mode (overlap satisfied by ambient modules masks a module's own enforcement gap) is general to the overlap-based sensitive-paths validator and has a clean sibling counter-example (`healthcare-smart-on-fhir` self-enforces `^auth/`).
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-10 (satisfies the PRD-0004 distillation rule fired by the modified `platform/profiles/management/privacy-by-design/module.yaml`; substantive connection — extracts the self-coverage principle from the triggerPath fix rather than restating it, and names the ambient-cross-coverage masking failure mode for any future module that declares sensitivePaths)

### A catalog-wide `sensitivePaths` audit generalizes the PR #114 self-coverage fix — every module must enforce its own declared sensitive surface

- **Context:** Issue #88. `validate-sensitive-paths` (OPP-0034/ADR-0017) requires every active `sensitivePath` to overlap an active companion `triggerPath`. Eight of 13 shipped compositions failed across seven modules (digital-twin, node-typescript, testing-standard, web3, self-hosted-oss, healthcare-fhir, healthcare-smart-on-fhir) — each declared sensitive paths it never enforced. This is the catalog-wide form of the single-module gap PR #114 fixed for privacy-by-design.
- **Observation:** `sensitivePaths` was being used for two superficially-similar purposes — path-prefix markers (`^tsconfig\.`, `^data/`) that genuinely warrant companion-backed review, and unanchored content-keyword markers (`patient`, `oauth`) that read as "flag files mentioning this term." The overlap invariant is coherent only for the former. The fix that preserves the validator's doctrine without a schema or validator change is **self-coverage**: fold each orphan into its own module's companion rule. The content-keyword cases resolve the same way because the modules that declared them (healthcare, SMART-on-FHIR) are opt-in domains whose purpose IS heightened PHI/auth governance — so "touching a PHI/auth surface requires a risk-register/ADR" is the intended contract, not over-enforcement. One genuinely-miscategorized marker (`^CHANGELOG`) was removed rather than enforced (the changelog is itself the audit record).
- **Implication:** When auditing a cross-cutting structural validator, the failure set is a map of where a declared-but-unenforced policy accreted. Resolve by making the declaring unit self-sufficient (declare-layer ⊆ enforce-layer within the module), not by relaxing the validator — relaxation reopens the gap the validator exists to close. Gate the class by running the validator over the project's own example compositions in CI, so the examples can't silently re-accrete the gap.
- **Confidence:** medium-high. Seven modules across four module types (stack, management, domain, delivery) resolved by one mechanism; the validator's dogfood run and the per-composition run are the evidence.
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-10 (satisfies the PRD-0004 distillation rule fired by the seven modified `platform/profiles/**/module.yaml`; substantive connection — generalizes the PR #114 single-module self-coverage observation into a catalog-wide audit principle and the "gate-examples-in-CI" prevention, rather than restating the issue)

### A deep-domain vertical can govern a *seam between two other domains* via a cross-family module dependency — composition has three shapes, not one

- **Context:** OPP-0045 / PRD-0024 (geospatial wedge, the fourth deep-domain vertical). Every prior catalog composition was either an intra-family dependency (substrate → access layer, e.g. `smart-on-fhir → fhir`, `openbim-exchange → iso19650-im`) or a domain × cross-cutting overlay (compose-with, e.g. AEC × privacy, cybersec × privacy). The geospatial `geospatial-bim-georeference` module instead declares `dependsOn` a module in a *different domain family* (`aec-openbim-exchange`) to govern the BIM↔GIS georeferencing seam — the catalog's first cross-family dependency.
- **Observation:** The seam between two mature domains is itself governable, and the harness already has the mechanism — a plain cross-family `dependsOn` edge — with no new primitive. The bridge's required artifact (`georeference-map.md`) is meaningful only because both sides exist, so the dependency makes that precondition *structural* (module-graph-enforced) rather than documentary. This is categorically distinct from compose-with (the AEC security ↔ privacy boundary): a bridge module is *incoherent* without its dependency, so a hard edge is correct; sensitivity is genuinely optional, so it stays compose-with. The decision rule between them is necessity, not convention.
- **Implication:** The deep-domain framework harvest must generalize composition into a **three-shape taxonomy**, not a single "modules compose" story: (a) intra-family dependency, (b) domain × cross-cutting overlay (optional, compose-with), and (c) cross-family bridge dependency (mandatory, governs a seam). A second, orthogonal enrichment from the same wedge: the geospatial forcing artifact (a CRS) is the first jurisdiction-profile instance bound to *time* (datum epoch / dynamic reference frames) as well as place — the harvest's generalized forcing-artifact pattern needs a temporal axis that legal-regime and national-annex instances never exercised.
- **Confidence:** medium-high. The cross-family edge is a concrete new structural case that `validate-module-graph` must resolve; the three-shape taxonomy is grounded in four shipped/designed verticals (healthcare, AEC, cybersec, geospatial) plus two cross-cutting overlays.
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-13 (satisfies the PRD-0004 distillation rule fired by the new `docs/opportunities/OPP-0045-domain-family-geospatial-decomposed.md`; substantive connection — generalizes the harness composition model into a three-shape taxonomy and surfaces the temporal forcing-artifact axis, both direct harvest inputs, rather than restating the OPP)

### The first cross-family `dependsOn` shipped with zero validator changes — a "bridge module" is a pure composition of existing primitives

- **Context:** PRD-0024 implementation (geospatial wedge Phase 2). `geospatial-bim-georeference` is the catalog's first module to `dependsOn` a module in a *different* domain family (`aec-openbim-exchange`). The design PR predicted this would need no new primitive; this is the implementation-level confirmation.
- **Observation:** The cross-family edge resolved cleanly in `validate-module-graph` with no validator change, no schema change, and no new module type — the harness's `dependsOn` mechanism was already family-agnostic (it resolves by module id, not by family). The transitive closure (`geospatial-bim-georeference → aec-openbim-exchange → aec-iso19650-im → kernel/base`) and the 4-way composition validated on the first correct build. A "bridge module" is therefore not a new kind of thing — it is an ordinary domain module whose required artifact (`georeference-map.md`) is meaningful only because both dependency sides exist.
- **Implication:** The deep-domain framework can treat seam-governance as a near-zero-cost composition: any future seam between two shipped domains (health-data × geospatial for epidemiology, finance × geospatial for property risk) is a single new bridge module with a hard cross-family `dependsOn` and no harness change. Secondary process note: the copy-exact plan referenced a non-existent validator (`validate-header-hygiene.sh`); the implementer caught it by *running* the gate, reaffirming that for copy-exact governance builds the residual failure mode is a stale plan reference caught by the validator-as-test, not a content error caught by per-task review.
- **Confidence:** high. The build shipped catalog-only / predict-clean with all 17 validators green; the cross-family edge is on disk and resolved.
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-14 (satisfies the PRD-0004 distillation rule fired by the three new `platform/profiles/domains/geospatial-*/module.yaml` manifests; substantive connection — the implementation-level confirmation that cross-family composition needs no new primitive, plus the copy-exact plan-defect failure-mode note, rather than restating the modules)

### The work-package lane is the multi-agent analog of the module declare-then-enforce contract; the shared-observations ledger is already an emergent cross-agent memory bus

- **Context:** OPP-0046 triages two field reports (#121 from Codex, #122 a multi-agent observation) from live parallel cycles — Claude planning, Codex + Gemini executing in isolated git worktrees (PlanAtlas, `central-city-web`). The recurring failure was reconciling a *prose* work-package boundary against acceptance criteria, named symbol locations, worktree setup, and per-tool defaults.
- **Observation:** Two harness primitives already cover the conceptual ground, which is why this is "harden an emergent pattern," not "invent a framework." (1) The proposed WP lane contract (`allowedFiles` + `requiredChecks` + lint-the-diff) is structurally identical to the module contract (`sensitivePaths` + `companionRules` + `validate-companions`): declare a boundary, then mechanically check work against it; the conflict protocol ("a symbol outside `allowedFiles` → stop and report") is a trust-tier stop-and-report on scope. (2) Issue #122 is direct field evidence that `shared-observations.md` (ADR-0002) already functions as a cross-agent memory bus — one agent logged a constraint, the next dispatch injected it as a hard prompt constraint. The ask is not to build the bus but to make it machine-checkable at the WP boundary and auto-injected into the planner's context.
- **Implication:** When a multi-agent-execution gap surfaces, first map it onto the harness's existing declare-then-enforce + structured-observations primitives before proposing new machinery — the new surface is usually a *re-targeting* of an existing contract (here, from "module ⊆ catalog" to "agent ⊆ work-package lane"). The follow-on wedge should harvest the lane schema from real lane specs (concrete-first), and the platform must ship the *mechanism* (lane schema, lint, memory-bus load) — never a specific project's learning (e.g. the symlink-`node_modules` rule belongs in the consumer's ledger, not the catalog).
- **Confidence:** medium-high. Two independent, high-confidence-marked field reports with concrete failures; the memory-bus primitive is already proven end-to-end.
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-15 (satisfies the PRD-0004 distillation rule fired by the new `docs/opportunities/OPP-0046-parallel-multi-agent-work-package-lane-contract.md`; substantive connection — maps the multi-agent coordination gap onto the existing declare-then-enforce + shared-observations primitives and the concrete-first wedge discipline, rather than restating the issues)

### Delivery cost is a new governance *axis* (economics), and it attaches to the same unit OPP-0046 defines — lane = scope contract, cost record = economic contract

- **Context:** OPP-0047 captures the token-cost-of-delivery as governance evidence for build-vs-buy, raised 2026-06-15. The harness governs quality/safety (trust tiers, sensitive paths) and, via OPP-0029, *runtime* observability — but never the cost of *producing* a unit of code, which agentic delivery makes directly observable (every dispatch emits token usage; the workflow runtime exposes a spend budget).
- **Observation:** Two things make this harness-native rather than a bolt-on. (1) It holds the same "govern the contract, not the extraction" boundary as OPP-0046's memory-bus: the harness owns the delivery-cost record schema + a cite-the-evidence rule on build-vs-buy decisions, while the runtime/CI emits the tokens. (2) It attaches to the *same unit* OPP-0046 defines — the work-package lane is the scope contract, the delivery-cost record is the economic contract; together they are one governance object (the lane simply gains a `tokenBudget`). The external landscape confirms the gap is real: the OTel GenAI semconv standardizes token *counts* but not dollar cost, and every cost-observability tool (Langfuse, LangSmith, Helicone, AgentOps) attributes per call/session — none to a unit of software delivery.
- **Implication:** A new governance *axis* (economics) is being added beside quality/safety. Its design must separate durable metrics (token counts) from volatile derived ones (a dated USD estimate) and be caching-aware (prompt caching dominates agentic-delivery cost; naive fresh-input sums overstate 5–10×). General pattern for future axes: when a new measurable dimension appears, first check whether it attaches to an *existing* governance unit (here, OPP-0046's lane) before inventing a parallel structure — co-locating scope and economics on one unit is cheaper to govern than two separate objects.
- **Confidence:** medium-high. The cost signal is already emitted in-repo; the landscape gap is web-confirmed; the composition with OPP-0046 is concrete.
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-15 (satisfies the PRD-0004 distillation rule fired by the new `docs/opportunities/OPP-0047-delivery-cost-unit-economics-governance.md`; substantive connection — names delivery-cost as a new economics governance axis, the govern-the-contract-not-the-extraction boundary, and the lane=scope / cost=economics co-location with OPP-0046, rather than restating the OPP)

### OPP/PRD status is un-validated prose that silently drifts after every implementation wave — the flip belongs in the implementing-PR checklist, and this is the live evidence for a backlog-review cadence

- **Context:** A 2026-06-15 backlog retrospective (four independent agents — Claude's three-agent run, Codex, Gemini, AntiGravity — plus the controller) found eight records whose capability had shipped but whose status still read proposed/exploring: OPP-0006/0033/0034/0036/0037/0045 and PRD-0006/PRD-0015. Root cause: Wave 5 shipped five sibling validators/principles in one burst (PRs #76–#84) and only OPP-0035 was flipped; the later digital-twin and geospatial work repeated the omission.
- **Observation:** `validate-list-completeness` enforces that every OPP/PRD is *indexed*, but nothing enforces that its *status* matches reality — status is prose, not a validated field (the non-validator-consistency class). So it drifts monotonically: every implementing PR that ships a capability but forgets to flip its source OPP/PRD adds one more stale record, invisible until a manual audit. The reconciliation itself was drafted by a multi-agent teammate (AntiGravity) that declared "validation passed" but left it CI-fatal — six modified OPP files with no distillation satisfier — the same "acted on a local check, declared done" failure mode the cadence would catch.
- **Implication:** Two fixes, one tactical and one structural. Tactical: add "flip the source OPP/PRD status to accepted (or *partial promotion*) once its acceptance criteria are met" to the implementing-PR checklist, so the flip ships *with* the capability rather than in a later sweep. Structural: this retrospective is itself the evidence for a backlog-review cadence (OPP-0032) — the harness already runs a weekly `doc-watch` for documentation drift but has no equivalent for backlog drift (stale status, promotable OPPs, deferred siblings). A status that can drift unseen for a month argues for either a `validate-opp-status`-style check or a scheduled review, not just discipline.
- **Confidence:** high. Eight stale records, found by four independent agents converging; the drift mechanism (status is un-validated prose) is structural, not incidental.
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-15 (satisfies the PRD-0004 distillation rule fired by the six modified OPP files in the hygiene reconciliation; substantive connection — names the structural drift mechanism and the tactical + structural fixes, including the self-evidence for OPP-0032's cadence, rather than restating the status changes)

### Two tightly-coupled OPPs promote best as one module with staged phases — "combine the home, sequence the depth"

- **Context:** PRD-0025 promotes OPP-0046 (the work-package lane = scope contract). Its sibling OPP-0047 (delivery-cost = economic contract) composes so tightly that the four-agent backlog retrospective split on how to promote them: combine into one module (Gemini, AntiGravity) vs. sequence two PRDs (Codex, the controller). The lane is the *unit of delivery*; the cost record attaches to that *same* unit.
- **Observation:** Neither pure position was right — the synthesis was. When two OPPs share a governance *object* (here, the work-package), the cheapest-to-govern shape is **one module that is the single home for the object, with the contracts staged as phases**: v1 the scope contract (lane), v2 the economic contract (token budget + cost record). The alternatives are worse — two modules split one object across two homes; two unrelated PRDs lose the composition. PRD-0025 is the single home; OPP-0047 becomes its deferred v2 phase, not a separate module.
- **Implication:** The "combine vs. sequence" question that recurs whenever coupled OPPs come up has a default answer — **combine the home (one module), sequence the depth (phases)** — gated by one test: do the OPPs attach contracts to the *same* governance unit? If yes, co-locate; if they govern *different* units that merely interact, keep them separate and compose. Promoting this way also let the status-flip discipline distilled minutes earlier apply immediately (OPP-0046 → accepted in the same PR that promoted it).
- **Confidence:** medium-high. One worked case (lane + cost), but it resolved a genuine four-agent split and the shares-a-governance-object test generalizes.
- **Severity:** process
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-15 (satisfies the PRD-0004 distillation rule fired by the modified `docs/opportunities/OPP-0046-...md` during its promotion; substantive connection — names the combine-the-home / sequence-the-depth resolution and its shares-a-governance-object test, rather than restating PRD-0025)

### A do-not-publish boundary enforced only by agent memory is a latent leak in a shared-identity multi-agent workspace — mark the file, don't rely on the discipline

- **Context:** auto-harness is a public repo that parks an untracked 716-line private design seed brief under `docs/superpowers/specs/`. The standing "do not publish" decision (it names several private/client projects) is enforced by nothing machine-checkable: the path is excluded from the placeholder validator (`.placeholder-ignore`) **and** markdownlint, `validate-knowledge-redaction.sh` (OPP-0036) scans only the two knowledge files against a hardcoded denylist that omits those names, and the redaction check is WARN-only and PR-diff-only. A single `git add -A` from any of the three agents that commit under the same git identity here (Claude, Codex, Gemini) would publish it tripping zero CI guardrails. Surfaced again during the 2026-06-17 GitBook pass, which had to be careful not to stage the file. Filed as OPP-0048.
- **Observation:** The cheapest robust fix is not a bigger name denylist — a denylist of private names cannot live as literals in a tracked public file without itself leaking them. It is a **file-level publication-boundary marker**: a `do-not-publish: true` frontmatter plus a *blocking* validator that fails if a marked file becomes tracked (`marker present AND file in git ls-files`). That mechanism needs no name corpus, attaches the intent to the artifact, and generalizes to any parked export. The content-denylist extension (configurable, wider scope) becomes a defense-in-depth second layer, not the primary control. This is the inverse of `requiredArtifacts` — a must-NOT-be-tracked assertion — and the same declare-then-enforce shape the harness already runs for module scope.
- **Implication:** When a safety property is currently held by "the agent will remember," and the workspace has ≥2 agents sharing one git identity, treat that property as unenforced and design a machine check. Prefer prevention timing (pre-commit hook) over detection timing (CI on PR), because a public-remote leak is irreversible the moment it is pushed — CI catches it only after exposure. The marker-and-block pattern is reusable for any "this artifact must never be published" case, including the `management/digital-twin` overlay's public/private publication boundaries.
- **Confidence:** high. The gap is concrete and live (the file is parked in the working tree now), the exclusion stack is verified, and the shared-identity multi-agent condition is the documented norm for this repo.
- **Severity:** security
- **Contributed by:** Claude Code (claude-opus-4-8), 2026-06-17 (satisfies the PRD-0004 distillation rule fired by the new `docs/opportunities/OPP-0048-redaction-scope-and-publication-boundary-hardening.md`; substantive connection — names the mark-the-file-don't-trust-the-discipline principle, the denylist-can't-be-public tension, and the prevention-over-detection timing, rather than restating the OPP)
