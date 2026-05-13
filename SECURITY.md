<!--
Copyright 2026 Nate DiNiro <nate@bdits.io>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Security Policy

auto-harness welcomes responsible disclosure of vulnerabilities and other security concerns. This document describes how to report a concern and what to expect in response.

---

## Supported Versions

auto-harness is currently at **alpha** maturity. Only the `main` branch is actively supported. Concerns found in earlier tagged commits or branches should still be reported, but fixes will land on `main`.

---

## Reporting a Concern

**Please do not file public GitHub issues for vulnerabilities.** Public reports give adversaries the same head start as defenders. Instead, contact the project privately.

- **Email:** nate@bdits.io
- **Subject prefix:** `[auto-harness security]`

Please include in your report:

- A description of the issue and where it lives in the repository
- Steps to reproduce, or a proof of concept, if practical
- The commit or tag you observed it on
- Any suggested mitigation, if you have one in mind
- Whether you wish to be credited publicly when a fix ships

---

## Response Expectations

| Stage | Target window |
| ----- | ------------- |
| Acknowledgement of receipt | Within 3 business days |
| Initial triage and severity assessment | Within 7 business days |
| Resolution or status update | Within 30 days |

The maintainer commits to:

- Handling your report confidentially
- Coordinating disclosure timing with you before any public discussion
- Crediting you in the fix commit and release notes, unless you prefer to remain anonymous

---

## Scope — Threat Model for a Governance Harness

Because auto-harness is a documentation-and-validator framework rather than a deployed service, the interesting attack surface differs from a typical application. Concerns **in scope** include:

- **Validator bypass** — anything that causes `validate-*.sh` scripts to produce false-negative results, allowing a governance gap to slip through
- **Bootstrap installer issues** — behavior in `install.sh` or `link-skills.sh` that could damage consumer-repo state, exfiltrate consumer data, or unsafely modify files outside the harness submodule
- **Template injection** — content in `platform/templates/` or skill documentation that could mislead downstream consumers into insecure configurations
- **Misleading governance advice** — content in skills or workflow docs that would steer a consumer toward weaker controls under the impression they are stronger
- **Supply-chain concerns** — tampered submodule references, malicious commits, compromised maintainer keys, or compromised release artifacts

**Out of scope:**

- Vulnerabilities in third-party tools the harness merely recommends (report those to the upstream projects directly)
- Concerns that require an attacker to already possess full repository write access
- Issues confined to archived `legacy/` content
- Theoretical concerns without a demonstrable impact on a consumer project

---

## Public Disclosure

After a fix is shipped, the maintainer will:

- Publish a GitHub Security Advisory describing the issue and its resolution
- Update the project change log and release notes
- Credit the reporter, unless they have asked to remain anonymous

Thank you for helping keep auto-harness and its downstream consumers safe.
