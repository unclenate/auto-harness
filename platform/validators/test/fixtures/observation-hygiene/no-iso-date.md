<!-- Fixture: Contributed-by without an ISO-8601 date. Expect exit 1. -->

### An observation whose attribution lacks an ISO date

- **Context:** Contributed by names an author but no date.
- **Observation:** The ISO-date check must reject a bare name.
- **Implication:** Attribution needs both a name and a YYYY-MM-DD date.
- **Confidence:** medium
- **Severity:** risk-bearing
- **Contributed by:** Test Fixture (fixture-author)
