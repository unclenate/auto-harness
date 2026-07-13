<!-- Fixture: Confidence value outside {low, medium, high}. Expect exit 1. -->

### An observation with an off-enum Confidence

- **Context:** Confidence carries a non-enum value.
- **Observation:** The leading token is not one of low/medium/high.
- **Implication:** The enum check must reject it.
- **Confidence:** certain
- **Severity:** architectural
- **Contributed by:** Test Fixture (fixture-author), 2026-07-11
