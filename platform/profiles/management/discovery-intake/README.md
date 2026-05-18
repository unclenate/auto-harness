<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Management Overlay: Discovery Intake

This overlay adds the pre-project discovery phase to the harness. Use it for any project
that starts without a complete, validated specification — which is most projects.

---

## When to Use This Overlay

Include `discovery-intake` in your manifest when:

- The project starts from a raw idea or informal description
- Requirements exist as a mockup, prototype, or wireframes rather than a written spec
- A client or stakeholder has goals but hasn't articulated requirements formally
- You need to validate and formalize an existing spec before building

You do not need this overlay if you are starting from a fully validated, formally documented
specification that already maps cleanly to requirements, personas, and MVP scope.
In practice, that is rare.

---

## What This Overlay Produces

Two required artifacts:

**`docs/discovery/intake-questionnaire.md`** — A filled-in copy of the intake questionnaire,
capturing what was learned from the client, stakeholder, or self-interview. This becomes
the provenance record for the product artifacts that follow.

**`docs/discovery/mvp-scope.md`** — An explicit boundary document: what is in scope for
the MVP, what is explicitly out of scope, and the success criteria that define "done."

Two optional artifacts:

**`docs/product/personas.md`** — User personas extracted from the intake, defining who
the product is for and explicitly who it is not for.

**`docs/discovery/starting-assets.md`** — Log of visual or other non-text artifacts
(mockups, wireframes, Vercel prototypes, screenshots) used as the basis for requirements,
with requirements extracted from each and open questions surfaced.

---

## Discovery Workflow

### Entry Points

Projects arrive in different states. The workflow meets them where they are.

**Starting from a raw idea:**

1. Run the full intake questionnaire — all 8 sections
2. Produce `problem-statement.md` and `personas.md` from sections 2–3
3. Produce `requirements.md` from section 5
4. Define `mvp-scope.md` from section 5 + the composition signals in section 8
5. Select modules, initialize `harness.manifest.yaml`

**Starting from a mockup or Vercel prototype:**

1. Log the asset in `starting-assets.md` — note what flows are covered and what isn't
2. Run intake questionnaire sections 2–6 to fill gaps the visual doesn't answer
3. Extract requirements from the mockup: what does each screen imply about the data model, user actions, and business rules?
4. Produce `requirements.md` with explicit priority tier (MVP vs. later)
5. Define `mvp-scope.md` — the mockup may show more than the MVP; be explicit about what ships first

**Starting from wireframes or design system:**

1. Log assets in `starting-assets.md`
2. Extract structural requirements from the wireframes (navigation, data entry points, content hierarchy)
3. Run sections 2–5 of the intake to validate and fill gaps
4. Produce `requirements.md` and `mvp-scope.md`

**Starting from an existing written spec:**

1. Run the questionnaire against the spec — not to re-ask what the spec answers, but to find what it doesn't answer
2. Gaps in the spec become open questions in the intake questionnaire
3. Produce or validate `problem-statement.md`, `personas.md`, `requirements.md`, `mvp-scope.md`
4. If the spec is very detailed, the intake questionnaire output can be brief — it just needs to cover the gaps

---

## Running the Intake with a Client or Stakeholder

The intake questionnaire is designed to be run as a conversation, not filled out as a form.

**Recommended approach:**

- Work through sections 1–5 in a single 60–90 minute session
- Use the embedded probe questions when answers are vague or incomplete
- Take notes directly in the questionnaire file
- Follow up on sections 6–8 asynchronously if needed

**What to watch for:**

- Vague MVP scope ("everything that's in the mockup") — push back until the shortest viable version is named
- Missing out-of-scope items — if only in-scope items are named, scope will grow during development
- Conflicting answers between problem description and requirements — surface this explicitly
- Unclear success criteria — "it feels ready" is not a criterion

**After the intake session:**
Produce the downstream artifacts (problem statement, personas, requirements, MVP scope)
within 48 hours while the conversation is still fresh. Do not let the questionnaire sit
as the only record.

---

## Running Discovery with an AI Agent

If using Claude or another AI agent to assist with discovery:

1. Share the filled-in intake questionnaire with the agent
2. Ask the agent to produce a draft `problem-statement.md` and `personas.md` from sections 2–3
3. Ask the agent to draft `requirements.md` from section 5, using Must/Should/Later priority tiers
4. Ask the agent to draft `mvp-scope.md` using the section 5 answers and the composition signals summary
5. Review every draft — the agent works from what you gave it; gaps in the intake produce gaps in the artifacts
6. Ask the agent to propose an initial `harness.manifest.yaml` from the composition signals summary

The agent must not finalize module selection or write the manifest without human review.
The composition signals table gives candidate modules; the human confirms the selection.

---

## Connecting Discovery to product-lite

This overlay precedes and feeds `product-lite`. The relationship:

| discovery-intake produces | product-lite consumes |
|--------------------------|----------------------|
| `intake-questionnaire.md` (source of truth for requirements) | `problem-statement.md` |
| `mvp-scope.md` (MVP boundary) | `requirements.md` (with MVP priority tier) |
| `personas.md` (who we're building for) | `release-intent.md` |

Once discovery artifacts are complete and `product-lite` is active, the `discovery-intake`
overlay continues to provide the companion rule: when `requirements.md` or `mvp-scope.md`
changes, a `change-log.md` entry or ADR is required. This keeps product artifacts live
during development.

---

## Calibrating Governance by Growth Stage

Different delivery stages warrant different governance depth. Do not apply production SaaS
ceremony to a throwaway prototype.

| Stage | Delivery module | Discovery depth |
|-------|----------------|----------------|
| Throwaway prototype | `delivery/prototype` | Intake + MVP scope minimum; skip formal personas if solo |
| MVP / early access | `delivery/prototype` or `production-saas` | Full discovery artifacts; personas required |
| Production v1 | `delivery/production-saas` | Full artifacts; risk register active |
| Scale / growth | `delivery/production-saas` | Full artifacts; program-lite if multi-team |

As the project matures, the manifest composition evolves. Replace `delivery/prototype` with
`delivery/production-saas` when the project needs real ops readiness. Add `project-standard`
for milestone and scope tracking. Add `program-lite` if multiple workstreams emerge.

---

## Keeping Product Artifacts Live During Development

Discovery does not end when engineering begins. Product direction changes during development —
new information surfaces, constraints shift, scope adjusts.

When requirements change after discovery:

1. Update `docs/product/requirements.md` — change the priority tier, add/remove items
2. Log the change in `docs/project/change-log.md` with: what changed, why, who decided
3. If the change is architectural, create a new ADR
4. If the change is a significant product decision, create a new PRD
5. If the MVP scope boundary shifts materially, update `docs/discovery/mvp-scope.md`

The companion rule in this module enforces steps 2–4 in CI: a PR that changes
`requirements.md` or `mvp-scope.md` without also touching `change-log.md`, an ADR,
or a PRD will fail.

---

## Snippets Superseded

The following legacy snippets are absorbed by this overlay and the enriched platform templates:

- Original PRD generation prompt — the PRD process has been restored as a first-class
  record type via `platform/templates/product/prd.md`, integrated into companion rules
  alongside ADRs. Discovery artifacts feed PRDs just as they feed requirements.
- Original ADR prompt — intent absorbed into `workflow/discovery-to-composition.md` §7

The original monolith prompt is archived at `legacy/v1-monolith-prompt.txt`.
