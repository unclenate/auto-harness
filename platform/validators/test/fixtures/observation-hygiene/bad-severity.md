<!-- Fixture: Severity 'process' — the single most common off-enum drift. Expect exit 1. -->

### An observation with an off-enum Severity

- **Context:** Severity carries 'process', which is not an ADR-0002 value.
- **Observation:** enforce-as-locked treats this as a violation on new observations.
- **Implication:** The author must pick a canonical severity.
- **Confidence:** high
- **Severity:** process
- **Contributed by:** Test Fixture (fixture-author), 2026-07-11
