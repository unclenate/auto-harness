---
regime: none
exemption: No personal data processed.
---

# Privacy Profile — Test Fixture (contradiction-profile)

This fixture declares `regime: none` but the profile body contains
personal-data indicator lines. This is the contradiction the validator
detects in `--scan-file` mode (in gated mode the same check compares
against data-inventory.md).

The validator should exit 1 against this file.

## Contradiction evidence

The following entries are present in the project's personal_data schema:

| data_subject | email_address | collected_at | purpose   |
|---|---|---|---|
| user         | user@example.com | signup | account   |

PII fields: name, email, date_of_birth, IP address.

These personal-data entries exist in the system — the regime: none
declaration above is therefore contradicted.
