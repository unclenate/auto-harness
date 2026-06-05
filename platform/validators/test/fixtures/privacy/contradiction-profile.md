---
regime: none
exemption: No personal data processed.
---

# Privacy Profile — Test Fixture (contradiction-profile)

This fixture declares `regime: none` but the profile body contains
personal-data indicator rows in a data-inventory-style table. This is the
contradiction the validator detects in `--scan-file` mode (in gated mode
the same check compares against data-inventory.md).

The validator should exit 1 against this file.

## Contradiction evidence

The following entries are present in the project's data inventory:

| Field | Classification | Purpose |
|---|---|---|
| email_address | PII | account identification |
| date_of_birth | personal_data | age verification |

These personal-data entries exist in the system — the regime: none
declaration above is therefore contradicted.
