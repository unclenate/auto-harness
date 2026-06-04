<!--
Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
SPDX-License-Identifier: [[SPDX_LICENSE]]
-->

# Project Intake Questionnaire

**Purpose:** Structured instrument for extracting requirements, gauging scope, and calibrating
delivery complexity — regardless of how much (or how little) definition exists at the start.

**Used by:**

- Developers gathering requirements from a client or stakeholder
- AI agents (Claude) conducting a discovery session interactively
- Solo builders clarifying their own thinking before starting
- Teams validating a spec or mockup against what they actually need

**How to use it:**
Work through each section in order. Skip questions that genuinely don't apply — but don't
skip them because the answer is uncomfortable or unclear. Unclear answers are the most
valuable ones to surface.

If working with a client or stakeholder, run sections 1–5 as a conversation, not a form.
The follow-up questions embedded in each section are for probing incomplete answers.

After completing this questionnaire, produce:

- `docs/product/problem-statement.md`
- `docs/product/personas.md`
- `docs/product/requirements.md`
- `docs/discovery/mvp-scope.md`

Then complete the **Composition Signals Summary** at the end to select harness modules.

---

## Section 1 — Project Identity

**1.1 Working title**
*(What do you call this thing right now? It doesn't need to be final.)*

Answer:

---

**1.2 One-sentence description**
*(Complete: "This is a [thing] that helps [who] [do what].")*

Answer:

---

**1.3 Primary goal for this phase**
*(What does success look like in 90 days? In 6 months? These can be different.)*

90-day goal:
6-month goal:

---

**1.4 Production URL or target domain** *(or "TBD")*

Answer:

---

## Section 2 — Problem and Opportunity

**2.1 What problem are you solving?**
*(Describe it from the user's perspective, not the product's perspective.)*

Answer:

> **Probe:** How do users currently solve this problem? What's broken or missing about that?

Current workaround:
What's broken about it:

---

**2.2 Why is this worth building now?**
*(What changed that makes this the right moment — market, technology, regulatory, personal?)*

Answer:

---

**2.3 What happens if this doesn't get built?**
*(Is this a must-have or a nice-to-have? What is the cost of not doing it?)*

Answer:

---

**2.4 Have you seen this attempted before?**
*(Existing products, competitors, failed attempts — what can you learn from them?)*

Answer:

---

## Section 3 — Users and Stakeholders

**3.1 Who are the primary users?**
*(The people who directly use the product to accomplish a goal. Be specific — "small business owners" is too broad; "restaurant owners managing staff scheduling manually in spreadsheets" is useful.)*

Primary user description:
What they need to accomplish:
What frustrates them about how they do it today:

---

**3.2 Are there secondary users or operators?**
*(Admins, managers, reviewers, integrating systems — people who interact with the product but aren't the primary beneficiary.)*

Secondary user / operator:
Their role in the product:

---

**3.3 Who are the key stakeholders?**
*(Decision-makers, funders, approvers — people who don't use the product but have a stake in its success.)*

Stakeholder name / role:
What matters most to them:

---

**3.4 Who is explicitly NOT the audience?**
*(Saying who this is not for is as important as saying who it is for. It prevents scope creep.)*

Answer:

---

## Section 4 — Starting Point

**Check all that apply:**

- [ ] **Raw idea** — no artifacts exist yet; starting from this questionnaire
- [ ] **Informal requirements** — notes, emails, or verbal description of what's needed
- [ ] **Mockup or prototype** — Vercel deploy, Figma, clickthrough, or screenshot set → attach or link below
- [ ] **Wireframes or design system** — structural layout without visual polish → attach or link below
- [ ] **Detailed written spec** — document describing requirements in depth → attach or link below
- [ ] **Existing codebase** — building on or extending existing code → describe below
- [ ] **Existing deployed product** — iteration on something live → describe below

**Asset links or descriptions:**

---

**4.1 If starting from a mockup, prototype, wireframes, or spec:**

What screens or flows are covered?

What is NOT covered by the existing artifacts that needs to be defined?

What questions does the visual/spec material raise that aren't answered?

*(These gaps become open questions in `docs/discovery/starting-assets.md`)*

---

**4.2 Existing systems or integrations:**
*(APIs, databases, auth providers, payment processors, third-party services that must connect.)*

| System | Integration type | Required or optional |
|--------|-----------------|---------------------|
| | | |

---

## Section 5 — Requirements Calibration

**5.1 What must exist for this to be useful?**
*(The shortest possible list of things without which the product doesn't deliver value. This becomes the MVP.)*

1.
2.
3.

> **Probe:** If you had to cut one more thing, what would it be?

---

**5.2 What would make it great but isn't essential for the first version?**
*(Things you want but can defer. v1 backlog.)*

1.
2.
3.

---

**5.3 What is explicitly out of scope for now?**
*(Name things you have already decided not to build in this phase. Naming them prevents them from sneaking back in.)*

1.
2.
3.

---

**5.4 Non-negotiable constraints**
*(Things that cannot be changed — regulatory requirements, existing contracts, accessibility mandates, platform restrictions.)*

| Constraint | Source / reason |
|------------|----------------|
| | |

---

**5.5 How will you know when the MVP is done?**
*(Concrete signal, not a feeling. "Users can complete a purchase" is concrete. "It feels ready" is not.)*

Answer:

---

## Section 6 — Scale and Growth Expectations

**6.1 Users at launch**
*(Realistic number, not aspirational.)*

Answer:

**6.2 Users at scale**
*(The number that would feel like success in 2–3 years.)*

Answer:

---

**6.3 Performance sensitivity**
*(Does response time matter to the user experience? Are there SLAs?)*

- [ ] High — sub-second responses expected (real-time UI, live data)
- [ ] Medium — seconds are acceptable, minutes are not
- [ ] Low — batch or async workflows, latency tolerance is high

Notes:

---

**6.4 Data sensitivity**
*(Check all that apply.)*

- [ ] PII (personally identifiable information)
- [ ] Financial data (payment processing, account balances)
- [ ] Health data (HIPAA-adjacent)
- [ ] User-generated content (moderation implications)
- [ ] Proprietary business data
- [ ] No sensitive data

---

**6.5 Geographic or regulatory requirements**
*(GDPR, CCPA, HIPAA, SOC2, specific country restrictions, data residency.)*

Answer:

---

## Section 7 — Team and Delivery Context

**7.1 Team composition**
*(Number of developers, designers, product owners — humans who will commit to this repo.)*

Answer:

**7.2 AI-assisted development**
*(Which tools, if any. Claude Code, Cursor, Copilot, other.)*

Answer:

---

**7.3 Timeline expectations**

First usable version by:
Production-ready by:
Hard deadline (if any) and reason:

---

**7.4 Budget / delivery tier**
*(Honest assessment of where this project is.)*

- [ ] **Throwaway prototype** — validates an idea, may be discarded
- [ ] **MVP / early access** — real users, rough edges acceptable
- [ ] **Production v1** — needs reliability, ops readiness, real support
- [ ] **Scale / growth** — existing production system, growth investment

---

**7.5 Deployment target preference**
*(Where should this run? Vercel, AWS, GCP, Fly.io, Railway, self-hosted, unknown.)*

Answer:

---

## Section 8 — Technical Context

**8.1 Technology preferences or constraints**
*(Languages, frameworks, platforms the team knows well or is required to use.)*

Answer:

**8.2 Technology aversions**
*(Things the team wants to avoid and why.)*

Answer:

---

**8.3 Target platforms**
*(Check all that apply.)*

- [ ] Web browser (desktop)
- [ ] Web browser (mobile)
- [ ] Native iOS
- [ ] Native Android
- [ ] REST or GraphQL API (consumed by others)
- [ ] Background / async processing
- [ ] CLI tool

---

**8.4 Existing infrastructure**
*(Hosting accounts, databases, auth providers already in use that this project should fit into.)*

Answer:

---

## Section 9 — Privacy

**9.1 Does this project handle personal or sensitive data?**
*(Personal data includes names, emails, IP addresses, location data, behavioral data, and anything
that can identify an individual. Sensitive data includes health, financial, biometric, and
government-ID data. When in doubt, assume yes.)*

- [ ] Yes — personal data (names, emails, identifiers, behavioral data)
- [ ] Yes — sensitive data (health, financial, biometric, government ID)
- [ ] Yes — both personal and sensitive data
- [ ] No — no personal or sensitive data of any kind

If no: [[REASON_NO_PERSONAL_DATA]]
*(One-sentence explanation, e.g., "Internal developer tooling with no end-user accounts." This
becomes the documented `regime: none` exemption in `docs/privacy/privacy-profile.md`.)*

---

**9.2 Which legal privacy regime(s) apply?**
*(Check all that apply. Leave blank only if §9.1 is No.)*

- [ ] GDPR (EU / EEA users or EU-based processing)
- [ ] CCPA / CPRA (California consumers)
- [ ] LGPD (Brazil)
- [ ] PIPEDA / Law 25 (Canada)
- [ ] PIPL (China)
- [ ] HIPAA (US health data)
- [ ] Other: [[OTHER_REGIME]]
- [ ] Unknown — needs legal review

Applicable regimes: [[APPLICABLE_REGIMES]]

---

**9.3 Data subjects and data categories**
*(Who does the data belong to, and what categories of data will be collected or processed?)*

Data subjects (e.g., end users, employees, patients): [[DATA_SUBJECTS]]

Data categories collected: [[DATA_CATEGORIES]]

---

## Composition Signals Summary

Complete this after finishing the questionnaire. It maps answers to candidate harness modules.
Use this to initialize `harness.manifest.yaml`.

| Signal from answers | Candidate module |
|--------------------|-----------------|
| Web UI needed (§8.3) | `architectures/web-app` |
| API surface for external consumers (§8.3) | `architectures/api-service` |
| Async / background processing (§8.3) | `architectures/event-driven` |
| Relational data / SQL mentioned (§4.2, §8.1) | `data/relational-postgres` |
| File storage / media / uploads (§5.1, §8.3) | `data/object-storage` |
| Document or JSON store (§8.1) | `data/document-store` |
| Node / TypeScript preferred (§8.1) | `stacks/node-typescript` |
| Python preferred (§8.1) | `stacks/python` |
| Supabase mentioned or preferred (§4.2, §8.1) | `domains/supabase` |
| Media processing pipeline (§5.1, §8.3) | `domains/media-pipeline` |
| Throwaway prototype (§7.4) | `delivery/prototype` |
| MVP or production (§7.4) | `delivery/production-saas` |
| Internal tooling (§7.1, §7.4) | `delivery/internal-platform` |
| Multi-team or multi-workstream (§7.1) | `management/program-lite` |
| Claude Code in use (§7.2) | `agents/claude-code` |
| Other LLM tool in use (§7.2) | `agents/generic-llm` |
| Always include for real products | `management/product-lite` + `management/project-standard` |
| Starting from this questionnaire | `management/discovery-intake` |
| Handles personal or sensitive data (§9.1, §9.2) — default: yes | `management/privacy-by-design` (default-on; remove only with a documented `regime: none` exemption) |

**Selected modules for this project:**

```yaml
# Paste into harness.manifest.yaml
modules:
  core:
    - kernel/base
  stacks:
    - # node-typescript or python
  architectures:
    - # web-app, api-service, event-driven
  data:
    - # relational-postgres, object-storage, document-store
  delivery:
    - # prototype or production-saas
  management:
    - discovery-intake
    - product-lite
    - project-standard
    - privacy-by-design
  agents:
    - base
    - # claude-code or generic-llm
```

---

*See `platform/workflow/discovery-to-composition.md` for the full workflow from this questionnaire to a running project.*
