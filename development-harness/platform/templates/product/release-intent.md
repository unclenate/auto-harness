# Release Intent

**Release:** *(version, milestone, or release name)*
**Growth stage:** *(prototype / MVP / early access / v1 / GA)*
**Owner:** @owner
**Last updated:** YYYY-MM-DD

---

## Target Outcome

*(What is this release intended to achieve? Write one to three sentences from the user's
perspective — not a feature list. Answer: what becomes possible or better for the user after
this release ships?)*

---

## Feature Maturity

*(Select one and briefly describe what it means for this release.)*

| Tier | Meaning |
|------|---------|
| Prototype | Throwaway or internal only; not suitable for real user data |
| Beta / Early Access | Real users, known rough edges; feedback is the primary goal |
| v1 / GA | Production-ready; support and reliability expectations apply |
| Internal-only | Audience is the team or company; external-facing polish not required |

**This release:** *(state the tier and what it means in practice for this specific release)*

---

## Scope of This Release

*(What is included in this release? Keep it to the Must-tier requirements from
`docs/product/requirements.md`. If you find yourself listing Should or Later tier items,
they belong in a future release.)*

---

## What Is Not in This Release

*(Explicitly name what is NOT included, especially if stakeholders might expect it.
Out-of-scope is as important as in-scope for setting expectations.)*

---

## Success Signals

*(Leading indicators that will tell the team the release met its intent. These should be
observable within days or weeks of shipping — not lagging metrics that take months to move.)*

| Signal | How measured | Target |
|--------|-------------|--------|
| | | |

**Good success signals:**
- "Users complete the onboarding flow without support contact"
- "Error rate on the primary action below 1% in the first week"
- "90% of beta users complete the core flow in their first session"

**Not good enough:**
- "Users like it" (not measurable)
- "It feels ready" (not observable)
- "No major bugs" (defines success by absence, not presence)

---

## Release Checklist Reference

*(For production-saas releases, confirm the following are complete before shipping.)*

- [ ] `docs/ops/release-checklist.md` reviewed and signed off
- [ ] `docs/ops/rollback-checklist.md` tested or reviewed
- [ ] Named release owner confirmed
- [ ] Named rollback authority confirmed
