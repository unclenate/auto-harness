<!-- Fixture: Confidence vocabulary ('Low') misfiled into Severity. Expect exit 1 + FR-S01 hint. -->

### An observation misfiling a Confidence value into Severity

- **Context:** Severity carries 'Low' — a Confidence value, capitalized.
- **Observation:** This is the 21-entry misfile class; case is normalized before the enum check.
- **Implication:** The hint must name that low/medium are Confidence values.
- **Confidence:** high
- **Severity:** Low — a backlog-disposition lesson
- **Contributed by:** Test Fixture (fixture-author), 2026-07-11
