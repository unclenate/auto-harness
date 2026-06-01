<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Management Overlay: Product Lite

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay keeps product context alive through the full delivery lifecycle — from problem
framing through active development. It is designed for small teams and solo builders who
need real product discipline without enterprise-scale ceremony.

---

## What This Overlay Requires

Three required artifacts:

**`docs/product/problem-statement.md`** — The problem from the user's perspective, the value
proposition, the opportunity hypothesis, and known constraints. This is not a pitch deck summary.
It is the working definition of what problem the team is solving and for whom.

**`docs/product/requirements.md`** — User stories, functional requirements with explicit priority
tiers (Must / Should / Later), out-of-scope items, quality expectations, and success metrics.
The out-of-scope section is not optional — unnamed scope expands during development.

**`docs/product/release-intent.md`** — What this release is intended to achieve, the feature
maturity level, and the leading indicators that will confirm the release met its intent.

Two optional but recommended artifacts:

**`docs/product/personas.md`** — Who the product is for (and explicitly who it is not for).
Required when the product serves distinct user types. Omit only for internal tools or
single-audience products where the audience is obvious and stable.

**`docs/discovery/intake-questionnaire.md` and `docs/discovery/mvp-scope.md`** — Upstream
discovery artifacts. If the project started with the `discovery-intake` overlay, these exist.
If not, the product-lite artifacts stand on their own — but the team should be able to answer
the intake questions informally before treating requirements as solid.

---

## Product Workflow

This overlay supports a two-phase product lifecycle:

### Phase 1: Definition (before engineering starts)

The goal of this phase is to answer: *What are we building, for whom, and what does done look like?*

1. Frame the problem (`problem-statement.md`) — start with the user, not the solution
2. Define personas (`personas.md`) — name who it is for and who it is not for
3. Capture requirements (`requirements.md`) — use Must / Should / Later tiers; name out-of-scope explicitly
4. State release intent (`release-intent.md`) — what does this release achieve and how will we know?

If starting from an idea or informal requirements, use the `discovery-intake` overlay and
the intake questionnaire to produce these artifacts through a structured discovery process.
See `platform/workflow/discovery-to-composition.md` for the full path from idea to manifest.

### Phase 2: Live tracking (during engineering)

Product direction changes during development. Requirements evolve as implementation reveals
constraints. The product artifacts must stay current — not because of bureaucracy, but because
stale requirements lead to agents and engineers building the wrong thing.

**When requirements change:**

- Update `docs/product/requirements.md`
- Log the change in `docs/project/change-log.md` (what changed, why, who decided)
- Create an ADR if the change is architectural
- Create a PRD if the change is a significant product decision (new feature, scope pivot, monetization change)

The companion rule in this module enforces this in CI: a PR that changes `requirements.md`
or `problem-statement.md` without also touching `change-log.md`, an ADR, or a PRD will fail.

---

## What Makes Requirements Good

The review gate for this overlay requires human judgment on quality, not just presence.
Validators check that the file exists and has content. Reviewers check that the content is real.

**Requirements that are good:**

- Specific enough to write acceptance tests against
- Include a concrete acceptance criterion, not a vague description
- Have an explicit priority tier
- Include out-of-scope items with reasons

**Requirements that are not good enough:**

- "The system should be fast" (not testable)
- "Users should be able to manage their account" (too vague)
- A list of in-scope features with no out-of-scope section
- Success metrics that say "users like it" or "it feels ready"

**Success metrics that are good:**

- "Users complete the sign-up flow without support contact"
- "Error rate below 1% on the primary user action"
- "90% of beta users rate the core flow as intuitive in a 5-question survey"

---

## Optional: KPI Dictionary

When a project's success metrics are measured across multiple documents
(PRDs, engine plans, dashboards, stakeholder reports), consolidate them
into a single `docs/standards/kpi-dictionary.md`. This is the
single-source-of-truth pattern for metrics:

- PRDs and requirements reference KPIs by name, not re-definition
- Changes to a KPI definition are breaking changes for everything
  downstream — treat them like an API change
- Retired KPIs stay documented with their replacement

This artifact is **optional** — small projects with a handful of metrics
can define them inline in `requirements.md` without a dictionary. Adopt
it when metric drift between planning and reporting becomes a real risk
(typically: multiple products, multiple audiences, or external reporting
commitments).

Template: `platform/templates/standards/kpi-dictionary.md`. Pattern
absorbed from adsclaw governance practice.

---

## Connecting to Discovery

If `discovery-intake` is also active, the product-lite artifacts are downstream of it:

| Discovery artifact | Feeds into |
|-------------------|-----------|
| `intake-questionnaire.md` §2–3 | `problem-statement.md` |
| `intake-questionnaire.md` §3 | `personas.md` |
| `intake-questionnaire.md` §5 | `requirements.md` (Must tier) |
| `mvp-scope.md` | `requirements.md` (out-of-scope section) |
| `mvp-scope.md` success criteria | `release-intent.md` success signals |

---

## Connecting to ADRs

Requirements often drive architectural decisions. ADRs should reference the requirements
that motivated them. When an architectural decision changes a requirement, update
`requirements.md`, note the ADR that drove the change, and log in `change-log.md`.

---

## Connecting to PRDs

When a product decision is significant enough to warrant its own rationale record —
a new feature direction, a scope pivot, a monetization decision, or a user-experience
strategy change — create a PRD in `docs/requirements/PRD-NNNN-slug.md`.

PRDs are the product counterpart to ADRs. Where ADRs record *how* and *why* the system
is built a certain way, PRDs record *what* and *why* the product includes or excludes
specific capabilities. Together they form the longitudinal decision record for a project.

**When to create a PRD instead of just updating requirements.md:**

- The decision affects multiple requirements or user stories
- The decision has alternatives that were considered and rejected
- The decision will be referenced by future work as context
- A stakeholder needs to review and approve the direction

**When updating requirements.md is sufficient:**

- Routine priority changes within established scope
- Adding acceptance criteria to existing requirements
- Minor scope adjustments within an accepted PRD's boundary

PRDs reference requirements and personas. Requirements reference PRDs that drove them.
When a PRD changes a requirement, update `requirements.md`, note the PRD that drove
the change, and log in `change-log.md`.

The PRD template is at `platform/templates/product/prd.md`.

**Two flavors of PRD, one template.** The template carries a governance core
(Cross-references, Goals & Non-Goals, FRs, Success Metrics) plus four
*optional* execution-spec sections — **Tech Stack, API & Data Contracts,
UI/UX Notes, CI/CD Gates** — borrowed from hackathon-style PRD frameworks.

- **Governance PRDs** (the historical default — scope pivots, monetization
  decisions, etc.) leave the four optional sections marked
  *N/A — governance PRD, not a build spec* (see PRD-0001 for the pattern).
- **Execution-spec PRDs** (driving an AI-agent build of a discrete feature)
  fill the optional sections concretely: which stack is decided, which
  endpoints exist, which empty/loading/error states must be handled, which
  CI/CD gates the implementation must clear.

When in doubt, default to governance flavor. Build PRDs are appropriate when
a single agent will execute the work end-to-end and ambiguity in any of those
four areas would cause drift.

---

## Calibrating Depth by Stage

| Delivery stage | Minimum viable product artifacts |
|---------------|--------------------------------|
| Prototype | Brief problem statement; minimal requirements (Must only); one-line release intent |
| MVP | Full problem statement; full requirements with out-of-scope; personas if multi-audience; concrete release intent with success signals |
| Production v1 | All artifacts fully populated; success metrics concrete and measurable; ongoing update discipline active |

Do not produce production-depth artifacts for a throwaway prototype.
Do not accept prototype-depth artifacts for a production release.

---

## Snippets Superseded

**`legacy/v1-monolith-prompt.txt`** contains the original monolith prompt, now superseded by this
overlay's workflow, `platform/templates/product/requirements.md` (enriched), `personas.md` (new),
and `platform/workflow/discovery-to-composition.md`. Retained as historical reference in `legacy/`.

The original PRD (Product Requirements Document) process from the legacy harness has been
restored as a first-class record type via `platform/templates/product/prd.md`. PRDs are now
integrated into companion rules alongside ADRs, capturing the longitudinal product decision
record that was previously lost in the modular decomposition.

---

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- Templates: `platform/templates/product/`
- Spec: [`docs/requirements/PRD-0001-restore-prd-support.md`](../../../../docs/requirements/PRD-0001-restore-prd-support.md)
