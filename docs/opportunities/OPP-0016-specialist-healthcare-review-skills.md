<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# OPP-0016 — Specialist Healthcare-Review Skill Family

**Status:** proposed
**Owner:** @unclenate
**Created:** 2026-05-24
**Last Updated:** 2026-05-24 *(augmented: Tula patient-client role refines harness-fhir/harness-smart scope; US-bias guardrail — see §TG5, OPP-0022)*
**Confidence:** medium

---

## Thesis

OPP-0013 proposes a broad `harness-healthcare` skill — healthcare-codebase
onboarding & code-review, loaded on demand when any `domains/healthcare-*`
sub-module is active. That skill is right-sized for *onboarding* a
healthcare codebase, but too broad for deep specialist work.

When a downstream consumer (or a canonization session) asks "audit this
FHIR endpoint set against US Core 8.0 conformance," "verify these HL7 v2
ADT message handlers cover the required segments," "review this audit
log for HITECH compliance," or "review this cipher-suite implementation
against modern best practices," the broad skill gives surface-level
guidance only. The work needs a specialist skill that knows the
specific standard, common pitfalls, and validation criteria.

Add a specialist skill family that refines the broad `harness-healthcare`
skill from OPP-0013:

| Skill | Triggers when | Purpose |
|---|---|---|
| `harness-fhir` | `domains/healthcare-fhir` active and task mentions FHIR | Assess FHIR R4 conformance: resources, profiles (US Core, IPS), interactions (CRUD/search/history), Bulk Data Export |
| `harness-hl7v2` | `domains/healthcare-hl7v2` active and task mentions HL7 v2 | Assess HL7 v2 message-type coverage (ADT, ORM, ORU, MDM, …), segment population, MLLP transport |
| `harness-onc-certification` | `ci/inferno/` present, or `domains/healthcare-fhir` + ONC certification mentioned | Assess ONC G10 readiness, Inferno integration check, certification-blocker triage |
| `harness-phi-audit` | Any `domains/healthcare-*` active and task mentions PHI / logs / errors | Scan a codebase for PHI-handling patterns, flag potential leaks (PHI in logs, PHI in error messages, missing audit-log calls around PHI access) |
| `harness-encryption-review` | `domains/healthcare-phi-encryption` active or task mentions encryption | Review a cryptographic implementation against modern best practices: cipher choice, key rotation, key storage, IV handling, HMAC presence |
| `harness-rbac-review` | `src/Gacl/` present, or task mentions ACL/RBAC | Review an ACL/RBAC implementation for completeness: default-deny, scope hierarchy, scope-to-action mapping, audit of permission checks |

These are deliberately narrow. Each addresses a recognizable specialist
review task that the broad `harness-healthcare` skill can hand off to.
Together they form a refinement tier — adopted incrementally as the
underlying domain modules ship and as specific review needs surface in
practice.

## Origin / Evidence

- **Consumer project: OpenEMR (`https://github.com/openemr/openemr`).**
  Brownfield onboarding session 2026-05-24 produced a gap analysis at
  `docs/knowledge/harness-coverage-gap-analysis.md` § G14, G15.

- **Code-level evidence in OpenEMR for each specialist's scope:**
  - **FHIR:** `src/FHIR/R4/`, `src/Services/FHIR/` (per-resource Service
    classes for Organization, Patient, Observation, Condition, etc.),
    `apis/` (routing), `src/FHIR/Export/` (Bulk Data Export)
  - **HL7 v2:** `aranyasen/hl7 ^3.2.2` Composer dependency
  - **ONC certification:** `ci/inferno/onc-certification-g10-test-kit/`
    submodule, `ci/inferno/run.sh`
  - **PHI audit:** `src/Common/Logging/Audit/`, `EventAuditLogger`,
    `BreakglassChecker`, `BreakglassCheckerInterface`
  - **Encryption review:** `src/Encryption/` (CipherSuite,
    Aes256CbcHmacSha384 / Aes256CbcHmacSha256, Plaintext/Ciphertext/
    Message, Keychain/KeyMaterial with two storage strategies)
  - **RBAC review:** `gacl/` (the gacl-php library; OpenEMR
    customization), `src/Gacl/GaclApi.php`, `src/Gacl/GaclAdminApi.php`,
    `src/Gacl/Gacl.php`

  Every skill has concrete subsystem evidence; nothing is speculative.

- **Second consumer refines `harness-fhir` / `harness-smart` scope: Tula
  (`github.com/unclenate/tula` fork).** Gap analysis §TG5. OpenEMR exercises
  FHIR/SMART as a **server / provider-launch**; Tula's
  `skills/health-records` (from [`jmandel/health-skillz`](https://github.com/jmandel/health-skillz),
  SMART co-creator) exercises them as a **patient-authorized client**. A
  `harness-fhir` / `harness-smart` specialist must therefore cover *both*
  conformance lenses — server resource/profile coverage **and** patient-
  access scope correctness (`patient/*.read`, launch context, token
  audience). The SMART-on-FHIR community itself
  ([`smart-on-fhir`](https://github.com/smart-on-fhir),
  [`smart-fetch`](https://github.com/smart-on-fhir/smart-fetch),
  [`gotdan`](https://github.com/gotdan)) is the authority a `harness-smart`
  skill would encode.

- **The broad-vs-narrow tradeoff is structural.** Skills are loaded on
  demand based on description-match. A broad `harness-healthcare` skill
  has a description that matches many tasks; its content has to cover
  many concerns at shallow depth. Narrow specialist skills match fewer
  tasks but deeper. The harness's existing pattern (e.g., `harness-web3`
  for web3 work, `harness-mcp` for MCP server work) is narrow — this
  OPP applies the same shape to healthcare specializations.

- **Refinement layer, not foundation.** These skills layer *on top of*
  `harness-healthcare`. The broad skill onboards the codebase and routes
  to specialists when deeper work surfaces. Filing them as a separate
  OPP (rather than bundling into OPP-0013) keeps OPP-0013 focused on
  the foundational modules + templates + composition, and lets the
  specialists develop incrementally.

## Why Now

- **Confidence is medium because skill adoption is the validation
  question.** A skill no one invokes is dead weight. The harness's
  existing narrow skills (`harness-web3`, `harness-mcp`) have known
  consumers; the proposed specialist skills don't yet. Filing now
  documents the gap; PRD authoring should defer until the broader
  `harness-healthcare` skill (OPP-0013) lands and produces evidence
  about where specialist hand-off would help.

- **Incremental adoption is the natural model.** All six specialists
  don't need to ship together. The first specialist to develop is
  likely `harness-fhir` (highest external standard formality, clearest
  pass/fail criteria) or `harness-phi-audit` (clearest tripwire utility).
  Filing the whole family now anchors the design space; individual
  specialists develop as need surfaces.

- **Pairs with the canonization sessions.** Each OpenEMR canonization
  OPP (FHIR R4 server, HL7 v2 messaging, encryption keystore, etc.)
  is a natural prompt for invoking the matching specialist skill. The
  skill development can be driven by canonization-session feedback —
  a tight evidence loop the broader harness doesn't yet have for skill
  authoring.

## Risks / Open Questions

- **Six specialists is a lot of catalog surface.** Mitigation: the OPP
  proposes them as a *family with incremental ship*, not a single
  big-bang ship. PRD authoring should rank the six and ship the top
  two first; the rest stay as candidates until evidence supports them.

- **Description-overlap risk.** If `harness-healthcare` and
  `harness-fhir` both match "review this FHIR endpoint" tasks, the
  client may load both, wasting context. Mitigation: descriptions
  should be deliberately disjoint — `harness-healthcare` mentions
  "onboarding, broad survey, initial code-read"; `harness-fhir`
  mentions "conformance assessment, profile coverage,
  Bulk Data Export." Validation requires reading actual session
  transcripts.

- **`harness-rbac-review` isn't healthcare-specific.** OpenEMR's gacl
  is healthcare-adjacent but the RBAC techniques generalize. The skill
  might better belong under `harness-security` or `harness-auth` rather
  than the healthcare specialist family. PRD authoring should validate.

- **The specialist skills depend on the underlying modules being
  active.** A consumer project that uses `harness-fhir` but doesn't
  activate `domains/healthcare-fhir` is using the skill outside its
  declared scope. The harness's skill-trigger mechanism doesn't
  currently enforce module-activation as a precondition. Either the
  skill descriptions cope with under-activation, or the
  skill-trigger contract grows a module-precondition field — that's
  a harness-level decision separate from this OPP.

- **US-healthcare bias.** Like the rest of the healthcare family, both
  evidence points are American. A `harness-fhir` specialist must not assume
  US Core is *the* profile (it is a US-realm profile; IPS and national
  profiles exist), and `harness-onc-certification` is inherently
  US-specific — its international analogues (e.g. EU EHDS conformance) are
  distinct skills, not the same one renamed. Carry realm specificity
  explicitly. See the US-healthcare-bias observation in
  `docs/knowledge/shared-observations.md`.

## Disposition

<!-- Empty: status is proposed -->

## Promotion

<!-- Empty: not yet accepted -->

## Related

- Gap analysis source: consumer project (`openemr`) at
  `docs/knowledge/harness-coverage-gap-analysis.md` §§ G14, G15
- Foundation OPP: [OPP-0013](OPP-0013-domain-family-healthcare-decomposed.md)
  — this OPP is the refinement layer on top of OPP-0013's
  `harness-healthcare` broad skill
- Existing narrow skills (parallels): `platform/skills/harness-web3/`,
  `platform/skills/harness-mcp/`
- Patient-side counterpart + bias guardrail: [OPP-0022](OPP-0022-patient-facing-health-agent-safety.md)
- Second-consumer (patient-client) gap analysis: consumer project (`tula`)
  at `docs/knowledge/harness-coverage-gap-analysis.md` §TG5
- Companion OPPs filed in the same session (OpenEMR canonization):
  [OPP-0011](OPP-0011-stack-module-php.md),
  [OPP-0012](OPP-0012-data-module-relational-sql-engine-generalization.md),
  [OPP-0013](OPP-0013-domain-family-healthcare-decomposed.md),
  [OPP-0014](OPP-0014-polyglot-companion-services.md),
  [OPP-0015](OPP-0015-regulated-compliance-test-kits.md),
  [OPP-0017](OPP-0017-legacy-coexistence-template-family.md)
