<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Discovery to Composition

## From Idea to Running Project — Development Harness Platform

This is the front-door document. Start here if you do not yet know your stack, do not yet
have a manifest, or are helping a client or stakeholder turn an idea into a buildable project.

---

## The Workflow at a Glance

```text
┌─────────────────────────────────────────────────────────────────────┐
│  Entry point                                                         │
│  idea / informal notes / mockup / wireframes / prototype / spec     │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
                     Step 1: Run the intake
                  intake-questionnaire.md (8 sections)
                                │
              ┌─────────────────┼─────────────────┐
              │                 │                 │
              ▼                 ▼                 ▼
       raw idea only       mockup /          written spec
       full questionnaire  prototype         validate gaps
              │                 │                 │
              └─────────────────┼─────────────────┘
                                │
                                ▼
                  Step 2: Capture visual assets (if any)
                       starting-assets.md
                                │
                                ▼
                    Step 3: Frame the problem
              problem-statement.md + personas.md
                                │
                                ▼
                  Step 4: Capture requirements
              requirements.md (Must / Should / Later)
                                │
                                ▼
                    Step 5: Define MVP scope
                mvp-scope.md (in / out / success criteria)
                                │
                                ▼
                    Step 6: Select modules
              composition signals → harness.manifest.yaml
                                │
                                ▼
                  Step 7: Seed early ADRs
               document stack, architecture, data choices
                                │
                                ▼
                  Step 8: Initialize the manifest
            harness.manifest.yaml + run validators
                                │
                                ▼
                     Build, learn, evolve
              (Steps 3–7 are live — update as things change)
```

---

## Step 1: Run the Intake

**Template:** `platform/templates/discovery/intake-questionnaire.md`

**What it is:** A structured 8-section instrument that extracts everything needed to
produce product artifacts and select modules, regardless of how much exists at the start.

**How to use it:**

Copy the questionnaire to `docs/discovery/intake-questionnaire.md` in the project repo.
Fill it in through one of these modes:

- **Client or stakeholder session:** Work through sections 1–5 as a 60–90 minute conversation.
  Use the embedded probe questions for incomplete answers. Sections 6–8 can be async.

- **AI-assisted session:** Share the blank questionnaire with Claude. Ask Claude to conduct
  the intake session with you interactively — it will ask the questions, record the answers,
  and surface gaps. After the session, produce the downstream artifacts together.

- **Self-interview:** Work through the questionnaire alone before starting. The value is in
  making implicit assumptions explicit before they are baked into architecture.

**Different entry points route through the questionnaire differently:**

| Starting point | Questionnaire approach |
|---------------|----------------------|
| Raw idea | Run all 8 sections in order |
| Informal notes or verbal requirements | Run all 8 sections; use existing notes to pre-fill answers |
| Mockup or Vercel prototype | Log assets in `starting-assets.md`; run sections 2–6 to fill gaps the visual doesn't answer |
| Wireframes or design system | Log assets; run sections 2–5 to validate and extract structural requirements |
| Detailed written spec | Run questionnaire against the spec to find what it doesn't cover; brief answers are fine for well-covered sections |

In all cases, the questionnaire ends with a **Composition Signals Summary** — a table mapping
answers to candidate modules. Complete this before Step 6.

---

## Step 2: Capture Visual Assets (if starting from non-text artifacts)

**Template:** `platform/templates/discovery/starting-assets.md`

If the project starts from a Vercel prototype, Figma mockup, wireframes, or screenshots,
log each asset before producing written requirements. This gives provenance for the artifacts
that follow: "these requirements were derived from these assets."

For each asset, capture:

- What screens or flows it covers
- Requirements extracted from visual review
- Open questions the asset raises but doesn't answer

The open questions become follow-up topics in the intake questionnaire.

---

## Step 3: Frame the Problem

**Template:** `platform/templates/product/problem-statement.md`
**Template:** `platform/templates/product/personas.md`

From intake questionnaire sections 2 and 3, produce:

**`docs/product/problem-statement.md`**

- The problem from the user's perspective (not the product's perspective)
- The value proposition if the problem is solved well
- The opportunity hypothesis: "If we build X for Y, then Z" — falsifiable
- Known constraints

**`docs/product/personas.md`**

- Primary persona: who is this built for, what do they need, what frustrates them
- Secondary persona if applicable
- Out-of-scope personas: explicitly who this is NOT for

The out-of-scope personas section is not optional. Unnamed audiences expand scope silently.

---

## Step 4: Capture Requirements

**Template:** `platform/templates/product/requirements.md`

From intake questionnaire section 5, produce `docs/product/requirements.md`.

Key discipline: **use priority tiers**.

| Tier | Meaning |
|------|---------|
| Must | Required for this version to deliver value. In MVP scope. |
| Should | High value but can ship without. Target v1+. |
| Later | Acknowledged and explicitly deferred. Out of scope now. |

Every requirement that is known but deferred should appear in the **Later** tier or in the
Out of Scope section. Requirements that aren't captured get rediscovered during development
and treated as in-scope. This is how scope creep starts.

Include user stories (from personas, intake §3) and success metrics (from intake §5.5, §6).

---

## Step 5: Define MVP Scope

**Template:** `platform/templates/discovery/mvp-scope.md`

The MVP scope document makes the boundary explicit. It answers:

- What is the shortest description of what ships? (one sentence)
- What features are in scope, with acceptance signals?
- What is explicitly out of scope, and when might it be revisited?
- What does "done" mean, concretely?

**The out-of-scope list is the most important part.** A list that only names what is in scope
leaves the boundary undefined. A list that also names what is not in scope closes the boundary.

Derive from intake questionnaire §5.1–5.3 and from the Must-tier requirements in `requirements.md`.

---

## Step 6: Select Modules

The composition signals summary at the end of the intake questionnaire maps answers to candidate
modules. Use it to populate `harness.manifest.yaml`.

**Decision matrix:**

| Question from intake | Module to select |
|---------------------|-----------------|
| Web UI needed? (§8.3) | `architectures/web-app` |
| Pure backend API consumed by others? (§8.3) | `architectures/api-service` |
| Async or background processing? (§8.3) | `architectures/event-driven` |
| Relational data / SQL needed? (§4.2, §8.1) | `data/relational-postgres` |
| File storage, media, or uploads? (§5.1, §8.3) | `data/object-storage` |
| Document or JSON store? (§8.1) | `data/document-store` |
| Node / TypeScript preferred? (§8.1) | `stacks/node-typescript` |
| Python preferred? (§8.1) | `stacks/python` |
| Using Supabase? (§4.2, §8.1) | `domains/supabase` |
| Media processing pipeline? (§5.1) | `domains/media-pipeline` |
| Throwaway prototype / validation only? (§7.4) | `delivery/prototype` |
| MVP or production product? (§7.4) | `delivery/production-saas` |
| Internal shared tooling? (§7.1, §7.4) | `delivery/internal-platform` |
| Multi-team or multi-workstream? (§7.1) | `management/program-lite` |
| Claude Code as agent? (§7.2) | `agents/claude-code` |
| Other LLM tool? (§7.2) | `agents/generic-llm` |
| Always include for real products | `management/product-lite` + `management/project-standard` |
| Discovery phase active (now) | `management/discovery-intake` |
| Multi-participant project (agents + humans) producing longitudinal observations? | `management/knowledge-capture` |
| Capturing forward-looking product candidates with a promotion path to PRDs? | `management/opportunity-capture` |

**Starter manifest for a project in discovery** (before stack is chosen):

```yaml
schemaVersion: 1
project:
  id: your-project-id
  name: Your Project Name
  maturity: prototype
  criticality: low
modules:
  core:
    - kernel/base
  delivery:
    - prototype
  management:
    - discovery-intake
    - product-lite
    - project-standard
  agents:
    - base
overrides:
  requiredArtifacts: []
  disabledValidations:
    - required-artifacts
```

After completing discovery and selecting your stack/architecture/data modules, replace the
`disabledValidations` override and add the selected profile modules.

---

## Step 7: Seed Early ADRs

**Template:** `platform/templates/adr.md`

Every significant decision made during module selection in Step 6 warrants an ADR.
These are the first ADRs every project needs.

**ADRs to create after composition selection:**

| Decision | Why record it |
|----------|--------------|
| Stack choice (Node/TS vs Python vs other) | Shapes every technical decision that follows |
| Architecture pattern (web app vs API vs event-driven) | Affects deployment, testing, and integration model |
| Data storage approach (relational, document, object) | Migration discipline and data model decisions depend on this |
| Auth approach (if applicable) | Security-sensitive; hard to change later |
| Delivery target (Vercel, AWS, Fly.io, etc.) | Affects CI, environment model, and cost |

The ADR template is at `platform/templates/adr.md`. Create files as `docs/adr/ADR-0001-stack-choice.md`,
`docs/adr/ADR-0002-architecture-pattern.md`, etc.

ADRs for decisions already made should be status `accepted`. ADRs for decisions still open
should be status `proposed`.

**Connecting ADRs to product context:**

- Reference the relevant intake questionnaire section in the ADR's Context field
- Reference linked PRD requirements in the ADR's Context if the decision was driven by a product constraint
- Link ADRs from `docs/discovery/mvp-scope.md` — the scope boundary should reflect the architectural choices made

---

## Step 7b: Seed Early PRDs

**Template:** `platform/templates/product/prd.md`

PRDs are the product counterpart to ADRs. Where ADRs capture *how and why* the system is
built a certain way, PRDs capture *what and why* the product includes or excludes specific
capabilities. Together they form the longitudinal decision record for the project.

**PRDs to create when the project has significant product decisions:**

| Decision | Why record it |
|----------|--------------|
| Core user flow or feature set | Defines what the product actually does — referenced by all future scope decisions |
| MVP feature boundary | Which capabilities are in v1 and which are deferred — prevents scope creep |
| Monetization or pricing model (if applicable) | Affects feature prioritization, UX, and data model |
| Target audience pivot | Changes who the product is for — cascades through personas, requirements, and success metrics |

Create files as `docs/requirements/PRD-0001-core-feature-set.md`,
`docs/requirements/PRD-0002-mvp-boundary.md`, etc.

PRDs for decisions already made should be status `accepted`. PRDs for decisions still open
should be status `proposed`.

Not every project needs PRDs at inception. If product decisions are straightforward and
captured adequately in `requirements.md`, defer PRD creation until a significant product
decision arises during development.

---

## Step 8: Initialize the Manifest

Create `harness.manifest.yaml` from the modules selected in Step 6.

Run the validators:

```bash
# From the platform/ directory
bash validators/validate-manifest.sh path/to/harness.manifest.yaml
bash validators/validate-module-graph.sh path/to/harness.manifest.yaml
bash validators/validate-required-artifacts.sh path/to/harness.manifest.yaml path/to/project/root
```

Validators require Ruby. The placeholder validator additionally requires `rg` (ripgrep).

Fix any errors before proceeding to build. Warnings about missing stack artifacts are expected
at the discovery stage — disable them via `disabledValidations` as shown in Step 6, then
re-enable as the project matures.

---

## Growth Stage Progression

The manifest composition evolves as the project matures. Do not over-engineer the initial
composition. Do not under-govern when the project reaches production.

| Stage | Typical manifest profile | Key changes from previous stage |
|-------|------------------------|--------------------------------|
| Discovery | `kernel/base` + `discovery-intake` + `product-lite` + `prototype` | Starting point; no stack yet |
| Prototype | Add stack + architecture + data modules | Stack chosen; first code written |
| MVP / early access | Switch to `production-saas` delivery; add `project-standard` | Real users; ops readiness begins |
| Production v1 | All profiles active; risk register in use; incident process live | Full governance active |
| Scale | Add `program-lite` if multi-team | Cross-team coordination needed |

**When to upgrade delivery from `prototype` to `production-saas`:**

- Real users with real data
- Data that would be painful to lose
- Any external stakeholder dependency on uptime

Switching delivery module triggers new required artifact validation — the ops and release
artifacts (`release-checklist.md`, `rollback-checklist.md`, `environment-inventory.md`) become
required. This is intentional: those artifacts should exist before real users arrive.

---

## During Development: Keeping Artifacts Live

Discovery does not end when engineering begins. Product direction changes during development
as new information surfaces, constraints shift, and scope adjusts.

**When requirements change:**

1. Update `docs/product/requirements.md` — adjust priority tier, add/remove items
2. Log the change in `docs/project/change-log.md`: what changed, why, who decided
3. If architectural: create a new ADR
4. If a significant product decision: create a new PRD
5. If MVP scope boundary shifts: update `docs/discovery/mvp-scope.md`

The `discovery-intake` module enforces this with a companion rule: a PR that changes
`requirements.md` or `mvp-scope.md` without also touching `change-log.md`, an ADR, or a PRD
will fail CI.

**When architecture changes:**

1. Update `docs/architecture/overview.md`
2. Create a new ADR documenting the decision, why it changed, and what was considered
3. If the change affects the manifest composition, update `harness.manifest.yaml`
4. If the change affects security posture, update `docs/security/risk-register.md`

**When personas or problem framing change:**
This is a significant product event and should almost always warrant a PRD. If who the
product is for has changed:

1. Create a new PRD documenting the pivot: what changed, why, what was considered
2. Update `docs/product/personas.md`
3. Update `docs/product/problem-statement.md`
4. Review and update `docs/product/requirements.md` — requirements derived from the old persona may no longer apply
5. Log in `docs/project/change-log.md`

---

## Snippets Reference

The following legacy snippets have been superseded by this workflow and the platform templates:

**`Universal PRD Generation Prompt`** (original monolith prompt, now archived at `legacy/v1-monolith-prompt.txt`)
The PRD process has been restored as a first-class record type. PRD template:
`platform/templates/product/prd.md`. Seeding guidance: Step 7b of this workflow.
Ongoing workflow: `product-lite/README.md` § Connecting to PRDs.

**`dev.ADR.prompt`** (original ADR prompt, absorbed into platform)
Superseded by: Step 7 of this workflow (ADR seeding), `templates/adr.md` (template),
and `discovery-intake/README.md` (guidance).

---

## Reference Links

| Resource | Path |
|----------|------|
| Intake questionnaire template | `platform/templates/discovery/intake-questionnaire.md` |
| MVP scope template | `platform/templates/discovery/mvp-scope.md` |
| Starting assets template | `platform/templates/discovery/starting-assets.md` |
| Personas template | `platform/templates/product/personas.md` |
| Problem statement template | `platform/templates/product/problem-statement.md` |
| Requirements template | `platform/templates/product/requirements.md` |
| ADR template | `platform/templates/adr.md` |
| Discovery starter composition | `platform/compositions/new-product-discovery.yaml` |
| Discovery-intake module | `platform/profiles/management/discovery-intake/` |
| Product-lite module | `platform/profiles/management/product-lite/` |
| Validators | `platform/validators/` |
