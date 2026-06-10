---
maturity: digital-twin-prototype
conformance:
  - standard: ISO 23247-5
    status: published
governingPrinciples: Purpose (public good); Trust (security, openness, quality)
---

# Twin Profile — Test Fixture (emerging-as-published)

This fixture declares ISO 23247-5 (the digital thread standard — a known emerging
standard) as `status: published`. This is an overclaim. The validator should exit 1
in `--scan-file` mode against this file (overclaim guard).

## Standards conformance

| Standard | Targets | Status (published / emerging) |
|----------|---------|-------------------------------|
| ISO 23247-5 | Digital thread | published |

> This is intentionally wrong — ISO 23247-5 is emerging, not ratified.
