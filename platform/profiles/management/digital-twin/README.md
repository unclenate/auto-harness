<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# Management Overlay: Digital Twin / Scenario Runtime

**Depends on:** `kernel/base`.
**Conflicts with:** None.

This overlay governs projects that **model real-world systems, run scenarios,
and publish decision-support** — a default-off, opt-in cross-cutting concern
that layers on whatever the project is (civic, real-estate / built-environment,
AI-datacenter, healthcare, geospatial). It is the second discipline overlay
after `privacy-by-design`, and it makes "build a planning model that can be
transformed into an operational twin" a governed conformance question.

## What This Overlay Requires

- **Required:** `docs/twin/twin-profile.md` — the forcing artifact. Declares the
  **maturity level** (digital model → shadow → prototype → operational →
  control-loop), the **standards conformance** the twin targets and at what
  *status* (published vs emerging), and the **governing principles** (the Gemini
  Principles). Template at `platform/templates/digital-twin/`.
- **Optional (required by maturity level):** scenario-manifest-spec,
  data-provenance, model-registry, agent-registry, run-log-spec,
  uncertainty-policy, publication-policy, security-boundaries — see the maturity
  ladder in `overview.md`. A digital *model* needs only the profile; an
  *operational* twin needs run-log + publication + review gates.

## Maturity ladder (declare your level; do not overclaim)

| Level | Adds (required) |
|---|---|
| 1 Digital model | twin-profile only |
| 2 Digital shadow | + data-provenance |
| 3 Digital twin prototype | + scenario-manifest-spec + model-registry + agent-registry + uncertainty-policy |
| 4 Operational twin | + run-log-spec + publication-policy + review gates |
| 5 Closed-loop / control twin | + security-boundaries + safety / second-review gates |

> **Bias guardrail — default-deny overclaiming.** You may not claim a maturity
> level your evidence does not support (no "operational twin" without live
> synchronization, run logs, and operational governance), cite an emerging
> standard as ratified, or publish a high-impact output without its review gate.

## Dual-spine standards anchor

- **Interoperability / digital thread:** ISO 23247 (incl. the emerging Part 5
  digital-thread), ISO/IEC 30173 (terminology), Asset Administration Shell
  (IEC 63278), DTDL, W3C WoT, ISO 10303 STEP/AP242, QIF (ISO 23952). Cite
  published as normative, emerging as emerging.
- **Governance values:** the Gemini Principles (CDBB, 2018) — Purpose
  (public good, value creation, insight), Trust (security, openness, quality),
  Function (federation, curation, evolution). "Federation" requires the standard
  connected environment the interoperability spine provides.

## Composition

Composes with `management/privacy-by-design` (personal/civic data) and with
subject-matter domains. The lead built-environment stack is
`domains/aec-iso19650-im` × `management/digital-twin` × `management/privacy-by-design`
(see `platform/compositions/digital-twin-prototype.yaml`).

## Sensitive Paths and Companion Rules

Registers scenario/model/agent/dataset/run-state/public-scenario patterns; changes
touching them require a twin-artifact update or an ADR. twin-profile maturity or
conformance changes require a change-log entry or ADR. Reviewers confirm the
declared maturity still holds.

## When to activate

Activate for projects that model real-world systems or run scenarios for
decision support. Not needed for projects that merely visualize data (a dashboard
is not a twin) or do no scenario modeling.
