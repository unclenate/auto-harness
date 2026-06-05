---
regime: none
exemption: Internal developer tooling with no user-facing surfaces and no data collection.
---

# Privacy Profile — Test Fixture (none-exempt-empty-inventory)

This fixture declares `regime: none` with a valid exemption. The profile body
contains a data-inventory-style table with ONLY a column-header row and a
separator row — no actual data rows.

Regression guard for the header-only false-positive: a table header row alone
must NOT trigger the regime:none contradiction check. The validator should
exit 0 in `--scan-file` mode against this file.

## Data Inventory (empty)

| Field | Type | Purpose |
|---|---|---|
