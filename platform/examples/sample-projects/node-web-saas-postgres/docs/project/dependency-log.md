<!--
NOTE: This is an auto-harness sample-project file (reference implementation).
If you copy this file into your own project, replace the SPDX/copyright
header below with your own — running
`bash platform/bootstrap/set-consumer-headers.sh` from your project root
after the copy will do this for you.
-->

<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Dependency Log

**Owner:** @platform-team
**Last updated:** 2024-03-01

External dependencies that the platform relies on — tools, services, and third-party
integrations. Update this log when a new dependency is introduced or when the status of
an existing dependency changes.

A dependency becomes a risk when its status changes to At Risk or Deprecated. Flag it in
`docs/security/risk-register.md` and document a mitigation plan.

---

| Dependency | Type | Version / Channel | Owner | Status | Impact if unavailable |
| ---------- | ---- | ----------------- | ----- | ------ | --------------------- |
| Ruby (stdlib only) | Runtime | 3.0+ (system or rbenv) | @platform-team | Stable | Validators cannot run; all CI checks fail |
| Bash | Runtime | 4.0+ (macOS ships 3.x — use Homebrew) | @platform-team | Stable | Validator shell scripts cannot execute |
| ripgrep (`rg`) | Runtime tool | Latest stable | @platform-team | Stable | `validate-placeholders.sh` cannot scan; CI step skipped |
| GitHub Actions | CI platform | ubuntu-latest runner | @platform-team | Stable | CI integration workflows do not run |
| ruby/setup-ruby action | CI action | v1 | @platform-team | Stable | Ruby not available in CI; validators fail |
| Agent Skills standard | Protocol | 1.0 (open standard) | Anthropic / community | Stable | Skills not auto-discovered by compliant clients; manual paste required |
| GitBook | Documentation hosting | Cloud (SaaS) | @platform-team | Stable | Platform docs not publicly browseable; source files still accessible in repo |

---

## Dependency Health Definitions

- **Stable** — actively maintained; no known deprecation timeline
- **Monitoring** — stable but watch for deprecation signals or API changes
- **At Risk** — known deprecation or breaking change expected; mitigation plan required
- **Deprecated** — no longer maintained; replacement must be in place before next release
