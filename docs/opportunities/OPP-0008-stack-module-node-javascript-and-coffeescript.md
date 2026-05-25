<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0008 — Stack Module for Plain Node-JavaScript (and Legacy CoffeeScript)

**Status:** accepted
**Owner:** @unclenate
**Created:** 2026-05-24
**Last Updated:** 2026-05-25 *(v1 implementation landed: `stacks/node-javascript` + `stacks/coffeescript` modules shipped)*
**Confidence:** high

---

## Thesis

The auto-harness stack catalog has `stacks/node-typescript` and `stacks/python`
but no module for Node projects that don't use TypeScript — plain JavaScript or
CoffeeScript. The `harness-onboarding` skill's "Evidence only" rule then
correctly refuses to activate `stacks/node-typescript` for such projects,
leaving the `stacks/*` section of the proposed composition entirely empty.
The composition is *valid* without a stack module, but the gap loses a
significant fact about the consumer (this is a Node project). Closing this
gap is small: a sibling `stacks/node-javascript` module (and optionally
`stacks/coffeescript` for legacy onboarding) modeled directly after
`stacks/node-typescript` — same shape, no required artifacts, no conflicts.

## Origin / Evidence

- **YouBase brownfield onboarding pass, 2026-05-24.** Section 2 of the
  resulting assessment notes verbatim:

  > "stacks: — none selected | catalog has no JS/CoffeeScript module;
  > evidence does not support `stacks/node-typescript` (no TS source, no
  > `tsconfig.json`, no `typescript` dep). The published `index.d.ts` is a
  > consumer-facing type declaration, not internal TS."

  YouBase is genuinely Node (a 28-runtime-dep `package.json` calling Express,
  LevelDB, etc.) + CoffeeScript (~600 LoC across 13 `.coffee` files,
  `prepare: coffee -o lib -c src`). The "no stack module fits" finding is
  not a quirk of the project; it is a hole in the taxonomy.

- **Module catalog confirmation.** The `harness-onboarding/SKILL.md`
  Module Catalog § "stacks" reads literally: *"Pick at most one —
  node-typescript or python"*. The footnote about polyglot combination
  applies to combining `node-typescript` with `python`, not to other Node
  flavors.

- **First-real-brownfield-hit pattern.** This is the first non-trivial
  external brownfield project the harness-onboarding skill has been pointed
  at outside the auto-harness self-dogfood. Discovering a catalog hole the
  first time a real codebase is put through the skill is a strong signal —
  not a hypothetical concern.

- **Brownfield demographics.** Codebases old enough to be worth onboarding
  to a governance harness (5+ years, abandoned, forked, acquired, or
  migration-from-other-tooling) often predate the TypeScript-default era
  (TS became common in Node circa 2018–2019). Brownfield is a major
  fraction of the harness's adoption surface, per the existence of the
  `harness-onboarding` skill and the `brownfield-onboarding.md` workflow.

- **No required-artifacts cost.** `stacks/node-typescript` and
  `stacks/python` have *no* required artifacts of their own (per the
  Module Catalog). A `stacks/node-javascript` module would inherit the
  same property — zero ongoing governance overhead, just a way to declare
  the truth.

## Why Now

- **Adoption ramp pressure.** Auto-harness reached v0.5.0 with the
  consumer-CI templates landing in PR #45. The next phase of adoption is
  more real brownfield consumers. Each one that hits a stack-catalog hole
  is told (per the skill's Conservative-module-selection rule) to leave
  the section empty — which works but tells the consumer "we don't have a
  category for you," which is the wrong signal for a governance framework
  that aspires to broad coverage.

- **Low cost of action.** The module shape is already proven by
  `stacks/node-typescript`. A `stacks/node-javascript` is a copy with the
  identifier renamed, the dependency-on-typescript dropped, and a
  one-paragraph README. The dogfood is trivial (auto-harness itself is
  Ruby + bash + markdown — no Node stack to dogfood against).

- **Discovery-loop momentum.** This is one of three OPPs filed from the
  same YouBase onboarding pass (see also OPP-0009, OPP-0010). Filing them
  together keeps the discovery thread coherent and surfaces the
  brownfield-discovery pattern as a class.

## Risks / Open Questions

### Risks

- **Aspirational defaults vs. catalog coverage.** A `stacks/node-javascript`
  module implicitly signals "JS without TS is a supported shape." Some
  governance frameworks deliberately omit such modules to nudge consumers
  toward TS. The counterargument: the harness's job is to govern reality,
  not to nudge stack choices. Coverage matters more than aspirational
  defaults; the harness can still *recommend* a TS port through a
  `docs/architecture/overview.md` artifact without refusing to acknowledge
  the JS state.

- **CoffeeScript scope creep.** Adding `stacks/coffeescript` lets the
  harness onboard CoffeeScript projects today. Whether that is a strategic
  good or a maintenance overhang is a separate question — CoffeeScript 2.x
  is still maintained but the ecosystem has effectively migrated to TS,
  and a `stacks/coffeescript` module is a signal that the harness is
  willing to govern legacy stacks at the long-tail end.

- **Granularity choice creates module sprawl.** Three flat siblings
  (`node-typescript`, `node-javascript`, `coffeescript`) plus future
  growth (Bun, Deno) could turn the stacks list into a sprawl. A
  consolidated `stacks/node` with a `flavor` field (typescript |
  javascript | coffeescript) would be cleaner taxonomy but a bigger
  blast radius — every existing reference to `node-typescript` would
  need to migrate.

### Open Questions

- **Naming.** `stacks/node-javascript` or `stacks/node-js`? The existing
  pattern is `stacks/node-typescript` (no contraction), so
  `stacks/node-javascript` matches stylistically. Worth confirming before
  shipping.

- **Polyglot composition.** Per the harness's polyglot rule, can a
  project activate both `stacks/node-javascript` and `stacks/coffeescript`
  (because CoffeeScript compiles to JS)? Or does CoffeeScript subsume
  JS the way the existing rule treats polyglots? Recommend: yes,
  activatable simultaneously — CoffeeScript projects often include
  hand-written JS for build tooling.

- **Inclusion of `stacks/node-bun` and `stacks/node-deno`?** Out of scope
  for this OPP — file separately if/when a real consumer surfaces them.
  The principle is the same (catalog coverage of real Node runtimes).

- **Migration ramp.** Does the harness want to recommend a TS port
  through the `docs/architecture/overview.md` artifact when
  `stacks/node-javascript` or `stacks/coffeescript` is active? Or is that
  a per-project decision left to the consumer's operating principles?
  Recommend: per-project, but the skill output can flag it as a typical
  next step.

### Design Options Under Consideration

| Option | Mechanism | Coverage | Blast radius |
|--------|-----------|----------|--------------|
| **A — Add `stacks/node-javascript` only** | New sibling module, copy of `stacks/node-typescript` with TS dependency dropped | Plain JS Node projects | Tiny: new module YAML + README |
| **B — Add `stacks/node-javascript` + `stacks/coffeescript`** | Two new sibling modules | Plain JS + CoffeeScript Node projects | Tiny: two new module YAMLs + READMEs |
| **C — Consolidate to `stacks/node` with `flavor` field** | Refactor `stacks/node-typescript`; introduce one module with sub-flavors | All Node stack variants | Large: every reference to `node-typescript` in catalog/skill/docs needs migration |
| **D — Defer; document the gap in the skill** | Update `harness-onboarding/SKILL.md` to explicitly say "stacks: leave empty if Node-not-TypeScript; declare informally in HARNESS.md" | None — punts | Tiny: skill-doc tweak only |

**Initial bias (subject to PRD validation): B.** Add both
`stacks/node-javascript` and `stacks/coffeescript` as sibling modules,
matching the existing flat catalog pattern. Lowest blast radius; immediate
coverage of the two cases the first real brownfield pass hit. Option C is
a cleaner long-term taxonomy but premature primitive-creation given that B
solves the immediate problem with the existing module shape. Option D is
explicitly *not* preferred — punting on coverage tells consumers the
harness has gaps where it could trivially have coverage.

## Disposition

<!--
Empty while Status: proposed. Populated on transition.
-->

## Promotion

<!--
Empty until accepted; then link to PRD-NNNN.
-->
