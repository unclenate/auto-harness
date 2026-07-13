<!-- Fixture: a well-formed observation conforming to ADR-0002. Expect exit 0. -->

### A ratified schema with no validator drifts

- **Context:** A shape linter fixture exercising the conformant path.
- **Observation:** Presence plus enum membership is mechanically checkable; semantic quality is not.
- **Implication:** Enforce the shape, leave the judgement to the author.
- **Confidence:** high
- **Severity:** governance-relevant
- **Contributed by:** Test Fixture (fixture-author), 2026-07-11
