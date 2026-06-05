---
# Copyright [[YEAR]] [[OWNER_NAME]] <[[OWNER_EMAIL]]>
# SPDX-License-Identifier: [[SPDX_LICENSE]]
regime: [[REGIME]]
exemption: [[EXEMPTION_REASON_OR_BLANK]]
---

# Privacy Profile — [[PROJECT_NAME]]

> Owner: [[OWNER]]
> Last updated: YYYY-MM-DD

Required artifact for the `management/privacy-by-design` overlay. Declares the
legal regime this project operates under and the Cavoukian-7 universal floor
that applies regardless of jurisdiction.

## Cavoukian's 7 Foundational Principles of Privacy by Design

These principles are the universal floor. They apply to every project,
independent of jurisdiction or legal regime.

1. **Proactive not reactive; preventative not remedial** — Anticipate and
   prevent privacy-invasive events before they happen; do not wait for harm
   to occur.
2. **Privacy as the default setting** — Personal data is automatically
   protected in any given IT system or business practice; no action is
   required by the individual to protect their privacy.
3. **Privacy embedded into design** — Privacy is not bolted on as an add-on
   after the fact, but is a core component of the system's design and
   architecture.
4. **Full functionality — positive-sum, not zero-sum** — Accommodate all
   legitimate interests and objectives; "privacy vs. security" is a false
   dichotomy — both can be achieved.
5. **End-to-end security — full lifecycle protection** — Strong security
   measures are essential to privacy, from initial collection to final
   disposal (data retention and secure destruction included).
6. **Visibility and transparency — keep it open** — All stakeholders can
   verify that business practices and technologies operate as promised;
   trust but verify.
7. **Respect for user privacy — keep it user-centric** — Respect the
   privacy interests of individual users through strong privacy defaults,
   appropriate notice, and empowering user-friendly options.

---

## Regime Choice

> **Bias guardrail.** No legal regime is the default. Declare yours below. Do not assume
> GDPR, US (CCPA/CPRA), or any single regime applies — privacy law is jurisdictional and
> the principles (Cavoukian's 7) are the universal floor, not any one country's statute.

| Regime | Jurisdiction | Key obligations |
| ------ | ------------ | --------------- |
| GDPR | European Union / EEA | Lawful basis, data subject rights, DPO, breach notification (72 h) |
| CCPA / CPRA | California, USA | Right to know / delete / opt-out of sale; sensitive PI protections |
| LGPD | Brazil | Similar to GDPR; DPO, lawful bases, ANPD oversight |
| PIPEDA | Canada (federal) | Consent-based; PIPEDA breach of security safeguards reporting |
| PIPL | China | Consent-first; cross-border transfer restrictions; security assessments |
| Multiple | Cross-jurisdictional | List each applicable regime in the Declared Regime field |
| decide-later | TBD | Interim research / internal projects; must be resolved before any PII is processed |
| none | N/A | Project handles no personal or sensitive data (exemption required — see below) |

**Selected regime:** [[REGIME]]

---

## `none`-Exemption

If you selected `regime: none` in the frontmatter above, you **must** provide a
one-line exemption explaining why this project handles no personal or sensitive
data. Leave blank if a real regime was selected.

**Exemption:** [[EXEMPTION_REASON_OR_BLANK]]

Examples of valid exemptions:

- "Internal developer tooling that processes only anonymized build-log artifacts."
- "Read-only public-dataset analytics; no user accounts or PII collected."

If the exemption field is left blank while `regime: none` is set, the
`validate-privacy-by-design.sh` validator will fail with an explicit error.

---

## Implementation Notes

Fill this section with project-specific notes on how the declared regime is
implemented (consent flows, data-retention schedules, DPO contact, etc.).
