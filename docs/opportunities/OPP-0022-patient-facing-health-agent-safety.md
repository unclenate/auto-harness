<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0022 — Patient-Facing Health-Agent Safety

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-24
**Last Updated:** 2026-05-24
**Confidence:** medium-high

---

## Thesis

OPP-0013's `domains/healthcare-*` family was derived entirely from OpenEMR
— a **provider/operator-side** EHR. Its sub-modules govern *running a
health system's software*: FHIR server, HL7 v2, CCDA, ePrescribing,
audit-log, EHI-export. None govern the **patient-facing health agent** —
software that acts *for a patient* on their own health data, where the
safety concerns are different in kind.

Add a patient-side counterpart — initial bias: a
`domains/healthcare-patient-agent` sub-module within the OPP-0013 family —
governing the safety surface a patient-facing health agent must implement:

| Concern | What it governs |
|---|---|
| Triage / red-flag gating | Scan for emergency red flags and redirect to emergency services *before* any other action |
| Draft-never-send | Clinical communications (portal messages, amendment requests) are drafts a human sends, never auto-sent |
| Non-diagnostic stance | The agent supports literacy and communication; it does not diagnose or recommend treatment — as an enforced posture, not a footer disclaimer |
| PHI workspace boundary | Patient data is confined to a scoped workspace; never embedded in skills/prompts/fixtures |
| Indirect-injection via ingestion | Health content arrives from untrusted channels (forwarded email, uploaded PDFs); the agent must assume injected instructions and gate accordingly |

## Origin / Evidence

- **Consumer project: Tula (`github.com/unclenate/tula` fork).** Brownfield
  onboarding 2026-05-24; gap analysis §TG4. Concrete patterns:
  triage-first red-flag gating with a 911 redirect before drafting
  (`skills/epic-note/references/triage-rules.md`); draft-never-send
  (`skills/epic-note/`, `skills/request-amendment/`); non-diagnostic stance
  as an operating principle (`docs/principles.md` § "AI-Assisted
  Interpretation, Not Clinical Diagnosis"); PHI confined to workspace caches
  (`.health-records-cache/`, `.med-pdf-cache/`); transport-layer
  sender-allowlist against indirect injection
  (`docs/security-model.md`, `docs/email-router-design.md`);
  clinical-significance tiering (`skills/memory-diff/references/clinical-significance.md`).
- **External signal.** The patient-facing health-agent pattern is being
  pioneered by the SMART-on-FHIR community itself —
  [`jmandel/health-skillz`](https://github.com/jmandel/health-skillz)
  (Josh Mandel, SMART co-creator), the SMART ecosystem
  ([`smart-on-fhir`](https://github.com/smart-on-fhir),
  [`smart-fetch`](https://github.com/smart-on-fhir/smart-fetch),
  [`gotdan`](https://github.com/gotdan)). Patient-authorized data access is
  a standards-backed, actively-developed surface, not a fringe case.
- **Why OPP-0013 does not cover it.** Its 12 sub-modules are operator-side
  capability surfaces. A patient agent consumes FHIR (as a client) rather
  than serving it, drafts rather than transmits clinical data, and crosses
  an untrusted-ingestion boundary that an internal EHR does not. These are
  orthogonal concerns, not a subset.
- **Why `domains/agentic-interfaces` does not cover it.** That domain
  governs prompt-injection / action-approval for in-product agent UIs
  *generically*; it has no notion of triage gating, non-diagnostic posture,
  or clinical-communication draft-not-send. This OPP is the health
  specialization that sits *with* it.

## Why Now

- **Patient-facing health agents are arriving fast**, backed by patient-
  access mandates (US ONC info-blocking / Cures Act; EU **European Health
  Data Space (EHDS)** secondary-use and patient-access rules). Governance
  for them should exist before the pattern proliferates ungoverned.
- **Completes the healthcare picture.** OPP-0013 saw only the operator side;
  Tula is the second healthcare consumer OPP-0013's own Risks section asked
  for, and it reveals the patient side as a first-class half of the domain.

## Risks / Open Questions

- **US-healthcare bias is a first-class risk for this whole family.** Both
  healthcare evidence points to date are American — OpenEMR (ONC/HIPAA) and
  Tula (Epic MyChart, HIPAA §164.526). There is a real danger of baking the
  cultural and economic assumptions of the **US** health system (its payer
  model, its certification regime, its consent and amendment law, MyChart as
  the canonical portal, US Core as the canonical profile) into module shapes
  as if they were universal. **Mitigation, required before this module's
  shape is frozen:** seek international second-evidence — patient-access and
  care-setting software from Europe (EHDS, national portals), the Near East,
  and the Far East — and design required artifacts around *concepts*
  (red-flag triage, draft-not-send, patient-as-resource-owner) that hold
  cross-jurisdiction, with realm-specific law (HIPAA §164.526, GDPR/EHDS
  rectification rights, etc.) carried as *fill-in* references, never
  hard-coded. The non-diagnostic stance, in particular, must not encode a
  single jurisdiction's medical-device or liability framing.
- **Sub-module vs cross-cutting overlay.** Patient-agent safety could be a
  `domains/healthcare-*` sub-module, or a cross-cutting overlay that
  composes with `domains/agentic-interfaces`. Bias: sub-module within the
  healthcare family, declaring a soft dependency on `agentic-interfaces`
  when an in-product UI is present.
- **Triage gating is safety-critical and easy to fake.** A reviewGate must
  verify the red-flag path is real and tested (an eval `should-not-trigger`
  / `triage-override` case — ties to OPP-0019), not a disclaimer string.
- **Single (US) evidence point.** As above — high enough confidence to file
  and frame the bias guardrail, not high enough to freeze artifacts.

## Disposition

<!-- Empty: status is proposed -->

## Promotion

<!-- Empty: not yet accepted -->

## Related

- Gap analysis source: consumer project (`tula`) at
  `docs/knowledge/harness-coverage-gap-analysis.md` §TG4
- Patient-side counterpart to: [OPP-0013](OPP-0013-domain-family-healthcare-decomposed.md)
  (operator/server-side healthcare family) and its augmentation for the
  patient-authorized-client SMART role (see OPP-0013/0016 Origin/Evidence)
- Composes with: `platform/profiles/domains/agentic-interfaces/`
  (generic agent-UI safety), [OPP-0019](OPP-0019-eval-gated-testing-posture.md)
  (triage gating verified by evals)
- External: HL7 FHIR (`github.com/HL7/fhir`), SMART on FHIR
  (`github.com/smart-on-fhir`, `smart-on-fhir.github.io`,
  `smart-on-fhir/smart-fetch`), `github.com/jmandel/health-skillz`,
  `github.com/jmandel`, `github.com/gotdan`
- Bias guardrail feeds: `docs/knowledge/shared-observations.md`
  (US-healthcare-bias architectural observation, filed alongside this OPP)
