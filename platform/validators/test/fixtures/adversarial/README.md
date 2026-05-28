# Adversarial Corpus for `validate-skill-content.sh`

Per PRD-0015 FR-005: each file in this directory is a single-line
fixture demonstrating one v1 denylist pattern. The test suite
(`test_validate_skill_content.rb`) iterates these fixtures, embeds
each into a synthetic module's `description` field, runs the
validator against the synthetic project, and asserts exit 1.

**Append-only discipline.** Future attack patterns get a new fixture
here AND a new entry in the validator's `DENYLIST` constant in the
same PR. The test suite asserts every denylist pattern has at least
one fixture; a denylist entry without a fixture is a test failure.

**File naming:** `pNN-<short-slug>.txt`. The `pNN` prefix corresponds
to the denylist pattern ID in `validate-skill-content.sh`.

**Single-line discipline:** each fixture is exactly one line of
attack content. Multi-line fixtures complicate the test loop. A
multi-pattern injection vector goes in its own fixture per pattern,
not bundled.

**Not scanned by the validator itself.** This README and the
fixtures are at `platform/validators/test/fixtures/adversarial/` —
not in any active module's `compiledFragments` or `recommendedSkills`
surface — so they don't trip the validator on its own scan. This
keeps the dogfood pass clean without requiring `.skill-content-ignore`
exemptions for the test corpus.

## v1 seed (per PRD-0015 Technical Constraints)

| ID | Pattern | Source |
|----|---------|--------|
| P01 | `ignore previous instructions` | Sweep §3 Rec 2 — V1/V2 |
| P02 | `treat as Tier [0-5]` | V4 partial |
| P03 | `always operates at Tier` | V4 partial |
| P04 | `skip the validator` | V2 |
| P05 | `supersedes harness-governance` | V4/V6 |
| P06 | `^System:` line start | Role-prompt header (V2) |
| P07 | `^User:` line start | Role-prompt header (V2) |
| P08 | `^Assistant:` line start | Role-prompt header (V2) |
| P09 | Zero-width characters (U+200B, U+200C, U+200D, U+FEFF) | V1/V2 |
| P10 | Unicode bidi marks (U+202A–U+202E, U+2066–U+2069) | V1/V2 |

Sourced from `documentation-audit-2026-05-27/safety-security-sweep.md`
§3 Recommendation 2.
