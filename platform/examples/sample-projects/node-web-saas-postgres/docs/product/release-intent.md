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

# Release Intent

**Release:** v1.0 — Reference implementation
**Growth stage:** MVP / Early Access
**Owner:** @platform-team
**Last updated:** 2024-01-15

---

## Target Outcome

Developers can initialize a governance-compliant Node/TypeScript/Postgres project by copying
this sample, adapting the manifest to their project, and reaching a passing validator run —
without reading every module definition or asking the platform team for help.

---

## Feature Maturity

**v1 / GA** — This is a reference implementation, not a deployed product. It is production-ready
in the sense that all validators pass, all required artifacts are populated with real content,
and the discovery-to-production pipeline is demonstrated end-to-end. It will be updated as the
platform evolves but is stable enough to copy and use today.

---

## Scope of This Release

- Valid `harness.manifest.yaml` with full Node/TS/Postgres/production-saas module set
- All required artifacts present and non-stub (discovery through ops)
- Validators green end-to-end: manifest, module graph, required artifacts, placeholders
- Filled-in discovery artifacts demonstrating the intake questionnaire workflow
- Filled-in product artifacts (personas, requirements, problem statement, release intent)
- Filled-in ops artifacts (environment inventory, release checklist, rollback checklist)

---

## What Is Not in This Release

- Working application code (this is a governance reference, not a deployable app)
- Database schema or migrations (requires a real application context)
- CI workflow configured for the sample project itself (platform CI covers validators)
- A second stack variant (Python sample is a separate project)

---

## Success Signals

| Signal | How measured | Target |
|--------|-------------|--------|
| Validators green | All four validators exit 0 against this sample | Confirmed in platform CI |
| No placeholder tokens | `validate-placeholders.sh` passes | Confirmed in platform CI |
| Usable as a starter | Developer can copy and adapt to green in one session | Manual usability check at each platform release |
| Discovery chain consistent | intake-questionnaire → mvp-scope → requirements cross-references resolve | Manual review |

---

## Release Checklist Reference

This is a sample project — no production deployment checklist applies. The ops artifacts in
`docs/ops/` demonstrate what a production-saas release checklist looks like when filled in.
