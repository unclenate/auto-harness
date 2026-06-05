<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Management Overlay: Privacy by Design

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay installs privacy-by-design as a **default-on cross-cutting
concern** across any harnessed project that handles personal data.
It uses Cavoukian's 7 principles as a jurisdiction-neutral spine and
pairs them with a consumer-declared legal regime (GDPR, CCPA, PIPEDA,
HIPAA, or `none` for regime-exempt projects). Opting out of the overlay
is done by declaring a **`none` exemption** in the privacy profile — this
keeps the overlay active in exempt mode (companion rules fire; review
gates apply) rather than removing it from the manifest.

## What This Overlay Requires

- **Required:** `docs/privacy/privacy-profile.md` — the privacy contract.
  Declares the legal regime, the active Cavoukian principles, and any
  scope exemptions. Template at `platform/templates/privacy/`.
- **Optional:** `docs/privacy/data-inventory.md` — an enumerated map of
  personal-data fields, storage location, retention, and access control.
  Accepted by the data-handling companion rule as an alternative to
  updating the privacy profile on every sensitive-path change.
- **Optional:** `docs/privacy/privacy-impact-assessment.md` — a PIA for
  a specific feature or data-handling change, typically authored before
  shipping a new data collection surface.

## Sensitive Paths and Companion Rules

The overlay registers eight sensitive-path patterns covering the most
common surfaces where personal data enters or exits a system: `pii`,
`personal`, `^src/.*user`, `consent`, `analytics`, `telemetry`,
`tracking`, and `^auth/`. Changes touching these paths trigger the
companion-rule check.

**Rule 1 — Data-handling changes pair a privacy document.**
When a changeset touches paths matching `pii`, `personal`, `consent`,
`analytics`, or `telemetry`, at least one of the following must also
appear in the same PR:

- `docs/privacy/privacy-profile.md`
- `docs/privacy/data-inventory.md`
- An `docs/adr/ADR-*` record

This prevents silent expansion of the data surface without a reviewable
privacy artifact. Reviewers confirm the privacy implications are captured
and the declared regime still holds.

**Rule 2 — Privacy-profile regime or exemption changes pair a change-log
entry or ADR.**
When `docs/privacy/privacy-profile.md` itself changes, at least one of
the following must appear in the same PR:

- `docs/project/change-log.md`
- An `docs/adr/ADR-*` record

Reviewers confirm a regime or exemption change is intentional and not a
drive-by edit.

## Review Gate

Human review is required for any of the following:

- Broadening data collection (new fields, new signals, new sources).
- Adding third-party data egress (new vendor, new API integration that
  sends personal data outbound).
- Weakening a declared privacy default (e.g., flipping an opt-in to
  opt-out, removing a consent gate, loosening a retention policy).
- Changing the declared legal regime in the privacy profile.
- Logging PII-shaped data (email addresses, device IDs, IP addresses,
  user-content fragments) to observability systems, crash reporters, or
  analytics pipelines.

Agents may not perform any of the above without explicit human approval
and a corresponding privacy artifact update.

## See Also

- Module definition: [`module.yaml`](module.yaml)
- Active modules table: [`HARNESS.md`](../../../../HARNESS.md)
- Templates: `platform/templates/privacy/`
- Origin: [`ADR-0018`](../../../../docs/adr/ADR-0018-privacy-by-default-posture.md), [`PRD-0018`](../../../../docs/requirements/PRD-0018-privacy-by-design.md)
