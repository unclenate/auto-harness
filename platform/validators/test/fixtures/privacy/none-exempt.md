---
regime: none
exemption: Internal developer tooling with no user-facing surfaces, no data collection, and no processing of personal data. All outputs are configuration files consumed by CI systems only.
---

# Privacy Profile — Test Fixture (none-exempt)

This fixture declares `regime: none` with a non-empty exemption line.
The validator should exit 0 in `--scan-file` mode against this file.

## Exemption rationale

This project is a build-time configuration generator. It emits YAML/JSON
artifacts consumed by CI pipelines. No user data is collected, stored, or
transmitted at runtime. The exemption above captures this rationale.
